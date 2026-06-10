(() => {

  function translateDisplayAudioText(key, fallback, vars) {
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
    const audios = %s;
    const pairId = %s;

    const FILE_CARD_WIDTH = 300;
    const FILE_CARD_MIN_HEIGHT = 60;

    const DATA_URI_EXTENSION_BY_MIME = {
      "audio/mpeg": "mp3",
      "audio/mp3": "mp3",
      "audio/wav": "wav",
      "audio/wave": "wav",
      "audio/x-wav": "wav",
      "audio/ogg": "ogg",
      "audio/webm": "webm",
      "audio/mp4": "m4a",
      "audio/x-m4a": "m4a",
      "audio/aac": "aac",
      "audio/flac": "flac",
      "audio/x-flac": "flac"
    };

    const DISPLAY_AUDIO_I18N_EVENT =
      window.AppI18n && window.AppI18n.eventName
        ? window.AppI18n.eventName
        : "app:i18n:changed";

    const t = translateDisplayAudioText;

    function getDisplayAudioFallbackName(index) {
      return t("displayAudio.fallbackName", "Audio {index}", {
        index: (Number(index) || 0) + 1
      });
    }

    function getDisplayAudioFallbackNameWithExtension(index, ext) {
      return t("displayAudio.fallbackNameWithExtension", "Audio {index}.{ext}", {
        index: (Number(index) || 0) + 1,
        ext: String(ext || "audio")
      });
    }

    function getDisplayAudioStateText(state) {
      if (state === "loading") {
        return t("displayAudio.status.loading", "Loading");
      }

      if (state === "error") {
        return t("displayAudio.status.unavailable", "Unavailable");
      }

      if (state === "paused") {
        return t("displayAudio.status.pause", "Pause");
      }

      if (state === "playing") {
        return t("displayAudio.status.playing", "Playing");
      }

      return t("displayAudio.status.stop", "Stop");
    }

    function applyDisplayAudioCardDictionary(card) {
      if (!card) {
        return;
      }

      if (card.__labelNode) {
        card.__labelNode.textContent = extractFileName(card.__audioSource, card.__audioIndex);
      }

      if (card.__status) {
        const state = card.dataset.audioState || "stopped";
        card.__status.textContent = getDisplayAudioStateText(state);
      }
    }

    function applyDisplayAudioDictionary() {
      const cards = document.querySelectorAll('[data-display-audio-card="1"]');

      cards.forEach(function (card) {
        applyDisplayAudioCardDictionary(card);
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

    function ensureAudioPlayer() {
      let player = document.getElementById("display-audio-player");

      if (player) {
        return player;
      }

      player = document.createElement("audio");
      player.id = "display-audio-player";
      player.preload = "metadata";
      player.style.display = "none";
      player.__currentSource = null;
      document.body.appendChild(player);

      return player;
    }

    function guessDataUriExtension(value) {
      const match = /^data:([^;,]+)[;,]/i.exec(value || "");

      if (!match) {
        return "audio";
      }

      const mime = String(match[1] || "").toLowerCase();
      return DATA_URI_EXTENSION_BY_MIME[mime] || mime.split("/").pop() || "audio";
    }

    function extractFileName(value, index) {
      const source = String(value || "").trim();

      if (!source) {
        return getDisplayAudioFallbackName(index);
      }

      if (/^data:/i.test(source)) {
        return getDisplayAudioFallbackNameWithExtension(
          index,
          guessDataUriExtension(source)
        );
      }

      let normalized = source.replace(/\\/g, "/");
      normalized = normalized.split("#")[0].split("?")[0];

      const lastSlash = normalized.lastIndexOf("/");
      const fileName = lastSlash >= 0 ? normalized.slice(lastSlash + 1) : normalized;

      if (!fileName) {
        return getDisplayAudioFallbackName(index);
      }

      try {
        return decodeURIComponent(fileName);
      } catch {
        return fileName;
      }
    }

    function createAudioIcon() {
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

      const glyph = document.createElement("span");
      glyph.textContent = "\uE15D";

      Object.assign(glyph.style, {
        color: "var(--input-chip-text)",
        fontFamily: '"Segoe MDL2 Assets", "Segoe Fluent Icons", system-ui, sans-serif',
        fontSize: "18px",
        lineHeight: "1",
        display: "block"
      });

      iconWrap.appendChild(glyph);

      return iconWrap;
    }

    function createStatusNode() {
      const status = document.createElement("div");
      status.textContent = getDisplayAudioStateText("stopped");

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

    function createProgressNode() {
      const wrap = document.createElement("div");

      Object.assign(wrap.style, {
        position: "absolute",
        left: "0",
        bottom: "0",
        width: "100%%",
        height: "4px",
        background: "var(--input-chip-bg)",
        opacity: "0",
        transition: "opacity 120ms ease",
        pointerEvents: "none",
        cursor: "pointer",
        boxSizing: "border-box"
      });

      const fill = document.createElement("div");

      Object.assign(fill.style, {
        width: "0%%",
        height: "100%%",
        background: "var(--input-chip-text)",
        transition: "width 80ms linear"
      });

      wrap.appendChild(fill);

      return { wrap, fill };
    }

    function updateCardProgress(card, ratio) {
      if (!card || !card.__progressFill) {
        return;
      }

      const safeRatio = Number.isFinite(ratio) ? ratio : 0;
      const clampedRatio = Math.max(0, Math.min(1, safeRatio));

      card.__progressFill.style.width = (clampedRatio * 100) + "%%";
    }

    function getProgressRatioFromClientX(progressWrap, clientX) {
      if (!progressWrap) {
        return 0;
      }

      const rect = progressWrap.getBoundingClientRect();

      if (!rect || rect.width <= 0) {
        return 0;
      }

      const x = clientX - rect.left;
      const ratio = x / rect.width;

      return Math.max(0, Math.min(1, ratio));
    }

    function applyCardVisualState(card, state) {
      const hovered = !!card.__isHovered;
      const status = card.__status;
      const progressWrap = card.__progressWrap;

      card.style.background = hovered
        ? "var(--input-shell-bg-hover)"
        : "var(--input-shell-bg)";
      card.style.borderColor = "var(--input-shell-border)";
      /*card.style.boxShadow = "var(--input-shell-shadow)";*/
      card.style.boxShadow = "none";
      status.style.background = "var(--input-chip-bg)";
      status.style.color = "var(--input-chip-text)";

      if (progressWrap) {
        const canSeek = (state === "playing" || state === "paused");
        progressWrap.style.opacity = canSeek ? "1" : "0";
        progressWrap.style.pointerEvents = canSeek ? "auto" : "none";
      }

      if (state === "playing") {
        card.style.background = "var(--input-shell-bg-hover)";
        card.style.boxShadow = "none";
      } else if (state === "paused") {
        card.style.background = hovered
          ? "var(--input-shell-bg-hover)"
          : "var(--input-shell-bg)";
        status.style.opacity = "0.92";
        return;
      } else if (state === "loading") {
        card.style.background = "var(--input-shell-bg-hover)";
        status.style.opacity = "0.92";
        return;
      } else if (state === "error") {
        status.style.background = "rgba(255,128,128,0.18)";
        status.style.color = "#ffb3b3";
      }

      status.style.opacity = "1";
    }

    function setCardState(card, state, text) {
      card.dataset.audioState = state;
      card.__status.textContent =
        text == null ? getDisplayAudioStateText(state) : text;
      applyCardVisualState(card, state);
    }

    function ensureAudioController() {
      if (window.__displayAudioController) {
        return window.__displayAudioController;
      }

      const player = ensureAudioPlayer();

      const controller = {
        player,
        currentCard: null,
        seekDragCard: null,

        clearCard(card) {
          if (!card) {
            return;
          }

          updateCardProgress(card, 0);
          setCardState(card, "stopped");
        },

        stop(resetSource) {
          this.player.pause();

          try {
            this.player.currentTime = 0;
          } catch {}

          if (this.currentCard) {
            this.clearCard(this.currentCard);
          }

          this.currentCard = null;

          if (resetSource) {
            this.player.removeAttribute("src");
            this.player.__currentSource = null;

            try {
              this.player.load();
            } catch {}
          }
        },

        play(card) {
          const source = card.__audioSource;

          if (!source) {
            return;
          }

          if (this.currentCard && this.currentCard !== card) {
            this.stop(false);
          }

          this.currentCard = card;

          updateCardProgress(card, 0);
          setCardState(card, "loading");

          this.player.pause();

          try {
            this.player.currentTime = 0;
          } catch {}

          if (this.player.__currentSource !== source) {
            this.player.__currentSource = source;
            this.player.src = source;

            try {
              this.player.load();
            } catch {}
          } else {
            try {
              this.player.currentTime = 0;
            } catch {}
          }

          const playPromise = this.player.play();

          if (playPromise && typeof playPromise.catch === "function") {
            playPromise.catch(() => {
              if (this.currentCard === card) {
                updateCardProgress(card, 0);
                setCardState(card, "error");
                this.currentCard = null;
              }
            });
          }
        },

        pause(card) {
          if (this.currentCard !== card) {
            return;
          }

          this.player.pause();
          setCardState(card, "paused");
        },

        seek(card, ratio) {
          if (!card || this.currentCard !== card) {
            return;
          }

          const safeRatio = Number.isFinite(ratio) ? ratio : 0;
          const clampedRatio = Math.max(0, Math.min(1, safeRatio));
          const duration = this.player.duration;

          if (!(duration > 0)) {
            return;
          }

          try {
            this.player.currentTime = duration * clampedRatio;
          } catch {}

          updateCardProgress(card, clampedRatio);
        },

        beginSeek(card, clientX) {
          if (!card || this.currentCard !== card || !card.__progressWrap) {
            return;
          }

          this.seekDragCard = card;
          this.seek(card, getProgressRatioFromClientX(card.__progressWrap, clientX));
        },

        moveSeek(clientX) {
          if (!this.seekDragCard || !this.seekDragCard.__progressWrap) {
            return;
          }

          this.seek(
            this.seekDragCard,
            getProgressRatioFromClientX(this.seekDragCard.__progressWrap, clientX)
          );
        },

        endSeek() {
          this.seekDragCard = null;
        },

        toggle(card) {
          if (!card) {
            return;
          }

          if (this.currentCard && this.currentCard !== card) {
            this.stop(false);
            this.play(card);
            return;
          }

          const state = card.dataset.audioState || "stopped";

          if (state === "playing") {
            this.pause(card);
            return;
          }

          if (state === "paused") {
            setCardState(card, "loading");

            const playPromise = this.player.play();

            if (playPromise && typeof playPromise.catch === "function") {
              playPromise.catch(() => {
                if (this.currentCard === card) {
                  setCardState(card, "error");
                  this.currentCard = null;
                }
              });
            }

            return;
          }

          this.play(card);
        }
      };

      player.addEventListener("playing", () => {
        if (!controller.currentCard) {
          return;
        }

        setCardState(controller.currentCard, "playing");
      });

      player.addEventListener("waiting", () => {
        if (!controller.currentCard) {
          return;
        }

        setCardState(controller.currentCard, "loading", "Loading");
      });

      player.addEventListener("pause", () => {
        if (!controller.currentCard) {
          return;
        }

        if (player.ended) {
          return;
        }

        const state = controller.currentCard.dataset.audioState || "";

        if (state === "playing") {
          setCardState(controller.currentCard, "paused");
        }
      });

      player.addEventListener("ended", () => {
        if (!controller.currentCard) {
          return;
        }

        controller.clearCard(controller.currentCard);
        controller.currentCard = null;
      });

      player.addEventListener("timeupdate", () => {
        if (!controller.currentCard) {
          return;
        }

        const duration = controller.player.duration;
        const currentTime = controller.player.currentTime;
        const ratio = duration > 0 ? currentTime / duration : 0;

        updateCardProgress(controller.currentCard, ratio);
      });

      player.addEventListener("error", () => {
        if (!controller.currentCard) {
          return;
        }

        updateCardProgress(controller.currentCard, 0);
        setCardState(controller.currentCard, "error");
        controller.currentCard = null;
      });

      window.addEventListener("mousemove", (event) => {
        controller.moveSeek(event.clientX);
      });

      window.addEventListener("mouseup", () => {
        controller.endSeek();
      });

      window.__displayAudioController = controller;

      return controller;
    }

    function createCard(audioSource, index, controller) {
      const card = document.createElement("div");
      card.dataset.displayAudioCard = "1";

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
        boxShadow: "none",
        cursor: "pointer",
        userSelect: "none",
        transition: "transform 120ms ease, background 120ms ease, box-shadow 120ms ease"
      });

      const icon = createAudioIcon();

      const label = document.createElement("div");
      label.textContent = extractFileName(audioSource, index);

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
      const progress = createProgressNode();

      card.__audioSource = audioSource;
      card.__audioIndex = index;
      card.__labelNode = label;
      card.__status = status;
      card.__progressWrap = progress.wrap;
      card.__progressFill = progress.fill;
      card.__isHovered = false;

      card.addEventListener("mouseenter", () => {
        card.__isHovered = true;
        card.style.transform = "translateY(-1px)";
        applyCardVisualState(card, card.dataset.audioState || "stopped");
      });

      card.addEventListener("mouseleave", () => {
        card.__isHovered = false;
        card.style.transform = "translateY(0)";
        applyCardVisualState(card, card.dataset.audioState || "stopped");
      });

      card.addEventListener("click", () => {
        controller.toggle(card);
      });

      progress.wrap.addEventListener("mousedown", (event) => {
        event.preventDefault();
        event.stopPropagation();
        controller.beginSeek(card, event.clientX);
      });

      progress.wrap.addEventListener("click", (event) => {
        event.preventDefault();
        event.stopPropagation();
      });

      contentRow.appendChild(icon);
      contentRow.appendChild(label);
      contentRow.appendChild(status);

      card.appendChild(contentRow);
      card.appendChild(progress.wrap);

      updateCardProgress(card, 0);
      setCardState(card, "stopped");
      applyDisplayAudioCardDictionary(card);

      return card;
    }

    function attachDisplayAudioContext(root, pairIdValue) {
      root.dataset.pairId = String(pairIdValue);
      root.dataset.kind = "body-attached";
    }

    function getDisplayAudioContextFromTarget(target) {
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

    function DisplayAudio(items, pairIdValue) {
      if (!Array.isArray(items) || !items.length) {
        return;
      }

      const response = ensureActiveResponse(pairIdValue);
      const controller = ensureAudioController();

      const gallery = document.createElement("div");

      attachDisplayAudioContext(gallery, pairIdValue);

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
        .forEach((audioSource, index) => {
          gallery.appendChild(createCard(audioSource.trim(), index, controller));
        });

      if (!gallery.childElementCount) {
        return;
      }

      response.appendChild(gallery);
    }

    if (!window.__displayAudioI18nBound) {
      window.__displayAudioI18nBound = true;

      window.addEventListener(DISPLAY_AUDIO_I18N_EVENT, function () {
        applyDisplayAudioDictionary();
      });
    }

    applyDisplayAudioDictionary();

    window.DisplayAudio = DisplayAudio;
    window.getDisplayAudioContextFromTarget = getDisplayAudioContextFromTarget;

    window.StopAudio = function() {
      if (!window.__displayAudioController) {
        return;
      }

      window.__displayAudioController.stop(true);
    };

    DisplayAudio(audios, pairId);
  } catch (e) {
    console.error("DisplayAudio error:", e);

    try {
      let mount = document.getElementById("ResponseContent");

      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      const dbg = document.createElement("div");
      dbg.textContent = translateDisplayAudioText(
        "displayAudio.debug.error",
        "Erreur DisplayAudio : {error}",
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
