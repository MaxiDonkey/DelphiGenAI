unit GenAI.Tutorial.FMX;

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
  System.SysUtils, System.Classes, Winapi.Messages, FMX.Types, FMX.StdCtrls, FMX.ExtCtrls,
  FMX.Controls, FMX.Forms, Winapi.Windows, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Media, FMX.Objects, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.UITypes,
  System.Types,
  GenAI, GenAI.Models;

type
  TToolProc = procedure (const Value: string) of object;

  /// <summary>
  /// Represents a tutorial hub for handling visual components in a Delphi application,
  /// including text display, button interactions, and navigation through pages.
  /// </summary>
  TFMXTutorialHub = class
  private
    FMemo1: TMemo;
    FButton: TButton;
    FModelId: string;
//    FTool: IFunctionCore;
    FToolCall: TToolProc;
    FCancel: Boolean;
    procedure OnButtonClick(Sender: TObject);
    procedure SetButton(const Value: TButton);
    procedure SetMemo1(const Value: TMemo);
  public
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
    /// Gets or sets the core function tool used for processing.
    /// </summary>
//    property Tool: IFunctionCore read FTool write FTool;
    /// <summary>
    /// Gets or sets the procedure for handling tool-specific calls.
    /// </summary>
    property ToolCall: TToolProc read FToolCall write FToolCall;
    /// <summary>
    /// Gets or sets a value indicating whether file overrides are allowed.
    /// </summary>
    constructor Create(const AMemo1: TMemo; const AButton: TButton);
  end;

  procedure Cancellation(Sender: TObject);
  function DoCancellation: Boolean;
  procedure Start(Sender: TObject);

  procedure Display(Sender: TObject); overload;
  procedure Display(Sender: TObject; Value: string); overload;
  procedure Display(Sender: TObject; Value: TArray<string>); overload;
  procedure Display(Sender: TObject; Value: TModel); overload;
  procedure Display(Sender: TObject; Value: TModels); overload;

  procedure DisplayStream(Sender: TObject; Value: string); overload;

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
  TutorialHub: TFMXTutorialHub = nil;

implementation

procedure Cancellation(Sender: TObject);
begin
  Display(Sender, 'The operation was cancelled' + sLineBreak);
  TutorialHub.Cancel := False;
end;

function DoCancellation: Boolean;
begin
  Result := TutorialHub.Cancel;
end;

procedure Start(Sender: TObject);
begin
  Display(Sender, 'Please wait...');
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: string);
var
  M: TMemo;
begin
  if Sender is TMemo then
    M := Sender as TMemo else
    M := (Sender as TFMXTutorialHub).Memo1;
  M.Lines.Add(Value);
  M.ViewportPosition := PointF(M.ViewportPosition.X, M.Content.Height - M.Height);
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
    F('Created', UnixDateTimeToString(Value.Created))
  ]);
  Display(Sender, EmptyStr);
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
end;

procedure DisplayStream(Sender: TObject; Value: string);
var
  M: TMemo;
  CurrentLine: string;
begin
  if Sender is TMemo then
    M := Sender as TMemo
  else
    M := (Sender as TFMXTutorialHub).Memo1;
  var ShouldScroll := M.ViewportPosition.Y >= (M.Content.Height - M.Height - 16);
  M.Lines.BeginUpdate;
  try
    var Lines := Value.Replace(#13, '').Split([#10]);
    if System.Length(Lines) > 0 then
    begin
      if M.Lines.Count > 0 then
        CurrentLine := M.Lines[M.Lines.Count - 1]
      else
        CurrentLine := EmptyStr;
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
    M.ViewportPosition := PointF(M.ViewportPosition.X, M.Content.Height - M.Height + 1);
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
  Result := Format('%s (%s): %s%%', [Name, BoolToStr(State, True), (Value * 100).ToString(ffNumber, 3, 3)])
end;

{ TFMXTutorialHub }

constructor TFMXTutorialHub.Create(const AMemo1: TMemo; const AButton: TButton);
begin
  inherited Create;
  Memo1 := AMemo1;
  Button := AButton;
end;

procedure TFMXTutorialHub.OnButtonClick(Sender: TObject);
begin
  Cancel := True;
end;

procedure TFMXTutorialHub.SetButton(const Value: TButton);
begin
  FButton := Value;
  FButton.OnClick := OnButtonClick;
  FButton.Text := 'Cancel';
end;

procedure TFMXTutorialHub.SetMemo1(const Value: TMemo);
begin
  FMemo1 := Value;
  FMemo1.TextSettings.WordWrap := True;
end;

initialization
finalization
  if Assigned(TutorialHub) then
    TutorialHub.Free;
end.
