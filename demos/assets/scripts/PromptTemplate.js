(() => {

  function translatePromptText(key, fallback, vars) {
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

  let text = %s;
  let pairId = %s;

  if (text == null || pairId == null) return;

  text = String(text).replace(/^[\s\uFEFF\u200B\u2060\u00A0]+|[\s\uFEFF\u200B\u2060\u00A0]+$/g, "");
  pairId = String(pairId).replace(/^[\s\uFEFF\u200B\u2060\u00A0]+|[\s\uFEFF\u200B\u2060\u00A0]+$/g, "");

  if (!pairId) return;

  const PROMPT_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  const t = translatePromptText;

  function getPromptToggleAriaLabel() {
    return t("prompt.toggleCollapse", "Plier ou déplier le prompt");
  }

  function applyPromptDictionary(scope) {
    const rootNode =
      scope && typeof scope.querySelectorAll === "function"
        ? scope
        : document;

    const toggles = rootNode.querySelectorAll(".prompt-simple-collapse-toggle");

    toggles.forEach(function (toggle) {
      toggle.setAttribute("aria-label", getPromptToggleAriaLabel());
    });
  }

  let root;

  if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.getMount === "function") {
    root = window.ResponseRenderBatch.getMount();
  } else {
    root = document.getElementById("ResponseContent");
    if (!root) {
      root = document.createElement("div");
      root.id = "ResponseContent";
      document.body.appendChild(root);
    }
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

  function hasVisibleVerticalScrollbar(root) {
    const target = getScrollTarget(root);
    return !!target && target.scrollHeight > target.clientHeight + 4;
  }

  function getViewportHeight(root) {
    const target = getScrollTarget(root);

    if (target === root) {
      return root.clientHeight || 0;
    }

    return window.innerHeight || document.documentElement.clientHeight || 0;
  }

  function getCurrentScrollTop(root) {
    const target = getScrollTarget(root);

    if (target === root) {
      return root.scrollTop || 0;
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

  function scrollToConversationBottom(root) {
    const target = getScrollTarget(root);

    if (target === root) {
      target.scrollTop = target.scrollHeight;
      return;
    }

    const bottom = Math.max(
      document.body.scrollHeight || 0,
      document.documentElement.scrollHeight || 0,
      root ? root.scrollHeight || 0 : 0
    );

    window.scrollTo(0, bottom);
  }

  function getPromptAnchorByPairId(pairId) {
    if (pairId == null) return null;

    return document.getElementById("prompt-anchor-" + pairId);
  }

  function scrollPromptAnchorToTop(root, anchor, behavior) {
    if (!anchor) return;

    const target = getScrollTarget(root);

    if (target === root) {
      const rootTop = root.getBoundingClientRect().top;
      const anchorTop = anchor.getBoundingClientRect().top;

      setCurrentScrollTop(
        root,
        getCurrentScrollTop(root) + (anchorTop - rootTop),
        behavior
      );
      return;
    }

    setCurrentScrollTop(
      root,
      getCurrentScrollTop(root) + anchor.getBoundingClientRect().top,
      behavior
    );
  }

  function scrollPromptBubbleToTop(root, bubble, anchorOverride, behavior) {
    if (!bubble) return;

    const block = bubble.closest(".prompt-block");
    const anchor = anchorOverride || (block ? block.querySelector(".prompt-anchor") : null);
    const scrollNode = anchor || bubble;

    const target = getScrollTarget(root);
    const tailAnchorOffsetPx = getPromptTailAnchorOffset(bubble);

    if (target === root) {
      const rootTop = root.getBoundingClientRect().top;
      const nodeTop = scrollNode.getBoundingClientRect().top;

      setCurrentScrollTop(
        root,
        getCurrentScrollTop(root) + (nodeTop - rootTop) + tailAnchorOffsetPx,
        behavior
      );
      return;
    }

    setCurrentScrollTop(
      root,
      getCurrentScrollTop(root) + scrollNode.getBoundingClientRect().top + tailAnchorOffsetPx,
      behavior
    );
  }

  function scrollPromptToPairId(pairId, behavior) {
    if (pairId == null) return false;

    const safePairId = String(pairId)
      .replace(/^[\s\uFEFF\u200B\u2060\u00A0]+|[\s\uFEFF\u200B\u2060\u00A0]+$/g, "");

    if (!safePairId) return false;

    const rootNode =
      (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.getMount === "function")
        ? window.ResponseRenderBatch.getMount()
        : document.getElementById("ResponseContent");

    if (!rootNode) return false;

    let block = null;

    for (const node of rootNode.children) {
      if (
        node &&
        node.nodeType === 1 &&
        node.dataset &&
        node.dataset.kind === "prompt" &&
        node.dataset.pairId === safePairId
      ) {
        block = node;
        break;
      }
    }

    if (!block) return false;

    const bubble = block.querySelector(".prompt-bubble");
    const anchor = getPromptAnchorByPairId(safePairId);
    const isCollapsed = block.dataset && block.dataset.promptCollapsed === "true";
    const scrollBehavior = behavior === "smooth" ? "smooth" : "auto";

    stopPromptTailPaddingObserver(rootNode);
    clearPromptTailPadding(rootNode);

    if (isCollapsed) {
      const extraPaddingPx = syncPromptTailPadding(rootNode, block, bubble);

      scrollPromptAnchorToTop(rootNode, anchor, scrollBehavior);

      if (extraPaddingPx > 0) {
        watchPromptTailPadding(rootNode, block, bubble);
      } else {
        stopPromptTailPaddingObserver(rootNode);
      }

      return true;
    }

    if (bubble) {
      scrollPromptBubbleToTop(rootNode, bubble, anchor, scrollBehavior);
      return true;
    }

    if (anchor) {
      scrollPromptAnchorToTop(rootNode, anchor, scrollBehavior);
      return true;
    }

    return false;
  }

window.scrollPromptToPairId = function (pairId, behavior) {
  return scrollPromptToPairId(pairId, behavior);
};

  function ensurePromptTailPaddingStyle() {
    if (document.getElementById("prompt-tail-padding-style")) return;

    const style = document.createElement("style");
    style.id = "prompt-tail-padding-style";
    style.textContent = `
      #ResponseContent[data-prompt-tail-padding="on"] {
        padding-bottom: calc(
          var(--prompt-tail-base-padding, 0px) +
          var(--prompt-tail-extra-padding, 0px)
        );
      }
    `;

    (document.head || document.documentElement).appendChild(style);
  }

  function ensurePromptTailPaddingState(root) {
    if (!root.__promptTailPaddingState) {
      root.__promptTailPaddingState = {
        observer: null,
        active: false,
        activePairId: "",
        basePaddingPx: 0
      };
    }

    return root.__promptTailPaddingState;
  }

  function stopPromptTailPaddingObserver(root) {
    if (!root || !root.__promptTailPaddingState) return;

    const state = root.__promptTailPaddingState;

    if (state.observer) {
      state.observer.disconnect();
      state.observer = null;
    }
  }

  function clearPromptTailPadding(root) {
    if (!root) return;

    const state = ensurePromptTailPaddingState(root);

    stopPromptTailPaddingObserver(root);

    root.removeAttribute("data-prompt-tail-padding");
    root.style.removeProperty("--prompt-tail-base-padding");
    root.style.removeProperty("--prompt-tail-extra-padding");

    state.active = false;
    state.activePairId = "";
    state.basePaddingPx = 0;
  }

  function getElementOuterHeight(node) {
    if (!node || node.nodeType !== 1) return 0;

    const rect = node.getBoundingClientRect();
    const style = window.getComputedStyle(node);
    const marginTop = parseFloat(style.marginTop) || 0;
    const marginBottom = parseFloat(style.marginBottom) || 0;

    return rect.height + marginTop + marginBottom;
  }

  function getHeightAfterPrompt(block) {
    let total = 0;
    let node = block ? block.nextSibling : null;

    while (node) {
      if (node.nodeType === 1) {
        total += getElementOuterHeight(node);
      }

      node = node.nextSibling;
    }

    return total;
  }

  function getPromptBodyLineHeight(body) {
    if (!body) return 0;

    const computed = window.getComputedStyle(body);
    const rawLineHeight = computed.lineHeight;

    if (rawLineHeight && rawLineHeight !== "normal") {
      const parsed = parseFloat(rawLineHeight);
      if (Number.isFinite(parsed) && parsed > 0) {
        return parsed;
      }
    }

    const fontSize = parseFloat(computed.fontSize);
    if (Number.isFinite(fontSize) && fontSize > 0) {
      return fontSize * 1.2;
    }

    return 0;
  }

  const PROMPT_COLLAPSE_VISIBLE_LINES = 5;
  const PROMPT_COLLAPSE_ICON_COLLAPSE = "\uE010";
  const PROMPT_COLLAPSE_ICON_EXPAND = "\uE099";

  function ensurePromptSimpleCollapseStyle() {
    if (document.getElementById("prompt-simple-collapse-style")) return;

    const style = document.createElement("style");
    style.id = "prompt-simple-collapse-style";
    style.textContent = `
      .prompt-bubble {
        position: relative;
      }

      .prompt-simple-collapse-toggle {
        display: none;
        width: 28px;
        height: 28px;
        margin: 8px auto 0;
        border: 1px solid rgba(255, 255, 255, 0.18);
        border-radius: 999px;
        background: rgba(0, 90, 158, 0.96);
        color: #fff;
        cursor: pointer;
        padding: 0;
        line-height: 1;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .prompt-simple-collapse-toggle span {
        pointer-events: none;
        display: block;
        font-family: "Segoe MDL2 Assets";
        font-size: 14px;
        line-height: 1;
      }
    `;

    (document.head || document.documentElement).appendChild(style);
  }

  function getPromptCollapseHeight(body) {
    const lineHeight = getPromptBodyLineHeight(body);
    if (!(lineHeight > 0)) return 0;

    return Math.ceil(lineHeight * PROMPT_COLLAPSE_VISIBLE_LINES);
  }

  function ensurePromptSimpleCollapseToggle(block, bubble, body) {
    if (!block || !bubble || !body) return;

    ensurePromptSimpleCollapseStyle();

    let toggle = block.querySelector(".prompt-simple-collapse-toggle");
    if (!toggle) {
      toggle = document.createElement("button");
      toggle.type = "button";
      toggle.className = "prompt-simple-collapse-toggle";
      toggle.setAttribute("aria-label", getPromptToggleAriaLabel());

      const icon = document.createElement("span");
      icon.textContent = PROMPT_COLLAPSE_ICON_COLLAPSE;
      toggle.appendChild(icon);
    }

    if (toggle.parentNode !== bubble) {
      bubble.appendChild(toggle);
    }

    toggle.setAttribute("aria-label", getPromptToggleAriaLabel());

    const collapseHeight = getPromptCollapseHeight(body);
    const canCollapse = collapseHeight > 0 && body.scrollHeight > collapseHeight + 1;

    if (block.dataset.promptCollapsed !== "true" && block.dataset.promptCollapsed !== "false") {
      block.dataset.promptCollapsed = canCollapse ? "true" : "false";
    }

    const isCollapsed = block.dataset.promptCollapsed === "true";

    if (!canCollapse) {
      toggle.style.display = "none";
      body.style.maxHeight = "";
      body.style.overflow = "";
      block.dataset.promptCollapsed = "false";
      return;
    }

    toggle.style.display = "block";

    if (isCollapsed) {
      body.style.maxHeight = collapseHeight + "px";
      body.style.overflow = "hidden";
      toggle.firstChild.textContent = PROMPT_COLLAPSE_ICON_EXPAND;
      toggle.setAttribute("aria-expanded", "false");
    } else {
      body.style.maxHeight = "";
      body.style.overflow = "";
      toggle.firstChild.textContent = PROMPT_COLLAPSE_ICON_COLLAPSE;
      toggle.setAttribute("aria-expanded", "true");
    }

    if (!toggle.__promptSimpleCollapseBound) {
      toggle.onclick = function () {
        block.dataset.promptCollapsed =
          block.dataset.promptCollapsed === "true" ? "false" : "true";

        ensurePromptSimpleCollapseToggle(block, bubble, body);

        const isCollapsed = block.dataset.promptCollapsed === "true";

        const rootNode =
          (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.getMount === "function")
            ? window.ResponseRenderBatch.getMount()
            : document.getElementById("ResponseContent");

        if (!rootNode) return;

        if (isCollapsed) {
          setTimeout(() => {
            const pairIdValue = block.dataset ? String(block.dataset.pairId || "") : "";
            const anchorNode = getPromptAnchorByPairId(pairIdValue);
            const extraPaddingPx = syncPromptTailPadding(rootNode, block, bubble);

            scrollPromptAnchorToTop(rootNode, anchorNode, "smooth");

            if (extraPaddingPx > 0) {
              watchPromptTailPadding(rootNode, block, bubble);
            } else {
              stopPromptTailPaddingObserver(rootNode);
            }
          }, 0);
        } else {
          stopPromptTailPaddingObserver(rootNode);
          clearPromptTailPadding(rootNode);
        }
      };

      toggle.__promptSimpleCollapseBound = true;
    }
  }

  function getPromptTailAnchorOffset(bubble) {
    if (!bubble) return 0;

    const body = bubble.querySelector(".prompt-body");
    if (!body) return 0;

    const lineHeight = getPromptBodyLineHeight(body);
    if (!(lineHeight > 0)) return 0;

    const visibleTextHeight = Math.ceil(lineHeight * PROMPT_COLLAPSE_VISIBLE_LINES);
    const hiddenTextHeight = Math.max(0, body.scrollHeight - visibleTextHeight);

    if (hiddenTextHeight <= 0) {
      return 0;
    }

    const bubbleRect = bubble.getBoundingClientRect();
    const bodyRect = body.getBoundingClientRect();
    const bodyOffsetInBubble = Math.max(0, bodyRect.top - bubbleRect.top);

    return bodyOffsetInBubble + hiddenTextHeight;
  }

  function syncPromptTailPadding(root, block, bubble) {
    if (!root || !block || !bubble) {
      clearPromptTailPadding(root);
      return 0;
    }

    ensurePromptTailPaddingStyle();

    const state = ensurePromptTailPaddingState(root);
    const pairIdValue = block.dataset ? String(block.dataset.pairId || "") : "";

    if (!state.active || state.activePairId !== pairIdValue) {
      state.basePaddingPx = parseFloat(window.getComputedStyle(root).paddingBottom) || 0;
      state.active = true;
      state.activePairId = pairIdValue;
    }

    const viewportHeight = getViewportHeight(root);
    const bubbleHeight = getElementOuterHeight(bubble);
    const bubbleRectHeight = bubble.getBoundingClientRect().height || 0;
    const tailAnchorOffsetPx = Math.min(getPromptTailAnchorOffset(bubble), bubbleRectHeight);
    const visibleBubbleHeight = Math.max(0, bubbleHeight - tailAnchorOffsetPx);
    const contentAfterPromptHeight = getHeightAfterPrompt(block);
    const extraPaddingPx = Math.max(0, viewportHeight - visibleBubbleHeight - contentAfterPromptHeight);

    if (extraPaddingPx <= 0) {
      clearPromptTailPadding(root);
      return 0;
    }

    root.dataset.promptTailPadding = "on";
    root.style.setProperty("--prompt-tail-base-padding", state.basePaddingPx + "px");
    root.style.setProperty("--prompt-tail-extra-padding", extraPaddingPx + "px");

    return extraPaddingPx;
  }

  function watchPromptTailPadding(root, block, bubble) {
    if (!root || !block || !bubble || typeof MutationObserver !== "function") return;

    const state = ensurePromptTailPaddingState(root);

    stopPromptTailPaddingObserver(root);

    const observer = new MutationObserver(() => {
      if (!document.contains(block)) {
        clearPromptTailPadding(root);
        return;
      }

      const currentPairId = block.dataset ? String(block.dataset.pairId || "") : "";

      if (!currentPairId || currentPairId !== state.activePairId) {
        clearPromptTailPadding(root);
        return;
      }

      const extraPaddingPx = syncPromptTailPadding(root, block, bubble);

      if (extraPaddingPx <= 0) {
        stopPromptTailPaddingObserver(root);
      }
    });

    observer.observe(root, {
      childList: true,
      subtree: true,
      characterData: true
    });

    state.observer = observer;
  }

    function ensurePromptAnchor(block, pairId) {
    if (!block) return null;

    let anchor = block.querySelector(".prompt-anchor");
    if (!anchor) {
      anchor = document.createElement("div");
      anchor.className = "prompt-anchor";
    } else {
      anchor.className = "prompt-anchor";
    }

    anchor.dataset.kind = "prompt-anchor";
    anchor.dataset.pairId = pairId;
    anchor.id = "prompt-anchor-" + pairId;

    anchor.style.display = "block";
    anchor.style.height = "0";
    anchor.style.margin = "0";
    anchor.style.padding = "0";
    anchor.style.border = "0";
    anchor.style.overflow = "hidden";
    anchor.style.pointerEvents = "none";

    return anchor;
  }

  function ensurePromptBlock(root, pairId) {
    let block = null;

    for (const node of root.children) {
      if (
        node.nodeType === 1 &&
        node.dataset &&
        node.dataset.kind === "prompt" &&
        node.dataset.pairId === pairId
      ) {
        block = node;
        break;
      }
    }

    if (!block) {
      block = document.createElement("div");
      block.className = "prompt-block";
      root.appendChild(block);
    }

    block.className = "prompt-block";
    block.dataset.kind = "prompt";
    block.dataset.pairId = pairId;

    if (!block.dataset.promptCollapsed) {
      block.dataset.promptCollapsed = "auto";
    }

    const anchor = ensurePromptAnchor(block, pairId);

    let bubble = block.querySelector(".prompt-bubble");
    if (!bubble) {
      bubble = document.createElement("div");
      bubble.className = "chat-bubble user prompt-bubble";
    } else {
      bubble.className = "chat-bubble user prompt-bubble";
    }

    let body = bubble.querySelector(".prompt-body");
    if (!body) {
      body = document.createElement("div");
      body.className = "prompt-body";
      body.style.whiteSpace = "pre-wrap";
      bubble.appendChild(body);
    } else {
      body.className = "prompt-body";
      body.style.whiteSpace = "pre-wrap";
    }

    let selectorHost = block.querySelector(".prompt-selector-host");
    if (!selectorHost) {
      selectorHost = document.createElement("div");
      selectorHost.className = "prompt-selector-host";
    } else {
      selectorHost.className = "prompt-selector-host";
    }

    block.replaceChildren(anchor, bubble, selectorHost);

    if (window.ensurePromptSelector) {
      window.ensurePromptSelector(block);
    }

    return block;
  }

  if (!window.__promptTemplateI18nBound) {
    window.__promptTemplateI18nBound = true;

    window.addEventListener(PROMPT_I18N_EVENT, function () {
      applyPromptDictionary(document);
    });
  }

  clearPromptTailPadding(root);

  const hadScrollableContent = hasVisibleVerticalScrollbar(root);

  const block = ensurePromptBlock(root, pairId);
  const bubble = block.querySelector(".prompt-bubble");
  const body = bubble.querySelector(".prompt-body");
  body.textContent = text;

  ensurePromptSimpleCollapseToggle(block, bubble, body);
  applyPromptDictionary(block);

  if (!window.ResponseRenderBatch || window.ResponseRenderBatch.shouldAutoScroll()) {
    setTimeout(() => {
      if (hadScrollableContent) {
        const extraPaddingPx = syncPromptTailPadding(root, block, bubble);

        scrollPromptBubbleToTop(root, bubble);

        if (extraPaddingPx > 0) {
          watchPromptTailPadding(root, block, bubble);
        }
      } else {
        clearPromptTailPadding(root);
        scrollToConversationBottom(root);
      }
    }, 0);
  }
})();
