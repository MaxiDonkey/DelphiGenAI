unit WVPythia.Chat.DecisionDlg;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.JSON,
  System.Generics.Collections,
  WVPythia.JSON.SafeReader;

const
  WEB_DECISION_DLG_REQUEST_TYPE = 'web-decision-dlg-request';
  WEB_DECISION_DLG_RESPONSE_EVENT = 'web-decision-dlg-response';
  WEB_DECISION_DLG_INFINITE = Cardinal($FFFFFFFF);

type
  TWebDecisionDlgContentFormat = (
    wdcText,
    wdcMarkdown
  );

  TWebDecisionDlgButtonRole = (
    wdrNeutral,
    wdrDefault,
    wdrCancel,
    wdrDanger
  );

  TWebDecisionDlgButton = record
    Id: string;
    Text: string;
    I18nKey: string;
    Role: TWebDecisionDlgButtonRole;
    Disabled: Boolean;

    class function Create(
      const AId: string;
      const AText: string = '';
      const ARole: TWebDecisionDlgButtonRole = wdrNeutral;
      const AI18nKey: string = '';
      const ADisabled: Boolean = False): TWebDecisionDlgButton; static;
  end;

  TWebDecisionDlgRequest = record
    RequestId: string;
    Title: string;
    TitleKey: string;
    Content: string;
    ContentFormat: TWebDecisionDlgContentFormat;
    FooterText: string;
    FooterTextKey: string;
    CloseText: string;
    CloseTextKey: string;
    Buttons: TArray<TWebDecisionDlgButton>;
    ShowClose: Boolean;

    class function Markdown(
      const ATitle: string;
      const AContent: string;
      const AButtons: TArray<TWebDecisionDlgButton>): TWebDecisionDlgRequest; static;

    class function Text(
      const ATitle: string;
      const AContent: string;
      const AButtons: TArray<TWebDecisionDlgButton>): TWebDecisionDlgRequest; static;
  end;

  TWebDecisionDlgResult = record
    RequestId: string;
    ChoiceId: string;
    ClosedBy: string;
    Success: Boolean;

    class function Error(
      const ARequestId: string;
      const AReason: string): TWebDecisionDlgResult; static;

    class function Timeout(
      const ARequestId: string): TWebDecisionDlgResult; static;
  end;

  TWebDecisionDlgBroker = class
  private
    type
      TPendingDecision = class
      public
        Event: TEvent;
        Result: TWebDecisionDlgResult;
        constructor Create(const ARequestId: string);
        destructor Destroy; override;
      end;

  private
    FLock: TObject;
    FPending: TDictionary<string, TPendingDecision>;

    class function NewRequestId: string; static;
    class function ContentFormatToString(
      const AValue: TWebDecisionDlgContentFormat): string; static;
    class function ButtonRoleToString(
      const AValue: TWebDecisionDlgButtonRole): string; static;
    class function NormalizeRequest(
      const ARequest: TWebDecisionDlgRequest): TWebDecisionDlgRequest; static;
    class function DefaultButtonText(
      const AButton: TWebDecisionDlgButton): string; static;
    class function JsonBool(const AValue: Boolean): TJSONValue; static;

    procedure AddPending(const ARequestId: string; const APending: TPendingDecision);
    procedure RemovePending(const ARequestId: string);
    function TryGetPending(
      const ARequestId: string;
      out APending: TPendingDecision): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    class function RequestToJson(
      const ARequest: TWebDecisionDlgRequest): string; static;

    function ExecuteSync(
      const ARequest: TWebDecisionDlgRequest;
      const APostMessage: TFunc<string, Boolean>;
      const ATimeoutMS: Cardinal = WEB_DECISION_DLG_INFINITE): TWebDecisionDlgResult;

    function ResolveResponse(const AJson: string): Boolean;
  end;

implementation

uses
  WVPythia.Strs;

{ TWebDecisionDlgButton }

class function TWebDecisionDlgButton.Create(
  const AId,
  AText: string;
  const ARole: TWebDecisionDlgButtonRole;
  const AI18nKey: string;
  const ADisabled: Boolean): TWebDecisionDlgButton;
begin
  Result.Id := AId;
  Result.Text := AText;
  Result.I18nKey := AI18nKey;
  Result.Role := ARole;
  Result.Disabled := ADisabled;
end;

{ TWebDecisionDlgRequest }

class function TWebDecisionDlgRequest.Markdown(
  const ATitle,
  AContent: string;
  const AButtons: TArray<TWebDecisionDlgButton>): TWebDecisionDlgRequest;
begin
  Result := Default(TWebDecisionDlgRequest);
  Result.Title := ATitle;
  Result.Content := AContent;
  Result.ContentFormat := wdcMarkdown;
  Result.Buttons := AButtons;
  Result.ShowClose := True;
end;

class function TWebDecisionDlgRequest.Text(
  const ATitle,
  AContent: string;
  const AButtons: TArray<TWebDecisionDlgButton>): TWebDecisionDlgRequest;
begin
  Result := Markdown(ATitle, AContent, AButtons);
  Result.ContentFormat := wdcText;
end;

{ TWebDecisionDlgResult }

class function TWebDecisionDlgResult.Error(
  const ARequestId,
  AReason: string): TWebDecisionDlgResult;
begin
  Result := Default(TWebDecisionDlgResult);
  Result.RequestId := ARequestId;
  Result.ChoiceId := '';
  Result.ClosedBy := AReason;
  Result.Success := False;
end;

class function TWebDecisionDlgResult.Timeout(
  const ARequestId: string): TWebDecisionDlgResult;
begin
  Result := Error(ARequestId, 'timeout');
end;

{ TWebDecisionDlgBroker.TPendingDecision }

constructor TWebDecisionDlgBroker.TPendingDecision.Create(const ARequestId: string);
begin
  inherited Create;
  Event := TEvent.Create(nil, True, False, '');
  Result := TWebDecisionDlgResult.Error(ARequestId, 'pending');
end;

destructor TWebDecisionDlgBroker.TPendingDecision.Destroy;
begin
  Event.Free;
  inherited Destroy;
end;

{ TWebDecisionDlgBroker }

constructor TWebDecisionDlgBroker.Create;
begin
  inherited Create;
  FLock := TObject.Create;
  FPending := TDictionary<string, TPendingDecision>.Create;
end;

destructor TWebDecisionDlgBroker.Destroy;
begin
  TMonitor.Enter(FLock);
  try
    for var Pending in FPending.Values do
      begin
        Pending.Result := TWebDecisionDlgResult.Error(Pending.Result.RequestId, 'destroyed');
        Pending.Event.SetEvent;
      end;
    FPending.Clear;
  finally
    TMonitor.Exit(FLock);
  end;

  FPending.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TWebDecisionDlgBroker.AddPending(
  const ARequestId: string;
  const APending: TPendingDecision);
begin
  TMonitor.Enter(FLock);
  try
    if FPending.ContainsKey(ARequestId) then
      raise Exception.CreateFmt(
        S_WEB_DECISION_DLG_ALREADY_PENDING_FMT,
        [ARequestId]);

    FPending.Add(ARequestId, APending);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class function TWebDecisionDlgBroker.ButtonRoleToString(
  const AValue: TWebDecisionDlgButtonRole): string;
begin
  case AValue of
    wdrDefault:
      Result := 'default';
    wdrCancel:
      Result := 'cancel';
    wdrDanger:
      Result := 'danger';
  else
    Result := 'neutral';
  end;
end;

class function TWebDecisionDlgBroker.ContentFormatToString(
  const AValue: TWebDecisionDlgContentFormat): string;
begin
  case AValue of
    wdcMarkdown:
      Result := 'markdown';
  else
    Result := 'text';
  end;
end;

class function TWebDecisionDlgBroker.DefaultButtonText(
  const AButton: TWebDecisionDlgButton): string;
begin
  if AButton.Role = wdrCancel then
    Result := S_WEB_DECISION_DLG_CANCEL
  else
    Result := S_WEB_DECISION_DLG_OK;
end;

function TWebDecisionDlgBroker.ExecuteSync(
  const ARequest: TWebDecisionDlgRequest;
  const APostMessage: TFunc<string, Boolean>;
  const ATimeoutMS: Cardinal): TWebDecisionDlgResult;
begin
  if not Assigned(APostMessage) then
    Exit(TWebDecisionDlgResult.Error(ARequest.RequestId, 'post-message-not-assigned'));

  var Request := NormalizeRequest(ARequest);
  var Pending := TPendingDecision.Create(Request.RequestId);
  try
    AddPending(Request.RequestId, Pending);
    try
      if not APostMessage(RequestToJson(Request)) then
        Exit(TWebDecisionDlgResult.Error(Request.RequestId, 'post-message-failed'));

      case Pending.Event.WaitFor(ATimeoutMS) of
        wrSignaled:
          Result := Pending.Result;
        wrTimeout:
          Result := TWebDecisionDlgResult.Timeout(Request.RequestId);
      else
        Result := TWebDecisionDlgResult.Error(Request.RequestId, 'wait-failed');
      end;
    finally
      RemovePending(Request.RequestId);
    end;
  finally
    Pending.Free;
  end;
end;

class function TWebDecisionDlgBroker.NewRequestId: string;
begin
  var Guid: TGUID;
  if CreateGUID(Guid) = 0 then
    Result := GUIDToString(Guid).Trim(['{', '}'])
  else
    Result := FormatDateTime('yyyymmddhhnnsszzz', Now) + '-' + IntToHex(Random(MaxInt), 8);
end;

class function TWebDecisionDlgBroker.NormalizeRequest(
  const ARequest: TWebDecisionDlgRequest): TWebDecisionDlgRequest;
begin
  Result := ARequest;

  if Result.RequestId.Trim.IsEmpty then
    Result.RequestId := NewRequestId;

  if Result.Title.Trim.IsEmpty and Result.TitleKey.Trim.IsEmpty then
    Result.Title := S_WEB_DECISION_DLG_TITLE;

  if Result.Content.Trim.IsEmpty then
    Result.Content := S_WEB_DECISION_DLG_MESSAGE;

  if Result.ShowClose and
     Result.CloseText.Trim.IsEmpty and
     Result.CloseTextKey.Trim.IsEmpty then
    Result.CloseText := S_WEB_DECISION_DLG_CLOSE;

  if Length(Result.Buttons) = 0 then
    Result.Buttons := [
      TWebDecisionDlgButton.Create(
        'ok',
        S_WEB_DECISION_DLG_OK,
        wdrDefault)
    ];

  for var I := 0 to High(Result.Buttons) do
    if Result.Buttons[I].Text.Trim.IsEmpty and
       Result.Buttons[I].I18nKey.Trim.IsEmpty then
      Result.Buttons[I].Text := DefaultButtonText(Result.Buttons[I]);
end;

class function TWebDecisionDlgBroker.RequestToJson(
  const ARequest: TWebDecisionDlgRequest): string;
begin
  var Request := NormalizeRequest(ARequest);

  var Root := TJSONObject.Create;
  try
    Root.AddPair('type', WEB_DECISION_DLG_REQUEST_TYPE);
    Root.AddPair('requestId', Request.RequestId);

    if not Request.Title.Trim.IsEmpty then
      Root.AddPair('title', Request.Title);
    if not Request.TitleKey.Trim.IsEmpty then
      Root.AddPair('titleKey', Request.TitleKey);

    Root.AddPair('content', Request.Content);
    Root.AddPair('contentFormat', ContentFormatToString(Request.ContentFormat));
    if not Request.FooterText.Trim.IsEmpty then
      Root.AddPair('footerText', Request.FooterText);
    if not Request.FooterTextKey.Trim.IsEmpty then
      Root.AddPair('footerTextKey', Request.FooterTextKey);
    if not Request.CloseText.Trim.IsEmpty then
      Root.AddPair('closeText', Request.CloseText);
    if not Request.CloseTextKey.Trim.IsEmpty then
      Root.AddPair('closeTextKey', Request.CloseTextKey);
    Root.AddPair('showClose', JsonBool(Request.ShowClose));

    var Buttons := TJSONArray.Create;
    Root.AddPair('buttons', Buttons);

    for var Button in Request.Buttons do
      begin
        var Item := TJSONObject.Create;
        Buttons.AddElement(Item);

        Item.AddPair('id', Button.Id);
        if not Button.Text.Trim.IsEmpty then
          Item.AddPair('text', Button.Text);
        if not Button.I18nKey.Trim.IsEmpty then
          Item.AddPair('i18nKey', Button.I18nKey);

        Item.AddPair('role', ButtonRoleToString(Button.Role));
        Item.AddPair('disabled', JsonBool(Button.Disabled));
      end;

    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

class function TWebDecisionDlgBroker.JsonBool(const AValue: Boolean): TJSONValue;
begin
  if AValue then
    Result := TJSONTrue.Create
  else
    Result := TJSONFalse.Create;
end;

procedure TWebDecisionDlgBroker.RemovePending(const ARequestId: string);
begin
  TMonitor.Enter(FLock);
  try
    FPending.Remove(ARequestId);
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TWebDecisionDlgBroker.ResolveResponse(const AJson: string): Boolean;
begin
  Result := False;

  var Reader := TJsonReader.Parse(AJson);
  if not Reader.IsValid then
    Exit;

  if not SameText(Reader.AsString('event'), WEB_DECISION_DLG_RESPONSE_EVENT) then
    Exit;

  var RequestId := Reader.AsString('requestId').Trim;
  if RequestId.IsEmpty then
    Exit;

  var Pending: TPendingDecision;
  if not TryGetPending(RequestId, Pending) then
    Exit;

  Pending.Result.RequestId := RequestId;
  Pending.Result.ChoiceId := Reader.AsString('choiceId');
  Pending.Result.ClosedBy := Reader.AsString('closedBy', 'button');
  Pending.Result.Success := Reader.AsBoolean('success', True);
  Pending.Event.SetEvent;

  Result := True;
end;

function TWebDecisionDlgBroker.TryGetPending(
  const ARequestId: string;
  out APending: TPendingDecision): Boolean;
begin
  TMonitor.Enter(FLock);
  try
    Result := FPending.TryGetValue(ARequestId, APending);
  finally
    TMonitor.Exit(FLock);
  end;
end;

end.
