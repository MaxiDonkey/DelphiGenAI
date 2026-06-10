unit FMX.WVPythia.Services;

interface

uses
  Fmx.Dialogs,
  System.SysUtils,

  WVPythia.Adapter, WVPythia.Chat.ManagedFlow, WVPythia.ManagedItemService;

type
  TFMXChatManagedItemDialogService = class(TCustomChatManagedItemDialogService)
  protected
    function DoSelectFunctionItem(
      out AItem: TChatManagedItemRef): Boolean; override;

    function DoSelectMCPItem(
      out AItem: TChatManagedItemRef): Boolean; override;

    function DoSelectSkillItem(
      out AItem: TChatManagedItemRef): Boolean; override;

    function DoSelectAgentItem(
      out AItem: TChatManagedItemRef): Boolean; override;

    function DoSelectCustomItem(
      out AItem: TChatManagedItemRef): Boolean; override;

    function DoActivateSystemSettings: Boolean; override;
    function DoActivateModelSelection: Boolean; override;

    function DoActivateInputState(
      const AState: TInputPromptState;
      const AOnFinalize: TManagedItemFinalizeProc): Boolean; override;

    function DoActivateCopyItemEvent(
      const APairId, AKind, AContent: string): Boolean; override;

    function DoActivateCodeCopyItemEvent(
      const ALang, AText: string): Boolean; override;

    function DoActivateNewChatEvent: Boolean; override;

    function DoActivateCardSettingsEvent: Boolean; override;

    function DoActivateAudioInputEvent: Boolean; override;
  end;

  TToolContainer = record
    class function SelectFunctionItem(out AItem: TChatManagedItemRef): Boolean; static;
    class function SelectMCPItem(out AItem: TChatManagedItemRef): Boolean; static;
    class function SelectSkillItem(out AItem: TChatManagedItemRef): Boolean; static;
    class function SelectAgentItem(out AItem: TChatManagedItemRef): Boolean; static;
    class function SelectCustomItem(out AItem: TChatManagedItemRef): Boolean; static;

    class function ActivateSystemPrompt: Boolean; static;
    class function ActivateModelSelection: Boolean; static;
    class function ActivateInputState(
      const AState: TInputPromptState;
      const AOnFinalize: TManagedItemFinalizeProc): Boolean; static;
    class function ActivateCopyItemEvent(
      const APairId, AKind, AContent: string): Boolean; static;
    class function ActivateCodeCopyItemEvent(
      const ALang, AText: string): Boolean; static;
    class function ActivateNewChatEvent: Boolean; static;
    class function ActivateCardSettingsEvent: Boolean; static;
    class function ActivateAudioInputEvent: Boolean; static;
  end;

implementation

uses
  Main, Demo.OpenAI.Services;

{ TFMXChatManagedItemDialogService }

function TFMXChatManagedItemDialogService.DoActivateCodeCopyItemEvent(
  const ALang, AText: string): Boolean;
begin
  Result := TToolContainer.ActivateCodeCopyItemEvent(ALang, AText);
end;

function TFMXChatManagedItemDialogService.DoActivateCopyItemEvent(const APairId,
  AKind, AContent: string): Boolean;
begin
  Result := TToolContainer.ActivateCopyItemEvent(APairId, AKind, AContent);
end;

function TFMXChatManagedItemDialogService.DoActivateInputState(
  const AState: TInputPromptState;
  const AOnFinalize: TManagedItemFinalizeProc): Boolean;
begin
  Result := TToolContainer.ActivateInputState(AState, AOnFinalize);
end;

function TFMXChatManagedItemDialogService.DoActivateModelSelection: Boolean;
begin
  Result := TToolContainer.ActivateModelSelection;
end;

function TFMXChatManagedItemDialogService.DoActivateSystemSettings: Boolean;
begin
  Result := TToolContainer.ActivateSystemPrompt;
end;

function TFMXChatManagedItemDialogService.DoActivateAudioInputEvent: Boolean;
begin
  Result := TToolContainer.ActivateAudioInputEvent;
end;

function TFMXChatManagedItemDialogService.DoActivateCardSettingsEvent: Boolean;
begin
  Result := TToolContainer.ActivateCardSettingsEvent;
end;

function TFMXChatManagedItemDialogService.DoActivateNewChatEvent: Boolean;
begin
  Result := TToolContainer.ActivateNewChatEvent;
end;

function TFMXChatManagedItemDialogService.DoSelectAgentItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := TToolContainer.SelectAgentItem(AItem);
end;

function TFMXChatManagedItemDialogService.DoSelectCustomItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := TToolContainer.SelectCustomItem(AItem);
end;

function TFMXChatManagedItemDialogService.DoSelectFunctionItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := TToolContainer.SelectFunctionItem(AItem);
end;

function TFMXChatManagedItemDialogService.DoSelectMCPItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := TToolContainer.SelectMCPItem(AItem);
end;

function TFMXChatManagedItemDialogService.DoSelectSkillItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := TToolContainer.SelectSkillItem(AItem);
end;

{ TToolContainer }

class function TToolContainer.ActivateCodeCopyItemEvent(const ALang,
  AText: string): Boolean;
begin
  Result := True;

  (*
  ShowMessage(
    'Code copy intercepted' + sLineBreak +
    'Lang = ' + ALang
  );
  *)
end;

class function TToolContainer.ActivateCopyItemEvent(const APairId, AKind,
  AContent: string): Boolean;
begin
  Result := True;

  (*
  ShowMessage(
    'Copy intercepted' + sLineBreak +
    'PairId = ' + APairId + sLineBreak +
    'Kind = ' + AKind + sLineBreak +
    'Content = ' + AContent
  );
  *)
end;

class function TToolContainer.ActivateInputState(
  const AState: TInputPromptState;
  const AOnFinalize: TManagedItemFinalizeProc): Boolean;
begin
  Result :=
    Assigned(OpenAIVendor) and
    Assigned(AState) and
    Assigned(AOnFinalize);
  if not Result then
    Exit;

  OpenAIVendor.AsyncAwaitStreamChat(AState, AOnFinalize);
end;

class function TToolContainer.ActivateModelSelection: Boolean;
begin
  Result := True;
  (*ShowMessage('Todo Model selection');*)
end;

class function TToolContainer.ActivateSystemPrompt: Boolean;
begin
  Result := True;
  (*ShowMessage('Todo custom settings');*)
end;

class function TToolContainer.ActivateAudioInputEvent: Boolean;
begin
  Result := True;
  {ShowMessage('Todo audio input');}
end;

class function TToolContainer.ActivateCardSettingsEvent: Boolean;
begin
  Result := True;
  (*ShowMessage('Todo settings card');*)
end;

class function TToolContainer.ActivateNewChatEvent: Boolean;
begin
  Result := True;
//  ShowMessage('New chat');
end;

class function TToolContainer.SelectAgentItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  {--- Non-intrusive: let Pythia's standard agent-card selector populate
       State.Integration.Agents. The OpenAI demo service routes the selected
       card through Demo.OpenAI.TextTurn at submit time. }
  AItem := Default(TChatManagedItemRef);
  Result := False;
end;

class function TToolContainer.SelectCustomItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := True;
  (*
  ShowMessage('Todo custom selection: custom Item');

  {--- Simulated return value here to maintain UI consistency }
  AItem := TChatManagedItemRef.Create(Trunc(Random(20000) + 1).ToString, 'custom service');
  *)
end;

class function TToolContainer.SelectFunctionItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := True;
  (*
  ShowMessage('Todo custom selection: function Item');

  {--- Simulated return value here to maintain UI consistency }
  AItem := TChatManagedItemRef.Create(Trunc(Random(20000) + 1).ToString, 'Function name');
  *)
end;

class function TToolContainer.SelectMCPItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := True;
  (*
  ShowMessage('Todo custom selection: MCP Item');

  {--- Simulated return value here to maintain UI consistency }
  AItem := TChatManagedItemRef.Create(Trunc(Random(20000) + 1).ToString, 'MCP-Title');
  *)
end;

class function TToolContainer.SelectSkillItem(
  out AItem: TChatManagedItemRef): Boolean;
begin
  Result := True;
  (*
  ShowMessage('Todo custom selection: skill Item');

  {--- Simulated return value here to maintain UI consistency }
  AItem := TChatManagedItemRef.Create(Trunc(Random(20000) + 1).ToString, 'custom-skill');
  *)
end;

end.


