unit GenAI.Messages;

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Threads, GenAI.API.Lists;

type
  TAssistantsUrlParams = class(TUrlAdvancedParams)
  public
    function RunId(const Value: string): TAssistantsUrlParams;
  end;

  TMessagesUpdateParams = class(TJSONParam)
  public
    function Metadata(const Value: TJSONObject): TMessagesUpdateParams;
  end;

  TIncompleteDetails = class
  private
    FReason: string;
  public
    property Reason: string read FReason write FReason;
  end;

  TMessagesImageFile = class
  private
    FFileId: string;
    FDetail: string;
  public
    property FileId: string read FFileId write FFileId;
    property Detail: string read FDetail write FDetail;
  end;

  TMessagesImageUrl = class
  private
    FUrl: string;
    FDetail: string;
  public
    property Url: string read FUrl write FUrl;
    property Detail: string read FDetail write FDetail;
  end;

  TFileCitation = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
  public
    property FileId: string read FFileId write FFileId;
  end;

  TFilePath = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
  public
    property FileId: string read FFileId write FFileId;
  end;

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
    property &Type: string read FType write FType;
    property Text: string read FText write FText;
    property FileCitation: TFileCitation read FFileCitation write FFileCitation;
    property FilePath: TFilePath read FFilePath write FFilePath;
    property StartIndex: Int64 read FStartIndex write FStartIndex;
    property EndIndex: Int64 read FEndIndex write FEndIndex;
    destructor Destroy; override;
  end;

  TMessagesText = class
  private
    FValue: string;
    FAnnotations: TArray<TMesssagesAnnotation>;
  public
    property Value: string read FValue write FValue;
    property Annotations: TArray<TMesssagesAnnotation> read FAnnotations write FAnnotations;
    destructor Destroy; override;
  end;

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
    property &Type: string read FType write FType;
    property ImageFile: TMessagesImageFile read FImageFile write FImageFile;
    property ImageUrl: TMessagesImageUrl read FImageUrl write FImageUrl;
    property Text: TMessagesText read FText write FText;
    property Refusal: string read FRefusal write FRefusal;
    destructor Destroy; override;
  end;

  TAttachmentTool = class
  private
    [JsonReflectAttribute(ctString, rtString, TAssistantsToolsTypeInterceptor)]
    FType: TAssistantsToolsType;
  public
    property &Type: TAssistantsToolsType read FType write FType;
  end;

  TAttachment = class
  private
    [JsonNameAttribute('file_id')]
    FFileId: string;
    FTools: TArray<TAttachmentTool>;
  public
    property FileId: string read FFileId write FFileId;
    property Tools: TArray<TAttachmentTool> read FTools write FTools;
    destructor Destroy; override;
  end;

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
    property Id: string read FId write FId;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property &Object: string read FObject write FObject;
    property ThreadId: string read FThreadId write FThreadId;
    property Status: TMessageStatus read FStatus write FStatus;
    property IncompleteDetails: TIncompleteDetails read FIncompleteDetails write FIncompleteDetails;
    property CompletedAt: Int64 read FCompletedAt write FCompletedAt;
    property CompletedAtString: string read GetCompletedAtAsString;
    property IncompleteAt: Int64 read FIncompleteAt write FIncompleteAt;
    property IncompleteAtAsString: string read GetIncompleteAtAsString;
    property Role: TRole read FRole write FRole;
    property Content: TArray<TMessagesContent> read FContent write FContent;
    property AssistantId: string read FAssistantId write FAssistantId;
    property RunId: string read FRunId write FRunId;
    property Attachments: TArray<TAttachment> read FAttachments write FAttachments;
    property Metadata: string read FMetadata write FMetadata;
    destructor Destroy; override;
  end;

  TMessagesList = TAdvancedList<TMessages>;

  TMessagesDeletion = class(TJSONFingerprint)
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
  /// Manages asynchronous chat callBacks for a chat request using <c>TMessages</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMessages</c> type extends the <c>TAsynParams&lt;TMessages&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynMessages = TAsynCallBack<TMessages>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TMessagesList</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMessagesList</c> type extends the <c>TAsynParams&lt;TMessagesList&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynMessagesList = TAsynCallBack<TMessagesList>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TMessagesDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynMessagesDeletion</c> type extends the <c>TAsynParams&lt;TMessagesDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynMessagesDeletion = TAsynCallBack<TMessagesDeletion>;

  TMessagesRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    procedure AsynCreate(const ThreadId: string; const ParamProc: TProc<TThreadsMessageParams>;
      const CallBacks: TFunc<TAsynMessages>);
    procedure AsynList(const ThreadId: string; const CallBacks: TFunc<TAsynMessagesList>); overload;
    procedure AsynList(const ThreadId: string; const ParamProc: TProc<TAssistantsUrlParams>;
      const CallBacks: TFunc<TAsynMessagesList>); overload;
    procedure AsynRetrieve(const ThreadId: string; const MessageId: string;
      const CallBacks: TFunc<TAsynMessages>);
    procedure AsynUpdate(const ThreadId: string; const MessageId: string;
      const ParamProc: TProc<TMessagesUpdateParams>;
      const CallBacks: TFunc<TAsynMessages>);
    procedure AsynDelete(const ThreadId: string; const MessageId: string;
      const CallBacks: TFunc<TAsynMessagesDeletion>);

    function Create(const ThreadId: string; const ParamProc: TProc<TThreadsMessageParams>): TMessages;
    function List(const ThreadId: string): TMessagesList; overload;
    function List(const ThreadId: string; const ParamProc: TProc<TAssistantsUrlParams>): TMessagesList; overload;
    function Retrieve(const ThreadId: string; const MessageId: string): TMessages;
    function Update(const ThreadId: string; const MessageId: string; const ParamProc: TProc<TMessagesUpdateParams>): TMessages;
    function Delete(const ThreadId: string; const MessageId: string): TMessagesDeletion;
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
  const CallBacks: TFunc<TAsynMessagesDeletion>);
begin
  with TAsynCallBackExec<TAsynMessagesDeletion, TMessagesDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TMessagesDeletion
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
  MessageId: string): TMessagesDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TMessagesDeletion>('threads/' + ThreadId + '/messages/' + MessageId);
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
