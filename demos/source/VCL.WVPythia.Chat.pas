unit VCL.WVPythia.Chat;

interface

uses
  Winapi.Windows, Winapi.ActiveX,

  System.SysUtils, System.classes, System.UITypes, System.IOUtils, System.JSON,

  Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.Dialogs, Vcl.FileCtrl, Vcl.Graphics, Vcl.Themes,

  WVPythia.Template.Manager, WVPythia.Capabilities.Manager, WVPythia.Strings.Escape,
  WVPythia.Chat.DecisionDlg, WVPythia.Chat.EventManager, WVPythia.Chat.Interfaces, WVPythia.Chat.Consts,
  WVPythia.TextFile.Helper, WVPythia.Types, WVPythia.Types.EnumWire, WVPythia.Adapter,
  WVPythia.ChatSession.Controller, WVPythia.Strs, WVPythia.Command.Registry,
  WVPythia.Command.Plugin, WVPythia.ApiKey.Service.Intf, WVPythia.Command.Plugin.ApiKey,
  WVPythia.ApiKey.Service, WVPythia.Command.Parser,

  uWVLoader, uWVBrowser, uWVWindowParent, uWVTypeLibrary,

  VCL.WVPythia.OpenDialog, WVPythia.Clipboard.VCL,
  Windows.Process.Execution, Windows.ApiKey.Management;

const
  BASE_URL = 'https://app.local';

  CAllowedOrigins: array[0..1] of string = (
    'https://app.local',
    'https://cdn.jsdelivr.net'
  );

type
  EVCLPythiaException = class(Exception);

  TVCLOpenDialog = class(TInterfacedObject, IOpenDialog)
  private
    {--- TOpenDialogHelper is responsible for the lifetime of FOpenDialog }
    FOpenDialog: TOpenDialog;
  public
    constructor Create;
    function Execute(const Filter: string; const index: Integer; out FileName: string): Boolean;
    function ExecuteFolder(out FolderPath: string): Boolean;
  end;

  TCastHelp = record
    class function BoolToStr(const Value: Boolean): string; static;
  end;

  TVCLPythiaAbstract = class(TComponent)
  protected
    function IsBrowserReady: Boolean; virtual; abstract;
    function IsJSScriptInjected: Boolean; virtual; abstract;
    function ExecuteScript(const Script: string): Boolean; virtual; abstract;
    function PostWebMessageAsJson(const Script: string): Boolean; overload; virtual; abstract;
    function PostWebMessageAsJson(const Script: string; const ExpectedType: string): Boolean; overload; virtual; abstract;
    procedure UpdateEnabledButtons; virtual; abstract;
    procedure Initialize; virtual; abstract;
    procedure BridgeInitialize; virtual; abstract;
  public
    function DisplayError(const Value: string): Boolean; virtual; abstract;
    function DisplayWarning(const Value: string): Boolean; virtual; abstract;
    function BubbleInputWelcome(const Value: string): Boolean; virtual; abstract;
  end;

  TVCLPythiaPath = class(TVCLPythiaAbstract)
  strict private
    const
      MEDIA_FOLDER = 'media';
      SUPPORT_JSON_FOLDER = 'support';
      LANGUAGE_FOLDER = 'lang';
  protected
    function ParamsMainValuesFileNameExists: Boolean;
    function GetAssetsFolder: string;
    function GetLanguageFolder: string;
    function GetMediaFolder: string;

    function GetAppRawName: string;
    function GetAppSubFolder: string;
    function GetRawName: string;
    function GetSupportRawName: string;

    function GetAppJsonSupportFolder: string;
    function GetParamsConfigFileName: string;
    function GetParamsMainValuesFileName: string;
    function GetChatSessionsFileName: string;
    function GetModelCategoriesFileName: string;
    function GetModelListFileName: string;

    function GetMcpCardsFileName: string;
    function GetFunctionCardsFileName: string;
    function GetSkillCardsFileName: string;
    function GetAgentCardsFileName: string;
    function GetCustomCardsFileName: string;

    function GetCapabilitiesFileName: string;
    function GetProjectsFileName: string;
    function GetExchangeDebugFileName: string;
    function GetAPIKeyNamesFileName: string;
    function GetCustomJSFileName: string;
  end;

  TVCLPythiaCore = class(TVCLPythiaPath)
  strict private
    const
      MIN_WIDTH = 450;
      MIN_HEIGHT = 350;
      TIMER_INTERVAL = 300;
      LOCAL_HOST = 'app.local';
  private
    FBrowser: TWVBrowser;
    FWindowParent: TWVWindowParent;
    FTimer: TTimer;
    FDefaultLangage: Boolean;
    function GetLocalHost: string;
    function GetBrowser: TWVBrowser;
  protected
    FOnBrowserCreated: TProc;
    procedure CreateMappingFolder;
    function EnsureBrowserInitialized: Boolean;
    procedure DoAfterCreated(Sender: TObject); virtual;
    procedure DoOnTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    function Update: Boolean;
    property Browser: TWVBrowser read GetBrowser;
    property LocalHost: string read GetLocalHost;
    property WindowParent: TWVWindowParent read FWindowParent;
  end;

  TVCLPythiaClipboard = class(TVCLPythiaCore)
  private
    FClipboard: IClipboardReader;
    function GetClipboard: IClipboardReader;
    procedure SetClipboard(const Value: IClipboardReader);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaCapabilitiesManager = class(TVCLPythiaClipboard)
  private
    FCapabilities: ICapabilities;
    procedure SaveDefaultCapabilitiesFile;
  protected
    function UpdateCapabilities: Boolean;
    function CapabilitiesInitialization: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    function ResetCapabilities: Boolean;
    property Capabilities: ICapabilities read FCapabilities write FCapabilities;
  end;

  TVCLPythiaProjectsManager = class(TVCLPythiaCapabilitiesManager)
  private
    function NormalizeProjectsJson(const JsonAsString: string;
      out NormalizedJson: string): Boolean;
    procedure SaveDefaultProjectsFile;
  protected
    function ProjectsInitialization: Boolean;
    function ProjectsStateUpdate(const JsonAsString: string): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaJSTemplatesManager = class(TVCLPythiaProjectsManager)
  private
    FTemplateProvider: ITemplateProvider;
  protected
    property TemplateProvider: ITemplateProvider read FTemplateProvider write FTemplateProvider;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaThemeManager = class(TVCLPythiaJSTemplatesManager)
  strict private
    const
      DARK_BACKGROUND_COLOR = $00272727;
      LIGHT_BACKGROUND_COLOR = TColorRec.White;
  private
    FTheme: string;
  protected
    FOnThemeChanged: TProc;
    procedure SetInternalTheme(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    property Theme: string read FTheme write SetInternalTheme;
  end;

  TVCLPythiaScrollManager = class(TVCLPythiaThemeManager)
  strict private
    const
      CLEAR_RATE = 1;
      BIAS_DEFAULT = 300;
  private
    FScrollButtonsVisible: Boolean;
    function GetHeightAfter(Bias: Integer = BIAS_DEFAULT): Integer;
    function GetScrollButtonsVisible: Boolean; virtual;
    procedure SetScrollButtonsVisible(const Value: Boolean); virtual;
  protected
    procedure ScrollButtonsVisible(Value: Boolean);
    procedure ScrollToAfterEnd(SizeAfter: Integer; Smooth: Boolean = True); overload; virtual;
    procedure ScrollToAfterEnd(Smooth: Boolean = True); overload; virtual;
  public
    procedure ScrollToTop(Smooth: Boolean = True); virtual;
    procedure ScrollToEnd(Smooth: Boolean = False); virtual;
    property LocalScrollButtonsVisible: Boolean read GetScrollButtonsVisible write SetScrollButtonsVisible;
  end;

  TVCLPythiaLanguageManager = class(TVCLPythiaScrollManager)
  private
    FLocalLanguage: string;
    function GetLocalLanguage: string;
    procedure SetLocalLanguage(const Value: string);
    function GetDictionaryFileName(const Value: string; out Dictionary: string): Boolean;
    function LoadDictionaryContent(const FileName: string): string;
  protected
    FOnTranslationsLoaded: TProc;
    function GetNormalizedFileNames: string;
    function SettingsPanelForceLanguageSelection(const JsonAsString: string): Boolean; virtual; abstract;
    property LocalLanguage: string read GetLocalLanguage write SetLocalLanguage;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetLanguage(const Value: string); virtual;
  end;

  TVCLPythiaAppSettings = class(TVCLPythiaLanguageManager)
  protected
    procedure SettingsPanelSaveAppSettings; virtual;
    procedure SaveDefaultValues;
  end;

  TVCLPythiaDialogManager = class(TVCLPythiaAppSettings)
  private
    FOpenDialog: IOpenDialog;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaRunProcessManager = class(TVCLPythiaDialogManager)
  private
    FRunProcess: IProcessExecute;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaChatContentManager = class(TVCLPythiaRunProcessManager)
  private
    FPromptCount: Integer;
    function GetPromptCount: Integer; virtual;
    procedure SetPromptCount(const Value: Integer); virtual;
  protected
    FOnRenderChatContent: TFunc<Boolean>;
    property PromptCount: Integer read GetPromptCount write SetPromptCount;
  end;

  TVCLPythiaCustomJSTemplate = class(TVCLPythiaChatContentManager)
  private
    FCustomJSTemplate: TArray<string>;
    procedure TryToLoadCustomTemplates;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaBridgeManager = class(TVCLPythiaCustomJSTemplate)
  strict private
    const
      MSG_READY = '"ready"';
      MSG_INPUT_READY = '"input-ready"';
      MSG_INJECTION_ENDED = '"injection-ended"';
      MSG_ABOUT_BLANK = 'about:blank';
  private
    FInitialNavigation: Boolean;
    FBrowserInitialized: Boolean;
    FEventManager: IBrowserEventManager;
    FJSScriptInjected: Boolean;

    function IsAllowedNavigation(const Url: string): Boolean;
    procedure DoInjectionsWhenReady;

  protected
    function IsBrowserReady: Boolean; override;
    function IsJSScriptInjected: Boolean; override;
    function ExecuteScript(const Script: string): Boolean; override;
    function PostWebMessageAsJson(const Script: string): Boolean; overload; override;
    function PostWebMessageAsJson(const Script: string; const ExpectedType: string): Boolean; overload; override;

    procedure LockNavigation;
    procedure BridgeInitialize; override;

    procedure DoNavigationCompleted(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2NavigationCompletedEventArgs);

    procedure DoWebMessageReceived(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2WebMessageReceivedEventArgs);

    procedure DoNavigationStarting(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2NavigationStartingEventArgs);

    procedure DoPermissionRequested(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2PermissionRequestedEventArgs);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaAdapter = class(TVCLPythiaBridgeManager)
  protected
    FServiceAdapter: IChatManagedItemDialogService;
    procedure SetServiceAdapter(const Value: IChatManagedItemDialogService);
  end;

  TVCLPythiaInputValue = class(TVCLPythiaAdapter)
  public
    function BrowserInput(
      const AMessage: string;
      const AKey: string;
      const AValue: string;
      const ADefault: string;
      const Hidden: Boolean = False): Boolean; overload;

    function BrowserInput(
      const AMessage: string;
      const AKey: string;
      const ADefault: string): Boolean; overload;

    function BrowserInput(
      const AMessage: string;
      const AKey: string;
      const Hidden: Boolean = False): Boolean; overload;
  end;

  TVCLPythiaAPIKeyManager = class(TVCLPythiaInputValue)
  private
    FApiKeySecretStore: ISecretStore;
    FApiKeyNamesAsJsonString: string;
    function GetApiKeyNamesAsJsonString: string;
    procedure SetApiKeyNamesAsJsonString(const Value: string);
  protected
    FOnApiKeyChanged: TProc<string>;
    function GetApiKeySecretStore: ISecretStore;
    procedure SetApiKeySecretStore(const Value: ISecretStore);
    procedure ApiKeyValuesUpdate(const KeyName: string);
    property ApiKeyNamesAsJsonString: string read GetApiKeyNamesAsJsonString write SetApiKeyNamesAsJsonString;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaLockServices = class(TVCLPythiaAPIKeyManager)
  private
    FLocked: Boolean;
    FEscape: Boolean;
    function LogoAnimationShow: Boolean;
    function LogoAnimationHide: Boolean;
    function GetLocked: Boolean; virtual;
    procedure SetLocked(const Value: Boolean); virtual;
    function GetEscape: Boolean; virtual;
    procedure SetEscape(const Value: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    property Locked: Boolean read GetLocked write SetLocked;
    property Escape: Boolean read GetEscape write SetEscape;
  end;

  TVCLPythiaCustomPanels = class(TVCLPythiaLockServices)
  private
    FCustomPanels: TCustomPanels;
  protected
    function GetCustomPanels: TCustomPanels;
    procedure SetCustomPanels(const Value: TCustomPanels);
  end;

  TVCLPythiaSettingsPanel = class(TVCLPythiaCustomPanels)
  private
    FSettingsPanelPage: Integer;
    function GetSettingsPanelPage: Integer; virtual; abstract;
    procedure SetSettingsPanelPage(const Value: Integer); virtual; abstract;
  protected
    function SettingsPanelShowPage(const Page: Integer): Boolean; virtual;
    function SettingsPanelHide: Boolean; virtual;
    function SettingsPanelRequestCurrentSettingsState: Boolean; virtual;
    function SettingsPanelInitializeFullState(const JsonAsString: string): Boolean; virtual;
    function SettingsPanelUpdatePropertiesByFullPath(const JsonAsString: string): Boolean; virtual;
    function SettingsPanelUpdateApplicationSettings(const JsonAsString: string): Boolean;
    function SettingsPanelForceLanguageSelection(const JsonAsString: string): Boolean; override;
    function SettingsPanelGetValues: Boolean; virtual;
    property SettingsPanelPage: Integer read GetSettingsPanelPage write SetSettingsPanelPage;
  end;

  TVCLPythiaModelsSelector = class(TVCLPythiaSettingsPanel)
  private
    function ModelSetDefaultContentIntoFile: Boolean;
    function ModelInitialize: Boolean;
  protected
    function ModelListFileCheck: Boolean;
    function ModelsSelectorShow: Boolean;
    function ModelsSelectorHide: Boolean;
    function ModelsSelectorCategoryVisible(const Category: string; const Visible: Boolean): Boolean;
    function ModelsSelectorSetModelList: Boolean;
    function ModelsSelectorCategoryAdd: Boolean;
    function ModelsSelectorGetReplaceVersion: Boolean;
  end;

  TVCLPythiaChatSessionManager = class(TVCLPythiaModelsSelector)
  strict private
    const
      PAGE_SIZE_VALUE = 25;
  private
    FPersistentChat: IPersistentChat;
    FChatListPage: TChatListPage;
    FPageSize: Integer;
    FLastPageId: string;
    FFirstPage: Boolean;
    function SettingsPanelLoadPage: Boolean; virtual;
    function InternalDisplaySession: Boolean; virtual; abstract;
    function GetPersistentChat: IPersistentChat;
    procedure SetPersistentChat(const Value: IPersistentChat);
  protected
    FOnChatSessionAutoRename: TProc<string, string>;
    FOnAfterSessionReloaded: TProc<string>;
    FOnNewChatRequested: TProc;
    function GetOnChatSessionAutoRename: TProc<string, string>;
    procedure SetOnChatSessionAutoRename(const Value: TProc<string, string>);

    function GetOnAfterSessionReloaded: TProc<string>;
    procedure SetOnAfterSessionReloaded(const Value: TProc<string>);

    function GetOnNewChatRequested: TProc;
    procedure SetOnNewChatRequested(const Value: TProc);

    function ChatSessionDrawerOpen: Boolean;
    function ChatSessionDrawerClose: Boolean;
    function ChatSessionDrawerClear: Boolean;

    function ChatSessionAdd(const ID: string; const Text: string): Boolean;
    function ChatSessionRemove(const Id: string): Boolean;
    function ChatSessionRename(const Id: string; const ATitle: string): Boolean;
    function ChatSessionToTop(const Id: string): Boolean;
    function ChatSessionUnselect: Boolean;
    procedure ChatSessionAutoRename(const ID: string; const Content: string);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SessionAutoRename(const Id: string; const ATitle: string);
    property PersistentChat: IPersistentChat read GetPersistentChat write SetPersistentChat;
  end;

  TVCLPythiaCardSelector = class(TVCLPythiaChatSessionManager)
  private
    procedure JSONCardContentDefaultCreate(const AType: string);
    function FilenameRetrieve(const AType: string): string;
    procedure CardsContentCreateDefaultFiles;
  protected
    function CardSelectorShow(const Dialog: string): Boolean;
    function CardSelectorHide: Boolean;
    function CardSelectorSetData(const JsonString: string): Boolean;
    function CardSettingsButtonVisible(const Value: Boolean): Boolean;
    function TryGetCardFileContent(const AType: string; ParamProc: TFunc<string, Boolean>): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TVCLPythiaInputBubble = class(TVCLPythiaCardSelector)
  private
    FEnabledButtons: TEnabledButtons;
  protected
    function GetEnabledButtons: TEnabledButtons;
    procedure SetEnabledButtons(const Value: TEnabledButtons);
    function BubbleInputMenuClose: Boolean;
    function BubbleInputPartialReset: Boolean;
    function BubbleInputAudioButtonVisible(const Value: Boolean = True): Boolean;
    function BubbleInputFunctionButtonVisible(const Value: Boolean = True): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    function BubbleInputMenuOpen: Boolean;
    function BubbleInputClear: Boolean;
    function BubbleInputSetText(const Value: string): Boolean;
    function BubbleInputInsertText(const Value: string): Boolean;
    function BubbleInputWelcome(const Value: string): Boolean; override;
  end;

  TVCLPythiaReasoningComponent = class(TVCLPythiaInputBubble)
  private
    FReasoningVisible: Boolean;
  protected
    function ReasoningCollapse: Boolean;
    function ReasoningExpand: Boolean;
    function ReasoningToggle: Boolean;
    function ReasoningHide: Boolean;
    function ReasoningShow: Boolean;
  end;

  TVCLPythiaCommandLine = class(TVCLPythiaReasoningComponent)
  private
    FCommandLine: ICommandRegistry;
    FApiKeyService: IApiKeyService;
    function GetCommandLine: ICommandRegistry;
    procedure SetCommandLine(const Value: ICommandRegistry);
    procedure CommandLineInitialize;
    function GetApiKeyService: IApiKeyService;
    procedure SetApiKeyService(const Value: IApiKeyService);
  protected
    FOnRegisterCommandPlugins: TProc;
    property ApiKeyService: IApiKeyService read GetApiKeyService write SetApiKeyService;
    procedure DispatchCommand(const ACommandResult: TCommandResult);
  public
    constructor Create(AOwner: TComponent); override;
    function TryHandleAsCommand(const PromptText: string): Boolean;
    property CommandLine: ICommandRegistry read GetCommandLine write SetCommandLine;
  end;

  TVCLPythiaFileUploadManager = class(TVCLPythiaCommandLine)
  private
    FFileUploadService: IFileUploadService;
  protected
    function GetFileUploadService: IFileUploadService;
    procedure SetFileUploadService(const Value: IFileUploadService);
    function SetFileUploadStatus(
      const APath: string;
      const AStatus: string;
      const AFileId: string = '';
      const AErrorMessage: string = ''): Boolean;
    function SetSendButtonAvailability(const AEnabled: Boolean): Boolean;
  end;

  TVCLPythiaKnowledgeIndexingManager = class(TVCLPythiaFileUploadManager)
  private
    FKnowledgeIndexingService: IKnowledgeIndexingService;
    FAudioTranscriptionService: IAudioTranscriptionService;
  protected
    function GetKnowledgeIndexingService: IKnowledgeIndexingService;
    procedure SetKnowledgeIndexingService(const Value: IKnowledgeIndexingService);
    function GetAudioTranscriptionService: IAudioTranscriptionService;
    procedure SetAudioTranscriptionService(const Value: IAudioTranscriptionService);
    function RecomputeSendButtonAvailability: Boolean;
  end;

  TInterfacedVCLPythia = class(TVCLPythiaKnowledgeIndexingManager, IPythiaBrowser)
  strict private
    const
      CLEARANCE = 400;
      CHAT_FOOTER_FONT_SIZE = 14;
      CHAT_FOOTER_COLOR = '"#6B7280"';
  strict private
    function GetSettingsPanelPage: Integer; override;
    procedure SetSettingsPanelPage(const Value: Integer); override;
  private
    FStreamContent: string;
    FStreamThink: string;
    FFirstChunkContent: Boolean;
    FWebDecisionDlgBroker: TWebDecisionDlgBroker;

    function ClearBrowserDisplay: Boolean;
    procedure ClearCurrentChatSession;
    procedure ClearInternalBrowserData;
    procedure ClearMediaPlayer;
    function DeferAfterDisplayStream(const Script: string; const PairId: Integer): string;

    function ExecuteTemplate(
      const Template: string;
      const Value: TArray<string>;
      const isPromptSource: Boolean;
      const Align: string = ''): Boolean; overload;

    function RenderMedia(
      const Template: string;
      const Value: TArray<string>;
      const isPromptSource: Boolean;
      const Align: string = '';
      Scroll: Boolean = True): Boolean;

    procedure StopAudio;
    procedure StopVideo;
    function SetChatFooter(const Text: string): Boolean;
    function InternalDisplaySession: Boolean; override;
  protected
    FOnInitialized: TProc;
    procedure UpdateEnabledButtons; override;

    procedure SetTheme(const Value: string);
    function Confirmation(const Value, Goal, Tag: string; const Index: Integer): Boolean;
    function DisplayChatSession: Boolean;
    procedure StopMedia;
    procedure AudioRecordingStart;
    procedure AudioRecordingStop;
    procedure AudioRecordingSwitch;
    function UpdateFileDrawer: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function WebDecisionDlg(
      const ARequest: TWebDecisionDlgRequest;
      const ATimeoutMS: Cardinal = WEB_DECISION_DLG_INFINITE): TWebDecisionDlgResult;
    function ResolveWebDecisionDlgResponse(const AJson: string): Boolean;

    procedure Clear;
    procedure SetFocus;
    procedure BringHostToFront;
    procedure BeginUpdate;
    procedure EndUpdate;

    function DisplayError(const Value: string): Boolean; override;
    function DisplayWarning(const Value: string): Boolean; override;
    function DisplayFooter(const Value: string): Boolean;
    function DisplaySuccess(const Value: string): Boolean;
    function DisplaySpacer(const AHeight: Integer = 190): Boolean;

    function Prompt(const AText: string): Boolean;

    function PromptMedia(Kind: TDisplayKind;
      const Value: TArray<string>;
      Scroll: Boolean = True): Boolean; overload;

    function Display(const AText: string;
      Scroll: Boolean = True): Boolean; overload;

    function Display(const AText: string;
      const AThink: string;
      Scroll: Boolean = True): Boolean; overload;

    function DisplayStream(const AText: string;
      Scroll: Boolean = True): Boolean; overload;

    function DisplayStream(const AText: string;
      const AThink: string;
      Scroll: Boolean = True): Boolean; overload;

    function DisplayBlock(
      const Kind: string;
      const PayloadJson: string;
      Scroll: Boolean = True): Boolean;

    function DisplayBlockStream(
      const Kind: string;
      const Delta: string;
      const PayloadJson: string = '';
      Scroll: Boolean = True): Boolean;

    function DisplayBlocks(
      const BlocksJson: string;
      Scroll: Boolean = True): Boolean;

    function DisplayAssistant(
      const AText: string;
      Scroll: Boolean = True): Boolean;

    function DisplayAssistantStream(
      const ADelta: string;
      Scroll: Boolean = True): Boolean;

    function DisplayReasoning(
      const AText: string;
      Scroll: Boolean = True): Boolean;

    function DisplayReasoningStream(
      const ADelta: string;
      Scroll: Boolean = True): Boolean;

    function DisplayStatus(
      const AText: string;
      Scroll: Boolean = True): Boolean;

    function DisplayToolStatus(
      const AText: string;
      Scroll: Boolean = True): Boolean;

    function DisplayToolOutput(
      const ATitle: string;
      const AText: string;
      Scroll: Boolean = True): Boolean;

    function DisplayToolOutputStart(
      const ATitle: string;
      Scroll: Boolean = True): Boolean;

    function DisplayToolOutputStream(
      const ADelta: string;
      Scroll: Boolean = True): Boolean;

    function DisplayToolError(
      const ATitle: string;
      const AText: string;
      Scroll: Boolean = True): Boolean;

    function DisplayToolErrorStart(
      const ATitle: string;
      Scroll: Boolean = True): Boolean;

    function DisplayToolErrorStream(
      const ADelta: string;
      Scroll: Boolean = True): Boolean;

    function DisplaySourceStatus(
      const AText: string;
      Scroll: Boolean = True): Boolean;

    function DisplaySourceList(
      const ATitle: string;
      const SourcesJson: string;
      Scroll: Boolean = True): Boolean;

    function DisplaySourceDocument(
      const ATitle: string;
      const AUrl: string;
      const AText: string = '';
      Scroll: Boolean = True): Boolean;

    function DisplayCitationList(
      const CitationsJson: string;
      Scroll: Boolean = True): Boolean;

    function DisplayArtifactList(
      const ATitle: string;
      const ArtifactsJson: string;
      Scroll: Boolean = True): Boolean;

    function DisplayMedia(Kind: TDisplayKind;
      const Value: TArray<string>;
      Scroll: Boolean = True): Boolean; overload;

    procedure Hide;
    procedure Show;
  end;

  TVCLPythia = class(TInterfacedVCLPythia)
  protected
    procedure Initialize; override;
  public
    constructor Create(AOwner: TComponent); override;

    class function Version: string;

    /// <summary>Specifies which built-in panels are replaced by host-provided custom panels.</summary>
    property CustomPanels: TCustomPanels read GetCustomPanels write SetCustomPanels;

    /// <summary>Specifies whether the input-bubble function menu and microphone buttons are visible.</summary>
    property EnabledButtons: TEnabledButtons read GetEnabledButtons write SetEnabledButtons;

    /// <summary>Adapter for selections, copies, custom events, and linking to one or more LLMs</summary>
    property ServiceAdapter: IChatManagedItemDialogService read FServiceAdapter write SetServiceAdapter;

    /// <summary>Occurs after the native browser instance has been created.</summary>
    property OnBrowserCreated: TProc read FOnBrowserCreated write FOnBrowserCreated;

    /// <summary>Occurs when the browser theme has changed and should be synchronized by the host.</summary>
    property OnThemeChanged: TProc read FOnThemeChanged write FOnThemeChanged;

    /// <summary>Occurs after a language dictionary has been loaded and translations have been applied.</summary>
    property OnTranslationsLoaded: TProc read FOnTranslationsLoaded write FOnTranslationsLoaded;

    /// <summary>Allows the host to override the default chat content rendering process.</summary>
    property OnRenderChatContent: TFunc<Boolean> read FOnRenderChatContent write FOnRenderChatContent;

    /// <summary>Occurs when a named API key has been changed.</summary>
    property OnApiKeyChanged: TProc<string> read FOnApiKeyChanged write FOnApiKeyChanged;

    /// <summary>Occurs when a chat session requests automatic title generation.</summary>
    property OnChatSessionAutoRename: TProc<string, string> read GetOnChatSessionAutoRename write SetOnChatSessionAutoRename;

    /// <summary>Occurs after a chat session has been re-displayed, carrying the active chat ID.
    /// Use it to restore any session-derived UI state (e.g. managed-agent chip).</summary>
    property OnAfterSessionReloaded: TProc<string> read GetOnAfterSessionReloaded write SetOnAfterSessionReloaded;

    /// <summary>Occurs when the user requests a new blank chat from the browser UI.</summary>
    property OnNewChatRequested: TProc read GetOnNewChatRequested write SetOnNewChatRequested;

    /// <summary>Allows the host to register custom command plugins during browser initialization.</summary>
    property OnRegisterCommandPlugins: TProc read FOnRegisterCommandPlugins write FOnRegisterCommandPlugins;

    /// <summary>
    /// Gets or sets the secret store used to read, write, and delete API key values.
    /// Assign a custom <see cref="ISecretStore"/> before calling Update to replace the default backend.
    /// </summary>
    property ApiKeySecretStore: ISecretStore read GetApiKeySecretStore write SetApiKeySecretStore;

    /// <summary>
    /// Optional service invoked when files are selected through the open dialog.
    /// When assigned, every file accepted by <c>ShouldHandle</c> is also routed
    /// through <c>SubmitForUpload</c> so the host can transfer it asynchronously
    /// to a remote storage (Files API and similar) and reference it later by an
    /// opaque file id. Leave unset to keep the default inline pipeline where
    /// selected files are sent as document blocks.
    /// </summary>
    property FileUploadService: IFileUploadService read GetFileUploadService write SetFileUploadService;

    /// <summary>
    /// Optional service invoked when a knowledge file is selected through the
    /// open dialog. When assigned, the file is routed through
    /// <c>SubmitForIndexing</c> so the host can vectorize it asynchronously
    /// (vector store, semantic retrieval corpus, libraries...) and reference
    /// the resulting index at submit time through <c>TryGetIndexRef</c>.
    /// Distinct from <c>FileUploadService</c>: the indexing pipeline involves
    /// poll-until-ready semantics, hence its own service contract.
    /// </summary>
    property KnowledgeIndexingService: IKnowledgeIndexingService
      read GetKnowledgeIndexingService write SetKnowledgeIndexingService;

    /// <summary>
    /// Optional service invoked when a microphone capture file is ready
    /// (produced browser-side through the recorder). When assigned, the
    /// audio file is routed through <c>SubmitForTranscription</c> so the host
    /// can perform speech-to-text asynchronously; Pythia then places the
    /// recognized text into the input bubble. Producing the capture stays
    /// vendor-agnostic, only the transcription step is delegated.
    /// </summary>
    property AudioTranscriptionService: IAudioTranscriptionService
      read GetAudioTranscriptionService write SetAudioTranscriptionService;

    /// <summary>
    /// Occurs after the browser, bridge, settings, model list, capabilities,
    /// translations and input surface have completed initialization.
    /// </summary>
    property OnInitialized: TProc read FOnInitialized write FOnInitialized;
  end;

implementation

uses
  Pythia.Webview2, WVPythia.JSON.SafeReader, WVPythia.WebView2.DropFiles;

{$REGION 'Dev notes'}

(*
    Developer Note VCL.WVPythia.Chat

    This unit hosts the VCL / WebView2 browser stack used by the chat UI.

    -------------------------------------------------------------------------
    Platform scope
    -------------------------------------------------------------------------

    This is a Windows-only VCL unit. The VCL framework itself is
    Windows-only, and the unit further depends on Microsoft WebView2
    (TWVBrowser, TWVWindowParent), which has no Android, iOS, macOS or
    Linux counterpart. There is no portability path from this unit to
    mobile. The FMX sibling unit (FMX.WVPythia.Chat) is kept architecturally
    aligned for maintenance reasons, but it too remains Windows-only for
    the same WebView2 reason switching to a mobile target would require
    a completely different rendering engine and a re-implementation of the
    whole browser stack against it.

    -------------------------------------------------------------------------
    Design philosophy   layered inheritance
    -------------------------------------------------------------------------

    The IPythiaBrowser contract (WVPythia.Chat.Interfaces) aggregates a large
    surface: rendering, session persistence, input handling, theme,
    language, models, cards, command line, API keys... Rather than
    assembling a monolithic class by composition, this unit implements
    IPythiaBrowser through a deep linear inheritance chain. Each class in the
    chain is responsible for exactly ONE concern and exposes protected
    primitives to the classes derived from it.

    Why inheritance rather than composition:

        IPythiaBrowser is a wide, closed contract. Every capability it exposes
        must be reachable from the same 'Self' at the leaf class. A chain
        of parent classes satisfies this naturally, with zero forwarding
        code.

        Each layer can introduce its own fields, its own constructor, and
        its own abstract hooks (virtual; abstract;) that upper layers are
        required to wire in. The contract between layers is enforced by
        the compiler.

        Lifetime is trivial: one TComponent owns everything; constructors
        compose top-down; destruction is automatic.

    The chain is an intentional structural choice, not legacy. Its
    linearity is what keeps the IPythiaBrowser fa ade implementable as a single
    class (TInterfacedVCLPythia) without turning it into a mega-class of
    unrelated responsibilities.

    -------------------------------------------------------------------------
    Layered architecture (top-level responsibilities)
    -------------------------------------------------------------------------

    Bootstrap layer
        TVCLPythiaAbstract:
          Declares every abstract primitive the chain relies on: browser
          readiness checks, script execution, web-message posting,
          Initialize, BridgeInitialize, UpdateEnabledButtons, and the
          three public display hooks (error, warning, welcome).
        TVCLPythiaPath:
          Resolves all filesystem locations used by the stack: assets,
          media, language, JSON support folder, chat sessions, capability,
          exchange-debug and API key name files.
        TVCLPythiaCore:
          Owns the WebView2 plumbing (TWVBrowser, TWVWindowParent), the
          startup timer, the virtual host mapping and the initial
          navigation. EnsureBrowserInitialized is the single path through
          which the browser comes up; both DoOnTimer and Update delegate
          to it.

    Data / configuration layers
        TVCLPythiaCapabilitiesManager:
          Synchronizes backend/frontend capabilities (ICapabilities).
        TVCLPythiaJSTemplatesManager:
          Owns the HTML/JS template provider injected into the page.
        TVCLPythiaThemeManager:
          Applies the active theme to both the VCL container and the
          embedded browser UI; propagates theme changes upward via
          OnThemeChanged.
        TVCLPythiaScrollManager:
          Centralizes scroll-to-top / scroll-to-end logic and the
          visibility of the scroll control surface.
        TVCLPythiaLanguageManager / TVCLPythiaAppSettings:
          Dictionary loading / localization, and persistence of user
          settings.

    Service layers
        TVCLPythiaDialogManager:
          Wraps the file-open dialog behind IOpenDialog.
        TVCLPythiaRunProcessManager:
          Wraps external process execution behind IProcessExecute.
        TVCLPythiaChatContentManager:
          Holds PromptCount (the alignment key between DOM rendering and
          persisted chat turns) and the content rebuild function.

    Bridge layer
        TVCLPythiaBridgeManager:
          Implements the WebView2 runtime bridge:
            - navigation lifecycle (start / complete / lock)
            - permission handling
            - template injection on "ready"
            - JSON message reception and forwarding to TBrowserEventManager
          This class intentionally centralizes all WebView2 event wiring
          (see BridgeInitialize).
        TVCLPythiaAdapter:
          Exposes the managed-item dialog service consumed by event
          handlers.

    Input / lock / panels layers
        TVCLPythiaInputValue:
          Generic "prompt the user for a value" bridge to the HTML input
          component.
        TVCLPythiaAPIKeyManager:
          Secret store access and API key name persistence.
        TVCLPythiaLockServices:
          Locked / Escape run-state flags consumed by upper layers.
        TVCLPythiaCustomPanels:
          Registry of application-defined extra panels surfaced in the
          UI.

    UI dialog layers
        TVCLPythiaSettingsPanel:
          Bridge to the settings dialog (page selection, full-state
          initialization, property updates, language forcing).
        TVCLPythiaModelsSelector:
          Bridge to the models-selector UI and the model list file.
        TVCLPythiaChatSessionManager:
          Persistent chat sessions (IPersistentChat) with paging,
          add / remove / rename / to-top and auto-rename.
        TVCLPythiaCardSelector:
          Bridge to the card selector dialog; creation of default card
          files (MCP, function, skill, agent, custom).

    Chat-input surface
        TVCLPythiaInputBubble:
          Owns FEnabledButtons. Drives the input bubble (menu, welcome,
          partial reset, audio and function button visibility).
        TVCLPythiaReasoningComponent:
          Toggles the reasoning panel visibility.
        TVCLPythiaCommandLine:
          Command registry and dispatch; validates prompt text and routes
          slash-style commands through TryHandleAsCommand. Built-in
          plugins (ApiKey) are registered in CommandLineInitialize; host
          applications may inject additional plugins via
          OnRegisterCommandPlugins.

    Facade
        TInterfacedVCLPythia:
          Concrete implementation of IBrowser. Acts as the fa ade used by
          the rest of the application:
            - rendering prompts / responses / media
            - managing reasoning visibility
            - interacting with chat sessions
            - sending commands to the browser DOM
          Its breadth is intentional and dictated by IBrowser. All the
          layers below exist specifically to keep this class from turning
          into a bag of unrelated responsibilities.

    Concrete publishable class
        TVCLPythia:
          Exposes CustomPanels and EnabledButtons as design-time
          properties.

    -------------------------------------------------------------------------
    Runtime model
    -------------------------------------------------------------------------

    1. WebView2 is initialized asynchronously via GlobalWebView2Loader.
    2. TVCLPythiaCore creates TWVBrowser and TWVWindowParent and parents
       the window parent to the owning TWinControl.
    3. EnsureBrowserInitialized (called from DoOnTimer and Update) creates
       the browser as soon as the loader is ready; BridgeInitialize wires
       every WebView2 event at that moment.
    4. A virtual host exposes local assets as https://app.local.
    5. On first navigation completion, the in-memory HTML shell is
       injected.
    6. When the page emits "ready":
         - theme is applied
         - templates are injected
         - navigation is locked
    7. Browser-side JSON messages are received by DoWebMessageReceived
       and dispatched through TBrowserEventManager.
    8. Event handlers (Browser.Chat.EventHandlers) call IBrowser methods
       implemented by TInterfacedVCLPythia to mutate the UI.

    -------------------------------------------------------------------------
    Key invariants
    -------------------------------------------------------------------------

      The browser is usable only when:
        - WebView2 is initialized
        - CoreWebView2 exists
        - the page has emitted "ready"
      FEventManager is created early (in TVCLPythiaBridgeManager) but
      receives its runtime dependencies only after TInterfacedVCLPythia
      construction.
      PromptCount is the alignment key between:
        - DOM rendering (browser side)
        - persisted chat turns (backend)
      Every abstract primitive declared in TVCLPythiaAbstract must have
      exactly one concrete override in the chain. Adding a new primitive
      in the abstract without providing an override somewhere below
      prevents TVCLPythia from being instantiated.

    -------------------------------------------------------------------------
    Architectural constraints (intentional design choices)
    -------------------------------------------------------------------------

      TVCLPythiaBridgeManager groups every WebView2 runtime concern by
      design. Splitting navigation, messaging and injection would break
      lifecycle coherence.
      TInterfacedVCLPythia is a wide fa ade by necessity, since IBrowser
      aggregates rendering, session, input and UI control
      responsibilities.
      TVCLPythiaCore centralizes initialization because WebView2 startup,
      host mapping and navigation are tightly coupled.
      The inheritance chain IS the contract. Upper layers must not reach
      into lower-layer private state   always use the protected
      primitives exposed by the parent.

    -------------------------------------------------------------------------
    Evolution guidelines
    -------------------------------------------------------------------------

      Do not add rendering logic to TVCLPythiaBridgeManager.
      Do not move WebView2 lifecycle logic into TInterfacedVCLPythia.
      Do not extend TVCLPythiaCore beyond infrastructure / bootstrap.
      Do not bypass IBrowser when interacting with the UI from event
      handlers.
      Do not introduce cross-layer dependencies that skip intermediate
      layers.
      Keep new concerns in their own layer (a new class in the chain)
      rather than widening an existing layer. The cost of an additional
      class is low; the cost of a bloated layer is compound.
      Keep this unit architecturally aligned with FMX.Browser.Chat. Drift
      between the two makes every future synchronization painful.

    -------------------------------------------------------------------------
    Reading this unit in isolation
    -------------------------------------------------------------------------

      This is not a simple visual control wrapper. It is the Windows-side
      bridge between:
        - the WebView2 frontend (HTML / JS)
        - the backend chat logic
        - persistent storage
      Most UI mutations occur through:
        - ExecuteScript (direct JS execution)
        - PostWebMessageAsJson (structured messaging)
      Event logic itself lives in:
        - Browser.Chat.EventHandlers
        - Browser.Chat.EventManager

*)

{$ENDREGION}

function BuildDisplayBlockPayload(
  const ATitle: string;
  const AText: string = '';
  const AUrl: string = '';
  const AItemsJson: string = ''): string;
var
  Obj: TJSONObject;
  Items: TJSONValue;
begin
  Obj := TJSONObject.Create;
  try
    if not ATitle.IsEmpty then
      Obj.AddPair('title', ATitle);

    if not AText.IsEmpty then
      Obj.AddPair('text', AText);

    if not AUrl.IsEmpty then
      Obj.AddPair('url', AUrl);

    if not AItemsJson.Trim.IsEmpty then
      begin
        Items := TJSONObject.ParseJSONValue(AItemsJson);
        if Assigned(Items) then
          Obj.AddPair('items', Items);
      end;

    Result := Obj.ToJSON;
  finally
    Obj.Free;
  end;
end;

{ TInterfacedVCLPythia }

procedure TInterfacedVCLPythia.BeginUpdate;
begin
  {--- Group a sequence of DOM updates into a single render batch. }
  if not ExecuteScript(RENDER_BATCH_BEGIN_UPDATE) then
    raise EVCLPythiaException.Create(S_BATCH_BEGIN_ERROR);
end;

procedure TInterfacedVCLPythia.BringHostToFront;
begin
  if not Assigned(FWindowParent) then
    Exit;

  var HostForm := GetParentForm(FWindowParent);
  if not Assigned(HostForm) then
    Exit;

  if HostForm.WindowState = wsMinimized then
    HostForm.WindowState := wsNormal;

  if not HostForm.Visible then
    HostForm.Visible := True;

  Application.Restore;
  HostForm.BringToFront;
  SetForegroundWindow(HostForm.Handle);
end;

procedure TInterfacedVCLPythia.Clear;
begin
  {--- Reset local streaming state first, then unselect and detach
       the current chat session from the browser view. }
  ClearMediaPlayer;
  ClearInternalBrowserData;
  ChatSessionUnselect;
  ClearCurrentChatSession;
  ClearBrowserDisplay;
  SetFocus;
end;

function TInterfacedVCLPythia.ClearBrowserDisplay: Boolean;
begin
  Result := ExecuteScript(CLEAR_TEMPLATE);
end;

procedure TInterfacedVCLPythia.ClearCurrentChatSession;
begin
  if Assigned(FPersistentChat) then
    FPersistentChat.CurrentChat := nil;
end;

procedure TInterfacedVCLPythia.ClearInternalBrowserData;
begin
  {--- Reset transient rendering state without touching persistent chat storage. }
  ReasoningHide;
  FStreamContent := '';
  FStreamThink := '';
  FPromptCount := 0;
  FFirstChunkContent := True;
end;

procedure TInterfacedVCLPythia.ClearMediaPlayer;
begin
  StopMedia;
end;

function TInterfacedVCLPythia.Confirmation(
  const Value, Goal, Tag: string;
  const Index: Integer): Boolean;
begin
  {--- Send a structured confirmation request to the browser-side dialog layer. }
  Result := PostWebMessageAsJson(
    Format(DIALOG_CONFIRMATION_REQUEST, [
      Value,
      Goal,
      Tag,
      Index
    ]),
    'dialog-confirmation-request'
  );
end;

constructor TInterfacedVCLPythia.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStreamContent := '';
  FStreamThink := '';
  FReasoningVisible := False;
  FWebDecisionDlgBroker := TWebDecisionDlgBroker.Create;

  {--- Complete event manager dependency injection only after the concrete
       browser instance and all inherited services are fully initialized. }
  FEventManager.SetBrowser(Self);
  FEventManager.SetOpenDialog(FOpenDialog);
  FEventManager.SetRunProcess(FRunProcess);
  FEventManager.SetPersistentChat(FPersistentChat);

  //FEventManager.SetServiceAdapter(FServiceAdapter);
  {--- ServiceAdapter is intentionally NOT wired here: the host application
     must provide its own IChatManagedItemDialogService implementation via
     the public property `ServiceAdapter`. Its setter forwards to
     FEventManager.SetServiceAdapter once the value is supplied. }
end;

destructor TInterfacedVCLPythia.Destroy;
begin
  FWebDecisionDlgBroker.Free;
  inherited Destroy;
end;

function TInterfacedVCLPythia.ResolveWebDecisionDlgResponse(
  const AJson: string): Boolean;
begin
  Result :=
    Assigned(FWebDecisionDlgBroker) and
    FWebDecisionDlgBroker.ResolveResponse(AJson);
end;

function TInterfacedVCLPythia.WebDecisionDlg(
  const ARequest: TWebDecisionDlgRequest;
  const ATimeoutMS: Cardinal): TWebDecisionDlgResult;
begin
  if GetCurrentThreadId = MainThreadID then
    raise EVCLPythiaException.Create(
      'WebDecisionDlg cannot be called synchronously from the UI thread.');

  Result := FWebDecisionDlgBroker.ExecuteSync(
    ARequest,
    function(Json: string): Boolean
    var
      Posted: Boolean;
    begin
      Posted := False;
      TThread.Synchronize(nil,
        procedure
        begin
          Posted := PostWebMessageAsJson(Json, WEB_DECISION_DLG_REQUEST_TYPE);
        end);
      Result := Posted;
    end,
    ATimeoutMS);
end;

function TInterfacedVCLPythia.DeferAfterDisplayStream(
  const Script: string;
  const PairId: Integer): string;
begin
  Result :=
    Format(DEFER_AFTER_DISPLAY_STREAM, [
      Script,
      TEscapeHelper.EscapeJSString(PairId.ToString)
    ]
  );
end;

function TInterfacedVCLPythia.Display(
  const AText: string;
  const AThink: string;
  Scroll: Boolean): Boolean;
begin
  if not IsBrowserReady then
    Exit(False);

  {--- Replace the current Markdown response buffer.
       A following DisplayStream call can append to this new base content. }
  FStreamContent := AText;

  {--- Replace the current reasoning buffer.
       Reasoning and response are rendered into the same browser-side response block,
       but kept as separate buffers on the Delphi side. }
  FStreamThink := AThink;

  {--- Try to hide the reasoning bubble }
  ReasoningHide;

  {--- Try to expand then reasoning content box }
  if not AThink.IsEmpty then
    ReasoningExpand;

  if not AText.IsEmpty then
    ReasoningCollapse;

  Result := ExecuteScript(
    Format(DISPLAY_TEMPLATE, [
      '"false"',
      TEscapeHelper.EscapeJSString(FPromptCount.ToString),
      TEscapeHelper.EscapeJSString(FStreamThink),
      TEscapeHelper.EscapeJSString(FStreamContent)]
      )
  );

  if Scroll and Result then
    ScrollToAfterEnd(GetHeightAfter(0), False);
end;

function TInterfacedVCLPythia.DisplayBlock(
  const Kind, PayloadJson: string;
  Scroll: Boolean): Boolean;
var
  Script: string;
  IsToolKind: Boolean;
begin
  if not IsBrowserReady then
    Exit(False);

  {--- Try to hide the reasoning bubble }
  ReasoningHide;

  Script := Format(DISPLAY_BLOCK_TEMPLATE, [
    TEscapeHelper.EscapeJSString(FPromptCount.ToString),
    TEscapeHelper.EscapeJSString(Kind),
    TEscapeHelper.EscapeJSString(PayloadJson)
  ]);

  {--- Tool-related blocks (toolStatus / toolOutput / toolError) are
       emitted while assistant text may still be queued in JavaScript.
       Send them to the browser immediately; DisplayTemplate coordinates
       the small visual deferral together with DisplayBlockStream so tool
       outputs still attach to their matching status entry. }
  IsToolKind :=
    SameText(Kind, DISPLAY_BLOCK_KIND_TOOL_STATUS) or
    SameText(Kind, DISPLAY_BLOCK_KIND_TOOL_OUTPUT) or
    SameText(Kind, DISPLAY_BLOCK_KIND_TOOL_ERROR);

  if IsToolKind then
    Result := ExecuteScript(Script)
  else
    Result := ExecuteScript(
      DeferAfterDisplayStream(Script, FPromptCount)
    );

  if Scroll and Result then
    ScrollToAfterEnd(GetHeightAfter(0), False);
end;

function TInterfacedVCLPythia.DisplayBlocks(
  const BlocksJson: string;
  Scroll: Boolean): Boolean;
begin
  if not IsBrowserReady then
    Exit(False);

  Result := ExecuteScript(
    Format(DISPLAY_BLOCKS_TEMPLATE, [
      TEscapeHelper.EscapeJSString(FPromptCount.ToString),
      TEscapeHelper.EscapeJSString(BlocksJson)
    ])
  );

  if Scroll and Result then
    ScrollToAfterEnd(GetHeightAfter(0), False);
end;

function TInterfacedVCLPythia.DisplayBlockStream(
  const Kind, Delta, PayloadJson: string;
  Scroll: Boolean): Boolean;
begin
  if not IsBrowserReady then
    Exit(False);

  {--- Try to hide the reasoning bubble }
  ReasoningHide;

  Result := ExecuteScript(
    Format(DISPLAY_BLOCK_STREAM_TEMPLATE, [
      TEscapeHelper.EscapeJSString(FPromptCount.ToString),
      TEscapeHelper.EscapeJSString(Kind),
      TEscapeHelper.EscapeJSString(Delta),
      TEscapeHelper.EscapeJSString(PayloadJson)
    ])
  );

  if Scroll and Result then
    ScrollToAfterEnd(GetHeightAfter(0), True);
end;

function TInterfacedVCLPythia.DisplayAssistant(
  const AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_ASSISTANT,
    BuildDisplayBlockPayload('', AText),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayAssistantStream(
  const ADelta: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlockStream(DISPLAY_BLOCK_KIND_ASSISTANT, ADelta, '', Scroll);
end;

function TInterfacedVCLPythia.DisplayArtifactList(
  const ATitle, ArtifactsJson: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_ARTIFACT_LIST,
    BuildDisplayBlockPayload(ATitle, '', '', ArtifactsJson),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayCitationList(
  const CitationsJson: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_CITATION_LIST,
    BuildDisplayBlockPayload('', '', '', CitationsJson),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayReasoning(
  const AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_REASONING,
    BuildDisplayBlockPayload('', AText),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayReasoningStream(
  const ADelta: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlockStream(DISPLAY_BLOCK_KIND_REASONING, ADelta, '', Scroll);
end;

function TInterfacedVCLPythia.DisplaySourceDocument(
  const ATitle, AUrl, AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_SOURCE_DOCUMENT,
    BuildDisplayBlockPayload(ATitle, AText, AUrl),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplaySourceList(
  const ATitle, SourcesJson: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_SOURCE_LIST,
    BuildDisplayBlockPayload(ATitle, '', '', SourcesJson),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplaySourceStatus(
  const AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_SOURCE_STATUS,
    BuildDisplayBlockPayload('', AText),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayStatus(
  const AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_STATUS,
    BuildDisplayBlockPayload('', AText),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayToolError(
  const ATitle, AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_TOOL_ERROR,
    BuildDisplayBlockPayload(ATitle, AText),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayToolErrorStart(
  const ATitle: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_TOOL_ERROR,
    BuildDisplayBlockPayload(ATitle),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayToolErrorStream(
  const ADelta: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlockStream(DISPLAY_BLOCK_KIND_TOOL_ERROR, ADelta, '', Scroll);
end;

function TInterfacedVCLPythia.DisplayToolOutput(
  const ATitle, AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_TOOL_OUTPUT,
    BuildDisplayBlockPayload(ATitle, AText),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayToolOutputStart(
  const ATitle: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_TOOL_OUTPUT,
    BuildDisplayBlockPayload(ATitle),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayToolOutputStream(
  const ADelta: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlockStream(DISPLAY_BLOCK_KIND_TOOL_OUTPUT, ADelta, '', Scroll);
end;

function TInterfacedVCLPythia.DisplayToolStatus(
  const AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayBlock(
    DISPLAY_BLOCK_KIND_TOOL_STATUS,
    BuildDisplayBlockPayload('', AText),
    Scroll
  );
end;

function TInterfacedVCLPythia.DisplayError(const Value: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(ERROR_DISPLAY_TEMPLATE, [Value]),
    'erreur'
  );
end;

function TInterfacedVCLPythia.DisplayFooter(const Value: string): Boolean;
begin
  Result := SetChatFooter(Value);
end;

function TInterfacedVCLPythia.DisplayMedia(Kind: TDisplayKind;
  const Value: TArray<string>; Scroll: Boolean): Boolean;
var
  Template: string;
  Align: string;
begin
  if Length(Value) = 0 then
    Exit(False);

  {--- Response-side media is rendered on the left, matching assistant output alignment. }
  case Kind of
    dkImages:
      begin
        Template := TemplateProvider.ImagesTemplate;
        Align := THorizontalPosition.Left.ToString;
      end;

    dkAudio:
      Template := TemplateProvider.AudioTemplate;

    dkVideo:
      Template := TemplateProvider.VideoTemplate;

    dkFile:
      Template := TemplateProvider.DisplayFileTemplate;
  end;

  Result := RenderMedia(Template, Value, False, Align, Scroll);
end;

function TInterfacedVCLPythia.DisplayChatSession: Boolean;
begin
  Result := InternalDisplaySession;

  {--- Notify the host AFTER the full re-render so any session-derived UI
       state (e.g. managed-agent chip restoration) can be re-applied atop
       the freshly rebuilt content. Fires regardless of which renderer
       path InternalDisplaySession took (default or OnRenderChatContent). }
  if Assigned(FOnAfterSessionReloaded) and
     Assigned(FPersistentChat) and
     Assigned(FPersistentChat.CurrentChat) then
    FOnAfterSessionReloaded(FPersistentChat.CurrentChat.Id);
end;

function TInterfacedVCLPythia.DisplaySpacer(const AHeight: Integer): Boolean;
var
  Script: string;
begin
  Script := Format(SPACER_TEMPLATE, [AHeight]);

  Result := ExecuteScript(
    DeferAfterDisplayStream(Script, FPromptCount)
  );
end;

function TInterfacedVCLPythia.DisplayStream(const AText: string;
  Scroll: Boolean): Boolean;
begin
  Result := DisplayStream(AText, '', Scroll);
end;

function TInterfacedVCLPythia.DisplayStream(const AText, AThink: string;
  Scroll: Boolean): Boolean;
begin
    if not IsBrowserReady then
    Exit(False);

  {--- Accumulate the Markdown stream }
  FStreamContent := FStreamContent + AText;

  {--- Keep reasoning and response streams separate, then render both
       into the same browser-side response block. }
  FStreamThink := FStreamThink + AThink;

  {--- Try to hide the reasoning bubble }
  ReasoningHide;

  {--- Try to expand then reasoning content box }
  if not AThink.IsEmpty then
    ReasoningExpand;

  if not AText.IsEmpty and FFirstChunkContent then
    begin
      FFirstChunkContent := False;
      ReasoningCollapse;
    end;

  Result := ExecuteScript(
    Format(DISPLAY_STREAM_TEMPLATE, [
      'true',
      TEscapeHelper.EscapeJSString(FPromptCount.ToString),
      TEscapeHelper.EscapeJSString(AThink),
      TEscapeHelper.EscapeJSString(AText)]
      )
  );

  if Scroll and Result then
    ScrollToAfterEnd(GetHeightAfter(0), True);
end;

function TInterfacedVCLPythia.DisplaySuccess(const Value: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(SUCCESS_DISPLAY_TEMPLATE, [Value]),
    'success'
  );
end;

function TInterfacedVCLPythia.DisplayWarning(const Value: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(WARNING_DISPLAY_TEMPLATE, [Value]),
    'warning'
  );
end;

procedure TInterfacedVCLPythia.EndUpdate;
begin
  {--- Flush the current render batch and allow the browser to repaint. }
  if not ExecuteScript(RENDER_BATCH_END_UPDATE) then
    raise EVCLPythiaException.Create(S_BATCH_END_ERROR);
end;

function TInterfacedVCLPythia.ExecuteTemplate(
  const Template: string;
  const Value: TArray<string>;
  const isPromptSource: Boolean;
  const Align: string): Boolean;
var
  EscapedItems: TArray<string>;
  index: Integer;
  Script: string;
begin
  SetLength(EscapedItems, Length(Value));
  for var i := 0 to High(Value) do
    EscapedItems[i] := TEscapeHelper.EscapeJSString(Value[i]);

  var AttachedData := '[' + string.Join(',', EscapedItems) + ']';

  {--- (PromptSource) Right-aligned media belongs to the next prompt bubble,
       while left-aligned media attaches to the current response block. }
  if isPromptSource then
    index := FPromptCount + 1
  else
    index := FPromptCount;

  if Align.IsEmpty then
    begin
      // Files
      Script := Format(Template, [
        AttachedData,
        index.ToString
      ]);

      if not isPromptSource then
        Script := DeferAfterDisplayStream(Script, index);

      Result := ExecuteScript(Script);
      Exit;
    end;

  // Images
  Script := Format(Template, [
    AttachedData,
    Align,
    index.ToString
  ]);

  if not isPromptSource then
    Script := DeferAfterDisplayStream(Script, index);

  Result := ExecuteScript(Script);
end;

function TInterfacedVCLPythia.Display(const AText: string; Scroll: Boolean): Boolean;
begin
  Result := Display(AText, '', Scroll);
end;

function TInterfacedVCLPythia.GetSettingsPanelPage: Integer;
begin
  Result := FSettingsPanelPage;
end;

procedure TInterfacedVCLPythia.Hide;
begin
  FWindowParent.Visible := False;
end;

function TInterfacedVCLPythia.InternalDisplaySession: Boolean;
begin
  if not Assigned(FPersistentChat) then
    Exit(False);

  ClearMediaPlayer;
  ClearInternalBrowserData;

  if Assigned(FOnRenderChatContent) then
    begin
      Exit(FOnRenderChatContent());
    end;

  Result := True;

  BeginUpdate;
  try
    var First := True;
    {--- Rebuild the full conversation by replaying each persisted turn
         in the same order as originally rendered. }
    for var Turn in FPersistentChat.CurrentChat.Data do
      begin
        if not First then
          DisplaySpacer(60);
        PromptMedia(dkimages, Turn.PromptImages, False);
        PromptMedia(dkFile, Turn.PromptFiles, False);
        PromptMedia(dkFile, Turn.PromptKnowledgeSearch, False);
        Prompt(Turn.Prompt);

        if Length(Turn.DisplayBlocks) > 0 then
          DisplayBlocks(ChatDisplayBlocksToJson(Turn.DisplayBlocks), False)
        else
          Display(Turn.Response, Turn.Reasoning, False);

        DisplayMedia(dkimages, Turn.ReponseImages, False);
        DisplayMedia(dkAudio, Turn.ReponseAudio, False);
        DisplayMedia(dkVideo, Turn.ReponseVideo, False);
        DisplayMedia(dkFile, Turn.ReponseFiles, False);
        DisplayFooter(Turn.Model);
        First := False;
      end;
      DisplaySpacer;

      ScrollToEnd(False);
      SetFocus;
  finally
    EndUpdate;
  end;
end;

function TInterfacedVCLPythia.Prompt(const AText: string): Boolean;
begin
  if not IsBrowserReady then
    Exit(False);

  {--- Starting a new prompt resets the active response streams
       and advances the prompt index used by subsequent render calls. }
  ReasoningHide;
  FReasoningVisible := False;

  if AText.Trim.IsEmpty then
    Exit(False);

  FPromptCount := FPromptCount + 1;
  FStreamContent := '';
  FStreamThink := '';
  FFirstChunkContent := True;

  Result := ExecuteScript(
    Format(TemplateProvider.PromptTemplate, [
      TEscapeHelper.EscapeJSString(AText),
      TEscapeHelper.EscapeJSString(FPromptCount.ToString)
    ])
  );

//  ReasoningShow;
end;

function TInterfacedVCLPythia.PromptMedia(Kind: TDisplayKind;
  const Value: TArray<string>; Scroll: Boolean): Boolean;
var
  Template: string;
  Align: string;
begin
  if Length(Value) = 0 then
    Exit(False);

  {--- Prompt-side media is limited to user-owned content such as images and files. }
  case Kind of
    dkImages:
      begin
        Template := TemplateProvider.ImagesTemplate;
        Align := THorizontalPosition.Right.ToString;
      end;

    dkFile:
      begin
        Template := TemplateProvider.PromptFileTemplate;
        Align := '';
      end;

    else
      Exit(False);
  end;

  Result := RenderMedia(Template, Value, True, Align, Scroll);
end;

function TInterfacedVCLPythia.RenderMedia(
  const Template: string;
  const Value: TArray<string>;
  const isPromptSource: Boolean;
  const Align: string;
  Scroll: Boolean): Boolean;
begin
  if not IsBrowserReady then
    Exit(False);

  if Align.IsEmpty then
    Result := ExecuteTemplate(Template, Value, isPromptSource)
  else
    Result := ExecuteTemplate(Template, Value, isPromptSource, Align);

  if Scroll then
    ScrollToAfterEnd(GetHeightAfter(0), False);
end;

procedure TInterfacedVCLPythia.UpdateEnabledButtons;
begin
  if not IsJSScriptInjected then
    Exit;

  BubbleInputFunctionButtonVisible(ebSettings in FEnabledButtons);
  BubbleInputAudioButtonVisible(ebMicrophone in FEnabledButtons);
end;

function TInterfacedVCLPythia.UpdateFileDrawer: Boolean;
begin
  {--- The first update initializes the files drawer, later updates append paging data. }
  Result := PostWebMessageAsJson(FChatListPage.ToJsonString(FFirstPage));

  if Result then
    FFirstPage := False;
end;

function TInterfacedVCLPythia.SetChatFooter(const Text: string): Boolean;
var
  Script: string;
begin
  Script := Format(TemplateProvider.ChatFooterTemplate, [
     TEscapeHelper.EscapeJSString(Text),
     TEscapeHelper.EscapeJSString(FPromptCount.ToString),
     CHAT_FOOTER_FONT_SIZE,
     CHAT_FOOTER_COLOR
  ]);

  Result := ExecuteScript(
    DeferAfterDisplayStream(Script, FPromptCount)
  );
end;

procedure TInterfacedVCLPythia.SetFocus;
begin
  if Assigned(FWindowParent) and FWindowParent.CanFocus then
    FWindowParent.SetFocus;

  if Assigned(FBrowser) then
    FBrowser.SetFocus;

  if not PostWebMessageAsJson(SET_INPUT_BUBBLE_FOCUS, 'input-bubble-setfocus') then
    raise EVCLPythiaException.Create(S_FOCUS_ERROR);
end;

procedure TInterfacedVCLPythia.SetSettingsPanelPage(const Value: Integer);
begin
  FSettingsPanelPage := Value;
end;

procedure TInterfacedVCLPythia.SetTheme(const Value: string);
begin
  Theme := Value;
end;

procedure TInterfacedVCLPythia.Show;
begin
  if not FWindowParent.Visible then
    FWindowParent.Visible := True;
end;

procedure TInterfacedVCLPythia.StopAudio;
begin
  if not ExecuteScript(STOP_AUDIO_TEMPLATE) then
    raise EVCLPythiaException.Create(S_STOP_AUDIO_MEDIA_ERROR);
end;

procedure TInterfacedVCLPythia.AudioRecordingStart;
begin
  {--- Ask the browser-side recorder to begin capturing the microphone.
       The encoded audio is later returned through the "audio-record" event. }
  if not PostWebMessageAsJson(AUDIO_RECORDING_START) then
    raise EVCLPythiaException.Create(S_AUDIO_RECORDING_START_ERROR);
end;

procedure TInterfacedVCLPythia.AudioRecordingStop;
begin
  {--- Ask the browser-side recorder to finalize the capture. }
  if not PostWebMessageAsJson(AUDIO_RECORDING_STOP) then
    raise EVCLPythiaException.Create(S_AUDIO_RECORDING_STOP_ERROR);
end;

procedure TInterfacedVCLPythia.AudioRecordingSwitch;
begin
  {--- Toggle the browser-side recorder; the browser decides start vs stop
       based on its live state, keeping the host free of recording state. }
  if not PostWebMessageAsJson(AUDIO_RECORDING_SWITCH) then
    raise EVCLPythiaException.Create(S_AUDIO_RECORDING_SWITCH_ERROR);
end;

procedure TInterfacedVCLPythia.StopMedia;
begin
  StopAudio;
  StopVideo;
end;

procedure TInterfacedVCLPythia.StopVideo;
begin
  if not ExecuteScript(STOP_VIDEO_TEMPLATE) then
    raise EVCLPythiaException.Create(S_STOP_VIDEO_MEDIA_ERROR);
end;

{ TVCLPythiaCore }

constructor TVCLPythiaCore.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  var Folder := GetMediaFolder;
  if not System.SysUtils.DirectoryExists(Folder) then
    MkDir(Folder);

  Folder := GetAppSubFolder;
  if not System.SysUtils.DirectoryExists(Folder) then
    MkDir(Folder);

  Folder := GetAppJsonSupportFolder;
  if not System.SysUtils.DirectoryExists(Folder) then
    MkDir(Folder);

  FBrowser := TWVBrowser.Create(Self);
  FWindowParent := TWVWindowParent.Create(Self);
  FTimer := TTimer.Create(Self);

  FWindowParent.DoubleBuffered := True;

  if AOwner is TWinControl then
    FWindowParent.Parent := TWinControl(AOwner);

  FWindowParent.Align := AlClient;
  FWindowParent.Browser := FBrowser;
  FWindowParent.Constraints.MinWidth := MIN_WIDTH;
  FWindowParent.Constraints.MinHeight := MIN_HEIGHT;

  FBrowser.DefaultURL := BASE_URL + '/index.htm';
  FBrowser.OnAfterCreated := DoAfterCreated;

  {--- The timer retries WebView2 startup until the global loader is ready. }
  FTimer.Interval := TIMER_INTERVAL;
  FTimer.OnTimer := DoOnTimer;

  FDefaultLangage := not ParamsMainValuesFileNameExists;
end;

procedure TVCLPythiaCore.CreateMappingFolder;
begin
  {--- Expose the local assets folder through the virtual host used by the embedded app. }
  FBrowser.SetVirtualHostNameToFolderMapping(
    LocalHost,
    GetAssetsFolder,
    COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND_ALLOW
  );
end;

procedure TVCLPythiaCore.DoAfterCreated(Sender: TObject);
begin
  FWindowParent.UpdateSize;
  FWindowParent.SetFocus;

  CreateMappingFolder;
  FBrowser.Navigate(FBrowser.DefaultURL);

  if Assigned(FOnBrowserCreated) then
    FOnBrowserCreated();
end;

procedure TVCLPythiaCore.DoOnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  if not EnsureBrowserInitialized then
    FTimer.Enabled := True;
end;

function TVCLPythiaCore.EnsureBrowserInitialized: Boolean;
begin
  Result := False;
  if GlobalWebView2Loader.InitializationError then
    begin
      ShowMessage(GlobalWebView2Loader.ErrorMessage);
      Exit;
    end;
  if not GlobalWebView2Loader.Initialized then
    Exit;
  if not FBrowser.Initialized then
    Result := FBrowser.CreateBrowser(FWindowParent.Handle)
  else
    Result := True;
end;

function TVCLPythiaCore.GetBrowser: TWVBrowser;
begin
  Result := FBrowser;
end;

function TVCLPythiaCore.GetLocalHost: string;
begin
  Result := LOCAL_HOST;
end;

function TVCLPythiaCore.Update: Boolean;
begin
  Result := EnsureBrowserInitialized;
  if not Result then
    FTimer.Enabled := True;
end;

{ TVCLPythiaBridgeManager }

procedure TVCLPythiaBridgeManager.BridgeInitialize;
begin
  FBrowser.OnNavigationCompleted := DoNavigationCompleted;
  FBrowser.OnWebMessageReceived := DoWebMessageReceived;
  FBrowser.OnPermissionRequested := DoPermissionRequested;
end;

constructor TVCLPythiaBridgeManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInitialNavigation := False;
  FBrowserInitialized := False;
  FJSScriptInjected := False;

  BridgeInitialize;  //A revoir

  {--- The event manager is created early, then completed later
       when TInterfacedVCLPythia injects the concrete runtime dependencies. }
  FEventManager := TBrowserEventManager.Create;
end;

procedure TVCLPythiaBridgeManager.DoInjectionsWhenReady;
begin
  {--- Inject all HTML fragments and browser-side helpers only after
       the page reports itself ready to receive them. }
  ExecuteScript(TemplateProvider.BootstrapDictionaryTemplate);
  ExecuteScript(TemplateProvider.RequestParamsTemplate);
  ExecuteScript(TemplateProvider.ModelsTemplate);
  ExecuteScript(TemplateProvider.InputBubbleTemplate);
  ExecuteScript(TemplateProvider.ScrollButtonsTemplate);
  ExecuteScript(TemplateProvider.PromptSummaryTemplate);
  ExecuteScript(TemplateProvider.DisplayTemplate);
  ExecuteScript(TemplateProvider.ImagesTemplate);
  ExecuteScript(TemplateProvider.PromptFileTemplate);
  ExecuteScript(TemplateProvider.AudioTemplate);
  ExecuteScript(TemplateProvider.AudioRecordingTemplate);
  ExecuteScript(TemplateProvider.VideoTemplate);
  ExecuteScript(TemplateProvider.DisplayFileTemplate);
  ExecuteScript(TemplateProvider.SelectorTemplate);
  ExecuteScript(TemplateProvider.ConfirmationDialogTemplate);
  ExecuteScript(TemplateProvider.FilesDrawerTemplate);
  ExecuteScript(TemplateProvider.ErrorsTemplate);
  ExecuteScript(TemplateProvider.ChatFooterTemplate);
  ExecuteScript(TemplateProvider.CardSelectorTemplate);
  ExecuteScript(TemplateProvider.ActivityLogoTemplate);
  ExecuteScript(TemplateProvider.WebDecisionTemplate);
  ExecuteScript(TemplateProvider.InputDialogTemplate);

  {--- Load and inject custom the JS templates }
  for var Item in FCustomJSTemplate do
    ExecuteScript(TemplateProvider.LoadCustomTemplate(Item));

  {--- Terminate with the injection of the "End" JS template }
  ExecuteScript(TemplateProvider.InjectionEndedTemplate);
end;

procedure TVCLPythiaBridgeManager.DoNavigationCompleted(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2NavigationCompletedEventArgs);
begin
  {--- The shell is now served directly from the secure virtual host
       (https://app.local/index.htm) instead of being injected through
       NavigateToString, which produced an opaque/insecure origin. A secure
       origin is required for powerful web APIs such as getUserMedia (audio
       capture). Injection is still driven by the page's "ready" message, so
       nothing needs to happen here on navigation completion. }
end;

procedure TVCLPythiaBridgeManager.DoNavigationStarting(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2NavigationStartingEventArgs);
var
  uri: PWideChar;
  url: string;
begin
  aArgs.Get_uri(uri);
  try
    url := uri;

    {--- Disable navigation with unauthorized external links }
    aArgs.Set_Cancel(Ord(not IsAllowedNavigation(url)));
  finally
    CoTaskMemFree(uri);
  end;
end;

procedure TVCLPythiaBridgeManager.DoPermissionRequested(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2PermissionRequestedEventArgs);
var
  Kind: COREWEBVIEW2_PERMISSION_KIND;
begin
  {--- Only microphone permission is granted automatically for browser-side audio features. }
  var CanSetState :=
    (aArgs.Get_PermissionKind(Kind) = S_OK) and
    (Kind = COREWEBVIEW2_PERMISSION_KIND_MICROPHONE);

  if not CanSetState then
    Exit;

  aArgs.Set_State(COREWEBVIEW2_PERMISSION_STATE_ALLOW);
end;

procedure TVCLPythiaBridgeManager.DoWebMessageReceived(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
var
  pMsg: PWideChar;
  rawJson: string;
begin
  {--- Calls the Get_WebMessageAsJson method to get the JSON }
  if aArgs.Get_WebMessageAsJson(pMsg) <> S_OK then
    Exit;

  try
    rawJson := pMsg;
  finally
    CoTaskMemFree(pMsg);
  end;

  if SameText(rawJson, MSG_READY) then
    begin
      FBrowserInitialized := True;

      {--- Refresh the page appearance with the current theme (light or dark) }
      SetInternalTheme(FTheme);

      {--- JS injection into the web browser }
      DoInjectionsWhenReady;

      {--- Disable navigation with unauthorized external links }
      LockNavigation;

      Exit;
    end;

  if SameText(rawJson, MSG_INPUT_READY) then
    begin
      {--- Enable or disable items in the input bubble menu }
      UpdateCapabilities;

      Exit;
    end;

  if SameText(rawJson, MSG_INJECTION_ENDED) then
    begin

      {--- All the JS scripts have been injected; we can now start the initialization. }
      FJSScriptInjected := True;

      Initialize;
    end;

  var EnrichedJson: string;
  if TWebView2DropFiles.TryBuildFileDropInJson(rawJson, aArgs, EnrichedJson) then
    rawJson := EnrichedJson;

  {--- Forward all regular browser-side events to the centralized JSON dispatcher. }
  FEventManager.Aggregate(rawJson);
end;

function TVCLPythiaBridgeManager.ExecuteScript(const Script: string): Boolean;
begin
  if not IsBrowserReady then
    Exit(False);

  Result := FBrowser.ExecuteScript(Script);
end;

function TVCLPythiaBridgeManager.IsAllowedNavigation(const Url: string): Boolean;
begin
  if SameText(Url, MSG_ABOUT_BLANK) then
    Exit(True);

  for var Origin in CAllowedOrigins do
    if SameText(Url, Origin) or Url.StartsWith(Origin + '/', True) then
      Exit(True);

  Result := False;
end;

function TVCLPythiaBridgeManager.IsBrowserReady: Boolean;
begin
  {--- Browser readiness requires both WebView2 initialization
       and an explicit ready signal from the injected page. }
  Result := Assigned(FBrowser) and Assigned(FBrowser.CoreWebView2) and FBrowserInitialized;
end;

function TVCLPythiaBridgeManager.IsJSScriptInjected: Boolean;
begin
  Result := IsBrowserReady and FJSScriptInjected;
end;

procedure TVCLPythiaBridgeManager.LockNavigation;
begin
  FBrowser.OnNavigationStarting := DoNavigationStarting;
end;

function TVCLPythiaBridgeManager.PostWebMessageAsJson(const Script: string): Boolean;
begin
  if IsBrowserReady then
    FBrowser.CoreWebView2.PostWebMessageAsJson(Script)
  else
    Exit(False);

  Result := True;
end;

function TVCLPythiaBridgeManager.PostWebMessageAsJson(
  const Script,
  ExpectedType: string): Boolean;
begin
  var Reader := TJsonReader.Parse(Script);

  if not Reader.IsValid then
    Exit(False);

  if not Reader.IsStringNode(PROP_TYPE) then
    Exit(False);

  if SameText(Reader.AsString(PROP_TYPE), ExpectedType) then
    Result := PostWebMessageAsJson(Script)
  else
    Exit(False);
end;

{ TVCLPythiaCapabilitiesManager }

function TVCLPythiaCapabilitiesManager.CapabilitiesInitialization: Boolean;
begin
  var Filename := GetCapabilitiesFileName;
  if not FileExists(Filename) then
     Exit(False);

  var CapabilitiesJsonString := TFileIOHelper.LoadFromFile(FileName);
  Result := PostWebMessageAsJson(CapabilitiesJsonString)
end;

constructor TVCLPythiaCapabilitiesManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCapabilities := TCapabilities.CreateInstance(GetCapabilitiesFileName, UpdateCapabilities);
  SaveDefaultCapabilitiesFile;
end;

function TVCLPythiaCapabilitiesManager.ResetCapabilities: Boolean;
begin
  FCapabilities.Reset;
  Result := UpdateCapabilities;
end;

procedure TVCLPythiaCapabilitiesManager.SaveDefaultCapabilitiesFile;
begin
  if not FileExists(GetCapabilitiesFileName) then
    begin
      TFileIOHelper.SaveToFile(GetCapabilitiesFileName, JSON_CAPABILITIES_DEFAULT);
    end;
end;

function TVCLPythiaCapabilitiesManager.UpdateCapabilities: Boolean;
begin
  {--- Push the current capability state to the browser-side input menu. }
  Result := PostWebMessageAsJson(Capabilities.ToJSON);
end;

{ TVCLPythiaProjectsManager }

constructor TVCLPythiaProjectsManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SaveDefaultProjectsFile;
end;

function TVCLPythiaProjectsManager.ProjectsInitialization: Boolean;
begin
  var Filename := GetProjectsFileName;
  if not FileExists(Filename) then
    Exit(False);

  var RawProjectsJsonString := TFileIOHelper.LoadFromFile(Filename);
  var ProjectsJsonString := '';
  if not NormalizeProjectsJson(RawProjectsJsonString, ProjectsJsonString) then
    TFileIOHelper.SaveToFile(Filename, ProjectsJsonString);

  Result := PostWebMessageAsJson(
    Format(FOLDER_STATE_TEMPLATE, [ProjectsJsonString]),
    'folder-state'
  );
end;

function TVCLPythiaProjectsManager.NormalizeProjectsJson(
  const JsonAsString: string; out NormalizedJson: string): Boolean;
begin
  NormalizedJson := JSON_PROJECTS_DEFAULT;

  var JsonValue := TJSONObject.ParseJSONValue(JsonAsString);
  try
    Result := JsonValue is TJSONArray;
    if Result then
      NormalizedJson := JsonValue.Format(4);
  finally
    JsonValue.Free;
  end;
end;

procedure TVCLPythiaProjectsManager.SaveDefaultProjectsFile;
begin
  if not FileExists(GetProjectsFileName) then
    TFileIOHelper.SaveToFile(GetProjectsFileName, JSON_PROJECTS_DEFAULT);
end;

function TVCLPythiaProjectsManager.ProjectsStateUpdate(
  const JsonAsString: string): Boolean;
begin
  var ProjectsJsonString := '';
  Result := NormalizeProjectsJson(JsonAsString, ProjectsJsonString);
  if Result then
    TFileIOHelper.SaveToFile(GetProjectsFileName, ProjectsJsonString);
end;

{ TVCLPythiaJSTemplatesManager }

constructor TVCLPythiaJSTemplatesManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTemplateProvider := TEdgeInjection.Create;
end;

{ TVCLPythiaThemeManager }

constructor TVCLPythiaThemeManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTheme := dark.ToString;
  FWindowParent.Color := DARK_BACKGROUND_COLOR;
end;

procedure TVCLPythiaThemeManager.SetInternalTheme(const Value: string);
var
  ThemeSelected: TLookAndFeel;
begin
  if not TLookAndFeel.TryToParse(Value, ThemeSelected) then
    ThemeSelected := dark;

  FTheme := ThemeSelected.ToString;
  case ThemeSelected of
    light:
      FWindowParent.Color := LIGHT_BACKGROUND_COLOR;
    else
      FWindowParent.Color := DARK_BACKGROUND_COLOR;
  end;

  if Assigned(FOnThemeChanged) then
    FOnThemeChanged();

  {--- Apply the selected theme to both the VCL host and the injected browser UI. }
  if not ExecuteScript(Format(SET_THEME_TEMPLATE, [FTheme, FTheme])) then
    raise EVCLPythiaException.Create(S_INTERNAL_THEME_ERROR);
end;

{ TVCLPythiaDialogManager }

constructor TVCLPythiaDialogManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOpenDialog := TVCLOpenDialog.Create;
end;

{ TVCLPythiaChatContentManager }

function TVCLPythiaChatContentManager.GetPromptCount: Integer;
begin
  Result := FPromptCount;
end;

procedure TVCLPythiaChatContentManager.SetPromptCount(const Value: Integer);
begin
  FPromptCount := Value;
end;

{ TVCLOpenDialog }

constructor TVCLOpenDialog.Create;
begin
  inherited Create;
end;

function TVCLOpenDialog.Execute(const Filter: string;
  const index: Integer;
  out FileName: string): Boolean;
begin
  Result := TOpenDialogHelper
    .Use(FOpenDialog)
    .Filter(Filter)
    .FilterIndex(Index)
    .Execute(FileName, True);
end;

function TVCLOpenDialog.ExecuteFolder(out FolderPath: string): Boolean;
begin
  Result := TFolderDialogHelper
    .Use(nil)
    .Execute(FolderPath);
end;

{ TVCLPythiaRunProcessManager }

constructor TVCLPythiaRunProcessManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRunProcess := TProcessExecute.Create;
end;

{ TCastHelp }

class function TCastHelp.BoolToStr(const Value: Boolean): string;
begin
  {--- Normalize booleans to lowercase for browser-side JSON / JS consumption. }
  Result := System.SysUtils.BoolToStr(Value, True).ToLower;
end;

{ TVCLPythiaAdapter }

procedure TVCLPythiaAdapter.SetServiceAdapter(
  const Value: IChatManagedItemDialogService);
begin
  FServiceAdapter := Value;
  FEventManager.SetServiceAdapter(FServiceAdapter);
end;

{ TVCLPythiaChatSessionManager }

function TVCLPythiaChatSessionManager.ChatSessionAdd(const ID,
  Text: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(FILES_DRAWER_ADD_ITEM, [Id, Text]),
    'files-drawer-add-item'
  );
end;

procedure TVCLPythiaChatSessionManager.ChatSessionAutoRename(
  const ID: string;
  const Content: string);
var
  Title: string;
begin
  if not Assigned(FOnChatSessionAutoRename) then
    Exit;

  if not Assigned(PersistentChat) then
    Exit;

  if ID.Trim.IsEmpty or not PersistentChat.TryToGetTitleById(ID, Title) then
    Exit;

  if not SameText(Title, 'New Chat') then
    Exit;

  FOnChatSessionAutoRename(ID, Content);
end;

function TVCLPythiaChatSessionManager.ChatSessionDrawerClear: Boolean;
begin
  Result := PostWebMessageAsJson(
    FILE_DRAWER_CLEAR,
    'files-drawer-clear'
  );
end;

function TVCLPythiaChatSessionManager.ChatSessionDrawerClose: Boolean;
begin
  Result := PostWebMessageAsJson(
    FILE_DRAWER_CLOSE,
    'files-drawer-close'
  );
end;

function TVCLPythiaChatSessionManager.ChatSessionDrawerOpen: Boolean;
begin
  Result := PostWebMessageAsJson(
    FILE_DRAWER_OPEN,
    'files-drawer-open'
  );
end;

function TVCLPythiaChatSessionManager.ChatSessionRemove(
  const Id: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(FILES_DRAWER_REMOVE_ITEM, [Id]),
    'files-drawer-remove-item'
  );
end;

function TVCLPythiaChatSessionManager.ChatSessionRename(const Id,
  ATitle: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(FILES_DRAWER_RENAME_ITEM, [Id, ATitle]),
    'files-drawer-rename-item'
  );
end;

function TVCLPythiaChatSessionManager.ChatSessionToTop(
  const Id: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(FILES_DRAWER_SET_TOPITEM, [Id]),
    'files-drawer-set-topitem'
  );
end;

function TVCLPythiaChatSessionManager.ChatSessionUnselect: Boolean;
begin
  Result := PostWebMessageAsJson(
    FILES_DRAWER_ITEM_UNSELECT,
    'files-drawer-item-unselect');
end;

constructor TVCLPythiaChatSessionManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLastPageId := '';
  FPageSize := PAGE_SIZE_VALUE;
  FFirstPage := True;
  FPersistentChat := TPersistentChatFactory.CreatePersistentChat(GetChatSessionsFileName);
  FPersistentChat.LocalFileName := TPath.GetFullPath(GetChatSessionsFileName);

  FChatListPage := Default(TChatListPage);

  {--- Prime the first page of chat summaries during session initialization. }
  SettingsPanelLoadPage;
end;

function TVCLPythiaChatSessionManager.GetOnChatSessionAutoRename: TProc<string, string>;
begin
  Result := FOnChatSessionAutoRename;
end;

function TVCLPythiaChatSessionManager.GetOnAfterSessionReloaded: TProc<string>;
begin
  Result := FOnAfterSessionReloaded;
end;

function TVCLPythiaChatSessionManager.GetOnNewChatRequested: TProc;
begin
  Result := FOnNewChatRequested;
end;

function TVCLPythiaChatSessionManager.GetPersistentChat: IPersistentChat;
begin
  Result := FPersistentChat;
end;

procedure TVCLPythiaChatSessionManager.SessionAutoRename(const Id,
  ATitle: string);
begin
  ChatSessionRename(ID, ATitle);
  PersistentChat.UpdateChatTitleById(ID, ATitle);
  PersistentChat.SaveToFile();
end;

procedure TVCLPythiaChatSessionManager.SetOnChatSessionAutoRename(
  const Value: TProc<string, string>);
begin
  FOnChatSessionAutoRename := Value;
end;

procedure TVCLPythiaChatSessionManager.SetOnAfterSessionReloaded(
  const Value: TProc<string>);
begin
  FOnAfterSessionReloaded := Value;
end;

procedure TVCLPythiaChatSessionManager.SetOnNewChatRequested(
  const Value: TProc);
begin
  FOnNewChatRequested := Value;
end;

procedure TVCLPythiaChatSessionManager.SetPersistentChat(
  const Value: IPersistentChat);
begin
  FPersistentChat := Value;
end;

function TVCLPythiaChatSessionManager.SettingsPanelLoadPage: Boolean;
begin
  if not Assigned(FPersistentChat) then
    Exit(False);

  Result := True;
  FChatListPage := FPersistentChat.GetRecentChatSummaries(FPageSize, FLastPageId);
  FLastPageId := FChatListPage.LastId;
end;

{ TVCLPythiaLockServices }

constructor TVCLPythiaLockServices.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLocked := False;
  FEscape := False;
end;

function TVCLPythiaLockServices.GetEscape: Boolean;
begin
  Result := FEscape;
end;

function TVCLPythiaLockServices.GetLocked: Boolean;
begin
  Result := FLocked;
end;

function TVCLPythiaLockServices.LogoAnimationHide: Boolean;
begin
  Result := ExecuteScript(LOGO_ANIMATION_HIDE);
end;

function TVCLPythiaLockServices.LogoAnimationShow: Boolean;
begin
  Result := ExecuteScript(LOGO_ANIMATION_SHOW);
end;

procedure TVCLPythiaLockServices.SetEscape(const Value: Boolean);
begin
  FEscape := Value;
end;

procedure TVCLPythiaLockServices.SetLocked(const Value: Boolean);
const
  TOGGLE: array[Boolean] of string = ('input', 'stop');
begin
  FLocked := Value;
  PostWebMessageAsJson(
    Format(SENDBTN_STATE_TEMPLATE, [TOGGLE[FLocked]]),
    'sendbtn-state'
  );

  if FLocked then
    LogoAnimationShow
  else
    LogoAnimationHide;

  Sleep(100);
end;

{ TVCLPythiaScrollManager }

function TVCLPythiaScrollManager.GetHeightAfter(Bias: Integer): Integer;
begin
  {--- Compute the remaining viewport height used as a scroll target offset. }
  if Bias = 0 then
    Result := FWindowParent.Height - Trunc(FWindowParent.Height * CLEAR_RATE)
  else
    Result := FWindowParent.Height - Bias;

  if Result < 0 then
    Result := 0;
end;

function TVCLPythiaScrollManager.GetScrollButtonsVisible: Boolean;
begin
  Result := FScrollButtonsVisible;
end;

procedure TVCLPythiaScrollManager.ScrollButtonsVisible(Value: Boolean);
begin
  ExecuteScript(
    Format(SCROLL_BUTTONS_VISIBLE, [TCastHelp.BoolToStr(Value)])
  );
end;

procedure TVCLPythiaScrollManager.ScrollToAfterEnd(Smooth: Boolean);
begin
  ScrollToAfterEnd(GetHeightAfter(0), Smooth);
end;

procedure TVCLPythiaScrollManager.ScrollToEnd(Smooth: Boolean);
begin
  if Smooth then
    ExecuteScript(SCROLL_TO_END_SMOOTH_TEMPLATE)
  else
    ExecuteScript(SCROLL_TO_END_TEMPLATE);
end;

procedure TVCLPythiaScrollManager.ScrollToTop(Smooth: Boolean);
begin
  if Smooth then
    ExecuteScript(SCROLL_TO_TOP_SMOOTH_TEMPLATE)
  else
    ExecuteScript(SCROLL_TO_TOP_TEMPLATE);
end;

procedure TVCLPythiaScrollManager.SetScrollButtonsVisible(
  const Value: Boolean);
begin
  FScrollButtonsVisible := Value;
  ScrollButtonsVisible(Value);
end;

procedure TVCLPythiaScrollManager.ScrollToAfterEnd(SizeAfter: Integer;
  Smooth: Boolean);
var
  ScrollCmd: string;
begin
  if Smooth then
    ScrollCmd := SCROLL_SMOOTH_TEMPLATE
  else
    ScrollCmd := SCROLL_TEMPLATE;

  ExecuteScript(
    Format(SCROLL_AFTER_END_SCRIPT_TEMPLATE, [SizeAfter, ScrollCmd])
  );
end;

{ TVCLPythia }

constructor TVCLPythia.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

end;

procedure TVCLPythia.Initialize;
begin
  {--- Inject this browser into the API key service so the ApiKey command
       plugin can reach BrowserInput to prompt the user. }
  ApiKeyService.Browser := Self;

  {--- Initialize custom line commands  }
  if Assigned(FOnRegisterCommandPlugins) then
    FOnRegisterCommandPlugins();

  {--- Load the capabilities descriptor from disk (create it with defaults
       if missing) and synchronize backend / frontend capability state. }
  CapabilitiesInitialization;

  {--- Restore the persisted project list into the input project menu. }
  ProjectsInitialization;

  {--- Reload or create general application settings (look & feel, language...)
       and push them into the settings panel UI. }
  var FileName := GetParamsMainValuesFileName;
  if not FileExists(FileName) then
    SaveDefaultValues;

  var AppsConfig := TFileIOHelper.LoadFromFile(FileName);
  SettingsPanelUpdateApplicationSettings(AppsConfig);

  {--- We reload all the digital parameters: temperature, top-p, system prompt... }
  FileName := GetParamsConfigFileName;
  if FileExists(FileName) then
    begin
      var ParamsConfig := TFileIOHelper.LoadFromFile(FileName);
      SettingsPanelInitializeFullState(ParamsConfig);
    end
  else
    {--- Force the creation of a local file with default settings for prompt data }
    SettingsPanelGetValues;

  {--- We initialize the list of sessions saved in the file drawer }
  UpdateFileDrawer;

  {--- Focus is assigned to the input area of the input bubble }
  SetFocus;

  {--- On first launch only (no persisted main-values file), force the UI
       language to English. After that the language comes from settings. }
  if FDefaultLangage then
    SetLanguage('english-us');

  {--- Ensure the model list file exists (create it with default content if
       missing) and push the category / model selection to the UI. }
  ModelInitialize;

  {--- Reflect the current FEnabledButtons set in the input bubble
       (audio / function / settings buttons visibility). }
  UpdateEnabledButtons;

  {--- A message is placed in the label of the input bubble. }
  BubbleInputWelcome(S_WELCOME);

  if Assigned(FOnInitialized) then
    FOnInitialized();
end;

class function TVCLPythia.Version: string;
begin
  Result := Format('%s %s', [Pythia.Webview2.VERSION, Pythia.Webview2.STATUS]);
end;

{ TVCLPythiaSettingsPanel }

function TVCLPythiaSettingsPanel.SettingsPanelForceLanguageSelection(
  const JsonAsString: string): Boolean;
begin
  Result := PostWebMessageAsJson(JsonAsString, 'set-language');
end;

function TVCLPythiaSettingsPanel.SettingsPanelInitializeFullState(const JsonAsString: string): Boolean;
begin
  Result := PostWebMessageAsJson(JsonAsString, 'request-initialization');
end;

function TVCLPythiaSettingsPanel.SettingsPanelRequestCurrentSettingsState: Boolean;
begin
  Result := PostWebMessageAsJson(SETTINGS_PANEL_GET_VALUES, 'request-params-get-values');
end;

function TVCLPythiaSettingsPanel.SettingsPanelUpdateApplicationSettings(
  const JsonAsString: string): Boolean;
begin
  Result := PostWebMessageAsJson(JsonAsString, 'request-params-main-values');
end;

function TVCLPythiaSettingsPanel.SettingsPanelUpdatePropertiesByFullPath(
  const JsonAsString: string): Boolean;
begin
  Result := PostWebMessageAsJson(JsonAsString, 'request-params-update');
end;

function TVCLPythiaSettingsPanel.SettingsPanelGetValues: Boolean;
begin
  Result := ExecuteScript(SETTING_PANEL_GET_VALUES);
end;

function TVCLPythiaSettingsPanel.SettingsPanelHide: Boolean;
begin
  Result := PostWebMessageAsJson(SETTINGS_PANEL_HIDE, 'request-params-hide');
end;

function TVCLPythiaSettingsPanel.SettingsPanelShowPage(const Page: Integer): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(SETTINGS_PANEL_SHOW, [Page]),
    'request-params-show'
  );
end;

{ TVCLPythiaLanguageManager }

constructor TVCLPythiaLanguageManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnTranslationsLoaded := nil;
end;

function TVCLPythiaLanguageManager.GetDictionaryFileName(
  const Value: string;
  out Dictionary: string): Boolean;
begin
  Dictionary := GetLanguageFolder + '\' + Value + '.json';
  Result := FileExists(Dictionary);
end;

function TVCLPythiaLanguageManager.GetLocalLanguage: string;
begin
  Result := FLocalLanguage;
end;

function TVCLPythiaLanguageManager.GetNormalizedFileNames: string;
begin
  var Files := TFileIOHelper.GetFileNames(GetLanguageFolder, '*.json');
  Files := TFileIOHelper.RemoveExtensionsAsJsonString(Files);
  Result := string.Join(',', Files);
end;

function TVCLPythiaLanguageManager.LoadDictionaryContent(
  const FileName: string): string;
begin
  Result := TFileIOHelper.LoadFromFile(FileName);

  {--- Message string translation }
  TStringTranslation.FromLanguageContent(Result, FOnTranslationsLoaded);
end;

procedure TVCLPythiaLanguageManager.SetLanguage(const Value: string);
begin
  LocalLanguage := Value;
  BubbleInputWelcome(S_WELCOME);
end;

procedure TVCLPythiaLanguageManager.SetLocalLanguage(const Value: string);
var
  FileName: string;
begin
  {--- Construct the file name and verify its existence. }
  if not GetDictionaryFileName(Value, FileName) then
    Exit;

  FLocalLanguage := Value;
  var Dictionary := LoadDictionaryContent(FileName);

  SettingsPanelForceLanguageSelection(
    Format(SETTINGS_PANEL_SET_LANGUAGE, [Dictionary, FLocalLanguage])
  );
end;

{ TVCLPythiaAppSettings }

procedure TVCLPythiaAppSettings.SaveDefaultValues;
begin
  SettingsPanelSaveAppSettings;
end;

procedure TVCLPythiaAppSettings.SettingsPanelSaveAppSettings;
begin
  var JSON := Format(APP_SETTINGS_TEMPLATE, [
    FTheme,
    GetNormalizedFileNames,
    LocalLanguage,
    BoolToStr(LocalScrollButtonsVisible, True).ToLower]
  );

  TJsonCheck.IsValid(JSON,
    procedure (Value: TJsonReader)
    begin
      TFileIOHelper.SaveToFile(GetParamsMainValuesFileName, Value.Format());
    end);
end;

{ TVCLPythiaModelsSelector }

function TVCLPythiaModelsSelector.ModelInitialize: Boolean;
begin
  if not ModelsSelectorSetModelList then
    Exit(False);

  Result := ModelsSelectorCategoryAdd;
end;

function TVCLPythiaModelsSelector.ModelListFileCheck: Boolean;
begin
  if FileExists(GetModelListFileName) then
    Exit(True);

  var WarningMessage :=
        Format(
          S_MODEL_FILE_NOT_FOUND_FMT,
          [ExtractFileName(GetModelListFileName)]
        );

  if IsJSScriptInjected then
    DisplayWarning(WarningMessage);

  {--- Create file with default didactic content. }
  Result := ModelSetDefaultContentIntoFile;
end;

function TVCLPythiaModelsSelector.ModelSetDefaultContentIntoFile: Boolean;
begin
  TFileIOHelper.SaveToFile(GetModelListFileName, JSON_MODELS_DEFAULT);
  Result := True;
end;

function TVCLPythiaModelsSelector.ModelsSelectorCategoryAdd: Boolean;
begin
  if not FileExists(GetModelCategoriesFileName) then
    Exit(False);

  var JSON := TFileIOHelper.LoadFromFile(GetModelCategoriesFileName);
  Result := PostWebMessageAsJson(JSON);
end;

function TVCLPythiaModelsSelector.ModelsSelectorCategoryVisible(
  const Category: string; const Visible: Boolean): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(MODEL_CATEGORY_VISIBILITY, [Category, TCastHelp.BoolToStr(Visible)]),
    'models-category-visibility'
  );
end;

function TVCLPythiaModelsSelector.ModelsSelectorGetReplaceVersion: Boolean;
begin
  Result := PostWebMessageAsJson(
    MODEL_GET_REPLACE_VERSION,
    'model-selector-get-replace-version'
  );
end;

function TVCLPythiaModelsSelector.ModelsSelectorHide: Boolean;
begin
  Result := ExecuteScript(MODEL_SELECTOR_PANEL_HIDE);
end;

function TVCLPythiaModelsSelector.ModelsSelectorSetModelList: Boolean;
begin
  if not ModelListFileCheck then
//    ModelSetDefaultContentIntoFile;
      Exit(False);

  var JsonString := TFileIOHelper.LoadFromFile(GetModelListFileName);
  Result := PostWebMessageAsJson(JsonString, 'model-selector-set-data');
end;

function TVCLPythiaModelsSelector.ModelsSelectorShow: Boolean;
begin
  Result := ExecuteScript(MODEL_SELECTOR_PANEL_SHOW);
end;

{ TVCLPythiaCardSelector }

procedure TVCLPythiaCardSelector.CardsContentCreateDefaultFiles;
begin
  for var Item := Low(TAdapterManagedItemKind) to High(TAdapterManagedItemKind) do
    begin
      var KindAsString := Item.ToString;
      if not SameText(KindAsString, 'none') then
        JSONCardContentDefaultCreate(KindAsString);
    end;
end;

function TVCLPythiaCardSelector.CardSelectorHide: Boolean;
begin
  Result := PostWebMessageAsJson(CARD_SELECTION_DIALOG_HIDE);
end;

function TVCLPythiaCardSelector.CardSelectorSetData(const JsonString: string): Boolean;
begin
  Result := PostWebMessageAsJson(JsonString, 'card-selection-dialog-set-data');
end;

function TVCLPythiaCardSelector.CardSelectorShow(const Dialog: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(CARD_SELECTION_DIALOG_SHOW, [Dialog]),
    'card-selection-dialog-show'
  );
end;

function TVCLPythiaCardSelector.CardSettingsButtonVisible(
  const Value: Boolean): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(CARD_SETTINGS_VISIBILITY, [TCastHelp.BoolToStr(Value)])
  );
end;

constructor TVCLPythiaCardSelector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CardsContentCreateDefaultFiles;
end;

function TVCLPythiaCardSelector.FilenameRetrieve(
  const AType: string): string;
var
  LType: TChatManagedItemKind;
begin

  TChatManagedItemKind.TryToParse(AType, LType);

  case LType of
    TChatManagedItemKind.function:
      Result := GetFunctionCardsFileName;
    TChatManagedItemKind.mcp:
      Result := GetMcpCardsFileName;
    TChatManagedItemKind.skills:
      Result := GetSkillCardsFileName;
    TChatManagedItemKind.agents:
      Result := GetAgentCardsFileName;
    TChatManagedItemKind.custom:
      Result := GetCustomCardsFileName;
    TChatManagedItemKind.none:
      Result := '';
  end;
end;

procedure TVCLPythiaCardSelector.JSONCardContentDefaultCreate(
  const AType: string);
var
  LType: TChatManagedItemKind;
  JsonAsString: string;
begin

  TChatManagedItemKind.TryToParse(AType, LType);

  case LType of
    TChatManagedItemKind.function:
      JsonAsString := Format(JSON_CARD_DEFAULT_FMT, ['function', 'function-cards', 'function']);

    TChatManagedItemKind.mcp:
      JsonAsString := Format(JSON_CARD_DEFAULT_FMT, ['mcp', 'mcp-cards', 'mcp']);

    TChatManagedItemKind.skills:
      JsonAsString := Format(JSON_CARD_DEFAULT_FMT, ['skills', 'skill-cards', 'skills']);

    TChatManagedItemKind.agents:
      JsonAsString := Format(JSON_CARD_DEFAULT_FMT, ['agents', 'agent-cards', 'agents']);

    TChatManagedItemKind.custom:
      JsonAsString := Format(JSON_CARD_DEFAULT_FMT, ['custom', 'custom-cards', 'custom']);

    TChatManagedItemKind.none: ;
  end;

  var FileName := FilenameRetrieve(AType);

  if not FileExists(Filename) and not JsonAsString.IsEmpty and not Filename.IsEmpty then
    TFileIOHelper.SaveToFile(Filename, JsonAsString);
end;

function TVCLPythiaCardSelector.TryGetCardFileContent(const AType: string;
  ParamProc: TFunc<string, Boolean>): Boolean;
begin
  var Filename := FilenameRetrieve(AType);

  if FileName.IsEmpty or not FileExists(Filename) then
    begin
      DisplayWarning(Format(S_CARD_JSON_FILE_NOT_FOUND, [AType]));

      {--- Create a JSON file with default content }
      JSONCardContentDefaultCreate(AType.ToLower);
      Exit(False);
    end;

  if not Assigned(ParamProc) then
    Exit(False);

  var Content := TFileIOHelper.LoadFromFile(FileName);

  Result := ParamProc(Content);
end;

{ TVCLPythiaInputBubble }

function TVCLPythiaInputBubble.BubbleInputAudioButtonVisible(
  const Value: Boolean): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(AUDIO_BUTTON_ENABLE, [TCastHelp.BoolToStr(Value)]),
    'setInputButtonsVisibility'
  );
end;

function TVCLPythiaInputBubble.BubbleInputClear: Boolean;
begin
  Result := ExecuteScript(INPUT_BUBBLE_RESET_TEMPLATE);
end;

function TVCLPythiaInputBubble.BubbleInputFunctionButtonVisible(
  const Value: Boolean): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(FUNCTION_BUTTON_ENABLE, [TCastHelp.BoolToStr(Value)]),
    'setInputButtonsVisibility'
  );
end;

function TVCLPythiaInputBubble.BubbleInputMenuClose: Boolean;
begin
  Result := ExecuteScript(CLOSE_INPUT_MAIN_MENU_TEMPLATE);
end;

function TVCLPythiaInputBubble.BubbleInputMenuOpen: Boolean;
begin
  Result := ExecuteScript(OPEN_INPUT_MAIN_MENU_TEMPLATE);
end;

function TVCLPythiaInputBubble.BubbleInputPartialReset: Boolean;
begin
  Result := ExecuteScript(INPUT_PARTIAL_RESET);
end;

function TVCLPythiaInputBubble.BubbleInputSetText(
  const Value: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(SET_INPUT_TEXT, [Value]),
    'setInputText'
  );
end;

function TVCLPythiaInputBubble.BubbleInputInsertText(
  const Value: string): Boolean;
begin
  {--- Insert at the caret (not a full replacement). The text is escaped to a
       safe JS string literal, so quotes/newlines/accents in a transcription
       cannot break the call. }
  Result := ExecuteScript(
    Format(INPUT_BUBBLE_INSERT_TEXT_TEMPLATE, [TEscapeHelper.EscapeJSString(Value)])
  );
end;

function TVCLPythiaInputBubble.BubbleInputWelcome(
  const Value: string): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(SET_INPUT_WELCOME, [Value]),
    'setInputWelcome'
  );
end;

constructor TVCLPythiaInputBubble.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabledButtons := [ebSettings];
end;

function TVCLPythiaInputBubble.GetEnabledButtons: TEnabledButtons;
begin
  Result := FEnabledButtons;
end;

procedure TVCLPythiaInputBubble.SetEnabledButtons(
  const Value: TEnabledButtons);
begin
  FEnabledButtons := Value;
  UpdateEnabledButtons;
end;

{ TVCLPythiaReasoningComponent }

function TVCLPythiaReasoningComponent.ReasoningCollapse: Boolean;
begin
  Result := ExecuteScript(COLLAPSE_REASONING_TEMPLATE);
end;

function TVCLPythiaReasoningComponent.ReasoningExpand: Boolean;
begin
  Result := ExecuteScript(EXPAND_REASONING_TEMPLATE);
end;

function TVCLPythiaReasoningComponent.ReasoningHide: Boolean;
begin
  BubbleInputPartialReset;

  if not FBrowserInitialized or not FReasoningVisible then
    Exit(False);

  try
    if not FBrowserInitialized then
      Exit(False);

    Result := ExecuteScript(HIDE_REASONING_TEMPLATE);

  finally
    FReasoningVisible := False;
  end;
end;

function TVCLPythiaReasoningComponent.ReasoningShow: Boolean;
begin
  if FReasoningVisible then
    Exit(False);

  if not FBrowserInitialized then
    Exit(False);

  Result := ExecuteScript(TemplateProvider.ReasoningTemplate);

  FReasoningVisible := Result;
end;

function TVCLPythiaReasoningComponent.ReasoningToggle: Boolean;
begin
  Result := ExecuteScript(TOGGLE_REASONING_TEMPLATE);
end;

{ TVCLPythiaAPIKeyManager }

procedure TVCLPythiaAPIKeyManager.ApiKeyValuesUpdate(const KeyName: string);
begin
  if Assigned(FOnApiKeyChanged) then
    FOnApiKeyChanged(KeyName);
end;

constructor TVCLPythiaAPIKeyManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FApiKeySecretStore := TSecretStore.Create;

  if FileExists(GetAPIKeyNamesFileName) then
    ApiKeyNamesAsJsonString := TFileIOHelper.LoadFromFile(GetAPIKeyNamesFileName);
end;

function TVCLPythiaAPIKeyManager.GetApiKeyNamesAsJsonString: string;
begin
  Result := FApiKeyNamesAsJsonString;
end;

function TVCLPythiaAPIKeyManager.GetApiKeySecretStore: ISecretStore;
begin
  Result := FApiKeySecretStore;
end;

procedure TVCLPythiaAPIKeyManager.SetApiKeyNamesAsJsonString(
  const Value: string);
begin
  if Value.Trim.IsEmpty then
    FApiKeyNamesAsJsonString := '{}'
  else
    FApiKeyNamesAsJsonString := Value;

  TFileIOHelper.SaveToFile(GetAPIKeyNamesFileName, FApiKeyNamesAsJsonString);
end;

procedure TVCLPythiaAPIKeyManager.SetApiKeySecretStore(
  const Value: ISecretStore);
begin
  FApiKeySecretStore := Value;
end;

{ TVCLPythiaFileUploadManager }

function TVCLPythiaFileUploadManager.GetFileUploadService: IFileUploadService;
begin
  Result := FFileUploadService;
end;

procedure TVCLPythiaFileUploadManager.SetFileUploadService(
  const Value: IFileUploadService);
begin
  FFileUploadService := Value;
end;

function TVCLPythiaFileUploadManager.SetFileUploadStatus(const APath, AStatus,
  AFileId, AErrorMessage: string): Boolean;
begin
  Result := ExecuteScript(
    Format(FILE_UPLOAD_STATUS_TEMPLATE, [
      APath,
      AStatus,
      AFileId,
      AErrorMessage
    ])
  );
end;

function TVCLPythiaFileUploadManager.SetSendButtonAvailability(
  const AEnabled: Boolean): Boolean;
begin
  Result := ExecuteScript(
    Format(SEND_BUTTON_AVAILABILITY_TEMPLATE, [TCastHelp.BoolToStr(AEnabled)])
  );
end;

{ TVCLPythiaKnowledgeIndexingManager }

function TVCLPythiaKnowledgeIndexingManager.GetKnowledgeIndexingService: IKnowledgeIndexingService;
begin
  Result := FKnowledgeIndexingService;
end;

procedure TVCLPythiaKnowledgeIndexingManager.SetKnowledgeIndexingService(
  const Value: IKnowledgeIndexingService);
begin
  FKnowledgeIndexingService := Value;
end;

function TVCLPythiaKnowledgeIndexingManager.GetAudioTranscriptionService: IAudioTranscriptionService;
begin
  Result := FAudioTranscriptionService;
end;

procedure TVCLPythiaKnowledgeIndexingManager.SetAudioTranscriptionService(
  const Value: IAudioTranscriptionService);
begin
  FAudioTranscriptionService := Value;
end;

function TVCLPythiaKnowledgeIndexingManager.RecomputeSendButtonAvailability: Boolean;
var
  Pending: Integer;
begin
  Pending := 0;

  if Assigned(FFileUploadService) then
    Inc(Pending, FFileUploadService.PendingCount);

  if Assigned(FKnowledgeIndexingService) then
    Inc(Pending, FKnowledgeIndexingService.PendingCount);

  Result := SetSendButtonAvailability(Pending = 0);
end;

{ TVCLPythiaInputValue }

function TVCLPythiaInputValue.BrowserInput(const AMessage, AKey, AValue,
  ADefault: string; const Hidden: Boolean): Boolean;
begin
  Result := PostWebMessageAsJson(
    Format(INPUT_STRING, [
      AMessage, AKey, AValue, ADefault, TCastHelp.BoolToStr(Hidden)
    ]),
    'input-string'
  );
end;

function TVCLPythiaInputValue.BrowserInput(const AMessage, AKey,
  ADefault: string): Boolean;
begin
  Result := BrowserInput(
    AMessage,
    AKey,
    '',
    ADefault
  );
end;

function TVCLPythiaInputValue.BrowserInput(const AMessage, AKey: string;
  const Hidden: Boolean): Boolean;
begin
  Result := BrowserInput(AMessage, AKey, '', '', Hidden);
end;

{ TVCLPythiaCommandLine }

procedure TVCLPythiaCommandLine.CommandLineInitialize;
begin
  FCommandLine.RegisterPlugin(TApiKeyPlugin.Create(FApiKeyService));
  {--- Custom command are initialized with the FOnRegisterCommandPlugins}
end;

constructor TVCLPythiaCommandLine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FApiKeyService := TApiKeyService.Create;
  FCommandLine := TCommandRegistry.Create;
  CommandLineInitialize;
end;

procedure TVCLPythiaCommandLine.DispatchCommand(
  const ACommandResult: TCommandResult);
begin
  var ExecRes := CommandLine.Execute(ACommandResult);
  if ExecRes.Success then
    BubbleInputPartialReset
  else
    DisplayError(ExecRes.Message);
end;

function TVCLPythiaCommandLine.GetApiKeyService: IApiKeyService;
begin
  Result := FApiKeyService;
end;

function TVCLPythiaCommandLine.GetCommandLine: ICommandRegistry;
begin
  Result := FCommandLine;
end;

procedure TVCLPythiaCommandLine.SetApiKeyService(const Value: IApiKeyService);
begin
  FApiKeyService := Value;
end;

procedure TVCLPythiaCommandLine.SetCommandLine(const Value: ICommandRegistry);
begin
  FCommandLine := Value;
end;

function TVCLPythiaCommandLine.TryHandleAsCommand(
  const PromptText: string): Boolean;
var
  CommandResult: TCommandResult;
begin
  CommandLine.Validate(PromptText, CommandResult);

  case CommandResult.Status of
    csNotACommand:
      Exit(False);
    csOk:
      DispatchCommand(CommandResult);
  else
    DisplayError(CommandResult.Message);
  end;

  Result := True;
end;

{ TVCLPythiaPath }

function TVCLPythiaPath.GetAgentCardsFileName: string;
begin
  Result := GetSupportRawName + '-agent-cards.json';
end;

function TVCLPythiaPath.GetAPIKeyNamesFileName: string;
begin
  Result := GetRawName + '-api-key-names.json';
end;

function TVCLPythiaPath.GetAppJsonSupportFolder: string;
begin
  Result := System.IOUtils.TPath.Combine(
    System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), GetAppRawName),
    SUPPORT_JSON_FOLDER
  );
end;

function TVCLPythiaPath.GetAppRawName: string;
begin
  Result := ChangeFileExt(ExtractFileName(ParamStr(0)),'');
end;

function TVCLPythiaPath.GetAppSubFolder: string;
begin
  Result := System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), GetAppRawName);
end;

function TVCLPythiaPath.GetAssetsFolder: string;
begin
  Result := System.IOUtils.TPath.GetFullPath(
    System.IOUtils.TPath.Combine(ExtractFilePath(ParamStr(0)), TEMPLATE_PATH)
  );
end;

function TVCLPythiaPath.GetCapabilitiesFileName: string;
begin
  Result := GetSupportRawName + '-capabilities.json';
end;

function TVCLPythiaPath.GetChatSessionsFileName: string;
begin
  Result := GetRawName + '-chat-sessions.json';
end;

function TVCLPythiaPath.GetCustomCardsFileName: string;
begin
  Result := GetSupportRawName + '-custom-cards.json';
end;

function TVCLPythiaPath.GetCustomJSFileName: string;
begin
  Result := GetSupportRawName + '-custom-template-js.json';
end;

function TVCLPythiaPath.GetExchangeDebugFileName: string;
begin
  Result := GetRawName + '-exchange-debug.json';
end;

function TVCLPythiaPath.GetFunctionCardsFileName: string;
begin
  Result := GetSupportRawName + '-function-cards.json';
end;

function TVCLPythiaPath.GetLanguageFolder: string;
begin
  Result := System.IOUtils.TPath.Combine(GetAssetsFolder, LANGUAGE_FOLDER);
end;

function TVCLPythiaPath.GetMcpCardsFileName: string;
begin
  Result := GetSupportRawName + '-mcp-cards.json';
end;

function TVCLPythiaPath.GetMediaFolder: string;
begin
  Result := System.IOUtils.TPath.Combine(GetAssetsFolder, MEDIA_FOLDER);
end;

function TVCLPythiaPath.GetModelCategoriesFileName: string;
begin
  Result := GetRawName + '-model-get-replace-version.json';
end;

function TVCLPythiaPath.GetModelListFileName: string;
begin
  Result := GetSupportRawName + '-model-list.json';
end;

function TVCLPythiaPath.GetParamsConfigFileName: string;
begin
  Result := GetRawName + '-request-params-config.json';
end;

function TVCLPythiaPath.GetParamsMainValuesFileName: string;
begin
  Result := GetRawName + '-request-params-main-values.json';
end;

function TVCLPythiaPath.GetProjectsFileName: string;
begin
  Result := GetSupportRawName + '-projects.json';
end;

function TVCLPythiaPath.GetRawName: string;
begin
  Result := System.IOUtils.TPath.Combine(GetAppRawName, GetAppRawName);
end;

function TVCLPythiaPath.GetSkillCardsFileName: string;
begin
  Result := GetSupportRawName + '-skill-cards.json';
end;

function TVCLPythiaPath.GetSupportRawName: string;
begin
  Result := System.IOUtils.TPath.Combine(GetAppJsonSupportFolder, GetAppRawName);
end;

function TVCLPythiaPath.ParamsMainValuesFileNameExists: Boolean;
begin
  Result := FileExists(GetParamsMainValuesFileName);
end;

{ TVCLPythiaCustomPanels }

function TVCLPythiaCustomPanels.GetCustomPanels: TCustomPanels;
begin
  Result := FCustomPanels;
end;

procedure TVCLPythiaCustomPanels.SetCustomPanels(const Value: TCustomPanels);
begin
  FCustomPanels := Value;
end;

{ TVCLPythiaCustomJSTemplate }

constructor TVCLPythiaCustomJSTemplate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCustomJSTemplate := [];
  TryToLoadCustomTemplates;
end;

procedure TVCLPythiaCustomJSTemplate.TryToLoadCustomTemplates;
begin
  var Filename := GetCustomJSFileName;

  if not FileExists(Filename) then
    begin
      TFileIOHelper.SaveToFile(Filename, JSON_CUSTOM_TEMPLATE_JS_DEFAULT);
      Exit;
    end;

  var Content := TFileIOHelper.LoadFromFile(Filename);
  var Reader := TJsonReader.Parse(Content);
  if not Reader.IsValid or not Reader.IsArrayNode('template_filename') then
    raise EVCLPythiaException.CreateFmt('%s: invalid JSON content', [Filename]);

  FCustomJSTemplate := Reader.ArrayStrings('template_filename');
  for var Item in FCustomJSTemplate do
    begin
      if not FileExists(Item) then
        raise EVCLPythiaException.CreateFmt('%s: file not found', [Item]);
    end;
end;

{ TVCLPythiaClipboard }

constructor TVCLPythiaClipboard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FClipboard := TVclClipboardReader.Create;
end;

function TVCLPythiaClipboard.GetClipboard: IClipboardReader;
begin
  Result := FClipboard;
end;

procedure TVCLPythiaClipboard.SetClipboard(const Value: IClipboardReader);
begin
  FClipboard := Value;
end;

initialization
  {--- Initialize the shared WebView2 loader once for the whole process
       and keep its user data in an application-local cache folder. }
  GlobalWebView2Loader := TWVLoader.Create(nil);
  GlobalWebView2Loader.UserDataFolder := ExtractFileDir(Application.ExeName) + '\CustomCache';
  GlobalWebView2Loader.StartWebView2;
end.

