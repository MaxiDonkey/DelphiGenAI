unit GenAI.Functions.Core;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON;

type
  /// <summary>
  /// Interface defining the core structure and functionality of a function in the system.
  /// </summary>
  /// <remarks>
  /// This interface outlines the basic properties and methods that any function implementation must include.
  /// </remarks>
  IFunctionCore = interface
    ['{586B30A0-4C30-47BA-87F1-88A14BCD6F4B}']
    /// <summary>
    /// Retrieves the description of the function.
    /// </summary>
    function GetDescription: string;
    /// <summary>
    /// Retrieves the name of the function.
    /// </summary>
    function GetName: string;
    /// <summary>
    /// Retrieves the parameters required by the function, represented as a JSON schema.
    /// </summary>
    function GetParameters: string;
    /// <summary>
    /// Retrieves the strict schema adherence switch value.
    /// </summary>
    function GetStrict: Boolean;
    /// <summary>
    /// Set value to the strict schema adherence switch.
    /// </summary>
    procedure SetStrict(const Value: Boolean);
    /// <summary>
    /// Retrieves the type of the function, typically "function".
    /// </summary>
    function GetType: string;
    /// <summary>
    /// Executes the function with the provided arguments and returns the result as a string.
    /// </summary>
    /// <param name="Arguments">The arguments passed to the function in JSON format.</param>
    /// <returns>The result of the function execution as a string.</returns>
    function Execute(const Arguments: string): string;
     /// <summary>
    /// Converts the TFunctionCore instance to a JSON object that contains its type and representation.
    /// </summary>
    /// <returns>A JSON object representing the function instance.</returns>
    function ToJson: TJSONObject;
    /// <summary>
    /// Creates a string representation of the TFunctionCore instance in JSON format, including its description, name, and parameters.
    /// </summary>
    /// <returns>A string representation of the function in JSON format.</returns>
    function ToString: string;
    /// <summary>
    /// A brief description of the function's purpose, used by the model to determine when and how to call the function.
    /// </summary>
    property Description: string read GetDescription;
    /// <summary>
    /// The unique identifier of the function that will be called. It must only contain characters from a-z, A-Z, 0-9, underscores, or dashes, and should not exceed 64 characters in length.
    /// </summary>
    property Name: string read GetName;
    //// <summary>
    /// The parameters required by the function, specified as a JSON schema. If no parameters are required, use the schema: {"type": "object", "properties": {}}.
    /// </summary>
    property Parameters: string read GetParameters;
    /// <summary>
    /// The type of the tool. Currently, only "function" is supported.
    /// </summary>
    property &Type: string read GetType;
    /// <summary>
    /// Retrieves the strict schema adherence switch value.
    /// </summary>
    property &Strict: Boolean read GetStrict write SetStrict;
  end;

  /// <summary>
  /// Abstract base class for implementing core function behavior.
  /// </summary>
  /// <remarks>
  /// This class provides basic implementations for some methods and defines the structure that derived classes must follow.
  /// </remarks>
  TFunctionCore = class abstract(TinterfacedObject, IFunctionCore)
  protected
    FStrict: Boolean;
    /// <summary>
    /// Retrieves the description of the function. Derived classes must implement this method.
    /// </summary>
    function GetDescription: string; virtual; abstract;
     /// <summary>
    /// Retrieves the name of the function. Derived classes must implement this method.
    /// </summary>
    function GetName: string; virtual; abstract;
    /// <summary>
    /// Retrieves the parameters required by the function, represented as a JSON schema. Derived classes must implement this method.
    /// </summary>
    function GetParameters: string; virtual; abstract;
    /// <summary>
    /// Retrieves the type of the function, which is "function" by default.
    /// </summary>
    function GetType: string; virtual;
    /// <summary>
    /// Retrieves the strict schema adherence switch value.
    /// </summary>
    function GetStrict: Boolean; virtual;
    /// <summary>
    /// Set value to the strict schema adherence switch.
    /// </summary>
    procedure SetStrict(const Value: Boolean); virtual;
  public
    constructor Create(const IsStrict: Boolean = False);
    /// <summary>
    /// Executes the function with the provided arguments and returns the result as a string. Derived classes must implement this method.
    /// </summary>
    /// <param name="Arguments">The arguments passed to the function in JSON format.</param>
    /// <returns>The result of the function execution as a string.</returns>
    function Execute(const Arguments: string): string; virtual; abstract;
    /// <summary>
    /// Converts the TFunctionCore instance to a JSON object that contains its type and representation.
    /// </summary>
    /// <returns>A JSON object representing the function instance.</returns>
    function ToJson: TJSONObject;
    /// <summary>
    /// Creates a string representation of the TFunctionCore instance in JSON format, including its description, name, and parameters.
    /// </summary>
    /// <returns>A string representation of the function in JSON format.</returns>
    function ToString: string; override;
    /// <summary>
    /// A brief description of the function's purpose, used by the model to determine when and how to call the function.
    /// </summary>
    property Description: string read GetDescription;
    /// <summary>
    /// The unique identifier of the function that will be called. It must only contain characters from a-z, A-Z, 0-9, underscores, or dashes, and should not exceed 64 characters in length.
    /// </summary>
    property Name: string read GetName;
    /// <summary>
    /// The parameters required by the function, specified as a JSON schema. If no parameters are required, use the schema: {"type": "object", "properties": {}}.
    /// </summary>
    property Parameters: string read GetParameters;
    /// <summary>
    /// The type of the tool. Currently, only "function" is supported.
    /// </summary>
    property &Type: string read GetType;
    /// <summary>
    /// Retrieves the strict schema adherence switch value.
    /// </summary>
    property &Strict: Boolean read GetStrict write SetStrict;
  end;

implementation

{ TFunctionCore }

constructor TFunctionCore.Create(const IsStrict: Boolean);
begin
  inherited Create;
  &Strict := IsStrict;
end;

function TFunctionCore.GetStrict: Boolean;
begin
  Result := FStrict;
end;

function TFunctionCore.GetType: string;
begin
  Result := 'function';
end;

procedure TFunctionCore.SetStrict(const Value: Boolean);
begin
  FStrict := Value;
end;

function TFunctionCore.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  try
    Result.AddPair('type', &Type);
    Result.AddPair('function', TJSONObject.ParseJSONValue(ToString));
  except
    on E: Exception do
      begin
        Result.Free;
        raise;
      end;
  end;
end;

function TFunctionCore.ToString: string;
begin
  with TStringWriter.Create do
    try
      Write('"name": "%s",', [Name]);
      Write('"description": "%s",', [Description]);
      Write('"parameters": %s', [Parameters]);
      if &Strict then
        Write(',"strict": %s', [BoolToStr(&Strict, True).ToLower]);
      Result := Format('{%s}', [ToString]);
    finally
      Free;
    end;
end;

end.
