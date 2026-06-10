unit GenAI.Audio.Stream;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  GenAI.API.Params, GenAI.API.JsonSafeReader, GenAI.Async.Support;

type
  TSpeechStreamChunk = class
  private
    FBytes: TBytes;
    FText: string;
    FEventName: string;
    FIsSSE: Boolean;
  public
    constructor Create(const ABytes: TBytes); overload;
    constructor Create(const AEventName, AData: string); overload;

    function GetStream: TStream;

    property Bytes: TBytes read FBytes write FBytes;
    property Text: string read FText write FText;
    property EventName: string read FEventName write FEventName;
    property IsSSE: Boolean read FIsSSE write FIsSSE;
  end;

  TSpeechStreamResult = record
  private
    FBytes: TBytes;
    FText: string;
  public
    class function Empty: TSpeechStreamResult; static;

    procedure Aggregate(const Chunk: TSpeechStreamChunk);
    function GetStream: TStream;

    property Bytes: TBytes read FBytes write FBytes;
    property Text: string read FText write FText;
  end;

  TTranscriptionStreamLogprob = record
  private
    FToken: string;
    FBytes: TArray<Integer>;
    FLogprob: Double;
  public
    property Token: string read FToken write FToken;
    property Bytes: TArray<Integer> read FBytes write FBytes;
    property Logprob: Double read FLogprob write FLogprob;
  end;

  TTranscriptionStreamInputTokenDetails = record
  private
    FAudioTokens: Int64;
    FTextTokens: Int64;
  public
    property AudioTokens: Int64 read FAudioTokens write FAudioTokens;
    property TextTokens: Int64 read FTextTokens write FTextTokens;
  end;

  TTranscriptionStreamUsage = record
  private
    FType: string;
    FInputTokens: Int64;
    FOutputTokens: Int64;
    FTotalTokens: Int64;
    FSeconds: Double;
    FInputTokenDetails: TTranscriptionStreamInputTokenDetails;
    FHasInputTokenDetails: Boolean;
  public
    property &Type: string read FType write FType;
    property InputTokens: Int64 read FInputTokens write FInputTokens;
    property OutputTokens: Int64 read FOutputTokens write FOutputTokens;
    property TotalTokens: Int64 read FTotalTokens write FTotalTokens;
    property Seconds: Double read FSeconds write FSeconds;
    property InputTokenDetails: TTranscriptionStreamInputTokenDetails read FInputTokenDetails write FInputTokenDetails;
    property HasInputTokenDetails: Boolean read FHasInputTokenDetails write FHasInputTokenDetails;
  end;

  TTranscriptionStreamSegment = record
  private
    FId: string;
    FStart: Double;
    FEnd: Double;
    FSpeaker: string;
    FText: string;
    FType: string;
  public
    property Id: string read FId write FId;
    property Start: Double read FStart write FStart;
    property &End: Double read FEnd write FEnd;
    property Speaker: string read FSpeaker write FSpeaker;
    property Text: string read FText write FText;
    property &Type: string read FType write FType;
  end;

  TTranscriptionStream = class(TJSONFingerprint)
  private
    FType: string;
    FDelta: string;
    FText: string;
    FSegmentId: string;
    FId: string;
    FStart: Double;
    FEnd: Double;
    FSpeaker: string;
    FLogprobs: TArray<TTranscriptionStreamLogprob>;
    FUsage: TTranscriptionStreamUsage;
    FCode: string;
    FMessage: string;
  protected
    procedure ContentUpdate; override;
    procedure AfterDeserialize; override;
  public
    function IsDelta: Boolean;
    function IsDone: Boolean;
    function IsSegment: Boolean;
    function IsError: Boolean;

    property &Type: string read FType write FType;
    property Delta: string read FDelta write FDelta;
    property Text: string read FText write FText;
    property SegmentId: string read FSegmentId write FSegmentId;
    property Id: string read FId write FId;
    property Start: Double read FStart write FStart;
    property &End: Double read FEnd write FEnd;
    property Speaker: string read FSpeaker write FSpeaker;
    property Logprobs: TArray<TTranscriptionStreamLogprob> read FLogprobs write FLogprobs;
    property Usage: TTranscriptionStreamUsage read FUsage write FUsage;
    property Code: string read FCode write FCode;
    property Message: string read FMessage write FMessage;
  end;

  TTranscriptionStreamResult = record
  private
    FText: string;
    FLogprobs: TArray<TTranscriptionStreamLogprob>;
    FUsage: TTranscriptionStreamUsage;
    FSegments: TArray<TTranscriptionStreamSegment>;
    FLastEventType: string;
  public
    class function Empty: TTranscriptionStreamResult; static;

    procedure Aggregate(const Event: TTranscriptionStream);

    property Text: string read FText write FText;
    property Logprobs: TArray<TTranscriptionStreamLogprob> read FLogprobs write FLogprobs;
    property Usage: TTranscriptionStreamUsage read FUsage write FUsage;
    property Segments: TArray<TTranscriptionStreamSegment> read FSegments write FSegments;
    property LastEventType: string read FLastEventType write FLastEventType;
  end;

  TSpeechStreamEvent = reference to procedure(var Chunk: TSpeechStreamChunk; IsDone: Boolean; var Cancel: Boolean);
  TTranscriptionStreamEvent = reference to procedure(var Event: TTranscriptionStream; IsDone: Boolean; var Cancel: Boolean);

  TAsynSpeechStream = TAsynStreamCallBack<TSpeechStreamChunk>;
  TPromiseSpeechStream = TPromiseStreamCallBack<TSpeechStreamChunk>;

  TAsynTranscriptionStream = TAsynStreamCallBack<TTranscriptionStream>;
  TPromiseTranscriptionStream = TPromiseStreamCallBack<TTranscriptionStream>;

implementation

type
  TAudioStreamJsonReader = record
    class function IntegerArrayOf(const Value: TJSONValue): TArray<Integer>; static;
    class function LogprobsOf(const Value: TJSONValue): TArray<TTranscriptionStreamLogprob>; static;
    class function UsageOf(const Reader: TJsonReader; const Path: string): TTranscriptionStreamUsage; static;
  end;

{ TAudioStreamJsonReader }

class function TAudioStreamJsonReader.IntegerArrayOf(
  const Value: TJSONValue): TArray<Integer>;
begin
  Result := [];
  if not (Value is TJSONArray) then
    Exit;

  var Items := TJSONArray(Value);
  for var Index := 0 to Items.Count - 1 do
    Result := Result + [StrToIntDef(Items.Items[Index].Value, 0)];
end;

class function TAudioStreamJsonReader.LogprobsOf(
  const Value: TJSONValue): TArray<TTranscriptionStreamLogprob>;
begin
  Result := [];
  if not (Value is TJSONArray) then
    Exit;

  var Items := TJSONArray(Value);
  for var Index := 0 to Items.Count - 1 do
    if Items.Items[Index] is TJSONObject then
      begin
        var Obj := TJSONObject(Items.Items[Index]);
        var Logprob: TTranscriptionStreamLogprob;
        Logprob.Token := Obj.GetPathString('token');
        Logprob.Bytes := IntegerArrayOf(Obj.GetPathValue('bytes'));
        Logprob.Logprob := Obj.GetPathDouble('logprob');
        Result := Result + [Logprob];
      end;
end;

class function TAudioStreamJsonReader.UsageOf(const Reader: TJsonReader;
  const Path: string): TTranscriptionStreamUsage;
begin
  Result.&Type := Reader.AsString(Path + '.type');
  Result.InputTokens := Reader.AsInt64(Path + '.input_tokens');
  Result.OutputTokens := Reader.AsInt64(Path + '.output_tokens');
  Result.TotalTokens := Reader.AsInt64(Path + '.total_tokens');
  Result.Seconds := Reader.AsDouble(Path + '.seconds');

  Result.HasInputTokenDetails := Reader.IsObjectNode(Path + '.input_token_details');
  if Result.HasInputTokenDetails then
    begin
      var Details: TTranscriptionStreamInputTokenDetails;
      Details.AudioTokens := Reader.AsInt64(Path + '.input_token_details.audio_tokens');
      Details.TextTokens := Reader.AsInt64(Path + '.input_token_details.text_tokens');
      Result.InputTokenDetails := Details;
    end;
end;

{ TSpeechStreamChunk }

constructor TSpeechStreamChunk.Create(const ABytes: TBytes);
begin
  inherited Create;
  FBytes := Copy(ABytes);
  FIsSSE := False;
end;

constructor TSpeechStreamChunk.Create(const AEventName, AData: string);
begin
  inherited Create;
  FEventName := AEventName;
  FText := AData;
  FBytes := TEncoding.UTF8.GetBytes(AData);
  FIsSSE := True;
end;

function TSpeechStreamChunk.GetStream: TStream;
begin
  Result := TMemoryStream.Create;
  try
    if Length(FBytes) > 0 then
      Result.WriteBuffer(FBytes[0], Length(FBytes));
    Result.Position := 0;
  except
    Result.Free;
    raise;
  end;
end;

{ TSpeechStreamResult }

procedure TSpeechStreamResult.Aggregate(const Chunk: TSpeechStreamChunk);
begin
  if not Assigned(Chunk) then
    Exit;

  var Offset := Length(FBytes);
  SetLength(FBytes, Offset + Length(Chunk.Bytes));
  if Length(Chunk.Bytes) > 0 then
    Move(Chunk.Bytes[0], FBytes[Offset], Length(Chunk.Bytes));

  if not Chunk.Text.IsEmpty then
    FText := FText + Chunk.Text;
end;

class function TSpeechStreamResult.Empty: TSpeechStreamResult;
begin
  Result.FBytes := [];
  Result.FText := EmptyStr;
end;

function TSpeechStreamResult.GetStream: TStream;
begin
  Result := TMemoryStream.Create;
  try
    if Length(FBytes) > 0 then
      Result.WriteBuffer(FBytes[0], Length(FBytes));
    Result.Position := 0;
  except
    Result.Free;
    raise;
  end;
end;

{ TTranscriptionStream }

procedure TTranscriptionStream.AfterDeserialize;
begin
  inherited;
  ContentUpdate;
end;

procedure TTranscriptionStream.ContentUpdate;
begin
  inherited;

  if JSONResponse.Trim.IsEmpty then
    Exit;

  var Reader := TJsonReader.Parse(JSONResponse);
  if not Reader.IsValid then
    Exit;

  FType := Reader.AsString('type');
  FDelta := Reader.AsString('delta');
  FText := Reader.AsString('text');
  FSegmentId := Reader.AsString('segment_id');
  FId := Reader.AsString('id');
  FStart := Reader.AsDouble('start');
  FEnd := Reader.AsDouble('end');
  FSpeaker := Reader.AsString('speaker');
  FCode := Reader.AsString('code');
  if FCode.IsEmpty then
    FCode := Reader.AsString('error.code');

  FMessage := Reader.AsString('message');
  if FMessage.IsEmpty then
    FMessage := Reader.AsString('error.message');

  FLogprobs := TAudioStreamJsonReader.LogprobsOf(Reader.Value('logprobs'));

  if Reader.IsObjectNode('usage') then
    FUsage := TAudioStreamJsonReader.UsageOf(Reader, 'usage');
end;

function TTranscriptionStream.IsDelta: Boolean;
begin
  Result := SameText(FType, 'transcript.text.delta');
end;

function TTranscriptionStream.IsDone: Boolean;
begin
  Result := SameText(FType, 'transcript.text.done');
end;

function TTranscriptionStream.IsError: Boolean;
begin
  Result := SameText(FType, 'error');
end;

function TTranscriptionStream.IsSegment: Boolean;
begin
  Result := SameText(FType, 'transcript.text.segment');
end;

{ TTranscriptionStreamResult }

procedure TTranscriptionStreamResult.Aggregate(
  const Event: TTranscriptionStream);
begin
  if not Assigned(Event) then
    Exit;

  FLastEventType := Event.&Type;

  if Event.IsDelta then
    FText := FText + Event.Delta
  else
  if Event.IsDone then
    begin
      if not Event.Text.IsEmpty then
        FText := Event.Text;
      FLogprobs := Event.Logprobs;
      FUsage := Event.Usage;
    end
  else
  if Event.IsSegment then
    begin
      var Segment: TTranscriptionStreamSegment;
      Segment.Id := Event.Id;
      Segment.Start := Event.Start;
      Segment.&End := Event.&End;
      Segment.Speaker := Event.Speaker;
      Segment.Text := Event.Text;
      Segment.&Type := Event.&Type;
      FSegments := FSegments + [Segment];
    end;
end;

class function TTranscriptionStreamResult.Empty: TTranscriptionStreamResult;
begin
  Result.FText := EmptyStr;
  Result.FLogprobs := [];
  Result.FSegments := [];
  Result.FLastEventType := EmptyStr;
end;

end.
