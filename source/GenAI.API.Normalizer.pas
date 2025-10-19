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

  {$REGION 'Dev note'}

(*
    Usage Guide — GenAI.API.Normalizer

    Unit: GenAI.API.Normalizer
    Purpose: normalize text fields in a JSON (of type JSONString) into an array of objects
    or a single object of the form { "type": "text", "text": "…" }, according to one or more paths.


    1. TL;DR

    * Converts JSON strings into {type,text} (object or array of objects)
    * Targeted by paths (Path) + wrap type (wkArray, wkObject)
    * Markers at the end: [] for array, {} for object
    * Wildcard * to iterate over arrays
    * Multi-rule application on the same DOM


    2. API Overview

    TWrapKind = (wkArray, wkObject);

    TNormalizationRule = record
    Path: TArray<string>;
    Wrap: TWrapKind;
    class function Make(const APath: array of string; AWrap: TWrapKind): TNormalizationRule; static;
    end;

    Normalize entry points:
    Normalize(Raw, Path)                       (default: wkArray)
    Normalize(Raw, Path, Wrap)                 (explicit selection)
    Normalize(Raw, Rules)                      (multiple (path+wrap))
    Normalize(Raw, PathsWithMarkers)           (syntax using [] / {})


    3. Path Semantics

    * Each Path is an array of keys.
    * The last segment may be [] or {}.
    * No marker => default wkArray.
    * Wildcard * = iterate over array.

    Examples:
    ['choices','*','message','content']
    ['data','items','[]']
    ['payload','note','{}']


    4. Normalization Behavior

    * Already correct type => no-op.
    * Null => no-op.
    * JSONString => replaced by array or object depending on Wrap.
    * Other types => exception.
    * Missing path or invalid JSON => Raw returned unchanged.


    5. Examples

      5.1 Single path => array
    Raw = '{"message":{"content":"Hello"}}';
    Normalize(Raw, ['message','content']);
    -> {"message":{"content":[{"type":"text","text":"Hello"}]}}

      5.2 Single path => object
    Normalize(Raw, ['message','content'], wkObject);
    -> {"message":{"content":{"type":"text","text":"Hello"}}}

      5.3 Wildcard *
    Raw = '{"choices":[{"message":{"content":"A"}},{"message":{"content":"B"}}]}';
    Normalize(Raw, ['choices','*','message','content']);
    -> each content becomes an array of {type,text}

      5.4 Multi-rules
    Rules = [
    Make(['choices','*','message','content'], wkArray),
    Make(['usage','note'], wkObject)
    ];
    Normalize(Raw, Rules);

      5.5 Markers
    Normalize(Raw, [
    ['choices','*','message','content','[]'],
    ['usage','note','{}']
    ]);

      5.6 Missing key => no-op
      5.7 Already normalized => no-op
      5.8 null => no-op
      5.9 Unsupported type => exception


    6. Multi-rule Application

    * Rules are applied sequentially on the same DOM.
    * Order: from higher-level to deeper-level paths.


    7. Performance and Safety

    * O(n) on JSON size.
    * Thread-safe (no global state).
    * Proper cleanup via try/finally.


    8. Error Handling

    * Invalid JSON or missing path => Raw unchanged.
    * Unexpected type => explicit exception with key and class name.


    9. Best Practices

    * Unit-test your paths.
    * Prefer marker-based API for readability.
    * Compose multiple rules rather than ad-hoc code.
    * No implicit key creation.
    * Handle null explicitly if needed.


    10. FAQ

    * Multiple targets? Yes, via multi-rules.
    * Force array when it’s already an object? No-op.
    * Wildcard * on object? No, only on arrays.
    * Empty path? Raw unchanged.


    11. Full Example

    Before:
    {
    "choices":[{"message":{"content":"Hello"}}]
    }

    After:
    Normalize(Raw, ['choices','*','message','content']);
    {
    "choices":[{"message":{"content":[{"type":"text","text":"Hello"}]}}]
    }


    12. Limitations / Design

    * No creation of missing keys.
    * No object<->array conversion.
    * Only JSONString values are transformed.
    * Exception if unexpected type.


    13. Type-safe Tip
        Encapsulate paths:

    type

      TPath = record
        class function MsgContent: TArray<string>; static;
      end;

    class function TPath.MsgContent: TArray<string>;
    begin
      Result := ['choices','*','message','content'];
    end;

    out := TJSONNormalizer.Normalize(raw, TPath.MsgContent);


    14. Feature Coverage
        ✓ Multi-rules
        ✓ Wildcard *
        ✓ Markers [] / {}
        ✓ No-op on null or already normalized
        ✓ Exception on unexpected type

*)

  {$ENDREGION}

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

