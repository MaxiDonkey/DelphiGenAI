unit GenAI.Models;

interface

uses
  System.SysUtils, System.Classes, System.Threading, REST.Json.Types,
  GenAI.API.Params, GenAI.API, GenAI.Async.Support;

type
  TModel = class(TJSONFingerprint)
  private
    FId: string;
    FCreated: Int64;
    FObject: string;
    [JsonNameAttribute('owned_by')]
    FOwnedBy: string;
  public
    property Id: string read FId write FId;
    property Created: Int64 read FCreated write FCreated;
    property &Object: string read FObject write FObject;
    property OwnedBy: string read FOwnedBy write FOwnedBy;
  end;

  TModels = class(TJSONFingerprint)
  private
    FObject: string;
    FData: TArray<TModel>;
  public
    property &Object: string read FObject write FObject;
    property Data: TArray<TModel> read FData write FData;
    destructor Destroy; override;
  end;

  TModelDeletion = class(TJSONFingerprint)
  private
    FId: string;
    FObject: string;
    FDeleted: Boolean;
  public
    property Id: string read FId write FId;
    property &Object: string read FObject write FObject;
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  TAsynModel = TAsynCallBack<TModel>;

  TAsynModels = TAsynCallBack<TModels>;

  TAsynModelDeletion = TAsynCallBack<TModelDeletion>;

  TModelsRoute = class(TGenAIRoute)
    procedure AsynList(const CallBacks: TFunc<TAsynModels>);
    procedure AsynDelete(const ModelId: string; const CallBacks: TFunc<TAsynModelDeletion>);
    procedure AsynRetrieve(const ModelId: string; const CallBacks: TFunc<TAsynModel>);
    function List: TModels;
    function Delete(const ModelId: string): TModelDeletion;
    function Retrieve(const ModelId: string): TModel;
  end;

implementation

{ TModels }

destructor TModels.Destroy;
begin
  for var Item in FData do
    Item.Free;
  inherited;
end;

{ TModelsRoute }

procedure TModelsRoute.AsynDelete(const ModelId: string;
  const CallBacks: TFunc<TAsynModelDeletion>);
begin
  with TAsynCallBackExec<TAsynModelDeletion, TModelDeletion>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModelDeletion
      begin
        Result := Self.Delete(ModelId);
      end);
  finally
    Free;
  end;
end;

procedure TModelsRoute.AsynList(const CallBacks: TFunc<TAsynModels>);
begin
  with TAsynCallBackExec<TAsynModels, TModels>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModels
      begin
        Result := Self.List;
      end);
  finally
    Free;
  end;
end;

procedure TModelsRoute.AsynRetrieve(const ModelId: string;
  const CallBacks: TFunc<TAsynModel>);
begin
  with TAsynCallBackExec<TAsynModel, TModel>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TModel
      begin
        Result := Self.Retrieve(ModelId);
      end);
  finally
    Free;
  end;
end;

function TModelsRoute.Delete(const ModelId: string): TModelDeletion;
begin
  Result := API.Delete<TModelDeletion>(Format('models/%s', [ModelId]));
end;

function TModelsRoute.List: TModels;
begin
  Result := API.Get<TModels>('models');
end;

function TModelsRoute.Retrieve(const ModelId: string): TModel;
begin
  Result := API.Get<TModel>(Format('models/%s', [ModelId]));
end;

end.
