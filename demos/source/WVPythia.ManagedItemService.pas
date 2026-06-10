unit WVPythia.ManagedItemService;

interface

uses
  WVPythia.Types, WVPythia.Adapter, WVPythia.Chat.ManagedFlow;

type
  TCustomChatManagedItemDialogService = class(TInterfacedObject, IChatManagedItemDialogService)
  protected
    function DoSelectFunctionItem(out AItem: TChatManagedItemRef): Boolean; virtual;
    function DoSelectMCPItem(out AItem: TChatManagedItemRef): Boolean; virtual;
    function DoSelectSkillItem(out AItem: TChatManagedItemRef): Boolean; virtual;
    function DoSelectAgentItem(out AItem: TChatManagedItemRef): Boolean; virtual;
    function DoSelectCustomItem(out AItem: TChatManagedItemRef): Boolean; virtual;

    function DoActivateSystemSettings: Boolean; virtual;
    function DoActivateModelSelection: Boolean; virtual;

    function DoActivateCopyItemEvent(
      const APairId, AKind, AContent: string): Boolean; virtual;

    function DoActivateCodeCopyItemEvent(
      const ALang, AText: string): Boolean; virtual;

    function DoActivateInputState(
      const AState: TInputPromptState;
      const AOnFinalize: TManagedItemFinalizeProc): Boolean; virtual; abstract;

    function DoActivateNewChatEvent: Boolean; virtual; abstract;

    function DoActivateCardSettingsEvent: Boolean; virtual; abstract;

    function DoActivateAudioInputEvent: Boolean; virtual; abstract;

    function DoActivateCustomEvent(const ARawJson: string): Boolean; virtual;

    function FinalizeResult(
      const AOnFinalize: TManagedItemFinalizeProc;
      const AResult: TManagedItemLLMResult;
      const AOwnsResult: Boolean = True): Boolean; virtual;

  public
    function SelectItem(
      const AKind: TAdapterManagedItemKind;
      out AItem: TChatManagedItemRef): Boolean;

    function ActivateManagedItemEvent(
      const AKind: TAdapterManagedItemKind): Boolean; overload;

    function ActivateManagedItemEvent(
      const AState: TInputPromptState;
      const AOnFinalize: TManagedItemFinalizeProc): Boolean; overload;

    function ActivateCopyItemEvent(
      const APairId, AKind, AContent: string): Boolean;

    function ActivateCodeCopyItemEvent(
      const ALang, AText: string): Boolean;

    function ActivateNewChatEvent: Boolean;

    function ActivateCardSettingEvent: Boolean;

    function ActivateAudioInputEvent: Boolean;

    function ActivateCustomEvent(const ARawJson: string): Boolean;
  end;

implementation

{$REGION 'Dev notes'}

(*
    Developer Note

    This unit defines the shared base service used by the browser chat layer to
    delegate managed item selection and UI-driven actions to the application layer.

    Purpose
    -------
    TCustomChatManagedItemDialogService is the common implementation of
    IChatManagedItemDialogService. It provides a stable service boundary between
    browser events and concrete application behavior, independently of the UI
    framework used by the host application.

    Main responsibilities:
      Expose a single service entry point for managed item selection.
      Route managed item kinds to their corresponding virtual methods.
      Expose activation methods for UI actions raised by the browser layer.
      Provide default no-op behavior for optional features.
      Keep application-specific behavior out of the browser event layer.

    Selection model:
      SelectItem dispatches TAdapterManagedItemKind to:
      . DoSelectFunctionItem
      . DoSelectMCPItem
      . DoSelectSkillItem
      . DoSelectAgentItem
      . DoSelectCustomItem

    Activation model:
      ActivateManagedItemEvent dispatches application actions such as:
      . system settings
      . model selection
      . card settings
      . audio input

      ActivateManagedItemEvent(AState, AOnFinalize) delegates prompt submission
      handling to DoActivateInputState.

      Dedicated activation methods are provided for:
      . copy item events
      . code copy events
      . new chat events
      . card settings
      . audio input
      . custom events

    Custom events:
      ActivateCustomEvent forwards the JSON received from the browser layer to
      DoActivateCustomEvent.
      No deserialization model is imposed at this level.
      Concrete descendants are responsible for parsing, validating, and handling
      the custom event payload.

    Finalization:
      FinalizeResult centralizes callback execution and optional ownership release
      for TManagedItemLLMResult instances.
      The result object is freed when AOwnsResult is True.

    Design boundaries:
      This unit is shared by VCL, FMX, and any other concrete UI layer.
      This unit does not implement framework-specific dialogs or workflows.
      This unit does not know how managed items are selected.
      This unit does not parse custom payloads.
      Concrete behavior must be implemented by descendants in the appropriate
      UI/application service layer.

    Extension rule:
      Override only the Do* methods required by the concrete application layer.
      Leave unused features with their default False behavior.
      Keep browser event decoding in the event layer and business/UI behavior in
      concrete service descendants.

*)

{$ENDREGION}

{ TCustomChatManagedItemDialogService }

function TCustomChatManagedItemDialogService.ActivateManagedItemEvent(
  const AKind: TAdapterManagedItemKind): Boolean;
begin
  case AKind of
    TAdapterManagedItemKind.SystemSettings:
      Result := DoActivateSystemSettings;

    TAdapterManagedItemKind.ModelSelection:
      Result := DoActivateModelSelection;

    TAdapterManagedItemKind.CardButtonSettings:
      Result := DoActivateCardSettingsEvent;

    TAdapterManagedItemKind.AudioInput:
      Result := DoActivateAudioInputEvent;
  else
    Result := False;
  end;
end;

function TCustomChatManagedItemDialogService.ActivateAudioInputEvent: Boolean;
begin
  Result := DoActivateAudioInputEvent;
end;

function TCustomChatManagedItemDialogService.ActivateCardSettingEvent: Boolean;
begin
  Result := DoActivateCardSettingsEvent;
end;

function TCustomChatManagedItemDialogService.ActivateCodeCopyItemEvent(
  const ALang, AText: string): Boolean;
begin
  Result := DoActivateCodeCopyItemEvent(ALang, AText);
end;

function TCustomChatManagedItemDialogService.ActivateCopyItemEvent(
  const APairId, AKind, AContent: string): Boolean;
begin
  Result := DoActivateCopyItemEvent(APairId, AKind, AContent);
end;

function TCustomChatManagedItemDialogService.ActivateCustomEvent(
  const ARawJson: string): Boolean;
begin
  Result := DoActivateCustomEvent(ARawJson);
end;

function TCustomChatManagedItemDialogService.ActivateManagedItemEvent(
  const AState: TInputPromptState;
  const AOnFinalize: TManagedItemFinalizeProc): Boolean;
begin
  Result := DoActivateInputState(AState, AOnFinalize);
end;

function TCustomChatManagedItemDialogService.ActivateNewChatEvent: Boolean;
begin
   Result := DoActivateNewChatEvent;
end;

function TCustomChatManagedItemDialogService.DoActivateCodeCopyItemEvent(
  const ALang, AText: string): Boolean;
begin
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoActivateCopyItemEvent(
  const APairId, AKind, AContent: string): Boolean;
begin
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoActivateCustomEvent(
  const ARawJson: string): Boolean;
begin
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoActivateModelSelection: Boolean;
begin
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoActivateSystemSettings: Boolean;
begin
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoSelectAgentItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  AItem := Default(TChatManagedItemRef);
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoSelectCustomItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  AItem := Default(TChatManagedItemRef);
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoSelectFunctionItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  AItem := Default(TChatManagedItemRef);
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoSelectMCPItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  AItem := Default(TChatManagedItemRef);
  Result := False;
end;

function TCustomChatManagedItemDialogService.DoSelectSkillItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  AItem := Default(TChatManagedItemRef);
  Result := False;
end;

function TCustomChatManagedItemDialogService.FinalizeResult(
  const AOnFinalize: TManagedItemFinalizeProc;
  const AResult: TManagedItemLLMResult;
  const AOwnsResult: Boolean): Boolean;
begin
  Result := Assigned(AOnFinalize) and Assigned(AResult);

  try
    if Result then
      AOnFinalize(AResult);
  finally
    if AOwnsResult and Assigned(AResult) then
      AResult.Free;
  end;
end;

function TCustomChatManagedItemDialogService.SelectItem(
  const AKind: TAdapterManagedItemKind;
  out AItem: TChatManagedItemRef): Boolean;
begin
  AItem := Default(TChatManagedItemRef);

  case AKind of
    TAdapterManagedItemKind.FunctionItem:
      Result := DoSelectFunctionItem(AItem);

    TAdapterManagedItemKind.MCP:
      Result := DoSelectMCPItem(AItem);

    TAdapterManagedItemKind.Skills:
      Result := DoSelectSkillItem(AItem);

    TAdapterManagedItemKind.Agents:
      Result := DoSelectAgentItem(AItem);

    TAdapterManagedItemKind.Custom:
      Result := DoSelectCustomItem(AItem);
  else
    Result := False;
  end;
end;

end.
