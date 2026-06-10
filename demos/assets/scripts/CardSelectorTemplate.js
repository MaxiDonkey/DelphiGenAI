(() => {
  const STYLE_ID = "card-selection-dialog-style";
  const ROOT_ID = "card-selection-dialog-root";
  const BODY_OPEN_CLASS = "csd-overlay-open";
  const ICON_FONT_FAMILY = '"Segoe Fluent Icons", "Segoe UI Symbol", "Segoe UI", sans-serif';

  const CARD_SELECTOR_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  const CARD_SELECTOR_LABEL_KEYS = {
    selectPrefix: "cardSelector.actions.selectPrefix",
    close: "cardSelector.actions.close",
    edit: "cardSelector.actions.edit",
    settings: "cardSelector.actions.settings",
    cancel: "cardSelector.actions.cancel",
    select: "cardSelector.actions.select",
    empty: "cardSelector.messages.empty",
    noComment: "cardSelector.messages.noComment"
  };

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

  const DIALOG_DEFINITIONS = Object.freeze({
    function: { id: "function", wireValue: "Function", label: "Function", badge: "\uE1B3" },
    mcp: { id: "mcp", wireValue: "MCP", label: "MCP", badge: "\uE8CE" },
    skills: { id: "skills", wireValue: "Skills", label: "Skills", badge: "\uECA7" },
    agents: { id: "agents", wireValue: "Agents", label: "Agents", badge: "\uE99A" },
    custom: { id: "custom", wireValue: "Custom", label: "Custom", badge: "\uE15E" }
  });

  const DEFAULT_CONFIG = {
    dialog: "",
    title: "Select item",
    ariaLabel: "Select item",
    headerIcon: "\uE8FD",
    closeOnBackdrop: true,
    closeOnEscape: true,
    labels: {
      selectPrefix: "Select",
      close: "Close",
      edit: "Edit",
      settings: "Settings",
      cancel: "Cancel",
      select: "Select",
      empty: "No items available.",
      noSubtitle: "",
      noComment: "",
      badgeFallback: ""
    },
    cards: [],
    selectedId: "",
    settingsVisible: false
  };

  const state = {
    mounted: false,
    visible: false,
    config: cloneConfig(DEFAULT_CONFIG),
    cards: [],
    cardsById: Object.create(null),
    selectedId: "",
    textOverrides: {
      title: false,
      ariaLabel: false,
      labels: Object.create(null)
    },
    elements: {
      root: null,
      dialog: null,
      title: null,
      icon: null,
      list: null,
      close: null,
      btnSettings: null,
      btnCancel: null,
      btnSelect: null,
      footerSummary: null,
      footerSummaryName: null,
      footerSummaryText: null
    }
  };

  function cloneConfig(config) {
    const source = config && typeof config === "object" ? config : {};
    const labels = source.labels && typeof source.labels === "object" ? source.labels : {};
    return {
      dialog: normalizeDialogType(source.dialog),
      title: String(source.title == null ? DEFAULT_CONFIG.title : source.title),
      ariaLabel: String(
        source.ariaLabel == null
          ? (source.title == null ? DEFAULT_CONFIG.ariaLabel : source.title)
          : source.ariaLabel
      ),
      headerIcon: String(source.headerIcon == null ? DEFAULT_CONFIG.headerIcon : source.headerIcon),
      closeOnBackdrop: source.closeOnBackdrop !== false,
      closeOnEscape: source.closeOnEscape !== false,
      labels: Object.assign({}, DEFAULT_CONFIG.labels, labels),
      cards: Array.isArray(source.cards) ? source.cards.slice() : [],
      selectedId: String(source.selectedId == null ? "" : source.selectedId),
      settingsVisible: source.settingsVisible === true
    };
  }

  function normalizeDialogType(dialog) {
    const value = String(dialog == null ? "" : dialog).trim().toLowerCase();

    if (!value) return "";
    if (value === "function") return "function";
    if (value === "mcp") return "mcp";
    if (value === "skills" || value === "skill") return "skills";
    if (value === "agents" || value === "agent") return "agents";
    if (value === "custom") return "custom";

    return "";
  }

  function getDialogDefinition(dialog) {
    const normalizedDialog = normalizeDialogType(dialog);
    return normalizedDialog ? (DIALOG_DEFINITIONS[normalizedDialog] || null) : null;
  }

  function getDialogWireValue() {
    const dialogDefinition = getDialogDefinition(state.config.dialog);
    return dialogDefinition ? dialogDefinition.wireValue : "";
  }

  function getDialogLabel(dialogDefinition) {
    if (!dialogDefinition) return "";

    return t(
      "cardSelector.dialogs." + dialogDefinition.id + ".label",
      dialogDefinition.label
    );
  }

  function getTranslatedDefaultLabel(labelName) {
    const key = CARD_SELECTOR_LABEL_KEYS[labelName];
    const fallback = DEFAULT_CONFIG.labels[labelName];

    if (!key) {
      return String(fallback == null ? "" : fallback);
    }

    return t(key, fallback);
  }

  function getResolvedLabel(labelName) {
    if (state.textOverrides.labels[labelName]) {
      return String(
        state.config.labels && state.config.labels[labelName] != null
          ? state.config.labels[labelName]
          : ""
      );
    }

    return getTranslatedDefaultLabel(labelName);
  }

  function getResolvedPanelTitle(dialogDefinition) {
    if (state.textOverrides.title) {
      return String(state.config.title == null ? "" : state.config.title);
    }

    if (!dialogDefinition) {
      return t("cardSelector.panel.title", DEFAULT_CONFIG.title);
    }

    return t(
      "cardSelector.panel.selectDialogTitle",
      "{selectPrefix} {dialogLabel}",
      {
        selectPrefix: getResolvedLabel("selectPrefix"),
        dialogLabel: getDialogLabel(dialogDefinition)
      }
    );
  }

  function getResolvedAriaLabel(resolvedTitle) {
    if (state.textOverrides.ariaLabel) {
      return String(state.config.ariaLabel == null ? "" : state.config.ariaLabel);
    }

    if (state.config.dialog) {
      return resolvedTitle;
    }

    return t("cardSelector.panel.ariaLabel", DEFAULT_CONFIG.ariaLabel);
  }

  function registerLabelOverrides(labels) {
    if (!labels || typeof labels !== "object") return;

    Object.keys(labels).forEach(function (key) {
      state.textOverrides.labels[key] = labels[key] != null;
    });
  }

  function getResolvedHeaderTitle() {
    const dialogDefinition = getDialogDefinition(state.config.dialog);
    return getResolvedPanelTitle(dialogDefinition);
  }

  function getResolvedHeaderIcon() {
    const dialogDefinition = getDialogDefinition(state.config.dialog);
    return dialogDefinition ? dialogDefinition.badge : state.config.headerIcon;
  }

  function getResolvedCardBadge(card) {
    const dialogDefinition = getDialogDefinition(state.config.dialog);

    if (card && card.badge) {
      return card.badge;
    }

    if (dialogDefinition && dialogDefinition.badge) {
      return dialogDefinition.badge;
    }

    return state.config.labels.badgeFallback || "";
  }

  function esc(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function post(message) {
    try {
      if (window.chrome && window.chrome.webview && typeof window.chrome.webview.postMessage === "function") {
        window.chrome.webview.postMessage(message);
      }
    } catch (_) {}
  }

  function normalizeCard(item, index) {
    const source = item && typeof item === "object" ? item : {};
    const id = String(source.id == null ? ("card-" + index) : source.id).trim();
    const commentaire = String(
      source.commentaire == null
        ? (
            source.comment == null
              ? (
                  source.subTitle == null
                    ? (source.subtitle == null ? "" : source.subtitle)
                    : source.subTitle
                )
              : source.comment
          )
        : source.commentaire
    );

    return {
      id: id,
      name: String(source.name == null ? "" : source.name),
      commentaire: commentaire,
      badge: String(source.badge == null ? "" : source.badge)
    };
  }

  function isCardSelectable(item) {
    const source = item && typeof item === "object" ? item : {};
    return source.selectable !== false;
  }

  function setCards(cards) {
    const list = Array.isArray(cards) ? cards : [];
    const cardsById = Object.create(null);
    const normalized = [];
    let i;

    for (i = 0; i < list.length; i += 1) {
      if (!isCardSelectable(list[i])) continue;
      const card = normalizeCard(list[i], i);
      if (!card.id || cardsById[card.id]) continue;
      cardsById[card.id] = card;
      normalized.push(card);
    }

    state.cards = normalized;
    state.cardsById = cardsById;

    if (!state.selectedId || !state.cardsById[state.selectedId]) {
      state.selectedId = normalized.length ? normalized[0].id : "";
    }
  }

  function getSelectedCard() {
    return state.selectedId ? (state.cardsById[state.selectedId] || null) : null;
  }

  function ensureStyle() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      body.${BODY_OPEN_CLASS} {
        overflow: hidden;
      }

      .csd-overlay {
        position: fixed;
        inset: 0;
        z-index: 7000;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 16px;
        box-sizing: border-box;
      }

      .csd-overlay.is-visible {
        display: flex;
      }

      .csd-backdrop {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.48);
        backdrop-filter: blur(6px);
      }

      .csd-dialog {
        position: relative;
        width: min(980px, calc(100vw - 32px));
        height: 600px;
        min-height: 600px;
        max-height: 600px;
        display: grid;
        grid-template-rows: auto minmax(0, 1fr) auto;
        border: 1px solid var(--input-shell-border);
        border-radius: 20px;
        box-sizing: border-box;
        overflow: hidden;
        background: color-mix(in srgb, var(--bg-main) 88%, transparent);
        box-shadow: 0 28px 90px rgba(0,0,0,0.42);
        backdrop-filter: blur(18px);
        color: var(--text-main);
        color-scheme: dark;
      }

      [data-theme="light"] .csd-dialog {
        color-scheme: light;
      }

      .csd-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        padding: 20px 24px;
        border-bottom: 1px solid var(--input-shell-border);
      }

      .csd-title-wrap {
        min-width: 0;
        display: flex;
        align-items: center;
        gap: 12px;
      }

      .csd-header-icon {
        width: 34px;
        height: 34px;
        border-radius: 10px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid var(--input-shell-border);
        background: var(--input-button-bg);
        color: var(--text-main);
        font-family: ${ICON_FONT_FAMILY};
        font-size: 22px;
        line-height: 1;
        flex: 0 0 auto;
      }

      .csd-title {
        min-width: 0;
        font-size: 18px;
        font-weight: 700;
        color: var(--text-main);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .csd-close {
        appearance: none;
        -webkit-appearance: none;
        width: 38px;
        height: 38px;
        padding: 0;
        margin: 0;
        border: 1px solid var(--input-shell-border);
        border-radius: 12px;
        background: var(--input-button-bg);
        color: var(--text-main);
        font-size: 20px;
        line-height: 20px;
        cursor: pointer;
        flex: 0 0 auto;
      }

      .csd-close:hover,
      .csd-btn:hover {
        background: var(--input-button-hover-bg);
        color: var(--input-button-hover-text);
      }

      .csd-close:focus,
      .csd-card:focus,
      .csd-btn:focus {
        outline: 2px solid color-mix(in srgb, var(--reasoning-accent) 60%, transparent);
        outline-offset: 1px;
      }

      .csd-body {
        min-height: 0;
        min-width: 0;
      }

      .csd-list {
        min-height: 0;
        height: 100%;
        padding: 18px 18px 22px;
        overflow-y: auto;
        overflow-x: hidden;
        scrollbar-gutter: stable;
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb) transparent;
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
        grid-auto-rows: 124px;
        gap: 18px;
        align-content: start;
        box-sizing: border-box;
      }

      .csd-list::-webkit-scrollbar {
        width: 12px;
        height: 12px;
      }

      .csd-list::-webkit-scrollbar-thumb {
        background: var(--scrollbar-thumb);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      .csd-list::-webkit-scrollbar-thumb:hover {
        background: var(--scrollbar-thumb-hover);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      .csd-empty {
        min-height: 120px;
        border: 1px dashed color-mix(in srgb, var(--input-shell-border) 78%, transparent);
        border-radius: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 24px;
        color: var(--request-params-nav-muted);
        background: color-mix(in srgb, var(--input-shell-bg) 42%, transparent);
        text-align: center;
      }

      .csd-card {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        min-height: 124px;
        height: 124px;
        padding: 16px 20px;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 78%, transparent);
        border-radius: 16px;
        box-sizing: border-box;
        background: color-mix(in srgb, var(--input-shell-bg) 58%, transparent);
        color: var(--text-main);
        text-align: left;
        cursor: pointer;
        display: grid;
        grid-template-rows: auto 1fr;
        gap: 10px;
        transition: transform 120ms ease, border-color 120ms ease, box-shadow 120ms ease, background 120ms ease;
      }

      .csd-card:hover {
        transform: translateY(-1px);
        background: color-mix(in srgb, var(--input-shell-bg-hover) 74%, transparent);
      }

      .csd-card.is-selected {
        border-color: color-mix(in srgb, var(--reasoning-accent) 42%, var(--input-shell-border));
        box-shadow: inset 2px 0 0 var(--reasoning-accent);
        background: color-mix(in srgb, var(--reasoning-accent) 7%, var(--input-shell-bg) 93%);
      }

      .csd-card-top {
        min-width: 0;
        display: flex;
        align-items: flex-start;
        gap: 12px;
      }

      .csd-card-badge {
        min-width: 28px;
        height: 28px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 9px;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 78%, transparent);
        background: color-mix(in srgb, var(--input-button-bg) 74%, transparent);
        color: var(--request-params-nav-title-inactive);
        font-family: ${ICON_FONT_FAMILY};
        font-size: 16px;
        line-height: 1;
        flex: 0 0 auto;
      }

      .csd-card-title-wrap {
        min-width: 0;
        flex: 1 1 auto;
      }

      .csd-card-name {
        font-size: 16px;
        font-weight: 700;
        line-height: 1.2;
        color: var(--text-main);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .csd-card-comment {
        font-size: 13px;
        line-height: 1.25;
        color: var(--request-params-nav-muted);
        overflow-wrap: anywhere;
        word-break: break-word;
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: normal;
      }

      .csd-footer {
        display: flex;
        align-items: stretch;
        justify-content: space-between;
        gap: 16px;
        height: 80px;
        min-height: 80px;
        padding: 12px 20px;
        border-top: 1px solid var(--input-shell-border);
        box-sizing: border-box;
        flex: 0 0 80px;
      }

      .csd-footer-left,
      .csd-footer-right {
        display: flex;
        align-items: center;
        gap: 12px;
      }

      .csd-footer-left {
        min-width: 0;
        flex: 1 1 auto;
        align-items: flex-start;
      }

      .csd-footer-right {
        flex: 0 0 auto;
        margin-left: auto;
      }

      .csd-selection-summary {
        min-width: 0;
        max-width: min(550px, 100%);
        flex: 1 1 auto;
        display: grid;
        gap: 3px;
      }

      .csd-selection-summary[hidden] {
        display: none;
      }

      .csd-selection-name {
        min-width: 0;
        font-size: 13px;
        font-weight: 700;
        line-height: 1.2;
        color: var(--text-main);
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .csd-selection-comment {
        min-width: 0;
        font-size: 12px;
        line-height: 1.3;
        color: var(--request-params-nav-muted);
        overflow-wrap: anywhere;
        word-break: break-word;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .csd-btn {
        appearance: none;
        -webkit-appearance: none;
        min-width: 112px;
        height: 44px;
        padding: 0 22px;
        border-radius: 14px;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 82%, transparent);
        background: color-mix(in srgb, var(--input-shell-bg) 58%, transparent);
        color: var(--text-main);
        font: inherit;
        font-size: 16px;
        font-weight: 700;
        cursor: pointer;
        transition: background 120ms ease, color 120ms ease, opacity 120ms ease, transform 120ms ease;
      }

      .csd-btn:active,
      .csd-close:active {
        transform: scale(0.97);
      }

      .csd-btn[disabled] {
        opacity: 0.5;
        cursor: default;
      }

      .csd-btn[disabled]:hover {
        background: color-mix(in srgb, var(--input-shell-bg) 58%, transparent);
        color: var(--text-main);
      }

      .csd-btn-primary {
        border-color: color-mix(in srgb, var(--reasoning-accent) 28%, var(--input-shell-border));
        background: color-mix(in srgb, var(--reasoning-accent) 12%, var(--input-shell-bg) 88%);
      }

      @media (max-width: 820px) {
        .csd-dialog {
          width: calc(100vw - 16px);
          height: calc(100vh - 16px);
          min-height: 0;
          max-height: none;
        }

        .csd-list {
          grid-template-columns: 1fr;
          padding: 14px;
          gap: 14px;
        }

        .csd-header,
        .csd-footer {
          padding-left: 14px;
          padding-right: 14px;
        }

        .csd-btn {
          min-width: 96px;
          padding: 0 18px;
        }
      }
    `;

    document.head.appendChild(style);
  }

  function cardHtml(card) {
    const selected = card.id === state.selectedId ? " is-selected" : "";
    const emptyComment = getResolvedLabel("noComment");

    return `
      <button
        type="button"
        class="csd-card${selected}"
        data-role="card"
        data-card-id="${esc(card.id)}"
        aria-pressed="${card.id === state.selectedId ? "true" : "false"}"
      >
        <span class="csd-card-top">
          <span class="csd-card-badge">${esc(getResolvedCardBadge(card))}</span>
          <span class="csd-card-title-wrap">
            <span class="csd-card-name">${esc(card.name)}</span>
          </span>
        </span>
        <span class="csd-card-comment">${esc(card.commentaire || emptyComment || "")}</span>
      </button>
    `;
  }

  function renderTitle() {
    const resolvedTitle = getResolvedHeaderTitle();
    const resolvedIcon = getResolvedHeaderIcon();
    const resolvedAriaLabel = getResolvedAriaLabel(resolvedTitle);

    if (!state.elements.title || !state.elements.icon) return;

    state.elements.title.textContent = resolvedTitle;
    state.elements.icon.textContent = resolvedIcon;

    if (state.elements.dialog) {
      state.elements.dialog.setAttribute("aria-label", resolvedAriaLabel || resolvedTitle);
    }
  }

  function renderButtons() {
    let settingsLabel;

    if (!state.elements.close) return;

    settingsLabel =
      getResolvedLabel("settings") ||
      getResolvedLabel("edit") ||
      DEFAULT_CONFIG.labels.settings;

    state.elements.close.setAttribute("aria-label", getResolvedLabel("close"));
    state.elements.btnSettings.textContent = settingsLabel;
    state.elements.btnCancel.textContent = getResolvedLabel("cancel");
    state.elements.btnSelect.textContent = getResolvedLabel("select");
    state.elements.btnSettings.hidden = !state.config.settingsVisible;
    state.elements.btnSettings.disabled = !state.config.settingsVisible;
    state.elements.btnSelect.disabled = !state.selectedId;
  }

  function renderCards() {
    if (!state.elements.list) return;

    if (!state.cards.length) {
      state.elements.list.innerHTML = `<div class="csd-empty">${esc(getResolvedLabel("empty"))}</div>`;
      return;
    }

    state.elements.list.innerHTML = state.cards.map(cardHtml).join("");
  }

  function renderSelectionSummary() {
    const selectedCard = getSelectedCard();
    let comment;

    if (
      !state.elements.footerSummary ||
      !state.elements.footerSummaryName ||
      !state.elements.footerSummaryText
    ) {
      return;
    }

    if (!selectedCard) {
      state.elements.footerSummary.hidden = true;
      state.elements.footerSummaryName.textContent = "";
      state.elements.footerSummaryText.textContent = "";
      state.elements.footerSummary.removeAttribute("title");
      return;
    }

    comment = selectedCard.commentaire || getResolvedLabel("noComment") || "";
    state.elements.footerSummary.hidden = false;
    state.elements.footerSummaryName.textContent = selectedCard.name || "";
    state.elements.footerSummaryText.textContent = comment;
    state.elements.footerSummary.setAttribute(
      "title",
      (selectedCard.name ? selectedCard.name + "\n" : "") + comment
    );
  }

  function render() {
    renderTitle();
    renderButtons();
    renderSelectionSummary();
    renderCards();
  }

  function closePanel() {
    if (!state.visible || !state.elements.root) return;
    state.visible = false;
    state.elements.root.classList.remove("is-visible");
    document.body.classList.remove(BODY_OPEN_CLASS);
  }

  function showPanel() {
    ensureMounted();
    render();
    state.visible = true;
    state.elements.root.classList.add("is-visible");
    document.body.classList.add(BODY_OPEN_CLASS);
  }

  function hidePanel() {
    closePanel();
  }

  function setSettingsVisibility(visible, renderNow) {
    state.config.settingsVisible = visible === true;

    if (renderNow !== false && state.mounted) {
      renderButtons();
    }

    return getState();
  }

  function selectCard(cardId, emit) {
    const normalizedId = String(cardId == null ? "" : cardId);
    if (!normalizedId || !state.cardsById[normalizedId]) return null;
    state.selectedId = normalizedId;
    render();
    if (emit !== false) {
      post({
        event: "card-selection-dialog-selection-changed",
        dialog: getDialogWireValue(),
        selectedId: state.selectedId,
        selectedCard: getSelectedCard()
      });
    }
    return getSelectedCard();
  }

  function emitSettings() {
    post({
      event: "card-selection-dialog-settings",
      dialog: getDialogWireValue()
    });
  }

  function emitCancel() {
    post({
      event: "card-selection-dialog-cancel",
      selectedId: state.selectedId,
      selectedCard: getSelectedCard()
    });
  }

  function emitSelect() {
    const selectedCard = getSelectedCard();
    if (!selectedCard) return;
    post({
      event: "card-selection-dialog-select",
      dialog: getDialogWireValue(),
      selectedId: selectedCard.id,
      selectedCard: selectedCard
    });
  }

  function confirmSelection() {
    const selectedCard = getSelectedCard();
    if (!selectedCard) return;

    emitSelect();
    closePanel();
  }

  function handleClick(event) {
    const target = event.target.closest("[data-role]");
    if (!target) return;

    const role = target.getAttribute("data-role");

    if (role === "backdrop") {
      if (state.config.closeOnBackdrop) {
        emitCancel();
        closePanel();
      }
      return;
    }

    if (role === "close" || role === "cancel") {
      emitCancel();
      closePanel();
      return;
    }

    if (role === "settings") {
      emitSettings();
      return;
    }

    if (role === "select") {
      if (!state.selectedId) return;
      confirmSelection();
      return;
    }

    if (role === "card") {
      event.preventDefault();

      if (event.detail > 1) {
        return;
      }

      selectCard(target.getAttribute("data-card-id"), true);
    }
  }

  function handleDoubleClick(event) {
    const target = event.target.closest("[data-role='card']");
    if (!target) return;

    event.preventDefault();

    const selectedCard = selectCard(target.getAttribute("data-card-id"), false);
    if (!selectedCard) return;

    confirmSelection();
  }

  function handleKeydown(event) {
    if (!state.visible) return;

    if (event.key === "Escape" && state.config.closeOnEscape) {
      event.preventDefault();
      emitCancel();
      closePanel();
      return;
    }

    if (event.key === "Enter") {
      event.preventDefault();

      if (!state.selectedId) return;

      confirmSelection();
    }
  }

  function ensureMounted() {
    if (state.mounted && state.elements.root) return;

    ensureStyle();

    const root = document.createElement("div");
    root.id = ROOT_ID;
    root.className = "csd-overlay";
    root.innerHTML = `
      <div class="csd-backdrop" data-role="backdrop"></div>
      <div class="csd-dialog" role="dialog" aria-modal="true" aria-label="${esc(state.config.ariaLabel)}">
        <div class="csd-header">
          <div class="csd-title-wrap">
            <div class="csd-header-icon"></div>
            <div class="csd-title"></div>
          </div>
          <button type="button" class="csd-close" data-role="close">×</button>
        </div>
        <div class="csd-body">
          <div class="csd-list"></div>
        </div>
        <div class="csd-footer">
          <div class="csd-footer-left">
            <button type="button" class="csd-btn" data-role="settings" hidden></button>
            <div class="csd-selection-summary" aria-live="polite" hidden>
              <div class="csd-selection-name"></div>
              <div class="csd-selection-comment"></div>
            </div>
          </div>
          <div class="csd-footer-right">
            <button type="button" class="csd-btn" data-role="cancel"></button>
            <button type="button" class="csd-btn csd-btn-primary" data-role="select"></button>
          </div>
        </div>
      </div>
    `;

    document.body.appendChild(root);

    state.elements.root = root;
    state.elements.dialog = root.querySelector(".csd-dialog");
    state.elements.title = root.querySelector(".csd-title");
    state.elements.icon = root.querySelector(".csd-header-icon");
    state.elements.list = root.querySelector(".csd-list");
    state.elements.close = root.querySelector(".csd-close");
    state.elements.btnSettings = root.querySelector('[data-role="settings"]');
    state.elements.btnCancel = root.querySelector('[data-role="cancel"]');
    state.elements.btnSelect = root.querySelector('[data-role="select"]');
    state.elements.footerSummary = root.querySelector(".csd-selection-summary");
    state.elements.footerSummaryName = root.querySelector(".csd-selection-name");
    state.elements.footerSummaryText = root.querySelector(".csd-selection-comment");

    root.addEventListener("click", handleClick);
    root.addEventListener("dblclick", handleDoubleClick);
    document.addEventListener("keydown", handleKeydown);

    state.mounted = true;
    render();
  }

  function applyConfig(config, renderNow) {
    const source = config && typeof config === "object" ? config : {};
    const nextConfigSource = Object.assign({}, state.config, source);

    if (Object.prototype.hasOwnProperty.call(source, "title")) {
      state.textOverrides.title = source.title != null;
    }

    if (Object.prototype.hasOwnProperty.call(source, "ariaLabel")) {
      state.textOverrides.ariaLabel = source.ariaLabel != null;
    } else if (Object.prototype.hasOwnProperty.call(source, "title")) {
      state.textOverrides.ariaLabel = source.title != null;
    }

    if (Object.prototype.hasOwnProperty.call(source, "labels")) {
      registerLabelOverrides(source.labels);
    }

    if (Object.prototype.hasOwnProperty.call(source, "dialog")) {
      nextConfigSource.dialog = normalizeDialogType(source.dialog);
    }

    const nextConfig = cloneConfig(nextConfigSource);
    state.config = nextConfig;
    setCards(nextConfig.cards);

    if (nextConfig.selectedId && state.cardsById[nextConfig.selectedId]) {
      state.selectedId = nextConfig.selectedId;
    }

    if (renderNow !== false) {
      ensureMounted();
      render();
    }

    return getState();
  }

  function getState() {
    const dialogDefinition = getDialogDefinition(state.config.dialog);
    const resolvedTitle = getResolvedHeaderTitle();
    const resolvedAriaLabel = getResolvedAriaLabel(resolvedTitle);

    return JSON.parse(JSON.stringify({
      visible: state.visible,
      dialog: state.config.dialog,
      dialogLabel: dialogDefinition ? getDialogLabel(dialogDefinition) : "",
      title: state.config.title,
      resolvedTitle: resolvedTitle,
      ariaLabel: resolvedAriaLabel,
      headerIcon: state.config.headerIcon,
      resolvedHeaderIcon: getResolvedHeaderIcon(),
      labels: state.config.labels,
      settingsVisible: state.config.settingsVisible,
      selectedId: state.selectedId,
      selectedCard: getSelectedCard(),
      cards: state.cards
    }));
  }

  window.addEventListener(CARD_SELECTOR_I18N_EVENT, function () {
    if (state.mounted) {
      render();
    }
  });

  window.CardSelectionDialog = {
    show: showPanel,
    hide: hidePanel,
    setData: applyConfig,
    setCards: function (cards) {
      state.config.cards = Array.isArray(cards) ? cards.slice() : [];
      setCards(state.config.cards);
      if (state.mounted) render();
      return getState();
    },
    setTitle: function (title) {
      state.textOverrides.title = true;
      state.textOverrides.ariaLabel = true;
      state.config.title = String(title == null ? "" : title);
      state.config.ariaLabel = state.config.title;
      if (state.mounted) render();
      return getState();
    },
    setHeaderIcon: function (glyph) {
      state.config.headerIcon = String(glyph == null ? "" : glyph);
      if (state.mounted) render();
      return getState();
    },
    setDialog: function (dialog) {
      state.config.dialog = normalizeDialogType(dialog);
      if (state.mounted) render();
      return getState();
    },
    setLabels: function (labels) {
      registerLabelOverrides(labels);
      state.config.labels = Object.assign({}, state.config.labels, labels || {});
      if (state.mounted) render();
      return getState();
    },
    setSettingsVisibility: function (visible) {
      return setSettingsVisibility(visible, true);
    },
    selectCard: function (cardId) {
      return selectCard(cardId, false);
    },
    getState: getState
  };

  if (window.chrome && window.chrome.webview && typeof window.chrome.webview.addEventListener === "function") {
    window.chrome.webview.addEventListener("message", function (event) {
      const msg = event && event.data;
      if (!msg || typeof msg !== "object") return;

      if (msg.type === "card-selection-dialog-show") {
        if (Object.prototype.hasOwnProperty.call(msg, "dialog")) {
          state.config.dialog = normalizeDialogType(msg.dialog);
        }
        showPanel();
        return;
      }

      if (msg.type === "card-selection-dialog-hide") {
        hidePanel();
        return;
      }

      if (msg.type === "card-selection-dialog-set-data") {
        applyConfig(msg, true);
        return;
      }

      if (msg.type === "cards-settings-visibity") {
        setSettingsVisibility(msg.value === true, true);
        return;
      }

      if (msg.type === "card-selection-dialog-select" && msg.cardId) {
        selectCard(msg.cardId, false);
      }
    });
  }
})();
