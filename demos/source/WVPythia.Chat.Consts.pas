unit WVPythia.Chat.Consts;

interface

const
  TEXT_GENERATION_INDEX = 1;
  IMAGE_GENERATION_INDEX = 2;
  VIDEO_CREATION_INDEX = 3;
  AUDIO_CREATION_INDEX = 4;
  TEXT_TO_SPEECH_INDEX = 5;
  SPEECH_TO_TEXT_INDEX = 6;
  DEEP_RESEARCH_INDEX = 7;

  PROP_EVENT = 'event';
  PROP_ID = 'id';
  PROP_PAIRID = 'pairId';
  PROP_KIND = 'kind';
  PROP_CONTENT = 'content';
  PROP_VALUE = 'value';
  PROP_KEY = 'key';
  PROP_GOAL = 'goal';
  PROP_TAG = 'tag';
  PROP_INDEX = 'index';
  PROP_LANG = 'lang';
  PROP_TEXT = 'text';
  PROP_TARGET = 'target';
  PROP_DIRECTION = 'direction';
  PROP_FILENAME = 'fileName';
  PROP_STATE = 'state';
  PROP_FILES = 'files';
  PROP_FULLPATH = 'fullPath';
  PROP_PROMPT_FRAGMENTS = 'promptFragments';
  PROP_PLACEHOLDER = 'placeholder';
  PROP_LAST_INDEX = 'lastId';
  PROP_INTERNAL = 'internal';
  PROP_TYPE = 'type';
  PROP_DATA = 'data';
  PROP_ERROR = 'error';
  PROP_OUTPUT_STRUCTURED_ENABLED = 'requestParams.structuredOutput.enabled';
  PROP_OUTPUT_STRUCTURED_SCHEMA = 'requestParams.structuredOutput.jsonSchema';

  DOCUMENTS_EXTENSION =
    'Documents (*.txt;*.md;*.pdf)|*.txt;*.md;*.pdf|' +
    'Text & Markdown (*.txt;*.md)|*.txt;*.md|' +
    'PDF Files (*.pdf)|*.pdf|' +
    'Office Documents (*.doc;*.docx;*.xls;*.xlsx;*.ppt;*.pptx)|*.doc;*.docx;*.xls;*.xlsx;*.ppt;*.pptx|' +
    'Code Files (*.c;*.cpp;*.cs;*.css;*.go;*.html;*.java;*.js;*.json;*.pas;*.php;*.py;*.rb;*.sh;*.tex;*.ts)|*.c;*.cpp;*.cs;*.css;*.go;*.html;*.java;*.js;*.json;*.pas;*.php;*.py;*.rb;*.sh;*.tex;*.ts|' +
    'Audio (*.wav;*.mp3)|*.wav;*.mp3|' +
    'Video (*.mp4)|*.mp4|' +
    'Compressed Archives (*.zip;*.tar;*.tgz;*.gz)|*.zip;*.tar;*.tgz;*.gz|' +
    'All (*.*)|*.*';

  GRAPHIC_EXTENSION =
    'Graphic Files (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg';

  AUDIO_EXTENSION =
    'Audio Files(*.wav;*.mp3)|*.wav;*.mp3|';

  (*
     --------------------
          JS scripts
     --------------------
  *)

  CLEAR_TEMPLATE =
    '(function(){' +
    '  if (window.DisplayTemplate && typeof window.DisplayTemplate.cancelStreams === ''function'') {' +
    '    window.DisplayTemplate.cancelStreams();' +
    '  }' +
    '  if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.cancel === ''function'') {' +
    '    window.ResponseRenderBatch.cancel();' +
    '  }' +
    '  var el1 = document.getElementById(''ResponseContent'');' +
    '  if (el1) el1.replaceChildren();' +
    '  var el2 = document.getElementById(''ResponseContentBatch'');' +
    '  if (el2) el2.replaceChildren();' +
    '  window.dispatchEvent(new Event(''resize''));' +
    '})();';

  COLLAPSE_REASONING_TEMPLATE =
    'window.DisplayTemplate.collapseReasoning();';

  EXPAND_REASONING_TEMPLATE =
    'window.DisplayTemplate.expandReasoning();';

  HIDE_REASONING_TEMPLATE =
    '(() => { const el = document.getElementById("loadingBubble"); if (el) el.remove(); })();';

  DISPLAY_TEMPLATE =
    'window.display(%s, %s, %s, %s);';

  DISPLAY_BLOCK_TEMPLATE =
    'window.DisplayTemplate.displayBlock(%s, %s, %s);';

  DISPLAY_BLOCK_STREAM_TEMPLATE =
    'window.DisplayTemplate.displayBlockStream(%s, %s, %s, %s);';

  DISPLAY_BLOCKS_TEMPLATE =
    'window.DisplayTemplate.displayBlocks(%s, %s);';

  DISPLAY_BLOCK_KIND_ASSISTANT = 'assistant';
  DISPLAY_BLOCK_KIND_REASONING = 'reasoning';
  DISPLAY_BLOCK_KIND_STATUS = 'status';
  DISPLAY_BLOCK_KIND_TOOL_STATUS = 'toolStatus';
  DISPLAY_BLOCK_KIND_TOOL_OUTPUT = 'toolOutput';
  DISPLAY_BLOCK_KIND_TOOL_ERROR = 'toolError';
  DISPLAY_BLOCK_KIND_SOURCE_STATUS = 'sourceStatus';
  DISPLAY_BLOCK_KIND_SOURCE_LIST = 'sourceList';
  DISPLAY_BLOCK_KIND_SOURCE_DOCUMENT = 'sourceDocument';
  DISPLAY_BLOCK_KIND_CITATION_LIST = 'citationList';
  DISPLAY_BLOCK_KIND_ARTIFACT_LIST = 'artifactList';

  DEFER_AFTER_DISPLAY_STREAM =
    '(function(){' +
    'const run=function(){%s};' +
    'if(window.DisplayTemplate&&typeof window.DisplayTemplate.runAfterStreams==="function"){' +
    'window.DisplayTemplate.runAfterStreams(run, %s);return;}' +
    'run();' +
    '})();';

  DISPLAY_STREAM_TEMPLATE =
    'window.displayStream(%s, %s, %s, %s);';

  INPUT_BUBBLE_RESET_TEMPLATE =
    'window.resetInputBubble();';

  INPUT_BUBBLE_INSERT_TEXT_TEMPLATE =
    'window.insertInputBubbleText(%s);';

  SCROLL_AFTER_END_SCRIPT_TEMPLATE =
    '(function(){' +
    '  const scroller = document.scrollingElement || document.documentElement || document.body;' +
    '  var spacer = document.getElementById("edge-spacer");' +
    '  if (!spacer) {' +
    '    spacer = document.createElement("div");' +
    '    spacer.id = "edge-spacer";' +
    '    document.body.appendChild(spacer);' +
    '  }' +
    '  spacer.style.height = "%dpx";' +
    '  setTimeout(function(){' +
    '    %s' +
    '  },0);' +
    '})();';

  SCROLL_SMOOTH_TEMPLATE =
    'scroller.scrollTo({ top: scroller.scrollHeight, behavior: "smooth" });';

  SCROLL_TEMPLATE =
    'scroller.scrollTop = scroller.scrollHeight;';

  SCROLL_BUTTONS_VISIBLE =
    'window.setScrollButtonsVisible(%s);';

  SCROLL_TO_END_SMOOTH_TEMPLATE =
      '(function(){' +
      '  const el = document.getElementById("edge-spacer");' +
      '  if (el) el.style.height = "0px";' +
      '  requestAnimationFrame(function(){' +
      '    requestAnimationFrame(function(){' +
      '      window.scrollTo({' +
      '        top: Math.max(document.body.scrollHeight, document.documentElement.scrollHeight),' +
      '        left: 0,' +
      '        behavior: "smooth"' +
      '      });' +
      '    });' +
      '  });' +
      '})();';

  SCROLL_TO_END_TEMPLATE =
      '(function(){' +
      '  const el = document.getElementById("edge-spacer");' +
      '  if (el) el.style.height = "0px";' +
      '  requestAnimationFrame(function(){' +
      '    requestAnimationFrame(function(){' +
      '      window.scrollTo(0, document.body.scrollHeight);' +
      '      document.documentElement.scrollTop = document.documentElement.scrollHeight;' +
      '      document.body.scrollTop = document.body.scrollHeight;' +
      '    });' +
      '  });' +
      '})();';

  SCROLL_TO_TOP_SMOOTH_TEMPLATE =
      '(function(){' +
      '  const el = document.getElementById("edge-spacer");' +
      '  if (el) el.style.height = "0px";' +
      '  requestAnimationFrame(function(){' +
      '    requestAnimationFrame(function(){' +
      '      window.scrollTo({ top: 0, left: 0, behavior: "smooth" });' +
      '    });' +
      '  });' +
      '})();';

  SCROLL_TO_TOP_TEMPLATE =
  '(function(){' +
  '  const el = document.getElementById("edge-spacer");' +
  '  if (el) el.style.height = "0px";' +
  '  requestAnimationFrame(function(){' +
  '    requestAnimationFrame(function(){' +
  '      window.scrollTo({ top: 0, left: 0, behavior: "auto" });' +
  '      document.documentElement.scrollTop = 0;' +
  '      document.body.scrollTop = 0;' +
  '    });' +
  '  });' +
  '})();';

  TOGGLE_REASONING_TEMPLATE =
    'window.DisplayTemplate.toggleReasoning();';

  SET_THEME_TEMPLATE =
    'document.documentElement.dataset.theme="%s"; localStorage.setItem("chat-theme","%s");';

  STOP_AUDIO_TEMPLATE =
    'window.StopAudio();';

  STOP_VIDEO_TEMPLATE =
    'window.StopVideo();';

  LOGO_ANIMATION_SHOW =
    'ActivityShow({ placement: "top-left", size: 24, gap: 12, offsetX: 50, offsetY: 0 });';

  LOGO_ANIMATION_HIDE =
    'if (window.ActivityHide) ActivityHide();';

  DELETE_BLOCK_TEMPLATE =
    '(() => {' +
    '  const root = document.getElementById("ResponseContent");' +
    '  if (!root || !root.lastChild) return;' +
    '  const targetPairId = "%s";' +
    '  let firstBlock = null;' +
    '  for (const node of root.children) {' +
    '    if (' +
    '      node.nodeType === 1 &&' +
    '      node.dataset &&' +
    '      (node.dataset.pairId || "") === targetPairId' +
    '    ) {' +
    '      firstBlock = node;' +
    '      break;' +
    '    }' +
    '  }' +
    '  if (!firstBlock) return;' +
    '  const range = document.createRange();' +
    '  range.setStartBefore(firstBlock);' +
    '  range.setEndAfter(root.lastChild);' +
    '  range.deleteContents();' +
    '})();';

  SPACER_TEMPLATE =
    '(function() {' +
    '  const height = %d;' +
    '  let mount;' +
    '  if (window.ResponseRenderBatch && typeof window.ResponseRenderBatch.getMount === ''function'') {' +
    '    mount = window.ResponseRenderBatch.getMount();' +
    '  } else {' +
    '    mount = document.getElementById(''ResponseContent'');' +
    '    if (!mount) {' +
    '      mount = document.createElement(''div'');' +
    '      mount.id = ''ResponseContent'';' +
    '      document.body.appendChild(mount);' +
    '    }' +
    '  }' +
    '  const panel = document.createElement(''div'');' +
    '  panel.id = ''gap_panel_'' + Date.now() + ''_'' + Math.random().toString(36).slice(2, 9);' +
    '  panel.setAttribute(''aria-hidden'', ''true'');' +
    '  panel.style.display = ''block'';' +
    '  panel.style.width = ''100%%'';' +
    '  panel.style.margin = ''0'';' +
    '  panel.style.padding = ''0'';' +
    '  panel.style.border = ''0'';' +
    '  panel.style.pointerEvents = ''none'';' +
    '  panel.style.background = getComputedStyle(mount).backgroundColor || getComputedStyle(document.body).backgroundColor || ''transparent'';' +
    '  panel.style.height = Math.max(0, Number(height) || 0) + ''px'';' +
    '  panel.style.minHeight = panel.style.height;' +
    '  mount.appendChild(panel);' +
    '})();';

  OPEN_INPUT_MAIN_MENU_TEMPLATE =
    'window.openInputMainMenu()';

  CLOSE_INPUT_MAIN_MENU_TEMPLATE =
    'window.closeInputMainMenu();';

  SEND_INPUT_STATE_TEMPLATE =
    'window.sendInputState()';

  INTEGRATION_AGENT_SELECTION =
    'window.onIntegrationAgentSelected(%s,%s)';

  INTEGRATION_FUNCTION_SELECTION =
    'window.onIntegrationFunctionSelected(%s,%s)';

  INTEGRATION_MCP_SELECTION =
    'window.onIntegrationMcpSelected(%s,%s)';

  INTEGRATION_SKILL_SELECTION =
    'window.onIntegrationSkillSelected(%s,%s)';

  CUSTOM_SELECTION =
    'window.onCustomSelected(%s,%s)';

  INPUT_PARTIAL_RESET =
    'window.partialResetInputBubble();';

  FILES_SELECTION_TEMPLATE =
    'window.onFileSelected(%s,%s)';

  PASTE_FRAGMENT_SELECTION_TEMPLATE =
    'window.onPasteFragmentSelected(%s,%d,%d)';

  RENDER_BATCH_BEGIN_UPDATE =
    'window.ResponseRenderBatch.begin();';

  RENDER_BATCH_END_UPDATE =
    'window.ResponseRenderBatch.commit({ scrollMode: "preserve" });';

  SETTING_PANEL_GET_VALUES =
    'window.RequestParams.sendValues();';

  MODEL_SELECTOR_PANEL_SHOW =
    'window.ModelSelectorPanel.show();';

  MODEL_SELECTOR_PANEL_HIDE =
    'window.ModelSelectorPanel.hide();';

  (*
     --------------------
           API FILE
     --------------------
  *)

  FILE_UPLOAD_STATUS_TEMPLATE =
    'window.setFileUploadStatus(%s,%s,%s,%s)';

  SEND_BUTTON_AVAILABILITY_TEMPLATE =
    'window.setSendButtonAvailability(%s)';


  FILE_UPLOAD_STATUS_UPLOADING = '"uploading"';
  FILE_UPLOAD_STATUS_INDEXING  = '"indexing"';
  FILE_UPLOAD_STATUS_READY     = '"ready"';
  FILE_UPLOAD_STATUS_FAILED    = '"failed"';

  PROP_PATH = 'path';

  (*
     --------------------
           JSON
     --------------------
  *)

  AUDIO_RECORDING_START =
    '{"type":"audio-recording-start"}';

  AUDIO_RECORDING_STOP =
    '{"type":"audio-recording-stop"}';

  AUDIO_RECORDING_SWITCH =
    '{"type":"audio-recording-switch"}';

  AUDIO_BUTTON_ENABLE =
    '{"type": "setInputButtonsVisibility","audio":%s}';

  FUNCTION_BUTTON_ENABLE =
    '{"type": "setInputButtonsVisibility","function":%s}';

  SENDBTN_STATE_TEMPLATE =
    '{"type":"sendbtn-state","state":"%s"}';

  SET_INPUT_BUBBLE_FOCUS =
    '{"type":"input-bubble-setfocus"}';

  FILES_DRAWER_REMOVE_ITEM =
    '{"type":"files-drawer-remove-item","id":"%s"}';

  FILES_DRAWER_RENAME_ITEM =
    '{"type": "files-drawer-rename-item","id": "%s","Title":"%s"}';

  FILES_DRAWER_SET_TOPITEM =
    '{"type":"files-drawer-set-topitem","id":"%s"}';

  FILES_DRAWER_ITEM_UNSELECT =
    '{ "type": "files-drawer-item-unselect" }';

  FILES_DRAWER_ADD_ITEM =
    '{"type":"files-drawer-add-item","id":"%s","text":"%s"}';

  SET_INPUT_TEXT =
    '{"type":"setInputText", "text":"%s"}';

  SET_INPUT_WELCOME =
    '{"type":"setInputWelcome", "text":"%s"}';

  FOLDER_SELECTED_TEMPLATE =
    '{"type":"folder-selected","folder_path":"%s"}';

  FOLDER_STATE_TEMPLATE =
    '{"type":"folder-state","state":%s}';

  ERROR_DISPLAY_TEMPLATE =
    '{"type":"erreur","text":"%s"}';

  WARNING_DISPLAY_TEMPLATE =
    '{"type":"warning","text":"%s"}';

  SUCCESS_DISPLAY_TEMPLATE =
    '{"type":"success","text":"%s"}';

  APP_SETTINGS_TEMPLATE =
    '{' +
      '"type": "request-params-main-values", ' +
      '"look": "%s", ' +
      '"language": [%s],' +
      '"selected":"%s",' +
      '"scroll": %s' +
    '}';

  DIALOG_CONFIRMATION_REQUEST =
    '{'+
      '"type":"dialog-confirmation-request",'+
      '"text":"%s",'+
      '"goal":"%s",' +
      '"tag":"%s",'+
      '"index":"%d"'+
    '}';

  SETTINGS_PANEL_SET_LANGUAGE =
    '{"type":"set-language","dictionary":%s,"name":"%s"}';

  SETTINGS_PANEL_GET_VALUES =
    '{"type": "request-params-get-values"}';

  SETTINGS_PANEL_HIDE =
    '{"type":"request-params-hide"}';

  SETTINGS_PANEL_SHOW =
    '{"type":"request-params-show","page":%d}';

  MODEL_CATEGORY_VISIBILITY =
    '{"type":"models-category-visibility","id":"%s","visible":%s}';

  MODEL_GET_REPLACE_VERSION =
    '{"type": "model-selector-get-replace-version"}';

  CARD_SELECTION_DIALOG_SHOW =
    '{"type":"card-selection-dialog-show","dialog":"%s"}';

  CARD_SELECTION_DIALOG_HIDE =
    '{"type":"card-selection-dialog-hide"}';

  CARD_SETTINGS_VISIBILITY =
    '{"type":"cards-settings-visibity","value":%s}';

  CARD_CHIP_AGENT_SHOW =
    'window.setIntegrationAgents([{id:"%s",name:"%s"}]);';

  FILE_DRAWER_OPEN =
    '{"type": "files-drawer-open"}';

  FILE_DRAWER_CLOSE =
    '{"type": "files-drawer-close"}';

  FILE_DRAWER_CLEAR =
    '{"type": "files-drawer-clear"}';

  INPUT_STRING =
    '{' +
      '"type":"input-string",' +
      '"message":"%s",' +
      '"key":"%s",' +
      '"value":"%s",' +
      '"default":"%s",' +
      '"hidden_value":%s' +
    '}';

  JSON_MODELS_DEFAULT =
    '{' + sLineBreak +
    '  "type": "model-selector-set-data",' + sLineBreak +
    '  "models": [' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "ID1",' + sLineBreak +
    '      "label": "One of text generation model   <- to define",' + sLineBreak +
    '      "capabilityLabels": ["Thinking", "Vision"],' + sLineBreak +
    '      "categoryId": "textGeneration"' + sLineBreak +
    '    },' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "ID2",' + sLineBreak +
    '      "label": "One of image creation model   <- to define",' + sLineBreak +
    '      "capabilityLabels": ["Create Image"],' + sLineBreak +
    '      "categoryId": "imageCreation"' + sLineBreak +
    '    },' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "ID3",' + sLineBreak +
    '      "label": "One of video creation model   <- to define",' + sLineBreak +
    '      "capabilityLabels": ["Create Video"],' + sLineBreak +
    '      "categoryId": "videoCreation"' + sLineBreak +
    '    },' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "ID4",' + sLineBreak +
    '      "label": "One of audio creation model   <- to define",' + sLineBreak +
    '      "capabilityLabels": ["Create Audio", "Text to speech"],' + sLineBreak +
    '      "categoryId": "audioCreation"' + sLineBreak +
    '    },' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "ID5",' + sLineBreak +
    '      "label": "One of text to speech model   <- to define",' + sLineBreak +
    '      "capabilityLabels": ["Text to speech"],' + sLineBreak +
    '      "categoryId": "textToSpeech"' + sLineBreak +
    '    },' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "ID7",' + sLineBreak +
    '      "label": "One of speech to text model   <- to define",' + sLineBreak +
    '      "capabilityLabels": ["Speech to text"],' + sLineBreak +
    '      "categoryId": "speechToText"' + sLineBreak +
    '    },' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "ID8",' + sLineBreak +
    '      "label": "One of deep research model   <- to define",' + sLineBreak +
    '      "capabilityLabels": ["Deep Research"],' + sLineBreak +
    '      "categoryId": "deepResearch"' + sLineBreak +
    '    }' + sLineBreak +
    '  ],' + sLineBreak +
    '  "activeCategoryId": "allModels",' + sLineBreak +
    '  "selectedModelId": ""' + sLineBreak +
    '}';

  JSON_CARD_DEFAULT_FMT =
    '{' + sLineBreak +
    '  "type": "card-selection-dialog-set-data",' + sLineBreak +
    '  "dialog": "%s",' + sLineBreak +
    '  "cards": [' + sLineBreak +
    '    {' + sLineBreak +
    '      "id": "DE5FE16B-F37F-47E2-A22F-55E45AE09E10",' + sLineBreak +
    '      "name": "Define a name",' + sLineBreak +
    '      "commentaire": "Edit the -%s.json file to define %s available list",' + sLineBreak +
    '      "badge": "\uE2AD",' + sLineBreak +
    '      "content": ""' + sLineBreak +
    '    }' + sLineBreak +
    '  ],' + sLineBreak +
    '  "selectedId": "DE5FE16B-F37F-47E2-A22F-55E45AE09E10"' + sLineBreak +
    '}';

  JSON_CAPABILITIES_DEFAULT =
    '{' + sLineBreak +
    '    "type": "setCapabilities",' + sLineBreak +
    '    "endpoint": true,' + sLineBreak +
    '    "endpointChatCompletion": true,' + sLineBreak +
    '    "endpointChatResponse": true,' + sLineBreak +
    '    "endpointMessage": true,' + sLineBreak +
    '    "endpointGenerateContent": true,' + sLineBreak +
    '    "endpointInteractions": true,' + sLineBreak +
    '    "endpointConversation": true,' + sLineBreak +
    '    "webSearch": true,' + sLineBreak +
    '    "thinking": true,' + sLineBreak +
    '    "files": true,' + sLineBreak +
    '    "knowledgeSearch": true,' + sLineBreak +
    '    "vision": true,' + sLineBreak +
    '    "deepResearch": true,' + sLineBreak +
    '    "integration": true,' + sLineBreak +
    '    "integrationFunction": true,' + sLineBreak +
    '    "integrationMcp": true,' + sLineBreak +
    '    "integrationSkills": true,' + sLineBreak +
    '    "integrationAgents": true,' + sLineBreak +
    '    "thinkingLow": true,' + sLineBreak +
    '    "thinkingMedium": true,' + sLineBreak +
    '    "thinkingHigh": true,' + sLineBreak +
    '    "media": true,' + sLineBreak +
    '    "mediaCreateImage": true,' + sLineBreak +
    '    "mediaCreateVideo": true,' + sLineBreak +
    '    "mediaCreateAudio": true,' + sLineBreak +
    '    "mediaSpeechToText": true,' + sLineBreak +
    '    "mediaTextToSpeech": true,' + sLineBreak +
    '    "custom": true,' + sLineBreak +
    '    "systemPrompt": true,' + sLineBreak +
    '    "model": true,' + sLineBreak +
    '    "project": true' + sLineBreak +
    '}';

  JSON_PROJECTS_DEFAULT =
    '[]';

  JSON_CUSTOM_TEMPLATE_JS_DEFAULT =
    '{' + sLineBreak +
    '    "template_filename": [' + sLineBreak +
    '    ]' + sLineBreak +
    '}';

implementation

end.
