unit GenAI.Threads;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Assistants;

type
  TThreadsImageFileParams = class(TJSONparam)
  public
    function FileId(const Value: string): TThreadsImageFileParams;
    function Detail(const Value: TImageDetail): TThreadsImageFileParams;
  end;

  TThreadsImageUrlParams = class(TJSONparam)
  public
    function Url(const Value: string): TThreadsImageUrlParams;
    function Detail(const Value: TImageDetail): TThreadsImageUrlParams;
  end;

  TThreadsContentParams = class(TJSONparam)
  public
    function &Type(const Value: string): TThreadsContentParams; overload;
    function &Type(const Value: TThreadsContentType): TThreadsContentParams; overload;
    function ImageFile(const Value: TThreadsImageFileParams): TThreadsContentParams;
    function ImageUrl(const Value: TThreadsImageUrlParams): TThreadsContentParams;
    function Text(const Value: string): TThreadsContentParams;
  end;

  TThreadsAttachment = class(TJSONparam)
    function FileId(const Value: string): TThreadsAttachment;
    function Tool(const Value: TAssistantsToolsType): TThreadsAttachment; overload;
    function Tool(const Value: string): TThreadsAttachment; overload;
  end;

  TThreadsMessageParams = class(TJSONparam)
  public
    function Role(const Value: string): TThreadsMessageParams; overload;
    function Role(const Value: TRole): TThreadsMessageParams; overload;
    function Content(const Value: string): TThreadsMessageParams; overload;
    function Content(const Value: TArray<TThreadsContentParams>): TThreadsMessageParams; overload;
    function Attachments(const Value: TArray<TThreadsAttachment>): TThreadsMessageParams;
    function Metadata(const Value: TJSONObject): TThreadsMessageParams;
  end;

  TThreadsCreateParams = class(TJSONparam)
  public
    function Messages(const Value: string): TThreadsCreateParams; overload;
    function Messages(const Value: TArray<TThreadsMessageParams>): TThreadsCreateParams; overload;
    function ToolResources(const Value: TToolResourcesParams): TAssistantsParams;
    function Metadata(const Value: TJSONObject): TThreadsCreateParams;
  end;

  TThreadsModifyParams = class(TJSONparam)
  public
    function ToolResources(const Value: TToolResourcesParams): TThreadsModifyParams;
    function Metadata(const Value: TJSONObject): TThreadsModifyParams;
  end;

  TThreads = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
    [JsonNameAttribute('tool_resources')]
    FToolResources: TToolResources;
    FMetadata: string;
  public
    property Id: string read FId write FId;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property &Object: string read FObject write FObject;
    property ToolResources: TToolResources read FToolResources write FToolResources;
    property Metadata: string read FMetadata write FMetadata;
    destructor Destroy; override;
  end;

  TThreadDeletion = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    FDeleted: Boolean;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TThreads</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynThreads</c> type extends the <c>TAsynParams&lt;TThreads&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynThreads = TAsynCallBack<TThreads>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TThreadDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynThreadDeletion</c> type extends the <c>TAsynParams&lt;TThreadDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynThreadDeletion = TAsynCallBack<TThreadDeletion>;

  TThreadsRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    procedure AsynCreate(const ParamProc: TProc<TThreadsCreateParams>; const CallBacks: TFunc<TAsynThreads>); overload;
    procedure AsynCreate(const CallBacks: TFunc<TAsynThreads>); overload;
    procedure AsynRetrieve(const ThreadId: string; const CallBacks: TFunc<TAsynThreads>);
    procedure AsynModify(const ThreadId: string; const ParamProc: TProc<TThreadsModifyParams>;
      const CallBacks: TFunc<TAsynThreads>);
    procedure AsynDelete(const ThreadId: string; const CallBacks: TFunc<TAsynThreadDeletion>);
    function Create(const ParamProc: TProc<TThreadsCreateParams> = nil): TThreads;
    function Retrieve(const ThreadId: string): TThreads;
    function Modify(const ThreadId: string; const ParamProc: TProc<TThreadsModifyParams>): TThreads;
    function Delete(const ThreadId: string): TThreadDeletion;
  end;

implementation

{ TThreadsMessageParams }

function TThreadsMessageParams.Attachments(
  const Value: TArray<TThreadsAttachment>): TThreadsMessageParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
    Result := TThreadsMessageParams(Add('attachments', JSONArray));
end;

function TThreadsMessageParams.Content(
  const Value: TArray<TThreadsContentParams>): TThreadsMessageParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TThreadsMessageParams(Add('content', JSONArray));
end;

function TThreadsMessageParams.Content(
  const Value: string): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('content', Value));
end;

function TThreadsMessageParams.Metadata(
  const Value: TJSONObject): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('metadata', Value));
end;

function TThreadsMessageParams.Role(
  const Value: string): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('role', TRole.Create(Value).ToString));
end;

function TThreadsMessageParams.Role(
  const Value: TRole): TThreadsMessageParams;
begin
  Result := TThreadsMessageParams(Add('role', Value.ToString));
end;

{ TThreadsContentParams }

function TThreadsContentParams.ImageFile(
  const Value: TThreadsImageFileParams): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('image_file', Value.Detach));
end;

function TThreadsContentParams.ImageUrl(
  const Value: TThreadsImageUrlParams): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('image_url', Value.Detach));
end;

function TThreadsContentParams.&Type(
  const Value: string): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('type', TThreadsContentType.Create(Value).ToString));
end;

function TThreadsContentParams.Text(const Value: string): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('text', Value));
end;

function TThreadsContentParams.&Type(
  const Value: TThreadsContentType): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('type', Value.ToString));
end;

{ TThreadsImageFileParams }

function TThreadsImageFileParams.Detail(
  const Value: TImageDetail): TThreadsImageFileParams;
begin
  Result := TThreadsImageFileParams(Add('detail', Value.ToString));
end;

function TThreadsImageFileParams.FileId(
  const Value: string): TThreadsImageFileParams;
begin
  Result := TThreadsImageFileParams(Add('file_id', Value));
end;

{ TThreadsImageUrlParams }

function TThreadsImageUrlParams.Detail(
  const Value: TImageDetail): TThreadsImageUrlParams;
begin
  Result := TThreadsImageUrlParams(Add('detail', Value.ToString));
end;

function TThreadsImageUrlParams.Url(
  const Value: string): TThreadsImageUrlParams;
begin
  Result := TThreadsImageUrlParams(Add('url', Value));
end;

{ TThreadsAttachment }

function TThreadsAttachment.FileId(const Value: string): TThreadsAttachment;
begin
  Result := TThreadsAttachment(Add('file_id', Value));
end;

function TThreadsAttachment.Tool(
  const Value: TAssistantsToolsType): TThreadsAttachment;
begin
  case Value of
    TAssistantsToolsType.code_interpreter,
    TAssistantsToolsType.file_search:
      Result := TThreadsAttachment(Add('tools', TJSONObject.Create.AddPair('type', Value.ToString)));
    else
      raise Exception.CreateFmt('%s: Threads attachments tools type value not managed', [Value.ToString]);
  end;
end;

function TThreadsAttachment.Tool(const Value: string): TThreadsAttachment;
begin
  Result := Tool(TAssistantsToolsType.Create(Value));
end;

{ TThreadsCreateParams }

function TThreadsCreateParams.Messages(
  const Value: string): TThreadsCreateParams;
begin
  var Msg := TThreadsMessageParams.Create.Role('user').Content([TThreadsContentParams.Create.&Type('text').Text(Value)]);
  Result := TThreadsCreateParams(Add('messages', Msg.Detach));
end;

function TThreadsCreateParams.Messages(
  const Value: TArray<TThreadsMessageParams>): TThreadsCreateParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TThreadsCreateParams(Add('messages', JSONArray));
end;

function TThreadsCreateParams.Metadata(
  const Value: TJSONObject): TThreadsCreateParams;
begin
  Result := TThreadsCreateParams(Add('metadata', Value));
end;

function TThreadsCreateParams.ToolResources(
  const Value: TToolResourcesParams): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('tool_resources', Value.Detach));
end;

{ TThreadsRoute }

procedure TThreadsRoute.AsynCreate(const ParamProc: TProc<TThreadsCreateParams>;
  const CallBacks: TFunc<TAsynThreads>);
begin
  with TAsynCallBackExec<TAsynThreads, TThreads>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TThreads
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TThreadsRoute.AsynCreate(const CallBacks: TFunc<TAsynThreads>);
begin
  with TAsynCallBackExec<TAsynThreads, TThreads>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TThreads
      begin
        Result := Self.Create();
      end);
  finally
    Free;
  end;
end;

procedure TThreadsRoute.AsynDelete(const ThreadId: string;
  const CallBacks: TFunc<TAsynThreadDeletion>);
begin
  with TAsynCallBackExec<TAsynThreadDeletion, TThreadDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TThreadDeletion
      begin
        Result := Self.Delete(ThreadId);
      end);
  finally
    Free;
  end;
end;

procedure TThreadsRoute.AsynModify(const ThreadId: string;
  const ParamProc: TProc<TThreadsModifyParams>;
  const CallBacks: TFunc<TAsynThreads>);
begin
  with TAsynCallBackExec<TAsynThreads, TThreads>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TThreads
      begin
        Result := Self.Modify(ThreadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TThreadsRoute.AsynRetrieve(const ThreadId: string;
  const CallBacks: TFunc<TAsynThreads>);
begin
  with TAsynCallBackExec<TAsynThreads, TThreads>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TThreads
      begin
        Result := Self.Retrieve(ThreadId);
      end);
  finally
    Free;
  end;
end;

function TThreadsRoute.Create(
  const ParamProc: TProc<TThreadsCreateParams>): TThreads;
begin
  HeaderCustomize;
  Result := API.Post<TThreads, TThreadsCreateParams>('threads', ParamProc)
end;

function TThreadsRoute.Delete(const ThreadId: string): TThreadDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TThreadDeletion>('threads/' + ThreadId);
end;

procedure TThreadsRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TThreadsRoute.Modify(const ThreadId: string;
  const ParamProc: TProc<TThreadsModifyParams>): TThreads;
begin
  HeaderCustomize;
  Result := API.Post<TThreads, TThreadsModifyParams>('threads/' + ThreadId, ParamProc);
end;

function TThreadsRoute.Retrieve(const ThreadId: string): TThreads;
begin
  HeaderCustomize;
  Result := API.Get<TThreads>('threads/' + ThreadId);
end;

{ TThreadsModifyParams }

function TThreadsModifyParams.Metadata(
  const Value: TJSONObject): TThreadsModifyParams;
begin
  Result := TThreadsModifyParams(Add('metadata', Value));
end;

function TThreadsModifyParams.ToolResources(
  const Value: TToolResourcesParams): TThreadsModifyParams;
begin
  Result := TThreadsModifyParams(Add('tool_resources', Value.Detach));
end;

{ TThreads }

destructor TThreads.Destroy;
begin
  if Assigned(FToolResources) then
    FToolResources.Free;
  inherited;
end;

end.
