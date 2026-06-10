unit uWVFMXCoreInit;

interface

uses
  uWVLoader;

type
  TWVFMXCoreOptions = record
    UserDataFolder        : string;
    ShowErrorDialogOnFail : Boolean;
    FailFastOnInitError   : Boolean;
  end;

var
  WVFMXCoreOptions: TWVFMXCoreOptions;

/// Force l'initialisation de WebView2 si ce n'est pas déjà fait.
procedure EnsureWebView2Initialized;

/// Helper d'état
function WebView2Initialized: Boolean;
function WebView2HasError: Boolean;
function WebView2ErrorMessage: string;

/// À appeler tôt (par ex. dans le DPR) si tu veux appliquer une politique d'erreur
procedure ConfigureAndCheckWebView2;

implementation

uses
  System.SysUtils,
  FMX.Dialogs;

procedure InitGlobalWebView2;
begin
  if Assigned(GlobalWebView2Loader) then
    Exit;

  GlobalWebView2Loader := TWVLoader.Create(nil);

  if WVFMXCoreOptions.UserDataFolder <> '' then
    GlobalWebView2Loader.UserDataFolder := WVFMXCoreOptions.UserDataFolder
  else
    GlobalWebView2Loader.UserDataFolder :=
      ExtractFileDir(ParamStr(0)) + '\CustomCache';

  GlobalWebView2Loader.StartWebView2;
end;

procedure EnsureWebView2Initialized;
begin
  InitGlobalWebView2;
end;

function WebView2Initialized: Boolean;
begin
  Result := Assigned(GlobalWebView2Loader) and GlobalWebView2Loader.Initialized;
end;

function WebView2HasError: Boolean;
begin
  Result := Assigned(GlobalWebView2Loader) and GlobalWebView2Loader.InitializationError;
end;

function WebView2ErrorMessage: string;
begin
  if Assigned(GlobalWebView2Loader) then
    Result := GlobalWebView2Loader.ErrorMessage
  else
    Result := '';
end;

procedure ConfigureAndCheckWebView2;
begin
  EnsureWebView2Initialized;

  if WebView2HasError then
    begin
      if WVFMXCoreOptions.ShowErrorDialogOnFail then
        ShowMessage(WebView2ErrorMessage);

      if WVFMXCoreOptions.FailFastOnInitError then
        Halt(1);
    end;
end;

initialization
  WVFMXCoreOptions.UserDataFolder        := EmptyStr;
  WVFMXCoreOptions.ShowErrorDialogOnFail := False;
  WVFMXCoreOptions.FailFastOnInitError   := False;

  EnsureWebView2Initialized;

finalization
  GlobalWebView2Loader.Free;
  GlobalWebView2Loader := nil;

end.

