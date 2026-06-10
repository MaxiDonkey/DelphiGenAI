(function () {

  function translateErrorsText(key, fallback, vars) {
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

  const ROOT_ID = "__delphi_error_bubble_stack__";
  const STYLE_ID = "__delphi_error_bubble_stack_style__";

  const AUTO_CLOSE_DELAY_MS = 12000;
  const CLOSE_ANIMATION_MS = 700;
  const STACK_TOP_PX = 0;

  let sequence = 0;
  let messageListenerAttached = false;
  let resizeHandlerAttached = false;

  const ERRORS_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  const t = translateErrorsText;

  function normalizeErrorsDisplayText(value) {
    const source = String(value == null ? "" : value);

    return source
      .replace(/#13#10(?!\d)/g, "\n")
      .replace(/#10#13(?!\d)/g, "\n")
      .replace(/#10(?!\d)/g, "\n")
      .replace(/#13(?!\d)/g, "\n")
      .replace(/#9(?!\d)/g, "\t");
  }

  function getErrorsRegionLabel() {
    return t("errors.aria.systemMessages", "System messages");
  }

  function getErrorsCloseLabel() {
    return t("errors.action.close", "Close");
  }

  function applyErrorsDictionary() {
    const root = document.getElementById(ROOT_ID);

    if (root) {
      root.setAttribute("aria-label", getErrorsRegionLabel());
    }

    const closeButtons = document.querySelectorAll(".delphi-error-bubble__close");

    closeButtons.forEach(function (button) {
      button.setAttribute("aria-label", getErrorsCloseLabel());
      button.title = getErrorsCloseLabel();
    });
  }

  function ensureStyles() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      :root {
        --delphi-error-bubble-text: #2b1f1d;
        --delphi-error-bubble-error-bg: #b03a2e;
        --delphi-error-bubble-error-border: #be756b;
        --delphi-error-bubble-warning-bg: #c96a1b;
        --delphi-error-bubble-warning-border: #d19b58;
        --delphi-error-bubble-success-bg: #2e7d4f;
        --delphi-error-bubble-success-border: #5ba87d;
      }

      #${ROOT_ID} {
        position: fixed;
        top: ${STACK_TOP_PX}px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 2100;
        pointer-events: none;
        box-sizing: border-box;
      }

      .delphi-error-bubble {
        position: relative;
        box-sizing: border-box;
        width: 100%;
        overflow: hidden;

        padding: 14px 34px 14px 18px;
        border-radius: 8px;
        border: 1px solid transparent;

        color: var(--delphi-error-bubble-text);
        text-align: center;
        font-family: "Segoe UI", Arial, sans-serif;
        font-size: 15px;
        line-height: 1.45;

        box-shadow: var(--input-shell-shadow, 0 10px 30px rgba(0,0,0,0.35));
        opacity: 1;
        max-height: 240px;
        transform: translateY(0);

        pointer-events: auto;

        transition:
          opacity ${CLOSE_ANIMATION_MS}ms ease,
          transform ${CLOSE_ANIMATION_MS}ms ease,
          max-height ${CLOSE_ANIMATION_MS}ms ease,
          padding-top ${CLOSE_ANIMATION_MS}ms ease,
          padding-bottom ${CLOSE_ANIMATION_MS}ms ease,
          border-width ${CLOSE_ANIMATION_MS}ms ease;
      }

      .delphi-error-bubble + .delphi-error-bubble {
        margin-top: 10px;
      }

      .delphi-error-bubble[data-kind="erreur"] {
        background: var(--delphi-error-bubble-error-bg);
        border-color: var(--delphi-error-bubble-error-border);
        color: #ffffff;
      }

      .delphi-error-bubble[data-kind="warning"] {
        background: var(--delphi-error-bubble-warning-bg);
        border-color: var(--delphi-error-bubble-warning-border);
        color: #ffffff;
      }

      .delphi-error-bubble[data-kind="success"] {
        background: var(--delphi-error-bubble-success-bg);
        border-color: var(--delphi-error-bubble-success-border);
        color: #ffffff;
      }

      .delphi-error-bubble.is-closing {
        opacity: 0;
        transform: translateY(-14px);
        max-height: 0;
        padding-top: 0;
        padding-bottom: 0;
        border-width: 0;
      }

      .delphi-error-bubble__text {
        width: 100%;
        text-align: center;
        white-space: pre-wrap;
        tab-size: 4;
        overflow-wrap: anywhere;
        word-break: break-word;
      }

      .delphi-error-bubble__close {
        appearance: none;
        -webkit-appearance: none;

        position: absolute;
        top: 8px;
        right: 8px;

        width: 18px;
        height: 18px;
        min-width: 18px;
        min-height: 18px;
        padding: 0;
        margin: 0;

        border: none;
        border-radius: 9px;
        background: transparent;
        color: inherit;

        cursor: pointer;

        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-sizing: border-box;

        font-family: "Segoe Fluent Icons","Segoe MDL2 Assets","Segoe UI Symbol","Segoe UI",sans-serif;
        font-size: 10px;
        line-height: 1;

        opacity: 0.78;
        transition:
          opacity 140ms ease,
          background 140ms ease,
          transform 120ms ease;
      }

      .delphi-error-bubble__close:hover,
      .delphi-error-bubble__close:focus-visible {
        opacity: 1;
        background: rgba(0,0,0,0.08);
        outline: none;
      }

      .delphi-error-bubble__close:active {
        transform: scale(0.94);
      }
    `;

    document.head.appendChild(style);
  }

  function ensureRoot() {
    ensureStyles();

    let root = document.getElementById(ROOT_ID);

    if (!root) {
      root = document.createElement("div");
      root.id = ROOT_ID;
      root.setAttribute("role", "region");
      root.setAttribute("aria-live", "polite");
      root.setAttribute("aria-label", getErrorsRegionLabel());
      document.body.appendChild(root);
    }

    syncRootLayout(root);
    applyErrorsDictionary();
    return root;
  }

  function getReferenceMetrics() {
    const inputHost = document.getElementById("InputHost");

    if (inputHost) {
      const rect = inputHost.getBoundingClientRect();

      if (rect && rect.width > 0) {
        return {
          centerX: rect.left + (rect.width / 2),
          width: rect.width
        };
      }
    }

    const responseRoot = document.getElementById("ResponseContent");

    if (responseRoot) {
      const rect = responseRoot.getBoundingClientRect();

      if (rect && rect.width > 0) {
        return {
          centerX: rect.left + (rect.width / 2),
          width: rect.width
        };
      }
    }

    return {
      centerX: window.innerWidth / 2,
      width: Math.max(320, Math.min(760, window.innerWidth - 32))
    };
  }

  function syncRootLayout(root) {
    if (!root) return;

    const metrics = getReferenceMetrics();
    const targetWidth = Math.max(
      240,
      Math.min(window.innerWidth - 32, Math.floor(metrics.width * 0.75))
    );

    root.style.left = Math.round(metrics.centerX) + "px";
    root.style.width = targetWidth + "px";
  }

  function capturePositions(root) {
    const map = new Map();

    if (!root) return map;

    Array.from(root.children).forEach(function (node) {
      if (node && node.nodeType === 1) {
        map.set(node, node.getBoundingClientRect());
      }
    });

    return map;
  }

  function animateStackReflow(root, beforeMap) {
    if (!root || !beforeMap) return;

    Array.from(root.children).forEach(function (node) {
      if (!(node instanceof HTMLElement)) return;
      if (node.classList.contains("is-closing")) return;

      const before = beforeMap.get(node);
      if (!before) return;

      const after = node.getBoundingClientRect();
      const deltaY = before.top - after.top;

      if (Math.abs(deltaY) < 1) return;

      node.style.transition = "none";
      node.style.transform = "translateY(" + deltaY + "px)";
      node.getBoundingClientRect();

      requestAnimationFrame(function () {
        node.style.transition = "transform 260ms ease";
        node.style.transform = "";

        window.setTimeout(function () {
          if (!node.classList.contains("is-closing")) {
            node.style.transition = "";
          }
        }, 280);
      });
    });
  }

  function clearToastTimers(toast) {
    if (!toast) return;

    if (toast.__autoCloseTimer) {
      window.clearTimeout(toast.__autoCloseTimer);
      toast.__autoCloseTimer = 0;
    }

    if (toast.__removeTimer) {
      window.clearTimeout(toast.__removeTimer);
      toast.__removeTimer = 0;
    }
  }

  function closeToast(toast) {
    if (!toast) return false;
    if (toast.__isClosing) return false;

    toast.__isClosing = true;
    clearToastTimers(toast);

    const root = toast.parentElement;
    const beforeMap = root ? capturePositions(root) : null;

    toast.classList.add("is-closing");

    if (root && beforeMap) {
      requestAnimationFrame(function () {
        animateStackReflow(root, beforeMap);
      });
    }

    toast.__removeTimer = window.setTimeout(function () {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, CLOSE_ANIMATION_MS);

    return true;
  }

  function scheduleAutoClose(toast) {
    if (!toast) return;

    toast.__autoCloseTimer = window.setTimeout(function () {
      closeToast(toast);
    }, AUTO_CLOSE_DELAY_MS);
  }

  function createToast(kind, text) {
    const toast = document.createElement("div");
    toast.className = "delphi-error-bubble";
    toast.dataset.kind = kind;
    toast.dataset.toastId = "toast-" + (++sequence);

    const closeBtn = document.createElement("button");
    closeBtn.type = "button";
    closeBtn.className = "delphi-error-bubble__close";
    closeBtn.setAttribute("aria-label", getErrorsCloseLabel());
    closeBtn.title = getErrorsCloseLabel();
    closeBtn.textContent = "\uE653";

    closeBtn.addEventListener("click", function (event) {
      event.preventDefault();
      event.stopPropagation();
      closeToast(toast);
    });

    const textNode = document.createElement("div");
    textNode.className = "delphi-error-bubble__text";
    textNode.textContent = text;

    toast.appendChild(closeBtn);
    toast.appendChild(textNode);

    return toast;
  }

  function normalizePayload(payload) {
    if (!payload || typeof payload !== "object") return null;

    const rawType = payload.type == null ? "" : String(payload.type).trim().toLowerCase();
    const rawTextSource = payload.text == null ? "" : String(payload.text);
    const normalizedText = normalizeErrorsDisplayText(rawTextSource);

    if (!normalizedText.trim()) return null;

    if (rawType === "erreur" || rawType === "error") {
      return {
        type: "erreur",
        text: normalizedText
      };
    }

    if (rawType === "warning") {
      return {
        type: "warning",
        text: normalizedText
      };
    }

    if (rawType === "success") {
      return {
        type: "success",
        text: normalizedText
      };
    }

    return null;
  }

  function showToast(payload) {
    const normalized = normalizePayload(payload);
    if (!normalized) return false;

    const root = ensureRoot();
    syncRootLayout(root);

    const toast = createToast(normalized.type, normalized.text);
    root.appendChild(toast);

    scheduleAutoClose(toast);
    return true;
  }

  function attachMessageListenerOnce() {
    if (messageListenerAttached) return;
    messageListenerAttached = true;

    if (
      !window.chrome ||
      !window.chrome.webview ||
      typeof window.chrome.webview.addEventListener !== "function"
    ) {
      return;
    }

    window.chrome.webview.addEventListener("message", function (event) {
      const msg = event ? event.data : null;
      showToast(msg);
    });
  }

  function attachResizeHandlerOnce() {
    if (resizeHandlerAttached) return;
    resizeHandlerAttached = true;

    window.addEventListener("resize", function () {
      const root = document.getElementById(ROOT_ID);
      if (!root) return;
      syncRootLayout(root);
    }, { passive: true });
  }

  if (!window.__errorsTemplateI18nBound) {
    window.__errorsTemplateI18nBound = true;

    window.addEventListener(ERRORS_I18N_EVENT, function () {
      applyErrorsDictionary();
    });
  }

  applyErrorsDictionary();

  window.ErrorBubbleTemplate = window.ErrorBubbleTemplate || {};
  window.ErrorBubbleTemplate.show = showToast;

  attachMessageListenerOnce();
  attachResizeHandlerOnce();
})();
