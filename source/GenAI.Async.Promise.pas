unit GenAI.Async.Promise;

(*******************************************************************************

      Unit providing a generic implementation of Promises for handling
      asynchronous operations in Delphi.

      The ASync.Promise unit enables structured handling of asynchronous
      tasks using Promises, allowing for a clean and readable
      asynchronous programming model similar to JavaScript Promises.

      Primary components include:

        - TPromise<T>: A generic class representing a promise that can be
          resolved or rejected asynchronously.
        - TPromiseState: An enumeration indicating the state of a promise
          (Pending, Fulfilled, or Rejected).
        - TPromiseRegistry: An internal registry that tracks all pending
          promises to prevent premature destruction.
        - Chained methods for structured handling:
          - &Then<T>: Chains operations to execute after a promise resolves.
          - &Catch: Handles errors occurring within a promise chain.

      These abstractions allow a structured and reusable way to manage
      asynchronous execution without deeply nested callbacks, facilitating
      a cleaner approach to asynchronous programming in Delphi.

  Example Usage:

  ```delphi
  procedure ExampleAsyncProcess;
  begin
    var Promise := TPromise<string>.Create(
      procedure(Resolve: TProc<string>; Reject: TProc<Exception>)
      begin
        TTask.Run(
        procedure()
        begin
          TThread.Queue(nil,
            procedure
            begin
              Sleep(2000); // Simulating asynchronous work
              if Random(2) = 0 then
                Resolve('Operation Successful')
              else
                Reject(Exception.Create('Operation Failed'));
            end)
        end)
      end);

    Promise
      .&Then(
        procedure(Value: string)
        begin
          ShowMessage('Success: ' + Value);
        end)
      .&Catch(
        procedure(E: Exception)
        begin
          ShowMessage('Error: ' + E.Message);
        end);
  end;
  ```

      The unit is designed to work seamlessly with other asynchronous
      programming modules, making it a powerful addition to any Delphi
      application requiring structured async execution.

*******************************************************************************)

interface

uses
  System.SysUtils, System.Generics.Collections, System.Classes, System.Threading;

type
  /// <summary>
  /// Represents the state of a Promise.
  /// </summary>
  TPromiseState = (
    /// <summary>
    /// The promise is pending and has not yet been resolved or rejected.
    /// </summary>
    psPending,
    /// <summary>
    /// The promise has been fulfilled with a value.
    /// </summary>
    psFulfilled,
    /// <summary>
    /// The promise has been rejected due to an error.
    /// </summary>
    psRejected
  );

  /// <summary>
  /// Abstract base class for promise implementations.
  /// </summary>
  /// <remarks>
  /// Provides a common interface for retrieving the current state
  /// of a promise. All concrete promise types must implement
  /// <see cref="GetState"/> to indicate whether they are pending,
  /// fulfilled, or rejected.
  /// </remarks>
  TPromiseBase = class abstract
  strict protected
    /// <summary>
    /// Returns the current state of the promise.
    /// </summary>
    /// <returns>
    /// A <see cref="TPromiseState"/> value indicating whether the
    /// promise is pending, fulfilled, or rejected.
    /// </returns>
    function GetState: TPromiseState; virtual; abstract;
  public
    /// <summary>
    /// Read-only property exposing the promise’s current state.
    /// </summary>
    /// <value>
    /// The <see cref="TPromiseState"/> of the promise.
    /// </value>
    property State: TPromiseState read GetState;
  end;

  /// <summary>
  /// A generic class that represents an asynchronous operation that may complete in the future.
  /// </summary>
  /// <typeparam name="T">The type of the value that the promise resolves with.</typeparam>
  TPromise<T> = class(TPromiseBase)
  public
    type
      /// <summary>
      /// Defines the executor procedure for a promise, providing callbacks
      /// to signal fulfillment or rejection of the asynchronous operation.
      /// </summary>
      /// <param name="Resolve">
      /// A callback that accepts a value of type T and transitions the promise
      /// into the fulfilled state with that value.
      /// </param>
      /// <param name="Reject">
      /// A callback that accepts an Exception and transitions the promise
      /// into the rejected state with that error.
      /// </param>
      TExecutor = reference to procedure(Resolve: TProc<T>; Reject: TProc<Exception>);
  private
    FState: TPromiseState;
    FValue: T;
    FError: Exception;
    FThenHandlers: TList<TProc<T>>;
    FCatchHandlers: TList<TProc<Exception>>;
    FHandlerLock: TObject;

    class function CloneException(E: Exception): Exception; static;

    /// <summary>
    /// Resolves the promise with a given value.
    /// </summary>
    /// <param name="AValue">The value to resolve the promise with.</param>
    procedure Resolve(const AValue: T);

    /// <summary>
    /// Rejects the promise with a given error.
    /// </summary>
    /// <param name="AError">The exception that caused the rejection.</param>
    procedure Reject(AError: Exception);

  strict protected
    /// <summary>
    /// Returns the current state of the promise.
    /// </summary>
    /// <returns>
    /// A <see cref="TPromiseState"/> value indicating whether the
    /// promise is pending, fulfilled, or rejected.
    /// </returns>
    function GetState: TPromiseState; override;

  public
    /// <summary>
    /// Initializes a new instance of the <see cref="TPromise{T}"/> class and starts the asynchronous operation.
    /// </summary>
    /// <param name="AExecutor">The executor function that starts the asynchronous task.</param>
    constructor Create(AExecutor: TExecutor);

    /// <summary>
    /// Destroys the promise instance and releases any associated resources.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Attaches a fulfillment callback that is executed when the promise is resolved.
    /// </summary>
    /// <param name="AOnFulfill">A callback function executed upon fulfillment.</param>
    /// <returns>A new promise to allow method chaining.</returns>
    function &Then(AOnFulfill: TProc): TPromise<T>; overload;

    /// <summary>
    /// Attaches a fulfillment callback that receives the resolved value.
    /// </summary>
    /// <param name="AOnFulfill">A callback function that receives the resolved value.</param>
    /// <returns>A new promise to allow method chaining.</returns>
    function &Then(AOnFulfill: TProc<T>): TPromise<T>; overload;

    /// <summary>
    /// Attaches a fulfillment callback that returns a transformed value of a different type.
    /// </summary>
    /// <typeparam name="TResult">The type of the transformed result.</typeparam>
    /// <param name="AOnFulfill">A function that produces the transformed result.</param>
    /// <returns>A new promise that resolves with the transformed value.</returns>
    function &Then<TResult>(AOnFulfill: TFunc<TResult>): TPromise<TResult>; overload;

    /// <summary>
    /// Attaches a fulfillment callback that returns another promise of a different type.
    /// </summary>
    /// <typeparam name="TResult">The type of the new promise’s result.</typeparam>
    /// <param name="AOnFulfill">A function that returns a new promise.</param>
    /// <returns>A new promise that resolves with the value of the returned promise.</returns>
    function &Then<TResult>(AOnFulfill: TFunc<T, TPromise<TResult>>): TPromise<TResult>; overload;

    /// <summary>
    /// Attaches a fulfillment callback that returns another promise of the same type.
    /// </summary>
    /// <param name="AOnFulfill">A function that returns a new promise of the same type.</param>
    /// <returns>A new promise that resolves with the value of the returned promise.</returns>
    function &Then(AOnFulfill: TFunc<T, TPromise<T>>): TPromise<T>; overload;

    /// <summary>
    /// Attaches a fulfillment callback that transforms the resolved value into another type.
    /// </summary>
    /// <typeparam name="TResult">The type of the transformed value.</typeparam>
    /// <param name="AOnFulfill">A function that transforms the resolved value.</param>
    /// <returns>A new promise that resolves with the transformed value.</returns>
    function &Then<TResult>(AOnFulfill: TFunc<T, TResult>): TPromise<TResult>; overload;

    /// <summary>
    /// Attaches a rejection callback to handle errors if the promise is rejected.
    /// </summary>
    /// <param name="AOnReject">A callback function that handles the error.</param>
    /// <returns>A new promise to allow method chaining.</returns>
    function &Catch(AOnReject: TProc<Exception>): TPromise<T>;

    class function Resolved(const AValue: T; Proc: TProc = nil): TPromise<T>;

    class function Rejected(AError: Exception; Proc: TProc = nil): TPromise<T>;

  end;

  /// <summary>
  /// Maintains a global registry of all pending promises, ensuring they
  /// are kept alive until they are fulfilled or rejected.
  /// </summary>
  /// <remarks>
  /// This sealed class provides thread-safe methods to add and remove
  /// promises from the registry, as well as a manual cleanup routine
  /// to prune completed promises.  It is used internally by
  /// <see cref="TPromise{T}"/> to prevent premature destruction of
  /// promises that are still pending.
  /// </remarks>
  TPromiseRegistry = class sealed
  strict private
    class var FList : TObjectList<TObject>;
    class var FLock : TObject;
  public
    /// <summary>
    /// Initializes the promise registry and its internal lock.
    /// </summary>
    class constructor Create;

    /// <summary>
    /// Releases all resources held by the promise registry.
    /// </summary>
    class destructor  Destroy;

    /// <summary>
    /// Adds a promise instance to the registry, preventing it
    /// from being freed until it transitions out of the pending state.
    /// </summary>
    /// <param name="APromise">
    /// The promise instance to register.
    /// </param>
    class procedure Add(APromise: TObject);

    /// <summary>
    /// Removes a promise instance from the registry, allowing it
    /// to be freed if it is no longer referenced elsewhere.
    /// </summary>
    /// <param name="APromise">
    /// The promise instance to unregister.
    /// </param>
    class procedure Remove(APromise: TObject);

    /// <summary>
    /// Removes later a promise instance from the registry, allowing it
    /// to be freed if it is no longer referenced elsewhere.
    /// </summary>
    /// <param name="APromise">
    /// The promise instance to unregister.
    /// </param>
    class procedure RemoveLater(APromise: TObject);

    /// <summary>
    /// Scans the registry and deletes any promises that are no longer
    /// pending (i.e., fulfilled or rejected), releasing their memory.
    /// </summary>
    /// <remarks>
    /// This method can be called manually if you need to force
    /// cleanup of completed promises before their <see cref="TPromise{T}"/>
    /// callbacks are all delivered.
    /// </remarks>
    class procedure Cleanup;

    /// <summary>
    /// Removes and frees all promises in the registry, regardless of their state.
    /// </summary>
    /// <remarks>
    /// Acquires the internal lock to ensure thread safety, then iterates through
    /// the list of registered promises and deletes each one.  This will release
    /// both pending and completed promises from memory.  Use with caution, as
    /// any still-pending promises will be destroyed immediately.
    /// </remarks>
    class procedure Clear;
  end;

  TStringPromise = TPromise<string>;

implementation

{ TPromise<T> }

class function TPromise<T>.CloneException(E: Exception): Exception;
var
  ExClass: ExceptClass ;
begin
  ExClass := ExceptClass(E.ClassType);
  Result := ExClass.Create(E.Message);
end;

constructor TPromise<T>.Create(AExecutor: TExecutor);
begin
  inherited Create;
  FHandlerLock := TObject.Create;
  FState := psPending;
  TPromiseRegistry.Add(Self);
  FThenHandlers := TList<TProc<T>>.Create;
  FCatchHandlers := TList<TProc<Exception>>.Create;
  try
    {--- The executor function that starts the asynchronous task. }
    AExecutor(
      procedure(AValue: T)
      begin
        Self.Resolve(AValue);
      end,

      {--- OnReject — clone then free the original }
      procedure(E: Exception)
      begin
        var Cloned := CloneException(E);
        {--- releases the original exception }
        E.Free;
        Self.Reject(Cloned);
      end
    );
  except
    on E: Exception do
    begin
      var Cloned := CloneException(E);
      {--- E.Free; Do not release E here because Delphi takes care of it }
      Reject(Cloned);
    end;
  end;
end;

destructor TPromise<T>.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  FThenHandlers.Free;
  FCatchHandlers.Free;
  FHandlerLock.Free;
  inherited;
end;

function TPromise<T>.GetState: TPromiseState;
begin
  Result := FState;
end;

class function TPromise<T>.Rejected(AError: Exception; Proc: TProc): TPromise<T>;
begin
  Result := TPromise<T>.Create(
    procedure(Resolve: TProc<T>; Reject: TProc<Exception>)
    begin
      TTask.Run(
        procedure()
        begin
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(Proc) then
                Proc();
              Reject(CloneException(AError));
//              Reject(AError);
            end)
        end)
    end);
end;

procedure TPromise<T>.Resolve(const AValue: T);
var
  Handlers: TArray<TProc<T>>;
  Handler: TProc<T>;
  LValue: T;
begin
  if FState <> psPending then
    Exit;

  FState := psFulfilled;
  FValue := AValue;
  LValue := AValue;

  {--- Copy the locked callback list }
  TMonitor.Enter(FHandlerLock);
  try
    Handlers := FThenHandlers.ToArray;
  finally
    TMonitor.Exit(FHandlerLock);
  end;

  {--- Asynchronously call all “then” callbacks }
  for Handler in Handlers do
    TThread.Queue(nil,
      procedure
      begin
        Handler(LValue);
      end);

  {--- Empty locked lists }
  TMonitor.Enter(FHandlerLock);
  try
    FThenHandlers.Clear;
    FCatchHandlers.Clear;
  finally
    TMonitor.Exit(FHandlerLock);
  end;

  {--- Safe destruction because we are out of the register }
  TPromiseRegistry.RemoveLater(Self);
end;

class function TPromise<T>.Resolved(const AValue: T; Proc: TProc): TPromise<T>;
begin
  Result := TPromise<T>.Create(
    procedure(Resolve: TProc<T>; Reject: TProc<Exception>)
    begin
      TTask.Run(
        procedure()
        begin
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(Proc) then
                Proc();
              Resolve(AValue);
            end)
        end)
    end);
end;

procedure TPromise<T>.Reject(AError: Exception);
var
  Handlers: TArray<TProc<Exception>>;
  Handler: TProc<Exception>;
  LError: Exception;
begin
  if FState <> psPending then
    begin
      AError.Free;
      Exit;
    end;

  FState := psRejected;
  FError := AError;
  LError := AError;

  {--- Copy the locked callback list }
  TMonitor.Enter(FHandlerLock);
  try
    Handlers := FCatchHandlers.ToArray;
  finally
    TMonitor.Exit(FHandlerLock);
  end;

  {--- Call all “catch” callbacks }
  for Handler in Handlers do
    TThread.Queue(nil,
      procedure
      begin
        Handler(LError);
      end);

  {--- Empty locked lists }
  TMonitor.Enter(FHandlerLock);
  try
    FThenHandlers.Clear;
    FCatchHandlers.Clear;
  finally
    TMonitor.Exit(FHandlerLock);
  end;

  {--- Safe destruction because we are out of the register }
  TPromiseRegistry.RemoveLater(Self);
end;

function TPromise<T>.&Then(AOnFulfill: TProc<T>): TPromise<T>;
begin
  {--- Version without transformation: we wrap the procedure in a function which returns the unchanged value }
  Result := &Then<T>(
    function(Value: T): T
    begin
      AOnFulfill(Value);
      Result := Value;
    end);
end;

function TPromise<T>.&Then<TResult>(AOnFulfill: TFunc<T, TResult>): TPromise<TResult>;
begin
  {--- Creation of a new promise that will be resolved when this one is resolved }
  Result := TPromise<TResult>.Create(
    procedure(Resolve: TProc<TResult>; Reject: TProc<Exception>)
    begin
      if FState = psFulfilled then
        begin
          try
            Resolve(AOnFulfill(FValue));
          except
            on E: Exception do
              Reject(CloneException(E));
          end;
        end
      else
      if FState = psRejected then
        begin
          Reject(CloneException(FError))
        end
      else
        begin
          {--- If the operation is not yet complete, we add callbacks for chaining }
          TMonitor.Enter(FHandlerLock);
          try
            FThenHandlers.Add(
              procedure(Value: T)
              begin
                try
                  Resolve(AOnFulfill(Value));
                except
                  on E: Exception do
                    Reject(CloneException(E));
                end;
              end);
            FCatchHandlers.Add(
              procedure(E: Exception)
              begin
                Reject(CloneException(E));
              end);
          finally
            TMonitor.Exit(FHandlerLock);
          end;
        end;
    end);
end;

function TPromise<T>.&Then(AOnFulfill: TFunc<T, TPromise<T>>): TPromise<T>;
begin
  Result := TPromise<T>.Create(
    procedure(Resolve: TProc<T>; Reject: TProc<Exception>)
    begin
      if FState = psFulfilled then
        begin
          try
            AOnFulfill(FValue)
              .&Then(
                procedure(NewValue: T)
                begin
                  Resolve(NewValue);
                end)
              .&Catch(
                procedure(E: Exception)
                begin
                  Reject(CloneException(E));
                end);
          except
            on E: Exception do
              Reject(CloneException(E));
          end;
        end
      else
      if FState = psRejected then
        begin
          Reject(CloneException(FError))
        end
      else
        begin
          TMonitor.Enter(FHandlerLock);
          try
            FThenHandlers.Add(
              procedure(Value: T)
              begin
                try
                  AOnFulfill(Value)
                    .&Then(
                      procedure(NewValue: T)
                      begin
                        Resolve(NewValue);
                      end)
                    .&Catch(
                    procedure(E: Exception)
                    begin
                      Reject(CloneException(E));
                    end);
                except
                  on E: Exception do
                    Reject(CloneException(E));
                end;
              end);
            FCatchHandlers.Add(
              procedure(E: Exception)
              begin
                Reject(CloneException(E));
              end);
          finally
            TMonitor.Exit(FHandlerLock);
          end;
        end;
    end);
end;

function TPromise<T>.&Then<TResult>(
  AOnFulfill: TFunc<TResult>): TPromise<TResult>;
begin
  Result := TPromise<TResult>.Create(
    procedure(Resolve: TProc<TResult>; Reject: TProc<Exception>)
    begin
      if FState = psFulfilled then
        begin
          try
            {--- Call the action without parameters and resolve with the result }
            Resolve(AOnFulfill());
          except
            on E: Exception do
              Reject(CloneException(E));
          end;
        end
    else
    if FState = psRejected then
      begin
        Reject(CloneException(FError));
      end
    else
      begin
        {--- If the promise is pending, we add callbacks }
        TMonitor.Enter(FHandlerLock);
        try
          FThenHandlers.Add(
            procedure(Value: T)
            begin
              try
                Resolve(AOnFulfill());
              except
                on E: Exception do
                  Reject(CloneException(E));
              end;
            end);
          FCatchHandlers.Add(
            procedure(E: Exception)
            begin
              Reject(CloneException(E));
            end);
        finally
          TMonitor.Exit(FHandlerLock);
        end;
      end;
    end);
end;

function TPromise<T>.&Then<TResult>(
  AOnFulfill: TFunc<T, TPromise<TResult>>): TPromise<TResult>;
begin
  Result := TPromise<TResult>.Create(
    procedure(Resolve: TProc<TResult>; Reject: TProc<Exception>)
    begin
      if FState = psFulfilled then
        begin
          try
            AOnFulfill(FValue)
              .&Then(
                procedure(NewValue: TResult)
                begin
                  Resolve(NewValue);
                end)
              .&Catch(
                procedure(E: Exception)
                begin
                  Reject(CloneException(E));
                end);
          except
            on E: Exception do
              Reject(CloneException(E));
          end;
        end
      else
      if FState = psRejected then
        begin
          Reject(CloneException(FError));
        end
      else
        begin
          TMonitor.Enter(FHandlerLock);
          try
            FThenHandlers.Add(
              procedure(Value: T)
              begin
                try
                  AOnFulfill(Value)
                    .&Then(
                      procedure(NewValue: TResult)
                      begin
                        Resolve(NewValue);
                      end)
                    .&Catch(
                      procedure(E: Exception)
                      begin
                        Reject(CloneException(E));
                      end);
                except
                  on E: Exception do
                    Reject(CloneException(E));
                end;
              end);
            FCatchHandlers.Add(
              procedure(E: Exception)
              begin
                Reject(CloneException(E));
              end);
          finally
            TMonitor.Exit(FHandlerLock);
          end;
        end;
    end);
end;

function TPromise<T>.&Then(AOnFulfill: TProc): TPromise<T>;
begin
  Result := TPromise<T>.Create(
    procedure(Resolve: TProc<T>; Reject: TProc<Exception>)
    begin
      if FState = psFulfilled then
        begin
          try
            {--- Calling the action without parameters }
            AOnFulfill();
            {--- Pass the initial value after the action is executed }
            Resolve(FValue);
          except
            on E: Exception do
              Reject(CloneException(E));
          end;
        end
      else
      if FState = psRejected then
        begin
          Reject(CloneException(FError))
        end
      else
        begin
          {--- If the operation is not yet completed, add callbacks for chaining }
          TMonitor.Enter(FHandlerLock);
          try
            FThenHandlers.Add(
              procedure(Value: T)
              begin
                try
                  AOnFulfill();
                  Resolve(Value);
                except
                  on E: Exception do
                    Reject(CloneException(E));
                end;
              end);
            FCatchHandlers.Add(
              procedure(E: Exception)
              begin
                Reject(CloneException(E));
              end);
          finally
            TMonitor.Exit(FHandlerLock);
          end;
        end;
    end);
end;

function TPromise<T>.&Catch(AOnReject: TProc<Exception>): TPromise<T>;
begin
  {--- Create a new promise that passes the value or handles the error with AOnReject }
  Result := TPromise<T>.Create(
    procedure(Resolve: TProc<T>; Reject: TProc<Exception>)
    begin
      if FState = psFulfilled then
        begin
          Resolve(FValue);
        end
      else
      if FState = psRejected then
        begin
          AOnReject(FError);
          Reject(CloneException(FError));
        end
      else
        begin
          TMonitor.Enter(FHandlerLock);
          try
            FThenHandlers.Add(
              procedure(Value: T)
              begin
                Resolve(Value);
              end);
            FCatchHandlers.Add(
              procedure(E: Exception)
              begin
                AOnReject(E);
                Reject(CloneException(E));
              end);
          finally
            TMonitor.Exit(FHandlerLock);
          end;
        end;
    end);
end;

{ TPromiseRegistry }

class procedure TPromiseRegistry.Add(APromise: TObject);
begin
  TMonitor.Enter(FLock);
  try
    FList.Add(APromise);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TPromiseRegistry.Cleanup;
begin
  TMonitor.Enter(FLock);
  try
    for var I := FList.Count - 1 downto 0 do
      {--- Remove the promise from the list as soon as it moves to the final state. }
      if TObject(FList[I]) is TPromiseBase then
        with TPromiseBase(FList[I]) do
          if State <> psPending then
            {--- releases the object }
            FList.Delete(I);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TPromiseRegistry.Clear;
begin
  TMonitor.Enter(FLock);
  try
    for var I := FList.Count - 1 downto 0 do
      {--- Remove the promise from the list as soon as it moves to the final state. }
      if TObject(FList[I]) is TPromiseBase then
        with TPromiseBase(FList[I]) do
            {--- releases the object }
            FList.Delete(I);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class constructor TPromiseRegistry.Create;
begin
  {--- simple critical section }
  FLock := TObject.Create;

  {--- OwnsObjects = True }
  FList := TObjectList<TObject>.Create(True);
end;

class destructor TPromiseRegistry.Destroy;
begin
  FList.Free;
  FLock.Free;
end;

class procedure TPromiseRegistry.Remove(APromise: TObject);
begin
  TMonitor.Enter(FLock);
  try
    {--- releases the object }
    var Index := FList.IndexOf(APromise);
    if Index >= 0 then
      FList.Delete(Index);
  finally
    TMonitor.Exit(FLock);
  end;
end;

class procedure TPromiseRegistry.RemoveLater(APromise: TObject);
begin
  TThread.Queue(nil,
    procedure
    begin
      Remove(APromise);
    end);
end;

initialization
finalization
  {--- Delete pending promises }
  TPromiseRegistry.Clear;
end.

