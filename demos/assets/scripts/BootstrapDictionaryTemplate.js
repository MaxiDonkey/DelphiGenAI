(function () {
  const DEFAULT_LANG = "en-US";
  const EVENT_NAME = "app:i18n:changed";

  let currentDictionary = { lang: DEFAULT_LANG };
  let currentLang = DEFAULT_LANG;

  function isObject(value) {
    return value != null && typeof value === "object" && !Array.isArray(value);
  }

  function clone(value) {
    if (typeof structuredClone === "function") {
      return structuredClone(value);
    }
    return JSON.parse(JSON.stringify(value));
  }

  function deepGet(obj, path) {
    if (!isObject(obj) || !path) return undefined;

    const parts = String(path).split(".");
    let current = obj;

    for (let i = 0; i < parts.length; i += 1) {
      const key = parts[i];
      if (current == null || !Object.prototype.hasOwnProperty.call(current, key)) {
        return undefined;
      }
      current = current[key];
    }

    return current;
  }

  function formatText(text, vars) {
    const source = String(text == null ? "" : text);

    return source.replace(/\{([a-zA-Z0-9_]+)\}/g, function (_, token) {
      if (vars && Object.prototype.hasOwnProperty.call(vars, token)) {
        const value = vars[token];
        return value == null ? "" : String(value);
      }
      return "{" + token + "}";
    });
  }

  function normalizeLang(value) {
    const raw = String(value == null ? "" : value).trim();
    return raw || DEFAULT_LANG;
  }

  function notifyLanguageChanged() {
    try {
      window.dispatchEvent(new CustomEvent(EVENT_NAME, {
        detail: {
          lang: currentLang,
          dictionary: clone(currentDictionary)
        }
      }));
    } catch (_) {}
  }

  function setDictionary(dictionary) {
    if (!isObject(dictionary)) return false;

    const nextDictionary = clone(dictionary);
    const nextLang = normalizeLang(nextDictionary.lang);

    nextDictionary.lang = nextLang;
    currentDictionary = nextDictionary;
    currentLang = nextLang;

    notifyLanguageChanged();
    return true;
  }

  function t(path, fallback, vars) {
    const value = deepGet(currentDictionary, path);
    const resolved = value == null ? fallback : value;
    return formatText(resolved == null ? "" : resolved, vars);
  }

  function has(path) {
    return deepGet(currentDictionary, path) != null;
  }

  function getDictionary() {
    return clone(currentDictionary);
  }

  function getLang() {
    return currentLang;
  }

  function applyMessage(msg) {
    if (!isObject(msg)) return false;
    if (msg.type !== "set-language") return false;
    if (!isObject(msg.dictionary)) return false;

    return setDictionary(msg.dictionary);
  }

  window.AppI18n = {
    setDictionary,
    getDictionary,
    getLang,
    has,
    t,
    eventName: EVENT_NAME
  };

  if (
    window.chrome &&
    window.chrome.webview &&
    typeof window.chrome.webview.addEventListener === "function"
  ) {
    window.chrome.webview.addEventListener("message", function (event) {
      const msg = event && event.data;
      applyMessage(msg);
    });
  }
})();
