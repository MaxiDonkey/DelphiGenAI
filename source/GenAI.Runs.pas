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
  TRunsUrlParams = TUrlAdvancedParams;

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

  TRunsCoreParams = class(TJSONParam)
  public
    function AssistantId(const Value: string): TRunsCoreParams;
    function Model(const Value: string): TRunsCoreParams;
    function Instructions(const Value: string): TRunsCoreParams;
    function AdditionalInstructions(const Value: string): TRunsCoreParams;
    function Tools(const Value: TArray<TAssistantsToolsParams>): TRunsCoreParams;
    function Metadata(const Value: TJSONObject): TRunsCoreParams;
    function Temperature(const Value: Double): TRunsCoreParams;
    function TopP(const Value: Double): TRunsCoreParams;
    function Stream(const Value: Boolean): TRunsCoreParams;
    function MaxPromptTokens(const Value: Integer): TRunsCoreParams;
    function MaxCompletionTokens(const Value: Integer): TRunsCoreParams;
    function TruncationStrategy(const Value: TRunsTruncationStrategy): TRunsCoreParams;
    function ToolChoice(const Value: string): TRunsCoreParams; overload;
    function ToolChoice(const Value: TRunsToolChoice): TRunsCoreParams; overload;
    function ParallelToolCalls(const Value: Boolean): TRunsCoreParams;
    function ResponseFormat(const Value: string = 'auto'): TRunsCoreParams; overload;
    function ResponseFormat(const Value: TResponseFormatParams): TRunsCoreParams; overload;
    function ResponseFormat(const Value: TJSONObject): TRunsCoreParams; overload;
  end;

  TRunsParams = class(TRunsCoreParams)
  public
    function AdditionalMessages(const Value: TArray<TThreadsMessageParams>): TRunsParams;
  end;

  TCreateRunsParams = class(TRunsCoreParams)
  public
    function Thread(const Value: TThreadsCreateParams): TCreateRunsParams;
    function ToolResources(const Value: TToolResourcesParams): TCreateRunsParams;
  end;

  TUpdateParams = class(TRunsCoreParams)
  public
    function Metadata(const Value: TJSONObject): TUpdateParams;
  end;

  TToolOutputParam = class(TJSONParam)
  public
    function ToolCallId(const Value: string): TToolOutputParam;
    function Output(const Value: string): TToolOutputParam;
  end;

  TSubmitToolParams = class(TJSONParam)
  public
     function ToolOutputs(const Value: TToolOutputParam): TSubmitToolParams;
     function Stream(const Value: Boolean): TSubmitToolParams;
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

  TRuns = TAdvancedList<TRun>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TRun</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRun</c> type extends the <c>TAsynParams&lt;TRun&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynRun = TAsynCallBack<TRun>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TRuns</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynRuns</c> type extends the <c>TAsynParams&lt;TRuns&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynRuns = TAsynCallBack<TRuns>;

  TRunsRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    procedure AsynCreate(const ThreadId: string; const ParamProc: TProc<TRunsParams>;
      const CallBacks: TFunc<TAsynRun>);
    procedure AsynCreateAndRun(const ParamProc: TProc<TCreateRunsParams>;
      const CallBacks: TFunc<TAsynRun>);
    procedure AsynList(const ThreadId: string; const CallBacks: TFunc<TAsynRuns>); overload;
    procedure AsynList(const ThreadId: string; const ParamProc: TProc<TRunsUrlParams>;
      const CallBacks: TFunc<TAsynRuns>); overload;
    procedure AsynRetrieve(const ThreadId: string; const RunId: string;
      const CallBacks: TFunc<TAsynRun>);
    procedure AsynUpdate(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TUpdateParams>;
      const CallBacks: TFunc<TAsynRun>);
    procedure AsynSubmitTool(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TSubmitToolParams>;
      const CallBacks: TFunc<TAsynRun>);
    procedure AsynCancel(const ThreadId: string; const RunId: string;
      const CallBacks: TFunc<TAsynRun>);

    function Create(const ThreadId: string; const ParamProc: TProc<TRunsParams>): TRun;
    function CreateAndRun(const ParamProc: TProc<TCreateRunsParams>): TRun;
    function List(const ThreadId: string): TRuns; overload;
    function List(const ThreadId: string; const ParamProc: TProc<TRunsUrlParams>): TRuns; overload;
    function Retrieve(const ThreadId: string; const RunId: string): TRun;
    function Update(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TUpdateParams>): TRun;
    function SubmitTool(const ThreadId: string; const RunId: string;
      const ParamProc: TProc<TSubmitToolParams>): TRun;
    function Cancel(const ThreadId: string; const RunId: string): TRun;
  end;

implementation

{ TRunsRoute }

procedure TRunsRoute.AsynCancel(const ThreadId, RunId: string;
  const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Cancel(ThreadId, RunId);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynCreate(const ThreadId: string;
  const ParamProc: TProc<TRunsParams>; const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Create(ThreadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynCreateAndRun(const ParamProc: TProc<TCreateRunsParams>;
  const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.CreateAndRun(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynList(const ThreadId: string;
  const ParamProc: TProc<TRunsUrlParams>; const CallBacks: TFunc<TAsynRuns>);
begin
  with TAsynCallBackExec<TAsynRuns, TRuns>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRuns
      begin
        Result := Self.List(ThreadId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynList(const ThreadId: string;
  const CallBacks: TFunc<TAsynRuns>);
begin
  with TAsynCallBackExec<TAsynRuns, TRuns>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRuns
      begin
        Result := Self.List(ThreadId);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynRetrieve(const ThreadId, RunId: string;
  const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Retrieve(ThreadId, RunId);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynSubmitTool(const ThreadId, RunId: string;
  const ParamProc: TProc<TSubmitToolParams>; const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.SubmitTool(ThreadId, RunId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TRunsRoute.AsynUpdate(const ThreadId, RunId: string;
  const ParamProc: TProc<TUpdateParams>; const CallBacks: TFunc<TAsynRun>);
begin
  with TAsynCallBackExec<TAsynRun, TRun>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TRun
      begin
        Result := Self.Update(ThreadId, RunId, ParamProc);
      end);
  finally
    Free;
  end;
end;

function TRunsRoute.Cancel(const ThreadId, RunId: string): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun>('threads/' + ThreadId + '/runs/' + RunId + '/cancel');
end;

function TRunsRoute.Create(const ThreadId: string;
  const ParamProc: TProc<TRunsParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TRunsParams>('threads/' + ThreadId + '/runs', ParamProc);
end;

function TRunsRoute.CreateAndRun(
  const ParamProc: TProc<TCreateRunsParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TCreateRunsParams>('threads/runs', ParamProc);
end;

procedure TRunsRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TRunsRoute.List(const ThreadId: string): TRuns;
begin
  HeaderCustomize;
  Result := API.Get<TRuns>('threads/' + ThreadId + '/runs');
end;

function TRunsRoute.List(const ThreadId: string;
  const ParamProc: TProc<TRunsUrlParams>): TRuns;
begin
  HeaderCustomize;
  Result := API.Get<TRuns, TRunsUrlParams>('threads/' + ThreadId + '/runs', ParamProc);
end;

function TRunsRoute.Retrieve(const ThreadId, RunId: string): TRun;
begin
  HeaderCustomize;
  Result := API.Get<TRun>('threads/' + ThreadId + '/runs/' + RunId);
end;

function TRunsRoute.SubmitTool(const ThreadId, RunId: string;
  const ParamProc: TProc<TSubmitToolParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TSubmitToolParams>('threads/' + ThreadId + '/runs/' + RunId + '/submit_tool_outputs', ParamProc);
end;

function TRunsRoute.Update(const ThreadId, RunId: string;
  const ParamProc: TProc<TUpdateParams>): TRun;
begin
  HeaderCustomize;
  Result := API.Post<TRun, TUpdateParams>('threads/' + ThreadId + '/runs/' + RunId, ParamProc);
end;

{ TRunsCoreParams }

function TRunsCoreParams.AdditionalInstructions(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('additional_instructions', Value));
end;

function TRunsCoreParams.AssistantId(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('assistant_id', Value));
end;

function TRunsCoreParams.Instructions(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('instructions', Value));
end;

function TRunsCoreParams.MaxCompletionTokens(const Value: Integer): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('max_completion_tokens', Value));
end;

function TRunsCoreParams.MaxPromptTokens(const Value: Integer): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('max_prompt_tokens', Value));
end;

function TRunsCoreParams.Metadata(const Value: TJSONObject): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('metadata', Value));
end;

function TRunsCoreParams.Model(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('model', Value));
end;

function TRunsCoreParams.ParallelToolCalls(const Value: Boolean): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('parallel_tool_calls', Value));
end;

function TRunsCoreParams.ResponseFormat(
  const Value: TResponseFormatParams): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('response_format', Value.Detach));
end;

function TRunsCoreParams.ResponseFormat(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('response_format', Value));
end;

function TRunsCoreParams.Stream(const Value: Boolean): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('stream', Value));
end;

function TRunsCoreParams.Temperature(const Value: Double): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('temperature', Value));
end;

function TRunsCoreParams.ToolChoice(const Value: string): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('tool_choice', Value));
end;

function TRunsCoreParams.ToolChoice(const Value: TRunsToolChoice): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('tool_choice', Value.Detach));
end;

function TRunsCoreParams.Tools(const Value: TArray<TAssistantsToolsParams>): TRunsCoreParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TRunsCoreParams(Add('tools', JSONArray));
end;

function TRunsCoreParams.TopP(const Value: Double): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('top_p', Value));
end;

function TRunsCoreParams.TruncationStrategy(
  const Value: TRunsTruncationStrategy): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('truncation_strategy', Value.Detach));
end;

function TRunsCoreParams.ResponseFormat(const Value: TJSONObject): TRunsCoreParams;
begin
  Result := TRunsCoreParams(Add('response_format', Value));
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

{ TRunsParams }

function TRunsParams.AdditionalMessages(
  const Value: TArray<TThreadsMessageParams>): TRunsParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TRunsParams(Add('additional_messages', JSONArray));
end;

{ TCreateRunsParams }

function TCreateRunsParams.Thread(
  const Value: TThreadsCreateParams): TCreateRunsParams;
begin
  Result := TCreateRunsParams(Add('thread', Value.Detach));
end;

function TCreateRunsParams.ToolResources(
  const Value: TToolResourcesParams): TCreateRunsParams;
begin
  Result := TCreateRunsParams(Add('tool_resources', Value.Detach));
end;

{ TUpdateParams }

function TUpdateParams.Metadata(const Value: TJSONObject): TUpdateParams;
begin
  Result := TUpdateParams(Add('metadata', Value));
end;

{ TToolOutputParam }

function TToolOutputParam.Output(const Value: string): TToolOutputParam;
begin
  Result := TToolOutputParam(Add('output', Value));
end;

function TToolOutputParam.ToolCallId(const Value: string): TToolOutputParam;
begin
  Result := TToolOutputParam(Add('tool_call_id', Value));
end;

{ TSubmitToolParams }

function TSubmitToolParams.Stream(const Value: Boolean): TSubmitToolParams;
begin
  Result := TSubmitToolParams(Add('stream', Value));
end;

function TSubmitToolParams.ToolOutputs(
  const Value: TToolOutputParam): TSubmitToolParams;
begin
  Result := TSubmitToolParams(Add('tool_outputs', Value.Detach));
end;

end.
