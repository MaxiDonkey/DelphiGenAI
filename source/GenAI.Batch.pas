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
  GenAI.API.Lists;

type
  /// <summary>
  /// Represents the parameters required to create a batch operation within the OpenAI API.
  /// This class encapsulates the settings and metadata necessary to initiate a batch process, including the
  /// input file, endpoint specification, completion window, and any optional metadata associated with the
  /// batch.
  /// </summary>
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

  /// <summary>
  /// Represents the error details associated with a specific request within a batch operation.
  /// This class holds detailed information about an error, including a machine-readable code, a human-readable message,
  /// and the specific parameter or line that caused the error. This facilitates debugging and error handling in batch processing.
  /// </summary>
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

  /// <summary>
  /// Represents a collection of errors associated with a batch operation.
  /// This class aggregates all errors that occurred during the execution of a batch, facilitating centralized error management
  /// and analysis. Each error is detailed by an instance of TBatchErrorsData, which provides specific error information.
  /// </summary>
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

  /// <summary>
  /// Provides a base class for handling timestamps associated with various stages of a batch's lifecycle.
  /// This class is designed to abstract the common functionality needed to convert timestamp data from Unix time format to human-readable strings.
  /// These timestamps reflect key events in the batch processing timeline, such as creation, processing, and expiration.
  /// </summary>
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

  /// <summary>
  /// Provides a count of requests at various stages of processing within a batch operation.
  /// This class includes properties for tracking the total number of requests, the number of requests that have been completed successfully,
  /// and the number of requests that have failed. This information is crucial for monitoring and managing the progress of batch operations.
  /// </summary>
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

  /// <summary>
  /// Represents a batch operation as managed by the OpenAI API, encapsulating comprehensive details
  /// necessary for managing batch processing tasks. This class includes functionalities such as tracking
  /// the batch's progress, its inputs and outputs, handling errors, and managing lifecycle timestamps.
  /// </summary>
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
    FCreatedAt: TInt64OrNull;
    [JsonNameAttribute('in_progress_at')]
    FInProgressAt: TInt64OrNull;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: TInt64OrNull;
    [JsonNameAttribute('finalizing_at')]
    FFinalizingAt: TInt64OrNull;
    [JsonNameAttribute('completed_at')]
    FCompletedAt: TInt64OrNull;
    [JsonNameAttribute('failed_at')]
    FFailedAt: TInt64OrNull;
    [JsonNameAttribute('expired_at')]
    FExpiredAt: TInt64OrNull;
    [JsonNameAttribute('cancelling_at')]
    FCancellingAt: TInt64OrNull;
    [JsonNameAttribute('cancelled_at')]
    FCancelledAt: TInt64OrNull;
    [JsonNameAttribute('request_counts')]
    FRequestCounts: TBatchRequestCounts;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
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
  /// Provides routes for managing batches within the OpenAI API.
  /// This class offers methods to create, retrieve, cancel, and list batches, facilitating the orchestration of batch operations.
  /// It is designed to support both synchronous and asynchronous execution of these operations, enhancing flexibility and efficiency
  /// in application workflows.
  /// </summary>
  TBatchRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously creates a batch with the specified parameters.
    /// This method uses a callback mechanism to manage the lifecycle of the batch creation operation,
    /// allowing for non-blocking operations within applications.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the parameters for the batch creation.</param>
    /// <param name="CallBacks">A function that returns an instance of TAsynBatch for handling callback events.</param>
    procedure AsynCreate(const ParamProc: TProc<TBatchCreateParams>; const CallBacks: TFunc<TAsynBatch>);

    /// <summary>
    /// Asynchronously retrieves a batch by its ID.
    /// This method uses a callback mechanism to handle the lifecycle of the batch retrieval operation,
    /// facilitating non-blocking retrieval within applications.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to retrieve.</param>
    /// <param name="CallBacks">A function that returns an instance of TAsynBatch for handling callback events.</param>
    procedure AsynRetrieve(const BatchId: string; const CallBacks: TFunc<TAsynBatch>);

    /// <summary>
    /// Asynchronously cancels an in-progress batch.
    /// This method provides a non-blocking way to send a cancellation request for a batch,
    /// using callbacks to manage the operation's lifecycle.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to cancel.</param>
    /// <param name="CallBacks">A function that returns an instance of TAsynBatch for handling callback events.</param>
    procedure AsynCancel(const BatchId: string; const CallBacks: TFunc<TAsynBatch>);

    /// <summary>
    /// Asynchronously lists all batches.
    /// This method uses a callback mechanism to enable non-blocking operations for listing batches,
    /// facilitating efficient data management and retrieval.
    /// </summary>
    /// <param name="CallBacks">A function that returns an instance of TAsynBatches for handling callback events.</param>
    procedure AsynList(const CallBacks: TFunc<TAsynBatches>); overload;

    /// <summary>
    /// Asynchronously lists batches with optional parameters for pagination.
    /// This method allows for non-blocking batch listing operations, using callbacks to handle the lifecycle of the listing request.
    /// </summary>
    /// <param name="ParamProc">An optional procedure to configure listing parameters such as pagination.</param>
    /// <param name="CallBacks">A function that returns an instance of TAsynBatches for handling callback events.</param>
    procedure AsynList(const ParamProc: TProc<TUrlPaginationParams>; const CallBacks: TFunc<TAsynBatches>); overload;

    /// <summary>
    /// Synchronously creates a batch with the specified parameters.
    /// This method provides a direct way to create a batch, blocking until the operation is complete.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the parameters for the batch creation.</param>
    /// <returns>An instance of TBatch representing the newly created batch.</returns>
    function Create(const ParamProc: TProc<TBatchCreateParams>): TBatch;

    /// <summary>
    /// Synchronously retrieves a batch by its ID.
    /// This method provides a direct way to retrieve a batch, blocking until the operation is complete.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to retrieve.</param>
    /// <returns>An instance of TBatch representing the retrieved batch.</returns>
    function Retrieve(const BatchId: string): TBatch;

    /// <summary>
    /// Synchronously cancels an in-progress batch.
    /// This method provides a direct way to send a cancellation request for a batch,
    /// blocking until the operation is confirmed.
    /// </summary>
    /// <param name="BatchId">The unique identifier of the batch to cancel.</param>
    /// <returns>An instance of TBatch representing the cancelled batch.</returns>
    function Cancel(const BatchId: string): TBatch;

    /// <summary>
    /// Synchronously lists all batches.
    /// This method provides a direct way to list batches, blocking until the operation is complete.
    /// </summary>
    /// <returns>An instance of TBatches containing the list of batches.</returns>
    function List: TBatches; overload;

    /// <summary>
    /// Synchronously lists batches with specified parameters for pagination.
    /// This method provides a direct way to list batches with additional control over the retrieval scope,
    /// blocking until the operation is complete.
    /// </summary>
    /// <param name="ParamProc">A procedure to configure listing parameters such as pagination.</param>
    /// <returns>An instance of TBatches containing the list of batches.</returns>
    function List(const ParamProc: TProc<TUrlPaginationParams>): TBatches; overload;
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

function TBatch.GetCancelledAt: Int64;
begin
  Result := TInt64OrNull(FCancelledAt).ToInteger;
end;

function TBatch.GetCancelledAtAsString: string;
begin
  Result := TInt64OrNull(FCancelledAt).ToUtcDateString;
end;

function TBatch.GetCancellingAt: Int64;
begin
  Result := TInt64OrNull(FCancellingAt).ToInteger;
end;

function TBatch.GetCancellingAtAsString: string;
begin
  Result := TInt64OrNull(FCancellingAt).ToUtcDateString;
end;

function TBatch.GetCompletedAt: Int64;
begin
  Result := TInt64OrNull(FCompletedAt).ToInteger;
end;

function TBatch.GetCompletedAtAsString: string;
begin
  Result := TInt64OrNull(FCompletedAt).ToUtcDateString;
end;

function TBatch.GetCreatedAt: Int64;
begin
  Result := TInt64OrNull(FCreatedAt).ToInteger;
end;

function TBatch.GetCreatedAtAsString: string;
begin
  Result := TInt64OrNull(FCreatedAt).ToUtcDateString;
end;

function TBatch.GetExpiredAt: Int64;
begin
  Result := TInt64OrNull(FExpiredAt).ToInteger;
end;

function TBatch.GetExpiredAtAsString: string;
begin
  Result := TInt64OrNull(FExpiredAt).ToUtcDateString;
end;

function TBatch.GetExpiresAt: Int64;
begin
  Result := TInt64OrNull(FExpiresAt).ToInteger;
end;

function TBatch.GetExpiresAtAsString: string;
begin
  Result := TInt64OrNull(FExpiresAt).ToUtcDateString;
end;

function TBatch.GetFailedAt: Int64;
begin
  Result := TInt64OrNull(FFailedAt).ToInteger;
end;

function TBatch.GetFailedAtAsString: string;
begin
  Result := TInt64OrNull(FFailedAt).ToUtcDateString;
end;

function TBatch.GetFinalizingAt: Int64;
begin
  Result := TInt64OrNull(FFinalizingAt).ToInteger;
end;

function TBatch.GetFinalizingAtAsString: string;
begin
  Result := TInt64OrNull(FFinalizingAt).ToUtcDateString;
end;

function TBatch.GetInProgressAt: Int64;
begin
  Result := TInt64OrNull(FInProgressAt).ToInteger;
end;

function TBatch.GetInProgressAtAsString: string;
begin
  Result := TInt64OrNull(FInProgressAt).ToUtcDateString;
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

procedure TBatchRoute.AsynList(const ParamProc: TProc<TUrlPaginationParams>;
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

function TBatchRoute.List(const ParamProc: TProc<TUrlPaginationParams>): TBatches;
begin
  Result := API.Get<TBatches, TUrlPaginationParams>('batches', ParamProc);
end;

function TBatchRoute.Retrieve(const BatchId: string): TBatch;
begin
  Result := API.Get<TBatch>('batches/' + BatchId);
end;

end.
