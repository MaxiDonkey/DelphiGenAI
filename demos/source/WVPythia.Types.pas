unit WVPythia.Types;

interface

uses
  System.SysUtils, WVPythia.Types.EnumWire;

type
  TDisplayKind = (
    dkImages,
    dkAudio,
    dkVideo,
    dkFile
  );

  TCustomPanel = (
    cpSettings,
    cpModels,
    cpCards
  );

  TCustomPanels = set of TCustomPanel;

  TEnabledButton = (
    ebSettings,
    ebMicrophone
  );

  TEnabledButtons = set of TEnabledButton;

  {$SCOPEDENUMS ON}
  TBrowserChatEvent = (
    &Copy,
    ScrollRequest,
    StopSubmit,
    AudioInput,
    InputSubmit,
    InputState,
    OpenFileDialog,
    FileRemoved,
    OpenIntegrationFunctionDialog,
    OpenIntegrationMcpDialog,
    OpenIntegrationSkillsDialog,
    OpenIntegrationAgentsDialog,
    OpenCustomDialog,
    DisplayFileClick,
    BranchEvent,
    CopyEvent,
    DeleteEvent,
    SystemSettings,
    ResquestParamsPageChanged,
    ModelSelection,
    DialogConfirmationResponse,
    NewChatEvent,
    ChatSelectionEvent,
    ChatNextPageEvent,
    ChatItemDeleteEvent,
    ChatItemRenameEvent,
    RequestParamsValues,
    LookAndFeelSelectedEvent,
    LanguageSelectedEvent,
    ScrollButtonSelectedEvent,
    ModelSelectorCategoryChanged,
    ModelSelectorSelectionChanged,
    ModelSelectorGetReplaceVersion,
    CardSelectionDialogSettings,
    CardSelectionDialogCancel,
    CardSelectionDialogSelect,
    CardSelectionDialogSelectionChanged,
    InputString,
    WebDecisionDlgResponse,
    CustomEvent,
    FileDropIn,
    PasteFromClipboard,
    FolderSelection,
    FolderState,
    AudioRecord
  );

  TBrowserChatEventHelper = record Helper for TBrowserChatEvent
  const
    Map: array[TBrowserChatEvent] of string = (
      'copy',
      'scroll-request',
      'stop-submit',
      'audio-input',
      'input-submit',
      'input-state',
      'open-file-dialog',
      'file-removed',
      'open-integration-function-dialog',
      'open-integration-mcp-dialog',
      'open-integration-skills-dialog',
      'open-integration-agents-dialog',
      'open-custom-dialog',
      'display-file-click',
      'branch-event',
      'copy-event',
      'delete-event',
      'system-settings',
      'resquest-params-page-changed',
      'model-selection',
      'dialog-confirmation-response',
      'new-chat',
      'chat-selection',
      'chat-next-page',
      'chat-item-delete',
      'chat-item-rename',
      'request-params-values',
      'look-and-feel-selected',
      'language-selected',
      'scroll-button-selected',
      'model-selector-category-changed',
      'model-selector-selection-changed',
      'model-selector-get-replace-version',
      'card-selection-dialog-settings',
      'card-selection-dialog-cancel',
      'card-selection-dialog-select',
      'card-selection-dialog-selection-changed',
      'input-string',
      'web-decision-dlg-response',
      'custom-event',
      'file-drop-in',
      'paste-from-clipboard',
      'folder-selection',
      'folder-state',
      'audio-record'
    );
  public
    class function Parse(const Value: string): TBrowserChatEvent; static; inline;
    class function TryToParse(const Value: string; out AResult: TBrowserChatEvent): Boolean; static; inline;
    function ToString: string;
  end;

  TScrollDirection = (
    Top,
    Bottom
  );

  TScrollDirectionHelper = record Helper for TScrollDirection
  public
    class function Parse(const Value: string): TScrollDirection; static; inline;
    class function TryToParse(const Value: string; out AResult: TScrollDirection): Boolean; static; inline;
    function ToString: string;
  end;

  THorizontalPosition = (
    Right,
    Left
  );

  THorizontalPositionHelper = record Helper for THorizontalPosition
    class function Parse(const Value: string): THorizontalPosition; static; inline;
    class function TryToParse(const Value: string; out AResult: THorizontalPosition): Boolean; static; inline;
    function ToString: string;
  end;

  TOpenFileTarget = (
    Images,
    Documents,
    Knowledge,
    Speech
  );

  TOpenFileTargetHelper = record Helper for TOpenFileTarget
  public
    class function Parse(const Value: string): TOpenFileTarget; static; inline;
    class function TryToParse(const Value: string; out AResult: TOpenFileTarget): Boolean; static; inline;
    function ToString: string;
  end;

  TDialogGoal = (
    DeleteDomBlock,
    DeleteChatSession
  );

  TDialogGoalHelper = record Helper for TDialogGoal
  const
    Map: array[TDialogGoal] of string = (
      'delete-dom-block',
      'delete-dom-chat_session'
    );
  public
    class function Parse(const Value: string): TDialogGoal; static; inline;
    class function TryToParse(const Value: string; out AResult: TDialogGoal): Boolean; static; inline;
    function ToString: string;
  end;

  TChatManagedItemKind = (
    &function,
    mcp,
    skills,
    agents,
    custom,
    none
  );

  TChatManagedItemKindHelper = record Helper for TChatManagedItemKind
    class function Parse(const Value: string): TChatManagedItemKind; static; inline;
    class function TryToParse(const Value: string; out AResult: TChatManagedItemKind): Boolean; static; inline;
    function ToString: string;
  end;

  {$SCOPEDENUMS OFF}

  TLookAndFeel = (
    light,
    dark
  );

  TLookAndFeelHelper = record Helper for TLookAndFeel
    class function Parse(const Value: string): TLookAndFeel; static; inline;
    class function TryToParse(const Value: string; out AResult: TLookAndFeel): Boolean; static; inline;
    function ToString: string;
  end;

  TAdapterManagedItemKind = (
    FunctionItem,
    Mcp,
    Skills,
    Agents,
    Custom,
    SystemSettings,
    ModelSelection,
    InputState,
    CardButtonSettings,
    AudioInput
  );

  TAdapterManagedItemKindHelper = record Helper for TAdapterManagedItemKind
  const
    Map: array[TAdapterManagedItemKind] of string = (
      'function',
      'mcp',
      'skills',
      'agents',
      'custom',
      'none',
      'none',
      'none',
      'none',
      'none'
    );
  public
    function ToString: string;
  end;

implementation

{ TBrowserChatEventHelper }

class function TBrowserChatEventHelper.Parse(
  const Value: string): TBrowserChatEvent;
begin
  Result := TEnumWire.Parse<TBrowserChatEvent>(Value, Map);
end;

function TBrowserChatEventHelper.ToString: string;
begin
  Result := Map[Self];
end;

class function TBrowserChatEventHelper.TryToParse(const Value: string; out AResult: TBrowserChatEvent): Boolean;
begin
  Result := TEnumWire.TryParse<TBrowserChatEvent>(Value, Map, AResult);
end;

{ TScrollDirectionHelper }

class function TScrollDirectionHelper.Parse(
  const Value: string): TScrollDirection;
begin
  Result := TEnumWire.Parse<TScrollDirection>(Value);
end;

function TScrollDirectionHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TScrollDirection>(Self);
end;

class function TScrollDirectionHelper.TryToParse(const Value: string;
  out AResult: TScrollDirection): Boolean;
begin
  Result := TEnumWire.TryParse<TScrollDirection>(Value, AResult);
end;

{ TOpenFileTargetHelper }

class function TOpenFileTargetHelper.Parse(
  const Value: string): TOpenFileTarget;
begin
  Result := TEnumWire.Parse<TOpenFileTarget>(Value);
end;

function TOpenFileTargetHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TOpenFileTarget>(Self).ToLower;
end;

class function TOpenFileTargetHelper.TryToParse(const Value: string;
  out AResult: TOpenFileTarget): Boolean;
begin
  Result := TEnumWire.TryParse<TOpenFileTarget>(Value, AResult);
end;

{ TDialogGoalHelper }

class function TDialogGoalHelper.Parse(const Value: string): TDialogGoal;
begin
  Result := TEnumWire.Parse<TDialogGoal>(Value, Map);
end;

function TDialogGoalHelper.ToString: string;
begin
  Result := Map[Self];
end;

class function TDialogGoalHelper.TryToParse(const Value: string;
  out AResult: TDialogGoal): Boolean;
begin
  Result := TEnumWire.TryParse<TDialogGoal>(Value, Map, AResult);
end;

{ TLookAndFeelHelper }

class function TLookAndFeelHelper.Parse(const Value: string): TLookAndFeel;
begin
  Result := TEnumWire.Parse<TLookAndFeel>(Value);
end;

function TLookAndFeelHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TLookAndFeel>(Self)
end;

class function TLookAndFeelHelper.TryToParse(const Value: string;
  out AResult: TLookAndFeel): Boolean;
begin
  Result := TEnumWire.TryParse<TLookAndFeel>(Value, AResult);
end;

{ THorizontalPositionHelper }

class function THorizontalPositionHelper.Parse(
  const Value: string): THorizontalPosition;
begin
  Result := TEnumWire.Parse<THorizontalPosition>(Value);
end;

function THorizontalPositionHelper.ToString: string;
begin
  Result := TEnumWire.ToString<THorizontalPosition>(Self);
end;

class function THorizontalPositionHelper.TryToParse(const Value: string;
  out AResult: THorizontalPosition): Boolean;
begin
  Result := TEnumWire.TryParse<THorizontalPosition>(Value, AResult);
end;

{ TChatManagedItemKindHelper }

class function TChatManagedItemKindHelper.Parse(
  const Value: string): TChatManagedItemKind;
begin
  Result := TEnumWire.Parse<TChatManagedItemKind>(Value);
end;

function TChatManagedItemKindHelper.ToString: string;
begin
  Result := TEnumWire.ToString<TChatManagedItemKind>(Self);
end;

class function TChatManagedItemKindHelper.TryToParse(const Value: string;
  out AResult: TChatManagedItemKind): Boolean;
begin
  Result := TEnumWire.TryParse<TChatManagedItemKind>(Value, AResult);
end;

{ TAdapterManagedItemKindHelper }

function TAdapterManagedItemKindHelper.ToString: string;
begin
  Result := Map[Self];
end;

end.
