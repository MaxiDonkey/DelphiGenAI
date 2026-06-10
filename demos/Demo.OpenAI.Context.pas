unit Demo.OpenAI.Context;

interface

{$REGION 'Dev note'}
(*

  Conversation context for the pythia-openai FMX demo.

  Responses offers two distinct continuity strategies:
    - local replay: rebuild input from the turns persisted by Pythia;
    - cloud chaining: send only the new user item with previous_response_id.

  BuildMessages keeps these paths separate. Local replay clones the last
  historical user message and the prior response.output items verbatim. This
  intentionally preserves opaque and newly introduced items such as compaction
  without teaching the demo their internal schema. Uploaded file_id content is
  dropped during replay because those temporary uploads may no longer exist.

  LastResponseId and ShouldUsePreviousResponseId expose the cloud path to the
  service layer, which remains responsible for applying previous_response_id
  to TResponsesParams.

  HistoricalVectorStoreIds exposes file_search vector stores from saved request
  payloads so the service layer can keep them attached during local replay only.

*)
{$ENDREGION}

uses
  System.SysUtils,
  GenAI, GenAI.Types, GenAI.Helpers,
  WVPythia.Chat.Interfaces, WVPythia.ChatSession.Controller,
  WVPythia.Vendors.Services;

type
  IContext = interface
    ['{9E1085A1-AA34-49CE-ADB7-A5E655D7D204}']
    function HasHistory: Boolean;
    function GetHistory: TArray<TInputListItem>;
    function LastResponseId: string;
    function ShouldUsePreviousResponseId(const AState: TStateBuffer): Boolean;
    function HasHistoricalCodeExecution: Boolean;
    function HistoricalVectorStoreIds: TArray<string>;

    function BuildMessages(
      const AState: TStateBuffer;
      const ACurrentContent: TArray<TItemContent>): TArray<TInputListItem>;
  end;

  TOpenAIContext = class(TInterfacedObject, IContext)
  private
    FBrowser: IPythiaBrowser;
    function CurrentSession: TChatSession;
    function HistoryTurns(const AChat: TChatSession): TArray<TChatTurn>;
    function FindLastTerminalResponseJson(
      const AJsonResponse: string): string;
    function ExtractResponseIdFromJsonResponse(
      const AJsonResponse: string): string;
    function BuildHistoricalUserItem(
      const ATurn: TChatTurn): TInputListItem;
    function BuildAssistantItems(
      const ATurn: TChatTurn): TArray<TInputListItem>;
    procedure AppendTurn(
      var AItems: TInputItems;
      const ATurn: TChatTurn);
  public
    constructor Create(const ABrowser: IPythiaBrowser);

    function HasHistory: Boolean;
    function GetHistory: TArray<TInputListItem>;
    function LastResponseId: string;
    function ShouldUsePreviousResponseId(const AState: TStateBuffer): Boolean;
    function HasHistoricalCodeExecution: Boolean;
    function HistoricalVectorStoreIds: TArray<string>;

    function BuildMessages(
      const AState: TStateBuffer;
      const ACurrentContent: TArray<TItemContent>): TArray<TInputListItem>;

    class function CreateInstance(const ABrowser: IPythiaBrowser): IContext; static;
  end;

implementation

uses
  System.JSON,
  WVPythia.JSON.SafeReader, WVPythia.JSON.SafeWriter,
  Demo.OpenAI.Helpers, Demo.OpenAI.JsonResponse.Helper;

type
  TRawInputListItem = class(TInputListItem)
  public
    class function FromJson(const AJson: TJSONObject): TInputListItem; static;
  end;

{ TRawInputListItem }

class function TRawInputListItem.FromJson(
  const AJson: TJSONObject): TInputListItem;
begin
  Result := nil;
  if not Assigned(AJson) then
    Exit;

  var Item := TRawInputListItem.Create;
  for var Pair in AJson do
    Item.Add(Pair.JsonString.Value, TJSONValue(Pair.JsonValue.Clone));

  Result := Item;
end;

function CloneReplayUserItem(
  const AReader: TJsonReader;
  const APath: string): TInputListItem;
begin
  Result := nil;
  if not AReader.IsObjectNode(APath) then
    Exit;

  var Writer := TJsonWriter.Parse(AReader.ObjectText(APath));
  if not Writer.IsValid then
    Exit;

  if AReader.IsArrayNode(APath + '.content') then
    begin
      for var I := AReader.Count(APath + '.content') - 1 downto 0 do
        begin
          var SourcePath := Format('%s.content[%d]', [APath, I]);
          if AReader.Exists(SourcePath + '.file_id') and
             not Writer.Remove(Format('content[%d]', [I])) then
            Exit;
        end;

      var SanitizedReader := TJsonReader.Parse(Writer.ToJson);
      if not SanitizedReader.IsValid or
         (SanitizedReader.Count('content') = 0) then
        Exit;
    end;

  Result := TRawInputListItem.FromJson(Writer.JSONObject);
end;

function IsTerminalResponseType(const AType: string): Boolean;
begin
  Result :=
    SameText(AType, 'response.completed') or
    SameText(AType, 'response.incomplete');
end;

function IsExecutionItemType(const AType: string): Boolean;
begin
  Result :=
    SameText(AType, 'code_interpreter_call') or
    SameText(AType, 'local_shell_call') or
    SameText(AType, 'shell_call') or
    SameText(AType, 'apply_patch_call');
end;

function HasExecutionTrace(const AJsonResponse: string): Boolean;
begin
  Result :=
    AJsonResponse.Contains('"type":"code_interpreter_call"') or
    AJsonResponse.Contains('"type": "code_interpreter_call"') or
    AJsonResponse.Contains('"type":"local_shell_call"') or
    AJsonResponse.Contains('"type": "local_shell_call"') or
    AJsonResponse.Contains('"type":"shell_call"') or
    AJsonResponse.Contains('"type": "shell_call"') or
    AJsonResponse.Contains('"type":"apply_patch_call"') or
    AJsonResponse.Contains('"type": "apply_patch_call"');
end;

function IsStoredOnlyReplayItemType(const AType: string): Boolean;
begin
  Result :=
    SameText(AType, 'file_search_call');
end;

function ExtractVectorStoreIdsFromPromptJson(
  const AJsonPrompt: string): TArray<string>;
begin
  Result := [];
  if AJsonPrompt.Trim.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(AJsonPrompt);
  if not Reader.IsValid or not Reader.IsArrayNode('tools') then
    Exit;

  for var I := 0 to Reader.Count('tools') - 1 do
    begin
      var ToolPath := Format('tools[%d]', [I]);
      if not SameText(Reader.AsString(ToolPath + '.type'), 'file_search') or
         not Reader.IsArrayNode(ToolPath + '.vector_store_ids') then
        Continue;

      for var VectorStoreId in Reader.ArrayStrings(ToolPath + '.vector_store_ids') do
        if not VectorStoreId.Trim.IsEmpty then
          Result := Result + [VectorStoreId.Trim];
    end;
end;

function ResponseWasStored(const ATurn: TChatTurn): Boolean;
begin
  Result := False;
  if not Assigned(ATurn) or ATurn.JsonPrompt.Trim.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(ATurn.JsonPrompt);
  if Reader.IsValid then
    Result := Reader.AsBoolean('store');
end;

function ReplayItemIsUsable(
  const AReader: TJsonReader;
  const APath: string;
  const AResponseWasStored: Boolean): Boolean;
begin
  Result := AReader.IsObjectNode(APath);
  if not Result then
    Exit;

  var ItemType := AReader.AsString(APath + '.type');

  {--- A file_search_call output item has an fs_... id that only remains
       resolvable by OpenAI when the originating response was stored. In local
       replay with store=false, the tool must stay attached through
       vector_store_ids, but the old transient fs_... item must be removed. }
  if not AResponseWasStored and IsStoredOnlyReplayItemType(ItemType) then
    Exit(False);

  if not SameText(ItemType, 'reasoning') then
    Exit;

  {--- Stateless reasoning items can only be replayed when their encrypted
       content was requested on the original response. Older sessions may not
       contain it: retain their assistant message, but skip this unusable item. }
  Result :=
    AResponseWasStored or
    not AReader.AsString(APath + '.encrypted_content').Trim.IsEmpty;
end;

{ TOpenAIContext }

constructor TOpenAIContext.Create(const ABrowser: IPythiaBrowser);
begin
  inherited Create;
  FBrowser := ABrowser;
end;

class function TOpenAIContext.CreateInstance(
  const ABrowser: IPythiaBrowser): IContext;
begin
  Result := TOpenAIContext.Create(ABrowser);
end;

function TOpenAIContext.CurrentSession: TChatSession;
begin
  Result := nil;
  if not Assigned(FBrowser) then
    Exit;

  var Persistent := FBrowser.PersistentChat;
  if not Assigned(Persistent) then
    Exit;

  Result := Persistent.CurrentChat;
end;

function TOpenAIContext.HistoryTurns(
  const AChat: TChatSession): TArray<TChatTurn>;
begin
  Result := [];
  if not Assigned(AChat) then
    Exit;

  for var Turn in AChat.Data do
    begin
      if not Assigned(Turn) then
        Continue;

      if Turn.Prompt.Trim.IsEmpty or Turn.Response.Trim.IsEmpty then
        Continue;

      Result := Result + [Turn];
    end;
end;

function TOpenAIContext.FindLastTerminalResponseJson(
  const AJsonResponse: string): string;
begin
  Result := '';
  var Normalized := TOpenAIJsonResponseHelper
    .NormalizeJsonResponse(AJsonResponse);

  for var Event in Normalized.Split([sLineBreak]) do
    begin
      if Event.Trim.IsEmpty then
        Continue;

      var Reader := TJsonReader.Parse(Event);
      if not Reader.IsValid then
        Continue;

      if IsTerminalResponseType(Reader.AsString('type')) then
        Result := Event;
    end;
end;

function TOpenAIContext.ExtractResponseIdFromJsonResponse(
  const AJsonResponse: string): string;
begin
  Result := '';
  var Event := FindLastTerminalResponseJson(AJsonResponse);
  if Event.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(Event);
  if Reader.IsValid then
    Result := Reader.AsString('response.id');
end;

function TOpenAIContext.BuildHistoricalUserItem(
  const ATurn: TChatTurn): TInputListItem;
begin
  Result := nil;
  if not Assigned(ATurn) or ATurn.JsonPrompt.Trim.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(ATurn.JsonPrompt);
  if not Reader.IsValid then
    Exit;

  if Reader.IsStringNode('input') then
    Exit(Generation.Payload.User(Reader.AsString('input')));

  if not Reader.IsArrayNode('input') then
    Exit;

  for var I := Reader.Count('input') - 1 downto 0 do
    begin
      var ItemPath := Format('input[%d]', [I]);
      if not Reader.IsObjectNode(ItemPath) then
        Continue;

      if SameText(Reader.AsString(ItemPath + '.role'), 'user') then
        Exit(CloneReplayUserItem(Reader, ItemPath));
    end;
end;

function TOpenAIContext.BuildAssistantItems(
  const ATurn: TChatTurn): TArray<TInputListItem>;
begin
  Result := [];
  if not Assigned(ATurn) then
    Exit;

  var Event := FindLastTerminalResponseJson(ATurn.JsonResponse);
  if Event.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(Event);
  if not Reader.IsValid or
     not Reader.IsArrayNode('response.output') then
    Exit;

  var WasStored := ResponseWasStored(ATurn);

  for var I := 0 to Reader.Count('response.output') - 1 do
    begin
      var ItemPath := Format('response.output[%d]', [I]);
      if not ReplayItemIsUsable(Reader, ItemPath, WasStored) then
        Continue;

      var Item := Reader.Value(ItemPath);
      if Item is TJSONObject then
        Result := Result + [
          TRawInputListItem.FromJson(TJSONObject(Item))
        ];
    end;
end;

procedure TOpenAIContext.AppendTurn(
  var AItems: TInputItems;
  const ATurn: TChatTurn);
begin
  {--- Hosted execution traces are response artifacts. For local replay, keep
       follow-up turns conversational by replaying only the visible exchange. }
  if HasExecutionTrace(ATurn.JsonResponse) then
    begin
      AItems := AItems.User(ATurn.Prompt);
      AItems := AItems.Assistant(ATurn.Response);
      Exit;
    end;

  var UserItem := BuildHistoricalUserItem(ATurn);
  if Assigned(UserItem) then
    AItems := AItems.AddItem(UserItem)
  else
    AItems := AItems.User(ATurn.Prompt);

  var AssistantItems := BuildAssistantItems(ATurn);
  if Length(AssistantItems) = 0 then
    begin
      AItems := AItems.Assistant(ATurn.Response);
      Exit;
    end;

  for var Item in AssistantItems do
    AItems := AItems.AddItem(Item);
end;

function TOpenAIContext.HasHistory: Boolean;
begin
  Result := Length(HistoryTurns(CurrentSession)) > 0;
end;

function TOpenAIContext.GetHistory: TArray<TInputListItem>;
begin
  var Items := Generation.MessageParts;

  for var Turn in HistoryTurns(CurrentSession) do
    AppendTurn(Items, Turn);

  Result := Items;
end;

function TOpenAIContext.LastResponseId: string;
begin
  Result := '';
  var Turns := HistoryTurns(CurrentSession);

  for var I := High(Turns) downto 0 do
    begin
      Result := ExtractResponseIdFromJsonResponse(Turns[I].JsonResponse);
      if not Result.IsEmpty then
        Exit;
    end;
end;

function TOpenAIContext.ShouldUsePreviousResponseId(
  const AState: TStateBuffer): Boolean;
begin
  Result :=
    TStateChecking.UsesPreviousResponseId(AState) and
    not LastResponseId.IsEmpty;
end;

function TOpenAIContext.HasHistoricalCodeExecution: Boolean;
begin
  Result := False;

  for var Turn in HistoryTurns(CurrentSession) do
    begin
      var Event := FindLastTerminalResponseJson(Turn.JsonResponse);
      if Event.IsEmpty then
        Continue;

      var Reader := TJsonReader.Parse(Event);
      if not Reader.IsValid then
        Continue;

      for var I := 0 to Reader.Count('response.output') - 1 do
        if IsExecutionItemType(
          Reader.AsString(Format('response.output[%d].type', [I]))) then
          Exit(True);
    end;
end;

function TOpenAIContext.HistoricalVectorStoreIds: TArray<string>;
begin
  Result := [];

  for var Turn in HistoryTurns(CurrentSession) do
    Result := Result + ExtractVectorStoreIdsFromPromptJson(Turn.JsonPrompt);

  Result := TArrayUtils.ArrayRemoveDuplicates(Result);
end;

function TOpenAIContext.BuildMessages(
  const AState: TStateBuffer;
  const ACurrentContent: TArray<TItemContent>): TArray<TInputListItem>;
begin
  var Items := Generation.MessageParts;

  if not ShouldUsePreviousResponseId(AState) then
    for var Turn in HistoryTurns(CurrentSession) do
      AppendTurn(Items, Turn);

  Items := Items.AddItem(
    TInputMessage.New.Role('user').Content(ACurrentContent));

  Result := Items;
end;

end.
