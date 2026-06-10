(function () {
  "use strict";

  const ACTIVITY_ID = "__pythia_activity_logo__";
  const STYLE_ID = "__pythia_activity_logo_style__";

  /* ===================================================== */
  /* SETTINGS                                              */
  /* ===================================================== */

  const ACTIVITY_SIZE_PX = 24;

  /*
    Position de l'animation par rapport à la bulle d'entrée.

    Valeurs supportées :
    - "right-center"  : à droite de la bulle, centré verticalement
    - "top-center"    : au-dessus de la bulle, centré horizontalement
    - "left-center"   : à gauche de la bulle, centré verticalement
    - "top-right"     : au-dessus de la bulle, aligné à droite
    - "top-left"      : au-dessus et à gauche de la bulle
    - "bottom-right"  : sous la bulle, aligné à droite
  */
  const ACTIVITY_PLACEMENT = "top-left";

  /*
    Distance entre le bord extérieur de la bulle et l'animation.
  */
  const ACTIVITY_GAP_PX = 12;

  /*
    Réglages fins.
    offsetX positif = plus à droite.
    offsetY positif = plus bas.
  */
  const ACTIVITY_OFFSET_X_PX = 0;
  const ACTIVITY_OFFSET_Y_PX = 0;

  const ACTIVITY_VIEWPORT_MARGIN_PX = 4;
  const ACTIVITY_FALLBACK_RIGHT_PX = 16;
  const ACTIVITY_FALLBACK_BOTTOM_PX = 16;
  const ACTIVITY_Z_INDEX = 2147483646;
  const ACTIVITY_DURATION_MS = 1250;
  const ACTIVITY_ELAPSED_TICK_MS = 250;

  /*
    Sélecteurs d'ancrage.

    Important :
    on ne cible pas textarea/input/contenteditable ici.
    L'ancrage doit se faire sur la bulle extérieure, pas sur le champ interne.
  */
  const ACTIVITY_ANCHOR_SELECTORS = [
    "[data-activity-anchor='input']",
    "[data-activity-anchor]",

    "#InputHost > .input-shell",
    "#InputHost > .prompt-input-shell",
    "#InputHost > .input-bubble",
    "#InputHost > .input-container",

    "#InputHost .input-shell",
    "#InputHost .prompt-input-shell",
    "#InputHost .input-bubble",
    "#InputHost .input-container",

    "#InputHost > :last-child",
    "#InputHost > *",
    "#InputHost",

    "#__delphi_input_string_dialog__"
  ];

  const state = {
    visible: false,
    size: ACTIVITY_SIZE_PX,
    placement: ACTIVITY_PLACEMENT,
    gap: ACTIVITY_GAP_PX,
    offsetX: ACTIVITY_OFFSET_X_PX,
    viewportMargin: ACTIVITY_VIEWPORT_MARGIN_PX,
    fallbackRight: ACTIVITY_FALLBACK_RIGHT_PX,
    fallbackBottom: ACTIVITY_FALLBACK_BOTTOM_PX,
    zIndex: ACTIVITY_Z_INDEX,
    durationMs: ACTIVITY_DURATION_MS,
    anchorSelectors: ACTIVITY_ANCHOR_SELECTORS.slice(),
    positionFrame: 0,
    hideTimer: 0,
    elapsedTimer: 0,
    elapsedStartedAt: 0,
    listenersAttached: false,
    mutationObserver: null
  };

  function clamp(value, min, max) {
    if (max < min) return min;
    return Math.min(Math.max(value, min), max);
  }

  function normalizeOptions(input) {
    if (input == null) return {};

    if (typeof input === "number") {
      return { size: input };
    }

    if (typeof input === "string") {
      const trimmed = input.trim();

      if (!trimmed) return {};

      if (/^-?\d+(\.\d+)?$/.test(trimmed)) {
        return { size: Number(trimmed) };
      }

      try {
        const parsed = JSON.parse(trimmed);
        return parsed && typeof parsed === "object" ? parsed : {};
      } catch (_) {
        return { anchorSelector: trimmed };
      }
    }

    if (typeof input === "object") {
      return input;
    }

    return {};
  }

  function readFiniteNumber(source, key, fallback, min, max) {
    if (!source || !Object.prototype.hasOwnProperty.call(source, key)) {
      return fallback;
    }

    const value = Number(source[key]);

    if (!Number.isFinite(value)) return fallback;

    let result = value;

    if (Number.isFinite(min)) result = Math.max(min, result);
    if (Number.isFinite(max)) result = Math.min(max, result);

    return result;
  }

  function readPlacement(source, key, fallback) {
    if (!source || !Object.prototype.hasOwnProperty.call(source, key)) {
      return fallback;
    }

    const value = String(source[key] == null ? "" : source[key]).trim();

    switch (value) {
      case "right-center":
      case "left-center":
      case "top-right":
      case "top-center":
      case "top-left":
      case "bottom-right":
        return value;

      default:
        return fallback;
    }
  }

  function configure(input) {
    const options = normalizeOptions(input);

    state.size = readFiniteNumber(options, "size", state.size, 8, 128);
    state.gap = readFiniteNumber(options, "gap", state.gap, -128, 256);
    state.offsetX = readFiniteNumber(options, "offsetX", state.offsetX, -512, 512);
    state.offsetY = readFiniteNumber(options, "offsetY", state.offsetY, -512, 512);
    state.viewportMargin = readFiniteNumber(options, "viewportMargin", state.viewportMargin, 0, 256);
    state.fallbackRight = readFiniteNumber(options, "fallbackRight", state.fallbackRight, 0, 512);
    state.fallbackBottom = readFiniteNumber(options, "fallbackBottom", state.fallbackBottom, 0, 512);
    state.zIndex = readFiniteNumber(options, "zIndex", state.zIndex, 1, 2147483647);
    state.durationMs = readFiniteNumber(options, "durationMs", state.durationMs, 250, 10000);
    state.placement = readPlacement(options, "placement", state.placement);

    if (typeof options.anchorSelector === "string" && options.anchorSelector.trim()) {
      state.anchorSelectors = [options.anchorSelector.trim()].concat(ACTIVITY_ANCHOR_SELECTORS);
    }

    if (Array.isArray(options.anchorSelectors) && options.anchorSelectors.length > 0) {
      state.anchorSelectors = options.anchorSelectors
        .map(function (selector) { return String(selector || "").trim(); })
        .filter(Boolean);
    }

    applyRuntimeStyle();
    schedulePosition();

    return getStateSnapshot();
  }

  function ensureStyles() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      :root {
        --activity-logo-cyan-1: #42f7ff;
        --activity-logo-cyan-2: #00c8ff;
        --activity-logo-cyan-3: #007ed0;
        --activity-logo-edge: rgba(0, 79, 145, 0.96);
        --activity-logo-soft: rgba(46, 239, 255, 0.22);
        --activity-logo-glow: rgba(0, 220, 255, 0.90);
      }

      [data-theme="light"] {
        --activity-logo-cyan-1: #22d8ff;
        --activity-logo-cyan-2: #009ee8;
        --activity-logo-cyan-3: #006fbd;
        --activity-logo-edge: rgba(0, 79, 145, 0.58);
        --activity-logo-soft: rgba(0, 140, 220, 0.18);
        --activity-logo-glow: rgba(0, 150, 230, 0.55);
      }

      #${ACTIVITY_ID} {
        position: fixed;
        left: 0;
        top: 0;
        display: inline-flex;
        align-items: center;
        gap: var(--activity-logo-elapsed-gap, 6px);
        width: auto;
        height: var(--activity-logo-size, 24px);
        z-index: var(--activity-logo-z-index, 2147483646);
        pointer-events: none;
        opacity: 0;
        transform: translate3d(0, 0, 0) scale(0.92);
        transform-origin: 50% 50%;
        transition:
          opacity 140ms ease,
          transform 140ms ease;
        contain: layout style paint;
        will-change: left, top, opacity, transform;
      }

      #${ACTIVITY_ID}[hidden] {
        display: none !important;
      }

      #${ACTIVITY_ID}.${ACTIVITY_ID}_visible {
        opacity: 1;
        transform: translate3d(0, 0, 0) scale(1);
      }

      #${ACTIVITY_ID} svg {
        display: block;
        flex: 0 0 var(--activity-logo-size, 24px);
        width: var(--activity-logo-size, 24px);
        height: var(--activity-logo-size, 24px);
        overflow: visible;
      }

      #${ACTIVITY_ID} .${ACTIVITY_ID}_elapsed {
        flex: 0 0 auto;
        min-width: 4ch;
        color: rgb(50%, 50%, 50%);
        font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        font-size: 12px;
        font-weight: 500;
        line-height: 1;
        letter-spacing: 0;
        font-variant-numeric: tabular-nums;
        white-space: nowrap;
      }

      #${ACTIVITY_ID} .${ACTIVITY_ID}_path {
        fill: none;
        stroke-linecap: round;
        stroke-linejoin: round;
      }

      #${ACTIVITY_ID} .${ACTIVITY_ID}_soft_body {
        stroke: var(--activity-logo-soft);
        stroke-width: 8.75;
      }

      #${ACTIVITY_ID} .${ACTIVITY_ID}_edge {
        stroke: var(--activity-logo-edge);
        stroke-width: 7.25;
        opacity: 0.95;
      }

      #${ACTIVITY_ID} .${ACTIVITY_ID}_body {
        stroke: url(#${ACTIVITY_ID}_stroke);
        stroke-width: 5.25;
        stroke-dasharray: 15 122;
        filter: drop-shadow(0 0 var(--activity-logo-glow-size, 1.5px) var(--activity-logo-glow));
      }

      #${ACTIVITY_ID} .${ACTIVITY_ID}_dot {
        transform-origin: 25.7px 17.1px;
        filter: drop-shadow(0 0 var(--activity-logo-dot-glow-size, 1.8px) var(--activity-logo-glow));
      }

      #${ACTIVITY_ID} .${ACTIVITY_ID}_dot_highlight {
        transform-origin: 25.7px 17.1px;
      }

      #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_body {
        animation: ${ACTIVITY_ID}_path_run var(--activity-logo-duration, 1250ms) linear infinite;
      }

      #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_soft_body {
        animation: ${ACTIVITY_ID}_glow_breathe var(--activity-logo-duration, 1250ms) ease-in-out infinite;
      }

      #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_dot {
        animation: ${ACTIVITY_ID}_dot_pulse var(--activity-logo-duration, 1250ms) ease-in-out infinite;
      }

      #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_dot_highlight {
        animation: ${ACTIVITY_ID}_dot_highlight var(--activity-logo-duration, 1250ms) ease-in-out infinite;
      }

      @keyframes ${ACTIVITY_ID}_path_run {
        from { stroke-dashoffset: 0; }
        to   { stroke-dashoffset: -137; }
      }

      @keyframes ${ACTIVITY_ID}_glow_breathe {
        0%, 100% { opacity: 0.25; }
        50%      { opacity: 0.55; }
      }

      @keyframes ${ACTIVITY_ID}_dot_pulse {
        0%, 100% { transform: scale(0.88); opacity: 0.82; }
        50%      { transform: scale(1.08); opacity: 1; }
      }

      @keyframes ${ACTIVITY_ID}_dot_highlight {
        0%, 100% { opacity: 0.25; transform: translate(-0.4px, -0.4px) scale(0.85); }
        50%      { opacity: 0.72; transform: translate(0.3px, 0.25px) scale(1.05); }
      }

      @media (prefers-reduced-motion: reduce) {
        #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_body,
        #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_soft_body,
        #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_dot,
        #${ACTIVITY_ID}.${ACTIVITY_ID}_running .${ACTIVITY_ID}_dot_highlight {
          animation: none;
        }
      }
    `;

    document.head.appendChild(style);
  }

  function createSvgMarkup() {
    return `
      <svg viewBox="0 0 44 44" width="44" height="44" aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="${ACTIVITY_ID}_stroke" x1="10" y1="6" x2="39" y2="37" gradientUnits="userSpaceOnUse">
            <stop offset="0%" style="stop-color: var(--activity-logo-cyan-1);" />
            <stop offset="52%" style="stop-color: var(--activity-logo-cyan-2);" />
            <stop offset="100%" style="stop-color: var(--activity-logo-cyan-3);" />
          </linearGradient>

          <radialGradient id="${ACTIVITY_ID}_dot_gradient" cx="36%" cy="30%" r="68%">
            <stop offset="0%" stop-color="#eaffff" />
            <stop offset="42%" stop-color="#35f7ff" />
            <stop offset="100%" stop-color="#0097e6" />
          </radialGradient>
        </defs>

        <path
          class="${ACTIVITY_ID}_path ${ACTIVITY_ID}_soft_body"
          d="M 12.8 36.3 L 12.8 11.6 Q 12.8 6.8 17.9 6.8 L 28.8 6.8 Q 36.3 6.8 39.1 13.1 Q 42.0 19.7 38.0 25.4 Q 34.9 29.8 28.0 29.8 L 19.6 29.8 L 12.8 36.3"
        />

        <path
          class="${ACTIVITY_ID}_path ${ACTIVITY_ID}_edge"
          d="M 12.8 36.3 L 12.8 11.6 Q 12.8 6.8 17.9 6.8 L 28.8 6.8 Q 36.3 6.8 39.1 13.1 Q 42.0 19.7 38.0 25.4 Q 34.9 29.8 28.0 29.8 L 19.6 29.8 L 12.8 36.3"
        />

        <path
          class="${ACTIVITY_ID}_path ${ACTIVITY_ID}_body"
          d="M 12.8 36.3 L 12.8 11.6 Q 12.8 6.8 17.9 6.8 L 28.8 6.8 Q 36.3 6.8 39.1 13.1 Q 42.0 19.7 38.0 25.4 Q 34.9 29.8 28.0 29.8 L 19.6 29.8 L 12.8 36.3"
        />

        <circle class="${ACTIVITY_ID}_dot" cx="25.7" cy="17.1" r="5.65" fill="url(#${ACTIVITY_ID}_dot_gradient)" />
        <circle class="${ACTIVITY_ID}_dot_highlight" cx="24.0" cy="15.25" r="1.65" fill="#eaffff" />
      </svg>
    `;
  }

  function createElapsedMarkup() {
    return '<span class="' + ACTIVITY_ID + '_elapsed" aria-hidden="true">0:00</span>';
  }

  function ensureHost() {
    ensureStyles();

    let host = document.getElementById(ACTIVITY_ID);

    if (!host) {
      host = document.createElement("div");
      host.id = ACTIVITY_ID;
      host.hidden = true;
      host.setAttribute("role", "status");
      host.setAttribute("aria-live", "polite");
      host.setAttribute("aria-label", "Traitement en cours");
      host.setAttribute("aria-hidden", "true");
      host.innerHTML = createSvgMarkup() + createElapsedMarkup();
      document.body.appendChild(host);
    } else if (!host.querySelector("." + ACTIVITY_ID + "_elapsed")) {
      host.insertAdjacentHTML("beforeend", createElapsedMarkup());
    }

    applyRuntimeStyle(host);

    return host;
  }

  function applyRuntimeStyle(host) {
    const target = host || document.getElementById(ACTIVITY_ID);
    if (!target) return;

    target.style.setProperty("--activity-logo-size", state.size + "px");
    target.style.setProperty("--activity-logo-z-index", String(Math.round(state.zIndex)));
    target.style.setProperty("--activity-logo-duration", Math.round(state.durationMs) + "ms");
    target.style.setProperty("--activity-logo-glow-size", Math.max(1, state.size / 16).toFixed(2) + "px");
    target.style.setProperty("--activity-logo-dot-glow-size", Math.max(1.1, state.size / 13.5).toFixed(2) + "px");
    target.style.setProperty("--activity-logo-elapsed-gap", Math.max(4, state.size / 4).toFixed(2) + "px");
  }

  function getNowMs() {
    return window.performance && typeof window.performance.now === "function"
      ? window.performance.now()
      : Date.now();
  }

  function formatElapsedTime(totalSeconds) {
    const safeSeconds = Math.max(0, Math.floor(totalSeconds));
    const seconds = safeSeconds % 60;
    const totalMinutes = Math.floor(safeSeconds / 60);
    const minutes = totalMinutes % 60;
    const hours = Math.floor(totalMinutes / 60);
    const paddedSeconds = seconds < 10 ? "0" + seconds : String(seconds);

    if (hours > 0) {
      const paddedMinutes = minutes < 10 ? "0" + minutes : String(minutes);
      return hours + ":" + paddedMinutes + ":" + paddedSeconds;
    }

    return totalMinutes + ":" + paddedSeconds;
  }

  function updateElapsedTime(host) {
    const target = host || document.getElementById(ACTIVITY_ID);
    if (!target) return;

    const elapsedNode = target.querySelector("." + ACTIVITY_ID + "_elapsed");
    if (!elapsedNode) return;

    elapsedNode.textContent = formatElapsedTime((getNowMs() - state.elapsedStartedAt) / 1000);
  }

  function stopElapsedTimer() {
    if (state.elapsedTimer) {
      window.clearInterval(state.elapsedTimer);
      state.elapsedTimer = 0;
    }
  }

  function startElapsedTimer(host) {
    stopElapsedTimer();
    state.elapsedStartedAt = getNowMs();
    updateElapsedTime(host);
    state.elapsedTimer = window.setInterval(function () {
      updateElapsedTime(host);
    }, ACTIVITY_ELAPSED_TICK_MS);
  }

  function getCandidateAnchorElements() {
    const result = [];
    const seen = new Set();

    state.anchorSelectors.forEach(function (selector) {
      let nodes;

      try {
        nodes = document.querySelectorAll(selector);
      } catch (_) {
        nodes = [];
      }

      Array.prototype.forEach.call(nodes, function (node) {
        if (!node || seen.has(node)) return;
        seen.add(node);
        result.push(node);
      });
    });

    return result;
  }

  function getAnchorRect() {
    const candidates = getCandidateAnchorElements();

    for (let i = 0; i < candidates.length; i += 1) {
      const node = candidates[i];
      if (!node || typeof node.getBoundingClientRect !== "function") continue;

      const rect = node.getBoundingClientRect();
      const hasSize = rect.width > 0 && rect.height > 0;
      const isUsable = hasSize && rect.right > 0 && rect.bottom > 0;

      if (isUsable) {
        return rect;
      }
    }

    return null;
  }

  function getViewportSize() {
    const viewport = window.visualViewport;

    return {
      width: viewport && viewport.width ? viewport.width : window.innerWidth,
      height: viewport && viewport.height ? viewport.height : window.innerHeight,
      offsetLeft: viewport && viewport.offsetLeft ? viewport.offsetLeft : 0,
      offsetTop: viewport && viewport.offsetTop ? viewport.offsetTop : 0
    };
  }

  function positionHost() {
    const host = ensureHost();
    const rect = getAnchorRect();
    const viewport = getViewportSize();
    const margin = state.viewportMargin;
    const size = state.size;

    let left;
    let top;

    if (rect) {
      switch (state.placement) {
        case "left-center":
          left = viewport.offsetLeft + rect.left - size - state.gap + state.offsetX;
          top = viewport.offsetTop + rect.top + ((rect.height - size) / 2) + state.offsetY;
          break;

        case "top-right":
          left = viewport.offsetLeft + rect.right - size + state.offsetX;
          top = viewport.offsetTop + rect.top - size - state.gap + state.offsetY;
          break;

        case "top-center":
          left = viewport.offsetLeft + rect.left + ((rect.width - size) / 2) + state.offsetX;
          top = viewport.offsetTop + rect.top - size - state.gap + state.offsetY;
          break;

        case "top-left":
          left = viewport.offsetLeft + rect.left - size - state.gap + state.offsetX;
          top = viewport.offsetTop + rect.top - size - state.gap + state.offsetY;
          break;

        case "bottom-right":
          left = viewport.offsetLeft + rect.right - size + state.offsetX;
          top = viewport.offsetTop + rect.bottom + state.gap + state.offsetY;
          break;

        case "right-center":
        default:
          left = viewport.offsetLeft + rect.right + state.gap + state.offsetX;
          top = viewport.offsetTop + rect.top + ((rect.height - size) / 2) + state.offsetY;
          break;
      }
    } else {
      left = viewport.offsetLeft + viewport.width - size - state.fallbackRight;
      top = viewport.offsetTop + viewport.height - size - state.fallbackBottom;
    }

    left = clamp(
      left,
      viewport.offsetLeft + margin,
      viewport.offsetLeft + viewport.width - size - margin
    );

    top = clamp(
      top,
      viewport.offsetTop + margin,
      viewport.offsetTop + viewport.height - size - margin
    );

    host.style.left = Math.round(left) + "px";
    host.style.top = Math.round(top) + "px";
  }

  function schedulePosition() {
    if (state.positionFrame) return;

    state.positionFrame = window.requestAnimationFrame(function () {
      state.positionFrame = 0;
      positionHost();
    });
  }

  function attachRuntimeListeners() {
    if (state.listenersAttached) return;
    state.listenersAttached = true;

    window.addEventListener("resize", schedulePosition, { passive: true });

    if (window.visualViewport) {
      window.visualViewport.addEventListener("resize", schedulePosition, { passive: true });
    }

    if (typeof MutationObserver === "function" && document.body) {
      state.mutationObserver = new MutationObserver(function (mutations) {
        if (!state.visible) return;

        const host = document.getElementById(ACTIVITY_ID);
        const onlyActivityHostChanged = mutations.every(function (mutation) {
          return mutation.target === host;
        });

        if (!onlyActivityHostChanged) {
          schedulePosition();
        }
      });

      state.mutationObserver.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ["class", "style", "hidden", "data-theme"]
      });
    }
  }

  function detachRuntimeListeners() {
    if (!state.listenersAttached) return;
    state.listenersAttached = false;

    window.removeEventListener("resize", schedulePosition);

    if (window.visualViewport) {
      window.visualViewport.removeEventListener("resize", schedulePosition);
    }

    if (state.mutationObserver) {
      state.mutationObserver.disconnect();
      state.mutationObserver = null;
    }
  }

  function restartAnimation(host) {
    host.classList.remove(ACTIVITY_ID + "_running");

    /* Force le redémarrage propre des keyframes quand Delphi rappelle ActivityShow. */
    void host.offsetWidth;

    host.classList.add(ACTIVITY_ID + "_running");
  }

  function show(input) {
    configure(input);

    const host = ensureHost();

    if (state.hideTimer) {
      window.clearTimeout(state.hideTimer);
      state.hideTimer = 0;
    }

    attachRuntimeListeners();
    positionHost();

    state.visible = true;
    host.hidden = false;
    host.setAttribute("aria-hidden", "false");
    startElapsedTimer(host);

    restartAnimation(host);

    window.requestAnimationFrame(function () {
      host.classList.add(ACTIVITY_ID + "_visible");
      schedulePosition();
    });

    return getStateSnapshot();
  }

  function hide() {
    const host = document.getElementById(ACTIVITY_ID);

    state.visible = false;
    stopElapsedTimer();

    if (!host) {
      detachRuntimeListeners();
      return getStateSnapshot();
    }

    host.classList.remove(ACTIVITY_ID + "_visible");
    host.classList.remove(ACTIVITY_ID + "_running");
    host.setAttribute("aria-hidden", "true");

    if (state.hideTimer) {
      window.clearTimeout(state.hideTimer);
    }

    state.hideTimer = window.setTimeout(function () {
      state.hideTimer = 0;
      if (!state.visible && host) {
        host.hidden = true;
      }
      detachRuntimeListeners();
    }, 160);

    return getStateSnapshot();
  }

  function getStateSnapshot() {
    return {
      visible: !!state.visible,
      size: state.size,
      placement: state.placement,
      gap: state.gap,
      offsetX: state.offsetX,
      offsetY: state.offsetY,
      zIndex: state.zIndex,
      durationMs: state.durationMs,
      anchorSelectors: state.anchorSelectors.slice()
    };
  }

  function handleHostMessage(data) {
    if (!data || typeof data !== "object") return;

    if (data.type === "activity-logo" || data.type === "activity") {
      const action = String(data.action || "").toLowerCase();

      if (action === "show" || data.visible === true) {
        show(data.options || data);
        return;
      }

      if (action === "hide" || data.visible === false) {
        hide();
      }
    }
  }

  if (window.chrome && window.chrome.webview) {
    window.chrome.webview.addEventListener("message", function (args) {
      handleHostMessage(args.data);
    });
  }

  window.ActivityShow = function (options) {
    return show(options);
  };

  window.ActivityHide = function () {
    return hide();
  };

  window.ActivityLogo = {
    show: show,
    hide: hide,
    configure: configure,
    updatePosition: schedulePosition,
    getState: getStateSnapshot
  };
})();
