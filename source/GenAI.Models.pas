unit GenAI.Models;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, REST.Json.Types,
  GenAI.API.Params, GenAI.API, GenAI.Async.Support, GenAI.API.Deletion,
  GenAI.Types;

type
  /// <summary>
  /// Represents an OpenAI model, encapsulating key information about a specific API model.
  /// </summary>
  /// <remarks>
  /// The TModel class stores attributes such as the unique identifier, creation timestamp,
  /// object type, and ownership details of the model. This class is typically used to handle
  /// and manipulate data related to models provided by OpenAI's API.
  /// </remarks>
  TModel = class(TJSONFingerprint)
  private
    FId: string;
    FCreated: TInt64OrNull;
    FObject: string;
    [JsonNameAttribute('owned_by')]
    FOwnedBy: string;
  private
    function GetCreatedAsString: string;
    function GetCreated: Int64;
  public
    /// <summary>
    /// Gets or sets the unique identifier of the model.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets the creation timestamp of the model, represented as a Unix timestamp.
    /// </summary>
    property Created: Int64 read GetCreated;
    /// <summary>
    /// Gets the creation timestamp of the model as a string.
    /// </summary>
    property CreatedAsString: string read GetCreatedAsString;
    /// <summary>
    /// Gets or sets the object type, which is consistently set to "model".
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the identifier of the organization that owns the model.
    /// </summary>
    property OwnedBy: string read FOwnedBy write FOwnedBy;
  end;

  /// <summary>
  /// Represents a collection of OpenAI models, providing a list structure for managing multiple model instances.
  /// </summary>
  /// <remarks>
  /// The TModels class encapsulates a list of TModel objects, each representing detailed information about
  /// individual models. This collection is useful for operations that require handling multiple models,
  /// such as listing all available models from the OpenAI API.
  /// </remarks>
  TModels = class(TJSONFingerprint)
  private
    FObject: string;
    FData: TArray<TModel>;
  public
    /// <summary>
    /// Gets or sets the type of object, consistently set to "list" in this context.
    /// </summary>
    property &Object: string read FObject write FObject;
    /// <summary>
    /// Gets or sets the array of model objects, providing access to multiple models.
    /// </summary>
    property Data: TArray<TModel> read FData write FData;
    /// <summary>
    /// Destructor to manage the cleanup of the array items when the TModels object is destroyed.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TModel</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModel</c> type extends the <c>TAsynParams&lt;TModel&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynModel = TAsynCallBack<TModel>;

  /// <summary>
  /// Manages asynchronous callBacks for a request using <c>TModels</c> as the response type.
  /// </summary>
  /// <remarks>
  /// The <c>TAsynModels</c> type extends the <c>TAsynParams&lt;TModels&gt;</c> record to handle the lifecycle of an asynchronous chat operation.
  /// It provides event handlers that trigger at various stages, such as when the operation starts, completes successfully, or encounters an error.
  /// This structure facilitates non-blocking operations.
  /// </remarks>
  TAsynModels = TAsynCallBack<TModels>;

  /// <summary>
  /// Provides routes for managing model data via API calls, including listing, retrieving, and deleting models.
  /// </summary>
  /// <remarks>
  /// The TModelsRoute class includes methods that facilitate asynchronous and synchronous operations
  /// to list, delete, and retrieve OpenAI models through the API. It acts as a controller for the
  /// interaction with the OpenAI model endpoints.
  /// </remarks>
  TModelsRoute = class(TGenAIRoute)
    /// <summary>
    /// Asynchronously lists all available models and returns them in a TModels object through a callback mechanism.
    /// </summary>
    /// <param name="CallBacks">A set of callback functions for success, error, and start conditions.</param>
    procedure AsynList(const CallBacks: TFunc<TAsynModels>);
    /// <summary>
    /// Asynchronously deletes a specified model by ID and returns the deletion status through a callback mechanism.
    /// </summary>
    /// <param name="ModelId">The unique identifier of the model to be deleted.</param>
    /// <param name="CallBacks">A set of callback functions for success, error, and start conditions.</param>
    procedure AsynDelete(const ModelId: string; const CallBacks: TFunc<TAsynDeletion>);
    /// <summary>
    /// Asynchronously retrieves a specific model by ID and returns it in a TModel object through a callback mechanism.
    /// </summary>
    /// <param name="ModelId">The unique identifier of the model to be retrieved.</param>
    /// <param name="CallBacks">A set of callback functions for success, error, and start conditions.</param>
    procedure AsynRetrieve(const ModelId: string; const CallBacks: TFunc<TAsynModel>);
    /// <summary>
    /// Synchronously lists all available models and returns them in a TModels object.
    /// </summary>
    /// <returns>A TModels object containing a list of all models.</returns>
    function List: TModels;
    /// <summary>
    /// Synchronously deletes a specified model by ID and returns the deletion status.
    /// </summary>
    /// <param name="ModelId">The unique identifier of the model to be deleted.</param>
    /// <returns>A TModelDeletion object indicating the status of the deletion.</returns>
    function Delete(const ModelId: string): TDeletion;
    /// <summary>
    /// Synchronously retrieves a specific model by ID and returns it in a TModel object.
    /// </summary>
    /// <param name="ModelId">The unique identifier of the model to be retrieved.</param>
    /// <returns>A TModel object containing the model details.</returns>
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

function TModelsRoute.Delete(const ModelId: string): TDeletion;
begin
  Result := API.Delete<TDeletion>(Format('models/%s', [ModelId]));
end;

function TModelsRoute.List: TModels;
begin
  Result := API.Get<TModels>('models');
end;

function TModelsRoute.Retrieve(const ModelId: string): TModel;
begin
  Result := API.Get<TModel>(Format('models/%s', [ModelId]));
end;

{ TModel }

function TModel.GetCreated: Int64;
begin
  Result := TInt64OrNull(FCreated).ToInteger;
end;

function TModel.GetCreatedAsString: string;
begin
  Result := TInt64OrNull(FCreated).ToUtcDateString;
end;

end.
