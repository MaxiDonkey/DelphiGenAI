unit WVPythia.ApiKey.Service;

interface

uses
  System.SysUtils, System.Generics.Collections,
  WVPythia.ApiKey.Service.Intf, WVPythia.Chat.Interfaces, WVPythia.JSON.SafeReader,
  WVPythia.JSON.SafeWriter, WVPythia.Chat.Consts, WVPythia.TextFile.Helper,
  WVPythia.Strs;

type
  TApiKeyService = class(TInterfacedObject, IApiKeyService)
  strict private
    FBrowser: IPythiaBrowser;
    function Normalize(const AName: string): string;
  private
    function GetBrowser: IPythiaBrowser;
    procedure SetBrowser(const Value: IPythiaBrowser);
  public
    constructor Create;
    destructor Destroy; override;

    property Browser: IPythiaBrowser read GetBrowser write SetBrowser;

    // IApiKeyService
    function CreateKey(const AName: string): TApiKeyOperationResult;
    function DeleteKey(const AName: string): TApiKeyOperationResult;
    function Exists(const AName: string): Boolean;
  end;

implementation

{ TApiKeyService }

constructor TApiKeyService.Create;
begin
  inherited Create;
end;

destructor TApiKeyService.Destroy;
begin
  inherited;
end;

function TApiKeyService.Normalize(const AName: string): string;
begin
  {--- Key names are case-insensitive and free of extraneous spaces. }
  Result := AName.Trim.ToLowerInvariant;
end;

procedure TApiKeyService.SetBrowser(const Value: IPythiaBrowser);
begin
  FBrowser := Value;
end;

function TApiKeyService.CreateKey(
  const AName: string): TApiKeyOperationResult;
{--- Prompt text: /api-key new vendorName }
begin
  var Key := Normalize(AName);
  if Key.IsEmpty then
    begin
      FBrowser.DisplayError(S_API_KEY_EMPTY_NAME_ERROR);

      Exit(TApiKeyOperationResult.Fail(S_API_KEY_Empty_NAME_ERROR));
    end;

  FBrowser.BrowserInput(Format(S_API_KEY_ENTER_DIALOG_PROMPT, [AName]), AName, True);

  Result := TApiKeyOperationResult.Ok('Request sended');
end;

function TApiKeyService.DeleteKey(
  const AName: string): TApiKeyOperationResult;
{--- Prompt text:  /api-key delete vendorName }
begin
  var Key := Normalize(AName);

  {--- Check if deleting the key is possible }
  var KeyNamesReader := TJsonReader.Parse(FBrowser.ApiKeyNamesAsJsonString);
  if not KeyNamesReader.Exists(Key) then
    begin
      var Message := Format(S_API_KEY_NOT_FOUND, [AName]);
      FBrowser.DisplayWarning(Message);
      Exit(TApiKeyOperationResult.Fail(Message));
    end;

  {--- Delete the secret key }
  FBrowser.ApiKeySecretStore.DeleteSecret(AName);

  {--- Update the JSON responsible for maintaining the list of names for the API keys }
  KeyNamesReader.Remove(Key);
  FBrowser.ApiKeyNamesAsJsonString := KeyNamesReader.Format();

  FBrowser.ApiKeyValuesUpdate(Key);

  var Message := Format(S_API_KEY_DELETED, [AName]);
  FBrowser.DisplaySuccess(Message);

  Result := TApiKeyOperationResult.Ok(Message);
end;

function TApiKeyService.Exists(const AName: string): Boolean;
{--- Prompt text: /api-key exists vendorName }
var
  Value: string;
  Message: string;
begin
  Result := FBrowser.ApiKeySecretStore.ReadSecret(Normalize(AName), Value);

  if Result then
    begin
      Message := Format(S_API_KEY_EXISTS, [AName]);
      FBrowser.DisplaySuccess(Message)
    end
  else
    begin
      Message := Format(S_API_KEY_NOT_FOUND, [AName]);
      FBrowser.DisplayWarning(Message);
    end;
end;

function TApiKeyService.GetBrowser: IPythiaBrowser;
begin
  Result := FBrowser;
end;

end.
