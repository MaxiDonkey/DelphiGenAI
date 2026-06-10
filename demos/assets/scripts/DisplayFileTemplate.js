(() => {

  function translateDisplayFileText(key, fallback, vars) {
    if (window.AppI18n && typeof window.AppI18n.t === "function") {
      return window.AppI18n.t(key, fallback, vars);
    }

    const source = String(fallback == null ? "" : fallback);

    return source.replace(/\{([a-zA-Z0-9_]+)\}/g, function (_, token) {
      if (vars && Object.prototype.hasOwnProperty.call(vars, token)) {
        const value = vars[token];
        return value == null ? "" : String(value);
      }

      return "{" + token + "}";
    });
  }

  try {
    const files = %s;
    const pairId = %s;

    const FILE_CARD_WIDTH = 300;
    const FILE_CARD_MIN_HEIGHT = 60;

    const DISPLAY_FILE_I18N_EVENT =
      window.AppI18n && window.AppI18n.eventName
        ? window.AppI18n.eventName
        : "app:i18n:changed";

    const t = translateDisplayFileText;

    function getFallbackFileName(index) {
      return t("displayFile.fallbackName", "File {index}", {
        index: (Number(index) || 0) + 1
      });
    }

    function applyDisplayFileCardDictionary(card) {
      if (!card) {
        return;
      }

      if (card.__labelNode) {
        card.__labelNode.textContent = extractFileName(card.__fullPath, card.__fileIndex);
        card.__labelNode.title = String(card.__fullPath || "");
      }

      if (card.__status) {
        card.__status.textContent = getStatusText(card.__extension);
      }

      if (card.__iconGlyph) {
        card.__iconGlyph.textContent = getFileBadge(card.__group);
      }
    }

    function applyDisplayFileDictionary() {
      const cards = document.querySelectorAll('[data-display-file-card="1"]');

      cards.forEach(function (card) {
        applyDisplayFileCardDictionary(card);
      });
    }

    const FILE_GROUP_BY_EXTENSION = {
      pdf: "pdf",

      xls: "sheet",
      xlsx: "sheet",
      ods: "sheet",
      csv: "sheet",

      doc: "doc",
      docx: "doc",
      odt: "doc",
      rtf: "doc",

      ppt: "slide",
      pptx: "slide",
      odp: "slide",

      txt: "text",
      text: "text",
      md: "text",
      log: "text",
      ini: "text",
      cfg: "text",
      conf: "text",
      json: "text",
      xml: "text",
      yaml: "text",
      yml: "text",
      toml: "text",
      sql: "text",

      pas: "pascal",
      pp: "pascal",
      inc: "pascal",
      dpr: "pascal",
      dfm: "pascal",
      fmx: "pascal",

      c: "code",
      h: "code",
      cc: "code",
      cp: "code",
      cpp: "code",
      cxx: "code",
      hpp: "code",
      hh: "code",
      hxx: "code",

      java: "code",
      class: "code",
      kt: "code",
      kts: "code",
      cs: "code",
      rs: "code",
      py: "code",
      js: "code",
      mjs: "code",
      cjs: "code",
      ts: "code",
      jsx: "code",
      tsx: "code",
      go: "code",
      php: "code",
      rb: "code",
      swift: "code",
      scala: "code",
      sh: "code",
      bat: "code",
      cmd: "code",
      ps1: "code",
      lua: "code",
      pl: "code",
      r: "code"
    };

    function ensureMount() {
      if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.getMount === "function") {
        return window.ResponseRenderBatch.getMount();
      }

      let mount = document.getElementById("ResponseContent");

      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      return mount;
    }

    function ensureActiveResponse(pairIdValue) {
      if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.ensureActiveResponse === "function") {
        return window.ResponseRenderBatch.ensureActiveResponse(
          pairIdValue,
          "assistant-message display-block"
        ).response;
      }

      const mount = ensureMount();
      const expectedPairId = String(pairIdValue == null ? "" : pairIdValue);

      let block = null;

      for (const node of mount.children) {
        if (node.nodeType === 1 && node.id === "assistant-stream-block") {
          block = node;
          break;
        }
      }

      if (block && block !== mount.lastElementChild) {
        block.removeAttribute("id");
        block = null;
      }

      if (block && block.dataset && (block.dataset.pairId || "") !== expectedPairId) {
        block.removeAttribute("id");
        block = null;
      }

      if (!block) {
        block = document.createElement("div");
        block.className = "assistant-message display-block";
        block.id = "assistant-stream-block";
        mount.appendChild(block);
      }

      block.dataset.pairId = expectedPairId;

      let response = block.querySelector(".assistant-response");

      if (!response) {
        response = document.createElement("div");
        response.className = "assistant-response";
        block.appendChild(response);
      }

      return response;
    }

    function normalizeFilePath(value) {
      let normalized = String(value || "").trim();

      if (!normalized) {
        return "";
      }

      normalized = normalized.replace(/\\/g, "/");
      normalized = normalized.split("#")[0].split("?")[0];

      return normalized;
    }

    function extractFileName(value, index) {
      const normalized = normalizeFilePath(value);

      if (!normalized) {
        return getFallbackFileName(index);
      }

      const lastSlash = normalized.lastIndexOf("/");
      const fileName = lastSlash >= 0 ? normalized.slice(lastSlash + 1) : normalized;

      if (!fileName) {
        return getFallbackFileName(index);
      }

      try {
        return decodeURIComponent(fileName);
      } catch {
        return fileName;
      }
    }

    function extractFileExtension(value) {
      const fileName = extractFileName(value, 0);
      const lastDot = fileName.lastIndexOf(".");

      if (lastDot <= 0 || lastDot === fileName.length - 1) {
        return "";
      }

      return fileName.slice(lastDot + 1).toLowerCase();
    }

    function getFileGroup(extension) {
      return FILE_GROUP_BY_EXTENSION[extension] || "file";
    }

    function getFileBadge(group) {
      if (group === "pdf") {
        return t("displayFile.badge.pdf", "PDF");
      }

      if (group === "sheet") {
        return t("displayFile.badge.sheet", "XLS");
      }

      if (group === "doc") {
        return t("displayFile.badge.doc", "DOC");
      }

      if (group === "slide") {
        return t("displayFile.badge.slide", "PPT");
      }

      if (group === "text") {
        return t("displayFile.badge.text", "TXT");
      }

      if (group === "pascal") {
        return t("displayFile.badge.pascal", "PAS");
      }

      if (group === "code") {
        return t("displayFile.badge.code", "</>");
      }

      return t("displayFile.badge.file", "FILE");
    }

    function getStatusText(extension) {
      if (!extension) {
        return t("displayFile.status.file", "FILE");
      }

      return extension.toUpperCase();
    }

    function createFileIcon(extension) {
      const group = getFileGroup(extension);

      const iconWrap = document.createElement("div");

      Object.assign(iconWrap.style, {
        width: "36px",
        height: "36px",
        minWidth: "36px",
        minHeight: "36px",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        borderRadius: "10px",
        background: "var(--input-chip-bg)",
        boxSizing: "border-box",
        flex: "0 0 auto",
        overflow: "hidden"
      });

      const glyph = document.createElement("span");
      glyph.textContent = getFileBadge(group);

      Object.assign(glyph.style, {
        color: "var(--input-chip-text)",
        font: '700 11px/1 "Segoe UI", system-ui, sans-serif',
        letterSpacing: "0.3px",
        display: "block",
        whiteSpace: "nowrap"
      });

      iconWrap.appendChild(glyph);
      iconWrap.__glyph = glyph;

      return iconWrap;
    }

    function createStatusNode(extension) {
      const status = document.createElement("div");
      status.textContent = getStatusText(extension);

      Object.assign(status.style, {
        flex: "0 0 auto",
        maxWidth: "74px",
        overflow: "hidden",
        textOverflow: "ellipsis",
        whiteSpace: "nowrap",
        padding: "4px 8px",
        borderRadius: "999px",
        background: "var(--input-chip-bg)",
        color: "var(--input-chip-text)",
        font: "600 11px system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        lineHeight: "16px",
        boxSizing: "border-box"
      });

      return status;
    }

    function applyFileCardVisualState(card) {
      const hovered = !!card.__isHovered;
      const status = card.__status;

      card.style.background = hovered
        ? "var(--input-shell-bg-hover)"
        : "var(--input-shell-bg)";
      card.style.borderColor = "var(--input-shell-border)";
      card.style.boxShadow = "none";

      if (status) {
        status.style.background = "var(--input-chip-bg)";
        status.style.color = "var(--input-chip-text)";
        status.style.opacity = "1";
      }
    }

    function notifyDelphiFileClick(fullPath) {
      const payload = {
        event: "display-file-click",
        fileName: String(fullPath || "")
      };

      const json = JSON.stringify(payload);

      try {
        if (
          window.chrome &&
          window.chrome.webview &&
          typeof window.chrome.webview.postMessage === "function"
        ) {
          window.chrome.webview.postMessage(payload);
          return true;
        }
      } catch {}

      try {
        if (typeof window.cefQuery === "function") {
          window.cefQuery({ request: json });
          return true;
        }
      } catch {}

      try {
        if (window.external && typeof window.external.Notify === "function") {
          window.external.Notify(json);
          return true;
        }
      } catch {}

      try {
        if (window.external && typeof window.external.invoke === "function") {
          window.external.invoke(json);
          return true;
        }
      } catch {}

      try {
        window.dispatchEvent(
          new CustomEvent("display-file-click", {
            detail: payload
          })
        );
      } catch {}

      return false;
    }

    function createFileCard(filePath, index) {
      const card = document.createElement("div");
      const extension = extractFileExtension(filePath);
      const group = getFileGroup(extension);

      const contentRow = document.createElement("div");

      Object.assign(contentRow.style, {
        display: "flex",
        alignItems: "center",
        gap: "12px",
        padding: "10px 14px",
        minHeight: FILE_CARD_MIN_HEIGHT + "px",
        boxSizing: "border-box",
        width: "100%%"
      });

      Object.assign(card.style, {
        width: FILE_CARD_WIDTH + "px",
        minWidth: FILE_CARD_WIDTH + "px",
        maxWidth: FILE_CARD_WIDTH + "px",
        minHeight: FILE_CARD_MIN_HEIGHT + "px",
        flex: "0 0 " + FILE_CARD_WIDTH + "px",
        position: "relative",
        overflow: "hidden",
        boxSizing: "border-box",
        border: "1px solid var(--input-shell-border)",
        borderRadius: "12px",
        background: "var(--input-shell-bg)",
        boxShadow: "none",
        cursor: "pointer",
        userSelect: "none",
        transition: "transform 120ms ease, background 120ms ease, box-shadow 120ms ease"
      });

      const icon = createFileIcon(extension);

      const label = document.createElement("div");
      label.textContent = extractFileName(filePath, index);
      label.title = String(filePath || "");

      Object.assign(label.style, {
        flex: "1 1 auto",
        minWidth: "0",
        overflow: "hidden",
        textOverflow: "ellipsis",
        whiteSpace: "nowrap",
        color: "var(--bubble-assistant-text)",
        font: "600 14px system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        lineHeight: "20px"
      });

      const status = createStatusNode(extension);

      card.__fullPath = filePath;
      card.__fileIndex = index;
      card.__extension = extension;
      card.__group = group;
      card.__labelNode = label;
      card.__status = status;
      card.__iconGlyph = icon.__glyph || null;
      card.__isHovered = false;
      card.dataset.displayFileCard = "1";

      applyDisplayFileCardDictionary(card);

      card.addEventListener("mouseenter", () => {
        card.__isHovered = true;
        card.style.transform = "translateY(-1px)";
        applyFileCardVisualState(card);
      });

      card.addEventListener("mouseleave", () => {
        card.__isHovered = false;
        card.style.transform = "translateY(0)";
        applyFileCardVisualState(card);
      });

      card.addEventListener("click", () => {
        notifyDelphiFileClick(card.__fullPath);
      });

      contentRow.appendChild(icon);
      contentRow.appendChild(label);
      contentRow.appendChild(status);

      card.appendChild(contentRow);

      applyFileCardVisualState(card);

      return card;
    }

    function attachDisplayFileContext(root, pairIdValue) {
      root.dataset.pairId = String(pairIdValue);
      root.dataset.kind = "body-attached";
    }

    function getDisplayFileContextFromTarget(target) {
      const element =
        target && target.nodeType === 1
          ? target
          : target && target.parentElement
            ? target.parentElement
            : null;

      const root = element
        ? element.closest('[data-kind="body-attached"][data-pair-id]')
        : null;

      if (!root) {
        return null;
      }

      return {
        root,
        pairId: root.dataset.pairId,
        kind: root.dataset.kind
      };
    }

    function DisplayFile(items, pairIdValue) {
      if (!Array.isArray(items) || !items.length) {
        return;
      }

      const response = ensureActiveResponse(pairIdValue);

      const gallery = document.createElement("div");

      attachDisplayFileContext(gallery, pairIdValue);

      Object.assign(gallery.style, {
        display: "flex",
        flexDirection: "row",
        flexWrap: "wrap",
        justifyContent: "flex-start",
        alignItems: "flex-start",
        alignContent: "flex-start",
        gap: "12px",
        margin: "1rem 0",
        width: "100%%",
        boxSizing: "border-box"
      });

      items
        .filter((x) => typeof x === "string" && x.trim() !== "")
        .forEach((filePath, index) => {
          gallery.appendChild(createFileCard(filePath.trim(), index));
        });

      if (!gallery.childElementCount) {
        return;
      }

      response.appendChild(gallery);
    }

    if (!window.__displayFileI18nBound) {
      window.__displayFileI18nBound = true;

      window.addEventListener(DISPLAY_FILE_I18N_EVENT, function () {
        applyDisplayFileDictionary();
      });
    }

    applyDisplayFileDictionary();

    window.DisplayFile = DisplayFile;
    window.getDisplayFileContextFromTarget = getDisplayFileContextFromTarget;;

    DisplayFile(files, pairId);
  } catch (e) {
    console.error("DisplayFile error:", e);

    try {
      let mount = document.getElementById("ResponseContent");

      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      const dbg = document.createElement("div");
      dbg.textContent = translateDisplayFileText(
        "displayFile.debug.error",
        "DisplayFile error: {error}",
        { error: String(e) }
      );

      Object.assign(dbg.style, {
        color: "#ff8080",
        padding: "8px 12px",
        margin: "8px 0",
        border: "1px solid #ff8080",
        borderRadius: "8px",
        font: "12px system-ui, sans-serif"
      });

      mount.appendChild(dbg);
    } catch {}
  }
})();
