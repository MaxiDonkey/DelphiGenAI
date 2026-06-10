unit GenAI.Files;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, System.IOUtils,
  System.NetEncoding, REST.Json.Types, REST.JsonReflect, System.Net.Mime,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Async.Promise, GenAI.API.Lists, GenAI.API.Deletion;

type
  TFileUrlParams = class(TUrlParam)
  public
    /// <summary>
    /// Sets the purpose parameter for the URL, defining the intended use of the files to be retrieved or listed.
    /// </summary>
    /// <param name="Value">
    /// A string that specifies the purpose of the file, such as "assistants", "fine-tune", "batch", or "vision".
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUrlParams, allowing for method chaining.
    /// </returns>
    function Purpose(const Value: string): TFileUrlParams; overload;

    /// <summary>
    /// Sets the purpose parameter using the TFilesPurpose enumeration for better type safety.
    /// </summary>
    /// <param name="Value">
    /// A value from the TFilesPurpose enumeration that specifies the purpose of the file.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUrlParams, allowing for method chaining.
    /// </returns>
    function Purpose(const Value: TFilesPurpose): TFileUrlParams; overload;

    /// <summary>
    /// Sets the limit parameter, which defines the maximum number of files to be retrieved in the response.
    /// </summary>
    /// <param name="Value">
    /// An integer specifying the maximum number of files to be returned. The value must be between 1 and 10,000.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUrlParams, allowing for method chaining.
    /// </returns>
    function Limit(const Value: Integer): TFileUrlParams;

    /// <summary>
    /// Sets the order parameter, which defines the sort order for the file listing based on the created_at timestamp.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the sort order. Use "asc" for ascending order or "desc" for descending order.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUrlParams, allowing for method chaining.
    /// </returns>
    function Order(const Value: string): TFileUrlParams;

    /// <summary>
    /// Sets the after parameter, which acts as a cursor for pagination to fetch the next page of files.
    /// </summary>
    /// <param name="Value">
    /// A string specifying the ID of the last file from the previous page to start fetching the next page.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUrlParams, allowing for method chaining.
    /// </returns>
    function After(const Value: string): TFileUrlParams;
  end;

  TFileUploadParams = class(TMultipartFormData)
  public
    constructor Create; reintroduce;

    /// <summary>
    /// Adds a file to the form data for uploading to the API.
    /// </summary>
    /// <param name="Value">
    /// A string representing the path to the file to be uploaded.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUploadParams, allowing for method chaining.
    /// </returns>
    function &File(const Value: string): TFileUploadParams; overload;

    /// <summary>
    /// Adds a file to the form data for uploading to the API.
    /// </summary>
    /// <param name="Value">
    /// A <c>TStream</c> object containing the file data.
    /// </param>
    /// <param name="FileName">
    /// A string representing the file path for the image, used for reference purposes.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUploadParams, allowing for method chaining.
    /// </returns>
    function &File(const Value: TStream; const FileName: string): TFileUploadParams; overload;

    /// <summary>
    /// Sets the purpose parameter for the uploaded file, defining its intended use in the API.
    /// </summary>
    /// <param name="Value">
    /// A string that specifies the purpose of the file, such as "assistants", "fine-tune", "batch", or "vision".
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUploadParams, allowing for method chaining.
    /// </returns>
    function Purpose(const Value: string): TFileUploadParams; overload;

    /// <summary>
    /// Sets the purpose parameter using the TFilesPurpose enumeration for better type safety.
    /// </summary>
    /// <param name="Value">
    /// A value from the TFilesPurpose enumeration that specifies the purpose of the file.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUploadParams, allowing for method chaining.
    /// </returns>
    function Purpose(const Value: TFilesPurpose): TFileUploadParams; overload;

    /// <summary>
    /// Sets the expiration policy for the uploaded file using the default anchor ("created_at").
    /// </summary>
    /// <param name="Seconds">
    /// The number of seconds after the anchor time that the file will expire. Must be between 3600 (1 hour)
    /// and 2592000 (30 days).
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUploadParams, allowing for method chaining.
    /// </returns>
    function ExpiresAfter(const Seconds: Integer): TFileUploadParams; overload;

    /// <summary>
    /// Sets the expiration policy for the uploaded file.
    /// </summary>
    /// <param name="Anchor">
    /// The anchor timestamp after which the expiration policy applies. Currently only "created_at" is supported.
    /// </param>
    /// <param name="Seconds">
    /// The number of seconds after the anchor time that the file will expire. Must be between 3600 (1 hour)
    /// and 2592000 (30 days).
    /// </param>
    /// <returns>
    /// Returns an instance of TFileUploadParams, allowing for method chaining.
    /// </returns>
    function ExpiresAfter(const Anchor: string; const Seconds: Integer): TFileUploadParams; overload;
  end;

  TFile = class(TJSONFingerprint)
  private
    FId: string;
    FBytes: Int64;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    FFilename: string;
    FObject: string;
    [JsonReflectAttribute(ctString, rtString, TFilesPurposeInterceptor)]
    FPurpose: TFilesPurpose;
    FStatus: string;
    [JsonNameAttribute('status_details')]
    FStatusDetails: string;
  private
    function GetCreatedAtAsString: string;
    function GetCreatedAt: Int64;
    function GetExpiresAtAsString: string;
    function GetExpiresAt: Int64;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the file.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Gets or sets the size of the file in bytes.
    /// </summary>
    property Bytes: Int64 read FBytes write FBytes;

    /// <summary>
    /// Gets the creation timestamp of the file in Unix seconds.
    /// </summary>
    property CreatedAt: Int64 read GetCreatedAt;

    /// <summary>
    /// Gets the creation timestamp of the file as string.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;

    /// <summary>
    /// Gets the Unix timestamp (in seconds) for when the file will expire.
    /// </summary>
    property ExpiresAt: Int64 read GetExpiresAt;

    /// <summary>
    /// Gets the expiration timestamp of the file as string.
    /// </summary>
    property ExpiresAtAsString: string read GetExpiresAtAsString;

    /// <summary>
    /// Gets or sets the name of the file.
    /// </summary>
    property Filename: string read FFilename write FFilename;

    /// <summary>
    /// Gets or sets the object type, which is always "file".
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Gets or sets the purpose of the file, indicating its intended use.
    /// </summary>
    property Purpose: TFilesPurpose read FPurpose write FPurpose;

    /// <summary>
    /// Deprecated. The current status of the file, which can be either uploaded, processed, or error.
    /// </summary>
    property Status: string read FStatus write FStatus;

    /// <summary>
    /// Deprecated. For details on why a fine-tuning training file failed validation, see the error field
    /// on fine_tuning.job.
    /// </summary>
    property StatusDetails: string read FStatusDetails write FStatusDetails;
  end;

  TFileContent = class(TJSONFingerprint)
  private
    FBase64: string;
    /// <summary>
    /// Decodes the base64-encoded content and returns it as a string.
    /// </summary>
    /// <returns>
    /// A string representing the decoded content of the file.
    /// </returns>
    function GetContent: string;
    property Base64: string read FBase64 write FBase64;
  public
    /// <summary>
    /// Gets the decoded content of the file as a string.
    /// </summary>
    property Content: string read GetContent;

    /// <summary>
    /// Saves the decoded file bytes without passing through a text encoding.
    /// </summary>
    procedure SaveToFile(const FileName: string);
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TFile</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFile</c> type extends the <c>TAsynParams&lt;TFile&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynFile = TAsynCallBack<TFile>;

  /// <summary>
  /// Represents a promise-based callback for handling asynchronous file operations.
  /// </summary>
  /// <remarks>
  /// This type alias specializes <c>TPromiseCallBack</c> with <c>TFile</c>,
  /// providing a promise-style mechanism to process the result of file-related API requests.
  /// It encapsulates both success and error handling for operations that return a <c>TFile</c> response.
  /// </remarks>
  TPromiseFile = TPromiseCallBack<TFile>;

  /// <summary>
  /// Represents a collection of file objects retrieved from the API.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access the metadata of a collection of files,
  /// including the list of files, pagination information, and object type.
  /// It is used for operations that involve listing or retrieving multiple files.
  /// </remarks>
  TFiles = TAdvancedList<TFile>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynFiles = TAsynCallBack<TFiles>;

  /// <summary>
  /// Represents a promise-based callback for handling asynchronous operations on collections of files.
  /// </summary>
  /// <remarks>
  /// This type alias specializes <c>TPromiseCallBack</c> with <c>TFiles</c>,
  /// providing a promise-style mechanism to process the result of API requests that return multiple file objects.
  /// It encapsulates both success and error handling for operations that return a <c>TFiles</c> response.
  /// </remarks>
  TPromiseFiles = TPromiseCallBack<TFiles>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynFileContent = TAsynCallBack<TFileContent>;

  TFilesAbstractSupport = class(TGenAIRoute)
  protected
    function Upload(const ParamProc: TProc<TFileUploadParams>): TFile; virtual; abstract;
    function List: TFiles; overload; virtual; abstract;
    function List(const ParamProc: TProc<TFileUrlParams>): TFiles; overload; virtual; abstract;
    function Retrieve(const FileId: string): TFile; virtual; abstract;
    function RetrieveContent(const FileId: string): TFileContent; virtual; abstract;
    function Delete(const FileId: string): TDeletion; virtual; abstract;
  end;

  TFilesAsynchronousSupport = class(TFilesAbstractSupport)
  public
    procedure AsynUpload(const ParamProc: TProc<TFileUploadParams>; const CallBacks: TFunc<TAsynFile>);
    procedure AsynList(const CallBacks: TFunc<TAsynFiles>); overload;
    procedure AsynList(const ParamProc: TProc<TFileUrlParams>; const CallBacks: TFunc<TAsynFiles>); overload;
    procedure AsynRetrieve(const FileId: string; const CallBacks: TFunc<TAsynFile>);
    procedure AsynRetrieveContent(const FileId: string; const CallBacks: TFunc<TAsynFileContent>);
    procedure AsynDelete(const FileId: string; const CallBacks: TFunc<TAsynDeletion>);
  end;

  TFilesRoute = class(TFilesAsynchronousSupport)
  public
    /// <summary>
    /// Initiates an asynchronous file upload and returns a promise for the uploaded file.
    /// </summary>
    /// <remarks>
    /// The <paramref name="ParamProc"/> procedure configures the multipart form data used for the upload (file path, purpose, etc.).
    /// The <paramref name="CallBacks"/> function defines event handlers for upload progress, success, and error.
    /// Once the upload completes successfully, the returned <see cref="TPromise{TFile}"/> is fulfilled with the resulting <c>TFile</c> instance.
    /// If an error occurs during upload, the promise is rejected with the corresponding exception.
    /// </remarks>
    /// <param name="ParamProc">
    /// A procedure that receives a <c>TFileUploadParams</c> instance for configuring the file path and purpose.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <see cref="TPromiseFile"/> (i.e., <c>TPromiseCallBack&lt;TFile&gt;</c>),
    /// which sets up the <c>Sender</c>, <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c> event handlers.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TFile&gt;</c> that is fulfilled when the upload succeeds, providing the uploaded <c>TFile</c> object,
    /// or rejected if the upload fails.
    /// </returns>
    function AsyncAwaitUpload(const ParamProc: TProc<TFileUploadParams>;
      const CallBacks: TFunc<TPromiseFile> = nil): TPromise<TFile>;

    /// <summary>
    /// Initiates an asynchronous request to list all files and returns a promise for the file collection.
    /// </summary>
    /// <remarks>
    /// The <paramref name="CallBacks"/> function defines event handlers for start, success, and error conditions.
    /// Once the list operation completes successfully, the returned <see cref="TPromise{TFiles}"/> is fulfilled with the retrieved <c>TFiles</c> collection.
    /// If an error occurs during the listing process, the promise is rejected with the corresponding exception.
    /// </remarks>
    /// <param name="CallBacks">
    /// A function that returns a <see cref="TPromiseFiles"/> (i.e., <c>TPromiseCallBack&lt;TFiles&gt;</c>),
    /// which sets up the <c>Sender</c>, <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c> event handlers.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TFiles&gt;</c> that is fulfilled when the list operation succeeds, providing the <c>TFiles</c> collection,
    /// or rejected if the operation fails.
    /// </returns>
    function AsyncAwaitList(const CallBacks: TFunc<TPromiseFiles> = nil): TPromise<TFiles>; overload;

    /// <summary>
    /// Initiates an asynchronous request to list files with specified URL parameters and returns a promise for the file collection.
    /// </summary>
    /// <remarks>
    /// The <paramref name="ParamProc"/> procedure configures URL parameters (such as purpose, limit, order, pagination) for filtering the file listing.
    /// The <paramref name="CallBacks"/> function defines event handlers for start, success, and error conditions.
    /// Once the list operation completes successfully, the returned <see cref="TPromise{TFiles}"/> is fulfilled with the retrieved <c>TFiles</c> collection.
    /// If an error occurs during the listing process, the promise is rejected with the corresponding exception.
    /// </remarks>
    /// <param name="ParamProc">
    /// A procedure that receives a <c>TFileUrlParams</c> instance for configuring URL parameters (e.g., purpose, limit, order, after).
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <see cref="TPromiseFiles"/> (i.e., <c>TPromiseCallBack&lt;TFiles&gt;</c>),
    /// which sets up the <c>Sender</c>, <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c> event handlers.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TFiles&gt;</c> that is fulfilled when the list operation succeeds, providing the <c>TFiles</c> collection,
    /// or rejected if the operation fails.
    /// </returns>
    function AsyncAwaitList(const ParamProc: TProc<TFileUrlParams>;
      const CallBacks: TFunc<TPromiseFiles> = nil): TPromise<TFiles>; overload;

    /// <summary>
    /// Initiates an asynchronous request to retrieve details of a specific file and returns a promise for the file.
    /// </summary>
    /// <remarks>
    /// The <paramref name="FileId"/> parameter specifies the unique identifier of the file to retrieve.
    /// The <paramref name="CallBacks"/> function defines event handlers for start, success, and error conditions.
    /// Once the retrieval completes successfully, the returned <see cref="TPromise{TFile}"/> is fulfilled with the retrieved <c>TFile</c> instance.
    /// If an error occurs during retrieval, the promise is rejected with the corresponding exception.
    /// </remarks>
    /// <param name="FileId">
    /// A string representing the unique identifier of the file to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <see cref="TPromiseFile"/> (i.e., <c>TPromiseCallBack&lt;TFile&gt;</c>),
    /// which sets up the <c>Sender</c>, <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c> event handlers.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TFile&gt;</c> that is fulfilled when the retrieval succeeds, providing the retrieved <c>TFile</c> object,
    /// or rejected if the operation fails.
    /// </returns>
    function AsyncAwaitRetrieve(const FileId: string;
      const CallBacks: TFunc<TPromiseFile> = nil): TPromise<TFile>;

    /// <summary>
    /// Initiates an asynchronous request to delete a specified file and returns a promise for the deletion result.
    /// </summary>
    /// <remarks>
    /// The <paramref name="FileId"/> parameter specifies the unique identifier of the file to delete.
    /// The <paramref name="CallBacks"/> function defines event handlers for start, success, and error conditions.
    /// Once the deletion completes successfully, the returned <see cref="TPromise{TDeletion}"/> is fulfilled with a <c>TDeletion</c> instance.
    /// If an error occurs during deletion, the promise is rejected with the corresponding exception.
    /// </remarks>
    /// <param name="FileId">
    /// A string representing the unique identifier of the file to be deleted.
    /// </param>
    /// <param name="CallBacks">
    /// A function that returns a <see cref="TPromiseDeletion"/> (i.e., <c>TPromiseCallBack&lt;TDeletion&gt;</c>),
    /// which sets up the <c>Sender</c>, <c>OnStart</c>, <c>OnSuccess</c>, and <c>OnError</c> event handlers.
    /// </param>
    /// <returns>
    /// A <c>TPromise&lt;TDeletion&gt;</c> that is fulfilled when the deletion succeeds, providing the <c>TDeletion</c> result,
    /// or rejected if the operation fails.
    /// </returns>
    function AsyncAwaitDelete(const FileId: string;
      const CallBacks: TFunc<TPromiseDeletion> = nil): TPromise<TDeletion>;

    /// <summary>
    /// Uploads a file to the API synchronously.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the file upload, including the file path and purpose.
    /// </param>
    /// <returns>
    /// Returns an instance of TFile representing the uploaded file.
    /// </returns>
    function Upload(const ParamProc: TProc<TFileUploadParams>): TFile; override;

    /// <summary>
    /// Lists all files in the API synchronously.
    /// </summary>
    /// <returns>
    /// Returns an instance of TFiles containing the list of files.
    /// </returns>
    function List: TFiles; overload; override;

    /// <summary>
    /// Lists files with specified URL parameters synchronously.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the URL parameters for filtering the file list.
    /// </param>
    /// <returns>
    /// Returns an instance of TFiles containing the filtered list of files.
    /// </returns>
    function List(const ParamProc: TProc<TFileUrlParams>): TFiles; overload; override;

    /// <summary>
    /// Retrieves details of a specific file synchronously.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file to retrieve.
    /// </param>
    /// <returns>
    /// Returns an instance of TFile containing the file's metadata.
    /// </returns>
    function Retrieve(const FileId: string): TFile; override;

    /// <summary>
    /// Retrieves the content of a specific file synchronously.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file whose content is to be retrieved.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileContent containing the file's content.
    /// </returns>
    function RetrieveContent(const FileId: string): TFileContent; override;

    /// <summary>
    /// Deletes a specific file synchronously.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file to delete.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileDeletion representing the deleted file.
    /// </returns>
    function Delete(const FileId: string): TDeletion; override;
  end;

implementation

uses
  System.DateUtils;

{ TFileUploadParams }

function TFileUploadParams.&File(const Value: string): TFileUploadParams;
begin
  AddFile('file', Value);
  Result := Self;
end;

function TFileUploadParams.&File(const Value: TStream;
  const FileName: string): TFileUploadParams;
begin
  {$IF RTLVersion > 35.0}
    AddStream('file', Value, True, FileName);
  {$ELSE}
    AddStream('file', Value, FileName);
  {$ENDIF}
  Result := Self;
end;

function TFileUploadParams.Purpose(
  const Value: TFilesPurpose): TFileUploadParams;
begin
  AddField('purpose', Value.ToString);
  Result := Self;
end;

function TFileUploadParams.Purpose(const Value: string): TFileUploadParams;
begin
  AddField('purpose', TFilesPurpose.Create(Value).ToString);
  Result := Self;
end;

function TFileUploadParams.ExpiresAfter(const Seconds: Integer): TFileUploadParams;
begin
  Result := ExpiresAfter('created_at', Seconds);
end;

function TFileUploadParams.ExpiresAfter(const Anchor: string;
  const Seconds: Integer): TFileUploadParams;
begin
  AddField('expires_after[anchor]', Anchor);
  AddField('expires_after[seconds]', Seconds.ToString);
  Result := Self;
end;

constructor TFileUploadParams.Create;
begin
  inherited Create(true);
end;

{ TFileUrlParams }

function TFileUrlParams.After(const Value: string): TFileUrlParams;
begin
  Result := TFileUrlParams(Add('after', Value));
end;

function TFileUrlParams.Limit(const Value: Integer): TFileUrlParams;
begin
  Result := TFileUrlParams(Add('limit', Value));
end;

function TFileUrlParams.Order(const Value: string): TFileUrlParams;
begin
  Result := TFileUrlParams(Add('order', Value));
end;

function TFileUrlParams.Purpose(const Value: TFilesPurpose): TFileUrlParams;
begin
  Result := TFileUrlParams(Add('purpose', Value.ToString));
end;

function TFileUrlParams.Purpose(const Value: string): TFileUrlParams;
begin
  Result := TFileUrlParams(Add('purpose', TFilesPurpose.Create(Value).ToString));
end;

{ TFilesRoute }

function TFilesRoute.AsyncAwaitDelete(const FileId: string;
  const CallBacks: TFunc<TPromiseDeletion>): TPromise<TDeletion>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TDeletion>(
    procedure(const CallBackParams: TFunc<TAsynDeletion>)
    begin
      AsynDelete(FileId, CallBackParams);
    end,
    CallBacks);
end;

function TFilesRoute.AsyncAwaitList(
  const CallBacks: TFunc<TPromiseFiles>): TPromise<TFiles>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TFiles>(
    procedure(const CallBackParams: TFunc<TAsynFiles>)
    begin
      AsynList(CallBackParams);
    end,
    CallBacks);
end;

function TFilesRoute.AsyncAwaitList(const ParamProc: TProc<TFileUrlParams>;
  const CallBacks: TFunc<TPromiseFiles>): TPromise<TFiles>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TFiles>(
    procedure(const CallBackParams: TFunc<TAsynFiles>)
    begin
      AsynList(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

function TFilesRoute.AsyncAwaitRetrieve(const FileId: string;
  const CallBacks: TFunc<TPromiseFile>): TPromise<TFile>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TFile>(
    procedure(const CallBackParams: TFunc<TAsynFile>)
    begin
      AsynRetrieve(FileId, CallBackParams);
    end,
    CallBacks);
end;

function TFilesRoute.AsyncAwaitUpload(const ParamProc: TProc<TFileUploadParams>;
  const CallBacks: TFunc<TPromiseFile>): TPromise<TFile>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TFile>(
    procedure(const CallBackParams: TFunc<TAsynFile>)
    begin
      AsynUpload(ParamProc, CallBackParams);
    end,
    CallBacks);
end;

{ TFilesAsynchronousSupport }

procedure TFilesAsynchronousSupport.AsynDelete(const FileId: string;
  const CallBacks: TFunc<TAsynDeletion>);
begin
  with TAsynCallBackExec<TAsynDeletion, TDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TDeletion
      begin
        Result := Self.Delete(FileId);
      end);
  finally
    Free;
  end;
end;

procedure TFilesAsynchronousSupport.AsynList(const CallBacks: TFunc<TAsynFiles>);
begin
  with TAsynCallBackExec<TAsynFiles, TFiles>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFiles
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TFilesAsynchronousSupport.AsynList(const ParamProc: TProc<TFileUrlParams>;
  const CallBacks: TFunc<TAsynFiles>);
begin
  with TAsynCallBackExec<TAsynFiles, TFiles>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFiles
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TFilesAsynchronousSupport.AsynRetrieve(const FileId: string;
  const CallBacks: TFunc<TAsynFile>);
begin
  with TAsynCallBackExec<TAsynFile, TFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFile
      begin
        Result := Self.Retrieve(FileId);
      end);
  finally
    Free;
  end;
end;

procedure TFilesAsynchronousSupport.AsynRetrieveContent(const FileId: string;
  const CallBacks: TFunc<TAsynFileContent>);
begin
  with TAsynCallBackExec<TAsynFileContent, TFileContent>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFileContent
      begin
        Result := Self.RetrieveContent(FileId);
      end);
  finally
    Free;
  end;
end;

procedure TFilesAsynchronousSupport.AsynUpload(const ParamProc: TProc<TFileUploadParams>;
  const CallBacks: TFunc<TAsynFile>);
begin
  with TAsynCallBackExec<TAsynFile, TFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TFile
      begin
        Result := Self.Upload(ParamProc);
      end);
  finally
    Free;
  end;
end;

{ TFilesRoute }

function TFilesRoute.Delete(const FileId: string): TDeletion;
begin
  Result := API.Delete<TDeletion>('files/' + FileId);
end;

function TFilesRoute.List: TFiles;
begin
  Result := API.Get<TFiles>('files');
end;

function TFilesRoute.List(const ParamProc: TProc<TFileUrlParams>): TFiles;
begin
  Result := API.Get<TFiles, TFileUrlParams>('files', ParamProc);
end;

function TFilesRoute.Retrieve(const FileId: string): TFile;
begin
  Result := API.Get<TFile>('files/' + FileId);
end;

function TFilesRoute.RetrieveContent(const FileId: string): TFileContent;
begin
  Result := API.GetFile<TFileContent>('files/' + FileId + '/content', 'base64');
end;

function TFilesRoute.Upload(const ParamProc: TProc<TFileUploadParams>): TFile;
begin
  Result := API.PostForm<TFile, TFileUploadParams>('files', ParamProc);
end;

{ TFileContent }

function TFileContent.GetContent: string;
begin
  Result :=  TNetEncoding.Base64.Decode(Base64);
end;

procedure TFileContent.SaveToFile(const FileName: string);
begin
  System.IOUtils.TFile.WriteAllBytes(
    FileName,
    TNetEncoding.Base64.DecodeStringToBytes(Base64));
end;

{ TFile }

function TFile.GetCreatedAt: Int64;
begin
  Result := FCreatedAt;
end;

function TFile.GetCreatedAtAsString: string;
begin
  if FCreatedAt <= 0 then
    Exit(EmptyStr);
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', UnixToDateTime(FCreatedAt, True));
end;

function TFile.GetExpiresAt: Int64;
begin
  Result := FExpiresAt;
end;

function TFile.GetExpiresAtAsString: string;
begin
  if FExpiresAt <= 0 then
    Exit(EmptyStr);
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', UnixToDateTime(FExpiresAt, True));
end;

end.
