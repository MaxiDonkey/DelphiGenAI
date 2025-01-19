unit GenAI.Embeddings;

interface

uses
  System.SysUtils, System.Classes, System.Threading, REST.Json.Types,
  GenAI.API.Params, GenAI.API, GenAI.Async.Support;

type
  TEncodingFormat = (
    float,
    base64
  );

  TEncodingFormatHelper = record Helper for TEncodingFormat
    function ToString: string;
  end;

  TEmbeddingsParams = class(TJSONParam)
  public
    function Input(const Value: string): TEmbeddingsParams; overload;
    function Input(const Value: TArray<string>): TEmbeddingsParams; overload;
    function Model(const Value: string): TEmbeddingsParams;
    function EncodingFormat(const Value: TEncodingFormat): TEmbeddingsParams;
    function Dimensions(const Value: Integer): TEmbeddingsParams;
    function User(const Value: string): TEmbeddingsParams;
  end;

  TEmbedding = class(TJSONFingerprint)
  private
    FIndex: Int64;
    FEmbedding: TArray<Double>;
    FObject: string;
  public
    property Index: Int64 read FIndex write FIndex;
    property Embedding: TArray<Double> read FEmbedding write FEmbedding;
    property &Object: string read FObject write FObject;
  end;

  TEmbeddings = class(TJSONFingerprint)
  private
    FObject: string;
    FData: TArray<TEmbedding>;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TEmbedding> read FData write FData;
    destructor Destroy; override;
  end;

  TAsynEmbeddings = TAsynCallBack<TEmbeddings>;

  TEmbeddingsRoute = class(TGenAIRoute)
    procedure AsynCreate(const ParamProc: TProc<TEmbeddingsParams>; const CallBacks: TFunc<TAsynEmbeddings>);
    function Create(const ParamProc: TProc<TEmbeddingsParams>): TEmbeddings;
  end;

implementation

{ TEmbeddingsParams }

function TEmbeddingsParams.Input(const Value: string): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('input', Value));
end;

function TEmbeddingsParams.Dimensions(const Value: Integer): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('dimensions', Value));
end;

function TEmbeddingsParams.EncodingFormat(
  const Value: TEncodingFormat): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('encoding_format', Value.ToString));
end;

function TEmbeddingsParams.Input(
  const Value: TArray<string>): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('input', Value));
end;

function TEmbeddingsParams.Model(const Value: string): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('model', Value));
end;

function TEmbeddingsParams.User(const Value: string): TEmbeddingsParams;
begin
  Result := TEmbeddingsParams(Add('user', Value));
end;

{ TEncodingFormatHelper }

function TEncodingFormatHelper.ToString: string;
begin
  case Self of
    float:
      Exit('float');
    base64:
      Exit('base64');
  end;
end;

{ TEmbeddings }

destructor TEmbeddings.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TEmbeddingsRoute }

procedure TEmbeddingsRoute.AsynCreate(const ParamProc: TProc<TEmbeddingsParams>;
  const CallBacks: TFunc<TAsynEmbeddings>);
begin
  with TAsynCallBackExec<TAsynEmbeddings, TEmbeddings>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TEmbeddings
      begin
        Result := Self.Create(ParamProc);
      end);
  finally
    Free;
  end;
end;

function TEmbeddingsRoute.Create(
  const ParamProc: TProc<TEmbeddingsParams>): TEmbeddings;
begin
  Result := API.Post<TEmbeddings, TEmbeddingsParams>('embeddings', ParamProc);
end;

end.
