unit WVPythia.JSON.SafeWriter;

interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections;

type
  TJsonWriter = record
  private
    type
      IJsonRootHolder = interface
        ['{B04E7BFA-C6E6-43F5-A8FB-F9D164E5E0B3}']
        function Root: TJSONValue;
      end;

      TJsonRootHolder = class(TInterfacedObject, IJsonRootHolder)
      private
        FRoot: TJSONValue;
      public
        constructor CreateOwned(ARoot: TJSONValue);
        constructor CreateFromText(const JsonText: string);
        destructor Destroy; override;
        function Root: TJSONValue;
      end;

  private
    FHolder: IJsonRootHolder;

    function Root: TJSONValue; inline;

    function InternalSetValue(const Path: string; AValue: TJSONValue): Boolean;
    function InternalAppendValue(const ArrayPath: string; AValue: TJSONValue): Boolean;
    function ResolveTerminalContainer(const Path: string; const WantArray: Boolean; out Container: TJSONValue): Boolean;

  public
    class function Parse(const JsonText: string): TJsonWriter; static;
    class function NewObject: TJsonWriter; static;
    class function NewArray: TJsonWriter; static;

    class operator Initialize(out Dest: TJsonWriter);

    function IsValid: Boolean; inline;

    function JSONObject: TJSONObject;
    function JSONArray: TJSONArray;

    function ToJson: string;
    function Format(const Indent: Integer = 4): string;

    function SetString(const Path, Value: string): Boolean;
    function SetInteger(const Path: string; const Value: Int64): Boolean;
    function SetBoolean(const Path: string; const Value: Boolean): Boolean;
    function SetDouble(const Path: string; const Value: Double): Boolean;
    function SetNull(const Path: string): Boolean;

    function SetJson(const Path, JsonText: string): Boolean;
    function SetObjectJson(const Path, JsonText: string): Boolean;
    function SetArrayJson(const Path, JsonText: string): Boolean;

    function EnsureObject(const Path: string): Boolean;
    function EnsureArray(const Path: string): Boolean;

    function AppendString(const ArrayPath, Value: string): Boolean;
    function AppendInteger(const ArrayPath: string; const Value: Int64): Boolean;
    function AppendBoolean(const ArrayPath: string; const Value: Boolean): Boolean;
    function AppendDouble(const ArrayPath: string; const Value: Double): Boolean;
    function AppendNull(const ArrayPath: string): Boolean;
    function AppendJson(const ArrayPath, JsonText: string): Boolean;
    function AppendObjectJson(const ArrayPath, JsonText: string): Boolean;
    function AppendArrayJson(const ArrayPath, JsonText: string): Boolean;

    function Remove(const Path: string): Boolean;
  end;

implementation

type
  TJsonPathToken = record
    Name: string;
    HasIndex: Boolean;
    Index: Integer;
  end;

function CreateJsonNumberFromDouble(const Value: Double): TJSONNumber;
begin
  Result := TJSONNumber.Create(FloatToStr(Value, TFormatSettings.Invariant));
end;

function CreateJsonBoolean(const Value: Boolean): TJSONValue;
begin
  if Value then
    Result := TJSONTrue.Create
  else
    Result := TJSONFalse.Create;
end;

function IsArrayExpectation(const NextToken: TJsonPathToken): Boolean;
begin
  Result := NextToken.HasIndex and NextToken.Name.IsEmpty;
end;

function CreateContainerForNextToken(const NextToken: TJsonPathToken): TJSONValue;
begin
  if IsArrayExpectation(NextToken) then
    Exit(TJSONArray.Create);

  Result := TJSONObject.Create;
end;

function CreateContainer(const WantArray: Boolean): TJSONValue;
begin
  if WantArray then
    Exit(TJSONArray.Create);

  Result := TJSONObject.Create;
end;

function ContainerMatches(const Value: TJSONValue; const WantArray: Boolean): Boolean;
begin
  if WantArray then
    Exit(Value is TJSONArray);

  Result := Value is TJSONObject;
end;

function ParsePathToken(const TokenText: string; out Token: TJsonPathToken): Boolean;
begin
  Token.Name := '';
  Token.HasIndex := False;
  Token.Index := -1;

  if TokenText.IsEmpty then
    Exit(False);

  var LeftPos := TokenText.IndexOf('[');
  if LeftPos < 0 then
    begin
      Token.Name := TokenText;
      Exit(not Token.Name.IsEmpty);
    end;

  var RightPos := TokenText.LastIndexOf(']');
  if (RightPos < 0) or (RightPos <> TokenText.Length - 1) then
    Exit(False);

  var ExtraLeft := TokenText.IndexOf('[', LeftPos + 1);
  if ExtraLeft >= 0 then
    Exit(False);

  var ExtraRight := TokenText.IndexOf(']');
  if ExtraRight <> RightPos then
    Exit(False);

  Token.Name := TokenText.Substring(0, LeftPos);

  var IndexText := TokenText.Substring(LeftPos + 1, RightPos - LeftPos - 1);
  if IndexText.IsEmpty then
    Exit(False);

  Token.HasIndex := True;
  Result := TryStrToInt(IndexText, Token.Index) and (Token.Index >= 0);
end;

function SplitPathStrict(const Path: string; out Tokens: TArray<TJsonPathToken>): Boolean;
var
  Token: TJsonPathToken;
begin
  SetLength(Tokens, 0);

  if Path.IsEmpty then
    Exit(False);

  if (Path[1] = '.') or (Path[Path.Length] = '.') then
    Exit(False);

  var I := 1;
  var Count := 0;

  while I <= Path.Length do
    begin
      var StartPos := I;

      while (I <= Path.Length) and (Path[I] <> '.') do
        Inc(I);

      if I = StartPos then
        Exit(False);

      var TokenText := Path.Substring(StartPos - 1, I - StartPos);
      if not ParsePathToken(TokenText, Token) then
        Exit(False);

      SetLength(Tokens, Count + 1);
      Tokens[Count] := Token;
      Inc(Count);

      if I <= Path.Length then
        begin
          Inc(I);
          if I > Path.Length then
            Exit(False);

          if Path[I] = '.' then
            Exit(False);
        end;
    end;

  Result := Count > 0;
end;

procedure FillArrayWithNulls(const Arr: TJSONArray; const LastIndex: Integer);
begin
  while Arr.Count <= LastIndex do
    Arr.AddElement(TJSONNull.Create);
end;

function ReplaceObjectMember(const Obj: TJSONObject; const Name: string; AValue: TJSONValue): Boolean;
begin
  Result := False;

  if (Obj = nil) or Name.IsEmpty or (AValue = nil) then
    Exit;

  var Pair := Obj.RemovePair(Name);
  try
    Obj.AddPair(Name, AValue);
    Result := True;
  finally
    Pair.Free;
  end;
end;

function ReplaceArrayItem(const Arr: TJSONArray; const Index: Integer; AValue: TJSONValue): Boolean;
begin
  Result := False;

  if (Arr = nil) or (AValue = nil) then
    Exit;

  if (Index < 0) or (Index >= Arr.Count) then
    Exit;

  var Tail := TList<TJSONValue>.Create;
  try
    for var I := Arr.Count - 1 downto Index + 1 do
      Tail.Add(Arr.Remove(I));

    Arr.Remove(Index).Free;
    Arr.AddElement(AValue);

    for var I := Tail.Count - 1 downto 0 do
      Arr.AddElement(Tail[I]);

    Result := True;
  finally
    Tail.Free;
  end;
end;

function SetArrayItem(const Arr: TJSONArray; const Index: Integer; AValue: TJSONValue): Boolean;
begin
  Result := False;

  if (Arr = nil) or (AValue = nil) or (Index < 0) then
    Exit;

  if Index < Arr.Count then
    Exit(ReplaceArrayItem(Arr, Index, AValue));

  while Arr.Count < Index do
    Arr.AddElement(TJSONNull.Create);

  Arr.AddElement(AValue);
  Result := True;
end;

function EnsureObjectMemberArray(const Obj: TJSONObject; const Name: string; out Arr: TJSONArray): Boolean;
begin
  Result := False;
  Arr := nil;

  if (Obj = nil) or Name.IsEmpty then
    Exit;

  var Child := Obj.GetValue(Name);
  if Child = nil then
    begin
      Obj.AddPair(Name, TJSONArray.Create);
      Child := Obj.GetValue(Name);
    end
  else if Child is TJSONNull then
    begin
      var NewValue := TJSONArray.Create;
      if not ReplaceObjectMember(Obj, Name, NewValue) then
        begin
          NewValue.Free;
          Exit(False);
        end;
      Child := Obj.GetValue(Name);
    end;

  if not (Child is TJSONArray) then
    Exit(False);

  Arr := TJSONArray(Child);
  Result := True;
end;

function EnsureObjectMemberContainer(const Obj: TJSONObject; const Name: string; const WantArray: Boolean; out Container: TJSONValue): Boolean;
var
  NewValue: TJSONValue;
begin
  Result := False;
  Container := nil;

  if (Obj = nil) or Name.IsEmpty then
    Exit;

  var Child := Obj.GetValue(Name);
  if Child = nil then
    begin
      NewValue := CreateContainer(WantArray);
      Obj.AddPair(Name, NewValue);
      Child := Obj.GetValue(Name);
    end
  else if Child is TJSONNull then
    begin
      NewValue := CreateContainer(WantArray);
      if not ReplaceObjectMember(Obj, Name, NewValue) then
        begin
          NewValue.Free;
          Exit(False);
        end;
      Child := Obj.GetValue(Name);
    end;

  if not ContainerMatches(Child, WantArray) then
    Exit(False);

  Container := Child;
  Result := True;
end;

function EnsureArrayItemContainer(const Arr: TJSONArray; const Index: Integer; const WantArray: Boolean; out Container: TJSONValue): Boolean;
var
  Child: TJSONValue;
  NewValue: TJSONValue;
begin
  Result := False;
  Container := nil;

  if (Arr = nil) or (Index < 0) then
    Exit;

  if Index < Arr.Count then
    Child := Arr.Items[Index]
  else
    Child := nil;

  if Child = nil then
    begin
      NewValue := CreateContainer(WantArray);
      if not SetArrayItem(Arr, Index, NewValue) then
        begin
          NewValue.Free;
          Exit(False);
        end;
      Child := Arr.Items[Index];
    end
  else if Child is TJSONNull then
    begin
      NewValue := CreateContainer(WantArray);
      if not ReplaceArrayItem(Arr, Index, NewValue) then
        begin
          NewValue.Free;
          Exit(False);
        end;
      Child := Arr.Items[Index];
    end;

  if not ContainerMatches(Child, WantArray) then
    Exit(False);

  Container := Child;
  Result := True;
end;

function NavigateIntermediate(var Current: TJSONValue; const Token, NextToken: TJsonPathToken): Boolean;
var
  Child: TJSONValue;
  NewValue: TJSONValue;
begin
  Result := False;

  if Current = nil then
    Exit;

  if not Token.Name.IsEmpty then
    begin
      if not (Current is TJSONObject) then
        Exit;

      var Obj := TJSONObject(Current);
      Child := Obj.GetValue(Token.Name);

      if Token.HasIndex then
        begin
          if Child = nil then
            begin
              Obj.AddPair(Token.Name, TJSONArray.Create);
              Child := Obj.GetValue(Token.Name);
            end
          else if Child is TJSONNull then
            begin
              NewValue := TJSONArray.Create;
              if not ReplaceObjectMember(Obj, Token.Name, NewValue) then
              begin
                NewValue.Free;
                Exit(False);
              end;
              Child := Obj.GetValue(Token.Name);
            end;

          if not (Child is TJSONArray) then
            Exit(False);
        end
      else
        begin
          if Child = nil then
            begin
              Obj.AddPair(Token.Name, CreateContainerForNextToken(NextToken));
              Child := Obj.GetValue(Token.Name);
            end
          else if Child is TJSONNull then
            begin
              NewValue := CreateContainerForNextToken(NextToken);
              if not ReplaceObjectMember(Obj, Token.Name, NewValue) then
              begin
                NewValue.Free;
                Exit(False);
              end;
              Child := Obj.GetValue(Token.Name);
            end;

          if not ContainerMatches(Child, IsArrayExpectation(NextToken)) then
            Exit(False);
        end;

      Current := Child;
    end;

  if Token.HasIndex then
    begin
      if not (Current is TJSONArray) then
        Exit(False);

      var Arr := TJSONArray(Current);

      if not EnsureArrayItemContainer(Arr, Token.Index, IsArrayExpectation(NextToken), Child) then
        Exit(False);

      Current := Child;
    end;

  Result := True;
end;

function ResolveParentForPath(const RootValue: TJSONValue; const Path: string; out Parent: TJSONValue; out LastToken: TJsonPathToken): Boolean;
var
  Tokens: TArray<TJsonPathToken>;
begin
  Result := False;
  Parent := nil;
  LastToken.Name := '';
  LastToken.HasIndex := False;
  LastToken.Index := -1;

  if RootValue = nil then
    Exit;

  if not SplitPathStrict(Path, Tokens) then
    Exit;

  var Current := RootValue;

  if Length(Tokens) = 1 then
    begin
      Parent := Current;
      LastToken := Tokens[0];
      Exit(True);
    end;

  for var I := 0 to High(Tokens) - 1 do
    if not NavigateIntermediate(Current, Tokens[I], Tokens[I + 1]) then
      Exit(False);

  Parent := Current;
  LastToken := Tokens[High(Tokens)];
  Result := True;
end;

{ TJsonWriter.TJsonRootHolder }

constructor TJsonWriter.TJsonRootHolder.CreateOwned(ARoot: TJSONValue);
begin
  inherited Create;
  FRoot := ARoot;
end;

constructor TJsonWriter.TJsonRootHolder.CreateFromText(const JsonText: string);
begin
  inherited Create;
  FRoot := TJSONObject.ParseJSONValue(JsonText);
end;

destructor TJsonWriter.TJsonRootHolder.Destroy;
begin
  FRoot.Free;
  inherited;
end;

function TJsonWriter.TJsonRootHolder.Root: TJSONValue;
begin
  Result := FRoot;
end;

{ TJsonWriter }

class operator TJsonWriter.Initialize(out Dest: TJsonWriter);
begin
  Dest.FHolder := nil;
end;

class function TJsonWriter.Parse(const JsonText: string): TJsonWriter;
begin
  Result.FHolder := TJsonRootHolder.CreateFromText(JsonText);
end;

class function TJsonWriter.NewObject: TJsonWriter;
begin
  Result.FHolder := TJsonRootHolder.CreateOwned(TJSONObject.Create);
end;

class function TJsonWriter.NewArray: TJsonWriter;
begin
  Result.FHolder := TJsonRootHolder.CreateOwned(TJSONArray.Create);
end;

function TJsonWriter.Root: TJSONValue;
begin
  if FHolder = nil then
    Exit(nil);

  Result := FHolder.Root;
end;

function TJsonWriter.IsValid: Boolean;
begin
  Result := Root <> nil;
end;

function TJsonWriter.JSONObject: TJSONObject;
begin
  if Root is TJSONObject then
    Exit(TJSONObject(Root));

  Result := nil;
end;

function TJsonWriter.JSONArray: TJSONArray;
begin
  if Root is TJSONArray then
    Exit(TJSONArray(Root));

  Result := nil;
end;

function TJsonWriter.ToJson: string;
begin
  var R := Root;
  if R = nil then
    Exit('');

  Result := R.ToJSON;
end;

function TJsonWriter.Format(const Indent: Integer): string;
begin
  var R := Root;
  if R = nil then
    Exit('');

  Result := R.Format(Indent);
end;

function TJsonWriter.ResolveTerminalContainer(const Path: string; const WantArray: Boolean; out Container: TJSONValue): Boolean;
var
  Parent: TJSONValue;
  LastToken: TJsonPathToken;
  Arr: TJSONArray;
begin
  Result := False;
  Container := nil;

  var R := Root;
  if R = nil then
    Exit;

  if Path.IsEmpty then
    begin
      if ContainerMatches(R, WantArray) then
        begin
          Container := R;
          Exit(True);
        end;

      Exit(False);
    end;

  if not ResolveParentForPath(R, Path, Parent, LastToken) then
    Exit(False);

  if not LastToken.Name.IsEmpty then
    begin
      if not (Parent is TJSONObject) then
        Exit(False);

      var Obj := TJSONObject(Parent);

      if LastToken.HasIndex then
        begin
          if not EnsureObjectMemberArray(Obj, LastToken.Name, Arr) then
            Exit(False);

          Exit(EnsureArrayItemContainer(Arr, LastToken.Index, WantArray, Container));
        end;

      Exit(EnsureObjectMemberContainer(Obj, LastToken.Name, WantArray, Container));
    end;

  if not LastToken.HasIndex then
    Exit(False);

  if not (Parent is TJSONArray) then
    Exit(False);

  Arr := TJSONArray(Parent);
  Result := EnsureArrayItemContainer(Arr, LastToken.Index, WantArray, Container);
end;

function TJsonWriter.InternalSetValue(const Path: string; AValue: TJSONValue): Boolean;
var
  Parent: TJSONValue;
  LastToken: TJsonPathToken;
  Arr: TJSONArray;
begin
  if AValue = nil then
    Exit(False);

  if Path.IsEmpty then
    begin
      AValue.Free;
      Exit(False);
    end;

  var R := Root;
  if R = nil then
    begin
      AValue.Free;
      Exit(False);
    end;

  try
    if not ResolveParentForPath(R, Path, Parent, LastToken) then
      Exit(False);

    if not LastToken.Name.IsEmpty then
      begin
        if not (Parent is TJSONObject) then
          Exit(False);

        var Obj := TJSONObject(Parent);

        if LastToken.HasIndex then
          begin
            if not EnsureObjectMemberArray(Obj, LastToken.Name, Arr) then
              Exit(False);

            if not SetArrayItem(Arr, LastToken.Index, AValue) then
              Exit(False);

            AValue := nil;
            Exit(True);
          end;

        if not ReplaceObjectMember(Obj, LastToken.Name, AValue) then
          Exit(False);

        AValue := nil;
        Exit(True);
      end;

    if not LastToken.HasIndex then
      Exit(False);

    if not (Parent is TJSONArray) then
      Exit(False);

    Arr := TJSONArray(Parent);
    if not SetArrayItem(Arr, LastToken.Index, AValue) then
      Exit(False);

    AValue := nil;
    Result := True;
  finally
    AValue.Free;
  end;
end;

function TJsonWriter.InternalAppendValue(const ArrayPath: string; AValue: TJSONValue): Boolean;
var
  Target: TJSONValue;
begin
  if AValue = nil then
      Exit(False);

  if Root = nil then
    begin
      AValue.Free;
      Exit(False);
    end;

  try
    if not ResolveTerminalContainer(ArrayPath, True, Target) then
      Exit(False);

    TJSONArray(Target).AddElement(AValue);
    AValue := nil;
    Result := True;
  finally
    AValue.Free;
  end;
end;

function TJsonWriter.SetString(const Path, Value: string): Boolean;
begin
  Result := InternalSetValue(Path, TJSONString.Create(Value));
end;

function TJsonWriter.SetInteger(const Path: string; const Value: Int64): Boolean;
begin
  Result := InternalSetValue(Path, TJSONNumber.Create(IntToStr(Value)));
end;

function TJsonWriter.SetBoolean(const Path: string; const Value: Boolean): Boolean;
begin
  Result := InternalSetValue(Path, CreateJsonBoolean(Value));
end;

function TJsonWriter.SetDouble(const Path: string; const Value: Double): Boolean;
begin
  Result := InternalSetValue(Path, CreateJsonNumberFromDouble(Value));
end;

function TJsonWriter.SetNull(const Path: string): Boolean;
begin
  Result := InternalSetValue(Path, TJSONNull.Create);
end;

function TJsonWriter.SetJson(const Path, JsonText: string): Boolean;
begin
  var V := TJSONObject.ParseJSONValue(JsonText);
  if V = nil then
    Exit(False);

  Result := InternalSetValue(Path, V);
end;

function TJsonWriter.SetObjectJson(const Path, JsonText: string): Boolean;
begin
  var V := TJSONObject.ParseJSONValue(JsonText);
  if (V = nil) or not (V is TJSONObject) then
    begin
      V.Free;
      Exit(False);
    end;

  Result := InternalSetValue(Path, V);
end;

function TJsonWriter.SetArrayJson(const Path, JsonText: string): Boolean;
begin
  var V := TJSONObject.ParseJSONValue(JsonText);
  if (V = nil) or not (V is TJSONArray) then
    begin
      V.Free;
      Exit(False);
    end;

  Result := InternalSetValue(Path, V);
end;

function TJsonWriter.EnsureObject(const Path: string): Boolean;
var
  V: TJSONValue;
begin
  Result := ResolveTerminalContainer(Path, False, V);
end;

function TJsonWriter.EnsureArray(const Path: string): Boolean;
var
  V: TJSONValue;
begin
  Result := ResolveTerminalContainer(Path, True, V);
end;

function TJsonWriter.AppendString(const ArrayPath, Value: string): Boolean;
begin
  Result := InternalAppendValue(ArrayPath, TJSONString.Create(Value));
end;

function TJsonWriter.AppendInteger(const ArrayPath: string; const Value: Int64): Boolean;
begin
  Result := InternalAppendValue(ArrayPath, TJSONNumber.Create(IntToStr(Value)));
end;

function TJsonWriter.AppendBoolean(const ArrayPath: string; const Value: Boolean): Boolean;
begin
  Result := InternalAppendValue(ArrayPath, CreateJsonBoolean(Value));
end;

function TJsonWriter.AppendDouble(const ArrayPath: string; const Value: Double): Boolean;
begin
  Result := InternalAppendValue(ArrayPath, CreateJsonNumberFromDouble(Value));
end;

function TJsonWriter.AppendNull(const ArrayPath: string): Boolean;
begin
  Result := InternalAppendValue(ArrayPath, TJSONNull.Create);
end;

function TJsonWriter.AppendJson(const ArrayPath, JsonText: string): Boolean;
begin
  var V := TJSONObject.ParseJSONValue(JsonText);
  if V = nil then
    Exit(False);

  Result := InternalAppendValue(ArrayPath, V);
end;

function TJsonWriter.AppendObjectJson(const ArrayPath, JsonText: string): Boolean;
begin
  var V := TJSONObject.ParseJSONValue(JsonText);
  if (V = nil) or not (V is TJSONObject) then
    begin
      V.Free;
      Exit(False);
    end;

  Result := InternalAppendValue(ArrayPath, V);
end;

function TJsonWriter.AppendArrayJson(const ArrayPath, JsonText: string): Boolean;
var
  V: TJSONValue;
begin
  V := TJSONObject.ParseJSONValue(JsonText);
  if (V = nil) or not (V is TJSONArray) then
    begin
      V.Free;
      Exit(False);
    end;

  Result := InternalAppendValue(ArrayPath, V);
end;

function TJsonWriter.Remove(const Path: string): Boolean;
var
  Parent: TJSONValue;
  LastToken: TJsonPathToken;
  Arr: TJSONArray;
begin
  Result := False;

  if Path.IsEmpty then
    Exit;

  var R := Root;
  if R = nil then
    Exit;

  if not ResolveParentForPath(R, Path, Parent, LastToken) then
    Exit(False);

  if not LastToken.Name.IsEmpty then
    begin
      if not (Parent is TJSONObject) then
        Exit(False);

      var Obj := TJSONObject(Parent);

      if LastToken.HasIndex then
        begin
          var Child := Obj.GetValue(LastToken.Name);
          if (Child = nil) or not (Child is TJSONArray) then
            Exit(False);

          Arr := TJSONArray(Child);
          if (LastToken.Index < 0) or (LastToken.Index >= Arr.Count) then
            Exit(False);

          Arr.Remove(LastToken.Index).Free;
          Exit(True);
        end;

      var Pair := Obj.RemovePair(LastToken.Name);
      if Pair = nil then
        Exit(False);

      Pair.Free;
      Exit(True);
    end;

  if not LastToken.HasIndex then
    Exit(False);

  if not (Parent is TJSONArray) then
    Exit(False);

  Arr := TJSONArray(Parent);
  if (LastToken.Index < 0) or (LastToken.Index >= Arr.Count) then
    Exit(False);

  Arr.Remove(LastToken.Index).Free;
  Result := True;
end;

end.
