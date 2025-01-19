unit GenAI.HttpClientAPI;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, System.JSON, System.NetConsts, GenAI.API.Params, GenAI.Errors,
  GenAI.Exceptions, GenAI.HttpClientInterface;

type
  THttpClientAPI = class(TInterfacedObject, IHttpClientAPI)
  private
    FHttpClient: THttpClient;
    FCheckSettingsProc: TProc;
    procedure SetSendTimeOut(const Value: Integer);
    function GetSendTimeOut: Integer;
    function GetConnectionTimeout: Integer;
    procedure SetConnectionTimeout(const Value: Integer);
    function GetResponseTimeout: Integer;
    procedure SetResponseTimeout(const Value: Integer);
    function GetProxySettings: TProxySettings;
    procedure SetProxySettings(const Value: TProxySettings);
    procedure CheckAPISettings; virtual;
  public
    function Get(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;
    function Get(const URL: string; const Response: TStream; const Headers: TNetHeaders): Integer; overload;
    function Delete(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer;
    function Post(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;
    function Post(const URL: string; Body: TMultipartFormData; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;
    function Post(const URL: string; Body: TJSONObject; Response: TStringStream; const Headers: TNetHeaders; OnReceiveData: TReceiveDataCallback): Integer; overload;
    function Patch(const URL: string; Body: TJSONObject; Response: TStringStream; const Headers: TNetHeaders): Integer;
    constructor Create(const CheckProc: TProc);
    class function CreateInstance(const CheckProc: TProc): IHttpClientAPI;
    destructor Destroy; override;
  end;

implementation

{ THttpClientAPI }

procedure THttpClientAPI.CheckAPISettings;
begin
  if Assigned(FCheckSettingsProc) then
    FCheckSettingsProc;
end;

constructor THttpClientAPI.Create(const CheckProc: TProc);
begin
  inherited Create;
  FHttpClient := THTTPClient.Create;
  FHttpClient.AcceptCharSet := 'utf-8';
  FCheckSettingsProc := CheckProc;
end;

class function THttpClientAPI.CreateInstance(
  const CheckProc: TProc): IHttpClientAPI;
begin
  Result := THttpClientAPI.Create(CheckProc);
end;

function THttpClientAPI.Delete(const URL: string;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Delete(URL, Response, Headers).StatusCode;
end;

destructor THttpClientAPI.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

function THttpClientAPI.Get(const URL: string; const Response: TStream;
  const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Get(URL, Response, Headers).StatusCode;
end;

function THttpClientAPI.GetConnectionTimeout: Integer;
begin
  Result := FHttpClient.ConnectionTimeout;
end;

function THttpClientAPI.GetProxySettings: TProxySettings;
begin
  Result := FHttpClient.ProxySettings;
end;

function THttpClientAPI.GetResponseTimeout: Integer;
begin
  Result := FHttpClient.ResponseTimeout;
end;

function THttpClientAPI.GetSendTimeOut: Integer;
begin
  Result := FHttpClient.SendTimeout;
end;

function THttpClientAPI.Get(const URL: string;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Get(URL, Response, Headers).StatusCode;
end;

function THttpClientAPI.Patch(const URL: string; Body: TJSONObject;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  var Stream := TStringStream.Create;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHttpClient.Patch(URL, Stream, Response, Headers).StatusCode;
  finally
    Stream.Free;
  end;
end;

function THttpClientAPI.Post(const URL: string; Body: TJSONObject;
  Response: TStringStream; const Headers: TNetHeaders;
  OnReceiveData: TReceiveDataCallback): Integer;
begin
  CheckAPISettings;
  var Stream := TStringStream.Create;
  FHttpClient.ReceiveDataCallBack := OnReceiveData;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHttpClient.Post(URL, Stream, Response, Headers).StatusCode;
  finally
    FHttpClient.ReceiveDataCallBack := nil;
    Stream.Free;
  end;
end;

procedure THttpClientAPI.SetConnectionTimeout(const Value: Integer);
begin
  FHttpClient.ConnectionTimeout := Value;
end;

procedure THttpClientAPI.SetProxySettings(const Value: TProxySettings);
begin
  FHttpClient.ProxySettings := Value;
end;

procedure THttpClientAPI.SetResponseTimeout(const Value: Integer);
begin
  FHttpClient.ResponseTimeout := Value;
end;

procedure THttpClientAPI.SetSendTimeOut(const Value: Integer);
begin
  FHttpClient.SendTimeout := Value;
end;

function THttpClientAPI.Post(const URL: string; Body: TMultipartFormData;
  Response: TStringStream; const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  Result := FHttpClient.Post(URL, Body, Response, Headers).StatusCode;
end;

function THttpClientAPI.Post(const URL: string; Response: TStringStream;
  const Headers: TNetHeaders): Integer;
begin
  CheckAPISettings;
  var Stream: TStringStream := nil;
  Result := FHttpClient.Post(URL, Stream, Response, Headers).StatusCode;
end;

end.
