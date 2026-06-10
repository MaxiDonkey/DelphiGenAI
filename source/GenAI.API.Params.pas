unit GenAI.API.Params;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.Classes, System.JSON, System.SysUtils, System.RTTI, REST.Json.Interceptors,
  REST.JsonReflect, System.Generics.Collections, System.Threading, System.TypInfo,
  GenAI.Consts;

const
  NULL = 'null';

type
  /// <summary>
  /// Represents a reference to a procedure that takes a single argument of type T and returns no value.
  /// </summary>
  /// <param name="T">
  /// The type of the argument that the referenced procedure will accept.
  /// </param>
  /// <remarks>
  /// This type is useful for defining callbacks or procedures that operate on a variable of type T,
  /// allowing for more flexible and reusable code.
  /// </remarks>
  TProcRef<T> = reference to procedure(var Arg: T);

  /// <summary>
  /// Represents a utility class for managing URL parameters and constructing query strings.
  /// </summary>
  /// <remarks>
  /// This class allows the addition of key-value pairs to construct a query string,
  /// which can be appended to a URL for HTTP requests. It provides overloads for adding
  /// various types of values, including strings, integers, booleans, doubles, and arrays.
  /// </remarks>
  TUrlParam = class
  private
    FValue: string;
    procedure Check(const Name: string);
    function GetValue: string;
  public
    /// <summary>
    /// Adds a string parameter to the query string.
    /// </summary>
    /// <param name="Name">
    /// The name of the parameter.
    /// </param>
    /// <param name="Value">
    /// The value of the parameter.
    /// </param>
    /// <returns>
    /// The current instance of <c>TUrlParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Name, Value: string): TUrlParam; overload; virtual;

    /// <summary>
    /// Adds an integer parameter to the query string.
    /// </summary>
    /// <param name="Name">
    /// The name of the parameter.
    /// </param>
    /// <param name="Value">
    /// The integer value of the parameter.
    /// </param>
    /// <returns>
    /// The current instance of <c>TUrlParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Name: string; Value: Integer): TUrlParam; overload; virtual;

    /// <summary>
    /// Adds an integer 64 parameter to the query string.
    /// </summary>
    /// <param name="Name">
    /// The name of the parameter.
    /// </param>
    /// <param name="Value">
    /// The integer 64 value of the parameter.
    /// </param>
    /// <returns>
    /// The current instance of <c>TUrlParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Name: string; Value: Int64): TUrlParam; overload; virtual;

    /// <summary>
    /// Adds a boolean parameter to the query string.
    /// </summary>
    /// <param name="Name">
    /// The name of the parameter.
    /// </param>
    /// <param name="Value">
    /// The boolean value of the parameter. It will be converted to "true" or "false".
    /// </param>
    /// <returns>
    /// The current instance of <c>TUrlParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Name: string; Value: Boolean): TUrlParam; overload; virtual;

    /// <summary>
    /// Adds a double parameter to the query string.
    /// </summary>
    /// <param name="Name">
    /// The name of the parameter.
    /// </param>
    /// <param name="Value">
    /// The double value of the parameter.
    /// </param>
    /// <returns>
    /// The current instance of <c>TUrlParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Name: string; Value: Double): TUrlParam; overload; virtual;

    /// <summary>
    /// Adds an array of string values to the query string as a single parameter.
    /// </summary>
    /// <param name="Name">
    /// The name of the parameter.
    /// </param>
    /// <param name="Value">
    /// The array of string values to be added, joined by commas.
    /// </param>
    /// <returns>
    /// The current instance of <c>TUrlParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Name: string; Value: TArray<string>): TUrlParam; overload; virtual;

    /// <summary>
    /// Gets the constructed query string with all parameters.
    /// </summary>
    /// <returns>
    /// The query string, prefixed with a question mark ("?") if parameters are present.
    /// </returns>
    property Value: string read GetValue;

    constructor Create; virtual;
  end;

  /// <summary>
  /// Represents the parameters for listing.
  /// This class provides the functionality to control pagination and set limits on the number of objects retrieved.
  /// It is useful for efficiently managing and navigating through large sets of objects.
  /// </summary>
  TUrlPaginationParams = class(TUrlParam)
  public
    /// <summary>
    /// A limit on the number of objects to be returned. Limit can range between 1 and 100,
    /// and the default is 20.
    /// </summary>
    /// <param name="Value">The limit on the number of objects, ranging from 1 to 100.</param>
    /// <returns>The instance of TUrlPaginationParams for method chaining.</returns>
    function Limit(const Value: Integer): TUrlPaginationParams;

    /// <summary>
    /// A cursor for use in pagination. after is an object ID that defines your place in the list.
    /// For instance, if you make a list request and receive 100 objects, ending with obj_foo, your
    /// subsequent call can include after=obj_foo in order to fetch the next page of the list.
    /// </summary>
    /// <param name="Value">The object ID that defines the starting point for pagination.</param>
    /// <returns>The instance of TUrlPaginationParams for method chaining.</returns>
    function After(const Value: string): TUrlPaginationParams;
  end;

  /// <summary>
  /// Represents the advanced parameters for listing and filtering data.
  /// This class extends <see cref="TUrlPaginationParams"/> to provide additional functionality for
  /// sorting and navigating through paginated data.
  /// It is designed to manage more complex scenarios where both pagination and sorting are required.
  /// </summary>
  TUrlAdvancedParams = class(TUrlPaginationParams)
  public
    /// <summary>
    /// Specifies the sort order of the retrieved objects based on their creation timestamp.
    /// This allows you to customize the order in which objects are returned, either in ascending
    /// or descending order.
    /// </summary>
    /// <param name="Value">"Asc" for ascending order or "Desc" for descending order.</param>
    /// <returns>The instance of TUrlAdvancedParams for method chaining.</returns>
    function Order(const Value: string): TUrlAdvancedParams;

    /// <summary>
    /// A cursor for use in pagination. This parameter allows you to specify an object ID that defines
    /// your place in the list when navigating to the previous set of results.
    /// For instance, if you receive a list of objects starting with obj_foo, a subsequent call can
    /// include before=obj_foo to fetch the previous page of results.
    /// </summary>
    /// <param name="Value">The object ID that defines the ending point for pagination.</param>
    /// <returns>The instance of TUrlAdvancedParams for method chaining.</returns>
    function Before(const Value: string): TUrlAdvancedParams;
  end;

  /// <summary>
  /// Represents a utility class for managing JSON objects and constructing JSON structures dynamically.
  /// </summary>
  /// <remarks>
  /// This class provides methods to add, remove, and manipulate key-value pairs in a JSON object.
  /// It supports various data types, including strings, integers, booleans, dates, arrays, and nested JSON objects.
  /// </remarks>
  TJSONParam = class
  private
    FJSON: TJSONObject;
    FIsDetached: Boolean;
    procedure SetJSON(const Value: TJSONObject);
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is a string.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The string value to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; const Value: string): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an integer.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The integer value to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; const Value: Integer): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an integer 64.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The integer value to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; const Value: Int64): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an extended (floating-point number).
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The extended value to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; const Value: Extended): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is a boolean.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The boolean value to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; const Value: Boolean): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is a date-time object.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The date-time value to associate with the key.
    /// </param>
    /// <param name="Format">
    /// The format in which to serialize the date-time value. If not specified, a default format is used.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    /// <remarks>
    /// Converting local DateTime to universal time (UTC) and then formatting it.
    /// </remarks>
    function Add(const Key: string; const Value: TDateTime; Format: string): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is another JSON object.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The JSON object to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; const Value: TJSONValue): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is a TJSONParam object.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The JSON object to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; const Value: TJSONParam): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an array of string.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// The string value to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; Value: TArray<string>): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an array of integer.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// An array of string to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; Value: TArray<Integer>): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an array of integer 64.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// An array of string to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; Value: TArray<Int64>): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an array of extended.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// An array of integer to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; Value: TArray<Extended>): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an array of JSON object.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// An array of TJSONValue to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; Value: TArray<TJSONValue>): TJSONParam; overload; virtual;

    /// <summary>
    /// Adds a key-value pair to the JSON object, where the value is an array of
    /// <c>TJSONParam</c>. Ownership of each item's JSON object is transferred into
    /// the created array, and every <c>TJSONParam</c> item is freed by this method.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to add.
    /// </param>
    /// <param name="Value">
    /// An array of <c>TJSONParam</c> to associate with the key.
    /// </param>
    /// <returns>
    /// The current instance of <c>TJSONParam</c>, allowing for method chaining.
    /// </returns>
    function Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam; overload; virtual;

    /// <summary>
    /// Clears all key-value pairs from the JSON object.
    /// </summary>
    procedure Clear; virtual;

    /// <summary>
    /// Removes a key-value pair from the JSON object by its key.
    /// </summary>
    /// <param name="Key">
    /// The key of the pair to remove.
    /// </param>
    procedure Delete(const Key: string); virtual;

    /// <summary>
    /// Detaches the internal JSON object from the <c>TJSONParam</c> instance.
    /// </summary>
    /// <remarks>
    /// After detaching, the internal JSON object is no longer managed by the <c>TJSONParam</c> instance.
    /// It becomes the caller's responsibility to free the detached object.
    /// </remarks>
    /// <remarks>
    /// Used during the creation of transient instances that must be deallocated immediately after their
    /// JSON representation is finalized.
    /// <para>
    /// These instances are exclusively maintained and are not shared among multiple clients.
    /// </para>
    /// </remarks>
    function Detach: TJSONObject;

    /// <summary>
    /// Gets or creates a JSON object associated with the specified key.
    /// </summary>
    /// <param name="Name">
    /// The key to look for or create.
    /// </param>
    /// <returns>
    /// A JSON object associated with the specified key.
    /// </returns>
    function GetOrCreateObject(const Name: string): TJSONObject;

    /// <summary>
    /// Gets or creates a JSON value of a specified type associated with the given key.
    /// </summary>
    /// <typeparam name="T">
    /// The type of the JSON value to retrieve or create. It must derive from <c>TJSONValue</c>
    /// and have a parameterless constructor.
    /// </typeparam>
    /// <param name="Name">
    /// The key to look for or create in the JSON object.
    /// </param>
    /// <returns>
    /// The JSON value associated with the specified key, creating a new one if it does not exist.
    /// </returns>
    function GetOrCreate<T: TJSONValue, constructor>(const Name: string): T;

    /// <summary>
    /// Converts the JSON object into a compact JSON string.
    /// </summary>
    /// <param name="FreeObject">
    /// Specifies whether the JSON object should be freed after conversion.
    /// </param>
    /// <returns>
    /// A compact JSON string.
    /// </returns>
    function ToJsonString(FreeObject: Boolean = False): string; virtual;

    /// <summary>
    /// Converts the JSON object into a formatted string.
    /// </summary>
    /// <param name="FreeObject">
    /// Specifies whether the JSON object should be freed after conversion.
    /// </param>
    /// <returns>
    /// A formatted JSON string.
    /// </returns>
    function ToFormat(FreeObject: Boolean = False): string;

    /// <summary>
    /// Converts the JSON object into an array of key-value string pairs.
    /// </summary>
    /// <returns>
    /// An array of <c>TPair</c>, where each pair contains the key as a string
    /// and the associated value converted to a string.
    /// </returns>
    function ToStringPairs: TArray<TPair<string, string>>;

    /// <summary>
    /// Converts the JSON object into a string stream for use with file or network operations.
    /// </summary>
    /// <returns>
    /// A <c>TStringStream</c> containing the JSON object as a string.
    /// The stream must be freed by the caller after use.
    /// </returns>
    function ToStream: TStringStream;

    /// <summary>
    /// Gets the number of key-value pairs in the JSON object.
    /// </summary>
    property Count: Integer read GetCount;

    /// <summary>
    /// Gets or sets the internal JSON object.
    /// </summary>
    property JSON: TJSONObject read FJSON write SetJSON;
  end;

  /// <summary>
  /// Base class for all classes obtained after deserialization. Stores the raw JSON
  /// string returned by the API and exposes the post-deserialization lifecycle used by
  /// the two-step (double) deserialization mechanism.
  /// </summary>
  /// <remarks>
  /// Step 1 maps the payload to the object graph; step 2 (the deserializer calls
  /// <c>InternalFinalizeDeserialize</c> after the raw JSON has been bound to every
  /// fingerprint via <c>TJSONFingerprintBinder</c>) lets each DTO re-parse its own
  /// <c>JSONResponse</c> to rebuild polymorphic / streaming content that RTTI cannot
  /// resolve on its own.
  /// </remarks>
  TJSONFingerprint = class
  private
    FJSONPayload: string;
    FJSONResponse: string;
  protected
    /// <summary>
    /// Rebuilds polymorphic content structures after deserialization (override per DTO).
    /// Relies on <c>JSONResponse</c> to extract and rebuild internal representations.
    /// </summary>
    procedure ContentUpdate; virtual;

    /// <summary>
    /// Builds the strongly-typed streaming event object graph from the raw payload
    /// (override per DTO). Relies on <c>JSONResponse</c>.
    /// </summary>
    procedure StreamEventBuilder; virtual;

    /// <summary>
    /// Post-deserialization hook. Derived classes perform their second-step parsing here
    /// (typically by calling <c>ContentUpdate</c> and/or <c>StreamEventBuilder</c>).
    /// </summary>
    procedure AfterDeserialize; virtual;
  public
    /// <summary>
    /// Finalizes deserialization by running the post-deserialization hooks. Intended to be
    /// called exclusively by the deserialization infrastructure, once the object has been
    /// instantiated, bound and its <c>JSONResponse</c> assigned.
    /// </summary>
    procedure InternalFinalizeDeserialize;

    /// <summary>The original request payload associated with this response (if any).</summary>
    property JSONPayload: string read FJSONPayload write FJSONPayload;

    /// <summary>
    /// Gets or sets the raw JSON string returned by the API.
    /// </summary>
    /// <remarks>
    /// Typically, the API returns a single JSON string, which is stored in this property.
    /// </remarks>
    property JSONResponse: string read FJSONResponse write FJSONResponse;
  end;

  /// <summary>
  /// A custom JSON interceptor for handling string-to-string conversions in JSON serialization and deserialization.
  /// </summary>
  /// <remarks>
  /// This interceptor is designed to override the default behavior of JSON serialization
  /// and deserialization for string values, ensuring compatibility with specific formats
  /// or custom requirements.
  /// </remarks>
  TJSONInterceptorStringToString = class(TJSONInterceptor)
  protected
    /// <summary>
    /// Provides runtime type information (RTTI) for enhanced handling of string values.
    /// </summary>
    RTTI: TRttiContext;
    class function GetMemberValue<T>(Data: TObject; const Field: string): T; static;
    class procedure SetMemberValue<T>(Data: TObject; const Field: string; const Value: T); static;
  public
    constructor Create; reintroduce;
  end;

  /// <summary>
  /// Represents a generic key-value parameter manager.
  /// </summary>
  /// <remarks>
  /// This class allows storing and retrieving various types of parameters as key-value pairs.
  /// It supports basic types (integers, strings, booleans, floating-point numbers), objects,
  /// as well as arrays of these types.
  /// </remarks>
  /// <example>
  ///   <code>
  ///     var Params: TParameters;
  ///     begin
  ///       Params := TParameters.Create;
  ///       Params.Add('Limit', 100)
  ///             .Add('Order', 'Asc')
  ///             .Add('IsEnabled', True);
  ///       if Params.Exists('Limit') then
  ///         ShowMessage(IntToStr(Params.GetInteger('Limit')));
  ///       Params.Free;
  ///     end;
  ///   </code>
  /// </example>
  TParameters = class
  private
    FParams: TDictionary<string, TValue>;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AKey: string; const AValue: Integer): TParameters; overload;
    function Add(const AKey: string; const AValue: Int64): TParameters; overload;
    function Add(const AKey: string; const AValue: string): TParameters; overload;
    function Add(const AKey: string; const AValue: Single): TParameters; overload;
    function Add(const AKey: string; const AValue: Double): TParameters; overload;
    function Add(const AKey: string; const AValue: Boolean): TParameters; overload;
    function Add(const AKey: string; const AValue: TObject): TParameters; overload;
    function Add(const AKey: string; const AValue: TJSONObject): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<string>): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<Integer>): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<Int64>): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<Single>): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<Double>): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<Boolean>): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<TObject>): TParameters; overload;
    function Add(const AKey: string; const AValue: TArray<TJSONObject>): TParameters; overload;

    function GetInteger(const AKey: string; const ADefault: Integer = 0): Integer;
    function GetInt64(const AKey: string; const ADefault: Integer = 0): Integer;
    function GetString(const AKey: string; const ADefault: string = ''): string;
    function GetSingle(const AKey: string; const ADefault: Single = 0.0): Double;
    function GetDouble(const AKey: string; const ADefault: Double = 0.0): Double;
    function GetBoolean(const AKey: string; const ADefault: Boolean = False): Boolean;
    function GetObject(const AKey: string; const ADefault: TObject = nil): TObject;
    function GetJSONObject(const AKey: string): TJSONObject;

    function GetArrayString(const AKey: string): TArray<string>;
    function GetArrayInteger(const AKey: string): TArray<Integer>;
    function GetArrayInt64(const AKey: string): TArray<Int64>;
    function GetArraySingle(const AKey: string): TArray<Single>;
    function GetArrayDouble(const AKey: string): TArray<Double>;
    function GetArrayBoolean(const AKey: string): TArray<Boolean>;
    function GetArrayObject(const AKey: string): TArray<TObject>;
    function GetArrayJSONObject(const AKey: string): TArray<TJSONObject>;
    function GetJSONArray(const AKey: string): TJSONArray;

    function Exists(const AKey: string): Boolean;
    procedure ProcessParam(const AKey: string; ACallback: TProc<TValue>);
  end;

  /// <summary>
  /// Represents an optional, deserialized content whose presence in the API
  /// response is tracked explicitly.
  /// </summary>
  /// <remarks>
  /// <para>
  /// <c>HasValue</c> is <c>True</c> when the instance was populated from an actual
  /// payload returned by the API, and <c>False</c> when it only exists as a
  /// placeholder (no corresponding content was present in the response).
  /// </para>
  /// </remarks>
  TOptionalContent = class
  private
    FHasValue: Boolean;
  public
    /// <summary>
    /// Indicates whether this instance contains a value provided by the
    /// deserialization process.
    /// </summary>
    property HasValue: Boolean read FHasValue;

    /// <summary>
    /// Marks this instance as containing a value provided by the deserialization process.
    /// </summary>
    procedure MarkHasValue; inline;
  end;

  /// <summary>
  /// Utility record exposing helper functions to parse JSON strings and to build
  /// <c>TJSONArray</c> values from arrays of <c>TJSONParam</c> or <c>TJSONObject</c>.
  /// </summary>
  TJSONHelper = record
    /// <summary>
    /// Parses a JSON string into a <c>TJSONObject</c>. Raises if the string is not
    /// a valid JSON object.
    /// </summary>
    class function StringToJson(const Value: string): TJSONObject; static;

    /// <summary>
    /// Parses a JSON string into a <c>TJSONArray</c>. Raises if the string is not
    /// a valid JSON array.
    /// </summary>
    class function StringToJsonArray(const Value: string): TJSONArray; static;

    /// <summary>
    /// Builds a <c>TJSONArray</c> by detaching the JSON object of each
    /// <c>TJSONParam</c> item (ownership is transferred to the array).
    /// </summary>
    class function ToJsonArray<T: TJSONParam>(const Value: TArray<T>): TJSONArray; overload; static;

    /// <summary>
    /// Builds a <c>TJSONArray</c> from an array of <c>TJSONObject</c> (ownership of
    /// each object is transferred to the array).
    /// </summary>
    class function ToJsonArray(const Value: TArray<TJSONObject>): TJSONArray; overload; static;

    /// <summary>
    /// Attempts to parse a JSON string into a <c>TJSONValue</c>.
    /// </summary>
    class function TryParse(const Value: string; out Json: TJSONValue): Boolean; static;

    /// <summary>
    /// Attempts to parse a JSON string into a <c>TJSONObject</c>.
    /// </summary>
    class function TryGetObject(const Value: string; out Obj: TJSONObject): Boolean; static;

    /// <summary>
    /// Attempts to parse a JSON string into a <c>TJSONArray</c>.
    /// </summary>
    class function TryGetArray(const Value: string; out Arr: TJSONArray): Boolean; static;
  end;

implementation

uses
  System.DateUtils, System.NetEncoding, GenAI.Types.Rtti;

{ TJSONInterceptorStringToString }

constructor TJSONInterceptorStringToString.Create;
begin
  inherited Create;
  ConverterType := ctString;
  ReverterType := rtString;
end;

class function TJSONInterceptorStringToString.GetMemberValue<T>(Data: TObject;
  const Field: string): T;
begin
  Result := TRttiMemberAccess.GetValue<T>(Data, Field);
end;

class procedure TJSONInterceptorStringToString.SetMemberValue<T>(Data: TObject;
  const Field: string; const Value: T);
begin
  TRttiMemberAccess.SetValue<T>(Data, Field, Value);
end;

{ TJSONFingerprint }

procedure TJSONFingerprint.AfterDeserialize;
begin
  {--- Default: no second-step processing. Derived DTOs override this. }
end;

procedure TJSONFingerprint.ContentUpdate;
begin
  {--- Default: nothing. Derived DTOs override to rebuild polymorphic content. }
end;

procedure TJSONFingerprint.StreamEventBuilder;
begin
  {--- Default: nothing. Derived DTOs override to build streaming events. }
end;

procedure TJSONFingerprint.InternalFinalizeDeserialize;
begin
  AfterDeserialize;
end;

{ Fetch }

type
  Fetch<T> = class
    type
      TFetchProc = reference to procedure(const Element: T);
  public
    class procedure All(const Items: TArray<T>; Proc: TFetchProc);
  end;

{ Fetch<T> }

class procedure Fetch<T>.All(const Items: TArray<T>; Proc: TFetchProc);
var
  Item: T;
begin
  for Item in Items do
    Proc(Item);
end;

{ TUrlParam }

function TUrlParam.Add(const Name, Value: string): TUrlParam;
begin
  Check(Name);
  var S := Format('%s=%s', [Name, TNetEncoding.URL.Encode(Value).Replace('+', '%20')]);
  if FValue.IsEmpty then
    FValue := S else
    FValue := FValue + '&' + S;
  Result := Self;
end;

function TUrlParam.Add(const Name: string; Value: Integer): TUrlParam;
begin
  Result := Add(Name, Value.ToString);
end;

function TUrlParam.Add(const Name: string; Value: Int64): TUrlParam;
begin
  Result := Add(Name, Value.ToString);
end;

function TUrlParam.Add(const Name: string; Value: Boolean): TUrlParam;
begin
  Result := Add(Name, BoolToStr(Value, true));
end;

function TUrlParam.Add(const Name: string; Value: Double): TUrlParam;
begin
  Result := Add(Name, Value.ToString);
end;

procedure TUrlParam.Check(const Name: string);
var
  Params: TArray<string>;
begin
  var Items := FValue.Split(['&']);
  FValue := EmptyStr;
  for var Item in Items do
    begin
      if not Item.StartsWith(Name + '=') then
        Params := Params + [Item];
    end;
  FValue := string.Join('&', Params);
end;

constructor TUrlParam.Create;
begin
  FValue := EmptyStr;
end;

function TUrlParam.GetValue: string;
var
  Params: TArray<string>;
begin
  var Items := FValue.Split(['&']);
  for var Item in Items do
    begin
      var SubStr := Item.Split(['=']);
      if Length(SubStr) <> 2 then
        raise Exception.CreateFmt('%s: Ivalid URL parameter.', [SubStr]);
      Params := Params + [
        TNetEncoding.URL.Encode(SubStr[0]).Replace('+', '%20') + '=' + SubStr[1] ];
    end;
  Result := string.Join('&', Params);
  if not Result.IsEmpty then
    Result := '?' + Result;
end;

function TUrlParam.Add(const Name: string; Value: TArray<string>): TUrlParam;
begin
  Result := Add(Name, string.Join(',', Value).Trim);
end;

{ TJSONParam }

function TJSONParam.Add(const Key, Value: string): TJSONParam;
begin
  Delete(Key);
  FJSON.AddPair(Key, Value);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TJSONValue): TJSONParam;
begin
  Delete(Key);
  FJSON.AddPair(Key, Value);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TJSONParam): TJSONParam;
begin
  {--- Clone semantics for a single TJSONParam to avoid consuming the argument.
     A nil value is serialized as an explicit JSON null.
     - Note: the deep clone of Value.JSON can be costly for large objects and is
     not always necessary if you're certain not to modify or retain the same JSON
     instance in multiple places.
  }
  if Value = nil then
    begin
      Delete(Key);
      FJSON.AddPair(Key, TJSONNull.Create);
      Exit(Self);
    end;

  Add(Key, TJSONValue(Value.JSON.Clone));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TDateTime; Format: string): TJSONParam;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
  {--- Converting local DateTime to universal time (UTC)  }
  Add(Key, FormatDateTime(Format, System.DateUtils.TTimeZone.local.ToUniversalTime(Value)));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Boolean): TJSONParam;
begin
  Add(Key, TJSONBool.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Integer): TJSONParam;
begin
  Add(Key, TJSONNumber.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Extended): TJSONParam;
begin
  Add(Key, TJSONNumber.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<TJSONValue>): TJSONParam;
begin
  var JSONArray := TJSONArray.Create;
  Fetch<TJSONValue>.All(Value, JSONArray.AddElement);
  Add(Key, JSONArray);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<Int64>): TJSONParam;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item);
  Add(Key, JSONArray);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: Int64): TJSONParam;
begin
  Add(Key, TJSONNumber.Create(Value));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<Extended>): TJSONParam;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item);
  Add(Key, JSONArray);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<Integer>): TJSONParam;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item);
  Add(Key, JSONArray);
  Result := Self;
end;

function TJSONParam.Add(const Key: string; Value: TArray<string>): TJSONParam;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
    JSONArray.Add(Item);
  Add(Key, JSONArray);
  Result := Self;
end;

procedure TJSONParam.Clear;
begin
  if Assigned(FJSON) then
    FreeAndNil(FJSON);
  FJSON := TJSONObject.Create;
end;

constructor TJSONParam.Create;
begin
  FJSON := TJSONObject.Create;
  FIsDetached := False;
end;

procedure TJSONParam.Delete(const Key: string);
begin
  var Item := FJSON.RemovePair(Key);
  if Assigned(Item) then
    Item.Free;
end;

destructor TJSONParam.Destroy;
begin
  if Assigned(FJSON) then
    FJSON.Free;
  inherited;
end;

function TJSONParam.Detach: TJSONObject;
begin
  Assert(not FIsDetached, 'Detach has already been called on this instance of TJSONParam.');
  Result := JSON;
  JSON := nil;
  FIsDetached := True;

  {--- NOTE
     Creating an asynchronous task to release the TJSONParam instance after a short delay.
     This ensures that all current references to the object are completed before its release.
     The 30-millisecond delay provides sufficient time for the caller to retrieve the detached JSON.
     Using TThread.Queue to ensure the release occurs in the main thread context, thereby avoiding
     potential issues related to memory management in secondary threads.
  }

  var Task: ITask := TTask.Create(
    procedure()
    begin
      Sleep(30);
      TThread.Queue(nil,
      procedure
      begin
        Self.Free;
      end);
    end
  );
  Task.Start;
end;

function TJSONParam.GetCount: Integer;
begin
  Result := FJSON.Count;
end;

function TJSONParam.GetOrCreate<T>(const Name: string): T;
begin
  var ExistingValue := FJSON.GetValue(Name);
  if Assigned(ExistingValue) then
    begin
      if ExistingValue is T then
        Result := T(ExistingValue)
      else
        raise Exception.CreateFmt(
          'Incorrect JSON value type for key "%s". Expected: %s, Found: %s.',
          [Name, T.ClassName, ExistingValue.ClassName]);
    end
  else
    begin
      Result := T.Create;
      FJSON.AddPair(Name, Result);
    end;
end;

function TJSONParam.GetOrCreateObject(const Name: string): TJSONObject;
begin
  Result := GetOrCreate<TJSONObject>(Name);
end;

procedure TJSONParam.SetJSON(const Value: TJSONObject);
begin
  FJSON := Value;
end;

function TJSONParam.ToFormat(FreeObject: Boolean): string;
begin
  Result := FJSON.Format(4);
  if FreeObject then
    Free;
end;

function TJSONParam.ToJsonString(FreeObject: Boolean): string;
begin
  Result := FJSON.ToJSON;
  if FreeObject then
    Free;
end;

function TJSONParam.ToStream: TStringStream;
begin
  Result := TStringStream.Create;
  try
    Result.WriteString(ToJsonString);
    Result.Position := 0;
  except
    Result.Free;
    raise;
  end;
end;

function TJSONParam.ToStringPairs: TArray<TPair<string, string>>;
begin
  for var Pair in FJSON do
    Result := Result + [TPair<string, string>.Create(Pair.JsonString.Value, Pair.JsonValue.ToString)];
end;

{ TUrlAdvancedParams  }

function TUrlAdvancedParams.Before(const Value: string): TUrlAdvancedParams;
begin
  Result := TUrlAdvancedParams (Add('before', Value));
end;

function TUrlAdvancedParams.Order(const Value: string): TUrlAdvancedParams;
begin
  Result := TUrlAdvancedParams (Add('order', Value));
end;

{ TUrlPaginationParams }

function TUrlPaginationParams.After(const Value: string): TUrlPaginationParams;
begin
  Result := TUrlPaginationParams(Add('after', Value));
end;

function TUrlPaginationParams.Limit(const Value: Integer): TUrlPaginationParams;
begin
  Result := TUrlPaginationParams(Add('limit', Value));
end;

{ TParameters }

function TParameters.Add(const AKey: string;
  const AValue: Boolean): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: Double): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: Integer): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

function TParameters.Add(const AKey, AValue: string): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

constructor TParameters.Create;
begin
  inherited Create;
  FParams := TDictionary<string, TValue>.Create;
end;

destructor TParameters.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TParameters.Exists(const AKey: string): Boolean;
begin
  Result := FParams.ContainsKey(AKey.ToLower)
end;

function TParameters.GetArrayBoolean(const AKey: string): TArray<Boolean>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<Boolean>> then
    Result := LValue.AsType<TArray<Boolean>>
  else
    Result := [];
end;

function TParameters.GetArrayDouble(const AKey: string): TArray<Double>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<Double>> then
    Result := LValue.AsType<TArray<Double>>
  else
    Result := [];
end;

function TParameters.GetArrayInt64(const AKey: string): TArray<Int64>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<Int64>> then
    Result := LValue.AsType<TArray<Int64>>
  else
    Result := [];
end;

function TParameters.GetArrayInteger(const AKey: string): TArray<Integer>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<Integer>> then
    Result := LValue.AsType<TArray<Integer>>
  else
    Result := [];
end;

function TParameters.GetArrayJSONObject(
  const AKey: string): TArray<TJSONObject>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<TJSONObject>> then
    Result := LValue.AsType<TArray<TJSONObject>>
  else
    Result := nil;
end;

function TParameters.GetArrayObject(const AKey: string): TArray<TObject>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<TObject>> then
    Result := LValue.AsType<TArray<TObject>>
  else
    Result := [];
end;

function TParameters.GetArraySingle(const AKey: string): TArray<Single>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<Single>> then
    Result := LValue.AsType<TArray<Single>>
  else
    Result := [];
end;

function TParameters.GetArrayString(const AKey: string): TArray<string>;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TArray<string>> then
    Result := LValue.AsType<TArray<string>>
  else
    Result := [];
end;

function TParameters.GetBoolean(const AKey: string;
  const ADefault: Boolean): Boolean;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<Boolean> then
    Result := LValue.AsBoolean
  else
    Result := ADefault;
end;

function TParameters.GetDouble(const AKey: string;
  const ADefault: Double): Double;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<Double> then
    Result := LValue.AsType<Double>
  else
    Result := ADefault;
end;

function TParameters.GetInt64(const AKey: string;
  const ADefault: Integer): Integer;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<Int64> then
    Result := LValue.AsInt64
  else
    Result := ADefault;
end;

function TParameters.GetInteger(const AKey: string;
  const ADefault: Integer): Integer;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<Integer> then
    Result := LValue.AsInteger
  else
    Result := ADefault;
end;

function TParameters.GetJSONArray(const AKey: string): TJSONArray;
begin
  Result := TJSONArray.Create;
  for var Item in GetArrayJSONObject(AKey) do
    Result.Add(Item);
end;

function TParameters.GetJSONObject(const AKey: string): TJSONObject;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<TJSONObject> then
    Result := LValue.AsType<TJSONObject>
  else
    Result := nil;
end;

function TParameters.GetObject(const AKey: string;
  const ADefault: TObject): TObject;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsObject then
    Result := LValue.AsObject
  else
    Result := ADefault;
end;

function TParameters.GetSingle(const AKey: string;
  const ADefault: Single): Double;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<Single> then
    Result := LValue.AsType<Single>
  else
    Result := ADefault;
end;

function TParameters.GetString(const AKey, ADefault: string): string;
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) and LValue.IsType<string> then
    Result := LValue.AsString
  else
    Result := ADefault;
end;

procedure TParameters.ProcessParam(const AKey: string;
  ACallback: TProc<TValue>);
var
  LValue: TValue;
begin
  if FParams.TryGetValue(AKey.ToLower, LValue) then
    ACallback(LValue);
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<string>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<string>>(AValue));
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<Integer>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<Integer>>(AValue));
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<Double>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<Double>>(AValue));
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<Boolean>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<Boolean>>(AValue));
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TObject): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<Single>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<Single>>(AValue));
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: Single): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<Int64>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<Int64>>(AValue));
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: Int64): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<TObject>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<TObject>>(AValue));
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TJSONObject): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, AValue);
  Result := Self;
end;

function TParameters.Add(const AKey: string;
  const AValue: TArray<TJSONObject>): TParameters;
begin
  FParams.AddOrSetValue(AKey.ToLower, TValue.From<TArray<TJSONObject>>(AValue));
  Result := Self;
end;

{ TJSONParam (array of TJSONParam) }

function TJSONParam.Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam;
begin
  var JSONArray := TJSONArray.Create;
  try
    for var Item in Value do
    try
      if Item = nil then
        begin
          JSONArray.AddElement(TJSONNull.Create);
          Continue;
        end;

      {--- Transfer ownership of Item.JSON into the array:
           - if Item.JSON is nil, treat it as an empty object. }
      if Item.FJSON = nil then
        Item.FJSON := TJSONObject.Create;

      JSONArray.AddElement(Item.FJSON);
      Item.FJSON := nil;
    finally
      Item.Free;
    end;

    {--- transfers ownership of JSONArray to FJSON }
    Add(Key, JSONArray);
  except
    JSONArray.Free;
    raise;
  end;
  Result := Self;
end;

{ TOptionalContent }

procedure TOptionalContent.MarkHasValue;
begin
  FHasValue := True;
end;

{ TJSONHelper }

class function TJSONHelper.StringToJson(const Value: string): TJSONObject;
begin
  var JSON := TJSONObject.ParseJSONValue(Value);
  if not Assigned(JSON) then
    raise Exception.CreateFmt('Invalid JSON: %s', [Value]);

  if not (JSON is TJSONObject) then
    begin
      JSON.Free;
      raise Exception.Create('JSON is not an object');
    end;

  Result := TJSONObject(JSON);
end;

class function TJSONHelper.StringToJsonArray(const Value: string): TJSONArray;
begin
  var JSON := TJSONObject.ParseJSONValue(Value);
  if not Assigned(JSON) then
    raise Exception.CreateFmt('Invalid JSON: %s', [Value]);

  if not (JSON is TJSONArray) then
    begin
      JSON.Free;
      raise Exception.Create('JSON is not an array');
    end;

  Result := TJSONArray(JSON);
end;

class function TJSONHelper.ToJsonArray(
  const Value: TArray<TJSONObject>): TJSONArray;
begin
  Result := TJSONArray.Create;
  try
    for var Item in Value do
      begin
        if Item = nil then
          Continue;

        Result.Add(Item);
      end;
  except
    Result.Free;
    raise;
  end;
end;

class function TJSONHelper.ToJsonArray<T>(const Value: TArray<T>): TJSONArray;
begin
  Result := TJSONArray.Create;
  try
    for var Item in Value do
      begin
        if Item = nil then
          Continue;

        Result.Add(Item.Detach);
      end;
  except
    Result.Free;
    raise;
  end;
end;

class function TJSONHelper.TryGetArray(const Value: string;
  out Arr: TJSONArray): Boolean;
var
  JSONValue: TJSONValue;
begin
  Arr := nil;
  if not TryParse(Value, JSONValue) then
    Exit(False);

  if JSONValue is TJSONArray then
    begin
      Arr := TJSONArray(JSONValue);
      Exit(True);
    end;

  JSONValue.Free;
  Result := False;
end;

class function TJSONHelper.TryGetObject(const Value: string;
  out Obj: TJSONObject): Boolean;
var
  JSONValue: TJSONValue;
begin
  Obj := nil;
  if not TryParse(Value, JSONValue) then
    Exit(False);

  if JSONValue is TJSONObject then
    begin
      Obj := TJSONObject(JSONValue);
      Exit(True);
    end;

  JSONValue.Free;
  Result := False;
end;

class function TJSONHelper.TryParse(const Value: string;
  out Json: TJSONValue): Boolean;
begin
  Json := nil;
  try
    Json := TJSONObject.ParseJSONValue(Value);
    Result := Json <> nil;
  except
    Json.Free;
    Json := nil;
    Result := False;
  end;
end;

end.
