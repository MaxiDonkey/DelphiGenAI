(function () {

  function onReady(fn) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", fn, { once: true });
    } else {
      fn();
    }
  }

  const SCROLL_BUTTONS_I18N_EVENT =
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

  onReady(function () {

    if (document.getElementById("scrollBtnTop") || document.getElementById("scrollBtnBottom")) {
      return;
    }

    const btnTop = document.createElement("button");
    const btnBottom = document.createElement("button");

    btnTop.id = "scrollBtnTop";
    btnBottom.id = "scrollBtnBottom";

    btnTop.className = "scroll-nav-btn";
    btnBottom.className = "scroll-nav-btn";

    btnTop.type = "button";
    btnBottom.type = "button";

    btnTop.textContent = "\uE64C";
    btnBottom.textContent = "\uE64B";

    function applyScrollButtonsDictionary() {
      const topText = t("scroll.top", "Scroll to top");
      const bottomText = t("scroll.bottom", "Scroll to bottom");

      btnTop.title = topText;
      btnTop.setAttribute("aria-label", topText);

      btnBottom.title = bottomText;
      btnBottom.setAttribute("aria-label", bottomText);
    }

    document.body.appendChild(btnTop);
    document.body.appendChild(btnBottom);

    applyScrollButtonsDictionary();

    window.addEventListener(SCROLL_BUTTONS_I18N_EVENT, function () {
      applyScrollButtonsDictionary();
    });

    const scrollButtonsRuntime =
      window.__scrollButtonsRuntime ||
      (window.__scrollButtonsRuntime = {
        enabled: false
      });

    let hostScrollButtonsVisible = false;
    let scrollButtonsHandlingEnabled = false;
    let responseRootScrollTarget = null;
    let responseRootObserver = null;
    let scheduledUpdateFrameId = 0;
    let scheduledUpdateTimeoutIds = [];

    function clearScheduledUpdates() {
      if (scheduledUpdateFrameId) {
        window.cancelAnimationFrame(scheduledUpdateFrameId);
        scheduledUpdateFrameId = 0;
      }

      while (scheduledUpdateTimeoutIds.length > 0) {
        window.clearTimeout(scheduledUpdateTimeoutIds.pop());
      }
    }

    function scheduleUpdateSequence(delays) {
      if (!hostScrollButtonsVisible || !scrollButtonsHandlingEnabled) {
        return;
      }

      clearScheduledUpdates();
      updateButtons();

      scheduledUpdateFrameId = window.requestAnimationFrame(function () {
        scheduledUpdateFrameId = 0;

        if (!hostScrollButtonsVisible || !scrollButtonsHandlingEnabled) {
          return;
        }

        updateButtons();
      });

      delays.forEach(function (delay) {
        const timeoutId = window.setTimeout(function () {
          scheduledUpdateTimeoutIds = scheduledUpdateTimeoutIds.filter(function (id) {
            return id !== timeoutId;
          });

          if (!hostScrollButtonsVisible || !scrollButtonsHandlingEnabled) {
            return;
          }

          updateButtons();
        }, delay);

        scheduledUpdateTimeoutIds.push(timeoutId);
      });
    }

    function detachResponseRootTracking() {
      if (responseRootScrollTarget) {
        responseRootScrollTarget.removeEventListener("scroll", updateButtons);
        responseRootScrollTarget = null;
      }

      if (responseRootObserver) {
        responseRootObserver.disconnect();
        responseRootObserver = null;
      }
    }

    function attachResponseRootTracking() {
      const root = getResponseRoot();

      if (!root) {
        detachResponseRootTracking();
        return;
      }

      if (responseRootScrollTarget === root && responseRootObserver) {
        return;
      }

      detachResponseRootTracking();

      responseRootScrollTarget = root;
      responseRootScrollTarget.addEventListener("scroll", updateButtons, { passive: true });

      responseRootObserver = new MutationObserver(function () {
        scheduleUpdateSequence([0, 120]);
      });

      responseRootObserver.observe(responseRootScrollTarget, {
        childList: true,
        subtree: true,
        characterData: true
      });
    }

    function enableScrollButtonsHandling() {
      if (scrollButtonsHandlingEnabled) {
        attachResponseRootTracking();
        scheduleUpdateSequence([0, 150, 400]);
        return;
      }

      scrollButtonsHandlingEnabled = true;

      window.addEventListener("scroll", updateButtons, { passive: true });
      window.addEventListener("resize", updateButtons, { passive: true });

      attachResponseRootTracking();
      scheduleUpdateSequence([0, 150, 400]);
    }

    function disableScrollButtonsHandling() {
      clearScheduledUpdates();

      if (scrollButtonsHandlingEnabled) {
        window.removeEventListener("scroll", updateButtons);
        window.removeEventListener("resize", updateButtons);
        detachResponseRootTracking();
        scrollButtonsHandlingEnabled = false;
      }

      hideButtonsGroup();
    }

    function setButtonsVisibility(showTop, showBottom) {
      btnTop.style.display = showTop ? "flex" : "none";
      btnBottom.style.display = showBottom ? "flex" : "none";
    }

    function hideButtonsGroup() {
      setButtonsVisibility(false, false);
    }

    window.setScrollButtonsVisible = function (visible) {
      const nextVisible = !!visible;

      scrollButtonsRuntime.enabled = nextVisible;
      hostScrollButtonsVisible = nextVisible;

      window.dispatchEvent(
        new CustomEvent("app:scroll-buttons-visibility-changed", {
          detail: { visible: nextVisible }
        })
      );

      if (hostScrollButtonsVisible) {
        enableScrollButtonsHandling();
        return;
      }

      disableScrollButtonsHandling();
    };

    function getResponseRoot() {
      return document.getElementById("ResponseContent");
    }

    function hasConversation() {
      const root = getResponseRoot();
      if (!root) return false;
      if (root.children.length > 0) return true;
      return root.textContent.trim().length > 0;
    }

    function getMetrics() {
      const root = getResponseRoot();

      if (root) {
        const style = window.getComputedStyle(root);
        const rootScrollable =
          (style.overflowY === "auto" || style.overflowY === "scroll") &&
          root.scrollHeight > root.clientHeight + 4;

        if (rootScrollable) {
          return {
            top: root.scrollTop,
            view: root.clientHeight,
            height: root.scrollHeight
          };
        }
      }

      const top = Math.max(
        window.pageYOffset || 0,
        document.documentElement.scrollTop || 0,
        document.body.scrollTop || 0
      );

      const view = window.innerHeight || document.documentElement.clientHeight || 0;

      const height = Math.max(
        document.body.scrollHeight || 0,
        document.documentElement.scrollHeight || 0,
        root ? root.scrollHeight || 0 : 0
      );

      return { top, view, height };
    }

    function updateButtons() {
      if (!hostScrollButtonsVisible || !scrollButtonsHandlingEnabled) {
        hideButtonsGroup();
        return;
      }

      if (!hasConversation()) {
        hideButtonsGroup();
        return;
      }

      const m = getMetrics();
      const hasScroll = m.height > m.view + 4;
      const atTop = m.top <= 4;
      const atBottom = m.top + m.view >= m.height - 4;

      if (!hasScroll) {
        hideButtonsGroup();
        return;
      }

      setButtonsVisibility(!atTop, !atBottom);
    }

    function postDirection(direction) {
      if (window.chrome && window.chrome.webview && window.chrome.webview.postMessage) {
        window.chrome.webview.postMessage({
          event: "scroll-request",
          direction: direction
        });
      }
    }

    btnTop.addEventListener("click", function () {
      postDirection("top");
    });

    btnBottom.addEventListener("click", function () {
      postDirection("bottom");
    });

    if (hostScrollButtonsVisible) {
      enableScrollButtonsHandling();
    } else {
      disableScrollButtonsHandling();
    }

  });

})();