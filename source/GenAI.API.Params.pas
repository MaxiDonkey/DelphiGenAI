unit GenAI.API.Params;

interface

uses
  System.Classes, System.JSON, System.SysUtils, System.Types, System.RTTI,
  REST.JsonReflect, REST.Json.Interceptors, System.Generics.Collections,
  System.Threading, System.TypInfo;

type
  /// <summary>
  /// Represents a reference to a procedure that takes a single argument of type T and returns no value.
  /// </summary>
  /// <param name="T">
  /// The type of the argument that the referenced procedure will accept.
  /// </param>
  /// <remarks>
  /// This type is useful for defining callbacks or procedures that operate on a variable of type T, allowing for more flexible and reusable code.
  /// </remarks>
  TProcRef<T> = reference to procedure(var Arg: T);

  TUrlParam = class
  private
    FValue: string;
    procedure Check(const Name: string);
    function GetValue: string;
  public
    function Add(const Name, Value: string): TUrlParam; overload; virtual;
    function Add(const Name: string; Value: Integer): TUrlParam; overload; virtual;
    function Add(const Name: string; Value: Boolean): TUrlParam; overload; virtual;
    function Add(const Name: string; Value: Double): TUrlParam; overload; virtual;
    function Add(const Name: string; Value: TArray<string>): TUrlParam; overload; virtual;
    property Value: string read GetValue;
    constructor Create; virtual;
  end;

  TJSONParam = class
  private
    FJSON: TJSONObject;
    procedure SetJSON(const Value: TJSONObject);
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const Key: string; const Value: string): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Integer): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Extended): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: Boolean): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TDateTime; Format: string): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TJSONValue): TJSONParam; overload; virtual;
    function Add(const Key: string; const Value: TJSONParam): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<string>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<Integer>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<Extended>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<TJSONValue>): TJSONParam; overload; virtual;
    function Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam; overload; virtual;
    function GetOrCreateObject(const Name: string): TJSONObject;
    function GetOrCreate<T: TJSONValue, constructor>(const Name: string): T;
    procedure Delete(const Key: string); virtual;
    procedure Clear; virtual;
    property Count: Integer read GetCount;
    function Detach: TJSONObject;
    property JSON: TJSONObject read FJSON write SetJSON;
    function ToJsonString(FreeObject: Boolean = False): string; virtual;
    function ToFormat(FreeObject: Boolean = False): string;
    function ToStringPairs: TArray<TPair<string, string>>;
    function ToStream: TStringStream;
  end;

  TJSONFingerprint = class
  private
    FJSONResponse: TArray<string>;
  public
    property JSONResponse: TArray<string> read FJSONResponse write FJSONResponse;
  end;

  TJSONInterceptorStringToString = class(TJSONInterceptor)
  protected
    RTTI: TRttiContext;
  public
    constructor Create; reintroduce;
  end;

implementation

uses
  System.DateUtils;

const
  DATE_FORMAT = 'YYYY-MM-DD';
  TIME_FORMAT = 'HH:NN:SS';
  DATE_TIME_FORMAT = DATE_FORMAT + ' ' + TIME_FORMAT;

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

function TUrlParam.Add(const Name: string; Value: Boolean): TUrlParam;
begin
  Result := Add(Name, BoolToStr(Value, true));
end;

function TUrlParam.Add(const Name: string; Value: Double): TUrlParam;
begin
  Result := Add(Name, Value.ToString);
end;

procedure TUrlParam.Check(const Name: string);
begin
  if FValue.Contains(Name) then
    begin
      var Items := FValue.Split(['&']);
      FValue := EmptyStr;
      for var Item in Items do
        begin
          if not Item.StartsWith(Name) then
            begin
              if FValue.IsEmpty then
                FValue := Item else
                FValue := FValue + '&' + Item;
            end;
        end;
    end;
end;

constructor TUrlParam.Create;
begin
  FValue := EmptyStr;
end;

function TUrlParam.GetValue: string;
begin
  Result := FValue;
  if not Result.IsEmpty then
    Result := '?' + Result;
end;

function TUrlParam.Add(const Name: string; Value: TArray<string>): TUrlParam;
begin
  Result := Add(Name, string.Join(',', Value).Replace(#32, #0));
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
  Add(Key, TJSONValue(Value.JSON.Clone));
  Result := Self;
end;

function TJSONParam.Add(const Key: string; const Value: TDateTime; Format: string): TJSONParam;
begin
  if Format.IsEmpty then
    Format := DATE_TIME_FORMAT;
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

function TJSONParam.Add(const Key: string; Value: TArray<TJSONParam>): TJSONParam;
begin
  var JSONArray := TJSONArray.Create;
  for var Item in Value do
  try
    JSONArray.AddElement(Item.JSON);
    Item.JSON := nil;
  finally
    Item.Free;
  end;
  Add(Key, JSONArray);
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
  FJSON.Free;
  FJSON := TJSONObject.Create;
end;

constructor TJSONParam.Create;
begin
  FJSON := TJSONObject.Create;
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
  Result := JSON;
  JSON := nil;
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
  if not FJSON.TryGetValue<T>(Name, Result) then
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
    Result := Result + [TPair<string, string>.Create(Pair.JsonString.Value, Pair.JsonValue.AsType<string>)];
end;

end.

