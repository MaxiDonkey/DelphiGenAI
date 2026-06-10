unit GenAI.API.SSEDecoder;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils;

type
  TSSEOnEvent = reference to procedure(const Data: string; var Abort: Boolean);
  TSSEOnNamedEvent = reference to procedure(const EventName, Data: string; var Abort: Boolean);

  TSSEDecoder = class
  const
    MAX_PENDING_BYTES = 1024 * 1024;
  private
    FOnEvent: TSSEOnEvent;
    FOnNamedEvent: TSSEOnNamedEvent;
    FPending: TBytes;
    FTextBuffer: string;
    FDataLines: TStringBuilder;
    FEncoding: TEncoding;
    FEventName: string;

    /// <summary>
    /// Returns the maximum number of leading bytes that can be safely decoded as UTF-8
    /// without splitting a multi-byte character at the end of the buffer.
    /// </summary>
    /// <param name="Bytes">
    /// A byte buffer that may end in the middle of a UTF-8 sequence.
    /// </param>
    /// <returns>
    /// The number of bytes from the start of <paramref name="Bytes"/> that form a safe UTF-8
    /// decoding boundary. The caller can decode <c>Bytes[0..Result-1]</c> and must keep the
    /// remaining bytes (<c>Bytes[Result..]</c>) for the next chunk.
    /// Returns <c>0</c> if no safe cut position can be determined (for example, if the buffer
    /// ends with only UTF-8 continuation bytes).
    /// </returns>
    /// <remarks>
    /// This helper is intended for incremental/streaming decoding. It inspects the tail of the
    /// buffer to determine whether the final UTF-8 code point is complete. It does not fully
    /// validate the entire buffer as UTF-8; its purpose is to avoid cutting the last code point.
    /// </remarks>
    class function Utf8SafeCut(const Bytes: TBytes): Integer; static;

    /// <summary>
    /// Appends <paramref name="Bytes"/> to the internal pending byte buffer.
    /// </summary>
    /// <param name="Bytes">
    /// A chunk of raw bytes (typically UTF-8) received from the stream.
    /// </param>
    /// <returns>
    /// <c>True</c> when the chunk was appended; <c>False</c> when the pending buffer was
    /// reset because it exceeded the maximum accepted size.
    /// </returns>
    /// <remarks>
    /// The decoder accumulates bytes in <c>FPending</c> because a stream chunk may end in the
    /// middle of a UTF-8 multi-byte sequence. The pending buffer is later split into a
    /// decodable prefix and a remainder using <see cref="Utf8SafeCut"/>.
    /// </remarks>
    function AppendPending(const Bytes: TBytes): Boolean;

    /// <summary>
    /// Clears the current byte, text, and event assembly buffers.
    /// </summary>
    /// <remarks>
    /// This method is used for defensive recovery when the pending byte buffer grows beyond
    /// <c>MAX_PENDING_BYTES</c>. It avoids raising from the streaming decoder and lets the
    /// caller continue or stop through its normal callback flow.
    /// </remarks>
    procedure ResetBuffers;

    /// <summary>
    /// Processes the accumulated text buffer by extracting complete lines and
    /// forwarding them to the SSE line parser.
    /// </summary>
    /// <param name="Abort">
    /// Set to <c>True</c> by downstream handlers to stop further processing.
    /// </param>
    /// <remarks>
    /// This method performs incremental parsing of Server-Sent Events (SSE) framing.
    /// It scans <c>FTextBuffer</c> for line feeds (<c>#10</c>), normalizes CRLF by
    /// removing a trailing carriage return (<c>#13</c>) from each extracted line,
    /// and calls <see cref="ProcessLine"/> for each complete line.
    /// Any trailing partial line (without <c>#10</c>) is kept in <c>FTextBuffer</c>
    /// for the next call.
    /// </remarks>
    procedure ProcessText(var Abort: Boolean);

    /// <summary>
    /// Processes a single SSE line and updates the current event assembly state.
    /// </summary>
    /// <param name="Line">
    /// One line of text extracted from the SSE stream (without the line break).
    /// </param>
    /// <param name="Abort">
    /// Set to <c>True</c> by downstream handlers to stop further processing.
    /// </param>
    /// <remarks>
    /// An empty line indicates the end of the current SSE event and triggers
    /// <see cref="EmitEvent"/>. For non-empty lines, this decoder handles
    /// <c>event:</c> and <c>data:</c> fields. Multiple <c>data:</c> lines are
    /// joined with a single line feed. Other SSE fields (such as <c>id:</c> and
    /// <c>retry:</c>) and comments are ignored.
    /// </remarks>
    procedure ProcessLine(const Line: string; var Abort: Boolean);

    /// <summary>
    /// Emits the currently assembled SSE event to the registered callback, if any.
    /// </summary>
    /// <param name="Abort">
    /// Set to <c>True</c> by the callback to stop further processing.
    /// </param>
    /// <remarks>
    /// This method concatenates the collected <c>data:</c> lines stored in
    /// <c>FDataLines</c>, clears the event buffer, and invokes either
    /// <c>FOnNamedEvent</c> or <c>FOnEvent</c>. If there is no pending event data,
    /// the method does nothing.
    /// </remarks>
    procedure EmitEvent(var Abort: Boolean);

  public
    constructor Create(const AOnEvent: TSSEOnEvent; AEncoding: TEncoding = nil); overload;

    constructor Create(const AOnNamedEvent: TSSEOnNamedEvent; AEncoding: TEncoding = nil); overload;

    destructor Destroy; override;

    /// <summary>
    /// Feeds a new chunk of raw bytes into the decoder and processes any complete SSE events.
    /// </summary>
    /// <param name="Bytes">
    /// A chunk of bytes received from the underlying stream (typically UTF-8 encoded).
    /// </param>
    /// <param name="Abort">
    /// Set to <c>True</c> by downstream handlers to stop further processing.
    /// </param>
    /// <remarks>
    /// The provided bytes are appended to an internal pending buffer to handle the case where
    /// the chunk ends in the middle of a UTF-8 multi-byte sequence. The decoder then determines
    /// a safe UTF-8 cut position using <see cref="Utf8SafeCut"/>, decodes only the safe prefix
    /// into text, appends it to <c>FTextBuffer</c>, and finally calls <see cref="ProcessText"/>
    /// to parse complete SSE lines and emit events.
    /// Any leftover bytes that cannot yet be safely decoded remain pending for the next call.
    /// </remarks>
    procedure Feed(const Bytes: TBytes; var Abort: Boolean);

    /// <summary>
    /// Flushes any remaining buffered data and emits a final SSE event if applicable.
    /// </summary>
    /// <param name="Abort">
    /// Set to <c>True</c> by downstream handlers to stop further processing.
    /// </param>
    /// <remarks>
    /// This method is typically called when the underlying connection closes. If the text
    /// buffer contains a final line without a trailing line feed, it is processed as an SSE
    /// line. The decoder then attempts to emit any pending event assembled from <c>data:</c>
    /// lines via <see cref="EmitEvent"/>.
    /// </remarks>
    procedure Flush(var Abort: Boolean);
  end;

implementation

{$REGION 'Dev note'}

(*

  Purpose
  -------
  TSSEDecoder provides incremental parsing of Server-Sent Events (SSE) streams
  with special care for streaming UTF-8.

  Key Points
  ----------
  - Chunk boundaries are not aligned with UTF-8 character boundaries.
    The decoder therefore buffers bytes in FPending and only decodes the largest
    safe prefix determined by Utf8SafeCut, keeping any trailing incomplete UTF-8
    sequence for the next Feed call.

  - Chunk boundaries are not aligned with SSE event boundaries.
    The decoder buffers decoded text in FTextBuffer, extracts complete lines
    separated by LF, normalizes CRLF, and processes one line at a time.

  SSE Subset Implemented
  ----------------------
  - "event:" fields are captured and passed to TSSEOnNamedEvent.
  - "data:" fields are handled and exposed through both callback forms.
  - Multiple "data:" lines are concatenated with LF (#10) as specified by SSE.
  - An empty line terminates an event and triggers emission.
  - Other fields ("id:", "retry:") and comments are ignored.

  Expected Payload
  ----------------
  The consumer callback receives the concatenated "data:" payload as a single
  string. Higher-level code is responsible for interpreting the payload
  (e.g. JSON objects, "[DONE]" markers, OpenAI response event names, etc.).

  OpenAI Constraint
  -----------------
  Chat-style streams often only require the "data:" payload and may include a
  "[DONE]" marker. Responses-style streams may provide an "event:" line whose
  value is semantically useful. For that reason this decoder keeps the simple
  TSSEOnEvent callback and adds TSSEOnNamedEvent for code that needs the SSE
  event name.

  Threading
  ---------
  TSSEDecoder is not internally synchronized. Feed/Flush must be called from a
  single execution context or externally protected if used concurrently.

  Limitations / Non-Goals
  -----------------------
  - Utf8SafeCut prevents cutting the final code point but does not fully validate
    the entire buffer as UTF-8.
  - The decoder does not implement reconnection logic, last-event-id handling,
    retry semantics, or event-name dispatch policy.

  Usage Pattern
  -------------
  - Call Feed for each incoming byte chunk.
  - Call Flush once when the stream ends to process any remaining buffered data.

*)

{$ENDREGION}

{ TSSEDecoder }

constructor TSSEDecoder.Create(const AOnEvent: TSSEOnEvent; AEncoding: TEncoding);
begin
  inherited Create;
  FOnEvent := AOnEvent;
  if Assigned(AEncoding) then
    FEncoding := AEncoding
  else
    FEncoding := TEncoding.UTF8;
  FDataLines := TStringBuilder.Create;
end;

constructor TSSEDecoder.Create(const AOnNamedEvent: TSSEOnNamedEvent; AEncoding: TEncoding);
begin
  inherited Create;
  FOnNamedEvent := AOnNamedEvent;
  if Assigned(AEncoding) then
    FEncoding := AEncoding
  else
    FEncoding := TEncoding.UTF8;
  FDataLines := TStringBuilder.Create;
end;

destructor TSSEDecoder.Destroy;
begin
  FDataLines.Free;
  inherited;
end;

procedure TSSEDecoder.ResetBuffers;
begin
  SetLength(FPending, 0);
  FTextBuffer := EmptyStr;
  FEventName := EmptyStr;
  if Assigned(FDataLines) then
    FDataLines.Clear;
end;

function TSSEDecoder.AppendPending(const Bytes: TBytes): Boolean;
begin
  var L0 := Length(FPending);
  var L1 := Length(Bytes);
  if L1 <= 0 then
    Exit(True);

  if (L0 + L1) > MAX_PENDING_BYTES then
    begin
      ResetBuffers;
      Exit(False);
    end;

  SetLength(FPending, L0 + L1);
  Move(Bytes[0], FPending[L0], L1);
  Result := True;
end;

class function TSSEDecoder.Utf8SafeCut(const Bytes: TBytes): Integer;
var
  Expected: Integer;
begin
  var N := Length(Bytes);
  if N = 0 then
    Exit(0);

  {--- ASCII case }
  var B := Bytes[N - 1];
  if (B and $80) = 0 then
    Exit(N);

  {--- Count the continuation bytes at the end }
  var I := N - 1;
  var Cont := 0;
  while (I >= 0) and ((Bytes[I] and $C0) = $80) do
    begin
      Inc(Cont);
      Dec(I);
    end;

  if I < 0 then
    Exit(0);

  var Start := I;
  B := Bytes[Start];

  {--- If the last byte is a "lead" but without continuation (Cont=0), cut before it. }
  if Cont = 0 then
    begin
      if (B and $E0) = $C0 then
        Exit(N - 1);

      if (B and $F0) = $E0 then
        Exit(N - 1);

      if (B and $F8) = $F0 then
        Exit(N - 1);

      {--- Invalid byte/non-ASCII }
      Exit(N - 1);
    end;

  if (B and $E0) = $C0 then
    Expected := 2
  else
  if (B and $F0) = $E0 then
    Expected := 3
  else
  if (B and $F8) = $F0 then
    Expected := 4
  else
    {--- Invalid lead -> cut before }
    Exit(Start);

  {--- If the final character is incomplete, cut before the lead. }
  if (Cont + 1) < Expected then
    Result := Start
  else
    Result := N;
end;

procedure TSSEDecoder.ProcessLine(const Line: string; var Abort: Boolean);
begin
  if Line.IsEmpty then
    begin
      EmitEvent(Abort);
      Exit;
    end;

  {--- SSE comment line. }
  if Line[1] = ':' then
    Exit;

  {--- SSE: event: .... }
  if (Line.Length >= 6) and SameText(Copy(Line, 1, 6), 'event:') then
    begin
      FEventName := Copy(Line, 7, MaxInt);
      if (Length(FEventName) > 0) and (FEventName[1] = ' ') then
        Delete(FEventName, 1, 1);
      Exit;
    end;

  {--- SSE: data: .... }
  if (Line.Length >= 5) and SameText(Copy(Line, 1, 5), 'data:') then
    begin
      var S := Copy(Line, 6, MaxInt);
      if (Length(S) > 0) and (S[1] = ' ') then
        Delete(S, 1, 1);

      if FDataLines.Length > 0 then
        FDataLines.Append(#10);
      FDataLines.Append(S);
    end;

  {--- We ignore id:, retry:, and other SSE fields. }
end;

procedure TSSEDecoder.EmitEvent(var Abort: Boolean);
begin
  if FDataLines.Length = 0 then
    begin
      FEventName := EmptyStr;
      Exit;
    end;

  var Data := FDataLines.ToString;
  var EventName := FEventName;
  FDataLines.Clear;
  FEventName := EmptyStr;

  if Assigned(FOnNamedEvent) then
    begin
      FOnNamedEvent(EventName, Data, Abort);
      Exit;
    end;

  if Assigned(FOnEvent) then
    FOnEvent(Data, Abort);
end;

procedure TSSEDecoder.ProcessText(var Abort: Boolean);
begin
  var N := Length(FTextBuffer);
  if N = 0 then
    Exit;

  var StartPos := 1;
  var Consumed := 0;

  var I := 1;

  {--- LF segmentation; manages CRLF. }
  while I <= N do
    begin
      if FTextBuffer[I] = #10 then
        begin
          var Line := Copy(FTextBuffer, StartPos, I - StartPos);

          {--- Normalize CRLF. }
          if not Line.IsEmpty and Line.EndsWith(#13) then
            Delete(Line, Length(Line), 1);

          ProcessLine(Line, Abort);
          if Abort then
            Exit;

          {--- Consume up to LF. }
          Consumed := I;

          {--- Next char after LF. }
          StartPos := I + 1;
        end;
      Inc(I);
    end;

  if Consumed > 0 then
    {--- Keep trailing partial line, if any. }
    Delete(FTextBuffer, 1, Consumed);
end;

procedure TSSEDecoder.Feed(const Bytes: TBytes; var Abort: Boolean);
var
  Decodable, Remainder: TBytes;
begin
  if not AppendPending(Bytes) then
    Exit;

  var Total := Length(FPending);
  if Total = 0 then
    Exit;

  var Cut := Utf8SafeCut(FPending);
  if Cut <= 0 then
    Exit;

  SetLength(Decodable, Cut);
  Move(FPending[0], Decodable[0], Cut);

  var RemainLen := Total - Cut;
  if RemainLen > 0 then
    begin
      SetLength(Remainder, RemainLen);
      Move(FPending[Cut], Remainder[0], RemainLen);
      FPending := Remainder;
    end
  else
    SetLength(FPending, 0);

  var S := EmptyStr;
  try
    S := FEncoding.GetString(Decodable);
  except
    ResetBuffers;
    Exit;
  end;

  if not S.IsEmpty then
    begin
      FTextBuffer := FTextBuffer + S;
    end;
    {--- WARNING: FTextBuffer := FTextBuffer + S can become expensive if very large
         stream chunks are received repeatedly. }

  ProcessText(Abort);
end;

procedure TSSEDecoder.Flush(var Abort: Boolean);
begin
  ProcessText(Abort);
  if Abort then
    Exit;

  if not FTextBuffer.IsEmpty then
    begin
      FTextBuffer := FTextBuffer + #10;
      ProcessText(Abort);
      if Abort then
        Exit;
    end;

  EmitEvent(Abort);
end;

end.
