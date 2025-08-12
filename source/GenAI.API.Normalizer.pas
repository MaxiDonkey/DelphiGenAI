unit GenAI.API.Normalizer;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.JSON;

type
  /// <summary> Choosing the target container at wrap time. </summary>
  TWrapKind = (wkArray, wkObject);

  /// <summary> Rule = path + wrap. Used internally for multi-rule applique. </summary>
  TNormalizationRule = record
    Path: TArray<string>;
    Wrap: TWrapKind;
    class function Make(const APath: array of string; AWrap: TWrapKind): TNormalizationRule; static;
  end;

  /// <summary>
  /// Provides functionality to normalize specified JSON string fields into a standardized array-of-objects format
  /// or a single object format, according to provided paths and markers.
  /// </summary>
  TJSONNormalizer = record
  private
    {--- single-path normalization }
    class function DoNormalize(const Raw: string;
      const Path: TArray<string>; Wrap: TWrapKind): string; overload; static;

    {--- multi-rule normalization (multiple paths potentially with different wraps) }
    class function DoNormalize(const Raw: string;
      const Rules: TArray<TNormalizationRule>): string; overload; static;

    {--- recursive descent of a path }
    class function NormalizeNode(Node: TJSONValue;
      const Path: TArray<string>; Depth: Integer; Wrap: TWrapKind): Boolean; static;

    (*--- convert a path array to a rule array by reading the [] / {} marker *)
    class function BuildRulesFromPaths(const Paths: TArray<TArray<string>>): TArray<TNormalizationRule>; static;
  public
    /// <summary>
    /// Normalize: Entry point history: wrap in table by default.
    /// </summary>
    class function Normalize(const Raw: string;
      const Path: TArray<string>): string; overload; static;

    /// <summary>
    /// Normalize: Explicit wrap selection for a single path.
    /// </summary>
    class function Normalize(const Raw: string;
      const Path: TArray<string>; Wrap: TWrapKind): string; overload; static;

    /// <summary>
    /// Normalize: Multiple rules (path + wrap).
    /// </summary>
    class function Normalize(const Raw: string;
      const Rules: TArray<TNormalizationRule>): string; overload; static;

    /// <summary>
    /// Uses a marker in the last segment : "[]" (array), "{}" (object).
    /// Without marker ⇒ array (existing behavior).
    /// </summary>
    class function Normalize(const Raw: string;
      const Paths: TArray<TArray<string>>): string; overload; static;
  end;

implementation

{ TNormalizationRule }

class function TNormalizationRule.Make(const APath: array of string; AWrap: TWrapKind): TNormalizationRule;
begin
  SetLength(Result.Path, Length(APath));
  for var i := 0 to High(APath) do
    Result.Path[i] := APath[i];
  Result.Wrap := AWrap;
end;

{ TJSONNormalizer }

class function TJSONNormalizer.Normalize(const Raw: string;
  const Path: TArray<string>): string;
begin
  Result := DoNormalize(Raw, TArray<string>(Path), wkArray);
end;

class function TJSONNormalizer.Normalize(const Raw: string;
  const Path: TArray<string>; Wrap: TWrapKind): string;
begin
  Result := DoNormalize(Raw, TArray<string>(Path), Wrap);
end;

class function TJSONNormalizer.Normalize(const Raw: string;
  const Rules: TArray<TNormalizationRule>): string;
begin
  Result := DoNormalize(Raw, Rules);
end;

class function TJSONNormalizer.Normalize(const Raw: string;
  const Paths: TArray<TArray<string>>): string;
begin
  (* Adapter for calling "array of arrays" with markers [] / {} *)
  Result := DoNormalize(Raw, BuildRulesFromPaths(Paths));
end;

class function TJSONNormalizer.DoNormalize(const Raw: string;
  const Path: TArray<string>; Wrap: TWrapKind): string;
var
  Root: TJSONValue;
begin
  if Length(Path) = 0 then
    Exit(Raw);

  Root := TJSONObject.ParseJSONValue(Raw);
  if not Assigned(Root) then
    Exit(Raw);

  try
    if not NormalizeNode(Root, Path, 0, Wrap) then
      Exit(Raw);

    if Root is TJSONObject then
      Result := TJSONObject(Root).ToJSON
    else
      Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

class function TJSONNormalizer.DoNormalize(const Raw: string;
  const Rules: TArray<TNormalizationRule>): string;
var
  Root: TJSONValue;
  AnyChanged: Boolean;
begin
  if Length(Rules) = 0 then
    Exit(Raw);

  Root := TJSONObject.ParseJSONValue(Raw);
  if not Assigned(Root) then
    Exit(Raw);

  try
    AnyChanged := False;

    {--- We apply each rule on the same DOM }
    for var R in Rules do
      if (Length(R.Path) > 0) and NormalizeNode(Root, R.Path, 0, R.Wrap) then
        AnyChanged := True;

    if not AnyChanged then
      Exit(Raw);

    if Root is TJSONObject then
      Result := TJSONObject(Root).ToJSON
    else
      Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

class function TJSONNormalizer.NormalizeNode(Node: TJSONValue;
  const Path: TArray<string>; Depth: Integer; Wrap: TWrapKind): Boolean;
var
  Key     : string;
  NextVal : TJSONValue;
  JObj    : TJSONObject;
  JArr    : TJSONArray;
  S       : string;
  NewArr  : TJSONArray;
  NewObj  : TJSONObject;
  NewVal  : TJSONValue;
  OldPair : TJSONPair;
begin
  Result := False;

  if Depth >= Length(Path) then
    Exit;

  Key := Path[Depth];

  {--- Wildcard "*" -> we browse the current table }
  if Key = '*' then
    begin
      if not (Node is TJSONArray) then
        Exit;

      JArr := TJSONArray(Node);
      for var Item in JArr do
        if NormalizeNode(Item, Path, Depth + 1, Wrap) then
          Result := True;
      Exit;
    end;

  {--- Explicit key -> descent into the object }
  if not (Node is TJSONObject) then
    Exit;

  JObj := TJSONObject(Node);
  NextVal := JObj.GetValue(Key);
  if not Assigned(NextVal) then
    Exit;

  {--- Last link in the path: target field }
  if Depth = High(Path) then
    begin
      {--- No-op if already in good shape }
      if (Wrap = wkArray) and (NextVal is TJSONArray) then Exit;
      if (Wrap = wkObject) and (NextVal is TJSONObject) then Exit;

      if NextVal is TJSONNull then
        Exit;

      if not (NextVal is TJSONString) then
        raise Exception.CreateFmt(
          'TJSONNormalizer: "%s" is neither JSONString nor JSONArray/JSONObject (got %s)',
          [Key, NextVal.ClassName]);

      S := TJSONString(NextVal).Value;

      {--- Construction according to the requested wrap }
      if Wrap = wkArray then
        begin
          NewArr := TJSONArray.Create;
          NewArr.Add(
            TJSONObject.Create
              .AddPair('type', 'text')
              .AddPair('text', S)
          );
          NewVal := NewArr;
        end
      else
        begin
          NewObj := TJSONObject.Create
            .AddPair('type', 'text')
            .AddPair('text', S);
          NewVal := NewObj;
        end;

      OldPair := JObj.RemovePair(Key);
      OldPair.Free;
      JObj.AddPair(Key, NewVal);
      Result := True;
      Exit;
    end;

  {--- Otherwise we continue the descent }
  Result := NormalizeNode(NextVal, Path, Depth + 1, Wrap);
end;

class function TJSONNormalizer.BuildRulesFromPaths(
  const Paths: TArray<TArray<string>>): TArray<TNormalizationRule>;
var
  R: TNormalizationRule;
  P: TArray<string>;
  N: Integer;
  Wrap: TWrapKind;
begin
  SetLength(Result, Length(Paths));
  for var i := 0 to High(Paths) do
  begin
    P := Paths[i];
    Wrap := wkArray; // default = array behavior

    N := Length(P);
    if N > 0 then
      begin
        if P[N-1] = '{}' then
          begin
            Wrap := wkObject;
            SetLength(P, N-1); // remove the marker
          end
        else if P[N-1] = '[]' then
          begin
            Wrap := wkArray;
            SetLength(P, N-1); // remove the marker (optional, but clean)
          end;
      end;

    R.Path := P;
    R.Wrap := Wrap;
    Result[i] := R;
  end;
end;

end.

