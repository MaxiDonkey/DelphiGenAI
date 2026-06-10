unit Demo.OpenAI.JsonResponse.Helper;

interface
uses
  System.SysUtils, System.Classes, System.JSON,
  WVPythia.JSON.SafeReader;

type
  TOpenAIJsonResponseHelper = record
  private
    class procedure AppendNormalisedJson(
      const ABuilder: TStringBuilder;
      const AReader: TJsonReader); static;

  public
    class function NormalizeJsonResponse(
      const AJsonResponse: string): string; static;
  end;

implementation

{$REGION 'Dev note'}
(*

  Persisted JSON response normalization for the pythia-openai FMX demo.

  Streaming responses may be persisted as line-separated JSON fragments, and
  older traces can contain events split across line breaks. This helper
  rebuilds valid JSON objects incrementally, then emits one compact JSON event
  per line so reload/replay code can parse the history consistently.

  The parser is intentionally forgiving: empty leading lines are ignored, and
  incomplete fragments are buffered until they form valid JSON. The unit does
  not interpret Anthropic event semantics; it only normalizes the persisted
  text representation.

*)
{$ENDREGION}

{ TOpenAIJsonResponseHelper }

class procedure TOpenAIJsonResponseHelper.AppendNormalisedJson(
  const ABuilder: TStringBuilder;
  const AReader: TJsonReader);
begin
  var Json := AReader.ToJson.Trim;

  if Json.IsEmpty then
    Exit;

  if ABuilder.Length > 0 then
    ABuilder.Append(sLineBreak);

  ABuilder.Append(Json);
end;

class function TOpenAIJsonResponseHelper.NormalizeJsonResponse(
  const AJsonResponse: string): string;
begin
  Result := '';

  if AJsonResponse.Trim.IsEmpty then
    Exit;

  var Builder := TStringBuilder.Create;
  try
    var PendingJson := '';

    {--- TStateBuffer.AddJsonResponse separates streamed events with a single
         LF. Splitting on LF also handles the CRLF line breaks that may occur
         inside a formatted SDK JSON payload. }
    for var RawLine in AJsonResponse.Split([#10]) do
      begin
        if RawLine.Trim.IsEmpty and PendingJson.Trim.IsEmpty then
          Continue;

        var CandidateJson := '';

        if PendingJson.IsEmpty then
          CandidateJson := RawLine
        else
          CandidateJson := PendingJson + RawLine;

        var Reader := TJsonReader.Parse(CandidateJson);

        if Reader.IsValid then
          begin
            AppendNormalisedJson(
              Builder,
              Reader);

            PendingJson := '';
          end
        else
          PendingJson := CandidateJson;
      end;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

end.
