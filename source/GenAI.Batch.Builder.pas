unit GenAI.Batch.Builder;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

--------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  GenAI.Types, GenAI.Batch.Interfaces;

type
  TBatchJSONBuilder = class(TInterfacedObject, IBatchJSONBuilder)
  private
    function FormatBatchLine(Index: Integer; const AMethod, AUrl, ABody: string): string;
    function BuildBatchContent(const AMethod, AUrl, Value: string): string; overload;
    function BuildBatchContent(const AMethod, AUrl: string; const Value: TArray<string>): string; overload;
    function LoadRawContent(const FileName: string): string;
    function SaveToFile(const Content, Destination: string): string;
  public
    /// <summary>
    /// Generates a JSON batch string by taking a single string value and converting
    /// it into a batch request to the specified <see cref="TBatchUrl"/>.
    /// </summary>
    /// <param name="Value">
    /// The string content to be converted into a JSON request body.
    /// </param>
    /// <param name="Url">
    /// The <see cref="TBatchUrl"/> object representing the destination URL where
    /// the batch request will be sent.
    /// </param>
    /// <returns>
    /// A JSON string that includes the request method ("POST"), the provided URL, and the content.
    /// </returns>
    function GenerateBatchString(const Value: string; const Url: TBatchUrl): string; overload;

    /// <summary>
    /// Generates a JSON batch string by taking a single string value and converting
    /// it into a batch request to the specified URL string.
    /// </summary>
    /// <param name="Value">
    /// The string content to be converted into a JSON request body.
    /// </param>
    /// <param name="Url">
    /// The string containing the destination URL where the batch request will be sent.
    /// </param>
    /// <returns>
    /// A JSON string that includes the request method ("POST"), the provided URL, and the content.
    /// </returns>
    function GenerateBatchString(const Value: string; const Url: string): string; overload;

    /// <summary>
    /// Generates a JSON batch string by taking an array of string values and converting
    /// them into individual batch requests to the specified <see cref="TBatchUrl"/>.
    /// </summary>
    /// <param name="Value">
    /// An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Url">
    /// The <see cref="TBatchUrl"/> object representing the destination URL where
    /// the batch requests will be sent.
    /// </param>
    /// <returns>
    /// A JSON string containing multiple request objects, each mapped to a single item in the array.
    /// </returns>
    function GenerateBatchString(const Value: TArray<string>; const Url: TBatchUrl): string; overload;

    /// <summary>
    /// Generates a JSON batch string by taking an array of string values and converting
    /// them into individual batch requests to the specified URL string.
    /// </summary>
    /// <param name="Value">
    /// An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Url">
    /// The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    /// A JSON string containing multiple request objects, each mapped to a single item in the array.
    /// </returns>
    function GenerateBatchString(const Value: TArray<string>; const Url: string): string; overload;

    /// <summary>
    /// Reads the content from a specified source file, generates a JSON batch string,
    /// and writes the output to a destination file. Each line in the source file
    /// is treated as a separate request body.
    /// </summary>
    /// <param name="Source">
    /// The file path of the source file that contains the input content.
    /// </param>
    /// <param name="Destination">
    /// The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    /// The <see cref="TBatchUrl"/> object representing the destination URL where
    /// the batch requests will be sent.
    /// </param>
    /// <returns>
    /// The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Source, Destination: string; const Url: TBatchUrl): string; overload;

    /// <summary>
    /// Reads the content from a specified source file, generates a JSON batch string,
    /// and writes the output to a destination file. Each line in the source file
    /// is treated as a separate request body.
    /// </summary>
    /// <param name="Source">
    /// The file path of the source file that contains the input content.
    /// </param>
    /// <param name="Destination">
    /// The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    /// The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    /// The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Source, Destination: string; const Url: string): string; overload;

    /// <summary>
    /// Takes an array of string values, generates a JSON batch string by treating each
    /// string as a separate request body, and saves the result to the specified
    /// destination file.
    /// </summary>
    /// <param name="Value">
    /// An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Destination">
    /// The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    /// The <see cref="TBatchUrl"/> object representing the destination URL where
    /// the batch requests will be sent.
    /// </param>
    /// <returns>
    /// The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: TBatchUrl): string; overload;

    /// <summary>
    /// Takes an array of string values, generates a JSON batch string by treating each
    /// string as a separate request body, and saves the result to the specified
    /// destination file.
    /// </summary>
    /// <param name="Value">
    /// An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Destination">
    /// The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    /// The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    /// The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: string): string; overload;
  end;

implementation

{ TBatchJSONBuilder }

function TBatchJSONBuilder.BuildBatchContent(const AMethod, AUrl, Value: string): string;
var
  Line: string;
begin
  var StringReader := TStringReader.Create(Value);
  var BatchBuilder := TStringBuilder.Create;
  try
    var index := 1;
    Line := StringReader.ReadLine;
    while not Line.Trim.IsEmpty do
      begin
        BatchBuilder.AppendLine(FormatBatchLine(index, AMethod, AUrl, Line));
        Inc(index);
        Line := StringReader.ReadLine;
      end;
    Result := BatchBuilder.ToString;
  finally
    StringReader.Free;
    BatchBuilder.Free;
  end;
end;

function TBatchJSONBuilder.BuildBatchContent(const AMethod, AUrl: string;
  const Value: TArray<string>): string;
begin
  Result := EmptyStr;
  var index := 1;
  var BatchBuilder := TStringBuilder.Create;
  try
    for var Line in Value do
      begin
        BatchBuilder.AppendLine(FormatBatchLine(Index, AMethod, AUrl, Line));
        Inc(Index);
      end;
    Result := BatchBuilder.ToString;
  finally
    BatchBuilder.Free;
  end;
end;

function TBatchJSONBuilder.FormatBatchLine(Index: Integer; const AMethod, AUrl,
  ABody: string): string;
begin
  Result := Format('{"custom_id": "request-%d", "method": "%s", "url": "%s", "body": %s}', [Index, AMethod, AUrl, ABody]);
end;

function TBatchJSONBuilder.WriteBatchToFile(const Source, Destination: string; const Url: TBatchUrl): string;
begin
  Result := GenerateBatchString(LoadRawContent(Source), Url );
  SaveToFile(Result, Destination);
end;

function TBatchJSONBuilder.GenerateBatchString(const Value: string;
  const Url: TBatchUrl): string;
begin
  Result := BuildBatchContent('POST', Url.ToString, Value);
end;

function TBatchJSONBuilder.GenerateBatchString(const Value,
  Url: string): string;
begin
  Result := GenerateBatchString(Value, TBatchUrl.Create(Url));
end;

function TBatchJSONBuilder.LoadRawContent(const FileName: string): string;
begin
  if not TFile.Exists(FileName) then
    raise Exception.CreateFmt('%s: File not found', [FileName]);

  var FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    var StringStream := TStringStream.Create('', TEncoding.UTF8);
    try
      StringStream.LoadFromStream(FileStream);
      Result := StringStream.DataString;
    finally
      StringStream.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

function TBatchJSONBuilder.SaveToFile(const Content,
  Destination: string): string;
begin
  {--- Generating a UTF-8 file without a BOM (Byte Order Mark) }
  var FileStream := TFileStream.Create(Destination, fmCreate);
  try
    var StringStream := TStringStream.Create(Content, TEncoding.UTF8);
    try
      StringStream.SaveToStream(FileStream);
    finally
      StringStream.Free;
    end;
  finally
    FileStream.Free;
  end;
  Result := Destination;
end;

function TBatchJSONBuilder.WriteBatchToFile(const Value: TArray<string>;
  const Destination, Url: string): string;
begin
  Result := WriteBatchToFile(Value, Destination, TBatchUrl.Create(Url));
end;

function TBatchJSONBuilder.WriteBatchToFile(const Value: TArray<string>;
  const Destination: string; const Url: TBatchUrl): string;
begin
  Result := GenerateBatchString(Value, Url);
  SaveToFile(Result, Destination);
end;

function TBatchJSONBuilder.WriteBatchToFile(const Source, Destination,
  Url: string): string;
begin
  Result := WriteBatchToFile(Source, Destination, TBatchUrl.Create(Url));
end;

function TBatchJSONBuilder.GenerateBatchString(const Value: TArray<string>;
  const Url: TBatchUrl): string;
begin
  Result := BuildBatchContent('POST', Url.ToString, Value);
end;

function TBatchJSONBuilder.GenerateBatchString(const Value: TArray<string>;
  const Url: string): string;
begin
  Result := GenerateBatchString(Value, TBatchUrl.Create(Url));
end;

end.
