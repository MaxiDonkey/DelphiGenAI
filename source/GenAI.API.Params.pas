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
  /// Represents a base class for all classes obtained after deserialization.
  /// </summary>
  /// <remarks>
  /// This class is designed to store the raw JSON string returned by the API,
  /// allowing applications to access the original JSON response if needed.
  /// </remarks>
  TJSONFingerprint = class
  private
    FJSONResponse: string;
  public
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
  public
    constructor Create; reintroduce;
  end;

implementation

uses
  System.DateUtils, System.NetEncoding;

{ TJSONInterceptorStringToString }

constructor TJSONInterceptorStringToString.Create;
begin
  inherited Create;
  ConverterType := ctString;
  ReverterType := rtString;
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
  var S := Format('%s=%s', [Name, Value]);
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
      Params := Params + [TNetEncoding.URL.Encode(SubStr[0]) + '=' + TNetEncoding.URL.Encode(SubStr[1])];
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
  {--- Note
     This line performs a deep clone of Value.JSON into the local JSON, which is
     generally suitable if you don't want the two TJSONParams to share the same
     references.
     - However, keep in mind that this operation can be costly for large
     objects and is not always necessary if you're certain not to modify or retain
     the same JSON instance in multiple places.
  }
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

end.

