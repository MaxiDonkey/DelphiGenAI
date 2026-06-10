(() => {
  try {
    const text = %s;
    const pairId = %s;
    const fontSize = %d;
    const textColor = %s;

    const DEFAULT_FONT_SIZE_PX = 16;
    const DEFAULT_TEXT_COLOR = "var(--bubble-assistant-text)";

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

    function attachDisplayTextContext(root, pairIdValue) {
      root.dataset.pairId = String(pairIdValue == null ? "" : pairIdValue);
      root.dataset.kind = "body-attached";
    }

    function getDisplayTextContextFromTarget(target) {
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

    function normalizeFontSize(value) {
      if (typeof value === "number" && Number.isFinite(value)) {
        return Math.max(1, value) + "px";
      }

      const source = String(value == null ? "" : value).trim();

      if (!source) {
        return DEFAULT_FONT_SIZE_PX + "px";
      }

      if (/^\d+(\.\d+)?$/.test(source)) {
        return source + "px";
      }

      return source;
    }

    function normalizeTextColor(value) {
      const source = String(value == null ? "" : value).trim();
      return source || DEFAULT_TEXT_COLOR;
    }

    function DisplayText(content, pairIdValue, options) {
      const normalizedContent = content == null ? "" : String(content);

      if (normalizedContent.trim() === "") {
        return null;
      }

      const response = ensureActiveResponse(pairIdValue);
      const wrapper = document.createElement("div");
      const textNode = document.createElement("div");
      const settings = options && typeof options === "object" ? options : {};

      attachDisplayTextContext(wrapper, pairIdValue);

      Object.assign(wrapper.style, {
        width: "100%%",
        boxSizing: "border-box",
        margin: "1rem 0"
      });

      textNode.textContent = normalizedContent;

      Object.assign(textNode.style, {
        color: normalizeTextColor(settings.color),
        fontSize: normalizeFontSize(settings.fontSize),
        lineHeight: "1.45",
        whiteSpace: "pre-wrap",
        overflowWrap: "anywhere",
        wordBreak: "break-word",
        fontFamily: 'system-ui, -apple-system, "Segoe UI", Roboto, sans-serif'
      });

      wrapper.appendChild(textNode);
      response.appendChild(wrapper);

      return wrapper;
    }

    window.DisplayText = DisplayText;
    window.getDisplayTextContextFromTarget = getDisplayTextContextFromTarget;

    DisplayText(text, pairId, {
      fontSize,
      color: textColor
    });
  } catch (e) {
    console.error("DisplayText error:", e);

    try {
      let mount = document.getElementById("ResponseContent");

      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      const dbg = document.createElement("div");
      dbg.textContent = "Erreur DisplayText : " + String(e);

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
