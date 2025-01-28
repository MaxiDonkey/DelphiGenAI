unit GenAI.Assistants;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.Schema;

type
  TRankingOptionsParams = class(TJSONParam)
  public
    function Ranker(const Value: string): TRankingOptionsParams;
    function ScoreThreshold(const Value: Double): TRankingOptionsParams;
  end;

  TFileSearchToolParams = class(TJSONParam)
  public
    function MaxNumResults(const Value: Integer): TFileSearchToolParams;
    function RankingOptions(const Value: TRankingOptionsParams): TFileSearchToolParams;
  end;

  TFunctionParams = class(TJSONParam)
  public
    function Description(const Value: string): TFunctionParams;
    function Name(const Value: string): TFunctionParams;
    function Parameters(const Value: TSchemaParams): TFunctionParams; overload;
    function Parameters(const Value: TJSONObject): TFunctionParams; overload;
    function &Strict(const Value: Boolean): TFunctionParams;
  end;

  TAssistantsToolsParams = class(TJSONParam)
  public
    function &Type(const Value: string): TAssistantsToolsParams; overload;
    function &Type(const Value: TAssistantsToolsType): TAssistantsToolsParams; overload;
    function FileSearch(const Value: TFileSearchToolParams): TAssistantsToolsParams;
    function &Function(const Value: TFunctionParams): TAssistantsToolsParams;
  end;

  TCodeInterpreterParams = class(TJSONParam)
  public
    function FileIds(const Value: TArray<string>): TCodeInterpreterParams;
  end;

  TChunkStaticParams = class(TJSONParam)
  public
    function MaxChunkSizeTokens(const Value: Integer): TChunkStaticParams;
    function ChunkOverlapTokens(const Value: Integer): TChunkStaticParams;
  end;

  TChunkingStrategyParams = class(TJSONParam)
  public
    function &Type(const Value: string): TChunkingStrategyParams; overload;
    function &Type(const Value: TChunkingStrategyType): TChunkingStrategyParams; overload;
    function Static(const Value: TChunkStaticParams): TChunkingStrategyParams;
  end;

  TVectorStoresParams = class(TJSONParam)
  public
    function FileIds(const Value: TArray<string>): TVectorStoresParams;
    function ChunkingStrategy(const Value: TChunkingStrategyParams): TVectorStoresParams;
    function Metadata(const Value: TJSONObject): TVectorStoresParams;
  end;

  TFileSearchParams = class(TJSONParam)
  public
    function VectorStoreIds(const Value: TArray<string>): TFileSearchParams;
    function VectorStores(const Value: TArray<TVectorStoresParams>): TFileSearchParams;
  end;

  TToolResourcesParams = class(TJSONParam)
  public
    function CodeInterpreter(const Value: TCodeInterpreterParams): TToolResourcesParams; overload;
    function CodeInterpreter(const FileIds: TArray<string>): TToolResourcesParams; overload;
    function FileSearch(const Value: TFileSearchParams): TToolResourcesParams;
  end;

  TJsonSchemaParams = class(TJSONParam)
  public
    function Description(const Value: string): TJsonSchemaParams;
    function Name(const Value: string): TJsonSchemaParams;
    function Schema(const Value: TSchemaParams): TJsonSchemaParams; overload;
    function Schema(const Value: TJSONObject): TJsonSchemaParams; overload;
    function &Strict(const Value: Boolean): TJsonSchemaParams;
  end;

  TResponseFormatParams = class(TJSONParam)
  public
    function &Type(const Value: string): TResponseFormatParams; overload;
    function &Type(const Value: TResponseFormatType): TResponseFormatParams; overload;
    function JsonSchema(const Value: TJsonSchemaParams): TResponseFormatParams;
  end;

  TAssistantsParams = class(TJSONParam)
  public
    function Model(const Value: string): TAssistantsParams;
    function Name(const Value: string): TAssistantsParams;
    function Description(const Value: string): TAssistantsParams;
    function Instructions(const Value: string): TAssistantsParams;
    function Tools(const Value: TAssistantsToolsParams): TAssistantsParams;
    function ToolResources(const Value: TToolResourcesParams): TAssistantsParams;
    function Metadata(const Value: TJSONObject): TAssistantsParams;
    function Temperature(const Value: Double): TAssistantsParams;
    function TopP(const Value: Double): TAssistantsParams;
    function ResponseFormat(const Value: string = 'auto'): TAssistantsParams; overload;
    function ResponseFormat(const Value: TResponseFormatParams): TAssistantsParams; overload;
  end;

  TAdvancedList<T: class, constructor> = class(TJSONFingerprint)
    FObject: string;
    FData: TArray<T>;
    [JsonNameAttribute('has_more')]
    FHasMore: Boolean;
    [JsonNameAttribute('first_id')]
    FFirstId: string;
    [JsonNameAttribute('last_id')]
    FLastId: string;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<T> read FData write FData;
    property HasMore: Boolean read FHasMore write FHasMore;
    property FirstId: string read FFirstId write FFirstId;
    property LastId: string read FLastId write FLastId;
    destructor Destroy; override;
  end;

  TRankingOptions = class
  private
    FRanker: string;
    [JsonNameAttribute('score_threshold')]
    FScoreThreshold: Double;
  public
    property Ranker: string read FRanker write FRanker;
    property ScoreThreshold: Double read FScoreThreshold write FScoreThreshold;
  end;

  TAssistantsFileSearch = class
  private
    [JsonNameAttribute('max_num_results')]
    FMaxNumResults: Int64;
    [JsonNameAttribute('ranking_options')]
    FRankingOptions: TRankingOptions;
  public
    property MaxNumResults: Int64 read FMaxNumResults write FMaxNumResults;
    property RankingOptions: TRankingOptions read FRankingOptions write FRankingOptions;
    destructor Destroy; override;
  end;

  TFunction = class
  private
    FDescription: string;
    FName: string;
    FParameters: string;
    FStrict: Boolean;
  public
    property Description: string read FDescription write FDescription;
    property Name: string read FName write FName;
    property Parameters: string read FParameters write FParameters;
    property Strict: Boolean read FStrict write FStrict;
  end;

  TAssistantsTools = class
  private
    [JsonReflectAttribute(ctString, rtString, TAssistantsToolsTypeInterceptor)]
    FType: TAssistantsToolsType;
    [JsonNameAttribute('file_search')]
    FFileSearch: TAssistantsFileSearch;
    FFunction: TFunction;
  public
    property &Type: TAssistantsToolsType read FType write FType;
    property FileSearch: TAssistantsFileSearch read FFileSearch write FFileSearch;
    property &Function: TFunction read FFunction write FFunction;
    destructor Destroy; override;
  end;

  TCodeInterpreter = class
  private
    [JsonNameAttribute('file_ids')]
    FFileIds: TArray<string>;
  public
    property FileIds: TArray<string> read FFileIds write FFileIds;
  end;

  TFileSearch = class
  private
    [JsonNameAttribute('vector_store_ids')]
    FVectorStoreIds: TArray<string>;
  public
    property VectorStoreIds: TArray<string> read FVectorStoreIds write FVectorStoreIds;
  end;

  TToolResources = class
  private
    [JsonNameAttribute('code_interpreter')]
    FCodeInterpreter: TCodeInterpreter;
    [JsonNameAttribute('file_search')]
    FFileSearch: TFileSearch;
  public
    property CodeInterpreter: TCodeInterpreter read FCodeInterpreter write FCodeInterpreter;
    property FileSearch: TFileSearch read FFileSearch write FFileSearch;
    destructor Destroy; override;
  end;

  TAssistant = class(TJSONFingerprint)
  private
    FId: string;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    FObject: string;
    FName: string;
    FDescription: string;
    FModel: string;
    FInstructions: string;
    FTools: TArray<TAssistantsTools>;
    [JsonNameAttribute('tool_resources')]
    FToolResources: TToolResources;
    FMetadata: string;
    FTemperature: Double;
    [JsonNameAttribute('top_p')]
    FTopP: Double;
    [JsonNameAttribute('response_format')]
    FResponseFormat: string;
  public
    property Id: string read FId write FId;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property &Object: string read FObject write FObject;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Model: string read FModel write FModel;
    property Instructions: string read FInstructions write FInstructions;
    property Tools: TArray<TAssistantsTools> read FTools write FTools;
    property ToolResources: TToolResources read FToolResources write FToolResources;
    property Metadata: string read FMetadata write FMetadata;
    property Temperature: Double read FTemperature write FTemperature;
    property TopP: Double read FTopP write FTopP;
    property ResponseFormat: string read FResponseFormat write FResponseFormat;
    destructor Destroy; override;
  end;

  TAssistants = TAdvancedList<TAssistant>;

  TAssistantDeletion = class(TJSONFingerprint)
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
  /// Manages asynchronous chat callBacks for a chat request using <c>TAssistant</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistant</c> type extends the <c>TAsynParams&lt;TAssistant&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAssistant = TAsynCallBack<TAssistant>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TAssistants</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistants</c> type extends the <c>TAsynParams&lt;TAssistants&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAssistants = TAsynCallBack<TAssistants>;

  /// <summary>
  /// Manages asynchronous chat callBacks for a chat request using <c>TAssistantDeletion</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynAssistantDeletion</c> type extends the <c>TAsynParams&lt;TAssistantDeletion&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking chat operations and is specifically tailored for scenarios where multiple choices from a chat model are required.
  /// </remarks>
  TAsynAssistantDeletion = TAsynCallBack<TAssistantDeletion>;

  TAssistantsRoute = class(TGenAIRoute)
    procedure AsynCreate(const ParamProc: TProc<TAssistantsParams>; const CallBacks: TFunc<TAsynAssistant>);
    procedure AsynList(const CallBacks: TFunc<TAsynAssistants>); overload;
    procedure AsynList(const ParamProc: TProc<TUrlAdvancedParams>; const CallBacks: TFunc<TAsynAssistants>); overload;
    procedure AsynRetrieve(const AssistantId: string; const CallBacks: TFunc<TAsynAssistant>);
    procedure AsynUpdate(const AssistantId: string; const ParamProc: TProc<TAssistantsParams>;
      const CallBacks: TFunc<TAsynAssistant>);
    procedure AsynDelete(const AssistantId: string; const CallBacks: TFunc<TAsynAssistantDeletion>);

    function Create(const ParamProc: TProc<TAssistantsParams>): TAssistant;
    function List: TAssistants; overload;
    function List(const ParamProc: TProc<TUrlAdvancedParams>): TAssistants; overload;
    function Retrieve(const AssistantId: string): TAssistant;
    function Update(const AssistantId: string; const ParamProc: TProc<TAssistantsParams>): TAssistant;
    function Delete(const AssistantId: string): TAssistantDeletion;
  end;

implementation

{ TAssistantsParams }

function TAssistantsParams.Description(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('description', Value));
end;

function TAssistantsParams.Instructions(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('instructions', Value));
end;

function TAssistantsParams.Metadata(
  const Value: TJSONObject): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('metadata', Value));
end;

function TAssistantsParams.Model(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('model', Value));
end;

function TAssistantsParams.Name(const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('name', Value));
end;

function TAssistantsParams.ResponseFormat(
  const Value: TResponseFormatParams): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('response_format', Value.Detach));
end;

function TAssistantsParams.ResponseFormat(
  const Value: string): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('response_format', Value));
end;

function TAssistantsParams.Temperature(const Value: Double): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('temperature', Value));
end;

function TAssistantsParams.ToolResources(
  const Value: TToolResourcesParams): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('tool_resources', Value.Detach));
end;

function TAssistantsParams.Tools(
  const Value: TAssistantsToolsParams): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('tools', Value.Detach));
end;

function TAssistantsParams.TopP(const Value: Double): TAssistantsParams;
begin
  Result := TAssistantsParams(Add('top_p', Value));
end;

{ TAssistantsToolsParams }

function TAssistantsToolsParams.&Type(const Value: string): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('type', TAssistantsToolsType.Create(Value).ToString));
end;

function TAssistantsToolsParams.&Function(
  const Value: TFunctionParams): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('function', Value));
end;

function TAssistantsToolsParams.FileSearch(
  const Value: TFileSearchToolParams): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('file_search', Value.Detach));
end;

function TAssistantsToolsParams.&Type(
  const Value: TAssistantsToolsType): TAssistantsToolsParams;
begin
  Result := TAssistantsToolsParams(Add('type', Value.ToString));
end;

{ TFileSearchToolParams }

function TFileSearchToolParams.MaxNumResults(
  const Value: Integer): TFileSearchToolParams;
begin
  Result := TFileSearchToolParams(Add('max_num_results', Value));
end;

function TFileSearchToolParams.RankingOptions(
  const Value: TRankingOptionsParams): TFileSearchToolParams;
begin
  Result := TFileSearchToolParams(Add('ranking_options', Value.Detach));
end;

{ TRankingOptionsParams }

function TRankingOptionsParams.Ranker(
  const Value: string): TRankingOptionsParams;
begin
  Result := TRankingOptionsParams(Add('ranker', Value));
end;

function TRankingOptionsParams.ScoreThreshold(
  const Value: Double): TRankingOptionsParams;
begin
  Result := TRankingOptionsParams(Add('score_threshold', Value));
end;

{ TFunctionParams }

function TFunctionParams.Description(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('description', Value));
end;

function TFunctionParams.Name(const Value: string): TFunctionParams;
begin
  Result := TFunctionParams(Add('name', Value));
end;

function TFunctionParams.Parameters(const Value: TJSONObject): TFunctionParams;
begin
  Result := TFunctionParams(Add('parameters', Value));
end;

function TFunctionParams.&Strict(const Value: Boolean): TFunctionParams;
begin
  Result := TFunctionParams(Add('strict', Value));
end;

function TFunctionParams.Parameters(
  const Value: TSchemaParams): TFunctionParams;
begin
  Result := TFunctionParams(Add('parameters', Value.Detach));
end;

{ TToolResourcesParams }

function TToolResourcesParams.CodeInterpreter(
  const Value: TCodeInterpreterParams): TToolResourcesParams;
begin
  Result := TToolResourcesParams(Add('code_interpreter', Value.Detach));
end;

function TToolResourcesParams.CodeInterpreter(
  const FileIds: TArray<string>): TToolResourcesParams;
begin
  Result := TToolResourcesParams(Add('code_interpreter', TCodeInterpreterParams.Create.FileIds(FileIds)));
end;

function TToolResourcesParams.FileSearch(
  const Value: TFileSearchParams): TToolResourcesParams;
begin
  Result := TToolResourcesParams(Add('file_search', Value.Detach));
end;

{ TCodeInterpreterParams }

function TCodeInterpreterParams.FileIds(
  const Value: TArray<string>): TCodeInterpreterParams;
begin
  Result := TCodeInterpreterParams(Add('file_ids', Value));
end;

{ TFileSearchParams }

function TFileSearchParams.VectorStoreIds(
  const Value: TArray<string>): TFileSearchParams;
begin
  Result := TFileSearchParams(Add('vector_store_ids', Value));
end;

function TFileSearchParams.VectorStores(
  const Value: TArray<TVectorStoresParams>): TFileSearchParams;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item.Detach);
  Result := TFileSearchParams(Add('vector_stores', JSONArray));
end;

{ TVectorStoresParams }

function TVectorStoresParams.ChunkingStrategy(
  const Value: TChunkingStrategyParams): TVectorStoresParams;
begin
  Result := TVectorStoresParams(Add('chunking_strategy', Value.Detach));
end;

function TVectorStoresParams.FileIds(
  const Value: TArray<string>): TVectorStoresParams;
begin
  Result := TVectorStoresParams(Add('file_ids', Value));
end;

function TVectorStoresParams.Metadata(
  const Value: TJSONObject): TVectorStoresParams;
begin
  Result := TVectorStoresParams(Add('metadata', Value));
end;

{ TChunkingStrategyParams }

function TChunkingStrategyParams.Static(
  const Value: TChunkStaticParams): TChunkingStrategyParams;
begin
  Result := TChunkingStrategyParams(Add('static', Value.Detach));
end;

function TChunkingStrategyParams.&Type(
  const Value: string): TChunkingStrategyParams;
begin
  Result := TChunkingStrategyParams(Add('type', TChunkingStrategyType.Create(Value).ToString));
end;

function TChunkingStrategyParams.&Type(
  const Value: TChunkingStrategyType): TChunkingStrategyParams;
begin
  Result := TChunkingStrategyParams(Add('type', Value.ToString));
end;

{ TChunkStaticParams }

function TChunkStaticParams.ChunkOverlapTokens(
  const Value: Integer): TChunkStaticParams;
begin
  Result := TChunkStaticParams(Add('chunk_overlap_tokens', Value));
end;

function TChunkStaticParams.MaxChunkSizeTokens(
  const Value: Integer): TChunkStaticParams;
begin
  Result := TChunkStaticParams(Add('max_chunk_size_tokens', Value));
end;

{ TResponseFormatParams }

function TResponseFormatParams.&Type(
  const Value: string): TResponseFormatParams;
begin
  Result := TResponseFormatParams(Add('type', TResponseFormatType.Create(Value).ToString));
end;

function TResponseFormatParams.JsonSchema(
  const Value: TJsonSchemaParams): TResponseFormatParams;
begin
  Result := TResponseFormatParams(Add('json_schema', Value.Detach));
end;

function TResponseFormatParams.&Type(
  const Value: TResponseFormatType): TResponseFormatParams;
begin
  Result := TResponseFormatParams(Add('type', Value.ToString));
end;

{ TJsonSchemaParams }

function TJsonSchemaParams.Description(const Value: string): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('description', Value));
end;

function TJsonSchemaParams.Name(const Value: string): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('name', Value));
end;

function TJsonSchemaParams.Schema(const Value: TJSONObject): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('schema', Value));
end;

function TJsonSchemaParams.&Strict(const Value: Boolean): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('strict', Value));
end;

function TJsonSchemaParams.Schema(
  const Value: TSchemaParams): TJsonSchemaParams;
begin
  Result := TJsonSchemaParams(Add('schema', Value.Detach));
end;

{ TAssistant }

destructor TAssistant.Destroy;
begin
  for var Item in FTools do
    Item.Free;
  if Assigned(FToolResources) then
    FToolResources.Free;
  inherited;
end;

{ TAssistantsFileSearch }

destructor TAssistantsFileSearch.Destroy;
begin
  if Assigned(FRankingOptions) then
    FRankingOptions.Free;
  inherited;
end;

{ TAssistantsTools }

destructor TAssistantsTools.Destroy;
begin
  if Assigned(FFileSearch) then
    FFileSearch.Free;
  if Assigned(FFunction) then
    FFunction.Free;
  inherited;
end;

{ TToolResources }

destructor TToolResources.Destroy;
begin
  if Assigned(FCodeInterpreter) then
    FCodeInterpreter.Free;
  if Assigned(FFileSearch) then
    FFileSearch.Free;
  inherited;
end;

{ TAssistantsRoute }

procedure TAssistantsRoute.AsynCreate(const ParamProc: TProc<TAssistantsParams>;
  const CallBacks: TFunc<TAsynAssistant>);
begin
  with TAsynCallBackExec<TAsynAssistant, TAssistant>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistant
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynList(const CallBacks: TFunc<TAsynAssistants>);
begin
  with TAsynCallBackExec<TAsynAssistants, TAssistants>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistants
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynDelete(const AssistantId: string;
  const CallBacks: TFunc<TAsynAssistantDeletion>);
begin
  with TAsynCallBackExec<TAsynAssistantDeletion, TAssistantDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistantDeletion
      begin
        Result := Self.Delete(AssistantId);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynList(const ParamProc: TProc<TUrlAdvancedParams>;
  const CallBacks: TFunc<TAsynAssistants>);
begin
  with TAsynCallBackExec<TAsynAssistants, TAssistants>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistants
      begin
        Result := Self.List(ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynRetrieve(const AssistantId: string;
  const CallBacks: TFunc<TAsynAssistant>);
begin
  with TAsynCallBackExec<TAsynAssistant, TAssistant>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistant
      begin
        Result := Self.Retrieve(AssistantId);
      end);
  finally
    Free;
  end;
end;

procedure TAssistantsRoute.AsynUpdate(const AssistantId: string;
  const ParamProc: TProc<TAssistantsParams>;
  const CallBacks: TFunc<TAsynAssistant>);
begin
  with TAsynCallBackExec<TAsynAssistant, TAssistant>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TAssistant
      begin
        Result := Self.Update(AssistantId, ParamProc);
      end);
  finally
    Free;
  end;
end;

function TAssistantsRoute.Create(
  const ParamProc: TProc<TAssistantsParams>): TAssistant;
begin
  Result := API.Post<TAssistant, TAssistantsParams>('assistants', ParamProc);
end;

function TAssistantsRoute.List: TAssistants;
begin
  Result := API.Get<TAssistants>('assistants');
end;

function TAssistantsRoute.Delete(const AssistantId: string): TAssistantDeletion;
begin
  Result := API.Delete<TAssistantDeletion>('assistants/' + AssistantId);
end;

function TAssistantsRoute.List(
  const ParamProc: TProc<TUrlAdvancedParams>): TAssistants;
begin
  Result := API.Get<TAssistants, TUrlAdvancedParams>('assistants', ParamProc);
end;

function TAssistantsRoute.Retrieve(const AssistantId: string): TAssistant;
begin
  Result := API.Get<TAssistant>('assistants/' + AssistantId );
end;

function TAssistantsRoute.Update(const AssistantId: string;
  const ParamProc: TProc<TAssistantsParams>): TAssistant;
begin
  Result := API.Post<TAssistant, TAssistantsParams>('assistants/' + AssistantId, ParamProc);
end;

{ TAdvancedList<T> }

destructor TAdvancedList<T>.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

end.
