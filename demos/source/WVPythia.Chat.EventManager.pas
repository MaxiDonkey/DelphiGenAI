unit WVPythia.Chat.EventManager;

interface

uses
  System.SysUtils, System.JSON,
  WVPythia.Chat.Interfaces, WVPythia.Chat.Consts, WVPythia.JSON.SafeReader,
  WVPythia.Types, WVPythia.Types.EnumWire, WVPythia.Chat.EventHandlers, WVPythia.Adapter,
  WVPythia.ChatSession.Controller;

type
  TBrowserEventMethod = function: Boolean of object;

  IBrowserEventManager = interface
    ['{D2CC5520-BA50-43BD-A250-193AC19E4264}']
    procedure SetBrowser(const Value: IPythiaBrowser);
    procedure SetOpenDialog(const Value: IOpenDialog);
    procedure SetRunProcess(const Value: IProcessExecute);
    procedure SetServiceAdapter(const Value: IChatManagedItemDialogService);
    procedure SetPersistentChat(const Value: IPersistentChat);

    function Aggregate(const Value: string): Boolean;
  end;

  TBrowserEventManager = class(TBrowserEventHandlers, IBrowserEventManager)
  private
    FDispatch: array[TBrowserChatEvent] of TBrowserEventMethod;
    procedure InitializeDispatch;
    procedure SetBrowser(const Value: IPythiaBrowser);
    procedure SetOpenDialog(const Value: IOpenDialog);
    procedure SetRunProcess(const Value: IProcessExecute);
    procedure SetServiceAdapter(const Value: IChatManagedItemDialogService);
    procedure SetPersistentChat(const Value: IPersistentChat);
  public
    constructor Create;
    function Aggregate(const Value: string): Boolean;
  end;

implementation

{$REGION 'Dev notes'}

(*
    Developer Note

    This unit is the concrete event dispatcher for the browser chat layer.
    It specializes TBrowserEventHandlers by wiring all browser event identifiers
    to their corresponding handler methods.

    Main responsibilities:
    • Hold the dispatch table from TBrowserChatEvent to handler methods.
    • Parse the raw JSON payload into FReader before dispatch.
    • Enforce the base readiness invariant through CanHandleEvents.
    • Receive injected dependencies from the application bootstrap code.

    Dispatch model:
    1. Aggregate receives the raw browser event payload as JSON text.
    2. The manager checks whether the handler layer is ready.
    3. The payload is parsed into FReader.
    4. The event name is extracted from PROP_EVENT and converted to TBrowserChatEvent.
    5. The corresponding method is looked up in FDispatch and invoked.

    Custom events
    -------------
    The dispatcher supports user-defined events through the reserved event:

        "event": "custom-event"

    Custom event payload MUST follow:

        {
          "event": "custom-event",
          "name": "<user-defined event name>",
          "payload": { ... }
        }

    Behavior:
    • "custom-event" is resolved through TBrowserChatEvent and routed like any
      built-in event via FDispatch.
    • The framework does not interpret or validate "name" or "payload".
    • The JSON payload is forwarded to the application layer without imposing
      a Delphi type (no deserialization contract).

    Flow:
    JS (postMessage)
      → Aggregate
      → CustomEvent handler (TBrowserEventHandlers)
      → IChatManagedItemDialogService.ActivateCustomEvent
      → TVCLChatManagedItemDialogService
      → User code

    Developer responsibilities:
    • Ensure emitted JSON is valid and well-formed.
    • Always use "event": "custom-event" for custom routing.
    • Define stable and unique event names (recommended: namespaced).
    • Parse and validate JSON on the Delphi side.
    • Handle malformed or unexpected payloads.

    Recommendations:
    • Use namespacing to avoid collisions:
        "plugin.export", "user.validate-form", etc.
    • Keep payload explicit and evolvable (versioning if needed).
    • Avoid interfering with framework-managed JS state.

    Limitations:
    • No automatic type binding (JSON is handled as raw data).
    • No built-in response channel (one-way communication).
    • Injected scripts run in the shared WebView context (no sandboxing).

    Important design detail:
    • This class does not implement business logic directly.
      Actual event behavior lives in TBrowserEventHandlers.
    • This class is responsible only for:
      * dependency injection storage
      * JSON event decoding
      * event-to-method routing

    Dependency lifecycle:
    • Other dependencies are injected later through the IBrowserEventManager setters.
    • Aggregate must only be called after the surrounding application has completed
      dependency injection.

    Reading this unit in isolation:
    • The concrete handler methods such as DeleteEvent, InputSubmitEvent, etc.
      are inherited from TBrowserEventHandlers.
    • Event names, parsing helpers, and constants come from Browser.Types,
      Browser.Types.EnumWire, and Browser.Chat.Consts.
    • Readiness checks are delegated to the inherited CanHandleEvents method.

*)

{$ENDREGION}

{$REGION 'JavaScript Templates and Custom Events'}

(*
    Developer Note — JavaScript Templates and Custom Events

    JavaScript templates injected into WebView2 must be written as isolated,
    self-executing units:

        (function () {
          ...
        })();

    This ensures proper encapsulation and prevents unintended pollution of the
    global window scope. Each template is responsible for managing its own state
    and DOM interactions.

    WebView2 communication boundary
    -------------------------------
    Communication with Delphi is strictly limited to the WebView2 bridge:

        window.chrome.webview.postMessage(...)

    Only messages sent through this API are received and processed by the Delphi
    event pipeline. DOM events or other JavaScript mechanisms are not propagated
    to Delphi.

    Built-in vs custom events
    ------------------------
    Two categories of events coexist:

    1. Framework (built-in) events
       • Directly posted using postMessage.
       • Must match TBrowserChatEvent identifiers.

       Example:
          window.chrome.webview.postMessage({
            event: "input-submit",
            state: ...
          });

    2. Custom events (user-defined)
       • Must use the reserved event name:

            "event": "custom-event"

       • Full contract:

            {
              "event": "custom-event",
              "name": "<user-defined event name>",
              "payload": { ... },
              "requestId": "..."   // optional
            }

    Recommended user bridge
    -----------------------
    For user/custom templates, expose a minimal helper:

        window.AppHost = Object.freeze({
          emit(name, payload = {}, requestId = crypto.randomUUID()) {
            window.chrome.webview.postMessage({
              event: "custom-event",
              name,
              payload,
              requestId
            });
            return requestId;
          }
        });

    Public usage:

        AppHost.emit("plugin.my-action", { id: 42 });

    Important:
    • AppHost.emit is intended for custom/user events only.
    • Framework templates may continue to call postMessage directly for
      built-in events.

    Template responsibilities
    -------------------------
    • Keep scripts self-contained (IIFE pattern).
    • Do not overwrite framework globals.
    • Use window namespace only for explicit APIs.
    • Emit only JSON-serializable data.
    • Maintain stable event names and payload structure.

    Event naming recommendations
    ----------------------------
        "plugin.export"
        "plugin.my-feature"
        "user.validate-form"

    Delphi-side expectations
    ------------------------
    • The Delphi layer receives the full JSON message.
    • No deserialization model is imposed.
    • The application layer is responsible for parsing and validation.

    Thread-safe JSON handling
    -------------------------
    JSON must be parsed using the thread-safe reader provided by the framework
    (see Browser.JSON.SafeReader).

    Recommended pattern:

        var Reader := TJsonReader.Parse(ARawJson);

        if not Reader.IsValid then
          Exit(False);

        var EventName := Reader.AsString('name');

        if Reader.HasNode('payload') then
        begin
          var Payload := Reader['payload'];

          if Payload.HasNode('id') then
          begin
            var Id := Payload.AsInteger('id');
            // process Id
          end;
        end;

    Notes:
    • Always validate presence of nodes before reading.
    • Never assume structure of "payload".
    • The reader is safe to use within the event pipeline and avoids
      manual JSON parsing errors.
    • Keep parsing local to the handler; do not leak JSON dependencies upward.

    Limitations
    -----------
    • No automatic type binding.
    • No built-in response channel (one-way messaging).
    • No sandbox: all scripts execute in the shared WebView context.

*)

{$ENDREGION}

{ TBrowserEventManager }

function TBrowserEventManager.Aggregate(const Value: string): Boolean;
var
  EventKind: TBrowserChatEvent;
begin
  if not CanHandleEvents then
    Exit(False);

  {--- Parse the raw browser event payload once and expose it
       through the inherited safe reader for downstream handlers. }
  FReader := TJsonReader.Parse(Value);
  if not FReader.IsValid or not HasStringNodes([PROP_EVENT]) then
    Exit(False);

  var EventName := FReader.AsString(PROP_EVENT);

  {--- Resolve the event kind, then route it through the prebuilt dispatch table. }
  if not TBrowserChatEvent.TryToParse(EventName, EventKind) then
    begin
      FBrowser.DisplayError(Format('%s: event not supported', [EventName]));
      Exit(False);
    end;

  var Handler: TBrowserEventMethod := FDispatch[EventKind];
  Result := Assigned(Handler) and Handler();
end;

constructor TBrowserEventManager.Create;
begin
  inherited Create;

  {--- Script execution is part of the base readiness invariant,
       so it is captured at construction time. }
  InitializeDispatch;
end;

procedure TBrowserEventManager.InitializeDispatch;
begin
  {--- Bind each browser event identifier to its inherited handler method. }
  FDispatch[TBrowserChatEvent.&Copy] := CodeCopyEvent;
  FDispatch[TBrowserChatEvent.ScrollRequest] := ScrollRequestEvent;
  FDispatch[TBrowserChatEvent.StopSubmit] := StopSubmitEvent;
  FDispatch[TBrowserChatEvent.InputSubmit] := InputSubmitEvent;
  FDispatch[TBrowserChatEvent.InputState] := InputStateEvent;
  FDispatch[TBrowserChatEvent.OpenFileDialog] := OpenFileDialogEvent;
  FDispatch[TBrowserChatEvent.FileRemoved] := FileRemovedEvent;
  FDispatch[TBrowserChatEvent.OpenIntegrationFunctionDialog] := OpenFunctionDialogEvent;
  FDispatch[TBrowserChatEvent.OpenIntegrationMcpDialog] := OpenMCPDialogEvent;
  FDispatch[TBrowserChatEvent.OpenIntegrationSkillsDialog] := OpenSkillsDialogEvent;
  FDispatch[TBrowserChatEvent.OpenIntegrationAgentsDialog] := OpenAgentsDialogEvent;
  FDispatch[TBrowserChatEvent.OpenCustomDialog] := OpenCustomDialogEvent;
  FDispatch[TBrowserChatEvent.DisplayFileClick] := DisplayFileClickEvent;
  FDispatch[TBrowserChatEvent.BranchEvent] := BranchEvent;
  FDispatch[TBrowserChatEvent.CopyEvent] := CopyEvent;
  FDispatch[TBrowserChatEvent.DeleteEvent] := DeleteEvent;
  FDispatch[TBrowserChatEvent.SystemSettings] := SystemSettingsEvent;
  FDispatch[TBrowserChatEvent.ResquestParamsPageChanged] := ResquestParamsPageChangedEvent;
  FDispatch[TBrowserChatEvent.ModelSelection] := ModelSelectionEvent;
  FDispatch[TBrowserChatEvent.DialogConfirmationResponse] := DialogConfirmationResponseEvent;
  FDispatch[TBrowserChatEvent.NewChatEvent] := NewChatSessionEvent;
  FDispatch[TBrowserChatEvent.ChatSelectionEvent] := ChatSelectionEvent;
  FDispatch[TBrowserChatEvent.ChatNextPageEvent] := ChatNextPageEvent;
  FDispatch[TBrowserChatEvent.ChatItemDeleteEvent] := ChatItemDeleteEvent;
  FDispatch[TBrowserChatEvent.ChatItemRenameEvent] := ChatItemRenameEvent;
  FDispatch[TBrowserChatEvent.RequestParamsValues] := RequestParamsValuesEvent;
  FDispatch[TBrowserChatEvent.LookAndFeelSelectedEvent] := LookAndFeelSelectedEvent;
  FDispatch[TBrowserChatEvent.LanguageSelectedEvent] := LanguageSelectedEvent;
  FDispatch[TBrowserChatEvent.ScrollButtonSelectedEvent] := ScrollButtonSelectedEvent;
  FDispatch[TBrowserChatEvent.ModelSelectorGetReplaceVersion] := ModelSelectorGetReplaceVersionEvent;
  FDispatch[TBrowserChatEvent.CardSelectionDialogSelectionChanged] := CardSelectionDialogSelectionChangedEvent;
  FDispatch[TBrowserChatEvent.CardSelectionDialogSelect] := CardSelectionDialogSelectEvent;
  FDispatch[TBrowserChatEvent.CardSelectionDialogCancel] := CardSelectionDialogCancelEvent;
  FDispatch[TBrowserChatEvent.CardSelectionDialogSettings] := CardSelectionDialogSettingsEvent;
  FDispatch[TBrowserChatEvent.AudioInput] := AudioInputEvent;
  FDispatch[TBrowserChatEvent.InputString] := InputString;
  FDispatch[TBrowserChatEvent.WebDecisionDlgResponse] := WebDecisionDlgResponseEvent;
  FDispatch[TBrowserChatEvent.CustomEvent] := CustomEvent;
  FDispatch[TBrowserChatEvent.FileDropIn] := FileDropInEvent;
  FDispatch[TBrowserChatEvent.PasteFromClipboard] := PasteFromClipboardEvent;
  FDispatch[TBrowserChatEvent.FolderSelection] := FolderSelectionEvent;
  FDispatch[TBrowserChatEvent.FolderState] := FolderStateEvent;
  FDispatch[TBrowserChatEvent.AudioRecord] := AudioRecordEvent;
end;

procedure TBrowserEventManager.SetBrowser(const Value: IPythiaBrowser);
begin
  {--- Inject the browser bridge used by inherited handlers for UI mutations. }
  FBrowser := Value;
end;

procedure TBrowserEventManager.SetOpenDialog(const Value: IOpenDialog);
begin
  {--- Inject the file dialog service for file and image selection events. }
  FOpenDialog := Value;
end;

procedure TBrowserEventManager.SetPersistentChat(const Value: IPersistentChat);
begin
  {--- Inject the persistence layer used by handlers to load and mutate chat sessions. }
  FPersistentChat := Value;
end;

procedure TBrowserEventManager.SetRunProcess(const Value: IProcessExecute);
begin
  {--- Inject the process launcher used for external file opening actions. }
  FRunProcess := Value;
end;

procedure TBrowserEventManager.SetServiceAdapter(
  const Value: IChatManagedItemDialogService);
begin
  {--- Inject the managed item service used by integration and command dialogs. }
  FDialogService := Value;
end;

end.
