unit GenAI.Uploads;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.Mime,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Files;

type
  /// <summary>
  /// Represents the parameters required for creating an upload object in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure the necessary fields for initiating an upload.
  /// An upload is used to prepare a file for adding multiple parts and eventually creating
  /// a File object that can be utilized within the platform.
  /// </remarks>
  TUploadCreateParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the filename of the file to be uploaded.
    /// </summary>
    /// <param name="Value">
    /// A string that specifies the name of the file.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TUploadCreateParams</c> with the filename set.
    /// </returns>
    function Filename(const Value: string): TUploadCreateParams;
    /// <summary>
    /// Sets the purpose of the uploaded file. This is a required field to define
    /// the intent or use of the file being uploaded.
    /// </summary>
    /// <param name="Value">
    /// A string that specifies the purpose of the file (e.g., "fine-tune" or other supported purposes).
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TUploadCreateParams</c> with the purpose set.
    /// </returns>
    function Purpose(const Value: string): TUploadCreateParams; overload;
    /// <summary>
    /// Sets the purpose of the uploaded file using an enumerated value. This method
    /// allows specifying the purpose from predefined purposes in the <c>TFilesPurpose</c> enumeration.
    /// </summary>
    /// <param name="Value">
    /// A <c>TFilesPurpose</c> enumeration value that specifies the purpose of the file.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TUploadCreateParams</c> with the purpose set.
    /// </returns>
    function Purpose(const Value: TFilesPurpose): TUploadCreateParams; overload;
    /// <summary>
    /// Sets the total size of the file in bytes. This value is required
    /// to ensure the uploaded parts match the intended file size.
    /// </summary>
    /// <param name="Value">
    /// An integer value representing the total size of the file in bytes.
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TUploadCreateParams</c> with the file size set.
    /// </returns>
    function Bytes(const Value: Int64): TUploadCreateParams;
    /// <summary>
    /// Sets the MIME type of the file to be uploaded. The MIME type must
    /// correspond to the supported types for the specified file purpose.
    /// </summary>
    /// <param name="Value">
    /// A string representing the MIME type of the file (e.g., "application/json").
    /// </param>
    /// <returns>
    /// Returns an instance of <c>TUploadCreateParams</c> with the MIME type set.
    /// </returns>
    function MimeType(const Value: string): TUploadCreateParams;
  end;

  /// <summary>
  /// Represents parameters for creating an upload part in a multipart form-data request.
  /// </summary>
  /// <remarks>
  /// This class provides methods to add data to the form-data structure, allowing the uploading
  /// of individual parts (chunks) of a file. It is specifically designed for use with APIs
  /// that handle large file uploads by splitting the file into smaller parts.
  /// </remarks>
  TUploadPartParams = class(TMultipartFormData)
  public
    constructor Create; reintroduce;
    /// <summary>
    /// Adds a file to the form-data as a part of the upload.
    /// </summary>
    /// <param name="Value">
    /// The path to the file that will be added as a data chunk for the upload.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TUploadPartParams</c> to allow method chaining.
    /// </returns>
    function Data(const Value: string): TUploadPartParams; overload;
    /// <summary>
    /// Adds a stream to the form-data as a part of the upload.
    /// </summary>
    /// <param name="Value">
    /// A <c>TStream</c> object that represents the data chunk to upload.
    /// </param>
    /// <param name="FileName">
    /// The name of the file associated with the stream data.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TUploadPartParams</c> to allow method chaining.
    /// </returns>
    /// <remarks>
    /// This method allows the uploading of data directly from a stream, which is useful
    /// for scenarios where the data is not stored in a file or needs to be processed dynamically.
    /// </remarks>
    function Data(const Value: TStream; const FileName: string): TUploadPartParams; overload;
  end;

  /// <summary>
  /// Represents parameters for completing an upload by specifying the order of parts and optional checksum validation.
  /// </summary>
  /// <remarks>
  /// This class provides methods to configure the finalization of a multipart upload by
  /// specifying the part IDs in the correct order and verifying the file's integrity using an MD5 checksum.
  /// </remarks>
  TUploadCompleteParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the list of part IDs in the order they should be assembled to complete the upload.
    /// </summary>
    /// <param name="Value">
    /// An array of strings representing the IDs of the uploaded parts, in the correct order for assembly.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TUploadCompleteParams</c> to allow method chaining.
    /// </returns>
    function PartIds(const Value: TArray<string>): TUploadCompleteParams;
    /// <summary>
    /// Sets the MD5 checksum for the uploaded file to ensure data integrity.
    /// </summary>
    /// <param name="Value">
    /// A string representing the MD5 checksum of the file contents. This value is optional
    /// and is used to verify that the assembled file matches the expected content.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TUploadCompleteParams</c> to allow method chaining.
    /// </returns>
    function Md5(const Value: string): TUploadCompleteParams;
  end;

  /// <summary>
  /// Represents the metadata and details of an upload, including its status, purpose, and associated file.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access information about an upload object, such as its ID,
  /// filename, size, purpose, status, and expiration time. It also includes a reference to the
  /// associated file object once the upload is completed.
  /// </remarks>
  TUpload = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FFilename: string;
    FBytes: Int64;
    [JsonReflectAttribute(ctString, rtString, TFilesPurposeInterceptor)]
    FPurpose: TFilesPurpose;
    FStatus: string;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    FObject: string;
    FFile: TFile;
  private
    function GetCreatedAtAsString: string;
    function GetExpiresAtAsString: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the upload.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) indicating when the upload was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets the Unix timestamp a a string, indicating when the upload was created.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the name of the file being uploaded.
    /// </summary>
    property Filename: string read FFilename write FFilename;
    /// <summary>
    /// Gets or sets the intended size of the file being uploaded, in bytes.
    /// </summary>
    property Bytes: Int64 read FBytes write FBytes;
    /// <summary>
    /// Gets or sets the purpose of the upload. This indicates the intended usage of the uploaded file.
    /// </summary>
    property Purpose: TFilesPurpose read FPurpose write FPurpose;
    /// <summary>
    /// Gets or sets the current status of the upload (e.g., "pending", "completed", or "cancelled").
    /// </summary>
    property Status: string read FStatus write FStatus;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) indicating when the upload will expire.
    /// </summary>
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;
    /// <summary>
    /// Gets the Unix timestamp as a string, indicating when the upload will expire.
    /// </summary>
    property ExpiresAtAsString: string read GetExpiresAtAsString;
    /// <summary>
    /// Gets or sets the object type, which is always "upload".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the associated file object created after the upload is completed.
    /// </summary>
    property &File: TFile read FFile write FFile;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents metadata and details of a single upload part, including its ID, creation timestamp, and associated upload.
  /// </summary>
  /// <remarks>
  /// This class provides properties to access information about an upload part, such as its unique ID,
  /// creation time, and the ID of the parent upload to which it belongs.
  /// </remarks>
  TUploadPart = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('upload_id')]
    FUploadId: string;
    FObject: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the upload part.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) indicating when the upload part was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets or sets the ID of the upload to which this part belongs.
    /// </summary>
    property UploadId: string read FUploadId write FUploadId;
    /// <summary>
    /// Gets or sets the object type, which is always "upload.part".
    /// </summary>
    property &Object: string read FObject write FObject;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TUpload</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynUpload</c> type extends the <c>TAsynParams&lt;TUpload&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynUpload = TAsynCallBack<TUpload>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TUploadPart</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynUploadPart</c> type extends the <c>TAsynParams&lt;TUploadPart&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynUploadPart = TAsynCallBack<TUploadPart>;

  /// <summary>
  /// Manages routes for handling file uploads, including creating uploads, adding parts, completing uploads, and canceling uploads.
  /// </summary>
  /// <remarks>
  /// This class provides methods to interact with the upload API endpoints. It supports asynchronous and synchronous
  /// operations for creating an upload, adding parts to it, completing the upload, and canceling an upload.
  /// </remarks>
  TUploadsRoute = class(TGenAIRoute)
    /// <summary>
    /// Initiates an asynchronous operation to create a new upload.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the upload creation parameters, such as filename, purpose, size, and MIME type.
    /// </param>
    /// <param name="CallBacks">
    /// A function that specifies the callbacks for the asynchronous operation.
    /// </param>
    procedure AsynCreate(const ParamProc: TProc<TUploadCreateParams>; const CallBacks: TFunc<TAsynUpload>);
    /// <summary>
    /// Initiates an asynchronous operation to add a part to an existing upload.
    /// </summary>
    /// <param name="UploadId">
    /// The ID of the upload to which the part will be added.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the upload part parameters, such as the data chunk.
    /// </param>
    /// <param name="CallBacks">
    /// A function that specifies the callbacks for the asynchronous operation.
    /// </param>
    procedure AsynAddPart(const UploadId: string; const ParamProc: TProc<TUploadPartParams>;
      const CallBacks: TFunc<TAsynUploadPart>);
    /// <summary>
    /// Initiates an asynchronous operation to complete an upload.
    /// </summary>
    /// <param name="UploadId">
    /// The ID of the upload to complete.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the parameters for completing the upload, such as the part order and optional MD5 checksum.
    /// </param>
    /// <param name="CallBacks">
    /// A function that specifies the callbacks for the asynchronous operation.
    /// </param>
    procedure AsynComplete(const UploadId: string; const ParamProc: TProc<TUploadCompleteParams>;
      const CallBacks: TFunc<TAsynUpload>);
    /// <summary>
    /// Initiates an asynchronous operation to cancel an upload.
    /// </summary>
    /// <param name="UploadId">
    /// The ID of the upload to cancel.
    /// </param>
    /// <param name="CallBacks">
    /// A function that specifies the callbacks for the asynchronous operation.
    /// </param>
    procedure AsynCancel(const UploadId: string; const CallBacks: TFunc<TAsynUpload>);
    /// <summary>
    /// Creates a new upload synchronously.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the upload creation parameters, such as filename, purpose, size, and MIME type.
    /// </param>
    /// <returns>
    /// A <c>TUpload</c> object containing the metadata of the created upload.
    /// </returns>
    function Create(const ParamProc: TProc<TUploadCreateParams>): TUpload;
    /// <summary>
    /// Adds a part to an existing upload synchronously.
    /// </summary>
    /// <param name="UploadId">
    /// The ID of the upload to which the part will be added.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the upload part parameters, such as the data chunk.
    /// </param>
    /// <returns>
    /// A <c>TUploadPart</c> object containing the metadata of the added part.
    /// </returns>
    function AddPart(const UploadId: string; const ParamProc: TProc<TUploadPartParams>): TUploadPart;
    /// <summary>
    /// Completes an upload synchronously.
    /// </summary>
    /// <param name="UploadId">
    /// The ID of the upload to complete.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the parameters for completing the upload, such as the part order and optional MD5 checksum.
    /// </param>
    /// <returns>
    /// A <c>TUpload</c> object containing the metadata of the completed upload.
    /// </returns>
    function Complete(const UploadId: string; const ParamProc: TProc<TUploadCompleteParams>): TUpload;
    /// <summary>
    /// Cancels an upload synchronously.
    /// </summary>
    /// <param name="UploadId">
    /// The ID of the upload to cancel.
    /// </param>
    /// <returns>
    /// A <c>TUpload</c> object containing the metadata of the canceled upload.
    /// </returns>
    function Cancel(const UploadId: string): TUpload;
  end;

implementation

{ TUploadCreateParams }

function TUploadCreateParams.Bytes(const Value: Int64): TUploadCreateParams;
begin
  Result := TUploadCreateParams(Add('bytes', Value));
end;

function TUploadCreateParams.Filename(
  const Value: string): TUploadCreateParams;
begin
  Result := TUploadCreateParams(Add('filename', Value));
end;

function TUploadCreateParams.MimeType(
  const Value: string): TUploadCreateParams;
begin
  Result := TUploadCreateParams(Add('mime_type', Value));
end;

function TUploadCreateParams.Purpose(
  const Value: string): TUploadCreateParams;
begin
  Result := TUploadCreateParams(Add('purpose', TFilesPurpose.Create(Value).ToString));
end;

function TUploadCreateParams.Purpose(
  const Value: TFilesPurpose): TUploadCreateParams;
begin
  Result := TUploadCreateParams(Add('purpose', Value.ToString));
end;

{ TUpload }

destructor TUpload.Destroy;
begin
  if Assigned(FFile) then
    FFile.Free;
  inherited;
end;

function TUpload.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TUpload.GetExpiresAtAsString: string;
begin
  Result := TimestampToString(ExpiresAt, UTCtimestamp);
end;

{ TUploadsRoute }

function TUploadsRoute.AddPart(const UploadId: string;
  const ParamProc: TProc<TUploadPartParams>): TUploadPart;
begin
  Result := API.PostForm<TUploadPart, TUploadPartParams>('uploads/' + UploadId + '/parts' , ParamProc);
end;

procedure TUploadsRoute.AsynAddPart(const UploadId: string;
  const ParamProc: TProc<TUploadPartParams>;
  const CallBacks: TFunc<TAsynUploadPart>);
begin
  with TAsynCallBackExec<TAsynUploadPart, TUploadPart>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TUploadPart
      begin
        Result := Self.AddPart(UploadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TUploadsRoute.AsynCancel(const UploadId: string;
  const CallBacks: TFunc<TAsynUpload>);
begin
  with TAsynCallBackExec<TAsynUpload, TUpload>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TUpload
      begin
        Result := Self.Cancel(UploadId);
      end);
  finally
    Free;
  end;
end;

procedure TUploadsRoute.AsynComplete(const UploadId: string;
  const ParamProc: TProc<TUploadCompleteParams>;
  const CallBacks: TFunc<TAsynUpload>);
begin
  with TAsynCallBackExec<TAsynUpload, TUpload>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TUpload
      begin
        Result := Self.Complete(UploadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TUploadsRoute.AsynCreate(const ParamProc: TProc<TUploadCreateParams>;
  const CallBacks: TFunc<TAsynUpload>);
begin
  with TAsynCallBackExec<TAsynUpload, TUpload>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TUpload
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TUploadsRoute.Cancel(const UploadId: string): TUpload;
begin
  Result := API.Post<TUpload>('uploads/' + UploadId + '/cancel');
end;

function TUploadsRoute.Complete(const UploadId: string;
  const ParamProc: TProc<TUploadCompleteParams>): TUpload;
begin
  Result := API.Post<TUpload, TUploadCompleteParams>('uploads/' + UploadId + '/complete', ParamProc);
end;

function TUploadsRoute.Create(
  const ParamProc: TProc<TUploadCreateParams>): TUpload;
begin
  Result := API.Post<TUpload, TUploadCreateParams>('uploads', ParamProc);
end;

{ TUploadPartParams }

function TUploadPartParams.Data(const Value: string): TUploadPartParams;
begin
  AddFile('data', Value);
  Result := Self;
end;

constructor TUploadPartParams.Create;
begin
  inherited Create(true);
end;

function TUploadPartParams.Data(const Value: TStream;
  const FileName: string): TUploadPartParams;
begin
  {$IF RTLVersion >= 35.0}
    AddStream('data', Value, True, FileName);
  {$ELSE}
    AddStream('data', Value, FileName);
  {$ENDIF}
  Result := Self;
end;

{ TUploadCompleteParams }

function TUploadCompleteParams.Md5(const Value: string): TUploadCompleteParams;
begin
  Result := TUploadCompleteParams(Add('md5',  Value));
end;

function TUploadCompleteParams.PartIds(
  const Value: TArray<string>): TUploadCompleteParams;
begin
  Result := TUploadCompleteParams(Add('part_ids',  Value));
end;

end.
