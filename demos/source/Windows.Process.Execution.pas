unit Windows.Process.Execution;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, WVPythia.Chat.Interfaces;

type
  TAPIRunProcess = record
    class procedure Open(const FileName: string); static;
  end;

  TProcessExecute = class(TInterfacedObject, IProcessExecute)
    procedure Open(const FileName: string);
  end;

implementation

{ TAPIRunProcess }

class procedure TAPIRunProcess.Open(const FileName: string);
begin
  ShellExecute(0, nil, PChar(FileName), nil, nil, SW_SHOWNORMAL);
end;

{ TProcessExecute }

procedure TProcessExecute.Open(const FileName: string);
begin
  TAPIRunProcess.Open(FileName);
end;

end.
