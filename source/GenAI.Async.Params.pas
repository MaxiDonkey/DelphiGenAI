unit GenAI.Async.Params;

{-------------------------------------------------------------------------------

      Unit containing generic interfaces and classes for managing parameters
      across  various  asynchronous  operations.

      The HuggingFace.Async.Params  unit  provides  a set of tools for creating
      and managing  parameter  instances  using  generic  types. The primary
      components include:

      - IUseParams<T>: A generic interface for managing parameters of type T.
      - TUseParams<T>: A class  implementing  the IUseParams<T>  interface to
        encapsulate  parameter  handling.
      - TUseParamsFactory<T>: A  factory  class  for  creating  instances  of
        IUseParams<T>.

      These abstractions allow for  a flexible and  reusable  way  to  handle
      parameters  across  different  modules  and  contexts,  particularly in
      asynchronous  scenarios  such  as  chat  operations.

      Note  that  This  unit  is  designed   to  work   seamlessly  with  the
      Gemini.Chat.AsyncEvents unit,  which  relies  on  IUseParams<T> and
      TUseParamsFactory<T>  to  manage   parameters   for  asynchronous  chat
      requests.

        Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
        Visit the Github repository for the documentation and use examples

-------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes;

type
  /// <summary>
  /// Generic interface for managing parameters of type <c>T</c>.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the parameters.
  /// </typeparam>
  IUseParams<T> = interface
    ['{D7C1F3AC-CA7C-49E5-9250-8E898B28EC97}']
    /// <summary>
    /// Sets the parameters.
    /// </summary>
    /// <param name="Value">
    /// The value of the parameters to be set.
    /// </param>
    procedure SetParams(const Value: T);
    /// <summary>
    /// Gets the current parameters.
    /// </summary>
    /// <returns>
    /// The current parameters of type <c>T</c>.
    /// </returns>
    function GetParams: T;
    /// <summary>
    /// Assigns the parameters using a function.
    /// </summary>
    /// <param name="Value">
    /// A function that returns parameters of type <c>T</c>.
    /// </param>
    procedure Assign(Value: TFunc<T>);
    /// <summary>
    /// Returns the current instance as an object of type <c>TObject</c>.
    /// </summary>
    /// <returns>
    /// The instance cast to <c>TObject</c>.
    /// </returns>
    function AsSender: TObject;
    /// <summary>
    /// Provides access to the parameters as a property.
    /// </summary>
    property Param: T read GetParams write SetParams;
  end;

  /// <summary>
  /// A factory class for creating instances of <c>IUseParams</c>.
  /// </summary>
  /// <param name="T">
  /// The type of the parameters for which the instance is created.
  /// </param>
  TUseParamsFactory<T> = class
    /// <summary>
    /// Creates and returns a new instance of <c>IUseParams</c> for the specified type <c>T</c>.
    /// </summary>
    /// <returns>
    /// A new instance of <c>IUseParams&lt;T&gt;</c>.
    /// </returns>
    class function CreateInstance: IUseParams<T>; overload;
    /// <summary>
    /// Creates and returns a new instance of <c>IUseParams</c> for the specified type <c>T</c>, using the provided function.
    /// </summary>
    /// <param name="Value">
    /// A function that provides the parameter values for the instance.
    /// </param>
    /// <returns>
    /// A new instance of <c>IUseParams&lt;T&gt;</c>.
    /// </returns>
    class function CreateInstance(Value: TFunc<T>): IUseParams<T>; overload;
  end;

  /// <summary>
  /// A generic class implementing the <c>IUseParams</c> interface to manage parameters of type <c>T</c>.
  /// </summary>
  /// <param name="T">
  /// The type of the parameters.
  /// </param>
  TUseParams<T> = class(TInterfacedObject, IUseParams<T>)
  private
    FParams: T;
    /// <summary>
    /// Sets the parameters to the provided value.
    /// </summary>
    /// <param name="Value">
    /// The new parameters value.
    /// </param>
    procedure SetParams(const Value: T);
    /// <summary>
    /// Retrieves the current parameters value.
    /// </summary>
    /// <returns>
    /// The current parameters.
    /// </returns>
    function GetParams: T;
  protected
    /// <summary>
    /// Casts the instance as a <c>TObject</c> for use as the sender of events.
    /// </summary>
    /// <returns>
    /// The current instance cast to <c>TObject</c>.
    /// </returns>
    function AsSender: TObject;
    /// <summary>
    /// Assigns the parameters using a function that returns type <c>T</c>.
    /// </summary>
    /// <param name="Value">
    /// A function that sets the parameters.
    /// </param>
    procedure Assign(Value: TFunc<T>);
  public
    /// <summary>
    /// Property to get or set the parameters.
    /// </summary>
    property Params: T read GetParams write SetParams;
  end;

implementation

{ TUseParams<T> }

function TUseParams<T>.AsSender: TObject;
begin
  Result := Self;
end;

procedure TUseParams<T>.Assign(Value: TFunc<T>);
begin
  if Assigned(Value) then
    begin
      Params := Value();
    end;
end;

function TUseParams<T>.GetParams: T;
begin
  Result := FParams;
end;

procedure TUseParams<T>.SetParams(const Value: T);
begin
  FParams := Value;
end;

{ TUseParamsFactory<T> }

class function TUseParamsFactory<T>.CreateInstance: IUseParams<T>;
begin
  Result := TUseParams<T>.Create;
end;

class function TUseParamsFactory<T>.CreateInstance(
  Value: TFunc<T>): IUseParams<T>;
begin
  Result := CreateInstance;
  Result.Assign(Value);
end;

end.
