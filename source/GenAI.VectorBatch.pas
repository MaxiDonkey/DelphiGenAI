unit GenAI.VectorBatch;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.API.Lists, GenAI.Assistants, GenAI.Runs, GenAI.Vector, GenAI.VectorFiles;

type
  TVectorStoreBatchUrlParams = TVectorStoreFilesUrlParams;

  TVectorStoreBatchCreateParams = TVectorStoreFilesCreateParams;

  TVectorStoreBatch = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('vector_store_id')]
    FVectorStoreId: string;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('file_counts')]
    FFileCounts: TVectorFileCounts;
  private
    function GetCreatedAtAsString: string;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property VectorStoreId: string read FVectorStoreId write FVectorStoreId;
    property Status: TRunStatus read FStatus write FStatus;
    property FileCounts: TVectorFileCounts read FFileCounts write FFileCounts;
    destructor Destroy; override;
  end;

  TVectorStoreBatches = TAdvancedList<TVectorStoreBatch>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreBatch</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreBatch</c> type extends the <c>TAsynParams&lt;TVectorStoreBatch&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreBatch = TAsynCallBack<TVectorStoreBatch>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreBatches</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreBatches</c> type extends the <c>TAsynParams&lt;TVectorStoreBatches&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreBatches = TAsynCallBack<TVectorStoreBatches>;

  TVectorStoreBatchRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    procedure AsynCreate(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreBatchCreateParams>;
      const CallBacks: TFunc<TAsynVectorStoreBatch>);
    procedure AsynRetrieve(const VectorStoreId: string;
      const BatchId: string;
      const CallBacks: TFunc<TAsynVectorStoreBatch>);
    procedure AsynCancel(const VectorStoreId: string;
      const BatchId: string;
      const CallBacks: TFunc<TAsynVectorStoreBatch>);
    procedure AsynList(const VectorStoreId: string;
      const BatchId: string;
      const CallBacks: TFunc<TAsynVectorStoreBatches>); overload;
    procedure AsynList(const VectorStoreId: string;
      const BatchId: string;
      const ParamProc: TProc<TVectorStoreBatchUrlParams>;
      const CallBacks: TFunc<TAsynVectorStoreBatches>); overload;

    function Create(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreBatchCreateParams>): TVectorStoreBatch;
    function Retrieve(const VectorStoreId: string; const BatchId: string): TVectorStoreBatch;
    function Cancel(const VectorStoreId: string; const BatchId: string): TVectorStoreBatch;
    function List(const VectorStoreId: string; const BatchId: string): TVectorStoreBatches; overload;
    function List(const VectorStoreId: string; const BatchId: string;
      const ParamProc: TProc<TVectorStoreBatchUrlParams>): TVectorStoreBatches; overload;
  end;

implementation

{ TVectorStoreBatch }

destructor TVectorStoreBatch.Destroy;
begin
  if Assigned(FFileCounts) then
    FFileCounts.Free;
  inherited;
end;

function TVectorStoreBatch.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

{ TVectorStoreBatchRoute }

procedure TVectorStoreBatchRoute.AsynCancel(const VectorStoreId,
  BatchId: string; const CallBacks: TFunc<TAsynVectorStoreBatch>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatch, TVectorStoreBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatch
      begin
        Result := Self.Cancel(VectorStoreId, BatchId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynCreate(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreBatchCreateParams>;
  const CallBacks: TFunc<TAsynVectorStoreBatch>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatch, TVectorStoreBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatch
      begin
        Result := Self.Create(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynList(const VectorStoreId, BatchId: string;
  const ParamProc: TProc<TVectorStoreBatchUrlParams>;
  const CallBacks: TFunc<TAsynVectorStoreBatches>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatches, TVectorStoreBatches>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatches
      begin
        Result := Self.List(VectorStoreId, BatchId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynList(const VectorStoreId, BatchId: string;
  const CallBacks: TFunc<TAsynVectorStoreBatches>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatches, TVectorStoreBatches>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatches
      begin
        Result := Self.List(VectorStoreId, BatchId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreBatchRoute.AsynRetrieve(const VectorStoreId,
  BatchId: string; const CallBacks: TFunc<TAsynVectorStoreBatch>);
begin
  with TAsynCallBackExec<TAsynVectorStoreBatch, TVectorStoreBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreBatch
      begin
        Result := Self.Retrieve(VectorStoreId, BatchId);
      end);
  finally
    Free;
  end;
end;

function TVectorStoreBatchRoute.Cancel(const VectorStoreId,
  BatchId: string): TVectorStoreBatch;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreBatch>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId + '/cancel');
end;

function TVectorStoreBatchRoute.Create(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreBatchCreateParams>): TVectorStoreBatch;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStoreBatch, TVectorStoreBatchCreateParams>('vector_stores/' + VectorStoreId + '/file_batches', ParamProc);
end;

procedure TVectorStoreBatchRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TVectorStoreBatchRoute.List(const VectorStoreId, BatchId: string;
  const ParamProc: TProc<TVectorStoreBatchUrlParams>): TVectorStoreBatches;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreBatches, TVectorStoreBatchUrlParams>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId + '/files', ParamProc);
end;

function TVectorStoreBatchRoute.List(const VectorStoreId,
  BatchId: string): TVectorStoreBatches;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreBatches>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId + '/files');
end;

function TVectorStoreBatchRoute.Retrieve(const VectorStoreId,
  BatchId: string): TVectorStoreBatch;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreBatch>('vector_stores/' + VectorStoreId + '/file_batches/' + BatchId);
end;

end.
