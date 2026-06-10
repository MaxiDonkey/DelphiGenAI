(function () {
  const ROOT_ID = "__delphi_left_dock_root__";
  const RAIL_ID = "__delphi_left_dock_rail__";
  const BODY_ID = "__delphi_left_dock_body__";
  const HEADER_ID = "__delphi_left_dock_header__";
  const CONTENT_ID = "__delphi_left_dock_content__";
  const LIST_ID = "__delphi_left_dock_chat_list__";
  const LIST_CONTENT_ID = "__delphi_left_dock_chat_list_content__";
  const STYLE_ID = "__delphi_left_dock_style__";

  const OPEN_PANEL_ICON = "\uE1C0";
  const NEW_CHAT_ICON = "\uE929";
  const NEXT_PAGE_GLYPH = "\uE64E";
  const CLOSE_PANEL_ICON = "\uE8A0";
  const CHAT_ITEM_MENU_ICON = "\uE712";
  const CHAT_ITEM_RENAME_ICON = "\uE70F";
  const CHAT_ITEM_DELETE_ICON = "\uE74D";

  const CHAT_ITEM_CLICK_TO_HOST_DELAY_MS = 220;

  const CLOSED_WIDTH = 64;
  const RAIL_WIDTH = 64;
  const DOCK_BUTTON_SIZE = 48;
  const HEADER_HEIGHT = DOCK_BUTTON_SIZE * 2;
  const HEADER_MIN_HEIGHT = 64;

  const DEFAULT_DOCK_OPEN_WIDTH = 320;
  const DEFAULT_DOCK_VIEWPORT_MARGIN = 16;
  const DEFAULT_PAGE_HORIZONTAL_RESERVE = 80;
  const DEFAULT_MAIN_CONTENT_MIN_WIDTH = 760;
  const DEFAULT_RESPONSE_CONTENT_MAX_WIDTH = 980;

  const DEFAULT_PAGE = {
    Items: [],
    FirstId: "",
    LastId: "",
    HasMore: false
  };

  const DEFAULTS = {
    open: false,
    page: DEFAULT_PAGE
  };

  const state = {
    open: DEFAULTS.open,
    page: {
      Items: [],
      FirstId: "",
      LastId: "",
      HasMore: false
    },
    openItemMenu: null,
    renameSession: null,
    pendingChatSelectionTimer: null,
    focusedItemId: ""
  };

  let resizeHandlerAttached = false;
  let keydownHandlerAttached = false;
  let clickOutsideHandlerAttached = false;

  let lastCompactViewport = false;

    const FILES_DRAWER_I18N_EVENT =
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

  function setButtonTitleAndAria(button, text) {
    if (!button) return;

    button.title = text;
    button.setAttribute("aria-label", text);
  }

  function setMenuItemLabel(button, text) {
    if (!button) return;

    const labelNode = button.querySelector(".delphi-dock-list-menu-item-label");
    if (labelNode) {
      labelNode.textContent = text;
    }
  }

  function applyFilesDrawerDictionary() {
    const refs = ensureRoot();
    const root = refs.root;
    const body = refs.body;

    if (body) {
      body.setAttribute(
        "aria-label",
        t("filesDrawer.aria.leftPanel", "Left panel")
      );
    }

    if (!root) return;

    let nodes;
    let i;
    let labelNode;
    let text;

    nodes = root.querySelectorAll('[data-i18n-role="open-panel"]');
    text = t("filesDrawer.actions.openPanel", "open panel");
    for (i = 0; i < nodes.length; i += 1) {
      setButtonTitleAndAria(nodes[i], text);
    }

    nodes = root.querySelectorAll('[data-i18n-role="new-session"]');
    text = t("filesDrawer.actions.newSession", "New session");
    for (i = 0; i < nodes.length; i += 1) {
      setButtonTitleAndAria(nodes[i], text);
    }

    nodes = root.querySelectorAll('[data-i18n-role="close-panel"]');
    text = t("filesDrawer.actions.closePanel", "Close panel");
    for (i = 0; i < nodes.length; i += 1) {
      setButtonTitleAndAria(nodes[i], text);
    }

    nodes = root.querySelectorAll(".delphi-dock-next-page-btn");
    text = t("filesDrawer.actions.nextPage", "Next page");
    for (i = 0; i < nodes.length; i += 1) {
      setButtonTitleAndAria(nodes[i], text);

      labelNode = nodes[i].querySelector(".delphi-dock-next-page-btn-label");
      if (labelNode) {
        labelNode.textContent = text;
      }
    }

    nodes = root.querySelectorAll(".delphi-dock-list-action-btn");
    text = t("filesDrawer.actions.more", "More");
    for (i = 0; i < nodes.length; i += 1) {
      setButtonTitleAndAria(nodes[i], text);
    }

    nodes = root.querySelectorAll('[data-i18n-role="rename-item"]');
    text = t("filesDrawer.actions.rename", "Rename");
    for (i = 0; i < nodes.length; i += 1) {
      setMenuItemLabel(nodes[i], text);
    }

    nodes = root.querySelectorAll('[data-i18n-role="delete-item"]');
    text = t("filesDrawer.actions.delete", "Delete");
    for (i = 0; i < nodes.length; i += 1) {
      setMenuItemLabel(nodes[i], text);
    }
  }

  function getRootCssPx(variableName, fallbackValue) {
    const rawValue = getComputedStyle(document.documentElement)
      .getPropertyValue(variableName)
      .trim();

    const numericValue = parseFloat(rawValue);

    return Number.isFinite(numericValue)
      ? numericValue
      : fallbackValue;
  }

  function getLayoutPagePadding() {
    return getRootCssPx("--layout-page-padding", 40);
  }

  function getDockOpenWidthValue() {
    return getRootCssPx(
      "--layout-left-panel-open-width",
      DEFAULT_DOCK_OPEN_WIDTH
    );
  }

  function getDockViewportMargin() {
    return getRootCssPx(
      "--layout-left-panel-viewport-margin",
      DEFAULT_DOCK_VIEWPORT_MARGIN
    );
  }

  function getPageHorizontalReserve() {
    return getRootCssPx(
      "--layout-page-horizontal-reserve",
      DEFAULT_PAGE_HORIZONTAL_RESERVE
    );
  }

  function getMainContentMinWidth() {
    return getRootCssPx(
      "--layout-main-content-min-width",
      DEFAULT_MAIN_CONTENT_MIN_WIDTH
    );
  }

  function getResponseContentMaxWidth() {
    return getRootCssPx(
      "--layout-response-max-width",
      DEFAULT_RESPONSE_CONTENT_MAX_WIDTH
    );
  }

  function isCompactViewport() {
    const viewportWidth =
      window.innerWidth ||
      document.documentElement.clientWidth ||
      0;

    const pagePadding = getLayoutPagePadding();
    const openWidth = getOpenWidth();

    const responseWidthIfDockReserved =
      viewportWidth
      - openWidth
      - (pagePadding * 2);

    return responseWidthIfDockReserved < getResponseContentMaxWidth();
  }

  function getOpenWidth() {
    const viewportWidth =
      window.innerWidth ||
      document.documentElement.clientWidth ||
      0;

    const maxAllowedWidth = Math.max(
      0,
      viewportWidth - getDockViewportMargin()
    );

    return Math.min(getDockOpenWidthValue(), maxAllowedWidth);
  }

  function shouldOverlayDock(openWidth) {
    if (isCompactViewport()) {
      return true;
    }

    const viewportWidth =
      window.innerWidth ||
      document.documentElement.clientWidth ||
      0;

    const safeOpenWidth = Number.isFinite(openWidth)
      ? openWidth
      : getOpenWidth();

    const remainingMainWidth =
      viewportWidth
      - safeOpenWidth
      - getPageHorizontalReserve();

    return remainingMainWidth < getMainContentMinWidth();
  }

  function getHeaderHeight() {
    return HEADER_HEIGHT;
  }

  function ensureStyles() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      #${ROOT_ID} {
        --delphi-dock-header-height: ${HEADER_HEIGHT}px;
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        width: ${CLOSED_WIDTH}px;
        z-index: 1600;
        box-sizing: border-box;
        overflow: hidden;
        background: transparent;
        border: none;
        border-radius: 0;
        box-shadow: none;
        transition:
          width 180ms ease,
          background 180ms ease;
      }

      #${ROOT_ID}.is-open {
        background: #202020;
      }

      [data-theme="light"] #${ROOT_ID}.is-open {
        background: #eceef1;
      }

      #${RAIL_ID} {
        position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
        width: ${RAIL_WIDTH}px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 4px;
        padding-top: 14px;
        box-sizing: border-box;
        background: transparent;
        border: none;
        border-radius: 0;
        box-shadow: none;
      }

      #${RAIL_ID} > button:nth-child(1),
      #${RAIL_ID} > button:nth-child(2) {
        position: relative;
        top: -10px;
      }

      #${ROOT_ID}.is-open #${RAIL_ID} {
        display: none;
      }

      #${BODY_ID} {
        position: absolute;
        left: ${RAIL_WIDTH}px;
        top: 0;
        right: 0;
        bottom: 0;
        display: none;
        flex-direction: column;
        min-height: 0;
        background: transparent;
        border: none;
        border-radius: 0;
        box-shadow: none;
        overflow: hidden;
      }

      #${ROOT_ID}.is-open #${BODY_ID} {
        left: 0;
        display: flex;
      }

      #${HEADER_ID} {
        flex: 0 0 var(--delphi-dock-header-height);
        min-height: var(--delphi-dock-header-height);
        padding: 4px 14px 0 8px;
        box-sizing: border-box;
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        gap: 10px;
        background: transparent;
        border: none;
      }

      #${CONTENT_ID} {
        flex: 1 1 auto;
        min-height: 0;
        overflow: hidden;
        background: transparent;
        border: none;
        box-sizing: border-box;
      }

      #${LIST_ID} {
        width: 100%;
        height: 100%;
        min-height: 0;
        overflow-y: auto;
        overflow-x: hidden;
        scrollbar-gutter: stable;
        box-sizing: border-box;
        padding: 0;
        display: block;
      }

      #${LIST_CONTENT_ID} {
        width: 100%;
        box-sizing: border-box;
        padding: 0 0 14px 0;
        display: flex;
        flex-direction: column;
        gap: 0;
      }

      #${LIST_ID}::-webkit-scrollbar {
        width: 12px;
      }

      #${LIST_ID}::-webkit-scrollbar-thumb {
        background: var(--scrollbar-thumb);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      #${LIST_ID}::-webkit-scrollbar-thumb:hover {
        background: var(--scrollbar-thumb-hover);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      .delphi-dock-list-row {
        position: relative;
        display: block;
        margin: 0 10px 2px 2px;
        /*min-height: 50px;*/
        min-height: 25px;
      }

      .delphi-dock-list-btn {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        /*padding: 12px 52px 12px 16px;*/
        /*padding: 8px 52px 8px 16px;*/
        padding: 7px 32px 7px 16px;
        margin: 0;
        border: none;
        border-radius: 10px;
        background: transparent;
        color: var(--text-main);
        cursor: pointer;
        box-sizing: border-box;
        text-align: left;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        font-family: "Segoe UI Variable Text", "Segoe UI", system-ui, sans-serif;
        font-size: 14px;
        font-weight: 600;
        line-height: 1.35;
        transition:
          background 140ms ease,
          color 140ms ease,
          transform 120ms ease,
          opacity 120ms ease;
      }

      .delphi-dock-list-row:hover .delphi-dock-list-btn,
      .delphi-dock-list-btn:focus-visible,
      .delphi-dock-list-row.is-menu-open .delphi-dock-list-btn,
      .delphi-dock-list-row.is-focused .delphi-dock-list-btn {
        background: var(--input-menu-item-hover-bg);
        color: var(--text-main);
        outline: none;
      }

      .delphi-dock-list-btn:active {
        transform: scale(0.995);
      }

      .delphi-dock-list-btn.is-hidden-for-rename {
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
      }

      .delphi-dock-next-page-btn {
        display: flex;
        align-items: center;
        justify-content: flex-start;
        gap: 8px;
      }

      .delphi-dock-next-page-btn-glyph {
        flex: 0 0 auto;
        font-family: "Segoe Fluent Icons","Segoe UI Symbol","Segoe UI",sans-serif;
        font-size: 14px;
        font-weight: 400;
        line-height: 1;
      }

      .delphi-dock-next-page-btn-label {
        min-width: 0;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .delphi-dock-list-action-btn {
        appearance: none;
        -webkit-appearance: none;
        position: absolute;
        top: 50%;
        right: 8px;
        width: 28px;
        height: 28px;
        margin: 0;
        padding: 0;
        border: none;
        border-radius: 10px;
        background: transparent;
        color: var(--text-main);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-sizing: border-box;
        cursor: pointer;
        opacity: 0;
        visibility: hidden;
        transform: translateY(-50%);
        transition:
          opacity 120ms ease,
          visibility 0s linear 120ms,
          background 120ms ease,
          color 120ms ease,
          transform 120ms ease;
        font-family: "Segoe Fluent Icons","Segoe Fluent Icons","Segoe UI Symbol","Segoe UI",sans-serif;
        font-size: 16px;
        line-height: 1;
        z-index: 3;
      }

      .delphi-dock-list-row:hover .delphi-dock-list-action-btn {
        opacity: 1;
        visibility: visible;
        transition:
          opacity 120ms ease,
          visibility 0s linear 0s,
          background 120ms ease,
          color 120ms ease,
          transform 120ms ease;
      }

      .delphi-dock-list-row.is-renaming .delphi-dock-list-action-btn {
        opacity: 0;
        visibility: hidden;
        pointer-events: none;
      }

      .delphi-dock-list-action-btn:hover,
      .delphi-dock-list-action-btn:focus-visible {
        background: var(--input-button-bg);
        color: var(--input-button-text);
        outline: none;
      }

      .delphi-dock-list-action-btn:active {
        transform: translateY(-50%) scale(0.94);
      }

      .delphi-dock-list-menu {
        position: fixed;
        top: 0;
        left: 0;
        min-width: 170px;
        padding: 6px;
        border-radius: 14px;
        border: 1px solid var(--input-menu-border);
        background: var(--input-menu-bg);
        box-shadow: var(--input-shell-shadow);
        display: none;
        flex-direction: column;
        gap: 2px;
        z-index: 4000;
      }

      .delphi-dock-list-row.is-menu-open .delphi-dock-list-menu {
        display: flex;
      }

      .delphi-dock-list-menu-item {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        padding: 10px 12px;
        margin: 0;
        border: none;
        border-radius: 10px;
        background: transparent;
        color: var(--input-menu-text);
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 10px;
        text-align: left;
        font-family: "Segoe UI Variable Text", "Segoe UI", system-ui, sans-serif;
        font-size: 14px;
        line-height: 1.3;
      }

      .delphi-dock-list-menu-item:hover,
      .delphi-dock-list-menu-item:focus-visible {
        background: var(--input-menu-item-hover-bg);
        color: var(--input-menu-item-hover-text);
        outline: none;
      }

      .delphi-dock-list-menu-item-icon {
        width: 16px;
        min-width: 16px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-family: "Segoe Fluent Icons","Segoe Fluent Icons","Segoe UI Symbol","Segoe UI",sans-serif;
        font-size: 16px;
        line-height: 1;
      }

      .delphi-dock-list-rename-input {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        width: auto;
        height: 100%;
        margin: 0;
        padding: 12px 52px 12px 16px;
        border: 1px solid var(--input-menu-border);
        border-radius: 18px;
        box-sizing: border-box;
        background: var(--input-shell-bg);
        color: var(--input-text);
        font-family: "Segoe UI Variable Text", "Segoe UI", system-ui, sans-serif;
        font-size: 14px;
        font-weight: 600;
        line-height: 1.35;
        outline: none;
        z-index: 2;
      }

      .delphi-dock-list-rename-input:focus {
        border-color: var(--input-button-bg);
      }
    `;

    document.head.appendChild(style);
  }

  function createDockButton(title, glyph, i18nRole) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.title = title;
    btn.setAttribute("aria-label", title);
    btn.textContent = glyph;

    if (i18nRole) {
      btn.setAttribute("data-i18n-role", i18nRole);
    }

    Object.assign(btn.style, {
      appearance: "none",
      width: "48px",
      height: "48px",
      minWidth: "48px",
      minHeight: "48px",
      padding: "0",
      margin: "0",
      border: "none",
      borderRadius: "12px",
      background: "transparent",
      color: "var(--text-main)",
      cursor: "pointer",
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      boxSizing: "border-box",
      lineHeight: "1",
      fontFamily: '"Segoe Fluent Icons","Segoe Fluent Icons","Segoe UI Symbol","Segoe UI",sans-serif',
      fontSize: "22px",
      fontWeight: "400",
      transition: "background 140ms ease, color 140ms ease, transform 120ms ease"
    });

    btn.addEventListener("mouseenter", function () {
      btn.style.background = "var(--input-menu-item-hover-bg)";
    });

    btn.addEventListener("mouseleave", function () {
      btn.style.background = "transparent";
      btn.style.transform = "none";
    });

    btn.addEventListener("mousedown", function () {
      btn.style.transform = "scale(0.96)";
    });

    btn.addEventListener("mouseup", function () {
      btn.style.transform = "none";
    });

    return btn;
  }

  function postToHost(payload) {
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
      window.dispatchEvent(new CustomEvent(payload.event || "dock-event", { detail: payload }));
    } catch {}

    return false;
  }

  function resetDisplayTemplateAnchorHistory() {
    try {
      if (
        window.DisplayTemplate &&
        typeof window.DisplayTemplate.resetAnchorHistory === "function"
      ) {
        window.DisplayTemplate.resetAnchorHistory();
        return true;
      }
    } catch {}

    return false;
  }

  function notifyNewChat() {
    resetDisplayTemplateAnchorHistory();

    return postToHost({
      event: "new-chat"
    });
  }

  function parseJsonIfNeeded(value) {
    if (typeof value !== "string") {
      return value;
    }

    const text = value.trim();

    if (!text) {
      return value;
    }

    const firstChar = text.charAt(0);

    if (firstChar !== "{" && firstChar !== "[") {
      return value;
    }

    try {
      return JSON.parse(text);
    } catch (_) {
      return value;
    }
  }

  function normalizeIncomingPayload(payload) {
    const normalized = parseJsonIfNeeded(payload);

    if (!normalized || typeof normalized !== "object") {
      return null;
    }

    const result = Object.assign({}, normalized);

    if (Object.prototype.hasOwnProperty.call(result, "page")) {
      result.page = parseJsonIfNeeded(result.page);
    }

    return result;
  }

  function normalizePage(page) {
    const normalizedPage = parseJsonIfNeeded(page);
    const rawItems =
      normalizedPage && Object.prototype.hasOwnProperty.call(normalizedPage, "Items")
        ? parseJsonIfNeeded(normalizedPage.Items)
        : [];

    const items = Array.isArray(rawItems) ? rawItems : [];

    return {
      Items: items.map(function (item, visibleIndex) {
        return {
          Id: item && item.Id != null ? String(item.Id) : "",
          Title: item && item.Title != null ? String(item.Title) : "",
          Index: item && item.Index != null ? String(item.Index) : String(visibleIndex)
        };
      }),
      FirstId: normalizedPage && normalizedPage.FirstId != null ? String(normalizedPage.FirstId) : "",
      LastId: normalizedPage && normalizedPage.LastId != null ? String(normalizedPage.LastId) : "",
      HasMore: !!(normalizedPage && normalizedPage.HasMore)
    };
  }

  function normalizeItemId(itemId) {
    return itemId == null ? "" : String(itemId);
  }

  function setFocusedItemId(itemId) {
    state.focusedItemId = normalizeItemId(itemId);
  }

  function isFocusedItem(item) {
    const itemId = item && item.Id != null ? String(item.Id) : "";
    return !!itemId && itemId === state.focusedItemId;
  }

  function syncFocusedRowState() {
    const { listContent } = ensureRoot();
    const rows = listContent.querySelectorAll(".delphi-dock-list-row[data-chat-item-id]");

    for (let i = 0; i < rows.length; i += 1) {
      const row = rows[i];
      const rowItemId = row.getAttribute("data-chat-item-id") || "";

      row.classList.toggle(
        "is-focused",
        !!state.focusedItemId && rowItemId === state.focusedItemId
      );
    }
  }

  function unselectFocusedItem() {
    setFocusedItemId("");
    closeChatItemMenu();
    syncFocusedRowState();
  }

  function notifyChatSelection(item, visibleIndex) {
    resetDisplayTemplateAnchorHistory();

    return postToHost({
      event: "chat-selection",
      id: item && item.Id ? String(item.Id) : "",
      index: item && item.Index != null ? String(item.Index) : String(visibleIndex)
    });
  }

  function cancelPendingChatSelection() {
    if (!state.pendingChatSelectionTimer) {
      return;
    }

    clearTimeout(state.pendingChatSelectionTimer);
    state.pendingChatSelectionTimer = null;
  }

  function queueChatSelection(item, visibleIndex) {
    cancelPendingChatSelection();

    state.pendingChatSelectionTimer = window.setTimeout(function () {
      state.pendingChatSelectionTimer = null;
      notifyChatSelection(item, visibleIndex);
    }, CHAT_ITEM_CLICK_TO_HOST_DELAY_MS);
  }

  function notifyNextPage(lastId) {
    if (!lastId) {
      return false;
    }

    return postToHost({
      event: "chat-next-page",
      lastId: String(lastId)
    });
  }

  function notifyChatRename(item, value) {
    const nextValue = String(value == null ? "" : value).trim();

    if (!nextValue) {
      return false;
    }

    return postToHost({
      event: "chat-item-rename",
      id: item && item.Id != null ? String(item.Id) : "",
      value: nextValue
    });
  }

  function notifyChatDelete(item) {
    return postToHost({
      event: "chat-item-delete",
      id: item && item.Id ? String(item.Id) : ""
    });
  }

  function closeChatItemMenu() {
    if (!state.openItemMenu) {
      return;
    }

    if (state.openItemMenu.row && state.openItemMenu.row.classList) {
      state.openItemMenu.row.classList.remove("is-menu-open");
    }

    state.openItemMenu = null;
  }

  function cancelChatItemRename() {
    const session = state.renameSession;

    if (!session) {
      return;
    }

    if (session.input && session.input.parentNode) {
      session.input.parentNode.removeChild(session.input);
    }

    if (session.button) {
      session.button.classList.remove("is-hidden-for-rename");
      session.button.textContent = session.oldTitle;
    }

    if (session.actionButton) {
      session.actionButton.disabled = false;
    }

    if (session.row && session.row.classList) {
      session.row.classList.remove("is-renaming");
    }

    state.renameSession = null;
  }

  function updateLocalChatItemTitle(targetItem, nextTitle) {
    const items =
      state.page && Array.isArray(state.page.Items)
        ? state.page.Items
        : [];

    for (let i = 0; i < items.length; i += 1) {
      const item = items[i];

      const sameByReference = item === targetItem;
      const sameById =
        targetItem &&
        item &&
        item.Id != null &&
        targetItem.Id != null &&
        String(item.Id) === String(targetItem.Id);

      const sameByIndex =
        targetItem &&
        item &&
        item.Index != null &&
        targetItem.Index != null &&
        String(item.Index) === String(targetItem.Index);

      if (sameByReference || sameById || sameByIndex) {
        item.Title = nextTitle;
        return item;
      }
    }

    if (targetItem) {
      targetItem.Title = nextTitle;
      return targetItem;
    }

    return null;
  }

  function renameChatItemById(itemId, nextTitle) {
    const normalizedId = String(itemId == null ? "" : itemId);
    const normalizedTitle = String(nextTitle == null ? "" : nextTitle).trim();

    if (!normalizedId || !normalizedTitle) {
      return false;
    }

    const { list } = ensureRoot();
    const previousScrollTop = list ? list.scrollTop : 0;

    cancelChatItemRename();
    closeChatItemMenu();

    const updatedItem = updateLocalChatItemTitle(
      { Id: normalizedId },
      normalizedTitle
    );

    if (!updatedItem) {
      return false;
    }

    requestAnimationFrame(function () {
      renderChatList();

      if (list) {
        list.scrollTop = previousScrollTop;
      }
    });

    return true;
  }

  function moveChatItemToTopById(itemId) {
    const normalizedId = String(itemId == null ? "" : itemId);

    if (!normalizedId) {
      return false;
    }

    const currentPage = state.page || DEFAULT_PAGE;
    const currentItems = Array.isArray(currentPage.Items) ? currentPage.Items : [];

    if (!currentItems.length) {
      return false;
    }

    const { list } = ensureRoot();

    cancelChatItemRename();
    closeChatItemMenu();

    let targetIndex = -1;

    for (let i = 0; i < currentItems.length; i += 1) {
      const item = currentItems[i];

      if (item && item.Id != null && String(item.Id) === normalizedId) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex < 0) {
      return false;
    }

    const nextItems = currentItems.slice();
    const targetItem = nextItems.splice(targetIndex, 1)[0];

    nextItems.unshift(targetItem);

    for (let i = 0; i < nextItems.length; i += 1) {
      nextItems[i].Index = String(i);
    }

    state.page = {
      Items: nextItems,
      FirstId: nextItems.length > 0 && nextItems[0].Id != null
        ? String(nextItems[0].Id)
        : "",
      LastId: nextItems.length > 0 && nextItems[nextItems.length - 1].Id != null
        ? String(nextItems[nextItems.length - 1].Id)
        : "",
      HasMore: !!currentPage.HasMore
    };

    requestAnimationFrame(function () {
      renderChatList();

      if (list) {
        list.scrollTop = 0;
      }
    });

    return true;
  }

    function focusChatItemButtonById(itemId) {
    const normalizedId = normalizeItemId(itemId);

    if (!normalizedId) {
      return false;
    }

    const { listContent } = ensureRoot();
    const rows = listContent.querySelectorAll(".delphi-dock-list-row[data-chat-item-id]");

    for (let i = 0; i < rows.length; i += 1) {
      const row = rows[i];
      const rowItemId = row.getAttribute("data-chat-item-id") || "";

      if (rowItemId !== normalizedId) {
        continue;
      }

      const button = row.querySelector(".delphi-dock-list-btn");

      if (!button) {
        return false;
      }

      try {
        button.focus({ preventScroll: true });
      } catch (_) {
        button.focus();
      }

      return true;
    }

    return false;
  }

  function scrollChatListToTopIfNeeded() {
    const { list } = ensureRoot();

    if (!list) {
      return false;
    }

    const hasVisibleScroll = list.scrollHeight > list.clientHeight + 1;
    const topIsVisible = list.scrollTop <= 0;

    if (!hasVisibleScroll || topIsVisible) {
      return false;
    }

    list.scrollTo({
      top: 0,
      behavior: "smooth"
    });

    return true;
  }

  function addChatItemToTop(itemId, text) {
    const normalizedId = normalizeItemId(itemId);
    const normalizedTitle = String(text == null ? "" : text);

    if (!normalizedId) {
      return false;
    }

    const currentPage = state.page || DEFAULT_PAGE;
    const currentItems = Array.isArray(currentPage.Items) ? currentPage.Items : [];

    cancelChatItemRename();
    closeChatItemMenu();
    setFocusedItemId(normalizedId);

    const nextItems = [{
      Id: normalizedId,
      Title: normalizedTitle,
      Index: "0"
    }];

    for (let i = 0; i < currentItems.length; i += 1) {
      const currentItem = currentItems[i];

      if (
        currentItem &&
        currentItem.Id != null &&
        String(currentItem.Id) === normalizedId
      ) {
        continue;
      }

      nextItems.push({
        Id: currentItem && currentItem.Id != null ? String(currentItem.Id) : "",
        Title: currentItem && currentItem.Title != null ? String(currentItem.Title) : "",
        Index: String(nextItems.length)
      });
    }

    state.page = {
      Items: nextItems,
      FirstId: normalizedId,
      LastId: nextItems.length > 0 && nextItems[nextItems.length - 1].Id != null
        ? String(nextItems[nextItems.length - 1].Id)
        : "",
      HasMore: !!currentPage.HasMore
    };

    requestAnimationFrame(function () {
      renderChatList();
      focusChatItemButtonById(normalizedId);
      scrollChatListToTopIfNeeded();
    });

    return true;
  }

  function removeChatItemById(itemId) {
    const normalizedId = String(itemId == null ? "" : itemId);

    if (!normalizedId) {
      return false;
    }

    const currentPage = state.page || DEFAULT_PAGE;
    const currentItems = Array.isArray(currentPage.Items) ? currentPage.Items : [];

    if (!currentItems.length) {
      return false;
    }

    const { list } = ensureRoot();
    const previousScrollTop = list ? list.scrollTop : 0;

    cancelChatItemRename();
    closeChatItemMenu();

    let targetIndex = -1;

    for (let i = 0; i < currentItems.length; i += 1) {
      const item = currentItems[i];

      if (item && item.Id != null && String(item.Id) === normalizedId) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex < 0) {
      return false;
    }

    if (state.focusedItemId === normalizedId) {
      setFocusedItemId("");
    }

    const nextItems = currentItems.slice();
    nextItems.splice(targetIndex, 1);

    for (let i = 0; i < nextItems.length; i += 1) {
      nextItems[i].Index = String(i);
    }

    state.page = {
      Items: nextItems,
      FirstId: nextItems.length > 0 && nextItems[0].Id != null
        ? String(nextItems[0].Id)
        : "",
      LastId: nextItems.length > 0 && nextItems[nextItems.length - 1].Id != null
        ? String(nextItems[nextItems.length - 1].Id)
        : "",
      HasMore: !!currentPage.HasMore
    };

    requestAnimationFrame(function () {
      renderChatList();

      if (list) {
        list.scrollTop = previousScrollTop;
      }
    });

    return true;
  }


  function commitChatItemRename() {
    const session = state.renameSession;

    if (!session || !session.input) {
      return false;
    }

    const nextTitle = String(session.input.value == null ? "" : session.input.value).trim();

    if (!nextTitle) {
      cancelChatItemRename();
      return false;
    }

    session.isCommitting = true;

    const { list } = ensureRoot();
    const previousScrollTop = list ? list.scrollTop : 0;

    updateLocalChatItemTitle(session.item, nextTitle);

    if (session.button) {
      session.button.textContent = nextTitle;
      session.button.classList.remove("is-hidden-for-rename");
    }

    if (session.actionButton) {
      session.actionButton.disabled = false;
    }

    if (session.row && session.row.classList) {
      session.row.classList.remove("is-renaming");
    }

    if (session.input && session.input.parentNode) {
      session.input.parentNode.removeChild(session.input);
    }

    state.renameSession = null;

    notifyChatRename(session.item, nextTitle);

    requestAnimationFrame(function () {
      renderChatList();

      if (list) {
        list.scrollTop = previousScrollTop;
      }
    });

    return true;
  }

  function createChatListButton(label) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "delphi-dock-list-btn";
    btn.textContent = label || "";
    return btn;
  }

  function createNextPageButton() {
    const nextPageText = t("filesDrawer.actions.nextPage", "Next page");

    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "delphi-dock-list-btn delphi-dock-next-page-btn";
    btn.setAttribute("data-i18n-role", "next-page");
    btn.title = nextPageText;
    btn.setAttribute("aria-label", nextPageText);

    const glyph = document.createElement("span");
    glyph.className = "delphi-dock-next-page-btn-glyph";
    glyph.setAttribute("aria-hidden", "true");
    glyph.textContent = NEXT_PAGE_GLYPH;

    const label = document.createElement("span");
    label.className = "delphi-dock-next-page-btn-label";
    label.textContent = nextPageText;

    btn.appendChild(glyph);
    btn.appendChild(label);

    return btn;
  }

  function createChatItemActionButton() {
    const moreText = t("filesDrawer.actions.more", "More");

    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "delphi-dock-list-action-btn";
    btn.setAttribute("data-i18n-role", "more-actions");
    btn.title = moreText;
    btn.setAttribute("aria-label", moreText);
    btn.textContent = CHAT_ITEM_MENU_ICON;
    return btn;
  }

  function createChatItemMenuItem(icon, label, i18nRole) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "delphi-dock-list-menu-item";

    if (i18nRole) {
      btn.setAttribute("data-i18n-role", i18nRole);
    }

    const iconNode = document.createElement("span");
    iconNode.className = "delphi-dock-list-menu-item-icon";
    iconNode.textContent = icon;

    const labelNode = document.createElement("span");
    labelNode.className = "delphi-dock-list-menu-item-label";
    labelNode.textContent = label;

    btn.appendChild(iconNode);
    btn.appendChild(labelNode);

    return btn;
  }

function positionChatItemMenu(row, actionButton, menu) {
  if (!row || !actionButton || !menu) {
    return;
  }

  const rowRect = row.getBoundingClientRect();
  const anchorRect = actionButton.getBoundingClientRect();
  const viewportWidth = window.innerWidth || document.documentElement.clientWidth;
  const viewportHeight = window.innerHeight || document.documentElement.clientHeight;

  const menuWidth = Math.ceil(menu.offsetWidth || 170);
  const menuHeight = Math.ceil(menu.offsetHeight || 96);

  let left = Math.round(anchorRect.right + 8);
  let top = Math.round(rowRect.top);

  if (left + menuWidth + 12 > viewportWidth) {
    left = Math.round(anchorRect.left - menuWidth - 8);
  }

  if (left < 8) {
    left = 8;
  }

  if (top < 8) {
    top = 8;
  }

  if (top + menuHeight + 8 > viewportHeight) {
    top = Math.max(8, viewportHeight - menuHeight - 8);
  }

  menu.style.left = left + "px";
  menu.style.top = top + "px";
}

function repositionOpenChatItemMenu() {
  if (!state.openItemMenu) {
    return;
  }

  positionChatItemMenu(
    state.openItemMenu.row,
    state.openItemMenu.button,
    state.openItemMenu.menu
  );
}

  function beginChatItemRename(row, button, actionButton, item) {
    cancelChatItemRename();
    closeChatItemMenu();

    const input = document.createElement("input");
    input.type = "text";
    input.className = "delphi-dock-list-rename-input";
    input.value = item && item.Title ? String(item.Title) : "";

    row.appendChild(input);
    row.classList.add("is-renaming");
    button.classList.add("is-hidden-for-rename");
    actionButton.disabled = true;

    state.renameSession = {
      row: row,
      button: button,
      actionButton: actionButton,
      input: input,
      item: item,
      oldTitle: item && item.Title ? String(item.Title) : "",
      isCommitting: false
    };

    input.addEventListener("click", function (e) {
      e.stopPropagation();
    });

    input.addEventListener("keydown", function (e) {
      if (e.key === "Enter") {
        e.preventDefault();
        e.stopPropagation();
        commitChatItemRename();
        return;
      }

      if (e.key === "Escape") {
        e.preventDefault();
        e.stopPropagation();
        cancelChatItemRename();
      }
    });

    input.addEventListener("blur", function () {
      if (
        state.renameSession &&
        state.renameSession.input === input &&
        !state.renameSession.isCommitting
      ) {
        cancelChatItemRename();
      }
    });

    requestAnimationFrame(function () {
      input.focus();
      input.select();
    });
  }

  function createChatListRow(item, visibleIndex) {
    const row = document.createElement("div");
    row.className = "delphi-dock-list-row";
    row.setAttribute(
      "data-chat-item-id",
      item && item.Id != null ? String(item.Id) : ""
    );

    if (isFocusedItem(item)) {
      row.classList.add("is-focused");
    }

    const btn = createChatListButton(item && item.Title ? item.Title : "");
    const actionBtn = createChatItemActionButton();
    const menu = document.createElement("div");
    menu.className = "delphi-dock-list-menu";

    const renameBtn = createChatItemMenuItem(
      CHAT_ITEM_RENAME_ICON,
      t("filesDrawer.actions.rename", "Rename"),
      "rename-item"
    );

    const deleteBtn = createChatItemMenuItem(
      CHAT_ITEM_DELETE_ICON,
      t("filesDrawer.actions.delete", "Delete"),
      "delete-item"
    );

    menu.appendChild(renameBtn);
    menu.appendChild(deleteBtn);

    let clickTimer = null;

    btn.addEventListener("click", function (e) {
      if (e.detail > 1) {
        return;
      }

      cancelChatItemRename();
      closeChatItemMenu();
      setFocusedItemId(item && item.Id != null ? item.Id : "");
      syncFocusedRowState();

      queueChatSelection(item, visibleIndex);
    });

    btn.addEventListener("dblclick", function (e) {
      e.preventDefault();
      e.stopPropagation();

      cancelPendingChatSelection();
      beginChatItemRename(row, btn, actionBtn, item);
    });

    btn.addEventListener("dblclick", function (e) {
      e.preventDefault();
      e.stopPropagation();

      if (clickTimer) {
        clearTimeout(clickTimer);
        clickTimer = null;
      }

      beginChatItemRename(row, btn, actionBtn, item);
    });

    actionBtn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();

      if (state.openItemMenu && state.openItemMenu.row === row) {
        closeChatItemMenu();
        return;
      }

      closeChatItemMenu();
      row.classList.add("is-menu-open");
      state.openItemMenu = {
        row: row,
        menu: menu,
        button: actionBtn
      };

      requestAnimationFrame(function () {
        repositionOpenChatItemMenu();
      });
    });

    renameBtn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();
      beginChatItemRename(row, btn, actionBtn, item);
    });

    deleteBtn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();
      closeChatItemMenu();
      notifyChatDelete(item);
    });

    menu.addEventListener("click", function (e) {
      e.stopPropagation();
    });

    row.appendChild(btn);
    row.appendChild(actionBtn);
    row.appendChild(menu);

    return row;
  }

  function createNextPageRow(onClick) {
    const row = document.createElement("div");
    row.className = "delphi-dock-list-row";

    const btn = createNextPageButton();

    btn.addEventListener("click", function () {
      onClick();
    });

    row.appendChild(btn);

    return row;
  }

  function renderChatList() {
    const { listContent } = ensureRoot();
    listContent.replaceChildren();

    closeChatItemMenu();
    cancelChatItemRename();

    const page = state.page || DEFAULT_PAGE;
    const items = Array.isArray(page.Items) ? page.Items : [];

    for (let i = 0; i < items.length; i += 1) {
      const item = items[i];
      const row = createChatListRow(item, i);
      listContent.appendChild(row);
    }

    if (page.HasMore) {
      const nextRow = createNextPageRow(function () {
        cancelChatItemRename();
        closeChatItemMenu();
        notifyNextPage(page.LastId);
      });

      listContent.appendChild(nextRow);
    }
  }

  function captureDockWheel(e) {
    if (!state.open) {
      return;
    }

    e.preventDefault();
  }

  function handleDockListWheel(e) {
    if (!state.open) {
      return;
    }

    const list = e.currentTarget;

    if (!list) {
      return;
    }

    e.preventDefault();
    e.stopPropagation();

    if (e.deltaY) {
      list.scrollTop += e.deltaY;
    }
  }

function ensureRoot() {
    let root = document.getElementById(ROOT_ID);
    if (root) {
      return {
        root,
        rail: document.getElementById(RAIL_ID),
        body: document.getElementById(BODY_ID),
        header: document.getElementById(HEADER_ID),
        content: document.getElementById(CONTENT_ID),
        list: document.getElementById(LIST_ID),
        listContent: document.getElementById(LIST_CONTENT_ID)
      };
    }

    ensureStyles();

    root = document.createElement("div");
    root.id = ROOT_ID;

    const rail = document.createElement("div");
    rail.id = RAIL_ID;

    const body = document.createElement("div");
    body.id = BODY_ID;
    body.setAttribute("role", "complementary");
    body.setAttribute(
      "aria-label",
      t("filesDrawer.aria.leftPanel", "Left panel")
    );

    const header = document.createElement("div");
    header.id = HEADER_ID;

    const content = document.createElement("div");
    content.id = CONTENT_ID;

    const list = document.createElement("div");
    list.id = LIST_ID;

    const listContent = document.createElement("div");
    listContent.id = LIST_CONTENT_ID;

    list.appendChild(listContent);

    root.addEventListener("wheel", captureDockWheel, {
      passive: false,
      capture: true
    });

    list.addEventListener("wheel", handleDockListWheel, {
      passive: false
    });

    list.addEventListener("scroll", function () {
      repositionOpenChatItemMenu();
    }, { passive: true });

    content.appendChild(list);
    body.appendChild(header);
    body.appendChild(content);

    root.appendChild(rail);
    root.appendChild(body);

    document.body.appendChild(root);

    return { root, rail, body, header, content, list, listContent };
  }

  function syncHeaderHeight() {
    const { root } = ensureRoot();

    root.style.setProperty(
      "--delphi-dock-header-height",
      getHeaderHeight() + "px"
    );
  }

  function syncPageLayoutWidth() {
    if (typeof window.setLeftPanelWidth !== "function") {
      return;
    }

    const { root } = ensureRoot();
    const rootWidth = root
      ? Math.round(root.getBoundingClientRect().width || 0)
      : 0;

    const reserveLayoutWidth =
      state.open && !shouldOverlayDock(rootWidth)
        ? rootWidth
        : 0;

    window.setLeftPanelWidth(reserveLayoutWidth);
  }

  function setOpenState(open) {
    const { root, body } = ensureRoot();

    state.open = !!open;

    if (!state.open) {
      closeChatItemMenu();
      cancelChatItemRename();
    }

    const targetWidth = state.open ? getOpenWidth() : CLOSED_WIDTH;

    syncHeaderHeight();

    root.classList.toggle("is-open", state.open);
    root.style.width = targetWidth + "px";
    body.setAttribute("aria-hidden", state.open ? "false" : "true");

    renderRail();
    renderBody();
    syncPageLayoutWidth();

    if (window.updateInputBubbleLayout) {
      window.updateInputBubbleLayout();
    }
  }

  function openDock() {
    setOpenState(true);
  }

  function closeDock() {
    setOpenState(false);
  }

  function toggleDock() {
    if (state.open) {
      closeDock();
    } else {
      openDock();
    }
  }

  function renderRail() {
    const { rail } = ensureRoot();
    rail.replaceChildren();

    if (state.open) {
      return;
    }

    const openBtn = createDockButton(
      t("filesDrawer.actions.openPanel", "open panel"),
      OPEN_PANEL_ICON,
      "open-panel"
    );
    openBtn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();
      openDock();
    });
    rail.appendChild(openBtn);

    const newChatBtn = createDockButton(
      t("filesDrawer.actions.newSession", "New session"),
      NEW_CHAT_ICON,
      "new-session"
    );
    newChatBtn.addEventListener("click", function () {
      notifyNewChat();
    });
    rail.appendChild(newChatBtn);
  }

  function renderBody() {
    const { header } = ensureRoot();
    header.replaceChildren();

    if (!state.open) {
      return;
    }

    const newChatBtn = createDockButton(
      t("filesDrawer.actions.newSession", "New session"),
      NEW_CHAT_ICON,
      "new-session"
    );
    newChatBtn.addEventListener("click", function () {
      notifyNewChat();
    });

    const closeBtn = createDockButton(
      t("filesDrawer.actions.closePanel", "Close panel"),
      CLOSE_PANEL_ICON,
      "close-panel"
    );
    closeBtn.addEventListener("click", function () {
      closeDock();
    });

    header.appendChild(newChatBtn);
    header.appendChild(closeBtn);

    renderChatList();
  }

  function syncLayout() {
    const { root } = ensureRoot();
    const targetWidth = state.open ? getOpenWidth() : CLOSED_WIDTH;

    syncHeaderHeight();

    root.style.width = targetWidth + "px";
    syncPageLayoutWidth();
  }

  function refreshDockView() {
    renderRail();
    renderBody();
    syncLayout();
  }

  function clearDock() {
    state.page = normalizePage(DEFAULT_PAGE);
    setFocusedItemId("");
    setOpenState(false);
  }

  function applyPayload(payload) {
    payload = normalizeIncomingPayload(payload);

    if (!payload) {
      return;
    }

    if (Object.prototype.hasOwnProperty.call(payload, "page")) {
      state.page = normalizePage(payload.page);
    }

    if (Object.prototype.hasOwnProperty.call(payload, "focusedItemId")) {
      setFocusedItemId(payload.focusedItemId);
    }

    if (Object.prototype.hasOwnProperty.call(payload, "open")) {
      setOpenState(!!payload.open);
      return;
    }

    refreshDockView();
  }

  function completePage(page) {
    page = parseJsonIfNeeded(page);

    if (!page || typeof page !== "object") {
      return;
    }

    const nextPage = normalizePage(page);
    const currentPage = state.page || DEFAULT_PAGE;
    const currentItems = Array.isArray(currentPage.Items) ? currentPage.Items : [];
    const nextItems = Array.isArray(nextPage.Items) ? nextPage.Items : [];

    state.page = {
      Items: currentItems.concat(nextItems),
      FirstId: currentItems.length > 0
        ? (currentPage.FirstId || nextPage.FirstId)
        : nextPage.FirstId,
      LastId: nextPage.LastId || currentPage.LastId || "",
      HasMore: nextPage.HasMore
    };

    refreshDockView();
  }

  function attachGlobalHandlersOnce() {
    if (!resizeHandlerAttached) {
      resizeHandlerAttached = true;
      window.addEventListener("resize", function () {
        const compactViewport = isCompactViewport();
        const crossedToCompact = !lastCompactViewport && compactViewport;

        lastCompactViewport = compactViewport;

        if (crossedToCompact && state.open) {
          closeDock();
          return;
        }

        syncLayout();
        repositionOpenChatItemMenu();
      }, { passive: true });
    }

    if (!clickOutsideHandlerAttached) {
      clickOutsideHandlerAttached = true;

      document.addEventListener("click", function (e) {
        if (state.renameSession && state.renameSession.input) {
          const input = state.renameSession.input;
          if (input === e.target || input.contains(e.target)) {
            return;
          }
        }

        if (
          state.openItemMenu &&
          state.openItemMenu.row &&
          !state.openItemMenu.row.contains(e.target)
        ) {
          closeChatItemMenu();
        }

        if (!state.open || !isCompactViewport()) {
          return;
        }

        const target = e.target;

        if (
          target &&
          typeof target.closest === "function" &&
          target.closest("#" + ROOT_ID)
        ) {
          return;
        }

        closeDock();
      });
    }

    if (!keydownHandlerAttached) {
      keydownHandlerAttached = true;

      document.addEventListener("keydown", function (e) {
        const key = (e.key || "").toLowerCase();
        const code = e.code || "";

        if (key === "escape" || code === "Escape") {
          if (state.renameSession) {
            e.preventDefault();
            e.stopPropagation();
            cancelChatItemRename();
            return;
          }

          if (state.openItemMenu) {
            e.preventDefault();
            e.stopPropagation();
            closeChatItemMenu();
            return;
          }

          if (state.open) {
            e.preventDefault();
            e.stopPropagation();
            closeDock();
          }
        }
      });
    }
  }

  function handleHostMessage(data) {
    data = normalizeIncomingPayload(data);

    if (!data) return;

    if (data.type === "left-dock-set") {
      applyPayload(data);
      return;
    }

    if (data.type === "left-dock-open") {
      openDock();
      return;
    }

    if (data.type === "left-dock-close") {
      closeDock();
      return;
    }

    if (data.type === "left-dock-toggle") {
      toggleDock();
      return;
    }

    if (data.type === "left-dock-clear") {
      clearDock();
      return;
    }

    if (data.type === "files-drawer-set-items") {
      applyPayload({
        page: data.page,
        focusedItemId: data.focusedItemId
      });
      return;
    }

    if (data.type === "files-drawer-complete-items") {
      completePage(data.page);
      return;
    }

    if (data.type === "files-drawer-add-item") {
      addChatItemToTop(data.id, data.text);
      return;
    }

    if (data.type === "files-drawer-rename-item") {
      renameChatItemById(data.id, data.Title);
      return;
    }

    if (data.type === "files-drawer-set-topitem") {
      moveChatItemToTopById(data.id);
      return;
    }

    if (data.type === "files-drawer-remove-item") {
      removeChatItemById(data.id);
      return;
    }

    if (data.type === "files-drawer-open") {
      openDock();
      return;
    }

    if (data.type === "files-drawer-close") {
      closeDock();
      return;
    }

    if (data.type === "files-drawer-toggle") {
      toggleDock();
      return;
    }

    if (data.type === "files-drawer-clear") {
      clearDock();
      return;
    }

    if (data.type === "files-drawer-item-unselect") {
      unselectFocusedItem();
      return;
    }
  }

  if (window.chrome && window.chrome.webview) {
    window.chrome.webview.addEventListener("message", function (args) {
      handleHostMessage(args.data);
    });
  }

  window.FilesDrawer = {
    set: applyPayload,
    open: openDock,
    close: closeDock,
    toggle: toggleDock,
    clear: clearDock
  };

  window.showDelphiFilesDrawer = function (payload) {
    payload = normalizeIncomingPayload(payload) || {};

    payload = Object.assign({}, payload, { open: true });
    applyPayload(payload);
  };

  window.addEventListener(FILES_DRAWER_I18N_EVENT, function () {
    applyFilesDrawerDictionary();
  });

  ensureRoot();
  lastCompactViewport = isCompactViewport();
  attachGlobalHandlersOnce();
  renderRail();
  renderBody();
  setOpenState(false);
  applyFilesDrawerDictionary();
})();
