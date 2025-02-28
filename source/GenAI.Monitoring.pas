unit GenAI.Monitoring;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs;

type
  IRequestMonitor = interface
    ['{4FE090AE-EC69-418A-8B1D-4DB6DB93ECA5}']
    function Inc: Integer;
    function Dec: Integer;
    function IsBusy: Boolean;
  end;

  TRequestMonitor = class(TInterfacedObject, IRequestMonitor)
  private
    FLock: TCriticalSection;
    FCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Inc: Integer;
    function Dec: Integer;
    function IsBusy: Boolean;
  end;

var
  Monitoring: IRequestMonitor;

implementation

{ TRequestMonitor }

constructor TRequestMonitor.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FCount := 0;
end;

function TRequestMonitor.Dec: Integer;
begin
  FLock.Enter;
  try
    if FCount > 0 then
      System.Dec(FCount);
    Result := FCount;
  finally
    FLock.Leave;
  end;
end;

destructor TRequestMonitor.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TRequestMonitor.Inc: Integer;
begin
  FLock.Enter;
  try
    System.Inc(FCount);
    Result := FCount;
  finally
    FLock.Leave;
  end;
end;

function TRequestMonitor.IsBusy: Boolean;
begin
  FLock.Enter;
  try
    Result := FCount > 0;
  finally
    FLock.Leave;
  end;
end;

initialization
  Monitoring := TRequestMonitor.Create;
end.
