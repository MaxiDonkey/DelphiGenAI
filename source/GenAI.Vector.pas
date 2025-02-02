unit GenAI.Vector;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.API.Lists, GenAI.Assistants;

type
  TVectorStoreUrlParam = class(TUrlAdvancedParams);

  TExpiresAfterParams = class(TJSONParam)
  public
    function Anchor(const Value: string): TExpiresAfterParams;
    function Days(const Value: Integer): TExpiresAfterParams;
  end;

  TVectorStoreCreateParams = class(TJSONParam)
  public
    function FileIds(const Value: string): TVectorStoreCreateParams;
    function Name(const Value: string): TVectorStoreCreateParams;
    function ExpiresAfter(const Value: TExpiresAfterParams): TVectorStoreCreateParams;
    function ChunkingStrategy(const Value: TChunkingStrategyParams): TVectorStoreCreateParams;
    function Metadata(const Value: TJSONObject): TVectorStoreCreateParams;
  end;

  TVectorStoreUpdateParams = class(TJSONParam)
  public
    function Name(const Value: string): TVectorStoreUpdateParams;
    function ExpiresAfter(const Value: TExpiresAfterParams): TVectorStoreUpdateParams;
    function Metadata(const Value: TJSONObject): TVectorStoreUpdateParams;
  end;

  TVectorFileCounts = class
  private
    [JsonNameAttribute('in_progress')]
    FInProgress: Int64;
    FCompleted: Int64;
    FFailed: Int64;
    FCancelled: Int64;
    FTotal: Int64;
  public
    property InProgress: Int64 read FInProgress write FInProgress;
    property Completed: Int64 read FCompleted write FCompleted;
    property Failed: Int64 read FFailed write FFailed;
    property Cancelled: Int64 read FCancelled write FCancelled;
    property Total: Int64 read FTotal write FTotal;
  end;

  TExpiresAfter = class
  private
    FAnchor: string;
    FDays: Int64;
  public
    property Anchor: string read FAnchor write FAnchor;
    property Days: Int64 read FDays write FDays;
  end;

  TVectorStoreTimestamp = class(TJSONFingerprint)
  protected
    function GetCreatedAtAsString: string; virtual; abstract;
    function GetExpiresAtAsString: string; virtual; abstract;
    function GetLastActiveAtAsString: string; virtual; abstract;
  public
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property ExpiresAtAsString: string read GetExpiresAtAsString;
    property LastActiveAtAsString: string read GetLastActiveAtAsString;
  end;

  TVectorStore = class(TVectorStoreTimestamp)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FName: string;
    [JsonNameAttribute('usage_bytes')]
    FUsageBytes: Int64;
    [JsonNameAttribute('file_counts')]
    FFileCounts: TVectorFileCounts;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('expires_after')]
    FExpiresAfter: TExpiresAfter;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    [JsonNameAttribute('last_active_at')]
    FLastActiveAt: Int64;
    FMetadata: string;
  protected
    function GetCreatedAtAsString: string; override;
    function GetExpiresAtAsString: string; override;
    function GetLastActiveAtAsString: string; override;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property Name: string read FName write FName;
    property UsageBytes: Int64 read FUsageBytes write FUsageBytes;
    property FileCounts: TVectorFileCounts read FFileCounts write FFileCounts;
    property Status: TRunStatus read FStatus write FStatus;
    property ExpiresAfter: TExpiresAfter read FExpiresAfter write FExpiresAfter;
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;
    property LastActiveAt: Int64 read FLastActiveAt write FLastActiveAt;
    property Metadata: string read FMetadata write FMetadata;
    destructor Destroy; override;
  end;

  TVectorStores = TAdvancedList<TVectorStore>;

  TVectorStoreDeletion = class
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
  /// Manages asynchronous chat callBacks for a chat request using <c>TVectorStore</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStore</c> type extends the <c>TAsynParams&lt;TVectorStore&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynVectorStore = TAsynCallBack<TVectorStore>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TVectorStores</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStores</c> type extends the <c>TAsynParams&lt;TVectorStores&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynVectorStores = TAsynCallBack<TVectorStores>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TVectorStoreDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreDeletion</c> type extends the <c>TAsynParams&lt;TVectorStoreDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynVectorStoreDeletion = TAsynCallBack<TVectorStoreDeletion>;

  TVectorStoreRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    procedure AsynCreate(const ParamProc: TProc<TVectorStoreCreateParams>;
      const CallBacks: TFunc<TAsynVectorStore>);
    procedure AsynList(const CallBacks: TFunc<TAsynVectorStores>); overload;
    procedure AsynList(const ParamProc: TProc<TVectorStoreUrlParam>;
      const CallBacks: TFunc<TAsynVectorStores>); overload;
    procedure AsynRetrieve(const VectorStoreId: string;
      const CallBacks: TFunc<TAsynVectorStore>);
    procedure AsynUpdate(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreUpdateParams>;
      const CallBacks: TFunc<TAsynVectorStore>);
    procedure AsynDelete(const VectorStoreId: string;
      const CallBacks: TFunc<TAsynVectorStoreDeletion>);
    function Create(const ParamProc: TProc<TVectorStoreCreateParams>): TVectorStore;
    function List: TVectorStores; overload;
    function List(const ParamProc: TProc<TVectorStoreUrlParam>): TVectorStores; overload;
    function Retrieve(const VectorStoreId: string): TVectorStore;
    function Update(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreUpdateParams>): TVectorStore;
    function Delete(const VectorStoreId: string): TVectorStoreDeletion;
  end;

implementation

{ TVectorStoreCreateParams }

function TVectorStoreCreateParams.ChunkingStrategy(
  const Value: TChunkingStrategyParams): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('chunking_strategy', Value.Detach));
end;

function TVectorStoreCreateParams.ExpiresAfter(
  const Value: TExpiresAfterParams): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('expires_after', Value.Detach));
end;

function TVectorStoreCreateParams.FileIds(const Value: string): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('file_ids', Value));
end;

function TVectorStoreCreateParams.Metadata(
  const Value: TJSONObject): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('metadata', Value));
end;

function TVectorStoreCreateParams.Name(const Value: string): TVectorStoreCreateParams;
begin
  Result := TVectorStoreCreateParams(Add('name', Value));
end;

{ TExpiresAfterParams }

function TExpiresAfterParams.Anchor(const Value: string): TExpiresAfterParams;
begin
  Result := TExpiresAfterParams(Add('anchor', Value));
end;

function TExpiresAfterParams.Days(const Value: Integer): TExpiresAfterParams;
begin
  Result := TExpiresAfterParams(Add('days', Value));
end;

{ TVectorStore }

destructor TVectorStore.Destroy;
begin
  if Assigned(FFileCounts) then
    FFileCounts.Free;
  if Assigned(FExpiresAfter) then
    FExpiresAfter.Free;
  inherited;
end;

function TVectorStore.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TVectorStore.GetExpiresAtAsString: string;
begin
  Result := TimestampToString(ExpiresAt, UTCtimestamp);
end;

function TVectorStore.GetLastActiveAtAsString: string;
begin
  Result := TimestampToString(LastActiveAt, UTCtimestamp);
end;

{ TVectorStoreRoute }

procedure TVectorStoreRoute.AsynCreate(
  const ParamProc: TProc<TVectorStoreCreateParams>;
  const CallBacks: TFunc<TAsynVectorStore>);
begin
  with TAsynCallBackExec<TAsynVectorStore, TVectorStore>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStore
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynDelete(const VectorStoreId: string;
  const CallBacks: TFunc<TAsynVectorStoreDeletion>);
begin
  with TAsynCallBackExec<TAsynVectorStoreDeletion, TVectorStoreDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreDeletion
      begin
        Result := Self.Delete(VectorStoreId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynList(const CallBacks: TFunc<TAsynVectorStores>);
begin
  with TAsynCallBackExec<TAsynVectorStores, TVectorStores>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStores
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynList(
  const ParamProc: TProc<TVectorStoreUrlParam>;
  const CallBacks: TFunc<TAsynVectorStores>);
begin
  with TAsynCallBackExec<TAsynVectorStores, TVectorStores>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStores
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynRetrieve(const VectorStoreId: string;
  const CallBacks: TFunc<TAsynVectorStore>);
begin
  with TAsynCallBackExec<TAsynVectorStore, TVectorStore>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStore
      begin
        Result := Self.Retrieve(VectorStoreId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreRoute.AsynUpdate(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreUpdateParams>;
  const CallBacks: TFunc<TAsynVectorStore>);
begin
  with TAsynCallBackExec<TAsynVectorStore, TVectorStore>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStore
      begin
        Result := Self.Update(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

function TVectorStoreRoute.Create(
  const ParamProc: TProc<TVectorStoreCreateParams>): TVectorStore;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStore, TVectorStoreCreateParams>('vector_stores', ParamProc);
end;

function TVectorStoreRoute.Delete(
  const VectorStoreId: string): TVectorStoreDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TVectorStoreDeletion>('vector_stores/' + VectorStoreId);
end;

procedure TVectorStoreRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TVectorStoreRoute.List: TVectorStores;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStores>('vector_stores');
end;

function TVectorStoreRoute.List(
  const ParamProc: TProc<TVectorStoreUrlParam>): TVectorStores;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStores, TVectorStoreUrlParam>('vector_stores', ParamProc);
end;

function TVectorStoreRoute.Retrieve(const VectorStoreId: string): TVectorStore;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStore>('vector_stores/' + VectorStoreId);
end;

function TVectorStoreRoute.Update(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreUpdateParams>): TVectorStore;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStore, TVectorStoreUpdateParams>('vector_stores/' + VectorStoreId, ParamProc);
end;

{ TVectorStoreUpdateParams }

function TVectorStoreUpdateParams.ExpiresAfter(
  const Value: TExpiresAfterParams): TVectorStoreUpdateParams;
begin
  Result := TVectorStoreUpdateParams(Add('expires_after', Value.Detach));
end;

function TVectorStoreUpdateParams.Metadata(
  const Value: TJSONObject): TVectorStoreUpdateParams;
begin
  Result := TVectorStoreUpdateParams(Add('metadata', Value));
end;

function TVectorStoreUpdateParams.Name(
  const Value: string): TVectorStoreUpdateParams;
begin
  Result := TVectorStoreUpdateParams(Add('name', Value));
end;

end.
