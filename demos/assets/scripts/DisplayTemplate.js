(() => {

  function translateDisplayTemplateText(key, fallback, vars) {
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

  /* =======================================================
     Highlight.js theme switch
     ======================================================= */

  const HLJS_DARK =
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/vs2015.min.css";

  const HLJS_LIGHT =
    "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/github.min.css";

  function applyHighlightTheme() {
    const theme = document.documentElement.dataset.theme || "dark";

    const link = document.getElementById("hljs-theme");
    if (!link) return;

    const target = theme === "light" ? HLJS_LIGHT : HLJS_DARK;

    if (link.getAttribute("href") !== target) {
      link.setAttribute("href", target);
    }
  }

  applyHighlightTheme();

  const themeObserver = new MutationObserver(applyHighlightTheme);

  themeObserver.observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"]
  });

  function getDisplayTemplateRuntimeMount() {
    if (
      window.ResponseRenderBatch &&
      typeof window.ResponseRenderBatch.getMount === "function"
    ) {
      const runtimeMount = window.ResponseRenderBatch.getMount();
      if (runtimeMount) return runtimeMount;
    }

    return document.getElementById("ResponseContent") || document.body;
  }

  function getDisplayTemplateActiveBlock(mount) {
    const targetMount = mount || getDisplayTemplateRuntimeMount();

    if (
      window.ResponseRenderBatch &&
      typeof window.ResponseRenderBatch.getActiveStreamBlock === "function"
    ) {
      const activeBlock = window.ResponseRenderBatch.getActiveStreamBlock(targetMount);
      if (activeBlock) return activeBlock;
    }

    if (targetMount && targetMount.children) {
      for (const node of targetMount.children) {
        if (node.nodeType === 1 && node.id === "assistant-stream-block") {
          return node;
        }
      }
    }

    return targetMount && targetMount.lastElementChild
      ? targetMount.lastElementChild
      : null;
  }

  function getDisplayTemplateActiveThought() {
    const mount = getDisplayTemplateRuntimeMount();
    const block = getDisplayTemplateActiveBlock(mount);

    if (block) {
      const thought = block.querySelector(".thought-container");
      if (thought) return thought;
    }

    const allThoughts =
      mount && typeof mount.querySelectorAll === "function"
        ? mount.querySelectorAll(".thought-container")
        : [];

    return allThoughts.length ? allThoughts[allThoughts.length - 1] : null;
  }

  function setDisplayTemplateReasoningOpen(open) {
    const thought = getDisplayTemplateActiveThought();
    if (!thought) return false;

    thought.classList.toggle("open", !!open);
    return true;
  }

  function toggleDisplayTemplateReasoning() {
    const thought = getDisplayTemplateActiveThought();
    if (!thought) return false;

    thought.classList.toggle("open");
    return thought.classList.contains("open");
  }

  window.DisplayTemplate = window.DisplayTemplate || {};

  window.DisplayTemplate.setReasoningOpen = setDisplayTemplateReasoningOpen;
  window.DisplayTemplate.expandReasoning = () => setDisplayTemplateReasoningOpen(true);
  window.DisplayTemplate.collapseReasoning = () => setDisplayTemplateReasoningOpen(false);
  window.DisplayTemplate.toggleReasoning = toggleDisplayTemplateReasoning;

  const DISPLAY_STREAM_MIN_CHUNK = 3;

  function cleanDisplayTemplatePairId(value) {
    return String(value == null ? "" : value)
      .replace(/^[\s\uFEFF\u200B\u200C\u200D\u2060\u00A0]+|[\s\uFEFF\u200B\u200C\u200D\u2060\u00A0]+$/g, "");
  }

  function cleanDisplayTemplateReasoning(value) {
    return String(value || "")
      .replace(/^[\uFEFF\u200B\u200C\u200D\u2060]+/, "")
      .replace(/^\r+/, "");
  }

  function cleanDisplayTemplateMarkdown(value) {
    return String(value)
      .replace(/^[\uFEFF\u200B\u200C\u200D\u2060]+/, "")
      .replace(/^\r+/, "");
  }

  function getDisplayStreamChunkSize(totalPending) {
    if (totalPending > 4000) return 80;
    if (totalPending > 1500) return 56;
    if (totalPending > 600) return 32;
    if (totalPending > 180) return 16;
    if (totalPending > 80) return 8;
    return DISPLAY_STREAM_MIN_CHUNK;
  }

  function takeDisplayStreamChunk(value, maxLength) {
    const source = String(value || "");
    if (!source) {
      return { chunk: "", rest: "" };
    }

    if (source.length <= maxLength) {
      return { chunk: source, rest: "" };
    }

    let end = Math.max(DISPLAY_STREAM_MIN_CHUNK, maxLength);

    if (/[\uDC00-\uDFFF]/.test(source.charAt(end))) {
      end += 1;
    }

    if (source.charAt(end - 1) === "\r" && source.charAt(end) === "\n") {
      end += 1;
    }

    return {
      chunk: source.slice(0, end),
      rest: source.slice(end)
    };
  }

  function getDisplayStreamQueues() {
    window.__displayTemplateStreamQueues =
      window.__displayTemplateStreamQueues || Object.create(null);

    return window.__displayTemplateStreamQueues;
  }

  function getDisplayStreamQueue(pairIdClean) {
    const queues = getDisplayStreamQueues();

    queues[pairIdClean] =
      queues[pairIdClean] || {
        pairId: pairIdClean,
        pendingReasoning: "",
        pendingMd: "",
        afterStreamTasks: [],
        frameId: 0,
        active: true
      };

    return queues[pairIdClean];
  }

  function displayStreamQueueIsPending(queue) {
    return !!(
      queue &&
      queue.active &&
      (
        queue.frameId ||
        queue.pendingReasoning.length ||
        queue.pendingMd.length
      )
    );
  }

  function completeDisplayStreamQueue(queue) {
    if (!queue) return;

    const queues = getDisplayStreamQueues();
    const tasks = Array.isArray(queue.afterStreamTasks)
      ? queue.afterStreamTasks.splice(0)
      : [];

    queue.active = false;
    queue.frameId = 0;
    queue.pendingReasoning = "";
    queue.pendingMd = "";

    delete queues[queue.pairId];

    tasks.forEach((task) => {
      try {
        task();
      } catch (error) {
        console.error("DisplayTemplate deferred task error:", error);
      }
    });
  }

  function requestDisplayStreamFrame(callback) {
    if (typeof window.requestAnimationFrame === "function") {
      return window.requestAnimationFrame(callback);
    }

    return window.setTimeout(callback, 16);
  }

  function cancelDisplayStreamFrame(frameId) {
    if (!frameId) return;

    if (typeof window.cancelAnimationFrame === "function") {
      window.cancelAnimationFrame(frameId);
      return;
    }

    window.clearTimeout(frameId);
  }

  function scheduleDisplayStreamQueue(queue) {
    if (!queue || !queue.active || queue.frameId) return;

    queue.frameId = requestDisplayStreamFrame(() => {
      queue.frameId = 0;
      drainDisplayStreamQueue(queue);
    });
  }

  function drainDisplayStreamQueue(queue) {
    if (!queue || !queue.active) return;

    const totalPending = queue.pendingReasoning.length + queue.pendingMd.length;

    if (!totalPending) {
      completeDisplayStreamQueue(queue);
      return;
    }

    const chunkSize = getDisplayStreamChunkSize(totalPending);
    const reasoningPart = takeDisplayStreamChunk(queue.pendingReasoning, chunkSize);
    const mdPart = takeDisplayStreamChunk(queue.pendingMd, chunkSize);

    queue.pendingReasoning = reasoningPart.rest;
    queue.pendingMd = mdPart.rest;

    renderDisplay(true, queue.pairId, reasoningPart.chunk, mdPart.chunk, {
      fromStreamQueue: true
    });

    if (queue.pendingReasoning.length || queue.pendingMd.length) {
      scheduleDisplayStreamQueue(queue);
    } else {
      completeDisplayStreamQueue(queue);
    }
  }

  function enqueueDisplayStream(streamed, pairId, reasoning, md) {
    const pairIdClean = cleanDisplayTemplatePairId(pairId);

    if (!pairIdClean) return false;

    const queue = getDisplayStreamQueue(pairIdClean);

    queue.active = true;
    queue.pendingReasoning += cleanDisplayTemplateReasoning(reasoning);
    queue.pendingMd += cleanDisplayTemplateMarkdown(md);

    scheduleDisplayStreamQueue(queue);

    return true;
  }

  function runAfterDisplayStreams(callback, pairId) {
    if (typeof callback !== "function") return false;

    const pairIdClean = cleanDisplayTemplatePairId(pairId);
    const queues = getDisplayStreamQueues();

    if (pairIdClean) {
      const queue = queues[pairIdClean];

      if (displayStreamQueueIsPending(queue)) {
        queue.afterStreamTasks.push(callback);
        return true;
      }

      callback();
      return false;
    }

    const pendingQueues = Object.keys(queues)
      .map((key) => queues[key])
      .filter(displayStreamQueueIsPending);

    if (!pendingQueues.length) {
      callback();
      return false;
    }

    let remaining = pendingQueues.length;

    pendingQueues.forEach((queue) => {
      queue.afterStreamTasks.push(() => {
        remaining -= 1;
        if (remaining === 0) {
          callback();
        }
      });
    });

    return true;
  }

  function cancelDisplayStreamQueue(pairId) {
    const pairIdClean = cleanDisplayTemplatePairId(pairId);
    if (!pairIdClean) return false;

    const queues = getDisplayStreamQueues();
    const queue = queues[pairIdClean];

    if (!queue) return false;

    queue.active = false;
    queue.pendingReasoning = "";
    queue.pendingMd = "";
    cancelDisplayStreamFrame(queue.frameId);
    queue.frameId = 0;
    delete queues[pairIdClean];

    return true;
  }

  function cancelAllDisplayStreamQueues() {
    const queues = getDisplayStreamQueues();

    Object.keys(queues).forEach((pairId) => {
      const queue = queues[pairId];

      if (!queue) return;

      queue.active = false;
      queue.pendingReasoning = "";
      queue.pendingMd = "";
      cancelDisplayStreamFrame(queue.frameId);
      queue.frameId = 0;
      delete queues[pairId];
    });

    return true;
  }

  const PYTHIA_DISPLAY_BLOCK_STYLE_ID = "pythia-display-block-style";
  const PYTHIA_TOOL_KINDS = new Set(["toolStatus", "toolOutput", "toolError"]);

  function isToolDisplayKind(kind) {
    return PYTHIA_TOOL_KINDS.has(String(kind || ""));
  }

  function applyReasoningDisplayBlockClasses(container) {
    if (!container) return container;

    ensurePythiaDisplayBlockStyles();

    container.classList.add("pythia-display-block", "pythia-display-block-reasoning");

    const header = container.querySelector(":scope > .thought-header");
    if (header) {
      header.classList.add("pythia-display-block-header", "pythia-reasoning-block-header");
    }

    const content = container.querySelector(":scope > .thought-content");
    if (content) {
      content.classList.add("pythia-display-block-body", "pythia-reasoning-block-body");
    }

    return container;
  }

  function createReasoningDisplayBlock(title, onToggle) {
    ensurePythiaDisplayBlockStyles();

    const container = document.createElement("div");
    container.className = "thought-container pythia-display-block pythia-display-block-reasoning";

    const header = document.createElement("div");
    header.className = "thought-header pythia-display-block-header pythia-reasoning-block-header";
    header.textContent = title || "";
    header.addEventListener("click", () => {
      if (typeof onToggle === "function") {
        onToggle(container);
      } else {
        container.classList.toggle("open");
      }
    });

    const content = document.createElement("div");
    content.className = "thought-content pythia-display-block-body pythia-reasoning-block-body";

    container.appendChild(header);
    container.appendChild(content);

    return { container, header, content };
  }

  function ensurePythiaDisplayBlockStyles() {
    if (document.getElementById(PYTHIA_DISPLAY_BLOCK_STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = PYTHIA_DISPLAY_BLOCK_STYLE_ID;
    style.textContent = `
      .pythia-display-block-list {
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-top: 0;
      }

      .pythia-display-block {
        background: transparent;
        border: none;
        padding: 0;
        margin: 0;
        overflow: visible;
      }

      .pythia-display-block-header {
        padding: 0;
        margin: 0 0 4px 0;
        font: 600 12px/1.35 Verdana, Geneva, DejaVu Sans, sans-serif;
        color: var(--pythia-muted-text, #cbd5e1);
        border: none;
      }

      html[data-theme="light"] .pythia-display-block-header {
        color: #475569;
      }

      .pythia-display-block-body {
        padding: 0;
      }

      .pythia-display-block-body:empty {
        display: none;
      }

      .pythia-display-block-reasoning.thought-container {
        background: transparent;
        border: none;
        border-radius: 0;
        margin: 4px 0;
        padding: 0 0 0 8px;
        border-left: 2px solid rgba(148, 163, 184, 0.25);
        overflow: visible;
      }

      html[data-theme="light"] .pythia-display-block-reasoning.thought-container {
        border-left-color: rgba(100, 116, 139, 0.3);
      }

      .pythia-display-block-reasoning > .pythia-reasoning-block-header {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        font: 500 12px/1.35 Verdana, Geneva, DejaVu Sans, sans-serif;
        color: var(--pythia-muted-text, #94a3b8);
        margin: 0;
        padding: 2px 0;
        user-select: none;
      }

      .pythia-display-block-reasoning > .pythia-reasoning-block-header::before {
        content: "▸";
        display: inline-block;
        font-size: 15px;
        line-height: 1;
        transition: transform 0.15s ease;
      }

      .pythia-display-block-reasoning.open > .pythia-reasoning-block-header::before {
        transform: rotate(90deg);
      }

      .pythia-display-block-reasoning > .pythia-reasoning-block-body {
        color: var(--pythia-muted-text, #94a3b8);
        display: none;
        font: 400 12px/1.4 Consolas, "Cascadia Code", Menlo, monospace;
        margin-top: 4px;
        padding: 0;
        word-break: break-word;
      }

      .pythia-display-block-reasoning.open > .pythia-reasoning-block-body {
        display: block;
      }

      .pythia-display-block-items {
        display: grid;
        gap: 8px;
        margin: 0;
        padding: 0;
        list-style: none;
      }

      .pythia-display-block-item {
        display: grid;
        gap: 3px;
        min-width: 0;
      }

      .pythia-display-block-item-title {
        font-weight: 600;
      }

      .pythia-display-block-item-url {
        overflow-wrap: anywhere;
        font-size: 12px;
        opacity: 0.82;
      }

      .pythia-display-block-item-text {
        opacity: 0.9;
      }

      .pythia-tool-group {
        background: transparent;
        border: none;
        margin: 4px 0;
        padding-left: 8px;
        border-left: 2px solid rgba(148, 163, 184, 0.25);
      }

      html[data-theme="light"] .pythia-tool-group {
        border-left-color: rgba(100, 116, 139, 0.3);
      }

      .pythia-tool-group > summary {
        list-style: none;
        cursor: pointer;
        font: 500 12px/1.35 Verdana, Geneva, DejaVu Sans, sans-serif;
        color: var(--pythia-muted-text, #94a3b8);
        user-select: none;
        padding: 2px 0;
        display: inline-flex;
        align-items: center;
        gap: 6px;
      }

      .pythia-tool-group > summary::-webkit-details-marker {
        display: none;
      }

      .pythia-tool-group > summary::before {
        content: "▸";
        display: inline-block;
        font-size: 15px;
        line-height: 1;
        transition: transform 0.15s ease;
      }

      .pythia-tool-group[open] > summary::before {
        transform: rotate(90deg);
      }

      .pythia-tool-group-body {
        margin-top: 4px;
        display: flex;
        flex-direction: column;
        gap: 6px;
      }

      .pythia-tool-call {
        display: flex;
        flex-direction: column;
        gap: 2px;
      }

      .pythia-tool-call-title {
        font: 500 12px/1.4 Consolas, "Cascadia Code", Menlo, monospace;
        color: var(--pythia-muted-text, #cbd5e1);
        word-break: break-word;
        white-space: pre-wrap;
      }

      html[data-theme="light"] .pythia-tool-call-title {
        color: #475569;
      }

      .pythia-tool-call-body {
        font-family: Consolas, "Cascadia Code", Menlo, monospace !important;
        font-size: 12px !important;
        font-weight: 400;
        line-height: 1.4 !important;
        white-space: pre-wrap;
        word-break: break-word;
        color: var(--pythia-muted-text, #94a3b8) !important;
        margin: 0;
        padding: 0;
        background: transparent;
      }

      .pythia-tool-call.is-error .pythia-tool-call-title,
      .pythia-tool-call.is-error .pythia-tool-call-body {
        color: #f87171;
      }

      .pythia-response-section {
        display: block;
      }

      .pythia-response-section + .pythia-response-section {
        margin-top: 0.85em;
      }

      .pythia-response-section > .pythia-tool-group {
        margin-top: 6px;
      }
    `;

    document.head.appendChild(style);
  }

  function normalizeDisplayBlockKind(kind) {
    const value = String(kind == null ? "" : kind).trim();
    return value || "status";
  }

  function normalizeDisplayBlockPayload(payload) {
    if (payload && typeof payload === "object" && !Array.isArray(payload)) {
      return payload;
    }

    const source = String(payload == null ? "" : payload);
    if (!source.trim()) return {};

    try {
      const parsed = JSON.parse(source);
      if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
        return parsed;
      }
    } catch {}

    return { text: source };
  }

  function normalizeDisplayBlocks(blocks) {
    if (Array.isArray(blocks)) return blocks;

    if (typeof blocks === "string") {
      try {
        const parsed = JSON.parse(blocks);
        if (Array.isArray(parsed)) return parsed;
        if (parsed && typeof parsed === "object") blocks = parsed;
      } catch {}
    }

    const payload = normalizeDisplayBlockPayload(blocks);
    if (Array.isArray(payload.blocks)) return payload.blocks;
    if (Array.isArray(payload.DisplayBlocks)) return payload.DisplayBlocks;
    if (Array.isArray(payload.items)) return payload.items;

    return [];
  }

  function escapeDisplayBlockHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function renderDisplayBlockMarkdown(value) {
    const source = String(value == null ? "" : value);
    if (!source) return "";

    if (window.marked && typeof window.marked.parse === "function") {
      try {
        return window.marked.parse(source);
      } catch {}
    }

    return escapeDisplayBlockHtml(source).replace(/\r?\n/g, "<br>");
  }

  function enhanceDisplayBlockContent(root) {
    if (!root) return;

    if (window.renderMathInElement && window.katex) {
      try {
        window.renderMathInElement(root, {
          delimiters: [
            { left: "$$", right: "$$", display: true },
            { left: "\\[", right: "\\]", display: true },
            { left: "$", right: "$", display: false },
            { left: "\\(", right: "\\)", display: false }
          ],
          ignoredTags: ["script", "noscript", "style", "textarea", "pre", "code", "option"],
          throwOnError: false,
          strict: "ignore"
        });
      } catch {}
    }

    if (window.hljs && typeof window.hljs.highlightElement === "function") {
      root.querySelectorAll("pre code").forEach((codeEl) => {
        try {
          window.hljs.highlightElement(codeEl);
        } catch {}
      });
    }
  }

  function getDisplayBlockText(payload) {
    if (!payload || typeof payload !== "object") return "";

    return String(
      payload.text == null
        ? payload.Text == null
          ? ""
          : payload.Text
        : payload.text
    );
  }

  function getDisplayBlockTitle(payload) {
    if (!payload || typeof payload !== "object") return "";

    return String(
      payload.title == null
        ? payload.Title == null
          ? ""
          : payload.Title
        : payload.title
    );
  }

  function getDisplayBlockUrl(payload) {
    if (!payload || typeof payload !== "object") return "";

    return String(
      payload.url == null
        ? payload.Url == null
          ? ""
          : payload.Url
        : payload.url
    );
  }

  function getDisplayBlockItems(payload) {
    if (!payload || typeof payload !== "object") return [];

    if (Array.isArray(payload.items)) return payload.items;
    if (Array.isArray(payload.Items)) return payload.Items;

    return [];
  }

  function ensureDisplayBlockResponse(pairIdClean) {
    let mount;
    let block;

    if (
      window.ResponseRenderBatch &&
      typeof window.ResponseRenderBatch.ensureActiveResponse === "function"
    ) {
      const ensured = window.ResponseRenderBatch.ensureActiveResponse(
        pairIdClean,
        "assistant-message display-block"
      );
      mount = ensured.mount;
      block = ensured.block;
    } else {
      mount = document.getElementById("ResponseContent");
      if (!mount) {
        mount = document.createElement("div");
        mount.id = "ResponseContent";
        document.body.appendChild(mount);
      }

      block = null;

      for (const node of mount.children) {
        if (node.nodeType !== 1 || node.id !== "assistant-stream-block") continue;

        if (!node.dataset || (node.dataset.pairId || "") === pairIdClean) {
          block = node;
          break;
        }

        node.removeAttribute("id");
      }

      if (!block) {
        block = document.createElement("div");
        block.className = "assistant-message display-block";
        block.id = "assistant-stream-block";
        mount.appendChild(block);
      }
    }

    block.classList.add("assistant-message", "display-block");
    block.dataset.pairId = pairIdClean;

    let response = block.querySelector(":scope > .assistant-response");
    if (!response) {
      response = document.createElement("div");
      response.className = "assistant-response";
      block.appendChild(response);
    }

    let host = response.querySelector(":scope > .pythia-display-block-list");
    if (!host) {
      host = document.createElement("div");
      host.className = "pythia-display-block-list";
      response.appendChild(host);
    }

    return { mount, block, response, host };
  }

  function findLastResponseSection(response) {
    if (!response) return null;
    const sections = response.querySelectorAll(":scope > .pythia-response-section");
    return sections.length ? sections[sections.length - 1] : null;
  }

  function createResponseSection(response) {
    ensurePythiaDisplayBlockStyles();

    const section = document.createElement("div");
    section.className = "pythia-response-section";

    const host = response.querySelector(":scope > .pythia-display-block-list");
    if (host) {
      response.insertBefore(section, host);
    } else {
      response.appendChild(section);
    }

    return section;
  }

  function ensureActiveStreamSection(response) {
    const last = findLastResponseSection(response);
    if (last && last.dataset.textClosed !== "true") {
      return last;
    }
    return createResponseSection(response);
  }

  function ensureStreamSectionContent(section) {
    let content = section.querySelector(":scope > .assistant-response-stream-content");
    if (!content) {
      content = document.createElement("div");
      content.className = "assistant-response-stream-content";
      section.prepend(content);
    }
    return content;
  }

  function ensureActiveToolSection(response) {
    let last = findLastResponseSection(response);
    if (!last || last.dataset.toolClosed === "true") {
      last = createResponseSection(response);
    }
    return last;
  }

  function ensureSectionToolGroup(section) {
    let group = section.querySelector(":scope > .pythia-tool-group");
    if (!group) {
      group = createToolGroupElement();
      section.appendChild(group);
    }
    return group;
  }

  function markSectionToolBoundary(section) {
    if (section) section.dataset.textClosed = "true";
  }

  window.DisplayTemplate = window.DisplayTemplate || {};
  window.DisplayTemplate.__resolveStreamSection = function(response) {
    const section = ensureActiveStreamSection(response);
    return {
      section: section,
      content: ensureStreamSectionContent(section)
    };
  };

  function renderDisplayBlockItems(target, items) {
    if (!Array.isArray(items) || !items.length) return;

    const list = document.createElement("ul");
    list.className = "pythia-display-block-items";

    items.forEach((item) => {
      const payload = normalizeDisplayBlockPayload(item);
      const title = getDisplayBlockTitle(payload);
      const url = getDisplayBlockUrl(payload);
      const text = getDisplayBlockText(payload);

      const row = document.createElement("li");
      row.className = "pythia-display-block-item";

      if (title) {
        const titleNode = document.createElement(url ? "a" : "div");
        titleNode.className = "pythia-display-block-item-title";
        titleNode.textContent = title;
        if (url) {
          titleNode.href = url;
          titleNode.target = "_blank";
          titleNode.rel = "noreferrer";
        }
        row.appendChild(titleNode);
      }

      if (url) {
        const urlNode = document.createElement("a");
        urlNode.className = "pythia-display-block-item-url";
        urlNode.href = url;
        urlNode.target = "_blank";
        urlNode.rel = "noreferrer";
        urlNode.textContent = url;
        row.appendChild(urlNode);
      }

      if (text) {
        const textNode = document.createElement("div");
        textNode.className = "pythia-display-block-item-text";
        textNode.innerHTML = renderDisplayBlockMarkdown(text);
        enhanceDisplayBlockContent(textNode);
        row.appendChild(textNode);
      }

      list.appendChild(row);
    });

    target.appendChild(list);
  }

  function getPythiaReasoningTitle() {
    if (window.AppI18n && typeof window.AppI18n.t === "function") {
      return window.AppI18n.t("display.reasoning.title", "Reasoning");
    }
    return "Reasoning";
  }

  function renderAssistantBlockElement(element) {
    const text = String(element.__pythiaDisplayText || "");
    element.replaceChildren();

    if (!text) return;

    const response = document.createElement("div");
    response.className = "assistant-response";
    response.innerHTML = renderDisplayBlockMarkdown(text);
    enhanceDisplayBlockContent(response);
    element.appendChild(response);
  }

  function renderReasoningBlockElement(element) {
    const text = String(element.__pythiaDisplayText || "");
    element.replaceChildren();

    if (!text) return;

    const reasoningBlock = createReasoningDisplayBlock(getPythiaReasoningTitle());
    const container = reasoningBlock.container;
    const content = reasoningBlock.content;
    content.innerHTML = renderDisplayBlockMarkdown(text);
    enhanceDisplayBlockContent(content);

    element.appendChild(container);
  }

  function renderDisplayBlockElement(element) {
    const kind = element.dataset ? element.dataset.displayKind || "" : "";

    if (kind === "assistant") {
      renderAssistantBlockElement(element);
      return;
    }

    if (kind === "reasoning") {
      renderReasoningBlockElement(element);
      return;
    }

    const payload = element.__pythiaDisplayPayload || {};
    const title = getDisplayBlockTitle(payload);
    const url = getDisplayBlockUrl(payload);
    const text = String(element.__pythiaDisplayText || "");
    const items = getDisplayBlockItems(payload);

    element.replaceChildren();

    if (title) {
      const header = document.createElement("div");
      header.className = "pythia-display-block-header";
      header.textContent = title;
      element.appendChild(header);
    }

    const body = document.createElement("div");
    body.className = "pythia-display-block-body";

    if (url) {
      const link = document.createElement("a");
      link.href = url;
      link.target = "_blank";
      link.rel = "noreferrer";
      link.textContent = url;
      body.appendChild(link);
    }

    if (text) {
      const textNode = document.createElement("div");
      textNode.innerHTML = renderDisplayBlockMarkdown(text);
      enhanceDisplayBlockContent(textNode);
      body.appendChild(textNode);
    }

    renderDisplayBlockItems(body, items);
    element.appendChild(body);
  }

  function createDisplayBlockElement(kind, payload) {
    const kindClean = normalizeDisplayBlockKind(kind);
    const data = normalizeDisplayBlockPayload(payload);
    const element = document.createElement("div");

    element.className = "pythia-display-block pythia-display-block-" +
      kindClean.replace(/[^a-z0-9_-]/gi, "-").toLowerCase();
    element.dataset.displayKind = kindClean;
    element.__pythiaDisplayPayload = data;
    element.__pythiaDisplayText = getDisplayBlockText(data);

    renderDisplayBlockElement(element);
    return element;
  }

  function getToolGroupLabel() {
    if (window.AppI18n && typeof window.AppI18n.t === "function") {
      return window.AppI18n.t("display.toolGroup.label", "Tools used");
    }
    return "Tools used";
  }

  function getToolGroupEntryCount(group) {
    if (!group || typeof group.querySelector !== "function") return 0;

    const body = group.querySelector(":scope > .pythia-tool-group-body");
    if (!body || typeof body.querySelectorAll !== "function") return 0;

    return body.querySelectorAll(":scope > .pythia-tool-call").length;
  }

  function getToolGroupSummaryLabel(group) {
    const label = getToolGroupLabel();
    const count = getToolGroupEntryCount(group);

    return count > 0 ? label + " (" + count + ")" : label;
  }

  function updateToolGroupSummary(group) {
    if (!group || typeof group.querySelector !== "function") return;

    const summary = group.querySelector(":scope > .pythia-tool-group-summary");
    if (!summary) return;

    summary.textContent = getToolGroupSummaryLabel(group);
  }

  function createToolGroupElement() {
    const details = document.createElement("details");
    details.className = "pythia-tool-group";

    const summary = document.createElement("summary");
    summary.className = "pythia-tool-group-summary";
    summary.textContent = getToolGroupSummaryLabel(details);
    details.appendChild(summary);

    const body = document.createElement("div");
    body.className = "pythia-tool-group-body";
    details.appendChild(body);

    return details;
  }

  function getToolGroupBody(group) {
    let body = group.querySelector(":scope > .pythia-tool-group-body");
    if (!body) {
      body = document.createElement("div");
      body.className = "pythia-tool-group-body";
      group.appendChild(body);
    }
    return body;
  }

  function getOrCreateToolGroup(host) {
    const last = host.lastElementChild;

    if (
      last &&
      last.classList &&
      last.classList.contains("pythia-tool-group") &&
      last.dataset &&
      last.dataset.streamClosed !== "true"
    ) {
      return last;
    }

    if (
      last &&
      last.dataset &&
      last.dataset.displayKind === "assistant" &&
      last.dataset.streamClosed !== "true"
    ) {
      let group = last.querySelector(":scope > .pythia-tool-group");
      if (group && group.dataset && group.dataset.streamClosed !== "true") {
        return group;
      }

      group = createToolGroupElement();
      last.appendChild(group);

      last.dataset.streamClosed = "true";
      return group;
    }

    const group = createToolGroupElement();
    host.appendChild(group);
    return group;
  }

  function closeOpenToolGroups(host) {
    host.querySelectorAll(".pythia-tool-group").forEach((group) => {
      group.dataset.streamClosed = "true";
    });
  }

  function renderToolCallEntry(entry) {
    const payload = entry.__pythiaDisplayPayload || {};
    const title = getDisplayBlockTitle(payload);
    const text = String(entry.__pythiaDisplayText || "");

    entry.replaceChildren();

    if (title) {
      const titleNode = document.createElement("div");
      titleNode.className = "pythia-tool-call-title";
      titleNode.textContent = title;
      entry.appendChild(titleNode);
    }

    if (text) {
      const bodyNode = document.createElement("pre");
      bodyNode.className = "pythia-tool-call-body";
      bodyNode.textContent = text;
      entry.appendChild(bodyNode);
    }
  }

  function createToolCallEntry(kind, payload) {
    const data = normalizeDisplayBlockPayload(payload);
    const entry = document.createElement("div");
    entry.className = "pythia-tool-call pythia-tool-call-" +
      String(kind).replace(/[^a-z0-9_-]/gi, "-");
    entry.dataset.displayKind = String(kind);
    entry.__pythiaDisplayPayload = data;
    entry.__pythiaDisplayText = getDisplayBlockText(data);

    if (String(kind) === "toolError") {
      entry.classList.add("is-error");
    }

    renderToolCallEntry(entry);
    return entry;
  }

  function getLastToolCallEntry(group) {
    const body = getToolGroupBody(group);
    const entries = body.querySelectorAll(":scope > .pythia-tool-call");
    return entries.length ? entries[entries.length - 1] : null;
  }

  function appendToolEntry(host, kind, payload) {
    const group = getOrCreateToolGroup(host);
    const entry = createToolCallEntry(kind, payload);
    getToolGroupBody(group).appendChild(entry);
    updateToolGroupSummary(group);
    return entry;
  }

  function getLastChildOpenBlockOfKind(host, kind) {
    const last = host.lastElementChild;
    if (!last) return null;
    if (!last.dataset) return null;
    if (last.dataset.displayKind !== kind) return null;
    if (last.dataset.streamClosed === "true") return null;
    return last;
  }

  function appendStandaloneBlock(host, kind, payload) {

    if (kind === "assistant" || kind === "reasoning") {
      closeOpenToolGroups(host);
    }

    const block = createDisplayBlockElement(kind, payload);
    host.appendChild(block);
    return block;
  }

  function appendToolEntryToSection(section, kind, payload) {
    const group = ensureSectionToolGroup(section);
    const entry = createToolCallEntry(kind, payload);
    getToolGroupBody(group).appendChild(entry);
    updateToolGroupSummary(group);
    markSectionToolBoundary(section);
    return entry;
  }

  function displayBlock(pairId, kind, payload) {
    ensurePythiaDisplayBlockStyles();

    const pairIdClean = cleanDisplayTemplatePairId(pairId);
    if (!pairIdClean) return false;

    const kindClean = normalizeDisplayBlockKind(kind);
    const data = normalizeDisplayBlockPayload(payload);

    if (kindClean === "assistant") {
      return display(false, pairIdClean, "", getDisplayBlockText(data));
    }

    if (kindClean === "reasoning") {
      return display(false, pairIdClean, getDisplayBlockText(data), "");
    }

    if (isToolDisplayKind(kindClean)) {
      runAfterDisplayStreams(() => {
        const target = ensureDisplayBlockResponse(pairIdClean);
        const section = ensureActiveToolSection(target.response);
        appendToolEntryToSection(section, kindClean, payload);
      }, pairIdClean);
      return true;
    }

    const target = ensureDisplayBlockResponse(pairIdClean);
    appendStandaloneBlock(target.host, kindClean, payload);
    return true;
  }

  function displayBlockStream(pairId, kind, delta, payload) {
    ensurePythiaDisplayBlockStyles();

    const pairIdClean = cleanDisplayTemplatePairId(pairId);
    if (!pairIdClean) return false;

    const kindClean = normalizeDisplayBlockKind(kind);
    const deltaText = String(delta == null ? "" : delta);

    if (kindClean === "assistant") {
      return displayStream(true, pairIdClean, "", deltaText);
    }

    if (kindClean === "reasoning") {
      return displayStream(true, pairIdClean, deltaText, "");
    }

    if (isToolDisplayKind(kindClean)) {
      runAfterDisplayStreams(() => {
        const target = ensureDisplayBlockResponse(pairIdClean);

        const section = ensureActiveToolSection(target.response);
        const group = ensureSectionToolGroup(section);

        if (kindClean === "toolStatus") {
          const entry = createToolCallEntry(kindClean, payload);
          if (deltaText) {
            entry.__pythiaDisplayText =
              String(entry.__pythiaDisplayText || "") + deltaText;
            renderToolCallEntry(entry);
          }
          getToolGroupBody(group).appendChild(entry);
          updateToolGroupSummary(group);
          markSectionToolBoundary(section);
          return;
        }

        let entry = getLastToolCallEntry(group);
        if (!entry) {

          entry = createToolCallEntry("toolStatus", {});
          getToolGroupBody(group).appendChild(entry);
          updateToolGroupSummary(group);
          markSectionToolBoundary(section);
        }

        if (kindClean === "toolError") {
          entry.classList.add("is-error");
          entry.dataset.displayKind = "toolError";
        }

        if (payload != null && String(payload).trim()) {
          const nextPayload = normalizeDisplayBlockPayload(payload);
          entry.__pythiaDisplayPayload = Object.assign(
            {},
            entry.__pythiaDisplayPayload || {},
            nextPayload
          );
        }

        entry.__pythiaDisplayText =
          String(entry.__pythiaDisplayText || "") + deltaText;
        renderToolCallEntry(entry);
      }, pairIdClean);
      return true;
    }

    const target = ensureDisplayBlockResponse(pairIdClean);

    let block = getLastChildOpenBlockOfKind(target.host, kindClean);

    if (!block) {
      block = appendStandaloneBlock(target.host, kindClean, payload);
    } else if (payload != null && String(payload).trim()) {
      const nextPayload = normalizeDisplayBlockPayload(payload);
      block.__pythiaDisplayPayload = Object.assign(
        {},
        block.__pythiaDisplayPayload || {},
        nextPayload
      );
    }

    block.__pythiaDisplayText =
      String(block.__pythiaDisplayText || "") + deltaText;

    renderDisplayBlockElement(block);
    return true;
  }

  function displayBlocks(pairId, blocksJson) {
    ensurePythiaDisplayBlockStyles();

    const pairIdClean = cleanDisplayTemplatePairId(pairId);
    if (!pairIdClean) return false;

    const blocks = normalizeDisplayBlocks(blocksJson);
    renderDisplay(true, pairIdClean, "", "", {
      fromStreamQueue: true,
      resetResponse: true
    });

    blocks.forEach((item) => {
      const payload = normalizeDisplayBlockPayload(item);
      const kind = normalizeDisplayBlockKind(
        payload.kind == null
          ? payload.Kind == null
            ? "status"
            : payload.Kind
          : payload.kind
      );

      if (kind === "reasoning") {
        const text = getDisplayBlockText(payload);
        if (text) {
          renderDisplay(true, pairIdClean, text, "", {
            fromStreamQueue: true
          });
        }
        return;
      }

      if (kind === "assistant") {
        const text = getDisplayBlockText(payload);
        if (text) {
          renderDisplay(true, pairIdClean, "", text, {
            fromStreamQueue: true
          });
        }
        return;
      }

      const target = ensureDisplayBlockResponse(pairIdClean);

      if (isToolDisplayKind(kind)) {
        const section = ensureActiveToolSection(target.response);
        appendToolEntryToSection(section, kind, payload);
        return;
      }

      appendStandaloneBlock(target.host, kind, payload);
    });

    const target = ensureDisplayBlockResponse(pairIdClean);
    target.block.dataset.streaming = "false";

    return true;
  }

  function display(streamed, pairId, reasoning, md) {
    cancelDisplayStreamQueue(pairId);
    return renderDisplay(false, pairId, reasoning, md);
  }

  function displayStream(streamed, pairId, reasoning, md) {
    return enqueueDisplayStream(streamed, pairId, reasoning, md);
  }

  function renderDisplay(streamed, pairId, reasoning, md, options) {

  const isStreamCall =
    streamed === true ||
    streamed === "true" ||
    streamed === 1 ||
    streamed === "1";

  const pairIdClean = cleanDisplayTemplatePairId(pairId);

  if (!pairIdClean) return;

  const fromStreamQueue = !!(options && options.fromStreamQueue);
  const resetResponse = !!(options && options.resetResponse);

  const reasoningClean = fromStreamQueue
    ? String(reasoning || "")
    : cleanDisplayTemplateReasoning(reasoning);

  const mdClean = fromStreamQueue
    ? String(md || "")
    : cleanDisplayTemplateMarkdown(md);

    const DISPLAY_TEMPLATE_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  const t = translateDisplayTemplateText;

  function getDisplayReasoningTitle() {
    return t("display.reasoning.title", "Reasoning");
  }

  function getDisplayCodeCopyLabel() {
    return t("display.code.copy", "Copy");
  }

  function getDisplayCodeCopiedLabel() {
    return t("display.code.copied", "Copied");
  }

  function getDisplayCodeCopyToClipboardTitle() {
    return t("display.code.copyToClipboard", "Copy to clipboard");
  }

  function getDisplayAlertLabel(type) {
    switch (String(type || "").toLowerCase()) {
      case "note":
        return t("display.alert.note", "Note");
      case "tip":
        return t("display.alert.tip", "Tip");
      case "important":
        return t("display.alert.important", "Important");
      case "warning":
        return t("display.alert.warning", "Warning");
      case "caution":
        return t("display.alert.caution", "Caution");
      default:
        return String(type || "");
    }
  }

  function applyDisplayTemplateDictionary(scope) {
    const rootNode =
      scope && typeof scope.querySelectorAll === "function"
        ? scope
        : document;

    rootNode.querySelectorAll(".thought-container > .thought-header").forEach((header) => {
      header.textContent = getDisplayReasoningTitle();
    });

    rootNode.querySelectorAll(".pythia-tool-group > .pythia-tool-group-summary").forEach((summary) => {
      updateToolGroupSummary(summary.parentElement);
    });

    rootNode
      .querySelectorAll(".md-alert[data-alert-type]")
      .forEach((alert) => {
        const label = alert.querySelector(".md-alert-label");
        if (!label) return;

        label.textContent = getDisplayAlertLabel(alert.dataset.alertType);
      });

    rootNode
      .querySelectorAll('.copy-btn[data-display-template-copy="1"]')
      .forEach((btn) => {
        const label = btn.querySelector(".copy-btn-label");
        const copied = btn.dataset.copyState === "true";

        btn.setAttribute("title", getDisplayCodeCopyToClipboardTitle());
        btn.setAttribute("aria-label", getDisplayCodeCopyToClipboardTitle());

        if (label) {
          if (copied) {
            label.textContent = getDisplayCodeCopiedLabel();
            label.style.display = "";
            btn.style.gap = "6px";
          } else {
            label.textContent = "";
            label.style.display = "none";
            btn.style.gap = "0";
          }
        }
      });
  }

  const MATH_MARKDOWN_PLACEHOLDER_PREFIX = "DISPLAYTEMPLATEMATH";

  const MATH_MARKDOWN_DELIMITERS = [
    { left: "$$", right: "$$" },
    { left: "\\[", right: "\\]" },
    { left: "\\(", right: "\\)" },
    { left: "$", right: "$" }
  ];

  const escapeMathHtml = (value) => {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  };

  const isEscapedMarkdownMathDelimiter = (text, index) => {
    let backslashCount = 0;

    for (let i = index - 1; i >= 0 && text[i] === "\\"; i--) {
      backslashCount += 1;
    }

    return backslashCount % 2 === 1;
  };

  const getMarkdownMathDelimiterAt = (text, index) => {
    for (const delimiter of MATH_MARKDOWN_DELIMITERS) {
      if (!text.startsWith(delimiter.left, index)) continue;
      if (isEscapedMarkdownMathDelimiter(text, index)) continue;

      if (
        delimiter.left === "$" &&
        (text.startsWith("$$", index) || text[index + 1] === " ")
      ) {
        continue;
      }

      return delimiter;
    }

    return null;
  };

  const getMarkdownProtectedRangeContaining = (ranges, index) => {
    if (!ranges || !ranges.length) return null;

    for (const range of ranges) {
      if (index < range.start) return null;
      if (index >= range.start && index < range.end) return range;
    }

    return null;
  };

  const findMarkdownMathEnd = (text, startIndex, delimiter, protectedRanges) => {
    let searchIndex = startIndex;

    while (searchIndex < text.length) {
      const endIndex = text.indexOf(delimiter.right, searchIndex);
      if (endIndex === -1) return -1;

      const protectedRange = getMarkdownProtectedRangeContaining(
        protectedRanges,
        endIndex
      );

      if (protectedRange) {
        searchIndex = protectedRange.end;
        continue;
      }

      if (
        !isEscapedMarkdownMathDelimiter(text, endIndex) &&
        !(delimiter.right === "$" && text.startsWith("$$", endIndex))
      ) {
        return endIndex;
      }

      searchIndex = endIndex + delimiter.right.length;
    }

    return -1;
  };

  const getMarkdownLineStart = (text, index) => {
    const lineBreakIndex = text.lastIndexOf("\n", index - 1);
    return lineBreakIndex === -1 ? 0 : lineBreakIndex + 1;
  };

  const getMarkdownLineEnd = (text, index) => {
    const lineBreakIndex = text.indexOf("\n", index);
    return lineBreakIndex === -1 ? text.length : lineBreakIndex + 1;
  };

  const getMarkdownFenceMatch = (line, closingOnly) => {
    const normalized = String(line == null ? "" : line).replace(/\r$/, "");
    const pattern = closingOnly
      ? /^[ \t]*(`{3,}|~{3,})[ \t]*$/
      : /^[ \t]*(`{3,}|~{3,})[^\r\n]*$/;

    const match = normalized.match(pattern);
    if (!match) return null;

    return {
      marker: match[1],
      char: match[1][0],
      length: match[1].length
    };
  };

  const collectMarkdownFenceRanges = (source) => {
    const ranges = [];
    let index = 0;

    while (index < source.length) {
      const lineEnd = source.indexOf("\n", index);
      const contentEnd = lineEnd === -1 ? source.length : lineEnd;
      const line = source.slice(index, contentEnd);
      const opening = getMarkdownFenceMatch(line, false);

      if (!opening) {
        index = lineEnd === -1 ? source.length : lineEnd + 1;
        continue;
      }

      const rangeStart = index;
      let searchIndex = lineEnd === -1 ? source.length : lineEnd + 1;
      let rangeEnd = source.length;

      while (searchIndex < source.length) {
        const closeLineEnd = source.indexOf("\n", searchIndex);
        const closeContentEnd = closeLineEnd === -1 ? source.length : closeLineEnd;
        const closeLine = source.slice(searchIndex, closeContentEnd);
        const closing = getMarkdownFenceMatch(closeLine, true);

        if (closing && closing.char === opening.char) {
          rangeEnd = closeLineEnd === -1 ? source.length : closeLineEnd + 1;
          break;
        }

        if (closeLineEnd === -1) break;
        searchIndex = closeLineEnd + 1;
      }

      ranges.push({ start: rangeStart, end: rangeEnd });
      index = rangeEnd;
    }

    return ranges;
  };

  const rangeContainsIndex = (range, index) => {
    return !!range && index >= range.start && index < range.end;
  };

  const collectMarkdownCodeSpanRanges = (source, fenceRanges) => {
    const ranges = [];
    let index = 0;

    while (index < source.length) {
      const fenceRange = getMarkdownProtectedRangeContaining(fenceRanges, index);
      if (fenceRange) {
        index = fenceRange.end;
        continue;
      }

      if (source[index] !== "`") {
        index += 1;
        continue;
      }

      let tickLength = 0;
      while (source[index + tickLength] === "`") {
        tickLength += 1;
      }

      const marker = "`".repeat(tickLength);
      const endIndex = source.indexOf(marker, index + tickLength);

      if (endIndex === -1) {
        index += tickLength;
        continue;
      }

      const rangeEnd = endIndex + tickLength;
      ranges.push({ start: index, end: rangeEnd });
      index = rangeEnd;
    }

    return ranges.filter((range) => {
      return !fenceRanges.some((fenceRange) => {
        return (
          rangeContainsIndex(fenceRange, range.start) ||
          rangeContainsIndex(fenceRange, range.end - 1)
        );
      });
    });
  };

  const collectMarkdownIndentedCodeRanges = (source, protectedRanges) => {
    const ranges = [];
    let index = 0;

    while (index < source.length) {
      const protectedRange = getMarkdownProtectedRangeContaining(protectedRanges, index);
      if (protectedRange) {
        index = protectedRange.end;
        continue;
      }

      const lineEnd = getMarkdownLineEnd(source, index);

      if (source.startsWith("    ", index) || source[index] === "\t") {
        ranges.push({ start: index, end: lineEnd });
      }

      index = lineEnd;
    }

    return ranges;
  };

  const collectMarkdownProtectedRanges = (source) => {
    const fenceRanges = collectMarkdownFenceRanges(source);
    const codeSpanRanges = collectMarkdownCodeSpanRanges(source, fenceRanges);
    const codeRanges = fenceRanges
      .concat(codeSpanRanges)
      .sort((a, b) => a.start - b.start || b.end - a.end);
    const indentedCodeRanges = collectMarkdownIndentedCodeRanges(
      source,
      codeRanges
    );

    return codeRanges
      .concat(indentedCodeRanges)
      .sort((a, b) => a.start - b.start || b.end - a.end);
  };

  const getMarkdownProtectedRangeStartingAt = (ranges, index) => {
    if (!ranges || !ranges.length) return null;

    for (const range of ranges) {
      if (range.start === index) return range;
      if (range.start > index) return null;
    }

    return null;
  };

  const protectMathForMarkdown = (src) => {
    const source = String(src == null ? "" : src);
    const protectedRanges = collectMarkdownProtectedRanges(source);
    const segments = [];
    let output = "";
    let index = 0;

    while (index < source.length) {
      const protectedRange = getMarkdownProtectedRangeStartingAt(
        protectedRanges,
        index
      );

      if (protectedRange) {
        output += source.slice(protectedRange.start, protectedRange.end);
        index = protectedRange.end;
        continue;
      }

      const delimiter = getMarkdownMathDelimiterAt(source, index);

      if (!delimiter) {
        output += source[index];
        index += 1;
        continue;
      }

      const contentStart = index + delimiter.left.length;
      const endIndex = findMarkdownMathEnd(
        source,
        contentStart,
        delimiter,
        protectedRanges
      );

      if (endIndex === -1) {
        output += source[index];
        index += 1;
        continue;
      }

      const placeholder = MATH_MARKDOWN_PLACEHOLDER_PREFIX + segments.length + "TOKEN";
      const contentEnd = endIndex + delimiter.right.length;

      segments.push(source.slice(index, contentEnd));
      output += placeholder;
      index = contentEnd;
    }

    return { source: output, segments };
  };

  const restoreMathAfterMarkdown = (htmlSource, segments) => {
    let html = String(htmlSource == null ? "" : htmlSource);

    segments.forEach((segment, index) => {
      const placeholder = MATH_MARKDOWN_PLACEHOLDER_PREFIX + index + "TOKEN";
      html = html.split(placeholder).join(escapeMathHtml(segment));
    });

    return html;
  };

  const buildHtml = (src) => {
    if (!(window.marked && typeof window.marked.parse === "function")) {
      return src;
    }

    const protectedMath = protectMathForMarkdown(src);
    const html = window.marked.parse(protectedMath.source);

    return restoreMathAfterMarkdown(html, protectedMath.segments);
  };

  const renderMath = (root) => {
    if (!root) return;
    if (!(window.renderMathInElement && window.katex)) return;

    window.renderMathInElement(root, {
      delimiters: [
        { left: "$$", right: "$$", display: true },
        { left: "\\[", right: "\\]", display: true },
        { left: "$", right: "$", display: false },
        { left: "\\(", right: "\\)", display: false }
      ],
      ignoredTags: ["script", "noscript", "style", "textarea", "pre", "code", "option"],
      throwOnError: false,
      strict: "ignore"
    });
  };

  function ensureMarkdownBadgeStyles() {
    if (document.getElementById("md-badge-style")) return;

    const style = document.createElement("style");
    style.id = "md-badge-style";

    style.textContent = `
      .assistant-response .md-badge,
      .thought-content .md-badge {
        display: inline-flex;
        align-items: stretch;
        height: 20px;
        margin: 0 4px 4px 0;
        border-radius: 3px;
        overflow: hidden;
        vertical-align: middle;
        white-space: nowrap;
        font: 600 11px/20px Verdana, Geneva, DejaVu Sans, sans-serif;
        letter-spacing: 0.01em;
        box-shadow: inset 0 -1px 0 rgba(0,0,0,0.16);
      }

      .assistant-response .md-badge-part,
      .thought-content .md-badge-part {
        display: inline-flex;
        align-items: center;
        height: 20px;
        padding: 0 6px;
        box-sizing: border-box;
      }

      .assistant-response .md-badge-label,
      .thought-content .md-badge-label {
        background: #555;
        color: #fff;
      }

      .assistant-response .md-badge-message,
      .thought-content .md-badge-message {
        color: #fff;
      }

      .assistant-response .md-badge svg,
      .thought-content .md-badge svg {
        width: 12px;
        height: 12px;
        margin-right: 4px;
        flex: 0 0 auto;
      }

      .assistant-response a .md-badge,
      .thought-content a .md-badge {
        cursor: pointer;
      }
    `;

    document.head.appendChild(style);
  }

  function decodeShieldsBadgeText(value) {
    let text = String(value == null ? "" : value);

    try {
      text = decodeURIComponent(text);
    } catch {}

    return text
      .replace(/__/g, "\u0000")
      .replace(/_/g, " ")
      .replace(/\u0000/g, "_")
      .replace(/--/g, "-")
      .replace(/\+/g, " ")
      .trim();
  }

  function normalizeBadgeColor(value, fallback) {
    const raw = String(value || fallback || "6a737d")
      .trim()
      .replace(/^#/, "")
      .toLowerCase();

    const namedColors = {
      brightgreen: "4c1",
      green: "97ca00",
      yellowgreen: "a4a61d",
      yellow: "dfb317",
      orange: "fe7d37",
      red: "e05d44",
      blue: "007ec6",
      lightgrey: "9f9f9f",
      lightgray: "9f9f9f",
      grey: "555",
      gray: "555",
      success: "28a745",
      important: "ffb000",
      critical: "d73a49",
      informational: "0366d6",
      inactive: "6a737d",
      white: "ffffff",
      black: "000000"
    };

    const color = namedColors[raw] || raw;

    if (/^[0-9a-f]{3}$/i.test(color) || /^[0-9a-f]{6}$/i.test(color)) {
      return "#" + color;
    }

    return "#" + String(fallback || "6a737d").replace(/^#/, "");
  }

  function getBadgeTextColor(backgroundColor) {
    const raw = String(backgroundColor || "#000000").replace(/^#/, "");

    const hex =
      raw.length === 3
        ? raw.split("").map((c) => c + c).join("")
        : raw;

    if (!/^[0-9a-f]{6}$/i.test(hex)) {
      return "#ffffff";
    }

    const r = parseInt(hex.slice(0, 2), 16) / 255;
    const g = parseInt(hex.slice(2, 4), 16) / 255;
    const b = parseInt(hex.slice(4, 6), 16) / 255;

    const luminance =
      0.2126 * r +
      0.7152 * g +
      0.0722 * b;

    return luminance > 0.62 ? "#24292f" : "#ffffff";
  }

  function stripBadgeExtension(value) {
    return String(value || "").replace(/\.(svg|png|gif|jpg|jpeg)$/i, "");
  }

  function findShieldsSeparator(value, fromRight) {
    const text = String(value || "");

    if (fromRight) {
      for (let i = text.length - 1; i >= 0; i--) {
        if (text[i] !== "-") continue;

        if (i > 0 && text[i - 1] === "-") {
          i--;
          continue;
        }

        if (i + 1 < text.length && text[i + 1] === "-") {
          continue;
        }

        return i;
      }

      return -1;
    }

    for (let i = 0; i < text.length; i++) {
      if (text[i] !== "-") continue;

      if (i + 1 < text.length && text[i + 1] === "-") {
        i++;
        continue;
      }

      if (i > 0 && text[i - 1] === "-") {
        continue;
      }

      return i;
    }

    return -1;
  }

  function splitShieldsBadgeSpec(spec) {
    const text = String(spec || "");

    const firstSeparator = findShieldsSeparator(text, false);
    const lastSeparator = findShieldsSeparator(text, true);

    if (firstSeparator <= 0 || lastSeparator <= firstSeparator) {
      return null;
    }

    return {
      label: text.slice(0, firstSeparator),
      message: text.slice(firstSeparator + 1, lastSeparator),
      color: text.slice(lastSeparator + 1)
    };
  }

  function parseShieldsBadgeUrl(src) {
    let url;

    try {
      url = new URL(src, document.baseURI);
    } catch {
      return null;
    }

    if (url.protocol !== "https:" || url.hostname !== "img.shields.io") {
      return null;
    }

    let label = "";
    let message = "";
    let color = "";
    let labelColor = url.searchParams.get("labelColor") || "555";

    if (url.pathname === "/static/v1") {
      label = url.searchParams.get("label") || "";
      message = url.searchParams.get("message") || "";
      color = url.searchParams.get("color") || "6a737d";
    } else if (url.pathname.startsWith("/badge/")) {
      const spec = url.pathname.slice("/badge/".length);
      const parts = splitShieldsBadgeSpec(spec);

      if (!parts) return null;

      label = parts.label;
      message = parts.message;
      color = parts.color;
    } else {
      return null;
    }

    return {
      label: decodeShieldsBadgeText(label),
      message: decodeShieldsBadgeText(message),
      color: normalizeBadgeColor(stripBadgeExtension(color), "6a737d"),
      labelColor: normalizeBadgeColor(labelColor, "555"),
      logo: url.searchParams.get("logo") || "",
      logoColor: url.searchParams.get("logoColor") || "ffffff"
    };
  }

  function createBadgeLogo(name, color) {
    const logo = String(name || "").trim().toLowerCase();
    if (!logo) return null;

    const ns = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(ns, "svg");

    svg.setAttribute("aria-hidden", "true");
    svg.setAttribute("focusable", "false");

    const fill = normalizeBadgeColor(color || "ffffff", "ffffff");

    if (logo === "windows") {
      svg.setAttribute("viewBox", "0 0 16 16");

      [
        [1, 1, 6, 6],
        [9, 1, 6, 6],
        [1, 9, 6, 6],
        [9, 9, 6, 6]
      ].forEach(([x, y, w, h]) => {
        const rect = document.createElementNS(ns, "rect");
        rect.setAttribute("x", x);
        rect.setAttribute("y", y);
        rect.setAttribute("width", w);
        rect.setAttribute("height", h);
        rect.setAttribute("fill", fill);
        svg.appendChild(rect);
      });

      return svg;
    }

    if (logo === "github") {
      svg.setAttribute("viewBox", "0 0 16 16");

      const path = document.createElementNS(ns, "path");
      path.setAttribute("fill", fill);
      path.setAttribute(
        "d",
        "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82A7.6 7.6 0 0 1 8 4.55c.68 0 1.36.09 2 .26 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8z"
      );

      svg.appendChild(path);
      return svg;
    }

    return null;
  }

  function createMarkdownBadge(info, altText) {
    const badge = document.createElement("span");
    badge.className = "md-badge";
    badge.setAttribute("role", "img");

    badge.setAttribute(
      "aria-label",
      altText || (info.label ? info.label + ": " + info.message : info.message)
    );

    const labelPart = document.createElement("span");
    labelPart.className = "md-badge-part md-badge-label";
    labelPart.style.background = info.labelColor;
    labelPart.style.color = getBadgeTextColor(info.labelColor);

    const logo = createBadgeLogo(info.logo, info.logoColor);
    if (logo) {
      labelPart.appendChild(logo);
    }

    const labelText = document.createElement("span");
    labelText.textContent = info.label;
    labelPart.appendChild(labelText);

    const messagePart = document.createElement("span");
    messagePart.className = "md-badge-part md-badge-message";
    messagePart.style.background = info.color;
    messagePart.style.color = getBadgeTextColor(info.color);
    messagePart.textContent = info.message;

    badge.appendChild(labelPart);
    badge.appendChild(messagePart);

    return badge;
  }

  function transformShieldsBadges(scope) {
    if (!scope || typeof scope.querySelectorAll !== "function") return;

    ensureMarkdownBadgeStyles();

    scope.querySelectorAll("img[src]").forEach((img) => {
      const info = parseShieldsBadgeUrl(img.getAttribute("src") || "");
      if (!info) return;

      img.replaceWith(
        createMarkdownBadge(info, img.getAttribute("alt") || "")
      );
    });
  }

  function escapeInlineMarkdownCodeSource(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  }

  function inlineMarkdownCodeMayContainMarkdown(value) {
    const text = String(value == null ? "" : value);

    return /(\[[^\]]+\]\([^)]+\)|\*\*|__|\*|_|~~)/.test(text);
  }

  function isSafeInlineMarkdownLinkHref(value) {
    const href = String(value == null ? "" : value).trim();

    if (!href) return false;

    if (
      href.startsWith("#") ||
      href.startsWith("/") ||
      href.startsWith("./") ||
      href.startsWith("../")
    ) {
      return true;
    }

    try {
      const url = new URL(href, document.baseURI);

      return (
        url.protocol === "http:" ||
        url.protocol === "https:" ||
        url.protocol === "mailto:" ||
        url.protocol === "tel:"
      );
    } catch {
      return false;
    }
  }

  function cloneSafeInlineMarkdownChildren(sourceNode) {
    const frag = document.createDocumentFragment();

    sourceNode.childNodes.forEach((child) => {
      frag.appendChild(cloneSafeInlineMarkdownNode(child));
    });

    return frag;
  }

  function cloneSafeInlineMarkdownNode(sourceNode) {
    if (sourceNode.nodeType === Node.TEXT_NODE) {
      return document.createTextNode(sourceNode.nodeValue || "");
    }

    if (sourceNode.nodeType !== Node.ELEMENT_NODE) {
      return document.createTextNode("");
    }

    const tag = sourceNode.tagName.toLowerCase();

    if (tag === "br") {
      return document.createElement("br");
    }

    if (tag === "strong" || tag === "b") {
      const strong = document.createElement("strong");
      strong.appendChild(cloneSafeInlineMarkdownChildren(sourceNode));
      return strong;
    }

    if (tag === "em" || tag === "i") {
      const em = document.createElement("em");
      em.appendChild(cloneSafeInlineMarkdownChildren(sourceNode));
      return em;
    }

    if (tag === "del" || tag === "s") {
      const del = document.createElement("del");
      del.appendChild(cloneSafeInlineMarkdownChildren(sourceNode));
      return del;
    }

    if (tag === "a") {
      const href = sourceNode.getAttribute("href") || "";

      if (!isSafeInlineMarkdownLinkHref(href)) {
        return cloneSafeInlineMarkdownChildren(sourceNode);
      }

      const a = document.createElement("a");
      a.setAttribute("href", href);

      const title = sourceNode.getAttribute("title");
      if (title) {
        a.setAttribute("title", title);
      }

      a.appendChild(cloneSafeInlineMarkdownChildren(sourceNode));
      return a;
    }

    return cloneSafeInlineMarkdownChildren(sourceNode);
  }

  function transformInlineMarkdownCode(scope) {
    if (!scope || typeof scope.querySelectorAll !== "function") return;
    if (!(window.marked && typeof window.marked.parseInline === "function")) return;

    scope.querySelectorAll("code").forEach((codeEl) => {
      if (codeEl.closest("pre")) return;
      if (codeEl.dataset.inlineMarkdownCode === "1") return;

      const source = codeEl.textContent || "";

      if (!inlineMarkdownCodeMayContainMarkdown(source)) return;

      const html = window.marked.parseInline(
        escapeInlineMarkdownCodeSource(source)
      );

      const host = document.createElement("span");
      host.innerHTML = html;

      if (!host.querySelector("a,strong,b,em,i,del,s")) return;

      codeEl.replaceChildren(cloneSafeInlineMarkdownChildren(host));
      codeEl.dataset.inlineMarkdownCode = "1";
    });
  }

  const buildRenderedFragment = (htmlSource) => {
    const host = document.createElement("div");
    host.innerHTML = htmlSource;

    transformShieldsBadges(host);
    transformInlineMarkdownCode(host);
    renderMath(host);

    const frag = document.createDocumentFragment();

    while (host.firstChild) {
      frag.appendChild(host.firstChild);
    }

    return frag;
  };

  const replaceRenderedHtml = (target, htmlSource) => {
    if (!target) return;
    target.replaceChildren(buildRenderedFragment(htmlSource));
  };

  const GITHUB_ALERT_TYPES = new Set([
    "note",
    "tip",
    "important",
    "warning",
    "caution"
  ]);

  function getGithubAlertTypeFromText(text) {
    const normalized = String(text == null ? "" : text)
      .replace(/\u00A0/g, " ")
      .replace(/\r\n?/g, "\n")
      .trimStart();

    const match = normalized.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](?:\s|$)/i);
    if (!match) return null;

    const type = match[1].toLowerCase();
    return GITHUB_ALERT_TYPES.has(type) ? type : null;
  }

  function stripGithubAlertMarker(paragraph) {
    if (!paragraph) return false;

    const walker = document.createTreeWalker(
      paragraph,
      NodeFilter.SHOW_TEXT,
      null
    );

    const textNodes = [];

    while (walker.nextNode()) {
      textNodes.push(walker.currentNode);
    }

    for (const textNode of textNodes) {
      if (!textNode.nodeValue || !textNode.nodeValue.trim()) {
        continue;
      }

      const replaced = textNode.nodeValue.replace(
        /^\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](?:\s*)/i,
        ""
      );

      if (replaced !== textNode.nodeValue) {
        textNode.nodeValue = replaced;
        return true;
      }

      return false;
    }

    return false;
  }

  function paragraphIsEmpty(paragraph) {
    if (!paragraph) return true;

    const text = (paragraph.textContent || "")
      .replace(/\u00A0/g, " ")
      .trim();

    if (text) return false;

    return !paragraph.querySelector(
      "img,svg,video,audio,table,pre,code,ul,ol,dl,blockquote"
    );
  }

  function createAlertSvg(type) {
    const ns = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(ns, "svg");

    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("width", "16");
    svg.setAttribute("height", "16");
    svg.setAttribute("aria-hidden", "true");

    const path = document.createElementNS(ns, "path");
    path.setAttribute("fill", "currentColor");

    const pathMap = {
      note: "M11 7h2v2h-2V7zm0 4h2v6h-2v-6zm1-9C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z",
      tip: "M9 21h6v-1H9v1zm3-19C8.14 2 5 5.14 5 9c0 2.38 1.19 4.47 3 5.74V17c0 .55.45 1 1 1h6c.55 0 1-.45 1-1v-2.26c1.81-1.27 3-3.36 3-5.74 0-3.86-3.14-7-7-7zm2.85 11.1-.85.6V16h-4v-2.29l-.85-.6C8 12.22 7 10.7 7 9c0-2.76 2.24-5 5-5s5 2.24 5 5c0 1.7-1 3.22-2.15 4.1z",
      important: "M4 4h16v12H7.17L4 19.17V4zm7 2v5h2V6h-2zm0 7v2h2v-2h-2z",
      warning: "M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z",
      caution: "M8.27 3h7.46L21 8.27v7.46L15.73 21H8.27L3 15.73V8.27L8.27 3zM11 7h2v6h-2V7zm0 8h2v2h-2v-2z"
    };

    path.setAttribute("d", pathMap[type] || pathMap.note);
    svg.appendChild(path);

    return svg;
  }

  function transformGithubAlerts(scope) {
    if (!scope || typeof scope.querySelectorAll !== "function") return;

    const blockquotes = Array.from(scope.querySelectorAll("blockquote"));

    blockquotes.forEach((blockquote) => {
      if (!blockquote.isConnected) return;

      const children = Array.from(blockquote.childNodes).filter((node) => {
        return !(node.nodeType === Node.TEXT_NODE && !node.nodeValue.trim());
      });

      if (!children.length) return;

      let type = "quote";
      let showTitle = false;

      const firstNode = children[0];

      if (firstNode.nodeType === Node.ELEMENT_NODE && firstNode.tagName === "P") {
        const firstParagraph = firstNode;
        const githubType = getGithubAlertTypeFromText(firstParagraph.textContent || "");

        if (githubType) {
          type = githubType;
          showTitle = true;

          stripGithubAlertMarker(firstParagraph);

          if (paragraphIsEmpty(firstParagraph)) {
            firstParagraph.remove();
          }
        }
      }

      const alert = document.createElement("div");
      alert.className = "md-alert md-alert-" + type;
      alert.dataset.alertType = type;

      if (showTitle) {
        const title = document.createElement("div");
        title.className = "md-alert-title";

        const label = document.createElement("span");
        label.className = "md-alert-label";
        label.textContent = getDisplayAlertLabel(type);

        title.appendChild(createAlertSvg(type));
        title.appendChild(label);

        alert.appendChild(title);
      }

      const content = document.createElement("div");
      content.className = "md-alert-content";

      while (blockquote.firstChild) {
        content.appendChild(blockquote.firstChild);
      }

      alert.appendChild(content);

      blockquote.replaceWith(alert);
    });
  }

  const enhanceTables = (scope) => {
    if (!scope || typeof scope.querySelectorAll !== "function") return;

    scope.querySelectorAll("table").forEach((table) => {
      table.classList.add("md-table");

      const parent = table.parentElement;

      if (parent && parent.classList && parent.classList.contains("md-table-wrap")) {
        return;
      }

      const wrapper = document.createElement("div");
      wrapper.className = "md-table-wrap";

      table.parentNode.insertBefore(wrapper, table);
      wrapper.appendChild(table);
    });
  };

  const html = buildHtml(mdClean);
  const reasoningHtml = reasoningClean ? buildHtml(reasoningClean) : "";

  let mount;
  let block;
  let isNewBlock = false;

  if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.ensureActiveResponse === "function") {
    const ensured = window.ResponseRenderBatch.ensureActiveResponse(
      pairIdClean,
      "assistant-message display-block"
    );

    mount = ensured.mount;
    block = ensured.block;
    isNewBlock = !!ensured.isNewBlock;
  } else {
    mount = document.getElementById("ResponseContent");
    if (!mount) {
      mount = document.createElement("div");
      mount.id = "ResponseContent";
      document.body.appendChild(mount);
    }

    let existingBlock = null;

    for (const node of mount.children) {
      if (node.nodeType === 1 && node.id === "assistant-stream-block") {
        existingBlock = node;
        break;
      }
    }

    if (existingBlock && existingBlock !== mount.lastElementChild) {
      existingBlock.removeAttribute("id");
      existingBlock = null;
    }

    if (existingBlock && existingBlock.dataset && (existingBlock.dataset.pairId || "") !== pairIdClean) {
      existingBlock.removeAttribute("id");
      existingBlock = null;
    }

    if (!existingBlock) {
      existingBlock = document.createElement("div");
      existingBlock.className = "assistant-message display-block";
      existingBlock.id = "assistant-stream-block";
      mount.appendChild(existingBlock);
      isNewBlock = true;
    }

    block = existingBlock;
  }

  block.className = "assistant-message display-block";
  block.dataset.kind = "display";
  block.dataset.pairId = pairIdClean;

  const getActiveThought = () => {
    let currentBlock = null;

    if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.getActiveStreamBlock === "function") {
      currentBlock = window.ResponseRenderBatch.getActiveStreamBlock(mount);
    } else {
      for (const node of mount.children) {
        if (node.nodeType === 1 && node.id === "assistant-stream-block") {
          currentBlock = node;
          break;
        }
      }
    }

    if (currentBlock) {
      const thought = currentBlock.querySelector(".thought-container");
      if (thought) return thought;
    }

    const allThoughts = mount.querySelectorAll(".thought-container");
    return allThoughts.length ? allThoughts[allThoughts.length - 1] : null;
  };

  const setThoughtOpen = (thought, open) => {
    if (!thought) return false;

    thought.classList.toggle("open", !!open);
    return true;
  };

  const toggleThought = (thought) => {
    if (!thought) return false;

    thought.classList.toggle("open");
    return thought.classList.contains("open");
  };

  window.DisplayTemplate = window.DisplayTemplate || {};

  window.DisplayTemplate.setReasoningOpen = (open) => {
    return setThoughtOpen(getActiveThought(), open);
  };

  window.DisplayTemplate.expandReasoning = () => {
    return setThoughtOpen(getActiveThought(), true);
  };

  window.DisplayTemplate.collapseReasoning = () => {
    return setThoughtOpen(getActiveThought(), false);
  };

  window.DisplayTemplate.toggleReasoning = () => {
    return toggleThought(getActiveThought());
  };

  const wasStreaming = block.dataset.streaming === "true";
  const isStartingStream = isStreamCall && (resetResponse || !wasStreaming || isNewBlock);

  if (isStartingStream) {
    block.__mdSource = "";
    block.__reasoningSource = "";
  }

  block.dataset.streaming = isStreamCall ? "true" : "false";

  const ensureThought = (targetBlock) => {
    let thought = targetBlock.querySelector(".thought-container");

    if (thought) return applyReasoningDisplayBlockClasses(thought);

    const reasoningBlock = createReasoningDisplayBlock(
      getDisplayReasoningTitle(),
      (node) => {
        toggleThought(node);
      }
    );
    thought = reasoningBlock.container;

    targetBlock.prepend(thought);

    return thought;
  };

  const renderReasoningSource = (targetBlock, source) => {
    let thought = targetBlock.querySelector(".thought-container");

    if (!source) {
      if (thought) thought.remove();
      return;
    }

    thought = ensureThought(targetBlock);

    const content = thought.querySelector(".thought-content");
    replaceRenderedHtml(content, buildHtml(source));
  };

  const ensureResponse = (targetBlock) => {
    let response = targetBlock.querySelector(".assistant-response");

    if (!response) {
      response = document.createElement("div");
      response.className = "assistant-response";
      targetBlock.appendChild(response);
    }

    return response;
  };

  const hasPythiaStructuredResponseContent = (targetResponse) => {
    if (!targetResponse || typeof targetResponse.querySelector !== "function") {
      return false;
    }

    return !!targetResponse.querySelector(
      ":scope > .pythia-response-section, :scope > .pythia-display-block-list"
    );
  };

  const resolveStreamSection =
    window.DisplayTemplate && typeof window.DisplayTemplate.__resolveStreamSection === "function"
      ? window.DisplayTemplate.__resolveStreamSection
      : null;

  const ensureStreamResponseContent = (targetResponse) => {

    if (resolveStreamSection) {
      return resolveStreamSection(targetResponse);
    }

    let content = targetResponse.querySelector(":scope > .assistant-response-stream-content");
    if (!content) {
      content = document.createElement("div");
      content.className = "assistant-response-stream-content";
      targetResponse.prepend(content);
    }
    return { section: null, content: content };
  };

  if (isStreamCall) {
    block.__reasoningSource = (block.__reasoningSource || "") + reasoningClean;
  } else {
    block.__reasoningSource = reasoningClean;
  }

  renderReasoningSource(block, block.__reasoningSource);

  let response = ensureResponse(block);

  if (isStreamCall) {
    if (
      resetResponse ||
      (isStartingStream && !hasPythiaStructuredResponseContent(response))
    ) {
      response.replaceChildren();
    }

    const resolved = ensureStreamResponseContent(response);
    const streamContent = resolved.content;
    const sectionEl = resolved.section;

    const accumulatorOwner = sectionEl || block;
    accumulatorOwner.__mdSource = (accumulatorOwner.__mdSource || "") + mdClean;
    replaceRenderedHtml(streamContent, buildHtml(accumulatorOwner.__mdSource));

    block.__mdSource = (block.__mdSource || "") + mdClean;
  } else {
    block.__mdSource = mdClean;

    if (wasStreaming) {
      replaceRenderedHtml(response, buildHtml(block.__mdSource));
    } else {
      const frag = buildRenderedFragment(html);
      response.appendChild(frag);
    }
  }

  let displaySelectorHost = block.querySelector(".display-selector-host");

  if (!displaySelectorHost) {
    displaySelectorHost = document.createElement("div");
    displaySelectorHost.className = "display-selector-host";
  }

  block.appendChild(displaySelectorHost);

  if (window.ensureDisplaySelector) {
    window.ensureDisplaySelector(block);
  }

  transformGithubAlerts(block);
  enhanceTables(block);

  const usedIds = new Set();

  function hasIdInMount(targetMount, idValue) {
    return !!targetMount.querySelector(
      '[id="' + String(idValue).replace(/"/g, '\\"') + '"]'
    );
  }

  function getElementByIdInMount(targetMount, idValue) {
    const id = String(idValue == null ? "" : idValue);
    if (!id) return null;

    const root = targetMount || document;
    const doc = root.ownerDocument || document;

    const found = doc.getElementById(id);

    if (found && (root === document || root.contains(found))) {
      return found;
    }

    return null;
  }

  function decodeInternalAnchorId(value) {
    const raw = String(value == null ? "" : value).trim();

    try {
      return decodeURIComponent(raw);
    } catch {
      return raw;
    }
  }

  function normalizeInternalAnchorId(value) {
    const decoded = decodeInternalAnchorId(value);

    if (window.slugify) {
      return window.slugify(decoded);
    }

    return decoded
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-");
  }

  function resolveInternalAnchorId(targetMount, idValue) {
    const rawId = decodeInternalAnchorId(idValue);
    if (!rawId) return "";

    const candidates = [
      rawId,
      rawId.replace(/-+/g, "-"),
      normalizeInternalAnchorId(rawId)
    ];

    for (const candidate of candidates) {
      if (candidate && getElementByIdInMount(targetMount, candidate)) {
        return candidate;
      }
    }

    return normalizeInternalAnchorId(rawId) || rawId;
  }

  function getDisplayTemplateAnchorMount() {
    if (
      window.ResponseRenderBatch &&
      typeof window.ResponseRenderBatch.getMount === "function"
    ) {
      const runtimeMount = window.ResponseRenderBatch.getMount();

      if (runtimeMount && runtimeMount.nodeType === 1) {
        return runtimeMount;
      }
    }

    return document.getElementById("ResponseContent") || document;
  }

  function getCurrentScrollTop() {
    return Math.max(
      window.pageYOffset || 0,
      document.documentElement.scrollTop || 0,
      document.body.scrollTop || 0
    );
  }

  function buildInternalAnchorUrl(idValue) {
    const id = String(idValue == null ? "" : idValue);

    return getInternalAnchorBaseUrl() + "#" + encodeURIComponent(id);
  }

  function getCurrentHistoryState() {
    const state = window.history ? window.history.state : null;

    if (state && typeof state === "object") {
      try {
        return Object.assign({}, state);
      } catch {}
    }

    return {};
  }

  function createInternalAnchorHistorySession() {
    window.__displayTemplateAnchorHistorySession =
      "dt-anchor-" +
      Date.now().toString(36) +
      "-" +
      Math.random().toString(36).slice(2);

    return String(window.__displayTemplateAnchorHistorySession);
  }

  function getInternalAnchorHistorySession() {
    if (!window.__displayTemplateAnchorHistorySession) {
      return createInternalAnchorHistorySession();
    }

    return String(window.__displayTemplateAnchorHistorySession);
  }

  function getInternalAnchorBaseUrl() {
    return window.location.href.replace(/#.*$/, "");
  }

  function resetInternalAnchorHistory() {
    const session = createInternalAnchorHistorySession();

    window.__displayTemplateAnchorHistoryInitialized = true;
    window.__displayTemplateAnchorHistoryHasLocalEntries = false;

    if (!window.history || typeof window.history.replaceState !== "function") {
      return false;
    }

    try {
      const state = getCurrentHistoryState();

      state.displayTemplateAnchor = "";
      state.displayTemplateScrollTop = 0;
      state.displayTemplateAnchorSession = session;
      state.displayTemplateAnchorReset = true;
      state.displayTemplateAnchorHasLocalEntries = false;

      window.history.replaceState(
        state,
        "",
        getInternalAnchorBaseUrl()
      );

      return true;
    } catch {
      return false;
    }
  }

  function ensureInitialInternalAnchorHistoryState() {
    if (window.__displayTemplateAnchorHistoryInitialized) {
      return;
    }

    window.__displayTemplateAnchorHistoryInitialized = true;

    if (!window.history || typeof window.history.replaceState !== "function") {
      return;
    }

    try {
      const state = getCurrentHistoryState();

      state.displayTemplateAnchor = decodeInternalAnchorId(
        window.location.hash.replace(/^#/, "")
      );

      state.displayTemplateScrollTop = getCurrentScrollTop();
      state.displayTemplateAnchorSession = getInternalAnchorHistorySession();

      window.history.replaceState(state, "", window.location.href);
    } catch {}
  }

  function scrollToInternalAnchorId(idValue, options) {
    const targetMount = getDisplayTemplateAnchorMount();
    const id = resolveInternalAnchorId(targetMount, idValue);

    if (!id) return false;

    const target = getElementByIdInMount(targetMount, id);

    if (!target) return false;

    target.scrollIntoView({
      behavior: options && options.smooth === false ? "auto" : "smooth",
      block: "start"
    });

    return true;
  }

  function pushInternalAnchorHistory(idValue) {
    if (!window.history || typeof window.history.pushState !== "function") {
      return;
    }

    const targetMount = getDisplayTemplateAnchorMount();
    const id = resolveInternalAnchorId(targetMount, idValue);

    if (!id || !getElementByIdInMount(targetMount, id)) {
      return;
    }

    try {
      ensureInitialInternalAnchorHistoryState();

      const currentId = resolveInternalAnchorId(
        targetMount,
        window.location.hash.replace(/^#/, "")
      );

      const state = getCurrentHistoryState();

      window.__displayTemplateAnchorHistoryHasLocalEntries = true;

      state.displayTemplateAnchor = id;
      state.displayTemplateScrollTop = getCurrentScrollTop();
      state.displayTemplateAnchorSession = getInternalAnchorHistorySession();
      state.displayTemplateAnchorHasLocalEntries = true;

      if (currentId === id) {
        window.history.replaceState(state, "", buildInternalAnchorUrl(id));
      } else {
        window.history.pushState(state, "", buildInternalAnchorUrl(id));
      }
    } catch {}
  }

  function restoreInternalAnchorFromHistory(event) {
    const state =
      event && event.state && typeof event.state === "object"
        ? event.state
        : null;

    const scrollTopBeforeRestore = getCurrentScrollTop();

    const expectedSession = getInternalAnchorHistorySession();
    const stateSession =
      state && state.displayTemplateAnchorSession
        ? String(state.displayTemplateAnchorSession)
        : "";

    if (stateSession && stateSession !== expectedSession) {
      window.requestAnimationFrame(() => {
        try {
          if (window.history && typeof window.history.replaceState === "function") {
            const neutralState = getCurrentHistoryState();

            neutralState.displayTemplateAnchor = "";
            neutralState.displayTemplateScrollTop = scrollTopBeforeRestore;
            neutralState.displayTemplateAnchorSession = expectedSession;
            neutralState.displayTemplateAnchorReset = true;
            neutralState.displayTemplateAnchorHasLocalEntries =
              !!window.__displayTemplateAnchorHistoryHasLocalEntries;

            window.history.replaceState(
              neutralState,
              "",
              getInternalAnchorBaseUrl()
            );
          }

          window.scrollTo(0, scrollTopBeforeRestore);
        } catch {}
      });

      return;
    }

    const hashId = decodeInternalAnchorId(
      window.location.hash.replace(/^#/, "")
    );

    if (hashId) {
      window.requestAnimationFrame(() => {
        scrollToInternalAnchorId(hashId, { smooth: false });
      });

      return;
    }

    const scrollTop = state && Number(state.displayTemplateScrollTop);

    if (Number.isFinite(scrollTop)) {
      window.requestAnimationFrame(() => {
        window.scrollTo(0, scrollTop);
      });
    }
  }

  function ensureInternalAnchorHistoryNavigation() {
    if (window.__displayTemplateAnchorHistoryBound) {
      return;
    }

    window.__displayTemplateAnchorHistoryBound = true;

    try {
      if (
        window.history &&
        "scrollRestoration" in window.history
      ) {
        window.history.scrollRestoration = "manual";
      }
    } catch {}

    document.addEventListener("click", function (event) {
      if (
        event.defaultPrevented ||
        event.button !== 0 ||
        event.metaKey ||
        event.ctrlKey ||
        event.shiftKey ||
        event.altKey
      ) {
        return;
      }

      const target =
        event.target && event.target.nodeType === 1
          ? event.target
          : event.target && event.target.parentElement
            ? event.target.parentElement
            : null;

      if (!target || typeof target.closest !== "function") {
        return;
      }

      const link = target.closest('a[href^="#"]');

      if (!link) {
        return;
      }

      const href = link.getAttribute("href") || "";
      let id = href.substring(1).trim();

      if (!id && window.slugify) {
        id = window.slugify(link.textContent || "");
      }

      const targetMount = getDisplayTemplateAnchorMount();
      id = resolveInternalAnchorId(targetMount, id);

      if (!id || !getElementByIdInMount(targetMount, id)) {
        return;
      }

      event.preventDefault();
      event.stopPropagation();

      link.setAttribute("href", "#" + id);

      pushInternalAnchorHistory(id);
      scrollToInternalAnchorId(id, { smooth: true });
    }, true);

    window.addEventListener("popstate", restoreInternalAnchorFromHistory);
  }

  window.DisplayTemplate.resetAnchorHistory = resetInternalAnchorHistory;

  block.querySelectorAll("h1, h2, h3, h4, h5, h6").forEach((el) => {
    let baseId = window.slugify ? window.slugify(el.textContent) : el.textContent;
    if (!baseId) baseId = "section";

    let finalId = baseId;
    let i = 2;

    while (hasIdInMount(mount, finalId) || usedIds.has(finalId)) {
      finalId = baseId + "-" + i;
      i++;
    }

    el.id = finalId;
    usedIds.add(finalId);
  });

  block.querySelectorAll('a[href^="#"]').forEach((a) => {
    const text = a.textContent || "";
    const href = a.getAttribute("href") || "";
    let id = href.substring(1).trim();

    if (!id && window.slugify) {
      id = window.slugify(text);
    }

    id = resolveInternalAnchorId(mount, id);

    if (id) {
      a.setAttribute("href", "#" + id);
    }
  });

  ensureInternalAnchorHistoryNavigation();

  const canClipboard = !!(navigator.clipboard && navigator.clipboard.writeText);

  const createIcon = (type) => {
    const ns = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(ns, "svg");

    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("width", "16");
    svg.setAttribute("height", "16");
    svg.setAttribute("aria-hidden", "true");

    const path = document.createElementNS(ns, "path");
    path.setAttribute("fill", "currentColor");

    path.setAttribute(
      "d",
      type === "check"
        ? "M9 16.2l-3.5-3.5L4 14.2l5 5 12-12-1.5-1.5z"
        : "M16 1H4c-1.1 0-2 .9-2 2v12h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"
    );

    svg.appendChild(path);

    return svg;
  };

  /* Scrollbars */

  if (!document.getElementById("code-scrollbar-style")) {
    const style = document.createElement("style");
    style.id = "code-scrollbar-style";

    style.textContent = `
      .code-container pre,
      .code-container code,
      .code-container code.hljs {
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb,#4a4a4a) transparent;
      }

      .code-container pre::-webkit-scrollbar,
      .code-container code::-webkit-scrollbar,
      .code-container code.hljs::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }

      .code-container pre::-webkit-scrollbar-track,
      .code-container code::-webkit-scrollbar-track,
      .code-container code.hljs::-webkit-scrollbar-track {
        background: transparent;
      }

      .code-container pre::-webkit-scrollbar-thumb,
      .code-container code::-webkit-scrollbar-thumb,
      .code-container code.hljs::-webkit-scrollbar-thumb {
        background: var(--scrollbar-thumb,#4a4a4a);
        border-radius: 6px;
      }

      .code-container pre::-webkit-scrollbar-thumb:hover,
      .code-container code::-webkit-scrollbar-thumb:hover,
      .code-container code.hljs::-webkit-scrollbar-thumb:hover {
        background: var(--scrollbar-thumb-hover,#6a6a6a);
      }
    `;

    document.head.appendChild(style);
  }

  /* Copy button */

  const makeCopyBtn = () => {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "copy-btn";
    btn.dataset.displayTemplateCopy = "1";
    btn.dataset.copyState = "false";

    btn.setAttribute("aria-live", "polite");
    btn.setAttribute("title", getDisplayCodeCopyToClipboardTitle());
    btn.setAttribute("aria-label", getDisplayCodeCopyToClipboardTitle());

    Object.assign(btn.style, {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      gap: "0",
      minWidth: "24px",
      height: "24px",
      padding: "0",
      borderRadius: "6px",

      border: "none",
      outline: "none",
      boxShadow: "none",

      background: "transparent",
      color: "var(--code-header-text)",

      cursor: "pointer",

      font: "12px system-ui, -apple-system, Segoe UI, Roboto, sans-serif",

      userSelect: "none",
      transition: "transform 120ms ease, opacity 120ms ease"
    });

    const label = document.createElement("span");
    label.className = "copy-btn-label";
    label.textContent = "";
    label.style.display = "none";

    btn.appendChild(createIcon("copy"));
    btn.appendChild(label);

    btn.addEventListener("pointerdown", () => {
      btn.style.transform = "scale(0.98)";
    }, { passive: true });

    btn.addEventListener("pointerup", () => {
      btn.style.transform = "scale(1)";
    }, { passive: true });

    btn.__setCopied = (on) => {
      if (!on) {
        return;
      }

      if (btn.__copiedTimer) {
        clearTimeout(btn.__copiedTimer);
        btn.__copiedTimer = null;
      }

      btn.dataset.copyState = "true";
      label.textContent = getDisplayCodeCopiedLabel();
      label.style.display = "";
      btn.style.gap = "6px";

      btn.replaceChild(createIcon("check"), btn.firstChild);

      btn.disabled = true;
      btn.style.opacity = "0.92";

      if (typeof btn.__updateFloatingCopyPosition === "function") {
        btn.__updateFloatingCopyPosition();
      }

      btn.__copiedTimer = setTimeout(() => {
        btn.dataset.copyState = "false";
        label.textContent = "";
        label.style.display = "none";
        btn.style.gap = "0";

        btn.replaceChild(createIcon("copy"), btn.firstChild);

        btn.disabled = false;
        btn.style.opacity = "1";
        btn.__copiedTimer = null;

        if (typeof btn.__updateFloatingCopyPosition === "function") {
          btn.__updateFloatingCopyPosition();
        }

        if (typeof btn.__syncFloatingCopyVisibility === "function") {
          btn.__syncFloatingCopyVisibility();
        }
      }, 2000);
    };

    return btn;
  };

  const bindCodeContainerFloatingCopyButton = (container, btn) => {
    if (!container || !btn || btn.__codeContainerFloatingCopyBound) return;

    btn.__codeContainerFloatingCopyBound = true;

    let hovering = false;
    let raf = 0;
    let pointerX = -1;
    let pointerY = -1;

    const margin = 8;

    const hide = () => {
      hovering = false;

      if (raf) {
        window.cancelAnimationFrame(raf);
        raf = 0;
      }

      btn.style.opacity = "0";
      btn.style.visibility = "hidden";
      btn.style.pointerEvents = "none";

      window.removeEventListener("scroll", scheduleUpdate, true);
      window.removeEventListener("resize", scheduleUpdate, true);
    };

    const pointerIsInside = (rect) => {
      return (
        pointerX >= rect.left &&
        pointerX <= rect.right &&
        pointerY >= rect.top &&
        pointerY <= rect.bottom
      );
    };

    const updatePositionNow = () => {
      raf = 0;

      if (!hovering) {
        hide();
        return;
      }

      const rect = container.getBoundingClientRect();

      if (
        rect.bottom <= 0 ||
        rect.top >= window.innerHeight ||
        rect.right <= 0 ||
        rect.left >= window.innerWidth ||
        !pointerIsInside(rect)
      ) {
        hide();
        return;
      }

      const width = btn.offsetWidth || 24;
      const height = btn.offsetHeight || 24;

      const viewportMaxLeft = Math.max(margin, window.innerWidth - width - margin);
      const viewportMaxTop = Math.max(margin, window.innerHeight - height - margin);

      const left = Math.min(
        Math.max(rect.right - width - margin, margin),
        viewportMaxLeft
      );

      const containerBottomTop = rect.bottom - height - margin;

      const top = Math.min(
        Math.max(
          Math.min(
            Math.max(rect.top + margin, margin),
            containerBottomTop
          ),
          margin
        ),
        viewportMaxTop
      );

      btn.style.left = left + "px";
      btn.style.top = top + "px";
      btn.style.visibility = "visible";
      btn.style.pointerEvents = "auto";
      btn.style.opacity = btn.dataset.copyState === "true" ? "0.92" : "1";
    };

    const scheduleUpdate = () => {
      if (!hovering || raf) return;
      raf = window.requestAnimationFrame(updatePositionNow);
    };

    const show = (event) => {
      hovering = true;

      if (event) {
        pointerX = event.clientX;
        pointerY = event.clientY;
      }

      Object.assign(btn.style, {
        position: "fixed",
        left: "0",
        top: "0",
        zIndex: "2100",
        opacity: "0",
        visibility: "hidden",
        pointerEvents: "none"
      });

      updatePositionNow();

      window.addEventListener("scroll", scheduleUpdate, true);
      window.addEventListener("resize", scheduleUpdate, true);
    };

    const trackPointer = (event) => {
      pointerX = event.clientX;
      pointerY = event.clientY;
      scheduleUpdate();
    };

    Object.assign(btn.style, {
      position: "fixed",
      left: "0",
      top: "0",
      zIndex: "2100",
      opacity: "0",
      visibility: "hidden",
      pointerEvents: "none"
    });

    btn.__updateFloatingCopyPosition = scheduleUpdate;

    btn.__syncFloatingCopyVisibility = () => {
      if (!hovering) {
        btn.style.opacity = "0";
        btn.style.visibility = "hidden";
        btn.style.pointerEvents = "none";
      }
    };

    container.addEventListener("pointerenter", show, { passive: true });
    container.addEventListener("pointermove", trackPointer, { passive: true });
    container.addEventListener("pointerleave", hide, { passive: true });
  };

  const getLang = (codeEl) => {
    const m = (codeEl.className.match(/language-([^\s]+)/) || [])[1];
    return (m || "text").toUpperCase();
  };

  const accentFor = (lang) => ({
    PASCAL: "#4db5ff", DELPHI: "#e64a19", JS: "#3aa0ff", TS: "#2f7de1",
    JSON: "#8a6cff", HTML: "#ff8a3d", CSS: "#00b894", SQL: "#ffb020",
    SH: "#27ae60", BASH: "#27ae60", PY: "#ffd43b", PYTHON: "#ffd43b",
    CPP: "#5e97d0", C: "#5e97d0", CS: "#239120", JAVA: "#ea2f2f",
  }[lang] || "#6aa9ff");

  function ensurePlainCodeBlockStyles() {
    if (document.getElementById("md-plain-code-style")) return;

    const style = document.createElement("style");
    style.id = "md-plain-code-style";

    style.textContent = `
      .assistant-response .md-plain-code-container,
      .thought-content .md-plain-code-container {
        position: relative;
        margin: 1rem 0;
        border-radius: 12px;
        border: 1px solid var(--code-border);
        /*box-shadow: 0 8px 24px rgba(0,0,0,0.20);*/
        box-shadow: none;
        overflow: hidden;
        background: var(--code-container-bg, var(--code-header-bg));
      }

      .assistant-response .md-plain-code-container pre,
      .thought-content .md-plain-code-container pre {
        margin: 0;
        padding: 1em;
        overflow: auto;
        background: transparent !important;
        border-radius: 12px;
        white-space: pre;
        box-sizing: border-box;

        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb,#4a4a4a) transparent;
      }

      .assistant-response .md-plain-code-container code,
      .thought-content .md-plain-code-container code {
        display: block;
        background: transparent !important;
        white-space: pre;
      }

      .assistant-response .md-plain-code-copy,
      .thought-content .md-plain-code-copy {
        z-index: 2100;
      }

      .md-plain-code-container pre::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }

      .md-plain-code-container pre::-webkit-scrollbar-track {
        background: transparent;
      }

      .md-plain-code-container pre::-webkit-scrollbar-thumb {
        background: var(--scrollbar-thumb,#4a4a4a);
        border-radius: 6px;
      }

      .md-plain-code-container pre::-webkit-scrollbar-thumb:hover {
        background: var(--scrollbar-thumb-hover,#6a6a6a);
      }
    `;

    document.head.appendChild(style);
  }

  const enhancePlainCodeBlocks = (scope) => {
    if (!scope || typeof scope.querySelectorAll !== "function") return;

    const plainCodeBlocks = Array.from(scope.querySelectorAll("pre > code"))
      .filter((codeEl) => {
        const className = String(codeEl.getAttribute("class") || "");
        return !/\blanguage-[^\s]+/.test(className);
      });

    if (!plainCodeBlocks.length) return;

    ensurePlainCodeBlockStyles();

    plainCodeBlocks.forEach((codeEl) => {
      const pre = codeEl.parentElement;
      if (!pre) return;

      const parent = pre.parentElement;

      if (
        parent &&
        parent.classList &&
        (
          parent.classList.contains("code-container") ||
          parent.classList.contains("md-plain-code-container")
        )
      ) {
        return;
      }

      const container = document.createElement("div");
      container.className = "md-plain-code-container";

      const copyBtn = makeCopyBtn();
      copyBtn.classList.add("md-plain-code-copy");

      pre.parentNode.insertBefore(container, pre);
      container.appendChild(pre);
      container.appendChild(copyBtn);

      bindCodeContainerFloatingCopyButton(container, copyBtn);

      pre.classList.add("md-plain-code-pre");
      codeEl.classList.add("md-plain-code-content");

      copyBtn.onclick = async () => {
        const text = codeEl.textContent || "";
        const lang = "TEXT";
        let ok = false;

        if (canClipboard) {
          try { await navigator.clipboard.writeText(text); ok = true; } catch {}
        }

        if (!ok) {
          try {
            const ta = document.createElement("textarea");

            ta.value = text;

            Object.assign(ta.style, {
              position: "fixed",
              top: "-1000px",
              opacity: "0"
            });

            document.body.appendChild(ta);

            ta.focus();
            ta.select();

            ok = document.execCommand("copy");

            ta.remove();
          } catch {}
        }

        if (ok) copyBtn.__setCopied(true);

        if (window.chrome && window.chrome.webview && window.chrome.webview.postMessage) {
          try {
            window.chrome.webview.postMessage({
              event: "copy",
              lang,
              text,
              success: !!ok
            });
          } catch {}
        }
      };
    });
  };

  enhancePlainCodeBlocks(block);

  block
    .querySelectorAll('pre > code[class*="language-"]')
    .forEach((codeEl) => {
      const pre = codeEl.parentElement;

      if (pre.parentElement && pre.parentElement.classList && pre.parentElement.classList.contains("code-container")) {
        return;
      }

      const lang = getLang(codeEl);
      const accent = accentFor(lang);

      const container = document.createElement("div");
      container.className = "code-container";

      Object.assign(container.style, {
        margin: "1rem 0",
        borderRadius: "10px",

        border: "1px solid var(--code-border)",

        /*boxShadow: "0 8px 24px rgba(0,0,0,0.20)",*/
        boxShadow: "none",

        overflow: "hidden",
        background: "var(--code-container-bg, var(--code-header-bg))"
      });

      const header = document.createElement("div");
      header.className = "code-header";

      Object.assign(header.style, {
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        gap: "0.75rem",

        padding: "8px 10px 6px 10px",

        borderBottom: "none",
        background: "var(--code-header-bg)",

        color: "var(--code-header-text)",

        font: "12px system-ui, -apple-system, Segoe UI, Roboto, sans-serif"
      });

      const titleWrap = document.createElement("div");

      titleWrap.style.display = "inline-flex";
      titleWrap.style.alignItems = "center";
      titleWrap.style.gap = "6px";

      const accentDot = document.createElement("span");

      Object.assign(accentDot.style, {
        display: "inline-block",
        width: "6px",
        height: "6px",

        borderRadius: "999px",
        background: accent
      });

      const langTitle = document.createElement("span");

      langTitle.textContent = lang.toLowerCase();
      langTitle.style.fontWeight = "500";
      langTitle.style.fontSize = "11px";
      langTitle.style.lineHeight = "1";
      langTitle.style.letterSpacing = "0";
      langTitle.style.color = "var(--code-language-text, #808080)";

      titleWrap.appendChild(accentDot);
      titleWrap.appendChild(langTitle);

      const copyBtn = makeCopyBtn();

      header.appendChild(titleWrap);
      header.appendChild(copyBtn);

      pre.parentNode.insertBefore(container, pre);
      container.appendChild(header);
      container.appendChild(pre);

      bindCodeContainerFloatingCopyButton(container, copyBtn);

      pre.style.margin = "0";
      pre.style.padding = "0rem 0.3rem 0.3rem 0.3rem";

      pre.style.overflow = "auto";
      pre.style.borderRadius = "0 0 12px 12px";

      copyBtn.onclick = async () => {
        const text = codeEl.textContent || "";
        let ok = false;

        if (canClipboard) {
          try { await navigator.clipboard.writeText(text); ok = true; } catch {}
        }

        if (!ok) {
          try {
            const ta = document.createElement("textarea");

            ta.value = text;

            Object.assign(ta.style, {
              position: "fixed",
              top: "-1000px",
              opacity: "0"
            });

            document.body.appendChild(ta);

            ta.focus();
            ta.select();

            ok = document.execCommand("copy");

            ta.remove();
          } catch {}
        }

        if (ok) copyBtn.__setCopied(true);

        if (window.chrome && window.chrome.webview && window.chrome.webview.postMessage) {
          try {
            window.chrome.webview.postMessage({
              event: "copy",
              lang,
              text,
              success: !!ok
            });
          } catch {}
        }
      };

      if (window.hljs && typeof window.hljs.highlightElement === "function") {
        window.hljs.highlightElement(codeEl);

        codeEl.style.display = "block";

        codeEl.style.overflowX = "auto";
        codeEl.style.overflowY = "hidden";
      }
    });

  if (!window.__displayTemplateI18nBound) {
    window.__displayTemplateI18nBound = true;

    window.addEventListener(DISPLAY_TEMPLATE_I18N_EVENT, function () {
      applyDisplayTemplateDictionary(document);
    });
  }

  applyDisplayTemplateDictionary(block);

  }

  window.DisplayTemplate = window.DisplayTemplate || {};
  window.DisplayTemplate.display = display;
  window.DisplayTemplate.displayStream = displayStream;
  window.DisplayTemplate.displayBlock = displayBlock;
  window.DisplayTemplate.displayBlockStream = displayBlockStream;
  window.DisplayTemplate.displayBlocks = displayBlocks;
  window.DisplayTemplate.runAfterStreams = runAfterDisplayStreams;
  window.DisplayTemplate.cancelStreams = cancelAllDisplayStreamQueues;
  window.display = display;
  window.displayStream = displayStream;
  window.displayBlock = displayBlock;
  window.displayBlockStream = displayBlockStream;
  window.displayBlocks = displayBlocks;

})();
