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
  GenAI.API.Deletion, GenAI.Assistants;

type
  /// <summary>
  /// Represents parameters for specifying image files in OpenAI threads.
  /// This class is used to define image-related details such as the file ID and image detail level.
  /// </summary>
  TThreadsImageFileParams = class(TJSONparam)
  public
    /// <summary>
    /// Sets the file ID of the image to be used in the thread.
    /// </summary>
    /// <param name="Value">
    /// The unique file ID referencing the image within the thread.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsImageFileParams</c> object with the specified file ID.
    /// </returns>
    function FileId(const Value: string): TThreadsImageFileParams;
    /// <summary>
    /// Sets the detail level for the specified image.
    /// </summary>
    /// <param name="Value">
    /// The desired image detail level, which can be low, high, or auto.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsImageFileParams</c> object with the specified detail level.
    /// </returns>
    function Detail(const Value: TImageDetail): TThreadsImageFileParams;
  end;

  /// <summary>
  /// Represents parameters for specifying image URLs in OpenAI threads.
  /// This class is used to define URL-related details such as the image URL and its detail level.
  /// </summary>
  TThreadsImageUrlParams = class(TJSONparam)
  public
    /// <summary>
    /// Sets the external URL of the image to be used in the thread.
    /// </summary>
    /// <param name="Value">
    /// The URL pointing to the image resource. The URL must reference a supported image format such as JPEG, PNG, GIF, or WebP.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsImageUrlParams</c> object with the specified image URL.
    /// </returns>
    function Url(const Value: string): TThreadsImageUrlParams;
    /// <summary>
    /// Sets the detail level for the specified image URL.
    /// </summary>
    /// <param name="Value">
    /// The desired image detail level, which can be low, high, or auto.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsImageUrlParams</c> object with the specified detail level.
    /// </returns>
    function Detail(const Value: TImageDetail): TThreadsImageUrlParams;
  end;

  /// <summary>
  /// Represents the parameters used to define the content of messages in OpenAI threads.
  /// This can include text content, image files, or image URLs.
  /// </summary>
  TThreadsContentParams = class(TJSONparam)
  public
    /// <summary>
    /// Sets the type of content for the message.
    /// </summary>
    /// <param name="Value">
    /// The type of the content, such as "text" or "image".
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsContentParams</c> object with the specified content type.
    /// </returns>
    function &Type(const Value: string): TThreadsContentParams; overload;
    /// <summary>
    /// Sets the type of content for the message using an enumerated type.
    /// </summary>
    /// <param name="Value">
    /// The content type as an enumeration, such as <c>TThreadsContentType.text</c> or <c>TThreadsContentType.image_file</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsContentParams</c> object with the specified content type.
    /// </returns>
    function &Type(const Value: TThreadsContentType): TThreadsContentParams; overload;
    /// <summary>
    /// Specifies an image file to be included as part of the message content.
    /// </summary>
    /// <param name="Value">
    /// The image file parameters, including the file ID and detail level.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsContentParams</c> object with the specified image file.
    /// </returns>
    function ImageFile(const Value: TThreadsImageFileParams): TThreadsContentParams;
    /// <summary>
    /// Specifies an image URL to be included as part of the message content.
    /// </summary>
    /// <param name="Value">
    /// The image URL parameters, including the URL and detail level.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsContentParams</c> object with the specified image URL.
    /// </returns>
    function ImageUrl(const Value: TThreadsImageUrlParams): TThreadsContentParams;
    /// <summary>
    /// Sets the text content for the message.
    /// </summary>
    /// <param name="Value">
    /// The text to be included in the message content.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsContentParams</c> object with the specified text content.
    /// </returns>
    function Text(const Value: string): TThreadsContentParams;
  end;

  /// <summary>
  /// Represents attachments that can be included in messages in OpenAI threads.
  /// Attachments can be files with specific tools applied, such as a code interpreter or file search.
  /// </summary>
  TThreadsAttachment = class(TJSONparam)
    /// <summary>
    /// Sets the file ID of the attachment to be included in the message.
    /// </summary>
    /// <param name="Value">
    /// The unique file ID referencing the attachment within the thread.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsAttachment</c> object with the specified file ID.
    /// </returns>
    function FileId(const Value: string): TThreadsAttachment;
    /// <summary>
    /// Specifies the tool to associate with the attachment, such as a code interpreter or file search.
    /// </summary>
    /// <param name="Value">
    /// The tool type as an enumerated value, either <c>code_interpreter</c> or <c>file_search</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsAttachment</c> object with the specified tool.
    /// </returns>
    function Tool(const Value: TAssistantsToolsType): TThreadsAttachment; overload;
    /// <summary>
    /// Specifies the tool to associate with the attachment using a string representation.
    /// </summary>
    /// <param name="Value">
    /// The tool type as a string, such as "code_interpreter" or "file_search".
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsAttachment</c> object with the specified tool.
    /// </returns>
    function Tool(const Value: string): TThreadsAttachment; overload;
  end;

  /// <summary>
  /// Represents the parameters used to define a message in OpenAI threads.
  /// A message contains details such as its role, content, attachments, and metadata.
  /// </summary>
  TThreadsMessageParams = class(TJSONparam)
  public
    /// <summary>
    /// Sets the role of the message sender.
    /// </summary>
    /// <param name="Value">
    /// The role as a string, such as "user" or "assistant".
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsMessageParams</c> object with the specified role.
    /// </returns>
    function Role(const Value: string): TThreadsMessageParams; overload;
    /// <summary>
    /// Sets the role of the message sender using an enumerated value.
    /// </summary>
    /// <param name="Value">
    /// The role as an enumerated value, such as <c>TRole.user</c> or <c>TRole.assistant</c>.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsMessageParams</c> object with the specified role.
    /// </returns>
    function Role(const Value: TRole): TThreadsMessageParams; overload;
    /// <summary>
    /// Sets the content of the message as a text string.
    /// </summary>
    /// <param name="Value">
    /// The text content to include in the message.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsMessageParams</c> object with the specified text content.
    /// </returns>
    function Content(const Value: string): TThreadsMessageParams; overload;
    /// <summary>
    /// Sets the content of the message using an array of content parameters.
    /// This can be used for messages containing multiple content types such as text and images.
    /// </summary>
    /// <param name="Value">
    /// An array of content parameters specifying the details of each content part.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsMessageParams</c> object with the specified content array.
    /// </returns>
    function Content(const Value: TArray<TThreadsContentParams>): TThreadsMessageParams; overload;
    /// <summary>
    /// Adds attachments to the message.
    /// </summary>
    /// <param name="Value">
    /// An array of attachments to include in the message. Each attachment can specify a file and a tool to apply to it.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsMessageParams</c> object with the specified attachments.
    /// </returns>
    function Attachments(const Value: TArray<TThreadsAttachment>): TThreadsMessageParams;
    /// <summary>
    /// Sets metadata for the message as a JSON object.
    /// Metadata can be used to store additional structured information about the message.
    /// </summary>
    /// <param name="Value">
    /// A JSON object containing key-value pairs of metadata.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsMessageParams</c> object with the specified metadata.
    /// </returns>
    function Metadata(const Value: TJSONObject): TThreadsMessageParams;
  end;

  /// <summary>
  /// Represents the parameters for creating a new thread in OpenAI threads.
  /// This includes defining initial messages, tool resources, and metadata.
  /// </summary>
  TThreadsCreateParams = class(TJSONparam)
  public
    /// <summary>
    /// Sets the initial message for the thread using a string.
    /// </summary>
    /// <param name="Value">
    /// The message content as a string, typically sent by the user to start the thread.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsCreateParams</c> object with the specified message.
    /// </returns>
    function Messages(const Value: string): TThreadsCreateParams; overload;
    /// <summary>
    /// Sets the initial messages for the thread using an array of message parameters.
    /// </summary>
    /// <param name="Value">
    /// An array of message parameters representing the initial conversation context.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsCreateParams</c> object with the specified messages.
    /// </returns>
    function Messages(const Value: TArray<TThreadsMessageParams>): TThreadsCreateParams; overload;
    /// <summary>
    /// Associates tool resources with the thread, such as files for the code interpreter or vector stores.
    /// </summary>
    /// <param name="Value">
    /// A set of tool resources, such as file IDs or vector store IDs, that can be used by the assistant tools.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsCreateParams</c> object with the specified tool resources.
    /// </returns>
    function ToolResources(const Value: TToolResourcesParams): TAssistantsParams;
    /// <summary>
    /// Attaches metadata to the thread as a JSON object.
    /// Metadata can store additional structured information related to the thread creation.
    /// </summary>
    /// <param name="Value">
    /// A JSON object containing key-value pairs of metadata.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsCreateParams</c> object with the specified metadata.
    /// </returns>
    function Metadata(const Value: TJSONObject): TThreadsCreateParams;
  end;

  /// <summary>
  /// Represents the parameters used to modify an existing thread in OpenAI threads.
  /// This includes updating tool resources and metadata.
  /// </summary>
  TThreadsModifyParams = class(TJSONparam)
  public
    /// <summary>
    /// Updates the tool resources associated with the thread.
    /// This can include files for the code interpreter or vector store configurations.
    /// </summary>
    /// <param name="Value">
    /// A set of tool resources, such as file IDs or vector store IDs, that can be used by the assistant tools.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsModifyParams</c> object with the specified tool resources.
    /// </returns>
    function ToolResources(const Value: TToolResourcesParams): TThreadsModifyParams;
    /// <summary>
    /// Updates the metadata associated with the thread as a JSON object.
    /// Metadata can be used to store additional structured information about the thread.
    /// </summary>
    /// <param name="Value">
    /// A JSON object containing key-value pairs of metadata.
    /// </param>
    /// <returns>
    /// The updated <c>TThreadsModifyParams</c> object with the specified metadata.
    /// </returns>
    function Metadata(const Value: TJSONObject): TThreadsModifyParams;
  end;

  /// <summary>
  /// Represents a thread object in OpenAI threads.
  /// A thread contains messages, tool resources, metadata, and other properties related to its creation and management.
  /// </summary>
  TThreads = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
    [JsonNameAttribute('tool_resources')]
    FToolResources: TToolResources;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FMetadata: string;
  private
    function GetCreatedAtAsString: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the thread.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the unique identifier of the thread.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets the formatted creation time as a human-readable string.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) for when the thread was created.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the tool resources associated with the thread.
    /// This includes files for the code interpreter or vector store configurations.
    /// </summary>
    property ToolResources: TToolResources read FToolResources write FToolResources;
    /// <summary>
    /// Gets or sets the metadata containing additional structured information about the thread.
    /// </summary>
    property Metadata: string read FMetadata write FMetadata;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TThreads</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynThreads</c> type extends the <c>TAsynParams&lt;TThreads&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynThreads = TAsynCallBack<TThreads>;

  /// <summary>
  /// Provides an interface for interacting with OpenAI threads via API routes.
  /// This class supports both synchronous and asynchronous operations, including creating, retrieving, modifying, and deleting threads.
  /// </summary>
  /// <remarks>
  /// <para>
  /// The class encapsulates API requests and manages the associated headers, routes, and callbacks required
  /// for interacting with the OpenAI API. Developers can use it to perform thread-related tasks while leveraging
  /// both synchronous and non-blocking (asynchronous) execution flows.
  /// </para>
  /// <para>
  /// The tool resources associated with threads, such as files and vector stores, can be specified to enhance
  /// assistant capabilities like code execution or vector-based searches. Metadata can also be attached
  /// to threads for storing structured information.
  /// </para>
  /// </remarks>
  TThreadsRoute = class(TGenAIRoute)
  protected
    /// <summary>
    /// Customizes the API headers specific to thread management operations.
    /// Adds the "OpenAI-Beta" header for proper API versioning.
    /// </summary>
    procedure HeaderCustomize; override;
  public
    /// <summary>
    /// Asynchronously creates a new thread using the specified parameters and callback functions.
    /// </summary>
    /// <param name="ParamProc">
    /// A procedure to configure the thread creation parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A set of callback functions to handle the asynchronous response.
    /// </param>
    procedure AsynCreate(const ParamProc: TProc<TThreadsCreateParams>; const CallBacks: TFunc<TAsynThreads>); overload;
    /// <summary>
    /// Asynchronously creates a new thread using the default parameters and callback functions.
    /// </summary>
    /// <param name="CallBacks">
    /// A set of callback functions to handle the asynchronous response.
    /// </param>
    procedure AsynCreate(const CallBacks: TFunc<TAsynThreads>); overload;
    /// <summary>
    /// Asynchronously retrieves a thread by its ID.
    /// </summary>
    /// <param name="ThreadId">
    /// The unique identifier of the thread to retrieve.
    /// </param>
    /// <param name="CallBacks">
    /// A set of callback functions to handle the asynchronous response.
    /// </param>
    procedure AsynRetrieve(const ThreadId: string; const CallBacks: TFunc<TAsynThreads>);
    /// <summary>
    /// Asynchronously modifies an existing thread using the specified parameters and callback functions.
    /// </summary>
    /// <param name="ThreadId">
    /// The unique identifier of the thread to modify.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the thread modification parameters.
    /// </param>
    /// <param name="CallBacks">
    /// A set of callback functions to handle the asynchronous response.
    /// </param>
    procedure AsynModify(const ThreadId: string; const ParamProc: TProc<TThreadsModifyParams>;
      const CallBacks: TFunc<TAsynThreads>);
    /// <summary>
    /// Asynchronously deletes a thread by its ID.
    /// </summary>
    /// <param name="ThreadId">
    /// The unique identifier of the thread to delete.
    /// </param>
    /// <param name="CallBacks">
    /// A set of callback functions to handle the asynchronous response.
    /// </param>
    procedure AsynDelete(const ThreadId: string; const CallBacks: TFunc<TAsynDeletion>);
    /// <summary>
    /// Synchronously creates a new thread using the specified parameters.
    /// </summary>
    /// <param name="ParamProc">
    /// An optional procedure to configure the thread creation parameters.
    /// </param>
    /// <returns>
    /// The created thread object.
    /// </returns>
    function Create(const ParamProc: TProc<TThreadsCreateParams> = nil): TThreads;
    /// <summary>
    /// Synchronously retrieves a thread by its ID.
    /// </summary>
    /// <param name="ThreadId">
    /// The unique identifier of the thread to retrieve.
    /// </param>
    /// <returns>
    /// The retrieved thread object.
    /// </returns>
    function Retrieve(const ThreadId: string): TThreads;
    /// <summary>
    /// Synchronously modifies an existing thread using the specified parameters.
    /// </summary>
    /// <param name="ThreadId">
    /// The unique identifier of the thread to modify.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure to configure the thread modification parameters.
    /// </param>
    /// <returns>
    /// The modified thread object.
    /// </returns>
    function Modify(const ThreadId: string; const ParamProc: TProc<TThreadsModifyParams>): TThreads;
    /// <summary>
    /// Synchronously deletes a thread by its ID.
    /// </summary>
    /// <param name="ThreadId">
    /// The unique identifier of the thread to delete.
    /// </param>
    /// <returns>
    /// The deletion status of the thread.
    /// </returns>
    function Delete(const ThreadId: string): TDeletion;
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

function TThreadsContentParams.Text(const Value: string): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('text', Value));
end;

function TThreadsContentParams.&Type(
  const Value: string): TThreadsContentParams;
begin
  Result := TThreadsContentParams(Add('type', TThreadsContentType.Create(Value).ToString));
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

function TThreadsRoute.Delete(const ThreadId: string): TDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TDeletion>('threads/' + ThreadId);
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

function TThreads.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

end.
