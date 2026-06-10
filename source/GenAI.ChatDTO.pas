unit GenAI.ChatDTO;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  REST.Json.Types, REST.JsonReflect,
  GenAI.API.Params, GenAI.API.JsonSafeReader, GenAI.Types,
  GenAI.Net.MediaCodec;

type
  {$SCOPEDENUMS ON}
  /// <summary>
  /// Describes the JSON shape found in a chat response <c>content</c> field.
  /// </summary>
  /// <remarks>
  /// This value is populated during the second deserialization pass. It avoids
  /// reintroducing polymorphic DTO inheritance while keeping the raw vendor
  /// payload available when <c>content</c> is not a plain string.
  /// </remarks>

  TChatContentKind = (Missing, Null, Text, Json);

  {$SCOPEDENUMS OFF}

  TTopLogprobs = class
  private
    FToken: string;
    FLogprob: Double;
    FBytes: TArray<Int64>;
  public
    /// <summary>
    /// The token analyzed for log probability.
    /// </summary>
    property Token: string read FToken write FToken;

    /// <summary>
    /// The log probability of the token.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;

    /// <summary>
    /// The UTF-8 byte representation of the token.
    /// </summary>
    property Bytes: TArray<Int64> read FBytes write FBytes;
  end;

  TLogprobsDetail = class
  private
    FToken: string;
    FLogprob: Double;
    FBytes: TArray<Int64>;
    [JsonNameAttribute('top_logprobs')]
    FTopLogprobs: TArray<TTopLogprobs>;
  public
    /// <summary>
    /// The token analyzed for log probability.
    /// </summary>
    property Token: string read FToken write FToken;

    /// <summary>
    /// The log probability of the token.
    /// </summary>
    property Logprob: Double read FLogprob write FLogprob;

    /// <summary>
    /// The UTF-8 byte representation of the token.
    /// </summary>
    property Bytes: TArray<Int64> read FBytes write FBytes;

    /// <summary>
    /// A list of the most likely alternatives and their probabilities.
    /// </summary>
    property TopLogprobs: TArray<TTopLogprobs> read FTopLogprobs write FTopLogprobs;

    destructor Destroy; override;
  end;

  TLogprobs = class
  private
    FContent: TArray<TLogprobsDetail>;
    FRefusal: TArray<TLogprobsDetail>;
  public
    /// <summary>
    /// Contains log probability details for content message tokens.
    /// </summary>
    property Content: TArray<TLogprobsDetail> read FContent write FContent;

    /// <summary>
    /// Contains log probability details for refusal message tokens.
    /// </summary>
    property Refusal: TArray<TLogprobsDetail> read FRefusal write FRefusal;

    destructor Destroy; override;
  end;

  TFunction = class
  private
    FName: string;
    FArguments: string;
  public
    /// <summary>
    /// The name of the function to call.
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// The function arguments as a JSON-formatted string.
    /// </summary>
    property Arguments: string read FArguments write FArguments;
  end;

  TToolCall = class
  private
    FId: string;
    [JsonReflectAttribute(ctString, rtString, TToolCallsInterceptor)]
    FType: TToolCalls;
    FFunction: TFunction;
  public
    /// <summary>
    /// The unique identifier for the tool call.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The type of tool call.
    /// </summary>
    property &Type: TToolCalls read FType write FType;

    /// <summary>
    /// The function requested by this tool call.
    /// </summary>
    property &Function: TFunction read FFunction write FFunction;

    destructor Destroy; override;
  end;

  TAudioData = class
  private
    FId: string;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    FData: string;
    FTranscript: string;
    function GetExpiresAtAsString: string;
  public
    /// <summary>
    /// The audio identifier.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The Unix timestamp after which the audio data expires.
    /// </summary>
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;

    /// <summary>
    /// The expiration timestamp formatted as UTC text.
    /// </summary>
    property ExpiresAtAsString: string read GetExpiresAtAsString;

    /// <summary>
    /// The base64-encoded audio data.
    ///</summary>
    property Data: string read FData write FData;

    /// <summary>
    /// The transcript of the audio content.
    /// </summary>
    property Transcript: string read FTranscript write FTranscript;
  end;

  TAudio = class(TAudioData)
  private
    FFileName: string;
  public
    /// <summary>
    /// Decodes the audio payload into a memory stream.
    /// </summary>
    /// <returns>
    /// A stream containing decoded audio data. If decoding fails, the stream is
    /// returned empty so response deserialization remains non-blocking.
    /// </returns>
    function GetStream: TStream;

    /// <summary>
    /// Saves the decoded audio payload to the specified file path.
    /// </summary>
    /// <param name="FileName">The destination file path.</param>
    /// <param name="RaiseError">
    /// When <c>True</c>, invalid input raises an exception. When <c>False</c>,
    /// invalid input is ignored.
    /// </param>
    procedure SaveToFile(const FileName: string; const RaiseError: Boolean = True);

    /// <summary>
    /// The last file path used by <see cref="SaveToFile"/>.
    /// </summary>
    property FileName: string read FFileName write FFileName;
  end;

  TUrlCitation = class
  private
    [JsonNameAttribute('end_index')]
    FEndIndex: Int64;
    [JsonNameAttribute('start_index')]
    FStartIndex: Int64;
    FTitle: string;
    FUrl: string;
  public
    /// <summary>
    /// The index of the last character of the citation in the message.
    /// </summary>
    property EndIndex: Int64 read FEndIndex write FEndIndex;

    /// <summary>
    /// The index of the first character of the citation in the message.
    /// </summary>
    property StartIndex: Int64 read FStartIndex write FStartIndex;

    /// <summary>
    /// The title of the referenced web resource.
    /// </summary>
    property Title: string read FTitle write FTitle;

    /// <summary>
    /// The URL of the referenced web resource.
    /// </summary>
    property Url: string read FUrl write FUrl;
  end;

  TAnnotation = class
  private
    FType: string;
    [JsonNameAttribute('url_citation')]
    FUrlCitation: TUrlCitation;
  public
    /// <summary>
    /// The annotation type, such as <c>url_citation</c>.
    /// </summary>
    property &Type: string read FType write FType;

    /// <summary>
    /// URL citation details when the annotation is a citation.
    /// </summary>
    property UrlCitation: TUrlCitation read FUrlCitation write FUrlCitation;

    destructor Destroy; override;
  end;

  TDelta = class(TJSONFingerprint)
  private
    FContent: string;
    [JSONMarshalled(False)]
    FRawContent: string;
    [JSONMarshalled(False)]
    FContentKind: TChatContentKind;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolCall>;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FRefusal: string;
  protected
    /// <summary>
    /// Runs the second deserialization pass for direct delta parsing.
    /// </summary>
    procedure ContentUpdate; override;

    /// <summary>
    /// Finalizes the direct delta deserialization lifecycle.
    /// </summary>
    procedure AfterDeserialize; override;
  public
    /// <summary>
    /// Updates the content fields from a raw JSON root and a node path.
    /// </summary>
    procedure HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);

    /// <summary>
    /// Text content when the delta content is a JSON string.
    /// </summary>
    property Content: string read FContent write FContent;

    /// <summary>
    /// Raw JSON or text extracted from the original content node.
    /// </summary>
    property RawContent: string read FRawContent write FRawContent;

    /// <summary>
    /// The JSON shape of the original content node.
    /// </summary>
    property ContentKind: TChatContentKind read FContentKind;

    /// <summary>
    /// Tool calls associated with the delta.
    /// </summary>
    property ToolCalls: TArray<TToolCall> read FToolCalls write FToolCalls;

    /// <summary>
    /// The role of the message author.
    /// </summary>
    property Role: TRole read FRole write FRole;

    /// <summary>
    /// Refusal text returned by the model, when present.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;

    destructor Destroy; override;
  end;

  TChatMessage = class(TJSONFingerprint)
  private
    FContent: string;
    [JSONMarshalled(False)]
    FRawContent: string;
    [JSONMarshalled(False)]
    FContentKind: TChatContentKind;
    FRefusal: string;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolCall>;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FAnnotations: TArray<TAnnotation>;
    FAudio: TAudio;
  protected
    procedure ContentUpdate; override;
    procedure AfterDeserialize; override;
  public
    /// <summary>
    /// Updates the content fields from a raw JSON root and a node path.
    /// </summary>
    procedure HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);

    /// <summary>
    /// Text content when the message content is a JSON string.
    /// </summary>
    property Content: string read FContent write FContent;

    /// <summary>
    /// Raw JSON or text extracted from the original content node.
    /// </summary>
    property RawContent: string read FRawContent write FRawContent;

    /// <summary>
    /// The JSON shape of the original content node.
    /// </summary>
    property ContentKind: TChatContentKind read FContentKind;

    /// <summary>
    /// Refusal text returned by the model, when present.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;

    /// <summary>
    /// Tool calls requested by this message.
    /// </summary>
    property ToolCalls: TArray<TToolCall> read FToolCalls write FToolCalls;

    /// <summary>
    /// The role of the message author.
    /// </summary>
    property Role: TRole read FRole write FRole;

    /// <summary>
    /// Annotations attached to the message.
    /// </summary>
    property Annotations: TArray<TAnnotation> read FAnnotations write FAnnotations;

    /// <summary>
    /// Audio data attached to the message, when present.
    /// </summary>
    property Audio: TAudio read FAudio write FAudio;

    destructor Destroy; override;
  end;

  TChoice = class
  private
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    [JsonNameAttribute('finish_reason')]
    FFinishReason: TFinishReason;
    FIndex: Int64;
    FMessage: TChatMessage;
    FLogprobs: TLogprobs;
    FDelta: TDelta;
  public
    /// <summary>
    /// The reason generation stopped for this choice.
    /// </summary>
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;

    /// <summary>
    /// The index of this choice in the response.
    /// </summary>
    property Index: Int64 read FIndex write FIndex;

    /// <summary>
    /// The completed message for non-streamed responses.
    /// </summary>
    property Message: TChatMessage read FMessage write FMessage;

    /// <summary>
    /// Token log probability details for this choice.
    /// </summary>
    property Logprobs: TLogprobs read FLogprobs write FLogprobs;

    /// <summary>
    /// The streamed delta for streamed responses.
    /// </summary>
    property Delta: TDelta read FDelta write FDelta;

    destructor Destroy; override;
  end;

  TCompletionDetail = class
  private
    [JsonNameAttribute('accepted_prediction_tokens')]
    FAcceptedPredictionTokens: Int64;
    [JsonNameAttribute('audio_tokens')]
    FAudioTokens: Int64;
    [JsonNameAttribute('reasoning_tokens')]
    FReasoningTokens: Int64;
    [JsonNameAttribute('rejected_prediction_tokens')]
    FRejectedPredictionTokens: Int64;
  public
    /// <summary>
    /// The number of accepted prediction tokens.
    /// </summary>
    property AcceptedPredictionTokens: Int64 read FAcceptedPredictionTokens write FAcceptedPredictionTokens;

    /// <summary>
    /// The number of audio tokens.
    /// </summary>
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;

    /// <summary>
    /// The number of reasoning tokens.
    /// </summary>
    property ReasoningTokens: Int64 read FReasoningTokens write FReasoningTokens;

    /// <summary>
    /// The number of rejected prediction tokens.
    /// </summary>
    property RejectedPredictionTokens: Int64 read FRejectedPredictionTokens write FRejectedPredictionTokens;
  end;

  TPromptDetail = class
  private
    [JsonNameAttribute('audio_tokens')]
    FAudioTokens: Int64;
    [JsonNameAttribute('cached_tokens')]
    FCachedTokens: Int64;
  public
    /// <summary>
    /// The number of audio tokens used by the prompt.
    /// </summary>
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;

    /// <summary>
    /// The number of cached tokens used by the prompt.
    /// </summary>
    property CachedTokens: Int64 read FCachedTokens write FCachedTokens;
  end;

  TUsage = class
  private
    [JsonNameAttribute('completion_tokens')]
    FCompletionTokens: Int64;
    [JsonNameAttribute('prompt_tokens')]
    FPromptTokens: Int64;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
    [JsonNameAttribute('completion_tokens_details')]
    FCompletionTokensDetails: TCompletionDetail;
    [JsonNameAttribute('prompt_tokens_details')]
    FPromptTokensDetails: TPromptDetail;
  public
    /// <summary>
    /// The total number of completion tokens.
    /// </summary>
    property CompletionTokens: Int64 read FCompletionTokens write FCompletionTokens;

    /// <summary>
    /// The total number of prompt tokens.
    /// </summary>
    property PromptTokens: Int64 read FPromptTokens write FPromptTokens;

    /// <summary>
    /// The total number of tokens used by the request.
    /// </summary>
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;

    /// <summary>
    /// Detailed token usage for the completion.
    /// </summary>
    property CompletionTokensDetails: TCompletionDetail read FCompletionTokensDetails write FCompletionTokensDetails;

    /// <summary>
    /// Detailed token usage for the prompt.
    /// </summary>
    property PromptTokensDetails: TPromptDetail read FPromptTokensDetails write FPromptTokensDetails;

    destructor Destroy; override;
  end;

  TChat = class(TJSONFingerprint)
  private
    FId: string;
    FChoices: TArray<TChoice>;
    FCreated: Int64;
    FModel: string;
    [JsonNameAttribute('service_tier')]
    FServiceTier: string;
    [JsonNameAttribute('system_fingerprint')]
    FSystemFingerprint: string;
    FMetadata: string;
    FObject: string;
    FUsage: TUsage;
    FObfuscation: string;
    function GetCreatedAsString: string;
  protected
    /// <summary>
    /// Runs the second deserialization pass for chat content fields.
    /// </summary>
    procedure ContentUpdate; override;

    /// <summary>
    /// Finalizes the chat deserialization lifecycle.
    /// </summary>
    procedure AfterDeserialize; override;
  public
    /// <summary>
    /// Updates nested message and delta content fields from a raw JSON root.
    /// </summary>
    procedure HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);

    /// <summary>
    /// The unique identifier for the chat completion.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The generated choices returned by the model.
    /// </summary>
    property Choices: TArray<TChoice> read FChoices write FChoices;

    /// <summary>
    /// The Unix timestamp indicating when the chat completion was created.
    /// </summary>
    property Created: Int64 read FCreated write FCreated;

    /// <summary>
    /// The creation timestamp formatted as UTC text.
    /// </summary>
    property CreatedAsString: string read GetCreatedAsString;

    /// <summary>
    /// The model identifier used to generate the response.
    /// </summary>
    property Model: string read FModel write FModel;

    /// <summary>
    /// The service tier used by the request.
    /// </summary>
    property ServiceTier: string read FServiceTier write FServiceTier;

    /// <summary>
    /// The backend system fingerprint returned by the service.
    /// </summary>
    property SystemFingerprint: string read FSystemFingerprint write FSystemFingerprint;

    /// <summary>
    /// Developer-defined metadata associated with the stored completion.
    /// </summary>
    /// <remarks>
    /// The API deserializer shields free-form JSON fields before the first mapping pass;
    /// this property therefore stores metadata as compact JSON text.
    /// </remarks>
    property Metadata: string read FMetadata write FMetadata;

    /// <summary>
    /// The object type returned by the service.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Token usage information for the chat completion.
    /// </summary>
    property Usage: TUsage read FUsage write FUsage;

    /// <summary>
    /// Optional obfuscation metadata returned by streaming responses.
    /// </summary>
    property Obfuscation: string read FObfuscation write FObfuscation;

    destructor Destroy; override;
  end;

  TChatCompletionMessage = class(TJSONFingerprint)
  private
    FContent: string;
    [JSONMarshalled(False)]
    FRawContent: string;
    [JSONMarshalled(False)]
    FContentKind: TChatContentKind;
    FId: string;
    FRefusal: string;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FAnnotations: TArray<TAnnotation>;
    FAudio: TAudio;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolCall>;
  protected
    /// <summary>
    /// Runs the second deserialization pass for direct stored message parsing.
    /// </summary>
    procedure ContentUpdate; override;

    /// <summary>
    /// Finalizes the stored message deserialization lifecycle.
    /// </summary>
    procedure AfterDeserialize; override;
  public
    /// <summary>
    /// Updates the content fields from a raw JSON root and a node path.
    /// </summary>
    procedure HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);

    /// <summary>
    /// Text content when the message content is a JSON string.
    /// </summary>
    property Content: string read FContent write FContent;

    /// <summary>
    /// Raw JSON or text extracted from the original content node.
    /// </summary>
    property RawContent: string read FRawContent write FRawContent;

    /// <summary>
    /// The JSON shape of the original content node.
    /// </summary>
    property ContentKind: TChatContentKind read FContentKind;

    /// <summary>
    /// The unique identifier for this chat message.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// Refusal text returned by the model, when present.
    /// </summary>
    property Refusal: string read FRefusal write FRefusal;

    /// <summary>
    /// The role of the message author.
    /// </summary>
    property Role: TRole read FRole write FRole;

    /// <summary>
    /// Annotations attached to the message.
    /// </summary>
    property Annotations: TArray<TAnnotation> read FAnnotations write FAnnotations;

    /// <summary>
    /// Audio data attached to the message, when present.
    /// </summary>
    property Audio: TAudio read FAudio write FAudio;

    /// <summary>
    /// Tool calls requested by this message.
    /// </summary>
    property ToolCalls: TArray<TToolCall> read FToolCalls write FToolCalls;

    destructor Destroy; override;
  end;

  TChatMessages = class(TJSONFingerprint)
  private
    FData: TArray<TChatCompletionMessage>;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
    [JsonNameAttribute('last_id')]
    FLastId: string;
    FObject: string;
  protected
    /// <summary>
    /// Runs the second deserialization pass for stored message content.
    /// </summary>
    procedure ContentUpdate; override;

    /// <summary>
    /// Finalizes the stored message list deserialization lifecycle.
    /// </summary>
    procedure AfterDeserialize; override;
  public
    /// <summary>
    /// The messages in the current page.
    /// </summary>
    property Data: TArray<TChatCompletionMessage> read FData write FData;

    /// <summary>
    /// The ID of the first message in this page.
    /// </summary>
    property FirstId: string read FFirstId write FFirstId;

    /// <summary>
    /// Indicates whether more messages are available.
    /// </summary>
    property HasMore: Boolean read FHasMore write FHasMore;

    /// <summary>
    /// The ID of the last message in this page.
    /// </summary>
    property LastId: string read FLastId write FLastId;

    /// <summary>
    /// The object type returned by the service.
    /// </summary>
    property &Object: string read FObject write FObject;

    destructor Destroy; override;
  end;

  TChatCompletion = class(TJSONFingerprint)
  private
    FData: TArray<TChat>;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
    [JsonNameAttribute('last_id')]
    FLastId: string;
    FObject: string;
  protected
    /// <summary>
    /// Runs the second deserialization pass for nested chat content.
    /// </summary>
    procedure ContentUpdate; override;

    /// <summary>
    /// Finalizes the chat completion list deserialization lifecycle.
    /// </summary>
    procedure AfterDeserialize; override;
  public
    /// <summary>
    /// The chat completions in the current page.
    /// </summary>
    property Data: TArray<TChat> read FData write FData;

    /// <summary>
    /// The ID of the first chat completion in this page.
    /// </summary>
    property FirstId: string read FFirstId write FFirstId;

    /// <summary>
    /// Indicates whether more chat completions are available.
    /// </summary>
    property HasMore: Boolean read FHasMore write FHasMore;

    /// <summary>
    /// The ID of the last chat completion in this page.
    /// </summary>
    property LastId: string read FLastId write FLastId;

    /// <summary>
    /// The object type returned by the service.
    /// </summary>
    property &Object: string read FObject write FObject;

    destructor Destroy; override;
  end;

  TChatDelete = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    FDeleted: Boolean;
  public
    /// <summary>
    /// The identifier of the deleted chat completion.
    /// </summary>
    property Id: string read FId write FId;

    /// <summary>
    /// The object type returned by the service.
    /// </summary>
    property &Object: string read FObject write FObject;

    /// <summary>
    /// Indicates whether the chat completion was deleted.
    /// </summary>
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

implementation

uses
  System.DateUtils;

type
  TChatDTOJsonPath = record
  public
    class function Combine(const BasePath, ChildPath: string): string; static;
  end;

  TChatDTOUnixTime = record
  public
    class function ToUtcString(const Value: Int64): string; static;
  end;

  TChatDTOContentReader = record
  public
    class procedure ExtractNode(const Root: TJsonReader; const NodePath: string;
      var Content: string; var RawContent: string; var ContentKind: TChatContentKind); static;
  end;

{ TChatDTOJsonPath }

class function TChatDTOJsonPath.Combine(const BasePath, ChildPath: string): string;
begin
  if BasePath.Trim.IsEmpty then
    Exit(ChildPath);
  if ChildPath.Trim.IsEmpty then
    Exit(BasePath);
  Result := BasePath + '.' + ChildPath;
end;

{ TChatDTOUnixTime }

class function TChatDTOUnixTime.ToUtcString(const Value: Int64): string;
begin
  if Value <= 0 then
    Exit(EmptyStr);

  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss"Z"', UnixToDateTime(Value, True));
end;

{ TChatDTOContentReader }

class procedure TChatDTOContentReader.ExtractNode(const Root: TJsonReader;
  const NodePath: string; var Content, RawContent: string;
  var ContentKind: TChatContentKind);
begin
  ContentKind := TChatContentKind.Missing;

  if not Root.IsValid then
    Exit;

  var TargetPath := TChatDTOJsonPath.Combine(NodePath, 'content');
  if Root.Value(TargetPath) = nil then
    Exit;

  if Root.IsNullNode(TargetPath) then
    begin
      Content := EmptyStr;
      RawContent := EmptyStr;
      ContentKind := TChatContentKind.Null;
      Exit;
    end;

  RawContent := Root.ExtractSubJson(TargetPath, EmptyStr);

  if Root.IsStringNode(TargetPath) then
    ContentKind := TChatContentKind.Text
  else
    ContentKind := TChatContentKind.Json;

  Content := RawContent;
end;

{ TLogprobsDetail }

destructor TLogprobsDetail.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

{ TLogprobs }

destructor TLogprobs.Destroy;
begin
  for var Item in FContent do
    Item.Free;
  for var Item in FRefusal do
    Item.Free;
  inherited;
end;

{ TToolCall }

destructor TToolCall.Destroy;
begin
  FFunction.Free;
  inherited;
end;

{ TAudioData }

function TAudioData.GetExpiresAtAsString: string;
begin
  Result := TChatDTOUnixTime.ToUtcString(FExpiresAt);
end;

{ TAudio }

function TAudio.GetStream: TStream;
begin
  Result := TMemoryStream.Create;
  if not TMediaCodec.TryDecodeBase64ToStream(Data, Result) then
    begin
      Result.Size := 0;
      Result.Position := 0;
    end;
end;

procedure TAudio.SaveToFile(const FileName: string; const RaiseError: Boolean);
begin
  if FileName.Trim.IsEmpty then
    begin
      if RaiseError then
        raise Exception.Create('File record aborted. SaveToFile requires a filename.');
      Exit;
    end;

  FFileName := FileName;
  if (not TMediaCodec.TryDecodeBase64ToFile(Data, FileName)) and RaiseError then
    raise Exception.CreateFmt('File record aborted. Unable to decode audio data into "%s".', [FileName]);
end;

{ TAnnotation }

destructor TAnnotation.Destroy;
begin
  FUrlCitation.Free;
  inherited;
end;

{ TDelta }

procedure TDelta.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TDelta.ContentUpdate;
begin
  inherited;
  HydrateContentFromRoot(TJsonReader.Parse(JSONResponse), EmptyStr);
end;

destructor TDelta.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

procedure TDelta.HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);
begin
  TChatDTOContentReader.ExtractNode(Root, NodePath, FContent, FRawContent, FContentKind);
end;

{ TChatMessage }

procedure TChatMessage.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TChatMessage.ContentUpdate;
begin
  inherited;
  HydrateContentFromRoot(TJsonReader.Parse(JSONResponse), EmptyStr);
end;

destructor TChatMessage.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  for var Item in FAnnotations do
    Item.Free;
  FAudio.Free;
  inherited;
end;

procedure TChatMessage.HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);
begin
  TChatDTOContentReader.ExtractNode(Root, NodePath, FContent, FRawContent, FContentKind);
end;

{ TChoice }

destructor TChoice.Destroy;
begin
  FMessage.Free;
  FLogprobs.Free;
  FDelta.Free;
  inherited;
end;

{ TUsage }

destructor TUsage.Destroy;
begin
  FCompletionTokensDetails.Free;
  FPromptTokensDetails.Free;
  inherited;
end;

{ TChat }

procedure TChat.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TChat.ContentUpdate;
begin
  inherited;
  HydrateContentFromRoot(TJsonReader.Parse(JSONResponse), EmptyStr);
end;

destructor TChat.Destroy;
begin
  for var Item in FChoices do
    Item.Free;
  FUsage.Free;
  inherited;
end;

function TChat.GetCreatedAsString: string;
begin
  Result := TChatDTOUnixTime.ToUtcString(FCreated);
end;

procedure TChat.HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);
begin
  if not Root.IsValid then
    Exit;

  for var Index := 0 to High(FChoices) do
    begin
      var Choice := FChoices[Index];
      if Choice = nil then
        Continue;

      var ChoicePath := TChatDTOJsonPath.Combine(NodePath, Format('choices[%d]', [Index]));

      if Assigned(Choice.Message) then
        Choice.Message.HydrateContentFromRoot(Root, TChatDTOJsonPath.Combine(ChoicePath, 'message'));

      if Assigned(Choice.Delta) then
        Choice.Delta.HydrateContentFromRoot(Root, TChatDTOJsonPath.Combine(ChoicePath, 'delta'));
    end;
end;

{ TChatCompletionMessage }

procedure TChatCompletionMessage.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TChatCompletionMessage.ContentUpdate;
begin
  inherited;
  HydrateContentFromRoot(TJsonReader.Parse(JSONResponse), EmptyStr);
end;

destructor TChatCompletionMessage.Destroy;
begin
  for var Item in FAnnotations do
    Item.Free;
  FAudio.Free;
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

procedure TChatCompletionMessage.HydrateContentFromRoot(const Root: TJsonReader; const NodePath: string);
begin
  TChatDTOContentReader.ExtractNode(Root, NodePath, FContent, FRawContent, FContentKind);
end;

{ TChatMessages }

procedure TChatMessages.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TChatMessages.ContentUpdate;
begin
  inherited;

  var Root := TJsonReader.Parse(JSONResponse);
  if not Root.IsValid then
    Exit;

  for var Index := 0 to High(FData) do
    if Assigned(FData[Index]) then
      FData[Index].HydrateContentFromRoot(Root, Format('data[%d]', [Index]));
end;

destructor TChatMessages.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TChatCompletion }

procedure TChatCompletion.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TChatCompletion.ContentUpdate;
begin
  inherited;

  var Root := TJsonReader.Parse(JSONResponse);
  if not Root.IsValid then
    Exit;

  for var Index := 0 to High(FData) do
    if Assigned(FData[Index]) then
      FData[Index].HydrateContentFromRoot(Root, Format('data[%d]', [Index]));
end;

destructor TChatCompletion.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;



end.


