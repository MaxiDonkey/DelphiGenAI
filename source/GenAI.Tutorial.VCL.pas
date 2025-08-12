unit GenAI.Tutorial.VCL;

{ Tutorial Support Unit

   WARNING:
     This module is intended solely to illustrate the examples provided in the
     README.md file of the repository :
          https://github.com/MaxiDonkey/DelphiGenAI
     Under no circumstances should the methods described below be used outside
     of the examples presented on the repository's page.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.UITypes, Vcl.MPlayer, system.JSON, GenAI, GenAI.Types;

type
  TToolProc = procedure (const Value: string) of object;

  /// <summary>
  /// Represents a tutorial hub for handling visual components in a Delphi application,
  /// including text display, button interactions, and navigation through pages.
  /// </summary>
  TVCLTutorialHub = class
  private
    FMemo1: TMemo;
    FMemo2: TMemo;
    FMemo3: TMemo;
    FImage: TImage;
    FButton: TButton;
    FModelId: string;
    FFileName: string;
    FTool: IFunctionCore;
    FToolCall: TToolProc;
    FCancel: Boolean;
    FMediaPlayer: TMediaPlayer;
    FClient: IGenAI;
    FId: string;
    FAudioId: string;
    FTranscript: string;
    procedure OnButtonClick(Sender: TObject);
    procedure SetButton(const Value: TButton);
    procedure SetMemo1(const Value: TMemo);
    procedure SetFileName(const Value: string);
    procedure SetMemo2(const Value: TMemo);
    procedure SetMemo3(const Value: TMemo);
    procedure SetJSONRequest(const Value: string);
    procedure SetJSONResponse(const Value: string);
  public
    /// <summary>
    /// Play audio using the mediaplayer.
    /// </summary>
    procedure PlayAudio;
    /// <summary>
    /// Gets or sets IGenAI interface.
    /// </summary>
    property Client: IGenAI read FClient write FClient;
    /// <summary>
    /// Gets or sets the first memo component for displaying messages or data.
    /// </summary>
    property Memo1: TMemo read FMemo1 write SetMemo1;
    /// <summary>
    /// Gets or sets the second memo component for displaying messages or data.
    /// </summary>
    property Memo2: TMemo read FMemo2 write SetMemo2;
    /// <summary>
    /// Gets or sets the third memo component for displaying messages or data.
    /// </summary>
    property Memo3: TMemo read FMemo3 write SetMemo3;
    /// <summary>
    /// Sets text Timage component.
    /// </summary>
    property Image: TImage read FImage write FImage;
    /// <summary>
    /// Sets text for displaying JSON request.
    /// </summary>
    property JSONRequest: string write SetJSONRequest;
    /// <summary>
    /// Sets text for displaying JSON response.
    /// </summary>
    property JSONResponse: string write SetJSONResponse;
    /// <summary>
    /// Gets or sets the button component used to trigger actions or handle cancellation.
    /// </summary>
    property Button: TButton read FButton write SetButton;
    /// <summary>
    /// Gets or sets a value indicating whether the operation has been canceled.
    /// </summary>
    property Cancel: Boolean read FCancel write FCancel;
    /// <summary>
    /// Gets or sets the model identifier associated with the tutorial hub.
    /// </summary>
    property ModelId: string read FModelId write FModelId;
    /// <summary>
    /// Gets or sets the filename associated with the tutorial hub.
    /// </summary>
    property FileName: string read FFileName write SetFileName;
    /// <summary>
    /// Gets or sets the core function tool used for processing.
    /// </summary>
    property Tool: IFunctionCore read FTool write FTool;
    /// <summary>
    /// Gets or sets the procedure for handling tool-specific calls.
    /// </summary>
    property ToolCall: TToolProc read FToolCall write FToolCall;
    /// <summary>
    /// Gets or sets the ID to simplify its usage.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    /// Gets or sets the ID used to manage audio references.
    /// </summary>
    property AudioId: string read FAudioId write FAudioId;
    /// <summary>
    /// Gets or sets the transcript with audio response.
    /// </summary>
    property Transcript: string read FTranscript write FTranscript;
    /// <summary>
    /// Gets or sets a TMediaplayer.
    /// </summary>
    property MediaPlayer: TMediaPlayer read FMediaPlayer write FMediaPlayer;
    procedure DisplayWeatherStream(const Value: string);
    procedure DisplayWeatherAudio(const Value: string);
    procedure SpeechChat(const  Value: string);
    procedure JSONRequestClear;
    procedure JSONResponseClear;
    constructor Create(const AClient: IGenAI; const AMemo1, AMemo2, AMemo3: TMemo;
      const AImage: TImage; const AButton: TButton; const AMediaPlayer: TMediaPlayer);
  end;

  procedure Cancellation(Sender: TObject);
  function DoCancellation: Boolean;
  procedure Start(Sender: TObject);

  procedure Display(Sender: TObject); overload;
  procedure Display(Sender: TObject; Value: string); overload;
  procedure Display(Sender: TObject; Value: TArray<string>); overload;
  procedure Display(Sender: TObject; Value: TModel); overload;
  procedure Display(Sender: TObject; Value: TModels); overload;
  procedure Display(Sender: TObject; Value: TDeletion); overload;
  procedure Display(Sender: TObject; Value: TEmbedding); overload;
  procedure Display(Sender: TObject; Value: TEmbeddings); overload;
  procedure Display(Sender: TObject; Value: TSpeechResult); overload;
  procedure Display(Sender: TObject; Value: TTranscription); overload;
  procedure Display(Sender: TObject; Value: TTranslation); overload;
  procedure Display(Sender: TObject; Value: TChat); overload;
  procedure Display(Sender: TObject; Value: TModeration); overload;
  procedure Display(Sender: TObject; Value: TModerationResult); overload;
  procedure Display(Sender: TObject; Value: TGeneratedImages); overload;
  procedure Display(Sender: TObject; Value: TFile); overload;
  procedure Display(Sender: TObject; Value: TFiles); overload;
  procedure Display(Sender: TObject; Value: TFileContent); overload;
  procedure Display(Sender: TObject; Value: TUpload); overload;
  procedure Display(Sender: TObject; Value: TUploadPart); overload;
  procedure Display(Sender: TObject; Value: TBatch); overload;
  procedure Display(Sender: TObject; Value: TBatches); overload;
  procedure Display(Sender: TObject; Value: TCompletion); overload;
  procedure Display(Sender: TObject; Value: TVectorStore); overload;
  procedure Display(Sender: TObject; Value: TVectorStores); overload;
  procedure Display(Sender: TObject; Value: TVectorStoreFile); overload;
  procedure Display(Sender: TObject; Value: TVectorStoreFiles); overload;
  procedure Display(Sender: TObject; Value: TVectorStoreBatch); overload;
  procedure Display(Sender: TObject; Value: TVectorStoreBatches); overload;
  procedure Display(Sender: TObject; Value: TAssistant); overload;
  procedure Display(Sender: TObject; Value: TAssistants); overload;
  procedure Display(Sender: TObject; Value: TThreads); overload;
  procedure Display(Sender: TObject; Value: TMessages); overload;
  procedure Display(Sender: TObject; Value: TMessagesList); overload;
  procedure Display(Sender: TObject; Value: TRun); overload;
  procedure Display(Sender: TObject; Value: TRuns); overload;
  procedure Display(Sender: TObject; Value: TRunStep); overload;
  procedure Display(Sender: TObject; Value: TRunSteps); overload;
  procedure Display(Sender: TObject; Value: TResponse); overload;
  procedure Display(Sender: TObject; Value: TResponseDelete); overload;
  procedure Display(Sender: TObject; Value: TResponses); overload;
  procedure Display(Sender: TObject; Value: TChatMessages); overload;
  procedure Display(Sender: TObject; Value: TChatCompletion); overload;
  procedure Display(Sender: TObject; Value: TChatDelete); overload;
  procedure Display(Sender: TObject; Value: TResponseItem); overload;

  procedure DisplayStream(Sender: TObject; Value: string); overload;
  procedure DisplayStream(Sender: TObject; Value: TChat); overload;
  procedure DisplayStream(Sender: TObject; Value: TCompletion); overload;
  procedure DisplayStream(Sender: TObject; Value: TResponseStream); overload;

  procedure DisplayChunk(Value: string); overload;
  procedure DisplayChunk(Value: TChat); overload;
  procedure DisplayChunk(Value: TCompletion); overload;
  procedure DisplayChunk(Value: TResponseStream); overload;

  procedure DisplayAudio(Sender: TObject; Value: TChat);
  procedure DisplayAudioEx(Sender: TObject; Value: TChat);

  function F(const Name, Value: string): string; overload;
  function F(const Name: string; const Value: TArray<string>): string; overload;
  function F(const Name: string; const Value: boolean): string; overload;
  function F(const Name: string; const State: Boolean; const Value: Double): string; overload;

var
  /// <summary>
  /// A global instance of the <see cref="TVCLTutorialHub"/> class used as the main tutorial hub.
  /// </summary>
  /// <remarks>
  /// This variable serves as the central hub for managing tutorial components, such as memos, buttons, and pages.
  /// It is initialized dynamically during the application's runtime, and its memory is automatically released during
  /// the application's finalization phase.
  /// </remarks>
  TutorialHub: TVCLTutorialHub = nil;

implementation

procedure Cancellation(Sender: TObject);
begin
  if TutorialHub.Cancel then
    begin
      Display(Sender, 'The operation was cancelled');
      Display(Sender);
      TutorialHub.Cancel := False;
    end;
end;

function DoCancellation: Boolean;
begin
  Result := TutorialHub.Cancel;
end;

procedure Start(Sender: TObject);
begin
  Display(Sender, 'Please wait...');
  Display(Sender);
  TutorialHub.Cancel := False;
  TutorialHub.JSONResponseClear;
end;

procedure Display(Sender: TObject; Value: string);
var
  M: TMemo;
begin
  if Sender is TMemo then
    M := TMemo(Sender) else
    M := (Sender as TVCLTutorialHub).Memo1;

  var S := Value.Split([#10]);
  if System.Length(S) = 0 then
    begin
      M.Lines.Add(Value)
    end
  else
    begin
      for var Item in S do
        M.Lines.Add(Item);
    end;

  M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure Display(Sender: TObject; Value: TArray<string>);
begin
  var index := 0;
  for var Item in Value do
    begin
      if not Item.IsEmpty then
        begin
          if index = 0 then
            Display(Sender, Item) else
            Display(Sender, '    ' + Item);
        end;
      Inc(index);
    end;
end;

procedure Display(Sender: TObject);
begin
  Display(Sender, sLineBreak);
end;

procedure Display(Sender: TObject; Value: TModel);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    EmptyStr,
    F('id', Value.Id),
    F('object', Value.&Object),
    F('owned_by', Value.OwnedBy),
    F('created', Value.CreatedAsString)
  ]);
  Display(Sender, EmptyStr);
end;

procedure Display(Sender: TObject; Value: TModels);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, 'Models list');
  if System.Length(Value.Data) = 0 then
    begin
      Display(Sender, 'No model found');
      Exit;
    end;
  for var Item in Value.Data do
    begin
      Display(Sender, Item);
      Application.ProcessMessages;
    end;
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TDeletion);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    EmptyStr,
    F('id', Value.Id),
    F('object', Value.&Object),
    F('deleted', BoolToStr(Value.Deleted, True))
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TEmbedding);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  var index := 1;
  for var Item in Value.Embedding do
    begin
      Display(Sender, F(Format('V[%d]', [index]), Item.ToString(ffNumber, 2, 6)));
      Inc(index);
    end;
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TEmbeddings);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
end;

procedure Display(Sender: TObject; Value: TSpeechResult);
begin
  {--- Display the JSON response }
  TutorialHub.JSONResponse := Value.JSONResponse;

  {--- The file name can not be null }
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');

  {--- Save the audio into a file. }
  Value.SaveToFile(TutorialHub.FileName);

  {--- Play the audio result }
  TutorialHub.PlayAudio;
end;

procedure Display(Sender: TObject; Value: TTranscription);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, Value.Text);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TTranslation);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, Value.Text);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TChat);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Choices do
    if Item.FinishReason = TFinishReason.tool_calls then
      begin
        if Assigned(TutorialHub.ToolCall) then
          begin
            for var Func in Item.Message.ToolCalls do
              begin
                Display(Sender, Func.&function.Arguments);
                var Evaluation := TutorialHub.Tool.Execute(Func.&function.Arguments);
                Display(Sender, Evaluation);
                Display(Sender);
                TutorialHub.ToolCall(Evaluation);
              end;
          end;
      end
    else
      begin
        Display(Sender, Item.Message.Content);
      end;
  Display(Sender, sLineBreak);
end;

procedure Display(Sender: TObject; Value: TModeration);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Results do
    Display(Sender, Item);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TModerationResult);
begin
  for var Item in Value.FlaggedDetail do
    Display(Sender, [
      EmptyStr,
      F(Item.Category.ToString, Item.Score.ToString(ffNumber, 3, 3))
    ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TGeneratedImages);
begin
  {--- Load image when url is not null. }
  if not TutorialHub.FileName.IsEmpty then
    begin
      if not Value.Data[0].Url.IsEmpty then
        Value.Data[0].Download(TutorialHub.FileName) else
        Value.Data[0].SaveToFile(TutorialHub.FileName);
    end;

  {--- Load image into a stream }
  var Stream := Value.Data[0].GetStream;
  try
    {--- Display the JSON response. }
    TutorialHub.JSONResponse := Value.JSONResponse;

    {--- Display the revised prompt. }
    Display(Sender, Value.Data[0].RevisedPrompt);

    {--- Load the stream into the TImage. }
    TutorialHub.Image.Picture.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure Display(Sender: TObject; Value: TFile);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    Value.Filename,
    F('id', [
      Value.Id,
      F('purpose', Value.Purpose.ToString),
      F('created_at', Value.CreatedAtAsString)
    ])
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TFiles);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TFileContent);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, Value.Content);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TUpload);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(TutorialHub, [
      F(Value.Id, Value.&Object),
      F(Value.Filename, Value.Bytes.ToString),
      Value.Purpose.ToString,
      Value.Status,
      Value.CreatedAtAsString,
      Value.ExpiresAtAsString
    ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TUploadPart);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(TutorialHub, [
      Value.Id,
      F(Value.&Object, F('upload_id', Value.UploadId)) //,
//      Value.CreatedAtAsString
    ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TBatch);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;

  Display(Sender, [
      Value.Id,
      F('endpoint', Value.Endpoint),
      F('output_file_id', Value.OutputFileId),
      F('Status', Value.Status.ToString),
      F('in_progress_at', Value.InProgressAtAsString),
      F('expires_at', Value.ExpiresAtAsString),
      F('metadata', Value.Metadata)
    ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TBatches);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender, [
    F('has more', BoolToStr(Value.HasMore, True)),
    F('first_id', Value.FirstId),
    F('last_id', Value.LastId)
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TCompletion);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Choices do
    Display(Sender, Item.Text);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TVectorStore);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('object', Value.&Object),
    F('name', Value.Name),
    F('created_at', Value.CreatedAtAsString),
    F('metadata', Value.Metadata)
  ]);
  Display(Sender, sLineBreak);
end;

procedure Display(Sender: TObject; Value: TVectorStores);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    begin
      Display(Sender, Item);
    end;
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TVectorStoreFile);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('object', Value.&Object),
    F('usage_bytes', Value.UsageBytes.ToString),
    F('status', Value.Status.ToString)
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TVectorStoreFiles);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TVectorStoreBatch);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('object', Value.&Object),
    F('vector_store_id', Value.VectorStoreId),
    F('status', Value.Status.ToString)
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TVectorStoreBatches);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender)
end;

procedure Display(Sender: TObject; Value: TAssistant);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('object', Value.&Object),
    F('name', Value.Name),
    F('model', Value.Model)
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TAssistants);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender)
end;

procedure Display(Sender: TObject; Value: TThreads);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('object', Value.&Object),
    F('created_at', Value.CreatedAtAsString)
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TMessages);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, F('id', [Value.Id, F('status', Value.Status.ToString)]));
  for var Item in Value.Content do
    Display(Sender, Item.Text.Value);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TMessagesList);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TRun);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('status',Value.Status.ToString),
    F('thread_id', Value.ThreadId),
    F('assistant_id', Value.AssistantId),
    F('expires_at', Value.ExpiresAtAsString)
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TRuns);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TRunStep);
begin
  if not Value.JSONResponse.IsEmpty then
    TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('status',Value.Status.ToString),
    F('thread_id', Value.ThreadId),
    F('assistant_id', Value.AssistantId),
    F('run_id', Value.RunId),
    F('step_details.type', Value.StepDetails.&Type.ToString),
    F('step_details.message_creation.MessageId', Value.StepDetails.MessageCreation.MessageId)
  ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TRunSteps);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    Display(Sender, Item);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TResponse);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Output do
    begin
      if Item.&Type = TResponseTypes.function_call then
        begin
           Display(Sender, Item.Arguments);
           var Evaluation := TutorialHub.Tool.Execute(Item.Arguments);
           Display(Sender, Evaluation);
           Display(Sender);
           TutorialHub.ToolCall(Evaluation);
        end
      else
        begin
          for var inst in Value.Instructions do
            begin
              Display(Sender, '* ' + inst.&Type);
              Display(Sender, '* ' + inst.Role.ToString);
              for var Content in inst.Content do
                begin
                  if not Content.Text.IsEmpty then
                  Display(Sender, '  * ' + Content.Text);
                end;
            end;
          Display(Sender);


          for var SubItem in Item.Content do
            Display(Sender, SubItem.Text);
        end;
    end;
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TResponseDelete);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, [
    F('id', Value.Id),
    F('object', Value.&Object),
    F('deleted', BoolToStr(Value.Deleted, True))
  ]);
end;

procedure Display(Sender: TObject; Value: TResponses);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    begin
      Display(Sender, Item);
    end;
end;

procedure Display(Sender: TObject; Value: TChatMessages);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    begin
      Display(Sender, Item.Content);
      Display(Sender);
    end;
end;

procedure Display(Sender: TObject; Value: TChatCompletion);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Data do
    begin
      for var SubItem in Item.Choices do
        begin
          Display(Sender, SubItem.Message.Content);
          Display(Sender);
        end;
    end;
end;

procedure Display(Sender: TObject; Value: TChatDelete);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  Display(Sender, Value.Id);
  Display(Sender, F('Deleted', BoolToStr(Value.Deleted, True)));
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TResponseItem);
begin
  Display(Sender, Value.Id);
  for var Item in Value.Content do
    begin
      Display(Sender, Item.Text);
    end;
  Display(Sender);
end;

procedure DisplayStream(Sender: TObject; Value: string);
var
  M   : TMemo;
  Txt : string;
begin
  if Value.IsEmpty then Exit;

  if Sender is TMemo then
    M := TMemo(Sender)
  else
    M := (Sender as TVCLTutorialHub).Memo1;

  Txt := StringReplace(Value, '\n', sLineBreak, [rfReplaceAll]);
  Txt := StringReplace(Txt, #10,  sLineBreak, [rfReplaceAll]);

  M.Lines.BeginUpdate;
  try
    M.SelStart   := M.GetTextLen;
    M.SelLength  := 0;
    M.SelText    := Txt;
  finally
    M.Lines.EndUpdate;
  end;

  M.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure DisplayStream(Sender: TObject; Value: TChat);
begin
  if Assigned(Value) then
    begin
      for var Item in Value.Choices do
        begin
          DisplayStream(Sender, Item.Delta.Content);
        end;
      DisplayChunk(Value);
    end;
end;

procedure DisplayStream(Sender: TObject; Value: TCompletion);
begin
  if Assigned(Value) then
    begin
      DisplayStream(Sender, Value.Choices[0].Text);
      DisplayChunk(Value);
    end;
end;

procedure DisplayStream(Sender: TObject; Value: TResponseStream);
begin
  if Assigned(Value) then
    begin
      if Value.&Type = TResponseStreamType.output_text_delta then
        DisplayStream(Sender, Value.Delta);
      DisplayChunk(Value);
    end;
end;

procedure DisplayChunk(Value: TChat);
begin
  DisplayChunk(Value.JSONResponse);
end;

procedure DisplayChunk(Value: string);
begin
  var JSONValue := TJSONObject.ParseJSONValue(Value);
  TutorialHub.Memo3.Lines.BeginUpdate;
  try
    Display(TutorialHub.Memo3, JSONValue.ToString);
  finally
    TutorialHub.Memo3.Lines.EndUpdate;
    JSONValue.Free;
  end;
end;

procedure DisplayChunk(Value: TCompletion);
begin
  DisplayChunk(Value.JSONResponse);
end;

procedure DisplayChunk(Value: TResponseStream);
begin
  DisplayChunk(Value.JSONResponse);
end;

procedure DisplayAudio(Sender: TObject; Value: TChat);
begin
  {--- Display the JSON response }
  TutorialHub.JSONResponse := Value.JSONResponse;

  {--- We need an audio filename for the tutorial }
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');

  {--- Store the audio Id. }
  TutorialHub.AudioId := Value.Choices[0].Message.Audio.Id;

  {--- Store the audio transcript. }
  TutorialHub.Transcript := Value.Choices[0].Message.Audio.Transcript;

  {--- The audio response is stored in a file. }
  Value.Choices[0].Message.Audio.SaveToFile(TutorialHub.FileName);

  {--- Display the textual response. }
  Display(Sender, Value.Choices[0].Message.Audio.Transcript);

  {--- Play audio response. }
  TutorialHub.PlayAudio;
  Display(Sender, sLineBreak);
end;

procedure DisplayAudioEx(Sender: TObject; Value: TChat);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  DisplayStream(Sender, Value.Choices[0].Message.Content);
  TutorialHub.SpeechChat(Value.Choices[0].Message.Content);
end;

function F(const Name, Value: string): string;
begin
  if not Value.IsEmpty then
    Result := Format('%s: %s', [Name, Value])
end;

function F(const Name: string; const Value: TArray<string>): string;
begin
  var index := 0;
  for var Item in Value do
    begin
      if index = 0 then
        Result := Format('%s: %s', [Name, Item]) else
        Result := Result + '    ' + Item;
      Inc(index);
    end;
end;

function F(const Name: string; const Value: boolean): string;
begin
  Result := Format('%s: %s', [Name, BoolToStr(Value, True)])
end;

function F(const Name: string; const State: Boolean; const Value: Double): string;
begin
  Result := Format('%s (%s): %s%%', [Name, BoolToStr(State, True), (Value * 100).ToString(ffNumber, 3, 2)])
end;

{ TVCLTutorialHub }

constructor TVCLTutorialHub.Create(const AClient: IGenAI; const AMemo1, AMemo2, AMemo3: TMemo;
  const AImage: TImage; const AButton: TButton; const AMediaPlayer: TMediaPlayer);
begin
  inherited Create;
  Memo1 := AMemo1;
  Memo2 := AMemo2;
  Memo3 := AMemo3;
  Image := AImage;
  Button := AButton;
  FMediaPlayer := AMediaPlayer;
  Client := AClient;
end;

procedure TVCLTutorialHub.DisplayWeatherAudio(const Value: string);
begin
  FileName := 'AudioWeather.mp3';

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('verse', 'mp3');
      Params.Messages([
        FromSystem('You are a weather presenter on a prime time TV channel.'),
        FromUser(Value)
      ]);
      Params.MaxCompletionTokens(1024);
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);
end;

procedure TVCLTutorialHub.DisplayWeatherStream(const Value: string);
begin
  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
          FromSystem('You are a weather presenter on a prime time TV channel.'),
          FromUser(Value)]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
end;

procedure TVCLTutorialHub.JSONRequestClear;
begin
  Memo2.Clear;
end;

procedure TVCLTutorialHub.JSONResponseClear;
begin
  Memo3.Clear;
end;

procedure TVCLTutorialHub.OnButtonClick(Sender: TObject);
begin
  Cancel := True;
end;

procedure TVCLTutorialHub.PlayAudio;
begin
  with TutorialHub.MediaPlayer do
    begin
      FileName := TutorialHub.FileName;
      Open;
      Play;
    end;
end;

procedure TVCLTutorialHub.SetButton(const Value: TButton);
begin
  FButton := Value;
  FButton.OnClick := OnButtonClick;
  FButton.Caption := 'Cancel';
end;

procedure TVCLTutorialHub.SetFileName(const Value: string);
begin
  FFileName := Value;
  FMediaPlayer.Close;
end;

procedure TVCLTutorialHub.SetJSONRequest(const Value: string);
begin
  Memo2.Lines.Text := Value;
  Memo2.SelStart := 0;
  Application.ProcessMessages;
end;

procedure TVCLTutorialHub.SetJSONResponse(const Value: string);
begin
  Memo3.Lines.Text := Value;
  Memo2.SelStart := 0;
  Application.ProcessMessages;
end;

procedure TVCLTutorialHub.SetMemo1(const Value: TMemo);
begin
  FMemo1 := Value;
  FMemo1.ScrollBars := TScrollStyle.ssVertical;
end;

procedure TVCLTutorialHub.SetMemo2(const Value: TMemo);
begin
  FMemo2 := Value;
  FMemo2.ScrollBars := TScrollStyle.ssBoth;
end;

procedure TVCLTutorialHub.SetMemo3(const Value: TMemo);
begin
  FMemo3 := Value;
  FMemo3.ScrollBars := TScrollStyle.ssBoth;
end;

procedure TVCLTutorialHub.SpeechChat(const Value: string);
begin
  FileName := 'SpeechChat.mp3';

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('ash', 'mp3');
      Params.Messages([
        FromUser(Value)
      ]);
      Params.MaxCompletionTokens(1024);
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);
end;

initialization
finalization
  if Assigned(TutorialHub) then
    TutorialHub.Free;
end.
