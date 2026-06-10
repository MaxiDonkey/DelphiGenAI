unit WVPythia.ChatSession.Controller;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  WVPythia.JSON.Resource, WVPythia.JSON.Resource.Lists;

type
  TChatSession = class;
  TChatSessionList = class;
  TPersistentChat = class;
  TChatDisplayBlock = class;

  TChatDisplayItem = class(TJSONResource)
  strict private
    FTitle: string;
    FText: string;
    FUrl: string;
    FPath: string;
    FMimeType: string;
  public
    function Clone: TChatDisplayItem;

    property Title: string read FTitle write FTitle;
    property Text: string read FText write FText;
    property Url: string read FUrl write FUrl;
    property Path: string read FPath write FPath;
    property MimeType: string read FMimeType write FMimeType;
  end;

  TChatDisplayBlock = class(TJSONResource)
  strict private
    FKind: string;
    FTitle: string;
    FText: string;
    FUrl: string;
    FItems: TArray<TChatDisplayItem>;
    procedure SetItems(const Value: TArray<TChatDisplayItem>);
  public
    function Clone: TChatDisplayBlock;

    property Kind: string read FKind write FKind;
    property Title: string read FTitle write FTitle;
    property Text: string read FText write FText;
    property Url: string read FUrl write FUrl;
    property Items: TArray<TChatDisplayItem> read FItems write SetItems;

    destructor Destroy; override;
  end;

  TGUIDBuilder = record
    class function Create(const Brace: Boolean = False): string; static;
  end;

  TUnixDateTime = record
    class function Now: Int64; static;
  end;

  TSortOrder = (soAscending, soDescending);

  TChatList = record
    Id: string;
    Title: string;
    Index: Integer;
  end;

  TChatListPage = record
    Items: TArray<TChatList>;
    FirstId: string;
    LastId: string;
    HasMore: Boolean;
  end;

  TChatSortItem = record
    Id: string;
    Title: string;
    Index: Integer;
    ModifiedAt: Int64;
  end;

  TChatListPageHelper = record Helper for TChatListPage
  private
    function ItemsToJsonString: string;
  public
    function ToJsonString(const FirstPage: Boolean = False): string;
  end;


  IPersistentChatRuntime = interface
    ['{34B0F7F7-8F53-4D41-94D4-2B4E1D9D7F45}']
    function GetCurrentChat: TChatSession;
    procedure SetCurrentChat(const Value: TChatSession);
    function GetData: TChatSessionList;

    property CurrentChat: TChatSession read GetCurrentChat write SetCurrentChat;
    property Data: TChatSessionList read GetData;
  end;

  TChatTurn = class(TJSONResource)
  strict private
    FId: string;
    FIndex: Integer;
    FStorage: Boolean;

    FModel: string;

    FPrompt: string;
    FJsonPromptState: string;
    FPromptFiles: TArray<string>;
    FPromptKnowledgeSearch: TArray<string>;
    FPromptImages: TArray<string>;
    FJsonPrompt: string;

    FResponse: string;
    FReasoning: string;
    FJsonResponse: string;
    FReponseFiles: TArray<string>;
    FReponseImages: TArray<string>;
    FReponseAudio: TArray<string>;
    FReponseVideo: TArray<string>;
    FDisplayBlocks: TArray<TChatDisplayBlock>;
    FDisplayBlocksJson: string;
    procedure SetDisplayBlocks(const Value: TArray<TChatDisplayBlock>);
    procedure SetDisplayBlocksJson(const Value: string);
  public
    property Id: string read FId write FId;
    property Index: Integer read FIndex write FIndex;
    property Storage: Boolean read FStorage write FStorage;
    property Model: string read FModel write FModel;
    property Prompt: string read FPrompt write FPrompt;
    property Response: string read FResponse write FResponse;
    property Reasoning: string read FReasoning write FReasoning;
    property JsonPromptState: string read FJsonPromptState write FJsonPromptState;
    property JsonPrompt: string read FJsonPrompt write FJsonPrompt;
    property PromptFiles: TArray<string> read FPromptFiles write FPromptFiles;
    property PromptKnowledgeSearch: TArray<string> read FPromptKnowledgeSearch write FPromptKnowledgeSearch;
    property PromptImages: TArray<string> read FPromptImages write FPromptImages;
    property JsonResponse: string read FJsonResponse write FJsonResponse;
    property ReponseFiles: TArray<string> read FReponseFiles write FReponseFiles;
    property ReponseImages: TArray<string> read FReponseImages write FReponseImages;
    property ReponseAudio: TArray<string> read FReponseAudio write FReponseAudio;
    property ReponseVideo: TArray<string> read FReponseVideo write FReponseVideo;
    property DisplayBlocks: TArray<TChatDisplayBlock> read FDisplayBlocks write SetDisplayBlocks;
    property DisplayBlocksJson: string read FDisplayBlocksJson write SetDisplayBlocksJson;

    procedure NormalizeDisplayBlocks;
    destructor Destroy; override;
  end;

  TChatSession = class(TJSONListParams<TChatSession, TChatTurn>)
  private
    FId: string;
    FCreatedAt: Int64;
    FModifiedAt: Int64;
    FTitle: string;
    FRuntime: IPersistentChatRuntime;
    procedure NormalizeTurnIndexes;
  public
    procedure SetRuntime(const Value: IPersistentChatRuntime);
    function AddItem: TChatTurn; override;
    function ApplyTitle(const Value: string): TChatSession;
    function ApplyCreatedAt(const Value: Int64): TChatSession;
    function ApplyModifiedAt(const Value: Int64): TChatSession;
    function Count: Integer;
    function DeleteLastTurn(const Index: Integer; const ParamProc: TProc<string> = nil): TChatSession;
    function DeleteFrom(const Index: Integer; const ParamProc: TProc<string> = nil): TChatSession;
    function SaveCurrentChat: TChatSession;
    procedure TouchModifiedAt;

    property Id: string read FId write FId;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property ModifiedAt: Int64 read FModifiedAt write FModifiedAt;
    property Title: string read FTitle write FTitle;
    destructor Destroy; override;
  end;

  TChatSessionList = class(TJSONListParams<TChatSessionList, TChatSession>)
  private
    FRuntime: IPersistentChatRuntime;
    procedure NormalizeSessions;
    procedure HydrateDisplayBlocksFromJsonFile(const FileName: string);
  public
    function AddItem: TChatSession; override;
    procedure SetRuntime(const Value: IPersistentChatRuntime);
    class function Reload(const FileName: string = ''): TChatSessionList; static;
    class function JsonFileName: string;
    function Delete(const Item: TObject; ParamProc: TProc<string>): TChatSessionList; overload;
    function Rename(const Index: Integer; NewTitle: string): TChatSessionList; overload;
    function Rename(const Item: TObject; NewTitle: string): TChatSessionList; overload;
    destructor Destroy; override;
  end;

  IPersistentChat = interface
    ['{7278ECC9-D702-4EC3-88E6-54B97732B7F5}']
    function GetFLocalFileName: string;
    procedure SetFLocalFileName(const Value: string);
    procedure SetCurrentChat(const Value: TChatSession);
    function GetData: TChatSessionList;
    function GetCurrentChat: TChatSession;
    function GetCurrentPrompt: TChatTurn;

    function ActivateChatById(const Id: string): Boolean;
    function AddChat: TChatSession;
    function AddPrompt: TChatTurn;
    procedure LoadFromFile(FileName: string = '');
    function Count: Integer;
    procedure SaveToFile(FileName: string = '');
    procedure Clear;

    function ForkChatFromIndex(const AId: string;
      const AIndex: Integer): Boolean;

    function GetRecentChatSummaries(
      const PageSize: Integer;
      const AfterId: string): TChatListPage;

    function GetResponseIds: TArray<string>;

    procedure TouchCurrentChatModifiedAt;
    function DeleteChatById(const Id: string; const ParamProc: TProc<string> = nil): Boolean;
    procedure UpdateChatTitleById(const Id: string; const ATitle: string);
    function TryToGetTitleById(const Id: string; out ATitle: string): Boolean;

    property Data: TChatSessionList read GetData;
    property CurrentChat: TChatSession read GetCurrentChat write SetCurrentChat;
    property CurrentPrompt: TChatTurn read GetCurrentPrompt;
    property LocalFileName: string read GetFLocalFileName write SetFLocalFileName;
  end;

  TChatSessionRuntime = class(TInterfacedObject, IPersistentChatRuntime)
  private
    FOwner: TPersistentChat;
  public
    constructor Create(AOwner: TPersistentChat);
    function GetCurrentChat: TChatSession;
    procedure SetCurrentChat(const Value: TChatSession);
    function GetData: TChatSessionList;
  end;

  TPersistentChat = class(TInterfacedObject, IPersistentChat)
  private
    FData: TChatSessionList;
    FCurrentChat: TChatSession;
    FCurrentPrompt: TChatTurn;
    FRuntime: IPersistentChatRuntime;
    FLocalFileName: string;
    procedure AssignTurn(const ASource, ATarget: TChatTurn);
    function ContainsChat(const Value: TChatSession): Boolean;
    function ContainsPrompt(const Chat: TChatSession; const Value: TChatTurn): Boolean;
    procedure NormalizeState;
    procedure SyncCurrentPrompt;
    procedure SetData(const Value: TChatSessionList);
    function GetData: TChatSessionList;
    function GetCurrentChat: TChatSession;
    function GetCurrentPrompt: TChatTurn;
    procedure SetCurrentChat(const Value: TChatSession);
    function BuildRecentChatSortItems: TArray<TChatSortItem>;
    function GetFLocalFileName: string;
    procedure SetFLocalFileName(const Value: string);
  public
    function ActivateChatById(const Id: string): Boolean;
    function AddChat: TChatSession;
    function AddPrompt: TChatTurn;
    procedure LoadFromFile(FileName: string = '');
    procedure SaveToFile(FileName: string = '');
    procedure Clear;
    function Count: Integer;

    function ForkChatFromIndex(const AId: string;
      const AIndex: Integer): Boolean;

    function GetRecentChatSummaries(
      const PageSize: Integer;
      const AfterId: string): TChatListPage;

    function GetResponseIds: TArray<string>;

    procedure TouchCurrentChatModifiedAt;
    function DeleteChatById(const Id: string; const ParamProc: TProc<string> = nil): Boolean;
    procedure UpdateChatTitleById(const Id: string; const ATitle: string);
    function TryToGetTitleById(const Id: string; out ATitle: string): Boolean;

    property Data: TChatSessionList read GetData;
    property CurrentChat: TChatSession read GetCurrentChat write SetCurrentChat;
    property CurrentPrompt: TChatTurn read GetCurrentPrompt;
    property LocalFileName: string read GetFLocalFileName write SetFLocalFileName;
    constructor Create; overload;
    constructor Create(const AData: TChatSessionList); overload;
    destructor Destroy; override;
  end;

  TPersistentChatFactory = class
  public
    class function CreatePersistentChat(const FileName: string = ''): IPersistentChat; static;
  end;

function CloneChatDisplayBlocks(
  const Values: TArray<TChatDisplayBlock>): TArray<TChatDisplayBlock>;

procedure FreeChatDisplayBlocks(var Values: TArray<TChatDisplayBlock>);

function ChatDisplayBlocksToJson(
  const Values: TArray<TChatDisplayBlock>): string;

function ChatDisplayBlocksFromJson(
  const Value: string): TArray<TChatDisplayBlock>;

implementation

uses
  System.DateUtils, System.Generics.Defaults, System.IOUtils, System.JSON,
  WVPythia.Strings.Escape;

procedure FreeChatDisplayItems(var Values: TArray<TChatDisplayItem>);
begin
  for var Item in Values do
    Item.Free;
  Values := nil;
end;

function ChatDisplayItemToJson(const Item: TChatDisplayItem): TJSONObject;
begin
  Result := TJSONObject.Create;

  if not Assigned(Item) then
    Exit;

  if not Item.Title.IsEmpty then
    Result.AddPair('title', Item.Title);

  if not Item.Text.IsEmpty then
    Result.AddPair('text', Item.Text);

  if not Item.Url.IsEmpty then
    Result.AddPair('url', Item.Url);

  if not Item.Path.IsEmpty then
    Result.AddPair('path', Item.Path);

  if not Item.MimeType.IsEmpty then
    Result.AddPair('mimeType', Item.MimeType);
end;

function ChatDisplayBlockToJson(const Block: TChatDisplayBlock): TJSONObject;
begin
  Result := TJSONObject.Create;

  if not Assigned(Block) then
    Exit;

  if not Block.Kind.IsEmpty then
    Result.AddPair('kind', Block.Kind);

  if not Block.Title.IsEmpty then
    Result.AddPair('title', Block.Title);

  if not Block.Text.IsEmpty then
    Result.AddPair('text', Block.Text);

  if not Block.Url.IsEmpty then
    Result.AddPair('url', Block.Url);

  if Length(Block.Items) > 0 then
    begin
      var Items := TJSONArray.Create;
      for var Item in Block.Items do
        Items.AddElement(ChatDisplayItemToJson(Item));
      Result.AddPair('items', Items);
    end;
end;

function CloneChatDisplayBlocks(
  const Values: TArray<TChatDisplayBlock>): TArray<TChatDisplayBlock>;
begin
  SetLength(Result, Length(Values));
  for var I := Low(Values) to High(Values) do
    if Assigned(Values[I]) then
      Result[I] := Values[I].Clone;
end;

procedure FreeChatDisplayBlocks(var Values: TArray<TChatDisplayBlock>);
begin
  for var Item in Values do
    Item.Free;
  Values := nil;
end;

function ChatDisplayBlocksToJson(
  const Values: TArray<TChatDisplayBlock>): string;
begin
  var Blocks := TJSONArray.Create;
  try
    for var Item in Values do
      Blocks.AddElement(ChatDisplayBlockToJson(Item));
    Result := Blocks.ToJSON;
  finally
    Blocks.Free;
  end;
end;

function JsonObjectValue(
  const Obj: TJSONObject;
  const Name, AlternateName: string): TJSONValue;
begin
  Result := nil;

  if not Assigned(Obj) then
    Exit;

  Result := Obj.GetValue(Name);
  if (not Assigned(Result)) and (not AlternateName.Trim.IsEmpty) then
    Result := Obj.GetValue(AlternateName);
end;

function JsonObjectString(
  const Obj: TJSONObject;
  const Name, AlternateName: string): string;
begin
  Result := EmptyStr;

  var Value := JsonObjectValue(Obj, Name, AlternateName);
  if not Assigned(Value) then
    Exit;

  if Value is TJSONString then
    Result := TJSONString(Value).Value
  else
    Result := Value.Value;
end;

function JsonObjectArray(
  const Obj: TJSONObject;
  const Name, AlternateName: string): TJSONArray;
begin
  Result := nil;

  var Value := JsonObjectValue(Obj, Name, AlternateName);
  if Value is TJSONArray then
    Result := TJSONArray(Value);
end;

function ChatDisplayItemFromJson(const Value: TJSONValue): TChatDisplayItem;
begin
  Result := nil;

  if not (Value is TJSONObject) then
    Exit;

  var Obj := TJSONObject(Value);

  Result := TChatDisplayItem.Create;
  Result.Title := JsonObjectString(Obj, 'title', 'Title');
  Result.Text := JsonObjectString(Obj, 'text', 'Text');
  Result.Url := JsonObjectString(Obj, 'url', 'Url');
  Result.Path := JsonObjectString(Obj, 'path', 'Path');
  Result.MimeType := JsonObjectString(Obj, 'mimeType', 'MimeType');
end;

function ChatDisplayBlockFromJson(const Value: TJSONValue): TChatDisplayBlock;
begin
  Result := nil;

  if not (Value is TJSONObject) then
    Exit;

  var Obj := TJSONObject(Value);

  Result := TChatDisplayBlock.Create;
  Result.Kind := JsonObjectString(Obj, 'kind', 'Kind');
  Result.Title := JsonObjectString(Obj, 'title', 'Title');
  Result.Text := JsonObjectString(Obj, 'text', 'Text');
  Result.Url := JsonObjectString(Obj, 'url', 'Url');

  var ItemsJson := JsonObjectArray(Obj, 'items', 'Items');
  if not Assigned(ItemsJson) then
    Exit;

  var Items: TArray<TChatDisplayItem>;
  SetLength(Items, ItemsJson.Count);

  var Count := 0;
  for var I := 0 to ItemsJson.Count - 1 do
    begin
      var Item := ChatDisplayItemFromJson(ItemsJson.Items[I]);
      if not Assigned(Item) then
        Continue;

      Items[Count] := Item;
      Inc(Count);
    end;

  if Count <> Length(Items) then
    SetLength(Items, Count);

  Result.Items := Items;
end;

function ChatDisplayBlocksFromJson(
  const Value: string): TArray<TChatDisplayBlock>;
begin
  Result := nil;

  if Value.Trim.IsEmpty then
    Exit;

  var Root: TJSONValue := nil;
  try
    Root := TJSONObject.ParseJSONValue(Value);
    if Assigned(Root) then
      begin
        var BlocksJson: TJSONArray := nil;
        if Root is TJSONArray then
          BlocksJson := TJSONArray(Root)
        else
        if Root is TJSONObject then
          begin
            BlocksJson := JsonObjectArray(TJSONObject(Root), 'displayBlocks', 'DisplayBlocks');
            if not Assigned(BlocksJson) then
              BlocksJson := JsonObjectArray(TJSONObject(Root), 'blocks', 'Blocks');
          end;

        if Assigned(BlocksJson) then
          begin
            SetLength(Result, BlocksJson.Count);

            var Count := 0;
            for var I := 0 to BlocksJson.Count - 1 do
              begin
                var Block := ChatDisplayBlockFromJson(BlocksJson.Items[I]);
                if not Assigned(Block) then
                  Continue;

                Result[Count] := Block;
                Inc(Count);
              end;

            if Count <> Length(Result) then
              SetLength(Result, Count);
          end;
      end;
  except
    FreeChatDisplayBlocks(Result);
  end;

  Root.Free;
end;

function ResolveChatSessionListFileName(const FileName: string): string;
begin
  Result := FileName;
  if Result.Trim.IsEmpty then
    Result := TChatSessionList.DefaultFileName;
  Result := TPath.GetFullPath(Result);
end;

{ TChatDisplayItem }

function TChatDisplayItem.Clone: TChatDisplayItem;
begin
  Result := TChatDisplayItem.Create;
  Result.Title := Title;
  Result.Text := Text;
  Result.Url := Url;
  Result.Path := Path;
  Result.MimeType := MimeType;
end;

{ TChatDisplayBlock }

function TChatDisplayBlock.Clone: TChatDisplayBlock;
begin
  Result := TChatDisplayBlock.Create;
  Result.Kind := Kind;
  Result.Title := Title;
  Result.Text := Text;
  Result.Url := Url;

  SetLength(Result.FItems, Length(FItems));
  for var I := Low(FItems) to High(FItems) do
    if Assigned(FItems[I]) then
      Result.FItems[I] := FItems[I].Clone;
end;

destructor TChatDisplayBlock.Destroy;
begin
  FreeChatDisplayItems(FItems);
  inherited;
end;

procedure TChatDisplayBlock.SetItems(const Value: TArray<TChatDisplayItem>);
begin
  FreeChatDisplayItems(FItems);
  FItems := Value;
end;

{ TChatTurn }

destructor TChatTurn.Destroy;
begin
  FreeChatDisplayBlocks(FDisplayBlocks);
  inherited;
end;

procedure TChatTurn.SetDisplayBlocks(const Value: TArray<TChatDisplayBlock>);
begin
  FreeChatDisplayBlocks(FDisplayBlocks);
  FDisplayBlocks := Value;
  FDisplayBlocksJson := ChatDisplayBlocksToJson(FDisplayBlocks);
end;

procedure TChatTurn.SetDisplayBlocksJson(const Value: string);
begin
  FDisplayBlocksJson := Value;

  if FDisplayBlocksJson.Trim.IsEmpty then
    Exit;

  NormalizeDisplayBlocks;
end;

procedure TChatTurn.NormalizeDisplayBlocks;
begin
  if FDisplayBlocksJson.Trim.IsEmpty then
    begin
      if Length(FDisplayBlocks) > 0 then
        FDisplayBlocksJson := ChatDisplayBlocksToJson(FDisplayBlocks);
      Exit;
    end;

  var Parsed := ChatDisplayBlocksFromJson(FDisplayBlocksJson);
  if (Length(Parsed) = 0) and (FDisplayBlocksJson.Trim <> '[]') then
    begin
      FreeChatDisplayBlocks(Parsed);
      Exit;
    end;

  FreeChatDisplayBlocks(FDisplayBlocks);
  FDisplayBlocks := Parsed;
end;

{ TChatSessionRuntime }

constructor TChatSessionRuntime.Create(AOwner: TPersistentChat);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TChatSessionRuntime.GetCurrentChat: TChatSession;
begin
  Result := FOwner.CurrentChat;
end;

procedure TChatSessionRuntime.SetCurrentChat(const Value: TChatSession);
begin
  FOwner.CurrentChat := Value;
end;

function TChatSessionRuntime.GetData: TChatSessionList;
begin
  Result := FOwner.Data;
end;

{ TPersistentChat }

constructor TPersistentChat.Create;
begin
  inherited Create;
  FRuntime := TChatSessionRuntime.Create(Self);
  SetData(TChatSessionList.Reload);
end;

constructor TPersistentChat.Create(const AData: TChatSessionList);
begin
  inherited Create;
  FRuntime := TChatSessionRuntime.Create(Self);
  SetData(AData);
end;

function TPersistentChat.DeleteChatById(const Id: string;
  const ParamProc: TProc<string>): Boolean;
begin
  if not Assigned(FData) or Id.IsEmpty then
    Exit(False);

  for var Session in FData.Data do
    if Assigned(Session) and SameText(Session.Id, Id) then
      begin
        if FCurrentChat = Session then
          begin
            FCurrentChat := nil;
            FCurrentPrompt := nil;
          end;

        FData.Delete(Session, ParamProc);
        NormalizeState;
        Exit(True);
      end;

  Result := False;
end;

destructor TPersistentChat.Destroy;
begin
  if Assigned(FData) then
    FData.SetRuntime(nil);

  FreeAndNil(FData);

  FCurrentPrompt := nil;
  FCurrentChat := nil;
  FRuntime := nil;
  inherited;
end;

function TPersistentChat.ForkChatFromIndex(const AId: string;
  const AIndex: Integer): Boolean;
begin
  Result := False;

  if not Assigned(FData) or AId.IsEmpty or (AIndex < 0) then
    Exit;

  var TempSessionIndex := -1;

  for var I := 0 to High(FData.Data) do
    if Assigned(FData.Data[I]) and SameText(FData.Data[I].Id, AId) then
      begin
        TempSessionIndex := I;
        Break;
      end;

  if TempSessionIndex < 0 then
    Exit;

  AddChat;
  if not Assigned(FCurrentChat) then
    Exit;

  FCurrentChat.Title := FData.Data[TempSessionIndex].Title;

  for var I := 0 to High(FData.Data[TempSessionIndex].Data) do
    if Assigned(FData.Data[TempSessionIndex].Data[I]) and
       (FData.Data[TempSessionIndex].Data[I].Index <= AIndex) then
      begin
        var NewTurn := FCurrentChat.AddItem;
        AssignTurn(FData.Data[TempSessionIndex].Data[I], NewTurn);
      end;

  FCurrentChat.Title := 'Fork> ' + FCurrentChat.Title;
  FCurrentChat.TouchModifiedAt;
  SyncCurrentPrompt;
  Result := True;
end;

function TPersistentChat.ContainsChat(const Value: TChatSession): Boolean;
begin
  Result := False;
  if not Assigned(Value) or not Assigned(FData) then
    Exit;

  for var Chat in FData.Data do
    if Chat = Value then
      Exit(True);
end;

function TPersistentChat.ContainsPrompt(const Chat: TChatSession; const Value: TChatTurn): Boolean;
begin
  Result := False;
  if not Assigned(Chat) or not Assigned(Value) then
    Exit;

  for var Turn in Chat.Data do
    if Turn = Value then
      Exit(True);
end;

procedure TPersistentChat.NormalizeState;
begin
  if not ContainsChat(FCurrentChat) then
    FCurrentChat := nil;

  if Assigned(FCurrentChat) then
    begin
      if not ContainsPrompt(FCurrentChat, FCurrentPrompt) then
        SyncCurrentPrompt;
    end
  else
    FCurrentPrompt := nil;
end;

procedure TPersistentChat.SetData(const Value: TChatSessionList);
begin
  if FData = Value then
    Exit;

  if Assigned(FData) then
    begin
      FData.SetRuntime(nil);
      FreeAndNil(FData);
    end;

  FData := Value;
  if not Assigned(FData) then
    FData := TChatSessionList.Create;

  FData.NormalizeSessions;
  FData.SetRuntime(FRuntime);
  NormalizeState;
end;

procedure TPersistentChat.SetFLocalFileName(const Value: string);
begin
  FLocalFileName := Value;
end;

function TPersistentChat.ActivateChatById(const Id: string): Boolean;
begin
  Result := False;

  if not Assigned(FData) or Id.IsEmpty then
    begin
      SetCurrentChat(nil);
      Exit;
    end;

  for var Session in FData.Data do
    if Assigned(Session) and SameText(Session.Id, Id) then
      begin
        SetCurrentChat(Session);
        Exit(True);
      end;

  SetCurrentChat(nil);
end;

function TPersistentChat.AddChat: TChatSession;
begin
  Result := GetData.AddItem;
  FCurrentChat := Result;
  SyncCurrentPrompt;
end;

function TPersistentChat.AddPrompt: TChatTurn;
begin
  NormalizeState;
  if not Assigned(FCurrentChat) then
    FCurrentChat := GetData.AddItem;

  Result := FCurrentChat.AddItem;
  FCurrentPrompt := Result;
end;

procedure TPersistentChat.AssignTurn(const ASource, ATarget: TChatTurn);
begin
  ATarget.Index := ASource.Index;
  ATarget.Storage := False;

  ATarget.Prompt := ASource.Prompt;
  ATarget.JsonPromptState := ASource.JsonPromptState;
  ATarget.PromptFiles := System.Copy(ASource.PromptFiles);
  ATarget.PromptKnowledgeSearch := System.Copy(ASource.PromptKnowledgeSearch);
  ATarget.PromptImages := System.Copy(ASource.PromptImages);
  ATarget.JsonPrompt := ASource.JsonPrompt;

  ATarget.Response := ASource.Response;
  ATarget.Reasoning := ASource.Reasoning;
  ATarget.JsonResponse := ASource.JsonResponse;
  ATarget.ReponseFiles := System.Copy(ASource.ReponseFiles);
  ATarget.ReponseImages := System.Copy(ASource.ReponseImages);
  ATarget.ReponseAudio := System.Copy(ASource.ReponseAudio);
  ATarget.ReponseVideo := System.Copy(ASource.ReponseVideo);
  ATarget.DisplayBlocks := CloneChatDisplayBlocks(ASource.DisplayBlocks);
end;

function TPersistentChat.BuildRecentChatSortItems: TArray<TChatSortItem>;
begin
  Result := [];
  if not Assigned(FData) then
    Exit;

  SetLength(Result, Length(FData.Data));

  var Count := 0;
  for var I := 0 to High(FData.Data) do
    begin
      var Session := FData.Data[I];
      if not Assigned(Session) then
        Continue;

      Result[Count].Id := Session.Id;
      Result[Count].Title := Session.Title;
      Result[Count].Index := I;
      Result[Count].ModifiedAt := Session.ModifiedAt;
      Inc(Count);
    end;

  if Count <> Length(Result) then
    SetLength(Result, Count);

  TArray.Sort<TChatSortItem>(Result,
    TComparer<TChatSortItem>.Construct(
      function(const Left, Right: TChatSortItem): Integer
      begin
        if Left.ModifiedAt > Right.ModifiedAt then
          Exit(-1);

        if Left.ModifiedAt < Right.ModifiedAt then
          Exit(1);

        if Left.Index > Right.Index then
          Exit(-1);

        if Left.Index < Right.Index then
          Exit(1);

        Result := 0;
      end
    ));
end;

procedure TPersistentChat.Clear;
begin
  FCurrentChat := nil;
  FCurrentPrompt := nil;
end;

function TPersistentChat.Count: Integer;
begin
  if not Assigned(FData) then
    Exit(0);

  Result := Length(FData.Data);
end;

function TPersistentChat.GetCurrentChat: TChatSession;
begin
  NormalizeState;
  Result := FCurrentChat;
end;

function TPersistentChat.GetCurrentPrompt: TChatTurn;
begin
  NormalizeState;
  Result := FCurrentPrompt;
end;

function TPersistentChat.GetData: TChatSessionList;
begin
  if not Assigned(FData) then
    SetData(nil);
  Result := FData;
end;

function TPersistentChat.GetFLocalFileName: string;
begin
  Result := FLocalFileName;
end;

function TPersistentChat.GetRecentChatSummaries(const PageSize: Integer;
  const AfterId: string): TChatListPage;
begin
  Result := Default(TChatListPage);

  if PageSize <= 0 then
    Exit;

  var SortedItems := BuildRecentChatSortItems;
  var Last := High(SortedItems);
  if Last < 0 then
    Exit;

  var StartPos := 0;

  if not AfterId.IsEmpty then
    begin
      var Found := False;

      for var I := 0 to Last do
        begin
          var IsTargetItem := SameText(SortedItems[I].Id, AfterId);
          if not IsTargetItem then
            Continue;

          StartPos := I + 1;
          Found := True;
          Break;
        end;

      if not Found then
        Exit;
    end;

  var CountToTake := PageSize;
  var Remaining := (Last + 1) - StartPos;

  if CountToTake > Remaining then
    CountToTake := Remaining;

  if CountToTake <= 0 then
    Exit;

  SetLength(Result.Items, CountToTake);

  for var I := 0 to CountToTake - 1 do
    begin
      var Item := SortedItems[StartPos + I];
      Result.Items[I].Id := Item.Id;
      Result.Items[I].Title := Item.Title;
      Result.Items[I].Index := Item.Index;
    end;

  Result.FirstId := Result.Items[0].Id;
  Result.LastId := Result.Items[CountToTake - 1].Id;
  Result.HasMore := (StartPos + CountToTake) < (Last + 1);
end;

function TPersistentChat.GetResponseIds: TArray<string>;
begin
  SetLength(Result, 0);
  if not Assigned(FData) then
    Exit;

  for var Session in FData.Data do
    if Assigned(Session) then
      for var Turn in Session.Data do
        if Assigned(Turn) then
          Result := Result + [Turn.Id];
end;

procedure TPersistentChat.LoadFromFile(FileName: string);
var
  CurrentFileName: string;
begin
  if FileName.Trim.IsEmpty then
    CurrentFileName := LocalFileName
  else
    CurrentFileName := FileName;

  SetData(TChatSessionList.Reload(CurrentFileName));
  Clear;
end;

procedure TPersistentChat.SaveToFile(FileName: string);
var
  CurrentFileName: string;
begin
  if FileName.Trim.IsEmpty then
    CurrentFileName := LocalFileName
  else
    CurrentFileName := FileName;

  GetData.Save(CurrentFileName);
end;

procedure TPersistentChat.SetCurrentChat(const Value: TChatSession);
begin
  if ContainsChat(Value) then
    FCurrentChat := Value
  else
    FCurrentChat := nil;
  SyncCurrentPrompt;
end;

procedure TPersistentChat.SyncCurrentPrompt;
begin
  FCurrentPrompt := nil;

  if not Assigned(FCurrentChat) then
    Exit;

  for var I := High(FCurrentChat.Data) downto 0 do
    if Assigned(FCurrentChat.Data[I]) then
      begin
        FCurrentPrompt := FCurrentChat.Data[I];
        Break;
      end;
end;

procedure TPersistentChat.TouchCurrentChatModifiedAt;
begin
  NormalizeState;

  if Assigned(FCurrentChat) then
    FCurrentChat.TouchModifiedAt;
end;

function TPersistentChat.TryToGetTitleById(const Id: string;
  out ATitle: string): Boolean;
begin
  if not Assigned(FData) or Id.IsEmpty then
    Exit(False);

  for var Session in FData.Data do
    if Assigned(Session) and SameText(Session.Id, Id) then
      begin
        ATitle := Session.Title;
        Exit(True);
      end;

  Result := False;
end;

procedure TPersistentChat.UpdateChatTitleById(const Id,
  ATitle: string);
begin
   if not Assigned(FData) or Id.IsEmpty then
    Exit;

  for var Session in FData.Data do
    if Assigned(Session) and SameText(Session.Id, Id) then
      begin
        Session.Title := ATitle;
        Session.TouchModifiedAt;

        Exit;
      end;
end;

{ TChatSession }

function TChatSession.AddItem: TChatTurn;
begin
  Result := inherited AddItem;
  Result.Id := TGUIDBuilder.Create();
end;

function TChatSession.ApplyCreatedAt(const Value: Int64): TChatSession;
begin
  CreatedAt := Value;
  Result := Self;
end;

function TChatSession.ApplyModifiedAt(const Value: Int64): TChatSession;
begin
  ModifiedAt := Value;
  Result := Self;
end;

function TChatSession.ApplyTitle(const Value: string): TChatSession;
begin
  Title := Value;
  Result := Self;
end;

function TChatSession.Count: Integer;
begin
  Result := Length(Data);
end;

destructor TChatSession.Destroy;
begin
  FRuntime := nil;
  inherited;
end;

procedure TChatSession.NormalizeTurnIndexes;
begin
  for var I := 0 to High(Data) do
    if Assigned(Data[I]) then
      Data[I].Index := I;
end;

procedure TChatSession.SetRuntime(const Value: IPersistentChatRuntime);
begin
  FRuntime := Value;
end;

procedure TChatSession.TouchModifiedAt;
begin
  FModifiedAt := TUnixDateTime.Now;
end;

function TChatSession.DeleteFrom(const Index: Integer; const ParamProc: TProc<string>): TChatSession;
begin
  if Index < 0 then
    Exit(Self);

  EnsureIndex(Index);

  var List := TList<TChatTurn>.Create(Data);
  var Removed := TList<TChatTurn>.Create;
  try
    for var I := List.Count - 1 downto Index do
      begin
        Removed.Add(List[I]);
        List.Delete(I);
      end;

    Data := List.ToArray;
    NormalizeTurnIndexes;

    for var Turn in Removed do
      try
        if Assigned(ParamProc) and Turn.Storage then
          ParamProc(Turn.Id);
      finally
        Turn.Free;
      end;
  finally
    Removed.Free;
    List.Free;
  end;

  if Length(Data) = 0 then
    begin
      if Assigned(FRuntime) then
        begin
          if FRuntime.CurrentChat = Self then
            FRuntime.CurrentChat := nil;
          if Assigned(FRuntime.Data) then
            FRuntime.Data.Delete(Self, ParamProc);
        end;
      Exit(nil);
    end;

  if Assigned(FRuntime) and (FRuntime.CurrentChat = Self) then
    FRuntime.CurrentChat := Self;

  Result := Self;
end;

function TChatSession.DeleteLastTurn(const Index: Integer; const ParamProc: TProc<string>): TChatSession;
begin
  if Index < 0 then
    Exit(Self);

  EnsureIndex(Index);
  if Index <> High(Data) then
    Exit(Self);

  Result := DeleteFrom(Index, ParamProc);
end;

function TChatSession.SaveCurrentChat: TChatSession;
begin
  if Assigned(FRuntime) and Assigned(FRuntime.CurrentChat) then
    FRuntime.CurrentChat.Save;
  Result := Self;
end;

{ TChatSessionList }

function TChatSessionList.AddItem: TChatSession;
begin
  Result := inherited AddItem;
  if Assigned(Result) then
    begin
      var UTCTime := TUnixDateTime.Now;
      Result.SetRuntime(FRuntime);
      Result.Id := TGUIDBuilder.Create();
      Result.CreatedAt := UTCTime;
      Result.ModifiedAt := UTCTime;
      Result.Title := 'New Chat';
    end;
end;

function TChatSessionList.Delete(const Item: TObject; ParamProc: TProc<string>): TChatSessionList;
begin
  ItemCheck(Item);
  var Buffer := TChatSession(Item);

  for var Value in Buffer.Data do
    if Assigned(Value) and Value.Storage and Assigned(ParamProc) then
      ParamProc(Value.Id);

  if Assigned(FRuntime) and (FRuntime.CurrentChat = Buffer) then
    FRuntime.CurrentChat := nil;

  Result := inherited Delete(Buffer);
end;

destructor TChatSessionList.Destroy;
begin
  SetRuntime(nil);
  inherited;
end;

procedure TChatSessionList.NormalizeSessions;
begin
  for var Session in Data do
    if Assigned(Session) then
      for var Turn in Session.Data do
        if Assigned(Turn) then
          Turn.NormalizeDisplayBlocks;
end;

procedure TChatSessionList.HydrateDisplayBlocksFromJsonFile(const FileName: string);
begin
  if FileName.Trim.IsEmpty or (not TFile.Exists(FileName)) then
    Exit;

  var Raw := TFile.ReadAllText(FileName, TEncoding.UTF8);
  if Raw.Trim.IsEmpty then
    Exit;

  var RootValue: TJSONValue := nil;
  try
    RootValue := TJSONObject.ParseJSONValue(Raw);
    if not (RootValue is TJSONObject) then
      Exit;

    var SessionsJson := JsonObjectArray(TJSONObject(RootValue), 'data', 'Data');
    if not Assigned(SessionsJson) then
      Exit;

    var SessionCount := Length(Data);
    if SessionsJson.Count < SessionCount then
      SessionCount := SessionsJson.Count;

    for var SessionIndex := 0 to SessionCount - 1 do
      begin
        if not Assigned(Data[SessionIndex]) or
           (not (SessionsJson.Items[SessionIndex] is TJSONObject)) then
          Continue;

        var TurnsJson := JsonObjectArray(
          TJSONObject(SessionsJson.Items[SessionIndex]), 'data', 'Data');

        if not Assigned(TurnsJson) then
          Continue;

        var TurnCount := Length(Data[SessionIndex].Data);
        if TurnsJson.Count < TurnCount then
          TurnCount := TurnsJson.Count;

        for var TurnIndex := 0 to TurnCount - 1 do
          begin
            var Turn := Data[SessionIndex].Data[TurnIndex];
            if not Assigned(Turn) or
               (not (TurnsJson.Items[TurnIndex] is TJSONObject)) then
              Continue;

            var TurnJson := TJSONObject(TurnsJson.Items[TurnIndex]);
            var BlocksJsonText := JsonObjectString(
              TurnJson, 'displayBlocksJson', 'DisplayBlocksJson');

            if BlocksJsonText.Trim.IsEmpty then
              begin
                var BlocksJson := JsonObjectArray(
                  TurnJson, 'displayBlocks', 'DisplayBlocks');
                if Assigned(BlocksJson) then
                  BlocksJsonText := BlocksJson.ToJSON;
              end;

            if not BlocksJsonText.Trim.IsEmpty then
              Turn.DisplayBlocksJson := BlocksJsonText;
          end;
      end;
  finally
    RootValue.Free;
  end;
end;

class function TChatSessionList.Reload(const FileName: string): TChatSessionList;
begin
  var EffectiveFileName := ResolveChatSessionListFileName(FileName);

  if not FileName.Trim.IsEmpty then
    Result := TChatSessionList.Load(FileName) as TChatSessionList
  else
    Result := TChatSessionList.Load as TChatSessionList;

  if not Assigned(Result) then
    Result := TChatSessionList.Create;

  Result.HydrateDisplayBlocksFromJsonFile(EffectiveFileName);
  Result.NormalizeSessions;
end;

function TChatSessionList.Rename(const Item: TObject; NewTitle: string): TChatSessionList;
begin
  Result := Rename(ItemCheck(Item).IndexOf(Item), NewTitle);
end;

function TChatSessionList.Rename(const Index: Integer; NewTitle: string): TChatSessionList;
begin
  if Index > -1 then
    begin
      EnsureIndex(Index);
      var Session := Data[Index];
      Session.Title := NewTitle;
    end;
  Result := Self;
end;

procedure TChatSessionList.SetRuntime(const Value: IPersistentChatRuntime);
begin
  FRuntime := Value;

  for var Session in Data do
    if Assigned(Session) then
      Session.SetRuntime(Value);
end;

class function TChatSessionList.JsonFileName: string;
begin
  Result := DefaultFileName;
end;

{ TPersistentChatFactory }

class function TPersistentChatFactory.CreatePersistentChat(const FileName: string): IPersistentChat;
begin
  if not FileName.Trim.IsEmpty then
    begin
      Result := TPersistentChat.Create(TChatSessionList.Reload(FileName))
    end
  else
    Result := TPersistentChat.Create;
end;

{ TGUIDBuilder }

class function TGUIDBuilder.Create(const Brace: Boolean): string;
begin
  Result := TGUID.NewGuid.ToString;
  if not Brace then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

{ TUnixDateTime }

class function TUnixDateTime.Now: Int64;
begin
  Result := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(System.SysUtils.Now));
end;

{ TChatListPageHelper }


function TChatListPageHelper.ItemsToJsonString: string;
const
  Pattern = '{"Id":%s,"Title":%s,"Index":%d}';
begin
  var Start := True;
  for var Item in Items do
    begin
      var S := Format(Pattern, [
        TEscapeHelper.EscapeJSString(Item.Id),
        TEscapeHelper.EscapeJSString(Item.Title),
        Item.Index
      ]);

      if Start then
        begin
          Start := False;
          Result := S;
        end
      else
        begin
          Result := Result + ',' + S;
        end;
    end;
end;

function TChatListPageHelper.ToJsonString(const FirstPage: Boolean): string;
const
  Pattern =
    '{' +
      '"type":%s,' +
        '"page":{' +
          '"Items":[%s],' +
          '"FirstId":%s,' +
          '"LastId":%s,' +
          '"HasMore":%s' +
        '}' +
    '}';
var
  CommandType: string;
begin
  if FirstPage then
    CommandType := 'files-drawer-set-items'
  else
    CommandType := 'files-drawer-complete-items';

  Result := Format(Pattern, [
    TEscapeHelper.EscapeJSString(CommandType),
    ItemsToJsonString,
    TEscapeHelper.EscapeJSString(FirstId),
    TEscapeHelper.EscapeJSString(LastId),
    BoolToStr(HasMore, True).ToLower
  ]);
end;

end.
