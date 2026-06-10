(function () {

  const canClipboard = !!(navigator.clipboard && navigator.clipboard.writeText);

  const SELECTOR_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  function t(key, fallback, vars) {
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

  function getSelectorTitle(eventName) {
    if (eventName === "branch-event") {
      return t(
        "selector.branchAfterMessage",
        "Branch chat after this message"
      );
    }

    if (eventName === "copy-event") {
      return t(
        "selector.copyMessage",
        "Copy message"
      );
    }

    if (eventName === "delete-event") {
      return t(
        "selector.deleteMessage",
        "Delete message"
      );
    }

    return "";
  }

  function applySelectorDictionary() {
    const buttons = document.querySelectorAll(
      ".prompt-selector-btn, .display-selector-btn"
    );

    for (let i = 0; i < buttons.length; i += 1) {
      const button = buttons[i];
      const title = getSelectorTitle(button.dataset ? button.dataset.event : "");

      if (!title) {
        continue;
      }

      button.title = title;
      button.setAttribute("aria-label", title);
    }
  }

  function normalizeSelectorContent(text){
    return String(text || "")
      .replace(/\r\n/g, "\n")
      .replace(/\u00A0/g, " ")
      .replace(/^[\s\uFEFF\u200B\u200C\u200D\u2060]+|[\s\uFEFF\u200B\u200C\u200D\u2060]+$/g, "");
  }

  function getSelectorContent(block){
    if (!block || !block.dataset) return "";

    const pairId = block.dataset.pairId || "";
    const kind = block.dataset.kind || "";

    if (!pairId || !kind) return "";

    if (kind === "display") {
      const targetBlock = document.querySelector(
        '.assistant-message.display-block[data-kind="display"][data-pair-id="' + pairId + '"]'
      );

      const response = targetBlock
        ? targetBlock.querySelector(".assistant-response")
        : null;

      if (!response) return "";

      const clone = response.cloneNode(true);

      clone.querySelectorAll(".code-header, .copy-btn").forEach((node) => {
        node.remove();
      });

      return normalizeSelectorContent(clone.innerText || clone.textContent || "");
    }

    if (kind === "prompt") {
      const targetBlock = document.querySelector(
        '.prompt-block[data-kind="prompt"][data-pair-id="' + pairId + '"]'
      );

      const bubble = targetBlock
        ? targetBlock.querySelector(".chat-bubble.user.prompt-bubble")
        : null;

      const body = bubble
        ? bubble.querySelector(".prompt-body")
        : null;

      return normalizeSelectorContent(body ? (body.textContent || "") : "");
    }

    return "";
  }

  function copySelectorContent(text){
    const value = normalizeSelectorContent(text);
    if (!value) return false;

    if (canClipboard) {
      navigator.clipboard.writeText(value).catch(() => {});
      return true;
    }

    try {
      const ta = document.createElement("textarea");
      ta.value = value;

      Object.assign(ta.style, {
        position: "fixed",
        top: "-1000px",
        opacity: "0"
      });

      document.body.appendChild(ta);
      ta.focus();
      ta.select();

      const ok = document.execCommand("copy");
      ta.remove();

      return ok;
    } catch {
      return false;
    }
  }

  function postPromptSelectorEvent(eventName, block){
    if (!block || !window.chrome || !window.chrome.webview) return;

    const content = getSelectorContent(block);

    if (eventName === "copy-event") {
      copySelectorContent(content);
    }

    const payload = {
      event: eventName,
      pairId: block.dataset ? (block.dataset.pairId || "") : "",
      kind: block.dataset ? (block.dataset.kind || "") : "",
      content: content
    };

    window.chrome.webview.postMessage(payload);
  }

  function ensurePromptSelectorButton(container, options){
    let button = container.querySelector('.prompt-selector-btn[data-event="' + options.eventName + '"]');

    if (!button) {
      button = document.createElement("button");
      button.type = "button";
      button.className = "prompt-selector-btn";
      button.dataset.event = options.eventName;
      container.appendChild(button);
    }

    const resolvedTitle = options.title || getSelectorTitle(options.eventName);

    button.title = resolvedTitle;
    button.setAttribute("aria-label", resolvedTitle);

    let icon = button.querySelector(".prompt-selector-icon");
    if (!icon) {
      icon = document.createElement("span");
      icon.className = "prompt-selector-icon";
      button.appendChild(icon);
    }

    icon.textContent = options.glyph;

    return button;
  }

  function shouldShowDeleteSelector(block){
    if (!block || !block.dataset) return false;

    const rawPairId = String(block.dataset.pairId || "").trim();
    if (!rawPairId) return false;

    const numericPairId = Number(rawPairId);
    if (!Number.isFinite(numericPairId)) return false;

    return numericPairId > 1;
  }

  function ensurePromptSelector(block){
    if (!block) return null;

    let host = block.querySelector(".prompt-selector-host");
    if (!host) {
      host = document.createElement("div");
      host.className = "prompt-selector-host";
      block.appendChild(host);
    }

    host.className = "prompt-selector-host";

    let selector = host.querySelector(".prompt-selector");
    if (!selector) {
      selector = document.createElement("div");
      selector.className = "prompt-selector";
    }

    selector.className = "prompt-selector";

    for (const child of Array.from(host.children)) {
      if (child !== selector) {
        host.removeChild(child);
      }
    }

    if (selector.parentNode !== host) {
      host.appendChild(selector);
    }

    selector.textContent = "";

    ensurePromptSelectorButton(selector, {
      eventName: "branch-event",
      glyph: "\uEF90",
      title: getSelectorTitle("branch-event")
    });

    ensurePromptSelectorButton(selector, {
      eventName: "copy-event",
      glyph: "\uE77F",
      title: getSelectorTitle("copy-event")
    });

    if (shouldShowDeleteSelector(block)) {
      ensurePromptSelectorButton(selector, {
        eventName: "delete-event",
        glyph: "\uE74D",
        title: getSelectorTitle("delete-event")
      });
    }

    return selector;
  }

  function postDisplaySelectorEvent(eventName, block){
    if (!block || !window.chrome || !window.chrome.webview) return;

    const content = getSelectorContent(block);

    if (eventName === "copy-event") {
      copySelectorContent(content);
    }

    const payload = {
      event: eventName,
      pairId: block.dataset ? (block.dataset.pairId || "") : "",
      kind: block.dataset ? (block.dataset.kind || "") : "",
      content: content
    };

    window.chrome.webview.postMessage(payload);
  }

  function ensureDisplaySelectorButton(container, options){
    let button = container.querySelector('.display-selector-btn[data-event="' + options.eventName + '"]');

    if (!button) {
      button = document.createElement("button");
      button.type = "button";
      button.className = "display-selector-btn";
      button.dataset.event = options.eventName;
      container.appendChild(button);
    }

    const resolvedTitle = options.title || getSelectorTitle(options.eventName);

    button.title = resolvedTitle;
    button.setAttribute("aria-label", resolvedTitle);

    let icon = button.querySelector(".display-selector-icon");
    if (!icon) {
      icon = document.createElement("span");
      icon.className = "display-selector-icon";
      button.appendChild(icon);
    }

    icon.textContent = options.glyph;

    return button;
  }

  function ensureDisplaySelector(block){
    if (!block) return null;

    let host = block.querySelector(".display-selector-host");
    if (!host) {
      host = document.createElement("div");
      host.className = "display-selector-host";
      block.appendChild(host);
    }

    host.className = "display-selector-host";

    let selector = host.querySelector(".display-selector");
    if (!selector) {
      selector = document.createElement("div");
      selector.className = "display-selector";
    }

    selector.className = "display-selector";

    for (const child of Array.from(host.children)) {
      if (child !== selector) {
        host.removeChild(child);
      }
    }

    if (selector.parentNode !== host) {
      host.appendChild(selector);
    }

    selector.textContent = "";

    ensureDisplaySelectorButton(selector, {
      eventName: "branch-event",
      glyph: "\uEF90",
      title: getSelectorTitle("branch-event")
    });

    ensureDisplaySelectorButton(selector, {
      eventName: "copy-event",
      glyph: "\uE77F",
      title: getSelectorTitle("copy-event")
    });

    if (shouldShowDeleteSelector(block)) {
      ensureDisplaySelectorButton(selector, {
        eventName: "delete-event",
        glyph: "\uE74D",
        title: getSelectorTitle("delete-event")
      });
    }

    return selector;
  }

  document.addEventListener("click", function(e){

    const button = e.target.closest(".prompt-selector-btn");
    if (!button) return;

    const block = button.closest(".prompt-block");
    if (!block) return;

    e.preventDefault();
    e.stopPropagation();

    postPromptSelectorEvent(button.dataset.event || "", block);
  });

  document.addEventListener("click", function(e){

    const button = e.target.closest(".display-selector-btn");
    if (!button) return;

    const block = button.closest(".display-block");
    if (!block) return;

    e.preventDefault();
    e.stopPropagation();

    postDisplaySelectorEvent(button.dataset.event || "", block);
  });

  window.addEventListener(SELECTOR_I18N_EVENT, function () {
    applySelectorDictionary();
  });

  window.ensurePromptSelector = ensurePromptSelector;
  window.ensureDisplaySelector = ensureDisplaySelector;

  applySelectorDictionary();

})();
