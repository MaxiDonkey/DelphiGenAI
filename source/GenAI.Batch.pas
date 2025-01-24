unit GenAI.Batch;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support;

type
  TBatchCreateParams = class(TJSONParam)
  public
    function InputFileId(const Value: string): TBatchCreateParams;
    function Endpoint(const Value: string): TBatchCreateParams;
    function CompletionWindow(const Value: string): TBatchCreateParams;
    function Metadata(const Value: TJSONObject): TBatchCreateParams;
  end;

  TBatchListParams = class(TURLParam)
  public
    function After(const Value: string): TBatchListParams;
    function Limit(const Value: Integer): TBatchListParams;
  end;

  TBatchErrorsData = class
  private
    FCode: string;
    FMessage: string;
    FParam: string;
    FLine: Int64;
  public
    property Code: string read FCode write FCode;
    property Message: string read FMessage write FMessage;
    property Param: string read FParam write FParam;
    property Line: Int64 read FLine write FLine;
  end;

  TBatchErrors = class
  private
    FObject: string;
    FData: TArray<TBatchErrorsData>;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TBatchErrorsData> read FData write FData;
    destructor Destroy; override;
  end;

  TBatchTimeStamp = class(TJSONFingerprint)
  protected
    function GetCreatedAtAsString: string; virtual; abstract;
    function GetInProgressAtAsString: string; virtual; abstract;
    function GetExpiresAtAsString: string; virtual; abstract;
    function GetFinalizingAtAsString: string; virtual; abstract;
    function GetCompletedAtAsString: string; virtual; abstract;
    function GetFailedAtAsString: string; virtual; abstract;
    function GetExpiredAtAsString: string; virtual; abstract;
    function GetCancellingAtAsString: string; virtual; abstract;
    function GetCancelledAtAsString: string; virtual; abstract;
  public
    property CreatedAtasString: string read GetCreatedAtAsString;
    property InProgressAtAsString: string read GetInProgressAtAsString;
    property ExpiresAtAsString: string read GetExpiresAtAsString;
    property FinalizingAtAsString: string read GetFinalizingAtAsString;
    property CompletedAtAsString: string read GetCompletedAtAsString;
    property FailedAtAsString: string read GetFailedAtAsString;
    property ExpiredAtAsString: string read GetExpiredAtAsString;
    property CancellingAtAsString: string read GetCancellingAtAsString;
    property CancelledAtAsString: string read GetCancelledAtAsString;
  end;

  TBatchRequestCounts = class
  private
    FTotal: Int64;
    FCompleted: Int64;
    FFailed: Int64;
  public
    property Total: Int64 read FTotal write FTotal;
    property Completed: Int64 read FCompleted write FCompleted;
    property Failed: Int64 read FFailed write FFailed;
  end;

  TBatch = class(TBatchTimeStamp)
  private
    FId: string;
    FObject: string;
    FEndpoint: string;
    FErrors: TBatchErrors;
    [JsonNameAttribute('input_file_id')]
    FInputFileId: string;
    [JsonNameAttribute('completion_window')]
    FCompletionWindow: string;
    FStatus: string;
    [JsonNameAttribute('output_file_id')]
    FOutputFileId: string;
    [JsonNameAttribute('error_file_id')]
    FErrorFileId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('in_progress_at')]
    FInProgressAt: Int64;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    [JsonNameAttribute('finalizing_at')]
    FFinalizingAt: Int64;
    [JsonNameAttribute('completed_at')]
    FCompletedAt: Int64;
    [JsonNameAttribute('failed_at')]
    FFailedAt: Int64;
    [JsonNameAttribute('expired_at')]
    FExpiredAt: Int64;
    [JsonNameAttribute('cancelling_at')]
    FCancellingAt: Int64;
    [JsonNameAttribute('cancelled_at')]
    FCancelledAt: Int64;
    [JsonNameAttribute('request_counts')]
    FRequestCounts: TBatchRequestCounts;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FMetadata: string;
  protected
    function GetCreatedAtAsString: string; override;
    function GetInProgressAtAsString: string; override;
    function GetExpiresAtAsString: string; override;
    function GetFinalizingAtAsString: string; override;
    function GetCompletedAtAsString: string; override;
    function GetFailedAtAsString: string; override;
    function GetExpiredAtAsString: string; override;
    function GetCancellingAtAsString: string; override;
    function GetCancelledAtAsString: string; override;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property Endpoint: string read FEndpoint write FEndpoint;
    property Errors: TBatchErrors read FErrors write FErrors;
    property InputFileId: string read FInputFileId write FInputFileId;
    property CompletionWindow: string read FCompletionWindow write FCompletionWindow;
    property Status: string read FStatus write FStatus;
    property OutputFileId: string read FOutputFileId write FOutputFileId;
    property ErrorFileId: string read FErrorFileId write FErrorFileId;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property InProgressAt: Int64 read FInProgressAt write FInProgressAt;
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;
    property FinalizingAt: Int64 read FFinalizingAt write FFinalizingAt;
    property CompletedAt: Int64 read FCompletedAt write FCompletedAt;
    property FailedAt: Int64 read FFailedAt write FFailedAt;
    property ExpiredAt: Int64 read FExpiredAt write FExpiredAt;
    property CancellingAt: Int64 read FCancellingAt write FCancellingAt;
    property CancelledAt: Int64 read FCancelledAt write FCancelledAt;
    property RequestCounts: TBatchRequestCounts read FRequestCounts write FRequestCounts;
    property Metadata: string read FMetadata write FMetadata;
    destructor Destroy; override;
  end;

  TBatches = class(TJSONFingerprint)
  private
    FObject: string;
    FData: TArray<TBatch>;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('last_id')]
    FLastId: string;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TBatch> read FData write FData;
    property FirstId: string read FFirstId write FFirstId;
    property LastId: string read FLastId write FLastId;
    property HasMore: Boolean read FHasMore write FHasMore;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TBatch</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatch</c> type extends the <c>TAsynParams&lt;TBatch&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynBatch = TAsynCallBack<TBatch>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TBatches</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatches</c> type extends the <c>TAsynParams&lt;TBatches&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynBatches = TAsynCallBack<TBatches>;

  TBatchRoute = class(TGenAIRoute)
    procedure AsynCreate(const ParamProc: TProc<TBatchCreateParams>; const CallBacks: TFunc<TAsynBatch>);
    procedure AsynRetrieve(const BatchId: string; const CallBacks: TFunc<TAsynBatch>);
    procedure AsynCancel(const BatchId: string; const CallBacks: TFunc<TAsynBatch>);
    procedure AsynList(const CallBacks: TFunc<TAsynBatches>); overload;
    procedure AsynList(const ParamProc: TProc<TBatchListParams>; const CallBacks: TFunc<TAsynBatches>); overload;
    function Create(const ParamProc: TProc<TBatchCreateParams>): TBatch;
    function Retrieve(const BatchId: string): TBatch;
    function Cancel(const BatchId: string): TBatch;
    function List: TBatches; overload;
    function List(const ParamProc: TProc<TBatchListParams>): TBatches; overload;
  end;

implementation

{ TBatchCreateParams }

function TBatchCreateParams.CompletionWindow(
  const Value: string): TBatchCreateParams;
begin
  Result := TBatchCreateParams(Add('completion_window', Value));
end;

function TBatchCreateParams.Endpoint(const Value: string): TBatchCreateParams;
begin
  Result := TBatchCreateParams(Add('endpoint', Value));
end;

function TBatchCreateParams.InputFileId(
  const Value: string): TBatchCreateParams;
begin
  Result := TBatchCreateParams(Add('input_file_id', Value));
end;

function TBatchCreateParams.Metadata(
  const Value: TJSONObject): TBatchCreateParams;
begin
  Result := TBatchCreateParams(Add('metadata', Value));
end;

{ TBatchErrors }

destructor TBatchErrors.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TBatch }

destructor TBatch.Destroy;
begin
  if Assigned(FErrors) then
    FErrors.Free;
  if Assigned(FRequestCounts) then
    FRequestCounts.Free;
  inherited;
end;

function TBatch.GetCancelledAtAsString: string;
begin
  Result := TimestampToString(CancelledAt, UTCtimestamp);
end;

function TBatch.GetCancellingAtAsString: string;
begin
  Result := TimestampToString(CancellingAt, UTCtimestamp);
end;

function TBatch.GetCompletedAtAsString: string;
begin
  Result := TimestampToString(CompletedAt, UTCtimestamp);
end;

function TBatch.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TBatch.GetExpiredAtAsString: string;
begin
  Result := TimestampToString(ExpiredAt, UTCtimestamp);
end;

function TBatch.GetExpiresAtAsString: string;
begin
  Result := TimestampToString(ExpiresAt, UTCtimestamp);
end;

function TBatch.GetFailedAtAsString: string;
begin
  Result := TimestampToString(FailedAt, UTCtimestamp);
end;

function TBatch.GetFinalizingAtAsString: string;
begin
  Result := TimestampToString(FinalizingAt, UTCtimestamp);
end;

function TBatch.GetInProgressAtAsString: string;
begin
  Result := TimestampToString(InProgressAt, UTCtimestamp);
end;

{ TBatchRoute }

procedure TBatchRoute.AsynCancel(const BatchId: string;
  const CallBacks: TFunc<TAsynBatch>);
begin
  with TAsynCallBackExec<TAsynBatch, TBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TBatch
      begin
        Result := Self.Cancel(BatchId);
      end);
  finally
    Free;
  end;
end;

procedure TBatchRoute.AsynCreate(const ParamProc: TProc<TBatchCreateParams>;
  const CallBacks: TFunc<TAsynBatch>);
begin
  with TAsynCallBackExec<TAsynBatch, TBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TBatch
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TBatchRoute.AsynList(const ParamProc: TProc<TBatchListParams>;
  const CallBacks: TFunc<TAsynBatches>);
begin
  with TAsynCallBackExec<TAsynBatches, TBatches>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TBatches
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TBatchRoute.AsynList(const CallBacks: TFunc<TAsynBatches>);
begin
  with TAsynCallBackExec<TAsynBatches, TBatches>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TBatches
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TBatchRoute.AsynRetrieve(const BatchId: string;
  const CallBacks: TFunc<TAsynBatch>);
begin
  with TAsynCallBackExec<TAsynBatch, TBatch>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TBatch
      begin
        Result := Self.Retrieve(BatchId);
      end);
  finally
    Free;
  end;
end;

function TBatchRoute.Cancel(const BatchId: string): TBatch;
begin
  Result := API.Post<TBatch>('batches/' + BatchId + '/cancel');
end;

function TBatchRoute.Create(const ParamProc: TProc<TBatchCreateParams>): TBatch;
begin
  Result := API.Post<TBatch, TBatchCreateParams>('batches', ParamProc);
end;

function TBatchRoute.List: TBatches;
begin
  Result := API.Get<TBatches>('batches');
end;

function TBatchRoute.List(const ParamProc: TProc<TBatchListParams>): TBatches;
begin
  Result := API.Get<TBatches, TBatchListParams>('batches', ParamProc);
end;

function TBatchRoute.Retrieve(const BatchId: string): TBatch;
begin
  Result := API.Get<TBatch>('batches/' + BatchId);
end;

{ TBatchListParams }

function TBatchListParams.After(const Value: string): TBatchListParams;
begin
  Result := TBatchListParams(Add('after', Value));
end;

function TBatchListParams.Limit(const Value: Integer): TBatchListParams;
begin
  Result := TBatchListParams(Add('limit', Value));
end;

{ TBatches }

destructor TBatches.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

end.
