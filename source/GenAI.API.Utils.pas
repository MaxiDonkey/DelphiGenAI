unit GenAI.API.Utils;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils;

const
  FIELDSASSTRING : TArray<string> = [
    '"metadata": {', '"metadata":{', '"response_format": {', '"response_format":{',
    '"parameters": {', '"parameters":{'
  ];

(*
   --- NOTE ---
    Each entry in this array corresponds to a  JSON field that is temporarily
    treated as  a string  during  parsing. In order  for these  fields  to be
    correctly restored as JSON objects upon re-marshalling, each unique field
    listed here must have a dedicated interceptor  that transforms the string
    back into a well-formed JSON object.

    Example: TMetadataInterceptor

      procedure TMetadataInterceptor.StringReverter(Data: TObject; Field,
        Arg: string);
      begin
        Arg := Format('{%s}', [Trim(Arg.Replace('`', '"').Replace(#10, ''))]);
        while Arg.Contains(', ') do Arg := Arg.Replace(', ', ',');
        RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, Arg.Replace(',', ', '));
      end;
*)

type
  /// <summary>
  /// Provides a mechanism for converting or transforming specific JSON fields in a string
  /// before deserialization. Typically used to handle scenarios where certain fields
  /// contain complex or nested structures that need to be converted into valid JSON.
  /// </summary>
  /// <remarks>
  /// <para>
  /// Implementations of this interface can adjust the JSON string prior to the deserialization
  /// process to address inconsistencies, remove or replace invalid characters, or convert
  /// problematic JSON fields into formats that a JSON deserializer can handle properly.
  /// </para>
  /// <para>
  /// For example, the implementation may detect fields named "metadata" and convert their
  /// content from a raw, non-standard structure into a valid JSON string by replacing certain
  /// delimiters or escape characters.
  /// </para>
  /// </remarks>
  ICustomFieldsPrepare = interface
    ['{60B0EAB1-3C74-4ACE-8B33-6DA2B40485F9}']
    /// <summary>
    /// Converts or transforms specified fields in the provided JSON string to ensure
    /// deserialization compatibility.
    /// </summary>
    /// <param name="Value">
    /// The raw JSON string containing fields that may require transformation.
    /// </param>
    /// <returns>
    /// A revised JSON string after applying the necessary field conversions or
    /// transformations.
    /// </returns>
    function Convert(const Value: string): string; overload;
  end;

  /// <summary>
  /// Implements the <c>ICustomFieldsPrepare</c> interface to transform specific JSON fields
  /// before deserialization. The class applies rules for handling particular fields that may
  /// contain nested objects or invalid characters, ensuring the resulting JSON is valid and
  /// ready for further processing.
  /// </summary>
  /// <remarks>
  /// <para>
  /// This class is most commonly used to modify JSON fields such as "metadata" that might
  /// otherwise cause errors during deserialization. It replaces problematic delimiters and
  /// characters (like quotation marks or braces) within specified field blocks, enabling
  /// compliant JSON output.
  /// </para>
  /// <para>
  /// <c>TDeserializationPrepare</c> scans the JSON string for patterns and adjusts the content
  /// accordingly, preventing typical parsing exceptions arising from malformed or unexpected
  /// inline structures.
  /// </para>
  /// </remarks>
  TDeserializationPrepare = class(TInterfacedObject, ICustomFieldsPrepare)
  private
    /// <summary>
    /// Searches for a single specified field in the JSON string and updates its content
    /// to ensure valid JSON syntax. Replaces certain delimiters and characters inside
    /// the field's scope with safe alternatives.
    /// </summary>
    /// <param name="Value">
    /// The entire JSON string being scanned.
    /// </param>
    /// <param name="Field">
    /// The name of the field whose content needs to be transformed.
    /// </param>
    /// <returns>
    /// A modified JSON string with the specified field's content replaced as necessary.
    /// </returns>
    /// <remarks>
    /// <para>
    /// This overload specifically handles updating a single <c>Field</c>. If multiple fields
    /// need to be processed, consider using the array overload of this method.
    /// </para>
    /// </remarks>
    function UpdateFieldValue(const Value, Field: string): string; overload;
    /// <summary>
    /// Scans the JSON string for multiple specified fields and updates each of their
    /// contents to ensure valid JSON syntax. Replaces certain delimiters and characters
    /// inside the scope of these fields with safe alternatives.
    /// </summary>
    /// <param name="Value">
    /// The entire JSON string being scanned.
    /// </param>
    /// <param name="Field">
    /// An array of field names whose content must be transformed.
    /// </param>
    /// <returns>
    /// A modified JSON string with each listed field’s content replaced as necessary.
    /// </returns>
    /// <remarks>
    /// <para>
    /// This overload iterates through each field name in <c>Field</c> and applies the
    /// transformations one by one. If you need to handle only a single field, use the
    /// other <c>UpdateFieldValue</c> method.
    /// </para>
    /// </remarks>
    function UpdateFieldValue(const Value: string; const Field: TArray<string>): string; overload;
  public
    /// <summary>
    /// Scans and modifies the input JSON string to replace fields that contain nested
    /// objects or invalid characters, ensuring the JSON is suitable for deserialization.
    /// </summary>
    /// <param name="Value">
    /// The original JSON string needing transformation.
    /// </param>
    /// <returns>
    /// A revised JSON string after applying all necessary field modifications.
    /// </returns>
    /// <remarks>
    /// <para>
    /// The conversion logic is determined by which fields or patterns are defined
    /// within the implementation. Currently, the class targets fields labeled
    /// <c>"metadata"</c>, converting them from non-standard structures into proper
    /// JSON-friendly strings.
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

implementation

{ TDeserializationPrepare }

function TDeserializationPrepare.UpdateFieldValue(const Value,
  Field: string): string;
begin
  Result := Value;
  var i := Pos(Field, Result);
  while (i > 0) and (i < Result.Length) do
    begin
      i := i + Field.Length - 1;
      Result[i] := '"';
      Inc(i);
      var j := 0;
      while (j > 0) or ((j = 0) and not (Result[i] = '}')) do
        begin
          case Result[i] of
            '{':
              Inc(j);
            '}':
              j := j - 1;
            '"':
              Result[i] := '`';
          end;
          Inc(i);
          if i > Result.Length then
            raise Exception.Create('Invalid JSON string');
        end;
      Result[i] := '"';
      i := Pos(Field, Result);
    end;
end;

class function TDeserializationPrepare.CreateInstance: ICustomFieldsPrepare;
begin
  Result := TDeserializationPrepare.Create;
end;

function TDeserializationPrepare.Convert(const Value: string): string;
begin
  Result := UpdateFieldValue(Value, FIELDSASSTRING);
end;

function TDeserializationPrepare.UpdateFieldValue(const Value: string;
  const Field: TArray<string>): string;
begin
  Result := Value;
  if Length(Field) > 0 then
    begin
      for var Item in Field do
        Result := UpdateFieldValue(Result, Item);
    end;
end;

end.
