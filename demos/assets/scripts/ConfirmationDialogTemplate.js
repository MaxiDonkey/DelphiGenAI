(function () {
  const DIALOG_ID = "__delphi_confirmation_dialog__";
  const STYLE_ID = "__delphi_confirmation_dialog_style__";
  const DEFAULTS = {
    title: "Confirmation",
    question: "Please confirm.",
    yesText: "Yes",
    noText: "No"
  };

  let keydownHandlerAttached = false;
  let currentDialogGoal = "";
  let currentDialogTag = "";
  let currentDialogIndex = "";

    const CONFIRMATION_DIALOG_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  let currentDialogText = "";
  let currentDialogTitleText = "";
  let currentDialogYesText = "";
  let currentDialogNoText = "";

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
      title: t("confirmation.title", "Confirmation"),
      question: t("confirmation.question", "Please confirm."),
      yesText: t("confirmation.yes", "Yes"),
      noText: t("confirmation.no", "No")
    };
  }

  function getDefaultDialogTexts() {
    return {
      title: t("confirmation.title", "Confirmation"),
      question: t("confirmation.question", "Please confirm."),
      yesText: t("confirmation.yes", "Yes"),
      noText: t("confirmation.no", "No")
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

  function applyConfirmationDialogDictionary() {
    const defaults = getDefaultDialogTexts();

    DEFAULTS.title = defaults.title;
    DEFAULTS.question = defaults.question;
    DEFAULTS.yesText = defaults.yesText;
    DEFAULTS.noText = defaults.noText;

    const overlay = getOverlay();
    if (!overlay) return;

    const dialog = overlay.querySelector("#" + DIALOG_ID);
    const body = overlay.querySelector("#" + DIALOG_ID + "_body");
    const btnNo = overlay.querySelector("." + DIALOG_ID + "_btn_no");
    const btnYes = overlay.querySelector("." + DIALOG_ID + "_btn_yes");

    if (dialog) {
      dialog.setAttribute("aria-label", currentDialogTitleText || DEFAULTS.title);
    }

    if (body) {
      body.textContent = currentDialogText || DEFAULTS.question;
    }

    if (btnNo) {
      btnNo.textContent = currentDialogNoText || DEFAULTS.noText;
    }

    if (btnYes) {
      btnYes.textContent = currentDialogYesText || DEFAULTS.yesText;
    }
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
        --dialog-overlay-bg: rgba(0, 0, 0, 0.35);
        --dialog-bg: var(--input-shell-bg, var(--bg-main, #2f2f2f));
        --dialog-text: var(--text-main, #ddd);
        --dialog-border: var(--input-shell-border, rgba(255,255,255,0.08));
        --dialog-shadow: var(--input-shell-shadow, 0 10px 30px rgba(0,0,0,0.35));
        --dialog-header-bg: var(--bubble-assistant-bg, var(--dialog-bg));
        --dialog-header-text: var(--text-main, #ddd);
        --dialog-header-border: var(--dialog-border);
        --dialog-btn-bg: var(--input-button-bg, #3a3a3a);
        --dialog-btn-text: var(--input-button-text, #ffffff);
        --dialog-btn-hover-bg: var(--input-button-hover-bg, #ffffff);
        --dialog-btn-hover-text: var(--input-button-hover-text, #111);
        --dialog-btn-border: var(--dialog-border);
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
        padding: 20px 18px;
        font-size: 14px;
        line-height: 1.5;
        word-break: break-word;
        white-space: pre-wrap;
        tab-size: 4;
        color: var(--dialog-text);
        background: var(--dialog-bg);
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

      .${DIALOG_ID}_btn_yes,
      .${DIALOG_ID}_btn_no {
        background: var(--dialog-btn-bg);
        color: var(--dialog-btn-text);
        border-color: var(--dialog-btn-border);
      }

      .${DIALOG_ID}_btn_yes:hover,
      .${DIALOG_ID}_btn_yes:focus-visible,
      .${DIALOG_ID}_btn_no:hover,
      .${DIALOG_ID}_btn_no:focus-visible {
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

    currentDialogText = "";
    currentDialogTitleText = "";
    currentDialogYesText = "";
    currentDialogNoText = "";
  }

  function sendResult(value, goal, tag, index) {
    if (!(window.chrome && window.chrome.webview)) return;

    const normalizedIndex = Number(index);

    window.chrome.webview.postMessage({
      event: "dialog-confirmation-response",
      value: !!value,
      goal: goal == null ? "" : goal,
      tag: tag == null ? "" : tag,
      index: Number.isFinite(normalizedIndex) ? Math.trunc(normalizedIndex) : 0
    });
  }

  function closeDialog(value) {
    const goal = currentDialogGoal;
    const tag = currentDialogTag;
    const index = currentDialogIndex;

    removeDialog();

    currentDialogGoal = "";
    currentDialogTag = "";
    currentDialogIndex = "";

    sendResult(value, goal, tag, index);
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

  function focusDialog(overlay, btnYes) {
    requestAnimationFrame(function () {
      if (!overlay || !document.body.contains(overlay)) return;

      if (focusElement(btnYes)) return;
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
      const btnNo = overlay.querySelector("." + DIALOG_ID + "_btn_no");
      const btnYes = overlay.querySelector("." + DIALOG_ID + "_btn_yes");

      if (key === "escape" || code === "Escape") {
        e.preventDefault();
        e.stopPropagation();
        closeDialog(false);
        return;
      }

      if (key === "n" || code === "KeyN") {
        e.preventDefault();
        e.stopPropagation();
        if (btnNo) btnNo.click();
        return;
      }

      if (key === "t" || code === "KeyT" || key === "y" || code === "KeyY") {
        e.preventDefault();
        e.stopPropagation();
        if (btnYes) btnYes.click();
        return;
      }
    });
  }

  function buildDialog(text, goal, tag, index, titleText, yesText, noText) {
    const defaults = getDefaultDialogTexts();

    removeDialog();
    currentDialogGoal = goal == null ? "" : goal;
    currentDialogTag = tag == null ? "" : tag;
    currentDialogIndex = index == null ? "" : index;

    currentDialogText = normalizeDialogDisplayText(text || defaults.question);
    currentDialogTitleText = titleText || defaults.title;
    currentDialogYesText = yesText || defaults.yesText;
    currentDialogNoText = noText || defaults.noText;

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
        body.textContent = currentDialogText || DEFAULTS.question;

    const footer = document.createElement("div");
    footer.id = DIALOG_ID + "_footer";

    const btnNo = document.createElement("button");
    btnNo.className = `${DIALOG_ID}_btn ${DIALOG_ID}_btn_no`;
    btnNo.type = "button";
    btnNo.textContent = currentDialogNoText || DEFAULTS.noText;

    const btnYes = document.createElement("button");
    btnYes.className = `${DIALOG_ID}_btn ${DIALOG_ID}_btn_yes`;
    btnYes.type = "button";
    btnYes.textContent = currentDialogYesText || DEFAULTS.yesText;

    btnNo.addEventListener("click", function () {
      closeDialog(false);
    });

    btnYes.addEventListener("click", function () {
      closeDialog(true);
    });

    overlay.addEventListener("click", function (e) {
      if (e.target !== overlay) return;
      e.preventDefault();
      e.stopPropagation();
    });

    footer.appendChild(btnNo);
    footer.appendChild(btnYes);

    dialog.appendChild(body);
    dialog.appendChild(footer);
    overlay.appendChild(dialog);
    document.body.appendChild(overlay);

    focusDialog(overlay, btnYes);
  }

  function handleHostMessage(data) {
    if (!data || typeof data !== "object") return;
    if (data.type !== "dialog-confirmation-request") return;

    buildDialog(
      data.text || DEFAULTS.question,
      data.goal,
      data.tag,
      data.index,
      data.title || DEFAULTS.title,
      data.yesText || DEFAULTS.yesText,
      data.noText || DEFAULTS.noText
    );
  }

  window.addEventListener(CONFIRMATION_DIALOG_I18N_EVENT, function () {
    applyConfirmationDialogDictionary();
  });

  applyConfirmationDialogDictionary();

  if (window.chrome && window.chrome.webview) {
    window.chrome.webview.addEventListener("message", function (args) {
      handleHostMessage(args.data);
    });
  }

  window.showDelphiConfirmationDialog = function (input) {
    let normalizedInput = input;

    if (typeof normalizedInput === "string") {
      try {
        normalizedInput = JSON.parse(normalizedInput);
      } catch (_) {
        normalizedInput = { text: normalizedInput };
      }
    }

    handleHostMessage({
      type: "dialog-confirmation-request",
      text: normalizedInput?.text || DEFAULTS.question,
      goal: normalizedInput?.goal,
      tag: normalizedInput?.tag,
      index: normalizedInput?.index,
      title: normalizedInput?.title,
      yesText: normalizedInput?.yesText,
      noText: normalizedInput?.noText
    });
  };

})();
