(() => {

  function translateDisplayImageText(key, fallback, vars) {
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
    const images = %s;
    const images_align = "%s";
    const pairId = %s;

    const MAX_IMAGES = 9;

    const THUMB_WIDTH = 355;
    const THUMB_HEIGHT = 200;
    const RIGHT_THUMB_WIDTH = 120;
    const RIGHT_THUMB_HEIGHT = Math.max(
      1,
      Math.round(THUMB_HEIGHT * (RIGHT_THUMB_WIDTH / THUMB_WIDTH))
    );

    const resolvedImagesAlign = images_align === "Right" ? "Right" : "Left";

    const DISPLAY_IMAGE_I18N_EVENT =
      window.AppI18n && window.AppI18n.eventName
        ? window.AppI18n.eventName
        : "app:i18n:changed";

    const t = translateDisplayImageText;

    function getDisplayImageAlt(index) {
      return t("displayImage.alt.imageIndex", "Image {index}", {
        index: (Number(index) || 0) + 1
      });
    }

    function getDisplayImageUnavailableText() {
      return t("displayImage.error.unavailable", "Image indisponible");
    }

    function applyDisplayImageViewerDictionary(overlay) {
      if (!overlay) {
        return;
      }

      if (overlay.__closeBtn) {
        overlay.__closeBtn.setAttribute(
          "aria-label",
          t("displayImage.action.close", "Fermer")
        );
      }
    }

    function applyDisplayImageCardDictionary(card) {
      if (!card) {
        return;
      }

      if (card.__imgNode) {
        card.__imgNode.alt = getDisplayImageAlt(card.__imageIndex);
      }

      if (card.__errorNode) {
        card.__errorNode.textContent = getDisplayImageUnavailableText();
      }
    }

    function applyDisplayImageDictionary() {
      const viewer = document.getElementById("display-image-viewer");
      if (viewer) {
        applyDisplayImageViewerDictionary(viewer);
      }

      const cards = document.querySelectorAll('[data-display-image-card="1"]');
      cards.forEach(function (card) {
        applyDisplayImageCardDictionary(card);
      });
    }

    function isRightAligned() {
      return resolvedImagesAlign === "Right";
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

    function ensureRightAlignedDisplayImagesBlock(pairIdValue) {
      const mount = ensureMount();
      const displayPairId = String(pairIdValue);

      let block = null;

      for (const node of mount.children) {
        if (
          node.nodeType === 1 &&
          node.dataset &&
          node.dataset.kind === "display-images-right" &&
          node.dataset.pairId === displayPairId
        ) {
          block = node;
          break;
        }
      }

      if (!block) {
        block = document.createElement("div");
        block.className = "display-images-right-block";
        block.dataset.kind = "display-images-right";
        block.dataset.pairId = displayPairId;
        mount.appendChild(block);
      }

      return block;
    }

    function removeRightAlignedDisplayImagesBlock(pairIdValue) {
      const mount = ensureMount();
      const displayPairId = String(pairIdValue);

      for (const node of mount.children) {
        if (
          node.nodeType === 1 &&
          node.dataset &&
          node.dataset.kind === "display-images-right" &&
          node.dataset.pairId === displayPairId
        ) {
          node.remove();
          break;
        }
      }
    }

    function ensureViewer() {
      let overlay = document.getElementById("display-image-viewer");
      if (overlay) {
        applyDisplayImageViewerDictionary(overlay);
        return overlay;
      }

      let viewerStyle = document.getElementById("display-image-viewer-style");
      if (!viewerStyle) {
        viewerStyle = document.createElement("style");
        viewerStyle.id = "display-image-viewer-style";
        viewerStyle.textContent = `
            #display-image-viewer-viewport {
              scrollbar-width: thin;
              scrollbar-color: var(--scrollbar-thumb) transparent;
            }

            #display-image-viewer-viewport::-webkit-scrollbar {
              width: 12px;
              height: 12px;
            }

            #display-image-viewer-viewport::-webkit-scrollbar-track {
              background: transparent;
            }

            #display-image-viewer-viewport::-webkit-scrollbar-thumb {
              background: var(--scrollbar-thumb);
              border-radius: 999px;
              border: 3px solid transparent;
              background-clip: padding-box;
            }

            #display-image-viewer-viewport::-webkit-scrollbar-thumb:hover {
              background: var(--scrollbar-thumb-hover);
              border-radius: 999px;
              border: 3px solid transparent;
              background-clip: padding-box;
            }
        `;
        (document.head || document.documentElement).appendChild(viewerStyle);
      }

      overlay = document.createElement("div");
      overlay.id = "display-image-viewer";

      Object.assign(overlay.style, {
        position: "fixed",
        inset: "0",
        display: "none",
        alignItems: "center",
        justifyContent: "center",
        background: "rgba(0,0,0,0.24)",
        backdropFilter: "blur(12px)",
        WebkitBackdropFilter: "blur(12px)",
        zIndex: "2147483647"
      });

      const closeBtn = document.createElement("button");
      closeBtn.type = "button";
      closeBtn.setAttribute(
        "aria-label",
        t("displayImage.action.close", "Fermer")
      );

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
        background: "var(--image-hover-overlay)",
        backdropFilter: "blur(6px)",
        WebkitBackdropFilter: "blur(6px)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "0",
        fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        fontSize: "28px",
        lineHeight: "1"
      });

      const closeIcon = document.createElement("span");
      closeIcon.textContent = "×";

      Object.assign(closeIcon.style, {
        display: "block",
        lineHeight: "1",
        transform: "translateY(-2px)"
      });

      closeBtn.appendChild(closeIcon);

      const viewport = document.createElement("div");
      viewport.id = "display-image-viewer-viewport";

      Object.assign(viewport.style, {
        position: "relative",
        width: "86vw",
        height: "86vh",
        overflow: "auto",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "20px",
        boxSizing: "border-box"
      });

      const img = document.createElement("img");
      img.alt = "";
      img.draggable = false;

      Object.assign(img.style, {
        display: "block",
        userSelect: "none",
        WebkitUserDrag: "none",
        width: "auto",
        height: "auto",
        maxWidth: "none",
        maxHeight: "none",
        objectFit: "contain",
        flex: "0 0 auto",
        borderRadius: "12px",
        boxShadow: "none"
      });

      const zoomState = {
        scale: 1,
        minScale: 0.25,
        maxScale: 6,
        step: 0.20,
        fitWidth: 0,
        fitHeight: 0
      };

      const panState = {
        active: false,
        moved: false,
        startX: 0,
        startY: 0,
        startScrollLeft: 0,
        startScrollTop: 0
      };

      const focusState = {
        previouslyFocused: null
      };

      function clamp(value, min, max) {
        return Math.min(Math.max(value, min), max);
      }

      function computeFitSize() {
        if (!img.naturalWidth || !img.naturalHeight) {
          return;
        }

        const availableWidth = Math.max(1, viewport.clientWidth - 40);
        const availableHeight = Math.max(1, viewport.clientHeight - 40);
        const ratio = Math.min(
          availableWidth / img.naturalWidth,
          availableHeight / img.naturalHeight,
          1
        );

        zoomState.fitWidth = Math.max(1, Math.round(img.naturalWidth * ratio));
        zoomState.fitHeight = Math.max(1, Math.round(img.naturalHeight * ratio));
      }

      function applyZoom() {
        if (!zoomState.fitWidth || !zoomState.fitHeight) {
          return;
        }

        img.style.width = Math.round(zoomState.fitWidth * zoomState.scale) + "px";
        img.style.height = Math.round(zoomState.fitHeight * zoomState.scale) + "px";

        syncViewportAlignment();
      }

      function syncViewportAlignment() {
        if (!zoomState.fitWidth || !zoomState.fitHeight) {
          viewport.style.justifyContent = "center";
          viewport.style.alignItems = "center";
          return;
        }

        const renderedWidth = Math.round(zoomState.fitWidth * zoomState.scale);
        const renderedHeight = Math.round(zoomState.fitHeight * zoomState.scale);

        const availableWidth = Math.max(1, viewport.clientWidth - 40);
        const availableHeight = Math.max(1, viewport.clientHeight - 40);

        viewport.style.justifyContent =
          renderedWidth > availableWidth ? "flex-start" : "center";

        viewport.style.alignItems =
          renderedHeight > availableHeight ? "flex-start" : "center";
      }

      function canPan() {
        return (
          viewport.scrollWidth > viewport.clientWidth ||
          viewport.scrollHeight > viewport.clientHeight
        );
      }

      function syncPanCursor() {
        img.style.cursor = canPan()
          ? (panState.active ? "grabbing" : "grab")
          : "default";
      }

      function startPan(ev) {
        if (ev.button !== 0) {
          return;
        }

        if (overlay.style.display === "none") {
          return;
        }

        if (!canPan()) {
          return;
        }

        panState.active = true;
        panState.moved = false;
        panState.startX = ev.clientX;
        panState.startY = ev.clientY;
        panState.startScrollLeft = viewport.scrollLeft;
        panState.startScrollTop = viewport.scrollTop;

        ev.preventDefault();
        syncPanCursor();
      }

      function movePan(ev) {
        if (!panState.active) {
          return;
        }

        const deltaX = ev.clientX - panState.startX;
        const deltaY = ev.clientY - panState.startY;

        if (Math.abs(deltaX) > 3 || Math.abs(deltaY) > 3) {
          panState.moved = true;
        }

        viewport.scrollLeft = panState.startScrollLeft - deltaX;
        viewport.scrollTop = panState.startScrollTop - deltaY;

        ev.preventDefault();
      }

      function stopPan() {
        if (!panState.active) {
          return;
        }

        panState.active = false;
        syncPanCursor();
      }

      function cancelClickAfterPan(ev) {
        if (!panState.moved) {
          return false;
        }

        panState.moved = false;
        ev.preventDefault();
        ev.stopPropagation();
        return true;
      }

      function setScale(nextScale, anchorClientX, anchorClientY) {
        if (!zoomState.fitWidth || !zoomState.fitHeight) {
          return;
        }

        const clampedScale = clamp(nextScale, zoomState.minScale, zoomState.maxScale);
        if (clampedScale === zoomState.scale) {
          return;
        }

        const viewportRect = viewport.getBoundingClientRect();
        const imgRectBefore = img.getBoundingClientRect();

        let useMouseAnchor = false;

        let focusClientX = viewportRect.left + viewport.clientWidth / 2;
        let focusClientY = viewportRect.top + viewport.clientHeight / 2;

        let viewportRatioX = viewport.scrollWidth
          ? (viewport.scrollLeft + viewport.clientWidth / 2) / viewport.scrollWidth
          : 0.5;
        let viewportRatioY = viewport.scrollHeight
          ? (viewport.scrollTop + viewport.clientHeight / 2) / viewport.scrollHeight
          : 0.5;

        let imageRatioX = 0.5;
        let imageRatioY = 0.5;

        const hasAnchor =
          typeof anchorClientX === "number" &&
          typeof anchorClientY === "number";

        if (
          hasAnchor &&
          imgRectBefore.width > 0 &&
          imgRectBefore.height > 0 &&
          anchorClientX >= imgRectBefore.left &&
          anchorClientX <= imgRectBefore.right &&
          anchorClientY >= imgRectBefore.top &&
          anchorClientY <= imgRectBefore.bottom
        ) {
          useMouseAnchor = true;
          focusClientX = anchorClientX;
          focusClientY = anchorClientY;
          imageRatioX = (anchorClientX - imgRectBefore.left) / imgRectBefore.width;
          imageRatioY = (anchorClientY - imgRectBefore.top) / imgRectBefore.height;
        }

        zoomState.scale = clampedScale;
        applyZoom();

        requestAnimationFrame(() => {
          if (useMouseAnchor) {
            const imgRectAfter = img.getBoundingClientRect();

            const afterFocusX = imgRectAfter.left + imgRectAfter.width * imageRatioX;
            const afterFocusY = imgRectAfter.top + imgRectAfter.height * imageRatioY;

            viewport.scrollLeft += afterFocusX - focusClientX;
            viewport.scrollTop += afterFocusY - focusClientY;
          } else {
            viewport.scrollLeft = Math.max(
              0,
              viewport.scrollWidth * viewportRatioX - viewport.clientWidth / 2
            );
            viewport.scrollTop = Math.max(
              0,
              viewport.scrollHeight * viewportRatioY - viewport.clientHeight / 2
            );
          }

          syncPanCursor();
        });
      }

      function resetZoom() {
        zoomState.scale = 1;
        computeFitSize();
        applyZoom();

        requestAnimationFrame(() => {
          viewport.scrollLeft = Math.max(
            0,
            (viewport.scrollWidth - viewport.clientWidth) / 2
          );
          viewport.scrollTop = Math.max(
            0,
            (viewport.scrollHeight - viewport.clientHeight) / 2
          );
          syncPanCursor();
        });
      }

      function zoomIn(anchorClientX, anchorClientY) {
        setScale(zoomState.scale + zoomState.step, anchorClientX, anchorClientY);
      }

      function zoomOut(anchorClientX, anchorClientY) {
        setScale(zoomState.scale - zoomState.step, anchorClientX, anchorClientY);
      }

      function clearViewer() {
        stopPan();
        panState.moved = false;

        zoomState.scale = 1;
        zoomState.fitWidth = 0;
        zoomState.fitHeight = 0;
        viewport.scrollLeft = 0;
        viewport.scrollTop = 0;
        viewport.style.justifyContent = "center";
        viewport.style.alignItems = "center";
        img.style.width = "auto";
        img.style.height = "auto";
        img.style.cursor = "default";
      }

      function closeViewer() {
        const active = document.activeElement;

        if (active && overlay.contains(active) && active instanceof HTMLElement) {
          active.blur();
        }

        overlay.style.display = "none";
        overlay.setAttribute("aria-hidden", "true");
        img.removeAttribute("src");
        clearViewer();

        if (overlay.dataset.prevOverflow !== undefined) {
          document.documentElement.style.overflow = overlay.dataset.prevOverflow;
          delete overlay.dataset.prevOverflow;
        }

        if (
          focusState.previouslyFocused &&
          focusState.previouslyFocused instanceof HTMLElement &&
          document.contains(focusState.previouslyFocused)
        ) {
          focusState.previouslyFocused.focus();
        }

        focusState.previouslyFocused = null;
      }

      function openViewer(src, alt) {
        focusState.previouslyFocused =
          document.activeElement && document.activeElement instanceof HTMLElement
            ? document.activeElement
            : null;

        overlay.dataset.prevOverflow = document.documentElement.style.overflow || "";
        document.documentElement.style.overflow = "hidden";

        overlay.style.display = "flex";
        overlay.setAttribute("aria-hidden", "false");
        img.alt = alt || "";
        img.src = src;

        closeBtn.focus();

        if (img.complete && img.naturalWidth) {
          resetZoom();
        }
      }

      img.onload = resetZoom;
      closeBtn.onclick = closeViewer;

      overlay.addEventListener("click", (ev) => {
        if (cancelClickAfterPan(ev)) {
          return;
        }

        if (ev.target === overlay) {
          closeViewer();
        }
      });

      img.addEventListener("dragstart", (ev) => {
        ev.preventDefault();
      });

      img.addEventListener("mousedown", startPan);
      document.addEventListener("mousemove", movePan);
      document.addEventListener("mouseup", stopPan);

      window.addEventListener("blur", () => {
        stopPan();
      });

      viewport.addEventListener("click", (ev) => {
        if (cancelClickAfterPan(ev)) {
          return;
        }

        if (ev.target !== viewport) {
          return;
        }

        const rect = viewport.getBoundingClientRect();
        const insideContentX = ev.clientX <= rect.left + viewport.clientWidth;
        const insideContentY = ev.clientY <= rect.top + viewport.clientHeight;

        if (!insideContentX || !insideContentY) {
          return;
        }

        closeViewer();
      });

      viewport.addEventListener(
        "wheel",
        (ev) => {
          if (overlay.style.display === "none") {
            return;
          }

          ev.preventDefault();

          if (ev.deltaY < 0) {
            zoomIn(ev.clientX, ev.clientY);
          } else {
            zoomOut(ev.clientX, ev.clientY);
          }
        },
        { passive: false }
      );

      document.addEventListener("keydown", (ev) => {
        if (overlay.style.display === "none") {
          return;
        }

        if (ev.key === "Escape") {
          closeViewer();
          return;
        }

        if (!ev.ctrlKey) {
          return;
        }

        const zoomInKey =
          ev.key === "+" ||
          ev.key === "=" ||
          ev.code === "NumpadAdd";

        const zoomOutKey =
          ev.key === "-" ||
          ev.key === "_" ||
          ev.code === "NumpadSubtract";

        if (zoomInKey) {
          ev.preventDefault();
          zoomIn();
          return;
        }

        if (zoomOutKey) {
          ev.preventDefault();
          zoomOut();
        }
      });

      overlay.__open = openViewer;
      overlay.__closeBtn = closeBtn;
      overlay.__imageNode = img;

      viewport.appendChild(img);
      overlay.appendChild(closeBtn);
      overlay.appendChild(viewport);
      document.body.appendChild(overlay);

      applyDisplayImageViewerDictionary(overlay);

      return overlay;
    }

    function createErrorNode() {
      const error = document.createElement("div");
      error.textContent = getDisplayImageUnavailableText();

      const errorWidth = isRightAligned() ? RIGHT_THUMB_WIDTH : THUMB_WIDTH;
      const errorHeight = isRightAligned() ? RIGHT_THUMB_HEIGHT : THUMB_HEIGHT;

      Object.assign(error.style, {
        width: errorWidth + "px",
        height: errorHeight + "px",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        color: "#ffffff",
        font: "12px system-ui, -apple-system, Segoe UI, Roboto, sans-serif",
        textAlign: "center",
        padding: "12px",
        boxSizing: "border-box"
      });

      return error;
    }

    function applyThumbLayout(card, thumb, img) {
      if (isRightAligned()) {
        const renderWidth = RIGHT_THUMB_WIDTH;
        const renderHeight = Math.max(
          1,
          Math.round(img.naturalHeight * (renderWidth / img.naturalWidth))
        );

        Object.assign(card.style, {
          width: renderWidth + "px"
        });

        Object.assign(thumb.style, {
          width: renderWidth + "px",
          height: renderHeight + "px",
          alignItems: "flex-start",
          justifyContent: "flex-start"
        });

        Object.assign(img.style, {
          width: renderWidth + "px",
          height: renderHeight + "px",
          maxWidth: "none",
          maxHeight: "none"
        });

        return;
      }

      const useNaturalSize =
        img.naturalWidth < THUMB_WIDTH &&
        img.naturalHeight < THUMB_HEIGHT;

      let renderWidth;
      let renderHeight;

      if (useNaturalSize) {
        renderWidth = img.naturalWidth;
        renderHeight = img.naturalHeight;
      } else {
        const ratio = THUMB_HEIGHT / img.naturalHeight;
        renderWidth = Math.round(img.naturalWidth * ratio);
        renderHeight = THUMB_HEIGHT;
      }

      Object.assign(card.style, {
        width: renderWidth + "px"
      });

      Object.assign(thumb.style, {
        width: renderWidth + "px",
        height: renderHeight + "px",
        alignItems: "flex-start",
        justifyContent: "flex-start"
      });

      Object.assign(img.style, {
        width: renderWidth + "px",
        height: renderHeight + "px",
        maxWidth: "none",
        maxHeight: "none"
      });
    }

    function createCard(src, index, viewer) {
      const card = document.createElement("div");
      card.dataset.displayImageCard = "1";

      Object.assign(card.style, {
        display: "inline-flex",
        flexDirection: "column",
        border: "2px solid var(--code-border)",
        borderRadius: "12px",
        overflow: "hidden",
        background: "transparent",
        boxShadow: "none",
        cursor: "pointer",
        transition: "transform 120ms ease, box-shadow 120ms ease"
      });

      card.addEventListener("mouseenter", () => {
        overlay.style.opacity = "1";
      });

      card.addEventListener("mouseleave", () => {
        overlay.style.opacity = "0";
      });

      const thumb = document.createElement("div");

      Object.assign(thumb.style, {
        position: "relative",
        overflow: "hidden",
        background: "transparent",
        cursor: "pointer",
        display: "flex",
        alignItems: "flex-start",
        justifyContent: "flex-start"
      });

      const overlay = document.createElement("div");

      Object.assign(overlay.style, {
        position: "absolute",
        inset: "0",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "rgba(0,0,0,0.35)",
        opacity: "0",
        transition: "opacity 120ms ease",
        pointerEvents: "none"
      });

      const svgNS = "http://www.w3.org/2000/svg";
      const icon = document.createElementNS(svgNS, "svg");

      icon.setAttribute("width", "28");
      icon.setAttribute("height", "28");
      icon.setAttribute("viewBox", "0 0 24 24");
      icon.setAttribute("fill", "none");

      const circle = document.createElementNS(svgNS, "circle");
      circle.setAttribute("cx", "11");
      circle.setAttribute("cy", "11");
      circle.setAttribute("r", "7");
      circle.setAttribute("stroke", "var(--image-hover-icon)");
      circle.setAttribute("stroke-width", "2");

      const line = document.createElementNS(svgNS, "line");
      line.setAttribute("x1", "16.65");
      line.setAttribute("y1", "16.65");
      line.setAttribute("x2", "21");
      line.setAttribute("y2", "21");
      line.setAttribute("stroke", "var(--image-hover-icon)");
      line.setAttribute("stroke-width", "2");
      line.setAttribute("stroke-linecap", "round");

      icon.appendChild(circle);
      icon.appendChild(line);
      overlay.appendChild(icon);

      const img = document.createElement("img");
      img.alt = getDisplayImageAlt(index);
      img.loading = "lazy";
      img.decoding = "async";

      Object.assign(img.style, {
        display: "block",
        userSelect: "none",
        WebkitUserDrag: "none"
      });

      card.__imageIndex = index;
      card.__imgNode = img;
      card.__errorNode = null;

      img.onload = () => {
        applyThumbLayout(card, thumb, img);
      };

      img.onerror = () => {
        thumb.innerHTML = "";
        thumb.style.cursor = "default";
        thumb.onclick = null;

        const errorNode = createErrorNode();
        thumb.appendChild(errorNode);
        card.__errorNode = errorNode;

        applyDisplayImageCardDictionary(card);

        Object.assign(card.style, {
          width: (isRightAligned() ? RIGHT_THUMB_WIDTH : THUMB_WIDTH) + "px"
        });
      };

      thumb.onclick = () => {
        viewer.__open(src, img.alt);
      };

      thumb.appendChild(img);
      thumb.appendChild(overlay);
      card.appendChild(thumb);

      applyDisplayImageCardDictionary(card);

      img.src = src;

      return card;
    }

    function attachDisplayImageContext(root, pairIdValue) {
      root.dataset.pairId = String(pairIdValue);
      root.dataset.kind = isRightAligned() ? "attached" : "body-attached";
    }

    function getDisplayImageContextFromTarget(target) {
      const element =
        target && target.nodeType === 1
          ? target
          : target && target.parentElement
            ? target.parentElement
            : null;

      const root = element
        ? element.closest('[data-kind="attached"][data-pair-id], [data-kind="body-attached"][data-pair-id]')
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

    function displayImages(items, pairIdValue) {
      const renderableItems = Array.isArray(items)
        ? items.filter((x) => typeof x === "string" && x.trim() !== "")
        : [];

      if (!renderableItems.length) {
        return;
      }

      const useDedicatedBlock = isRightAligned();

      const response = useDedicatedBlock
        ? ensureRightAlignedDisplayImagesBlock(pairIdValue)
        : ensureActiveResponse(pairIdValue);

      if (useDedicatedBlock) {
        response.replaceChildren();
      }

      const viewer = ensureViewer();
      const gallery = document.createElement("div");

      attachDisplayImageContext(gallery, pairIdValue);

      Object.assign(
        gallery.style,
        useDedicatedBlock
          ? {
              display: "flex",
              flexDirection: "column",
              alignItems: "flex-end",
              gap: "12px",
              margin: "1rem 0",
              width: "100%%",
              boxSizing: "border-box"
            }
          : {
              display: "flex",
              flexWrap: "wrap",
              alignItems: "flex-start",
              gap: "12px",
              margin: "1rem 0"
            }
      );

      renderableItems
        .slice(0, MAX_IMAGES)
        .forEach((src, index) => {
          gallery.appendChild(createCard(src, index, viewer));
        });

      if (!gallery.childElementCount) {
        return;
      }

      response.appendChild(gallery);
    }

    if (!window.__displayImageI18nBound) {
      window.__displayImageI18nBound = true;

      window.addEventListener(DISPLAY_IMAGE_I18N_EVENT, function () {
        applyDisplayImageDictionary();
      });
    }

    applyDisplayImageDictionary();

    window.getDisplayImageContextFromTarget = getDisplayImageContextFromTarget;

    displayImages(images, pairId);
  } catch (e) {
    console.error("DisplayImages error:", e);

    try {
      let mount = document.getElementById("ResponseContent");
      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      const dbg = document.createElement("div");
      dbg.textContent = translateDisplayImageText(
        "displayImage.debug.error",
        "Erreur DisplayImages : {error}",
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
