unit GenAI.Batch.Writer;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, GenAI.Types;

type
  IBatchJSONBuilder = interface
    ['{35CDFC80-3BC4-4D3F-9908-6489493425B8}']
    function GenerateBatchString(const Value: string; const Url: TBatchUrl): string; overload;
    function GenerateBatchString(const Value: string; const Url: string): string; overload;
    function GenerateBatchString(const Value: TArray<string>; const Url: TBatchUrl): string; overload;
    function GenerateBatchString(const Value: TArray<string>; const Url: string): string; overload;
    function WriteBatchToFile(const Source, Destination: string; const Url: TBatchUrl): string; overload;
    function WriteBatchToFile(const Source, Destination: string; const Url: string): string; overload;
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: TBatchUrl): string; overload;
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: string): string; overload;
  end;

  TBatchJSONBuilder = class(TInterfacedObject, IBatchJSONBuilder)
  private
    function FormatBatchLine(Index: Integer; const AMethod, AUrl, ABody: string): string;
    function BuildBatchContent(const AMethod, AUrl, Value: string): string; overload;
    function BuildBatchContent(const AMethod, AUrl: string; const Value: TArray<string>): string; overload;
    function LoadRawContent(const FileName: string): string;
    function SaveToFile(const Content, Destination: string): string;
  public
    function GenerateBatchString(const Value: string; const Url: TBatchUrl): string; overload;
    function GenerateBatchString(const Value: string; const Url: string): string; overload;
    function GenerateBatchString(const Value: TArray<string>; const Url: TBatchUrl): string; overload;
    function GenerateBatchString(const Value: TArray<string>; const Url: string): string; overload;
    function WriteBatchToFile(const Source, Destination: string; const Url: TBatchUrl): string; overload;
    function WriteBatchToFile(const Source, Destination: string; const Url: string): string; overload;
    function WriteBatchToFile(const Value: TArray<string>; const Destination: string; const Url: TBatchUrl): string; overload;
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
