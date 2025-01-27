unit GenAI.Batch.Builder;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

--------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, GenAI.Types, GenAI.Batch.Interfaces;

type
  /// <summary>
  ///  The <c>TBatchJSONBuilder</c> class provides mechanisms to generate JSON-formatted
  ///  batch requests from either a single value, an array of values, or the contents
  ///  of a file. It also allows saving these batch requests to a specified file.
  /// </summary>
  /// <remarks>
  ///  <para>
  ///   This class implements <see cref="IBatchJSONBuilder"/> to offer various methods
  ///   for creating and writing JSON batch content. It is designed to streamline
  ///   batch request creation, especially in scenarios involving multiple requests
  ///   to the same endpoint.
  ///  </para>
  ///  <para>
  ///   Typical usage involves calling one of the <c>GenerateBatchString</c> methods
  ///   to produce a JSON string or one of the <c>WriteBatchToFile</c> methods to
  ///   save the resulting JSON directly to a file.
  ///  </para>
  /// </remarks>
  TBatchJSONBuilder = class(TInterfacedObject, IBatchJSONBuilder)
  private
    /// <summary>
    ///  Formats a single line of batch content, converting the specified parameters
    ///  into a JSON object with the fields <c>custom_id</c>, <c>method</c>,
    ///  <c>url</c>, and <c>body</c>.
    /// </summary>
    /// <param name="Index">
    ///  A sequential number indicating the request order.
    /// </param>
    /// <param name="AMethod">
    ///  The HTTP method to be used for the request (e.g., POST or GET).
    /// </param>
    /// <param name="AUrl">
    ///  The target endpoint URL for the request.
    /// </param>
    /// <param name="ABody">
    ///  The JSON content or payload for the request body.
    /// </param>
    /// <returns>
    ///  A string containing a single JSON object for a batch request.
    /// </returns>
    function FormatBatchLine(Index: Integer; const AMethod, AUrl, ABody: string): string;
    /// <summary>
    ///  Builds the complete JSON batch content by splitting a single multi-line string
    ///  into individual lines and converting each line into a batch request.
    /// </summary>
    /// <param name="AMethod">
    ///  The HTTP method to be used in the batch requests (e.g., POST).
    /// </param>
    /// <param name="AUrl">
    ///  The target endpoint URL for the requests.
    /// </param>
    /// <param name="Value">
    ///  A multi-line string where each line is treated as a separate request body.
    /// </param>
    /// <returns>
    ///  A JSON-formatted string containing one request entry per line.
    /// </returns>
    function BuildBatchContent(const AMethod, AUrl, Value: string): string; overload;
    /// <summary>
    ///  Builds the complete JSON batch content by iterating over an array of string values
    ///  and converting each element into a batch request.
    /// </summary>
    /// <param name="AMethod">
    ///  The HTTP method to be used in the batch requests (e.g., POST).
    /// </param>
    /// <param name="AUrl">
    ///  The target endpoint URL for the requests.
    /// </param>
    /// <param name="Value">
    ///  An array of strings, each of which will be treated as a separate request body.
    /// </param>
    /// <returns>
    ///  A JSON-formatted string containing one request entry per string in the array.
    /// </returns>
    function BuildBatchContent(const AMethod, AUrl: string; const Value: TArray<string>): string; overload;
    /// <summary>
    ///  Loads and returns the raw content of a text file in UTF-8 format.
    /// </summary>
    /// <param name="FileName">
    ///  The file path of the text file to be read.
    /// </param>
    /// <returns>
    ///  The UTF-8 content of the file as a string.
    /// </returns>
    /// <exception cref="Exception">
    ///  Raised if the specified file does not exist.
    /// </exception>
    function LoadRawContent(const FileName: string): string;
    /// <summary>
    ///  Saves a given string to a file in UTF-8 format, without including a BOM.
    /// </summary>
    /// <param name="Content">
    ///  The string data to be saved.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the data will be written.
    /// </param>
    /// <returns>
    ///  The same file path specified by <c>Destination</c>.
    /// </returns>
    function SaveToFile(const Content, Destination: string): string;
  public
    /// <summary>
    ///  Generates a JSON batch string by taking a single string value and converting
    ///  it into a batch request to the specified <see cref="TBatchUrl"/>.
    /// </summary>
    /// <param name="Value">
    ///  The string content to be converted into a JSON request body.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch request will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string that includes the request method ("POST"), the provided URL, and the content.
    /// </returns>
    function GenerateBatchString(const Value: string; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Generates a JSON batch string by taking a single string value and converting
    ///  it into a batch request to the specified URL string.
    /// </summary>
    /// <param name="Value">
    ///  The string content to be converted into a JSON request body.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch request will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string that includes the request method ("POST"), the provided URL, and the content.
    /// </returns>
    function GenerateBatchString(const Value: string; const Url: string): string; overload;
    /// <summary>
    ///  Generates a JSON batch string by taking an array of string values and converting
    ///  them into individual batch requests to the specified <see cref="TBatchUrl"/>.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string containing multiple request objects, each mapped to a single item in the array.
    /// </returns>
    function GenerateBatchString(const Value: TArray<string>; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Generates a JSON batch string by taking an array of string values and converting
    ///  them into individual batch requests to the specified URL string.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  A JSON string containing multiple request objects, each mapped to a single item in the array.
    /// </returns>
    function GenerateBatchString(const Value: TArray<string>; const Url: string): string; overload;
    /// <summary>
    ///  Reads the content from a specified source file, generates a JSON batch string,
    ///  and writes the output to a destination file. Each line in the source file
    ///  is treated as a separate request body.
    /// </summary>
    /// <param name="Source">
    ///  The file path of the source file that contains the input content.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Source, Destination: string; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Reads the content from a specified source file, generates a JSON batch string,
    ///  and writes the output to a destination file. Each line in the source file
    ///  is treated as a separate request body.
    /// </summary>
    /// <param name="Source">
    ///  The file path of the source file that contains the input content.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Source, Destination: string; const Url: string): string; overload;
    /// <summary>
    ///  Takes an array of string values, generates a JSON batch string by treating each
    ///  string as a separate request body, and saves the result to the specified
    ///  destination file.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The <see cref="TBatchUrl"/> object representing the destination URL where
    ///  the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
    /// </returns>
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: TBatchUrl): string; overload;
    /// <summary>
    ///  Takes an array of string values, generates a JSON batch string by treating each
    ///  string as a separate request body, and saves the result to the specified
    ///  destination file.
    /// </summary>
    /// <param name="Value">
    ///  An array of string values, each to be included as a separate item in the JSON batch.
    /// </param>
    /// <param name="Destination">
    ///  The file path where the generated JSON batch string will be saved.
    /// </param>
    /// <param name="Url">
    ///  The string containing the destination URL where the batch requests will be sent.
    /// </param>
    /// <returns>
    ///  The file path of the newly created batch file (identical to the <c>Destination</c>).
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
