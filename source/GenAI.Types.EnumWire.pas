unit GenAI.Types.EnumWire;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.TypInfo, System.Rtti, System.Generics.Collections;

type
  WireString = UTF8String;

  EEnumWireError = class(Exception);

  EnumWireMapAttribute = class(TCustomAttribute)
  public
    Values: string;
    Separator: Char;
    constructor Create(const AValues: string); overload;
    constructor Create(const AValues: string; const ASeparator: Char); overload;
  end;

  TEnumWireAlias = record
  public
    AliasValue: string;
    WireValue: string;
    constructor Create(const AAliasValue, AWireValue: string);
  end;

  TEnumWire = record
  private type
    TMap = class
    public
      MinOrd: Integer;
      MaxOrd: Integer;
      WireByOrd: TArray<WireString>;
      WireToOrd: TDictionary<string, Integer>;
      procedure Add(Ordinal: Integer; const Wire: WireString; const TypeLabel: string);
      procedure AddAlias(const AliasValue, WireValue, TypeLabel: string);
      destructor Destroy; override;
    end;
  private
    class var Cache: TObjectDictionary<PTypeInfo, TMap>;
    class constructor Create;
    class destructor Destroy;

    class function AsciiLower(const Value: string): string; inline; static;

    class function TypeName(const Info: PTypeInfo): string; static;
    class procedure EnsureEnum(const Info: PTypeInfo); static;

    class function StripEscapePrefix(const Value: string): string; inline; static;
    class function KeyOf(const Value: string): string; static; inline;
    class function CanonicalEnumName(const Name: string): string; inline; static;

    class function TryGetEnumWireMap(const Info: PTypeInfo; out Values: string; out Separator: Char): Boolean; static;
    class function BuildMap(const Info: PTypeInfo): TMap; overload; static;
    class function BuildMap(const Info: PTypeInfo; const WireMap: array of string;
      const Aliases: array of TEnumWireAlias): TMap; overload; static;
    class function GetMap(const Info: PTypeInfo): TMap; static;
    class function OrdinalOf<T>(const Value: T): Integer; static;
  public
    class function TryParse<T>(const Wire: string; out TypeValue: T): Boolean; overload; static;
    class function TryParse<T>(const Wire: string; const WireMap: array of string; out TypeValue: T): Boolean; overload; static;
    class function TryParse<T>(const Wire: string; const WireMap: array of string;
      const Aliases: array of TEnumWireAlias; out TypeValue: T): Boolean; overload; static;

    class function TryToParse<T>(const Wire: string; out TypeValue: T): Boolean; overload; static;
    class function TryToParse<T>(const Wire: string; const WireMap: array of string; out TypeValue: T): Boolean; overload; static;
    class function TryToParse<T>(const Wire: string; const WireMap: array of string;
      const Aliases: array of TEnumWireAlias; out TypeValue: T): Boolean; overload; static;

    class function Parse<T>(const Wire: string): T; overload; static;
    class function Parse<T>(const Wire: string; const WireMap: array of string): T; overload; static;
    class function Parse<T>(const Wire: string; const WireMap: array of string;
      const Aliases: array of TEnumWireAlias): T; overload; static;

    class function ToString<T>(const Value: T): string; overload; static;
    class function ToString<T>(const Value: T; const WireMap: array of string): string; overload; static;
  end;

  TWire = record
  public
    class function FromUnicode(const S: string): WireString; inline; static;
    class function ToUnicode(const W: WireString): string; inline; static;
  end;


implementation

{ EnumWireMapAttribute }

constructor EnumWireMapAttribute.Create(const AValues: string);
begin
  inherited Create;
  Values := AValues;
  Separator := '|';
end;

constructor EnumWireMapAttribute.Create(const AValues: string; const ASeparator: Char);
begin
  inherited Create;
  Values := AValues;
  Separator := ASeparator;
end;

{ TEnumWireAlias }

constructor TEnumWireAlias.Create(const AAliasValue, AWireValue: string);
begin
  AliasValue := AAliasValue;
  WireValue := AWireValue;
end;

{ TEnumWire.TMap }

procedure TEnumWire.TMap.Add(Ordinal: Integer; const Wire: WireString; const TypeLabel: string);
begin
  var Index := Ordinal - MinOrd;
  WireByOrd[Index] := Wire;

  var Uc := TWire.ToUnicode(Wire);
  var Key := TEnumWire.KeyOf(Uc);
  if WireToOrd.ContainsKey(Key) then
    raise EEnumWireError.CreateFmt('Duplicate wire value "%s" in %s', [TWire.ToUnicode(Wire), TypeLabel]);

  WireToOrd.Add(Key, Ordinal);
end;

procedure TEnumWire.TMap.AddAlias(const AliasValue, WireValue, TypeLabel: string);
var
  AliasKey: string;
  OrdVal: Integer;
begin
  AliasKey := TEnumWire.KeyOf(AliasValue);
  if AliasKey.IsEmpty then
    raise EEnumWireError.CreateFmt('Empty enum wire alias in %s', [TypeLabel]);

  if WireToOrd.ContainsKey(AliasKey) then
    raise EEnumWireError.CreateFmt('Duplicate wire value "%s" in %s', [AliasValue, TypeLabel]);

  if not WireToOrd.TryGetValue(TEnumWire.KeyOf(WireValue), OrdVal) then
    raise EEnumWireError.CreateFmt('Unknown alias target "%s" in %s', [WireValue, TypeLabel]);

  WireToOrd.Add(AliasKey, OrdVal);
end;

destructor TEnumWire.TMap.Destroy;
begin
  WireToOrd.Free;
  inherited;
end;

{ TEnumWire }

class constructor TEnumWire.Create;
begin
  Cache := TObjectDictionary<PTypeInfo, TMap>.Create([doOwnsValues]);
end;

class destructor TEnumWire.Destroy;
begin
  Cache.Free;
end;

class function TEnumWire.AsciiLower(const Value: string): string;
var
  C: Char;
begin
  Result := Value;
  for var i := 1 to Length(Result) do
    begin
      C := Result[i];
      if (C >= 'A') and (C <= 'Z') then
        Result[i] := Char(Ord(C) + 32);
    end;
end;

class function TEnumWire.TypeName(const Info: PTypeInfo): string;
begin
  if Info = nil then
    Exit('<nil>');
  Result := string(Info^.Name);
end;

class procedure TEnumWire.EnsureEnum(const Info: PTypeInfo);
begin
  if (Info = nil) or (Info^.Kind <> tkEnumeration) then
    raise EEnumWireError.CreateFmt('Type %s is not an enumeration', [TypeName(Info)]);
end;

class function TEnumWire.StripEscapePrefix(const Value: string): string;
begin
  if Value.StartsWith('&') then
    Result := Value.Substring(1)
  else
    Result := Value;
end;

class function TEnumWire.KeyOf(const Value: string): string;
begin
  if Value.IsEmpty then
    Exit(EmptyStr);

  Result := AsciiLower(StripEscapePrefix(Value.Trim));
end;

class function TEnumWire.CanonicalEnumName(const Name: string): string;
begin
  Result := StripEscapePrefix(Name);
end;

class function TEnumWire.TryGetEnumWireMap(const Info: PTypeInfo; out Values: string;
  out Separator: Char): Boolean;
var
  RttiContext: TRttiContext;
begin
  Values := EmptyStr;
  Separator := '|';

  var RttiType := RttiContext.GetType(Info);
  if RttiType = nil then
    Exit(False);

  for var Attribute in RttiType.GetAttributes do
    if Attribute is EnumWireMapAttribute then
      begin
        Values := EnumWireMapAttribute(Attribute).Values;
        Separator := EnumWireMapAttribute(Attribute).Separator;
        Exit(True);
      end;

  Result := False;
end;

class function TEnumWire.BuildMap(const Info: PTypeInfo): TMap;
var
  Raw: string;
  Sep: Char;
begin
  EnsureEnum(Info);
  var Data := GetTypeData(Info);

  Result := TMap.Create;
  Result.MinOrd := Data^.MinValue;
  Result.MaxOrd := Data^.MaxValue;

  SetLength(Result.WireByOrd, Result.MaxOrd - Result.MinOrd + 1);
  Result.WireToOrd := TDictionary<string, Integer>.Create;

  var TypeLabel := TypeName(Info);

  if TryGetEnumWireMap(Info, Raw, Sep) then
    begin
      var Parts := Raw.Split([Sep]);

      if Length(Parts) <> Length(Result.WireByOrd) then
        raise EEnumWireError.CreateFmt(
          'Enum wire map count mismatch for %s (expected %d, got %d)',
          [TypeLabel, Length(Result.WireByOrd), Length(Parts)]);

      for var OrdVal := Result.MinOrd to Result.MaxOrd do
        begin
          var Index := OrdVal - Result.MinOrd;
          var Wire := TWire.FromUnicode(Parts[Index].Trim);
          Result.Add(OrdVal, Wire, TypeLabel);
        end;

      Exit;
    end;

  for var OrdVal := Result.MinOrd to Result.MaxOrd do
    begin
      var Wire := TWire.FromUnicode(CanonicalEnumName(GetEnumName(Info, OrdVal)));
      Result.Add(OrdVal, Wire, TypeLabel);
    end;
end;

class function TEnumWire.BuildMap(const Info: PTypeInfo; const WireMap: array of string;
  const Aliases: array of TEnumWireAlias): TMap;
begin
  EnsureEnum(Info);
  var Data := GetTypeData(Info);

  Result := TMap.Create;
  Result.MinOrd := Data^.MinValue;
  Result.MaxOrd := Data^.MaxValue;

  SetLength(Result.WireByOrd, Result.MaxOrd - Result.MinOrd + 1);
  Result.WireToOrd := TDictionary<string, Integer>.Create;

  var TypeLabel := TypeName(Info);

  if Length(WireMap) <> Length(Result.WireByOrd) then
    raise EEnumWireError.CreateFmt(
      'Enum wire map count mismatch for %s (expected %d, got %d)',
      [TypeLabel, Length(Result.WireByOrd), Length(WireMap)]);

  for var OrdVal := Result.MinOrd to Result.MaxOrd do
    begin
      var Index := OrdVal - Result.MinOrd;
      var Wire := TWire.FromUnicode(WireMap[Index].Trim);
      Result.Add(OrdVal, Wire, TypeLabel);
    end;

  for var Alias in Aliases do
    Result.AddAlias(Alias.AliasValue, Alias.WireValue, TypeLabel);
end;

class function TEnumWire.GetMap(const Info: PTypeInfo): TMap;
begin
  EnsureEnum(Info);

  TMonitor.Enter(Cache);
  try
    if not Cache.TryGetValue(Info, Result) then
      begin
        Result := BuildMap(Info);
        Cache.Add(Info, Result);
      end;
  finally
    TMonitor.Exit(Cache);
  end;
end;

class function TEnumWire.OrdinalOf<T>(const Value: T): Integer;
begin
  Result := TValue.From<T>(Value).AsOrdinal;
end;

class function TEnumWire.TryParse<T>(const Wire: string; out TypeValue: T): Boolean;
var
  Info: PTypeInfo;
  OrdVal: Integer;
begin
  if Wire.IsEmpty then
    Exit(False);

  Info := System.TypeInfo(T);
  EnsureEnum(Info);

  var Map := GetMap(Info);

  Result := Map.WireToOrd.TryGetValue(KeyOf(Wire), OrdVal);
  if Result then
    TypeValue := TValue.FromOrdinal(Info, OrdVal).AsType<T>;
end;

class function TEnumWire.TryParse<T>(const Wire: string; const WireMap: array of string;
  out TypeValue: T): Boolean;
begin
  Result := TryParse<T>(Wire, WireMap, [], TypeValue);
end;

class function TEnumWire.TryParse<T>(const Wire: string; const WireMap: array of string;
  const Aliases: array of TEnumWireAlias; out TypeValue: T): Boolean;
var
  Info: PTypeInfo;
  OrdVal: Integer;
begin
  if Wire.IsEmpty then
    Exit(False);

  Info := System.TypeInfo(T);
  var Map := BuildMap(Info, WireMap, Aliases);
  try
    Result := Map.WireToOrd.TryGetValue(KeyOf(Wire), OrdVal);
    if Result then
      TypeValue := TValue.FromOrdinal(Info, OrdVal).AsType<T>;
  finally
    Map.Free;
  end;
end;

class function TEnumWire.TryToParse<T>(const Wire: string; out TypeValue: T): Boolean;
begin
  Result := TryParse<T>(Wire, TypeValue);
end;

class function TEnumWire.TryToParse<T>(const Wire: string; const WireMap: array of string;
  out TypeValue: T): Boolean;
begin
  Result := TryParse<T>(Wire, WireMap, TypeValue);
end;

class function TEnumWire.TryToParse<T>(const Wire: string; const WireMap: array of string;
  const Aliases: array of TEnumWireAlias; out TypeValue: T): Boolean;
begin
  Result := TryParse<T>(Wire, WireMap, Aliases, TypeValue);
end;

class function TEnumWire.Parse<T>(const Wire: string): T;
begin
  if not TryParse<T>(Wire, Result) then
    raise EEnumWireError.CreateFmt(
      'Unknown enum wire value "%s" for %s',
      [Wire, TypeName(System.TypeInfo(T))]);
end;

class function TEnumWire.Parse<T>(const Wire: string; const WireMap: array of string): T;
begin
  Result := Parse<T>(Wire, WireMap, []);
end;

class function TEnumWire.Parse<T>(const Wire: string; const WireMap: array of string;
  const Aliases: array of TEnumWireAlias): T;
begin
  if not TryParse<T>(Wire, WireMap, Aliases, Result) then
    raise EEnumWireError.CreateFmt(
      'Unknown enum wire value "%s" for %s',
      [Wire, TypeName(System.TypeInfo(T))]);
end;

class function TEnumWire.ToString<T>(const Value: T): string;
var
  Info: PTypeInfo;
begin
  Info := System.TypeInfo(T);
  EnsureEnum(Info);

  var OrdVal := OrdinalOf<T>(Value);

  var Map := GetMap(Info);
  if (OrdVal < Map.MinOrd) or (OrdVal > Map.MaxOrd) then
    raise EEnumWireError.CreateFmt('Enum ordinal out of range for %s', [TypeName(Info)]);

  Result := TWire.ToUnicode(Map.WireByOrd[OrdVal - Map.MinOrd]);
end;

class function TEnumWire.ToString<T>(const Value: T; const WireMap: array of string): string;
var
  Info: PTypeInfo;
begin
  Info := System.TypeInfo(T);
  EnsureEnum(Info);
  var Data := GetTypeData(Info);

  if Length(WireMap) <> (Data^.MaxValue - Data^.MinValue + 1) then
    raise EEnumWireError.CreateFmt(
      'Enum wire map count mismatch for %s (expected %d, got %d)',
      [TypeName(Info), (Data^.MaxValue - Data^.MinValue + 1), Length(WireMap)]);

  var OrdVal := OrdinalOf<T>(Value);
  if (OrdVal < Data^.MinValue) or (OrdVal > Data^.MaxValue) then
    raise EEnumWireError.CreateFmt('Enum ordinal out of range for %s', [TypeName(Info)]);

  Result := WireMap[OrdVal - Data^.MinValue].Trim;
end;

{ TWire }

class function TWire.FromUnicode(const S: string): WireString;
begin
  Result := WireString(S);
end;

class function TWire.ToUnicode(const W: WireString): string;
begin
  Result := string(W);
end;

end.
