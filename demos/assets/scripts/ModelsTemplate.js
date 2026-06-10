(() => {
  const STYLE_ID = "model-selector-panel-style";
  const ROOT_ID = "model-selector-panel-root";
  const BODY_OPEN_CLASS = "msp-overlay-open";
  const MODEL_SELECTOR_ICON_FONT_FAMILY = '"Segoe Fluent Icons", "Segoe UI Symbol", sans-serif';
  const I18N_EVENT_NAME = window.AppI18n && window.AppI18n.eventName
    ? window.AppI18n.eventName
    : "app:i18n:changed";
  const I18N_NAMESPACE = "modelSelector";
  const FEATURE_LABEL_I18N_KEY_BY_LABEL = {
    "Web research": I18N_NAMESPACE + ".features.webResearch",
    Thinking: I18N_NAMESPACE + ".features.thinking",
    "Attach files": I18N_NAMESPACE + ".features.attachFiles",
    Vision: I18N_NAMESPACE + ".features.vision",
    "Create Image": I18N_NAMESPACE + ".features.createImage",
    "Create Video": I18N_NAMESPACE + ".features.createVideo",
    "Create Audio": I18N_NAMESPACE + ".features.createAudio",
    "Speech to text": I18N_NAMESPACE + ".features.speechToText",
    "Text to speech": I18N_NAMESPACE + ".features.textToSpeech",
    "Deep Research": I18N_NAMESPACE + ".features.deepResearch"
  };
  const CATEGORY_LABEL_I18N_KEY_BY_ID = {
    allModels: I18N_NAMESPACE + ".categories.allModels.label",
    textGeneration: I18N_NAMESPACE + ".categories.textGeneration.label",
    imageCreation: I18N_NAMESPACE + ".categories.imageCreation.label",
    videoCreation: I18N_NAMESPACE + ".categories.videoCreation.label",
    audioCreation: I18N_NAMESPACE + ".categories.audioCreation.label",
    speechToText: I18N_NAMESPACE + ".features.speechToText",
    SpeechToText: I18N_NAMESPACE + ".features.speechToText",
    textToSpeech: I18N_NAMESPACE + ".categories.textToSpeech.label",
    deepResearch: I18N_NAMESPACE + ".categories.deepResearch.label"
  };

  function interpolateText(text, vars) {
    return String(text == null ? "" : text).replace(/\{([a-zA-Z0-9_]+)\}/g, function (_, token) {
      if (vars && Object.prototype.hasOwnProperty.call(vars, token)) {
        const value = vars[token];
        return value == null ? "" : String(value);
      }
      return "{" + token + "}";
    });
  }

  function t(key, fallback, vars) {
    if (window.AppI18n && typeof window.AppI18n.t === "function") {
      return window.AppI18n.t(key, fallback, vars);
    }

    return interpolateText(fallback, vars);
  }

  const FEATURE_ICON_BY_LABEL = {
    "Web research": "\uE12B",
    Thinking: "\uEA91",
    "Attach files": "\uE16C",
    Vision: "\uE8B8",
    "Create Image": "\uEB9F",
    "Create Video": "\uE714",
    "Create Audio": "\uED1F",
    "Speech to text": "\uF47F",
    "Text to speech": "\uF8B2",
    "Deep Research": "\uF6FA"
  };

  const DEFAULT_ASSIGNMENT_CONFIG = [
    {
      id: "allModels",
      label: "Model list",
      badge: "\uE169",
      sourceCategoryId: "none",
      featureLabels: ["All"],
      model: "",
      visible: true
    },
    {
      id: "textGeneration",
      label: "Text Generation",
      badge: "\uE8F3",
      sourceCategoryId: "text",
      featureLabels: ["Thinking", "Attach files", "Web research", "Vision"],
      model: "",
      visible: true
    },
    {
      id: "imageCreation",
      label: "Image Creation",
      badge: "\uE91B",
      sourceCategoryId: "image",
      featureLabels: ["Create Image", "Vision"],
      model: "",
      visible: true
    },
    {
      id: "videoCreation",
      label: "Video Creation",
      badge: "\uE20A",
      sourceCategoryId: "image",
      featureLabels: ["Create Video"],
      model: "",
      visible: true
    },
    {
      id: "audioCreation",
      label: "Audio creation",
      badge: "\uE15D",
      sourceCategoryId: "audio",
      featureLabels: ["Create Audio"],
      model: "",
      visible: true
    },
    {
      id: "textToSpeech",
      label: "Text to speech",
      badge: "\uE993",
      sourceCategoryId: "audio",
      featureLabels: ["Text to speech"],
      model: "",
      visible: true
    },
    {
      id: "speechToText",
      label: "Speech to text",
      badge: "\uF47F",
      sourceCategoryId: "audio",
      featureLabels: ["Speech to text"],
      model: "",
      visible: true
    },
    {
      id: "deepResearch",
      label: "Deep Research",
      badge: "\uEB44",
      sourceCategoryId: "deepResearch",
      featureLabels: ["Deep Research"],
      model: "",
      visible: true
    }
  ];

  function getAssignmentModelId(item) {
    if (!item || typeof item !== "object") return "";
    if (item.model != null) return String(item.model);
    if (item.modelId != null) return String(item.modelId);
    return "";
  }

  function normalizeAssignmentCategoryId(categoryId) {
    const normalizedId = String(categoryId == null ? "" : categoryId).trim();

    if (normalizedId.toLowerCase() === "speechtotext") {
      return "speechToText";
    }

    return normalizedId;
  }

  function getAssignmentCategoryId(item) {
    if (!item || typeof item !== "object") return "";

    if (item.id != null && String(item.id).trim()) {
      return normalizeAssignmentCategoryId(item.id);
    }

    if (item.type != null && String(item.type).trim()) {
      return normalizeAssignmentCategoryId(item.type);
    }

    return "";
  }

  function findDefaultAssignmentConfigItem(categoryId) {
    const normalizedCategoryId = normalizeAssignmentCategoryId(categoryId);
    let i;

    if (!normalizedCategoryId) return null;

    for (i = 0; i < DEFAULT_ASSIGNMENT_CONFIG.length; i += 1) {
      if (DEFAULT_ASSIGNMENT_CONFIG[i] && DEFAULT_ASSIGNMENT_CONFIG[i].id === normalizedCategoryId) {
        return DEFAULT_ASSIGNMENT_CONFIG[i];
      }
    }

    return null;
  }

  function cloneAssignmentConfigItem(item) {
    const source = item && typeof item === "object" ? item : {};
    const normalizedId = getAssignmentCategoryId(source);
    const defaultItem = findDefaultAssignmentConfigItem(normalizedId);
    const featureLabelsSource = Array.isArray(source.featureLabels)
      ? source.featureLabels
      : (Array.isArray(source.features)
          ? source.features
          : (defaultItem && Array.isArray(defaultItem.featureLabels) ? defaultItem.featureLabels : []));

    return Object.assign({}, defaultItem || {}, source, {
      id: normalizedId,
      label: String(
        source.label ||
        source.title ||
        (defaultItem ? defaultItem.label : normalizedId)
      ),
      badge: source.badge == null
        ? (defaultItem && defaultItem.badge != null ? String(defaultItem.badge) : "")
        : String(source.badge),
      sourceCategoryId: source.sourceCategoryId == null
        ? (
            source.sourceCategory == null
              ? (
                  defaultItem && defaultItem.sourceCategoryId != null
                    ? String(defaultItem.sourceCategoryId)
                    : normalizedId
                )
              : String(source.sourceCategory)
          )
        : String(source.sourceCategoryId),
      featureLabels: featureLabelsSource.map(function (label) {
        return String(label == null ? "" : label);
      }).filter(Boolean),
      model: getAssignmentModelId(source) || (defaultItem ? getAssignmentModelId(defaultItem) : ""),
      visible: source.visible !== false
    });
  }

  function cloneAssignmentConfig(items) {
    return (Array.isArray(items) ? items : []).map(cloneAssignmentConfigItem).filter(function (item) {
      return !!item.id;
    });
  }

  let runtimeAssignmentConfig = cloneAssignmentConfig(DEFAULT_ASSIGNMENT_CONFIG);
  let runtimeAssignmentConfigById = Object.create(null);
  let runtimeAssignmentOrder = [];

  function rebuildRuntimeAssignmentDerivedData() {
    runtimeAssignmentConfigById = runtimeAssignmentConfig.reduce(function (acc, item) {
      if (!item || !item.id) return acc;
      acc[item.id] = item;
      return acc;
    }, Object.create(null));

    runtimeAssignmentOrder = runtimeAssignmentConfig.map(function (item) {
      return item.id;
    });
  }

  rebuildRuntimeAssignmentDerivedData();

  const DEFAULT_ASSIGNMENT_CONFIG_BY_ID = DEFAULT_ASSIGNMENT_CONFIG.reduce(function (acc, item) {
    if (!item || !item.id) return acc;
    acc[item.id] = item;
    return acc;
  }, Object.create(null));

  const DEFAULT_ASSIGNMENT_ORDER = DEFAULT_ASSIGNMENT_CONFIG.map(function (item) {
    return item.id;
  });

  function completeAssignmentConfig(items) {
    const sourceItems = cloneAssignmentConfig(items);
    const sourceById = sourceItems.reduce(function (acc, item) {
      if (item && item.id) {
        acc[item.id] = item;
      }
      return acc;
    }, Object.create(null));
    const result = DEFAULT_ASSIGNMENT_ORDER.map(function (categoryId) {
      return sourceById[categoryId] || cloneAssignmentConfigItem(DEFAULT_ASSIGNMENT_CONFIG_BY_ID[categoryId]);
    });
    const seen = result.reduce(function (acc, item) {
      if (item && item.id) {
        acc[item.id] = true;
      }
      return acc;
    }, Object.create(null));

    sourceItems.forEach(function (item) {
      if (!item || seen[item.id]) {
        return;
      }

      seen[item.id] = true;
      result.push(item);
    });

    return result;
  }

  function runtimeAssignmentConfigNeedsRefresh(items) {
    const sourceItems = Array.isArray(items) ? items : [];
    const normalizedItems = cloneAssignmentConfig(sourceItems);
    const completedItems = completeAssignmentConfig(sourceItems);

    for (let i = 0; i < sourceItems.length; i += 1) {
      const source = sourceItems[i] && typeof sourceItems[i] === "object" ? sourceItems[i] : {};
      const sourceId = source.id != null && String(source.id).trim()
        ? String(source.id).trim()
        : (source.type != null ? String(source.type).trim() : "");

      if (sourceId && sourceId !== getAssignmentCategoryId(source)) {
        return true;
      }
    }

    if (normalizedItems.length !== completedItems.length) {
      return true;
    }

    for (let i = 0; i < completedItems.length; i += 1) {
      if (!normalizedItems[i] || normalizedItems[i].id !== completedItems[i].id) {
        return true;
      }
    }

    return false;
  }


  function createDefaultAssignmentsMap(items) {
    return (Array.isArray(items) ? items : []).reduce(function (acc, item) {
      if (!item || !item.id) return acc;
      acc[item.id] = item.model == null ? "" : String(item.model);
      return acc;
    }, Object.create(null));
  }

  const state = {
    mounted: false,
    visible: false,
    activeCategoryId: "textGeneration",
    focusModelId: "",
    selectedModelId: "",
    selectedModelName: "",
    categoryLabelOverrides: Object.create(null),
    defaultAssignments: createDefaultAssignmentsMap(runtimeAssignmentConfig),
    categories: runtimeAssignmentConfig.filter(function (item) {
      return item && item.visible !== false;
    }).map(function (item) {
      return {
        id: item.id,
        label: item.label
      };
    }),
    models: [],
    modelsById: Object.create(null),
    elements: {
      root: null,
      dialog: null,
      categories: null,
      defaults: null,
      models: null,
      close: null,
      title: null
    }
  };

  function rebuildRuntimeModelsDerivedData() {
    state.modelsById = (Array.isArray(state.models) ? state.models : []).reduce(function (acc, item) {
      if (!item || !item.id) return acc;
      acc[item.id] = item;
      return acc;
    }, Object.create(null));
  }

  function normalizeModelCategoryIds(categoryId, categoryIds) {
    const seen = Object.create(null);
    const result = [];
    const values = [];

    if (categoryId != null && String(categoryId).trim()) {
      values.push(categoryId);
    }

    if (Array.isArray(categoryIds)) {
      values.push.apply(values, categoryIds);
    }

    values.forEach(function (value) {
      const normalizedValue = normalizeAssignmentCategoryId(value);
      if (!normalizedValue || seen[normalizedValue]) return;
      seen[normalizedValue] = true;
      result.push(normalizedValue);
    });

    return result;
  }

  function normalizeModelsInput(items) {
    const modelsById = Object.create(null);
    const result = [];

    (Array.isArray(items) ? items : []).map(normalizeModelInput).forEach(function (item) {
      if (!item || !item.id) return;

      const existing = modelsById[item.id];
      if (!existing) {
        modelsById[item.id] = item;
        result.push(item);
        return;
      }

      existing.categoryIds = normalizeModelCategoryIds(
        existing.categoryId,
        existing.categoryIds.concat(item.categoryIds)
      );

      if (!existing.categoryId && item.categoryId) {
        existing.categoryId = item.categoryId;
      }

      if (!existing.sourceCategoryId && item.sourceCategoryId) {
        existing.sourceCategoryId = item.sourceCategoryId;
      }
    });

    return result;
  }

  function flattenLegacyModelsByCategory(modelsByCategory) {
    const result = [];

    if (!modelsByCategory || typeof modelsByCategory !== "object") {
      return result;
    }

    Object.keys(modelsByCategory).forEach(function (key) {
      const list = Array.isArray(modelsByCategory[key]) ? modelsByCategory[key] : [];

      list.forEach(function (item) {
        const source = item && typeof item === "object" ? item : {};
        result.push(Object.assign({}, source, {
          categoryId: source.categoryId == null ? key : source.categoryId
        }));
      });
    });

    return result;
  }

  function getRuntimeCategoryConfigMode(mode) {
    return String(mode == null ? "" : mode).trim().toLowerCase() === "replace"
      ? "replace"
      : "merge";
  }

  function normalizeRuntimeConfigurationPayload(payload) {
    const source = payload && typeof payload === "object" ? payload : {};
    const hasModels = Object.prototype.hasOwnProperty.call(source, "models") ||
      Object.prototype.hasOwnProperty.call(source, "modelsByCategory");

    return {
      categories: Array.isArray(source.categories) ? source.categories : [],
      hasModels: hasModels,
      models: Array.isArray(source.models) ? source.models : source.modelsByCategory,
      activeCategoryId: source.activeCategoryId == null ? "" : String(source.activeCategoryId),
      selectedModelId: source.selectedModelId == null ? "" : String(source.selectedModelId),
      defaultAssignments: source.defaultAssignments,
      categoryConfigMode: getRuntimeCategoryConfigMode(source.categoryConfigMode)
    };
  }

  function post(message) {
    try {
      if (window.chrome && window.chrome.webview) {
        window.chrome.webview.postMessage(message);
      }
    } catch (_) {}
  }

  function esc(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function getRuntimeAssignmentConfig() {
    return cloneAssignmentConfig(runtimeAssignmentConfig);
  }

  function getRuntimeAssignmentOrder() {
    return runtimeAssignmentOrder.slice();
  }

  function getVisibleRuntimeAssignmentConfig() {
    return runtimeAssignmentConfig.filter(function (item) {
      return item && item.visible !== false;
    });
  }

  function createCategoryLabelOverrides(categories) {
    return (Array.isArray(categories) ? categories : []).reduce(function (acc, item) {
      const id = getAssignmentCategoryId(item);
      if (!id) return acc;
      if (!runtimeAssignmentConfigById[id]) return acc;

      acc[id] = {
        id: id,
        label: String(item.label || item.title || id)
      };
      return acc;
    }, Object.create(null));
  }

  function rebuildStateCategories() {
    state.categories = getVisibleRuntimeAssignmentConfig().map(function (item) {
      const override = state.categoryLabelOverrides[item.id];
      return {
        id: item.id,
        label: override ? override.label : item.label
      };
    });
  }

  function rebuildDefaultAssignmentsState() {
    const seededAssignments = createDefaultAssignmentsMap(runtimeAssignmentConfig);
    const nextAssignments = Object.create(null);

    getRuntimeAssignmentOrder().forEach(function (key) {
      const legacyKey = key === "speechToText" ? "SpeechToText" : key;

      if (Object.prototype.hasOwnProperty.call(state.defaultAssignments, key)) {
        nextAssignments[key] = state.defaultAssignments[key];
        return;
      }

      if (Object.prototype.hasOwnProperty.call(state.defaultAssignments, legacyKey)) {
        nextAssignments[key] = state.defaultAssignments[legacyKey];
        return;
      }

      nextAssignments[key] = seededAssignments[key];
    });

    state.defaultAssignments = nextAssignments;
  }

  function ensureActiveCategoryStillValid() {
    const activeCategoryExists = !!(
      state.activeCategoryId &&
      isCategoryVisible(state.activeCategoryId) &&
      state.categories.some(function (item) { return item.id === state.activeCategoryId; })
    );

    if (!activeCategoryExists) {
      state.activeCategoryId = state.categories.length ? state.categories[0].id : "";
    }
  }

  function applyDefaultAssignmentsInput(assignments) {
    if (!assignments || typeof assignments !== "object") return;

    if (Array.isArray(assignments)) {
      assignments.forEach(function (item) {
        const categoryId = getAssignmentCategoryId(item);
        if (!categoryId) return;
        if (!getCategoryConfig(categoryId)) return;
        state.defaultAssignments[categoryId] = item.model == null ? "" : String(item.model);
      });
      return;
    }

    getRuntimeAssignmentOrder().forEach(function (key) {
      if (Object.prototype.hasOwnProperty.call(assignments, key)) {
        state.defaultAssignments[key] = assignments[key] == null ? "" : String(assignments[key]);
        return;
      }

      if (key === "speechToText" && Object.prototype.hasOwnProperty.call(assignments, "SpeechToText")) {
        state.defaultAssignments[key] = assignments.SpeechToText == null ? "" : String(assignments.SpeechToText);
      }
    });
  }

  function syncDerivedState(renderNow) {
    rebuildStateCategories();
    rebuildDefaultAssignmentsState();
    ensureActiveCategoryStillValid();
    syncDefaultAssignments();
    ensureSelectedStillValid();
    ensureFocusStillValid();

    if (renderNow !== false) {
      render();
    }
  }

  function getCategoryConfig(categoryId) {
    return runtimeAssignmentConfigById[normalizeAssignmentCategoryId(categoryId)] || null;
  }

  function isCategoryVisible(categoryId) {
    const config = getCategoryConfig(categoryId);
    return !!(config && config.visible !== false);
  }

  function getVisibleCategories(categories) {
    return (Array.isArray(categories) ? categories : []).filter(function (item) {
      return !!item && !!item.id && isCategoryVisible(item.id);
    });
  }

  function getCategoryLabelText(categoryId, fallbackLabel) {
    const normalizedCategoryId = normalizeAssignmentCategoryId(categoryId);
    const override = state.categoryLabelOverrides[normalizedCategoryId];
    const config = getCategoryConfig(normalizedCategoryId);
    const sourceLabel = fallbackLabel != null
      ? String(fallbackLabel)
      : (config && config.label != null ? String(config.label) : normalizedCategoryId);
    const key = CATEGORY_LABEL_I18N_KEY_BY_ID[normalizedCategoryId];

    if (override && override.label != null) {
      return String(override.label);
    }

    return key ? t(key, sourceLabel) : sourceLabel;
  }

  function getFeatureLabelText(label) {
    const normalizedLabel = normalizeFeatureLabel(label);
    const key = FEATURE_LABEL_I18N_KEY_BY_LABEL[normalizedLabel];
    return key ? t(key, normalizedLabel) : normalizedLabel;
  }

  function getNotAssignedText() {
    return t(I18N_NAMESPACE + ".status.notAssigned", "Not assigned");
  }

  function getNoDefaultModelText() {
    return t(I18N_NAMESPACE + ".status.noDefaultModel", "No default model");
  }

  function normalizeFeatureLabel(label) {
    const source = String(label == null ? "" : label).trim();
    const normalized = source.toLowerCase();

    if (!normalized) return "";
    if (normalized === "web research") return "Web research";
    if (normalized === "thinking" || normalized === "reasoning") return "Thinking";
    if (normalized === "attach files" || normalized === "attach file") return "Attach files";
    if (normalized === "vision" || normalized === "image analysis" || normalized === "light image processing") return "Vision";
    if (normalized === "create image" || normalized === "generation") return "Create Image";
    if (normalized === "create video" || normalized === "video") return "Create Video";
    if (normalized === "create audio" || normalized === "conversation" || normalized === "synthesis") return "Create Audio";
    if (normalized === "speech to text" || normalized === "transcription" || normalized === "fast transcription") return "Speech to text";
    if (normalized === "text to speech") return "Text to speech";
    if (normalized === "deep research" || normalized === "deepResearch") return "Deep Research";

    return source;
  }

  function uniqueLabels(labels) {
    const seen = Object.create(null);
    return labels.filter(function (label) {
      if (seen[label]) return false;
      seen[label] = true;
      return true;
    });
  }

  function splitSubtitleLabels(value) {
    const labels = Array.isArray(value)
      ? value
      : String(value == null ? "" : value).split(",");

    return uniqueLabels(labels.map(normalizeFeatureLabel).filter(Boolean));
  }

  function getModelFeatureLabels(model) {
    if (!model || typeof model !== "object") return [];

    if (Array.isArray(model.capabilityLabels) && model.capabilityLabels.length) {
      return splitSubtitleLabels(model.capabilityLabels);
    }

    if (Array.isArray(model.subtitleLabels) && model.subtitleLabels.length) {
      return splitSubtitleLabels(model.subtitleLabels);
    }

    if (typeof model.subtitle === "string" && model.subtitle.trim()) {
      return splitSubtitleLabels(model.subtitle);
    }

    if (Array.isArray(model.features) && model.features.length) {
      return splitSubtitleLabels(model.features);
    }

    return [];
  }

  function normalizeModelInput(item) {
    const source = item && typeof item === "object" ? item : {};
    const categoryId = source.categoryId == null ? "" : String(source.categoryId);
    const normalized = Object.assign({}, source, {
      id: String(source.id || source.modelId || ""),
      name: String(source.name || source.label || source.title || source.id || source.modelId || ""),
      categoryId: categoryId,
      categoryIds: normalizeModelCategoryIds(categoryId, source.categoryIds),
      sourceCategoryId: source.sourceCategoryId == null
        ? (source.sourceCategory == null
            ? (source.categoryId == null ? "" : String(source.categoryId))
            : String(source.sourceCategory))
        : String(source.sourceCategoryId),
      subtitleLabels: getModelFeatureLabels(source),
      isDefault: !!source.isDefault
    });

    delete normalized.badge;
    return normalized;
  }

  function getModelSourceCategoryId(model) {
    if (!model || typeof model !== "object") return "";
    if (model.sourceCategoryId != null) return String(model.sourceCategoryId);
    if (model.sourceCategory != null) return String(model.sourceCategory);
    return String(model.categoryId || "");
  }

  function getModelSubtitleText(model) {
    return getModelFeatureLabels(model).map(getFeatureLabelText).join(", ");
  }

  function getFeatureIcon(label) {
    const normalizedLabel = normalizeFeatureLabel(label);
    return FEATURE_ICON_BY_LABEL[normalizedLabel] || normalizedLabel;
  }

  function hasAllFeatures(featureLabels) {
    return (Array.isArray(featureLabels) ? featureLabels : []).some(function (label) {
      return String(label == null ? "" : label).trim().toLowerCase() === "all";
    });
  }

  function isUnfilteredCategoryConfig(config) {
    return !!(config && String(config.sourceCategoryId || "").toLowerCase() === "none");
  }

  function getAllModels() {
    return state.models.slice();
  }

  function modelBelongsToCategory(model, categoryId) {
    const normalizedCategoryId = normalizeAssignmentCategoryId(categoryId);
    if (!model || !normalizedCategoryId) return false;

    return normalizeModelCategoryIds(model.categoryId, model.categoryIds).indexOf(normalizedCategoryId) !== -1;
  }

  function modelSupportsAnyFeature(model, featureLabels) {
    const modelFeatures = getModelFeatureLabels(model);
    if (!featureLabels || !featureLabels.length || hasAllFeatures(featureLabels)) return true;

    return featureLabels.some(function (featureLabel) {
      return modelFeatures.indexOf(normalizeFeatureLabel(featureLabel)) !== -1;
    });
  }

  function getModels(categoryId) {
    const config = getCategoryConfig(categoryId);
    if (!config) return [];

    if (isUnfilteredCategoryConfig(config)) {
      return getAllModels();
    }

    const normalizedCategoryId = normalizeAssignmentCategoryId(categoryId);
    const directCategoryModels = state.models.filter(function (model) {
      return modelBelongsToCategory(model, normalizedCategoryId);
    });

    if (directCategoryModels.length || !config.sourceCategoryId) {
      return directCategoryModels;
    }

    return state.models.filter(function (model) {
      return !!model &&
        getModelSourceCategoryId(model) === String(config.sourceCategoryId || "") &&
        modelSupportsAnyFeature(model, config.featureLabels);
    });
  }

  function findModel(modelId) {
    const normalizedModelId = String(modelId || "");
    if (!normalizedModelId) return null;
    return state.modelsById[normalizedModelId] || null;
  }

  function getFirstAvailableModel() {
    return state.models.length ? state.models[0] : null;
  }

  function updateSelectedModelName() {
    const model = findModel(state.selectedModelId);
    state.selectedModelName = model ? String(model.name || model.id) : "";
  }

  function findFirstMatchingModel(categoryId) {
    const models = getModels(categoryId);
    let i;

    for (i = 0; i < models.length; i += 1) {
      if (models[i].isDefault) {
        return models[i];
      }
    }

    return models.length ? models[0] : null;
  }

  function syncDefaultAssignments() {
    getRuntimeAssignmentOrder().forEach(function (key) {
      const config = getCategoryConfig(key);
      if (!config) return;

      if (isUnfilteredCategoryConfig(config) && hasAllFeatures(config.featureLabels)) {
        if (state.defaultAssignments[key] == null) {
          state.defaultAssignments[key] = "";
        }
        return;
      }

      const assignedModelId = state.defaultAssignments[key] == null
        ? ""
        : String(state.defaultAssignments[key]);
      const categoryModels = getModels(key);

      if (!assignedModelId) {
        state.defaultAssignments[key] = "";
        return;
      }

      const currentModel = findModel(assignedModelId);

      if (
        currentModel &&
        categoryModels.some(function (item) { return item.id === currentModel.id; })
      ) {
        return;
      }

      const fallback = findFirstMatchingModel(key);
      state.defaultAssignments[key] = fallback ? fallback.id : "";
    });
  }

  function getDefaultAssignmentsForCategory(categoryId) {
    const config = getCategoryConfig(categoryId);
    if (!config) return [];

    if (isUnfilteredCategoryConfig(config) && hasAllFeatures(config.featureLabels)) {
      return [];
    }

    const modelId = state.defaultAssignments[categoryId] || "";
    const model = findModel(modelId);

    return [{
      key: categoryId,
      label: getCategoryLabelText(categoryId, config.label),
      modelId: modelId,
      modelName: model ? String(model.name || model.id) : getNotAssignedText()
    }];
  }

  function getCategoryCardDefaultModelText(categoryId) {
    const assignments = getDefaultAssignmentsForCategory(categoryId);

    if (!assignments.length) {
      return getNoDefaultModelText();
    }

    return assignments[0].modelName || getNotAssignedText();
  }

  function hasMissingDefaultAssignment(categoryId) {
    const config = getCategoryConfig(categoryId);
    const assignedModelId = state.defaultAssignments[categoryId] == null
      ? ""
      : String(state.defaultAssignments[categoryId]);

    if (!config) return false;

    if (isUnfilteredCategoryConfig(config) && hasAllFeatures(config.featureLabels)) {
      return false;
    }

    return !assignedModelId;
  }

  function defaultAssignmentItemHtml(item) {
    const assigned = item.modelId ? " is-assigned" : "";
    return `
      <div class="msp-default-item${assigned}" data-default-key="${esc(item.key)}">
        <div class="msp-default-label">${esc(item.label)}</div>
        <div class="msp-default-value">${esc(item.modelName)}</div>
      </div>
    `;
  }

  function renderDefaultAssignments() {
    const assignments = getDefaultAssignmentsForCategory(state.activeCategoryId);
    const defaultsTitle = t(I18N_NAMESPACE + ".defaults.title", "Default model");
    const emptyText = t(I18N_NAMESPACE + ".defaults.empty", "No default model for this category.");

    if (!assignments.length) {
      return `
        <div class="msp-defaults">
          <div class="msp-defaults-title">${esc(defaultsTitle)}</div>
          <div class="msp-defaults-empty">${esc(emptyText)}</div>
        </div>
      `;
    }

    return `
      <div class="msp-defaults">
        <div class="msp-defaults-title">${esc(defaultsTitle)}</div>
        <div class="msp-defaults-list">${assignments.map(defaultAssignmentItemHtml).join("")}</div>
      </div>
    `;
  }

  function updateAssignmentsFromModel(model) {
    if (!model) return;

    const activeCategoryConfig = getCategoryConfig(state.activeCategoryId);
    if (!activeCategoryConfig) return;

    if (isUnfilteredCategoryConfig(activeCategoryConfig) && hasAllFeatures(activeCategoryConfig.featureLabels)) {
      return;
    }

    if (!getModels(state.activeCategoryId).some(function (item) { return item.id === model.id; })) {
      return;
    }

    state.defaultAssignments[state.activeCategoryId] = model.id;
    syncDefaultAssignments();
  }

  function getDefaultAssignments() {
    return JSON.parse(JSON.stringify(state.defaultAssignments));
  }

  function buildReplaceVersionCategories() {
    const defaultAssignments = getDefaultAssignments();

    return completeAssignmentConfig(getRuntimeAssignmentConfig()).map(function (item) {
      const categoryId = getAssignmentCategoryId(item);
      const assignedModelId = Object.prototype.hasOwnProperty.call(defaultAssignments, categoryId)
        ? defaultAssignments[categoryId]
        : item.model;

      return Object.assign({}, item, {
        model: assignedModelId == null ? "" : String(assignedModelId)
      });
    });
  }

  function buildReplaceVersionPayload() {
    syncDefaultAssignments();

    return {
      event: "model-selector-get-replace-version",
      categoryConfigMode: "replace",
      categories: buildReplaceVersionCategories()
    };
  }

  function emitReplaceVersion() {
    const payload = buildReplaceVersionPayload();
    post(payload);
    return payload;
  }

  function emitFocusChanged() {
    post({
      event: "model-selector-focus-changed",
      categoryId: state.activeCategoryId,
      focusModelId: state.focusModelId,
      selectedModelId: state.selectedModelId,
      selectedModelName: state.selectedModelName,
      defaultAssignments: getDefaultAssignments()
    });
  }

  function emitSelectionChanged() {
    post({
      event: "model-selector-selection-changed",
      categoryId: state.activeCategoryId,
      focusModelId: state.focusModelId,
      selectedModelId: state.selectedModelId,
      selectedModelName: state.selectedModelName,
      defaultAssignments: getDefaultAssignments()
    });

    emitReplaceVersion();
  }

  function setDefaultAssignments(assignments) {
    if (!assignments || typeof assignments !== "object") return;

    applyDefaultAssignmentsInput(assignments);
    syncDefaultAssignments();
    ensureSelectedStillValid();
    ensureFocusStillValid();
    render();
  }

  function setRuntimeAssignmentConfig(items, options) {
    if (!Array.isArray(items)) {
      return getRuntimeAssignmentConfig();
    }

    const normalizedItems = completeAssignmentConfig(items);
    const replace = !!(
      (options && options.replace === true) ||
      getRuntimeCategoryConfigMode(options && options.categoryConfigMode) === "replace"
    );
    const renderNow = !(options && options.renderNow === false);
    const nextConfig = replace ? normalizedItems : runtimeAssignmentConfig.slice();

    if (!replace) {
      normalizedItems.forEach(function (item) {
        const existingIndex = nextConfig.findIndex(function (currentItem) {
          return currentItem.id === item.id;
        });

        if (existingIndex === -1) {
          nextConfig.push(item);
        } else {
          nextConfig[existingIndex] = item;
        }
      });
    }

    runtimeAssignmentConfig = nextConfig;
    rebuildRuntimeAssignmentDerivedData();
    syncDerivedState(renderNow);

    return getRuntimeAssignmentConfig();
  }

  function setCategoryVisibility(categoryId, visible, emit) {
    const normalizedCategoryId = normalizeAssignmentCategoryId(categoryId);
    const config = getCategoryConfig(normalizedCategoryId);

    if (!config) return false;

    const nextVisible = visible !== false;
    if (config.visible === nextVisible) {
      return true;
    }

    runtimeAssignmentConfig = runtimeAssignmentConfig.map(function (item) {
      if (!item || item.id !== normalizedCategoryId) {
        return item;
      }

      return Object.assign({}, item, {
        visible: nextVisible
      });
    });

    rebuildRuntimeAssignmentDerivedData();
    syncDerivedState();

    if (emit !== false) {
      post({
        event: "model-selector-category-visibility-changed",
        categoryId: normalizedCategoryId,
        visible: nextVisible,
        activeCategoryId: state.activeCategoryId,
        focusModelId: state.focusModelId,
        selectedModelId: state.selectedModelId,
        selectedModelName: state.selectedModelName,
        defaultAssignments: getDefaultAssignments()
      });
    }

    return true;
  }

  function ensureStyle() {
    if (document.getElementById(STYLE_ID)) return;

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      body.msp-overlay-open {
        overflow: hidden;
      }

      .msp-overlay {
        position: fixed;
        inset: 0;
        z-index: 7000;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 16px;
        box-sizing: border-box;
      }

      .msp-overlay.is-visible {
        display: flex;
      }

      .msp-backdrop {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.48);
        backdrop-filter: blur(6px);
      }

      .msp-dialog {
        position: relative;
        width: min(980px, calc(100vw - 32px));
        height: 600px;
        min-height: 600px;
        max-height: 600px;
        display: grid;
        grid-template-rows: auto minmax(0, 1fr);
        border: 1px solid var(--input-shell-border);
        border-radius: 20px;
        box-sizing: border-box;
        overflow: hidden;
        background: color-mix(in srgb, var(--bg-main) 88%, transparent);
        box-shadow: 0 28px 90px rgba(0,0,0,0.42);
        backdrop-filter: blur(18px);
        color: var(--text-main);
        color-scheme: dark;
      }

      [data-theme="light"] .msp-dialog {
        color-scheme: light;
      }

      .msp-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        padding: 20px 24px;
        border-bottom: 1px solid var(--input-shell-border);
      }

      .msp-title-wrap {
        display: flex;
        align-items: center;
        gap: 12px;
        min-width: 0;
      }

      .msp-grid-icon {
        width: 34px;
        height: 34px;
        border-radius: 10px;
        position: relative;
        display: inline-block;
        background: var(--input-button-bg);
        color: var(--text-main);
        border: 1px solid var(--input-shell-border);
        font-family: ${MODEL_SELECTOR_ICON_FONT_FAMILY};
        font-size: 26px;
        line-height: 1;
        flex: 0 0 auto;
        padding: 0;
      }

      .msp-grid-icon::before {
        content: "\uE7BE";
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        line-height: 1;
        display: block;
      }

      .msp-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--text-main);
      }

      .msp-close {
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

      .msp-close:hover {
        background: var(--input-button-hover-bg);
        color: var(--input-button-hover-text);
      }

      .msp-body {
        min-height: 0;
        display: grid;
        grid-template-columns: 380px minmax(0, 1fr);
      }

      .msp-sidebar {
        min-height: 0;
        border-right: 1px solid var(--input-shell-border);
        display: grid;
        grid-template-rows: minmax(0, 1fr) auto;
      }

      .msp-categories {
        min-height: 0;
        padding: 14px;
        overflow-y: auto;
        scrollbar-gutter: stable;
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb) transparent;
      }

      .msp-categories-list {
        display: grid;
        gap: 12px;
      }

      .msp-defaults-slot {
        padding: 14px;
        padding-top: 10px;
        border-top: 1px solid color-mix(in srgb, var(--input-shell-border) 82%, transparent);
      }

      .msp-category {
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
        font: inherit;
        font-size: 15px;
        font-weight: 600;
      }

      .msp-category-inner {
        display: flex;
        align-items: center;
        gap: 12px;
        min-width: 0;
        width: 100%;
      }

      .msp-category-badge {
        width: 28px;
        height: 28px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex: 0 0 auto;
        font-family: ${MODEL_SELECTOR_ICON_FONT_FAMILY};
        font-size: 18px;
        line-height: 1;
        color: var(--request-params-nav-muted);
      }

      .msp-category-copy {
        min-width: 0;
        flex: 1 1 auto;
        display: flex;
        flex-direction: column;
        gap: 4px;
      }

      .msp-category-label {
        min-width: 0;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        line-height: 1.2;
      }

      .msp-category-default-model {
        min-width: 0;
        font-size: 12px;
        font-weight: 400;
        line-height: 1.25;
        color: var(--request-params-nav-muted);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .msp-category-state {
        flex: 0 0 auto;
        width: 14px;
        display: inline-flex;
        align-items: center;
        justify-content: flex-end;
        align-self: center;
        margin-left: auto;
      }

      .msp-category-missing-dot {
        width: 10px;
        height: 10px;
        border-radius: 999px;
        background: #b55d4c;
        box-shadow: 0 0 0 2px color-mix(in srgb, var(--bg-main) 82%, transparent);
      }

      .msp-category:hover {
        background: color-mix(in srgb, var(--input-shell-bg-hover) 78%, transparent);
      }

      .msp-category.is-active {
        border-color: color-mix(in srgb, var(--reasoning-accent) 42%, var(--input-shell-border));
        box-shadow: inset 2px 0 0 var(--reasoning-accent);
        background: color-mix(in srgb, var(--reasoning-accent) 7%, var(--input-shell-bg) 93%);
      }

      .msp-defaults {
        display: grid;
        gap: 10px;
      }

      .msp-defaults-title {
        font-size: 12px;
        font-weight: 700;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        color: var(--request-params-nav-muted);
      }

      .msp-defaults-list {
        display: grid;
        gap: 10px;
      }

      .msp-default-item {
        min-width: 0;
        padding: 12px 14px;
        border-radius: 14px;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 78%, transparent);
        background: color-mix(in srgb, var(--input-shell-bg) 48%, transparent);
      }

      .msp-default-item.is-assigned {
        background: color-mix(in srgb, var(--reasoning-accent) 5%, var(--input-shell-bg) 95%);
      }

      .msp-default-label {
        font-size: 12px;
        line-height: 1.2;
        color: var(--request-params-nav-muted);
      }

      .msp-default-value {
        margin-top: 6px;
        font-size: 14px;
        line-height: 1.25;
        font-weight: 700;
        color: var(--text-main);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .msp-defaults-empty {
        padding: 12px 14px;
        border-radius: 14px;
        border: 1px dashed color-mix(in srgb, var(--input-shell-border) 72%, transparent);
        color: var(--request-params-nav-muted);
        font-size: 13px;
        line-height: 1.35;
      }

      .msp-models {
        min-width: 0;
        min-height: 0;
        padding: 20px 18px;
        overflow-y: auto;
        scrollbar-gutter: stable;
        scrollbar-width: thin;
        scrollbar-color: var(--scrollbar-thumb) transparent;
        display: grid;
        gap: 14px;
        align-content: start;
      }

      .msp-card {
        position: relative;
        appearance: none;
        -webkit-appearance: none;
        width: 100%;
        min-height: 86px;
        height: 86px;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 78%, transparent);
        border-radius: 18px;
        background: color-mix(in srgb, var(--input-shell-bg) 58%, transparent);
        color: var(--text-main);
        text-align: left;
        padding: 16px 18px;
        cursor: pointer;
        transition: border-color 120ms ease, box-shadow 120ms ease, background 120ms ease;
      }

      .msp-card:hover {
        background: color-mix(in srgb, var(--input-shell-bg-hover) 74%, transparent);
      }

      .msp-card.is-focused {
        border-color: color-mix(in srgb, var(--reasoning-accent) 42%, var(--input-shell-border));
        box-shadow: inset 0 0 0 1px color-mix(in srgb, var(--reasoning-accent) 20%, transparent);
        background: color-mix(in srgb, var(--reasoning-accent) 6%, var(--input-shell-bg) 94%);
      }

      .msp-card-row {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        min-width: 0;
      }

      .msp-meta {
        min-width: 0;
        flex: 1 1 auto;
        display: flex;
        flex-direction: column;
        justify-content: center;
      }

      .msp-name-line {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
      }

      .msp-name-wrap {
        display: inline-flex;
        align-items: center;
        min-width: 0;
        flex: 1 1 auto;
      }

      .msp-name {
        min-width: 0;
        font-size: 19px;
        font-weight: 700;
        color: var(--text-main);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        line-height: 1.2;
      }

      .msp-right {
        flex: 0 0 auto;
        margin-left: auto;
        display: inline-flex;
        align-items: center;
        justify-content: flex-end;
        gap: 8px;
        min-height: 30px;
        padding-left: 12px;
      }

      .msp-subtitle {
        margin-top: 6px;
        font-size: 13px;
        color: var(--request-params-nav-muted);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        line-height: 1.25;
      }

      .msp-feature {
        min-width: 30px;
        height: 30px;
        padding: 0 8px;
        border-radius: 10px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid color-mix(in srgb, var(--input-shell-border) 82%, transparent);
        background: color-mix(in srgb, var(--input-button-bg) 74%, transparent);
        font-family: ${MODEL_SELECTOR_ICON_FONT_FAMILY};
        font-size: 16px;
        font-weight: 400;
        color: var(--request-params-nav-title-inactive);
        box-sizing: border-box;
        line-height: 1;
      }

      .msp-categories::-webkit-scrollbar,
      .msp-models::-webkit-scrollbar {
        width: 12px;
        height: 12px;
      }

      .msp-categories::-webkit-scrollbar-thumb,
      .msp-models::-webkit-scrollbar-thumb {
        background: var(--scrollbar-thumb);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      .msp-categories::-webkit-scrollbar-thumb:hover,
      .msp-models::-webkit-scrollbar-thumb:hover {
        background: var(--scrollbar-thumb-hover);
        border-radius: 999px;
        border: 3px solid transparent;
        background-clip: padding-box;
      }

      .msp-close:focus,
      .msp-category:focus,
      .msp-card:focus {
        outline: 2px solid color-mix(in srgb, var(--reasoning-accent) 60%, transparent);
        outline-offset: 1px;
      }

      @media (max-width: 820px) {
        .msp-dialog {
          width: calc(100vw - 16px);
          height: calc(100vh - 16px);
          min-height: 0;
          max-height: none;
        }

        .msp-body {
          grid-template-columns: 1fr;
        }

        .msp-sidebar {
          border-right: none;
          border-bottom: 1px solid var(--input-shell-border);
          grid-template-rows: auto auto;
        }

        .msp-categories {
          padding: 12px;
          overflow-x: auto;
          overflow-y: hidden;
        }

        .msp-categories-list {
          display: flex;
          gap: 10px;
        }

        .msp-category {
          width: auto;
          white-space: nowrap;
        }

        .msp-defaults-slot {
          padding: 0 12px 12px;
          border-top: none;
        }

        .msp-defaults {
          min-width: 0;
        }
      }
    `;

    document.head.appendChild(style);
  }

  function categoryButtonHtml(category) {
    const active = category.id === state.activeCategoryId ? " is-active" : "";
    const config = getCategoryConfig(category.id);
    const badge = config && config.badge ? config.badge : "";
    const categoryLabel = getCategoryLabelText(category.id, category.label);
    const defaultModelText = getCategoryCardDefaultModelText(category.id);
    const missingAssignmentDot = hasMissingDefaultAssignment(category.id)
      ? `<span class="msp-category-state"><span class="msp-category-missing-dot" aria-hidden="true"></span></span>`
      : `<span class="msp-category-state"></span>`;

    return `
      <button type="button" class="msp-category${active}" data-role="category" data-category-id="${esc(category.id)}">
        <span class="msp-category-inner">
          <span class="msp-category-badge">${esc(badge)}</span>
          <span class="msp-category-copy">
            <span class="msp-category-label">${esc(categoryLabel)}</span>
            <span class="msp-category-default-model">${esc(defaultModelText)}</span>
          </span>
          ${missingAssignmentDot}
        </span>
      </button>
    `;
  }

  function modelCardHtml(model) {
    const focused = model.id === state.focusModelId ? " is-focused" : "";
    const featureLabels = getModelFeatureLabels(model);
    const subtitleText = getModelSubtitleText(model);
    const features = featureLabels.length
      ? `<div class="msp-right">${featureLabels.map(function (item) { return `<span class="msp-feature" title="${esc(getFeatureLabelText(item))}">${esc(getFeatureIcon(item))}</span>`; }).join("")}</div>`
      : `<div class="msp-right"></div>`;

    return `
      <button type="button" class="msp-card${focused}" data-role="model" data-model-id="${esc(model.id)}">
        <div class="msp-card-row">
          <div class="msp-meta">
            <div class="msp-name-line">
              <div class="msp-name-wrap"><div class="msp-name">${esc(model.name || model.id)}</div></div>
              ${features}
            </div>
            <div class="msp-subtitle">${esc(subtitleText)}</div>
          </div>
        </div>
      </button>
    `;
  }

  function renderStaticText() {
    if (!state.elements.dialog || !state.elements.close || !state.elements.title) return;

    state.elements.dialog.setAttribute(
      "aria-label",
      t(I18N_NAMESPACE + ".panel.aria.dialog", "Select default models")
    );
    state.elements.title.textContent = t(I18N_NAMESPACE + ".panel.title", "Select default models");
    state.elements.close.setAttribute(
      "aria-label",
      t(I18N_NAMESPACE + ".actions.close", "Close")
    );
  }

  function handleI18nChanged() {
    if (!state.mounted) return;
    renderStaticText();
    render();
  }

  function renderCategories() {
    if (!state.elements.categories || !state.elements.defaults) return;
    syncDefaultAssignments();

    state.elements.categories.innerHTML = `
      <div class="msp-categories-list">${state.categories.map(categoryButtonHtml).join("")}</div>
    `;

    state.elements.defaults.innerHTML = renderDefaultAssignments();
  }

  function ensureFocusStillValid() {
    const models = getModels(state.activeCategoryId);
    if (!models.length) {
      state.focusModelId = "";
      return;
    }

    const focusExists = models.some(function (item) {
      return item.id === state.focusModelId;
    });

    if (focusExists) {
      return;
    }

    const selectedInCategory = models.find(function (item) {
      return item.id === state.selectedModelId;
    });
    const defaultModelId = state.defaultAssignments[state.activeCategoryId] || "";
    const defaultInCategory = models.find(function (item) {
      return item.id === defaultModelId;
    });

    state.focusModelId = selectedInCategory
      ? selectedInCategory.id
      : (defaultInCategory ? defaultInCategory.id : "");
  }

  function ensureSelectedStillValid() {
    const currentModel = findModel(state.selectedModelId);

    if (currentModel) {
      updateSelectedModelName();
      return;
    }

    state.selectedModelId = "";
    state.selectedModelName = "";
  }

  function renderModels() {
    if (!state.elements.models) return;
    ensureSelectedStillValid();
    ensureFocusStillValid();
    const models = getModels(state.activeCategoryId);
    state.elements.models.innerHTML = models.map(modelCardHtml).join("");
  }

  function render() {
    renderCategories();
    renderModels();
  }

  function setFocusedModelId(modelId) {
    const normalizedModelId = String(modelId || "");
    const models = getModels(state.activeCategoryId);
    const exists = models.some(function (item) {
      return item.id === normalizedModelId;
    });

    if (!exists) return false;
    state.focusModelId = normalizedModelId;
    return true;
  }

  function focusModel(modelId, emit) {
    if (!setFocusedModelId(modelId)) return null;
    render();
    if (emit === true) {
      emitFocusChanged();
    }
    return findModel(state.focusModelId);
  }

  function commitFocusedModel(emit) {
    if (!state.focusModelId) return null;

    const model = findModel(state.focusModelId);
    if (!model) return null;

    state.selectedModelId = model.id;
    updateSelectedModelName();
    updateAssignmentsFromModel(model);
    render();

    if (emit !== false) {
      emitSelectionChanged();
    }

    return model;
  }

  function closePanel() {
    if (!state.visible || !state.elements.root) return;
    state.visible = false;
    state.elements.root.classList.remove("is-visible");
    document.body.classList.remove(BODY_OPEN_CLASS);
  }

  function showPanel(categoryId) {
    ensureMounted();
    if (categoryId && isCategoryVisible(categoryId)) {
      setActiveCategory(categoryId, false);
    }
    render();
    state.visible = true;
    state.elements.root.classList.add("is-visible");
    document.body.classList.add(BODY_OPEN_CLASS);
  }

  function hidePanel() {
    closePanel();
  }

  function setActiveCategory(categoryId, emit) {
    const exists = state.categories.some(function (item) {
      return item.id === categoryId;
    });
    if (!exists || !isCategoryVisible(categoryId)) return;

    state.activeCategoryId = categoryId;
    ensureSelectedStillValid();
    ensureFocusStillValid();
    render();

    if (emit !== false) {
      post({
        event: "model-selector-category-changed",
        categoryId: state.activeCategoryId,
        focusModelId: state.focusModelId,
        selectedModelId: state.selectedModelId,
        selectedModelName: state.selectedModelName,
        defaultAssignments: getDefaultAssignments()
      });
    }
  }

  function selectModel(modelId, emit) {
    if (!setFocusedModelId(modelId)) return null;
    return commitFocusedModel(emit);
  }

  function setData(categories, models, selectedModelId, activeCategoryId, defaultAssignments) {
    if (Array.isArray(categories) && categories.length) {
      state.categoryLabelOverrides = createCategoryLabelOverrides(categories);
    } else {
      state.categoryLabelOverrides = Object.create(null);
    }

    rebuildStateCategories();

    state.models = Array.isArray(models)
      ? normalizeModelsInput(models)
      : normalizeModelsInput(flattenLegacyModelsByCategory(models));
    rebuildRuntimeModelsDerivedData();

    if (
      activeCategoryId &&
      isCategoryVisible(activeCategoryId) &&
      state.categories.some(function (item) { return item.id === activeCategoryId; })
    ) {
      state.activeCategoryId = activeCategoryId;
    } else {
      ensureActiveCategoryStillValid();
    }

    if (selectedModelId) {
      state.selectedModelId = String(selectedModelId);
    }

    applyDefaultAssignmentsInput(defaultAssignments);
    syncDerivedState();
  }

  function setDataMessagePayload(payload) {
    const source = payload && typeof payload === "object" ? payload : {};
    const models = Array.isArray(source.models) ? source.models : source.modelsByCategory;

    setData(
      Array.isArray(source.categories) ? source.categories : [],
      models,
      source.selectedModelId == null ? "" : String(source.selectedModelId),
      source.activeCategoryId == null ? "" : String(source.activeCategoryId),
      source.defaultAssignments
    );

    return getState();
  }

  function setRuntimeConfiguration(payload) {
    const runtimePayload = normalizeRuntimeConfigurationPayload(payload);
    const refreshReplaceVersion =
      runtimePayload.categoryConfigMode === "replace" &&
      runtimeAssignmentConfigNeedsRefresh(runtimePayload.categories);
    const activeCategoryId = normalizeAssignmentCategoryId(runtimePayload.activeCategoryId);

    state.categoryLabelOverrides = Object.create(null);
    setRuntimeAssignmentConfig(runtimePayload.categories, {
      categoryConfigMode: runtimePayload.categoryConfigMode,
      renderNow: false
    });

    state.defaultAssignments = createDefaultAssignmentsMap(runtimeAssignmentConfig);

    if (runtimePayload.hasModels) {
      state.models = Array.isArray(runtimePayload.models)
        ? normalizeModelsInput(runtimePayload.models)
        : normalizeModelsInput(flattenLegacyModelsByCategory(runtimePayload.models));
      rebuildRuntimeModelsDerivedData();
    }

    if (
      activeCategoryId &&
      isCategoryVisible(activeCategoryId) &&
      state.categories.some(function (item) { return item.id === activeCategoryId; })
    ) {
      state.activeCategoryId = activeCategoryId;
    } else {
      ensureActiveCategoryStillValid();
    }

    state.selectedModelId = runtimePayload.selectedModelId;
    applyDefaultAssignmentsInput(runtimePayload.defaultAssignments);
    syncDerivedState();

    if (refreshReplaceVersion) {
      emitReplaceVersion();
    }

    return getState();
  }

  function handleClick(event) {
    const target = event.target.closest("[data-role]");
    if (!target) return;

    const role = target.getAttribute("data-role");

    if (role === "close" || role === "backdrop") {
      closePanel();
      return;
    }

    if (role === "category") {
      setActiveCategory(target.getAttribute("data-category-id"), true);
      return;
    }

    if (role === "model") {
      event.preventDefault();
      selectModel(target.getAttribute("data-model-id"), true);
      return;
    }
  }

  function handleKeydown(event) {
    if (!state.visible) return;

    if (event.key === "Escape") {
      event.preventDefault();
      closePanel();
      return;
    }

    if (event.key === "Enter") {
      const activeElement = document.activeElement;
      if (activeElement && activeElement.getAttribute("data-role") === "model") {
        event.preventDefault();
        selectModel(activeElement.getAttribute("data-model-id"), true);
      }
    }
  }

  function ensureMounted() {
    if (state.mounted && state.elements.root) return;

    ensureStyle();
    syncDerivedState(false);

    const panelTitle = t(I18N_NAMESPACE + ".panel.title", "Select default models");
    const panelAriaLabel = t(I18N_NAMESPACE + ".panel.aria.dialog", "Select default models");
    const closeLabel = t(I18N_NAMESPACE + ".actions.close", "Close");

    const root = document.createElement("div");
    root.id = ROOT_ID;
    root.className = "msp-overlay";
    root.innerHTML = `
      <div class="msp-backdrop" data-role="backdrop"></div>
      <div class="msp-dialog" role="dialog" aria-modal="true" aria-label="${esc(panelAriaLabel)}">
        <div class="msp-header">
          <div class="msp-title-wrap">
            <div class="msp-grid-icon"></div>
            <div class="msp-title">${esc(panelTitle)}</div>
          </div>
          <button type="button" class="msp-close" data-role="close" aria-label="${esc(closeLabel)}">×</button>
        </div>
        <div class="msp-body">
          <div class="msp-sidebar">
            <div class="msp-categories"></div>
            <div class="msp-defaults-slot"></div>
          </div>
          <div class="msp-models"></div>
        </div>
      </div>
    `;

    document.body.appendChild(root);

    state.elements.root = root;
    state.elements.dialog = root.querySelector(".msp-dialog");
    state.elements.categories = root.querySelector(".msp-categories");
    state.elements.defaults = root.querySelector(".msp-defaults-slot");
    state.elements.models = root.querySelector(".msp-models");
    state.elements.close = root.querySelector(".msp-close");
    state.elements.title = root.querySelector(".msp-title");

    root.addEventListener("click", handleClick);
    document.addEventListener("keydown", handleKeydown);

    state.mounted = true;
    renderStaticText();
    render();
  }

  function getState() {
    return JSON.parse(JSON.stringify({
      visible: state.visible,
      activeCategoryId: state.activeCategoryId,
      focusModelId: state.focusModelId,
      selectedModelId: state.selectedModelId,
      selectedModelName: state.selectedModelName,
      defaultAssignments: state.defaultAssignments,
      categories: state.categories,
      models: state.models
    }));
  }

  if (typeof window.addEventListener === "function") {
    window.addEventListener(I18N_EVENT_NAME, handleI18nChanged);
  }

  window.ModelSelectorPanel = {
    show: showPanel,
    hide: hidePanel,
    toggle: function (categoryId) {
      if (state.visible) {
        hidePanel();
      } else {
        showPanel(categoryId);
      }
    },
    focusModel: focusModel,
    setActiveCategory: setActiveCategory,
    selectModel: selectModel,
    commitSelection: commitFocusedModel,
    setData: setData,
    setDataMessagePayload: setDataMessagePayload,
    setDefaultAssignments: setDefaultAssignments,
    getReplaceVersion: emitReplaceVersion,
    setRuntimeConfiguration: setRuntimeConfiguration,
    setRuntimeAssignmentConfig: setRuntimeAssignmentConfig,
    setCategoryVisibility: setCategoryVisibility,
    getDefaultAssignments: getDefaultAssignments,
    getState: getState
  };

  if (window.chrome && window.chrome.webview && typeof window.chrome.webview.addEventListener === "function") {
    window.chrome.webview.addEventListener("message", function (event) {
      const msg = event && event.data;
      if (!msg || typeof msg !== "object") return;

      if (msg.type === "model-selector-show") {
        showPanel(msg.categoryId);
        return;
      }

      if (msg.type === "model-selector-hide") {
        hidePanel();
        return;
      }

      if (msg.type === "model-selector-select") {
        if (msg.categoryId) {
          setActiveCategory(msg.categoryId, false);
        }
        if (msg.modelId) {
          focusModel(msg.modelId, false);
        }
        if (msg.commit === true) {
          commitFocusedModel(false);
        }
        return;
      }

      if (msg.type === "models-category-visibility") {
        setCategoryVisibility(msg.id, msg.visible, false);
        emitReplaceVersion();
        return;
      }

      if (msg.type === "model-selector-set-data") {
        setDataMessagePayload(msg);
        return;
      }

      if (msg.type === "model-selector-set-runtime-config") {
        setRuntimeConfiguration(msg);
      }

      if (msg.type === "model-selector-get-replace-version") {
        emitReplaceVersion();
      }
    });
  }
})();
