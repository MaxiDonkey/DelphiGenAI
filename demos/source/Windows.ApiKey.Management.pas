unit Windows.ApiKey.Management;

interface

uses
  Winapi.Windows, System.SysUtils, System.Win.Registry,
  WVPythia.Chat.Interfaces;

type
  TWinSecretStore = record
  public
    class procedure SetUserEnvVar(const Name, Value: string); static;
    class function ReadEnvFromRegistry(const Name: string): string; static;
    class function TryToReadKey(const KeyName: string;
      out KeyValue: string; const ParamProc: TProc<string> = nil): Boolean; static;
    class procedure DeleteKey(const KeyName: string); static;
  end;

  TSecretStore = class(TInterfacedObject, ISecretStore)
  private
  public
    function ReadSecret(const Name: string; out Value: string; const ParamProc: TProc<string> = nil): Boolean;
    procedure WriteSecret(const Name, Value: string);
    procedure DeleteSecret(const Name: string);
  end;

implementation

{ TWinSecretStore }

class function TWinSecretStore.TryToReadKey(const KeyName: string;
  out KeyValue: string;
  const ParamProc: TProc<string>): Boolean;
begin
  KeyValue := ReadEnvFromRegistry(KeyName);
  Result := not KeyValue.Trim.IsEmpty;

  if Result then
    Exit;

  if Assigned(ParamProc) then
    ParamProc(KeyName);
end;

class procedure TWinSecretStore.DeleteKey(const KeyName: string);
var
  R: TRegistry;
begin
  R := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKey('Environment', False) and R.ValueExists(KeyName) then
      R.DeleteValue(KeyName);
  finally
    R.Free;
  end;
end;

class function TWinSecretStore.ReadEnvFromRegistry(const Name: string): string;

  function ReadFrom(const Root: HKEY; const SubKey, ValueName: string): string;
  var R: TRegistry;
  begin
    Result := '';
    R := TRegistry.Create(KEY_READ);
    try
      R.RootKey := Root;
      if R.OpenKeyReadOnly(SubKey) and R.ValueExists(ValueName) then
        Result := R.ReadString(ValueName);
    finally
      R.Free;
    end;
  end;

begin
  Result := ReadFrom(HKEY_CURRENT_USER, 'Environment', Name);
  if not Result.Trim.IsEmpty then
    Exit;

  Result := ReadFrom(HKEY_LOCAL_MACHINE,
            'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', Name);
end;

class procedure TWinSecretStore.SetUserEnvVar(const Name, Value: string);
var
  EnvKey: HKEY;
  Status: Longint;
  DataSize: DWORD;
begin
  Status := RegCreateKeyEx(
    HKEY_CURRENT_USER, 'Environment', 0, nil,
    REG_OPTION_NON_VOLATILE, KEY_SET_VALUE,
    nil, EnvKey, nil);

  if Status <> ERROR_SUCCESS then
    RaiseLastOSError(Status);

  try
    DataSize := (Length(Value) + 1) * SizeOf(Char);
    Status := RegSetValueEx(
      EnvKey, PChar(Name), 0, REG_SZ,
      PByte(PChar(Value)), DataSize);

    if Status <> ERROR_SUCCESS then
      RaiseLastOSError(Status);
  finally
    RegCloseKey(EnvKey);
  end;
end;

{ TSecretStore }

procedure TSecretStore.DeleteSecret(const Name: string);
begin
  TWinSecretStore.DeleteKey(Name);
end;

function TSecretStore.ReadSecret(const Name: string;
  out Value: string;
  const ParamProc: TProc<string>): Boolean;
begin
  Result := TWinSecretStore.TryToReadKey(Name, Value, ParamProc);
end;

procedure TSecretStore.WriteSecret(const Name, Value: string);
begin
  TWinSecretStore.SetUserEnvVar(Name, Value);
end;

end.

