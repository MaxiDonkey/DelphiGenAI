unit WVPythia.Chat.EventHandlers;

//{$I Debug.inc}

interface

uses
  System.SysUtils, System.JSON,
  WVPythia.Chat.Interfaces, WVPythia.JSON.SafeReader, WVPythia.Chat.Consts,
  WVPythia.Types, WVPythia.Types.EnumWire, WVPythia.Strs, WVPythia.Strings.Escape,
  WVPythia.Adapter, WVPythia.ChatSession.Controller, WVPythia.Chat.ManagedFlow,
  WVPythia.Command.Parser;

type
  TOrchestratorEventHandler = class(TInterfacedObject)
  strict private
    function CreateTurnAndAddPrompt(
      const APayload: string;
      const State: TInputPromptState): TChatTurn;

    procedure CompleteTurn(
      const Turn: TChatTurn;
      const AResult: TManagedItemLLMResult);

    function ValidateRequiredModels(const State: TInputPromptState; out ErrorMessage: string): Boolean;

    procedure UpdatePromptUI(const State: TInputPromptState);
    procedure UpdateMessageUI(const State: TManagedItemLLMResult);
    procedure ReleaseTurnLock;

    function JsonIsValid(const Reader: TJsonReader; const KeyName: string): Boolean;
    function StructuredOutputIsValid(const Payload: string): Boolean;

    function Normalize(const Payload: string): string;
    procedure AddPromptFragmentConsumedPath(
      var APaths: TArray<string>;
      const APath: string);
    function PromptFragmentPathWasConsumed(
      const APaths: TArray<string>;
      const APath: string): Boolean;
    function ExpandPromptFragments(const APayload: string;
      out AExpandedPayload: string;
      out AConsumedPaths: TArray<string>): Boolean;

    function TryDeserializeInputState(const APayload: string; out State: TInputPromptState): Boolean;

    function DefaultModelPanelIsUsed: Boolean;
    function TryHandleAsCommand(const PromptText: string): Boolean;

    function CategoriesExists: Boolean;
    function ValidateDialogServiceAvailable(const NormalizedPayload: string): Boolean;
    function MissingDefaultModelFailureResult: Boolean;
    function BuildDeserializationFailureResult: Boolean;
    function BuildStructuredOutputFailureResult: Boolean;
    function BuildModelValidationFailureResult(const ErrorMessage: string; const State: TInputPromptState): Boolean;
    function BuildJsonStateFailureResult: Boolean;
    procedure HandleOrchestratorError(const ErrorMessage: string; const Turn: TChatTurn);

    function ValidateAggregatedPrompt(const APayload: string;
      var State: TInputPromptState;
      out Payload: string): Boolean;

  protected
    FBrowser: IPythiaBrowser;
    FOpenDialog: IOpenDialog;
    FRunProcess: IProcessExecute;
    FReader: TJsonReader;
    FPersistentChat: IPersistentChat;
    FDialogService: IChatManagedItemDialogService;

    function SubmitAggregatedPromptToOrchestrator(const APayload: string): Boolean;
  end;

  TCardEventHandler = class(TOrchestratorEventHandler)
  protected
    function EmitManagedItemSelection(const ATemplate: string;
      const AItem: TChatManagedItemRef): Boolean;

    function CardDialogSelect: Boolean;
  end;

  TDialogConfirmationEventHandler = class(TCardEventHandler)
  strict private
    procedure SavePersistentChatAfterDeletion;
    function HasStringNodes(const AProps: TArray<string>): Boolean;
  protected
    function AttachFilesToInput(
      const APaths: TArray<string>;
      const ATarget: TOpenFileTarget): Boolean;
    function ConfirmationResponse: Boolean;
    function OpenFileDialog: Boolean;
    function OpenManagedItemDialog(
      const AKind: TAdapterManagedItemKind;
      const ATemplate: string): Boolean;
  end;

  TChatSessionEventHandler = class(TDialogConfirmationEventHandler)
  protected
    function HasStringNodes(const AProps: TArray<string>): Boolean;
    function ChatSessionCreate: Boolean;
    function ChatSessionSelection: Boolean;
    function ChatSessionNextPage: Boolean;
    function ChatSessionItemDelete: Boolean;
    function ChatSessionItemRename: Boolean;
  end;

  TOpenFileEventHandler = class(TChatSessionEventHandler)
  protected
    function OpenFile: Boolean;
  end;

  TSelectorEventHandler = class(TOpenFileEventHandler)
  protected
    function Branch: Boolean;
    function Copy: Boolean;
    function Delete: Boolean;
  end;

  TCodeCopyEventHandler = class(TSelectorEventHandler)
  protected
    function CodeCopy: Boolean;
  end;

  TBrowserScrollEventHandler = class(TCodeCopyEventHandler)
  protected
    function Scroll: Boolean;
  end;

  TModelsEventHandler = class(TBrowserScrollEventHandler)
  protected
    function ActivateManagedItemEvent(
      const AKind: TAdapterManagedItemKind): Boolean; overload; virtual; abstract;

    function ActivateManagedItemEvent(
      const APayload: string): Boolean; overload; virtual; abstract;

    function ModelsSelection: Boolean;
    function ModelsDialogOpen: Boolean;
  end;

  TSettingsEventHandler = class(TModelsEventHandler)
  protected
    function SettingsDialogOpen: Boolean;
  end;

  TBrowserEventHandlers = class(TSettingsEventHandler)
  private
    function ClampSelection(const AValue, AMaxValue: Integer): Integer;
  protected
    function CanHandleEvents: Boolean; virtual;

    function OpenManagedItemDialogEvent(
      const AKind: TAdapterManagedItemKind;
      const ATemplate: string): Boolean;

    function ActivateManagedItemEvent(
      const AKind: TAdapterManagedItemKind): Boolean; overload; override;

    function ActivateManagedItemEvent(
      const APayload: string): Boolean; overload; override;

    function CodeCopyEvent: Boolean;
    function ScrollRequestEvent: Boolean;
    function DialogConfirmationResponseEvent: Boolean;

    function StopSubmitEvent: Boolean;
    function InputSubmitEvent: Boolean;
    function InputStateEvent: Boolean;

    function FileRemovedEvent: Boolean;

    function OpenFileDialogEvent: Boolean;
    function FolderSelectionEvent: Boolean;
    function FolderStateEvent: Boolean;
    function OpenFunctionDialogEvent: Boolean;
    function OpenMCPDialogEvent: Boolean;
    function OpenSkillsDialogEvent: Boolean;
    function OpenAgentsDialogEvent: Boolean;
    function OpenCustomDialogEvent: Boolean;
    function ModelSelectionEvent: Boolean;

    function DisplayFileClickEvent: Boolean;
    function BranchEvent: Boolean;
    function CopyEvent: Boolean;
    function DeleteEvent: Boolean;

    function NewChatSessionEvent: Boolean;
    function ChatSelectionEvent: Boolean;
    function ChatNextPageEvent: Boolean;
    function ChatItemDeleteEvent: Boolean;
    function ChatItemRenameEvent: Boolean;

    function SystemSettingsEvent: Boolean;
    function ResquestParamsPageChangedEvent: Boolean;
    function RequestParamsValuesEvent: Boolean;

    function LookAndFeelSelectedEvent: Boolean;
    function LanguageSelectedEvent: Boolean;
    function ScrollButtonSelectedEvent: Boolean;

    function ModelSelectorGetReplaceVersionEvent: Boolean;

    function CardSelectionDialogSelectionChangedEvent: Boolean;
    function CardSelectionDialogSelectEvent: Boolean;
    function CardSelectionDialogCancelEvent: Boolean;
    function CardSelectionDialogSettingsEvent: Boolean;

    function AudioInputEvent: Boolean;
    function InputString: Boolean;
    function WebDecisionDlgResponseEvent: Boolean;

    function CustomEvent: Boolean;
    function FileDropInEvent: Boolean;
    function PasteFromClipboardEvent: Boolean;
    function AudioRecordEvent: Boolean;
  end;

implementation

{$REGION 'Dev notes'}

(*
    Developer Note:
    ---------------

    This unit implements the event handling layer for the browser-based chat UI.
    It acts as the execution side of the browser event pipeline: events are routed
    by TBrowserEventManager, then handled here through small, focused methods.

    Purpose:
    � Bridge JSON-driven browser events to chat/session/orchestrator services.
    � Keep event execution logic separated from event routing.
    � Coordinate UI updates, persistence, dialogs, managed items, and prompt flow.
    � Provide a shared event handling layer independently of the concrete UI
      framework using it.

    Class layering:
    � TOrchestratorEventHandler
      Handles prompt/orchestrator flow, turn creation, completion callbacks,
      payload preparation, command handling, and prompt UI replay.

    � TCardEventHandler
      Handles managed card selection helpers.

    � TDialogConfirmationEventHandler
      Handles deferred confirmation flows and managed item dialog opening.

    � TChatSessionEventHandler
      Handles chat session creation, selection, pagination, deletion, and rename.

    � TOpenFileEventHandler
      Handles file selection callbacks.

    � TSelectorEventHandler / TCodeCopyEventHandler / TBrowserScrollEventHandler
      Handle message-level actions such as branch, copy, delete, code copy, and
      scroll requests.

    � TModelsEventHandler / TSettingsEventHandler
      Handle model and settings-related actions.

    � TBrowserEventHandlers
      Final concrete handler surface consumed by TBrowserEventManager.

    Architectural assumptions:
    � This class hierarchy does not route events by enum.
      Routing is owned by TBrowserEventManager.
    � FReader is prepared before handler execution.
    � Readiness is guaranteed by CanHandleEvents before dispatch.
    � FBrowser is a mandatory invariant.
    � Optional services are checked per event when required.

    Event flow model:
    1. TBrowserEventManager receives raw JSON from the browser.
    2. The payload is parsed once into FReader.
    3. The event name is resolved to TBrowserChatEvent.
    4. The matching handler method from this unit is invoked.
    5. The handler validates required JSON nodes.
    6. The action is delegated to the proper service or browser abstraction.

    Important patterns:
    � Confirmation events are split:
      . initial request opens/records the pending action
      . DialogConfirmationResponseEvent performs the confirmed action

    � Managed item execution uses a request/completion pattern:
      . input state is persisted first as a chat turn
      . execution is delegated through IChatManagedItemDialogService
      . completion is injected later through CompleteTurn

    � UI synchronization is centralized:
      . UI mutations go through IBrowser or injected browser scripts
      . UpdatePromptUI replays the full input state into the browser

    � Persistence is incremental:
      . chat state is saved after structural changes
      . deletion relies on UI/persistent prompt alignment

    Custom events:
    � CustomEvent handles the reserved browser event "custom-event".
    � It forwards the complete JSON message to the dialog service through:

          FDialogService.ActivateCustomEvent(FReader.ToJson)

    � This layer does not interpret "name" or "payload".
    � No Delphi data model is imposed for custom payloads.
    � The application service layer is responsible for parsing, validating, and
      dispatching user-defined custom events.

    JSON handling:
    � All event data must be read through TJsonReader / FReader.
    � Handlers should validate required nodes before reading them.
    � Payload-specific parsing must remain local to the handler or be delegated
      to the application service when the payload is user-defined.

    Design boundaries:
    � This unit does not own event-to-method dispatch.
    � This unit does not define browser event names.
    � This unit does not implement concrete dialogs.
    � This unit does not contain UI-framework-specific behavior.
    � This unit should not deserialize custom-event payloads into predefined
      Delphi types.

    Reading this unit in isolation:
    � Event routing is implemented in TBrowserEventManager.Aggregate.
    � Dispatch table initialization is implemented in TBrowserEventManager.
    � Event identifiers and wire names come from Browser.Types and
      Browser.Types.EnumWire.
    � Constants come from Browser.Chat.Consts.
    � Concrete application behavior is reached through injected services such as
      IBrowser, IPersistentChat, and IChatManagedItemDialogService.

*)

{$ENDREGION}

uses
  System.IOUtils, REST.Json, WVPythia.JSON.SafeWriter, WVPythia.TextFile.Helper,
  WVPythia.Net.MediaCodec;

{ TBrowserEventHandlers }

function TBrowserEventHandlers.ActivateManagedItemEvent(
  const APayload: string): Boolean;
begin
  Result := SubmitAggregatedPromptToOrchestrator(APayload);
end;

function TBrowserEventHandlers.AudioInputEvent: Boolean;
begin
  {--- When a vendor transcription service is registered, the microphone button
       drives the browser-side recorder (start/stop toggle). Producing the
       capture is vendor-agnostic, so the toggle lives here in Pythia. Without
       such a service, fall back to the legacy managed-item routing. }
  if Assigned(FBrowser) and Assigned(FBrowser.AudioTranscriptionService) then
    begin
      {--- Lock the send button while a capture is in progress so the user
           cannot start a flow during recording. It is restored in
           AudioRecordEvent once the recording ends (success or failure). }
      FBrowser.SetSendButtonAvailability(False);
      FBrowser.AudioRecordingSwitch;
      Exit(True);
    end;

  Result := ActivateManagedItemEvent(TAdapterManagedItemKind.AudioInput);
end;

function TBrowserEventHandlers.AudioRecordEvent: Boolean;
begin
  Result := False;

  {--- The send button stays locked (from AudioInputEvent) until the capture is
       fully resolved. It is handed to the async transcription on the happy
       path; for every other (synchronous) outcome the finally block below
       restores it immediately. }
  var HandedToTranscription := False;

  try
    if not FReader.IsStringNode(PROP_DATA) then
      Exit;

    var Base64 := FReader.AsString(PROP_DATA);
    if Base64.Trim.IsEmpty then
      begin
        {--- The browser reports a capture failure (e.g. getUserMedia blocked or
             unavailable) through the optional "error" field. Surface it so the
             cause is visible instead of failing silently. }
        if FReader.IsStringNode(PROP_ERROR) then
          FBrowser.DisplayError(
            Format('Audio recording failed: %s', [FReader.AsString(PROP_ERROR)]));
        Exit;
      end;

    {--- Persist the browser-captured audio to a temporary file named after a
         fresh CLSID. The container (webm/opus) is both playable by the display
         layer and accepted by the OpenAI transcription endpoint. }
    var FileName :=
      TPath.Combine(
        TPath.GetTempPath,
        TGUID.NewGuid.ToString.Trim(['{', '}']) + '.webm');

    if not TMediaCodec.TryDecodeBase64ToFile(Base64, FileName) then
      Exit;

    Result := True;

    {--- The capture file is vendor-agnostic: hand it to the registered
         transcription service (if any) and let Pythia place the recognized text
         into the input bubble. Pythia never knows which vendor performs the
         speech-to-text step. }
    var Service := FBrowser.AudioTranscriptionService;
    if not Assigned(Service) then
      Exit;

    HandedToTranscription := True;

    Service.SubmitForTranscription(FileName,
      procedure(AResult: TAudioTranscriptionResult)
      begin
        {--- Belt-and-suspenders: whatever the transcription outcome (success,
             error, or an exception while inserting), the send button MUST be
             restored exactly once here, since the synchronous path delegated
             that responsibility to this callback. }
        try
          if AResult.Success and not AResult.Text.Trim.IsEmpty then
            FBrowser.BubbleInputInsertText(AResult.Text);
        finally
          FBrowser.RecomputeSendButtonAvailability;
        end;
      end);
  finally
    {--- No async transcription was started (capture failed, no service, etc.):
         the recording is fully over, so restore the send button now. When the
         capture was handed off, the completion callback owns the restore. }
    if not HandedToTranscription then
      FBrowser.RecomputeSendButtonAvailability;
  end;
end;

function TBrowserEventHandlers.ActivateManagedItemEvent(
  const AKind: TAdapterManagedItemKind): Boolean;
begin
  if FDialogService = nil then
    Exit(False);

  Result := FDialogService.ActivateManagedItemEvent(AKind);
end;

function TBrowserEventHandlers.BranchEvent: Boolean;
begin
  Result := Branch;
end;

function TBrowserEventHandlers.CanHandleEvents: Boolean;
begin
  {--- Base event handling requires a live browser bridge and a script executor. }
  Result := Assigned(FBrowser);
end;

function TBrowserEventHandlers.CardSelectionDialogSettingsEvent: Boolean;
begin
  Result := ActivateManagedItemEvent(TAdapterManagedItemKind.cardButtonSettings);
end;

function TBrowserEventHandlers.CardSelectionDialogSelectEvent: Boolean;
begin
  Result := CardDialogSelect;
end;

function TBrowserEventHandlers.CardSelectionDialogSelectionChangedEvent: Boolean;
begin
  Result := True;
end;

function TBrowserEventHandlers.CardSelectionDialogCancelEvent: Boolean;
begin
  Result := True;
end;

function TBrowserEventHandlers.ChatItemDeleteEvent: Boolean;
begin
  Result := ChatSessionItemDelete;
end;

function TBrowserEventHandlers.ChatItemRenameEvent: Boolean;
begin
  Result := ChatSessionItemRename;
end;

function TBrowserEventHandlers.ChatNextPageEvent: Boolean;
begin
  Result := ChatSessionNextPage;
end;

function TBrowserEventHandlers.ChatSelectionEvent: Boolean;
begin
  Result := ChatSessionSelection;
end;

function TBrowserEventHandlers.ClampSelection(const AValue,
  AMaxValue: Integer): Integer;
begin
  if AValue < 0 then
      Exit(0);

  if AValue > AMaxValue then
    Exit(AMaxValue);

  Result := AValue;
end;

function TBrowserEventHandlers.CodeCopyEvent: Boolean;
begin
  Result := CodeCopy;
end;

function TBrowserEventHandlers.CopyEvent: Boolean;
begin
  Result := Copy;
end;

function TBrowserEventHandlers.CustomEvent: Boolean;
begin
  Result :=
    Assigned(FDialogService) and
    FDialogService.ActivateCustomEvent(FReader.ToJson);
end;

function TBrowserEventHandlers.DeleteEvent: Boolean;
begin
  Result := Delete;
end;

function TBrowserEventHandlers.DialogConfirmationResponseEvent: Boolean;
begin
  Result := ConfirmationResponse;
end;

function TBrowserEventHandlers.DisplayFileClickEvent: Boolean;
begin
  Result := OpenFile;
end;

function TBrowserEventHandlers.FileDropInEvent: Boolean;
begin
  if not Assigned(FBrowser) then
    Exit(False);

  var Files := FReader.ArrayStrings('filenames');
  if Length(Files) = 0 then
    Exit(False);

  FBrowser.BringHostToFront;

  var Target := TOpenFileTarget.Documents;
  if FReader.IsStringNode(PROP_TARGET) then
    Target := TOpenFileTarget.Parse(FReader.AsString(PROP_TARGET));

  Result := AttachFilesToInput(Files, Target);

  if Result then
    begin
      FBrowser.BringHostToFront;
      FBrowser.SetFocus;
    end;
end;

function TBrowserEventHandlers.FileRemovedEvent: Boolean;
begin
  Result := False;

  if not FReader.IsStringNode(PROP_PATH) then
    Exit;

  var Path := FReader.AsString(PROP_PATH);

  {--- The JS bridge does not carry the target on file-removed events, so
       both async file services receive the cancellation. Each
       implementation must tolerate calls for unknown paths (contract
       documented on IFileUploadService and IKnowledgeIndexingService). }
  var UploadService := FBrowser.FileUploadService;
  if Assigned(UploadService) then
    UploadService.CancelOrDelete(Path);

  var IndexingService := FBrowser.KnowledgeIndexingService;
  if Assigned(IndexingService) then
    IndexingService.CancelOrDelete(Path);

  Result := True;
end;

function TBrowserEventHandlers.InputStateEvent: Boolean;
begin
  if not FReader.IsObjectNode(PROP_STATE) then
    Exit(False);

  {--- Forward the serialized input state object to the managed item pipeline. }
  var StateJson := FReader.ObjectText(PROP_STATE);
  Result := ActivateManagedItemEvent(StateJson);
end;

function TBrowserEventHandlers.InputString: Boolean;
var
  Message: string;
begin
  if not Assigned(FBrowser.ApiKeySecretStore) then
    Exit(False);

  var Key := FReader.AsString(PROP_KEY);
  var Value := FReader.AsString(PROP_VALUE);

  {--- Write the (key, value) pair to the register at the location [HKLM]Environment }
  FBrowser.ApiKeySecretStore.WriteSecret(Key, Value);

  {--- Update the JSON responsible for maintaining the list of names for the API keys. }
  var KeyNamesReader := TJsonReader.Parse(FBrowser.ApiKeyNamesAsJsonString);
  if KeyNamesReader.Exists(Key) then
    Message := Format(S_API_KEY_MODIFIED, [Key])
  else
    Message := Format(S_API_KEY_INSERTED, [Key]);

  var KeyNamesWriter := TJsonWriter.Parse(FBrowser.ApiKeyNamesAsJsonString);
  KeyNamesWriter.SetBoolean(key, True);
  FBrowser.ApiKeyNamesAsJsonString := KeyNamesWriter.Format();

  {--- Update key for clients }
  FBrowser.ApiKeyValuesUpdate(Key);

  FBrowser.DisplaySuccess(Message);
  Result := True;
end;

function TBrowserEventHandlers.WebDecisionDlgResponseEvent: Boolean;
begin
  Result :=
    Assigned(FBrowser) and
    FBrowser.ResolveWebDecisionDlgResponse(FReader.ToJson);
end;

function TBrowserEventHandlers.InputSubmitEvent: Boolean;
begin
  Result := True;

  {--- Request the browser layer to emit the current input state as structured JSON. }
  FBrowser.ExecuteScript(SEND_INPUT_STATE_TEMPLATE);
end;

function TBrowserEventHandlers.LanguageSelectedEvent: Boolean;
begin
  var Internal := FReader.AsBoolean(PROP_INTERNAL);
  if Internal then
    Exit(False);

  var Language := FReader.AsString(PROP_VALUE);
  FBrowser.SetLanguage(Language);
  FBrowser.SettingsPanelSaveAppSettings;

  Result := True;
end;

function TBrowserEventHandlers.LookAndFeelSelectedEvent: Boolean;
begin
  var Theme := FReader.AsString(PROP_VALUE);
  FBrowser.SetTheme(Theme);
  FBrowser.SettingsPanelSaveAppSettings;
  Result := True;
end;

function TBrowserEventHandlers.ModelSelectionEvent: Boolean;
begin
  Result := ModelsDialogOpen;
end;

function TBrowserEventHandlers.ModelSelectorGetReplaceVersionEvent: Boolean;
begin
  Result := ModelsSelection;
end;

function TBrowserEventHandlers.NewChatSessionEvent: Boolean;
begin
  Result := ChatSessionCreate;
end;

function TBrowserEventHandlers.OpenAgentsDialogEvent: Boolean;
begin
  Result := OpenManagedItemDialogEvent(
    TAdapterManagedItemKind.Agents,
    INTEGRATION_AGENT_SELECTION
  );
end;

function TBrowserEventHandlers.OpenCustomDialogEvent: Boolean;
begin
  Result := OpenManagedItemDialogEvent(
    TAdapterManagedItemKind.Custom,
    CUSTOM_SELECTION
  );
end;

function TBrowserEventHandlers.OpenFileDialogEvent: Boolean;
begin
  Result := OpenFileDialog;
end;

function TBrowserEventHandlers.FolderSelectionEvent: Boolean;
var
  FolderPath: string;
begin
  Result := False;

  if not Assigned(FOpenDialog) or not Assigned(FBrowser) then
    Exit;

  if not FOpenDialog.ExecuteFolder(FolderPath) then
    Exit;

  Result := FBrowser.PostWebMessageAsJson(
    Format(FOLDER_SELECTED_TEMPLATE, [
      TEscapeHelper.EscapeJSString(FolderPath, False)
    ])
  );
end;

function TBrowserEventHandlers.FolderStateEvent: Boolean;
begin
  if not Assigned(FBrowser) then
    Exit(False);

  if not FReader.IsArrayNode(PROP_STATE) then
    Exit(False);

  Result := FBrowser.ProjectsStateUpdate(FReader.ArrayText(PROP_STATE));
end;

function TBrowserEventHandlers.OpenFunctionDialogEvent: Boolean;
begin
  Result := OpenManagedItemDialogEvent(
    TAdapterManagedItemKind.FunctionItem,
    INTEGRATION_FUNCTION_SELECTION
  );
end;

function TBrowserEventHandlers.OpenManagedItemDialogEvent(
  const AKind: TAdapterManagedItemKind; const ATemplate: string): Boolean;
begin
  Result := OpenManagedItemDialog(AKind, ATemplate);
end;

function TBrowserEventHandlers.OpenMCPDialogEvent: Boolean;
begin
  Result := OpenManagedItemDialogEvent(
    TAdapterManagedItemKind.MCP,
    INTEGRATION_MCP_SELECTION
  );
end;

function TBrowserEventHandlers.OpenSkillsDialogEvent: Boolean;
begin
  Result := OpenManagedItemDialogEvent(
    TAdapterManagedItemKind.Skills,
    INTEGRATION_SKILL_SELECTION
  );
end;

function TBrowserEventHandlers.PasteFromClipboardEvent: Boolean;
begin
  Result := False;

  if not Assigned(FBrowser) then
    Exit;

  var Clipboard := FBrowser.Clipboard;
  if not Assigned(Clipboard) then
    Exit;

  if not Clipboard.IsAvailable then
    Exit;

  var Files: TArray<string>;
  if Clipboard.TryGetFiles(Files) and (Length(Files) > 0) then
    Exit(AttachFilesToInput(Files, TOpenFileTarget.Documents));

  var ImageFileName: string;
  if Clipboard.TrySaveImageToTempPng(ImageFileName) then
    Exit(AttachFilesToInput([ImageFileName], TOpenFileTarget.Images));

  var TextData: TClipboardTextData;
  if not Clipboard.TryGetText(TextData) then
    Exit;

  var Prompt := FReader.AsString('prompt');
  var SelectionStart := FReader.AsInteger('selectionStart', 0);
  var SelectionEnd := FReader.AsInteger('selectionEnd', SelectionStart);
  var PromptLength := Length(Prompt);

  SelectionStart := ClampSelection(SelectionStart, PromptLength);
  SelectionEnd := ClampSelection(SelectionEnd, PromptLength);

  if SelectionStart > SelectionEnd then
    begin
      var Swap := SelectionStart;
      SelectionStart := SelectionEnd;
      SelectionEnd := Swap;
    end;

  if TextData.Kind = ctkTempFile then
    begin
      if not AttachFilesToInput([TextData.FileName], TOpenFileTarget.Documents) then
        Exit(False);

      Exit(FBrowser.ExecuteScript(
        Format(PASTE_FRAGMENT_SELECTION_TEMPLATE, [
          TEscapeHelper.EscapeJSString(TextData.FileName),
          SelectionStart,
          SelectionEnd
        ])
      ));
    end;

  var UpdatedPrompt :=
    System.Copy(Prompt, 1, SelectionStart) +
    TextData.Text +
    System.Copy(Prompt, SelectionEnd + 1, MaxInt);

  Result := FBrowser.BubbleInputSetText(
    TEscapeHelper.EscapeJSString(UpdatedPrompt, False)
  );
end;

function TBrowserEventHandlers.RequestParamsValuesEvent: Boolean;
begin
  var FWriter := TJsonWriter.Parse(FReader.ToJson);
  if not FWriter.IsValid then
    Exit(False);

  if FWriter.Remove(PROP_EVENT) and
     FWriter.SetString(PROP_TYPE, 'request-initialization')
    then
      begin
        Result := TJsonCheck.IsValid(FWriter.ToJson,
          procedure (Value: TJsonReader)
          begin
            TFileIOHelper.SaveToFile(FBrowser.GetParamsConfigFileName, Value.Format());
          end);

        Exit;
      end
    else
      Exit(False);
end;

function TBrowserEventHandlers.ResquestParamsPageChangedEvent: Boolean;
begin
  var index := FReader.AsInteger(PROP_INDEX);
  FBrowser.SettingsPanelPage := index;
  Result := True;
end;

function TBrowserEventHandlers.ScrollButtonSelectedEvent: Boolean;
begin
  var Enabled := FReader.AsBoolean(PROP_VALUE);
  FBrowser.LocalScrollButtonsVisible := Enabled;
  FBrowser.SettingsPanelSaveAppSettings;
  Result := True;
end;

function TBrowserEventHandlers.ScrollRequestEvent: Boolean;
begin
  Result := Scroll;
end;

function TBrowserEventHandlers.StopSubmitEvent: Boolean;
begin
  FBrowser.Escape := True;
  Result := True;
end;

function TBrowserEventHandlers.SystemSettingsEvent: Boolean;
begin
  Result := SettingsDialogOpen;
end;

{ TOrchestratorEventHandler }

function TOrchestratorEventHandler.BuildDeserializationFailureResult: Boolean;
begin
  FBrowser.DisplayError(S_DESERIALIZATON_ERROR);
  Result := False;
end;

function TOrchestratorEventHandler.BuildJsonStateFailureResult: Boolean;
begin
  FBrowser.DisplayError(S_INVALID_PAYLOAD_EXPECTED_VALID_JSON);
  Result := False;
end;

function TOrchestratorEventHandler.BuildModelValidationFailureResult(
  const ErrorMessage: string; const State: TInputPromptState): Boolean;
begin
  FBrowser.DisplayError(ErrorMessage);
  FreeAndNil(State);
  Result := False;
end;

function TOrchestratorEventHandler.BuildStructuredOutputFailureResult: Boolean;
begin
  FBrowser.DisplayError(S_STRUCTURED_OUTPUT_ERROR);
  Result := False;
end;

function TOrchestratorEventHandler.CategoriesExists: Boolean;
begin
  Result :=
    not FBrowser.GetModelCategoriesFileName.Trim.IsEmpty and
    FileExists(FBrowser.GetModelCategoriesFileName);
end;

procedure TOrchestratorEventHandler.CompleteTurn(const Turn: TChatTurn;
  const AResult: TManagedItemLLMResult);
begin
  if not Assigned(Turn) or not Assigned(AResult) then
    Exit;

  Turn.Model := AResult.Model;
  Turn.JsonPrompt := AResult.JsonPrompt;
  Turn.Reasoning := AResult.TextReasoning;
  Turn.Response := AResult.TextResponse;
  Turn.JsonResponse := AResult.JsonResponse;
  Turn.ReponseFiles := AResult.FileList;
  Turn.ReponseImages := AResult.ImageList;
  Turn.ReponseAudio := AResult.AudioList;
  Turn.ReponseVideo := AResult.VideoList;
  Turn.DisplayBlocks := CloneChatDisplayBlocks(AResult.DisplayBlocks);

  if Assigned(FPersistentChat) then
    FPersistentChat.SaveToFile();

  var ID := FPersistentChat.CurrentChat.Id;
  FBrowser.ChatSessionAutoRename(ID, Turn.Prompt + #10 + Turn.Response);
end;

function TOrchestratorEventHandler.CreateTurnAndAddPrompt(
  const APayload: string; const State: TInputPromptState): TChatTurn;
begin
  if not Assigned(FPersistentChat) then
    Exit(nil);

  Result := FPersistentChat.AddPrompt;
  Result.JsonPromptState := APayload;
  Result.Index := FBrowser.PromptCount + 1;
  Result.Prompt := State.Text;
  Result.PromptImages := State.ToImageSources(State.Images);
  Result.PromptFiles :=
    State.ToFilePaths(State.Files) +
    State.ToFilePaths(State.Media.SpeechToText);
  Result.PromptKnowledgeSearch := State.ToFilePaths(State.KnowledgeSearch);

  {--- Persist the new prompt first, then ensure the session is visible in the browser UI. }
  FPersistentChat.SaveToFile();
  FBrowser.ChatSessionAdd(FPersistentChat.CurrentChat.Id, FPersistentChat.CurrentChat.Title);
end;

function TOrchestratorEventHandler.DefaultModelPanelIsUsed: Boolean;
begin
  Result := not (cpModels in FBrowser.CustomPanels);
end;

procedure TOrchestratorEventHandler.HandleOrchestratorError(
  const ErrorMessage: string; const Turn: TChatTurn);
begin
  if Assigned(Turn) then
    begin
      Turn.Response := ErrorMessage;
      if Assigned(FPersistentChat) then
        FPersistentChat.SaveToFile();
    end;

  FBrowser.ReasoningHide;
  FBrowser.Display(ErrorMessage);
  FBrowser.DisplayError(ErrorMessage);
  ReleaseTurnLock;
end;

function TOrchestratorEventHandler.TryHandleAsCommand(
  const PromptText: string): Boolean;
begin
  Result := FBrowser.TryHandleAsCommand(PromptText);
end;

function TOrchestratorEventHandler.JsonIsValid(const Reader: TJsonReader;
  const KeyName: string): Boolean;
begin
  var JsonSchemaAsString := Reader.AsString(KeyName);
  Result := TJsonReader.Parse(JsonSchemaAsString).IsValid;
end;

function TOrchestratorEventHandler.MissingDefaultModelFailureResult: Boolean;
begin
  FBrowser.DisplayWarning(S_MISSING_DEFAULT_MODELS_ERROR);
  Result := False;
end;

function TOrchestratorEventHandler.Normalize(const Payload: string): string;
begin
  if FBrowser.GetModelCategoriesFileName.Trim.IsEmpty or
     not FileExists(FBrowser.GetModelCategoriesFileName) then
    Exit(Payload);

  {--- Retrieve the JSON content }
  var ParamsPayload := TFileIOHelper.LoadFromFile(FBrowser.GetModelCategoriesFileName);
  var Writer := TJsonWriter.Parse(Payload);

  if not Writer.IsValid then
    Exit(Payload);

  {--- Add the JSON models to the current JSON }
  Writer.SetObjectJson('models', ParamsPayload);
  Writer.Remove('requestParams.appSettings.availableLanguages');
  Result := Writer.ToJSON;
end;

procedure TOrchestratorEventHandler.AddPromptFragmentConsumedPath(
  var APaths: TArray<string>; const APath: string);
begin
  for var Existing in APaths do
    if SameText(Existing, APath) then
      Exit;

  APaths := APaths + [APath];
end;

function TOrchestratorEventHandler.PromptFragmentPathWasConsumed(
  const APaths: TArray<string>; const APath: string): Boolean;
begin
  Result := False;

  for var Existing in APaths do
    if SameText(Existing, APath) then
      Exit(True);
end;

function TOrchestratorEventHandler.ExpandPromptFragments(
  const APayload: string; out AExpandedPayload: string;
  out AConsumedPaths: TArray<string>): Boolean;
var
  ConsumedPaths: TArray<string>;
begin
  {--- promptFragments is an optional browser-side overlay. Keep the original
       payload when the node is absent so the historical input flow is
       preserved. }
  AExpandedPayload := APayload;
  SetLength(AConsumedPaths, 0);
  Result := True;

  {--- Read the submitted browser state through the safe reader. Invalid JSON is
       left untouched and will be rejected by the normal validation pipeline. }
  var Reader := TJsonReader.Parse(APayload);
  if not Reader.IsValid then
    Exit;

  {--- No prompt fragment metadata means there is nothing to materialize. }
  if not Reader.IsArrayNode(PROP_PROMPT_FRAGMENTS) then
    Exit;

  var FragmentCount := Reader.Count(PROP_PROMPT_FRAGMENTS);
  if FragmentCount = 0 then
    Exit;

  {--- Replace each live placeholder by the content of its temporary text file.
       If the user removed a placeholder from the textarea, the file remains a
       regular attachment and is not consumed. }
  var PromptText := Reader.AsString(PROP_TEXT);

  for var index := 0 to FragmentCount - 1 do
    begin
      var FragmentPath := Format('%s[%d]', [PROP_PROMPT_FRAGMENTS, index]);
      var Placeholder := Reader.AsString(FragmentPath + '.' + PROP_PLACEHOLDER);
      var FullPath := Reader.AsString(FragmentPath + '.' + PROP_FULLPATH);

      if Placeholder.Trim.IsEmpty or FullPath.Trim.IsEmpty then
        begin
          FBrowser.DisplayError('Invalid prompt fragment metadata.');
          Exit(False);
        end;

      if Pos(Placeholder, PromptText) = 0 then
        Continue;

      if not FileExists(FullPath) then
        begin
          FBrowser.DisplayError(Format('Prompt fragment file not found: %s', [FullPath]));
          Exit(False);
        end;

      try
        var Content := TFileIOHelper.LoadFromFile(FullPath);
        PromptText := StringReplace(PromptText, Placeholder, Content, [rfReplaceAll]);
        AddPromptFragmentConsumedPath(ConsumedPaths, FullPath);
      except
        on E: Exception do
          begin
            FBrowser.DisplayError(E.Message);
            Exit(False);
          end;
      end;
    end;

  {--- Rewrite the state with the materialized prompt. TInputPromptState stays
       unchanged because the overlay is resolved before deserialization. }
  var Writer := TJsonWriter.Parse(APayload);
  if not Writer.IsValid then
    Exit(False);

  if not Writer.SetString(PROP_TEXT, PromptText) then
    Exit(False);

  {--- Files consumed as prompt fragments must not be sent to the vendor as
       regular attachments, otherwise the same content would be duplicated. }
  if Length(ConsumedPaths) > 0 then
    begin
      var FilesWriter := TJsonWriter.NewArray;
      var FileCount := Reader.Count(PROP_FILES);

      for var index := 0 to FileCount - 1 do
        begin
          var FilePath := Format('%s[%d]', [PROP_FILES, index]);
          var FullPath := Reader.AsString(FilePath + '.' + PROP_FULLPATH);

          if PromptFragmentPathWasConsumed(ConsumedPaths, FullPath) then
            Continue;

          if not FilesWriter.AppendObjectJson('', Reader.ObjectText(FilePath)) then
            Exit(False);
        end;

      if not Writer.SetArrayJson(PROP_FILES, FilesWriter.ToJson) then
        Exit(False);
    end;

  {--- promptFragments is a transport instruction only. Persist and deserialize
       the normalized state without this transient node. }
  Writer.Remove(PROP_PROMPT_FRAGMENTS);
  AExpandedPayload := Writer.ToJson;
  AConsumedPaths := ConsumedPaths;
end;

function TOrchestratorEventHandler.StructuredOutputIsValid(
  const Payload: string): Boolean;
begin
  var Reader := TJsonReader.Parse(Payload);

  var Enabled := Reader.AsBoolean(PROP_OUTPUT_STRUCTURED_ENABLED);

  if not Enabled then
    Exit(True);

  Result := JsonIsValid(Reader, PROP_OUTPUT_STRUCTURED_SCHEMA);
end;

function TOrchestratorEventHandler.SubmitAggregatedPromptToOrchestrator(
  const APayload: string): Boolean;
{--- Boundary method.
     Aggregates the browser prompt context, validates the submit session,
     persists the chat turn, delegates execution to the orchestrator,
     then folds the managed result back into the session and UI. }
var
  State: TInputPromptState;
  LocalTurn: TChatTurn;
  Payload: string;
begin
  LocalTurn := nil;
  State := nil;

  try
    {--- Validate the aggregated browser payload and prepare the input state
         required to submit the prompt to the orchestrator. }
    if not ValidateAggregatedPrompt(APayload, State, Payload) then
      Exit(False);

    try
      {--- Keep the exact browser payload as the source snapshot for this turn. }
      State.Source := Payload;

      {--- Persist the prompt before delegating the managed action,
           so the session keeps the submitted input state. }
      var Turn := CreateTurnAndAddPrompt(Payload, State);

      {--- Preserve the session turn for the asynchronous finalization callback. }
      LocalTurn := Turn;

      {--- Reflect the submitted prompt state immediately in the UI. }
      UpdatePromptUI(State);

      {--- Result means that the managed action was accepted for execution.
           The actual LLM result is handled by the callback below. }
      Result := FDialogService.ActivateManagedItemEvent(State,
        procedure (const AResult: TManagedItemLLMResult)
        begin
          {--- Reconcile the managed result with the persisted session turn. }
          try
            try
              CompleteTurn(LocalTurn, AResult);
              UpdateMessageUI(AResult);

              if AResult.HasError then
                FBrowser.DisplayError(AResult.AcquireError);
            except
              {--- Finalization barrier.
                   The managed result may come from success, error, or controlled
                   cancellation normalized through the promise rejection path.
                   Never raise from this post-settlement UI/session fold-back. }
            end;
          finally
            ReleaseTurnLock;
          end;
        end);

      if not Result then
        ReleaseTurnLock;
    finally
      FreeAndNil(State);
    end;

  except
    on E: Exception do
      begin
        HandleOrchestratorError(E.Message, LocalTurn);
        Result := False;
      end;
  end;
end;

function TOrchestratorEventHandler.TryDeserializeInputState(const APayload: string;
  out State: TInputPromptState): Boolean;
begin
  try
    State := TJson.JsonToObject<TInputPromptState>(APayload);
    Result := True;
  except
    on E: Exception do
      begin
        FreeAndNil(State);
        ReleaseTurnLock;
        FBrowser.DisplayError(
          Format(S_DESERIALIZATION_ERROR_FMT, [#10 + E.Message])
        );
        Exit(False);
      end;
  end;
end;

procedure TOrchestratorEventHandler.UpdateMessageUI(
  const State: TManagedItemLLMResult);
begin
  if (Length(State.DisplayBlocks) = 0) and
     (not State.TextResponse.Trim.IsEmpty or
      not State.TextReasoning.Trim.IsEmpty) then
    FBrowser.Display(State.TextResponse, State.TextReasoning, False);

  FBrowser.DisplayMedia(dkImages, State.ImageList, False);
  FBrowser.DisplayMedia(dkFile, State.FileList, False);
  FBrowser.DisplayMedia(dkVideo, State.VideoList, False);
  FBrowser.DisplayMedia(dkAudio, State.AudioList, False);
  FBrowser.DisplayFooter(State.Model);
  FBrowser.DisplaySpacer();
end;

procedure TOrchestratorEventHandler.ReleaseTurnLock;
begin
  FBrowser.Escape := False;
  if FBrowser.Locked then
    FBrowser.Locked := False;
end;

procedure TOrchestratorEventHandler.UpdatePromptUI(
  const State: TInputPromptState);
begin
  FBrowser.PromptMedia(dkImages, State.ToImageSources(State.Images), False);

  {--- Merge regular file attachments, speech-to-text audio files, and
       knowledge search references before replaying them into the prompt UI. }
  var Files :=
    State.ToFilePaths(State.Files) +
    State.ToFilePaths(State.Media.SpeechToText) +
    State.ToFilePaths(State.KnowledgeSearch);

  FBrowser.PromptMedia(dkFile, Files, False);
  FBrowser.Prompt(State.Text);
end;

function TOrchestratorEventHandler.ValidateAggregatedPrompt(
  const APayload: string; var State: TInputPromptState;
  out Payload: string): Boolean;
var
  ErrorMessage: string;
  ExpandedPayload: string;
  ConsumedFragmentPaths: TArray<string>;
begin
  if not ExpandPromptFragments(APayload, ExpandedPayload, ConsumedFragmentPaths) then
    Exit(False);

  var CommandReader := TJsonReader.Parse(ExpandedPayload);
  if CommandReader.IsValid then
    begin
      var Command := CommandReader.AsString('text');

      {--- Intercept slash commands before sending the prompt to the LLM.. }
      if TryHandleAsCommand(Command) then
        Exit(False);
    end;

  {--- Ensure the default model category is available before injecting
       the selected/default model into the payload. }
  if DefaultModelPanelIsUsed and not CategoriesExists then
    Exit(MissingDefaultModelFailureResult);

  {--- Normalize the browser payload by injecting the model selection expected
       by the orchestrator/session layer. }
  Payload := Normalize(ExpandedPayload);

  {--- Reject the submission while the browser is already processing a prompt
       or when the dialog service cannot accept managed execution. }
  if FBrowser.Locked or not ValidateDialogServiceAvailable(Payload) then
    Exit(False);

  {--- Validate structured-output constraints before accepting the payload
       as a candidate prompt submission. }
  if not StructuredOutputIsValid(Payload) then
    Exit(BuildStructuredOutputFailureResult);

  {--- Validate the final JSON payload before deserializing it into
       the input state snapshot. }
  Result := TJsonCheck.IsValid(Payload,
    procedure (Value: TJsonReader)
    begin
      {$IFDEF DEV_MODE}
      TFileIOHelper.SaveToFile(FBrowser.GetExchangeDebugFileName, Value.Format());
      {$ENDIF}
    end);

  if not Result then
    Exit(BuildJsonStateFailureResult);

  {--- Deserialize the input state snapshot received from the browser layer. }
  if not TryDeserializeInputState(Payload, State) then
    Exit(BuildDeserializationFailureResult);

  {--- Ensure all models referenced by the deserialized state are available
       before locking the browser and starting prompt processing. }
  if not ValidateRequiredModels(State, ErrorMessage) then
    Exit(BuildModelValidationFailureResult(ErrorMessage, State));

  {--- Enable cancellation for the upcoming prompt processing. }
  FBrowser.Escape := False;

  {--- Lock the browser interaction surface for the whole managed prompt lifecycle. }
  FBrowser.Locked := True;

  if Assigned(FBrowser.FileUploadService) then
    begin
      for var Path in ConsumedFragmentPaths do
        FBrowser.FileUploadService.CancelOrDelete(Path);
    end;

  Result := True;
end;

function TOrchestratorEventHandler.ValidateDialogServiceAvailable(const NormalizedPayload: string): Boolean;
begin
  if Assigned(FDialogService) then
    Exit(True);

  FBrowser.Clear;
  var Reader := TJsonReader.Parse(NormalizedPayload);
  FBrowser.Display(TEscapeHelper.ToPreformattedHTML(Reader.Format()));
  FBrowser.DisplayWarning(S_DIALOG_SERVICE_NOT_ASSIGNETD);
  FBrowser.DisplaySpacer();
  Result := False;
end;

function TOrchestratorEventHandler.ValidateRequiredModels(
  const State: TInputPromptState; out ErrorMessage: string): Boolean;
begin
    if cpModels in FBrowser.CustomPanels then
    Exit(True);

  if Length(State.Models.Categories) < 2 then
    begin
      ErrorMessage := S_MODELS_CATEGORIES_COUNT_ERROR;
      Exit(False);
    end;

  if Length(State.Models.Categories) <= DEEP_RESEARCH_INDEX then
    begin
      ErrorMessage := S_INVALID_CATEGORIES_FILE_ERROR;
      Exit(False);
    end;

  if State.Models.Categories[TEXT_GENERATION_INDEX].Model.IsEmpty then
    begin
      ErrorMessage := S_TEXT_GENERATION_CANT_HANDLED_ERROR;
      Exit(False);
    end;

  if State.Media.CreateImage and
     State.Models.Categories[IMAGE_GENERATION_INDEX].Model.IsEmpty then
    begin
      ErrorMessage := S_IMAGE_CREATION_ABORTED_ERROR;
      Exit(False);
    end;

  if State.Media.CreateVideo and
     State.Models.Categories[VIDEO_CREATION_INDEX].Model.IsEmpty then
    begin
      ErrorMessage := S_VIDEO_CREATION_ABORTED_ERROR;
      Exit(False);
    end;

  if State.Media.CreateAudio and
     State.Models.Categories[AUDIO_CREATION_INDEX].Model.IsEmpty then
    begin
      ErrorMessage := S_AUDIO_CREATION_ABORTED_ERROR;
      Exit(False);
    end;

  if State.Media.TextToSpeech and
     State.Models.Categories[TEXT_TO_SPEECH_INDEX].Model.IsEmpty then
    begin
      ErrorMessage := S_TTS_OPERATION_ABORTED_ERROR;
      Exit(False);
    end;

  if (Length(State.Media.SpeechToText) > 0) and
     State.Models.Categories[SPEECH_TO_TEXT_INDEX].Model.IsEmpty then
    begin
      ErrorMessage := S_STT_OPERATION_ABORTED_ERROR;
      Exit(False);
    end;

  if State.DeepResearch and
     State.Models.Categories[DEEP_RESEARCH_INDEX].Model.IsEmpty then
    begin
      ErrorMessage := S_DEEP_RESEARCH_OPERATION_ABORTED_ERROR;
      Exit(False);
    end;

  Result := True;
end;

{ TCardEventHandler }

function TCardEventHandler.CardDialogSelect: Boolean;
var
  DialogType: TChatManagedItemKind;
begin
  var ID := FReader.AsString('selectedCard.id');
  var Name := FReader.AsString('selectedCard.name');
  var Dialog := FReader.AsString('dialog');

  var Item := TChatManagedItemRef.Create(ID, Name);

  if not TChatManagedItemKind.TryToParse(Dialog, DialogType) then
    Exit(False);

  case DialogType of
    TChatManagedItemKind.function:
      EmitManagedItemSelection(INTEGRATION_FUNCTION_SELECTION, Item);

    TChatManagedItemKind.mcp:
      EmitManagedItemSelection(INTEGRATION_MCP_SELECTION, Item);

    TChatManagedItemKind.skills:
      EmitManagedItemSelection(INTEGRATION_SKILL_SELECTION, Item);

    TChatManagedItemKind.agents:
      EmitManagedItemSelection(INTEGRATION_AGENT_SELECTION, Item);

    TChatManagedItemKind.custom:
      EmitManagedItemSelection(CUSTOM_SELECTION, Item);

    TChatManagedItemKind.none:
      Exit(False);
  end;

  Result := True;
end;

function TCardEventHandler.EmitManagedItemSelection(const ATemplate: string;
  const AItem: TChatManagedItemRef): Boolean;
begin
  if AItem.Id.IsEmpty then
    Exit(False);

  {--- Inject the selected managed item back into the browser-side input model. }
  FBrowser.ExecuteScript(
    Format(ATemplate, [
      TEscapeHelper.EscapeJSString(AItem.Id),
      TEscapeHelper.EscapeJSString(AItem.Name)
    ])
  );

  Result := True;
end;

{ TDialogConfirmationEventHandler }

function TDialogConfirmationEventHandler.AttachFilesToInput(
  const APaths: TArray<string>;
  const ATarget: TOpenFileTarget): Boolean;
begin
  Result := False;

  if not Assigned(FBrowser) then
    Exit;

  var UploadService := FBrowser.FileUploadService;
  var IndexingService := FBrowser.KnowledgeIndexingService;

  for var Item in APaths do
    begin
      var Path := Item.Trim;

      if Path.IsEmpty then
        Continue;

      FBrowser.ExecuteScript(
        Format(FILES_SELECTION_TEMPLATE, [
          TEscapeHelper.EscapeJSString(Path),
          TEscapeHelper.EscapeJSString(ATarget.ToString)])
      );

      {--- Knowledge files go through the vectorization pipeline; every other
           target keeps using the plain upload pipeline. The two services are
           mutually exclusive on a per-file basis: a path never reaches both. }
      case ATarget of
        TOpenFileTarget.Knowledge:
          if Assigned(IndexingService) and
             IndexingService.ShouldHandle(Path, ATarget) then
            IndexingService.SubmitForIndexing(Path, ATarget, nil);
      else
        if Assigned(UploadService) and
           UploadService.ShouldHandle(Path, ATarget) then
          UploadService.SubmitForUpload(Path, ATarget, nil);
      end;

      Result := True;
    end;

  if Result and (ATarget = TOpenFileTarget.Speech) then
    FBrowser.BubbleInputSetText('[Transcription]');
end;

function TDialogConfirmationEventHandler.ConfirmationResponse: Boolean;
begin
  if FReader.AsBoolean(PROP_VALUE) = False then
    Exit(False);

  if not HasStringNodes([PROP_GOAL, PROP_TAG]) then
    Exit(False);

  var Goal  := TDialogGoal.Parse( FReader.AsString(PROP_GOAL) );
  var Tag   := FReader.AsString(PROP_TAG);


  if (Goal = TDialogGoal.DeleteDomBlock) then
    begin
      var index := FReader.AsInteger(PROP_INDEX);

      FBrowser.StopMedia;

      {--- Remove the DOM block first, then sync the prompt count and persisted chat. }
      FBrowser.ExecuteScript(
        Format(DELETE_BLOCK_TEMPLATE, [index.ToString])
      );

      {--- Update the remaining item count in the conversation. }
      FBrowser.PromptCount := index - 1;

      SavePersistentChatAfterDeletion;

      FBrowser.ScrollToAfterEnd(60, False);
    end
  else
  if Goal = TDialogGoal.DeleteChatSession then
    begin
      FBrowser.ChatSessionRemove(Tag);

      if not Assigned(FPersistentChat) then
        Exit(False);

      {--- Clear the browser only when the deleted session is the active one. }
      if Assigned(FPersistentChat.CurrentChat) and
         SameText(FPersistentChat.CurrentChat.Id, Tag) then
        FBrowser.Clear;

      FPersistentChat.DeleteChatById(Tag);
      FPersistentChat.SaveToFile();
    end;

  Result := True;
end;

function TDialogConfirmationEventHandler.HasStringNodes(
  const AProps: TArray<string>): Boolean;
begin
  for var PropName in AProps do
    if not FReader.IsStringNode(PropName) then
      Exit(False);

  Result := True;
end;

function TDialogConfirmationEventHandler.OpenFileDialog: Boolean;
var
  Filter: string;
  SelectedPaths: string;
begin
  if not Assigned(FOpenDialog) then
    Exit(False);

  if not HasStringNodes([PROP_TARGET]) then
    Exit(False);

  Result := True;

  var Target := TOpenFileTarget.Parse(FReader.AsString(PROP_TARGET));

  var FilterIndex := 0;
  case Target of
    TOpenFileTarget.Images:
        Filter := GRAPHIC_EXTENSION;

    TOpenFileTarget.Speech:
        Filter := AUDIO_EXTENSION;

    else
      Filter := DOCUMENTS_EXTENSION;
  end;

  if FOpenDialog.Execute(Filter, FilterIndex, SelectedPaths) then
    begin
      {--- Each selected path is pushed individually into the browser input
           model and, when applicable, routed through the upload service. }
      AttachFilesToInput(SelectedPaths.Split([#10]), Target);
    end;
end;

function TDialogConfirmationEventHandler.OpenManagedItemDialog(
  const AKind: TAdapterManagedItemKind; const ATemplate: string): Boolean;
begin
  var Item: TChatManagedItemRef;

  if not (cpCards in FBrowser.CustomPanels) then
    begin
      Result := FBrowser.TryGetCardFileContent(AKind.ToString,
        function (Content: string): Boolean
        begin
          Result := FBrowser.CardSelectorSetData(Content);
        end);

      if not Result then
        Exit(False);

      Result := FBrowser.CardSelectorShow(AKind.ToString);
      Exit;
    end;

  if (FDialogService = nil) or not FDialogService.SelectItem(AKind, Item) then
    Exit(False);

  Result := EmitManagedItemSelection(ATemplate, Item);
end;

procedure TDialogConfirmationEventHandler.SavePersistentChatAfterDeletion;
begin
  if not Assigned(FPersistentChat) or not Assigned(FPersistentChat.CurrentChat) then
    Exit;

  {--- Remove all turns from the updated prompt count onward. }
  FPersistentChat.CurrentChat.DeleteFrom(FBrowser.PromptCount);
  FPersistentChat.SaveToFile();
end;

{ TChatSessionEventHandler }

function TChatSessionEventHandler.ChatSessionItemDelete: Boolean;
begin
  if not HasStringNodes([PROP_ID]) or FBrowser.Locked then
    Exit(False);

  var Id := FReader.AsString(PROP_ID);

  {--- Deletion is confirmed asynchronously through the dialog response event. }
  Result := FBrowser.Confirmation(
    S_DELETE_CHAT_SESSION,
    TDialogGoal.DeleteChatSession.ToString,
    Id,
    -1
  );
end;

function TChatSessionEventHandler.ChatSessionItemRename: Boolean;
begin
  if not Assigned(FPersistentChat) or FBrowser.Locked then
    Exit(False);

  if not HasStringNodes([PROP_ID, PROP_VALUE]) then
    Exit(False);

  var Id := FReader.AsString(PROP_ID);
  var Title := FReader.AsString(PROP_VALUE);

  FPersistentChat.UpdateChatTitleById(Id, Title);
  FPersistentChat.SaveToFile();

  Result := True;
end;

function TChatSessionEventHandler.ChatSessionNextPage: Boolean;
begin
  if not Assigned(FPersistentChat) then
    Exit(False);

  Result := FBrowser.SettingsPanelLoadPage;
  if not Result then
    Exit(False);

  {--- Refresh the file drawer after paging so its content stays aligned
        with the newly displayed session range. }
  FBrowser.UpdateFileDrawer;
end;

function TChatSessionEventHandler.ChatSessionSelection: Boolean;
begin
  if not Assigned(FPersistentChat) or FBrowser.Locked then
    Exit(False);

  if not HasStringNodes([PROP_ID]) then
    Exit(False);

  var ID := FReader.AsString(PROP_ID);

  if Assigned(FPersistentChat.CurrentChat) then
    if SameText(FPersistentChat.CurrentChat.Id, ID) then
      Exit(False);

  Result := FPersistentChat.ActivateChatById(Id);
  if not Result then
    Exit(False);

  FBrowser.DisplayChatSession;
end;

function TChatSessionEventHandler.HasStringNodes(
  const AProps: TArray<string>): Boolean;
begin
  for var PropName in AProps do
    if not FReader.IsStringNode(PropName) then
      Exit(False);

  Result := True;
end;

function TChatSessionEventHandler.ChatSessionCreate: Boolean;
begin
  if FBrowser.Locked then
    begin
      FBrowser.SetFocus;
      Exit(False);
    end;

  {--- Reset the current browser view before starting a fresh conversation. }
  FBrowser.Clear;

  var NewChatRequested := FBrowser.OnNewChatRequested;
  if Assigned(NewChatRequested) then
    NewChatRequested();

  FBrowser.SetFocus;

  if FDialogService = nil then
    Exit(False);

  Result := FDialogService.ActivateNewChatEvent;
end;

{ TSelectorEventHandler }

function TSelectorEventHandler.Branch: Boolean;
begin
  if not Assigned(FPersistentChat) or not Assigned(FPersistentChat.CurrentChat) or
     FBrowser.Locked then
    Exit(False);

  if not HasStringNodes([PROP_PAIRID]) then
    Exit(False);

  var index := FReader.AsString(PROP_PAIRID);
  var ID := FPersistentChat.CurrentChat.Id;

  try
    if not FPersistentChat.ForkChatFromIndex(Id, index.ToInteger) then
      Exit(False);

    FPersistentChat.SaveToFile();

    {--- UI Update: The CurrentChat property now holds the forked chat state. }
    FBrowser.ChatSessionAdd(
      FPersistentChat.CurrentChat.Id,
      FPersistentChat.CurrentChat.Title);

    FBrowser.DisplayChatSession;

    Result := True;
  except
    on E: Exception do
      begin
        FBrowser.DisplayError(E.Message);
        Exit(False);
      end;
  end;
end;

function TSelectorEventHandler.Copy: Boolean;
begin
  if FBrowser.Locked then
    Exit(False);

  if not HasStringNodes([PROP_PAIRID, PROP_KIND, PROP_CONTENT]) then
    Exit(False);

  var PairID := FReader.AsString(PROP_PAIRID);
  var Kind := FReader.AsString(PROP_KIND);
  var Content := FReader.AsString(PROP_CONTENT);

  if FDialogService = nil then
    Exit(False);

  Result := FDialogService.ActivateCopyItemEvent(PairID, Kind, Content);
end;

function TSelectorEventHandler.Delete: Boolean;
begin
  if not HasStringNodes([PROP_PAIRID]) or FBrowser.Locked then
    Exit(False);

  var PairId := FReader.AsString(PROP_PAIRID);
  try
    var Index := PairId.ToInteger;

    if Index <= 1 then
      begin
        Exit(False);
      end;

    {--- The actual deletion is deferred until the confirmation response arrives. }
    FBrowser.Confirmation(
      S_DELETE_QA,
      TDialogGoal.DeleteDomBlock.ToString,
      '',
      Index
    );

    Result := True;
  except
    Result := False;
  end;
end;

{ TOpenFileEventHandler }

function TOpenFileEventHandler.OpenFile: Boolean;
begin
  if FRunProcess = nil then
    Exit(False);

  if not HasStringNodes([PROP_FILENAME]) then
    Exit(False);

  var FileName := FReader.AsString(PROP_FILENAME);
  FRunProcess.Open(FileName);

  Result := True;
end;

{ TCodeCopyEventHandler }

function TCodeCopyEventHandler.CodeCopy: Boolean;
begin
  if not HasStringNodes([PROP_LANG, PROP_TEXT]) then
    Exit(False);

  var Language := FReader.AsString(PROP_LANG);
  var Code := FReader.AsString(PROP_TEXT);

  if FDialogService = nil then
    Exit(False);

  Result := FDialogService.ActivateCodeCopyItemEvent(Language, Code);
end;

{ TBrowserScrollEventHandler }

function TBrowserScrollEventHandler.Scroll: Boolean;
begin
  if not HasStringNodes([PROP_DIRECTION]) then
    Exit(False);

  var Direction := TScrollDirection.Parse( FReader.AsString(PROP_DIRECTION) );

  if Direction = TScrollDirection.Top then
    begin
      FBrowser.ScrollToTop(False);
      Exit(True);
    end;

  Result := True;
  FBrowser.ScrollToAfterEnd(False);
end;

{ TModelsEventHandler }

function TModelsEventHandler.ModelsDialogOpen: Boolean;
begin
  if not (cpModels in FBrowser.CustomPanels) then
    begin
      FBrowser.BubbleInputMenuClose;
      FBrowser.ModelsSelectorShow;
      Result := True;
    end
  else
    begin
      Result := ActivateManagedItemEvent(TAdapterManagedItemKind.ModelSelection);
    end;
end;

function TModelsEventHandler.ModelsSelection: Boolean;
begin
  var FWriter := TJsonWriter.Parse(FReader.ToJson);
  if not FWriter.IsValid then
    Exit(False);

  if FWriter.Remove(PROP_EVENT) and
     FWriter.SetString(PROP_TYPE, 'model-selector-set-runtime-config')
    then
      begin
        Result := TJsonCheck.IsValid(FWriter.ToJson,
          procedure (Value: TJsonReader)
          begin
            TFileIOHelper.SaveToFile(FBrowser.GetModelCategoriesFileName, Value.Format());
          end);

        Exit;
      end
    else
      Exit(False);
end;

{ TSettingsEventHandler }

function TSettingsEventHandler.SettingsDialogOpen: Boolean;
begin
  if not (cpSettings in FBrowser.CustomPanels) then
    begin
      FBrowser.BubbleInputMenuClose;
      FBrowser.SettingsPanelShowPage(FBrowser.SettingsPanelPage);
      Result := True;
    end
  else
    begin
      Result := ActivateManagedItemEvent(TAdapterManagedItemKind.SystemSettings);
    end;
end;

end.

