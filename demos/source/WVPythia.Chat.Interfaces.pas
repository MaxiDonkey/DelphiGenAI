unit WVPythia.Chat.Interfaces;

interface

uses
  System.SysUtils, WVPythia.Types, WVPythia.Chat.DecisionDlg,
  WVPythia.ChatSession.Controller, WVPythia.Command.Parser;

type
  TClipboardTextKind = (
    ctkInline,
    ctkTempFile
  );

  TClipboardTextData = record
    Kind: TClipboardTextKind;
    Text: string;
    FileName: string;
  end;

  IClipboardReader = interface
    ['{5EE91EF1-87FD-4544-95AB-D863F4DB7742}']
    function IsAvailable: Boolean;
    function TryGetText(out AText: TClipboardTextData): Boolean;
    function TrySaveImageToTempPng(out AFileName: string): Boolean;
    function TryGetFiles(out AFiles: TArray<string>): Boolean;
  end;

  ISecretStore = interface
    ['{0828CA5A-491F-41E5-B127-9037F22CCF79}']
    function ReadSecret(const Name: string; out Value: string; const ParamProc: TProc<string> = nil): Boolean;
    procedure WriteSecret(const Name, Value: string);
    procedure DeleteSecret(const Name: string);
  end;

  IOpenDialog = interface
    ['{4ABD78A5-4281-4930-B55A-BF6A259E914C}']
    function Execute(const Filter: string; const index: Integer; out FileName: string): Boolean;
    function ExecuteFolder(out FolderPath: string): Boolean;
  end;

  IProcessExecute = interface
    ['{CD67CA09-B39A-47F0-BFF1-5F50DFDA3A53}']
    procedure Open(const FileName: string);
  end;

  TCommandExecResult = record
    Success: Boolean;
    Message: string;
    class function Ok(const AMessage: string = ''): TCommandExecResult; static;
    class function Fail(const AMessage: string): TCommandExecResult; static;
  end;

  ICommandPlugin = interface
    ['{8F2E4A91-5C3D-4B72-A6E0-1D9F8B4C2A35}']
    function GetName: string;
    function Execute(const Action: string;
      const Args: TArray<string>): TCommandExecResult;
    property Name: string read GetName;
  end;

  ICommandRegistry = interface
    ['{45EF7138-C258-4913-9965-37885F647971}']
    function RegisterPlugin(const APlugin: ICommandPlugin): ICommandPlugin;
    function Validate(const Source: string;
      out Res: TCommandResult): Boolean;
    function Execute(const Res: TCommandResult): TCommandExecResult;
  end;

  {--- Result of a single file upload attempt, surfaced to the host through
       TUploadCompleteProc when an IFileUploadService implementation finishes
       processing a file. The record is the only piece of upload state that
       crosses the service boundary; the local path is preserved as the
       correlation key. }
  TUploadResult = record
    LocalPath: string;
    Success: Boolean;
    FileId: string;
    ErrorMessage: string;
    class function Ok(const ALocalPath, AFileId: string): TUploadResult; static;
    class function Fail(const ALocalPath, AErrorMessage: string): TUploadResult; static;
  end;

  TUploadCompleteProc = TProc<TUploadResult>;

  {--- Optional vendor-provided service used by Pythia when the host wants to
       transfer selected files asynchronously to a remote storage / Files API
       and reference them later by an opaque file id (rather than inlining
       them as document blocks).

       Lifecycle contract:
       • ShouldHandle is called synchronously on the UI thread for every
         file selected through the open dialog. The implementation decides
         per-file whether it wants to take ownership of the upload.
       • SubmitForUpload returns immediately. The actual transfer runs
         asynchronously. AOnComplete is invoked exactly once, on the UI
         thread, when this specific file is Ready or Failed. AOnComplete
         may be nil when the host only relies on TryGetFileId at submit time.
       • CancelOrDelete is called when the user removes an attachment from
         the compose box, or when the host wants to evict a previously
         uploaded file. Implementations must tolerate calls for unknown
         paths.
       • TryGetFileId is queried at submit time, just before the chat
         payload is built. It must not block.
       • PendingCount + OnPendingChanged are exposed so the host UI can
         disable the send button while at least one upload is still in
         flight. OnPendingChanged is invoked on the UI thread whenever
         PendingCount transitions to or from zero, at minimum.

       Implementations are responsible for thread-marshaling, concurrency
       control (rate limit, parallel cap) and persistence of file ids for
       later cleanup. Pythia core is intentionally agnostic of those
       concerns. }
  IFileUploadService = interface
    ['{7D4A2C8E-9F31-4E5B-B3A7-1C0E6D2F5A48}']
    function ShouldHandle(const ALocalPath: string;
                          const ATarget: TOpenFileTarget): Boolean;

    procedure SubmitForUpload(
      const ALocalPath: string;
      const ATarget: TOpenFileTarget;
      const AOnComplete: TUploadCompleteProc = nil);

    procedure CancelOrDelete(const ALocalPath: string);

    function TryGetFileId(const ALocalPath: string;
                          out AFileId: string): Boolean;

    function PendingCount: Integer;

    function GetOnPendingChanged: TProc;
    procedure SetOnPendingChanged(const Value: TProc);
    property OnPendingChanged: TProc
      read GetOnPendingChanged write SetOnPendingChanged;
  end;

  {--- Optional vendor-provided service used by Pythia when the host wants to
       index selected files into a vector store / knowledge base before they
       are referenced by the LLM through a retrieval tool (file_search,
       semantic retrieval, libraries, etc.).

       Distinction with IFileUploadService:
       • An upload is a one-shot byte transfer; its async primitive is a
         single promise resolved on completion.
       • An indexation is a multi-stage pipeline (typically: upload → ingest
         → chunk + embed → ready) whose completion is observed through
         polling or webhooks. Stage durations vary from seconds to minutes.

       Lifecycle contract:
       • ShouldHandle is called synchronously on the UI thread and only for
         TOpenFileTarget.Knowledge files. Other targets are routed to
         IFileUploadService.
       • SubmitForIndexing returns immediately. The implementation is
         responsible for any required upload step, ingestion call, and
         polling loop. AOnComplete is invoked exactly once, on the UI
         thread, when the file is fully indexed (Ready) or has failed.
         AOnComplete may be nil when the host only relies on
         TryGetIndexRef at submit time.
       • CancelOrDelete is called when the user removes a knowledge entry
         from the compose box, or when the host wants to evict a previously
         indexed file. Implementations must tolerate calls for unknown
         paths and must clean up both the staged file (if any) and the
         vector-store entry server-side.
       • TryGetIndexRef is queried at submit time, just before the chat
         payload is built. It returns the opaque reference the vendor needs
         to consume the indexed file (e.g. vector_store_id for OpenAI,
         corpus / document id for Gemini, library id for Mistral). It must
         not block.
       • PendingCount + OnPendingChanged are exposed so the host UI can
         disable the send button while at least one indexation is still in
         flight. PendingCount counts any non-terminal state across the
         whole multi-stage pipeline (queued, uploading, indexing).

       Important — Ready semantics:
         A file is Ready only when fully indexed and discoverable by the
         retrieval tool. A finished upload that has not yet been embedded
         must NOT be reported as Ready. }
  IKnowledgeIndexingService = interface
    ['{B2F84A1C-3D67-4E29-A150-9C8F0B5E7D63}']
    function ShouldHandle(const ALocalPath: string;
                          const ATarget: TOpenFileTarget): Boolean;

    procedure SubmitForIndexing(
      const ALocalPath: string;
      const ATarget: TOpenFileTarget;
      const AOnComplete: TUploadCompleteProc = nil);

    procedure CancelOrDelete(const ALocalPath: string);

    function TryGetIndexRef(const ALocalPath: string;
                            out AIndexRef: string): Boolean;

    function PendingCount: Integer;

    function GetOnPendingChanged: TProc;
    procedure SetOnPendingChanged(const Value: TProc);
    property OnPendingChanged: TProc
      read GetOnPendingChanged write SetOnPendingChanged;
  end;

  {--- Outcome of a single audio transcription attempt, surfaced to Pythia
       through TAudioTranscriptionCompleteProc once an
       IAudioTranscriptionService implementation finishes processing a capture
       file. Pythia owns the capture (vendor-agnostic); the result only carries
       the recognized text or an error. }
  TAudioTranscriptionResult = record
    Success: Boolean;
    Text: string;
    ErrorMessage: string;
    class function Ok(const AText: string): TAudioTranscriptionResult; static;
    class function Fail(const AErrorMessage: string): TAudioTranscriptionResult; static;
  end;

  TAudioTranscriptionCompleteProc = TProc<TAudioTranscriptionResult>;

  {--- Optional vendor-provided service used by Pythia to turn a browser-side
       audio capture file into text. The microphone capture, the temporary
       file production and the placement of the resulting text in the input
       bubble are all handled by Pythia and remain vendor-neutral; the vendor
       only implements the speech-to-text step.

       Lifecycle contract:
       • SubmitForTranscription is called by Pythia on the UI thread once a
         capture file is ready on disk (see AudioRecordEvent). It returns
         immediately; the actual transcription may run asynchronously.
       • AOnComplete is invoked exactly once, on the UI thread, with the
         recognized text (Success) or an error (Fail). It may be nil when the
         host does not need the result.
       • Implementations must tolerate being called for a path they cannot
         process and must report it through TAudioTranscriptionResult.Fail
         rather than raising. }
  IAudioTranscriptionService = interface
    ['{7C1F3A92-6B4D-4E18-9A2C-3D5E8F0B1A74}']
    procedure SubmitForTranscription(
      const AAudioFilePath: string;
      const AOnComplete: TAudioTranscriptionCompleteProc = nil);
  end;

  {--- Vendor-neutral snapshot of streamed display blocks. Implementations can
       keep their own live aggregation strategy, but must expose cloned Pythia
       blocks for persistence/replay at turn finalization time. }
  IPythiaDisplayBlockSnapshot = interface
    ['{D2711A7D-857C-4FA8-9A52-7E99D5DBEBD1}']
    function CloneDisplayBlocks: TArray<TChatDisplayBlock>;
  end;

  {--- Vendor-provided display bridge for a streamed LLM or agent turn.
       Pythia owns the browser/display vocabulary; each vendor maps its own
       stream events to these operations. }
  IPythiaTurnDisplay = interface(IPythiaDisplayBlockSnapshot)
    ['{5D8E95B7-7D9E-4E78-BB95-D48F062F2913}']
    procedure AssistantDelta(const AText: string);
    procedure AssistantText(const AText: string;
      const CloseBlock: Boolean = False); overload;
    procedure AssistantText(const ABlockText, ABrowserText: string;
      const CloseBlock: Boolean = False); overload;
    procedure BrowserError(const AMessage: string);
    procedure ErrorStatus(const ATitle, ADetail: string);
    procedure ReasoningDelta(const AText: string);
    procedure Status(const ATitle: string); overload;
    procedure Status(const ATitle, ADetail: string); overload;
    procedure ToolResult(const AKey, ATitle, AOutput: string;
      const IsError: Boolean);
    procedure ToolResultStatus(const AKey, ATitle, AOutput: string);
    procedure ToolStatus(const ATitle: string); overload;
    procedure ToolStatus(const ATitle, ADetail: string); overload;
    procedure ToolUse(const AKey, ATitle: string;
      const NotifyBrowser: Boolean = True);
  end;

  IPythiaBrowser = interface
    ['{B6D390AF-CEFB-436A-9560-6BACCC390F25}']

    //setters et getters
    function GetClipboard: IClipboardReader;
    procedure SetClipboard(const Value: IClipboardReader);
    function GetScrollButtonsVisible: Boolean;
    procedure SetScrollButtonsVisible(const Value: Boolean);
    function GetSettingsPanelPage: Integer;
    procedure SetSettingsPanelPage(const Value: Integer);
    function GetPromptCount: Integer;
    procedure SetPromptCount(const Value: Integer);
    function GetLocked: Boolean;
    procedure SetLocked(const Value: Boolean);
    function GetEscape: Boolean;
    procedure SetEscape(const Value: Boolean);
    function GetCustomPanels: TCustomPanels;
    procedure SetCustomPanels(const Value: TCustomPanels);
    function GetEnabledButtons: TEnabledButtons;
    procedure SetEnabledButtons(const Value: TEnabledButtons);

    function GetOnChatSessionAutoRename: TProc<string, string>;
    procedure SetOnChatSessionAutoRename(const Value: TProc<string, string>);

    function GetOnAfterSessionReloaded: TProc<string>;
    procedure SetOnAfterSessionReloaded(const Value: TProc<string>);

    function GetOnNewChatRequested: TProc;
    procedure SetOnNewChatRequested(const Value: TProc);

    function GetPersistentChat: IPersistentChat;
    procedure SetPersistentChat(const Value: IPersistentChat);
    function GetApiKeySecretStore: ISecretStore;
    procedure SetApiKeySecretStore(const Value: ISecretStore);
    function GetCommandLine: ICommandRegistry;
    procedure SetCommandLine(const Value: ICommandRegistry);
    function GetApiKeyNamesAsJsonString: string;
    procedure SetApiKeyNamesAsJsonString(const Value: string);
    function GetFileUploadService: IFileUploadService;
    procedure SetFileUploadService(const Value: IFileUploadService);
    function GetKnowledgeIndexingService: IKnowledgeIndexingService;
    procedure SetKnowledgeIndexingService(const Value: IKnowledgeIndexingService);
    function GetAudioTranscriptionService: IAudioTranscriptionService;
    procedure SetAudioTranscriptionService(const Value: IAudioTranscriptionService);

    //accessible uniquement avec via l'interface
    function ExecuteScript(const Script: string): Boolean;
    function PostWebMessageAsJson(const Script: string): Boolean;

    procedure SetTheme(const Value: string);
    function CapabilitiesInitialization: Boolean;
    function ProjectsInitialization: Boolean;
    function ProjectsStateUpdate(const JsonAsString: string): Boolean;

    function ChatSessionDrawerOpen: Boolean;
    function ChatSessionDrawerClose: Boolean;
    function ChatSessionDrawerClear: Boolean;

    function Confirmation(const Value, Goal, Tag: string; const Index: Integer): Boolean;
    function WebDecisionDlg(
      const ARequest: TWebDecisionDlgRequest;
      const ATimeoutMS: Cardinal = WEB_DECISION_DLG_INFINITE): TWebDecisionDlgResult;
    function ResolveWebDecisionDlgResponse(const AJson: string): Boolean;
    function ChatSessionAdd(const ID: string; const Text: string): Boolean;
    function ChatSessionRemove(const Id: string): Boolean;
    function ChatSessionRename(const Id: string; const ATitle: string): Boolean;
    function ChatSessionToTop(const Id: string): Boolean;
    function ChatSessionUnselect: Boolean;
    procedure SessionAutoRename(const Id: string; const ATitle: string);

    function BubbleInputMenuOpen: Boolean;
    function BubbleInputMenuClose: Boolean;
    function BubbleInputPartialReset: Boolean;
    function BubbleInputAudioButtonVisible(const Value: Boolean = True): Boolean;
    function BubbleInputFunctionButtonVisible(const Value: Boolean = True): Boolean;
    function BubbleInputClear: Boolean;
    function BubbleInputSetText(const Value: string): Boolean;
    function BubbleInputInsertText(const Value: string): Boolean;
    function BubbleInputWelcome(const Value: string): Boolean;

    function ReasoningCollapse: Boolean;
    function ReasoningExpand: Boolean;
    function ReasoningToggle: Boolean;
    function ReasoningHide: Boolean;
    function ReasoningShow: Boolean;

    function SettingsPanelShowPage(const Page: Integer): Boolean;
    function SettingsPanelHide: Boolean;
    function SettingsPanelRequestCurrentSettingsState: Boolean;
    function SettingsPanelInitializeFullState(const JsonAsString: string): Boolean;
    function SettingsPanelUpdatePropertiesByFullPath(const JsonAsString: string): Boolean;
    function SettingsPanelUpdateApplicationSettings(const JsonAsString: string): Boolean;
    function SettingsPanelForceLanguageSelection(const JsonAsString: string): Boolean;
    function SettingsPanelGetValues: Boolean;
    function SettingsPanelLoadPage: Boolean;
    procedure SettingsPanelSaveAppSettings;

    function ModelInitialize: Boolean;
    function ModelListFileCheck: Boolean;
    function ModelsSelectorShow: Boolean;
    function ModelsSelectorHide: Boolean;
    function ModelsSelectorCategoryVisible(const Category: string; const Visible: Boolean): Boolean;
    function ModelsSelectorSetModelList: Boolean;
    function ModelsSelectorCategoryAdd: Boolean;
    function ModelsSelectorGetReplaceVersion: Boolean;

    function CardSelectorShow(const Dialog: string): Boolean;
    function CardSelectorHide: Boolean;
    function CardSelectorSetData(const JsonString: string): Boolean;
    function CardSettingsButtonVisible(const Value: Boolean): Boolean;
    function TryGetCardFileContent(const AType: string; ParamProc: TFunc<string, Boolean>): Boolean;

    procedure ScrollToAfterEnd(SizeAfter: Integer; Smooth: Boolean = True); overload;
    procedure ScrollToAfterEnd(Smooth: Boolean = True); overload;
    procedure ScrollToEnd(Smooth: Boolean = False);
    procedure ScrollToTop(Smooth: Boolean = false);

    procedure SetLanguage(const Value: string);
    procedure StopMedia;
    procedure AudioRecordingStart;
    procedure AudioRecordingStop;
    procedure AudioRecordingSwitch;
    function DisplayChatSession: Boolean;
    function UpdateFileDrawer: Boolean;

    function GetAssetsFolder: string;
    function GetLanguageFolder: string;
    function GetMediaFolder: string;
    function GetAppRawName: string;
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
    function GetProjectsFileName: string;
    function GetExchangeDebugFileName: string;
    function GetAPIKeyNamesFileName: string;
    function GetCustomJSFileName: string;
    function GetCapabilitiesFileName: string;

    procedure DispatchCommand(const ACommandResult: TCommandResult);
    function TryHandleAsCommand(const PromptText: string): Boolean;

    procedure ChatSessionAutoRename(const ID: string; const Content: string);
    procedure ApiKeyValuesUpdate(const KeyName: string);

    {--- Pushes the upload status of a file (identified by its local path,
         already present in the compose box) to the JS layer so the bubble
         can carry the file_id and reflect a visual indicator.

         IMPORTANT — convention de pré-échappement : l'implémentation côté
         host se contente d'injecter chaque paramètre via Format dans le
         template JS. L'appelant doit donc fournir des littéraux JS prêts à
         l'emploi (chaîne entre guillemets et échappée, ou 'null'). Les
         constantes FILE_UPLOAD_STATUS_UPLOADING / READY / FAILED de
         WVPythia.Chat.Consts sont déjà au bon format pour AStatus. }
    function SetFileUploadStatus(
      const APath: string;
      const AStatus: string;
      const AFileId: string = '';
      const AErrorMessage: string = ''): Boolean;

    {--- Toggles the orthogonal availability flag of the send button (i.e.
         whether the button is clickable, independently of its input/stop
         visual mode). Used by the upload pipeline to lock submit while at
         least one transfer is still in flight. }
    function SetSendButtonAvailability(const AEnabled: Boolean): Boolean;

    {--- Aggregated availability push: sums the PendingCount of every
         registered async file service (FileUploadService and
         KnowledgeIndexingService), then pushes the resulting flag through
         SetSendButtonAvailability. Vendor service implementations should
         call this entry point on every state transition instead of pushing
         their local PendingCount directly, otherwise two services would
         overwrite each other's flag. }
    function RecomputeSendButtonAvailability: Boolean;

    // Methods exposed by the object
    procedure Clear;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure BringHostToFront;
    procedure SetFocus;

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

    function DisplayError(const Value: string): Boolean;
    function DisplayWarning(const Value: string): Boolean;
    function DisplaySuccess(const Value: string): Boolean;
    function DisplayFooter(const Value: string): Boolean;
    function DisplaySpacer(const AHeight: Integer = 190): Boolean;

    function ResetCapabilities: Boolean;

    procedure Hide;
    procedure Show;

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

    property Clipboard: IClipboardReader read GetClipboard write SetClipboard;
    property PromptCount: Integer read GetPromptCount write SetPromptCount;
    property Locked: Boolean read GetLocked write SetLocked;
    property Escape: Boolean read GetEscape write SetEscape;
    property LocalScrollButtonsVisible: Boolean read GetScrollButtonsVisible write SetScrollButtonsVisible;
    property SettingsPanelPage: Integer read GetSettingsPanelPage write SetSettingsPanelPage;
    property CustomPanels: TCustomPanels read GetCustomPanels write SetCustomPanels;
    property EnabledButtons: TEnabledButtons read GetEnabledButtons write SetEnabledButtons;
    property OnChatSessionAutoRename: TProc<string, string> read GetOnChatSessionAutoRename write SetOnChatSessionAutoRename;
    property OnAfterSessionReloaded: TProc<string> read GetOnAfterSessionReloaded write SetOnAfterSessionReloaded;
    property OnNewChatRequested: TProc read GetOnNewChatRequested write SetOnNewChatRequested;
    property PersistentChat: IPersistentChat read GetPersistentChat write SetPersistentChat;
    property ApiKeySecretStore: ISecretStore read GetApiKeySecretStore write SetApiKeySecretStore;
    property CommandLine: ICommandRegistry read GetCommandLine write SetCommandLine;
    property ApiKeyNamesAsJsonString: string read GetApiKeyNamesAsJsonString write SetApiKeyNamesAsJsonString;
    property FileUploadService: IFileUploadService read GetFileUploadService write SetFileUploadService;
    property KnowledgeIndexingService: IKnowledgeIndexingService
      read GetKnowledgeIndexingService write SetKnowledgeIndexingService;
    property AudioTranscriptionService: IAudioTranscriptionService
      read GetAudioTranscriptionService write SetAudioTranscriptionService;
  end;

implementation

class function TCommandExecResult.Ok(const AMessage: string): TCommandExecResult;
begin
  Result.Success := True;
  Result.Message := AMessage;
end;

class function TCommandExecResult.Fail(const AMessage: string): TCommandExecResult;
begin
  Result.Success := False;
  Result.Message := AMessage;
end;

{ TUploadResult }

class function TUploadResult.Ok(
  const ALocalPath, AFileId: string): TUploadResult;
begin
  Result.LocalPath := ALocalPath;
  Result.Success := True;
  Result.FileId := AFileId;
  Result.ErrorMessage := '';
end;

class function TUploadResult.Fail(
  const ALocalPath, AErrorMessage: string): TUploadResult;
begin
  Result.LocalPath := ALocalPath;
  Result.Success := False;
  Result.FileId := '';
  Result.ErrorMessage := AErrorMessage;
end;

{ TAudioTranscriptionResult }

class function TAudioTranscriptionResult.Ok(
  const AText: string): TAudioTranscriptionResult;
begin
  Result.Success := True;
  Result.Text := AText;
  Result.ErrorMessage := '';
end;

class function TAudioTranscriptionResult.Fail(
  const AErrorMessage: string): TAudioTranscriptionResult;
begin
  Result.Success := False;
  Result.Text := '';
  Result.ErrorMessage := AErrorMessage;
end;

end.
