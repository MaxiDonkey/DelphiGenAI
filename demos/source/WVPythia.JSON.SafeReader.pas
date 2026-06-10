unit WVPythia.JSON.SafeReader;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections;

type
  TJSONValueHelper = class helper for TJSONValue
  public
    function GetPathValue(const Path: string): TJSONValue;
    function GetPathString(const Path: string; const Default: string = ''): string;
    function GetPathInteger(const Path: string; const Default: Integer = 0): Integer;
    function GetPathBoolean(const Path: string; const Default: Boolean = False): Boolean;
    function GetPathDouble(const Path: string; const Default: Double = 0.0): Double;
    function GetPathObjectText(const Path: string; const Default: string = ''): string;
    function GetPathArrayText(const Path: string; const Default: string = ''): string;
    function GetPathCount(const Path: string; const Default: Integer = 0): Integer;
    function RemovePath(const Path: string): Boolean;
  end;

  TJsonReader = record
  private
    type
      {$SCOPEDENUMS ON}
      TJsonNodeKind = (
        none,
        null,
        &string,
        number,
        &object,
        &array,
        &boolean
      );
      {$SCOPEDENUMS OFF}

      IJsonRootHolder = interface
        ['{0E6D8A89-2DA5-4A5A-8E1B-9C0C8F2D0C77}']
        function Root: TJSONValue;
        function Source: string;
      end;

      TJsonRootHolder = class(TInterfacedObject, IJsonRootHolder)
      private
        FRoot: TJSONValue;
        FSource: string;
      public
        constructor Create(const JsonText: string);
        destructor Destroy; override;
        function Root: TJSONValue;
        function Source: string;
      end;

  private
    FHolder: IJsonRootHolder;
    function Root: TJSONValue; inline;

    function ValueKind(const Path: string): TJsonNodeKind;
  public
    class function Parse(const JsonText: string): TJsonReader; static;

    class operator Initialize(out Dest: TJsonReader);

    function IsValid: Boolean; inline;

    function Value(const Path: string): TJSONValue; inline;

    function Exists(const Path: string): Boolean;

    function AsString(const Path: string; const Default: string = ''): string;
    function AsInteger(const Path: string; const Default: Integer = 0): Integer;
    function AsBoolean(const Path: string; const Default: Boolean = False): Boolean;
    function AsDouble(const Path: string; const Default: Double = 0.0): Double;

    function ObjectText(const Path: string; const Default: string = ''): string;
    function ObjectFieldNames(const Path: string = ''): TArray<string>;
    function ArrayText(const Path: string; const Default: string = ''): string;
    function Count(const Path: string; const Default: Integer = 0): Integer;
    function Format(const Format: Integer = 4): string;
    function ToJson: string;
    function Remove(const Path: string): Boolean;
    function ExtractSubJson(const Path: string; const Default: string = ''): string;
    function IndicesWithFieldInArray(const ArrayPath: string; const FieldName: string = 'content'): TArray<Integer>;
    function ArrayFieldStrings(const ArrayPath: string; const FieldName: string = 'type'): TArray<string>;
    function ArrayStrings(const ArrayPath: string): TArray<string>;
    function IsStringNode(const Path: string): Boolean;
    function IsNumberNode(const Path: string): Boolean;
    function IsObjectNode(const Path: string): Boolean;
    function IsArrayNode(const Path: string): Boolean;
    function IsNullNode(const Path: string): Boolean;
    function JSONObject: TJSONObject;
    function Source: string;
  end;

  TJsonCheck = record
    class function IsValid(const JsonAsString: string;
      const ParamProc: TProc<TJsonReader> = nil): Boolean; static;
  end;

implementation

function NextToken(const S: string; var Index: Integer): string;
begin
  while (Index <= S.Length) and (S[Index] = '.') do
    Inc(Index);

  var Start := Index;

  while (Index <= S.Length) and (S[Index] <> '.') do
    Inc(Index);

  Result := S.Substring(Start - 1, Index - Start);

  if (Index <= S.Length) and (S[Index] = '.') then
    Inc(Index);
end;

function ParseArrayIndex(const Token: string; out Name: string; out HasIndex: Boolean; out Index: Integer): Boolean;
begin
  Name := Token;
  HasIndex := False;
  Index := -1;

  var Left := Token.IndexOf('[');
  if Left < 0 then
    Exit(True);

  var Right := Token.IndexOf(']', Left + 1);
  if Right < 0 then
    Exit(False);

  Name := Token.Substring(0, Left);
  var IndexStr := Token.Substring(Left + 1, Right - (Left + 1));
  HasIndex := True;
  Result := TryStrToInt(IndexStr, Index) and (Index >= 0);
end;

{ TJSONValueHelper }

function TJSONValueHelper.GetPathValue(const Path: string): TJSONValue;
var
  ArrIndex: Integer;
  Name: string;
  HasIndex: Boolean;
begin
  Result := nil;

  var Current := Self;
  if (Current = nil) or Path.IsEmpty then
    Exit;

  var I := 1;
  while I <= Path.Length do
    begin
      var Token := NextToken(Path, I);
      if Token.IsEmpty then
        Break;

      if not ParseArrayIndex(Token, Name, HasIndex, ArrIndex) then
        Exit(nil);

      if not Name.IsEmpty then
        begin
          if not (Current is TJSONObject) then
            Exit(nil);

          var Obj := TJSONObject(Current);
          Current := Obj.GetValue(Name);
          if Current = nil then
            Exit(nil);
        end;

      if HasIndex then
        begin
          if not (Current is TJSONArray) then
            Exit(nil);

          var Arr := TJSONArray(Current);
          if (ArrIndex < 0) or (ArrIndex >= Arr.Count) then
            Exit(nil);

          Current := Arr.Items[ArrIndex];
          if Current = nil then
            Exit(nil);
        end;
    end;

  Result := Current;
end;

function TJSONValueHelper.RemovePath(const Path: string): Boolean;
var
  Parent: TJSONValue;
  TargetName: string;
  HasIndex: Boolean;
  TargetIndex: Integer;

  function SplitLastToken(const P: string; out ParentPath, LastToken: string): Boolean;
  var
    Dot: Integer;
  begin
    ParentPath := '';
    LastToken := '';
    if P.IsEmpty then Exit(False);

    Dot := P.LastIndexOf('.');
    if Dot < 0 then
      begin
        ParentPath := '';
        LastToken := P;
        Exit(True);
      end;

    ParentPath := P.Substring(0, Dot);
    LastToken := P.Substring(Dot + 1);
    Result := True;
  end;

begin
  Result := False;
  if (Self = nil) or Path.IsEmpty then
    Exit;

  var ParentPath, LastToken: string;
  if not SplitLastToken(Path, ParentPath, LastToken) then
    Exit;

  if not ParseArrayIndex(LastToken, TargetName, HasIndex, TargetIndex) then
    Exit(False);

  if ParentPath.IsEmpty then
    Parent := Self
  else
    Parent := Self.GetPathValue(ParentPath);

  if Parent = nil then
    Exit(False);

  if HasIndex then
  begin
    var ArrValue: TJSONValue := Parent;

    if not TargetName.IsEmpty then
      begin
        if not (Parent is TJSONObject) then Exit(False);
        ArrValue := TJSONObject(Parent).GetValue(TargetName);
        if (ArrValue = nil) or not (ArrValue is TJSONArray) then Exit(False);
      end;

    if not (ArrValue is TJSONArray) then Exit(False);

    var Arr := TJSONArray(ArrValue);
    if (TargetIndex < 0) or (TargetIndex >= Arr.Count) then
      Exit(False);

    Arr.Remove(TargetIndex).Free;
    Exit(True);
  end;

  if TargetName.IsEmpty then
    Exit(False);

  if not (Parent is TJSONObject) then
    Exit(False);

  var Obj := TJSONObject(Parent);
  var Pair := Obj.RemovePair(TargetName);
  if Pair = nil then
    Exit(False);

  Pair.Free;
  Result := True;
end;

function TJSONValueHelper.GetPathString(const Path: string; const Default: string): string;
begin
  var JSONValue := GetPathValue(Path);
  if JSONValue = nil then
    Exit(Default);

  if JSONValue is TJSONString then
    Exit(TJSONString(JSONValue).Value);

  if JSONValue is TJSONNumber then
    Exit(TJSONNumber(JSONValue).ToString);

  Result := JSONValue.Value;
  if Result.IsEmpty then
    Result := JSONValue.ToString;
end;

function TJSONValueHelper.GetPathInteger(const Path: string; const Default: Integer): Integer;
begin
  var S := GetPathString(Path, '');
  if not S.IsEmpty and TryStrToInt(S, Result) then
    Exit;

  Result := Default;
end;

function TJSONValueHelper.GetPathBoolean(const Path: string; const Default: Boolean): Boolean;
begin
  var S := GetPathString(Path, '');
  if SameText(S, 'true') then
    Exit(True);

  if SameText(S, 'false') then
    Exit(False);

 Result := Default;
end;

function TJSONValueHelper.GetPathDouble(const Path: string; const Default: Double): Double;
begin
  var S := GetPathString(Path, '');
  var FS := TFormatSettings.Invariant;
  if not S.IsEmpty and TryStrToFloat(S, Result, FS) then
    Exit;

  Result := Default;
end;

function TJSONValueHelper.GetPathObjectText(const Path, Default: string): string;
begin
  var V := GetPathValue(Path);
  if (V <> nil) and (V is TJSONObject) then
    Exit(TJSONObject(V).ToJSON);

  Result := Default;
end;

function TJSONValueHelper.GetPathArrayText(const Path, Default: string): string;
begin
  var V := GetPathValue(Path);
  if (V <> nil) and (V is TJSONArray) then
    Exit(TJSONArray(V).ToJSON);

  Result := Default;
end;

function TJSONValueHelper.GetPathCount(const Path: string; const Default: Integer): Integer;
begin
  var V := GetPathValue(Path);
  if V = nil then
    Exit(Default);

  if V is TJSONArray then
    Exit(TJSONArray(V).Count);

  if V is TJSONObject then
    Exit(TJSONObject(V).Count);

  Result := Default;
end;

{ TJsonReader.TJsonRootHolder }

constructor TJsonReader.TJsonRootHolder.Create(const JsonText: string);
begin
  inherited Create;
  FSource := JsonText;
  FRoot := TJSONObject.ParseJSONValue(JsonText);
end;

destructor TJsonReader.TJsonRootHolder.Destroy;
begin
  FRoot.Free;
  inherited;
end;

function TJsonReader.TJsonRootHolder.Root: TJSONValue;
begin
  Result := FRoot;
end;

function TJsonReader.TJsonRootHolder.Source: string;
begin
  Result := FSource;
end;

{ TJsonReader }

function TJsonReader.IndicesWithFieldInArray(const ArrayPath,
  FieldName: string): TArray<Integer>;
begin
  SetLength(Result, 0);

  var R := Root;
  if (R = nil) or ArrayPath.IsEmpty or FieldName.IsEmpty then
    Exit;

  var V := R.GetPathValue(ArrayPath);
  if (V = nil) or not (V is TJSONArray) then
    Exit;

  var Arr := TJSONArray(V);

  var Indices := TList<Integer>.Create;
  try
    for var I := 0 to Arr.Count - 1 do
      begin
        var Item := Arr.Items[I];
        if (Item <> nil) and (Item is TJSONObject) then
          begin
            {--- Contains a "content" field => the key exists and its value is not nil }
            var Child := TJSONObject(Item).GetValue(FieldName);
            if Child <> nil then
              Indices.Add(I);
          end;
      end;

    Result := Indices.ToArray;
  finally
    Indices.Free;
  end;
end;

class operator TJsonReader.Initialize(out Dest: TJsonReader);
begin
  Dest.FHolder := nil;
end;

function TJsonReader.Remove(const Path: string): Boolean;
begin
  var R := Root;
  if R = nil then
    Exit(False);

  Result := R.RemovePath(Path);
end;

function TJsonReader.Root: TJSONValue;
begin
  if FHolder = nil then
    Exit(nil);

  Result := FHolder.Root;
end;

function TJsonReader.Source: string;
begin
  if FHolder = nil then
    Exit('');

  Result := FHolder.Source;
end;

function TJsonReader.ToJson: string;
begin
  Result := JSONObject.ToJSON;
end;

class function TJsonReader.Parse(const JsonText: string): TJsonReader;
begin
  Result.FHolder := TJsonRootHolder.Create(JsonText);
end;

function TJsonReader.IsArrayNode(const Path: string): Boolean;
begin
  Result := ValueKind(Path) = TJsonNodeKind.array;
end;

function TJsonReader.IsNullNode(const Path: string): Boolean;
begin
  Result := ValueKind(Path) = TJsonNodeKind.null;
end;

function TJsonReader.IsNumberNode(const Path: string): Boolean;
begin
  Result := ValueKind(Path) = TJsonNodeKind.number;
end;

function TJsonReader.IsObjectNode(const Path: string): Boolean;
begin
  Result := ValueKind(Path) = TJsonNodeKind.object;
end;

function TJsonReader.IsStringNode(const Path: string): Boolean;
begin
  Result := ValueKind(Path) = TJsonNodeKind.string;
end;

function TJsonReader.IsValid: Boolean;
begin
  Result := Root <> nil;
end;

function TJsonReader.JSONObject: TJSONObject;
begin
  Result := Root as TJSONObject;
end;

function TJsonReader.Value(const Path: string): TJSONValue;
begin
  var R := Root;
  if R = nil then
    Exit(nil);

  Result := R.GetPathValue(Path);
end;

function TJsonReader.ValueKind(const Path: string): TJsonNodeKind;
begin
  Result := TJsonNodeKind.none;

  var V := Value(Path);
  if V = nil then
    Exit(TJsonNodeKind.none);

  if V is TJSONString then
    Exit(TJsonNodeKind.string);

  if V is TJSONNumber then
    Exit(TJsonNodeKind.number);

  if V is TJSONObject then
    Exit(TJsonNodeKind.object);

  if V is TJSONArray then
    Exit(TJsonNodeKind.array);

  if (V is TJSONTrue) or (V is TJSONFalse) then
    Exit(TJsonNodeKind.boolean);

  if V is TJSONNull then
    Exit(TJsonNodeKind.null);
end;

function TJsonReader.AsString(const Path: string; const Default: string): string;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathString(Path, Default);
end;

function TJsonReader.AsInteger(const Path: string; const Default: Integer): Integer;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathInteger(Path, Default);
end;

function TJsonReader.AsBoolean(const Path: string; const Default: Boolean): Boolean;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathBoolean(Path, Default);
end;

function TJsonReader.AsDouble(const Path: string; const Default: Double): Double;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathDouble(Path, Default);
end;

function TJsonReader.ObjectText(const Path: string; const Default: string): string;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathObjectText(Path, Default);
end;

function TJsonReader.ObjectFieldNames(const Path: string): TArray<string>;
begin
  Result := [];

  var R := Root;
  if R = nil then
    Exit;

  var V: TJSONValue;
  if Path.Trim.IsEmpty then
    V := R
  else
    V := R.GetPathValue(Path);

  if not (V is TJSONObject) then
    Exit;

  var Names := TList<string>.Create;
  try
    for var Pair in TJSONObject(V) do
      if Assigned(Pair) and Assigned(Pair.JsonString) then
        Names.Add(Pair.JsonString.Value);

    Result := Names.ToArray;
  finally
    Names.Free;
  end;
end;

function TJsonReader.ArrayFieldStrings(const ArrayPath,
  FieldName: string): TArray<string>;
begin
  SetLength(Result, 0);

  var R := Root;
  if (R = nil) or ArrayPath.IsEmpty or FieldName.IsEmpty then
    Exit;

  var V := R.GetPathValue(ArrayPath);
  if (V = nil) or not (V is TJSONArray) then
    Exit;

  var Arr := TJSONArray(V);

  var Values := TList<string>.Create;
  try
    for var I := 0 to Arr.Count - 1 do
      begin
        var Item := Arr.Items[I];
        if (Item <> nil) and (Item is TJSONObject) then
          begin
            var Field := TJSONObject(Item).GetValue(FieldName);
            if (Field <> nil) then
              begin
                if Field is TJSONString then
                  Values.Add(TJSONString(Field).Value)
                else
                  Values.Add(Field.Value);
              end;
          end;
      end;

    Result := Values.ToArray;
  finally
    Values.Free;
  end;
end;

function TJsonReader.ArrayStrings(const ArrayPath: string): TArray<string>;
begin
  SetLength(Result, 0);

  var R := Root;
  if (R = nil) or ArrayPath.IsEmpty then
    Exit;

  var V := R.GetPathValue(ArrayPath);
  if not (V is TJSONArray) then
    Exit;

  var Arr := TJSONArray(V);
  var Values := TList<string>.Create;
  try
    for var I := 0 to Arr.Count - 1 do
      begin
        var Item := Arr.Items[I];

        if Item is TJSONString then
          Values.Add(TJSONString(Item).Value)
        else if Item <> nil then
          Values.Add(Item.Value);
      end;

    Result := Values.ToArray;
  finally
    Values.Free;
  end;
end;

function TJsonReader.ArrayText(const Path: string; const Default: string): string;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathArrayText(Path, Default);
end;

function TJsonReader.Count(const Path: string; const Default: Integer): Integer;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathCount(Path, Default);
end;

function TJsonReader.Exists(const Path: string): Boolean;
begin
  Result := Value(Path) <> nil;
end;

function TJsonReader.ExtractSubJson(const Path, Default: string): string;
begin
  Result := Default;

  if Path.IsEmpty then
    Exit;

  var V := Self.Value(Path);
  if V = nil then
    Exit;

  if (V is TJSONObject) or (V is TJSONArray) then
    Exit(V.ToJSON);

  if V is TJSONString then
    Exit(TJSONString(V).Value);

  if V is TJSONNumber then
    Exit(TJSONNumber(V).ToString);

  Result := V.Value;
  if Result.IsEmpty then
    Result := V.ToString;
end;

function TJsonReader.Format(const Format: Integer): string;
begin
  var R := Root;
  if R = nil then
    Exit('');

  Result := R.Format(Format);
end;

{ TJsonCheck }

class function TJsonCheck.IsValid(
  const JsonAsString: string;
  const ParamProc: TProc<TJsonReader>): Boolean;
begin
  var Reader := TJsonReader.Parse(JsonAsString);
  Result := Reader.IsValid;

  if not Result then
    Exit;

  if Assigned(ParamProc) then
    ParamProc(Reader);
end;

end.
