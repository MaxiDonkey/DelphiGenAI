unit GenAI.Chat;

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Schema, GenAI.Chat.StreamingCallback,
  GenAI.Types, GenAI.Chat.StreamingInterface, GenAI.Functions.Tools, GenAI.Functions.Core,
  GenAI.Async.Params, GenAI.Async.Support;

type
  TImageUrl = class(TJSONParam)
  public
    function Url(const Value: string): TImageUrl;
    function Detail(const Value: TImageDetail): TImageUrl;
    class function New(const PathLocation: string; const Detail: TImageDetail = id_auto): TImageUrl;
  end;

  TInputAudio = class(TJSONParam)
  public
    function Data(const Value: string): TInputAudio;
    function Format(const Value: string): TInputAudio; overload;
    function Format(const Value: TAudioFormat): TInputAudio; overload;
    class function New(const PathLocation: string): TInputAudio; overload;
  end;

  TContentParams = class(TJSONParam)
  private
    class function Extract(const Value: string; var Detail: TImageDetail): string;
  public
    function &Type(const Value: string): TContentParams;
    function Text(const Value: string): TContentParams;
    function ImageUrl(const Value: TImageUrl): TContentParams; overload;
    function InputAudio(const Value: TInputAudio): TContentParams; overload;
    class function AddFile(const FileLocation: string): TContentParams;
  end;

  TFunctionParams = class(TJSONParam)
  public
    function Name(const Value: string): TFunctionParams;
    function Arguments(const Value: string): TFunctionParams;
  end;

  TToolCallsParams = class(TJSONParam)
  public
    function Id(const Value: string): TToolCallsParams;
    function &Type(const Value: string): TToolCallsParams; overload;
    function &Type(const Value: TToolCalls): TToolCallsParams; overload;
    function &Function(const Name: string; const Arguments: string): TToolCallsParams;
    class function New(const Id: string; const Name: string; const Arguments: string): TToolCallsParams;
  end;

  TAssistantContentParams = class(TJSONParam)
  public
    function &Type(const Value: string): TAssistantContentParams;
    function Text(const Value: string): TAssistantContentParams;
    function Refusal(const Value: string): TAssistantContentParams;
    class function AddText(const AType: string; const Value: string): TAssistantContentParams;
    class function AddRefusal(const AType: string; const Value: string): TAssistantContentParams;
  end;

  TMessagePayload = class(TJSONParam)
  public
    function Role(const Value: TRole): TMessagePayload; overload;
    function Role(const Value: string): TMessagePayload; overload;
    function Content(const Value: string): TMessagePayload; overload;
    function Content(const Value: TJSONArray): TMessagePayload; overload;
    function Content(const Value: TArray<TAssistantContentParams>): TMessagePayload; overload;
    function Content(const Value: TJSONObject): TMessagePayload; overload;
    function Name(const Value: string): TMessagePayload;
    function Refusal(const Value: string): TMessagePayload;
    function Audio(const Value: string): TMessagePayload;
    function ToolCalls(const Value: TArray<TToolCallsParams>): TMessagePayload;
    function ToolCallId(const Value: string): TMessagePayload;
    class function New(const Role: TRole; const Content: string; const Name: string = ''):TMessagePayload; overload;
    class function Developer(const Content: string; const Name: string = ''):TMessagePayload;
    class function System(const Content: string; const Name: string = ''):TMessagePayload;
    class function User(const Content: string; const Name: string = ''):TMessagePayload; overload;
    class function User(const Content: string; const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
    class function User(const Docs: TArray<string>; const Name: string = ''):TMessagePayload; overload;
    class function Assistant(const ParamProc: TProcRef<TMessagePayload>): TMessagePayload; overload;
    class function Assistant(const Value: TMessagePayload): TMessagePayload; overload;
    class function Tool(const Content: string; const ToolCallId: string): TMessagePayload;
  end;

  TPredictionPartParams = class(TJSONParam)
  public
    function &Type(const Value: string): TPredictionPartParams;
    function Text(const Value: string): TPredictionPartParams;
    class function New(const AType: string; const Text: string): TPredictionPartParams;
  end;

  TPredictionParams = class(TJSONParam)
  public
    function &Type(const Value: string): TPredictionParams;
    function Content(const Value: string): TPredictionParams; overload;
    function Content(const Value: TArray<TPredictionPartParams>): TPredictionParams; overload;
    class function New(const Value: string): TPredictionParams; overload;
    class function New(const Value: TArray<TPredictionPartParams>): TPredictionParams; overload;
  end;

  TAudioParams = class(TJSONParam)
  public
    function Voice(const Value: TChatVoice): TAudioParams;
    function Format(const Value: TAudioFormat): TAudioParams;
  end;

  TToolChoiceFunctionParams = class(TJSONParam)
  public
    function Name(const Value: string): TToolChoiceFunctionParams;
  end;

  TToolChoiceParams = class(TJSONParam)
  public
    function &Type(const Value: string): TToolChoiceParams;
    function &Function(const Name: string): TToolChoiceParams;
    class function New(const Name: string): TToolChoiceParams;
  end;

  TChatParams = class(TJSONParam)
  public
    function Messages(const Value: TArray<TMessagePayload>): TChatParams; overload;
    function Messages(const Value: TJSONObject): TChatParams; overload;
    function Messages(const Value: TJSONArray): TChatParams; overload;
    function Model(const Value: string): TChatParams;
    function Store(const Value: Boolean): TChatParams;
    function ReasoningEffort(const Value: TReasoningEffort): TChatParams; overload;
    function ReasoningEffort(const Value: string): TChatParams; overload;
    function Metadata(const Value: TJSONObject): TChatParams;
    function FrequencyPenalty(const Value: Double): TChatParams;
    function LogitBias(const Value: TJSONObject): TChatParams;
    function Logprobs(const Value: Boolean): TChatParams;
    function TopLogprobs(const Value: Integer): TChatParams;
    function MaxCompletionTokens(const Value: Integer): TChatParams;
    function N(const Value: Integer): TChatParams;
    function Modalities(const Value: TArray<string>): TChatParams; overload;
    function Modalities(const Value: TArray<TModalities>): TChatParams; overload;
    function Prediction(const Value: string): TChatParams; overload;
    function Prediction(const Value: TArray<TPredictionPartParams>): TChatParams; overload;
    function Audio(const Voice: TChatVoice; const Format: TAudioFormat): TChatParams; overload;
    function Audio(const Voice, Format: string): TChatParams; overload;
    function PresencePenalty(const Value: Double): TChatParams;
    function ResponseFormat(const Value: TSchemaParams): TChatParams; overload;
    function ResponseFormat(const ParamProc: TProcRef<TSchemaParams>): TChatParams; overload;
    function ResponseFormat(const Value: TJSONObject): TChatParams; overload;
    function Seed(const Value: Integer): TChatParams;
    function ServiceTier(const Value: string): TChatParams;
    function Stop(const Value: string): TChatParams; overload;
    function Stop(const Value: TArray<string>): TChatParams; overload;
    function Stream(const Value: Boolean = True): TChatParams;
    function StreamOptions(const Value: TJSONObject): TChatParams; overload;
    function StreamOptions(const IncludeUsage: Boolean): TChatParams; overload;
    function Temperature(const Value: Double): TChatParams;
    function TopP(const Value: Double): TChatParams;
    function Tools(const Value: TArray<TChatMessageTool>): TChatParams; overload;
    function Tools(const Value: TArray<IFunctionCore>): TChatParams; overload;
    function Tools(const Value: TJSONObject): TChatParams; overload;
    function ToolChoice(const Value: string): TChatParams; overload;
    function ToolChoice(const Value: TToolChoice): TChatParams; overload;
    function ToolChoice(const Value: TJSONObject): TChatParams; overload;
    function ToolChoice(const Value: TToolChoiceParams): TChatParams; overload;
    function ParallelToolCalls(const Value: Boolean): TChatParams;
    function User(const Value: string): TChatParams;
  end;

  TTopLogprobs = class
  private
    FToken: string;
    FLogprob: Double;
    FBytes: TArray<Int64>;
  public
    property Token: string read FToken write FToken;
    property Logprob: Double read FLogprob write FLogprob;
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
    property Token: string read FToken write FToken;
    property Logprob: Double read FLogprob write FLogprob;
    property Bytes: TArray<Int64> read FBytes write FBytes;
    property TopLogprobs: TArray<TTopLogprobs> read FTopLogprobs write FTopLogprobs;
    destructor Destroy; override;
  end;

  TLogprobs = class
  private
    FContent: TArray<TLogprobsDetail>;
    FRefusal: TArray<TLogprobsDetail>;
  public
    property Content: TArray<TLogprobsDetail> read FContent write FContent;
    property Refusal: TArray<TLogprobsDetail> read FRefusal write FRefusal;
    destructor Destroy; override;
  end;

  TFunction = class
  private
    FName: string;
    FArguments: string;
  public
    property Name: string read FName write FName;
    property Arguments: string read FArguments write FArguments;
  end;

  TToolcall = class
  private
    FId: string;
    [JsonReflectAttribute(ctString, rtString, TToolCallsInterceptor)]
    FType: TToolCalls;
    FFunction: TFunction;
  public
    property Id: string read FId write FId;
    property &Type: TToolCalls read FType write FType;
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
  public
    property Id: string read FId write FId;
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;
    property Data: string read FData write FData;
    property Transcript: string read FTranscript write FTranscript;
  end;

  TAudio = class(TAudioData)
  private
    FFileName: string;
  public
    function GetStream: TStream;
    procedure SaveToFile(const FileName: string);
    property FileName: string read FFileName write FFileName;
  end;

  TDelta = class
  private
    FContent: string;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolcall>;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FRefusal: string;
  public
    property Content: string read FContent write FContent;
    property ToolCalls: TArray<Ttoolcall> read FToolCalls write FToolCalls;
    property Role: TRole read FRole write FRole;
    property Refusal: string read FRefusal write FRefusal;
    destructor Destroy; override;
  end;

  TMessage = class
  private
    FContent: string;
    FRefusal: string;
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolcall>;
    [JsonReflectAttribute(ctString, rtString, TRoleInterceptor)]
    FRole: TRole;
    FAudio: TAudio;
  public
    property Content: string read FContent write FContent;
    property Refusal: string read FRefusal write FRefusal;
    property ToolCalls: TArray<Ttoolcall> read FToolCalls write FToolCalls;
    property Role: TRole read FRole write FRole;
    property Audio: TAudio read FAudio write FAudio;
    destructor Destroy; override;
  end;

  TChoice = class
  private
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    [JsonNameAttribute('finish_reason')]
    FFinishReason: TFinishReason;
    FIndex: Int64;
    FMessage: TMessage;
    FLogprobs: TLogprobs;
    FDelta: TDelta;
  public
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;
    property Index: Int64 read FIndex write FIndex;
    property Message: TMessage read FMessage write FMessage;
    property Logprobs: TLogprobs read FLogprobs write FLogprobs;
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
    property AcceptedPredictionTokens: Int64 read FAcceptedPredictionTokens write FAcceptedPredictionTokens;
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;
    property ReasoningTokens: Int64 read FReasoningTokens write FReasoningTokens;
    property RejectedPredictionTokens: Int64 read FRejectedPredictionTokens write FRejectedPredictionTokens;
  end;

  TPromptDetail = class
  private
    [JsonNameAttribute('audio_tokens')]
    FAudioTokens: Int64;
    [JsonNameAttribute('cached_tokens')]
    FCachedTokens: Int64;
  public
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;
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
    property CompletionTokens: Int64 read FCompletionTokens write FCompletionTokens;
    property PromptTokens: Int64 read FPromptTokens write FPromptTokens;
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;
    property CompletionTokensDetails: TCompletionDetail read FCompletionTokensDetails write FCompletionTokensDetails;
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
    FObject: string;
    FUsage: TUsage;
  public
    property Id: string read FId write FId;
    property Choices: TArray<TChoice> read FChoices write FChoices;
    property Created: Int64 read FCreated write FCreated;
    property Model: string read FModel write FModel;
    property ServiceTier: string read FServiceTier write FServiceTier;
    property SystemFingerprint: string read FSystemFingerprint write FSystemFingerprint;
    property &Object: string read FObject write FObject;
    property Usage: TUsage read FUsage write FUsage;
    destructor Destroy; override;
  end;

  TAsynChat = TAsynCallBack<TChat>;

  TAsynChatStream = TAsynStreamCallBack<TChat>;

  TChatRoute = class(TGenAIRoute)
    procedure AsynCreate(ParamProc: TProc<TChatParams>; CallBacks: TFunc<TAsynChat>);
    procedure AsynCreateStream(ParamProc: TProc<TChatParams>; CallBacks: TFunc<TAsynChatStream>);
    function Create(ParamProc: TProc<TChatParams>): TChat;
    function CreateStream(ParamProc: TProc<TChatParams>; Event: TStreamCallbackEvent<TChat>): Boolean;
  end;

implementation

uses
  System.StrUtils, GenAI.Httpx, GenAI.NetEncoding.Base64, REST.Json;

{ TMessagePayload }

function TMessagePayload.Content(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('content', Value));
end;

class function TMessagePayload.Assistant(
  const ParamProc: TProcRef<TMessagePayload>): TMessagePayload;
begin
  Result := TMessagePayload.Create.Role(TRole.assistant);
  if Assigned(ParamProc) then
    begin
      ParamProc(Result);
    end;
end;

class function TMessagePayload.Assistant(
  const Value: TMessagePayload): TMessagePayload;
begin
  Result := Value;
end;

function TMessagePayload.Audio(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('audio', TJSONObject.Create.AddPair('id', Value)));
end;

function TMessagePayload.Content(
  const Value: TArray<TAssistantContentParams>): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TMessagePayload(Add('content', JSONArray));
end;

function TMessagePayload.Content(const Value: TJSONArray): TMessagePayload;
begin
  Result := TMessagePayload(Add('content', Value));
end;

function TMessagePayload.Content(const Value: TJSONObject): TMessagePayload;
begin
  Result := TMessagePayload(Add('content', Value));
end;

class function TMessagePayload.Developer(const Content,
  Name: string): TMessagePayload;
begin
  Result := New(TRole.developer, Content, Name);
end;

function TMessagePayload.Name(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('name', Value));
end;

class function TMessagePayload.New(const Role: TRole; const Content,
  Name: string): TMessagePayload;
begin
  Result := TMessagePayload.Create.Role(Role).Content(Content);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

function TMessagePayload.Refusal(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('refusal', Value));
end;

function TMessagePayload.Role(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('role', TRole.Create(Value).ToString));
end;

function TMessagePayload.Role(const Value: TRole): TMessagePayload;
begin
  Result := TMessagePayload(Add('role', Value.ToString));
end;

class function TMessagePayload.System(const Content,
  Name: string): TMessagePayload;
begin
  Result := New(TRole.system, Content, Name);
end;

class function TMessagePayload.Tool(const Content,
  ToolCallId: string): TMessagePayload;
begin
  Result := New(TRole.tool, Content).ToolCallId(ToolCallId);
end;

function TMessagePayload.ToolCallId(const Value: string): TMessagePayload;
begin
  Result := TMessagePayload(Add('tool_call_id', Value));
end;

function TMessagePayload.ToolCalls(
  const Value: TArray<TToolCallsParams>): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TMessagePayload(Add('tool_calls', JSONArray));
end;

class function TMessagePayload.User(const Content,
  Name: string): TMessagePayload;
begin
  Result := New(TRole.User, Content, Name);
end;

class function TMessagePayload.User(const Content: string;
  const Docs: TArray<string>; const Name: string): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  JSONArray.Add(TContentParams.Create.&Type('text').Text(Content).Detach);

  for var Item in Docs do
    JSONArray.Add(TContentParams.AddFile(Item).Detach);

  Result := TMessagePayload.Create.Role(TRole.user).Content(JSONArray);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

class function TMessagePayload.User(const Docs: TArray<string>;
  const Name: string = ''): TMessagePayload;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Docs do
    JSONArray.Add(TContentParams.AddFile(Item).Detach);

  Result := TMessagePayload.Create.Role(TRole.user).Content(JSONArray);
  if not Name.IsEmpty then
    Result := Result.Name(Name);
end;

{ TChatParams }

function TChatParams.Audio(const Voice: TChatVoice;
  const Format: TAudioFormat): TChatParams;
begin
  var Value := TAudioParams.Create.Voice(Voice).Format(Format);
  Result := TChatParams(Add('audio', Value.Detach));
end;

function TChatParams.Audio(const Voice, Format: string): TChatParams;
begin
  Result := Audio(TChatVoice.Create(Voice), TAudioFormat.Create(Format));
end;

function TChatParams.FrequencyPenalty(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('frequency_penalty', Value));
end;

function TChatParams.LogitBias(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('logit_bias', Value));
end;

function TChatParams.Logprobs(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('logprobs', Value));
end;

function TChatParams.MaxCompletionTokens(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('max_completion_tokens', Value));
end;

function TChatParams.Messages(
  const Value: TArray<TMessagePayload>): TChatParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TChatParams(Add('messages', JSONArray));
end;

function TChatParams.Messages(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('messages', Value));
end;

function TChatParams.Messages(const Value: TJSONArray): TChatParams;
begin
  Result := TChatParams(Add('messages', Value));
end;

function TChatParams.Metadata(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('metadata', Value));
end;

function TChatParams.Modalities(const Value: TArray<string>): TChatParams;
var
  Checks: TArray<string>;
begin
  {--- Check string values }
  for var Item in Value do
    Checks := Checks + [TModalities.Create(Item).ToString];
  Result := TChatParams(Add('modalities', Checks));
end;

function TChatParams.Modalities(const Value: TArray<TModalities>): TChatParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToString);
  Result := TChatParams(Add('modalities', JSONArray));
end;

function TChatParams.Model(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('model', Value));
end;

function TChatParams.N(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('n', Value));
end;

function TChatParams.ParallelToolCalls(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('parallel_tool_calls', Value));
end;

function TChatParams.Prediction(
  const Value: TArray<TPredictionPartParams>): TChatParams;
begin
  Result := TChatParams(Add('prediction', TPredictionParams.New(Value).Detach));
end;

function TChatParams.PresencePenalty(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('presence_penalty', Value));
end;

function TChatParams.Prediction(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('prediction', TPredictionParams.New(Value).Detach));
end;

function TChatParams.ReasoningEffort(
  const Value: TReasoningEffort): TChatParams;
begin
  Result := TChatParams(Add('reasoning_effort', Value.ToString));
end;

function TChatParams.ReasoningEffort(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('reasoning_effort', TReasoningEffort.Create(Value).ToString));
end;

function TChatParams.ResponseFormat(
  const ParamProc: TProcRef<TSchemaParams>): TChatParams;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TSchemaParams.Create;
      ParamProc(Value);
      Result := TChatParams(Add('response_format', Value.Detach));
    end
  else Result := Self;
end;

function TChatParams.ResponseFormat(const Value: TSchemaParams): TChatParams;
begin
  Result := TChatParams(Add('response_format', Value.Detach));
end;

function TChatParams.ResponseFormat(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('response_format', Value));
end;

function TChatParams.Seed(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('seed', Value));
end;

function TChatParams.ServiceTier(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('service_tier', Value));
end;

function TChatParams.Stop(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Stop(const Value: TArray<string>): TChatParams;
begin
  Result := TChatParams(Add('stop', Value));
end;

function TChatParams.Store(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('store', Value));
end;

function TChatParams.Stream(const Value: Boolean): TChatParams;
begin
  Result := TChatParams(Add('stream', Value));
end;

function TChatParams.StreamOptions(const IncludeUsage: Boolean): TChatParams;
begin
  Result := StreamOptions(TJSONObject.Create.AddPair('stream_options', IncludeUsage));
end;

function TChatParams.StreamOptions(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('stream_options', Value));
end;

function TChatParams.Temperature(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('temperature', Value));
end;

function TChatParams.ToolChoice(const Value: string): TChatParams;
begin
  var index := IndexStr(Value.ToLower, ['none', 'auto', 'required']);
  if index > -1 then
    Result := TChatParams(Add('tool_choice', Value)) else
    Result := ToolChoice(TToolChoiceParams.New(Value));
end;

function TChatParams.ToolChoice(const Value: TToolChoice): TChatParams;
begin
  Result := ToolChoice(Value.ToString);
end;

function TChatParams.ToolChoice(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('tool_choice', Value));
end;

function TChatParams.ToolChoice(const Value: TToolChoiceParams): TChatParams;
begin
  Result := TChatParams(Add('tool_choice', Value.Detach));
end;

function TChatParams.Tools(const Value: TJSONObject): TChatParams;
begin
  Result := TChatParams(Add('tools', Value));
end;

function TChatParams.Tools(const Value: TArray<IFunctionCore>): TChatParams;
var
  Funcs: TArray<TChatMessageTool>;
begin
  for var Item in Value do
    Funcs := Funcs + [TChatMessageTool.Add(Item)];
  Result := Tools(Funcs);
end;

function TChatParams.Tools(const Value: TArray<TChatMessageTool>): TChatParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.ToJson);
  Result := TChatParams(Add('tools', JSONArray));
end;

function TChatParams.TopLogprobs(const Value: Integer): TChatParams;
begin
  Result := TChatParams(Add('top_logprobs', Value));
end;

function TChatParams.TopP(const Value: Double): TChatParams;
begin
  Result := TChatParams(Add('top_p', Value));
end;

function TChatParams.User(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('user', Value));
end;

{ TContentParams }

class function TContentParams.AddFile(
  const FileLocation: string): TContentParams;
var
  MimeType: string;
  Detail: TImageDetail;
begin
  {--- Param detail extraction }
  var Location := Extract(FileLocation, Detail);

  {--- Retrieve mimetype }
  if Location.ToLower.StartsWith('http') then
    MimeType := THttpx.GetMimeType(Location) else
    MimeType := GetMimeType(Location);

  {--- Audio file managment }
  var index := IndexStr(MimeType, AudioTypeAccepted);
  if index <> -1 then
    Exit(TContentParams.Create.&Type('input_audio').InputAudio(TInputAudio.New(Location)));

  {--- Image file managment }
  index := IndexStr(MimeType, ImageTypeAccepted);
  if index <> -1 then
    Exit(TContentParams.Create.&Type('image_url').ImageUrl(TImageUrl.New(Location, Detail)));

  raise Exception.CreateFmt('%s : File not managed', [Location]);
end;

class function TContentParams.Extract(const Value: string;
  var Detail: TImageDetail): string;
begin
  Detail := id_auto;
  var index := Value.Trim.Tolower.IndexOf('detail');
  if index > -1 then
    begin
      Result := Value.Substring(0, index-1);
      var Details := Value.Substring(index, Value.Length).Replace(' ', '').Split(['=']);
      if Length(Details) = 2 then
        Detail := TImageDetail.Create(Details[1]);
    end
  else
    begin
      Result := Value.Trim;
    end;
end;

function TContentParams.ImageUrl(const Value: TImageUrl): TContentParams;
begin
  Result := TContentParams(Add('image_url', Value.Detach));
end;

function TContentParams.InputAudio(const Value: TInputAudio): TContentParams;
begin
  Result := TContentParams(Add('input_audio', Value.Detach));
end;

function TContentParams.Text(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('text', Value));
end;

function TContentParams.&Type(const Value: string): TContentParams;
begin
  Result := TContentParams(Add('type', Value));
end;

{ TImageUrl }

function TImageUrl.Detail(const Value: TImageDetail): TImageUrl;
begin
  Result := TImageUrl(Add('detail', Value.ToString));
end;

class function TImageUrl.New(const PathLocation: string; const Detail: TImageDetail): TImageUrl;
begin
  Result := TImageUrl.Create.Url( ProcessUrlOrEncodeData(PathLocation) );
  if Detail <> id_auto then
    Result := Result.Detail(Detail);
end;

function TImageUrl.Url(const Value: string): TImageUrl;
begin
  Result := TImageUrl(Add('url', Value));
end;

{ TInputAudio }

function TInputAudio.Data(const Value: string): TInputAudio;
begin
  Result := TInputAudio(Add('data', Value));
end;

function TInputAudio.Format(const Value: string): TInputAudio;
begin
  Result := TInputAudio(Add('format', Value));
end;

function TInputAudio.Format(const Value: TAudioFormat): TInputAudio;
begin
  Result := Format(Value.ToString);
end;

class function TInputAudio.New(const PathLocation: string): TInputAudio;
var
  MimeType: string;
begin
  if PathLocation.ToLower.StartsWith('http') then
    Result := TInputAudio.Create.Data(THttpx.LoadDataToBase64(PathLocation, MimeType)) else
    Result := TInputAudio.Create.Data(EncodeBase64(PathLocation, MimeType));
  Result := Result.Format(TAudioFormat.InputMimeType(MimeType));
end;

{ TToolCallsParams }

function TToolCallsParams.&Type(const Value: string): TToolCallsParams;
begin
  Result := TToolCallsParams(Add('type', TToolCalls.Create(Value).ToString));
end;

function TToolCallsParams.&Type(const Value: TToolCalls): TToolCallsParams;
begin
  Result := TToolCallsParams(Add('type', Value.ToString));
end;

function TToolCallsParams.&Function(const Name,
  Arguments: string): TToolCallsParams;
begin
  var Func := TFunctionParams.Create.Name(Name).Arguments(Arguments);
  Result := TToolCallsParams(Add('function', Func.Detach));
end;

function TToolCallsParams.Id(const Value: string): TToolCallsParams;
begin
  Result := TToolCallsParams(Add('id', Value));
end;

class function TToolCallsParams.New(const Id, Name,
  Arguments: string): TToolCallsParams;
begin
  Result := TToolCallsParams.Create.Id(Id).&Type(tc_function).&Function(Name, Arguments);
end;

{ TFunctionParams }

function TFunctionParams.Arguments(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('arguments', Value));
end;

function TFunctionParams.Name(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('name', Value));
end;

{ TAssistantContentParams }

class function TAssistantContentParams.AddRefusal(const AType,
  Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams.Create.&Type(AType).Refusal(Value);
end;

class function TAssistantContentParams.AddText(const AType,
  Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams.Create.&Type(AType).Text(Value);
end;

function TAssistantContentParams.Refusal(
  const Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams(Add('refusal', Value));
end;

function TAssistantContentParams.Text(
  const Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams(Add('text', Value));
end;

function TAssistantContentParams.&Type(
  const Value: string): TAssistantContentParams;
begin
  Result := TAssistantContentParams(Add('type', Value));
end;

{ TPredictionParams }

function TPredictionParams.Content(
  const Value: string): TPredictionParams;
begin
  Result := TPredictionParams(Add('content', Value));
end;

function TPredictionParams.Content(
  const Value: TArray<TPredictionPartParams>): TPredictionParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TPredictionParams(Add('content', JSONArray));
end;

class function TPredictionParams.New(
  const Value: TArray<TPredictionPartParams>): TPredictionParams;
begin
  Result := TPredictionParams.Create.&Type('content').Content(Value);
end;

class function TPredictionParams.New(const Value: string): TPredictionParams;
begin
  Result := TPredictionParams.Create.&Type('content').Content(Value);
end;

function TPredictionParams.&Type(const Value: string): TPredictionParams;
begin
  Result := TPredictionParams(Add('type', Value));
end;

{ TPredictionPartParams }

class function TPredictionPartParams.New(const AType,
  Text: string): TPredictionPartParams;
begin
  Result := TPredictionPartParams.Create.&Type(AType).Text(Text);
end;

function TPredictionPartParams.Text(
  const Value: string): TPredictionPartParams;
begin
  Result := TPredictionPartParams(Add('text', Value));
end;

function TPredictionPartParams.&Type(
  const Value: string): TPredictionPartParams;
begin
  Result := TPredictionPartParams(Add('type', Value));
end;

{ TAudioParams }

function TAudioParams.Format(const Value: TAudioFormat): TAudioParams;
begin
  Result := TAudioParams(Add('format', Value.ToString));
end;

function TAudioParams.Voice(const Value: TChatVoice): TAudioParams;
begin
  Result := TAudioParams(Add('voice', Value.ToString));
end;

{ TToolChoiceParams }

function TToolChoiceParams.&Function(const Name: string): TToolChoiceParams;
begin
  Result := TToolChoiceParams(Add('function', TToolChoiceFunctionParams.Create.Name(Name).Detach));
end;

class function TToolChoiceParams.New(const Name: string): TToolChoiceParams;
begin
  Result := TToolChoiceParams.Create.&Type('function').&Function(Name);
end;

function TToolChoiceParams.&Type(const Value: string): TToolChoiceParams;
begin
  Result := TToolChoiceParams(Add('type', Value));
end;

{ TToolChoiceFunctionParams }

function TToolChoiceFunctionParams.Name(
  const Value: string): TToolChoiceFunctionParams;
begin
  Result := TToolChoiceFunctionParams(Add('name', Value));
end;

{ TChat }

destructor TChat.Destroy;
begin
  for var Item in FChoices do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  inherited;
end;

{ TUsage }

destructor TUsage.Destroy;
begin
  if Assigned(FCompletionTokensDetails) then
    FCompletionTokensDetails.Free;
  if Assigned(FPromptTokensDetails) then
    FPromptTokensDetails.Free;
  inherited;
end;

{ TChoice }

destructor TChoice.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;
  if Assigned(FLogprobs) then
    FLogprobs.Free;
  if Assigned(FDelta) then
    FDelta.Free;
  inherited;
end;

{ Ttoolcall }

destructor Ttoolcall.Destroy;
begin
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

{ TMessage }

destructor TMessage.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  if Assigned(FAudio) then
    FAudio.Free;
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

{ TLogprobsDetail }

destructor TLogprobsDetail.Destroy;
begin
  for var Item in FTopLogprobs do
    Item.Free;
  inherited;
end;

{ TDelta }

destructor TDelta.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

{ TChatRoute }

procedure TChatRoute.AsynCreateStream(ParamProc: TProc<TChatParams>;
  CallBacks: TFunc<TAsynChatStream>);
begin
  var CallBackParams := TUseParamsFactory<TAsynChatStream>.CreateInstance(CallBacks);

  var Sender := CallBackParams.Param.Sender;
  var OnStart := CallBackParams.Param.OnStart;
  var OnSuccess := CallBackParams.Param.OnSuccess;
  var OnProgress := CallBackParams.Param.OnProgress;
  var OnError := CallBackParams.Param.OnError;
  var OnCancellation := CallBackParams.Param.OnCancellation;
  var OnDoCancel := CallBackParams.Param.OnDoCancel;

  var Task: ITask := TTask.Create(
          procedure()
          begin
            {--- Pass the instance of the current class in case no value was specified. }
            if not Assigned(Sender) then
              Sender := Self;

            {--- Trigger OnStart callback }
            if Assigned(OnStart) then
              TThread.Queue(nil,
                procedure
                begin
                  OnStart(Sender);
                end);
            try
              var Stop := False;

              {--- Processing }
              CreateStream(ParamProc,
                procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
                begin
                  {--- Check that the process has not been canceled }
                  if Assigned(OnDoCancel) then
                    TThread.Queue(nil,
                        procedure
                        begin
                          Stop := OnDoCancel();
                        end);
                  if Stop then
                    begin
                      {--- Trigger when processus was stopped }
                      if Assigned(OnCancellation) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnCancellation(Sender)
                        end);
                      Cancel := True;
                      Exit;
                    end;
                  if not IsDone and Assigned(Chat) then
                    begin
                      var LocalChat := Chat;
                      Chat := nil;

                      {--- Triggered when processus is progressing }
                      if Assigned(OnProgress) then
                        TThread.Synchronize(TThread.Current,
                        procedure
                        begin
                          try
                            OnProgress(Sender, LocalChat);
                          finally
                            {--- Makes sure to release the instance containing the data obtained
                                 following processing}
                            LocalChat.Free;
                          end;
                        end)
                     else
                       LocalChat.Free;
                    end
                  else
                  if IsDone then
                    begin
                      {--- Trigger OnEnd callback when the process is done }
                      if Assigned(OnSuccess) then
                        TThread.Queue(nil,
                        procedure
                        begin
                          OnSuccess(Sender);
                        end);
                    end;
                end);
            except
              on E: Exception do
                begin
                  var Error := AcquireExceptionObject;
                  try
                    var ErrorMsg := (Error as Exception).Message;

                    {--- Trigger OnError callback if the process has failed }
                    if Assigned(OnError) then
                      TThread.Queue(nil,
                      procedure
                      begin
                        OnError(Sender, ErrorMsg);
                      end);
                  finally
                    {--- Ensures that the instance of the caught exception is released}
                    Error.Free;
                  end;
                end;
            end;
          end);
  Task.Start;
end;

procedure TChatRoute.AsynCreate(ParamProc: TProc<TChatParams>;
  CallBacks: TFunc<TAsynChat>);
begin
  with TAsynCallBackExec<TAsynChat, TChat>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TChat
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TChatRoute.Create(ParamProc: TProc<TChatParams>): TChat;
begin
  Result := API.Post<TChat, TChatParams>('chat/completions', ParamProc);
end;

function TChatRoute.CreateStream(ParamProc: TProc<TChatParams>;
  Event: TStreamCallbackEvent<TChat>): Boolean;
begin
  var Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Result := API.Post<TChatParams>('chat/completions', ParamProc, Response,
      TStreamCallback<TChat>.CreateInstance(Response, Event, TApiDeserializer.Parse<TChat>).OnStream);
  finally
    Response.Free;
  end;
end;

{ TAudio }

function TAudio.GetStream: TStream;
begin
  {--- Create a memory stream to write the decoded content. }
  Result := TMemoryStream.Create;
  try
    {--- Convert the base-64 string directly into the memory stream. }
    DecodeBase64ToStream(Data, Result)
  except
    Result.Free;
    raise;
  end;
end;

procedure TAudio.SaveToFile(const FileName: string);
begin
  if FileName.Trim.IsEmpty then
    raise Exception.Create('File record aborted. SaveToFile requires a filename.');

  try
    Self.FFileName := FileName;
    {--- Perform the decoding operation and save it into the file specified by the FileName parameter. }
    DecodeBase64ToFile(Data, FileName)
  except
    raise;
  end;
end;

end.
