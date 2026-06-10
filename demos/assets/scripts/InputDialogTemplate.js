(function () {
  const DIALOG_ID = "__delphi_input_string_dialog__";
  const STYLE_ID = "__delphi_input_string_dialog_style__";
  const DEFAULTS = {
    title: "Input",
    message: "Please enter a value.",
    okText: "OK",
    cancelText: "Cancel"
  };

  let keydownHandlerAttached = false;

  let currentDialogKey = "";
  let currentDialogMessageText = "";
  let currentDialogTitleText = "";
  let currentDialogOkText = "";
  let currentDialogCancelText = "";
  let currentDialogDefaultValue = "";
  let currentDialogHiddenValue = false;
  let currentDialogTextVisible = false;

  const INPUT_STRING_DIALOG_I18N_EVENT =
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

  function getDefaultDialogTexts() {
    return {
      title: t("inputString.title", "Input"),
      message: t("inputString.message", "Please enter a value."),
      okText: t("inputString.ok", "OK"),
      cancelText: t("inputString.cancel", "Cancel")
    };
  }

  function normalizeDialogDisplayText(value) {
    const source = String(value == null ? "" : value);

    return source
      .replace(/#13#10(?!\d)/g, "\n")
      .replace(/#10(?!\d)/g, "\n")
      .replace(/#13(?!\d)/g, "\n")
      .replace(/#9(?!\d)/g, "\t");
  }

  function normalizeInputValue(value) {
    return value == null ? "" : String(value);
  }

  function getOverlay() {
    return document.getElementById(DIALOG_ID + "_overlay");
  }

  function getInputElement() {
    const overlay = getOverlay();
    if (!overlay) return null;

    return overlay.querySelector("#" + DIALOG_ID + "_input");
  }

    function getVisibilityToggleElement() {
    const overlay = getOverlay();
    if (!overlay) return null;

    return overlay.querySelector("#" + DIALOG_ID + "_toggle_visibility");
  }

  function getVisibilityToggleText(isVisible) {
    return isVisible
      ? t("inputString.hideValue", "Hide value")
      : t("inputString.showValue", "Show value");
  }

  function getVisibilityToggleIconSvg(isVisible) {
    if (isVisible) {
      return `
        <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
          <path d="M3 3l18 18"></path>
          <path d="M10.58 10.58a2 2 0 102.84 2.84"></path>
          <path d="M9.88 5.09A10.94 10.94 0 0112 5c5.05 0 9.27 3.11 10.5 7-0.45 1.42-1.35 2.79-2.58 3.95"></path>
          <path d="M6.61 6.61C4.68 7.82 3.33 9.52 2.5 12c1.23 3.89 5.45 7 10.5 7 1.56 0 3.04-.3 4.38-.84"></path>
        </svg>
      `;
    }

    return `
      <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
        <path d="M1.5 12S5.5 5 12 5s10.5 7 10.5 7-4 7-10.5 7S1.5 12 1.5 12z"></path>
        <circle cx="12" cy="12" r="3"></circle>
      </svg>
    `;
  }

  function syncInputType(input) {
    if (!input) return;

    input.type =
      currentDialogHiddenValue && !currentDialogTextVisible ? "password" : "text";

    input.className = currentDialogHiddenValue ? DIALOG_ID + "_input_hidden" : "";
  }

  function syncVisibilityToggleState() {
    const input = getInputElement();
    const toggle = getVisibilityToggleElement();

    syncInputType(input);

    if (!toggle) return;

    const isVisible = !!currentDialogTextVisible;
    const label = getVisibilityToggleText(isVisible);

    toggle.setAttribute("aria-pressed", isVisible ? "true" : "false");
    toggle.setAttribute("aria-label", label);
    toggle.title = label;
    toggle.innerHTML = getVisibilityToggleIconSvg(isVisible);
  }

  function toggleInputVisibility() {
    if (!currentDialogHiddenValue) return;

    currentDialogTextVisible = !currentDialogTextVisible;
    syncVisibilityToggleState();

    const input = getInputElement();
    if (!input) return;

    focusElement(input);

    try {
      const length = input.value.length;
      input.setSelectionRange(length, length);
    } catch (_) {}
  }

  function applyInputStringDialogDictionary() {
    const defaults = getDefaultDialogTexts();

    DEFAULTS.title = defaults.title;
    DEFAULTS.message = defaults.message;
    DEFAULTS.okText = defaults.okText;
    DEFAULTS.cancelText = defaults.cancelText;

    const overlay = getOverlay();
    if (!overlay) return;

    const dialog = overlay.querySelector("#" + DIALOG_ID);
    const body = overlay.querySelector("#" + DIALOG_ID + "_body");
    const btnCancel = overlay.querySelector("." + DIALOG_ID + "_btn_cancel");
    const btnOk = overlay.querySelector("." + DIALOG_ID + "_btn_ok");
    const input = getInputElement();

    if (dialog) {
      dialog.setAttribute("aria-label", currentDialogTitleText || DEFAULTS.title);
    }

    if (body) {
      body.textContent = currentDialogMessageText || DEFAULTS.message;
    }

    if (btnCancel) {
      btnCancel.textContent = currentDialogCancelText || DEFAULTS.cancelText;
    }

    if (btnOk) {
      btnOk.textContent = currentDialogOkText || DEFAULTS.okText;
    }

    syncVisibilityToggleState();
  }

  function ensureStyles() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      :root {
        --dialog-overlay-bg: rgba(0, 0, 0, 0.35);
        --dialog-bg: var(--input-shell-bg, var(--bg-main, #2f2f2f));
        --dialog-text: var(--text-main, #ddd);
        --dialog-border: var(--input-shell-border, rgba(255,255,255,0.08));
        --dialog-shadow: var(--input-shell-shadow, 0 10px 30px rgba(0,0,0,0.35));
        --dialog-btn-bg: var(--input-button-bg, #3a3a3a);
        --dialog-btn-text: var(--input-button-text, #ffffff);
        --dialog-btn-hover-bg: var(--input-button-hover-bg, #ffffff);
        --dialog-btn-hover-text: var(--input-button-hover-text, #111);
        --dialog-btn-border: var(--dialog-border);
        --dialog-input-bg: var(--input-bg, rgba(255,255,255,0.04));
        --dialog-input-text: var(--text-main, #ddd);
        --dialog-input-border: var(--input-shell-border, rgba(255,255,255,0.08));
        --dialog-input-focus: var(--input-border-focus, rgba(255,255,255,0.22));
      }

      #${DIALOG_ID}_overlay {
        position: fixed;
        inset: 0;
        background: var(--dialog-overlay-bg);
        z-index: 2147483647;
        display: flex;
        align-items: center;
        justify-content: center;
        font-family: Segoe UI, Arial, sans-serif;
      }

      #${DIALOG_ID} {
        width: min(420px, calc(100vw - 32px));
        background: var(--dialog-bg);
        color: var(--dialog-text);
        border-radius: 12px;
        box-shadow: var(--dialog-shadow);
        overflow: hidden;
        border: 1px solid var(--dialog-border);
      }

      #${DIALOG_ID}_body {
        padding: 20px 18px 12px 18px;
        font-size: 14px;
        line-height: 1.5;
        word-break: break-word;
        white-space: pre-wrap;
        tab-size: 4;
        color: var(--dialog-text);
        background: var(--dialog-bg);
      }

      #${DIALOG_ID}_input_wrap {
        padding: 0 18px 18px 18px;
        background: var(--dialog-bg);
      }

      #${DIALOG_ID}_input_shell {
        position: relative;
      }

      #${DIALOG_ID}_input_shell.${DIALOG_ID}_input_shell_has_toggle #${DIALOG_ID}_input {
        padding-right: 42px;
      }

      #${DIALOG_ID}_input {
        width: 100%;
        box-sizing: border-box;
        padding: 10px 12px;
        font-size: 14px;
        line-height: 1.4;
        border-radius: 10px;
        border: 1px solid var(--dialog-input-border);
        background: var(--dialog-input-bg);
        color: var(--dialog-input-text);
        outline: none;
        box-shadow: none;
        appearance: none;
        -webkit-appearance: none;
      }

      #${DIALOG_ID}_input::-ms-reveal,
      #${DIALOG_ID}_input::-ms-clear {
        display: none;
      }

      #${DIALOG_ID}_toggle_visibility {
        position: absolute;
        top: 50%;
        right: 10px;
        width: 24px;
        height: 24px;
        padding: 0;
        margin: 0;
        transform: translateY(-50%);
        border: none;
        background: transparent;
        color: var(--dialog-input-text);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
      }

      #${DIALOG_ID}_toggle_visibility:hover,

      #${DIALOG_ID}_toggle_visibility:focus-visible {
        background: transparent;
        color: var(--dialog-input-text);
        outline: none;
      }

      #${DIALOG_ID}_toggle_visibility svg {
        display: block;
        width: 20px;
        height: 20px;
        stroke: currentColor;
        fill: none;
        stroke-width: 1.8;
        stroke-linecap: round;
        stroke-linejoin: round;
        pointer-events: none;
      }

      #${DIALOG_ID}_input.${DIALOG_ID}_input_hidden {
        font-size: 22px;
        letter-spacing: 0.08em;
      }

      #${DIALOG_ID}_input:focus {
        border-color: var(--dialog-input-focus);
      }

      #${DIALOG_ID}_footer {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        padding: 14px 18px 18px 18px;
        background: var(--dialog-bg);
      }

      .${DIALOG_ID}_btn {
        min-width: 90px;
        padding: 8px 14px;
        font-size: 14px;
        border-radius: 10px;
        border: 1px solid var(--dialog-btn-border);
        cursor: pointer;
        background: var(--dialog-btn-bg);
        color: var(--dialog-btn-text);
        transition:
          background 140ms ease,
          color 140ms ease,
          border-color 140ms ease,
          transform 120ms ease,
          box-shadow 120ms ease;
      }

      .${DIALOG_ID}_btn:hover,
      .${DIALOG_ID}_btn:focus-visible {
        background: var(--dialog-btn-hover-bg);
        color: var(--dialog-btn-hover-text);
        outline: none;
      }

      .${DIALOG_ID}_btn:active {
        transform: scale(0.96);
      }

      .${DIALOG_ID}_btn_ok,
      .${DIALOG_ID}_btn_cancel {
        background: var(--dialog-btn-bg);
        color: var(--dialog-btn-text);
        border-color: var(--dialog-btn-border);
      }

      .${DIALOG_ID}_btn_ok:hover,
      .${DIALOG_ID}_btn_ok:focus-visible,
      .${DIALOG_ID}_btn_cancel:hover,
      .${DIALOG_ID}_btn_cancel:focus-visible {
        background: var(--dialog-btn-hover-bg);
        color: var(--dialog-btn-hover-text);
        outline: none;
      }
    `;
    document.head.appendChild(style);
  }

  function removeDialog() {
    const overlay = getOverlay();
    if (overlay) overlay.remove();

    currentDialogMessageText = "";
    currentDialogTitleText = "";
    currentDialogOkText = "";
    currentDialogCancelText = "";
    currentDialogDefaultValue = "";
    currentDialogHiddenValue = false;
    currentDialogTextVisible = false;
  }

  function sendResult(key, value) {
    if (!(window.chrome && window.chrome.webview)) return;

    window.chrome.webview.postMessage({
      event: "input-string",
      key: key == null ? "" : String(key),
      value: value == null ? "" : String(value)
    });
  }

  function resolveDialogValue(rawValue, defaultValue) {
    const normalizedRawValue = normalizeInputValue(rawValue);
    if (normalizedRawValue !== "") {
      return normalizedRawValue;
    }

    return normalizeInputValue(defaultValue);
  }

  function cancelDialog() {
    removeDialog();
    currentDialogKey = "";
  }

  function submitDialog() {
    const input = getInputElement();
    const key = currentDialogKey;
    const value = resolveDialogValue(
      input ? input.value : "",
      currentDialogDefaultValue
    );

    removeDialog();
    currentDialogKey = "";

    sendResult(key, value);
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

    return document.activeElement === element;
  }

  function focusDialog(overlay, input) {
    requestAnimationFrame(function () {
      if (!overlay || !document.body.contains(overlay)) return;

      if (focusElement(input)) {
        try {
          const length = input.value.length;
          input.setSelectionRange(length, length);
        } catch (_) {}
        return;
      }

      focusElement(overlay);
    });
  }

  function attachKeydownHandlerOnce() {
    if (keydownHandlerAttached) return;
    keydownHandlerAttached = true;

    document.addEventListener("keydown", function (e) {
      const overlay = getOverlay();
      if (!overlay) return;

      const key = (e.key || "").toLowerCase();
      const code = e.code || "";

      if (key === "escape" || code === "Escape") {
        e.preventDefault();
        e.stopPropagation();
        cancelDialog();
        return;
      }

      if (e.isComposing) return;

      if (key === "enter" || code === "Enter" || code === "NumpadEnter") {
        e.preventDefault();
        e.stopPropagation();
        submitDialog();
      }
    });
  }

  function buildDialog(
    message,
    key,
    value,
    defaultValue,
    hiddenValue,
    titleText,
    okText,
    cancelText
  ) {
    const defaults = getDefaultDialogTexts();

    removeDialog();

    currentDialogKey = key == null ? "" : String(key);
    currentDialogDefaultValue = normalizeInputValue(defaultValue);
    currentDialogHiddenValue = !!hiddenValue;
    currentDialogTextVisible = false;

    currentDialogMessageText = normalizeDialogDisplayText(
      message || defaults.message
    );
    currentDialogTitleText = titleText || defaults.title;
    currentDialogOkText = okText || defaults.okText;
    currentDialogCancelText = cancelText || defaults.cancelText;

    ensureStyles();
    attachKeydownHandlerOnce();

    const overlay = document.createElement("div");
    overlay.id = DIALOG_ID + "_overlay";
    overlay.tabIndex = -1;

    const dialog = document.createElement("div");
    dialog.id = DIALOG_ID;
    dialog.tabIndex = -1;
    dialog.setAttribute("role", "dialog");
    dialog.setAttribute("aria-modal", "true");
    dialog.setAttribute("aria-label", currentDialogTitleText || DEFAULTS.title);
    dialog.setAttribute("aria-describedby", DIALOG_ID + "_body");

    const body = document.createElement("div");
    body.id = DIALOG_ID + "_body";
    body.textContent = currentDialogMessageText || DEFAULTS.message;

    const inputWrap = document.createElement("div");
    inputWrap.id = DIALOG_ID + "_input_wrap";

    const inputShell = document.createElement("div");
    inputShell.id = DIALOG_ID + "_input_shell";
    inputShell.className = currentDialogHiddenValue
      ? DIALOG_ID + "_input_shell_has_toggle"
      : "";

    const input = document.createElement("input");
    input.id = DIALOG_ID + "_input";
    input.autocomplete = "off";
    input.spellcheck = false;
    input.value = normalizeInputValue(value);

    syncInputType(input);

    let btnToggle = null;

    if (currentDialogHiddenValue) {
      btnToggle = document.createElement("button");
      btnToggle.id = DIALOG_ID + "_toggle_visibility";
      btnToggle.type = "button";

      btnToggle.addEventListener("mousedown", function (e) {
        e.preventDefault();
      });

      btnToggle.addEventListener("click", function (e) {
        e.preventDefault();
        toggleInputVisibility();
      });
    }

    const footer = document.createElement("div");
    footer.id = DIALOG_ID + "_footer";

    const btnCancel = document.createElement("button");
    btnCancel.className = `${DIALOG_ID}_btn ${DIALOG_ID}_btn_cancel`;
    btnCancel.type = "button";
    btnCancel.textContent = currentDialogCancelText || DEFAULTS.cancelText;

    const btnOk = document.createElement("button");
    btnOk.className = `${DIALOG_ID}_btn ${DIALOG_ID}_btn_ok`;
    btnOk.type = "button";
    btnOk.textContent = currentDialogOkText || DEFAULTS.okText;

    btnCancel.addEventListener("click", function () {
      cancelDialog();
    });

    btnOk.addEventListener("click", function () {
      submitDialog();
    });

    overlay.addEventListener("click", function (e) {
      if (e.target !== overlay) return;
      e.preventDefault();
      e.stopPropagation();
    });

    inputShell.appendChild(input);

    if (btnToggle) {
      inputShell.appendChild(btnToggle);
    }

    inputWrap.appendChild(inputShell);
    footer.appendChild(btnCancel);
    footer.appendChild(btnOk);

    dialog.appendChild(body);
    dialog.appendChild(inputWrap);
    dialog.appendChild(footer);
    overlay.appendChild(dialog);
    document.body.appendChild(overlay);

    syncVisibilityToggleState();
    focusDialog(overlay, input);
  }

  function handleHostMessage(data) {
    if (!data || typeof data !== "object") return;
    if (data.type !== "input-string") return;

    buildDialog(
      data.message || DEFAULTS.message,
      data.key,
      data.value,
      data.default,
      data.hidden_value,
      data.title || DEFAULTS.title,
      data.okText || DEFAULTS.okText,
      data.cancelText || DEFAULTS.cancelText
    );
  }

  window.addEventListener(INPUT_STRING_DIALOG_I18N_EVENT, function () {
    applyInputStringDialogDictionary();
  });

  applyInputStringDialogDictionary();

  if (window.chrome && window.chrome.webview) {
    window.chrome.webview.addEventListener("message", function (args) {
      handleHostMessage(args.data);
    });
  }

  window.showDelphiInputStringDialog = function (input) {
    let normalizedInput = input;

    if (typeof normalizedInput === "string") {
      try {
        normalizedInput = JSON.parse(normalizedInput);
      } catch (_) {
        normalizedInput = { message: normalizedInput };
      }
    }

    handleHostMessage({
      type: "input-string",
      message: normalizedInput?.message || DEFAULTS.message,
      key: normalizedInput?.key,
      value: normalizedInput?.value,
      default: normalizedInput?.default,
      hidden_value: normalizedInput?.hidden_value,
      title: normalizedInput?.title,
      okText: normalizedInput?.okText,
      cancelText: normalizedInput?.cancelText
    });
  };
})();
