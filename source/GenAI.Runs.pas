unit GenAI.Runs;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Schema, GenAI.API.Lists, GenAI.Assistants, GenAI.Threads, GenAI.Chat;

type
  TRunsToolChoice = class(TJSONParam)
  public
    function &Type(const Value: string): TRunsToolChoice;
    function &function(const Value: string): TRunsToolChoice;
    class function New(const FunctionName: string): TRunsToolChoice;
  end;

  TRunsTruncationStrategy = class(TJSONParam)
  public
    function &Type(const Value: string): TRunsTruncationStrategy; overload;
    function &Type(const Value: TTruncationStrategyType): TRunsTruncationStrategy; overload;
    function LastMessages(const Value: Integer): TRunsTruncationStrategy;
  end;

  TRunsParams = class(TJSONParam)
  public
    function AssistantId(const Value: string): TRunsParams;
    function Model(const Value: string): TRunsParams;
    function Instructions(const Value: string): TRunsParams;
    function AdditionalInstructions(const Value: string): TRunsParams;
    function AdditionalMessages(const Value: TArray<TThreadsMessageParams>): TRunsParams; overload;
    function Tools(const Value: TArray<TAssistantsToolsParams>): TRunsParams;
    function Metadata(const Value: TJSONObject): TRunsParams;
    function Temperature(const Value: Double): TRunsParams;
    function TopP(const Value: Double): TRunsParams;
    function Stream(const Value: Boolean): TRunsParams;
    function MaxPromptTokens(const Value: Integer): TRunsParams;
    function MaxCompletionTokens(const Value: Integer): TRunsParams;
    function TruncationStrategy(const Value: TRunsTruncationStrategy): TRunsParams;
    function ToolChoice(const Value: string): TRunsParams; overload;
    function ToolChoice(const Value: TRunsToolChoice): TRunsParams; overload;
    function ParallelToolCalls(const Value: Boolean): TRunsParams;
    function ResponseFormat(const Value: string = 'auto'): TRunsParams; overload;
    function ResponseFormat(const Value: TResponseFormatParams): TRunsParams; overload;
    function ResponseFormat(const Value: TJSONObject): TRunsParams; overload;
  end;

  TSubmitToolOutputs = class
  private
    [JsonNameAttribute('tool_calls')]
    FToolCalls: TArray<TToolcall>;
  public
    property ToolCalls: TArray<TToolcall> read FToolCalls write FToolCalls;
    destructor Destroy; override;
  end;

  TRequiredAction = class
  private
    FType: string;
    [JsonNameAttribute('submit_tool_outputs')]
    FSubmitToolOutputs: TSubmitToolOutputs;
  public
    property &Type: string read FType write FType;
    property SubmitToolOutputs: TSubmitToolOutputs read FSubmitToolOutputs write FSubmitToolOutputs;
    destructor Destroy; override;
  end;

  TLastError = class
  private
    FCode: string;
    FMessage: string;
  public
    property Code: string read FCode write FCode;
    property Message: string read FMessage write FMessage;
  end;

  TIncompleteDetailsReason = class
  private
    FReason: string;
  public
    property Reason: string read FReason write FReason;
  end;

  TIncompleteDetails = class
  private
    FReason: string;
  public
    property Reason: string read FReason write FReason;
  end;

  TRunUsage = class
  private
    [JsonNameAttribute('completion_tokens')]
    FCompletionTokens: Int64;
    [JsonNameAttribute('prompt_tokens')]
    FPromptTokens: Int64;
    [JsonNameAttribute('total_tokens')]
    FTotalTokens: Int64;
  public
    property CompletionTokens: Int64 read FCompletionTokens write FCompletionTokens;
    property PromptTokens: Int64 read FPromptTokens write FPromptTokens;
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;
  end;

  TTruncationStrategy = class
  private
    [JsonReflectAttribute(ctString, rtString, TTruncationStrategyTypeInterceptor)]
    FType: TTruncationStrategyType;
    [JsonNameAttribute('last_messages')]
    FLastMessages: Int64;
  public
    property &Type: TTruncationStrategyType read FType write FType;
    property LastMessages: Int64 read FLastMessages write FLastMessages;
  end;

  TRunTimeStamp = class(TJSONFingerprint)
  protected
    function GetCreatedAtAsString: string; virtual; abstract;
    function GetExpiresAtAsString: string; virtual; abstract;
    function GetStartedAtAsString: string; virtual; abstract;
    function GetCancelledAtAsString: string; virtual; abstract;
    function GetFailedAtAsString: string; virtual; abstract;
    function GetCompletedAtAsString: string; virtual; abstract;
  public
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property ExpiresAtAsString: string read GetExpiresAtAsString;
    property StartedAtAsString: string read GetStartedAtAsString;
    property CancelledAtAsString: string read GetCancelledAtAsString;
    property FailedAtAsString: string read GetFailedAtAsString;
    property CompletedAtAsString: string read GetCompletedAtAsString;
  end;

  TRun = class(TRunTimeStamp)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
    [JsonNameAttribute('thread_id')]
    FThreadId: string;
    [JsonNameAttribute('assistant_id')]
    FAssistantId: string;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('required_action')]
    FRequiredAction: TRequiredAction;
    [JsonNameAttribute('last_error')]
    FLastError: TLastError;
    [JsonNameAttribute('expires_at')]
    FExpiresAt: Int64;
    [JsonNameAttribute('started_at')]
    FStartedAt: Int64;
    [JsonNameAttribute('cancelled_at')]
    FCancelledAt: Int64;
    [JsonNameAttribute('failed_at')]
    FFailedAt: Int64;
    [JsonNameAttribute('completed_at')]
    FCompletedAt: Int64;
    [JsonNameAttribute('incomplete_details')]
    FIncompleteDetails: TIncompleteDetails;
    FModel: string;
    FInstructions: string;
    FTools: TArray<TAssistantsTools>;
    FMetadata: string;
    FUsage: TRunUsage;
    FTemperature: Double;
    [JsonNameAttribute('top_p')]
    FTopP: Double;
    [JsonNameAttribute('max_prompt_tokens')]
    FMaxPromptTokens: Int64;
    [JsonNameAttribute('max_completion_tokens')]
    FMaxCompletionTokens: Int64;
    [JsonNameAttribute('truncation_strategy')]
    FTruncationStrategy: TTruncationStrategy;
    [JsonNameAttribute('tool_choice')]
    FToolChoice: string;
    [JsonNameAttribute('parallel_tool_calls')]
    FParallelToolCalls: Boolean;
    [JsonNameAttribute('response_format')]
    FResponseFormat: string;
  protected
    function GetCreatedAtAsString: string; override;
    function GetExpiresAtAsString: string; override;
    function GetStartedAtAsString: string; override;
    function GetCancelledAtAsString: string; override;
    function GetFailedAtAsString: string; override;
    function GetCompletedAtAsString: string; override;
  public
    property Id: string read FId write FId;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property &Object: string read FObject write FObject;
    property ThreadId: string read FThreadId write FThreadId;
    property AssistantId: string read FAssistantId write FAssistantId;
    property Status: TRunStatus read FStatus write FStatus;
    property RequiredAction: TRequiredAction read FRequiredAction write FRequiredAction;
    property LastError: TLastError read FLastError write FLastError;
    property ExpiresAt: Int64 read FExpiresAt write FExpiresAt;
    property StartedAt: Int64 read FStartedAt write FStartedAt;
    property CancelledAt: Int64 read FCancelledAt write FCancelledAt;
    property FailedAt: Int64 read FFailedAt write FFailedAt;
    property CompletedAt: Int64 read FCompletedAt write FCompletedAt;
    property IncompleteDetails: TIncompleteDetails read FIncompleteDetails write FIncompleteDetails;
    property Model: string read FModel write FModel;
    property Instructions: string read FInstructions write FInstructions;
    property Tools: TArray<TAssistantsTools> read FTools write FTools;
    property Metadata: string read FMetadata write FMetadata;
    property Usage: TRunUsage read FUsage write FUsage;
    property Temperature: Double read FTemperature write FTemperature;
    property TopP: Double read FTopP write FTopP;
    property MaxPromptTokens: Int64 read FMaxPromptTokens write FMaxPromptTokens;
    property MaxCompletionTokens: Int64 read FMaxCompletionTokens write FMaxCompletionTokens;
    property TruncationStrategy: TTruncationStrategy read FTruncationStrategy write FTruncationStrategy;
    property ToolChoice: string read FToolChoice write FToolChoice;
    property ParallelToolCalls: Boolean read FParallelToolCalls write FParallelToolCalls;
    property ResponseFormat: string read FResponseFormat write FResponseFormat;
    destructor Destroy; override;
  end;

  TRunsRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    function Create(const ThreadId: string; const ParamProc: TProc<TRunsParams>): TRun;
  end;

implementation

{ TRunsRoute }

function TRunsRoute.Create(const ThreadId: string;
  const ParamProc: TProc<TRunsParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TRunsParams>('threads/' + ThreadId + '/runs', ParamProc);
end;

procedure TRunsRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

{ TRunsParams }

function TRunsParams.AdditionalInstructions(const Value: string): TRunsParams;
begin
  Result := TRunsParams(Add('additional_instructions', Value));
end;

function TRunsParams.AdditionalMessages(
  const Value: TArray<TThreadsMessageParams>): TRunsParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TRunsParams(Add('additional_messages', JSONArray));
end;

function TRunsParams.AssistantId(const Value: string): TRunsParams;
begin
  Result := TRunsParams(Add('assistant_id', Value));
end;

function TRunsParams.Instructions(const Value: string): TRunsParams;
begin
  Result := TRunsParams(Add('instructions', Value));
end;

function TRunsParams.MaxCompletionTokens(const Value: Integer): TRunsParams;
begin
  Result := TRunsParams(Add('max_completion_tokens', Value));
end;

function TRunsParams.MaxPromptTokens(const Value: Integer): TRunsParams;
begin
  Result := TRunsParams(Add('max_prompt_tokens', Value));
end;

function TRunsParams.Metadata(const Value: TJSONObject): TRunsParams;
begin
  Result := TRunsParams(Add('metadata', Value));
end;

function TRunsParams.Model(const Value: string): TRunsParams;
begin
  Result := TRunsParams(Add('model', Value));
end;

function TRunsParams.ParallelToolCalls(const Value: Boolean): TRunsParams;
begin
  Result := TRunsParams(Add('parallel_tool_calls', Value));
end;

function TRunsParams.ResponseFormat(
  const Value: TResponseFormatParams): TRunsParams;
begin
  Result := TRunsParams(Add('response_format', Value.Detach));
end;

function TRunsParams.ResponseFormat(const Value: string): TRunsParams;
begin
  Result := TRunsParams(Add('response_format', Value));
end;

function TRunsParams.Stream(const Value: Boolean): TRunsParams;
begin
  Result := TRunsParams(Add('stream', Value));
end;

function TRunsParams.Temperature(const Value: Double): TRunsParams;
begin
  Result := TRunsParams(Add('temperature', Value));
end;

function TRunsParams.ToolChoice(const Value: string): TRunsParams;
begin
  Result := TRunsParams(Add('tool_choice', Value));
end;

function TRunsParams.ToolChoice(const Value: TRunsToolChoice): TRunsParams;
begin
  Result := TRunsParams(Add('tool_choice', Value.Detach));
end;

function TRunsParams.Tools(const Value: TArray<TAssistantsToolsParams>): TRunsParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TRunsParams(Add('tools', JSONArray));
end;

function TRunsParams.TopP(const Value: Double): TRunsParams;
begin
  Result := TRunsParams(Add('top_p', Value));
end;

function TRunsParams.TruncationStrategy(
  const Value: TRunsTruncationStrategy): TRunsParams;
begin
  Result := TRunsParams(Add('truncation_strategy', Value.Detach));
end;

function TRunsParams.ResponseFormat(const Value: TJSONObject): TRunsParams;
begin
  Result := TRunsParams(Add('response_format', Value));
end;

{ TRunsTruncationStrategy }

function TRunsTruncationStrategy.LastMessages(
  const Value: Integer): TRunsTruncationStrategy;
begin
  Result := TRunsTruncationStrategy(Add('last_messages', Value));
end;

function TRunsTruncationStrategy.&Type(const Value: string): TRunsTruncationStrategy;
begin
  Result := TRunsTruncationStrategy(Add('type', TTruncationStrategyType.Create(Value).ToString));
end;

function TRunsTruncationStrategy.&Type(
  const Value: TTruncationStrategyType): TRunsTruncationStrategy;
begin
  Result := TRunsTruncationStrategy(Add('type', Value.ToString));
end;

{ TRunsToolChoice }

function TRunsToolChoice.&function(
  const Value: string): TRunsToolChoice;
begin
  Result := TRunsToolChoice(Add('function', TJSONObject.Create.AddPair('name', Value)));
end;

class function TRunsToolChoice.New(
  const FunctionName: string): TRunsToolChoice;
begin
  Result := TRunsToolChoice.Create.&Type('function').&function(FunctionName);
end;

function TRunsToolChoice.&Type(
  const Value: string): TRunsToolChoice;
begin
  Result := TRunsToolChoice(Add('type', Value));
end;

{ TRun }

destructor TRun.Destroy;
begin
  if Assigned(FRequiredAction) then
    FRequiredAction.Free;
  if Assigned(FLastError) then
    FLastError.Free;
  if Assigned(FIncompleteDetails) then
    FIncompleteDetails.Free;
  for var Item in FTools do
    Item.Free;
  if Assigned(FUsage) then
    FUsage.Free;
  if Assigned(FTruncationStrategy) then
    FTruncationStrategy.Free;
  inherited;
end;

function TRun.GetCancelledAtAsString: string;
begin
  Result := TimestampToString(CancelledAt, UTCtimestamp);
end;

function TRun.GetCompletedAtAsString: string;
begin
  Result := TimestampToString(CompletedAt, UTCtimestamp);
end;

function TRun.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

function TRun.GetExpiresAtAsString: string;
begin
  Result := TimestampToString(ExpiresAt, UTCtimestamp);
end;

function TRun.GetFailedAtAsString: string;
begin
  Result := TimestampToString(FailedAt, UTCtimestamp);
end;

function TRun.GetStartedAtAsString: string;
begin
  Result := TimestampToString(StartedAt, UTCtimestamp);
end;

{ TRequiredAction }

destructor TRequiredAction.Destroy;
begin
  if Assigned(FSubmitToolOutputs) then
    FSubmitToolOutputs.Free;
  inherited;
end;

{ TSubmitToolOutputs }

destructor TSubmitToolOutputs.Destroy;
begin
  for var Item in FToolCalls do
    Item.Free;
  inherited;
end;

end.
