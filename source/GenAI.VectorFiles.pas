unit GenAI.VectorFiles;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, System.Net.URLClient,
  GenAI.API.Params, GenAI.API, GenAI.Consts, GenAI.Types, GenAI.Async.Support,
  GenAI.API.Lists, GenAI.API.Deletion, GenAI.Assistants, GenAI.Runs;

type
  TVectorStoreFilesUrlParams = class(TUrlAdvancedParams)
  public
    function Filter(const Value: string): TVectorStoreFilesUrlParams;
  end;

  TVectorStoreFilesCreateParams = class(TJSONParam)
  public
    function FileId(const Value: string): TVectorStoreFilesCreateParams;
    function ChunkingStrategy(const Value: TChunkingStrategyParams): TVectorStoreFilesCreateParams;
  end;

  TChunkingStrategyStatic = class
  private
    [JsonNameAttribute('max_chunk_size_tokens')]
    FMaxChunkSizeTokens: Int64;
    [JsonNameAttribute('chunk_overlap_tokens')]
    FChunkOverlapTokens: Int64;
  public
    property MaxChunkSizeTokens: Int64 read FMaxChunkSizeTokens write FMaxChunkSizeTokens;
    property ChunkOverlapTokens: Int64 read FChunkOverlapTokens write FChunkOverlapTokens;
  end;

  TChunkingStrategy = class
  private
    FType: string;
    FStatic: TChunkingStrategyStatic;
  public
    property &Type: string read FType write FType;
    property Static: TChunkingStrategyStatic read FStatic write FStatic;
    destructor Destroy; override;
  end;

  TVectorStoreFile = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    [JsonNameAttribute('usage_bytes')]
    FUsageBytes: Int64;
    [JsonNameAttribute('created_at')]
    FCreatedAt: Int64;
    [JsonNameAttribute('vector_store_id')]
    FVectorStoreId: string;
    [JsonReflectAttribute(ctString, rtString, TRunStatusInterceptor)]
    FStatus: TRunStatus;
    [JsonNameAttribute('last_error')]
    FLastError: TLastError;
    [JsonNameAttribute('chunking_strategy')]
    FChunkingStrategy: TChunkingStrategy;
  private
    function GetCreatedAtAsString: string;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property UsageBytes: Int64 read FUsageBytes write FUsageBytes;
    property CreatedAt: Int64 read FCreatedAt write FCreatedAt;
    property CreatedAtAsString: string read GetCreatedAtAsString;
    property VectorStoreId: string read FVectorStoreId write FVectorStoreId;
    property Status: TRunStatus read FStatus write FStatus;
    property LastError: TLastError read FLastError write FLastError;
    property ChunkingStrategy: TChunkingStrategy read FChunkingStrategy write FChunkingStrategy;
    destructor Destroy; override;
  end;

  TVectorStoreFiles = TAdvancedList<TVectorStoreFile>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreFile</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreFile</c> type extends the <c>TAsynParams&lt;TVectorStoreFile&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreFile = TAsynCallBack<TVectorStoreFile>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TVectorStoreFiles</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynVectorStoreFiles</c> type extends the <c>TAsynParams&lt;TVectorStoreFiles&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynVectorStoreFiles = TAsynCallBack<TVectorStoreFiles>;

  TVectorStoreFilesRoute = class(TGenAIRoute)
  protected
    procedure HeaderCustomize; override;
  public
    procedure AsynCreate(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreFilesCreateParams>;
      const CallBacks: TFunc<TAsynVectorStoreFile>);
    procedure AsynList(const VectorStoreId: string;
      const CallBacks: TFunc<TAsynVectorStoreFiles>); overload;
    procedure AsynList(const VectorStoreId: string;
      const ParamProc: TProc<TVectorStoreFilesUrlParams>;
      const CallBacks: TFunc<TAsynVectorStoreFiles>); overload;
    procedure AsynRetrieve(const VectorStoreId: string; const FileId: string;
      const CallBacks: TFunc<TAsynVectorStoreFile>);
    procedure AsynDelete(const VectorStoreId: string; const FileId: string;
      const CallBacks: TFunc<TAsynDeletion>);
    function Create(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreFilesCreateParams>): TVectorStoreFile;
    function List(const VectorStoreId: string): TVectorStoreFiles; overload;
    function List(const VectorStoreId: string; const ParamProc: TProc<TVectorStoreFilesUrlParams>): TVectorStoreFiles; overload;
    function Retrieve(const VectorStoreId: string; const FileId: string): TVectorStoreFile;
    function Delete(const VectorStoreId: string; const FileId: string): TDeletion;
  end;

implementation

{ TVectorStoreFilesCreateParams }

function TVectorStoreFilesCreateParams.ChunkingStrategy(
  const Value: TChunkingStrategyParams): TVectorStoreFilesCreateParams;
begin
  Result := TVectorStoreFilesCreateParams(Add('chunking_strategy', Value.Detach));
end;

function TVectorStoreFilesCreateParams.FileId(
  const Value: string): TVectorStoreFilesCreateParams;
begin
  Result := TVectorStoreFilesCreateParams(Add('file_id', Value));
end;

{ TVectorStoreFile }

destructor TVectorStoreFile.Destroy;
begin
  if Assigned(FLastError) then
    FLastError.Free;
  if Assigned(FChunkingStrategy) then
    FChunkingStrategy.Free;
  inherited;
end;

function TVectorStoreFile.GetCreatedAtAsString: string;
begin
  Result := TimestampToString(CreatedAt, UTCtimestamp);
end;

{ TChunkingStrategy }

destructor TChunkingStrategy.Destroy;
begin
  if Assigned(FStatic) then
    FStatic.Free;
  inherited;
end;

{ TVectorStoreFilesRoute }

procedure TVectorStoreFilesRoute.AsynCreate(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesCreateParams>;
  const CallBacks: TFunc<TAsynVectorStoreFile>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFile, TVectorStoreFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFile
      begin
        Result := Self.Create(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynDelete(const VectorStoreId, FileId: string;
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
        Result := Self.Delete(VectorStoreId, FileId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynList(const VectorStoreId: string;
  const CallBacks: TFunc<TAsynVectorStoreFiles>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFiles, TVectorStoreFiles>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFiles
      begin
        Result := Self.List(VectorStoreId);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynList(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesUrlParams>;
  const CallBacks: TFunc<TAsynVectorStoreFiles>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFiles, TVectorStoreFiles>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFiles
      begin
        Result := Self.List(VectorStoreId, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TVectorStoreFilesRoute.AsynRetrieve(const VectorStoreId,
  FileId: string; const CallBacks: TFunc<TAsynVectorStoreFile>);
begin
  with TAsynCallBackExec<TAsynVectorStoreFile, TVectorStoreFile>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVectorStoreFile
      begin
        Result := Self.Retrieve(VectorStoreId, FileId);
      end);
  finally
    Free;
  end;
end;

function TVectorStoreFilesRoute.Create(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesCreateParams>): TVectorStoreFile;
begin
  HeaderCustomize;
  Result := API.Post<TVectorStoreFile, TVectorStoreFilesCreateParams>('vector_stores/' + VectorStoreId + '/files', ParamProc);
end;

function TVectorStoreFilesRoute.Delete(const VectorStoreId,
  FileId: string): TDeletion;
begin
  HeaderCustomize;
  Result := API.Delete<TDeletion>('vector_stores/' + VectorStoreId + '/files/' + FileId);
end;

procedure TVectorStoreFilesRoute.HeaderCustomize;
begin
  inherited;
  API.CustomHeaders := [TNetHeader.Create('OpenAI-Beta', 'assistants=v2')];
end;

function TVectorStoreFilesRoute.List(
  const VectorStoreId: string): TVectorStoreFiles;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreFiles>('vector_stores/' + VectorStoreId + '/files');
end;

function TVectorStoreFilesRoute.List(const VectorStoreId: string;
  const ParamProc: TProc<TVectorStoreFilesUrlParams>): TVectorStoreFiles;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreFiles, TVectorStoreFilesUrlParams>('vector_stores/' + VectorStoreId + '/files', ParamProc);
end;

function TVectorStoreFilesRoute.Retrieve(const VectorStoreId,
  FileId: string): TVectorStoreFile;
begin
  HeaderCustomize;
  Result := API.Get<TVectorStoreFile>('vector_stores/' + VectorStoreId + '/files/' + FileId);
end;

{ TVectorStoreFilesUrlParams }

function TVectorStoreFilesUrlParams.Filter(
  const Value: string): TVectorStoreFilesUrlParams;
begin
  Result := TVectorStoreFilesUrlParams(Add('filter', Value));
end;

end.
