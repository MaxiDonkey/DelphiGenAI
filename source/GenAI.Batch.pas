unit GenAI.Batch;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

-------------------------------------------------------------------------------}

interface

{$REGION  'Dev notes : GenAI.Batch'}

(*
  -- WARNING --
    The documentation references the capability to execute a batch through the /v1/completions endpoint.
    However, it  is  important to  clarify  that batch  processing is  not feasible  with this endpoint.
    This limitation arises because not all models available  for the completion mechanism support batch
    operations.
*)

{$ENDREGION}

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Async.Promise, GenAI.API.Lists;

type
  TBatchCreateParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the ID of the uploaded file that contains the batch requests.
    /// This is a required parameter and must reference a valid file ID that has been prepared and uploaded beforehand.
    /// </summary>
    /// <param name="Value">The ID of the uploaded file.</param>
    /// <returns>The instance of TBatchCreateParams for method chaining.</returns>
    function InputFileId(const Value: string): TBatchCreateParams;

    /// <summary>
    /// Specifies the API endpoint to be used for all requests within the batch.
    /// This is a required parameter and must be one of the supported endpoints such as :
    /// <para>
    /// - <c>/v1/chat/completions</c>
    /// </para>
    /// <para>
    /// - <c>/v1/embeddings</c>
    /// </para>
    /// </summary>
    /// <param name="Value">The API endpoint as a string.</param>
    /// <returns>The instance of TBatchCreateParams for method chaining.</returns>
    function Endpoint(const Value: string): TBatchCreateParams;

    /// <summary>
    /// Sets the completion window for the batch. This defines the time frame within which the batch should be processed.
    /// Currently, only "24h" is supported, which indicates that the batch should be completed within 24 hours.
    /// </summary>
    /// <param name="Value">The completion window string, typically "24h".</param>
    /// <returns>The instance of TBatchCreateParams for method chaining.</returns>
    function CompletionWindow(const Value: string): TBatchCreateParams;

    /// <summary>
    /// Attaches optional custom metadata to the batch. This can be used to store additional structured information about the batch operation.
    /// The metadata is a JSON object and can contain up to 16 key-value pairs, with keys up to 64 characters and values up to 512 characters.
    /// </summary>
    /// <param name="Value">The JSON object containing the metadata.</param>
    /// <returns>The instance of TBatchCreateParams for method chaining.</returns>
    function Metadata(const Value: TJSONObject): TBatchCreateParams;
  end;

  TBatchErrorsData = class
  private
    FCode: string;
    FMessage: string;
    FParam: string;
    FLine: Int64;
  public
    /// <summary>
    /// Gets or sets the machine-readable error code. This code can be used to programmatically identify the type of error that occurred.
    /// </summary>
    /// <returns>The error code as a string.</returns>
    property Code: string read FCode write FCode;

    /// <summary>
    /// Gets or sets the human-readable error message that describes the error. This message is designed to be easily understood
    /// and can be used for logging or displaying error information to users.
    /// </summary>
    /// <returns>The error message as a string.</returns>
    property Message: string read FMessage write FMessage;

    /// <summary>
    /// Gets or sets the parameter name related to the error, providing context for the error within the scope of the request.
    /// This is particularly useful when the error is associated with a specific parameter in the request data.
    /// </summary>
    /// <returns>The parameter name as a string.</returns>
    property Param: string read FParam write FParam;

    /// <summary>
    /// Gets or sets the line number from the input file that triggered the error, if applicable. This helps in pinpointing the exact
    /// location in the batch input file that needs attention, improving the efficiency of error resolution.
    /// </summary>
    /// <returns>The line number as an Int64.</returns>
    property Line: Int64 read FLine write FLine;
  end;

  TBatchErrors = class
  private
    FObject: string;
    FData: TArray<TBatchErrorsData>;
  public
    /// <summary>
    /// Gets or sets the type of the object. This property typically contains the value 'error', identifying the nature of the data stored in this class.
    /// </summary>
    /// <returns>The object type as a string.</returns>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Gets or sets an array of TBatchErrorsData instances that detail each error occurred during the batch operation.
    /// This array facilitates access to specific error details, allowing for individual error handling and reporting.
    /// </summary>
    /// <returns>An array of TBatchErrorsData instances.</returns>
    property Data: TArray<TBatchErrorsData> read FData write FData;

    destructor Destroy; override;
  end;

  TBatchTimeStamp = class abstract(TJSONFingerprint)
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
    /// <summary>
    /// Retrieves the creation timestamp as a formatted string. This timestamp represents when the batch was initially created.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for the batch's creation time.</returns>
    property CreatedAtasString: string read GetCreatedAtAsString;

    /// <summary>
    /// Retrieves the in-progress timestamp as a formatted string. This timestamp indicates when the batch started processing.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch processing began.</returns>
    property InProgressAtAsString: string read GetInProgressAtAsString;

    /// <summary>
    /// Retrieves the expiration timestamp as a formatted string. This timestamp denotes when the batch is set to expire.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch will expire.</returns>
    property ExpiresAtAsString: string read GetExpiresAtAsString;

    /// <summary>
    /// Retrieves the finalizing timestamp as a formatted string. This timestamp reflects when the batch entered the finalizing stage,
    /// which typically involves concluding processing and preparing results.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch began its finalization process.</returns>
    property FinalizingAtAsString: string read GetFinalizingAtAsString;

    /// <summary>
    /// Retrieves the completed timestamp as a formatted string. This timestamp indicates when the batch processing was fully completed.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch processing was completed.</returns>
    property CompletedAtAsString: string read GetCompletedAtAsString;

    /// <summary>
    /// Retrieves the failed timestamp as a formatted string. This timestamp is recorded if the batch fails at any point during its lifecycle.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch failed.</returns>
    property FailedAtAsString: string read GetFailedAtAsString;

    /// <summary>
    /// Retrieves the expired timestamp as a formatted string. This timestamp is used when the batch has passed its expiration time without completion.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch expired.</returns>
    property ExpiredAtAsString: string read GetExpiredAtAsString;

    /// <summary>
    /// Retrieves the cancelling timestamp as a formatted string. This timestamp denotes when the cancellation process for the batch was initiated.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch cancellation process started.</returns>
    property CancellingAtAsString: string read GetCancellingAtAsString;

    /// <summary>
    /// Retrieves the cancelled timestamp as a formatted string. This timestamp indicates when the batch was fully cancelled.
    /// </summary>
    /// <returns>A string representation of the Unix timestamp for when the batch was officially cancelled.</returns>
    property CancelledAtAsString: string read GetCancelledAtAsString;
  end;

  TBatchRequestCounts = class
  private
    FTotal: Int64;
    FCompleted: Int64;
    FFailed: Int64;
  public
    /// <summary>
    /// Gets or sets the total number of requests included in the batch. This count provides an overview of the batch size and scope.
    /// </summary>
    /// <returns>The total number of requests as an Int64.</returns>
    property Total: Int64 read FTotal write FTotal;

    /// <summary>
    /// Gets or sets the number of requests that have been completed successfully. This count helps in assessing the effectiveness
    /// and efficiency of the batch processing.
    /// </summary>
    /// <returns>The number of completed requests as an Int64.</returns>
    property Completed: Int64 read FCompleted write FCompleted;

    /// <summary>
    /// Gets or sets the number of requests that have failed during the batch processing. This count is essential for error analysis
    /// and understanding the robustness of the batch operation.
    /// </summary>
    /// <returns>The number of failed requests as an Int64.</returns>
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
    [JsonReflectAttribute(ctString, rtString, TBatchStatusInterceptor)]
    FStatus: TBatchStatus;
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
    FMetadata: string;
    function GetCancelledAt: Int64;
    function GetCancellingAt: Int64;
    function GetCompletedAt: Int64;
    function GetCreatedAt: Int64;
    function GetExpiredAt: Int64;
    function GetExpiresAt: Int64;
    function GetFailedAt: Int64;
    function GetFinalizingAt: Int64;
    function GetInProgressAt: Int64;
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
    /// <summary>
    /// The unique identifier for the batch. This ID is used to track and manage the batch throughout its lifecycle.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Specifies the object type, which remains constant as 'batch' for instances of this class,
    /// aligning with OpenAI's API structure.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Defines the API endpoint that the batch uses, indicating whether the batch is for completions, embeddings,
    /// or another supported API function. This setup helps direct the batch processing accordingly.
    /// </summary>
    property Endpoint: string read FEndpoint write FEndpoint;

    /// <summary>
    /// Manages the collection of errors that might occur during the processing of the batch, providing
    /// detailed error diagnostics that are critical for troubleshooting and error resolution.
    /// </summary>
    property Errors: TBatchErrors read FErrors write FErrors;

    /// <summary>
    /// Identifies the input file by its ID, linking the batch to its specific input data which contains
    /// the requests or data set the batch operation is expected to process.
    /// </summary>
    property InputFileId: string read FInputFileId write FInputFileId;

    /// <summary>
    /// Specifies the time window within which the batch is expected to complete, ensuring timely processing.
    /// This property supports the current system constraint of a 24-hour processing window.
    /// </summary>
    property CompletionWindow: string read FCompletionWindow write FCompletionWindow;

    /// <summary>
    /// Reflects the current status of the batch, such as 'in progress', 'completed', or 'failed',
    /// providing real-time status updates necessary for monitoring the progress of batch operations.
    /// </summary>
    property Status: TBatchStatus read FStatus write FStatus;

    /// <summary>
    /// Holds the ID of the output file that contains the results of the batch's processed requests,
    /// facilitating access to the outcomes of the batch operation.
    /// </summary>
    property OutputFileId: string read FOutputFileId write FOutputFileId;

    /// <summary>
    /// If errors occur, this holds the ID of the error file which logs detailed error information,
    /// assisting in the analysis and rectification of issues that occurred during batch processing.
    /// </summary>
    property ErrorFileId: string read FErrorFileId write FErrorFileId;

    /// <summary>
    /// Records the timestamp of when the batch was initially created. This is the starting point in the
    /// lifecycle of a batch operation.
    /// </summary>
    property CreatedAt: Int64 read GetCreatedAt;

    /// <summary>
    /// Marks the timestamp of when the batch started processing. It's crucial for monitoring when the
    /// batch transitions from a queued or pending state to an active processing state.
    /// </summary>
    property InProgressAt: Int64 read GetInProgressAt;

    /// <summary>
    /// Indicates the timestamp of when the batch is set to expire. This property is essential for managing
    /// the lifecycle of the batch, ensuring that operations are completed within the expected timeframe or
    /// handling tasks that exceed their completion window.
    /// </summary>
    property ExpiresAt: Int64 read GetExpiresAt;

    /// <summary>
    /// Captures the timestamp of when the batch entered the finalizing stage. This stage marks the transition
    /// from active processing to concluding the operations, where final checks or cleanup might occur.
    /// </summary>
    property FinalizingAt: Int64 read GetFinalizingAt;

    /// <summary>
    /// Represents the timestamp of when the batch processing was completed successfully. This timestamp is
    /// crucial for tracking the end of the processing phase and the readiness of the output data.
    /// </summary>
    property CompletedAt: Int64 read GetCompletedAt;

    /// <summary>
    /// Logs the timestamp of when the batch encountered a failure that prevented it from completing
    /// successfully. This property is critical for error handling and for initiating potential retries or
    /// investigations.
    /// </summary>
    property FailedAt: Int64 read GetFailedAt;

    /// <summary>
    /// Denotes the timestamp of when the batch expired. If a batch does not complete within the designated
    /// time (as noted in ExpiresAt), it may be marked as expired, indicating that it did not conclude in the
    /// expected period.
    /// </summary>
    property ExpiredAt: Int64 read GetExpiredAt;

    /// <summary>
    /// Records the timestamp of when the cancellation process for the batch started. This property is
    /// important for managing batches that need to be stopped before completion due to errors, changes in
    /// requirements, or other operational reasons.
    /// </summary>
    property CancellingAt: Int64 read GetCancellingAt;

    /// <summary>
    /// Indicates the timestamp of when the batch was officially cancelled. This final timestamp in the
    /// cancellation process confirms that no further processing will occur and the batch has been terminated.
    /// </summary>
    property CancelledAt: Int64 read GetCancelledAt;

    /// <summary>
    /// Provides a structured breakdown of request counts within the batch, including total requests,
    /// successfully completed requests, and failed requests, enabling effective management and analysis
    /// of batch performance.
    /// </summary>
    property RequestCounts: TBatchRequestCounts read FRequestCounts write FRequestCounts;

    /// <summary>
    /// Optional metadata that can be attached to a batch. This metadata can store additional information
    /// about the batch in a structured format, aiding in further customization and utility.
    /// </summary>
    property Metadata: string read FMetadata write FMetadata;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a collection of batch objects from the OpenAI API.
  /// This class provides an aggregated view of multiple batch entries, enabling effective navigation and management
  /// of batch operations. It includes functionality for pagination to handle large sets of data efficiently.
  /// </summary>
  TBatches = TAdvancedList<TBatch>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TBatch</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatch</c> type extends the <c>TAsynParams&lt;TBatch&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynBatch = TAsynCallBack<TBatch>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TBatches</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynBatches</c> type extends the <c>TAsynParams&lt;TBatches&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynBatches = TAsynCallBack<TBatches>;

  /// <summary>
  /// Promise callback record for a single batch response.
  /// </summary>
  TPromiseBatch = TPromiseCallBack<TBatch>;

  /// <summary>
  /// Promise callback record for a batch list response.
  /// </summary>
  TPromiseBatches = TPromiseCallBack<TBatches>;

  TBatchAbstractSupport = class(TGenAIRoute)
  protected
    function Create(const ParamProc: TProc<TBatchCreateParams>): TBatch; virtual; abstract;
    function Retrieve(const BatchId: string): TBatch; virtual; abstract;
    function Cancel(const BatchId: string): TBatch; virtual; abstract;
    function List: TBatches; overload; virtual; abstract;
    function List(const ParamProc: TProc<TUrlPaginationParams>): TBatches; overload; virtual; abstract;
  end;

  TBatchAsynchronousSupport = class(TBatchAbstractSupport)
  public
    procedure AsynCreate(const ParamProc: TProc<TBatchCreateParams>; const CallBacks: TFunc<TAsynBatch>);
    procedure AsynRetrieve(const BatchId: string; const CallBacks: TFunc<TAsynBatch>);
    procedure AsynCancel(const BatchId: string; const CallBacks: TFunc<TAsynBatch>);
    procedure AsynList(const CallBacks: TFunc<TAsynBatches>); overload;
    procedure AsynList(const ParamProc: TProc<TUrlPaginationParams>; const CallBacks: TFunc<TAsynBatches>); overload;
  end;

  /// <summary>
  /// Provides routes for managing batches within the OpenAI API.
  /// This class provides the concrete synchronous implementations along with their promise-based
  /// (<c>AsyncAwait*</c>) variants, inheriting the callback-based (<c>Asyn*</c>) variants from
  /// <see cref="TBatchAsynchronousSupport"/>. It can create, retrieve, cancel, and list batches.
  /// </summary>
  TBatchRoute = class(TBatchAsynchronousSupport)
  public
    /// <summary>
    /// Asynchronously creates a batch and returns a promise that resolves with the created batch.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the parameters for the batch creation.</param>
    /// <param name="CallBacks">An optional function providing <see cref="TPromiseBatch"/> lifecycle callbacks.</param>
    /// <returns>A <c>TPromise&lt;TBatch&gt;</c> that completes when the creation request succeeds or fails.</returns>
    function AsyncAwaitCreate(const ParamProc: TProc<TBatchCreateParams>;
      const CallBacks: TFunc<TPromiseBatch> = nil): TPromise<TBatch>;

    /// <summary>
    /// Asynchronously retrieves a batch by its ID and returns a promise that resolves with the batch.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to retrieve.</param>
    /// <param name="CallBacks">An optional function providing <see cref="TPromiseBatch"/> lifecycle callbacks.</param>
    /// <returns>A <c>TPromise&lt;TBatch&gt;</c> that completes when the retrieval request succeeds or fails.</returns>
    function AsyncAwaitRetrieve(const BatchId: string;
      const CallBacks: TFunc<TPromiseBatch> = nil): TPromise<TBatch>;

    /// <summary>
    /// Asynchronously cancels an in-progress batch and returns a promise that resolves with the cancelled batch.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to cancel.</param>
    /// <param name="CallBacks">An optional function providing <see cref="TPromiseBatch"/> lifecycle callbacks.</param>
    /// <returns>A <c>TPromise&lt;TBatch&gt;</c> that completes when the cancellation request succeeds or fails.</returns>
    function AsyncAwaitCancel(const BatchId: string;
      const CallBacks: TFunc<TPromiseBatch> = nil): TPromise<TBatch>;

    /// <summary>
    /// Asynchronously lists all batches and returns a promise that resolves with the batch list.
    /// </summary>
    /// <param name="CallBacks">An optional function providing <see cref="TPromiseBatches"/> lifecycle callbacks.</param>
    /// <returns>A <c>TPromise&lt;TBatches&gt;</c> that completes when the listing request succeeds or fails.</returns>
    function AsyncAwaitList(const CallBacks: TFunc<TPromiseBatches> = nil): TPromise<TBatches>; overload;

    /// <summary>
    /// Asynchronously lists batches with pagination and returns a promise that resolves with the batch list.
    /// </summary>
    /// <param name="ParamProc">A procedure to configure listing parameters such as pagination.</param>
    /// <param name="CallBacks">An optional function providing <see cref="TPromiseBatches"/> lifecycle callbacks.</param>
    /// <returns>A <c>TPromise&lt;TBatches&gt;</c> that completes when the listing request succeeds or fails.</returns>
    function AsyncAwaitList(const ParamProc: TProc<TUrlPaginationParams>;
      const CallBacks: TFunc<TPromiseBatches> = nil): TPromise<TBatches>; overload;

    /// <summary>
    /// Synchronously creates a batch with the specified parameters.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the parameters for the batch creation.</param>
    /// <returns>An instance of TBatch representing the newly created batch.</returns>
    function Create(const ParamProc: TProc<TBatchCreateParams>): TBatch; override;

    /// <summary>
    /// Synchronously retrieves a batch by its ID.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to retrieve.</param>
    /// <returns>An instance of TBatch representing the retrieved batch.</returns>
    function Retrieve(const BatchId: string): TBatch; override;

    /// <summary>
    /// Synchronously cancels an in-progress batch.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to cancel.</param>
    /// <returns>An instance of TBatch representing the cancelled batch.</returns>
    function Cancel(const BatchId: string): TBatch; override;

    /// <summary>
    /// Synchronously lists all batches.
    /// </summary>
    /// <returns>An instance of TBatches containing the list of batches.</returns>
    function List: TBatches; overload; override;

    /// <summary>
    /// Synchronously lists batches with specified parameters for pagination.
    /// </summary>
    /// <param name="ParamProc">A procedure to configure listing parameters such as pagination.</param>
    /// <returns>An instance of TBatches containing the list of batches.</returns>
    function List(const ParamProc: TProc<TUrlPaginationParams>): TBatches; overload; override;
  end;

implementation

uses
  System.DateUtils;

function BatchUnixToUtc(const Value: Int64): string;
begin
  if Value <= 0 then
    Exit(EmptyStr);
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', UnixToDateTime(Value, True));
end;

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

function TBatch.GetCancelledAt: Int64;
begin
  Result := FCancelledAt;
end;

function TBatch.GetCancelledAtAsString: string;
begin
  Result := BatchUnixToUtc(FCancelledAt);
end;

function TBatch.GetCancellingAt: Int64;
begin
  Result := FCancellingAt;
end;

function TBatch.GetCancellingAtAsString: string;
begin
  Result := BatchUnixToUtc(FCancellingAt);
end;

function TBatch.GetCompletedAt: Int64;
begin
  Result := FCompletedAt;
end;

function TBatch.GetCompletedAtAsString: string;
begin
  Result := BatchUnixToUtc(FCompletedAt);
end;

function TBatch.GetCreatedAt: Int64;
begin
  Result := FCreatedAt;
end;

function TBatch.GetCreatedAtAsString: string;
begin
  Result := BatchUnixToUtc(FCreatedAt);
end;

function TBatch.GetExpiredAt: Int64;
begin
  Result := FExpiredAt;
end;

function TBatch.GetExpiredAtAsString: string;
begin
  Result := BatchUnixToUtc(FExpiredAt);
end;

function TBatch.GetExpiresAt: Int64;
begin
  Result := FExpiresAt;
end;

function TBatch.GetExpiresAtAsString: string;
begin
  Result := BatchUnixToUtc(FExpiresAt);
end;

function TBatch.GetFailedAt: Int64;
begin
  Result := FFailedAt;
end;

function TBatch.GetFailedAtAsString: string;
begin
  Result := BatchUnixToUtc(FFailedAt);
end;

function TBatch.GetFinalizingAt: Int64;
begin
  Result := FFinalizingAt;
end;

function TBatch.GetFinalizingAtAsString: string;
begin
  Result := BatchUnixToUtc(FFinalizingAt);
end;

function TBatch.GetInProgressAt: Int64;
begin
  Result := FInProgressAt;
end;

function TBatch.GetInProgressAtAsString: string;
begin
  Result := BatchUnixToUtc(FInProgressAt);
end;

{ TBatchAsynchronousSupport }

procedure TBatchAsynchronousSupport.AsynCancel(const BatchId: string;
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

procedure TBatchAsynchronousSupport.AsynCreate(const ParamProc: TProc<TBatchCreateParams>;
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

procedure TBatchAsynchronousSupport.AsynList(const ParamProc: TProc<TUrlPaginationParams>;
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

procedure TBatchAsynchronousSupport.AsynList(const CallBacks: TFunc<TAsynBatches>);
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

procedure TBatchAsynchronousSupport.AsynRetrieve(const BatchId: string;
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

{ TBatchRoute }

function TBatchRoute.AsyncAwaitCreate(const ParamProc: TProc<TBatchCreateParams>;
  const CallBacks: TFunc<TPromiseBatch>): TPromise<TBatch>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TBatch>(
    procedure(const CallBackParams: TFunc<TAsynBatch>)
    begin
      AsynCreate(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TBatchRoute.AsyncAwaitRetrieve(const BatchId: string;
  const CallBacks: TFunc<TPromiseBatch>): TPromise<TBatch>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TBatch>(
    procedure(const CallBackParams: TFunc<TAsynBatch>)
    begin
      AsynRetrieve(BatchId, CallBackParams);
    end,
    CallBacks);
end;

function TBatchRoute.AsyncAwaitCancel(const BatchId: string;
  const CallBacks: TFunc<TPromiseBatch>): TPromise<TBatch>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TBatch>(
    procedure(const CallBackParams: TFunc<TAsynBatch>)
    begin
      AsynCancel(BatchId, CallBackParams);
    end,
    CallBacks);
end;

function TBatchRoute.AsyncAwaitList(
  const CallBacks: TFunc<TPromiseBatches>): TPromise<TBatches>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TBatches>(
    procedure(const CallBackParams: TFunc<TAsynBatches>)
    begin
      AsynList(CallBackParams);
    end,
    CallBacks);
end;

function TBatchRoute.AsyncAwaitList(const ParamProc: TProc<TUrlPaginationParams>;
  const CallBacks: TFunc<TPromiseBatches>): TPromise<TBatches>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TBatches>(
    procedure(const CallBackParams: TFunc<TAsynBatches>)
    begin
      AsynList(ParamProc, CallBackParams);
    end,
    CallBacks);
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

function TBatchRoute.List(const ParamProc: TProc<TUrlPaginationParams>): TBatches;
begin
  Result := API.Get<TBatches, TUrlPaginationParams>('batches', ParamProc);
end;

function TBatchRoute.Retrieve(const BatchId: string): TBatch;
begin
  Result := API.Get<TBatch>('batches/' + BatchId);
end;

end.
