unit Main;

interface

uses
  System.SysUtils, System.Types, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Layouts,

  {--- Pythia-Webview }
  FMX.WVPythia.Chat, WVPythia.Types,

  {--- Adapter }
  FMX.WVPythia.Services,

  {--- AsyncTools}
  Demo.OpenAI.AsyncUtils,

  {--- OpenAI SDK - GenAI }
  GenAI, Demo.OpenAI.Services, Demo.OpenAI.Context, Demo.OpenAI.Strs;

const
  STILL_IN_PROGRESS_ERROR =
    'Requests are still in progress. #10Please wait for them to complete before closing the application.';
  APP_CAPTION =
    'Pythia-Webview2 (%s) - OpenAI vendor Demo - Delphi GenAI SDK version %s';

type
  TOpenAIDemoPythia = class(TFMXPythia)
  public
    procedure SetLanguage(const Value: string); override;
  end;

  TForm1 = class(TForm)
    Layout1: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure DoOnInitialized;
    procedure UpdateApiKey(KeyName: string);
  public
    Pythia: TFMXPythia;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

{ TOpenAIDemoPythia }

procedure TOpenAIDemoPythia.SetLanguage(const Value: string);
begin
  inherited SetLanguage(Value);
  TOpenAIDemoTranslations.LoadFromLanguage(GetLanguageFolder, Value);
end;


{ TForm1 }

procedure TForm1.DoOnInitialized;
begin
  OpenAIVendor := TOpenAIServices.Create(
    Pythia,
    TOpenAIContext.CreateInstance(Pythia)
  );

  TFMXAlphaBlend.ShowWindow(Self);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not HttpMonitoring.IsBusy;
  if not CanClose then
    Pythia.DisplayError(STILL_IN_PROGRESS_ERROR);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  Caption := Format(APP_CAPTION, [TFMXPythia.Version, GenAI.Version]);

  Width := 1350;
  Height := 770;

  TFMXAlphaBlend.HideWindow(Self);

  Pythia := TOpenAIDemoPythia.Create(Layout1);
  Pythia.AttachHost(Self);
  Pythia.OnApiKeyChanged := UpdateApiKey;
  Pythia.ServiceAdapter := TFMXChatManagedItemDialogService.Create;
  Pythia.OnInitialized := DoOnInitialized;
  Pythia.Update;
end;

procedure TForm1.UpdateApiKey(KeyName: string);
begin
  if SameText(KeyName, TOpenAIServices.API_KEY_NAME) then
    OpenAIVendor.UpdateApiKey;
end;

end.
