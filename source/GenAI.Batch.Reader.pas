unit GenAI.Batch.Reader;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.JSON, REST.Json.Types,
  REST.JsonReflect, GenAI.API, GenAI.Batch.Interfaces;

type
  /// <summary>
  /// Implements the <see cref="IJSONLReader{T}"/> interface for reading and deserializing
  /// JSONL (JSON Lines) input into a strongly typed array of batch output objects.
  /// </summary>
  /// <typeparam name="T">
  /// The type of the response body object to be deserialized. Must be a class with a parameterless constructor.
  /// </typeparam>
  TJSONLReader<T: class, constructor> = class(TInterfacedObject, IJSONLReader<T>)
  private
    FInput: string;
    function Input(const Value: string): TJSONLReader<T>;
    function Output: TArray<TBatchOutput<T>>;
  public
    /// <summary>
    /// Deserializes a JSONL-formatted string into an array of <typeparamref name="TBatchOutput{T}"/> objects.
    /// </summary>
    /// <param name="Value">
    /// The JSONL-formatted input string to be deserialized.
    /// </param>
    /// <returns>
    /// An array of deserialized <typeparamref name="TBatchOutput{T}"/> objects.
    /// </returns>
    function Deserialize(const Value: string): TArray<TBatchOutput<T>>;
    /// <summary>
    /// Creates an instance of the <see cref="TJSONLReader{T}"/> class.
    /// </summary>
    /// <returns>
    /// An instance of <see cref="IJSONLReader{T}"/> for processing JSONL input.
    /// </returns>
    class function CreateInstance: IJSONLReader<T>;
  end;

implementation

{ TJSONLReader }

class function TJSONLReader<T>.CreateInstance: IJSONLReader<T>;
begin
  Result := TJSONLReader<T>.Create;
end;

function TJSONLReader<T>.Deserialize(const Value: string): TArray<TBatchOutput<T>>;
begin
  Result := Input(Value).Output;
end;

function TJSONLReader<T>.Input(const Value: string): TJSONLReader<T>;
begin
  FInput := Value;
  Result := Self;
end;

function TJSONLReader<T>.Output: TArray<TBatchOutput<T>>;
var
  Line: string;
begin
  var FStringReader := TStringReader.Create(FInput);
  try
    repeat
      Line := FStringReader.ReadLine;
      if not Line.Trim.IsEmpty then
        begin
          Result := Result + [TApiDeserializer.Parse<TBatchOutput<T>>(Line)];
        end;
    until Line.Trim.IsEmpty;
  finally
    FStringReader.Free;
  end;
end;

end.
