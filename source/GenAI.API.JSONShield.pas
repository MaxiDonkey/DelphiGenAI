unit GenAI.API.JSONShield;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  GenAI.API.Consts;

type
  /// <summary>
  /// Provides a mechanism for preparing selected JSON fields before deserialization.
  /// Typically used when protected fields contain variable nested objects or arrays
  /// that must survive a first DTO mapping pass.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Implementations of this interface can adjust the JSON string prior to the deserialization
  /// process by shielding selected nested JSON payloads while leaving the rest of the
  /// response unchanged.
  /// </para>
  /// <para>
  /// For example, the implementation may detect fields listed in <c>PROTECTED_FIELD</c>
  /// and shield their nested object or array payload so the REST JSON layer can carry them
  /// as strings without corrupting embedded quotes or backslashes.
  /// </para>
  /// </remarks>
  ICustomFieldsPrepare = interface
    ['{E523EC7C-C180-4CBE-ADC0-BE82B751557F}']
    /// <summary>
    /// Prepares specified fields in the provided JSON string to ensure deserialization
    /// compatibility.
    /// </summary>
    /// <param name="Value">
    /// The raw JSON string containing fields that may require transformation.
    /// </param>
    /// <returns>
    /// A revised JSON string after applying the necessary field shielding.
    /// </returns>
    function Convert(const Value: string): string; overload;
  end;

  /// <summary>
  /// Implements the <c>ICustomFieldsPrepare</c> interface to shield selected JSON fields
  /// before deserialization. The class protects fields that may contain nested objects
  /// or arrays whose schema is resolved in a second pass.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This class is used to protect JSON fields listed in <c>PROTECTED_FIELD</c> when they
  /// contain nested objects or arrays that cannot be reliably bound to a fixed DTO during
  /// the first deserialization pass.
  /// </para>
  /// <para>
  /// <c>TDeserializationPrepare</c> scans the JSON payload, shields protected object or array
  /// values, and lets the REST layer temporarily treat them as strings. The original JSON shape
  /// can then be restored by <c>TJsonPolyUnshield</c> inside the corresponding interceptors.
  /// </para>
  /// </remarks>
  TDeserializationPrepare = class(TInterfacedObject, ICustomFieldsPrepare)
  public
    /// <summary>
    /// Scans and modifies the input JSON string to shield protected fields that contain
    /// nested objects or arrays.
    /// </summary>
    /// <param name="Value">
    /// The original JSON string needing transformation.
    /// </param>
    /// <returns>
    /// A revised JSON string after applying all necessary field modifications.
    /// </returns>
    /// <remarks>
    /// <para>
    /// The conversion logic is driven by <c>PROTECTED_FIELD</c>, which lists the OpenAI
    /// fields whose values may contain free-form nested JSON. Matching object and array
    /// values are shielded before the REST deserializer runs.
    /// </para>
    /// </remarks>
    function Convert(const Value: string): string;

    /// <summary>
    /// Factory method for creating an instance of the <c>TDeserializationPrepare</c> class.
    /// Returns an interface reference to <c>ICustomFieldsPrepare</c>.
    /// </summary>
    /// <returns>
    /// A newly constructed <c>TDeserializationPrepare</c> object as <c>ICustomFieldsPrepare</c>.
    /// </returns>
    /// <remarks>
    /// This method hides the constructor, enforcing interface-based usage.
    /// </remarks>
    class function CreateInstance: ICustomFieldsPrepare;
  end;

  /// <summary>
  /// Restores a shielded object or array payload to its original JSON form.
  /// </summary>
  /// <remarks>
  /// REST interceptors receive shielded payloads as strings. Use this helper in a
  /// string reverter to rebuild the original object or array JSON before assigning
  /// it back to the DTO member.
  /// </remarks>
  TJsonPolyUnshield = record
  public
    /// <summary>
    /// Converts a shielded string value back into JSON object or array text.
    /// </summary>
    /// <param name="Arg">
    /// The shielded string value produced by <c>TDeserializationPrepare.Convert</c>.
    /// </param>
    /// <returns>
    /// The restored JSON object or array text, or the original unshielded text when no
    /// shield marker is present.
    /// </returns>
    class function Restore(const Arg: string): string; static;
  end;

implementation

type
  TJsonPolyShield = record
  public
    const S_QUOTE = Char($E000);
    const S_BSLASH = Char($E001);
    const S_KIND_O = Char($E010);
    const S_KIND_A = Char($E011);

    class function Prepare(const Json: string; const Keys: array of string): string; static;
    class function Unshield(const Shielded: string): string; static;
  private
    class function ReadJsonString(const S: string; var I: Integer; out Text: string): Boolean; static;
    class procedure SkipSpaces(const S: string; var I: Integer); static;
    class function FindBlockEnd(const S: string; StartIdx: Integer): Integer; static;
    class function InSet(const Key: string; const SetKeys: TDictionary<string, Byte>): Boolean; static;
  end;

{ TJsonPolyShield }

class function TJsonPolyShield.InSet(const Key: string; const SetKeys: TDictionary<string, Byte>): Boolean;
begin
  Result := SetKeys.ContainsKey(Key);
end;

class procedure TJsonPolyShield.SkipSpaces(const S: string; var I: Integer);
begin
  while (I <= S.Length) and (S[I] <= ' ') do
    Inc(I);
end;

class function TJsonPolyShield.ReadJsonString(const S: string; var I: Integer; out Text: string): Boolean;
begin
  Result := False;
  Text := EmptyStr;

  if (I > S.Length) or (S[I] <> '"') then
    Exit;

  var StringBuilder := TStringBuilder.Create;
  try
    Inc(I);
    var Escaped := False;

    while I <= S.Length do
      begin
        if Escaped then
          begin
            StringBuilder.Append(S[I]);
            Escaped := False;
          end
        else
          begin
            if S[I] = '\' then
              Escaped := True
            else if S[I] = '"' then
              begin
                Inc(I);
                Text := StringBuilder.ToString;
                Exit(True);
              end
            else
              StringBuilder.Append(S[I]);
          end;
        Inc(I);
      end;

    Exit(False);
  finally
    StringBuilder.Free;
  end;
end;

class function TJsonPolyShield.FindBlockEnd(const S: string; StartIdx: Integer): Integer;
begin
  var Index := StartIdx;
  var InString := False;
  var Escaped := False;
  var BraceDepth := 0;
  var BracketDepth := 0;

  case S[Index] of
    '{': BraceDepth := 1;
    '[': BracketDepth := 1;
  else
    raise Exception.Create('StartIdx must point to { or [');
  end;

  Inc(Index);

  while Index <= S.Length do
    begin
      if InString then
        begin
          if Escaped then
            Escaped := False
          else
            begin
              if S[Index] = '\' then
                Escaped := True
              else if S[Index] = '"' then
                InString := False;
            end;
        end
      else
        begin
          case S[Index] of
            '"': InString := True;
            '{': Inc(BraceDepth);
            '}': Dec(BraceDepth);
            '[': Inc(BracketDepth);
            ']': Dec(BracketDepth);
          end;

          if (BraceDepth = 0) and (BracketDepth = 0) then
            Exit(Index);
        end;

      Inc(Index);
    end;

  raise Exception.Create('Invalid JSON string (unclosed block)');
end;

class function TJsonPolyShield.Prepare(const Json: string; const Keys: array of string): string;
var
  Dictionary: TDictionary<string, Byte>;
  Key: string;
  Kind: Char;
begin
  Dictionary := TDictionary<string, Byte>.Create;
  try
    for var Item in Keys do
      if not Item.IsEmpty then
        Dictionary.AddOrSetValue(Item, 0);

    var StringBuilder := TStringBuilder.Create(Json.Length + 64);
    try
      var I := 1;
      var N := Json.Length;

      while I <= N do
        begin
          if Json[I] <> '"' then
            begin
              StringBuilder.Append(Json[I]);
              Inc(I);
              Continue;
            end;

          var KeyStart := I;
          var AfterKey := I;
          if not ReadJsonString(Json, AfterKey, Key) then
            begin
              StringBuilder.Append(Copy(Json, I, N - I + 1));
              Break;
            end;

          var J := AfterKey;
          SkipSpaces(Json, J);

          if (J <= N) and (Json[J] = ':') and InSet(Key, Dictionary) then
            begin
              Inc(J);
              SkipSpaces(Json, J);

              if (J <= N) and CharInSet(Json[J], ['{', '[']) then
                begin
                  StringBuilder.Append(Copy(Json, KeyStart, J - KeyStart));

                  if Json[J] = '{' then
                    Kind := S_KIND_O
                  else
                    Kind := S_KIND_A;

                  var BlockEnd := FindBlockEnd(Json, J);

                  StringBuilder.Append('"');
                  StringBuilder.Append(Kind);

                  for var P := J + 1 to BlockEnd - 1 do
                    begin
                      case Json[P] of
                        '"': StringBuilder.Append(S_QUOTE);
                        '\': StringBuilder.Append(S_BSLASH);
                      else
                        StringBuilder.Append(Json[P]);
                      end;
                    end;

                  StringBuilder.Append('"');

                  I := BlockEnd + 1;
                  Continue;
                end;
            end;

          StringBuilder.Append(Copy(Json, KeyStart, AfterKey - KeyStart));
          I := AfterKey;
        end;

      Result := StringBuilder.ToString;
    finally
      StringBuilder.Free;
    end;
  finally
    Dictionary.Free;
  end;
end;

class function TJsonPolyShield.Unshield(const Shielded: string): string;
begin
  Result := Shielded
    .Replace(string(S_QUOTE), '"')
    .Replace(string(S_BSLASH), '\');
end;

{ TJsonPolyUnshield }

class function TJsonPolyUnshield.Restore(const Arg: string): string;
var
  Kind: Char;
begin
  var Buffer := Arg.Replace(#10, '').Trim;
  Buffer := TJsonPolyShield.Unshield(Buffer);

  while Buffer.Contains(', ') do
    Buffer := Buffer.Replace(', ', ',');

  if not Buffer.IsEmpty and ((Buffer[1] = TJsonPolyShield.S_KIND_O) or (Buffer[1] = TJsonPolyShield.S_KIND_A)) then
    begin
      Kind := Buffer[1];
      Delete(Buffer, 1, 1);
    end
  else
    Exit(Buffer);

  if Kind = TJsonPolyShield.S_KIND_A then
    Result := Format('[%s]', [Buffer])
  else
    Result := Format('{%s}', [Buffer]);

  Result := Result.Replace(',', ', ');
end;

{ TDeserializationPrepare }

class function TDeserializationPrepare.CreateInstance: ICustomFieldsPrepare;
begin
  Result := TDeserializationPrepare.Create;
end;

function TDeserializationPrepare.Convert(const Value: string): string;
begin
  Result := TJsonPolyShield.Prepare(Value, PROTECTED_FIELD);
end;

end.
