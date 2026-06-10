unit Demo.OpenAI.AsyncUtils;

interface

uses
  System.SysUtils, System.IOUtils, System.Classes, System.Threading,
  Winapi.Windows,
  GenAI, GenAI.Types, GenAI.Helpers, GenAI.Async.Promise,
  WVPythia.Chat.Interfaces, WVPythia.Vendors.Services, WVPythia.TextFile.Helper,
  Demo.OpenAI.Helpers;

type
  IOpenAIClientUtils = interface
    ['{7A5E70A4-251C-47B0-BBBA-185DA65A2A76}']
    procedure ASyncSessionRename(const ChatID: string; const ContentToSummarize: string);
    procedure CustomSkillRegister(const SkillID: string; const AName: string);
    function AsyncTranscribe(const AAudioFilePath: string): TPromise<TTranscription>;
    function WhenAllRetrieve(const IDs: TArray<string>): TPromise<TArray<string>>;
    procedure AsyncDownloadAs(const ID, LocalPath: string);
    procedure AsyncDownloadContainerFileAs(
      const ContainerId, FileId, LocalPath: string);
    procedure AsyncDeleteFire(const ID: string);
    procedure AsyncDeleteAllFire(const IDs: TArray<string>);
  end;

  TOpenAIClientUtils = class(TInterfacedObject, IOpenAIClientUtils)
  const
    MODEL_FOR_RENAMING = 'gpt-4.1';
    OPENAI_DEFAULT_TRANSCRIPTION_MODEL = 'whisper-1';
  private
    FClient: IGenAI;
    FPythia: IPythiaBrowser;
  protected
    /// <summary>
    /// Searches OpenAI custom skills by name, following result pages until a
    /// case-insensitive match for AName is found. Returns the matching skill
    /// ID, or an empty string when no match exists.
    /// </summary>
    function FindCustomSkillIDByName(const AName: string): string;

    /// <summary>
    /// Registers a custom skill by creating it from the files in Folder. The
    /// OpenAI Skills API derives the skill metadata from the uploaded bundle.
    /// Returns the new skill ID.
    /// </summary>
    function SkillRegister(const AName: string; const Folder: string): string;
  public
    constructor Create(const AClient: IGenAI; const ABrowser: IPythiaBrowser);

    /// <summary>
    /// Fire-and-forget chat-title generation for ChatID. The model summarizes
    /// ContentToSummarize into a short title, which is then saved to the
    /// persistent chat store and reflected in the active chat session. Empty
    /// results and failures are ignored.
    /// </summary>
    procedure ASyncSessionRename(const ChatID: string; const ContentToSummarize: string);

    /// <summary>
    /// Registers or resolves the OpenAI custom skill identified by AName.
    /// If the registered skill ID differs from SkillID, the local skill-card
    /// file is updated accordingly.
    /// </summary>
    procedure CustomSkillRegister(const SkillID: string; const AName: string);

    /// <summary>
    /// Transcribes a local audio file with the OpenAI transcription API and
    /// resolves the full <c>TTranscription</c> result. The model defaults to
    /// Whisper (<c>whisper-1</c>); the container is inferred from the file. The
    /// returned promise rejects when the request fails, so callers chain their
    /// own <c>&amp;Then</c>/<c>&amp;Catch</c>.
    /// </summary>
    function AsyncTranscribe(const AAudioFilePath: string): TPromise<TTranscription>;

    /// <summary>
    /// Resolves all retrieve promises in parallel and yields the server-side
    /// filenames in the same order as the input IDs. The returned promise
    /// rejects on first failure.
    /// </summary>
    function WhenAllRetrieve(const IDs: TArray<string>): TPromise<TArray<string>>;

    /// <summary>
    /// Fire-and-forget download that saves the payload at LocalPath, then
    /// best-effort deletes the server-side file once the local copy is
    /// persisted (or once the download has definitively failed). The delete
    /// is itself fire-and-forget; failures are silent.
    /// </summary>
    procedure AsyncDownloadAs(const ID, LocalPath: string);

    /// <summary>
    /// Downloads one file produced in a Responses Code Interpreter container.
    /// Container files are intentionally left in place after download so a
    /// chained response can still reuse the active container.
    /// </summary>
    procedure AsyncDownloadContainerFileAs(
      const ContainerId, FileId, LocalPath: string);

    /// <summary>
    /// Fire-and-forget best-effort delete of one server-side file. Empty
    /// IDs are ignored. Errors are silent (404/already-deleted is normal
    /// after AsyncDownloadAs has already cleaned up).
    /// </summary>
    procedure AsyncDeleteFire(const ID: string);

    /// <summary>
    /// Bulk variant. Used to clean up prompt-attached file_ids
    /// (State.Files[i].FileId) once the assistant turn has consumed them.
    /// </summary>
    procedure AsyncDeleteAllFire(const IDs: TArray<string>);
  end;

implementation

var
  GSkillCardsJsonLock: TObject;

type
  TSkillCardFileUpdater = record
  public
    class function TryUpdateSkillId(const SkillCardsFileName, AName,
      NewId: string): Boolean; static;
  end;

  TPythiaQueuedMessage = record
  public
    class procedure Error(const Pythia: IPythiaBrowser; const Message: string); static;
    class procedure Success(const Pythia: IPythiaBrowser; const Message: string); static;
    class procedure Warning(const Pythia: IPythiaBrowser; const Message: string); static;
  end;

{ TSkillCardFileUpdater }

class function TSkillCardFileUpdater.TryUpdateSkillId(
  const SkillCardsFileName, AName, NewId: string): Boolean;
begin
  Result := False;
  var UpdatedSkillJsonAsString := '';

  if SkillCardsFileName.IsEmpty then
    Exit;

  TMonitor.Enter(GSkillCardsJsonLock);
  try
    if not FileExists(SkillCardsFileName) then
      Exit;

    var SkillJsonAsString := TFileIOHelper.LoadFromFile(SkillCardsFileName);

    Result := TSkillHelper.TryToUpdateID(
      SkillJsonAsString,
      AName,
      NewId,
      procedure (NewSkillsJsonAsString: string)
      begin
        UpdatedSkillJsonAsString := NewSkillsJsonAsString;
      end);

    if Result then
      TFileIOHelper.SaveToFile(SkillCardsFileName, UpdatedSkillJsonAsString);

  finally
    TMonitor.Exit(GSkillCardsJsonLock);
  end;
end;

{ TPythiaQueuedMessage }

class procedure TPythiaQueuedMessage.Error(
  const Pythia: IPythiaBrowser; const Message: string);
begin
  if not Assigned(Pythia) then
    Exit;

  TThread.Queue(nil,
    procedure
    begin
      if Assigned(Pythia) then
        Pythia.DisplayError(Message);
    end);
end;

class procedure TPythiaQueuedMessage.Success(
  const Pythia: IPythiaBrowser; const Message: string);
begin
  if not Assigned(Pythia) then
    Exit;

  TThread.Queue(nil,
    procedure
    begin
      if Assigned(Pythia) then
        Pythia.DisplaySuccess(Message);
    end);
end;

class procedure TPythiaQueuedMessage.Warning(
  const Pythia: IPythiaBrowser; const Message: string);
begin
  if not Assigned(Pythia) then
    Exit;

  TThread.Queue(nil,
    procedure
    begin
      if Assigned(Pythia) then
        Pythia.DisplayWarning(Message);
    end);
end;

type
  IFileRetrievalContext = interface
    ['{9E2F4D71-1C68-4A8E-9F3C-1A2B3C4D5E60}']
    function IsSettled: Boolean;
    procedure CompleteOne(Idx: Integer; const Filename: string);
    procedure SettleReject(const Msg: string);
    procedure DispatchAll;
  end;

  TFileRetrievalContext = class(TInterfacedObject, IFileRetrievalContext)
  private
    FClient: IGenAI;
    FIDs: TArray<string>;
    FNames: TArray<string>;
    FRemaining: Integer;
    FSettled: Boolean;
    FResolve: TProc<TArray<string>>;
    FReject: TProc<Exception>;
    procedure DispatchOne(Idx: Integer);
    procedure SettleResolve;
  public
    constructor Create(
      const AClient: IGenAI;
      const AIDs: TArray<string>;
      const AResolve: TProc<TArray<string>>;
      const AReject: TProc<Exception>);
    function IsSettled: Boolean;
    procedure CompleteOne(Idx: Integer; const Filename: string);
    procedure SettleReject(const Msg: string);
    procedure DispatchAll;
  end;

constructor TFileRetrievalContext.Create(
  const AClient: IGenAI;
  const AIDs: TArray<string>;
  const AResolve: TProc<TArray<string>>;
  const AReject: TProc<Exception>);
begin
  inherited Create;
  FClient := AClient;
  FIDs := AIDs;
  SetLength(FNames, Length(AIDs));
  FRemaining := Length(AIDs);
  FSettled := False;
  FResolve := AResolve;
  FReject := AReject;
end;

function TFileRetrievalContext.IsSettled: Boolean;
begin
  Result := FSettled;
end;

procedure TFileRetrievalContext.SettleResolve;
begin
  if FSettled then
    Exit;

  FSettled := True;
  if Assigned(FResolve) then
    FResolve(FNames);
end;

procedure TFileRetrievalContext.SettleReject(const Msg: string);
begin
  if FSettled then
    Exit;

  FSettled := True;
  try
    if Assigned(FReject) then
      FReject(Exception.Create(Msg));
  except
    {--- Last-resort guard: never let an exception escape the queued
         lambda, otherwise the outer promise stays pending forever and
         the surrounding flow never emits TFinalizeData. }
  end;
end;

procedure TFileRetrievalContext.CompleteOne(
  Idx: Integer;
  const Filename: string);
begin
  if FSettled then
    Exit;

  FNames[Idx] := Filename;
  Dec(FRemaining);

  if FRemaining = 0 then
    SettleResolve;
end;

procedure TFileRetrievalContext.DispatchOne(Idx: Integer);
var
  Ctx: IFileRetrievalContext;
  LocalId: string;
begin
  {--- Capture Self as an explicit IInterface so the inner async
       closures keep the context alive via refcount; do NOT let the
       compiler capture the bare Self pointer, which would not pin
       the object's lifetime and could leave a dangling reference. }
  Ctx := Self;
  LocalId := FIDs[Idx];

  try
    FClient.Files.AsyncAwaitRetrieve(LocalId)
      .&Then(
        procedure (Value: TFile)
        begin
          if Ctx.IsSettled then
            Exit;

          try
            Ctx.CompleteOne(Idx, Value.Filename);
          except
            on E: Exception do
              Ctx.SettleReject(Format('Files.Retrieve Then handler failed: %s (%s)',
                [E.Message, E.ClassName]));
          end;
        end)
      .&Catch(
        procedure (E: Exception)
        begin
          {--- Capture message immediately; CloneException on E later
               (inside the framework) may dereference a freed object
               or fail on an exotic class. Stringifying here is safe. }
          Ctx.SettleReject(Format('Files.Retrieve [%s] failed: %s (%s)',
            [LocalId, E.Message, E.ClassName]));
        end);
  except
    on E: Exception do
      Ctx.SettleReject(Format('Files.Retrieve [%s] sync setup failed: %s (%s)',
        [LocalId, E.Message, E.ClassName]));
  end;
end;

procedure TFileRetrievalContext.DispatchAll;
begin
  if FRemaining = 0 then
    begin
      SettleResolve;
      Exit;
    end;

  try
    for var index := Low(FIDs) to High(FIDs) do
      begin
        if FSettled then
          Break;

        DispatchOne(index);
      end;
  except
    on E: Exception do
      SettleReject(Format('WhenAllRetrieve loop failed: %s (%s)',
        [E.Message, E.ClassName]));
  end;
end;


{ TOpenAIClientUtils }

procedure TOpenAIClientUtils.AsyncDeleteAllFire(const IDs: TArray<string>);
begin
  for var index := Low(IDs) to High(IDs) do
    AsyncDeleteFire(IDs[index]);
end;

procedure TOpenAIClientUtils.AsyncDeleteFire(const ID: string);
begin
  if ID.Trim.IsEmpty then
    Exit;

  try
    FClient.Files.AsyncAwaitDelete(ID)
      .&Then(
        procedure (Value: TDeletion)
        begin
          {--- Best-effort: success is the expected case, no UI noise. }
        end)
      .&Catch(
        procedure (E: Exception)
        begin
          {--- Silent: 404 on an already-deleted id, or transient network
               errors, are not worth surfacing in the chat UI. The file is
               either gone or will be reaped by OpenAI's retention policy. }
        end);
  except
    {--- Sync setup failures (FClient in a degraded state) are also silent —
         this is best-effort cleanup, not a critical path. }
  end;
end;

procedure TOpenAIClientUtils.AsyncDownloadAs(const ID, LocalPath: string);
begin
  if ID.Trim.IsEmpty or LocalPath.Trim.IsEmpty then
    Exit;

  var FileId := ID.Trim;
  var TargetPath := LocalPath;

  try
    FClient.Files.AsynRetrieveContent(FileId,
      function: TAsynFileContent
      begin
        Result := Default(TAsynFileContent);

        Result.OnSuccess :=
          procedure(Sender: TObject; Value: TFileContent)
          begin
            try
              Value.SaveToFile(TargetPath);
              TPythiaQueuedMessage.Success(
                FPythia,
                Format('File downloaded: %s', [TargetPath]));
            except
              on E: Exception do
                TPythiaQueuedMessage.Error(
                  FPythia,
                  Format('File download failed: %s (%s)',
                    [TargetPath, E.Message]));
            end;

            AsyncDeleteFire(FileId);
          end;

        Result.OnError :=
          procedure(Sender: TObject; ErrorMessage: string)
          begin
            TPythiaQueuedMessage.Error(
              FPythia,
              Format('File download failed: %s (%s)',
                [TargetPath, ErrorMessage]));
            AsyncDeleteFire(FileId);
          end;
      end);
  except
    on E: Exception do
      begin
        TPythiaQueuedMessage.Error(
          FPythia,
          Format('File download dispatch failed: %s (%s)',
            [TargetPath, E.Message]));
        AsyncDeleteFire(FileId);
      end;
  end;
end;

procedure TOpenAIClientUtils.AsyncDownloadContainerFileAs(
  const ContainerId, FileId, LocalPath: string);
begin
  if ContainerId.Trim.IsEmpty or FileId.Trim.IsEmpty or
     LocalPath.Trim.IsEmpty then
    Exit;

  var CapturedContainerId := ContainerId.Trim;
  var CapturedFileId := FileId.Trim;
  var TargetPath := LocalPath;

  try
    FClient.ContainerFiles.AsyncAwaitGetContent(
      CapturedContainerId,
      CapturedFileId)
      .&Then(
        procedure(Value: TContainerFileContent)
        begin
          try
            Value.SaveToFile(TargetPath);
            TPythiaQueuedMessage.Success(
              FPythia,
              Format('File downloaded: %s', [TargetPath]));
          except
            on E: Exception do
              TPythiaQueuedMessage.Error(
                FPythia,
                Format('Container file download failed: %s (%s)',
                  [TargetPath, E.Message]));
          end;
        end)
      .&Catch(
        procedure(E: Exception)
        begin
          TPythiaQueuedMessage.Error(
            FPythia,
            Format('Container file download failed: %s (%s)',
              [TargetPath, E.Message]));
        end);
  except
    on E: Exception do
      TPythiaQueuedMessage.Error(
        FPythia,
        Format('Container file download dispatch failed: %s (%s)',
          [TargetPath, E.Message]));
  end;
end;

procedure TOpenAIClientUtils.ASyncSessionRename(const ChatID,
  ContentToSummarize: string);
begin
  var Model := MODEL_FOR_RENAMING;
  var Prompt := Format('Summarize the following message:'#10'%s', [ContentToSummarize]);
  var SystemPrompt :=
    '# Rules :' + slineBreak +
    '- Do not comment on your answer' + slineBreak +
    '- Display only the answer' + slineBreak +
    '- Do not use articles or pronouns' + slineBreak +
    '- Write at most 4 words' + sLineBreak +
    '- No final punctuation';

  var Payload: TResponsesParamsProc :=
    procedure (Params: TResponsesParams)
    begin
      Params
        .Model(Model)
        .Instructions(SystemPrompt)
        .Input(Prompt)
        .MaxOutputTokens(32);
    end;

  FClient.Responses.AsyncAwaitCreate(Payload)
    .&Then(
      procedure (Value: TResponse)
      begin
        var Name := '';

        for var Item in Value.Output do
          begin
            for var SubItem in Item.Content do
              Name := Name + SubItem.Text;
          end;

        if Name.IsEmpty then
          Exit;

        if not Assigned(FPythia)  then
          Exit;

        if not Assigned(FPythia.PersistentChat) then
          Exit;

        FPythia.PersistentChat.UpdateChatTitleById(ChatID, Name);
        FPythia.PersistentChat.SaveToFile();

        FPythia.ChatSessionRename(ChatID, Name);

      end)
    .&Catch(
      procedure (E: Exception)
      begin
        TPythiaQueuedMessage.Error(
          FPythia,
          Format('Session rename failed: %s (%s)',
            [E.Message, E.ClassName]));
      end);
end;

procedure TOpenAIClientUtils.CustomSkillRegister(
  const SkillID,
  AName: string);
begin
  if not Assigned(FPythia) then
    Exit;

  var Folder := TPath.Combine(FPythia.GetAppRawName, AName);
  var SkillCardsFileName := FPythia.GetSkillCardsFileName;
  if not FileExists(SkillCardsFileName) then
    Exit;

  if not TDirectory.Exists(Folder) then
    begin
      FPythia.DisplayError(Format('Custom skill folder not found: %s', [Folder]));
      Exit;
    end;

  var Pythia := FPythia;
  var CardSkillID := SkillID;

  TTask.Run(
    procedure
    var
      RegisteredSkillID: string;
      SkillCreated: Boolean;
    begin
      try
        SkillCreated := False;
        RegisteredSkillID := FindCustomSkillIDByName(AName);

        if RegisteredSkillID.IsEmpty then
          begin
            RegisteredSkillID := SkillRegister(AName, Folder);
            SkillCreated := True;
          end;

        if RegisteredSkillID.IsEmpty then
          Exit;

        if CardSkillID <> RegisteredSkillID then
          begin
            if TSkillCardFileUpdater.TryUpdateSkillId(
              SkillCardsFileName,
              AName,
              RegisteredSkillID) then
              TPythiaQueuedMessage.Success(Pythia, Format('Custom skill card updated: %s', [RegisteredSkillID]))
            else
              TPythiaQueuedMessage.Warning(Pythia, Format('Custom skill card update failed: %s', [AName]));
          end;

        if SkillCreated then
          TPythiaQueuedMessage.Success(Pythia, Format('Custom skill registered: %s', [RegisteredSkillID]))
        else
          TPythiaQueuedMessage.Success(Pythia, Format('Custom skill found: %s', [RegisteredSkillID]));
      except
        on E: Exception do
          TPythiaQueuedMessage.Error(Pythia, Format('Custom skill registration failed (%s): %s', [AName, E.Message]));
      end;
    end);
end;

constructor TOpenAIClientUtils.Create(const AClient: IGenAI;
  const ABrowser: IPythiaBrowser);
begin
  inherited Create;
  FClient := AClient;
  FPythia := ABrowser;
end;

function TOpenAIClientUtils.AsyncTranscribe(
  const AAudioFilePath: string): TPromise<TTranscription>;
begin
  var AudioFile := AAudioFilePath;

  var Model := OPENAI_DEFAULT_TRANSCRIPTION_MODEL;

  {--- Build the request through the SDK parameter object and hand back the
       transcription promise as-is. The container (mp3/wav/webm/...) is
       inferred from the file by the OpenAI endpoint. }
  Result := FClient.Audio.AsyncAwaitTranscription(
    procedure (Params: TTranscriptionParams)
    begin
      Params
        .Model(Model)
        .&File(AudioFile)
        .ResponseFormat('json');
    end);
end;

function TOpenAIClientUtils.FindCustomSkillIDByName(
  const AName: string): string;
begin
  Result := '';

  var After := '';
  repeat
    var SkillList := FClient.Skills.List(
      procedure (Params: TUrlSkillsParams)
      begin
        Params.Limit(100);

        if not After.IsEmpty then
          Params.After(After);
      end);

    try
      for var Item in SkillList.Data do
        if SameText(Item.Name, AName) then
          Exit(Item.Id);

      if SkillList.HasMore and not SkillList.LastId.IsEmpty then
        After := SkillList.LastId
      else
        After := '';
    finally
      SkillList.Free;
    end;
  until After.IsEmpty;
end;

function TOpenAIClientUtils.SkillRegister(
  const AName,
  Folder: string): string;
begin
  Result := '';

  var Files := TDirectory.GetFiles(Folder, '*', TSearchOption.soAllDirectories);
  if Length(Files) = 0 then
    raise Exception.CreateFmt('Custom skill folder is empty: %s', [Folder]);

  var Skill := FClient.Skills.Create(
    procedure (Params: TSkillCreateParams)
    begin
      Params.Files(Files);
    end);

  try
    Result := Skill.Id;
  finally
    Skill.Free;
  end;
end;

function TOpenAIClientUtils.WhenAllRetrieve(
  const IDs: TArray<string>): TPromise<TArray<string>>;
begin
  Result := TPromise<TArray<string>>.Create(
    procedure (Resolve: TProc<TArray<string>>; Reject: TProc<Exception>)
    begin
      var Ctx: IFileRetrievalContext :=
        TFileRetrievalContext.Create(FClient, IDs, Resolve, Reject);
      Ctx.DispatchAll;
    end);
end;

initialization
  GSkillCardsJsonLock := TObject.Create;

finalization
  GSkillCardsJsonLock.Free;

end.
