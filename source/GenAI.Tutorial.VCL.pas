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
  System.UITypes, Vcl.MPlayer,
  GenAI, GenAI.Types, GenAI.Functions.Core, GenAI.Models, GenAI.Embeddings, GenAI.Chat;

type
  TToolProc = procedure (const Value: string) of object;

  /// <summary>
  /// Represents a tutorial hub for handling visual components in a Delphi application,
  /// including text display, button interactions, and navigation through pages.
  /// </summary>
  TVCLTutorialHub = class
  private
    FMemo1: TMemo;
    FButton: TButton;
    FModelId: string;
    FFileName: string;
    FTool: IFunctionCore;
    FToolCall: TToolProc;
    FCancel: Boolean;
    FMediaPlayer: TMediaPlayer;
    FClient: IGenAI;
    procedure OnButtonClick(Sender: TObject);
    procedure SetButton(const Value: TButton);
    procedure SetMemo1(const Value: TMemo);
    procedure SetFileName(const Value: string);
  public
    procedure PlayAudio;
    property Client: IGenAI read FClient write FClient;
    //AudioId

    /// <summary>
    /// Gets or sets the first memo component for displaying messages or data.
    /// </summary>
    property Memo1: TMemo read FMemo1 write SetMemo1;
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

    property MediaPlayer: TMediaPlayer read FMediaPlayer write FMediaPlayer;
    procedure DisplayWeatherStream(const Value: string);
    procedure DisplayWeatherAudio(const Value: string);
    procedure SpeechChat(const  Value: string);
    constructor Create(const AClient: IGenAI; const AMemo1: TMemo; const AButton: TButton; const AMediaPlayer: TMediaPlayer);
  end;

  procedure Cancellation(Sender: TObject);
  function DoCancellation: Boolean;
  procedure Start(Sender: TObject);

  procedure Display(Sender: TObject); overload;
  procedure Display(Sender: TObject; Value: string); overload;
  procedure Display(Sender: TObject; Value: TArray<string>); overload;
  procedure Display(Sender: TObject; Value: TModel); overload;
  procedure Display(Sender: TObject; Value: TModels); overload;
  procedure Display(Sender: TObject; Value: TModelDeletion); overload;
  procedure Display(Sender: TObject; Value: TEmbedding); overload;
  procedure Display(Sender: TObject; Value: TEmbeddings); overload;
  procedure Display(Sender: TObject; Value: TSpeechResult); overload;
  procedure Display(Sender: TObject; Value: TTranscription); overload;
  procedure Display(Sender: TObject; Value: TTranslation); overload;
  procedure Display(Sender: TObject; Value: TChat); overload;

  procedure DisplayStream(Sender: TObject; Value: string); overload;
  procedure DisplayStream(Sender: TObject; Value: TChat); overload;

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

uses
  System.DateUtils;

function UnixIntToDateTime(const Value: Int64): TDateTime;
begin
  Result := TTimeZone.Local.ToLocalTime(UnixToDateTime(Value));
end;

function UnixDateTimeToString(const Value: Int64): string;
begin
  Result := DateTimeToStr(UnixIntToDateTime(Value))
end;

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
  Display(Sender, [
    EmptyStr,
    F('id', Value.Id),
    F('object', Value.&Object),
    F('owned_by', Value.OwnedBy),
    F('created', UnixDateTimeToString(Value.Created))
  ]);
  Display(Sender, EmptyStr);
  Display(Sender, Value.JSONResponse);
end;

procedure Display(Sender: TObject; Value: TModels);
begin
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
  Display(Sender, Value.JSONResponse);
end;

procedure Display(Sender: TObject; Value: TModelDeletion);
begin
  Display(Sender, [
    EmptyStr,
    F('id', Value.Id),
    F('object', Value.&Object),
    F('deleted', BoolToStr(Value.Deleted, True))
  ]);
  Display(Sender);
  Display(Sender, Value.JSONResponse);
end;

procedure Display(Sender: TObject; Value: TEmbedding);
begin
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
  for var Item in Value.Data do
    Display(Sender, Item);
end;

procedure Display(Sender: TObject; Value: TSpeechResult);
begin
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');
  Value.SaveToFile(TutorialHub.FileName);
  TutorialHub.PlayAudio;
end;

procedure Display(Sender: TObject; Value: TTranscription);
begin
  Display(Sender, Value.Text);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TTranslation);
begin
  Display(Sender, Value.Text);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TChat);
begin
  for var Item in Value.Choices do
    if Item.FinishReason = TFinishReason.fr_tool_calls then
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
  Display(Sender, Value.JSONResponse);
end;

procedure DisplayStream(Sender: TObject; Value: string);
var
  M: TMemo;
  CurrentLine: string;
  Lines: TArray<string>;
begin
  if Value.Trim.IsEmpty then
    Exit;
  if Sender is TMemo then
    M := TMemo(Sender) else
    M := (Sender as TVCLTutorialHub).Memo1;
  var OldSelStart := M.SelStart;
  var ShouldScroll := (OldSelStart = M.GetTextLen);
  M.Lines.BeginUpdate;
  try
    Lines := Value.Split([#10]);
    if System.Length(Lines) > 0 then
    begin
      if M.Lines.Count > 0 then
        CurrentLine := M.Lines[M.Lines.Count - 1]
      else
        CurrentLine := '';
      CurrentLine := CurrentLine + Lines[0];
      if M.Lines.Count > 0 then
        M.Lines[M.Lines.Count - 1] := CurrentLine
      else
        M.Lines.Add(CurrentLine);
      for var i := 1 to High(Lines) do
        M.Lines.Add(Lines[i]);
    end;
  finally
    M.Lines.EndUpdate;
  end;
  if ShouldScroll then
  begin
    M.SelStart := M.GetTextLen;
    M.SelLength := 0;
    M.Perform(EM_SCROLLCARET, 0, 0);
  end;
end;

procedure DisplayStream(Sender: TObject; Value: TChat);
begin
  if Assigned(Value) then
    for var Item in Value.Choices do
      begin
        DisplayStream(Sender, Item.Delta.Content);
      end;
end;

procedure DisplayAudio(Sender: TObject; Value: TChat);
begin
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');
  Value.Choices[0].Message.Audio.SaveToFile(TutorialHub.FileName);
  Display(Sender, Value.Choices[0].Message.Audio.Transcript);
  TutorialHub.PlayAudio;
  Display(Sender, sLineBreak);
  Display(Sender, Value.JSONResponse);
end;

procedure DisplayAudioEx(Sender: TObject; Value: TChat);
begin
  DisplayStream(Sender, Value.Choices[0].Message.Content);
  TutorialHub.SpeechChat(Value.Choices[0].Message.Content)
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

constructor TVCLTutorialHub.Create(const AClient: IGenAI; const AMemo1: TMemo;
  const AButton: TButton; const AMediaPlayer: TMediaPlayer);
begin
  inherited Create;
  Memo1 := AMemo1;
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
        FromSystem('Tu es un présentateur météo sur une chaîne télé de grande écoute.'),
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
          Payload.System('Tu es un présentateur météo sur une chaîne télé de grande écoute.'),
          Payload.User(Value)]);
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

procedure TVCLTutorialHub.SetMemo1(const Value: TMemo);
begin
  FMemo1 := Value;
  FMemo1.ScrollBars := TScrollStyle.ssVertical;
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
