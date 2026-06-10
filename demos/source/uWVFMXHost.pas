unit uWVFMXHost;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Types, System.Classes, System.UITypes, //System.Messaging,
  FMX.Types, FMX.Forms, FMX.Layouts, FMX.Platform, FMX.Platform.Win,
  uWVFMXBrowser, uWVFMXWindowParent;

type
  /// <summary>
  ///  Abstraction de l’hébergement d’un TWVFMXBrowser dans une fenêtre FMX (Win32).
  ///  - crée le TWVFMXBrowser au runtime
  ///  - crée / gère le TWVFMXWindowParent
  ///  - hook la WndProc pour gérer move/resize/show
  /// </summary>
  IWVFMXHost = interface
    ['{8CC0D0B9-F00A-4B4D-8A43-D03CA4E09F25}']
    /// À appeler une fois (ex: FormCreate)
    procedure Initialize(AForm: TForm; ABrowserLayout: TLayout);

    /// Crée le TWVFMXBrowser au runtime si besoin et le renvoie.
    function CreateBrowser(AOwner: TComponent): TWVFMXBrowser;

    /// Renvoie le browser (ou nil si CreateBrowser pas encore appelé).
    function GetBrowser: TWVFMXBrowser;

    /// À appeler dans TForm.CreateHandle
    procedure HookWndProc;

    /// À appeler dans TForm.DestroyHandle
    procedure UnhookWndProc;

    /// À appeler dans TForm.Resize (ou FormResize)
    procedure ResizeChild;

    /// À appeler quand la fenêtre bouge (SetBounds override)
    procedure NotifyMoveOrResizeStarted;

    /// Handle Win32 du parent natif (pour CreateBrowser)
    function GetBrowserParentHandle: HWND;

    /// Accès au TWVFMXWindowParent
    function GetWindowParent: TWVFMXWindowParent;

    function GetWindowParentRect: TRect;
  end;

function CreateWVFMXHost: IWVFMXHost;

implementation

type
  TWVFMXHost = class(TInterfacedObject, IWVFMXHost)
  private
    FForm: TForm;
    FLayout: TLayout;
    FBrowser: TWVFMXBrowser;
    FWindowParent: TWVFMXWindowParent;
    FCustomState: TWindowState;
    FOldWndProc: TFNWndProc;
    FStub: Pointer;
    FHooked: Boolean;

    procedure CustomWndProc(var Msg: TMessage);
    function  GetFMXWindowParentRect: TRect;
    function  GetCurrentWindowState: TWindowState;
    procedure UpdateCustomWindowState;
    function  PostCustomMessage(AMsg: Cardinal; AWParam: WPARAM = 0; ALParam: LPARAM = 0): Boolean;
  protected const
    WEBVIEW2_SHOWBROWSER = WM_APP + $101;
    SWP_STATECHANGED     = $8000;
  public
    destructor Destroy; override;
    { IWVFMXHost }
    procedure Initialize(AForm: TForm; ABrowserLayout: TLayout);
    function  CreateBrowser(AOwner: TComponent): TWVFMXBrowser;
    function  GetBrowser: TWVFMXBrowser;
    procedure HookWndProc;
    procedure UnhookWndProc;
    procedure ResizeChild;
    procedure NotifyMoveOrResizeStarted;
    function  GetBrowserParentHandle: HWND;
    function  GetWindowParent: TWVFMXWindowParent;
    function  GetWindowParentRect: TRect;
  end;

{ Factory }

function CreateWVFMXHost: IWVFMXHost;
begin
  Result := TWVFMXHost.Create;
end;

{ TWVFMXHost }

procedure TWVFMXHost.Initialize(AForm: TForm; ABrowserLayout: TLayout);
begin
  FForm   := AForm;
  FLayout := ABrowserLayout;
  if FForm <> nil then
    FCustomState := FForm.WindowState
  else
    FCustomState := TWindowState.wsNormal;
end;

function TWVFMXHost.CreateBrowser(AOwner: TComponent): TWVFMXBrowser;
begin
  if FBrowser = nil then
    begin
      FBrowser := TWVFMXBrowser.Create(AOwner);
      // aucune nécessité de Parent visuel en FMX : c’est le TWVFMXWindowParent
      // qui portera le rendu via HWND
      if FWindowParent <> nil then
        FWindowParent.Browser := FBrowser;
    end;
  Result := FBrowser;
end;

function TWVFMXHost.GetBrowser: TWVFMXBrowser;
begin
  Result := FBrowser;
end;

procedure TWVFMXHost.HookWndProc;
begin
  if FHooked or (FForm = nil) then
    Exit;

  var Handle := FmxHandleToHWND(FForm.Handle);
  if Handle = 0 then
    Exit;

  FStub       := MakeObjectInstance(CustomWndProc);
  FOldWndProc := TFNWndProc(SetWindowLongPtr(Handle, GWLP_WNDPROC, NativeInt(FStub)));
  FHooked     := True;
end;

procedure TWVFMXHost.UnhookWndProc;
begin
  if not FHooked then
    Exit;

  var Handle := FmxHandleToHWND(FForm.Handle);
  if Handle <> 0 then
    SetWindowLongPtr(Handle, GWLP_WNDPROC, NativeInt(FOldWndProc));

  FreeObjectInstance(FStub);
  FStub   := nil;
  FHooked := False;
end;

procedure TWVFMXHost.ResizeChild;
begin
  if (FWindowParent <> nil) then
    begin
      FWindowParent.SetBounds(GetFMXWindowParentRect);
      FWindowParent.UpdateSize;
    end;
end;

procedure TWVFMXHost.NotifyMoveOrResizeStarted;
begin
  if (FBrowser <> nil) then
    FBrowser.NotifyParentWindowPositionChanged;
end;

function TWVFMXHost.GetBrowserParentHandle: HWND;
begin
  if (FWindowParent = nil) and (FForm <> nil) then
    begin
      FWindowParent := TWVFMXWindowParent.CreateNew(nil);
      FWindowParent.Browser := FBrowser;
      FWindowParent.Reparent(FForm.Handle);
      FWindowParent.SetBounds(GetFMXWindowParentRect);
      FWindowParent.Show;

      if not FHooked then
        HookWndProc;
    end;

  if FWindowParent <> nil then
    Result := FmxHandleToHWND(FWindowParent.Handle)
  else
    Result := 0;
end;

function TWVFMXHost.GetWindowParent: TWVFMXWindowParent;
begin
  Result := FWindowParent;
end;

function TWVFMXHost.GetWindowParentRect: TRect;
begin
  Result := GetFMXWindowParentRect;
end;

function TWVFMXHost.GetFMXWindowParentRect: TRect;
begin
  if (FLayout <> nil) then
    begin
      var R := FLayout.AbsoluteRect;
      Result.Left   := Round(R.Left);
      Result.Top    := Round(R.Top);
      Result.Right  := Round(R.Right);
      Result.Bottom := Round(R.Bottom);
    end
  else
    Result := TRect.Empty;
end;

function TWVFMXHost.PostCustomMessage(AMsg: Cardinal; AWParam: WPARAM; ALParam: LPARAM): Boolean;
begin
  var Handle := FmxHandleToHWND(FForm.Handle);
  Result := (Handle <> 0) and Winapi.Windows.PostMessage(Handle, AMsg, AWParam, ALParam);
end;

procedure TWVFMXHost.CustomWndProc(var Msg: TMessage);
var
  TempWindowPos: PWindowPos;
begin
  try
    case Msg.Msg of
      WM_MOVE,
      WM_MOVING:
        NotifyMoveOrResizeStarted;

      WM_SIZE:
        if (Msg.WParam = SIZE_RESTORED) then
          UpdateCustomWindowState;

      WM_WINDOWPOSCHANGING:
        begin
          TempWindowPos := TWMWindowPosChanging(Msg).WindowPos;
          if ((TempWindowPos.Flags and SWP_STATECHANGED) <> 0) then
            UpdateCustomWindowState;
        end;

      WM_SHOWWINDOW:
        if (Msg.WParam <> 0) and (Msg.LParam = SW_PARENTOPENING) then
          PostCustomMessage(WEBVIEW2_SHOWBROWSER);

      WEBVIEW2_SHOWBROWSER:
        if (FWindowParent <> nil) then
        begin
          FWindowParent.WindowState := TWindowState.wsNormal;
          ResizeChild;
        end;
    end;

    var Handle := FmxHandleToHWND(FForm.Handle);
    Msg.Result := CallWindowProc(FOldWndProc, Handle, Msg.Msg, Msg.WParam, Msg.LParam);
  except
    // log éventuel
  end;
end;

destructor TWVFMXHost.Destroy;
begin
  { La WndProc doit être décrochée, sinon le stub MakeObjectInstance
    reste alloué et les messages Windows tenteraient d'appeler du code
    mort après la destruction. }
  if FHooked then
    UnhookWndProc;

  { FBrowser n'est PAS libéré ici : son AOwner (passé à CreateBrowser)
    en a la charge. }

  { FWindowParent a été créé avec AOwner = nil (voir GetBrowserParentHandle),
    donc il faut le libérer explicitement. On délie d'abord sa référence
    vers le browser pour éviter un pointeur pendant si l'ordre de
    destruction avec le browser devient acrobatique. }
  if FWindowParent <> nil then
    begin
      FWindowParent.Browser := nil;
      FreeAndNil(FWindowParent);
    end;

  inherited
end;

function TWVFMXHost.GetCurrentWindowState: TWindowState;
var
  TempPlacement: TWindowPlacement;
begin
  Result := TWindowState.wsNormal;
  if FForm = nil then
    Exit;

  var Handle := FmxHandleToHWND(FForm.Handle);

  ZeroMemory(@TempPlacement, SizeOf(TWindowPlacement));
  TempPlacement.Length := SizeOf(TWindowPlacement);

  if GetWindowPlacement(Handle, @TempPlacement) then
    case TempPlacement.showCmd of
      SW_SHOWMAXIMIZED : Result := TWindowState.wsMaximized;
      SW_SHOWMINIMIZED : Result := TWindowState.wsMinimized;
    end;

  if IsIconic(Handle) then
    Result := TWindowState.wsMinimized;
end;

procedure TWVFMXHost.UpdateCustomWindowState;
begin
  var NewState := GetCurrentWindowState;

  if (FCustomState <> NewState) then
    begin
      if (FCustomState = TWindowState.wsMinimized) then
        PostCustomMessage(WEBVIEW2_SHOWBROWSER);

      FCustomState := NewState;
    end;
end;

end.

