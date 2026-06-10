(function () {

  function onReady(fn) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", fn, { once: true });
    } else {
      fn();
    }
  }

  const PROMPT_SUMMARY_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  const SCROLL_BUTTONS_VISIBILITY_EVENT = "app:scroll-buttons-visibility-changed";
  const PROMPT_SUMMARY_ICON = "\uE81E";
  const PROMPT_SUMMARY_MAX_CHARS = 50;
  const PROMPT_SUMMARY_MAX_VISIBLE_ITEMS = 6;
  const PROMPT_SUMMARY_PANEL_BOTTOM_MARGIN = 16;
  const PROMPT_SUMMARY_VIEWPORT_SAFETY_PX = 2;

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

  onReady(function () {

    if (document.getElementById("promptSummaryBtn")) {
      return;
    }

    const btn = document.createElement("button");
    btn.id = "promptSummaryBtn";
    btn.className = "prompt-summary-btn";
    btn.type = "button";
    btn.textContent = PROMPT_SUMMARY_ICON;
    btn.setAttribute("aria-expanded", "false");

    const panel = document.createElement("div");
    panel.id = "promptSummaryPanel";
    panel.className = "prompt-summary-panel";
    panel.hidden = true;

    const viewport = document.createElement("div");
    viewport.className = "prompt-summary-viewport";

    const list = document.createElement("div");
    list.className = "prompt-summary-list";

    viewport.appendChild(list);
    panel.appendChild(viewport);

    document.body.appendChild(btn);
    document.body.appendChild(panel);

    const state = {
      hostVisible: !!(
        window.__scrollButtonsRuntime &&
        window.__scrollButtonsRuntime.enabled
      ),
      panelOpen: false,
      rootObserver: null,
      renderedItemsSignature: ""
    };

    function applyDictionary() {
      const label = state.panelOpen
        ? t("prompt.summary.close", "Close the prompt summary")
        : t("prompt.summary.open", "Open the prompt summary");

      btn.title = label;
      btn.setAttribute("aria-label", label);
    }

    function getResponseRoot() {
      return document.getElementById("ResponseContent");
    }

    function normalizeText(value) {
      return String(value == null ? "" : value)
        .replace(/\s+/g, " ")
        .trim();
    }

    function getPromptBlocks() {
      const root = getResponseRoot();
      if (!root) return [];

      return Array.from(root.children).filter(function (node) {
        return (
          node &&
          node.nodeType === 1 &&
          node.classList.contains("prompt-block") &&
          node.dataset &&
          node.dataset.kind === "prompt" &&
          String(node.dataset.pairId || "").trim() !== ""
        );
      });
    }

    function buildPromptSummaryLabel(fullText) {
      const source = normalizeText(fullText);
      const shortText = source.slice(0, PROMPT_SUMMARY_MAX_CHARS);
      return shortText + "...";
    }

    function getPromptItems() {
      return getPromptBlocks().map(function (block) {
        const pairId = String(block.dataset ? block.dataset.pairId || "" : "");
        const body = block.querySelector(".prompt-body");
        const fullText = normalizeText(body ? body.textContent : "");

        return {
          pairId: pairId,
          fullText: fullText,
          label: buildPromptSummaryLabel(fullText)
        };
      });
    }

    function buildPromptItemsSignature(items) {
      return items.map(function (item) {
        return [
          String(item.pairId || ""),
          String(item.label || ""),
          String(item.fullText || "")
        ].join("\u0001");
      }).join("\u0002");
    }

    function getPanelChromeHeight() {
      return Math.max(0, panel.offsetHeight - viewport.offsetHeight);
    }

    function getAvailableViewportHeight() {
      if (panel.hidden) {
        return 0;
      }

      const panelRect = panel.getBoundingClientRect();
      const availableHeight =
        window.innerHeight - panelRect.top - PROMPT_SUMMARY_PANEL_BOTTOM_MARGIN;

      return Math.max(0, availableHeight - getPanelChromeHeight());
    }

    function getNumericStylePixelValue(node, propertyName) {
      if (!node) {
        return 0;
      }

      const rawValue = window.getComputedStyle(node).getPropertyValue(propertyName);
      const parsedValue = parseFloat(rawValue);

      return Number.isFinite(parsedValue) ? parsedValue : 0;
    }

    function getViewportVerticalPadding() {
      return (
        getNumericStylePixelValue(viewport, "padding-top") +
        getNumericStylePixelValue(viewport, "padding-bottom")
      );
    }

    function getListVerticalGap() {
      const rowGap = getNumericStylePixelValue(list, "row-gap");
      if (rowGap > 0) {
        return rowGap;
      }

      return getNumericStylePixelValue(list, "gap");
    }

    function getItemsHeightForCount(count) {
      const itemNodes = Array.from(list.children);
      const safeCount = Math.min(itemNodes.length, Math.max(0, count));

      if (!safeCount) {
        return 0;
      }

      const verticalGap = getListVerticalGap();
      let usedHeight = 0;

      for (let i = 0; i < safeCount; i += 1) {
        const itemNode = itemNodes[i];

        usedHeight += itemNode.offsetHeight;
        usedHeight += getNumericStylePixelValue(itemNode, "margin-top");
        usedHeight += getNumericStylePixelValue(itemNode, "margin-bottom");

        if (i < safeCount - 1) {
          usedHeight += verticalGap;
        }
      }

      return Math.ceil(usedHeight);
    }

    function applyPanelViewportHeight() {
      if (panel.hidden) {
        return;
      }

      const itemCount = list.children.length;

      if (!itemCount) {
        viewport.style.maxHeight = "";
        viewport.style.overflowY = "";
        viewport.scrollTop = 0;
        return;
      }

      const previousScrollTop = viewport.scrollTop;
      const requestedVisibleCount = Math.min(
        PROMPT_SUMMARY_MAX_VISIBLE_ITEMS,
        itemCount
      );

      const availableViewportHeight = Math.max(
        0,
        Math.floor(getAvailableViewportHeight())
      );
      const viewportVerticalPadding = Math.ceil(getViewportVerticalPadding());
      const fitLimit = Math.max(
        0,
        availableViewportHeight - PROMPT_SUMMARY_VIEWPORT_SAFETY_PX
      );

      if (fitLimit <= 0) {
        viewport.style.maxHeight = "0px";
        viewport.style.overflowY = "auto";
        viewport.scrollTop = 0;
        return;
      }

      let appliedVisibleCount = 0;
      let appliedHeight = 0;

      for (let count = 1; count <= requestedVisibleCount; count += 1) {
        const candidateHeight =
          getItemsHeightForCount(count) + viewportVerticalPadding;

        if (candidateHeight <= fitLimit) {
          appliedVisibleCount = count;
          appliedHeight = candidateHeight;
        } else {
          break;
        }
      }

      if (appliedVisibleCount === 0) {
        appliedVisibleCount = 1;
        appliedHeight = Math.min(
          getItemsHeightForCount(1) + viewportVerticalPadding,
          fitLimit
        );
      }

      const hasOverflow = itemCount > appliedVisibleCount;
      const finalAppliedHeight = hasOverflow
        ? Math.max(0, appliedHeight - Math.ceil(getListVerticalGap()))
        : Math.max(0, appliedHeight);

      viewport.style.maxHeight = finalAppliedHeight + "px";
      viewport.style.overflowY = hasOverflow ? "auto" : "hidden";

      if (hasOverflow) {
        const maxScrollTop = Math.max(
          0,
          viewport.scrollHeight - viewport.clientHeight
        );

        viewport.scrollTop = Math.min(previousScrollTop, maxScrollTop);
      } else {
        viewport.scrollTop = 0;
      }
    }

    function findPromptBlockByPairId(pairId) {
      const blocks = getPromptBlocks();

      for (let i = 0; i < blocks.length; i += 1) {
        const block = blocks[i];
        const currentPairId = String(block.dataset ? block.dataset.pairId || "" : "");

        if (currentPairId === pairId) {
          return block;
        }
      }

      return null;
    }

    function getScrollTarget(root) {
      if (root) {
        const style = window.getComputedStyle(root);
        const rootScrollable =
          (style.overflowY === "auto" || style.overflowY === "scroll") &&
          root.scrollHeight > root.clientHeight + 4;

        if (rootScrollable) {
          return root;
        }
      }

      return document.scrollingElement || document.documentElement;
    }

    function getCurrentScrollTop(root) {
      const target = getScrollTarget(root);

      if (target === root) {
        return target.scrollTop || 0;
      }

      return Math.max(
        window.pageYOffset || 0,
        document.documentElement.scrollTop || 0,
        document.body.scrollTop || 0
      );
    }

    function setCurrentScrollTop(root, value, behavior) {
      const target = getScrollTarget(root);
      const safeValue = Math.max(0, Number.isFinite(value) ? value : 0);
      const scrollBehavior = behavior === "smooth" ? "smooth" : "auto";

      if (target === root) {
        if (typeof target.scrollTo === "function") {
          target.scrollTo({
            top: safeValue,
            behavior: scrollBehavior
          });
        } else {
          target.scrollTop = safeValue;
        }
        return;
      }

      window.scrollTo({
        top: safeValue,
        behavior: scrollBehavior
      });
    }

    function scrollNodeToTop(root, node, behavior) {
      if (!root || !node) return;

      const target = getScrollTarget(root);

      if (target === root) {
        const rootTop = root.getBoundingClientRect().top;
        const nodeTop = node.getBoundingClientRect().top;

        setCurrentScrollTop(
          root,
          getCurrentScrollTop(root) + (nodeTop - rootTop),
          behavior
        );

        return;
      }

      setCurrentScrollTop(
        root,
        getCurrentScrollTop(root) + node.getBoundingClientRect().top,
        behavior
      );
    }

    function scrollToPrompt(pairId) {
      if (window.scrollPromptToPairId) {
        window.scrollPromptToPairId(pairId, "smooth");
        return;
      }

      const root = getResponseRoot();
      if (!root) return;

      const block = findPromptBlockByPairId(pairId);
      if (!block) return;

      const anchor = document.getElementById("prompt-anchor-" + pairId);
      const bubble = block.querySelector(".prompt-bubble");
      const targetNode = anchor || bubble || block;

      if (!targetNode) return;

      scrollNodeToTop(root, targetNode, "smooth");
    }

    function closePanel() {
      state.panelOpen = false;
      panel.hidden = true;
      viewport.style.maxHeight = "";
      viewport.style.overflowY = "";
      viewport.scrollTop = 0;
      btn.setAttribute("aria-expanded", "false");
      applyDictionary();
    }

    function renderPanel(forceRender) {
      const items = getPromptItems();
      const nextSignature = buildPromptItemsSignature(items);

      if (!forceRender && nextSignature === state.renderedItemsSignature) {
        return false;
      }

      const previousScrollTop = viewport.scrollTop;

      list.replaceChildren();

      items.forEach(function (itemData) {
        const itemBtn = document.createElement("button");
        itemBtn.type = "button";
        itemBtn.className = "prompt-summary-item";
        itemBtn.textContent = itemData.label;
        itemBtn.title = itemData.fullText || itemData.label;
        itemBtn.setAttribute("data-pair-id", itemData.pairId);

        itemBtn.setAttribute(
          "aria-label",
          t("prompt.summary.goto", "Aller au prompt : {text}", {
            text: itemData.fullText || itemData.label
          })
        );

        list.appendChild(itemBtn);
      });

      state.renderedItemsSignature = nextSignature;
      viewport.scrollTop = Math.max(0, previousScrollTop);

      return true;
    }

    function openPanel() {
      renderPanel(true);
      state.panelOpen = true;
      panel.hidden = false;
      applyPanelViewportHeight();
      viewport.scrollTop = 0;
      btn.setAttribute("aria-expanded", "true");
      applyDictionary();
    }

    function updateVisibility() {
      const promptCount = getPromptItems().length;
      const mustShow = state.hostVisible && promptCount >= 2;

      btn.style.display = mustShow ? "flex" : "none";

      if (!mustShow) {
        closePanel();
        return;
      }

      if (state.panelOpen) {
        renderPanel(false);
        applyPanelViewportHeight();
      }
    }

    function bindRootObserver() {
      const root = getResponseRoot();

      if (!root || typeof MutationObserver !== "function") {
        return;
      }

      if (state.rootObserver) {
        state.rootObserver.disconnect();
        state.rootObserver = null;
      }

      state.rootObserver = new MutationObserver(function () {
        updateVisibility();
      });

      state.rootObserver.observe(root, {
        childList: true,
        subtree: true,
        characterData: true
      });
    }

    btn.addEventListener("click", function (event) {
      event.stopPropagation();

      if (state.panelOpen) {
        closePanel();
      } else {
        openPanel();
      }
    });

    list.addEventListener("pointerdown", function (event) {
      const itemBtn = event.target.closest(".prompt-summary-item");
      if (!itemBtn) return;

      event.preventDefault();
      event.stopPropagation();

      const pairId = String(itemBtn.getAttribute("data-pair-id") || "");
      if (!pairId) return;

      /*closePanel();*/

      window.setTimeout(function () {
        scrollToPrompt(pairId);
      }, 0);
    });

    document.addEventListener("click", function (event) {
      if (!state.panelOpen) return;

      if (btn.contains(event.target)) return;
      if (panel.contains(event.target)) return;

      closePanel();
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" && state.panelOpen) {
        closePanel();
      }
    });

    window.addEventListener(PROMPT_SUMMARY_I18N_EVENT, function () {
      applyDictionary();
      if (state.panelOpen) {
        renderPanel(true);
        applyPanelViewportHeight();
      }
    });

    window.addEventListener(SCROLL_BUTTONS_VISIBILITY_EVENT, function (event) {
      state.hostVisible = !!(event && event.detail && event.detail.visible);
      updateVisibility();
    });

    window.addEventListener("resize", function () {
      updateVisibility();
    }, { passive: true });

    applyDictionary();
    bindRootObserver();
    updateVisibility();
  });

})();
