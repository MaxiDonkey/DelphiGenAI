(function () {
  const DIALOG_ID = "__pythia_web_decision_dlg__";
  const STYLE_ID = "__pythia_web_decision_dlg_style__";
  const REQUEST_TYPE = "web-decision-dlg-request";
  const RESPONSE_EVENT = "web-decision-dlg-response";

  const DEFAULTS = {
    title: "Confirmation",
    message: "Please confirm.",
    okText: "OK",
    cancelText: "Cancel",
    closeText: "Close"
  };

  const I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  let currentRequest = null;
  let currentButtons = [];
  let keydownHandlerAttached = false;

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

  function getDefaultDialogTexts() {
    return {
      title: t("webDecisionDlg.title", t("confirmation.title", "Confirmation")),
      message: t("webDecisionDlg.message", t("confirmation.question", "Please confirm.")),
      okText: t("webDecisionDlg.ok", t("inputString.ok", "OK")),
      cancelText: t("webDecisionDlg.cancel", t("inputString.cancel", "Cancel")),
      closeText: t("webDecisionDlg.close", t("requestParams.panel.close", "Close"))
    };
  }

  function refreshDefaults() {
    const defaults = getDefaultDialogTexts();
    DEFAULTS.title = defaults.title;
    DEFAULTS.message = defaults.message;
    DEFAULTS.okText = defaults.okText;
    DEFAULTS.cancelText = defaults.cancelText;
    DEFAULTS.closeText = defaults.closeText;
  }

  function normalizeDialogDisplayText(value) {
    const source = String(value == null ? "" : value);

    return source
      .replace(/#13#10(?!\d)/g, "\n")
      .replace(/#10(?!\d)/g, "\n")
      .replace(/#13(?!\d)/g, "\n")
      .replace(/#9(?!\d)/g, "\t");
  }

  function normalizeString(value) {
    return String(value == null ? "" : value);
  }

  function isObject(value) {
    return value != null && typeof value === "object" && !Array.isArray(value);
  }

  function escapeHtml(value) {
    return normalizeString(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function isSafeLinkHref(value) {
    const href = normalizeString(value).trim();
    if (!href) return false;

    try {
      const parsed = new URL(href, window.location.href);
      return parsed.protocol === "http:" ||
        parsed.protocol === "https:" ||
        parsed.protocol === "mailto:";
    } catch (_) {
      return false;
    }
  }

  function attr(value) {
    return escapeHtml(value).replace(/`/g, "&#96;");
  }

  function textToHtml(value) {
    const source = normalizeDialogDisplayText(value).trim();
    if (!source) return "";

    return source
      .split(/\n{2,}/)
      .map(function (paragraph) {
        return "<p>" + escapeHtml(paragraph).replace(/\n/g, "<br>") + "</p>";
      })
      .join("");
  }

  function renderInlineTokens(tokens) {
    if (!Array.isArray(tokens)) return "";

    return tokens.map(function (token) {
      if (!token) return "";

      switch (token.type) {
        case "text":
        case "escape":
          return escapeHtml(token.text || token.raw || "");
        case "strong":
          return "<strong>" + renderInlineTokens(token.tokens) + "</strong>";
        case "em":
          return "<em>" + renderInlineTokens(token.tokens) + "</em>";
        case "codespan":
          return "<code>" + escapeHtml(token.text || "") + "</code>";
        case "del":
          return "<del>" + renderInlineTokens(token.tokens) + "</del>";
        case "br":
          return "<br>";
        case "link": {
          const label = renderInlineTokens(token.tokens) || escapeHtml(token.text || token.href || "");
          if (!isSafeLinkHref(token.href)) return label;

          return '<a href="' + attr(token.href) + '" target="_blank" rel="noopener noreferrer">' +
            label +
            "</a>";
        }
        case "image":
          return escapeHtml(token.text || "");
        case "html":
          return escapeHtml(token.text || token.raw || "");
        default:
          if (Array.isArray(token.tokens)) return renderInlineTokens(token.tokens);
          return escapeHtml(token.text || token.raw || "");
      }
    }).join("");
  }

  function tokenizeInline(value) {
    if (
      window.marked &&
      window.marked.Lexer &&
      typeof window.marked.Lexer.lexInline === "function"
    ) {
      try {
        return window.marked.Lexer.lexInline(normalizeString(value));
      } catch (_) {}
    }

    return [{ type: "text", text: normalizeString(value) }];
  }

  function renderCellTokens(cell) {
    if (Array.isArray(cell && cell.tokens)) {
      return renderInlineTokens(cell.tokens);
    }

    return renderInlineTokens(tokenizeInline(cell && cell.text ? cell.text : cell));
  }

  function renderMarkdownToken(token) {
    if (!token) return "";

    switch (token.type) {
      case "space":
      case "def":
        return "";
      case "hr":
        return "<hr>";
      case "heading": {
        const depth = Math.min(Math.max(Number(token.depth) || 2, 1), 6);
        return "<h" + depth + ">" + renderInlineTokens(token.tokens) + "</h" + depth + ">";
      }
      case "paragraph":
        return "<p>" + renderInlineTokens(token.tokens) + "</p>";
      case "text":
        return "<p>" + renderInlineTokens(token.tokens || tokenizeInline(token.text || token.raw || "")) + "</p>";
      case "blockquote":
        return "<blockquote>" + renderMarkdownTokens(token.tokens || []) + "</blockquote>";
      case "list": {
        const tag = token.ordered ? "ol" : "ul";
        const items = (token.items || []).map(function (item) {
          const itemHtml = item.tokens && item.tokens.length
            ? renderMarkdownTokens(item.tokens)
            : renderInlineTokens(item.tokens || tokenizeInline(item.text || ""));

          return "<li>" + itemHtml + "</li>";
        }).join("");

        return "<" + tag + ">" + items + "</" + tag + ">";
      }
      case "code": {
        const lang = normalizeString(token.lang || "").trim();
        const className = lang ? ' class="language-' + attr(lang.toLowerCase()) + '"' : "";
        return "<pre><code" + className + ">" + escapeHtml(token.text || "") + "</code></pre>";
      }
      case "table": {
        const header = (token.header || []).map(function (cell) {
          return "<th>" + renderCellTokens(cell) + "</th>";
        }).join("");

        const rows = (token.rows || []).map(function (row) {
          return "<tr>" + row.map(function (cell) {
            return "<td>" + renderCellTokens(cell) + "</td>";
          }).join("") + "</tr>";
        }).join("");

        return '<div class="wdd-table-wrap"><table><thead><tr>' +
          header +
          "</tr></thead><tbody>" +
          rows +
          "</tbody></table></div>";
      }
      case "html":
        return escapeHtml(token.text || token.raw || "");
      default:
        if (Array.isArray(token.tokens)) return renderMarkdownTokens(token.tokens);
        return escapeHtml(token.text || token.raw || "");
    }
  }

  function renderMarkdownTokens(tokens) {
    return (tokens || []).map(renderMarkdownToken).join("");
  }

  function renderMarkdown(value) {
    const source = normalizeDialogDisplayText(value);
    if (!source.trim()) return "";

    if (window.marked && typeof window.marked.lexer === "function") {
      try {
        return renderMarkdownTokens(window.marked.lexer(source, {
          gfm: true,
          breaks: false
        }));
      } catch (_) {}
    }

    return textToHtml(source);
  }

  function getOverlay() {
    return document.getElementById(DIALOG_ID + "_overlay");
  }

  function ensureStyles() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      :root {
        --wdd-overlay-bg: rgba(0, 0, 0, 0.08);
        --wdd-bg: var(--bg-main, #2f2f2f);
        --wdd-text: var(--text-main, #ddd);
        --wdd-muted: var(--text-muted, #9ca3af);
        --wdd-border: var(--input-shell-border, rgba(255,255,255,0.10));
        --wdd-shadow: 0 28px 90px rgba(0,0,0,0.42);
        --wdd-header-bg: transparent;
        --wdd-btn-bg: var(--input-button-bg, #3a3a3a);
        --wdd-btn-text: var(--input-button-text, #ffffff);
        --wdd-btn-hover-bg: var(--input-button-hover-bg, #ffffff);
        --wdd-btn-hover-text: var(--input-button-hover-text, #111);
        --wdd-btn-border: var(--wdd-border);
        --wdd-code-bg: rgba(127,127,127,0.14);
        --wdd-danger-bg: rgba(185, 28, 28, 0.18);
        --wdd-danger-border: rgba(248, 113, 113, 0.42);
      }

      #${DIALOG_ID}_overlay {
        position: fixed;
        inset: 0;
        z-index: 2147483000;
        display: flex;
        align-items: flex-end;
        justify-content: flex-end;
        box-sizing: border-box;
        padding: 0 28px 28px 0;
        background: var(--wdd-overlay-bg);
      }

      #${DIALOG_ID} {
        width: min(760px, calc(100vw - 56px));
        max-height: min(72vh, 720px);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        color: var(--wdd-text);
        background: var(--wdd-bg);
        background: color-mix(in srgb, var(--bg-main) 88%, transparent);
        border: 1px solid var(--wdd-border);
        border-radius: 20px;
        box-shadow: var(--wdd-shadow);
        backdrop-filter: blur(18px);
        font-family: var(--font-family, "Segoe UI", system-ui, sans-serif);
      }

      [data-theme="light"] #${DIALOG_ID} {
        background: color-mix(in srgb, var(--bg-main) 94%, transparent);
        box-shadow: 0 28px 90px rgba(15,23,42,0.18);
      }

      #${DIALOG_ID}_header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 14px;
        min-height: 54px;
        padding: 14px 16px 12px 20px;
        background: var(--wdd-header-bg);
        border-bottom: 1px solid var(--wdd-border);
      }

      #${DIALOG_ID}_title {
        min-width: 0;
        margin: 0;
        overflow: hidden;
        color: var(--wdd-text);
        font-size: 16px;
        font-weight: 650;
        line-height: 1.35;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      #${DIALOG_ID}_close {
        width: 32px;
        height: 32px;
        flex: 0 0 auto;
        border: 1px solid var(--input-shell-border);
        border-radius: 10px;
        color: var(--wdd-muted);
        background: var(--input-button-bg);
        cursor: pointer;
        font-size: 18px;
        line-height: 1;
      }

      #${DIALOG_ID}_close:hover,
      #${DIALOG_ID}_close:focus-visible {
        color: var(--wdd-btn-hover-text);
        background: var(--wdd-btn-hover-bg);
        outline: none;
      }

      #${DIALOG_ID}_body {
        min-height: 180px;
        max-height: calc(min(72vh, 720px) - 118px);
        overflow: auto;
        padding: 20px;
        color: var(--wdd-text);
        font-size: 14px;
        line-height: 1.55;
      }

      #${DIALOG_ID}_body :first-child {
        margin-top: 0;
      }

      #${DIALOG_ID}_body :last-child {
        margin-bottom: 0;
      }

      #${DIALOG_ID}_body p,
      #${DIALOG_ID}_body ul,
      #${DIALOG_ID}_body ol,
      #${DIALOG_ID}_body blockquote,
      #${DIALOG_ID}_body pre,
      #${DIALOG_ID}_body .wdd-table-wrap {
        margin: 0.8em 0;
      }

      #${DIALOG_ID}_body h1,
      #${DIALOG_ID}_body h2,
      #${DIALOG_ID}_body h3,
      #${DIALOG_ID}_body h4,
      #${DIALOG_ID}_body h5,
      #${DIALOG_ID}_body h6 {
        margin: 1em 0 0.45em;
        color: var(--wdd-text);
        font-size: 15px;
        line-height: 1.35;
      }

      #${DIALOG_ID}_body code {
        padding: 0.1em 0.35em;
        border-radius: 5px;
        background: var(--wdd-code-bg);
        font-family: Consolas, "Cascadia Mono", "SFMono-Regular", monospace;
        font-size: 0.92em;
      }

      #${DIALOG_ID}_body pre {
        overflow: auto;
        padding: 12px;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 78%, transparent);
        border-radius: 14px;
        background: color-mix(in srgb, var(--input-shell-bg) 52%, transparent);
      }

      #${DIALOG_ID}_body pre code {
        padding: 0;
        background: transparent;
      }

      #${DIALOG_ID}_body blockquote {
        padding: 0.1em 0 0.1em 0.9em;
        border-left: 3px solid var(--wdd-border);
        color: var(--wdd-muted);
      }

      #${DIALOG_ID}_body a {
        color: var(--link-color, #6ea8fe);
        text-decoration: underline;
      }

      #${DIALOG_ID}_body .wdd-table-wrap {
        overflow: auto;
      }

      #${DIALOG_ID}_body table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
      }

      #${DIALOG_ID}_body th,
      #${DIALOG_ID}_body td {
        padding: 7px 9px;
        border: 1px solid var(--wdd-border);
        text-align: left;
        vertical-align: top;
      }

      #${DIALOG_ID}_footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        padding: 14px 16px 16px 20px;
        background: transparent;
        border-top: 1px solid var(--wdd-border);
      }

      #${DIALOG_ID}_footer_text {
        min-width: 0;
        flex: 1 1 auto;
        color: var(--wdd-text);
        font-size: 14px;
        font-weight: 600;
        line-height: 1.35;
      }

      #${DIALOG_ID}_footer_text:empty {
        display: none;
      }

      #${DIALOG_ID}_actions {
        display: flex;
        flex: 0 0 auto;
        align-items: center;
        justify-content: flex-end;
        gap: 10px;
      }

      .${DIALOG_ID}_btn {
        min-width: 104px;
        max-width: 220px;
        min-height: 36px;
        padding: 7px 14px;
        overflow: hidden;
        border: 1px solid var(--wdd-btn-border);
        border-radius: 12px;
        color: var(--wdd-btn-text);
        background: var(--wdd-btn-bg);
        cursor: pointer;
        font: inherit;
        font-size: 13px;
        line-height: 1.25;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .${DIALOG_ID}_btn:hover,
      .${DIALOG_ID}_btn:focus-visible {
        color: var(--wdd-btn-hover-text);
        background: var(--wdd-btn-hover-bg);
        outline: none;
      }

      .${DIALOG_ID}_btn[data-role="danger"] {
        border-color: var(--wdd-danger-border);
        background: var(--wdd-danger-bg);
      }

      @media (max-width: 640px) {
        #${DIALOG_ID}_overlay {
          padding: 0 12px 12px;
        }

        #${DIALOG_ID} {
          width: calc(100vw - 24px);
          max-height: 78vh;
        }

        #${DIALOG_ID}_footer {
          flex-wrap: wrap;
          align-items: stretch;
        }

        #${DIALOG_ID}_footer_text {
          flex-basis: 100%;
        }

        #${DIALOG_ID}_actions {
          width: 100%;
          flex-wrap: wrap;
        }

        .${DIALOG_ID}_btn {
          flex: 1 1 140px;
        }
      }
    `;

    document.head.appendChild(style);
  }

  function resolveTitle(request) {
    if (request.title) return normalizeDialogDisplayText(request.title);
    if (request.titleKey) return t(request.titleKey, DEFAULTS.title);
    return DEFAULTS.title;
  }

  function fallbackButtonText(button) {
    const role = normalizeString(button.role).toLowerCase();
    if (role === "cancel") return DEFAULTS.cancelText;
    return DEFAULTS.okText;
  }

  function resolveButtonText(button) {
    if (button.text) return normalizeDialogDisplayText(button.text);
    if (button.i18nKey) return t(button.i18nKey, fallbackButtonText(button));
    return fallbackButtonText(button);
  }

  function resolveFooterText(request) {
    if (request.footerText) return normalizeDialogDisplayText(request.footerText);
    if (request.footerTextKey) return t(request.footerTextKey, "");
    return "";
  }

  function resolveCloseText(request) {
    if (request.closeText) return normalizeDialogDisplayText(request.closeText);
    if (request.closeTextKey) return t(request.closeTextKey, DEFAULTS.closeText);
    return DEFAULTS.closeText;
  }

  function normalizeButton(button, index) {
    const source = isObject(button) ? button : {};
    const role = normalizeString(source.role || (index === 0 ? "default" : "neutral")).toLowerCase();
    const id = normalizeString(source.id || source.value || role || ("button-" + index)).trim();

    return {
      id: id || ("button-" + index),
      role,
      text: normalizeString(source.text),
      i18nKey: normalizeString(source.i18nKey),
      disabled: !!source.disabled
    };
  }

  function normalizeButtons(input) {
    const source = Array.isArray(input) && input.length
      ? input
      : [{ id: "ok", role: "default", i18nKey: "webDecisionDlg.ok" }];

    return source.map(normalizeButton).filter(function (button) {
      return !!button.id;
    });
  }

  function findButtonByRole(role) {
    const normalizedRole = normalizeString(role).toLowerCase();
    return currentButtons.find(function (button) {
      return button.role === normalizedRole && !button.disabled;
    }) || null;
  }

  function getDefaultButton() {
    return findButtonByRole("default") ||
      currentButtons.find(function (button) { return !button.disabled; }) ||
      null;
  }

  function getCancelButton() {
    return findButtonByRole("cancel") ||
      currentButtons.slice().reverse().find(function (button) { return !button.disabled; }) ||
      getDefaultButton();
  }

  function sendResult(button, closedBy) {
    if (!(window.chrome && window.chrome.webview)) return;
    if (!currentRequest) return;

    window.chrome.webview.postMessage({
      event: RESPONSE_EVENT,
      requestId: currentRequest.requestId,
      choiceId: button && button.id ? button.id : "",
      closedBy: closedBy || "button",
      success: !!button
    });
  }

  function detachKeydownHandler() {
    if (!keydownHandlerAttached) return;
    document.removeEventListener("keydown", handleKeydown, true);
    keydownHandlerAttached = false;
  }

  function removeDialog() {
    const overlay = getOverlay();
    if (overlay && overlay.parentNode) {
      overlay.parentNode.removeChild(overlay);
    }

    detachKeydownHandler();
    currentRequest = null;
    currentButtons = [];
  }

  function closeDialog(button, closedBy) {
    sendResult(button, closedBy);
    removeDialog();
  }

  function cancelExistingDialog() {
    if (!currentRequest) return;
    closeDialog(getCancelButton(), "replaced");
  }

  function getFocusableElements() {
    const overlay = getOverlay();
    if (!overlay) return [];

    return Array.from(overlay.querySelectorAll(
      'button:not([disabled]), a[href], [tabindex]:not([tabindex="-1"])'
    )).filter(function (element) {
      return !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length);
    });
  }

  function focusElement(element) {
    if (!element) return false;

    try {
      element.focus({ preventScroll: true });
    } catch (_) {
      try {
        element.focus();
      } catch (_) {
        return false;
      }
    }

    return true;
  }

  function handleKeydown(event) {
    if (!currentRequest) return;

    if (event.key === "Escape") {
      event.preventDefault();
      closeDialog(getCancelButton(), "escape");
      return;
    }

    if (event.key === "Enter") {
      const active = document.activeElement;
      if (active && active.tagName === "BUTTON") return;

      const defaultButton = getDefaultButton();
      if (defaultButton) {
        event.preventDefault();
        closeDialog(defaultButton, "enter");
      }
      return;
    }

    if (event.key !== "Tab") return;

    const focusable = getFocusableElements();
    if (!focusable.length) return;

    const first = focusable[0];
    const last = focusable[focusable.length - 1];

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      focusElement(last);
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      focusElement(first);
    }
  }

  function attachKeydownHandler() {
    if (keydownHandlerAttached) return;
    document.addEventListener("keydown", handleKeydown, true);
    keydownHandlerAttached = true;
  }

  function resolveContent(request) {
    if (request.content != null) return normalizeDialogDisplayText(request.content);
    if (request.messageMarkdown != null) return normalizeDialogDisplayText(request.messageMarkdown);
    if (request.messageText != null) return normalizeDialogDisplayText(request.messageText);
    if (request.message != null) return normalizeDialogDisplayText(request.message);
    return DEFAULTS.message;
  }

  function resolveContentFormat(request) {
    const explicitFormat = normalizeString(request.contentFormat).trim().toLowerCase();
    if (explicitFormat === "text" || explicitFormat === "markdown") return explicitFormat;
    if (request.messageMarkdown != null) return "markdown";
    return "text";
  }

  function renderContent(body, request) {
    const content = resolveContent(request);
    const format = resolveContentFormat(request);

    if (format === "markdown") {
      body.innerHTML = renderMarkdown(content);
    } else {
      body.textContent = content;
    }
  }

  function applyDialogDictionary() {
    refreshDefaults();

    const overlay = getOverlay();
    if (!overlay || !currentRequest) return;

    const title = overlay.querySelector("#" + DIALOG_ID + "_title");
    const dialog = overlay.querySelector("#" + DIALOG_ID);
    const close = overlay.querySelector("#" + DIALOG_ID + "_close");
    const footerText = overlay.querySelector("#" + DIALOG_ID + "_footer_text");

    const titleText = resolveTitle(currentRequest);

    if (title) title.textContent = titleText;
    if (dialog) dialog.setAttribute("aria-label", titleText);
    if (close) {
      const closeText = resolveCloseText(currentRequest);
      close.setAttribute("aria-label", closeText);
      close.setAttribute("title", closeText);
    }
    if (footerText) footerText.textContent = resolveFooterText(currentRequest);

    overlay.querySelectorAll("." + DIALOG_ID + "_btn").forEach(function (buttonNode) {
      const index = Number(buttonNode.getAttribute("data-index"));
      const button = Number.isFinite(index) ? currentButtons[index] : null;
      if (button) buttonNode.textContent = resolveButtonText(button);
    });
  }

  function normalizeRequest(data) {
    const source = isObject(data) ? data : {};
    let requestId = normalizeString(source.requestId).trim();

    if (!requestId && window.crypto && typeof window.crypto.randomUUID === "function") {
      requestId = window.crypto.randomUUID();
    }

    if (!requestId) {
      requestId = "web-decision-dlg-" + Date.now().toString(36);
    }

    return {
      requestId,
      title: normalizeString(source.title),
      titleKey: normalizeString(source.titleKey),
      message: source.message,
      messageText: source.messageText,
      messageMarkdown: source.messageMarkdown,
      content: source.content,
      contentFormat: normalizeString(source.contentFormat),
      footerText: normalizeString(source.footerText),
      footerTextKey: normalizeString(source.footerTextKey),
      closeText: normalizeString(source.closeText),
      closeTextKey: normalizeString(source.closeTextKey),
      buttons: source.buttons,
      showClose: source.showClose !== false
    };
  }

  function buildDialog(data) {
    refreshDefaults();
    cancelExistingDialog();

    const request = normalizeRequest(data);
    const buttons = normalizeButtons(request.buttons);

    ensureStyles();

    currentRequest = request;
    currentButtons = buttons;

    const overlay = document.createElement("div");
    overlay.id = DIALOG_ID + "_overlay";

    const dialog = document.createElement("div");
    dialog.id = DIALOG_ID;
    dialog.tabIndex = -1;
    dialog.setAttribute("role", "dialog");
    dialog.setAttribute("aria-modal", "true");
    dialog.setAttribute("aria-describedby", DIALOG_ID + "_body");

    const header = document.createElement("div");
    header.id = DIALOG_ID + "_header";

    const title = document.createElement("h2");
    title.id = DIALOG_ID + "_title";
    title.textContent = resolveTitle(request);

    header.appendChild(title);

    if (request.showClose) {
      const close = document.createElement("button");
      close.id = DIALOG_ID + "_close";
      close.type = "button";
      close.textContent = "\u00d7";
      close.setAttribute("aria-label", resolveCloseText(request));
      close.setAttribute("title", resolveCloseText(request));
      close.addEventListener("click", function () {
        closeDialog(getCancelButton(), "close");
      });
      header.appendChild(close);
    }

    const body = document.createElement("div");
    body.id = DIALOG_ID + "_body";
    renderContent(body, request);

    const footer = document.createElement("div");
    footer.id = DIALOG_ID + "_footer";

    const footerText = document.createElement("div");
    footerText.id = DIALOG_ID + "_footer_text";
    footerText.textContent = resolveFooterText(request);
    footer.appendChild(footerText);

    const actions = document.createElement("div");
    actions.id = DIALOG_ID + "_actions";

    buttons.forEach(function (button, index) {
      const buttonNode = document.createElement("button");
      buttonNode.type = "button";
      buttonNode.className = DIALOG_ID + "_btn";
      buttonNode.textContent = resolveButtonText(button);
      buttonNode.disabled = button.disabled;
      buttonNode.setAttribute("data-role", button.role);
      buttonNode.setAttribute("data-index", String(index));
      buttonNode.addEventListener("click", function () {
        closeDialog(button, "button");
      });
      actions.appendChild(buttonNode);
    });

    footer.appendChild(actions);

    dialog.appendChild(header);
    dialog.appendChild(body);
    dialog.appendChild(footer);
    overlay.appendChild(dialog);
    document.body.appendChild(overlay);

    applyDialogDictionary();
    attachKeydownHandler();

    const defaultButton = getDefaultButton();
    const defaultButtonIndex = defaultButton ? buttons.indexOf(defaultButton) : -1;
    const defaultButtonNode = defaultButtonIndex >= 0
      ? footer.querySelector('[data-index="' + defaultButtonIndex + '"]')
      : null;

    focusElement(defaultButtonNode || dialog);
  }

  function handleHostMessage(data) {
    if (!data || typeof data !== "object") return;
    if (data.type !== REQUEST_TYPE) return;

    buildDialog(data);
  }

  window.addEventListener(I18N_EVENT, function () {
    applyDialogDictionary();
  });

  refreshDefaults();

  if (window.chrome && window.chrome.webview) {
    window.chrome.webview.addEventListener("message", function (args) {
      handleHostMessage(args.data);
    });
  }

  window.showPythiaWebDecisionDlg = function (input) {
    let normalizedInput = input;

    if (typeof normalizedInput === "string") {
      try {
        normalizedInput = JSON.parse(normalizedInput);
      } catch (_) {
        normalizedInput = { content: normalizedInput, contentFormat: "markdown" };
      }
    }

    handleHostMessage(Object.assign({}, normalizedInput || {}, {
      type: REQUEST_TYPE
    }));
  };
})();
