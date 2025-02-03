unit GenAI.Messages;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Threads, GenAI.API.Lists, GenAI.API.Deletion;

type
  /// <summary>
  /// Represents URL parameters used for customizing requests related to assistants in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TUrlAdvancedParams</c> to provide additional parameters
  /// that can be added to API calls when interacting with assistant-related threads.
  /// </remarks>
  TAssistantsUrlParams = class(TUrlAdvancedParams)
  public
    /// <summary>
    /// Specifies the <c>run_id</c> parameter for filtering messages by a specific run ID.
    /// </summary>
    /// <param name="Value">
    /// The run ID that will be used to filter the API request.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TAssistantsUrlParams</c> for method chaining.
    /// </returns>
    /// <remarks>
    /// The <c>run_id</c> parameter can be used to retrieve messages that are associated
    /// with a specific execution or run within the assistant's context.
    /// </remarks>
    function RunId(const Value: string): TAssistantsUrlParams;
  end;

  /// <summary>
  /// Represents parameters used for updating messages within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TJSONParam</c> to provide structured key-value pairs
  /// for modifying messages, such as attaching metadata or updating message-specific details.
  /// </remarks>
  TMessagesUpdateParams = class(TJSONParam)
  public
    /// <summary>
    /// Adds or updates metadata for a message.
    /// </summary>
    /// <param name="Value">
    /// A JSON object containing key-value pairs representing metadata.
    /// Each key must be a string of maximum length 64 characters, and each value
    /// must be a string of maximum length 512 characters.
    /// </param>
    /// <returns>
    /// Returns the current instance of <c>TMessagesUpdateParams</c> for method chaining.
    /// </returns>
    /// <remarks>
    /// Metadata can be useful for storing additional structured information about the message,
    /// such as timestamps, categories, or custom identifiers.
    /// </remarks>
    function Metadata(const Value: TJSONObject): TMessagesUpdateParams;
  end;

  /// <summary>
  /// Represents details related to incomplete messages within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class contains information on why a message was marked as incomplete,
  /// typically providing a reason for the failure or interruption during processing.
  /// </remarks>
  TIncompleteDetails = class
  private
    FReason: string;
  public
    /// <summary>
    /// Gets or sets the reason for the incomplete message.
    /// </summary>
    /// <remarks>
    /// The reason provides diagnostic information, which may include errors
    /// related to processing, timeouts, or API restrictions.
    /// </remarks>
    property Reason: string read FReason write FReason;
  end;

  /// <summary>
  /// Represents an image file attached to a message within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to reference an image that is included as part of a message.
  /// The image is identified by its file ID and can have an associated detail level.
  /// </remarks>
  TMessagesImageFile = class
  private
    FFileId: string;
    FDetail: string;
  public
    /// <summary>
    /// Gets or sets the file ID of the image.
    /// </summary>
    /// <remarks>
    /// The file ID is a unique reference used to retrieve or process the image within the API.
    /// </remarks>
    property FileId: string read FFileId write FFileId;
    /// <summary>
    /// Gets or sets the detail level of the image.
    /// </summary>
    /// <remarks>
    /// The detail level can be <c>low</c> for fewer tokens or <c>high</c> for high-resolution processing.
    /// </remarks>
    property Detail: string read FDetail write FDetail;
  end;

  /// <summary>
  /// Represents an external image URL attached to a message within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to reference an image located at an external URL.
  /// The image can have an associated detail level, which determines the resolution or processing cost.
  /// </remarks>
  TMessagesImageUrl = class
  private
    FUrl: string;
    FDetail: string;
  public
    /// <summary>
    /// Gets or sets the external URL of the image.
    /// </summary>
    /// <remarks>
    /// The URL must point to a supported image format such as JPEG, PNG, or GIF.
    /// </remarks>
    property Url: string read FUrl write FUrl;
    /// <summary>
    /// Gets or sets the detail level of the image.
    /// </summary>
    /// <remarks>
    /// The detail level can be <c>low</c> for lower token consumption or <c>high</c> for detailed processing.
    /// </remarks>
    property Detail: string read FDetail write FDetail;
  end;

  /// <summary>
  /// Represents a citation within a message that references a specific portion of a file in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to provide contextual citations by referencing parts of a file
  /// that the assistant used during message generation or processing.
  /// </remarks>
  TFileCitation = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
  public
    /// <summary>
    /// Gets or sets the file ID for the cited file.
    /// </summary>
    /// <remarks>
    /// The file ID is a reference to the specific file that contains the content being cited.
    /// This ensures that citations in messages are traceable and verifiable.
    /// </remarks>
    property FileId: string read FFileId write FFileId;
  end;

  /// <summary>
  /// Represents the file path of a file generated or referenced during message processing in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class is used to reference a file by its path or identifier, typically when
  /// files are generated dynamically during tasks like code execution or data processing.
  /// </remarks>
  TFilePath = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
  public
    /// <summary>
    /// Gets or sets the file ID for the file path.
    /// </summary>
    /// <remarks>
    /// The file ID uniquely identifies a generated or referenced file, allowing it to be
    /// retrieved or processed within the context of a message.
    /// </remarks>
    property FileId: string read FFileId write FFileId;
  end;

  /// <summary>
  /// Represents an annotation within a message, providing contextual references such as file citations or file paths.
  /// </summary>
  /// <remarks>
  /// This class is used to add annotations that point to specific parts of external files,
  /// providing traceable references within the message content.
  /// </remarks>
  TMesssagesAnnotation = class
  private
    FType: string;
    FText: string;
    [JsonNameAttribute('file_citation')]
    FFileCitation: TFileCitation;
    [JsonNameAttribute('file_path')]
    FFilePath: TFilePath;
    [JsonNameAttribute('start_index')]
    FStartIndex: Int64;
    [JsonNameAttribute('end_index')]
    FEndIndex: Int64;
  public
    /// <summary>
    /// Gets or sets the type of the annotation.
    /// </summary>
    /// <remarks>
    /// Typical values include <c>file_citation</c> and <c>file_path</c>.
    /// </remarks>
    property &Type: string read FType write FType;
    /// <summary>
    /// Gets or sets the annotated text within the message.
    /// </summary>
    property Text: string read FText write FText;
    /// <summary>
    /// Gets or sets the file citation details.
    /// </summary>
    /// <remarks>
    /// This property is used when the annotation refers to a specific part of a file for citation purposes.
    /// </remarks>
    property FileCitation: TFileCitation read FFileCitation write FFileCitation;
    /// <summary>
    /// Gets or sets the file path details.
    /// </summary>
    /// <remarks>
    /// This property is used when the annotation points to a file that was generated or referenced during processing.
    /// </remarks>
    property FilePath: TFilePath read FFilePath write FFilePath;
    /// <summary>
    /// Gets or sets the starting index of the annotated text.
    /// </summary>
    /// <remarks>
    /// The starting index is zero-based and specifies the position where the annotation begins.
    /// </remarks>
    property StartIndex: Int64 read FStartIndex write FStartIndex;
    /// <summary>
    /// Gets or sets the ending index of the annotated text.
    /// </summary>
    /// <remarks>
    /// The ending index is zero-based and specifies the position where the annotation ends.
    /// </remarks>
    property EndIndex: Int64 read FEndIndex write FEndIndex;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the text content of a message within the OpenAI API, including any associated annotations.
  /// </summary>
  /// <remarks>
  /// This class stores the text content of a message along with any annotations that provide
  /// additional context, such as file citations or file paths.
  /// </remarks>
  TMessagesText = class
  private
    FValue: string;
    FAnnotations: TArray<TMesssagesAnnotation>;
  public
    /// <summary>
    /// Gets or sets the value of the text content.
    /// </summary>
    /// <remarks>
    /// The text content represents the primary message data, such as user input or assistant responses.
    /// </remarks>
    property Value: string read FValue write FValue;
    /// <summary>
    /// Gets or sets the list of annotations associated with the text.
    /// </summary>
    /// <remarks>
    /// Annotations can reference specific parts of external files or provide contextual metadata
    /// related to the message content.
    /// </remarks>
    property Annotations: TArray<TMesssagesAnnotation> read FAnnotations write FAnnotations;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents the content of a message in the OpenAI API, including text, images, and refusal reasons.
  /// </summary>
  /// <remarks>
  /// This class stores various types of content that can be part of a message,
  /// such as plain text, image references, or refusal messages indicating that the assistant
  /// declined to respond.
  /// </remarks>
  TMessagesContent = class
  private
    FType: string;
    [JsonNameAttribute('image_file')]
    FImageFile: TMessagesImageFile;
    [JsonNameAttribute('image_url')]
    FImageUrl: TMessagesImageUrl;
    FText: TMessagesText;
    FRefusal: string;
  public
    /// <summary>
    /// Gets or sets the type of content in the message.
    /// </summary>
    /// <remarks>
    /// Typical values include <c>text</c>, <c>image_file</c>, <c>image_url</c>, or <c>refusal</c>.
    /// </remarks>
    property &Type: string read FType write FType;
    /// <summary>
    /// Gets or sets the image file details if the content includes an image file.
    /// </summary>
    /// <remarks>
    /// This property is populated when the message references an image uploaded as a file.
    /// </remarks>
    property ImageFile: TMessagesImageFile read FImageFile write FImageFile;
    /// <summary>
    /// Gets or sets the external image URL details if the content includes an image URL.
    /// </summary>
    /// <remarks>
    /// This property is populated when the message references an image hosted externally via a URL.
    /// </remarks>
    property ImageUrl: TMessagesImageUrl read FImageUrl write FImageUrl;
    /// <summary>
    /// Gets or sets the text content of the message.
    /// </summary>
    /// <remarks>
    /// This property is populated when the message includes text data, which may contain annotations.
    /// </remarks>
    property Text: TMessagesText read FText write FText;
    /// <summary>
    /// Gets or sets the refusal message content if the assistant declined to respond.
    /// </summary>
    /// <remarks>
    /// This property is populated when the assistant provides a refusal explanation
    /// indicating why a response was not generated.
    /// </remarks>
    property Refusal: string read FRefusal write FRefusal;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a tool associated with an attachment in a message within the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class specifies the type of tool linked to an attachment, such as a code interpreter
  /// or file search tool, which can be used during message processing.
  /// </remarks>
  TAttachmentTool = class
  private
    [JsonReflectAttribute(ctString, rtString, TAssistantsToolsTypeInterceptor)]
    FType: TAssistantsToolsType;
  public
    /// <summary>
    /// Gets or sets the type of tool associated with the attachment.
    /// </summary>
    /// <remarks>
    /// Typical values include <c>code_interpreter</c> and <c>file_search</c>.
    /// The tool determines how the attached file is used during the conversation.
    /// </remarks>
    property &Type: TAssistantsToolsType read FType write FType;
  end;

  /// <summary>
  /// Represents an attachment associated with a message in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class stores information about a file attached to a message and the tools
  /// that can be used to process or interact with the file.
  /// </remarks>
  TAttachment = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
    FTools: TArray<TAttachmentTool>;
  public
    /// <summary>
    /// Gets or sets the file ID of the attachment.
    /// </summary>
    /// <remarks>
    /// The file ID uniquely identifies the attached file within the API and is used to retrieve
    /// or process it during message handling.
    /// </remarks>
    property FileId: string read FFileId write FFileId;
    /// <summary>
    /// Gets or sets the list of tools associated with the attachment.
    /// </summary>
    /// <remarks>
    /// Each tool defines how the attached file will be used, such as executing it with a
    /// code interpreter or searching its contents.
    /// </remarks>
    property Tools: TArray<TAttachmentTool> read FTools write FTools;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a message within a thread in the OpenAI API, including its content, status, metadata, and attachments.
  /// </summary>
  /// <remarks>
  /// This class stores all the details related to a message, such as its creation timestamp,
  /// role, status, and the content it contains (text, images, or other media).
  /// </remarks>
  TMessages = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
    [JsonNameAttribute('thread_id')]
    FThreadId: string;
    [JsonReflectAttribute(ctString, rtString, TMessageStatusInterceptor)]
    FStatus: TMessageStatus;
    [JsonNameAttribute('incomplete_details')]
    FIncompleteDetails: TIncompleteDetails;
    [JsonNameAttribute('completed_at')]
    FCompletedAt: Int64;
    [JsonNameAttribute('incomplete_at')]
    FIncompleteAt: Int64;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FContent: TArray<TMessagesContent>;
    [JsonNameAttribute('assistant_id')]
    FAssistantId: string;
    [JsonNameAttribute('run_id')]
    FRunId: string;
    FAttachments: TArray<TAttachment>;
    FMetadata: string;
  private
    function GetCreatedAtAsString: string;
    function GetCompletedAtAsString: string;
    function GetIncompleteAtAsString: string;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the message.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) indicating when the message was created.
    /// </summary>
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    /// <summary>
    /// Gets the formatted creation time as a human-readable string.
    /// </summary>
    property CreatedAtAsString: string read GetCreatedAtAsString;
    /// <summary>
    /// Gets or sets the object type of the message.
    /// </summary>
    /// <remarks>
    /// This value is typically <c>thread.message</c>.
    /// </remarks>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the ID of the thread that the message belongs to.
    /// </summary>
    property ThreadId: string read FThreadId write FThreadId;
    /// <summary>
    /// Gets or sets the status of the message.
    /// </summary>
    /// <remarks>
    /// The status indicates whether the message is in progress, incomplete, or completed.
    /// </remarks>
    property Status: TMessageStatus read FStatus write FStatus;
    /// <summary>
    /// Gets or sets the details related to why the message is incomplete, if applicable.
    /// </summary>
    property IncompleteDetails: TIncompleteDetails read FIncompleteDetails write FIncompleteDetails;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) when the message was completed.
    /// </summary>
    property CompletedAt: Int64 read FCompletedAt write FCompletedAt;
    /// <summary>
    /// Gets the formatted completion time as a human-readable string.
    /// </summary>
    property CompletedAtString: string read GetCompletedAtAsString;
    /// <summary>
    /// Gets or sets the Unix timestamp (in seconds) when the message was marked as incomplete.
    /// </summary>
    property IncompleteAt: Int64 read FIncompleteAt write FIncompleteAt;
    /// <summary>
    /// Gets the formatted incomplete time as a human-readable string.
    /// </summary>
    property IncompleteAtAsString: string read GetIncompleteAtAsString;
    /// <summary>
    /// Gets or sets the role associated with the message, such as user or assistant.
    /// </summary>
    property Role: TRole read FRole write FRole;
    /// <summary>
    /// Gets or sets the array of content types included in the message.
    /// </summary>
    /// <remarks>
    /// The content array can include text, images, or refusal messages.
    /// </remarks>
    property Content: TArray<TMessagesContent> read FContent write FContent;
    /// <summary>
    /// Gets or sets the assistant ID if the message was generated by an assistant.
    /// </summary>
    property AssistantId: string read FAssistantId write FAssistantId;
    /// <summary>
    /// Gets or sets the run ID associated with the message creation.
    /// </summary>
    property RunId: string read FRunId write FRunId;
    /// <summary>
    /// Gets or sets the list of files attached to the message.
    /// </summary>
    property Attachments: TArray<TAttachment> read FAttachments write FAttachments;
    /// <summary>
    /// Gets or sets the metadata associated with the message.
    /// </summary>
    /// <remarks>
    /// Metadata can store additional key-value pairs providing extra context for the message.
    /// </remarks>
    property Metadata: string read FMetadata write FMetadata;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Represents a list of messages within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TAdvancedList</c> to provide a collection of <c>TMessages</c> objects,
  /// allowing for easy iteration and manipulation of messages retrieved from the API.
  /// </remarks>
  TMessagesList = TAdvancedList<TMessages>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TMessages</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMessages</c> type extends the <c>TAsynParams&lt;TMessages&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynMessages = TAsynCallBack<TMessages>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TMessagesList</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMessagesList</c> type extends the <c>TAsynParams&lt;TMessagesList&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynMessagesList = TAsynCallBack<TMessagesList>;

  /// <summary>
  /// Manages the API routes for handling messages within a thread in the OpenAI API.
  /// </summary>
  /// <remarks>
  /// This class provides methods to create, retrieve, update, delete, and list messages
  /// within a thread. It also supports asynchronous operations for non-blocking message handling.
  /// </remarks>
  TMessagesRoute = class(TGenAIRoute)
  protected
    /// <summary>
    /// Customizes the headers used for the message routes.
    /// </summary>
    procedure HeaderCustomize; override;
  public
    /// <summary>
    /// Asynchronously creates a new message within the specified thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread where the message will be created.</param>
    /// <param name="ParamProc">A procedure to configure the message parameters.</param>
    /// <param name="CallBacks">A function to handle the asynchronous call result.</param>
    procedure AsynCreate(const ThreadId: string;
      const ParamProc: TProc<TThreadsMessageParams>;
      const CallBacks: TFunc<TAsynMessages>);
    /// <summary>
    /// Asynchronously retrieves the list of messages within the specified thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread to retrieve messages from.</param>
    /// <param name="CallBacks">A function to handle the asynchronous call result.</param>
    procedure AsynList(const ThreadId: string; const CallBacks: TFunc<TAsynMessagesList>); overload;
    /// <summary>
    /// Asynchronously retrieves the list of messages within the specified thread using additional URL parameters.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread to retrieve messages from.</param>
    /// <param name="ParamProc">A procedure to configure the URL parameters.</param>
    /// <param name="CallBacks">A function to handle the asynchronous call result.</param>
    procedure AsynList(const ThreadId: string; const ParamProc: TProc<TAssistantsUrlParams>;
      const CallBacks: TFunc<TAsynMessagesList>); overload;
    /// <summary>
    /// Asynchronously retrieves a specific message by its ID within a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the message.</param>
    /// <param name="MessageId">The ID of the message to retrieve.</param>
    /// <param name="CallBacks">A function to handle the asynchronous call result.</param>
    procedure AsynRetrieve(const ThreadId: string; const MessageId: string;
      const CallBacks: TFunc<TAsynMessages>);
    /// <summary>
    /// Asynchronously updates an existing message within a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the message.</param>
    /// <param name="MessageId">The ID of the message to update.</param>
    /// <param name="ParamProc">A procedure to configure the update parameters.</param>
    /// <param name="CallBacks">A function to handle the asynchronous call result.</param>
    procedure AsynUpdate(const ThreadId: string; const MessageId: string;
      const ParamProc: TProc<TMessagesUpdateParams>;
      const CallBacks: TFunc<TAsynMessages>);
    /// <summary>
    /// Asynchronously deletes a message within a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the message.</param>
    /// <param name="MessageId">The ID of the message to delete.</param>
    /// <param name="CallBacks">A function to handle the asynchronous call result.</param>
    procedure AsynDelete(const ThreadId: string; const MessageId: string;
      const CallBacks: TFunc<TAsynDeletion>);
    /// <summary>
    /// Creates a new message within the specified thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread where the message will be created.</param>
    /// <param name="ParamProc">A procedure to configure the message parameters.</param>
    /// <returns>
    /// The newly created message object.
    /// </returns>
    function Create(const ThreadId: string; const ParamProc: TProc<TThreadsMessageParams>): TMessages;
    /// <summary>
    /// Retrieves the list of messages within the specified thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread to retrieve messages from.</param>
    /// <returns>
    /// A list of messages associated with the thread.
    /// </returns>
    function List(const ThreadId: string): TMessagesList; overload;
    /// <summary>
    /// Retrieves the list of messages within the specified thread using additional URL parameters.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread to retrieve messages from.</param>
    /// <param name="ParamProc">A procedure to configure the URL parameters.</param>
    /// <returns>
    /// A list of messages associated with the thread.
    /// </returns>
    function List(const ThreadId: string; const ParamProc: TProc<TAssistantsUrlParams>): TMessagesList; overload;
    /// <summary>
    /// Retrieves a specific message by its ID within a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the message.</param>
    /// <param name="MessageId">The ID of the message to retrieve.</param>
    /// <returns>
    /// The message object matching the specified ID.
    /// </returns>
    function Retrieve(const ThreadId: string; const MessageId: string): TMessages;
    /// <summary>
    /// Updates an existing message within a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the message.</param>
    /// <param name="MessageId">The ID of the message to update.</param>
    /// <param name="ParamProc">A procedure to configure the update parameters.</param>
    /// <returns>
    /// The updated message object.
    /// </returns>
    function Update(const ThreadId: string; const MessageId: string; const ParamProc: TProc<TMessagesUpdateParams>): TMessages;
    /// <summary>
    /// Deletes a message within a thread.
    /// </summary>
    /// <param name="ThreadId">The ID of the thread containing the message.</param>
    /// <param name="MessageId">The ID of the message to delete.</param>
    /// <returns>
    /// An object representing the deletion status.
    /// </returns>
    function Delete(const ThreadId: string; const MessageId: string): TDeletion;
  end;

implementation

{ TMessagesRoute }

procedure TMessagesRoute.AsynCreate(const ThreadId: string;
  const ParamProc: TProc<TThreadsMessageParams>;
  const CallBacks: TFunc<TAsynMessages>);
begin
  with TAsynCallBackExec<TAsynMessages, TMessages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TMessages
      begin
        Result := Self.Create(ThreadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TMessagesRoute.AsynDelete(const ThreadId, MessageId: string;
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
        Result := Self.Delete(ThreadId, MessageId);
      end);
  finally
    Free;
  end;
end;

procedure TMessagesRoute.AsynList(const ThreadId: string;
  const CallBacks: TFunc<TAsynMessagesList>);
begin
  with TAsynCallBackExec<TAsynMessagesList, TMessagesList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TMessagesList
      begin
        Result := Self.List(ThreadId);
      end);
  finally
    Free;
  end;
end;

procedure TMessagesRoute.AsynList(const ThreadId: string;
  const ParamProc: TProc<TAssistantsUrlParams>;
  const CallBacks: TFunc<TAsynMessagesList>);
begin
  with TAsynCallBackExec<TAsynMessagesList, TMessagesList>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TMessagesList
      begin
        Result := Self.List(ThreadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TMessagesRoute.AsynRetrieve(const ThreadId, MessageId: string;
  const CallBacks: TFunc<TAsynMessages>);
begin
  with TAsynCallBackExec<TAsynMessages, TMessages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TMessages
      begin
        Result := Self.Retrieve(ThreadId, MessageId);
      end);
  finally
    Free;
  end;
end;

procedure TMessagesRoute.AsynUpdate(const ThreadId, MessageId: string;
  const ParamProc: TProc<TMessagesUpdateParams>;
  const CallBacks: TFunc<TAsynMessages>);
begin
  with TAsynCallBackExec<TAsynMessages, TMessages>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TMessages
      begin
        Result := Self.Update(ThreadId, MessageId, ParamProc);
      end);
  finally
    Free;
  end;
end;

function TMessagesRoute.Create(const ThreadId: string;
  const ParamProc: TProc<TThreadsMessageParams>): TMessages;
begin
  HeaderCustomize;
  Result := API.Post<TMessages, TThreadsMessageParams>('threads/' + ThreadId + '/messages', ParamProc);
end;

function TMessagesRoute.Delete(const ThreadId,
  MessageId: string): TDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TDeletion>('threads/' + ThreadId + '/messages/' + MessageId);
end;

procedure TMessagesRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TMessagesRoute.List(const ThreadId: string): TMessagesList;
begin
  HeaderCustomize;
  Result := API.Get<TMessagesList>('threads/' + ThreadId + '/messages');
end;

function TMessagesRoute.List(const ThreadId: string;
  const ParamProc: TProc<TAssistantsUrlParams>): TMessagesList;
begin
  HeaderCustomize;
  Result := API.Get<TMessagesList, TAssistantsUrlParams>('threads/' + ThreadId + '/messages', ParamProc);
end;

function TMessagesRoute.Retrieve(const ThreadId, MessageId: string): TMessages;
begin
  HeaderCustomize;
  Result := API.Get<TMessages>('threads/' + ThreadId + '/messages/' + MessageId);
end;

function TMessagesRoute.Update(const ThreadId, MessageId: string;
  const ParamProc: TProc<TMessagesUpdateParams>): TMessages;
begin
  HeaderCustomize;
  Result := API.Post<TMessages, TMessagesUpdateParams>('threads/' + ThreadId + '/messages/' + MessageId, ParamProc);
end;

{ TMessages }

destructor TMessages.Destroy;
begin
  if Assigned(FIncompleteDetails) then
    FIncompleteDetails.Free;
  for var Item in FContent do
    Item.Free;
  for var Item in FAttachments do
    Item.Free;
  inherited;
end;

function TMessages.GetCompletedAtAsString: string;
begin
  Result := TimestampToString(CompletedAt, UTCtimestamp);
end;

function TMessages.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TMessages.GetIncompleteAtAsString: string;
begin
  Result := TimestampToString(IncompleteAt, UTCtimestamp);
end;

{ TMessagesContent }

destructor TMessagesContent.Destroy;
begin
  if Assigned(FImageFile) then
    FImageFile.Free;
  if Assigned(FImageUrl) then
    FImageUrl.Free;
  if Assigned(FText) then
    FText.Free;
  inherited;
end;

{ TMessagesText }

destructor TMessagesText.Destroy;
begin
  for var Item in FAnnotations do
    Item.Free;
  inherited;
end;

{ TMesssagesAnnotation }

destructor TMesssagesAnnotation.Destroy;
begin
  if Assigned(FFileCitation) then
    FFileCitation.Free;
  if Assigned(FFilePath) then
    FFilePath.Free;
  inherited;
end;

{ TAttachment }

destructor TAttachment.Destroy;
begin
  for var Item in FTools do
    Item.Free;
  inherited;
end;

{ TAssistantsUrlParams }

function TAssistantsUrlParams.RunId(const Value: string): TAssistantsUrlParams;
begin
  Result := TAssistantsUrlParams(Add('run_id', Value));
end;

{ TMessagesUpdateParams }

function TMessagesUpdateParams.Metadata(
  const Value: TJSONObject): TMessagesUpdateParams;
begin
  Result := TMessagesUpdateParams(Add('metadata', Value));
end;

end.
