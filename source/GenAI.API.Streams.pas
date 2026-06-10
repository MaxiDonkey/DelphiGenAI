unit GenAI.API.Streams;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs;

type
  /// <summary>
  /// A <see cref="TMemoryStream"/> descendant that serializes access to its internal buffer
  /// to support concurrent writers and incremental readers safely.
  /// </summary>
  /// <remarks>
  /// <para>
  /// <see cref="TMemoryStream"/> may reallocate its internal buffer when it grows. If one
  /// thread reads from <see cref="TMemoryStream.Memory"/> while another thread is writing,
  /// the reader can observe an invalid pointer and raise runtime errors.
  /// </para>
  /// <para>
  /// <c>TLockedMemoryStream</c> addresses this by guarding writes (and delta extraction) with
  /// a critical section. Use <see cref="ExtractDelta"/> to retrieve the bytes appended since
  /// a previous offset in an atomic, thread-safe way.
  /// </para>
  /// </remarks>
  TLockedMemoryStream = class(TMemoryStream)
  private
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// Writes <paramref name="Count"/> bytes from <paramref name="Buffer"/> into the stream
    /// in a thread-safe manner.
    /// </summary>
    /// <param name="Buffer">
    /// The source memory block containing the bytes to write.
    /// </param>
    /// <param name="Count">
    /// The number of bytes to write from <paramref name="Buffer"/>.
    /// </param>
    /// <returns>
    /// The number of bytes actually written.
    /// </returns>
    /// <remarks>
    /// This override serializes access to the underlying <see cref="TMemoryStream"/> storage
    /// using a critical section. It is designed to prevent races between concurrent writers
    /// and readers (such as <see cref="ExtractDelta"/>) that could otherwise occur when the
    /// stream grows and its internal buffer is reallocated.
    /// </remarks>
    function Write(const Buffer; Count: Longint): Longint; override;

    /// <summary>
    /// Extracts the bytes appended to the stream since the last read position given by
    /// <paramref name="Offset"/> and advances <paramref name="Offset"/> accordingly.
    /// </summary>
    /// <param name="Offset">
    /// On input, the byte position from which to start extracting new data. On output, this
    /// value is advanced by the number of extracted bytes.
    /// </param>
    /// <param name="Bytes">
    /// Receives the extracted byte slice. Set to an empty array if no new data is available.
    /// </param>
    /// <returns>
    /// <c>True</c> if at least one byte was extracted; <c>False</c> if no new data is available
    /// or if <paramref name="Offset"/> is out of range.
    /// </returns>
    /// <remarks>
    /// This method is intended for incremental consumption of a <see cref="TMemoryStream"/>
    /// that is being written to concurrently. The extraction is performed under the same
    /// lock used by <see cref="Write"/>, ensuring the internal buffer cannot be reallocated
    /// while the copy is in progress. This prevents invalid pointer access when reading from
    /// <see cref="TMemoryStream.Memory"/>.
    /// </remarks>
    function ExtractDelta(var Offset: Int64; out Bytes: TBytes): Boolean;
  end;

implementation

{ TLockedMemoryStream }

constructor TLockedMemoryStream.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TLockedMemoryStream.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TLockedMemoryStream.Write(const Buffer; Count: Longint): Longint;
begin
  FLock.Enter;
  try
    Result := inherited Write(Buffer, Count);
  finally
    FLock.Leave;
  end;
end;

function TLockedMemoryStream.ExtractDelta(var Offset: Int64; out Bytes: TBytes): Boolean;
var
  NewCount: Int64;
begin
  Result := False;
  SetLength(Bytes, 0);

  FLock.Enter;
  try
    {--- Guard against invalid offsets (negative or beyond current Size) to avoid out-of-bounds
         reads and pointer arithmetic on the internal buffer. }
    if (Offset < 0) or (Offset > Size) then
      Exit;

    NewCount := Size - Offset;
    if NewCount <= 0 then
      Exit;

    SetLength(Bytes, NewCount);
    Move(PByte(Memory)[NativeInt(Offset)], Bytes[0], NewCount);
    Inc(Offset, NewCount);
    Result := True;
  finally
    FLock.Leave;
  end;
end;

end.
