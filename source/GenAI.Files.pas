unit GenAI.Files;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.Mime,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support;

type
  /// <summary>
  /// Represents a class for constructing URL parameters specifically for file-related operations in the API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure URL parameters such as purpose, limit, order, and pagination.
  /// It is designed to simplify the creation of query strings for file operations like listing files or filtering them by specific criteria.
  /// </remarks>
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

  /// <summary>
  /// Represents a class for constructing parameters for uploading files to the API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure multipart form data for file uploads,
  /// including setting the file path and specifying its purpose.
  /// It is designed to facilitate file uploads for various use cases such as fine-tuning, batch processing, or assistants.
  /// </remarks>
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
  end;

  /// <summary>
  /// Represents a file object in the API, containing metadata and attributes of the uploaded file.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access file metadata such as ID, size, creation timestamp, filename,
  /// purpose, and type. It is used for operations that involve file management within the API.
  /// </remarks>
  TFile = class(TJSONFingerprint)
  private
    FId: string;
    FBytes: Int64;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FFilename: string;
    FObject: string;
    [JsonReflectAttribute(ctString, rtString, TFilesPurposeInterceptor)]
    FPurpose: TFilesPurpose;
  private
    function GetCreatedAtAsString: string;
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
    /// Gets or sets the creation timestamp of the file in Unix seconds.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets the creation timestamp of the file as string.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;
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
  end;

  /// <summary>
  /// Represents a collection of file objects retrieved from the API.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access the metadata of a collection of files,
  /// including the list of files, pagination information, and object type.
  /// It is used for operations that involve listing or retrieving multiple files.
  /// </remarks>
  TFiles = class(TJSONFingerprint)
  private
    FData: TArray<TFile>;
    FObject: string;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('last_id')]
    FLastId: string;
  public
    /// <summary>
    /// An array of file objects included in the collection.
    /// </summary>
    property Data: TArray<TFile> read FData write FData;
    /// <summary>
    /// Gets or sets the type of object, which is always "list".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Indicates whether there are more files to be retrieved beyond the current collection.
    /// </summary>
    property HasMore: Boolean read FHasMore write FHasMore;
    /// <summary>
    /// Gets or sets the ID of the first file in the collection.
    /// </summary>
    property FirstId: string read FFirstId write FFirstId;
    /// <summary>
    /// Gets or sets the ID of the last file in the collection.
    /// </summary>
    property LastId: string read FLastId write FLastId;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the content of a file retrieved from the API.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access the base64-encoded content of a file
  /// and a method to decode it into a readable string. It is used for operations that involve
  /// retrieving and processing the actual content of files.
  /// </remarks>
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
  end;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFile</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFile</c> type extends the <c>TAsynParams&lt;TFile&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFile = TAsynCallBack<TFile>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFiles = TAsynCallBack<TFiles>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynFiles</c> type extends the <c>TAsynParams&lt;TFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynFileContent = TAsynCallBack<TFileContent>;

  /// <summary>
  /// Represents a route for managing file operations in the API.
  /// </summary>
  /// <remarks>
  /// This class provides methods for performing file-related operations, including uploading files,
  /// listing files, retrieving specific file details or content, and deleting files.
  /// It supports both synchronous and asynchronous operations for efficient file management.
  /// </remarks>
  TFilesRoute = class(TGenAIRoute)
    /// <summary>
    /// Performs an asynchronous file upload operation.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the file upload, including the file path and purpose.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines callbacks to handle events like success, failure, or progress during the upload process.
    /// </param>
    procedure AsynUpload(const ParamProc: TProc<TFileUploadParams>; const CallBacks: TFunc<TAsynFile>);
    /// <summary>
    /// Performs an asynchronous operation to list all files.
    /// </summary>
    /// <param name="CallBacks">
    /// A function that defines callbacks to handle events like success, failure, or progress during the listing process.
    /// </param>
    procedure AsynList(const CallBacks: TFunc<TAsynFiles>); overload;
    /// <summary>
    /// Performs an asynchronous operation to list files with specified URL parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the URL parameters for filtering the file list.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines callbacks to handle events like success, failure, or progress during the listing process.
    /// </param>
    procedure AsynList(const ParamProc: TProc<TFileUrlParams>; const CallBacks: TFunc<TAsynFiles>); overload;
    /// <summary>
    /// Performs an asynchronous operation to retrieve details of a specific file.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines callbacks to handle events like success, failure, or progress during the retrieval process.
    /// </param>
    procedure AsynRetrieve(const FileId: string; const CallBacks: TFunc<TAsynFile>);
    /// <summary>
    /// Performs an asynchronous operation to retrieve the content of a specific file.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file whose content is to be retrieved.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines callbacks to handle events like success, failure, or progress during the retrieval process.
    /// </param>
    procedure AsynRetrieveContent(const FileId: string; const CallBacks: TFunc<TAsynFileContent>);
    /// <summary>
    /// Performs an asynchronous operation to delete a specific file.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A function that defines callbacks to handle events like success, failure, or progress during the deletion process.
    /// </param>
    procedure AsynDelete(const FileId: string; const CallBacks: TFunc<TAsynFile>);
    /// <summary>
    /// Uploads a file to the API synchronously.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the parameters for the file upload, including the file path and purpose.
    /// </param>
    /// <returns>
    /// Returns an instance of TFile representing the uploaded file.
    /// </returns>
    function Upload(const ParamProc: TProc<TFileUploadParams>): TFile;
    /// <summary>
    /// Lists all files in the API synchronously.
    /// </summary>
    /// <returns>
    /// Returns an instance of TFiles containing the list of files.
    /// </returns>
    function List: TFiles; overload;
    /// <summary>
    /// Lists files with specified URL parameters synchronously.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure that configures the URL parameters for filtering the file list.
    /// </param>
    /// <returns>
    /// Returns an instance of TFiles containing the filtered list of files.
    /// </returns>
    function List(const ParamProc: TProc<TFileUrlParams>): TFiles; overload;
    /// <summary>
    /// Retrieves details of a specific file synchronously.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file to retrieve.
    /// </param>
    /// <returns>
    /// Returns an instance of TFile containing the file's metadata.
    /// </returns>
    function Retrieve(const FileId: string): TFile;
    /// <summary>
    /// Retrieves the content of a specific file synchronously.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file whose content is to be retrieved.
    /// </param>
    /// <returns>
    /// Returns an instance of TFileContent containing the file's content.
    /// </returns>
    function RetrieveContent(const FileId: string): TFileContent;
    /// <summary>
    /// Deletes a specific file synchronously.
    /// </summary>
    /// <param name="FileId">
    /// The unique identifier of the file to delete.
    /// </param>
    /// <returns>
    /// Returns an instance of TFile representing the deleted file.
    /// </returns>
    function Delete(const FileId: string): TFile;
  end;

implementation

uses
  System.NetEncoding;

{ TFileUploadParams }

function TFileUploadParams.&File(const Value: string): TFileUploadParams;
begin
  AddFile('file', Value);
  Result := Self;
end;

function TFileUploadParams.&File(const Value: TStream;
  const FileName: string): TFileUploadParams;
begin
  {$IF RTLVersion >= 35.0}
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

constructor TFileUploadParams.Create;
begin
  inherited Create(true);
end;

{ TFiles }

destructor TFiles.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
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

procedure TFilesRoute.AsynDelete(const FileId: string;
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
        Result := Self.Delete(FileId);
      end);
  finally
    Free;
  end;
end;

procedure TFilesRoute.AsynList(const CallBacks: TFunc<TAsynFiles>);
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

procedure TFilesRoute.AsynList(const ParamProc: TProc<TFileUrlParams>;
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

procedure TFilesRoute.AsynRetrieve(const FileId: string;
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

procedure TFilesRoute.AsynRetrieveContent(const FileId: string;
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

procedure TFilesRoute.AsynUpload(const ParamProc: TProc<TFileUploadParams>;
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

function TFilesRoute.Delete(const FileId: string): TFile;
begin
  Result := API.Delete<TFile>('files/' + FileId);
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

{ TFile }

function TFile.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

end.
