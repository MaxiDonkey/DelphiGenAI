(function () {

  const INPUT_HOST_ID = "InputHost";
  const RESPONSE_HOST_ID = "ResponseContent";
  const FILES_DRAWER_ROOT_ID = "__delphi_left_dock_root__";
  const MAX_LINES = 8;

  function ensureInputBubble() {

    let integrationFunctionBtn;
    let integrationMcpBtn;
    let integrationSkillsBtn;
    let integrationAgentsBtn;

    let mediaCreateImageBtn;
    let mediaCreateVideoBtn;
    let mediaCreateAudioBtn;
    let mediaSpeechToTextBtn;
    let mediaTextToSpeechBtn;

    let endpointBtn;
    let endpointChatCompletionBtn;
    let endpointChatResponseBtn;
    let endpointMessageBtn;
    let endpointGenerateContentBtn;
    let endpointInteractionsBtn;
    let endpointConversationBtn;
    let customBtn;
    let systemPromptBtn;
    let modelBtn;
    let projectBtn;
    let projectLabel;
    let projectMenu;

    const INPUT_BUBBLE_I18N_EVENT =
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

    function setMenuItemLabel(btn, label) {
      if (!btn) return;

      btn.dataset.label = label;

      const labelSpan = btn.querySelector(".input-menu-item-label");
      if (labelSpan) {
        labelSpan.textContent = label;
      }
    }

    function getEndpointLabel(endpointFeature) {
      if (endpointFeature === "endpoint-chat-completion")
        return t("input.endpoint.chatCompletion", "v1/chat/completion");

      if (endpointFeature === "endpoint-chat-response")
        return t("input.endpoint.chatResponse", "v1/chat/response");

      if (endpointFeature === "endpoint-message")
        return t("input.endpoint.message", "v1/message");

      if (endpointFeature === "endpoint-generate-content")
        return t("input.endpoint.generateContent", ":generateContent");

      if (endpointFeature === "endpoint-interactions")
        return t("input.endpoint.interactions", "v1/interactions");

      if (endpointFeature === "endpoint-conversation")
        return t("input.endpoint.conversation", "v1/conversation");

      return "";
    }

    function getEndpointProviderLabel(endpointFeature) {
      if (endpointFeature === "endpoint-chat-completion")
        return t("input.endpoint.provider.chatCompletion", "OpenAI, DeepSeek, MistralAI");

      if (endpointFeature === "endpoint-chat-response")
        return t("input.endpoint.provider.chatResponse", "OpenAI");

      if (endpointFeature === "endpoint-message")
        return t("input.endpoint.provider.message", "Claude");

      if (endpointFeature === "endpoint-generate-content")
        return t("input.endpoint.provider.generateContent", "Gemini");

      if (endpointFeature === "endpoint-interactions")
        return t("input.endpoint.provider.interactions", "Gemini");

      if (endpointFeature === "endpoint-conversation")
        return t("input.endpoint.provider.conversation", "MistralAI");

      return "";
    }

    function getThinkingLabel(level) {
      if (level === "low")
        return t("input.thinking.low", "Low");

      if (level === "medium")
        return t("input.thinking.medium", "Medium");

      if (level === "high")
        return t("input.thinking.high", "High");

      return "";
    }

    function applyInputBubbleDictionary() {
      textarea.placeholder = t("input.placeholder.askQuestion", "Ask a question...");

      setMenuItemLabel(endpointBtn, t("input.menu.endpoint", "Endpoint"));
      setMenuItemLabel(webResearchBtn, t("input.menu.webResearch", "Web research"));
      setMenuItemLabel(thinkingBtn, t("input.menu.thinking", "Thinking"));
      setMenuItemLabel(fileBtn, t("input.menu.attachFiles", "Attach files"));
      setMenuItemLabel(knowledgeBtn, t("input.menu.knowledgeSearch", "Knowledge search"));
      setMenuItemLabel(visionBtn, t("input.menu.vision", "Vision"));
      setMenuItemLabel(deepResearchBtn, t("input.menu.deepResearch", "Deep Research"));
      setMenuItemLabel(integrationBtn, t("input.menu.integration", "Integration"));
      setMenuItemLabel(mediaBtn, t("input.menu.media", "Media"));
      setMenuItemLabel(customBtn, t("input.menu.custom", "Custom"));

      setMenuItemLabel(integrationFunctionBtn, t("input.integration.function", "Function"));
      setMenuItemLabel(integrationMcpBtn, t("input.integration.mcp", "MCP"));
      setMenuItemLabel(integrationSkillsBtn, t("input.integration.skills", "Skills"));
      setMenuItemLabel(integrationAgentsBtn, t("input.integration.agents", "Agents"));

      setMenuItemLabel(mediaCreateImageBtn, t("input.media.createImage", "Create Image"));
      setMenuItemLabel(mediaCreateVideoBtn, t("input.media.createVideo", "Create Video"));
      setMenuItemLabel(mediaCreateAudioBtn, t("input.media.createAudio", "Create Audio"));
      setMenuItemLabel(mediaSpeechToTextBtn, t("input.media.speechToText", "Speech to text"));
      setMenuItemLabel(mediaTextToSpeechBtn, t("input.media.textToSpeech", "Text to speech"));

      setMenuItemLabel(endpointChatCompletionBtn, t("input.endpoint.chatCompletion", "v1/chat/completion"));
      setMenuItemLabel(endpointChatResponseBtn, t("input.endpoint.chatResponse", "v1/chat/response"));
      setMenuItemLabel(endpointMessageBtn, t("input.endpoint.message", "v1/message"));
      setMenuItemLabel(endpointGenerateContentBtn, t("input.endpoint.generateContent", ":generateContent"));
      setMenuItemLabel(endpointInteractionsBtn, t("input.endpoint.interactions", "v1/interactions"));
      setMenuItemLabel(endpointConversationBtn, t("input.endpoint.conversation", "v1/conversation"));

      endpointChatCompletionBtn.title = t("input.endpoint.provider.chatCompletion", "OpenAI, DeepSeek, MistralAI");
      endpointChatResponseBtn.title = t("input.endpoint.provider.chatResponse", "OpenAI");
      endpointMessageBtn.title = t("input.endpoint.provider.message", "Claude");
      endpointGenerateContentBtn.title = t("input.endpoint.provider.generateContent", "Gemini");
      endpointInteractionsBtn.title = t("input.endpoint.provider.interactions", "Gemini");
      endpointConversationBtn.title = t("input.endpoint.provider.conversation", "MistralAI");

      const thinkingButtons = thinkingMenu.querySelectorAll("button");

      if (thinkingButtons[0])
        setMenuItemLabel(thinkingButtons[0], t("input.thinking.low", "Low"));

      if (thinkingButtons[1])
        setMenuItemLabel(thinkingButtons[1], t("input.thinking.medium", "Medium"));

      if (thinkingButtons[2])
        setMenuItemLabel(thinkingButtons[2], t("input.thinking.high", "High"));

      systemPromptLabel.textContent = t("input.menu.settings", "settings");
      modelLabel.textContent = t("input.menu.model", "model");

      if (host.__updateProjectButtonLabel)
        host.__updateProjectButtonLabel();

      if (host.__renderProjectMenu)
        host.__renderProjectMenu();
    }

    let host = document.getElementById(INPUT_HOST_ID);
    if (!host) {
      host = document.createElement("div");
      host.id = INPUT_HOST_ID;
      document.body.appendChild(host);
    }

    if (host.__inputBubbleInitialized) {
      window.updateInputBubbleLayout && window.updateInputBubbleLayout();
      return;
    }

    host.__inputBubbleInitialized = true;
    host.__features = new Set();
    host.__files = [];
    host.__images = [];
    host.__knowledgeFiles = [];
    host.__speechToTextFiles = [];
    host.__promptFragments = [];
    host.__nextPasteFragmentIndex = 1;
    host.__integrationFunctions = [];
    host.__integrationMcps = [];
    host.__integrationSkills = [];
    host.__integrationAgents = [];
    host.__customItems = [];
    host.__projects = [];
    host.__welcomeText = "";
    host.__sendButtonState = "input-mode";
    host.__sendButtonAvailable = true;

    function buildEnabledFunctionsState() {
      return {
        endpoint: true,
        endpointChatCompletion: true,
        endpointChatResponse: true,
        endpointMessage: true,
        endpointGenerateContent: true,
        endpointInteractions: true,
        endpointConversation: true,

        webResearch: true,

        thinking: true,
        thinkingLow: true,
        thinkingMedium: true,
        thinkingHigh: true,

        chatFiles: true,
        knowledgeSearch: true,
        vision: true,
        deepResearch: true,

        integration: true,
        integrationFunction: true,
        integrationMcp: true,
        integrationSkills: true,
        integrationAgents: true,

        media: true,
        mediaCreateImage: true,
        mediaCreateVideo: true,
        mediaCreateAudio: true,
        mediaSpeechToText: true,
        mediaTextToSpeech: true,

        custom: true,
        systemPrompt: true,
        model: true,
        project: true
      };
    }

    host.__enabledFunctions = buildEnabledFunctionsState();

    const INPUT_HOST_BASE_TRANSITION =
      "left 180ms ease, width 180ms ease, top 220ms ease, bottom 220ms ease";

    const INPUT_HOST_SYNC_TRANSITION =
      "top 220ms ease, bottom 220ms ease";

    let horizontalSyncFrameId = 0;
    let horizontalSyncUntil = 0;
    let horizontalSyncActive = false;

    Object.assign(host.style, {
      position: "fixed",
      left: "50%",
      zIndex: "1000",
      width: "min(760px, calc(100vw - 32px))",
      transform: "translateX(-50%)",
      transition: INPUT_HOST_BASE_TRANSITION
    });

    const welcome = document.createElement("div");
    welcome.id = "InputBubbleWelcome";

    Object.assign(welcome.style, {
      position: "absolute",
      left: "0",
      bottom: "calc(100% + 18px)",
      display: "none",
      width: "100%",
      boxSizing: "border-box",
      padding: "0 12px",
      color: "var(--input-welcome-text, #f3f3f3)",
      fontFamily: '"Segoe UI", sans-serif',
      fontSize: "22px",
      fontWeight: "500",
      lineHeight: "1.3",
      textAlign: "center",
      whiteSpace: "normal",
      overflowWrap: "anywhere",
      pointerEvents: "none",
      userSelect: "none"
    });

    function updateWelcomeVisibility(forceCentered) {
      const hasText = !!(host.__welcomeText && host.__welcomeText.trim());
      const isCentered = typeof forceCentered === "boolean"
        ? forceCentered
        : !hasConversation();

      welcome.textContent = host.__welcomeText || "";
      welcome.style.display = (hasText && isCentered) ? "block" : "none";
    }

    const shell = document.createElement("div");
    shell.id = "InputBubbleShell";

    Object.assign(shell.style, {
      position: "relative",
      display: "flex",
      flexDirection: "column",
      gap: "6px",
      padding: "12px",
      borderRadius: "28px",
      background: "var(--input-shell-bg, #2f2f2f)",
      border: "1px solid var(--input-shell-border, rgba(255,255,255,0.08))",
      boxShadow: "var(--input-shell-shadow, 0 10px 30px rgba(0,0,0,0.35))"
    });

    const filesRow = document.createElement("div");
    filesRow.id = "InputFilesRow";

    Object.assign(filesRow.style, {
      display: "none",
      flexWrap: "wrap",
      gap: "6px",
      padding: "2px 6px"
    });

    const row = document.createElement("div");

    Object.assign(row.style, {
      display: "grid",
      gridTemplateColumns: "48px 1fr 18px 44px 44px",
      gridTemplateRows: "auto auto",
      alignItems: "center",
      gap: "6px"
    });

    const featuresRow = document.createElement("div");
    featuresRow.id = "InputFeaturesRow";

    Object.assign(featuresRow.style, {
      display: "none",
      flexWrap: "wrap",
      gap: "6px",
      padding: "2px 6px"
    });

    const menuBtn = document.createElement("button");
    menuBtn.id = "InputFunctionButton";
    menuBtn.textContent = "\uE710";

    const textarea = document.createElement("textarea");
    textarea.id = "InputBubbleText";
    textarea.rows = 1;
    textarea.placeholder = "Ask a question...";

    const sendBtn = document.createElement("button");
    sendBtn.id = "InputSendButton";
    sendBtn.textContent = "\uF5B0";

    const audioBtn = document.createElement("button");
    audioBtn.id = "InputAudioButton";
    audioBtn.textContent = "\uE1D6";

    const dropdown = document.createElement("div");
    dropdown.id = "InputFunctionMenu";
    dropdown.hidden = true;

    const menuItemsZone = document.createElement("div");
    menuItemsZone.id = "InputFunctionMenuItems";

    Object.assign(menuItemsZone.style, {
      display: "flex",
      flexDirection: "column",
      minHeight: "0",
      overflowX: "hidden",
      overflowY: "hidden",
      boxSizing: "border-box"
    });

    const menuIconsZone = document.createElement("div");
    menuIconsZone.id = "InputFunctionMenuIcons";

    host.__uiState = {
      showFunctionButton: true,
      showAudioButton: false
    };

    Object.assign(dropdown.style, {
      position: "absolute",
      left: "0",
      top: "-10px",
      transform: "translateY(calc(-100% + 6px)) scale(0.985)",
      transformOrigin: "bottom left",
      opacity: "0",
      minWidth: "220px",
      padding: "8px",
      borderRadius: "14px",
      background: "var(--input-menu-bg, #2b2b2b)",
      border: "1px solid var(--input-menu-border, rgba(255,255,255,0.08))",
      boxSizing: "border-box",
      overflow: "visible",
      zIndex: "1001",
      transition: "opacity 180ms ease, transform 180ms ease",
      willChange: "opacity, transform"
    });

    Object.assign(menuIconsZone.style, {
      display: "flex",
      alignItems: "center",
      gap: "8px",
      marginTop: "8px",
      paddingTop: "8px",
      borderTop: "1px solid var(--input-menu-border, rgba(255,255,255,0.08))"
    });

    const thinkingMenu = document.createElement("div");
    thinkingMenu.id = "InputThinkingMenu";
    thinkingMenu.hidden = true;

    Object.assign(thinkingMenu.style, {
      position: "absolute",
      left: "100%",
      top: "0",
      marginLeft: "6px",
      minWidth: "160px",
      padding: "6px",
      borderRadius: "12px",
      background: "var(--input-menu-bg, #2b2b2b)",
      border: "1px solid var(--input-menu-border, rgba(255,255,255,0.08))",
      boxSizing: "border-box",
      overflowX: "hidden",
      overflowY: "hidden",
      zIndex: "1002",
      opacity: "0",
      transform: "translateY(6px) scale(0.97)",
      transformOrigin: "top left",
      transition: "opacity 180ms ease, transform 180ms ease",
      willChange: "opacity, transform"
    });

    const endpointMenu = document.createElement("div");
    endpointMenu.id = "InputEndpointMenu";
    endpointMenu.hidden = true;

    Object.assign(endpointMenu.style, {
      position: "absolute",
      left: "100%",
      top: "0",
      marginLeft: "6px",
      minWidth: "220px",
      padding: "6px",
      borderRadius: "12px",
      background: "var(--input-menu-bg, #2b2b2b)",
      border: "1px solid var(--input-menu-border, rgba(255,255,255,0.08))",
      boxSizing: "border-box",
      overflowX: "hidden",
      overflowY: "hidden",
      zIndex: "1002",
      opacity: "0",
      transform: "translateY(6px) scale(0.97)",
      transformOrigin: "top left",
      transition: "opacity 180ms ease, transform 180ms ease",
      willChange: "opacity, transform"
    });

    const integrationMenu = document.createElement("div");
    integrationMenu.id = "InputIntegrationMenu";
    integrationMenu.hidden = true;

    Object.assign(integrationMenu.style, {
      position: "absolute",
      left: "100%",
      top: "0",
      marginLeft: "6px",
      minWidth: "180px",
      padding: "6px",
      borderRadius: "12px",
      background: "var(--input-menu-bg, #2b2b2b)",
      border: "1px solid var(--input-menu-border, rgba(255,255,255,0.08))",
      boxSizing: "border-box",
      overflowX: "hidden",
      overflowY: "hidden",
      zIndex: "1002",
      opacity: "0",
      transform: "translateY(6px) scale(0.7)",
      transformOrigin: "top left",
      transition: "opacity 180ms ease, transform 180ms ease",
      willChange: "opacity, transform"
    });

    const mediaMenu = document.createElement("div");
    mediaMenu.id = "InputMediaMenu";
    mediaMenu.hidden = true;

    Object.assign(mediaMenu.style, {
      position: "absolute",
      left: "100%",
      top: "0",
      marginLeft: "6px",
      minWidth: "200px",
      padding: "6px",
      borderRadius: "12px",
      background: "var(--input-menu-bg, #2b2b2b)",
      border: "1px solid var(--input-menu-border, rgba(255,255,255,0.08))",
      boxSizing: "border-box",
      overflowX: "hidden",
      overflowY: "hidden",
      zIndex: "1002",
      opacity: "0",
      transform: "translateY(6px) scale(0.97)",
      transformOrigin: "top left",
      transition: "opacity 180ms ease, transform 180ms ease",
      willChange: "opacity, transform"
    });

    const fileInput = document.createElement("input");
    fileInput.type = "file";
    fileInput.multiple = true;
    fileInput.style.display = "none";

    const knowledgeInput = document.createElement("input");
    knowledgeInput.type = "file";
    knowledgeInput.multiple = true;
    knowledgeInput.style.display = "none";

    const imageInput = document.createElement("input");
    imageInput.type = "file";
    imageInput.accept = "image/*";  /**/
    imageInput.multiple = true;
    imageInput.style.display = "none";

    document.body.appendChild(fileInput);
    document.body.appendChild(knowledgeInput);
    document.body.appendChild(imageInput);

    const fileDropZone = document.createElement("div");
    fileDropZone.id = "InputFileDropZone";
    fileDropZone.setAttribute("aria-hidden", "true");

    Object.assign(fileDropZone.style, {
      display: "none",
      opacity: "0",
      pointerEvents: "none"
    });

    document.body.appendChild(fileDropZone);

    let fileDropZoneHideTimer = 0;

    function readDrawerRightFromDom() {
      const drawer = document.getElementById(FILES_DRAWER_ROOT_ID);
      if (!drawer) return 0;

      const rect = drawer.getBoundingClientRect();
      if (!rect) return 0;

      const right = Math.max(rect.right, rect.left + rect.width);
      return right > 0 ? right : 0;
    }

    function readDrawerRightFromLayoutVar() {
      const raw = getComputedStyle(document.documentElement)
        .getPropertyValue("--layout-left-panel-width");

      const parsed = parseFloat(raw);
      return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
    }

    function getFileDropZoneBounds() {
      const viewportWidth =
        window.innerWidth ||
        document.documentElement.clientWidth ||
        0;

      const drawerRight = Math.max(
        readDrawerRightFromDom(),
        readDrawerRightFromLayoutVar()
      );

      const left = Math.min(
        viewportWidth,
        Math.max(0, Math.round(drawerRight))
      );

      return {
        left: left,
        width: Math.max(0, viewportWidth - left)
      };
    }

    function applyFileDropZoneBounds() {
      const bounds = getFileDropZoneBounds();

      fileDropZone.style.left = bounds.left + "px";
      fileDropZone.style.width = bounds.width + "px";
      fileDropZone.style.right = "auto";
    }

    window.addEventListener("resize", function () {
      if (fileDropZone.style.display === "flex") {
        applyFileDropZoneBounds();
      }
    });

    function hasDraggedFiles(event) {
      const dataTransfer = event && event.dataTransfer;
      if (!dataTransfer) return false;

      const types = dataTransfer.types;
      if (types) {
        if (typeof types.contains === "function" && types.contains("Files"))
          return true;

        if (typeof types.includes === "function" && types.includes("Files"))
          return true;

        for (let i = 0; i < types.length; i++) {
          if (types[i] === "Files")
            return true;
        }
      }

      if (dataTransfer.items) {
        for (let i = 0; i < dataTransfer.items.length; i++) {
          if (dataTransfer.items[i].kind === "file")
            return true;
        }
      }

      return !!(dataTransfer.files && dataTransfer.files.length > 0);
    }

    function showFileDropZone() {
      window.clearTimeout(fileDropZoneHideTimer);
      applyFileDropZoneBounds();

      if (fileDropZone.style.display !== "flex") {
        fileDropZone.style.opacity = "0";
        fileDropZone.style.display = "flex";
      }

      fileDropZone.style.pointerEvents = "auto";
      fileDropZone.getBoundingClientRect();
      fileDropZone.style.opacity = "1";
    }

    function hideFileDropZone() {
      window.clearTimeout(fileDropZoneHideTimer);

      fileDropZone.style.opacity = "0";
      fileDropZone.style.pointerEvents = "none";

      fileDropZoneHideTimer = window.setTimeout(function () {
        if (fileDropZone.style.opacity === "0")
          fileDropZone.style.display = "none";
      }, 130);
    }

    function normalizeDroppedPath(value) {
      if (!value) return "";

      let path = String(value).trim();
      if (!path) return "";

      if (path.indexOf("file:") === 0) {
        try {
          const url = new URL(path);

          if (url.protocol === "file:") {
            if (url.host) {
              path = "\\\\" + url.host + decodeURIComponent(url.pathname);
            } else {
              path = decodeURIComponent(url.pathname).replace(/^\/([A-Za-z]:)/, "$1");
            }
          }
        } catch (_) {
          try {
            path = decodeURI(path.replace(/^file:\/\/\/?/, ""));
          } catch (__) {
            path = path.replace(/^file:\/\/\/?/, "");
          }
        }
      }

      return path.replace(/\//g, "\\");
    }

    function isLocalDroppedPath(value) {
      if (!value) return false;

      const path = String(value).trim();

      return (
        /^[A-Za-z]:[\\\/]/.test(path) ||
        /^\\\\/.test(path) ||
        path.indexOf("file:") === 0
      );
    }

    function getDroppedFilePath(file) {
      if (!file) return "";

      const path = normalizeDroppedPath(
        file.path ||
        file.fullPath ||
        file.mozFullPath ||
        file.webkitRelativePath
      );

      return isLocalDroppedPath(path) ? path : "";
    }

    function getDroppedUriListPaths(dataTransfer) {
      if (!dataTransfer || typeof dataTransfer.getData !== "function")
        return [];

      try {
        return String(dataTransfer.getData("text/uri-list") || "")
          .split(/\r?\n/)
          .map(function (line) { return line.trim(); })
          .filter(function (line) { return line && line.charAt(0) !== "#"; })
          .map(normalizeDroppedPath)
          .filter(isLocalDroppedPath)
          .filter(Boolean);
      } catch (_) {
        return [];
      }
    }

    function getDroppedTextPaths(dataTransfer) {
      if (!dataTransfer || typeof dataTransfer.getData !== "function")
        return [];

      const formats = ["text/plain", "Text", "URL"];
      const paths = [];

      formats.forEach(function (format) {
        try {
          String(dataTransfer.getData(format) || "")
            .split(/\r?\n/)
            .map(function (line) { return normalizeDroppedPath(line); })
            .filter(isLocalDroppedPath)
            .forEach(function (path) { paths.push(path); });
        } catch (_) {
        }
      });

      return paths;
    }

    function getDroppedFilenames(dataTransfer) {
      const filenames = [];
      const seen = new Set();

      function addFilename(path) {
        const normalized = normalizeDroppedPath(path);
        if (!normalized || seen.has(normalized)) return;

        seen.add(normalized);
        filenames.push(normalized);
      }

      Array.from(dataTransfer.files || []).forEach(function (file) {
        addFilename(getDroppedFilePath(file));
      });

      getDroppedUriListPaths(dataTransfer).forEach(addFilename);
      getDroppedTextPaths(dataTransfer).forEach(addFilename);

      return filenames;
    }

    function postDroppedFiles(filenames, dataTransfer) {
      if (!window.chrome || !window.chrome.webview) return;

      const message = {
        event: "file-drop-in",
        filenames: Array.isArray(filenames) ? filenames : []
      };

      const files = dataTransfer && dataTransfer.files
        ? Array.from(dataTransfer.files)
        : [];

      if (
        files.length > 0 &&
        typeof window.chrome.webview.postMessageWithAdditionalObjects === "function"
      ) {
        try {
          window.chrome.webview.postMessageWithAdditionalObjects(message, files);
          return;
        } catch (_) {
        }
      }

      window.chrome.webview.postMessage(message);
    }

    function isPointInsideFileDropZone(event) {
      if (!event || fileDropZone.style.display === "none")
        return false;

      const rect = fileDropZone.getBoundingClientRect();

      return (
        event.clientX >= rect.left &&
        event.clientX <= rect.right &&
        event.clientY >= rect.top &&
        event.clientY <= rect.bottom
      );
    }

    function handleDroppedFiles(event) {
      if (event.__inputBubbleFileDropHandled) return;

      event.__inputBubbleFileDropHandled = true;

      const filenames = getDroppedFilenames(event.dataTransfer);
      hideFileDropZone();
      postDroppedFiles(filenames, event.dataTransfer);
    }

    function setDropEffect(event) {
      try {
        event.dataTransfer.dropEffect = "copy";
      } catch (_) {
      }
    }

    function handleBrowserFileDrag(event) {
      if (!hasDraggedFiles(event)) return;

      event.preventDefault();
      setDropEffect(event);
      showFileDropZone();
    }

    function handleBrowserFileDrop(event) {
      if (!hasDraggedFiles(event)) return;

      event.preventDefault();

      if (isPointInsideFileDropZone(event)) {
        handleDroppedFiles(event);
        return;
      }

      hideFileDropZone();
    }

    function handleBrowserFileDragLeave(event) {
      if (
        event.clientX <= 0 ||
        event.clientY <= 0 ||
        event.clientX >= window.innerWidth ||
        event.clientY >= window.innerHeight
      ) {
        hideFileDropZone();
      }
    }

    fileDropZone.addEventListener("dragover", function (event) {
      if (!hasDraggedFiles(event)) return;

      event.preventDefault();
      setDropEffect(event);
      showFileDropZone();
    });

    fileDropZone.addEventListener("drop", function (event) {
      if (!hasDraggedFiles(event)) return;

      event.preventDefault();
      event.stopPropagation();

      handleDroppedFiles(event);
    });

    window.addEventListener("dragenter", handleBrowserFileDrag, true);
    window.addEventListener("dragover", handleBrowserFileDrag, true);
    window.addEventListener("drop", handleBrowserFileDrop, true);
    window.addEventListener("dragleave", handleBrowserFileDragLeave, true);

    function styleButton(btn) {
      Object.assign(btn.style, {
        width: "36px",
        height: "36px",
        minWidth: "36px",
        minHeight: "36px",
        padding: "0",
        borderRadius: "18px",
        border: "none",
        background: "var(--input-button-bg, #3a3a3a)",
        color: "var(--input-button-text, #ffffff)",
        cursor: "pointer",
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        boxSizing: "border-box",
        lineHeight: "1",
        fontFamily: '"Segoe UI Symbol","Segoe UI",sans-serif',
        fontSize: "16px",
        transition: "background 140ms ease, color 140ms ease"
      });
    }

    function addHover(btn) {
      btn.addEventListener("mouseenter", function () {
        btn.style.background = "var(--input-button-hover-bg, #ffffff)";
        btn.style.color = "var(--input-button-hover-text, #111)";
      });

      btn.addEventListener("mouseleave", function () {
        btn.style.background = "var(--input-button-bg, #3a3a3a)";
        btn.style.color = "var(--input-button-text, #ffffff)";
      });
    }

    styleButton(menuBtn);
    styleButton(sendBtn);
    styleButton(audioBtn);
    styleButton(menuBtn);

    sendBtn.style.width = "48px";
    sendBtn.style.height = "48px";
    sendBtn.style.minWidth = "48px";
    sendBtn.style.minHeight = "48px";
    sendBtn.style.borderRadius = "24px";
    sendBtn.style.fontFamily = '"Segoe Fluent Icons"';
    sendBtn.style.fontSize = "18px";
    sendBtn.style.paddingLeft = "0";

    audioBtn.style.fontFamily = '"Segoe Fluent Icons"';
    audioBtn.style.fontSize = "16px";

    menuBtn.style.fontFamily = '"Segoe Fluent Icons"';
    menuBtn.style.fontSize = "16px";

    addHover(menuBtn);
    addHover(sendBtn);
    addHover(audioBtn);

    menuBtn.style.transform = "translateY(-3px)";
    sendBtn.style.transform = "translateY(-3px)";
    audioBtn.style.transform = "translateY(-3px)";

    audioBtn.style.fontSize = "15px";

    const SEND_BUTTON_INPUT_MODE = "input-mode";
    const SEND_BUTTON_STOP_MODE = "stop-mode";
    const SEND_BUTTON_INPUT_ICON = "\uF5B0";
    const SEND_BUTTON_STOP_ICON = "\uE747";

    function applySendButtonStateUI() {
      const state = host.__sendButtonState === SEND_BUTTON_STOP_MODE
        ? SEND_BUTTON_STOP_MODE
        : SEND_BUTTON_INPUT_MODE;

      host.__sendButtonState = state;
      sendBtn.dataset.state = state;
      sendBtn.textContent = state === SEND_BUTTON_STOP_MODE
        ? SEND_BUTTON_STOP_ICON
        : SEND_BUTTON_INPUT_ICON;

      // Orthogonal availability flag, controlled by setSendButtonAvailability
      // and used to lock the send button while uploads are in flight.
      const available = host.__sendButtonAvailable !== false;
      sendBtn.dataset.available = available ? "true" : "false";
      sendBtn.style.opacity = available ? "" : "0.4";
      sendBtn.style.cursor = available ? "" : "not-allowed";
      sendBtn.style.pointerEvents = available ? "" : "none";
    }

    function setSendButtonState(state) {
      if (state !== SEND_BUTTON_INPUT_MODE && state !== SEND_BUTTON_STOP_MODE)
        return false;

      host.__sendButtonState = state;
      applySendButtonStateUI();
      return true;
    }

    Object.assign(textarea.style, {
      resize: "none",
      border: "none",
      outline: "none",
      background: "transparent",
      color: "var(--input-text, #e8e8e8)",
      fontFamily: '"Segoe UI", sans-serif',
      fontSize: "17px",
      lineHeight: "1.45",
      padding: "6px 10px 6px 8px",
      width: "100%",
      margin: "0",
      overflowY: "auto",
      gridColumn: "2 / 3",
      gridRow: "1 / span 2",
      boxSizing: "border-box"
    });

    if (!document.getElementById("input-text-scrollbar-style")) {
      const scrollbarStyle = document.createElement("style");
      scrollbarStyle.id = "input-text-scrollbar-style";
      scrollbarStyle.textContent = `
        #InputBubbleText {
          scrollbar-width: thin;
          scrollbar-color: var(--scrollbar-thumb, #4a4a4a) transparent;
        }
        #InputBubbleText::-webkit-scrollbar { width: 8px; }
        #InputBubbleText::-webkit-scrollbar-track { background: transparent; }
        #InputBubbleText::-webkit-scrollbar-thumb {
          background: var(--scrollbar-thumb, #4a4a4a);
          border-radius: 6px;
        }
        #InputBubbleText::-webkit-scrollbar-thumb:hover {
          background: var(--scrollbar-thumb-hover, #6a6a6a);
        }
      `;
      document.head.appendChild(scrollbarStyle);
    }

    if (!document.getElementById("input-chip-style")) {
      const chipStyle = document.createElement("style");
      chipStyle.id = "input-chip-style";
      chipStyle.textContent = `
        .input-chip-close {
          opacity: 0;
          transition: opacity 120ms ease;
          cursor: pointer;
        }

        .input-chip:hover .input-chip-close {
          opacity: 1;
        }
      `;
      document.head.appendChild(chipStyle);
    }

    if (!document.getElementById("input-menu-scrollbar-style")) {
      const menuScrollbarStyle = document.createElement("style");
      menuScrollbarStyle.id = "input-menu-scrollbar-style";
      menuScrollbarStyle.textContent = `
        #InputFunctionMenuItems,
        #InputThinkingMenu,
        #InputEndpointMenu,
        #InputIntegrationMenu,
        #InputMediaMenu {
          scrollbar-width: thin;
          scrollbar-color: var(--scrollbar-thumb, #4a4a4a) transparent;
        }

        #InputFunctionMenuItems::-webkit-scrollbar,
        #InputThinkingMenu::-webkit-scrollbar,
        #InputEndpointMenu::-webkit-scrollbar,
        #InputIntegrationMenu::-webkit-scrollbar,
        #InputMediaMenu::-webkit-scrollbar {
          width: 8px;
        }

        #InputFunctionMenuItems::-webkit-scrollbar-track,
        #InputThinkingMenu::-webkit-scrollbar-track,
        #InputEndpointMenu::-webkit-scrollbar-track,
        #InputIntegrationMenu::-webkit-scrollbar-track,
        #InputMediaMenu::-webkit-scrollbar-track {
          background: transparent;
        }

        #InputFunctionMenuItems::-webkit-scrollbar-thumb,
        #InputThinkingMenu::-webkit-scrollbar-thumb,
        #InputEndpointMenu::-webkit-scrollbar-thumb,
        #InputIntegrationMenu::-webkit-scrollbar-thumb,
        #InputMediaMenu::-webkit-scrollbar-thumb {
          background: var(--scrollbar-thumb, #4a4a4a);
          border-radius: 6px;
        }

        #InputFunctionMenuItems::-webkit-scrollbar-thumb:hover,
        #InputThinkingMenu::-webkit-scrollbar-thumb:hover,
        #InputEndpointMenu::-webkit-scrollbar-thumb:hover,
        #InputIntegrationMenu::-webkit-scrollbar-thumb:hover,
        #InputMediaMenu::-webkit-scrollbar-thumb:hover {
          background: var(--scrollbar-thumb-hover, #6a6a6a);
        }
      `;
      document.head.appendChild(menuScrollbarStyle);
    }

    const lineHeight = 17 * 1.45;
    const maxHeight = lineHeight * MAX_LINES + 4;

    function autoResizeTextarea() {
      textarea.style.height = "auto";
      textarea.style.height = Math.min(textarea.scrollHeight, maxHeight) + "px";
    }

    const INPUT_HISTORY_LIMIT = 120;

    function clampInputIndex(value) {
      const max = textarea.value.length;
      const n = Number(value);

      if (!Number.isFinite(n) || n < 0)
        return 0;

      if (n > max)
        return max;

      return n;
    }

    function getInputSnapshot() {
      return {
        value: textarea.value || "",
        selectionStart: clampInputIndex(textarea.selectionStart || 0),
        selectionEnd: clampInputIndex(textarea.selectionEnd || 0)
      };
    }

    function sameInputSnapshot(a, b) {
      return !!a && !!b &&
        a.value === b.value &&
        a.selectionStart === b.selectionStart &&
        a.selectionEnd === b.selectionEnd;
    }

    function pushInputUndo(snapshot) {
      if (!host.__inputHistory)
        host.__inputHistory = { undo: [], redo: [], applying: false };

      const undo = host.__inputHistory.undo;
      if (undo.length > 0 && sameInputSnapshot(undo[undo.length - 1], snapshot))
        return;

      undo.push(snapshot);
      if (undo.length > INPUT_HISTORY_LIMIT)
        undo.shift();
    }

    function rememberInputBeforeChange() {
      if (!host.__inputHistory)
        host.__inputHistory = { undo: [], redo: [], applying: false };

      if (host.__inputHistory.applying)
        return;

      pushInputUndo(getInputSnapshot());
      host.__inputHistory.redo = [];
    }

    function restoreInputSnapshot(snapshot) {
      if (!snapshot)
        return false;

      if (!host.__inputHistory)
        host.__inputHistory = { undo: [], redo: [], applying: false };

      host.__inputHistory.applying = true;
      textarea.value = snapshot.value || "";
      autoResizeTextarea();

      const start = clampInputIndex(snapshot.selectionStart || 0);
      const end = clampInputIndex(snapshot.selectionEnd || start);
      textarea.setSelectionRange(start, end);
      host.__inputHistory.applying = false;

      return true;
    }

    function undoInputChange() {
      if (!host.__inputHistory || host.__inputHistory.undo.length === 0)
        return false;

      const current = getInputSnapshot();
      const previous = host.__inputHistory.undo.pop();

      if (!sameInputSnapshot(current, previous))
        host.__inputHistory.redo.push(current);

      return restoreInputSnapshot(previous);
    }

    function redoInputChange() {
      if (!host.__inputHistory || host.__inputHistory.redo.length === 0)
        return false;

      pushInputUndo(getInputSnapshot());
      return restoreInputSnapshot(host.__inputHistory.redo.pop());
    }

    function clearInputHistory() {
      host.__inputHistory = { undo: [], redo: [], applying: false };
    }

    function setInputValue(value, recordHistory) {
      const nextValue = value == null ? "" : String(value);

      if (recordHistory !== false && textarea.value !== nextValue)
        rememberInputBeforeChange();

      textarea.value = nextValue;
      autoResizeTextarea();
    }

    function insertTextAtSelection(value, selectionStart, selectionEnd) {
      const text = value == null ? "" : String(value);
      const start = clampInputIndex(selectionStart || 0);
      const end = clampInputIndex(selectionEnd || start);
      const left = Math.min(start, end);
      const right = Math.max(start, end);

      rememberInputBeforeChange();

      const nextValue =
        textarea.value.slice(0, left) +
        text +
        textarea.value.slice(right);

      textarea.value = nextValue;
      autoResizeTextarea();

      const caret = left + text.length;
      textarea.setSelectionRange(caret, caret);
    }

    function getWheelScrollableContainer(startNode) {
      if (!(startNode instanceof Element)) {
        return null;
      }

      const candidates = [
        textarea,
        menuItemsZone,
        thinkingMenu,
        endpointMenu,
        integrationMenu,
        mediaMenu
      ];

      for (let i = 0; i < candidates.length; i += 1) {
        const el = candidates[i];

        if (el && el.contains(startNode)) {
          return el;
        }
      }

      return null;
    }

    function isContainerScrollable(el) {
      if (!el) {
        return false;
      }

      return el.scrollHeight > el.clientHeight + 1;
    }

    function captureInputBubbleWheel(e) {
      const scrollable = getWheelScrollableContainer(e.target);

      if (!scrollable) {
        e.preventDefault();
        return;
      }

      e.preventDefault();
      e.stopPropagation();

      if (!isContainerScrollable(scrollable)) {
        return;
      }

      scrollable.scrollTop += e.deltaY;
    }

    function handleInputTextareaWheel(e) {
      const target = e.currentTarget;

      if (!target) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();

      if (target.scrollHeight <= target.clientHeight + 1) {
        return;
      }

      target.scrollTop += e.deltaY;
    }

    textarea.addEventListener("beforeinput", function (event) {
      if (event.inputType === "historyUndo") {
        if (undoInputChange())
          event.preventDefault();
        return;
      }

      if (event.inputType === "historyRedo") {
        if (redoInputChange())
          event.preventDefault();
        return;
      }

      rememberInputBeforeChange();
    });

    textarea.addEventListener("input", autoResizeTextarea);

    textarea.addEventListener("paste", function (event) {
      event.preventDefault();
      event.stopPropagation();

      if (!window.chrome || !window.chrome.webview)
        return;

      window.chrome.webview.postMessage({
        event: "paste-from-clipboard",
        prompt: textarea.value || "",
        selectionStart: textarea.selectionStart || 0,
        selectionEnd: textarea.selectionEnd || 0
      });
    });

    textarea.addEventListener("keydown", function (e) {
      const key = String(e.key || "").toLowerCase();

      if ((e.ctrlKey || e.metaKey) && !e.altKey && key === "z") {
        const handled = e.shiftKey ? redoInputChange() : undoInputChange();
        if (handled) {
          e.preventDefault();
          e.stopPropagation();
        }
        return;
      }

      if ((e.ctrlKey || e.metaKey) && !e.altKey && key === "y") {
        if (redoInputChange()) {
          e.preventDefault();
          e.stopPropagation();
        }
        return;
      }

      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        sendBtn.click();
      }
    });

    function clearThinking() {
      host.__features.delete("thinking-low");
      host.__features.delete("thinking-medium");
      host.__features.delete("thinking-high");
    }

    function getThinkingFeature() {
      if (host.__features.has("thinking-high")) return "thinking-high";
      if (host.__features.has("thinking-medium")) return "thinking-medium";
      if (host.__features.has("thinking-low")) return "thinking-low";
      return null;
    }

    function setThinking(level) {
      clearThinking();
      host.__features.add("thinking-" + level);
    }

    function clearEndpoint() {
      host.__features.delete("endpoint-chat-completion");
      host.__features.delete("endpoint-chat-response");
      host.__features.delete("endpoint-message");
      host.__features.delete("endpoint-generate-content");
      host.__features.delete("endpoint-interactions");
      host.__features.delete("endpoint-conversation");
    }

    function getEndpointFeature() {
      if (host.__features.has("endpoint-chat-completion")) return "endpoint-chat-completion";
      if (host.__features.has("endpoint-chat-response")) return "endpoint-chat-response";
      if (host.__features.has("endpoint-message")) return "endpoint-message";
      if (host.__features.has("endpoint-generate-content")) return "endpoint-generate-content";
      if (host.__features.has("endpoint-interactions")) return "endpoint-interactions";
      if (host.__features.has("endpoint-conversation")) return "endpoint-conversation";
      return null;
    }

    function setEndpoint(value) {
      clearEndpoint();
      host.__features.add("endpoint-" + value);
    }

    function toggleWebResearch() {
      if (host.__features.has("web-research"))
        host.__features.delete("web-research");
      else
        host.__features.add("web-research");
    }

    function toggleKnowledgeSearch() {
      if (host.__features.has("knowledge-search"))
        host.__features.delete("knowledge-search");
      else
        host.__features.add("knowledge-search");
    }

    function toggleIntegrationFeature(featureName) {
      const key = "integration-" + featureName;
      if (host.__features.has(key))
        host.__features.delete(key);
      else
        host.__features.add(key);
    }

    function createChip(icon, label, removeFn) {

      const chip = document.createElement("div");
      chip.className = "input-chip";

      Object.assign(chip.style, {
        display: "flex",
        alignItems: "center",
        gap: "4px",
        padding: "4px 8px",
        borderRadius: "14px",
        background: "var(--input-chip-bg, #3a3a3a)",
        fontSize: "13px",
        color: "var(--input-indicator-text, var(--input-chip-text, #ddd))",
        maxWidth: "100%"
      });

      const close = document.createElement("span");
      close.textContent = "✕";
      close.className = "input-chip-close";

      const ic = document.createElement("span");
      ic.textContent = icon;

      Object.assign(ic.style, {
        fontFamily: "Segoe Fluent Icons"
      });

      const lab = document.createElement("span");
      lab.textContent = label;

      close.onclick = removeFn;

      chip.appendChild(close);
      chip.appendChild(ic);
      chip.appendChild(lab);

      return chip;

    }

    // Notify Delphi whenever a file is removed from the compose box. Upload
    // and indexing services tolerate unknown paths, while forwarding every
    // removal avoids depending on asynchronous browser-side status updates.
    function notifyFileRemoved(removed) {
      if (!removed) return;
      if (!window.chrome || !window.chrome.webview) return;
      if (!removed.path) return;

      window.chrome.webview.postMessage({
        event: "file-removed",
        path: removed.path
      });
    }

    function notifyFilesRemoved(removedFiles) {
      removedFiles.forEach(notifyFileRemoved);
    }

    function removePromptFragmentsForPath(path) {
      if (!path) return;

      host.__promptFragments = host.__promptFragments.filter(function (fragment) {
        return !fragment || fragment.fullPath !== path;
      });
    }

    function removePromptFragmentsForFiles(files) {
      (files || []).forEach(function (file) {
        if (file && file.path)
          removePromptFragmentsForPath(file.path);
      });
    }

    // Append a small visual badge to a chip reflecting the upload status of
    // its underlying file entry. Files without an uploadStatus are unaffected.
    function applyUploadStatusToChip(chip, file) {
      if (!file || !file.uploadStatus) return;

      const badge = document.createElement("span");
      badge.className = "input-chip-upload-status";
      badge.style.marginLeft = "4px";
      badge.style.fontSize = "11px";
      badge.style.fontFamily = "Segoe Fluent Icons";

      if (file.uploadStatus === "uploading") {
        badge.textContent = "\uE895"; // Sync
        badge.title = "Uploading";
        badge.style.opacity = "0.7";
      } else if (file.uploadStatus === "indexing") {
        badge.textContent = "\uE9F5"; // Processing
        badge.title = "Indexing";
        badge.style.opacity = "0.7";
      } else if (file.uploadStatus === "ready") {
        badge.textContent = "\uE73E"; // CheckMark
        badge.title = "Uploaded";
        badge.style.color = "#4caf50";
      } else if (file.uploadStatus === "failed") {
        badge.textContent = "\uE783"; // Error
        badge.title = file.uploadError || "Upload failed";
        badge.style.color = "#e57373";
      }

      chip.appendChild(badge);
    }

    function renderFiles() {

      filesRow.innerHTML = "";

      if (
        host.__files.length === 0 &&
        host.__knowledgeFiles.length === 0 &&
        host.__images.length === 0 &&
        host.__speechToTextFiles.length === 0 &&
        host.__integrationFunctions.length === 0 &&
        host.__integrationMcps.length === 0 &&
        host.__integrationSkills.length === 0 &&
        host.__integrationAgents.length === 0 &&
        host.__customItems.length === 0
      ) {
        filesRow.style.display = "none";
        return;
      }

      filesRow.style.display = "flex";

      host.__files.forEach((file, i) => {
        const chip = createChip("\uE16C", file.name, function () {
          const removed = host.__files.splice(i, 1)[0];
          notifyFileRemoved(removed);
          removePromptFragmentsForPath(removed && removed.path);
          render();
        });
        applyUploadStatusToChip(chip, file);
        filesRow.appendChild(chip);
      });

      host.__knowledgeFiles.forEach((file, i) => {
        const chip = createChip("\uE11A", file.name, function () {
          const removed = host.__knowledgeFiles.splice(i, 1)[0];
          notifyFileRemoved(removed);

          if (host.__knowledgeFiles.length === 0)
            host.__features.delete("knowledge-search");

          render();
        });
        applyUploadStatusToChip(chip, file);
        filesRow.appendChild(chip);
      });

      host.__images.forEach((file, i) => {
        filesRow.appendChild(
          createChip("\uE8B8", file.name, function () {
            host.__images.splice(i, 1);
            render();
          })
        );
      });

      host.__speechToTextFiles.forEach((file, i) => {
        filesRow.appendChild(
          createChip("\uF47F", file.name, function () {
            host.__speechToTextFiles.splice(i, 1);
            render();
          })
        );
      });

      host.__integrationFunctions.forEach((item, i) => {
        filesRow.appendChild(
          createChip("\uE1B3", item.name, function () {
            host.__integrationFunctions.splice(i, 1);
            render();
          })
        );
      });

      host.__integrationMcps.forEach((item, i) => {
        filesRow.appendChild(
          createChip("\uE8CE", item.name, function () {
            host.__integrationMcps.splice(i, 1);
            render();
          })
        );
      });

      host.__integrationSkills.forEach((item, i) => {
        filesRow.appendChild(
          createChip("\uECA7", item.name, function () {
            host.__integrationSkills.splice(i, 1);
            render();
          })
        );
      });

      host.__integrationAgents.forEach((item, i) => {
        filesRow.appendChild(
          createChip("\uE99A", item.name, function () {
            host.__integrationAgents.splice(i, 1);
            render();
          })
        );
      });

      host.__customItems.forEach((item, i) => {
        filesRow.appendChild(
          createChip("\uE15E", item.name, function () {
            host.__customItems.splice(i, 1);
            render();
          })
        );
      });

    }

    function renderFeatures() {

      featuresRow.innerHTML = "";

      const thinking = getThinkingFeature();
      const endpoint = getEndpointFeature();
      const hasWeb = host.__features.has("web-research");
      const hasFiles = host.__files.length > 0;
      const hasImages = host.__images.length > 0;
      const hasKnowledge = host.__features.has("knowledge-search");
      const hasDeepResearch = host.__features.has("deep-research");

      const hasIntegrationFunction = host.__features.has("integration-function");
      const hasIntegrationMcp = host.__features.has("integration-mcp");
      const hasIntegrationSkills = host.__features.has("integration-skills");
      const hasIntegrationAgents = host.__features.has("integration-agents");
      const hasCustom = host.__features.has("custom");

      const hasMediaCreateImage = host.__features.has("media-create-image");
      const hasMediaCreateVideo = host.__features.has("media-create-video");
      const hasMediaCreateAudio = host.__features.has("media-create-audio");
      const hasMediaSpeechToText = host.__speechToTextFiles.length > 0;
      const hasMediaTextToSpeech = host.__features.has("media-text-to-speech");

      if (!endpoint && !thinking && !hasWeb && !hasFiles && !hasImages && !hasKnowledge && !hasDeepResearch &&
        !hasIntegrationFunction && !hasIntegrationMcp &&
        !hasIntegrationSkills && !hasIntegrationAgents &&
        !hasMediaCreateImage && !hasMediaCreateVideo && !hasMediaCreateAudio &&
        !hasMediaSpeechToText && !hasMediaTextToSpeech &&
        !hasCustom) {
          featuresRow.style.display = "none";
          return;
        }

      featuresRow.style.display = "flex";

      if (endpoint) {
        const title = getEndpointLabel(endpoint);

        featuresRow.appendChild(
          createChip(
            "\uE1D2",
            t("input.chips.endpoint", "Endpoint: {title}", { title: title }),
            function () {
              clearEndpoint();
              render();
            }
          )
        );
      }

      if (hasWeb) {
        featuresRow.appendChild(
          createChip("\uE12B", t("input.chips.webResearch", "Web research"), function () {
            host.__features.delete("web-research");
            render();
          })
        );
      }

      if (thinking) {
        const level = thinking.split("-")[1];
        const title = getThinkingLabel(level);

        featuresRow.appendChild(
          createChip(
            "\uEA91",
            t("input.chips.thinking", "Thinking: {title}", { title: title }),
            function () {
              clearThinking();
              render();
            }
          )
        );
      }

      if (hasKnowledge) {
        featuresRow.appendChild(
          createChip(
            "\uE11A",
            t("input.chips.knowledgeSearch", "Knowledge search ({count})", {
              count: host.__knowledgeFiles.length
            }),
            function () {
              notifyFilesRemoved(host.__knowledgeFiles);
              host.__knowledgeFiles = [];
              host.__features.delete("knowledge-search");
              render();
            }
          )
        );
      }

      if (hasDeepResearch) {
        featuresRow.appendChild(
          createChip("\uF6FA", t("input.chips.deepResearch", "Deep Research"), function () {
            host.__features.delete("deep-research");
            render();
          })
        );
      }

      if (hasFiles) {
        featuresRow.appendChild(
          createChip(
            "\uE16C",
            t("input.chips.filesAttached", "Files attached ({count})", {
              count: host.__files.length
            }),
            function () {
              notifyFilesRemoved(host.__files);
              removePromptFragmentsForFiles(host.__files);
              host.__files = [];
              render();
            }
          )
        );
      }

      if (hasImages) {
        featuresRow.appendChild(
          createChip(
            "\uE8B8",
            t("input.chips.vision", "Vision ({count})", {
              count: host.__images.length
            }),
            function () {
              host.__images = [];
              render();
            }
          )
        );
      }

      if (hasIntegrationFunction) {
        featuresRow.appendChild(
          createChip(
            "\uE1B3",
            t("input.chips.integrationFunction", "Integration: Function ({count})", {
              count: host.__integrationFunctions.length
            }),
            function () {
              host.__integrationFunctions = [];
              host.__features.delete("integration-function");
              render();
            }
          )
        );
      }

      if (hasIntegrationMcp) {
        featuresRow.appendChild(
          createChip(
            "\uE8CE",
            t("input.chips.integrationMcp", "Integration: MCP ({count})", {
              count: host.__integrationMcps.length
            }),
            function () {
              host.__integrationMcps = [];
              host.__features.delete("integration-mcp");
              render();
            }
          )
        );
      }

      if (hasIntegrationSkills) {
        featuresRow.appendChild(
          createChip(
            "\uECA7",
            t("input.chips.integrationSkills", "Integration: Skills ({count})", {
              count: host.__integrationSkills.length
            }),
            function () {
              host.__integrationSkills = [];
              host.__features.delete("integration-skills");
              render();
            }
          )
        );
      }

      if (hasIntegrationAgents) {
        featuresRow.appendChild(
          createChip(
            "\uE99A",
            t("input.chips.integrationAgents", "Integration: Agents ({count})", {
              count: host.__integrationAgents.length
            }),
            function () {
              host.__integrationAgents = [];
              host.__features.delete("integration-agents");
              render();
            }
          )
        );
      }

      if (hasMediaCreateImage) {
        featuresRow.appendChild(
          createChip("\uEB9F", t("input.chips.mediaCreateImage", "Media: Create Image"), function () {
            host.__features.delete("media-create-image");
            render();
          })
        );
      }

      if (hasMediaCreateVideo) {
        featuresRow.appendChild(
          createChip("\uE714", t("input.chips.mediaCreateVideo", "Media: Create Video"), function () {
            host.__features.delete("media-create-video");
            render();
          })
        );
      }

      if (hasMediaCreateAudio) {
        featuresRow.appendChild(
          createChip("\uED1F", t("input.chips.mediaCreateAudio", "Media: Create Audio"), function () {
            host.__features.delete("media-create-audio");
            render();
          })
        );
      }

      if (hasMediaSpeechToText) {
        featuresRow.appendChild(
          createChip(
            "\uF47F",
            t("input.chips.speechToText", "Speech to text ({count})", {
              count: host.__speechToTextFiles.length
            }),
            function () {
              host.__speechToTextFiles = [];
              render();
            }
          )
        );
      }

      if (hasMediaTextToSpeech) {
        featuresRow.appendChild(
          createChip("\uF8B2", t("input.chips.mediaTextToSpeech", "Media: Text to speech"), function () {
            host.__features.delete("media-text-to-speech");
            render();
          })
        );
      }

      if (hasCustom) {
        featuresRow.appendChild(
          createChip(
            "\uE15E",
            t("input.chips.custom", "Custom ({count})", {
              count: host.__customItems.length
            }),
            function () {
              host.__customItems = [];
              host.__features.delete("custom");
              render();
            }
          )
        );
      }

    }

    function render() {
      if (host.__knowledgeFiles.length > 0)
        host.__features.add("knowledge-search");
      else
        host.__features.delete("knowledge-search");

      if (host.__integrationFunctions.length > 0)
        host.__features.add("integration-function");
      else
        host.__features.delete("integration-function");

      if (host.__integrationMcps.length > 0)
        host.__features.add("integration-mcp");
      else
        host.__features.delete("integration-mcp");

      if (host.__integrationSkills.length > 0)
        host.__features.add("integration-skills");
      else
        host.__features.delete("integration-skills");

      if (host.__integrationAgents.length > 0)
        host.__features.add("integration-agents");
      else
        host.__features.delete("integration-agents");

      if (host.__customItems.length > 0)
        host.__features.add("custom");
      else
        host.__features.delete("custom");

      renderFiles();
      renderFeatures();
      updateMenuState();
      applyInputButtonsVisibility();
      syncOpenDropdownLayout();
    }

    host.__refreshUI = render;

    window.onFileSelected = function(fullPath, target) {

      const name = fullPath.split("\\").pop();

      let list;

      if (target === "images") {
         list = host.__images;
      } else if (target === "knowledge") {
         list = host.__knowledgeFiles;
      } else if (target === "speech") {
         list = host.__speechToTextFiles;
      } else if (isMediaFile(name)) {
         list = host.__images;
      } else {
         list = host.__files;
      }

      const exists = list.some(f => f.path === fullPath);

      if (!exists) {
        list.push({
          name: name,
          path: fullPath
        });
      }

      render();
    };

    window.onPasteFragmentSelected = function(fullPath, selectionStart, selectionEnd) {
      if (!fullPath) return;

      const normalizedPath = String(fullPath);
      const parts = normalizedPath.split(/[\\/]+/);
      const name = parts.length ? parts[parts.length - 1] : normalizedPath;
      const placeholder = "[paste:p" + host.__nextPasteFragmentIndex++ + "]";

      host.__promptFragments.push({
        placeholder: placeholder,
        name: name,
        fullPath: normalizedPath
      });

      insertTextAtSelection(placeholder, selectionStart, selectionEnd);
      render();
    };

    function parseIntegrationSelection(value) {
      if (typeof value === "string") {
        const text = value.trim();

        if (text.length > 0) {
          const first = text.charAt(0);
          const last = text.charAt(text.length - 1);

          if (
            (first === "[" && last === "]") ||
            (first === "{" && last === "}")
          ) {
            try {
              return JSON.parse(text);
            } catch (_) {
              return value;
            }
          }
        }
      }

      return value;
    }

    function normalizeIntegrationSelection(idOrItems, name) {
      const parsed = parseIntegrationSelection(idOrItems);
      const source = Array.isArray(parsed) ? parsed : [parsed];

      return source
        .map(function (item) {
          if (item && typeof item === "object") {
            const id =
              item.id != null ? item.id :
              item.ID != null ? item.ID :
              item.value != null ? item.value :
              item.key != null ? item.key :
              null;

            const label =
              item.name != null ? item.name :
              item.Name != null ? item.Name :
              item.label != null ? item.label :
              item.title != null ? item.title :
              null;

            return {
              id: id == null ? "" : String(id),
              name: label == null ? "" : String(label)
            };
          }

          return {
            id: idOrItems == null ? "" : String(idOrItems),
            name: name == null ? "" : String(name)
          };
        })
        .filter(function (item) {
          return item.id !== "" && item.name !== "";
        });
    }

    function upsertIntegrationSelection(list, idOrItems, name, replace) {
      const items = normalizeIntegrationSelection(idOrItems, name);

      if (replace) {
        list.length = 0;
      }

      items.forEach(function (item) {
        const existing = list.find(function (f) {
          return f.id === item.id;
        });

        if (existing) {
          existing.name = item.name;
        } else {
          list.push({
            id: item.id,
            name: item.name
          });
        }
      });

      render();
    }

    window.onIntegrationFunctionSelected = function(id, name) {
      upsertIntegrationSelection(host.__integrationFunctions, id, name, false);
    };

    window.onIntegrationMcpSelected = function(id, name) {
      upsertIntegrationSelection(host.__integrationMcps, id, name, false);
    };

    window.onIntegrationSkillSelected = function(id, name) {
      upsertIntegrationSelection(host.__integrationSkills, id, name, false);
    };

    window.onIntegrationAgentSelected = function(id, name) {
      // Single-agent invariant + sticky guard: a menu pick is IGNORED when
      // a chip is already in place. The user must explicitly dismiss the
      // existing chip before selecting a different agent — defense in depth
      // for multi-turn agent conversations, where switching mid-chat would
      // be silently routed to the original session's agent backend-side.
      // setIntegrationAgents (Delphi-driven restore) keeps full-replace
      // semantics so AfterSessionReloaded can still rewrite the chip.
      if (host.__integrationAgents.length > 0) return;
      upsertIntegrationSelection(host.__integrationAgents, id, name, true);
    };

    window.setIntegrationFunctions = function(items) {
      upsertIntegrationSelection(host.__integrationFunctions, items, null, true);
    };

    window.setIntegrationMcps = function(items) {
      upsertIntegrationSelection(host.__integrationMcps, items, null, true);
    };

    window.setIntegrationSkills = function(items) {
      upsertIntegrationSelection(host.__integrationSkills, items, null, true);
    };

    window.setIntegrationAgents = function(items) {
      // Single-agent invariant: collapse bulk payloads to their last entry
      // so legacy multi-agent state cannot reintroduce multiple chips.
      const normalized = Array.isArray(items) ? items.slice(-1) : items;
      upsertIntegrationSelection(host.__integrationAgents, normalized, null, true);
    };

    window.onCustomSelected = function(id, name) {
      if (!id || !name) return;

      id = String(id);
      name = String(name);

      const existing = host.__customItems.find(f => f.id === id);

      if (existing) {
        existing.name = name;
      } else {
        host.__customItems.push({
          id: id,
          name: name
        });
      }

      render();
    };

    window.getInputState = function () {

      const features = Array.from(host.__features);

      function extractEndpoint(features) {
        if (features.includes("endpoint-chat-completion")) return "v1/chat/completion";
        if (features.includes("endpoint-chat-response")) return "v1/chat/response";
        if (features.includes("endpoint-message")) return "v1/message";
        if (features.includes("endpoint-generate-content")) return ":generateContent";
        if (features.includes("endpoint-interactions")) return "v1/interactions";
        if (features.includes("endpoint-conversation")) return "v1/conversation";
        return "none";
      }

      function extractThinking(features) {
        if (features.includes("thinking-high")) return "high";
        if (features.includes("thinking-medium")) return "medium";
        if (features.includes("thinking-low")) return "low";
        return "none";
      }

      function buildDefaultRequestParams() {
        return {
          systemPrompt: {
            systemPrompt: "",
            enabled: false
          },

          settings: {
            temperature: 0.8,
            maxToken: {
              maxToken: 2048,
              enabled: false
            },
            stopString: {
              stopString: [],
              enabled: false
            }
          },

          sampling: {
            topK: {
              topK: 20,
              enabled: false
            },
            presencePenalty: {
              presencePenalty: 0,
              enabled: false
            },
            topP: {
              topP: 0,
              enabled: false
            },
            seed: {
              seed: 0,
              enabled: false
            }
          },

          structuredOutput: {
            jsonSchema: "",
            enabled: false
          },

          vendorSettings: {
            parallelToolCalls: false,
            backgroundResponse: false,
            usingPreviousId: false,
            store: false
          }
        };
      }

      const requestParams =
        window.RequestParams &&
        typeof window.RequestParams.getState === "function"
          ? window.RequestParams.getState()
          : buildDefaultRequestParams();

      const activeProject = host.__enabledFunctions.project
        ? getActiveProject()
        : null;

      return {
        text: document.getElementById("InputBubbleText")?.value || "",

        endpoint: extractEndpoint(features),

        thinking: extractThinking(features),
        deepResearch: features.includes("deep-research"),
        webSearch: features.includes("web-research"),

        project: activeProject
          ? {
              displayName: activeProject.displayName || "",
              fullPath: activeProject.fullPath || null,
              full_path: activeProject.fullPath || null
            }
          : null,

        files: host.__files.map(f => ({
          name: f.name,
          fullPath: f.path || null,
          fileId: f.fileId || null
        })),

        images: host.__images.map(f => ({
          name: f.name,
          fullPath: f.path || null
        })),

        knowledgeSearch: host.__knowledgeFiles.map(f => ({
          name: f.name,
          fullPath: f.path || null,
          fileId: f.fileId || null
        })),

        promptFragments: host.__promptFragments
          .filter(f => f && f.placeholder && f.fullPath)
          .filter(f => (textarea.value || "").indexOf(f.placeholder) >= 0)
          .map(f => ({
            placeholder: f.placeholder,
            name: f.name,
            fullPath: f.fullPath
          })),

        integration: {
          function: host.__integrationFunctions.map(f => ({
            id: f.id,
            name: f.name
          })),
          mcp: host.__integrationMcps.map(f => ({
            id: f.id,
            name: f.name
          })),
          skills: host.__integrationSkills.map(f => ({
            id: f.id,
            name: f.name
          })),
          agents: host.__integrationAgents.map(f => ({
            id: f.id,
            name: f.name
          }))
        },

        custom: host.__customItems.map(f => ({
          id: f.id,
          name: f.name
        })),

        media: {
          createImage: features.includes("media-create-image"),
          createVideo: features.includes("media-create-video"),
          createAudio: features.includes("media-create-audio"),
          speechToText: host.__speechToTextFiles.map(f => ({
            name: f.name,
            fullPath: f.path || null
          })),
          textToSpeech: features.includes("media-text-to-speech")
        },

        requestParams: requestParams
      };
    };

    window.setInputBubbleText = function (text) {
      setInputValue(text, true);
    };

    window.insertInputBubbleText = function (text) {
      const insert = (text == null ? "" : String(text)).trim();
      if (!insert)
        return;

      try {
        textarea.focus({ preventScroll: true });
      } catch (_) {
        textarea.focus();
      }

      const value = textarea.value || "";
      const start = clampInputIndex(textarea.selectionStart || 0);
      const end = clampInputIndex(textarea.selectionEnd || start);
      const left = Math.min(start, end);
      const right = Math.max(start, end);

      const before = value.slice(0, left);
      const after = value.slice(right);

      let piece = insert;

      /*--- Pad the insertion so words never fuse with the surrounding text. */
      if (before.length && !/\s$/.test(before) && !/^\s/.test(piece))
        piece = " " + piece;

      if (after.length && !/^\s/.test(after) && !/\s$/.test(piece))
        piece = piece + " ";

      insertTextAtSelection(piece, left, right);
    };

    window.setInputAudioRecording = function (active) {
      if (!audioBtn)
        return;

      /*--- Toggles the red+bold "recording" look (see #InputAudioButton.is-recording
            in index.htm). Driven by AudioRecordingTemplate on real start/stop. */
      audioBtn.classList.toggle("is-recording", !!active);
    };

    window.setInputBubbleFocus = function () {
      try {
        textarea.focus({ preventScroll: true });
      } catch (_) {
        textarea.focus();
      }

      const end = textarea.value.length;
      textarea.setSelectionRange(end, end);
    };

    window.setInputBubbleWelcome = function (text) {
      host.__welcomeText = text == null ? "" : String(text);
      updateWelcomeVisibility();
    };

    window.setSendButtonState = function (state) {
      return setSendButtonState(state);
    };

    // Updates the upload status of a file already present in the compose box,
    // identified by its local path. Looks first in __files, then in
    // __knowledgeFiles. When status is "ready", fileId is stored on the
    // entry. When status is "failed", errorMessage is stored. The
    // "indexing" status is the second stage of the knowledge pipeline
    // (after upload, before retrieval-ready). Unknown paths are silently
    // ignored.
    window.setFileUploadStatus = function (path, status, fileId, errorMessage) {
      if (!path || !status) return false;

      function applyTo(list) {
        const entry = list.find(function (f) { return f.path === path; });
        if (!entry) return false;

        entry.uploadStatus = status;

        if (status === "ready") {
          entry.fileId = fileId || null;
          delete entry.uploadError;
        } else if (status === "failed") {
          entry.uploadError = errorMessage || "";
        } else if (status === "uploading" || status === "indexing") {
          delete entry.uploadError;
        }

        return true;
      }

      const updated = applyTo(host.__files) || applyTo(host.__knowledgeFiles);
      if (updated) render();
      return updated;
    };

    // Orthogonal flag controlling whether the send button is clickable.
    // The send button visual mode (input / stop) keeps working independently;
    // when availability is false, the button is greyed out and clicks are
    // ignored. Used to lock submit while uploads are in flight.
    window.setSendButtonAvailability = function (enabled) {
      host.__sendButtonAvailable = !!enabled;
      applySendButtonStateUI();
    };

    window.partialResetInputBubble = function () {
      setInputValue("", false);
      clearInputHistory();

      clearEndpoint();

      host.__files = [];
      host.__images = [];
      host.__knowledgeFiles = [];
      host.__speechToTextFiles = [];
      host.__promptFragments = [];
      host.__nextPasteFragmentIndex = 1;

      host.__features.delete("knowledge-search");
      host.__features.delete("media-text-to-speech");

      // After a bulk reset, no upload can still be in flight from the user's
      // point of view. Re-enable submit so the button does not stay locked
      // if Delphi never re-pushes availability.
      host.__sendButtonAvailable = true;
      applySendButtonStateUI();

      closeDropdown();
      render();
    };

    window.sendInputState = function () {
      if (window.chrome && window.chrome.webview) {
        window.chrome.webview.postMessage({
          event: "input-state",
          state: window.getInputState()
        });
      }
    };

    function addMenuItemHover(btn) {
      btn.addEventListener("mouseenter", function () {
        btn.style.background = "var(--input-menu-item-hover-bg, rgba(255,255,255,0.08))";
        btn.style.color = "var(--input-menu-item-hover-text, #ffffff)";
      });

      btn.addEventListener("mouseleave", function () {
        btn.style.background = "transparent";
        btn.style.color = "var(--input-menu-text, #ddd)";
      });

      btn.addEventListener("focus", function () {
        btn.style.background = "var(--input-menu-item-hover-bg, rgba(255,255,255,0.08))";
        btn.style.color = "var(--input-menu-item-hover-text, #ffffff)";
      });

      btn.addEventListener("blur", function () {
        btn.style.background = "transparent";
        btn.style.color = "var(--input-menu-text, #ddd)";
      });
    }


    function createMenuItem(label, icon, onclick, hasSubmenu = false) {

      const btn = document.createElement("button");

      btn.type = "button";
      btn.dataset.label = label;

      Object.assign(btn.style, {
        position: "relative",
        display: "block",
        width: "100%",
        textAlign: "left",
        background: "transparent",
        border: "none",
        color: "var(--input-menu-text, #ddd)",
        padding: "6px 22px 6px 6px", // espace à droite pour le chevron
        cursor: "pointer",
        borderRadius: "8px",
        transition: "background 140ms ease, color 140ms ease",
      });

      btn.onclick = onclick;

      const iconSpan = document.createElement("span");
      iconSpan.className = "input-menu-item-icon";
      iconSpan.textContent = icon;

      Object.assign(iconSpan.style, {
        fontFamily: "Segoe Fluent Icons",
        marginRight: "6px",
        width: "16px",
        display: "inline-block",
        textAlign: "center"
      });

      const labelSpan = document.createElement("span");
      labelSpan.className = "input-menu-item-label";
      labelSpan.textContent = label;

      btn.appendChild(iconSpan);
      btn.appendChild(labelSpan);


      if (hasSubmenu) {
        const chevron = document.createElement("span");

        chevron.textContent = "›";

        Object.assign(chevron.style, {
          position: "absolute",
          right: "8px",          // collé au bord droit du menu
          top: "50%",
          transform: "translateY(-50%)",
          pointerEvents: "none",
          opacity: "0.7",
          fontSize: "14px"
        });

        btn.appendChild(chevron);

      }

      addMenuItemHover(btn);
      return btn;
    }

    const SUBMENU_OVERLAP = 5;
    const SUBMENU_VIEWPORT_MARGIN = 8;
    const MENU_VIEWPORT_MARGIN = 12;
    const SUBMENU_VERTICAL_OFFSET = 3;
    const SUBMENU_EXTRA_HEIGHT = 20;

    let activeSubmenuButton = null;
    let activeSubmenuPanel = null;

    function getVerticalPadding(node) {
      const style = window.getComputedStyle(node);
      return (parseFloat(style.paddingTop) || 0) + (parseFloat(style.paddingBottom) || 0);
    }

    function getVerticalPaddingDetail(node) {
      const style = window.getComputedStyle(node);

      return {
        top: parseFloat(style.paddingTop) || 0,
        bottom: parseFloat(style.paddingBottom) || 0
      };
    }

    function getVerticalBorders(node) {
      const style = window.getComputedStyle(node);
      return (parseFloat(style.borderTopWidth) || 0) + (parseFloat(style.borderBottomWidth) || 0);
    }

    function getVerticalMargins(node) {
      const style = window.getComputedStyle(node);
      return (parseFloat(style.marginTop) || 0) + (parseFloat(style.marginBottom) || 0);
    }

    function measureOuterHeight(node) {
      if (!node) return 0;
      return node.getBoundingClientRect().height + getVerticalMargins(node);
    }

    function getVisibleMenuButtons(container) {
      return Array.from(container.children).filter(function (el) {
        return el.tagName === "BUTTON" && el.style.display !== "none";
      });
    }

    function sumButtonsHeight(buttons) {
      return buttons.reduce(function (sum, btn) {
        return sum + Math.ceil(btn.getBoundingClientRect().height);
      }, 0);
    }

    function getMenuButtonHeight(buttons) {
      if (!buttons.length) return 0;
      return Math.ceil(buttons[0].getBoundingClientRect().height);
    }

    function getSnappedVisibleHeight(totalHeight, availableHeight, itemHeight) {
      if (availableHeight <= 0) return 0;

      if (itemHeight <= 0 || totalHeight <= availableHeight) {
        return Math.min(totalHeight, availableHeight);
      }

      const visibleCount = Math.floor(availableHeight / itemHeight);

      if (visibleCount >= 1) {
        return Math.min(totalHeight, visibleCount * itemHeight);
      }

      return availableHeight;
    }

    function applyScrollableMenuHeight(container, availableHeight, reservedHeight) {
      const buttons = getVisibleMenuButtons(container);
      const totalButtonsHeight = sumButtonsHeight(buttons);
      const itemHeight = getMenuButtonHeight(buttons);
      const safeReservedHeight = Math.max(0, Math.ceil(reservedHeight || 0));
      const availableForButtons = Math.max(0, Math.floor(availableHeight - safeReservedHeight));
      const visibleButtonsHeight = getSnappedVisibleHeight(
        totalButtonsHeight,
        availableForButtons,
        itemHeight
      );

      container.style.maxHeight = visibleButtonsHeight + "px";
      container.style.overflowY =
        totalButtonsHeight > visibleButtonsHeight + 1 ? "auto" : "hidden";

      return {
        totalButtonsHeight: totalButtonsHeight,
        visibleButtonsHeight: visibleButtonsHeight
      };
    }

    function getDropdownAvailableHeight() {
      const shellRect = shell.getBoundingClientRect();
      return Math.max(0, Math.floor(shellRect.top - MENU_VIEWPORT_MARGIN));
    }

    function applyDropdownScrollableLayout() {
      if (dropdown.hidden) return;

      const availableHeight = getDropdownAvailableHeight();
      const dropdownPadding = getVerticalPadding(dropdown);
      const iconsHeight =
        menuIconsZone.style.display === "none" ? 0 : measureOuterHeight(menuIconsZone);

      dropdown.style.maxHeight = availableHeight + "px";
      dropdown.style.overflow = "visible";

      applyScrollableMenuHeight(
        menuItemsZone,
        availableHeight,
        dropdownPadding + iconsHeight
      );
    }

    function applySubmenuScrollableLayout(submenu) {
      if (!submenu || submenu.hidden) return;

      const availableHeight = Math.max(
        0,
        window.innerHeight - (SUBMENU_VIEWPORT_MARGIN * 2)
      );

      const submenuPadding = getVerticalPaddingDetail(submenu);
      const submenuBorders = getVerticalBorders(submenu);

      submenu.style.overflowX = "hidden";

      const reservedHeight =
        submenuPadding.top +
        submenuPadding.bottom +
        submenuBorders;

      const layout = applyScrollableMenuHeight(
        submenu,
        availableHeight,
        reservedHeight
      );

      const visibleOuterHeight = Math.min(
        availableHeight,
        layout.visibleButtonsHeight +
          submenuPadding.top +
          submenuPadding.bottom +
          submenuBorders +
          SUBMENU_EXTRA_HEIGHT
      );

      submenu.style.maxHeight = visibleOuterHeight + "px";

      const hasVerticalScroll =
        layout.totalButtonsHeight > layout.visibleButtonsHeight + 1;

      submenu.style.overflowY = hasVerticalScroll ? "auto" : "hidden";
    }

    function measureSubmenu(submenu) {
      const wasHidden = submenu.hidden;
      const prevVisibility = submenu.style.visibility;
      const prevPointerEvents = submenu.style.pointerEvents;
      const prevOpacity = submenu.style.opacity;
      const prevTransform = submenu.style.transform;
      const prevTransition = submenu.style.transition;

      if (wasHidden) {
        submenu.hidden = false;
      }

      submenu.style.visibility = "hidden";
      submenu.style.pointerEvents = "none";
      submenu.style.opacity = "1";
      submenu.style.transform = "none";
      submenu.style.transition = "none";

      const rect = submenu.getBoundingClientRect();

      if (wasHidden) {
        submenu.hidden = true;
      }

      submenu.style.visibility = prevVisibility;
      submenu.style.pointerEvents = prevPointerEvents;
      submenu.style.opacity = prevOpacity;
      submenu.style.transform = prevTransform;
      submenu.style.transition = prevTransition;

      return rect;
    }

    function positionSubmenu(triggerBtn, submenu) {
      const dropdownRect = dropdown.getBoundingClientRect();
      const triggerRect = triggerBtn.getBoundingClientRect();
      const submenuRect = measureSubmenu(submenu);

      const viewportWidth = window.innerWidth;
      const viewportHeight = window.innerHeight;

      const minTopViewport = SUBMENU_VIEWPORT_MARGIN;
      const maxTopViewport = Math.max(
        minTopViewport,
        viewportHeight - SUBMENU_VIEWPORT_MARGIN - submenuRect.height
      );

      const desiredTopViewport = triggerRect.top - SUBMENU_VERTICAL_OFFSET;

      const topViewport = Math.min(
        Math.max(desiredTopViewport, minTopViewport),
        maxTopViewport
      );

      // Ouverture à droite avec recouvrement de 5 px
      const outsideLeftViewport = dropdownRect.right - SUBMENU_OVERLAP;

      // Repli à l'intérieur si pas assez de place à droite
      const insideLeftViewport = Math.max(
        dropdownRect.left,
        dropdownRect.right - submenuRect.width
      );

      const canOpenOutside =
        outsideLeftViewport + submenuRect.width <=
        viewportWidth - SUBMENU_VIEWPORT_MARGIN;

      const leftViewport = canOpenOutside
        ? outsideLeftViewport
        : insideLeftViewport;

      submenu.style.left = (leftViewport - dropdownRect.left) + "px";
      submenu.style.top = (topViewport - dropdownRect.top) + "px";
      submenu.style.marginLeft = "0";
      submenu.style.transform = "none";
    }

    function animateSubmenuOpen(submenu) {
      submenu.style.transition = "none";
      submenu.style.opacity = "0";
      submenu.style.transform = "translateY(2px) scale(0.985)";

      submenu.getBoundingClientRect();

      submenu.style.transition = "opacity 140ms ease, transform 140ms ease";
      submenu.style.opacity = "1";
      submenu.style.transform = "none";
    }

    function openSubmenu(triggerBtn, submenu) {
      if (activeSubmenuPanel === submenu && !submenu.hidden) {
        return;
      }

      closeAllSubmenus();

      submenu.hidden = false;
      applySubmenuScrollableLayout(submenu);
      positionSubmenu(triggerBtn, submenu);
      animateSubmenuOpen(submenu);

      activeSubmenuButton = triggerBtn;
      activeSubmenuPanel = submenu;
    }

    function toggleSubmenu(triggerBtn, submenu) {
      const wasHidden = submenu.hidden;

      if (!wasHidden) {
        closeAllSubmenus();
        return;
      }

      openSubmenu(triggerBtn, submenu);
    }

    function bindSubmenuHover(triggerBtn, submenu) {
      triggerBtn.addEventListener("mouseenter", function () {
        if (dropdown.hidden) return;
        openSubmenu(triggerBtn, submenu);
      });
    }

    function bindSimpleItemHover(btn) {
      btn.addEventListener("mouseenter", function () {
        if (dropdown.hidden) return;
        closeAllSubmenus();
      });
    }

    menuIconsZone.addEventListener("mouseenter", function () {
      if (dropdown.hidden) return;
      closeAllSubmenus();
    });

    endpointBtn = createMenuItem("Endpoint", "\uE1D2", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.endpoint) return;

      toggleSubmenu(endpointBtn, endpointMenu);
    }, true);

    const webResearchBtn = createMenuItem("Web research", "\uE12B", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.webResearch) return;
      toggleWebResearch();
      render();
    });

    const thinkingBtn = createMenuItem("Thinking", "\uEA91", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.thinking) return;

      toggleSubmenu(thinkingBtn, thinkingMenu);
    }, true);

    const fileBtn = createMenuItem("Attach files", "\uE16C", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.chatFiles) return;
      /*fileInput.click();*/
      window.chrome.webview.postMessage({
       event: "open-file-dialog",
       target: "documents"
      });
    });

    const knowledgeBtn = createMenuItem("Knowledge search", "\uE11A", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.knowledgeSearch) return;
      /*knowledgeInput.click();*/
      window.chrome.webview.postMessage({
       event: "open-file-dialog",
       target: "knowledge"
      });
    });

    const visionBtn = createMenuItem("Vision", "\uE8B8", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.vision) return;
      /*imageInput.click();*/
      window.chrome.webview.postMessage({
       event: "open-file-dialog",
       target: "images"
      });
    });

    const deepResearchBtn = createMenuItem("Deep Research", "\uF6FA", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.deepResearch) return;

      if (host.__features.has("deep-research"))
        host.__features.delete("deep-research");
      else
        host.__features.add("deep-research");
      render();
    });

    const integrationBtn = createMenuItem("Integration", "\uEB3C", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.integration) return;

      toggleSubmenu(integrationBtn, integrationMenu);
    }, true);

    const mediaBtn = createMenuItem("Media", "\uF8A6", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.media) return;

      toggleSubmenu(mediaBtn, mediaMenu);
    }, true);

    customBtn = createMenuItem("Custom", "\uE15E", function (e) {
      e.stopPropagation();
      if (!host.__enabledFunctions.custom) return;

      window.chrome.webview.postMessage({
        event: "open-custom-dialog",
        target: "custom"
      });
    });

    systemPromptBtn = document.createElement("button");
    systemPromptBtn.id = "InputSystemPromptButton";
    systemPromptBtn.type = "button";
    systemPromptBtn.title = "";

    styleButton(systemPromptBtn);
    addHover(systemPromptBtn);

    systemPromptBtn.style.display = "flex";
    systemPromptBtn.style.alignItems = "center";
    systemPromptBtn.style.justifyContent = "center";
    systemPromptBtn.style.gap = "6px";

    // IMPORTANT : break the square button imposed by styleButton
    systemPromptBtn.style.width = "auto";
    systemPromptBtn.style.minWidth = "0";
    systemPromptBtn.style.padding = "6px 12px";

    systemPromptBtn.style.transform = "none";

    systemPromptBtn.style.height = "32px";
    systemPromptBtn.style.borderRadius = "16px";
    systemPromptBtn.style.whiteSpace = "nowrap";

    // icon
    const systemPromptIcon = document.createElement("span");
    systemPromptIcon.textContent = "\uE115";
    systemPromptIcon.style.fontFamily = "Segoe Fluent Icons";
    systemPromptIcon.style.fontSize = "14px";
    systemPromptIcon.style.lineHeight = "1";

    // text
    const systemPromptLabel = document.createElement("span");
    systemPromptLabel.textContent = "settings";
    systemPromptLabel.style.fontFamily = "Segoe UI, sans-serif";
    systemPromptLabel.style.fontSize = "13px";

    // assembly
    systemPromptBtn.appendChild(systemPromptIcon);
    systemPromptBtn.appendChild(systemPromptLabel);

    systemPromptBtn.onclick = function (e) {
      e.stopPropagation();

      if (window.chrome && window.chrome.webview) {
        window.chrome.webview.postMessage({
          event: "system-settings"
        });
      }
    };

    modelBtn = document.createElement("button");
    modelBtn.id = "InputModelButton";
    modelBtn.type = "button";
    modelBtn.title = "";

    styleButton(modelBtn);
    addHover(modelBtn);

    modelBtn.style.display = "flex";
    modelBtn.style.alignItems = "center";
    modelBtn.style.justifyContent = "center";
    modelBtn.style.gap = "6px";

    // IMPORTANT : break the square button imposed by styleButton
    modelBtn.style.width = "auto";
    modelBtn.style.minWidth = "0";
    modelBtn.style.padding = "6px 12px";

    modelBtn.style.transform = "none";

    modelBtn.style.height = "32px";
    modelBtn.style.borderRadius = "16px";
    modelBtn.style.whiteSpace = "nowrap";

    // icon
    const modelIcon = document.createElement("span");
    modelIcon.textContent = "\uE7BE";
    modelIcon.style.fontFamily = "Segoe Fluent Icons";
    modelIcon.style.fontSize = "22px";
    modelIcon.style.lineHeight = "1";

    // text
    const modelLabel = document.createElement("span");
    modelLabel.textContent = "model";
    modelLabel.style.fontFamily = "Segoe UI, sans-serif";
    modelLabel.style.fontSize = "13px";

    // assembly
    modelBtn.appendChild(modelIcon);
    modelBtn.appendChild(modelLabel);

    modelBtn.onclick = function (e) {
      e.stopPropagation();

      if (window.chrome && window.chrome.webview) {
        window.chrome.webview.postMessage({
          event: "model-selection"
        });
      }
    };

    projectBtn = document.createElement("button");
    projectBtn.id = "InputProjectButton";
    projectBtn.type = "button";
    projectBtn.title = "";

    styleButton(projectBtn);
    addHover(projectBtn);

    projectBtn.style.display = "flex";
    projectBtn.style.alignItems = "center";
    projectBtn.style.justifyContent = "center";
    projectBtn.style.gap = "6px";

    projectBtn.style.width = "auto";
    projectBtn.style.minWidth = "0";
    projectBtn.style.padding = "6px 12px";

    projectBtn.style.transform = "none";

    projectBtn.style.height = "32px";
    projectBtn.style.borderRadius = "16px";
    projectBtn.style.whiteSpace = "nowrap";

    const projectIcon = document.createElement("span");
    projectIcon.textContent = "";
    projectIcon.style.fontFamily = "Segoe Fluent Icons";
    projectIcon.style.fontSize = "14px";
    projectIcon.style.lineHeight = "1";

    projectLabel = document.createElement("span");
    projectLabel.textContent = "Project: none";
    projectLabel.style.fontFamily = "Segoe UI, sans-serif";
    projectLabel.style.fontSize = "13px";

    projectBtn.appendChild(projectIcon);
    projectBtn.appendChild(projectLabel);

    projectMenu = document.createElement("div");
    projectMenu.id = "InputProjectMenu";
    projectMenu.hidden = true;

    Object.assign(projectMenu.style, {
      position: "fixed",
      minWidth: "220px",
      padding: "6px",
      borderRadius: "12px",
      background: "var(--input-menu-bg, #2b2b2b)",
      border: "1px solid var(--input-menu-border, rgba(255,255,255,0.08))",
      boxSizing: "border-box",
      overflowX: "hidden",
      overflowY: "auto",
      zIndex: "1003",
      opacity: "0",
      transform: "translateY(6px) scale(0.97)",
      transformOrigin: "bottom left",
      transition: "opacity 180ms ease, transform 180ms ease",
      willChange: "opacity, transform"
    });

    if (!document.getElementById("input-project-menu-style")) {
      const projectMenuStyle = document.createElement("style");
      projectMenuStyle.id = "input-project-menu-style";
      projectMenuStyle.textContent = `
        .input-project-menu-option {
          appearance: none;
          -webkit-appearance: none;
          width: 100%;
          min-height: 32px;
          padding: 0 12px;
          border: 0;
          border-radius: 10px;
          box-sizing: border-box;
          background: transparent;
          color: var(--input-menu-text, #ddd);
          font: inherit;
          font-family: "Segoe UI", sans-serif;
          font-size: 13px;
          display: flex;
          align-items: center;
          justify-content: space-between;
          gap: 12px;
          text-align: left;
          cursor: pointer;
          transition: background 140ms ease, color 140ms ease;
        }

        .input-project-menu-remove {
          flex: 0 0 18px;
          width: 18px;
          height: 18px;
          border-radius: 50%;
          display: inline-flex;
          align-items: center;
          justify-content: center;
          opacity: 0;
          pointer-events: none;
          color: var(--input-menu-text, #ddd);
          font-size: 11px;
          line-height: 1;
          transition: opacity 120ms ease, background 120ms ease, color 120ms ease;
        }

        .input-project-menu-option:hover .input-project-menu-remove,
        .input-project-menu-option:focus .input-project-menu-remove,
        .input-project-menu-option:focus-within .input-project-menu-remove {
          opacity: 1;
          pointer-events: auto;
        }

        .input-project-menu-remove:hover {
          background: var(--input-menu-item-hover-bg, rgba(255,255,255,0.12));
          color: var(--input-menu-item-hover-text, #ffffff);
        }

        .input-project-menu-option:hover,
        .input-project-menu-option:focus {
          background: var(--input-menu-item-hover-bg, rgba(255,255,255,0.08));
          color: var(--input-menu-item-hover-text, #ffffff);
          outline: none;
        }

        .input-project-menu-option.is-selected {
          background: color-mix(in srgb, var(--reasoning-accent, #4f8cff) 12%, transparent);
          color: var(--text-main, #ffffff);
        }

        .input-project-menu-option.is-selected:hover,
        .input-project-menu-option.is-selected:focus {
          background: color-mix(in srgb, var(--reasoning-accent, #4f8cff) 20%, transparent);
        }

        .input-project-menu-option-label {
          min-width: 0;
          flex: 1 1 auto;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .input-project-menu-option-check {
          flex: 0 0 auto;
          width: 18px;
          text-align: right;
          color: var(--reasoning-accent, #4f8cff);
          font-size: 13px;
          font-weight: 700;
        }

        .input-project-menu-separator {
          border: 0;
          border-top: 1px solid var(--input-menu-border, rgba(255,255,255,0.08));
          margin: 6px 4px;
        }
      `;
      document.head.appendChild(projectMenuStyle);
    }

    function buildProjectMenuOption(labelText, opts) {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "input-project-menu-option" + (opts && opts.selected ? " is-selected" : "");

      if (opts && typeof opts.onRemove === "function") {
        const removeSpan = document.createElement("span");
        removeSpan.className = "input-project-menu-remove";
        removeSpan.textContent = "✕";
        removeSpan.title = t("input.project.delete", "Delete");
        removeSpan.setAttribute("aria-hidden", "true");
        removeSpan.addEventListener("click", function (e) {
          e.preventDefault();
          e.stopPropagation();
          opts.onRemove(e);
        });
        btn.appendChild(removeSpan);
      }

      const labelSpan = document.createElement("span");
      labelSpan.className = "input-project-menu-option-label";
      labelSpan.textContent = labelText;
      btn.appendChild(labelSpan);

      const checkSpan = document.createElement("span");
      checkSpan.className = "input-project-menu-option-check";
      checkSpan.textContent = opts && opts.selected ? "✓" : "";
      btn.appendChild(checkSpan);

      if (opts && typeof opts.onClick === "function")
        btn.addEventListener("click", opts.onClick);

      if (opts && opts.role)
        btn.dataset.role = opts.role;

      return btn;
    }

    function renderProjectMenu() {
      projectMenu.innerHTML = "";

      const addLabel = t("input.project.add", "Add project");
      const addBtn = buildProjectMenuOption("+  " + addLabel, {
        role: "project-menu-add",
        onClick: function (e) {
          e.stopPropagation();
          closeProjectMenu();
          if (window.chrome && window.chrome.webview) {
            window.chrome.webview.postMessage({ event: "folder-selection" });
          }
        }
      });
      projectMenu.appendChild(addBtn);

      host.__projects.forEach(function (project) {
        if (!project) return;

        const row = buildProjectMenuOption(project.displayName || project.fullPath, {
          selected: !!project.selected,
          onClick: function (e) {
            e.stopPropagation();
            setActiveProject(project.fullPath);
            closeProjectMenu();
          },
          onRemove: function () {
            removeProject(project.fullPath);
          }
        });
        row.dataset.role = "project-menu-item";
        row.dataset.fullPath = project.fullPath;

        projectMenu.appendChild(row);
      });

      const separator = document.createElement("hr");
      separator.className = "input-project-menu-separator";
      projectMenu.appendChild(separator);

      const noneLabelText = t("input.project.noneUsed", "No project used");
      const noneBtn = buildProjectMenuOption("-  " + noneLabelText, {
        role: "project-menu-none",
        onClick: function (e) {
          e.stopPropagation();
          clearActiveProject();
          closeProjectMenu();
        }
      });
      projectMenu.appendChild(noneBtn);

      if (!projectMenu.hidden)
        positionProjectMenu();
    }

    function getProjectDisplayName(fullPath) {
      const value = typeof fullPath === "string" ? fullPath.trim() : "";
      if (!value) return "";

      const segments = value.split(/[\\/]+/).filter(Boolean);
      return segments.length ? segments[segments.length - 1] : value;
    }

    function buildProjectState() {
      return host.__projects
        .filter(function (project) {
          return !!(project && project.fullPath);
        })
        .map(function (project) {
          return {
            displayName: project.displayName || getProjectDisplayName(project.fullPath),
            fullPath: project.fullPath,
            selected: !!project.selected
          };
        });
    }

    function notifyProjectStateChanged() {
      if (!window.chrome || !window.chrome.webview)
        return;

      window.chrome.webview.postMessage({
        event: "folder-state",
        state: buildProjectState()
      });
    }

    function applyProjectState(projects) {
      if (!Array.isArray(projects))
        return;

      const seen = new Set();
      const nextProjects = [];
      let selectedFound = false;

      projects.forEach(function (project) {
        if (!project) return;

        const fullPath = String(
          project.fullPath ||
          project.full_path ||
          project.folder_path ||
          ""
        ).trim();

        if (!fullPath || seen.has(fullPath))
          return;

        seen.add(fullPath);

        const selected = !!project.selected && !selectedFound;
        if (selected)
          selectedFound = true;

        nextProjects.push({
          displayName: project.displayName || project.display_name || getProjectDisplayName(fullPath),
          fullPath: fullPath,
          selected: selected
        });
      });

      host.__projects = nextProjects;
      updateProjectButtonLabel();
      renderProjectMenu();
    }

    function setActiveProject(fullPath) {
      let changed = false;
      for (let i = 0; i < host.__projects.length; i += 1) {
        const p = host.__projects[i];
        if (!p) continue;
        const next = (p.fullPath === fullPath);
        if (p.selected !== next) {
          p.selected = next;
          changed = true;
        }
      }
      if (changed) {
        updateProjectButtonLabel();
        renderProjectMenu();
        notifyProjectStateChanged();
      }
    }

    function clearActiveProject() {
      let changed = false;
      for (let i = 0; i < host.__projects.length; i += 1) {
        const p = host.__projects[i];
        if (p && p.selected) {
          p.selected = false;
          changed = true;
        }
      }
      if (changed) {
        updateProjectButtonLabel();
        renderProjectMenu();
        notifyProjectStateChanged();
      }
    }

    function removeProject(fullPath) {
      let wasSelected = false;
      let changed = false;
      for (let i = host.__projects.length - 1; i >= 0; i -= 1) {
        const p = host.__projects[i];
        if (p && p.fullPath === fullPath) {
          if (p.selected) wasSelected = true;
          host.__projects.splice(i, 1);
          changed = true;
        }
      }
      if (wasSelected)
        updateProjectButtonLabel();
      renderProjectMenu();
      if (changed)
        notifyProjectStateChanged();
    }

    host.__renderProjectMenu = renderProjectMenu;
    host.__applyProjectState = applyProjectState;
    host.__notifyProjectStateChanged = notifyProjectStateChanged;

    function getActiveProject() {
      for (let i = 0; i < host.__projects.length; i += 1) {
        if (host.__projects[i] && host.__projects[i].selected)
          return host.__projects[i];
      }
      return null;
    }

    function updateProjectButtonLabel() {
      const active = getActiveProject();
      const noneLabel = t("input.project.none", "none");
      const prefix = t("input.menu.project", "Project");
      const name = active && active.displayName ? active.displayName : noneLabel;
      projectLabel.textContent = prefix + ": " + name;
    }

    host.__updateProjectButtonLabel = updateProjectButtonLabel;

    function positionProjectMenu() {
      const btnRect = projectBtn.getBoundingClientRect();
      const prevMaxHeight = projectMenu.style.maxHeight;
      const prevTransform = projectMenu.style.transform;

      projectMenu.style.maxHeight = "none";
      projectMenu.style.transform = "none";
      projectMenu.style.visibility = "hidden";
      projectMenu.style.display = "block";
      const menuRect = projectMenu.getBoundingClientRect();
      projectMenu.style.display = "";
      projectMenu.style.visibility = "";
      projectMenu.style.transform = prevTransform;

      const margin = 8;
      const gap = 6;
      const viewportWidth = window.innerWidth || document.documentElement.clientWidth || 0;
      const viewportHeight = window.innerHeight || document.documentElement.clientHeight || 0;
      const availableHeight = Math.max(0, viewportHeight - (margin * 2));
      const menuHeight = Math.min(menuRect.height, availableHeight);
      let left = btnRect.left;
      let top = btnRect.bottom + gap;
      const overflowBottom = top + menuHeight - (viewportHeight - margin);

      if (left + menuRect.width > viewportWidth - margin)
        left = Math.max(margin, viewportWidth - menuRect.width - margin);

      if (overflowBottom > 0)
        top -= overflowBottom;

      if (top < margin)
        top = margin;

      projectMenu.style.maxHeight = availableHeight > 0
        ? availableHeight + "px"
        : prevMaxHeight;
      projectMenu.style.left = left + "px";
      projectMenu.style.top = top + "px";
    }

    function openProjectMenu() {
      renderProjectMenu();
      projectMenu.hidden = false;
      projectMenu.style.opacity = "0";
      projectMenu.style.transform = "translateY(6px) scale(0.97)";
      positionProjectMenu();
      projectMenu.getBoundingClientRect();
      projectMenu.style.opacity = "1";
      projectMenu.style.transform = "translateY(0) scale(1)";
    }

    function closeProjectMenu() {
      projectMenu.hidden = true;
      projectMenu.style.opacity = "0";
      projectMenu.style.transform = "translateY(6px) scale(0.97)";
    }

    host.__closeProjectMenu = closeProjectMenu;

    projectBtn.onclick = function (e) {
      e.stopPropagation();
      if (projectMenu.hidden)
        openProjectMenu();
      else
        closeProjectMenu();
    };

    document.addEventListener("click", function (e) {
      const inProjectMenu = projectMenu.contains(e.target);
      const inProjectButton = projectBtn.contains(e.target);

      if (projectMenu.hidden) return;
      if (inProjectMenu || inProjectButton) return;

      closeProjectMenu();
    }, true);

    window.addEventListener("resize", function () {
      if (!projectMenu.hidden) positionProjectMenu();
    });

    bindSubmenuHover(endpointBtn, endpointMenu);
    bindSubmenuHover(thinkingBtn, thinkingMenu);
    bindSubmenuHover(integrationBtn, integrationMenu);
    bindSubmenuHover(mediaBtn, mediaMenu);

    bindSimpleItemHover(webResearchBtn);
    bindSimpleItemHover(fileBtn);
    bindSimpleItemHover(knowledgeBtn);
    bindSimpleItemHover(visionBtn);
    bindSimpleItemHover(deepResearchBtn);
    bindSimpleItemHover(customBtn);

    function closeAllSubmenus() {
      [endpointMenu, thinkingMenu, integrationMenu, mediaMenu].forEach(function (menu) {
        menu.hidden = true;
        menu.style.opacity = "0";
        menu.style.transform = "translateY(2px) scale(0.985)";
      });

      activeSubmenuButton = null;
      activeSubmenuPanel = null;
    }

    function syncDropdownWidth() {
      const shellRect = shell.getBoundingClientRect();
      const width = Math.round(shellRect.width);

      dropdown.style.width = width + "px";
      dropdown.style.minWidth = width + "px";
      dropdown.style.maxWidth = width + "px";
    }

    function syncOpenDropdownLayout() {
      if (dropdown.hidden) return;

      syncDropdownWidth();
      applyDropdownScrollableLayout();

      if (
        activeSubmenuButton &&
        activeSubmenuPanel &&
        !activeSubmenuPanel.hidden
      ) {
        applySubmenuScrollableLayout(activeSubmenuPanel);
        positionSubmenu(activeSubmenuButton, activeSubmenuPanel);
      }
    }

    function animateDropdownOpen() {
      dropdown.style.transition = "none";
      dropdown.style.opacity = "0";
      dropdown.style.transform = "translateY(calc(-100% + 6px)) scale(0.985)";

      dropdown.getBoundingClientRect();

      dropdown.style.transition = "opacity 180ms ease, transform 180ms ease";
      dropdown.style.opacity = "1";
      dropdown.style.transform = "translateY(-100%) scale(1)";
    }

    function openDropdown() {
      syncDropdownWidth();
      dropdown.hidden = false;
      applyDropdownScrollableLayout();
      animateDropdownOpen();
    }

    function closeDropdown() {
      dropdown.hidden = true;
      dropdown.style.opacity = "0";
      dropdown.style.transform = "translateY(calc(-100% + 6px)) scale(0.985)";
      closeAllSubmenus();
    }

    window.closeInputMainMenu = function () {
      closeDropdown();
    };

    window.openInputMainMenu = function () {
      if (dropdown.hidden) openDropdown();
    };

    menuItemsZone.appendChild(endpointBtn);
    menuItemsZone.appendChild(webResearchBtn);
    menuItemsZone.appendChild(thinkingBtn);
    menuItemsZone.appendChild(fileBtn);
    menuItemsZone.appendChild(knowledgeBtn);
    menuItemsZone.appendChild(visionBtn);
    menuItemsZone.appendChild(deepResearchBtn);
    menuItemsZone.appendChild(integrationBtn);
    menuItemsZone.appendChild(mediaBtn);
    menuItemsZone.appendChild(customBtn);

    menuIconsZone.appendChild(systemPromptBtn);
    menuIconsZone.appendChild(modelBtn);
    menuIconsZone.appendChild(projectBtn);

    document.body.appendChild(projectMenu);

    updateProjectButtonLabel();
    renderProjectMenu();

    dropdown.appendChild(menuItemsZone);
    dropdown.appendChild(menuIconsZone);

    dropdown.appendChild(endpointMenu);
    dropdown.appendChild(thinkingMenu);
    dropdown.appendChild(integrationMenu);
    dropdown.appendChild(mediaMenu);

    integrationFunctionBtn = createMenuItem("Function","\uE1B3",function(e){
      e.stopPropagation();
      if (!host.__enabledFunctions.integrationFunction) return;

      window.chrome.webview.postMessage({
        event: "open-integration-function-dialog",
        target: "integration-function"
      });

      integrationMenu.hidden = true;
    });

    integrationMcpBtn = createMenuItem("MCP","\uE8CE",function(e){
      e.stopPropagation();
      if (!host.__enabledFunctions.integrationMcp) return;

      window.chrome.webview.postMessage({
        event: "open-integration-mcp-dialog",
        target: "integration-mcp"
      });

      integrationMenu.hidden = true;
    });

    integrationSkillsBtn = createMenuItem("Skills","\uECA7",function(e){
      e.stopPropagation();
      if (!host.__enabledFunctions.integrationSkills) return;

      window.chrome.webview.postMessage({
        event: "open-integration-skills-dialog",
        target: "integration-skills"
      });

      integrationMenu.hidden = true;
    });

    integrationAgentsBtn = createMenuItem("Agents","\uE99A",function(e){
      e.stopPropagation();
      if (!host.__enabledFunctions.integrationAgents) return;

      window.chrome.webview.postMessage({
        event: "open-integration-agents-dialog",
        target: "integration-agents"
      });

      integrationMenu.hidden = true;
    });

    function toggleMediaFeature(featureName) {
      const key = "media-" + featureName;

      if (host.__features.has(key))
        host.__features.delete(key);
      else
        host.__features.add(key);
    }

    mediaCreateImageBtn = createMenuItem("Create Image", "\uEB9F", function(e){
      e.stopPropagation();
      toggleMediaFeature("create-image");
      mediaMenu.hidden = true;
      render();
    });

    mediaCreateVideoBtn = createMenuItem("Create Video", "\uE714", function(e){
      e.stopPropagation();
      toggleMediaFeature("create-video");
      mediaMenu.hidden = true;
      render();
    });

    mediaCreateAudioBtn = createMenuItem("Create Audio", "\uED1F", function(e){
      e.stopPropagation();
      toggleMediaFeature("create-audio");
      mediaMenu.hidden = true;
      render();
    });

    mediaSpeechToTextBtn = createMenuItem("Speech to text", "\uF47F", function(e){
      e.stopPropagation();

      window.chrome.webview.postMessage({
      event: "open-file-dialog",
      target: "speech"
  });

  mediaMenu.hidden = true;
    });

    mediaTextToSpeechBtn = createMenuItem("Text to speech", "\uF8B2", function(e){
      e.stopPropagation();
      toggleMediaFeature("text-to-speech");
      mediaMenu.hidden = true;
      render();
    });

    integrationFunctionBtn.style.paddingLeft = "10px";
    integrationMcpBtn.style.paddingLeft = "10px";
    integrationSkillsBtn.style.paddingLeft = "10px";
    integrationAgentsBtn.style.paddingLeft = "10px";

    mediaCreateImageBtn.style.paddingLeft = "10px";
    mediaCreateVideoBtn.style.paddingLeft = "10px";
    mediaCreateAudioBtn.style.paddingLeft = "10px";
    mediaSpeechToTextBtn.style.paddingLeft = "10px";
    mediaTextToSpeechBtn.style.paddingLeft = "10px";

    integrationMenu.appendChild(integrationFunctionBtn);
    integrationMenu.appendChild(integrationMcpBtn);
    integrationMenu.appendChild(integrationSkillsBtn);
    integrationMenu.appendChild(integrationAgentsBtn);

    mediaMenu.appendChild(mediaCreateImageBtn);
    mediaMenu.appendChild(mediaCreateVideoBtn);
    mediaMenu.appendChild(mediaCreateAudioBtn);
    mediaMenu.appendChild(mediaSpeechToTextBtn);
    mediaMenu.appendChild(mediaTextToSpeechBtn);

    endpointChatCompletionBtn = createMenuItem("v1/chat/completion", "", function (e) {
      e.stopPropagation();
      setEndpoint("chat-completion");
      endpointMenu.hidden = true;
      render();
    });
    endpointChatCompletionBtn.title = "OpenAI, DeepSeek, MistralAI";
    endpointChatCompletionBtn.style.paddingLeft = "10px";

    endpointChatResponseBtn = createMenuItem("v1/chat/response", "", function (e) {
      e.stopPropagation();
      setEndpoint("chat-response");
      endpointMenu.hidden = true;
      render();
    });
    endpointChatResponseBtn.title = "OpenAI";
    endpointChatResponseBtn.style.paddingLeft = "10px";

    endpointMessageBtn = createMenuItem("v1/message", "", function (e) {
      e.stopPropagation();
      setEndpoint("message");
      endpointMenu.hidden = true;
      render();
    });
    endpointMessageBtn.title = "Claude";
    endpointMessageBtn.style.paddingLeft = "10px";

    endpointGenerateContentBtn = createMenuItem(":generateContent", "", function (e) {
      e.stopPropagation();
      setEndpoint("generate-content");
      endpointMenu.hidden = true;
      render();
    });
    endpointGenerateContentBtn.title = "Gemini";
    endpointGenerateContentBtn.style.paddingLeft = "10px";

    endpointInteractionsBtn = createMenuItem("v1/interactions", "", function (e) {
      e.stopPropagation();
      setEndpoint("interactions");
      endpointMenu.hidden = true;
      render();
    });
    endpointInteractionsBtn.title = "Gemini";
    endpointInteractionsBtn.style.paddingLeft = "10px";

    endpointConversationBtn = createMenuItem("v1/conversation", "", function (e) {
      e.stopPropagation();
      setEndpoint("conversation");
      endpointMenu.hidden = true;
      render();
    });
    endpointConversationBtn.title = "MistralAI";
    endpointConversationBtn.style.paddingLeft = "10px";

    endpointMenu.appendChild(endpointChatCompletionBtn);
    endpointMenu.appendChild(endpointChatResponseBtn);
    endpointMenu.appendChild(endpointMessageBtn);
    endpointMenu.appendChild(endpointGenerateContentBtn);
    endpointMenu.appendChild(endpointInteractionsBtn);
    endpointMenu.appendChild(endpointConversationBtn);

    [
      { key: "thinkingLow", level: "low" },
      { key: "thinkingMedium", level: "medium" },
      { key: "thinkingHigh", level: "high" }
    ].forEach(function (cfg) {

      const btn = createMenuItem(
        cfg.level.charAt(0).toUpperCase() + cfg.level.slice(1),
        "",
        function (e) {
          e.stopPropagation();
          setThinking(cfg.level);
          thinkingMenu.hidden = true;
          render();
        }
      );

      btn.style.paddingLeft = "10px";

      btn.style.display = host.__enabledFunctions[cfg.key] ? "" : "none";

      thinkingMenu.appendChild(btn);
    });


    function updateMenuState() {
      endpointBtn.style.display = host.__enabledFunctions.endpoint ? "" : "none";
      endpointChatCompletionBtn.style.display = host.__enabledFunctions.endpointChatCompletion ? "" : "none";
      endpointChatResponseBtn.style.display = host.__enabledFunctions.endpointChatResponse ? "" : "none";
      endpointMessageBtn.style.display = host.__enabledFunctions.endpointMessage ? "" : "none";
      endpointGenerateContentBtn.style.display = host.__enabledFunctions.endpointGenerateContent ? "" : "none";
      endpointInteractionsBtn.style.display = host.__enabledFunctions.endpointInteractions ? "" : "none";
      endpointConversationBtn.style.display = host.__enabledFunctions.endpointConversation ? "" : "none";
      webResearchBtn.style.display = host.__enabledFunctions.webResearch ? "" : "none";
      thinkingBtn.style.display = host.__enabledFunctions.thinking ? "" : "none";
      fileBtn.style.display = host.__enabledFunctions.chatFiles ? "" : "none";
      knowledgeBtn.style.display = host.__enabledFunctions.knowledgeSearch ? "" : "none";
      visionBtn.style.display = host.__enabledFunctions.vision ? "" : "none";
      deepResearchBtn.style.display = host.__enabledFunctions.deepResearch ? "" : "none";
      integrationBtn.style.display = host.__enabledFunctions.integration ? "" : "none";
      mediaBtn.style.display = host.__enabledFunctions.media ? "" : "none";
      customBtn.style.display = host.__enabledFunctions.custom ? "" : "none";

      integrationFunctionBtn.style.display = host.__enabledFunctions.integrationFunction ? "" : "none";
      integrationMcpBtn.style.display = host.__enabledFunctions.integrationMcp ? "" : "none";
      integrationSkillsBtn.style.display = host.__enabledFunctions.integrationSkills ? "" : "none";
      integrationAgentsBtn.style.display = host.__enabledFunctions.integrationAgents ? "" : "none";

      mediaCreateImageBtn.style.display = host.__enabledFunctions.mediaCreateImage ? "" : "none";
      mediaCreateVideoBtn.style.display = host.__enabledFunctions.mediaCreateVideo ? "" : "none";
      mediaCreateAudioBtn.style.display = host.__enabledFunctions.mediaCreateAudio ? "" : "none";
      mediaSpeechToTextBtn.style.display = host.__enabledFunctions.mediaSpeechToText ? "" : "none";
      mediaTextToSpeechBtn.style.display = host.__enabledFunctions.mediaTextToSpeech ? "" : "none";

      thinkingMenu.querySelectorAll("button")[0].style.display = host.__enabledFunctions.thinkingLow ? "" : "none";
      thinkingMenu.querySelectorAll("button")[1].style.display = host.__enabledFunctions.thinkingMedium ? "" : "none";
      thinkingMenu.querySelectorAll("button")[2].style.display = host.__enabledFunctions.thinkingHigh ? "" : "none";

      systemPromptBtn.style.display = host.__enabledFunctions.systemPrompt ? "flex" : "none";
      modelBtn.style.display = host.__enabledFunctions.model ? "flex" : "none";
      projectBtn.style.display = host.__enabledFunctions.project ? "flex" : "none";

      menuIconsZone.style.display =
        (
          host.__enabledFunctions.systemPrompt ||
          host.__enabledFunctions.model ||
          host.__enabledFunctions.project
        )
          ? "flex"
          : "none";
    }

    function applyCapabilities(msg) {
      if (!msg || msg.type !== "setCapabilities")
        return;

      const hasOwn = function (key) {
        return Object.prototype.hasOwnProperty.call(msg, key);
      };

      [
        ["endpoint", "endpoint"],
        ["endpointChatCompletion", "endpointChatCompletion"],
        ["endpointChatResponse", "endpointChatResponse"],
        ["endpointMessage", "endpointMessage"],
        ["endpointGenerateContent", "endpointGenerateContent"],
        ["endpointInteractions", "endpointInteractions"],
        ["endpointConversation", "endpointConversation"],
        ["webResearch", "webSearch"],
        ["thinking", "thinking"],
        ["thinkingLow", "thinkingLow"],
        ["thinkingMedium", "thinkingMedium"],
        ["thinkingHigh", "thinkingHigh"],
        ["chatFiles", "files"],
        ["knowledgeSearch", "knowledgeSearch"],
        ["vision", "vision"],
        ["deepResearch", "deepResearch"],
        ["integration", "integration"],
        ["integrationFunction", "integrationFunction"],
        ["integrationMcp", "integrationMcp"],
        ["integrationSkills", "integrationSkills"],
        ["integrationAgents", "integrationAgents"],
        ["media", "media"],
        ["mediaCreateImage", "mediaCreateImage"],
        ["mediaCreateVideo", "mediaCreateVideo"],
        ["mediaCreateAudio", "mediaCreateAudio"],
        ["mediaSpeechToText", "mediaSpeechToText"],
        ["mediaTextToSpeech", "mediaTextToSpeech"],
        ["custom", "custom"],
        ["systemPrompt", "systemPrompt"],
        ["model", "model"],
        ["project", "project"]
      ].forEach(function (pair) {
        const targetKey = pair[0];
        const sourceKey = pair[1];

        if (hasOwn(sourceKey)) {
          host.__enabledFunctions[targetKey] = !!msg[sourceKey];
        }
      });

      if (
        (hasOwn("endpoint") && !host.__enabledFunctions.endpoint) ||
        (hasOwn("endpointChatCompletion") && !host.__enabledFunctions.endpointChatCompletion && host.__features.has("endpoint-chat-completion")) ||
        (hasOwn("endpointChatResponse") && !host.__enabledFunctions.endpointChatResponse && host.__features.has("endpoint-chat-response")) ||
        (hasOwn("endpointMessage") && !host.__enabledFunctions.endpointMessage && host.__features.has("endpoint-message")) ||
        (hasOwn("endpointGenerateContent") && !host.__enabledFunctions.endpointGenerateContent && host.__features.has("endpoint-generate-content")) ||
        (hasOwn("endpointInteractions") && !host.__enabledFunctions.endpointInteractions && host.__features.has("endpoint-interactions")) ||
        (hasOwn("endpointConversation") && !host.__enabledFunctions.endpointConversation && host.__features.has("endpoint-conversation"))
      ) {
        clearEndpoint();
      }

      if (
        (hasOwn("thinking") && !host.__enabledFunctions.thinking) ||
        (hasOwn("thinkingLow") && !host.__enabledFunctions.thinkingLow && host.__features.has("thinking-low")) ||
        (hasOwn("thinkingMedium") && !host.__enabledFunctions.thinkingMedium && host.__features.has("thinking-medium")) ||
        (hasOwn("thinkingHigh") && !host.__enabledFunctions.thinkingHigh && host.__features.has("thinking-high"))
      ) {
        clearThinking();
      }

      if (hasOwn("webSearch") && !host.__enabledFunctions.webResearch) {
        host.__features.delete("web-research");
      }

      if (hasOwn("files") && !host.__enabledFunctions.chatFiles) {
        host.__files = [];
        host.__promptFragments = [];
        host.__nextPasteFragmentIndex = 1;
      }

      if (hasOwn("knowledgeSearch") && !host.__enabledFunctions.knowledgeSearch) {
        host.__features.delete("knowledge-search");
        host.__knowledgeFiles = [];
      }

      if (hasOwn("vision") && !host.__enabledFunctions.vision) {
        host.__images = [];
      }

      if (hasOwn("deepResearch") && !host.__enabledFunctions.deepResearch) {
        host.__features.delete("deep-research");
      }

      if (hasOwn("integration") && !host.__enabledFunctions.integration) {
        host.__features.delete("integration-function");
        host.__features.delete("integration-mcp");
        host.__features.delete("integration-skills");
        host.__features.delete("integration-agents");
        host.__integrationFunctions = [];
        host.__integrationMcps = [];
        host.__integrationSkills = [];
        host.__integrationAgents = [];
      }

      if (hasOwn("integrationFunction") && !host.__enabledFunctions.integrationFunction) {
        host.__features.delete("integration-function");
        host.__integrationFunctions = [];
      }

      if (hasOwn("integrationMcp") && !host.__enabledFunctions.integrationMcp) {
        host.__features.delete("integration-mcp");
        host.__integrationMcps = [];
      }

      if (hasOwn("integrationSkills") && !host.__enabledFunctions.integrationSkills) {
        host.__features.delete("integration-skills");
        host.__integrationSkills = [];
      }

      if (hasOwn("integrationAgents") && !host.__enabledFunctions.integrationAgents) {
        host.__features.delete("integration-agents");
        host.__integrationAgents = [];
      }

      if (hasOwn("media") && !host.__enabledFunctions.media) {
        host.__features.delete("media-create-image");
        host.__features.delete("media-create-video");
        host.__features.delete("media-create-audio");
        host.__features.delete("media-text-to-speech");
        host.__speechToTextFiles = [];
      }

      if (hasOwn("mediaCreateImage") && !host.__enabledFunctions.mediaCreateImage) {
        host.__features.delete("media-create-image");
      }

      if (hasOwn("mediaCreateVideo") && !host.__enabledFunctions.mediaCreateVideo) {
        host.__features.delete("media-create-video");
      }

      if (hasOwn("mediaCreateAudio") && !host.__enabledFunctions.mediaCreateAudio) {
        host.__features.delete("media-create-audio");
      }

      if (hasOwn("mediaSpeechToText") && !host.__enabledFunctions.mediaSpeechToText) {
        host.__speechToTextFiles = [];
      }

      if (hasOwn("mediaTextToSpeech") && !host.__enabledFunctions.mediaTextToSpeech) {
        host.__features.delete("media-text-to-speech");
      }

      if (hasOwn("custom") && !host.__enabledFunctions.custom) {
        host.__features.delete("custom");
        host.__customItems = [];
      }

      if (hasOwn("project") && !host.__enabledFunctions.project) {
        closeProjectMenu();
      }

      closeDropdown();
      render();
    }

    host.__applyCapabilities = applyCapabilities;

    function applyInputButtonsVisibility() {
      const showFunction = host.__uiState.showFunctionButton;
      const showAudio = host.__uiState.showAudioButton;

      menuBtn.style.display = showFunction ? "" : "none";
      audioBtn.style.display = showAudio ? "" : "none";

      if (showFunction && showAudio) {
        row.style.gridTemplateColumns = "48px 1fr 18px 44px 44px";
        textarea.style.gridColumn = "2 / 3";
        menuBtn.style.gridColumn = "1";
        audioBtn.style.gridColumn = "4";
        sendBtn.style.gridColumn = "5";
        return;
      }

      if (!showFunction && showAudio) {
        row.style.gridTemplateColumns = "1fr 18px 44px 44px";
        textarea.style.gridColumn = "1 / 2";
        audioBtn.style.gridColumn = "3";
        sendBtn.style.gridColumn = "4";
        return;
      }

      if (showFunction && !showAudio) {
        row.style.gridTemplateColumns = "48px 1fr 18px 44px";
        textarea.style.gridColumn = "2 / 3";
        menuBtn.style.gridColumn = "1";
        sendBtn.style.gridColumn = "4";
        return;
      }

      row.style.gridTemplateColumns = "1fr 18px 44px";
      textarea.style.gridColumn = "1 / 2";
      sendBtn.style.gridColumn = "3";
    }

    const MEDIA_EXTENSIONS = ["png", "jpg", "jpeg", "gif", "webp"];

    function hasMediaExtension(name) {
      if (typeof name !== "string") return false;

      const lower = name.toLowerCase();
      const dot = lower.lastIndexOf(".");
      if (dot < 0) return false;

      return MEDIA_EXTENSIONS.indexOf(lower.slice(dot + 1)) !== -1;
    }

    function isMediaFile(file) {
      if (!file) return false;

      if (typeof file === "string") return hasMediaExtension(file);

      const type = (file.type || "").toLowerCase();

      if (type.startsWith("image/")) {
        const subtype = type.slice("image/".length);
        if (MEDIA_EXTENSIONS.indexOf(subtype) !== -1) return true;
      }

      return hasMediaExtension(file.name);
    }

    fileInput.addEventListener("change", function () {
      const files = Array.from(fileInput.files);

      console.log("ATTACH FILE INPUT TRIGGERED");

      const isSame = (a, b) =>
        a.name === b.name &&
        a.size === b.size &&
        a.lastModified === b.lastModified;

      files.forEach(f => {
        if (isMediaFile(f)) {
          if (!host.__images.some(existing => isSame(existing, f))) {
            host.__images.push(f);
          }
        } else {
          if (!host.__files.some(existing => isSame(existing, f))) {
            host.__files.push(f);
          }
        }
      });

      fileInput.value = "";

      render();
    });

    knowledgeInput.addEventListener("change", function () {
      const files = Array.from(knowledgeInput.files);

      const isSame = (a, b) =>
        a.name === b.name &&
        a.size === b.size &&
        a.lastModified === b.lastModified;

      files.forEach(f => {
        if (!host.__knowledgeFiles.some(existing => isSame(existing, f))) {
          host.__knowledgeFiles.push(f);
        }
      });

      knowledgeInput.value = "";

      if (host.__knowledgeFiles.length > 0)
        host.__features.add("knowledge-search");

      render();
    });

    imageInput.addEventListener("change", function () {
      const files = Array.from(imageInput.files);

      const isSame = (a, b) =>
        a.name === b.name &&
        a.size === b.size &&
        a.lastModified === b.lastModified;

      files.forEach(f => {
        if (!host.__images.some(existing => isSame(existing, f))) {
          host.__images.push(f);
        }
      });

      imageInput.value = "";
      render();
    });

    menuBtn.onclick = function (e) {
      e.stopPropagation();

      if (dropdown.hidden) {
        openDropdown();
      } else {
        closeDropdown();
      }
    };

    document.addEventListener("click", function (e) {
      if (!dropdown.contains(e.target) && e.target !== menuBtn) {
        closeDropdown();
      }
    });

    window.addEventListener("resize", function () {
      syncOpenDropdownLayout();
    });

    function buildOutgoingFeatures() {

      const features = Array.from(host.__features);

      if (host.__files.length > 0)
        features.push("attach-file");

      if (host.__images.length > 0)
        features.push("vision");

      return features;

    }

    sendBtn.onclick = function () {
      if (!window.chrome || !window.chrome.webview)
        return;

      if (host.__sendButtonState === SEND_BUTTON_STOP_MODE) {
        window.chrome.webview.postMessage({
          event: "stop-submit"
        });
        return;
      }

      // Locked while uploads are in flight; Delphi re-enables via
      // setSendButtonAvailability(true) when no transfer is pending.
      if (host.__sendButtonAvailable === false)
        return;

      const text = textarea.value.trim();
      if (!text) return;

      window.chrome.webview.postMessage({
        event: "input-submit",
        text: text,
        features: buildOutgoingFeatures(),
        files: host.__files,
        images: host.__images,
        knowledgeFiles: host.__knowledgeFiles,
        integrationFunctions: host.__integrationFunctions.map(f => ({
          id: f.id,
          name: f.name
        })),
        integrationMcps: host.__integrationMcps.map(f => ({
          id: f.id,
          name: f.name
        })),
        integrationSkills: host.__integrationSkills.map(f => ({
          id: f.id,
          name: f.name
        })),
        integrationAgents: host.__integrationAgents.map(f => ({
          id: f.id,
          name: f.name
        })),
        customItems: host.__customItems.map(f => ({
          id: f.id,
          name: f.name
        })),
        audioMode: false
      });
    };

    audioBtn.onclick = function () {
      if (window.chrome && window.chrome.webview) {
        window.chrome.webview.postMessage({ event: "audio-input" });
      }
    };

    row.appendChild(menuBtn);
    menuBtn.style.gridColumn = "1";
    menuBtn.style.gridRow = "2";

    row.appendChild(textarea);

    row.appendChild(audioBtn);
    audioBtn.style.gridColumn = "4";
    audioBtn.style.gridRow = "2";

    row.appendChild(sendBtn);
    sendBtn.style.gridColumn = "5";
    sendBtn.style.gridRow = "2";

    shell.appendChild(filesRow);
    shell.appendChild(row);
    shell.appendChild(featuresRow);
    shell.appendChild(dropdown);

    host.appendChild(welcome);
    host.appendChild(shell);

    shell.addEventListener("wheel", captureInputBubbleWheel, {
      passive: false,
      capture: true
    });

    textarea.addEventListener("wheel", handleInputTextareaWheel, {
      passive: false
    });

    const shellResizeObserver = new ResizeObserver(function () {
      syncOpenDropdownLayout();
    });

    shellResizeObserver.observe(shell);

    function hasConversation() {

      const root = document.getElementById(RESPONSE_HOST_ID);
      if (!root) return false;

      const children = Array.from(root.children)
        .filter(function (el) {
          return !(el.id === "loadingBubble" && root.children.length === 1);
        });

      return children.length > 0;

    }

    function getResponseLayoutMetrics() {
      const root = document.getElementById(RESPONSE_HOST_ID);

      if (!root) {
        return {
          centerX: Math.round(window.innerWidth / 2),
          width: Math.max(320, Math.min(760, window.innerWidth - 32))
        };
      }

      const rect = root.getBoundingClientRect();

      if (!rect || rect.width <= 0) {
        return {
          centerX: Math.round(window.innerWidth / 2),
          width: Math.max(320, Math.min(760, window.innerWidth - 32))
        };
      }

      return {
        centerX: Math.round(rect.left + (rect.width / 2)),
        width: Math.max(320, Math.min(760, Math.floor(rect.width)))
      };
    }

    function applyHorizontalLayout() {
      const metrics = getResponseLayoutMetrics();

      host.style.left = metrics.centerX + "px";
      host.style.width = metrics.width + "px";

      syncOpenDropdownLayout();
    }

    function startHorizontalSyncBurst() {
      horizontalSyncUntil = performance.now() + 260;

      if (horizontalSyncActive) {
        return;
      }

      horizontalSyncActive = true;
      host.style.transition = INPUT_HOST_SYNC_TRANSITION;

      function tick() {
        if (window.updateInputBubbleLayout) {
          window.updateInputBubbleLayout();
        }

        if (performance.now() < horizontalSyncUntil) {
          horizontalSyncFrameId = requestAnimationFrame(tick);
          return;
        }

        horizontalSyncActive = false;
        horizontalSyncFrameId = 0;
        host.style.transition = INPUT_HOST_BASE_TRANSITION;

        if (window.updateInputBubbleLayout) {
          window.updateInputBubbleLayout();
        }
      }

      horizontalSyncFrameId = requestAnimationFrame(tick);
    }

    const INPUT_BUBBLE_RESERVE_GAP = 32;

    function getInputBubbleBackdrop() {
      let backdrop = document.getElementById("InputBubbleBackdrop");

      if (!backdrop) {
        backdrop = document.createElement("div");
        backdrop.id = "InputBubbleBackdrop";
        backdrop.setAttribute("aria-hidden", "true");
        backdrop.hidden = true;
        document.body.appendChild(backdrop);
      }

      return backdrop;
    }

    function clearInputBubbleReserve() {
      document.documentElement.style.setProperty(
        "--layout-input-bubble-reserve",
        "0px"
      );

      const backdrop = getInputBubbleBackdrop();
      backdrop.hidden = true;
    }

    function applyInputBubbleReserve() {
      const measured = host.offsetHeight || 0;

      if (measured <= 0) {
        clearInputBubbleReserve();
        return;
      }

      const reserve = Math.ceil(measured + INPUT_BUBBLE_RESERVE_GAP);

      document.documentElement.style.setProperty(
        "--layout-input-bubble-reserve",
        reserve + "px"
      );

      const backdrop = getInputBubbleBackdrop();
      backdrop.hidden = false;
    }

    function setCenteredMode() {
      host.dataset.bubbleMode = "centered";
      applyHorizontalLayout();
      host.style.top = "50%";
      host.style.bottom = "auto";
      host.style.transform = "translate(-50%, -50%)";
      updateWelcomeVisibility(true);
      clearInputBubbleReserve();
    }

    function setBottomMode() {
      host.dataset.bubbleMode = "bottom";
      applyHorizontalLayout();
      host.style.top = "auto";
      host.style.bottom = "24px";
      host.style.transform = "translateX(-50%)";
      updateWelcomeVisibility(false);
      applyInputBubbleReserve();
    }

    window.updateInputBubbleLayout = function () {
      if (hasConversation())
        setBottomMode();
      else
        setCenteredMode();
    };

    const hostResizeObserver = new ResizeObserver(function () {
      if (host.dataset.bubbleMode === "bottom") {
        applyInputBubbleReserve();
      }
    });

    hostResizeObserver.observe(host);

    const observer = new MutationObserver(function () {
      window.updateInputBubbleLayout && window.updateInputBubbleLayout();
    });

    const responseRoot = document.getElementById(RESPONSE_HOST_ID);

    if (responseRoot)
      observer.observe(responseRoot, { childList: true, subtree: false });

    window.addEventListener("resize", function () {
      startHorizontalSyncBurst();
    }, { passive: true });

    window.addEventListener(INPUT_BUBBLE_I18N_EVENT, function () {
      applyInputBubbleDictionary();
      render();
    });

    applyInputBubbleDictionary();
    autoResizeTextarea();
    applySendButtonStateUI();
    clearInputHistory();
    render();
    window.updateInputBubbleLayout && window.updateInputBubbleLayout();

  }

  window.resetInputBubble = function () {

    const host = document.getElementById("InputHost");
    if (!host) return;

    const textarea = document.getElementById("InputBubbleText");

    if (textarea) {
      textarea.value = "";
      textarea.style.height = "auto";
    }

    host.__inputHistory = { undo: [], redo: [], applying: false };

    host.__features.clear();
    host.__files = [];
    host.__images = [];
    host.__knowledgeFiles = [];
    host.__speechToTextFiles = [];
    host.__promptFragments = [];
    host.__nextPasteFragmentIndex = 1;
    host.__integrationFunctions = [];
    host.__integrationMcps = [];
    host.__integrationSkills = [];
    host.__integrationAgents = [];
    host.__customItems = [];

    if (host.__refreshUI)
      host.__refreshUI();
  };

  window.chrome.webview.addEventListener("message", function (event) {

    const msg = event.data;
    if (!msg) return;

    if (msg.type === "setInputButtonsVisibility") {

      const host = document.getElementById("InputHost");
      if (!host) return;

      const state = host.__uiState;
      if (!state) return;

      if (Object.prototype.hasOwnProperty.call(msg, "function")) {
        state.showFunctionButton = !!msg.function;
      }

      if (Object.prototype.hasOwnProperty.call(msg, "audio")) {
        state.showAudioButton = !!msg.audio;
      }

      if (host.__refreshUI)
        host.__refreshUI();

      return;
    }

    if (msg.type === "sendbtn-state") {
      let nextState = null;

      if (msg.state === "input" || msg.state === "input-mode")
        nextState = "input-mode";
      else if (msg.state === "stop" || msg.state === "stop-mode")
        nextState = "stop-mode";

      if (nextState && window.setSendButtonState)
        window.setSendButtonState(nextState);

      return;
    }

    if (msg.type === "resetInput")
      window.resetInputBubble();

    if (msg.type === "setInputText") {
      window.setInputBubbleText(msg.text);
      return;
    }

    if (msg.type === "input-bubble-setfocus") {
      if (window.setInputBubbleFocus)
        window.setInputBubbleFocus();

      return;
    }

    if (msg.type === "setInputWelcome") {
      window.setInputBubbleWelcome(msg.text);
      return;
    }

    if (msg.type === "setCapabilities") {
      const host = document.getElementById("InputHost");
      if (!host || typeof host.__applyCapabilities !== "function")
        return;

      host.__applyCapabilities(msg);
      return;
    }

    if (msg.type === "folder-state") {
      const host = document.getElementById("InputHost");
      if (!host || typeof host.__applyProjectState !== "function")
        return;

      host.__applyProjectState(msg.state);
      return;
    }

    if (msg.type === "folder-selected") {
      const host = document.getElementById("InputHost");
      if (!host || !Array.isArray(host.__projects)) return;

      const rawPath = typeof msg.folder_path === "string" ? msg.folder_path : "";
      const fullPath = rawPath.trim();
      if (!fullPath) return;

      const segments = fullPath.split(/[\\/]+/).filter(Boolean);
      const displayName = segments.length
        ? segments[segments.length - 1]
        : fullPath;

      let target = null;
      for (let i = 0; i < host.__projects.length; i += 1) {
        if (host.__projects[i] && host.__projects[i].fullPath === fullPath) {
          target = host.__projects[i];
          break;
        }
      }

      if (!target) {
        target = { displayName: displayName, fullPath: fullPath, selected: false };
        host.__projects.push(target);
      } else if (!target.displayName) {
        target.displayName = displayName;
      }

      for (let i = 0; i < host.__projects.length; i += 1) {
        if (host.__projects[i])
          host.__projects[i].selected = (host.__projects[i] === target);
      }

      if (host.__updateProjectButtonLabel)
        host.__updateProjectButtonLabel();

      if (host.__renderProjectMenu)
        host.__renderProjectMenu();

      if (host.__notifyProjectStateChanged)
        host.__notifyProjectStateChanged();

      return;
    }

  });

  ensureInputBubble();

  window.chrome.webview.postMessage("input-ready");

})();
