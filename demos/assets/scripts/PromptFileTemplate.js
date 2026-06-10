(() => {

  function translatePromptFileText(key, fallback, vars) {
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
    const files = %s;
    const pairId = %s;

    const FILE_CARD_WIDTH = 300;
    const FILE_CARD_MIN_HEIGHT = 60;

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

    function ensurePromptFileBlock(pairIdValue) {
      const mount = ensureMount();
      const promptPairId = String(pairIdValue);

      let block = null;

      for (const node of mount.children) {
        if (
          node.nodeType === 1 &&
          node.dataset &&
          node.dataset.kind === "prompt-file" &&
          node.dataset.pairId === promptPairId
        ) {
          block = node;
          break;
        }
      }

      if (!block) {
        block = document.createElement("div");
        block.className = "prompt-file-block";
        block.dataset.kind = "prompt-file";
        block.dataset.pairId = promptPairId;
        mount.appendChild(block);
      }

      return block;
    }

    function createFileIcon() {
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

      const svgNS = "http://www.w3.org/2000/svg";
      const svg = document.createElementNS(svgNS, "svg");
      svg.setAttribute("width", "18");
      svg.setAttribute("height", "18");
      svg.setAttribute("viewBox", "0 0 24 24");
      svg.setAttribute("fill", "none");

      const path1 = document.createElementNS(svgNS, "path");
      path1.setAttribute(
        "d",
        "M14 3H8C6.89543 3 6 3.89543 6 5V19C6 20.1046 6.89543 21 8 21H16C17.1046 21 18 20.1046 18 19V7L14 3Z"
      );

      path1.setAttribute("stroke", "var(--input-chip-text)");
      path1.setAttribute("stroke-width", "1.7");
      path1.setAttribute("stroke-linejoin", "round");

      const path2 = document.createElementNS(svgNS, "path");
      path2.setAttribute("d", "M14 3V7H18");
      path2.setAttribute("stroke", "var(--input-chip-text)");
      path2.setAttribute("stroke-width", "1.7");
      path2.setAttribute("stroke-linejoin", "round");

      svg.appendChild(path1);
      svg.appendChild(path2);
      iconWrap.appendChild(svg);

      return iconWrap;
    }

    function getDisplayFileName(fullName) {
      const value = String(fullName ?? "").trim();

      if (!value) {
        return "";
      }

      const parts = value.split(/[\\/]+/);
      return parts[parts.length - 1] || value;
    }

    function ensureFileHoverInfo() {
      let info = document.getElementById("PromptFileHoverInfo");

      if (!info) {
        info = document.createElement("div");
        info.id = "PromptFileHoverInfo";
        info.className = "prompt-file-hover-info";
        document.body.appendChild(info);
      }

      return info;
    }

    function showFileHoverInfo(fullName) {
      const info = ensureFileHoverInfo();
      info.textContent = fullName;
      info.classList.add("is-visible");
    }

    function hideFileHoverInfo() {
      const info = document.getElementById("PromptFileHoverInfo");

      if (!info) {
        return;
      }

      info.textContent = "";
      info.classList.remove("is-visible");
    }

    function createCard(fullName) {
      const card = document.createElement("div");
      const displayName = getDisplayFileName(fullName);

      Object.assign(card.style, {
        width: FILE_CARD_WIDTH + "px",
        minHeight: FILE_CARD_MIN_HEIGHT + "px",
        display: "flex",
        alignItems: "center",
        gap: "12px",
        padding: "10px 14px",
        boxSizing: "border-box",
        border: "1px solid var(--input-shell-border)",
        borderRadius: "12px",
        background: "var(--input-shell-bg)",
        boxShadow: "none"
      });

      card.style.transition = "transform 120ms ease, background 120ms ease";
      card.dataset.fullName = fullName;

      const icon = createFileIcon();

      const label = document.createElement("div");
      label.textContent = displayName;

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

      card.addEventListener("mouseenter", () => {
        card.style.background = "var(--input-shell-bg-hover)";
        card.style.transform = "translateY(-1px)";
        showFileHoverInfo(fullName);
      });

      card.addEventListener("mouseleave", () => {
        card.style.background = "var(--input-shell-bg)";
        card.style.transform = "translateY(0)";
        hideFileHoverInfo();
      });

      card.appendChild(icon);
      card.appendChild(label);

      return card;
    }

    function attachPromptContext(root, pairIdValue) {
      root.dataset.pairId = String(pairIdValue);
      root.dataset.kind = "attached";
    }

    function getPromptContextFromTarget(target) {
      const element =
        target && target.nodeType === 1
          ? target
          : target && target.parentElement
            ? target.parentElement
            : null;

      const root = element
        ? element.closest('[data-kind="attached"][data-pair-id]')
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

    function PromptFile(items, pairIdValue) {
      const block = ensurePromptFileBlock(pairIdValue);
      block.replaceChildren();
      hideFileHoverInfo();

      if (!Array.isArray(items) || !items.length) {
        block.remove();
        return;
      }

      const gallery = document.createElement("div");

      attachPromptContext(gallery, pairIdValue);

      Object.assign(gallery.style, {
        display: "flex",
        flexDirection: "column",
        alignItems: "flex-end",
        gap: "12px",
        margin: "1rem 0",
        width: "100%%",
        boxSizing: "border-box"
      });

      items
        .filter((x) => typeof x === "string" && x.trim() !== "")
        .forEach((fullName) => {
          gallery.appendChild(createCard(fullName.trim()));
        });

      if (!gallery.childElementCount) {
        block.remove();
        return;
      }

      block.appendChild(gallery);
    }

    window.PromptFile = PromptFile;
    window.getPromptContextFromTarget = getPromptContextFromTarget;

    PromptFile(files, pairId);
  } catch (e) {
    console.error("PromptFile error:", e);

    try {
      let mount = document.getElementById("ResponseContent");

      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      const dbg = document.createElement("div");
      dbg.textContent = translatePromptFileText(
        "promptFile.debug.error",
        "Erreur PromptFile : {error}",
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
