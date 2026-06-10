(() => {

  const DEFAULT_TEMPERATURE = 0.8;
  const DEFAULT_MAX_TOKEN = 2048;
  const DEFAULT_TOP_K = 20;
  const DEFAULT_PRESENCE_PENALTY = 0;
  const DEFAULT_TOP_P = 0;
  const DEFAULT_SEED = 0;
  const DEFAULT_LOOK_AND_FEEL_DARK = false;
  const DEFAULT_APP_LANGUAGE = "";
  const DEFAULT_APP_LANGUAGE_NAME = "";
  const DEFAULT_SCROLL_BUTTONS = false;

  const REQUEST_PARAMS_STYLE_ID = "request-params-style";
  const REQUEST_PARAMS_OVERLAY_ID = "request-params-overlay";
  const REQUEST_PARAMS_DIALOG_ID = "request-params-dialog";
  const REQUEST_PARAMS_BADGE_ICON_FONT_FAMILY = '"Segoe Fluent Icons", "Segoe UI Symbol", sans-serif';
  const REQUEST_PARAMS_BADGE_ICON_BY_CODE = {
    RP: "\uE154",
    AS: "\uE115",
    SP: "\uE8AC",
    GS: "\uE15E",
    SA: "\uE835",
    SO: "\uE9A3",
    VO: "\uEB95"
  };

  const REQUEST_PARAMS_NAV_MIN_WIDTH = 350;
  const REQUEST_PARAMS_NAV_MAX_WIDTH = 350;
  const REQUEST_PARAMS_NAV_HORIZONTAL_PADDING = 18;
  const REQUEST_PARAMS_NAV_BADGE_WIDTH = 32;
  const REQUEST_PARAMS_NAV_LINE_GAP = 12;
  const REQUEST_PARAMS_NAV_SAFE_EXTRA = 12;
  const REQUEST_PARAMS_NAV_TITLE_FONT = "600 15px Segoe UI, sans-serif";
  const REQUEST_PARAMS_NAV_SUMMARY_FONT = "400 13px Segoe UI, sans-serif";
  const REQUEST_PARAMS_SELECT_MAX_VISIBLE_ITEMS = 5;
  const REQUEST_PARAMS_SELECT_OPTION_HEIGHT = 40;

  const categoryDefinitions = {
    appSettings: {
      id: "appSettings",
      title: "App Settings",
      subtitle: "General",
      panelSubtitle: "",
      badge: "AS",
      items: [
        {
          type: "theme-toggle",
          label: "Look&feel",
          valuePath: "appSettings.lookAndFeelDark"
        },
        {
          type: "select",
          label: "Language",
          valuePath: "appSettings.language",
          optionsPath: "appSettings.availableLanguages",
          placeholder: "Select a language",
          alwaysEnabled: true
        },
        {
          type: "boolean-right",
          label: "Scroll buttons",
          valuePath: "appSettings.scrollButtons"
        }
      ]
    },
    systemPrompt: {
      id: "systemPrompt",
      title: "System Prompt",
      badge: "SP",
      items: [
        {
          type: "textarea",
          label: "System Prompt",
          labelWhenDisabled: "Disabled",
          labelWhenEnabled: "Enabled",
          enabledPath: "systemPrompt.enabled",
          valuePath: "systemPrompt.systemPrompt",
          placeholder: "Enter the system prompt"
        }
      ]
    },
    settings: {
      id: "settings",
      title: "General Settings",
      badge: "GS",
      items: [
        {
          type: "number",
          label: "Temperature",
          valuePath: "settings.temperature",
          min: 0,
          max: 1,
          step: 0.01,
          alwaysEnabled: true
        },
        {
          type: "number",
          label: "Max Tokens",
          enabledPath: "settings.maxToken.enabled",
          valuePath: "settings.maxToken.maxToken",
          min: 0,
          step: 1
        },
        {
          type: "textarea-list",
          label: "Stop Strings",
          enabledPath: "settings.stopString.enabled",
          valuePath: "settings.stopString.stopString",
          placeholder: "One stop string per line"
        }
      ]
    },
    sampling: {
      id: "sampling",
      title: "Sampling",
      badge: "SA",
      items: [
        {
          type: "number",
          label: "Top-k",
          enabledPath: "sampling.topK.enabled",
          valuePath: "sampling.topK.topK",
          min: 0,
          step: 1
        },
        {
          type: "number",
          label: "Top-p",
          enabledPath: "sampling.topP.enabled",
          valuePath: "sampling.topP.topP",
          min: 0,
          max: 1,
          step: 0.01
        },
        {
          type: "number",
          label: "Presence Penalty",
          enabledPath: "sampling.presencePenalty.enabled",
          valuePath: "sampling.presencePenalty.presencePenalty",
          step: 0.01
        },
        {
          type: "number",
          label: "Random Seed",
          enabledPath: "sampling.seed.enabled",
          valuePath: "sampling.seed.seed",
          step: 1
        }
      ]
    },
    structuredOutput: {
      id: "structuredOutput",
      title: "Structured Output",
      badge: "SO",
      items: [
        {
          type: "textarea",
          label: "JSON Schema",
          labelWhenDisabled: "Disabled",
          labelWhenEnabled: "Enabled",
          invalidJsonMessage: "Invalid JSON",
          enabledPath: "structuredOutput.enabled",
          valuePath: "structuredOutput.jsonSchema",
          placeholder: "Enter the JSON schema"
        }
      ]
    },
    vendorSettings: {
      id: "vendorSettings",
      title: "Vendor Options",
      badge: "VO",
      items: [
        {
          type: "boolean",
          label: "Parallel Tool Calls",
          valuePath: "vendorSettings.parallelToolCalls"
        },
        {
          type: "boolean",
          label: "Background Response",
          valuePath: "vendorSettings.backgroundResponse"
        },
        {
          type: "boolean",
          label: "Using Previous Id",
          valuePath: "vendorSettings.usingPreviousId"
        },
        {
          type: "boolean",
          label: "Store",
          valuePath: "vendorSettings.store"
        }
      ]
    }
  };

  const categoryOrder = [
    "appSettings",
    "systemPrompt",
    "settings",
    "sampling",
    "structuredOutput",
    "vendorSettings"
  ];

    const REQUEST_PARAMS_I18N_EVENT =
    window.AppI18n && window.AppI18n.eventName
      ? window.AppI18n.eventName
      : "app:i18n:changed";

  const BASE_CATEGORY_DEFINITIONS = clone(categoryDefinitions);

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

  function applyCategoryTranslation(categoryId) {
    const targetCategory = categoryDefinitions[categoryId];
    const baseCategory = BASE_CATEGORY_DEFINITIONS[categoryId];

    if (!targetCategory || !baseCategory) return;

    targetCategory.title = t(
      "requestParams.categories." + categoryId + ".title",
      baseCategory.title
    );

    if (Object.prototype.hasOwnProperty.call(baseCategory, "subtitle")) {
      targetCategory.subtitle = t(
        "requestParams.categories." + categoryId + ".subtitle",
        baseCategory.subtitle
      );
    }

    if (Object.prototype.hasOwnProperty.call(baseCategory, "panelSubtitle")) {
      targetCategory.panelSubtitle = t(
        "requestParams.categories." + categoryId + ".panelSubtitle",
        baseCategory.panelSubtitle
      );
    }
  }

  function applyItemTranslation(targetItem, baseItem, keyPrefix) {
    if (!targetItem || !baseItem) return;

    if (Object.prototype.hasOwnProperty.call(baseItem, "label")) {
      targetItem.label = t(keyPrefix + ".label", baseItem.label);
    }

    if (Object.prototype.hasOwnProperty.call(baseItem, "labelWhenDisabled")) {
      targetItem.labelWhenDisabled = t(
        keyPrefix + ".labelWhenDisabled",
        baseItem.labelWhenDisabled
      );
    }

    if (Object.prototype.hasOwnProperty.call(baseItem, "labelWhenEnabled")) {
      targetItem.labelWhenEnabled = t(
        keyPrefix + ".labelWhenEnabled",
        baseItem.labelWhenEnabled
      );
    }

    if (Object.prototype.hasOwnProperty.call(baseItem, "invalidJsonMessage")) {
      targetItem.invalidJsonMessage = t(
        keyPrefix + ".invalidJsonMessage",
        baseItem.invalidJsonMessage
      );
    }

    if (Object.prototype.hasOwnProperty.call(baseItem, "placeholder")) {
      targetItem.placeholder = t(
        keyPrefix + ".placeholder",
        baseItem.placeholder
      );
    }
  }

  function applyRequestParamsDictionary() {
    applyCategoryTranslation("appSettings");
    applyCategoryTranslation("systemPrompt");
    applyCategoryTranslation("settings");
    applyCategoryTranslation("sampling");
    applyCategoryTranslation("structuredOutput");
    applyCategoryTranslation("vendorSettings");

    applyItemTranslation(
      categoryDefinitions.appSettings.items[0],
      BASE_CATEGORY_DEFINITIONS.appSettings.items[0],
      "requestParams.items.appSettings.lookAndFeel"
    );

    applyItemTranslation(
      categoryDefinitions.appSettings.items[1],
      BASE_CATEGORY_DEFINITIONS.appSettings.items[1],
      "requestParams.items.appSettings.language"
    );

    applyItemTranslation(
      categoryDefinitions.appSettings.items[2],
      BASE_CATEGORY_DEFINITIONS.appSettings.items[2],
      "requestParams.items.appSettings.scrollButtons"
    );

    applyItemTranslation(
      categoryDefinitions.systemPrompt.items[0],
      BASE_CATEGORY_DEFINITIONS.systemPrompt.items[0],
      "requestParams.items.systemPrompt.systemPrompt"
    );

    applyItemTranslation(
      categoryDefinitions.settings.items[0],
      BASE_CATEGORY_DEFINITIONS.settings.items[0],
      "requestParams.items.settings.temperature"
    );

    applyItemTranslation(
      categoryDefinitions.settings.items[1],
      BASE_CATEGORY_DEFINITIONS.settings.items[1],
      "requestParams.items.settings.maxTokens"
    );

    applyItemTranslation(
      categoryDefinitions.settings.items[2],
      BASE_CATEGORY_DEFINITIONS.settings.items[2],
      "requestParams.items.settings.stopStrings"
    );

    applyItemTranslation(
      categoryDefinitions.sampling.items[0],
      BASE_CATEGORY_DEFINITIONS.sampling.items[0],
      "requestParams.items.sampling.topK"
    );

    applyItemTranslation(
      categoryDefinitions.sampling.items[1],
      BASE_CATEGORY_DEFINITIONS.sampling.items[1],
      "requestParams.items.sampling.topP"
    );

    applyItemTranslation(
      categoryDefinitions.sampling.items[2],
      BASE_CATEGORY_DEFINITIONS.sampling.items[2],
      "requestParams.items.sampling.presencePenalty"
    );

    applyItemTranslation(
      categoryDefinitions.sampling.items[3],
      BASE_CATEGORY_DEFINITIONS.sampling.items[3],
      "requestParams.items.sampling.randomSeed"
    );

    applyItemTranslation(
      categoryDefinitions.structuredOutput.items[0],
      BASE_CATEGORY_DEFINITIONS.structuredOutput.items[0],
      "requestParams.items.structuredOutput.jsonSchema"
    );

    applyItemTranslation(
      categoryDefinitions.vendorSettings.items[0],
      BASE_CATEGORY_DEFINITIONS.vendorSettings.items[0],
      "requestParams.items.vendorSettings.parallelToolCalls"
    );

    applyItemTranslation(
      categoryDefinitions.vendorSettings.items[1],
      BASE_CATEGORY_DEFINITIONS.vendorSettings.items[1],
      "requestParams.items.vendorSettings.backgroundResponse"
    );

    applyItemTranslation(
      categoryDefinitions.vendorSettings.items[2],
      BASE_CATEGORY_DEFINITIONS.vendorSettings.items[2],
      "requestParams.items.vendorSettings.usingPreviousId"
    );

    applyItemTranslation(
      categoryDefinitions.vendorSettings.items[3],
      BASE_CATEGORY_DEFINITIONS.vendorSettings.items[3],
      "requestParams.items.vendorSettings.store"
    );
  }

  function getRequestParamsCategoryIdByPage(page) {
    if (page == null || page === "") return null;

    const index = Number(page);

    if (!Number.isInteger(index)) return null;
    if (index < 0 || index >= categoryOrder.length) return null;

    return categoryOrder[index] || null;
  }

  const state = {
    appSettings: {
      lookAndFeelDark: DEFAULT_LOOK_AND_FEEL_DARK,
      language: DEFAULT_APP_LANGUAGE,
      languageName: DEFAULT_APP_LANGUAGE_NAME,
      availableLanguages: [],
      scrollButtons: DEFAULT_SCROLL_BUTTONS
    },

    systemPrompt: {
      systemPrompt: "",
      enabled: false
    },

    settings: {
      temperature: DEFAULT_TEMPERATURE,
      maxToken: {
        maxToken: DEFAULT_MAX_TOKEN,
        enabled: false
      },
      stopString: {
        stopString: [],
        enabled: false
      }
    },

    sampling: {
      topK: {
        topK: DEFAULT_TOP_K,
        enabled: false
      },
      presencePenalty: {
        presencePenalty: DEFAULT_PRESENCE_PENALTY,
        enabled: false
      },
      topP: {
        topP: DEFAULT_TOP_P,
        enabled: false
      },
      seed: {
        seed: DEFAULT_SEED,
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

  const overlayState = {
    activeCategoryId: "sampling",
    mounted: false,
    isVisible: false,
    sendTimer: 0,
    navMeasureFrame: 0,
    navTooltipFrame: 0,
    openSelectPath: "",
    elements: {
      root: null,
      dialog: null,
      nav: null,
      panelBadge: null,
      panelTitle: null,
      panelBody: null,
      closeButton: null
    }
  };

  let isInternalLanguageSelection = false;

  function clone(value) {
    if (typeof structuredClone === "function") {
      return structuredClone(value);
    }

    return JSON.parse(JSON.stringify(value));
  }

  function toStringValue(value) {
    return value == null ? "" : String(value);
  }

  function toBooleanValue(value) {
    return !!value;
  }

  function toIntegerValue(value) {
    if (value == null || value === "") return 0;

    const n = Number(value);

    if (!Number.isFinite(n)) return 0;

    return Math.trunc(n);
  }

  function toDoubleValue(value) {
    if (value == null || value === "") return 0;

    const n = Number(value);

    if (!Number.isFinite(n)) return 0;

    return n;
  }

  function toStringArray(value) {
    if (Array.isArray(value)) {
      return value.map(v => String(v));
    }

    if (value == null || value === "") {
      return [];
    }

    return [String(value)];
  }

  function getRequestParamsLanguageTranslationKey(value) {
    return "requestParams.languages." + toStringValue(value).trim().toLowerCase();
  }

  function getRequestParamsLanguageLabel(value, fallbackLabel) {
    const optionValue = toStringValue(value).trim();

    if (!optionValue) {
      return "";
    }

    const fallback = toStringValue(
      fallbackLabel != null ? fallbackLabel : optionValue
    );

    return t(
      getRequestParamsLanguageTranslationKey(optionValue),
      fallback || optionValue
    );
  }

  function refreshAppSettingsAvailableLanguagesLabels() {
    state.appSettings.availableLanguages = normalizeLanguageOptions(
      state.appSettings.availableLanguages
    );
  }

  function normalizeLanguageOptions(value) {
    if (!Array.isArray(value)) {
      return [];
    }

    return value
      .map(function (entry) {
        if (entry && typeof entry === "object") {
          const optionValue = toStringValue(entry.value).trim();
          const optionLabel = getRequestParamsLanguageLabel(
            optionValue,
            entry.label != null ? entry.label : optionValue
          );

          if (!optionValue) return null;

          return {
            value: optionValue,
            label: optionLabel || optionValue
          };
        }

        const optionValue = toStringValue(entry).trim();

        if (!optionValue) return null;

        return {
          value: optionValue,
          label: getRequestParamsLanguageLabel(optionValue, optionValue) || optionValue
        };
      })
      .filter(Boolean);
  }

  function getValueByPath(path) {
    const parts = String(path).split(".");
    let current = state;

    for (let i = 0; i < parts.length; i += 1) {
      if (current == null) return undefined;
      current = current[parts[i]];
    }

    return current;
  }

  function encodeAttribute(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/"/g, "&quot;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function formatInputValue(item, value) {
    if (item.type === "textarea-list") {
      return Array.isArray(value) ? value.join("\n") : "";
    }

    if (value == null) return "";

    return String(value);
  }

  let structuredOutputValidationTimer = 0;

  function isStructuredOutputItem(item) {
    return !!(
      item &&
      item.valuePath === "structuredOutput.jsonSchema"
    );
  }

  function isStructuredOutputJsonValid() {
    if (!toBooleanValue(state.structuredOutput.enabled)) {
      return true;
    }

    try {
      JSON.parse(toStringValue(state.structuredOutput.jsonSchema));
      return true;
    } catch (_) {
      return false;
    }
  }

  function shouldShowStructuredOutputInvalidJson() {
    return (
      toBooleanValue(state.structuredOutput.enabled) &&
      !isStructuredOutputJsonValid()
    );
  }

  function getStructuredOutputInvalidJsonLabel() {
    const item =
      categoryDefinitions.structuredOutput &&
      categoryDefinitions.structuredOutput.items &&
      categoryDefinitions.structuredOutput.items[0];

    return toStringValue(
      item && item.invalidJsonMessage != null
        ? item.invalidJsonMessage
        : "Invalid JSON"
    );
  }

  function syncStructuredOutputValidationUi() {
    const root = overlayState.elements.root;
    if (!root) return;

    const invalidNode = root.querySelector(
      '[data-role="structured-output-invalid-json"]'
    );

    if (!invalidNode) return;

    const showInvalidJson = shouldShowStructuredOutputInvalidJson();

    invalidNode.textContent = showInvalidJson
      ? getStructuredOutputInvalidJsonLabel()
      : "";

    invalidNode.classList.toggle(
      "is-visible",
      showInvalidJson
    );
  }

  function scheduleStructuredOutputValidationUiSync() {
    clearTimeout(structuredOutputValidationTimer);

    structuredOutputValidationTimer = window.setTimeout(function () {
      syncStructuredOutputValidationUi();
    }, 120);
  }

  function setSystemPromptSystemPrompt(value) {
    state.systemPrompt.systemPrompt = toStringValue(value);
  }

  function setSystemPromptEnabled(value) {
    state.systemPrompt.enabled = toBooleanValue(value);
  }

  function setSettingsTemperature(value) {
    let n = toDoubleValue(value);

    if (n < 0) n = 0;
    if (n > 1) n = 1;

    state.settings.temperature = n;
  }

  function setSettingsMaxTokenValue(value) {
    state.settings.maxToken.maxToken = toIntegerValue(value);
  }

  function setSettingsMaxTokenEnabled(value) {
    state.settings.maxToken.enabled = toBooleanValue(value);
  }

  function setSettingsStopStringValue(value) {
    state.settings.stopString.stopString = toStringArray(value);
  }

  function setSettingsStopStringEnabled(value) {
    state.settings.stopString.enabled = toBooleanValue(value);
  }

  function setSamplingTopKValue(value) {
    state.sampling.topK.topK = toIntegerValue(value);
  }

  function setSamplingTopKEnabled(value) {
    state.sampling.topK.enabled = toBooleanValue(value);
  }

  function setSamplingPresencePenaltyValue(value) {
    state.sampling.presencePenalty.presencePenalty = toDoubleValue(value);
  }

  function setSamplingPresencePenaltyEnabled(value) {
    state.sampling.presencePenalty.enabled = toBooleanValue(value);
  }

  function setSamplingTopPValue(value) {
    state.sampling.topP.topP = toDoubleValue(value);
  }

  function setSamplingTopPEnabled(value) {
    state.sampling.topP.enabled = toBooleanValue(value);
  }

  function setSamplingSeedValue(value) {
    state.sampling.seed.seed = toIntegerValue(value);
  }
  function setSamplingSeedEnabled(value) {
    state.sampling.seed.enabled = toBooleanValue(value);
  }

  function setStructuredOutputJsonschema(value) {
    state.structuredOutput.jsonSchema = toStringValue(value);
  }

  function setStructuredOutputEnabled(value) {
    state.structuredOutput.enabled = toBooleanValue(value);
  }

  function setVendorSettingsParallelToolCalls(value) {
    state.vendorSettings.parallelToolCalls = toBooleanValue(value);
  }

  function setVendorSettingsBackgroundResponse(value) {
    state.vendorSettings.backgroundResponse = toBooleanValue(value);
  }

  function setVendorSettingsUsingPreviousId(value) {
    state.vendorSettings.usingPreviousId = toBooleanValue(value);
  }

  function setVendorSettingsStore(value) {
    state.vendorSettings.store = toBooleanValue(value);
  }

  function setAppSettingsLookAndFeelDark(value) {
    state.appSettings.lookAndFeelDark = toBooleanValue(value);
  }

  function setAppSettingsLanguageName(value) {
    state.appSettings.languageName = toStringValue(value).trim();
  }

  function getAppSettingsDisplayedLanguageLabel(option) {
    const optionValue = toStringValue(option && option.value).trim();
    const currentLanguageValue = toStringValue(state.appSettings.language).trim();

    if (
      optionValue &&
      optionValue === currentLanguageValue &&
      state.appSettings.languageName
    ) {
      return state.appSettings.languageName;
    }

    return toStringValue(option && option.label != null ? option.label : optionValue);
  }

  function setAppSettingsLanguage(value) {
    const nextValue = toStringValue(value);

    if (nextValue !== state.appSettings.language) {
      state.appSettings.languageName = DEFAULT_APP_LANGUAGE_NAME;
    }

    state.appSettings.language = nextValue;
  }

  function setAppSettingsAvailableLanguages(value) {
    const normalizedOptions = normalizeLanguageOptions(value);

    state.appSettings.availableLanguages = normalizedOptions;

    if (!normalizedOptions.length) {
      state.appSettings.language = DEFAULT_APP_LANGUAGE;
      state.appSettings.languageName = DEFAULT_APP_LANGUAGE_NAME;
      return;
    }

    const hasCurrentValue = normalizedOptions.some(function (option) {
      return option.value === state.appSettings.language;
    });

    if (!hasCurrentValue) {
      state.appSettings.language = normalizedOptions[0].value;
      state.appSettings.languageName = DEFAULT_APP_LANGUAGE_NAME;
    }
  }

  function findAppSettingsLanguageOptionByName(name) {
    const searchedName = toStringValue(name).trim().toLowerCase();

    if (!searchedName) {
      return null;
    }

    for (let i = 0; i < state.appSettings.availableLanguages.length; i += 1) {
      const option = state.appSettings.availableLanguages[i];
      if (!option) continue;

      const optionValue = toStringValue(option.value).trim().toLowerCase();
      const optionLabel = toStringValue(option.label).trim().toLowerCase();

      if (optionLabel === searchedName || optionValue === searchedName) {
        return option;
      }
    }

    return null;
  }

  function setAppSettingsScrollButtons(value) {
    state.appSettings.scrollButtons = toBooleanValue(value);
  }

  function getRequestParamsBadgeIcon(badge) {
    const normalizedBadge = String(badge == null ? "" : badge).trim();

    return REQUEST_PARAMS_BADGE_ICON_BY_CODE[normalizedBadge] || "";
  }

  function getRequestParamsBadgeDisplayValue(badge) {
    return getRequestParamsBadgeIcon(badge) || badge;
  }

  function getRequestParamsBadgeClassName(baseClassName, badge) {
    return getRequestParamsBadgeIcon(badge)
      ? baseClassName + " request-params-badge-icon"
      : baseClassName;
  }

  function measureRequestParamsTextWidth(text, font) {
    const canvas =
      measureRequestParamsTextWidth.canvas ||
      (measureRequestParamsTextWidth.canvas = document.createElement("canvas"));

    const context = canvas.getContext("2d");
    if (!context) return 0;

    context.font = font;
    return Math.ceil(context.measureText(toStringValue(text)).width);
  }

  function getRequestParamsNavLongestLabelWidth() {
    return categoryOrder.reduce(function (maxWidth, categoryId) {
      const category = categoryDefinitions[categoryId];
      if (!category) return maxWidth;

      const summary = category.subtitle || buildCategorySummary(categoryId);
      const titleWidth = measureRequestParamsTextWidth(
        category.title,
        REQUEST_PARAMS_NAV_TITLE_FONT
      );
      const summaryWidth = measureRequestParamsTextWidth(
        summary,
        REQUEST_PARAMS_NAV_SUMMARY_FONT
      );

      return Math.max(maxWidth, titleWidth, summaryWidth);
    }, 0);
  }

  function getRequestParamsNavWidth() {
    const contentWidth = getRequestParamsNavLongestLabelWidth();
    const desiredWidth =
      (REQUEST_PARAMS_NAV_HORIZONTAL_PADDING * 2) +
      REQUEST_PARAMS_NAV_BADGE_WIDTH +
      REQUEST_PARAMS_NAV_LINE_GAP +
      contentWidth +
      REQUEST_PARAMS_NAV_SAFE_EXTRA;

    return Math.max(
      REQUEST_PARAMS_NAV_MIN_WIDTH,
      Math.min(REQUEST_PARAMS_NAV_MAX_WIDTH, desiredWidth)
    );
  }

  function getRequestParamsNavTextNodes() {
    const nav = overlayState.elements.nav;
    if (!nav) return [];

    return Array.prototype.slice.call(
      nav.querySelectorAll(".request-params-nav-title, .request-params-nav-summary")
    );
  }

  function getRequestParamsStylePixelValue(style, propertyName) {
    const value = parseFloat(style.getPropertyValue(propertyName));
    return Number.isFinite(value) ? value : 0;
  }

  function applyRequestParamsNavTooltips() {
    const nodes = getRequestParamsNavTextNodes();

    nodes.forEach(function (node) {
      const text = toStringValue(node.textContent).trim();

      if (!text) {
        node.removeAttribute("title");
        return;
      }

      if (node.scrollWidth > node.clientWidth + 1) {
        node.setAttribute("title", text);
      } else {
        node.removeAttribute("title");
      }
    });
  }

  function measureRequestParamsNavWidthFromDom() {
    const dialog = overlayState.elements.dialog;
    const nav = overlayState.elements.nav;

    if (!dialog || !nav) return;

    const navStyle = window.getComputedStyle(nav);
    const navHorizontalSpace =
      getRequestParamsStylePixelValue(navStyle, "padding-left") +
      getRequestParamsStylePixelValue(navStyle, "padding-right") +
      getRequestParamsStylePixelValue(navStyle, "border-left-width") +
      getRequestParamsStylePixelValue(navStyle, "border-right-width");

    let widestItemWidth = 0;

    Array.prototype.forEach.call(
      nav.querySelectorAll(".request-params-nav-item"),
      function (item) {
        const line = item.querySelector(".request-params-nav-line");
        if (!line) return;

        const itemStyle = window.getComputedStyle(item);
        const itemHorizontalSpace =
          getRequestParamsStylePixelValue(itemStyle, "padding-left") +
          getRequestParamsStylePixelValue(itemStyle, "padding-right") +
          getRequestParamsStylePixelValue(itemStyle, "border-left-width") +
          getRequestParamsStylePixelValue(itemStyle, "border-right-width");

        const fullItemWidth =
          Math.ceil(line.scrollWidth || 0) + itemHorizontalSpace;

        if (fullItemWidth > widestItemWidth) {
          widestItemWidth = fullItemWidth;
        }
      }
    );

    const desiredWidth =
      navHorizontalSpace +
      widestItemWidth +
      REQUEST_PARAMS_NAV_SAFE_EXTRA;

    const navWidth = Math.max(
      REQUEST_PARAMS_NAV_MIN_WIDTH,
      Math.min(REQUEST_PARAMS_NAV_MAX_WIDTH, Math.ceil(desiredWidth))
    );

    dialog.style.setProperty("--request-params-nav-width", navWidth + "px");
  }

  function scheduleRequestParamsNavTooltipSync() {
    if (!overlayState.isVisible) return;

    if (overlayState.navTooltipFrame) {
      window.cancelAnimationFrame(overlayState.navTooltipFrame);
      overlayState.navTooltipFrame = 0;
    }

    overlayState.navTooltipFrame = window.requestAnimationFrame(function () {
      overlayState.navTooltipFrame = 0;
      applyRequestParamsNavTooltips();
    });
  }

  function scheduleRequestParamsNavLayoutSync() {
    if (!overlayState.isVisible) return;

    if (overlayState.navMeasureFrame) {
      window.cancelAnimationFrame(overlayState.navMeasureFrame);
      overlayState.navMeasureFrame = 0;
    }

    if (overlayState.navTooltipFrame) {
      window.cancelAnimationFrame(overlayState.navTooltipFrame);
      overlayState.navTooltipFrame = 0;
    }

    overlayState.navMeasureFrame = window.requestAnimationFrame(function () {
      overlayState.navMeasureFrame = 0;
      measureRequestParamsNavWidthFromDom();

      overlayState.navTooltipFrame = window.requestAnimationFrame(function () {
        overlayState.navTooltipFrame = 0;
        applyRequestParamsNavTooltips();
      });
    });
  }

  const requestParamsUpdateHandlers = {
    "appSettings.availableLanguages": setAppSettingsAvailableLanguages,
    "appSettings.language": setAppSettingsLanguage,
    "appSettings.languageName": setAppSettingsLanguageName,
    "appSettings.lookAndFeelDark": setAppSettingsLookAndFeelDark,
    "appSettings.scrollButtons": setAppSettingsScrollButtons,

    "systemPrompt.systemPrompt": setSystemPromptSystemPrompt,
    "systemPrompt.enabled": setSystemPromptEnabled,

    "settings.temperature": setSettingsTemperature,
    "settings.maxToken.maxToken": setSettingsMaxTokenValue,
    "settings.maxToken.enabled": setSettingsMaxTokenEnabled,
    "settings.stopString.stopString": setSettingsStopStringValue,
    "settings.stopString.enabled": setSettingsStopStringEnabled,

    "sampling.topK.topK": setSamplingTopKValue,
    "sampling.topK.enabled": setSamplingTopKEnabled,
    "sampling.presencePenalty.presencePenalty": setSamplingPresencePenaltyValue,
    "sampling.presencePenalty.enabled": setSamplingPresencePenaltyEnabled,
    "sampling.topP.topP": setSamplingTopPValue,
    "sampling.topP.enabled": setSamplingTopPEnabled,
    "sampling.seed.seed": setSamplingSeedValue,
    "sampling.seed.enabled": setSamplingSeedEnabled,

    "structuredOutput.jsonSchema": setStructuredOutputJsonschema,
    "structuredOutput.enabled": setStructuredOutputEnabled,

    "vendorSettings.parallelToolCalls": setVendorSettingsParallelToolCalls,
    "vendorSettings.backgroundResponse": setVendorSettingsBackgroundResponse,
    "vendorSettings.usingPreviousId": setVendorSettingsUsingPreviousId,
    "vendorSettings.store": setVendorSettingsStore
  };

  function countEnabledInCategory(categoryId) {
    const category = categoryDefinitions[categoryId];
    if (!category) return { enabled: 0, disabled: 0, total: 0 };

    let enabled = 0;
    let disabled = 0;

    category.items.forEach(function (item) {
      if (item.enabledPath) {
        if (toBooleanValue(getValueByPath(item.enabledPath))) {
          enabled += 1;
        } else {
          disabled += 1;
        }
        return;
      }

      if (item.type === "boolean" || item.type === "boolean-right") {
        if (toBooleanValue(getValueByPath(item.valuePath))) {
          enabled += 1;
        } else {
          disabled += 1;
        }
      }
    });

    return {
      enabled: enabled,
      disabled: disabled,
      total: enabled + disabled
    };
  }

  function buildCategorySummary(categoryId) {
    const counts = countEnabledInCategory(categoryId);

    if (counts.total === 0) {
      return t(
        "requestParams.summary.alwaysAvailable",
        "Always available"
      );
    }

    if (counts.total === 1) {
      return counts.enabled === 1
        ? t("requestParams.summary.enabled", "Enabled")
        : t("requestParams.summary.disabled", "Disabled");
    }

    return t(
      "requestParams.summary.enabledDisabled",
      "{enabled} enabled / {disabled} disabled",
      {
        enabled: counts.enabled,
        disabled: counts.disabled
      }
    );
  }

  function injectOverlayStyles() {
    let style = document.getElementById(REQUEST_PARAMS_STYLE_ID);

    if (!style) {
      style = document.createElement("style");
      style.id = REQUEST_PARAMS_STYLE_ID;
      document.head.appendChild(style);
    }

    style.textContent = `
      body.request-params-overlay-open {
        overflow: hidden;
      }

      .request-params-overlay {
        position: fixed;
        inset: 0;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 16px;
        box-sizing: border-box;
        z-index: 5000;
      }
      .request-params-overlay.is-visible {
        display: flex;
      }

      .request-params-overlay-backdrop {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.48);
        backdrop-filter: blur(6px);
      }

      .request-params-dialog {
        position: relative;
        width: min(980px, calc(100vw - 32px));
        max-height: calc(100vh - 32px);
        display: grid;
        grid-template-rows: auto minmax(0, 1fr);
        border: 1px solid var(--input-shell-border);
        border-radius: 20px;
        box-sizing: border-box;
        overflow: hidden;
        background: color-mix(in srgb, var(--bg-main) 82%, transparent);
        box-shadow: 0 28px 90px rgba(0,0,0,0.42);
        backdrop-filter: blur(18px);
        color-scheme: dark;
      }

      .request-params-dialog--compact {
        width: min(980px, calc(100vw - 48px));
      }

      .request-params-dialog--stacked {
        width: min(980px, calc(100vw - 48px));
        min-height: 0;
      }

      [data-theme="light"] .request-params-dialog {
        color-scheme: light;
      }

      .request-params-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        padding: 20px 24px;
        border-bottom: 1px solid var(--input-shell-border);
      }

      .request-params-header-title {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 18px;
        font-weight: 700;
        color: var(--text-main);
      }

      .request-params-header-badge {
        width: 34px;
        height: 34px;
        border-radius: 10px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: var(--input-button-bg);
        color: var(--text-main);
        border: 1px solid var(--input-shell-border);
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.04em;
      }

      .request-params-badge-icon {
        font-family: ${REQUEST_PARAMS_BADGE_ICON_FONT_FAMILY};
        font-size:26px;
        font-weight: 400;
        letter-spacing: 0;
        line-height: 1;
      }

      .request-params-close {
        appearance: none;
        -webkit-appearance: none;
        width: 38px;
        height: 38px;
        padding: 0;
        margin: 0;
        border: 1px solid var(--input-shell-border);
        border-radius: 12px;
        background: var(--input-button-bg);
        color: var(--text-main);
        font-size: 20px;
        line-height: 20px;
        cursor: pointer;
      }

      .request-params-close:hover {
        background: var(--input-button-hover-bg);
        color: var(--input-button-hover-text);
      }

      .request-params-layout {
        min-height: 0;
        display: grid;
        grid-template-columns: var(--request-params-nav-width, 280px) minmax(0, 1fr);
      }

      .request-params-dialog--stacked .request-params-layout {
        grid-template-columns: var(--request-params-nav-width, 280px) minmax(0, 1fr);
      }

      .request-params-nav {
        min-height: 0;
        padding: 20px;
        border-right: 1px solid var(--input-shell-border);
        overflow-y: auto;
        scrollbar-gutter: stable;
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb) transparent;
      }

      .request-params-nav-list {
        display: grid;
        gap: 12px;
      }

      .request-params-nav-item {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        padding: 15px 18px;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 78%, transparent);
        border-radius: 14px;
        box-sizing: border-box;
        background: color-mix(in srgb, var(--input-shell-bg) 52%, transparent);
        color: var(--text-main);
        text-align: left;
        cursor: pointer;
      }

      .request-params-nav-item:hover {
        background: color-mix(in srgb, var(--input-shell-bg-hover) 78%, transparent);
      }

      .request-params-nav-item.is-active {
        border-color: color-mix(in srgb, var(--reasoning-accent) 42%, var(--input-shell-border));
        box-shadow: inset 2px 0 0 var(--reasoning-accent);
        background: color-mix(in srgb, var(--reasoning-accent) 7%, var(--input-shell-bg) 93%);
      }

      .request-params-nav-line {
        display: flex;
        align-items: center;
        gap: 12px;
        min-width: 0;
      }

      .request-params-nav-badge {
        flex: 0 0 auto;
        width: 32px;
        height: 32px;
        border-radius: 10px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: color-mix(in srgb, var(--input-button-bg) 78%, transparent);
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 82%, transparent);
        color: var(--request-params-nav-muted);
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.04em;
      }

      .request-params-nav-badge.request-params-badge-icon {
        font-size: 17px;
        font-weight: 400;
        letter-spacing: 0;
        line-height: 1;
      }

      .request-params-nav-text {
        min-width: 0;
        flex: 1 1 auto;
        max-width: 100%;
      }

      .request-params-nav-title {
        display: block;
        max-width: 100%;
        font-size: 15px;
        font-weight: 600;
        color: var(--request-params-nav-title-inactive);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .request-params-nav-item.is-active .request-params-nav-title {
        color: var(--text-main);
      }

      .request-params-nav-summary {
        display: block;
        max-width: 100%;
        margin-top: 6px;
        font-size: 13px;
        color: var(--request-params-nav-muted);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .request-params-panel {
        min-width: 0;
        min-height: 0;
        padding: 24px;
        overflow-y: auto;
        scrollbar-gutter: stable;
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb) transparent;
      }

      .request-params-panel-header {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 18px;
      }

      .request-params-panel-title {
        display: flex;
        flex-direction: column;
        gap: 2px;
      }

      .request-params-panel-title-main {
        font-size: 18px;
        font-weight: 700;
        color: var(--text-main);
      }

      .request-params-panel-title-subtitle {
        font-size: 13px;
        color: var(--input-welcome-text);
      }

      .request-params-panel-card {
        border: 1px solid var(--input-shell-border);
        border-radius: 16px;
        overflow: visible;
        background: color-mix(in srgb, var(--input-shell-bg) 58%, transparent);
      }

      .request-params-panel-card--stacked {
        overflow: visible;
        padding: 18px;
      }

      .request-params-stacked-editor {
        display: grid;
        gap: 16px;
      }

      .request-params-stacked-editor-head {
        display: flex;
        align-items: center;
        gap: 14px;
        min-width: 0;
      }

      .request-params-stacked-editor-title {
        min-width: 0;
        font-size: 15px;
        font-weight: 600;
        color: var(--text-main);
      }

      .request-params-stacked-editor-body {
        min-width: 0;
      }

      .request-params-stacked-editor-validation {
        min-height: 18px;
        display: flex;
        align-items: center;
        justify-content: flex-end;
        font-size: 12px;
        font-weight: 600;
        color: #d13438;
        text-align: right;
        visibility: hidden;
      }

      .request-params-stacked-editor-validation.is-visible {
        visibility: visible;
      }

      .request-params-row {
        display: grid;
        grid-template-columns: minmax(240px, 1fr) minmax(220px, 320px);
        align-items: center;
        gap: 16px;
        padding: 18px 18px;
      }

      .request-params-row + .request-params-row {
        border-top: 1px solid var(--input-shell-border);
      }

      .request-params-row-main {
        min-width: 0;
        display: flex;
        align-items: center;
        gap: 14px;
      }

      .request-params-row-label {
        min-width: 0;
        font-size: 15px;
        font-weight: 600;
        color: var(--text-main);
      }

      .request-params-row-label-wrap {
        min-height: 24px;
        display: flex;
        align-items: center;
      }

      .request-params-row-label-with-leading-icon {
        display: inline-flex;
        align-items: center;
        gap: 10px;
      }

      .request-params-row-leading-icon {
        flex: 0 0 auto;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-family: ${REQUEST_PARAMS_BADGE_ICON_FONT_FAMILY};
        font-size: 26px;
        font-weight: 400;
        line-height: 1;
        letter-spacing: 0;
        color: var(--text-main);
      }

      .request-params-row-help {
        margin-top: 6px;
        font-size: 12px;
        color: var(--input-welcome-text);
      }

      .request-params-row-control {
        min-width: 0;
        position: relative;
        overflow: visible;
      }

      .request-params-inline-control {
        width: 100%;
        display: inline-flex;
        align-items: center;
        justify-content: flex-end;
        gap: 12px;
      }

      .request-params-segmented {
        display: inline-flex;
        align-items: center;
        padding: 4px;
        border: 1px solid var(--input-shell-border);
        border-radius: 12px;
        background: color-mix(in srgb, var(--input-shell-bg) 72%, transparent);
        gap: 4px;
      }

      .request-params-segmented-button {
        appearance: none;
        -webkit-appearance: none;
        min-width: 84px;
        height: 36px;
        padding: 0 14px;
        border: 0;
        border-radius: 8px;
        background: transparent;
        color: var(--input-welcome-text);
        font: inherit;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
      }

      .request-params-segmented-button:hover {
        background: color-mix(in srgb, var(--input-shell-bg-hover) 78%, transparent);
        color: var(--text-main);
      }

      .request-params-segmented-button.is-active {
        background: var(--reasoning-accent);
        color: #ffffff;
      }

      .request-params-segmented-button:focus {
        outline: 2px solid color-mix(in srgb, var(--reasoning-accent) 60%, transparent);
        outline-offset: 1px;
      }

      .request-params-field,
      .request-params-textarea {
        width: 100%;
        box-sizing: border-box;
        border: 1px solid var(--input-shell-border);
        border-radius: 10px;
        background: color-mix(in srgb, var(--bg-main) 72%, transparent);
        color: var(--input-text);
        font: inherit;
      }

      .request-params-field {
        min-height: 44px;
        padding: 0 14px;
      }

      .request-params-field[type="number"] {
        appearance: auto;
        -webkit-appearance: auto;
        color-scheme: dark;
      }

      [data-theme="light"] .request-params-field[type="number"] {
        color-scheme: light;
      }

      .request-params-select {
        position: relative;
        width: 100%;
      }

      .request-params-select.is-open {
        z-index: 2;
      }

      .request-params-select-trigger {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        min-height: 44px;
        padding: 0 14px;
        border: 1px solid var(--input-shell-border);
        border-radius: 12px;
        box-sizing: border-box;
        background: color-mix(in srgb, var(--bg-main) 72%, transparent);
        color: var(--input-text);
        font: inherit;
        display: flex;
        align-items: center;
        gap: 12px;
        text-align: left;
        cursor: pointer;
      }

      .request-params-select-trigger:hover {
        background: color-mix(in srgb, var(--input-shell-bg-hover) 60%, var(--bg-main));
      }

      .request-params-select.is-open .request-params-select-trigger {
        border-color: color-mix(in srgb, var(--reasoning-accent) 42%, var(--input-shell-border));
      }

      .request-params-select.is-disabled .request-params-select-trigger {
        opacity: 0.55;
        cursor: not-allowed;
      }

      .request-params-select-trigger-label {
        min-width: 0;
        flex: 1 1 auto;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .request-params-select-trigger-icon {
        flex: 0 0 auto;
        color: var(--input-welcome-text);
        font-size: 26px;
        line-height: 1;
        transition: transform 120ms ease;
      }

      .request-params-select.is-open .request-params-select-trigger-icon {
        transform: rotate(180deg);
      }

      .request-params-select-panel {
        position: absolute;
        top: calc(100% + 8px);
        left: 0;
        right: 0;
        padding: 6px;
        border: 1px solid var(--input-menu-border);
        border-radius: 14px;
        box-sizing: border-box;
        background: var(--input-menu-bg);
        box-shadow: var(--input-shell-shadow);
        overflow-y: auto;
        scrollbar-gutter: stable;
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb) transparent;
        max-height: calc((var(--request-params-select-visible-items) * ${REQUEST_PARAMS_SELECT_OPTION_HEIGHT}px) + 12px);
        z-index: 30;
      }

      .request-params-select-option {
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        min-height: ${REQUEST_PARAMS_SELECT_OPTION_HEIGHT}px;
        padding: 0 12px;
        border: 0;
        border-radius: 10px;
        box-sizing: border-box;
        background: transparent;
        color: var(--input-menu-text);
        font: inherit;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        text-align: left;
        cursor: pointer;
      }

      .request-params-select-option:hover,
      .request-params-select-option:focus {
        background: var(--input-menu-item-hover-bg);
        color: var(--input-menu-item-hover-text);
        outline: none;
      }

      .request-params-select-option.is-selected {
        background: color-mix(in srgb, var(--reasoning-accent) 12%, transparent);
        color: var(--text-main);
      }

      .request-params-select-option-label {
        min-width: 0;
        flex: 1 1 auto;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .request-params-select-option-check {
        flex: 0 0 auto;
        width: 18px;
        text-align: right;
        color: var(--reasoning-accent);
        font-size: 13px;
        font-weight: 700;
      }

      .request-params-textarea {
        min-height: 132px;
        padding: 12px 14px;
        resize: vertical;
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb) transparent;
      }

      .request-params-textarea--large {
        min-height: 188px;
        width: 100%;
      }

      .request-params-nav::-webkit-scrollbar,
      .request-params-panel::-webkit-scrollbar,
      .request-params-textarea::-webkit-scrollbar,
      .request-params-select-panel::-webkit-scrollbar {
        width: 12px;
        height: 12px;
      }

      .request-params-nav::-webkit-scrollbar-thumb,
      .request-params-panel::-webkit-scrollbar-thumb,
      .request-params-textarea::-webkit-scrollbar-thumb,
      .request-params-select-panel::-webkit-scrollbar-thumb {
        background: var(--scrollbar-thumb);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      .request-params-nav::-webkit-scrollbar-thumb:hover,
      .request-params-panel::-webkit-scrollbar-thumb:hover,
      .request-params-textarea::-webkit-scrollbar-thumb:hover,
      .request-params-select-panel::-webkit-scrollbar-thumb:hover {
        background: var(--scrollbar-thumb-hover);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      .request-params-field:disabled,
      .request-params-textarea:disabled {
        opacity: 0.55;
        cursor: not-allowed;
      }

      .request-params-field:focus,
      .request-params-textarea:focus,
      .request-params-close:focus,
      .request-params-nav-item:focus,
      .request-params-select-trigger:focus,
      .request-params-select-option:focus {
        outline: 2px solid color-mix(in srgb, var(--reasoning-accent) 60%, transparent);
        outline-offset: 1px;
      }

      .request-params-switch {
        position: relative;
        flex: 0 0 auto;
        width: 42px;
        height: 24px;
      }

      .request-params-switch input {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        margin: 0;
        opacity: 0;
        cursor: pointer;
      }

      .request-params-switch-track {
        position: absolute;
        inset: 0;
        border-radius: 999px;
        background: color-mix(in srgb, var(--text-main) 20%, transparent);
        transition: background 120ms ease;
      }

      .request-params-switch-thumb {
        position: absolute;
        top: 3px;
        left: 3px;
        width: 18px;
        height: 18px;
        border-radius: 50%;
        background: #ffffff;
        box-shadow: 0 1px 4px rgba(0,0,0,0.28);
        transition: transform 120ms ease;
      }

      .request-params-switch input:checked + .request-params-switch-track {
        background: var(--reasoning-accent);
      }

      .request-params-switch input:checked + .request-params-switch-track .request-params-switch-thumb {
        transform: translateX(18px);
      }

      @media (max-width: 980px) {
        .request-params-dialog,
        .request-params-dialog--compact,
        .request-params-dialog--stacked {
          width: calc(100vw - 16px);
          min-height: 0;
          max-height: calc(100vh - 16px);
        }

        .request-params-layout,
        .request-params-dialog--stacked .request-params-layout {
          grid-template-columns: 1fr;
        }

        .request-params-nav {
          border-right: none;
          border-bottom: 1px solid var(--input-shell-border);
        }

        .request-params-row {
          grid-template-columns: 1fr;
        }
      }
    `;

    document.head.appendChild(style);
  }

  function buildSwitchHtml(path, checked) {
    return `
      <label class="request-params-switch">
        <input type="checkbox" data-role="toggle" data-path="${encodeAttribute(path)}" ${checked ? "checked" : ""}>
        <span class="request-params-switch-track">
          <span class="request-params-switch-thumb"></span>
        </span>
      </label>
    `;
  }

  function getSelectOptions(item) {
    return Array.isArray(getValueByPath(item.optionsPath))
      ? getValueByPath(item.optionsPath)
      : [];
  }

  function getSelectOptionLabel(item, option) {
    const optionValue = toStringValue(option && option.value);

    if (item.valuePath === "appSettings.language") {
      return getAppSettingsDisplayedLanguageLabel(option);
    }

    return toStringValue(option && option.label != null ? option.label : optionValue);
  }

  function normalizeSelectTypeaheadText(value) {
    return toStringValue(value)
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .trim()
      .toLowerCase();
  }

  function findSelectOptionByLeadingCharacter(item, key) {
    const normalizedKey = normalizeSelectTypeaheadText(key);

    if (!normalizedKey || normalizedKey.length !== 1) {
      return null;
    }

    const options = getSelectOptions(item);

    for (let i = 0; i < options.length; i += 1) {
      const option = options[i];
      const optionLabel = normalizeSelectTypeaheadText(
        getSelectOptionLabel(item, option)
      );
      const optionValue = normalizeSelectTypeaheadText(
        option && option.value
      );

      if (
        optionLabel.startsWith(normalizedKey) ||
        optionValue.startsWith(normalizedKey)
      ) {
        return option;
      }
    }

    return null;
  }

  function scheduleOpenSelectSelectedOptionVisibilitySync() {
    if (!overlayState.isVisible || !overlayState.openSelectPath) {
      return;
    }

    window.requestAnimationFrame(function () {
      const root = overlayState.elements.root;
      if (!root) return;

      const panel = root.querySelector('[data-role="select-panel"]');
      if (!panel) return;

      const selectedOption = panel.querySelector(".request-params-select-option.is-selected");
      if (!selectedOption || typeof selectedOption.scrollIntoView !== "function") {
        return;
      }

      selectedOption.scrollIntoView({
        block: "nearest"
      });
    });
  }

  function buildSelectHtml(item, value) {
    const options = getSelectOptions(item);
    const stringValue = toStringValue(value);
    const selectedOption = options.find(function (option) {
      return toStringValue(option.value) === stringValue;
    }) || null;
    const isDisabled = !options.length;
    const isOpen = !isDisabled && overlayState.openSelectPath === item.valuePath;
    const visibleItems = Math.min(
      options.length || 1,
      REQUEST_PARAMS_SELECT_MAX_VISIBLE_ITEMS
    );
    const panelId =
      "request-params-select-panel-" +
      item.valuePath.replace(/[^a-zA-Z0-9_-]/g, "-");
    const triggerLabel = selectedOption
      ? getSelectOptionLabel(item, selectedOption)
      : toStringValue(item.placeholder);

    return `
      <div
        class="request-params-select${isOpen ? " is-open" : ""}${isDisabled ? " is-disabled" : ""}"
        data-role="select-root"
        data-path="${encodeAttribute(item.valuePath)}"
        style="--request-params-select-visible-items:${visibleItems};"
      >
        <button
          type="button"
          class="request-params-select-trigger"
          data-role="select-trigger"
          data-path="${encodeAttribute(item.valuePath)}"
          data-panel-id="${encodeAttribute(panelId)}"
          aria-haspopup="listbox"
          aria-expanded="${isOpen ? "true" : "false"}"
          aria-controls="${encodeAttribute(panelId)}"${isDisabled ? " disabled" : ""}
        >
          <span class="request-params-select-trigger-label">${escapeHtml(triggerLabel)}</span>
          <span class="request-params-select-trigger-icon" aria-hidden="true">▾</span>
        </button>
        ${
          isOpen
            ? `
              <div
                class="request-params-select-panel"
                id="${encodeAttribute(panelId)}"
                data-role="select-panel"
                role="listbox"
                aria-label="${encodeAttribute(item.label)}"
              >
                ${options.map(function (option) {
                  const optionValue = toStringValue(option.value);
                  const optionLabel = getSelectOptionLabel(item, option);
                  const isSelected = optionValue === stringValue;

                  return `
                    <button
                      type="button"
                      class="request-params-select-option${isSelected ? " is-selected" : ""}"
                      data-role="select-option"
                      data-path="${encodeAttribute(item.valuePath)}"
                      data-value="${encodeAttribute(optionValue)}"
                      role="option"
                      aria-selected="${isSelected ? "true" : "false"}"
                    >
                      <span class="request-params-select-option-label">${escapeHtml(optionLabel)}</span>
                      <span class="request-params-select-option-check" aria-hidden="true">${isSelected ? "✓" : ""}</span>
                    </button>
                  `;
                }).join("")}
              </div>
            `
            : ""
        }
      </div>
    `;
  }

  function isStackedEditorCategory(category) {
    return !!(
      category &&
      Array.isArray(category.items) &&
      category.items.length === 1 &&
      category.items[0] &&
      category.items[0].type === "textarea" &&
      category.items[0].enabledPath
    );
  }

  function syncRequestParamsDialogLayout(category) {
    const dialog = overlayState.elements.dialog;
    if (!dialog) return;

    const stackedEditor = isStackedEditorCategory(category);

    dialog.classList.toggle("request-params-dialog--compact", !stackedEditor);
    dialog.classList.toggle("request-params-dialog--stacked", stackedEditor);
  }

  function renderStackedEditorHtml(item) {
    const enabled = item.enabledPath
      ? toBooleanValue(getValueByPath(item.enabledPath))
      : true;

    const value = getValueByPath(item.valuePath);
    const title = typeof item.labelWhenEnabled === "string" && typeof item.labelWhenDisabled === "string"
      ? (enabled ? item.labelWhenEnabled : item.labelWhenDisabled)
      : item.label;

    const showInvalidJson =
      isStructuredOutputItem(item) &&
      shouldShowStructuredOutputInvalidJson();

    return `
      <div class="request-params-stacked-editor">
        <div class="request-params-stacked-editor-head">
          ${buildSwitchHtml(item.enabledPath, enabled)}
          <div class="request-params-stacked-editor-title">${escapeHtml(title)}</div>
        </div>
        <div
          class="request-params-stacked-editor-validation${showInvalidJson ? " is-visible" : ""}"
          data-role="structured-output-invalid-json"
        >${showInvalidJson ? escapeHtml(getStructuredOutputInvalidJsonLabel()) : ""}</div>
        <div class="request-params-stacked-editor-body">
          <textarea
            class="request-params-textarea request-params-textarea--large"
            data-role="value"
            data-path="${encodeAttribute(item.valuePath)}"
            data-type="${item.type}"
            placeholder="${encodeAttribute(item.placeholder || "")}"${enabled ? "" : " disabled"}
          >${escapeHtml(formatInputValue(item, value))}</textarea>
        </div>
      </div>
    `;
  }

  function renderItemRowHtml(item) {
    const enabled = item.alwaysEnabled
      ? true
      : item.enabledPath
        ? toBooleanValue(getValueByPath(item.enabledPath))
        : toBooleanValue(getValueByPath(item.valuePath));

    const value = getValueByPath(item.valuePath);

    if (item.type === "theme-toggle") {
      const isDark = toBooleanValue(value);

      return `
        <div class="request-params-row">
          <div class="request-params-row-main">
            <div>
              <div class="request-params-row-label">${escapeHtml(item.label)}</div>
            </div>
          </div>
          <div class="request-params-row-control">
            <div class="request-params-inline-control">
              <div class="request-params-segmented" role="group" aria-label="${encodeAttribute(item.label)}">
                <button
                  type="button"
                  class="request-params-segmented-button${isDark ? "" : " is-active"}"
                  data-role="theme-choice"
                  data-path="${encodeAttribute(item.valuePath)}"
                  data-value="light"
                >${escapeHtml(t("requestParams.panel.theme.light", "Light"))}</button>
                <button
                  type="button"
                  class="request-params-segmented-button${isDark ? " is-active" : ""}"
                  data-role="theme-choice"
                  data-path="${encodeAttribute(item.valuePath)}"
                  data-value="dark"
                >${escapeHtml(t("requestParams.panel.theme.dark", "Dark"))}</button>
              </div>
            </div>
          </div>
        </div>
      `;
    }

    if (item.type === "select") {
      return `
        <div class="request-params-row">
          <div class="request-params-row-main">
            <div>
              <div class="request-params-row-label">${escapeHtml(item.label)}</div>
            </div>
          </div>
          <div class="request-params-row-control">
            ${buildSelectHtml(item, value)}
          </div>
        </div>
      `;
    }

    if (item.type === "boolean-right") {
      return `
        <div class="request-params-row">
          <div class="request-params-row-main">
            <div>
              <div class="request-params-row-label">${escapeHtml(item.label)}</div>
            </div>
          </div>
          <div class="request-params-row-control">
            <div class="request-params-inline-control">
              ${buildSwitchHtml(item.valuePath, enabled)}
            </div>
          </div>
        </div>
      `;
    }

    const toggleHtml = item.enabledPath
      ? buildSwitchHtml(item.enabledPath, enabled)
      : item.type === "boolean"
        ? buildSwitchHtml(item.valuePath, enabled)
        : item.valuePath === "settings.temperature"
          ? ""
          : '<span style="width:42px;display:inline-block;"></span>';

    let controlHtml = "";

    if (item.type === "textarea" || item.type === "textarea-list") {
      controlHtml = `
        <textarea
          class="request-params-textarea"
          data-role="value"
          data-path="${encodeAttribute(item.valuePath)}"
          data-type="${item.type}"
          placeholder="${encodeAttribute(item.placeholder || "")}"${enabled ? "" : " disabled"}
        >${escapeHtml(formatInputValue(item, value))}</textarea>
      `;
    } else if (item.type === "number") {
      const minAttr = item.min == null ? "" : ` min="${item.min}"`;
      const maxAttr = item.max == null ? "" : ` max="${item.max}"`;
      const stepAttr = item.step == null ? "" : ` step="${item.step}"`;

      controlHtml = `
        <input
          class="request-params-field"
          type="number"
          data-role="value"
          data-path="${encodeAttribute(item.valuePath)}"
          data-type="number"
          value="${encodeAttribute(formatInputValue(item, value))}"${minAttr}${maxAttr}${stepAttr}${enabled ? "" : " disabled"}
        >
      `;
    } else if (item.type === "boolean") {
      controlHtml = '<div></div>';
    }

    const labelHtml = item.valuePath === "settings.temperature"
      ? `
        <div class="request-params-row-label request-params-row-label-with-leading-icon">
          <span class="request-params-row-leading-icon">${escapeHtml("\uE9CA")}</span>
          <span>${escapeHtml(item.label)}</span>
        </div>
      `
      : `
        <div class="request-params-row-label">${escapeHtml(item.label)}</div>
      `;

    return `
      <div class="request-params-row">
        <div class="request-params-row-main">
          ${toggleHtml}
          <div class="request-params-row-label-wrap">
            ${labelHtml}
          </div>
        </div>
        <div class="request-params-row-control">${controlHtml}</div>
      </div>
    `;
  }

  function isRequestParamsEditableTarget(target) {
    return !!(
      target &&
      (
        target instanceof HTMLTextAreaElement ||
        (target instanceof HTMLInputElement && target.getAttribute("data-role") === "value")
      )
    );
  }

  function isTargetInsideRequestParamsOverlay(target) {
    const root = overlayState.elements.root;

    return !!(
      root &&
      target instanceof Node &&
      root.contains(target)
    );
  }

  function resolveRequestParamsEditableTarget(event) {
    const directTarget = event && event.target;

    if (
      isRequestParamsEditableTarget(directTarget) &&
      isTargetInsideRequestParamsOverlay(directTarget)
    ) {
      return directTarget;
    }

    const activeElement = document.activeElement;

    if (
      isRequestParamsEditableTarget(activeElement) &&
      isTargetInsideRequestParamsOverlay(activeElement)
    ) {
      return activeElement;
    }

    return null;
  }

  function getSelectedTextFromEditableTarget(target) {
    if (!isRequestParamsEditableTarget(target)) {
      return "";
    }

    try {
      if (
        typeof target.selectionStart === "number" &&
        typeof target.selectionEnd === "number"
      ) {
        const start = Math.max(0, target.selectionStart);
        const end = Math.max(start, target.selectionEnd);
        return String(target.value == null ? "" : target.value).slice(start, end);
      }
    } catch (_) {}

    try {
      if (window.getSelection) {
        return String(window.getSelection() || "");
      }
    } catch (_) {}

    return "";
  }

  function stopEventCompletely(event) {
    event.preventDefault();
    event.stopPropagation();

    if (typeof event.stopImmediatePropagation === "function") {
      event.stopImmediatePropagation();
    }
  }

  function stopEventPropagationOnly(event) {
    event.stopPropagation();

    if (typeof event.stopImmediatePropagation === "function") {
      event.stopImmediatePropagation();
    }
  }

  function writeTextToClipboard(text) {
    const value = String(text == null ? "" : text);

    if (!value) {
      return;
    }

    try {
      if (
        navigator.clipboard &&
        typeof navigator.clipboard.writeText === "function"
      ) {
        navigator.clipboard.writeText(value);
        return;
      }
    } catch (_) {}

    const activeElement = document.activeElement;
    const helper = document.createElement("textarea");

    helper.value = value;
    helper.setAttribute("readonly", "");
    helper.style.position = "fixed";
    helper.style.left = "-99999px";
    helper.style.top = "0";
    helper.style.opacity = "0";

    document.body.appendChild(helper);
    helper.focus();
    helper.select();

    try {
      document.execCommand("copy");
    } catch (_) {}

    document.body.removeChild(helper);

    if (activeElement && typeof activeElement.focus === "function") {
      try {
        activeElement.focus();
      } catch (_) {}
    }
  }

  function deleteEditableSelection(target) {
    if (!isRequestParamsEditableTarget(target)) {
      return false;
    }

    if (target.disabled || target.readOnly) {
      return false;
    }

    try {
      if (
        typeof target.selectionStart === "number" &&
        typeof target.selectionEnd === "number"
      ) {
        const value = String(target.value == null ? "" : target.value);
        const start = Math.max(0, target.selectionStart);
        const end = Math.max(start, target.selectionEnd);

        if (start === end) {
          return false;
        }

        target.value = value.slice(0, start) + value.slice(end);
        target.selectionStart = start;
        target.selectionEnd = start;

        target.dispatchEvent(new Event("input", { bubbles: true }));
        return true;
      }
    } catch (_) {}

    return false;
  }

  function handleRequestParamsEditableShortcutKeydown(event) {
    if (!overlayState.isVisible) return;
    if (!(event.ctrlKey || event.metaKey) || event.altKey) return;

    const target = resolveRequestParamsEditableTarget(event);
    if (!target) return;

    const key = String(event.key || "").toLowerCase();

    if (key === "c" || key === "x" || key === "v" || key === "a") {
      stopEventPropagationOnly(event);
    }
  }

  function handleRequestParamsEditableCopy(event) {
    if (!overlayState.isVisible) return;

    const target = resolveRequestParamsEditableTarget(event);
    if (!target) return;

    stopEventPropagationOnly(event);
  }

  function handleRequestParamsEditableCut(event) {
    if (!overlayState.isVisible) return;

    const target = resolveRequestParamsEditableTarget(event);
    if (!target) return;

    stopEventPropagationOnly(event);
  }

  function handleRequestParamsEditablePaste(event) {
    if (!overlayState.isVisible) return;

    const target = resolveRequestParamsEditableTarget(event);
    if (!target) return;

    stopEventPropagationOnly(event);
  }

  function handleOpenSelectTypeaheadKeydown(event) {
    if (!overlayState.isVisible) return;
    if (!overlayState.openSelectPath) return;

    if (event.ctrlKey || event.metaKey || event.altKey) {
      return;
    }

    const editableTarget = resolveRequestParamsEditableTarget(event);
    if (editableTarget) {
      return;
    }

    const key = toStringValue(event.key);

    if (key.length !== 1) {
      return;
    }

    if (!/[a-zA-Z0-9]/.test(key)) {
      return;
    }

    const category = categoryDefinitions[overlayState.activeCategoryId];
    if (!category || !Array.isArray(category.items)) {
      return;
    }

    const item = category.items.find(function (entry) {
      return (
        entry &&
        entry.type === "select" &&
        entry.valuePath === overlayState.openSelectPath
      );
    });

    if (!item) {
      return;
    }

    const matchedOption = findSelectOptionByLeadingCharacter(item, key);

    if (!matchedOption) {
      return;
    }

    stopEventCompletely(event);

    applyRequestParamsUpdate(
      { [item.valuePath]: matchedOption.value },
      { render: false }
    );

    if (item.valuePath === "appSettings.language") {
      sendLanguageSelected(matchedOption.value);
    }

    if (shouldSendRequestParamsValuesForPath(item.valuePath)) {
      scheduleSendRequestParamsValues();
    }

    renderOverlay({ recalculateWidth: false });
    scheduleOpenSelectSelectedOptionVisibilitySync();
  }

  function ensureOverlayMounted() {
    if (overlayState.mounted && overlayState.elements.root) {
      return overlayState.elements.root;
    }

    injectOverlayStyles();
    const root = document.createElement("div");
    root.id = REQUEST_PARAMS_OVERLAY_ID;
    root.className = "request-params-overlay";
    root.innerHTML = `
      <div class="request-params-overlay-backdrop" data-role="overlay-close"></div>
      <div class="request-params-dialog" id="${REQUEST_PARAMS_DIALOG_ID}" role="dialog" aria-modal="true" aria-labelledby="request-params-panel-title">
        <div class="request-params-header">
          <div class="request-params-header-title">
            <span class="${getRequestParamsBadgeClassName("request-params-header-badge", "RP")}">${escapeHtml(getRequestParamsBadgeDisplayValue("RP"))}</span>
            <span data-role="request-params-header-title">${escapeHtml(t("requestParams.panel.title", "Parameters"))}</span>
          </div>
          <button type="button" class="request-params-close" data-role="overlay-close" aria-label="${encodeAttribute(t("requestParams.panel.close", "Close"))}">×</button>
        </div>
        <div class="request-params-layout">
          <div class="request-params-nav" id="request-params-nav"></div>
          <div class="request-params-panel">
            <div class="request-params-panel-header">
              <span class="request-params-header-badge" id="request-params-panel-badge"></span>
              <div class="request-params-panel-title" id="request-params-panel-title"></div>
            </div>
            <div class="request-params-panel-card" id="request-params-panel-body"></div>
          </div>
        </div>
      </div>
    `;

    document.body.appendChild(root);

    overlayState.elements.root = root;
    overlayState.elements.dialog = root.querySelector("#" + REQUEST_PARAMS_DIALOG_ID);
    overlayState.elements.nav = root.querySelector("#request-params-nav");
    overlayState.elements.panelBadge = root.querySelector("#request-params-panel-badge");
    overlayState.elements.panelTitle = root.querySelector("#request-params-panel-title");
    overlayState.elements.panelBody = root.querySelector("#request-params-panel-body");
    overlayState.elements.closeButton = root.querySelector(".request-params-close");
    overlayState.mounted = true;

    window.addEventListener("keydown", handleRequestParamsEditableShortcutKeydown, true);
    window.addEventListener("keydown", handleOpenSelectTypeaheadKeydown, true);
    window.addEventListener("copy", handleRequestParamsEditableCopy, true);
    window.addEventListener("beforecopy", handleRequestParamsEditableCopy, true);
    window.addEventListener("cut", handleRequestParamsEditableCut, true);
    window.addEventListener("paste", handleRequestParamsEditablePaste, true);

    root.addEventListener("click", function (event) {
      const eventTarget = event.target instanceof Element ? event.target : null;
      const actionTarget = eventTarget ? eventTarget.closest("[data-role]") : null;
      const role = actionTarget ? actionTarget.getAttribute("data-role") : "";
      const clickedInsideSelect = !!(
        eventTarget && eventTarget.closest(".request-params-select")
      );

      if (role === "overlay-close") {
        hideRequestParamsOverlay();
        return;
      }

      if (role === "select-trigger") {
        const path = actionTarget.getAttribute("data-path");

        if (!path || actionTarget.hasAttribute("disabled")) return;

        overlayState.openSelectPath =
          overlayState.openSelectPath === path ? "" : path;

        renderOverlay({ recalculateWidth: false });
        return;
      }

      if (role === "select-option") {
        const path = actionTarget.getAttribute("data-path");
        const selectedValue = actionTarget.getAttribute("data-value");

        if (!path) return;

        overlayState.openSelectPath = "";
        applyRequestParamsUpdate({ [path]: selectedValue }, { render: false });

        if (path === "appSettings.language") {
          sendLanguageSelected(selectedValue);
        }

        if (shouldSendRequestParamsValuesForPath(path)) {
          scheduleSendRequestParamsValues();
        }

        renderOverlay({ recalculateWidth: false });
        return;
      }

      if (!actionTarget) {
        if (!clickedInsideSelect && overlayState.openSelectPath) {
          overlayState.openSelectPath = "";
          renderOverlay({ recalculateWidth: false });
        }
        return;
      }

      if (role === "nav-item") {
        const categoryId = actionTarget.getAttribute("data-category");
        const index = toIntegerValue(actionTarget.getAttribute("data-index"));

        if (!categoryDefinitions[categoryId]) return;
        if (categoryOrder[index] !== categoryId) return;

        overlayState.openSelectPath = "";
        overlayState.activeCategoryId = categoryId;
        renderOverlay({ recalculateWidth: false });
        sendRequestParamsPageChanged(index);
        return;
      }

      if (role === "theme-choice") {
        const path = actionTarget.getAttribute("data-path");
        const selectedValue = actionTarget.getAttribute("data-value");
        const normalizedTheme = selectedValue === "dark" ? "dark" : "light";

        if (!path) return;

        overlayState.openSelectPath = "";
        applyRequestParamsUpdate({ [path]: normalizedTheme === "dark" });
        sendLookAndFeelSelected(normalizedTheme);

        if (shouldSendRequestParamsValuesForPath(path)) {
          scheduleSendRequestParamsValues();
        }

        return;
      }
    });

    root.addEventListener("change", function (event) {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;

      const role = target.getAttribute("data-role");
      const path = target.getAttribute("data-path");
      if (!path) return;

      if (role === "toggle" && target instanceof HTMLInputElement) {
        applyRequestParamsUpdate({ [path]: target.checked });

        if (path === "appSettings.scrollButtons") {
          sendScrollButtonSelected(target.checked);
        }

        if (path === "structuredOutput.enabled") {
          scheduleStructuredOutputValidationUiSync();
        }

        if (shouldSendRequestParamsValuesForPath(path)) {
          scheduleSendRequestParamsValues();
        }

        return;
      }

      if (role === "value" && target instanceof HTMLSelectElement && target.dataset.type === "select") {
        applyRequestParamsUpdate({ [path]: target.value }, { render: false });

        if (path === "appSettings.language") {
          sendLanguageSelected(target.value);
        }

        if (shouldSendRequestParamsValuesForPath(path)) {
          scheduleSendRequestParamsValues();
        }

        return;
      }

      if (role === "value" && target instanceof HTMLInputElement && target.dataset.type === "number") {
        applyRequestParamsUpdate({ [path]: target.value }, { render: false });

        if (shouldSendRequestParamsValuesForPath(path)) {
          scheduleSendRequestParamsValues();
        }
      }
    });

    root.addEventListener("input", function (event) {
      const target = event.target;
      if (!(target instanceof HTMLElement)) return;

      const role = target.getAttribute("data-role");
      const path = target.getAttribute("data-path");
      if (role !== "value" || !path) return;

      if (target instanceof HTMLTextAreaElement) {
        if (target.dataset.type === "textarea-list") {
          const values = target.value
            .split(/\r?\n/)
            .map(function (line) { return line.trim(); })
            .filter(function (line) { return line.length > 0; });

          applyRequestParamsUpdate({ [path]: values }, { render: false });

          if (shouldSendRequestParamsValuesForPath(path)) {
            scheduleSendRequestParamsValues();
          }

          return;
        }

        applyRequestParamsUpdate({ [path]: target.value }, { render: false });

        if (path === "structuredOutput.jsonSchema") {
          scheduleStructuredOutputValidationUiSync();
        }

        if (shouldSendRequestParamsValuesForPath(path)) {
          scheduleSendRequestParamsValues();
        }

        return;
      }

      if (target instanceof HTMLInputElement && target.dataset.type === "number") {
        applyRequestParamsUpdate({ [path]: target.value }, { render: false });

        if (shouldSendRequestParamsValuesForPath(path)) {
          scheduleSendRequestParamsValues();
        }
      }
    });

    document.addEventListener("keydown", function (event) {
      if (!overlayState.isVisible) return;

      if (event.key === "Escape") {
        event.preventDefault();
        hideRequestParamsOverlay();
      }
    });

    return root;
  }

  function renderOverlayNav(options) {
    const nav = overlayState.elements.nav;
    if (!nav) return;

    const shouldRecalculateWidth = !!(options && options.recalculateWidth);

    nav.innerHTML = `
      <div class="request-params-nav-list">
        ${categoryOrder.map(function (categoryId, index) {
          const category = categoryDefinitions[categoryId];
          const activeClass = categoryId === overlayState.activeCategoryId ? " is-active" : "";
          const summary = category.subtitle || buildCategorySummary(categoryId);

          return `
            <button
              type="button"
              class="request-params-nav-item${activeClass}"
              data-role="nav-item"
              data-category="${encodeAttribute(category.id)}"
              data-index="${index}"
            >
              <span class="request-params-nav-line">
                <span class="${getRequestParamsBadgeClassName("request-params-nav-badge", category.badge)}">${escapeHtml(getRequestParamsBadgeDisplayValue(category.badge))}</span>
                <span class="request-params-nav-text">
                  <span class="request-params-nav-title">${escapeHtml(category.title)}</span>
                  <span class="request-params-nav-summary">${escapeHtml(summary)}</span>
                </span>
              </span>
            </button>
          `;
        }).join("")}
      </div>
    `;

    if (shouldRecalculateWidth) {
      scheduleRequestParamsNavLayoutSync();
    } else {
      scheduleRequestParamsNavTooltipSync();
    }
  }

  function renderOverlayPanel() {
    const category = categoryDefinitions[overlayState.activeCategoryId] || categoryDefinitions.sampling;
    if (!category) return;

    syncRequestParamsDialogLayout(category);

    if (overlayState.elements.panelBadge) {
      overlayState.elements.panelBadge.className = getRequestParamsBadgeClassName("request-params-header-badge", category.badge);
      overlayState.elements.panelBadge.textContent = getRequestParamsBadgeDisplayValue(category.badge);
    }

    if (overlayState.elements.panelTitle) {
      const panelSubtitle = Object.prototype.hasOwnProperty.call(category, "panelSubtitle")
        ? category.panelSubtitle
        : category.subtitle;

      overlayState.elements.panelTitle.innerHTML = panelSubtitle
        ? `
          <span class="request-params-panel-title-main">${escapeHtml(category.title)}</span>
          <span class="request-params-panel-title-subtitle">${escapeHtml(panelSubtitle)}</span>
        `
        : `
          <span class="request-params-panel-title-main">${escapeHtml(category.title)}</span>
        `;
    }

    if (overlayState.elements.panelBody) {
      const panelBody = overlayState.elements.panelBody;
      const stackedEditor = isStackedEditorCategory(category);

      panelBody.classList.toggle("request-params-panel-card--stacked", stackedEditor);
      panelBody.innerHTML = stackedEditor
        ? renderStackedEditorHtml(category.items[0])
        : category.items.map(renderItemRowHtml).join("");
    }
  }

  function renderOverlayHeaderTexts() {
    const root = overlayState.elements.root;
    if (!root) return;

    const headerTitle = root.querySelector('[data-role="request-params-header-title"]');

    if (headerTitle) {
      headerTitle.textContent = t("requestParams.panel.title", "Parameters");
    }

    if (overlayState.elements.closeButton) {
      overlayState.elements.closeButton.setAttribute(
        "aria-label",
        t("requestParams.panel.close", "Close")
      );
    }
  }

  function renderOverlay(options) {
    if (!overlayState.mounted || !overlayState.elements.root) {
      return;
    }

    renderOverlayHeaderTexts();
    renderOverlayNav(options);
    renderOverlayPanel();
  }

  function showRequestParamsOverlay(page) {
    const categoryId = getRequestParamsCategoryIdByPage(page);

    if (categoryId) {
      overlayState.activeCategoryId = categoryId;
    }

    const root = ensureOverlayMounted();
    overlayState.openSelectPath = "";
    overlayState.isVisible = true;
    root.classList.add("is-visible");
    document.body.classList.add("request-params-overlay-open");
    renderOverlay({ recalculateWidth: true });
  }

  function hideRequestParamsOverlay() {
    const root = overlayState.elements.root;
    if (!root) return;

    if (overlayState.navMeasureFrame) {
      window.cancelAnimationFrame(overlayState.navMeasureFrame);
      overlayState.navMeasureFrame = 0;
    }

    if (overlayState.navTooltipFrame) {
      window.cancelAnimationFrame(overlayState.navTooltipFrame);
      overlayState.navTooltipFrame = 0;
    }

    overlayState.openSelectPath = "";
    overlayState.isVisible = false;
    root.classList.remove("is-visible");
    document.body.classList.remove("request-params-overlay-open");
  }

  function scheduleSendRequestParamsValues() {
    clearTimeout(overlayState.sendTimer);
    overlayState.sendTimer = window.setTimeout(function () {
      sendRequestParamsValues();
    }, 120);
  }

  function shouldSendRequestParamsValuesForPath(path) {
    const normalizedPath = toStringValue(path).trim();

    if (!normalizedPath) {
      return false;
    }

    return !(
      normalizedPath === "appSettings.lookAndFeelDark" ||
      normalizedPath === "appSettings.language" ||
      normalizedPath === "appSettings.scrollButtons"
    );
  }

  function applyRequestParamsUpdate(msg, options) {
    if (!msg || typeof msg !== "object") return;

    const shouldRender = !options || options.render !== false;

    Object.keys(requestParamsUpdateHandlers).forEach(function (key) {
      if (Object.prototype.hasOwnProperty.call(msg, key)) {
        requestParamsUpdateHandlers[key](msg[key]);
      }
    });

    if (shouldRender && overlayState.isVisible) {
      renderOverlay();
    }
  }

  function applyRequestParamsMainValues(msg, options) {
    if (!msg || typeof msg !== "object") return;

    const shouldRender = !options || options.render !== false;

    if (Object.prototype.hasOwnProperty.call(msg, "look")) {
      const normalizedLook =
        toStringValue(msg.look).trim().toLowerCase() === "dark" ? "dark" : "light";

      setAppSettingsLookAndFeelDark(normalizedLook === "dark");
      sendLookAndFeelSelected(normalizedLook);
    }

    if (Object.prototype.hasOwnProperty.call(msg, "language")) {
      setAppSettingsAvailableLanguages(msg.language);
    }

    if (
      Object.prototype.hasOwnProperty.call(msg, "selected") &&
      toStringValue(msg.selected).trim() !== ""
    ) {
      applySetLanguageMessage(
        { name: msg.selected },
        { render: false, internal: false }
      );
    }

    if (Object.prototype.hasOwnProperty.call(msg, "scroll")) {
      const nextScrollButtonsValue = toBooleanValue(msg.scroll);

      setAppSettingsScrollButtons(nextScrollButtonsValue);
      sendScrollButtonSelected(nextScrollButtonsValue);
    }

    if (shouldRender && overlayState.isVisible) {
      renderOverlay({ recalculateWidth: true });
    }
  }

  function flattenRequestParamsInitializationSection(source, prefix, target) {
    if (!source || typeof source !== "object" || Array.isArray(source)) {
      return;
    }

    Object.keys(source).forEach(function (key) {
      const value = source[key];
      const path = prefix ? prefix + "." + key : key;

      if (Array.isArray(value)) {
        target[path] = clone(value);
        return;
      }

      if (value && typeof value === "object") {
        flattenRequestParamsInitializationSection(value, path, target);
        return;
      }

      target[path] = value;
    });
  }

  function applyRequestParamsInitialization(msg, options) {
    if (!msg || typeof msg !== "object") return;

    const update = {};

    flattenRequestParamsInitializationSection(
      msg.systemPrompt,
      "systemPrompt",
      update
    );
    flattenRequestParamsInitializationSection(
      msg.settings,
      "settings",
      update
    );
    flattenRequestParamsInitializationSection(
      msg.sampling,
      "sampling",
      update
    );
    flattenRequestParamsInitializationSection(
      msg.structuredOutput,
      "structuredOutput",
      update
    );
    flattenRequestParamsInitializationSection(
      msg.vendorSettings,
      "vendorSettings",
      update
    );

    applyRequestParamsUpdate(update, options);
  }

  function applySetLanguageMessage(msg, options) {
    if (!msg || typeof msg !== "object") return;

    const shouldRender = !options || options.render !== false;
    const isInternalSelection = !options || options.internal !== false;

    isInternalLanguageSelection = isInternalSelection;

    try {
      const targetOption = findAppSettingsLanguageOptionByName(msg.name);

      if (!targetOption) {
        return;
      }

      setAppSettingsLanguage(targetOption.value);
      setAppSettingsLanguageName(msg.name);

      if (shouldRender && overlayState.isVisible) {
        renderOverlay({ recalculateWidth: false });
      }

      sendLanguageSelected(targetOption.value);
    } finally {
      isInternalLanguageSelection = false;
    }
  }

  function buildRequestParamsValuesMessage() {
    return {
      event: "request-params-values",
      systemPrompt: clone(state.systemPrompt),
      settings: clone(state.settings),
      sampling: clone(state.sampling),
      structuredOutput: clone(state.structuredOutput),
      vendorSettings: clone(state.vendorSettings)
    };
  }

  function postRequestParamsMessage(message) {
    if (!window.chrome || !window.chrome.webview) return;

    window.chrome.webview.postMessage(message);
  }

  function sendLookAndFeelSelected(value) {
    postRequestParamsMessage({
      event: "look-and-feel-selected",
      value: value === "dark" ? "dark" : "light"
    });
  }

  function sendLanguageSelected(value) {
    postRequestParamsMessage({
      event: "language-selected",
      value: toStringValue(value),
      internal: isInternalLanguageSelection
    });
  }

  function sendScrollButtonSelected(value) {
    postRequestParamsMessage({
      event: "scroll-button-selected",
      value: toBooleanValue(value)
    });
  }

  function sendRequestParamsPageChanged(index) {
    postRequestParamsMessage({
      event: "resquest-params-page-changed",
      index: toIntegerValue(index)
    });
  }

  function sendRequestParamsValues() {
    postRequestParamsMessage(buildRequestParamsValuesMessage());
  }

  function resetState() {
    state.appSettings.lookAndFeelDark = DEFAULT_LOOK_AND_FEEL_DARK;
    state.appSettings.language = state.appSettings.availableLanguages.length
      ? state.appSettings.availableLanguages[0].value
      : DEFAULT_APP_LANGUAGE;
    state.appSettings.languageName = DEFAULT_APP_LANGUAGE_NAME;
    state.appSettings.scrollButtons = DEFAULT_SCROLL_BUTTONS;

    state.systemPrompt.systemPrompt = "";
    state.systemPrompt.enabled = false;

    state.settings.temperature = DEFAULT_TEMPERATURE;
    state.settings.maxToken.maxToken = DEFAULT_MAX_TOKEN;
    state.settings.maxToken.enabled = false;
    state.settings.stopString.stopString = [];
    state.settings.stopString.enabled = false;

    state.sampling.topK.topK = DEFAULT_TOP_K;
    state.sampling.topK.enabled = false;
    state.sampling.presencePenalty.presencePenalty = DEFAULT_PRESENCE_PENALTY;
    state.sampling.presencePenalty.enabled = false;
    state.sampling.topP.topP = DEFAULT_TOP_P;
    state.sampling.topP.enabled = false;
    state.sampling.seed.seed = DEFAULT_SEED;
    state.sampling.seed.enabled = false;

    state.structuredOutput.jsonSchema = "";
    state.structuredOutput.enabled = false;

    state.vendorSettings.parallelToolCalls = false;
    state.vendorSettings.backgroundResponse = false;
    state.vendorSettings.usingPreviousId = false;
    state.vendorSettings.store = false;

    if (overlayState.isVisible) {
      renderOverlay();
    }
  }

  window.addEventListener(REQUEST_PARAMS_I18N_EVENT, function () {
    applyRequestParamsDictionary();
    refreshAppSettingsAvailableLanguagesLabels();

    if (overlayState.mounted) {
      renderOverlay({ recalculateWidth: true });
    }
  });

  applyRequestParamsDictionary();

  window.RequestParams = {
    getState() {
      return clone(state);
    },

    sendValues() {
      sendRequestParamsValues();
    },

    applyUpdate(msg) {
      applyRequestParamsUpdate(msg);
    },

    applyMainValues(msg) {
      applyRequestParamsMainValues(msg);
    },

    applyInitialization(msg) {
      applyRequestParamsInitialization(msg);
    },

    show(page) {
      showRequestParamsOverlay(page);
    },

    hide() {
      hideRequestParamsOverlay();
    },

    reset() {
      resetState();
    },

    setAppSettingsAvailableLanguages,
    setAppSettingsLanguage,
    setAppSettingsLanguageName,
    setAppSettingsLookAndFeelDark,
    setAppSettingsScrollButtons,

    setSystemPromptSystemPrompt,
    setSystemPromptEnabled,

    setSettingsTemperature,
    setSettingsMaxTokenValue,
    setSettingsMaxTokenEnabled,
    setSettingsStopStringValue,
    setSettingsStopStringEnabled,

    setSamplingTopKValue,
    setSamplingTopKEnabled,
    setSamplingPresencePenaltyValue,
    setSamplingPresencePenaltyEnabled,
    setSamplingTopPValue,
    setSamplingTopPEnabled,

    setSamplingSeedValue,
    setSamplingSeedEnabled,

    setStructuredOutputJsonschema,
    setStructuredOutputEnabled,

    setVendorSettingsParallelToolCalls,
    setVendorSettingsBackgroundResponse,
    setVendorSettingsUsingPreviousId,
    setVendorSettingsStore
  };

  window.chrome.webview.addEventListener("message", function (event) {
    const msg = event.data;
    if (!msg) return;

    if (msg.type === "request-params-get-values") {
      sendRequestParamsValues();
      return;
    }

    if (msg.type === "request-params-main-values") {
      applyRequestParamsMainValues(msg);
      return;
    }

    if (msg.type === "request-initialization") {
      applyRequestParamsInitialization(msg);
      return;
    }

    if (msg.type === "request-params-update") {
      applyRequestParamsUpdate(msg);
      return;
    }

    if (msg.type === "set-language") {
      applySetLanguageMessage(msg);
      return;
    }

    if (msg.type === "request-params-show") {
      showRequestParamsOverlay(msg.page);
      return;
    }

    if (msg.type === "request-params-hide") {
      hideRequestParamsOverlay();
    }
  });

})();
