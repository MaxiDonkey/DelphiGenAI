unit GenAI.Monitoring;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs;

type
  /// <summary>
  /// Interface for monitoring request counts in a thread-safe manner.
  /// </summary>
  /// <remarks>
  /// This interface defines methods to increment and decrement a request counter,
  /// as well as a method to check if any requests are currently being processed.
  /// </remarks>
  IRequestMonitor = interface
    ['{4FE090AE-EC69-418A-8B1D-4DB6DB93ECA5}']
    /// <summary>
    /// Increments the request counter.
    /// </summary>
    /// <returns>
    /// The updated number of active requests.
    /// </returns>
    function Inc: Integer;
    /// <summary>
    /// Decrements the request counter.
    /// </summary>
    /// <returns>
    /// The updated number of active requests.
    /// </returns>
    function Dec: Integer;
    /// <summary>
    /// Checks if there are active requests being processed.
    /// </summary>
    /// <returns>
    /// <c>True</c> if there are active requests, otherwise <c>False</c>.
    /// </returns>
    function IsBusy: Boolean;
  end;

  /// <summary>
  /// Implements a thread-safe request monitor.
  /// </summary>
  /// <remarks>
  /// This class provides synchronized methods to track the number of active requests.
  /// It ensures thread safety using a critical section.
  /// </remarks>
  TRequestMonitor = class(TInterfacedObject, IRequestMonitor)
  private
    FLock: TCriticalSection;
    FCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    /// Increments the request counter in a thread-safe manner.
    /// </summary>
    /// <returns>
    /// The updated number of active requests.
    /// </returns>
    function Inc: Integer;
    /// <summary>
    /// Decrements the request counter in a thread-safe manner.
    /// </summary>
    /// <returns>
    /// The updated number of active requests.
    /// </returns>
    function Dec: Integer;
    /// <summary>
    /// Checks if there are any active requests.
    /// </summary>
    /// <returns>
    /// <c>True</c> if there are active requests, otherwise <c>False</c>.
    /// </returns>
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
