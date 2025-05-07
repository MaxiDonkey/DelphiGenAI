unit GenAI.Schema;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, REST.Json.Types,
  GenAI.API.Params, GenAI.Types;

type
  TSchemaParams = class;

  /// <summary>
  /// Provides helper methods for creating property items in OpenAPI schema definitions.
  /// </summary>
  /// <remarks>
  /// This record simplifies the creation of property entries when building schema objects,
  /// particularly for object properties in OpenAPI specifications.
  /// </remarks>
  TPropertyItem = record
  public
    /// <summary>
    /// Creates a JSON pair representing a property in a schema object.
    /// </summary>
    /// <param name="Key">The name of the property.</param>
    /// <param name="Value">The data type of the property as a <c>TSchemaType</c>.</param>
    /// <returns>A <c>TJSONPair</c> representing the property key-value pair.</returns>
    /// <remarks>
    /// This method facilitates the addition of properties to schema objects by creating
    /// a JSON pair with the specified key and data type.
    /// </remarks>
    class function Add(Key: string; Value: TSchemaType): TJSONPair; static;
  end;

  /// <summary>
  /// Represents the Schema Object in OpenAPI, enabling the definition of input and output data types.
  /// These types can be objects, primitives, or arrays. This class provides methods to build and
  /// configure schema definitions as per the OpenAPI 3.0 Specification.
  /// </summary>
  /// <remarks>
  /// The Schema Object allows the definition of input and output data types in the OpenAPI Specification.
  /// This class provides a fluent interface to construct schema definitions programmatically.
  /// </remarks>
  TSchemaParams = class(TJSONParam)
  public
    /// <summary>
    /// Sets the data type of the schema.
    /// </summary>
    /// <param name="Value">The data type to assign to the schema, specified as a <c>TSchemaType</c> value.</param>
    /// <returns>The current <c>TSchemaParams</c> instance to allow for method chaining.</returns>
    /// <remarks>
    /// The <c>type</c> keyword is required in the Schema Object to define the data type.
    /// Valid types include <c>string</c>, <c>number</c>, <c>integer</c>, <c>boolean</c>, <c>array</c>, and <c>object</c>.
    /// </remarks>
    function &Type(const Value: TSchemaType): TSchemaParams;
    /// <summary>
    /// Specifies the format of the data type.
    /// </summary>
    /// <param name="Value">The format of the data type, as a string.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>format</c> keyword is an optional modifier to provide more fine-grained data type information.
    /// Common formats include <c>int32</c>, <c>int64</c> for <c>integer</c> types; <c>float</c>, <c>double</c>
    /// for <c>number</c> types; and <c>byte</c>, <c>binary</c>, <c>date</c>, <c>date-time</c>, <c>password</c> for <c>string</c> types.
    /// </remarks>
    function Format(const Value: string): TSchemaParams;
    /// <summary>
    /// Adds a description to the schema.
    /// </summary>
    /// <param name="Value">A brief description of the schema. Supports Markdown for formatting.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>description</c> keyword provides a description of the schema and can include examples of use.
    /// This field supports Markdown syntax for rich text representation.
    /// </remarks>
    function Description(const Value: string): TSchemaParams;
    /// <summary>
    /// Specifies whether the schema's value can be null.
    /// </summary>
    /// <param name="Value">A boolean indicating if the schema allows null values.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>nullable</c> keyword is a boolean property that indicates if the value of the schema can be null.
    /// By default, this is false.
    /// </remarks>
    function Nullable(const Value: Boolean): TSchemaParams;
    /// <summary>
    /// Specifies an enumeration of possible values.
    /// </summary>
    /// <param name="Value">An array of string values that the schema can take.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>enum</c> keyword restricts the value of the schema to a fixed set of values.
    /// The schema's type must be <c>string</c> when using enum.
    /// </remarks>
    function Enum(const Value: TArray<string>): TSchemaParams;
    /// <summary>
    /// Specifies the maximum number of items allowed in an array schema.
    /// </summary>
    /// <param name="Value">The maximum number of items as a string.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>maxItems</c> keyword applies to schemas of type <c>array</c> and restricts the maximum number
    /// of items the array can contain.
    /// </remarks>
    function MaxItems(const Value: string): TSchemaParams;
    /// <summary>
    /// Specifies the minimum number of items required in an array schema.
    /// </summary>
    /// <param name="Value">The minimum number of items as a string.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>minItems</c> keyword applies to schemas of type <c>array</c> and defines the minimum number
    /// of items the array must contain.
    /// </remarks>
    function MinItems(const Value: string): TSchemaParams;
    /// <summary>
    /// Adds a property to an object schema.
    /// </summary>
    /// <param name="Key">The name of the property.</param>
    /// <param name="Value">A <c>TSchemaParams</c> instance defining the property's schema.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>properties</c> keyword is used to define the properties of an object schema.
    /// Each property is a key-value pair where the key is the property name and the value is a schema defining the property.
    /// </remarks>
    function Properties(const Key: string; const Value: TSchemaParams): TSchemaParams; overload;
    /// <summary>
    /// Adds a property to an object schema using a parameterized procedure to configure the property's schema.
    /// </summary>
    /// <param name="Key">The name of the property.</param>
    /// <param name="ParamProc">A procedure that takes a <c>TSchemaParams</c> instance to configure the property's schema.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// This overload allows you to define the property's schema inline using a procedural configuration.
    /// </remarks>
    function Properties(const Key: string; const ParamProc: TProcRef<TSchemaParams>): TSchemaParams; overload;
    /// <summary>
    /// Adds multiple properties to an object schema.
    /// </summary>
    /// <param name="Value">An array of <c>TJSONPair</c> instances representing the properties.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// This overload allows adding multiple properties at once to the object schema.
    /// </remarks>
    function Properties(const Value: TArray<TJSONPair>): TSchemaParams; overload;
    /// <summary>
    /// Specifies which properties are required in an object schema.
    /// </summary>
    /// <param name="Value">An array of property names that are required.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>required</c> keyword lists the property names that must be included when an object instance
    /// is validated against the schema.
    /// </remarks>
    function Required(const Value: TArray<string>): TSchemaParams;
    /// <summary>
    /// Specifies the schema of the items in an array schema.
    /// </summary>
    /// <param name="Value">A <c>TSchemaParams</c> instance defining the schema of the array items.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// The <c>items</c> keyword is used in array schemas to define the schema of each item in the array.
    /// </remarks>
    function Items(const Value: TSchemaParams): TSchemaParams; overload;
    /// <summary>
    /// Specifies the schema of the items in an array schema using a parameterized procedure.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures a <c>TSchemaParams</c> instance to define the array items' schema.</param>
    /// <returns>The current <c>TSchemaParams</c> instance for method chaining.</returns>
    /// <remarks>
    /// This overload allows you to define the items' schema inline using a procedural configuration.
    /// </remarks>
    function Items(const ParamProc: TProcRef<TSchemaParams>): TSchemaParams; overload;
    /// <summary>
    /// Creates a new instance of <c>TSchemaParams</c>.
    /// </summary>
    /// <returns>A new <c>TSchemaParams</c> instance.</returns>
    class function New: TSchemaParams; overload;
    /// <summary>
    /// Creates and configures a new instance of <c>TSchemaParams</c> using a parameterized procedure.
    /// </summary>
    /// <param name="ParamProc">A procedure that configures the new <c>TSchemaParams</c> instance.</param>
    /// <returns>A new <c>TSchemaParams</c> instance.</returns>
    /// <remarks>
    /// This overload allows you to create and configure the instance inline.
    /// </remarks>
    class function New(const ParamProc: TProcRef<TSchemaParams>): TSchemaParams; overload;
  end;

implementation

uses
  System.StrUtils, System.Rtti, Rest.Json;

{ TSchemaParams }

function TSchemaParams.Description(const Value: string): TSchemaParams;
begin
  Result := TSchemaParams(Add('description', Value));
end;

function TSchemaParams.Enum(const Value: TArray<string>): TSchemaParams;
begin
  Result := TSchemaParams(Add('enum', Value));
end;

function TSchemaParams.Format(const Value: string): TSchemaParams;
begin
  Result := TSchemaParams(Add('format', Value));
end;

function TSchemaParams.Items(
  const ParamProc: TProcRef<TSchemaParams>): TSchemaParams;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TSchemaParams.Create;
      ParamProc(Value);
      Result := Items(Value);
    end
  else Result := Self;
end;

function TSchemaParams.Items(const Value: TSchemaParams): TSchemaParams;
begin
  Result := TSchemaParams(Add('items', Value.Detach));
end;

function TSchemaParams.MaxItems(const Value: string): TSchemaParams;
begin
  Result := TSchemaParams(Add('maxItems', Value));
end;

function TSchemaParams.MinItems(const Value: string): TSchemaParams;
begin
  Result := TSchemaParams(Add('minItems', Value));
end;

class function TSchemaParams.New: TSchemaParams;
begin
  Result := TSchemaParams.Create;
end;

class function TSchemaParams.New(
  const ParamProc: TProcRef<TSchemaParams>): TSchemaParams;
begin
  Result := TSchemaParams.Create;
  if Assigned(ParamProc) then
    begin
      ParamProc(Result);
    end
end;

function TSchemaParams.Nullable(const Value: Boolean): TSchemaParams;
begin
  Result := TSchemaParams(Add('nullable', Value.ToString));
end;

function TSchemaParams.Properties(
  const Value: TArray<TJSONPair>): TSchemaParams;
begin
  var JSONValue := TJSONObject.Create;
  for var Item in Value do
    begin
      JSONValue.AddPair(Item);
    end;
  Result := TSchemaParams(Add('properties', JSONValue));
end;

function TSchemaParams.Properties(const Key: string;
  const ParamProc: TProcRef<TSchemaParams>): TSchemaParams;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TSchemaParams.Create;
      ParamProc(Value);
      Result := Properties(Key, Value);
    end
  else Result := Self;
end;

function TSchemaParams.Properties(const Key: string;
  const Value: TSchemaParams): TSchemaParams;
begin
  Result := TSchemaParams(Add(Key, Value.Detach));
end;

function TSchemaParams.Required(const Value: TArray<string>): TSchemaParams;
begin
  Result := TSchemaParams(Add('required', Value));
end;

function TSchemaParams.&Type(const Value: TSchemaType): TSchemaParams;
begin
  Result := TSchemaParams(Add('type', Value.ToString));
end;

{ TPropertyItem }

class function TPropertyItem.Add(Key: string; Value: TSchemaType): TJSONPair;
begin
  Result := TJSONPair.Create(Key, Value.ToString);
end;

end.
