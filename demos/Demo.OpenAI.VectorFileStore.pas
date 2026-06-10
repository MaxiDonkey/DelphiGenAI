unit Demo.OpenAI.VectorFileStore;

interface

{$REGION 'Dev note'}
(*

  OpenAI knowledge indexing for the pythia-openai FMX demo.

  Pythia exposes knowledge files through a vendor-neutral indexing service. This
  unit adapts that contract to OpenAI Responses file_search:
    - upload the local file with the OpenAI Files API and keep the file_id;
    - create one vector store per local file;
    - attach the uploaded file to that vector store and wait until it is ready;
    - return the vector_store_id to Pythia as the opaque knowledge index ref.

  The file upload and vector-store lifecycle are intentionally separate from the
  regular prompt-file attachment flow. Files API entries are kept because they
  allow a missing, expired or failed vector store to be rebuilt without uploading
  the local file again.

  A persistent cache is saved next to the demo support JSON files using the
  "<app>-vector-store.json" convention. Cache entries include the local file
  fingerprint, the OpenAI file_id, the vector_store_id and indexing status.
  Before reusing an entry, the service validates both the local fingerprint and
  the remote OpenAI resources. If the vector store is gone but the file still
  exists server-side, only the vector store is recreated.

  CancelOrDelete only affects the in-demo pending entry and UI availability. It
  deliberately does not delete the cached OpenAI file or vector store, because
  knowledge indexing is persistent demo state rather than a temporary prompt
  attachment.

  Pythia's current UI bridge names the returned opaque index reference "fileId".
  This unit contains that adaptation boundary: for OpenAI knowledge search, the
  value sent through that field is the vector_store_id, not the OpenAI file_id.

*)
{$ENDREGION}

uses
  System.SysUtils, System.JSON, System.Generics.Collections,
  WVPythia.Chat.Interfaces, WVPythia.Types,
  GenAI;

type
  TOpenAIKnowledgeIndexingService = class(TInterfacedObject, IKnowledgeIndexingService)
  private type
    EVectorStoreFileTerminalStatus = class(Exception);

    TIndexingStatus = (isUploading, isIndexing, isReady, isFailed, isCancelled);

    TIndexingEntry = class
    public
      LocalPath: string;
      Status: TIndexingStatus;
      LastActiveStatus: TIndexingStatus;
      IndexRef: string;
      ErrorMessage: string;
      Cancelled: Boolean;
    end;

    TVectorFileCacheEntry = record
      Name: string;
      FullPath: string;
      Size: Int64;
      LastWriteTimeUtc: string;
      FileId: string;
      VectorStoreId: string;
      Status: string;

      function HasSameLocalFingerprint(
        const AName, AFullPath: string;
        const ASize: Int64;
        const ALastWriteTimeUtc: string): Boolean;
    end;

  private const
    POLL_INTERVAL_MS = 1500;
    POLL_MAX_ATTEMPTS = 120;

    CACHE_SUFFIX = '-vector-store.json';
    CACHE_STATUS_COMPLETED = 'completed';
    CACHE_STATUS_FILE_UPLOADED = 'file_uploaded';
    CACHE_STATUS_INDEXING = 'indexing';
  private
    FPythia: IPythiaBrowser;
    FClient: IGenAI;
    FOnPending: TProc;
    FEntries: TObjectDictionary<string, TIndexingEntry>;
    FLock: TObject;

    class function EntryKey(const ALocalPath: string): string; static;
    class function IsTransientVectorStoreFileLookupError(
      const AMessage: string): Boolean; static;
    class function LocalFileSize(const ALocalPath: string): Int64; static;
    class function ToJSStringOrNull(const S: string): string; static;

    function CacheFileName: string;
    function NewCacheEntry(const ALocalPath: string): TVectorFileCacheEntry;

    function LoadCache: TArray<TVectorFileCacheEntry>;
    procedure SaveCache(const AEntries: TArray<TVectorFileCacheEntry>);
    procedure SaveCacheEntry(const AEntry: TVectorFileCacheEntry);
    function TryFindValidLocalCacheEntry(
      const ALocalPath: string;
      out AEntry: TVectorFileCacheEntry): Boolean;

    function TryRemoteFileExists(const AFileId: string): Boolean;
    function TryRemoteVectorStoreExists(const AVectorStoreId: string): Boolean;
    function TryRemoteVectorStoreFileReady(
      const AVectorStoreId, AFileId: string): Boolean;

    function UploadFile(const ALocalPath: string): string;
    function CreateVectorStoreForFile(
      const AFileId, ALocalPath: string): string;
    procedure WaitUntilVectorStoreFileReady(
      const AVectorStoreId, AFileId: string);
    function ResolveVectorStore(
      const ALocalPath: string): TVectorFileCacheEntry;

    procedure PushUploadStatus(
      const APath, AStatus, AIndexRef, AErrorMessage: string);
    procedure PushReadyVectorStoreIdToPythia(
      const ALocalPath, AVectorStoreId: string);
    procedure MarkEntryIndexing(const ALocalPath: string);
    procedure UpdateAvailability;
    procedure CompleteEntry(
      const ALocalPath, AIndexRef: string;
      const AOnComplete: TUploadCompleteProc);
    procedure FailEntry(
      const ALocalPath, AErrorMessage: string;
      const AOnComplete: TUploadCompleteProc);
    function EntryWasCancelled(const ALocalPath: string): Boolean;

  public
    constructor Create(
      const APythia: IPythiaBrowser;
      const AClient: IGenAI);
    destructor Destroy; override;

    function ShouldHandle(
      const ALocalPath: string;
      const ATarget: TOpenFileTarget): Boolean;

    procedure SubmitForIndexing(
      const ALocalPath: string;
      const ATarget: TOpenFileTarget;
      const AOnComplete: TUploadCompleteProc = nil);

    procedure CancelOrDelete(const ALocalPath: string);

    function TryGetIndexRef(
      const ALocalPath: string;
      out AIndexRef: string): Boolean;

    function PendingCount: Integer;

    function GetOnPendingChanged: TProc;
    procedure SetOnPendingChanged(const Value: TProc);
    property OnPendingChanged: TProc read GetOnPendingChanged write SetOnPendingChanged;
  end;

implementation

uses
  System.Classes, System.IOUtils, System.DateUtils, System.Threading,
  WVPythia.Chat.Consts, WVPythia.JSON.SafeReader, WVPythia.JSON.SafeWriter,
  WVPythia.Strings.Escape, WVPythia.TextFile.Helper,
  GenAI.Types;

{ TOpenAIKnowledgeIndexingService.TVectorFileCacheEntry }

function TOpenAIKnowledgeIndexingService.TVectorFileCacheEntry.HasSameLocalFingerprint(
  const AName, AFullPath: string;
  const ASize: Int64;
  const ALastWriteTimeUtc: string): Boolean;
begin
  Result :=
    SameText(Name, AName) and
    SameText(FullPath, AFullPath) and
    (Size = ASize) and
    SameText(LastWriteTimeUtc, ALastWriteTimeUtc);
end;

{ TOpenAIKnowledgeIndexingService }

constructor TOpenAIKnowledgeIndexingService.Create(
  const APythia: IPythiaBrowser;
  const AClient: IGenAI);
begin
  inherited Create;
  FPythia := APythia;
  FClient := AClient;
  FEntries := TObjectDictionary<string, TIndexingEntry>.Create([doOwnsValues]);
  FLock := TObject.Create;
end;

destructor TOpenAIKnowledgeIndexingService.Destroy;
begin
  FLock.Free;
  FEntries.Free;
  inherited;
end;

class function TOpenAIKnowledgeIndexingService.EntryKey(
  const ALocalPath: string): string;
begin
  Result := TPath.GetFullPath(ALocalPath.Trim).ToLowerInvariant;
end;

class function TOpenAIKnowledgeIndexingService.IsTransientVectorStoreFileLookupError(
  const AMessage: string): Boolean;
begin
  var Text := AMessage.Trim.ToLowerInvariant;
  Result :=
    Text.Contains('404') and
    Text.Contains('vector store') and
    (Text.Contains('no file found') or Text.Contains('not found'));
end;

class function TOpenAIKnowledgeIndexingService.LocalFileSize(
  const ALocalPath: string): Int64;
begin
  var Stream := TFileStream.Create(ALocalPath, fmOpenRead or fmShareDenyNone);
  try
    Result := Stream.Size;
  finally
    Stream.Free;
  end;
end;

class function TOpenAIKnowledgeIndexingService.ToJSStringOrNull(
  const S: string): string;
begin
  if S.Trim.IsEmpty then
    Result := 'null'
  else
    Result := TEscapeHelper.EscapeJSString(S);
end;

function TOpenAIKnowledgeIndexingService.CacheFileName: string;
begin
  Result := TPath.Combine(
    TPath.GetDirectoryName(FPythia.GetChatSessionsFileName),
    FPythia.GetAppRawName + CACHE_SUFFIX);
end;

function TOpenAIKnowledgeIndexingService.NewCacheEntry(
  const ALocalPath: string): TVectorFileCacheEntry;
begin
  Result := Default(TVectorFileCacheEntry);
  Result.FullPath := TPath.GetFullPath(ALocalPath.Trim);
  Result.Name := TPath.GetFileName(Result.FullPath);
  Result.Size := LocalFileSize(Result.FullPath);
  Result.LastWriteTimeUtc :=
    DateToISO8601(TFile.GetLastWriteTimeUtc(Result.FullPath), True);
end;

function TOpenAIKnowledgeIndexingService.LoadCache: TArray<TVectorFileCacheEntry>;
begin
  Result := [];
  if not TFile.Exists(CacheFileName) then
    Exit;

  var Reader := TJsonReader.Parse(TFileIOHelper.LoadFromFile(CacheFileName));
  if not Reader.IsValid or not Reader.IsArrayNode('files') then
    Exit;

  for var index := 0 to Reader.Count('files') - 1 do
    begin
      var Path := Format('files[%d]', [index]);

      var Entry := Default(TVectorFileCacheEntry);
      Entry.Name := Reader.AsString(Path + '.name');
      Entry.FullPath := Reader.AsString(Path + '.fullPath');
      Entry.Size := StrToInt64Def(Reader.AsString(Path + '.size'), 0);
      Entry.LastWriteTimeUtc := Reader.AsString(Path + '.lastWriteTimeUtc');
      Entry.FileId := Reader.AsString(Path + '.fileId');
      Entry.VectorStoreId := Reader.AsString(Path + '.vectorStoreId');
      Entry.Status := Reader.AsString(Path + '.status');

      if not Entry.FullPath.Trim.IsEmpty then
        Result := Result + [Entry];
    end;
end;

procedure TOpenAIKnowledgeIndexingService.SaveCache(
  const AEntries: TArray<TVectorFileCacheEntry>);
begin
  var CacheFolder := TPath.GetDirectoryName(CacheFileName);
  if not TDirectory.Exists(CacheFolder) then
    TDirectory.CreateDirectory(CacheFolder);

  var Writer := TJsonWriter.NewObject;
  if not Writer.EnsureArray('files') then
    raise Exception.Create('Unable to create vector store cache JSON.');

  for var Entry in AEntries do
    begin
      var Item := TJsonWriter.NewObject;
      if not Item.SetString('name', Entry.Name) then
        raise Exception.Create('Unable to write vector store cache name.');

      if not Item.SetString('fullPath', Entry.FullPath) then
        raise Exception.Create('Unable to write vector store cache path.');

      if not Item.SetInteger('size', Entry.Size) then
        raise Exception.Create('Unable to write vector store cache size.');

      if not Item.SetString('lastWriteTimeUtc', Entry.LastWriteTimeUtc) then
        raise Exception.Create('Unable to write vector store cache timestamp.');

      if not Item.SetString('fileId', Entry.FileId) then
        raise Exception.Create('Unable to write vector store cache file id.');

      if not Item.SetString('vectorStoreId', Entry.VectorStoreId) then
        raise Exception.Create('Unable to write vector store cache vector store id.');

      if not Item.SetString('status', Entry.Status) then
        raise Exception.Create('Unable to write vector store cache status.');

      if not Writer.AppendObjectJson('files', Item.ToJson) then
        raise Exception.Create('Unable to append vector store cache entry.');
    end;

  TFileIOHelper.SaveToFile(CacheFileName, Writer.Format);
end;

procedure TOpenAIKnowledgeIndexingService.SaveCacheEntry(
  const AEntry: TVectorFileCacheEntry);
begin
  TMonitor.Enter(FLock);
  try
    var Entries := LoadCache;
    var Replaced := False;

    for var index := Low(Entries) to High(Entries) do
      if SameText(Entries[index].FullPath, AEntry.FullPath) then
        begin
          Entries[index] := AEntry;
          Replaced := True;
          Break;
        end;

    if not Replaced then
      Entries := Entries + [AEntry];

    SaveCache(Entries);
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TOpenAIKnowledgeIndexingService.TryFindValidLocalCacheEntry(
  const ALocalPath: string;
  out AEntry: TVectorFileCacheEntry): Boolean;
begin
  AEntry := NewCacheEntry(ALocalPath);

  TMonitor.Enter(FLock);
  try
    var Entries := LoadCache;
    for var Item in Entries do
      if Item.HasSameLocalFingerprint(
        AEntry.Name,
        AEntry.FullPath,
        AEntry.Size,
        AEntry.LastWriteTimeUtc) then
        begin
          AEntry := Item;
          Exit(True);
        end;
  finally
    TMonitor.Exit(FLock);
  end;

  Result := False;
end;

function TOpenAIKnowledgeIndexingService.TryRemoteFileExists(
  const AFileId: string): Boolean;
begin
  Result := False;
  if AFileId.Trim.IsEmpty then
    Exit;

  try
    var Value := FClient.Files.Retrieve(AFileId.Trim);
    try
      Result := Assigned(Value) and SameText(Value.Id, AFileId.Trim);
    finally
      Value.Free;
    end;
  except
    Result := False;
  end;
end;

function TOpenAIKnowledgeIndexingService.TryRemoteVectorStoreExists(
  const AVectorStoreId: string): Boolean;
begin
  Result := False;
  if AVectorStoreId.Trim.IsEmpty then
    Exit;

  try
    var Value := FClient.VectorStore.Retrieve(AVectorStoreId.Trim);
    try
      Result :=
        Assigned(Value) and
        SameText(Value.Id, AVectorStoreId.Trim) and
        (Value.Status <> TRunStatus.expired);
    finally
      Value.Free;
    end;
  except
    Result := False;
  end;
end;

function TOpenAIKnowledgeIndexingService.TryRemoteVectorStoreFileReady(
  const AVectorStoreId, AFileId: string): Boolean;
begin
  Result := False;
  if AVectorStoreId.Trim.IsEmpty or AFileId.Trim.IsEmpty then
    Exit;

  try
    var Value := FClient.VectorStoreFiles.Retrieve(
      AVectorStoreId.Trim,
      AFileId.Trim);
    try
      Result :=
        Assigned(Value) and
        SameText(Value.VectorStoreId, AVectorStoreId.Trim) and
        SameText(Value.Id, AFileId.Trim) and
        (Value.Status = TRunStatus.completed);
    finally
      Value.Free;
    end;
  except
    Result := False;
  end;
end;

function TOpenAIKnowledgeIndexingService.UploadFile(
  const ALocalPath: string): string;
begin
  var Value := FClient.Files.Upload(
    procedure(Params: TFileUploadParams)
    begin
      Params
        .&File(ALocalPath)
        .Purpose(TFilesPurpose.assistants);
    end);
  try
    Result := Value.Id;
  finally
    Value.Free;
  end;
end;

function TOpenAIKnowledgeIndexingService.CreateVectorStoreForFile(
  const AFileId, ALocalPath: string): string;
begin
  var StoreName := Format('Pythia knowledge - %s', [TPath.GetFileName(ALocalPath)]);
  var Value := FClient.VectorStore.Create(
    procedure(Params: TVectorStoreCreateParams)
    begin
      Params
        .Name(StoreName)
        .FileIds([AFileId]);
    end);
  try
    Result := Value.Id;
  finally
    Value.Free;
  end;
end;

procedure TOpenAIKnowledgeIndexingService.WaitUntilVectorStoreFileReady(
  const AVectorStoreId, AFileId: string);
begin
  for var Attempt := 1 to POLL_MAX_ATTEMPTS do
    begin
      try
        var Value := FClient.VectorStoreFiles.Retrieve(
          AVectorStoreId,
          AFileId);
        try
          case Value.Status of
            TRunStatus.completed:
              Exit;

            TRunStatus.failed,
            TRunStatus.cancelled,
            TRunStatus.expired:
              raise EVectorStoreFileTerminalStatus.CreateFmt(
                'OpenAI vector store file indexing failed with status "%s".',
                [Value.Status.ToString]);
          end;
        finally
          Value.Free;
        end;
      except
        on E: EVectorStoreFileTerminalStatus do
          raise;

        on E: Exception do
          begin
            if not IsTransientVectorStoreFileLookupError(E.Message) then
              raise;

            if Attempt = POLL_MAX_ATTEMPTS then
              raise Exception.CreateFmt(
                'OpenAI vector store file lookup timed out after transient 404: %s',
                [E.Message]);
          end;
      end;

      Sleep(POLL_INTERVAL_MS);
    end;

  raise Exception.Create('OpenAI vector store file indexing timed out.');
end;

function TOpenAIKnowledgeIndexingService.ResolveVectorStore(
  const ALocalPath: string): TVectorFileCacheEntry;
begin
  var HasCache := TryFindValidLocalCacheEntry(ALocalPath, Result);
  if not HasCache then
    Result := NewCacheEntry(ALocalPath);

  if HasCache and
     not Result.VectorStoreId.Trim.IsEmpty and
     TryRemoteVectorStoreExists(Result.VectorStoreId) then
    begin
      try
        if not TryRemoteVectorStoreFileReady(Result.VectorStoreId, Result.FileId) then
          begin
            MarkEntryIndexing(Result.FullPath);
            Result.Status := CACHE_STATUS_INDEXING;
            SaveCacheEntry(Result);
            WaitUntilVectorStoreFileReady(Result.VectorStoreId, Result.FileId);
          end;

        Result.Status := CACHE_STATUS_COMPLETED;
        SaveCacheEntry(Result);
        Exit;
      except
        on E: EVectorStoreFileTerminalStatus do
          begin
            Result.VectorStoreId := '';
            Result.Status := CACHE_STATUS_FILE_UPLOADED;
            SaveCacheEntry(Result);
          end;
      end;
    end;

  if (Result.FileId.Trim.IsEmpty) or
     not TryRemoteFileExists(Result.FileId) then
    begin
      Result.FileId := UploadFile(Result.FullPath);
      Result.VectorStoreId := '';
      Result.Status := CACHE_STATUS_FILE_UPLOADED;
      SaveCacheEntry(Result);
    end;

  MarkEntryIndexing(Result.FullPath);
  Result.Status := CACHE_STATUS_INDEXING;
  SaveCacheEntry(Result);

  Result.VectorStoreId := CreateVectorStoreForFile(Result.FileId, Result.FullPath);
  if Result.VectorStoreId.Trim.IsEmpty then
    raise Exception.Create('OpenAI vector store creation returned an empty id.');

  SaveCacheEntry(Result);
  WaitUntilVectorStoreFileReady(Result.VectorStoreId, Result.FileId);

  Result.Status := CACHE_STATUS_COMPLETED;
  SaveCacheEntry(Result);
end;

procedure TOpenAIKnowledgeIndexingService.PushUploadStatus(
  const APath, AStatus, AIndexRef, AErrorMessage: string);
begin
  var Path := APath;
  var Status := AStatus;
  var IndexRef := AIndexRef;
  var ErrorMessage := AErrorMessage;

  TThread.Queue(nil,
    procedure
    begin
      if Assigned(FPythia) then
        FPythia.SetFileUploadStatus(
          TEscapeHelper.EscapeJSString(Path),
          Status,
          ToJSStringOrNull(IndexRef),
          ToJSStringOrNull(ErrorMessage));
    end);
end;

procedure TOpenAIKnowledgeIndexingService.PushReadyVectorStoreIdToPythia(
  const ALocalPath, AVectorStoreId: string);
begin
  {--- Pythia's current UI bridge names this argument "fileId". At this
       adapter boundary only, OpenAI passes the vendor-neutral index reference:
       for OpenAI knowledge search that reference is the vector_store_id. }
  PushUploadStatus(
    ALocalPath,
    FILE_UPLOAD_STATUS_READY,
    AVectorStoreId,
    '');
end;

procedure TOpenAIKnowledgeIndexingService.MarkEntryIndexing(
  const ALocalPath: string);
begin
  var ShouldNotify := False;

  TMonitor.Enter(FLock);
  try
    var Entry: TIndexingEntry;
    if FEntries.TryGetValue(EntryKey(ALocalPath), Entry) and
       not Entry.Cancelled then
      begin
        Entry.Status := isIndexing;
        Entry.LastActiveStatus := isIndexing;
        ShouldNotify := True;
      end;
  finally
    TMonitor.Exit(FLock);
  end;

  if ShouldNotify then
    begin
      PushUploadStatus(ALocalPath, FILE_UPLOAD_STATUS_INDEXING, '', '');
      UpdateAvailability;
    end;
end;

procedure TOpenAIKnowledgeIndexingService.UpdateAvailability;
begin
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(FPythia) then
        FPythia.RecomputeSendButtonAvailability;

      if Assigned(FOnPending) then
        FOnPending();
    end);
end;

procedure TOpenAIKnowledgeIndexingService.CompleteEntry(
  const ALocalPath, AIndexRef: string;
  const AOnComplete: TUploadCompleteProc);
begin
  var WasCancelled := False;

  TMonitor.Enter(FLock);
  try
    var Entry: TIndexingEntry;
    if FEntries.TryGetValue(EntryKey(ALocalPath), Entry) then
      begin
        WasCancelled := Entry.Cancelled;
        Entry.Status := isReady;
        Entry.LastActiveStatus := isReady;
        Entry.IndexRef := AIndexRef;
        Entry.ErrorMessage := '';
      end;
  finally
    TMonitor.Exit(FLock);
  end;

  UpdateAvailability;

  if WasCancelled then
    begin
      if Assigned(AOnComplete) then
        TThread.Queue(nil,
          procedure
          begin
            AOnComplete(TUploadResult.Fail(ALocalPath, 'cancelled'));
          end);
      Exit;
    end;

  PushReadyVectorStoreIdToPythia(ALocalPath, AIndexRef);

  if Assigned(AOnComplete) then
    TThread.Queue(nil,
      procedure
      begin
        AOnComplete(TUploadResult.Ok(ALocalPath, AIndexRef));
      end);
end;

procedure TOpenAIKnowledgeIndexingService.FailEntry(
  const ALocalPath, AErrorMessage: string;
  const AOnComplete: TUploadCompleteProc);
begin
  var WasCancelled := False;

  TMonitor.Enter(FLock);
  try
    var Entry: TIndexingEntry;
    if FEntries.TryGetValue(EntryKey(ALocalPath), Entry) then
      begin
        WasCancelled := Entry.Cancelled;
        Entry.Status := isFailed;
        Entry.LastActiveStatus := isFailed;
        Entry.ErrorMessage := AErrorMessage;
      end;
  finally
    TMonitor.Exit(FLock);
  end;

  UpdateAvailability;

  if not WasCancelled then
    PushUploadStatus(ALocalPath, FILE_UPLOAD_STATUS_FAILED, '', AErrorMessage);

  if Assigned(AOnComplete) then
    TThread.Queue(nil,
      procedure
      begin
        AOnComplete(TUploadResult.Fail(ALocalPath, AErrorMessage));
      end);
end;

function TOpenAIKnowledgeIndexingService.EntryWasCancelled(
  const ALocalPath: string): Boolean;
begin
  Result := False;
  TMonitor.Enter(FLock);
  try
    var Entry: TIndexingEntry;
    if FEntries.TryGetValue(EntryKey(ALocalPath), Entry) then
      Result := Entry.Cancelled;
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TOpenAIKnowledgeIndexingService.ShouldHandle(
  const ALocalPath: string;
  const ATarget: TOpenFileTarget): Boolean;
begin
  Result :=
    (ATarget = TOpenFileTarget.Knowledge) and
    TFile.Exists(ALocalPath.Trim);
end;

procedure TOpenAIKnowledgeIndexingService.SubmitForIndexing(
  const ALocalPath: string;
  const ATarget: TOpenFileTarget;
  const AOnComplete: TUploadCompleteProc);
begin
  if not ShouldHandle(ALocalPath, ATarget) then
    begin
      if Assigned(AOnComplete) then
        AOnComplete(TUploadResult.Fail(ALocalPath, 'unsupported knowledge file'));
      Exit;
    end;

  var Key := EntryKey(ALocalPath);

  TMonitor.Enter(FLock);
  try
    var Existing: TIndexingEntry;
    if FEntries.TryGetValue(Key, Existing) then
      begin
        if Existing.Status = isReady then
          begin
            PushReadyVectorStoreIdToPythia(ALocalPath, Existing.IndexRef);
            if Assigned(AOnComplete) then
              AOnComplete(TUploadResult.Ok(ALocalPath, Existing.IndexRef));
            Exit;
          end;

        if Existing.Status = isCancelled then
          begin
            Existing.Cancelled := False;
            Existing.Status := Existing.LastActiveStatus;

            if Existing.Status = isReady then
              PushReadyVectorStoreIdToPythia(ALocalPath, Existing.IndexRef)
            else
            if Existing.Status = isUploading then
              PushUploadStatus(ALocalPath, FILE_UPLOAD_STATUS_UPLOADING, '', '')
            else
              PushUploadStatus(ALocalPath, FILE_UPLOAD_STATUS_INDEXING, '', '');

            UpdateAvailability;
            Exit;
          end;

        if Existing.Status in [isUploading, isIndexing] then
          Exit;

        FEntries.Remove(Key);
      end;

    var Entry := TIndexingEntry.Create;
    Entry.LocalPath := ALocalPath;
    Entry.Status := isUploading;
    Entry.LastActiveStatus := isUploading;
    FEntries.Add(Key, Entry);
  finally
    TMonitor.Exit(FLock);
  end;

  PushUploadStatus(ALocalPath, FILE_UPLOAD_STATUS_UPLOADING, '', '');
  UpdateAvailability;

  var CapturedPath := ALocalPath;
  var CapturedComplete := AOnComplete;

  TTask.Run(
    procedure
    begin
      try
        var CacheEntry := ResolveVectorStore(CapturedPath);

        if EntryWasCancelled(CapturedPath) then
          begin
            CompleteEntry(CapturedPath, CacheEntry.VectorStoreId, CapturedComplete);
            Exit;
          end;

        CompleteEntry(CapturedPath, CacheEntry.VectorStoreId, CapturedComplete);
      except
        on E: Exception do
          FailEntry(CapturedPath, E.Message, CapturedComplete);
      end;
    end);
end;

procedure TOpenAIKnowledgeIndexingService.CancelOrDelete(
  const ALocalPath: string);
begin
  TMonitor.Enter(FLock);
  try
    var Entry: TIndexingEntry;
    if not FEntries.TryGetValue(EntryKey(ALocalPath), Entry) then
      Exit;

    case Entry.Status of
      isUploading,
      isIndexing:
        begin
          Entry.Cancelled := True;
          Entry.LastActiveStatus := Entry.Status;
          Entry.Status := isCancelled;
        end;

      isCancelled: ;
    else
      FEntries.Remove(EntryKey(ALocalPath));
    end;
  finally
    TMonitor.Exit(FLock);
  end;

  UpdateAvailability;
end;

function TOpenAIKnowledgeIndexingService.TryGetIndexRef(
  const ALocalPath: string;
  out AIndexRef: string): Boolean;
begin
  AIndexRef := '';

  TMonitor.Enter(FLock);
  try
    var Entry: TIndexingEntry;
    Result := FEntries.TryGetValue(EntryKey(ALocalPath), Entry) and
      (Entry.Status = isReady) and
      not Entry.IndexRef.Trim.IsEmpty;

    if Result then
      AIndexRef := Entry.IndexRef;
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TOpenAIKnowledgeIndexingService.PendingCount: Integer;
begin
  Result := 0;

  TMonitor.Enter(FLock);
  try
    for var Entry in FEntries.Values do
      if Entry.Status in [isUploading, isIndexing] then
        Inc(Result);
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TOpenAIKnowledgeIndexingService.GetOnPendingChanged: TProc;
begin
  Result := FOnPending;
end;

procedure TOpenAIKnowledgeIndexingService.SetOnPendingChanged(
  const Value: TProc);
begin
  FOnPending := Value;
end;

end.
