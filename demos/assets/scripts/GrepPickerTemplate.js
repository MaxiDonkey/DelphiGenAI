/* =================================================================
   Grep picker template
   --------------------------------------------------------------
   Self-contained IIFE injected by Demo.Grep.Plugin.Service.

   Contract with the Delphi side
     window.__grepPickerPayload__   base64-encoded JSON:
       {
         pattern, root, count, truncated,
         matches: [{ id, file, line, snippet }, ...]
       }

     The picker decodes this payload once, builds a modal overlay,
     and lets the user tick the matches that should land in the
     prompt. On confirm it emits 'grep.pick'; on cancel it emits
     'grep.cancel'. Both events go through the standard custom-event
     channel:

       window.chrome.webview.postMessage({
         event:  "custom-event",
         name:   "grep.pick" | "grep.cancel",
         payload: { ... }
       });

     The picker carries the full match data back in the 'pick'
     payload (file, line, snippet) so the Delphi side does not need
     to re-correlate by id.

   Why no LoadCustomTemplate
     The picker is transient: it is created on demand by the plugin
     and removed once the user has answered. Wiring it through
     ITemplateProvider would tie its lifecycle to the WebView load
     cycle. ExecuteScript injection keeps it under the plugin's
     control.
   ================================================================= */

(() => {
  const OVERLAY_ID = "__grep_picker_overlay__";
  const STYLE_ID   = "__grep_picker_style__";
  const EVENT_NAME = "custom-event";

  /* ---------------- payload bootstrap ---------------- */

  function decodePayload() {
    try {
      const b64 = window.__grepPickerPayload__ || "";
      const raw = atob(b64);
      const utf8 = decodeURIComponent(escape(raw));
      const obj = JSON.parse(utf8);

      if (!obj || !Array.isArray(obj.matches)) {
        return null;
      }

      return obj;
    } catch (e) {
      console.warn("[grep-picker] payload decode failed:", e);
      return null;
    }
  }

  const data = decodePayload();
  if (!data) {
    return;
  }

  /* ---------------- DOM cleanup ---------------- */

  function removeExisting() {
    const previous = document.getElementById(OVERLAY_ID);

    if (!previous) {
      return;
    }

    if (typeof previous.__grepReleaseScrollTrap === "function") {
      previous.__grepReleaseScrollTrap();
      previous.__grepReleaseScrollTrap = null;
    }

    if (previous.parentNode) {
      previous.parentNode.removeChild(previous);
    }
  }

  /* ---------------- styles ---------------- */

  function ensureStyles() {
    if (document.getElementById(STYLE_ID)) {
      return;
    }

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      #${OVERLAY_ID} {
        --grep-overlay-bg: rgba(0, 0, 0, 0.35);
        --grep-modal-bg: var(--input-shell-bg, var(--bg-main, #2f2f2f));
        --grep-panel-bg: var(--input-menu-bg, var(--grep-modal-bg));
        --grep-input-bg: var(--bg-main, rgba(255, 255, 255, 0.04));
        --grep-row-hover-bg: var(--input-menu-item-hover-bg, rgba(255, 255, 255, 0.08));
        --grep-text: var(--text-main, #ddd);
        --grep-muted: var(--input-welcome-text, #cfd4dc);
        --grep-border: var(--input-shell-border, rgba(255, 255, 255, 0.08));
        --grep-shadow: var(--input-shell-shadow, 0 10px 30px rgba(0, 0, 0, 0.35));
        --grep-accent: var(--link, #58a6ff);
        --grep-accent-hover: var(--link-hover, #1f6feb);
        --grep-primary-bg: var(--bubble-user-bg, #256EB8);
        --grep-primary-text: var(--bubble-user-text, #ffffff);
        --grep-button-bg: var(--input-button-bg, #3a3a3a);
        --grep-button-text: var(--input-button-text, #ffffff);
        --grep-button-hover-bg: var(--input-button-hover-bg, #ffffff);
        --grep-button-hover-text: var(--input-button-hover-text, #111111);
        --grep-inline-code-bg: var(--inline-code-bg, rgba(255, 255, 255, 0.075));
        --grep-inline-code-border: var(--inline-code-border, rgba(255, 255, 255, 0.10));
        --grep-warning: var(--alert-warning, #d29922);
        --grep-highlight-bg: rgba(210, 153, 34, 0.22);
        --grep-highlight-text: var(--grep-text);
        --grep-disabled-bg: var(--input-button-bg, rgba(120, 120, 140, 0.40));
        --grep-disabled-text: var(--input-welcome-text, rgba(255, 255, 255, 0.55));

        position: fixed;
        inset: 0;
        z-index: 2147483647;
        box-sizing: border-box;
        padding: 16px;
        background: var(--grep-overlay-bg);
        color: var(--grep-text);
        display: flex;
        align-items: center;
        justify-content: center;
        font-family: "Segoe UI", ui-sans-serif, system-ui, -apple-system,
                     Roboto, sans-serif;
        overscroll-behavior: contain;
      }

      [data-theme="light"] #${OVERLAY_ID} {
        --grep-overlay-bg: rgba(17, 24, 39, 0.20);
        --grep-highlight-bg: rgba(221, 170, 0, 0.24);
      }

      #${OVERLAY_ID},
      #${OVERLAY_ID} * {
        box-sizing: border-box;
      }

      #${OVERLAY_ID} .grep-modal {
        width: min(820px, 92vw);
        max-height: min(86vh, calc(100vh - 32px));
        background: var(--grep-modal-bg);
        color: var(--grep-text);
        border: 1px solid var(--grep-border);
        border-radius: 14px;
        box-shadow: var(--grep-shadow);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        overscroll-behavior: contain;
      }

      #${OVERLAY_ID} .grep-head {
        padding: 14px 18px;
        border-bottom: 1px solid var(--grep-border);
        background: var(--grep-modal-bg);
        display: flex;
        flex-direction: column;
        gap: 4px;
      }

      #${OVERLAY_ID} .grep-head .title {
        color: var(--grep-text);
        font-weight: 600;
        font-size: 15px;
        line-height: 1.35;
      }

      #${OVERLAY_ID} .grep-head .meta {
        color: var(--grep-muted);
        font-size: 12px;
        line-height: 1.45;
        word-break: break-all;
      }

      #${OVERLAY_ID} .grep-head code {
        padding: 1px 5px;
        border: 1px solid var(--grep-inline-code-border);
        border-radius: 6px;
        background: var(--grep-inline-code-bg);
        color: var(--grep-text);
        font: 12px/1.4 "JetBrains Mono", "Cascadia Code", Consolas,
              ui-monospace, monospace;
      }

      #${OVERLAY_ID} .grep-toolbar {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 10px 18px;
        border-bottom: 1px solid var(--grep-border);
        background: var(--grep-modal-bg);
        font-size: 12px;
      }

      #${OVERLAY_ID} .grep-toolbar input[type="search"] {
        flex: 1 1 auto;
        min-width: 0;
        padding: 8px 10px;
        border: 1px solid var(--grep-border);
        border-radius: 10px;
        background: var(--grep-input-bg);
        color: var(--grep-text);
        outline: none;
        font: inherit;
        appearance: none;
        -webkit-appearance: none;
        transition:
          border-color 140ms ease,
          background 140ms ease,
          box-shadow 140ms ease;
      }

      #${OVERLAY_ID} .grep-toolbar input[type="search"]::placeholder {
        color: var(--grep-muted);
        opacity: 1;
      }

      #${OVERLAY_ID} .grep-toolbar input[type="search"]:focus {
        border-color: var(--grep-accent);
        box-shadow: 0 0 0 2px color-mix(in srgb, var(--grep-accent) 22%, transparent);
      }

      #${OVERLAY_ID} .grep-toolbar .grep-counter {
        color: var(--grep-muted);
        white-space: nowrap;
      }

      #${OVERLAY_ID} .grep-list {
        flex: 1 1 auto;
        min-height: 0;
        padding: 8px 6px 8px 12px;
        overflow-y: auto;
        overflow-x: hidden;
        background: var(--grep-modal-bg);
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb, #4a4a4a) transparent;
        overscroll-behavior: contain;
      }

      #${OVERLAY_ID} .grep-list::-webkit-scrollbar {
        width: 10px;
      }

      #${OVERLAY_ID} .grep-list::-webkit-scrollbar-track {
        background: transparent;
      }

      #${OVERLAY_ID} .grep-list::-webkit-scrollbar-thumb {
        background: var(--scrollbar-thumb, #4a4a4a);
        border: 2px solid transparent;
        border-radius: 999px;
        background-clip: padding-box;
      }

      #${OVERLAY_ID} .grep-list::-webkit-scrollbar-thumb:hover {
        background: var(--scrollbar-thumb-hover, #6a6a6a);
        border: 2px solid transparent;
        background-clip: padding-box;
      }

      #${OVERLAY_ID} .grep-file {
        margin: 8px 4px;
      }

      #${OVERLAY_ID} .grep-file-head {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 6px 6px;
        border-radius: 8px;
        color: var(--grep-text);
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        user-select: none;
      }

      #${OVERLAY_ID} .grep-file-head:hover {
        background: var(--grep-row-hover-bg);
      }

      #${OVERLAY_ID} .grep-file-head .grep-path {
        min-width: 0;
        color: var(--grep-accent);
        font-family: "JetBrains Mono", "Cascadia Code", Consolas,
                     ui-monospace, monospace;
        font-size: 12.5px;
        line-height: 1.45;
        word-break: break-all;
      }

      #${OVERLAY_ID} .grep-file-head .grep-fcount {
        color: var(--grep-muted);
        font-weight: 400;
        font-size: 11.5px;
        line-height: 1;
      }

      #${OVERLAY_ID} .grep-row {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        padding: 5px 8px 5px 26px;
        border-radius: 8px;
        color: var(--grep-text);
        font-family: "JetBrains Mono", "Cascadia Code", Consolas,
                     ui-monospace, monospace;
        font-size: 12px;
        line-height: 1.5;
      }

      #${OVERLAY_ID} .grep-row:hover {
        background: var(--grep-row-hover-bg);
      }

      #${OVERLAY_ID} .grep-row .grep-line {
        min-width: 44px;
        color: var(--grep-muted);
        text-align: right;
        user-select: none;
      }

      #${OVERLAY_ID} .grep-row .grep-snippet {
        flex: 1 1 auto;
        min-width: 0;
        white-space: pre-wrap;
        overflow-wrap: anywhere;
        word-break: break-word;
      }

      #${OVERLAY_ID} .grep-row .grep-hl {
        padding: 0 2px;
        border-radius: 3px;
        background: var(--grep-highlight-bg);
        color: var(--grep-highlight-text);
      }

      #${OVERLAY_ID} .grep-foot {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 12px 18px 14px 18px;
        border-top: 1px solid var(--grep-border);
        background: var(--grep-modal-bg);
        font-size: 13px;
      }

      #${OVERLAY_ID} .grep-foot .grep-summary {
        color: var(--grep-muted);
      }

      #${OVERLAY_ID} .grep-foot .grep-actions {
        display: flex;
        align-items: center;
        gap: 8px;
      }

      #${OVERLAY_ID} button {
        min-width: 0;
        padding: 8px 14px;
        border: 1px solid var(--grep-border);
        border-radius: 10px;
        background: var(--grep-button-bg);
        color: var(--grep-button-text);
        font: inherit;
        line-height: 1.2;
        cursor: pointer;
        appearance: none;
        -webkit-appearance: none;
        transition:
          background 140ms ease,
          color 140ms ease,
          border-color 140ms ease,
          transform 120ms ease,
          opacity 120ms ease;
      }

      #${OVERLAY_ID} button:hover,
      #${OVERLAY_ID} button:focus-visible {
        background: var(--grep-button-hover-bg);
        color: var(--grep-button-hover-text);
        outline: none;
      }

      #${OVERLAY_ID} button:active {
        transform: scale(0.96);
      }

      #${OVERLAY_ID} button.primary {
        border-color: var(--grep-primary-bg);
        background: var(--grep-primary-bg);
        color: var(--grep-primary-text);
      }

      #${OVERLAY_ID} button.primary:hover,
      #${OVERLAY_ID} button.primary:focus-visible {
        border-color: var(--grep-accent-hover);
        background: var(--grep-accent-hover);
        color: var(--grep-primary-text);
        outline: none;
      }

      #${OVERLAY_ID} button.primary:disabled,
      #${OVERLAY_ID} button.primary:disabled:hover,
      #${OVERLAY_ID} button.primary:disabled:focus-visible {
        border-color: var(--grep-border);
        background: var(--grep-disabled-bg);
        color: var(--grep-disabled-text);
        cursor: not-allowed;
        opacity: 0.70;
        transform: none;
      }

      #${OVERLAY_ID} input[type="checkbox"] {
        margin-top: 2px;
        cursor: pointer;
        accent-color: var(--grep-accent);
      }

      #${OVERLAY_ID} .grep-truncated {
        margin: 8px 12px 6px 12px;
        padding: 7px 10px;
        border-left: 3px solid var(--grep-warning);
        border-radius: 8px;
        background: color-mix(in srgb, var(--grep-warning) 14%, transparent);
        color: var(--grep-text);
        font-size: 12px;
        line-height: 1.45;
      }

      @media (max-width: 640px) {
        #${OVERLAY_ID} {
          padding: 10px;
          align-items: stretch;
        }

        #${OVERLAY_ID} .grep-modal {
          width: 100%;
          max-height: calc(100vh - 20px);
        }

        #${OVERLAY_ID} .grep-toolbar,
        #${OVERLAY_ID} .grep-foot {
          align-items: stretch;
          flex-direction: column;
        }

        #${OVERLAY_ID} .grep-foot .grep-actions {
          justify-content: flex-end;
        }
      }
    `;
    document.head.appendChild(style);
  }

  /* ---------------- helpers ---------------- */

  function escapeHtml(s) {
    const text = String(s == null ? "" : s);
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function highlightSnippet(snippet, pattern) {
    const safe = escapeHtml(snippet);
    if (!pattern) {
      return safe;
    }

    const lowerSafe = safe.toLowerCase();
    const lowerPat = pattern.toLowerCase();

    const out = [];
    let cursor = 0;

    while (true) {
      const found = lowerSafe.indexOf(lowerPat, cursor);
      if (found < 0) {
        out.push(safe.substring(cursor));
        break;
      }
      out.push(safe.substring(cursor, found));
      out.push(
        '<span class="grep-hl">' +
        safe.substring(found, found + lowerPat.length) +
        "</span>"
      );
      cursor = found + lowerPat.length;
    }

    return out.join("");
  }

  function postEvent(name, payload) {
    try {
      window.chrome.webview.postMessage({
        event:   EVENT_NAME,
        name:    name,
        payload: payload || {}
      });
    } catch (e) {
      console.warn("[grep-picker] postMessage failed:", e);
    }
  }

  function grepIsScrollableY(element) {
    if (!element || element === document.body || element === document.documentElement) {
      return false;
    }

    const style = window.getComputedStyle(element);
    const overflowY = style.overflowY;

    if (overflowY !== "auto" && overflowY !== "scroll" && overflowY !== "overlay") {
      return false;
    }

    return element.scrollHeight > element.clientHeight + 1;
  }

  function grepFindScrollableYInside(root, start) {
    let element = start;

    while (element && element !== document.body && element !== document.documentElement) {
      if (root.contains(element) && grepIsScrollableY(element)) {
        return element;
      }

      if (element === root) {
        break;
      }

      element = element.parentElement;
    }

    return null;
  }

  function grepShouldCaptureScroll(root, eventTarget, deltaY) {
    const scrollable = grepFindScrollableYInside(root, eventTarget);

    if (!scrollable) {
      return true;
    }

    if (deltaY < 0 && scrollable.scrollTop <= 0) {
      return true;
    }

    if (
      deltaY > 0 &&
      scrollable.scrollTop + scrollable.clientHeight >= scrollable.scrollHeight - 1
    ) {
      return true;
    }

    return false;
  }

  function grepBindScrollTrap(root) {
    let lastTouchY = 0;

    function onWheel(event) {
      if (!root.contains(event.target)) {
        return;
      }

      if (grepShouldCaptureScroll(root, event.target, event.deltaY)) {
        event.preventDefault();
      }

      event.stopPropagation();
    }

    function onTouchStart(event) {
      if (!root.contains(event.target) || event.touches.length !== 1) {
        return;
      }

      lastTouchY = event.touches[0].clientY;
    }

    function onTouchMove(event) {
      if (!root.contains(event.target) || event.touches.length !== 1) {
        return;
      }

      const currentTouchY = event.touches[0].clientY;
      const deltaY = lastTouchY - currentTouchY;

      lastTouchY = currentTouchY;

      if (grepShouldCaptureScroll(root, event.target, deltaY)) {
        event.preventDefault();
      }

      event.stopPropagation();
    }

    root.addEventListener("wheel", onWheel, { passive: false });
    root.addEventListener("touchstart", onTouchStart, { passive: true });
    root.addEventListener("touchmove", onTouchMove, { passive: false });

    return function releaseScrollTrap() {
      root.removeEventListener("wheel", onWheel);
      root.removeEventListener("touchstart", onTouchStart);
      root.removeEventListener("touchmove", onTouchMove);
    };
  }

  /* ---------------- rendering ---------------- */

  function groupByFile(matches) {
    const groups = new Map();
    matches.forEach((m) => {
      if (!groups.has(m.file)) {
        groups.set(m.file, []);
      }
      groups.get(m.file).push(m);
    });
    return groups;
  }

  function build(matches) {
    const overlay = document.createElement("div");
    overlay.id = OVERLAY_ID;

    const modal = document.createElement("div");
    modal.className = "grep-modal";
    overlay.appendChild(modal);

    /* head */
    const head = document.createElement("div");
    head.className = "grep-head";
    head.innerHTML = `
      <div class="title">Grep — pick the matches you want as context</div>
      <div class="meta">
        Pattern <code>${escapeHtml(data.pattern)}</code>
        &middot; ${matches.length} match${matches.length === 1 ? "" : "es"}
        &middot; <span title="${escapeHtml(data.root)}">${escapeHtml(
          data.root)}</span>
      </div>
    `;
    modal.appendChild(head);

    /* toolbar */
    const toolbar = document.createElement("div");
    toolbar.className = "grep-toolbar";
    toolbar.innerHTML = `
      <input type="search" placeholder="Filter by file or text…"
             aria-label="Filter matches" />
      <span class="grep-counter">0 selected</span>
    `;
    modal.appendChild(toolbar);

    /* truncated banner */
    if (data.truncated) {
      const banner = document.createElement("div");
      banner.className = "grep-truncated";
      banner.textContent =
        "Result set was truncated. Narrow the pattern or use a sub-path.";
      modal.appendChild(banner);
    }

    /* list */
    const list = document.createElement("div");
    list.className = "grep-list";
    modal.appendChild(list);

    const groups = groupByFile(matches);
    groups.forEach((group, fileName) => {
      const fileBlock = document.createElement("div");
      fileBlock.className = "grep-file";
      fileBlock.dataset.file = fileName;

      const fileHead = document.createElement("div");
      fileHead.className = "grep-file-head";
      fileHead.innerHTML = `
        <input type="checkbox" class="grep-file-toggle"
               aria-label="Toggle all matches in ${escapeHtml(fileName)}">
        <span class="grep-path">${escapeHtml(fileName)}</span>
        <span class="grep-fcount">${group.length}</span>
      `;
      fileBlock.appendChild(fileHead);

      const rowsHost = document.createElement("div");
      rowsHost.className = "grep-rows";
      fileBlock.appendChild(rowsHost);

      group.forEach((m) => {
        const row = document.createElement("label");
        row.className = "grep-row";
        row.dataset.matchId = String(m.id);
        row.innerHTML = `
          <input type="checkbox" class="grep-row-cb" data-id="${m.id}">
          <span class="grep-line">L${m.line}</span>
          <span class="grep-snippet">${highlightSnippet(m.snippet,
            data.pattern)}</span>
        `;
        rowsHost.appendChild(row);
      });

      list.appendChild(fileBlock);
    });

    /* foot */
    const foot = document.createElement("div");
    foot.className = "grep-foot";
    foot.innerHTML = `
      <span class="grep-summary">Esc cancels &middot;
        Ctrl+Enter injects</span>
      <span class="grep-actions">
        <button class="grep-cancel">Cancel</button>
        <button class="grep-confirm primary" disabled>Inject as context</button>
      </span>
    `;
    modal.appendChild(foot);

    return { overlay, toolbar, list, foot };
  }

  /* ---------------- behaviour ---------------- */

  function activate(parts, matches) {
    const filterInput = parts.toolbar.querySelector('input[type="search"]');
    const counter     = parts.toolbar.querySelector(".grep-counter");
    const confirmBtn  = parts.foot.querySelector(".grep-confirm");
    const cancelBtn   = parts.foot.querySelector(".grep-cancel");

    const matchById = new Map();
    matches.forEach((m) => matchById.set(m.id, m));

    function rowCheckboxes() {
      return parts.list.querySelectorAll(".grep-row-cb");
    }

    function selectedIds() {
      const ids = [];
      rowCheckboxes().forEach((cb) => {
        if (cb.checked) {
          const visibleRow = cb.closest(".grep-row");
          if (visibleRow && visibleRow.style.display !== "none") {
            ids.push(parseInt(cb.dataset.id, 10));
          }
        }
      });
      return ids;
    }

    function refreshCounter() {
      const n = selectedIds().length;
      counter.textContent =
        n + " selected";
      confirmBtn.disabled = n === 0;
    }

    /* per-row toggle */
    parts.list.addEventListener("change", (ev) => {
      const target = ev.target;
      if (!(target instanceof HTMLInputElement)) {
        return;
      }
      if (target.classList.contains("grep-row-cb")) {
        refreshCounter();

        /* sync the per-file toggle */
        const fileBlock = target.closest(".grep-file");
        if (fileBlock) {
          const fileToggle = fileBlock.querySelector(".grep-file-toggle");
          const rows = fileBlock.querySelectorAll(".grep-row-cb");
          const all = Array.from(rows).every((r) => r.checked);
          const none = Array.from(rows).every((r) => !r.checked);
          fileToggle.checked = all;
          fileToggle.indeterminate = !all && !none;
        }
        return;
      }

      if (target.classList.contains("grep-file-toggle")) {
        const fileBlock = target.closest(".grep-file");
        if (!fileBlock) return;
        const rows = fileBlock.querySelectorAll(".grep-row-cb");
        rows.forEach((r) => { r.checked = target.checked; });
        target.indeterminate = false;
        refreshCounter();
      }
    });

    /* filter */
    filterInput.addEventListener("input", () => {
      const q = filterInput.value.trim().toLowerCase();
      parts.list.querySelectorAll(".grep-file").forEach((fb) => {
        const fileName = (fb.dataset.file || "").toLowerCase();
        let visibleCount = 0;
        fb.querySelectorAll(".grep-row").forEach((row) => {
          if (q.length === 0) {
            row.style.display = "";
            visibleCount++;
            return;
          }
          const text = row.textContent.toLowerCase();
          const matches =
            text.indexOf(q) >= 0 ||
            fileName.indexOf(q) >= 0;
          row.style.display = matches ? "" : "none";
          if (matches) visibleCount++;
        });
        fb.style.display = visibleCount === 0 ? "none" : "";
      });
      refreshCounter();
    });

    /* confirm */
    function confirm() {
      const ids = selectedIds();
      if (ids.length === 0) return;

      const picked = ids.map((id) => {
        const m = matchById.get(id);
        return m
          ? { file: m.file, line: m.line, snippet: m.snippet }
          : null;
      }).filter(Boolean);

      postEvent("grep.pick", {
        pattern:  data.pattern,
        root:     data.root,
        selected: picked
      });

      teardown();
    }

    /* cancel */
    function cancel() {
      postEvent("grep.cancel", { pattern: data.pattern });
      teardown();
    }

    confirmBtn.addEventListener("click", confirm);
    cancelBtn.addEventListener("click", cancel);
    parts.overlay.addEventListener("click", (ev) => {
      if (ev.target === parts.overlay) cancel();
    });

    function onKey(e) {
      if (e.key === "Escape") {
        e.preventDefault();
        cancel();
      } else if (e.key === "Enter" && (e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        if (!confirmBtn.disabled) confirm();
      }
    }
    document.addEventListener("keydown", onKey, true);

    function teardown() {
      document.removeEventListener("keydown", onKey, true);
      window.__grepPickerPayload__ = "";
      removeExisting();
    }

    refreshCounter();
    setTimeout(() => filterInput.focus(), 0);
  }

  /* ---------------- mount ---------------- */

  removeExisting();
  ensureStyles();

  const parts = build(data.matches);

  document.body.appendChild(parts.overlay);

  parts.overlay.__grepReleaseScrollTrap = grepBindScrollTrap(parts.overlay);

  activate(parts, data.matches);
})();