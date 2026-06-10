(() => {

  function translateDisplayVideoText(key, fallback, vars) {
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

  try {
    const videos = %s;
    const pairId = %s;

    const FILE_CARD_WIDTH = 300;
    const FILE_CARD_MIN_HEIGHT = 60;

    const DATA_URI_EXTENSION_BY_MIME = {
      "video/mp4": "mp4",
      "video/webm": "webm",
      "video/ogg": "ogv",
      "video/quicktime": "mov",
      "video/x-msvideo": "avi",
      "video/x-m4v": "m4v",
      "video/mpeg": "mpeg"
    };

        const DISPLAY_VIDEO_I18N_EVENT =
      window.AppI18n && window.AppI18n.eventName
        ? window.AppI18n.eventName
        : "app:i18n:changed";

    const t = translateDisplayVideoText;

    function getDisplayVideoFallbackName(index) {
      return t("displayVideo.fallbackName", "Video {index}", {
        index: (Number(index) || 0) + 1
      });
    }

    function getDisplayVideoFallbackNameWithExtension(index, ext) {
      return t("displayVideo.fallbackNameWithExtension", "Video {index}.{ext}", {
        index: (Number(index) || 0) + 1,
        ext: String(ext || "video")
      });
    }

    function getDisplayVideoOpenText() {
      return t("displayVideo.action.open", "Open");
    }

    function getDisplayVideoCloseText() {
      return t("displayVideo.action.close", "Fermer");
    }

    function applyDisplayVideoControllerDictionary(controller) {
      if (!controller || !controller.overlay) {
        return;
      }

      const closeBtn = controller.overlay.__closeBtn || null;

      if (closeBtn) {
        closeBtn.setAttribute("aria-label", getDisplayVideoCloseText());
      }
    }

    function applyDisplayVideoCardDictionary(card) {
      if (!card) {
        return;
      }

      if (card.__labelNode) {
        card.__labelNode.textContent = extractFileName(card.__videoSource, card.__videoIndex);
      }

      if (card.__status) {
        card.__status.textContent = getDisplayVideoOpenText();
      }
    }

    function applyDisplayVideoDictionary() {
      if (window.__displayVideoController) {
        applyDisplayVideoControllerDictionary(window.__displayVideoController);
      }

      const cards = document.querySelectorAll('[data-display-video-card="1"]');

      cards.forEach(function (card) {
        applyDisplayVideoCardDictionary(card);
      });
    }

    function ensureMount() {
      if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.getMount === "function") {
        return window.ResponseRenderBatch.getMount();
      }

      let mount = document.getElementById("ResponseContent");

      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      return mount;
    }

    function ensureActiveResponse(pairIdValue) {
      if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.ensureActiveResponse === "function") {
        return window.ResponseRenderBatch.ensureActiveResponse(
          pairIdValue,
          "assistant-message display-block"
        ).response;
      }

      const mount = ensureMount();
      const expectedPairId = String(pairIdValue == null ? "" : pairIdValue);

      let block = null;

      for (const node of mount.children) {
        if (node.nodeType === 1 && node.id === "assistant-stream-block") {
          block = node;
          break;
        }
      }

      if (block && block !== mount.lastElementChild) {
        block.removeAttribute("id");
        block = null;
      }

      if (block && block.dataset && (block.dataset.pairId || "") !== expectedPairId) {
        block.removeAttribute("id");
        block = null;
      }

      if (!block) {
        block = document.createElement("div");
        block.className = "assistant-message display-block";
        block.id = "assistant-stream-block";
        mount.appendChild(block);
      }

      block.dataset.pairId = expectedPairId;

      let response = block.querySelector(".assistant-response");

      if (!response) {
        response = document.createElement("div");
        response.className = "assistant-response";
        block.appendChild(response);
      }

      return response;
    }

    function guessDataUriExtension(value) {
      const match = /^data:([^;,]+)[;,]/i.exec(value || "");

      if (!match) {
        return "video";
      }

      const mime = String(match[1] || "").toLowerCase();
      return DATA_URI_EXTENSION_BY_MIME[mime] || mime.split("/").pop() || "video";
    }

    function extractFileName(value, index) {
      const source = String(value || "").trim();

      if (!source) {
        return getDisplayVideoFallbackName(index);
      }

      if (/^data:/i.test(source)) {
        return getDisplayVideoFallbackNameWithExtension(
          index,
          guessDataUriExtension(source)
        );
      }

      let normalized = source.replace(/\\/g, "/");
      normalized = normalized.split("#")[0].split("?")[0];

      const lastSlash = normalized.lastIndexOf("/");
      const fileName = lastSlash >= 0 ? normalized.slice(lastSlash + 1) : normalized;

      if (!fileName) {
        return getDisplayVideoFallbackName(index);
      }

      try {
        return decodeURIComponent(fileName);
      } catch {
        return fileName;
      }
    }

    function createVideoIcon() {
      const iconWrap = document.createElement("div");

      Object.assign(iconWrap.style, {
        width: "36px",
        height: "36px",
        minWidth: "36px",
        minHeight: "36px",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        borderRadius: "10px",
        background: "var(--input-chip-bg)",
        boxSizing: "border-box",
        flex: "0 0 auto"
      });

      const ns = "http://www.w3.org/2000/svg";
      const svg = document.createElementNS(ns, "svg");
      svg.setAttribute("viewBox", "0 0 24 24");
      svg.setAttribute("width", "18");
      svg.setAttribute("height", "18");
      svg.setAttribute("aria-hidden", "true");

      Object.assign(svg.style, {
        display: "block",
        color: "var(--input-chip-text)"
      });

      const path = document.createElementNS(ns, "path");
      path.setAttribute(
        "d",
        "M4 7.75A2.75 2.75 0 0 1 6.75 5h6.5A2.75 2.75 0 0 1 16 7.75v.71l2.74-1.83A1.25 1.25 0 0 1 20.67 7.67v8.66a1.25 1.25 0 0 1-1.93 1.04L16 15.54v.71A2.75 2.75 0 0 1 13.25 19h-6.5A2.75 2.75 0 0 1 4 16.25z"
      );
      path.setAttribute("fill", "currentColor");

      svg.appendChild(path);
      iconWrap.appendChild(svg);

      return iconWrap;
    }

    function createStatusNode() {
      const status = document.createElement("div");
      status.textContent = getDisplayVideoOpenText();

      Object.assign(status.style, {
        flex: "0 0 auto",
        maxWidth: "74px",
        overflow: "hidden",
        textOverflow: "ellipsis",
        whiteSpace: "nowrap",
        padding: "4px 8px",
        borderRadius: "999px",
        background: "var(--input-chip-bg)",
        color: "var(--input-chip-text)",
        font: "600 11px system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        lineHeight: "16px",
        boxSizing: "border-box"
      });

      return status;
    }

    function applyCardVisualState(card) {
      const hovered = !!card.__isHovered;

      card.style.background = hovered
        ? "var(--input-shell-bg-hover)"
        : "var(--input-shell-bg)";
      card.style.borderColor = "var(--input-shell-border)";
      /*card.style.boxShadow = "var(--input-shell-shadow)";*/
      card.style.boxShadow = "none";
    }

    function createActionButton(text) {
      const button = document.createElement("button");
      button.type = "button";
      button.textContent = text;

      Object.assign(button.style, {
        appearance: "none",
        border: "1px solid var(--input-shell-border)",
        background: "var(--input-chip-bg)",
        color: "var(--input-chip-text)",
        borderRadius: "10px",
        padding: "8px 12px",
        font: "600 12px system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        lineHeight: "16px",
        cursor: "pointer",
        boxSizing: "border-box"
      });

      button.addEventListener("mouseenter", () => {
        button.style.filter = "brightness(1.05)";
      });

      button.addEventListener("mouseleave", () => {
        button.style.filter = "none";
      });

      return button;
    }

    function ensureVideoController() {
      if (window.__displayVideoController) {
        try {
          if (
            window.__displayVideoController.overlay &&
            window.__displayVideoController.overlay.parentNode
          ) {
            window.__displayVideoController.overlay.parentNode.removeChild(
              window.__displayVideoController.overlay
            );
          }
        } catch {}

        window.__displayVideoController = null;
      }

      let previousBodyOverflow = "";

      const overlay = document.createElement("div");
      overlay.id = "display-video-overlay";

      Object.assign(overlay.style, {
        position: "fixed",
        inset: "0",
        zIndex: "999999",
        display: "none",
        alignItems: "center",
        justifyContent: "center",
        padding: "24px",
        background: "rgba(15,15,15,0.35)",
        backdropFilter: "blur(14px)",
        WebkitBackdropFilter: "blur(14px)",
        boxSizing: "border-box"
      });

      const closeBtn = document.createElement("button");
      closeBtn.type = "button";
      closeBtn.setAttribute("aria-label", getDisplayVideoCloseText());

      Object.assign(closeBtn.style, {
        position: "absolute",
        top: "18px",
        right: "18px",
        width: "42px",
        height: "42px",
        border: "none",
        borderRadius: "999px",
        cursor: "pointer",
        color: "#fff",
        background: "var(--image-hover-overlay, rgba(0,0,0,0.45))",
        backdropFilter: "blur(6px)",
        WebkitBackdropFilter: "blur(6px)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "0",
        fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        fontSize: "28px",
        lineHeight: "1",
        zIndex: "1"
      });

      const closeIcon = document.createElement("span");
      closeIcon.textContent = "×";

      Object.assign(closeIcon.style, {
        display: "block",
        lineHeight: "1",
        transform: "translateY(-2px)"
      });

      closeBtn.appendChild(closeIcon);

      const dialog = document.createElement("div");

      Object.assign(dialog.style, {
        width: "min(1100px, calc(100vw - 48px))",
        maxWidth: "1100px",
        maxHeight: "calc(100vh - 48px)",
        display: "flex",
        flexDirection: "column",
        background: "var(--input-shell-bg)",
        border: "1px solid var(--input-shell-border)",
        borderRadius: "16px",
        /*boxShadow: "var(--input-shell-shadow)",*/
        boxShadow: "none",
        overflow: "hidden",
        boxSizing: "border-box"
      });

      const body = document.createElement("div");

      Object.assign(body.style, {
        padding: "16px",
        boxSizing: "border-box",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "#000"
      });

      const player = document.createElement("video");
      player.id = "display-video-player";
      player.preload = "metadata";
      player.controls = true;
      player.playsInline = true;

      Object.assign(player.style, {
        display: "block",
        width: "100%%",
        maxWidth: "100%%",
        maxHeight: "calc(100vh - 180px)",
        background: "#000",
        borderRadius: "12px",
        outline: "none"
      });

      body.appendChild(player);
      dialog.appendChild(body);

      overlay.appendChild(closeBtn);
      overlay.appendChild(dialog);
      document.body.appendChild(overlay);

      const controller = {
        overlay,
        dialog,
        player,

        open(card) {
          if (!card || !card.__videoSource) {
            return;
          }

          previousBodyOverflow = document.body.style.overflow || "";
          document.body.style.overflow = "hidden";
          this.overlay.style.display = "flex";

          this.player.pause();

          try {
            this.player.currentTime = 0;
          } catch {}

          this.player.removeAttribute("src");
          this.player.src = card.__videoSource;

          try {
            this.player.load();
          } catch {}

          const playPromise = this.player.play();

          if (playPromise && typeof playPromise.catch === "function") {
            playPromise.catch(() => {});
          }
        },

        stop() {
          this.close();
        },

        close() {
          this.player.pause();

          try {
            this.player.currentTime = 0;
          } catch {}

          if (document.fullscreenElement && document.exitFullscreen) {
            document.exitFullscreen().catch(() => {});
          }

          this.overlay.style.display = "none";
          this.player.removeAttribute("src");

          try {
            this.player.load();
          } catch {}

          document.body.style.overflow = previousBodyOverflow;
        }
      };

      closeBtn.onclick = (event) => {
        event.preventDefault();
        event.stopPropagation();
        controller.close();
      };

      overlay.addEventListener("click", (event) => {
        if (event.target === overlay) {
          controller.close();
        }
      });

      dialog.addEventListener("click", (event) => {
        event.stopPropagation();
      });

      document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && overlay.style.display !== "none") {
          controller.close();
        }
      });

      player.addEventListener("ended", () => {
        if (document.fullscreenElement && document.exitFullscreen) {
          document.exitFullscreen().catch(() => {});
        }

        try {
          player.currentTime = 0;
        } catch {}
      });

      player.addEventListener("error", () => {
        console.error("DisplayVideo player error");
      });

      overlay.__closeBtn = closeBtn;

      applyDisplayVideoControllerDictionary(controller);

      window.__displayVideoController = controller;
      return controller;
    }

    function createCard(videoSource, index, controller) {
      const card = document.createElement("div");
      card.dataset.displayVideoCard = "1";

      const contentRow = document.createElement("div");

      Object.assign(contentRow.style, {
        display: "flex",
        alignItems: "center",
        gap: "12px",
        padding: "10px 14px",
        minHeight: FILE_CARD_MIN_HEIGHT + "px",
        boxSizing: "border-box",
        width: "100%%"
      });

      Object.assign(card.style, {
        width: FILE_CARD_WIDTH + "px",
        minWidth: FILE_CARD_WIDTH + "px",
        maxWidth: FILE_CARD_WIDTH + "px",
        minHeight: FILE_CARD_MIN_HEIGHT + "px",
        flex: "0 0 " + FILE_CARD_WIDTH + "px",
        position: "relative",
        overflow: "hidden",
        boxSizing: "border-box",
        border: "1px solid var(--input-shell-border)",
        borderRadius: "12px",
        background: "var(--input-shell-bg)",
        /*boxShadow: "var(--input-shell-shadow)",*/
        boxShadow: "none",
        cursor: "pointer",
        userSelect: "none",
        transition: "transform 120ms ease, background 120ms ease, box-shadow 120ms ease"
      });

      const icon = createVideoIcon();

      const label = document.createElement("div");
      label.textContent = extractFileName(videoSource, index);

      Object.assign(label.style, {
        flex: "1 1 auto",
        minWidth: "0",
        overflow: "hidden",
        textOverflow: "ellipsis",
        whiteSpace: "nowrap",
        color: "var(--bubble-assistant-text)",
        font: "600 14px system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        lineHeight: "20px"
      });

      const status = createStatusNode();

      card.__videoSource = videoSource;
      card.__videoIndex = index;
      card.__videoName = label.textContent;
      card.__labelNode = label;
      card.__status = status;
      card.__isHovered = false;

      applyDisplayVideoCardDictionary(card);

      card.addEventListener("mouseenter", () => {
        card.__isHovered = true;
        card.style.transform = "translateY(-1px)";
        applyCardVisualState(card);
      });

      card.addEventListener("mouseleave", () => {
        card.__isHovered = false;
        card.style.transform = "translateY(0)";
        applyCardVisualState(card);
      });

      card.addEventListener("click", () => {
        controller.open(card);
      });

      contentRow.appendChild(icon);
      contentRow.appendChild(label);
      contentRow.appendChild(status);

      card.appendChild(contentRow);

      applyCardVisualState(card);

      return card;
    }

    function attachDisplayVideoContext(root, pairIdValue) {
      root.dataset.pairId = String(pairIdValue);
      root.dataset.kind = "body-attached";
    }

    function getDisplayVideoContextFromTarget(target) {
      const element =
        target && target.nodeType === 1
          ? target
          : target && target.parentElement
            ? target.parentElement
            : null;

      const root = element
        ? element.closest('[data-kind="body-attached"][data-pair-id]')
        : null;

      if (!root) {
        return null;
      }

      return {
        root,
        pairId: root.dataset.pairId,
        kind: root.dataset.kind
      };
    }

    function DisplayVideo(items, pairIdValue) {
      if (!Array.isArray(items) || !items.length) {
        return;
      }

      const response = ensureActiveResponse(pairIdValue);
      const controller = ensureVideoController();

      const gallery = document.createElement("div");

      attachDisplayVideoContext(gallery, pairIdValue);

      Object.assign(gallery.style, {
        display: "flex",
        flexDirection: "row",
        flexWrap: "wrap",
        justifyContent: "flex-start",
        alignItems: "flex-start",
        alignContent: "flex-start",
        gap: "12px",
        margin: "1rem 0",
        width: "100%%",
        boxSizing: "border-box"
      });

      items
        .filter((x) => typeof x === "string" && x.trim() !== "")
        .forEach((videoSource, index) => {
          gallery.appendChild(createCard(videoSource.trim(), index, controller));
        });

      if (!gallery.childElementCount) {
        return;
      }

      response.appendChild(gallery);
    }

    if (!window.__displayVideoI18nBound) {
      window.__displayVideoI18nBound = true;

      window.addEventListener(DISPLAY_VIDEO_I18N_EVENT, function () {
        applyDisplayVideoDictionary();
      });
    }

    applyDisplayVideoDictionary();

    window.DisplayVideo = DisplayVideo;
    window.getDisplayVideoContextFromTarget = getDisplayVideoContextFromTarget;

    window.StopVideo = function() {
      if (
        window.__displayVideoController &&
        typeof window.__displayVideoController.stop === "function"
      ) {
        window.__displayVideoController.stop();
      }
    };

    DisplayVideo(videos, pairId);
  } catch (e) {
    console.error("DisplayVideo error:", e);

    try {
      let mount = document.getElementById("ResponseContent");

      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      const dbg = document.createElement("div");
      dbg.textContent = translateDisplayVideoText(
        "displayVideo.debug.error",
        "Erreur DisplayVideo : {error}",
        { error: String(e) }
      );

      Object.assign(dbg.style, {
        color: "#ff8080",
        padding: "8px 12px",
        margin: "8px 0",
        border: "1px solid #ff8080",
        borderRadius: "8px",
        font: "12px system-ui, sans-serif"
      });

      mount.appendChild(dbg);
    } catch {}
  }
})();
