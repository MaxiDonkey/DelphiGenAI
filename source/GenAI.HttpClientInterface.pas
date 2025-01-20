unit GenAI.HttpClientInterface;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.JSON, System.Net.Mime;

type
  IHttpClientParam = interface
    ['{BCF51E39-B8CF-4706-90CC-FC93D07230BD}']
    procedure SetSendTimeOut(const Value: Integer);
    function GetSendTimeOut: Integer;
    function GetConnectionTimeout: Integer;
    procedure SetConnectionTimeout(const Value: Integer);
    function GetResponseTimeout: Integer;
    procedure SetResponseTimeout(const Value: Integer);
    function GetProxySettings: TProxySettings;
    procedure SetProxySettings(const Value: TProxySettings);

    property SendTimeOut: Integer read GetSendTimeOut write SetSendTimeOut;
    property ConnectionTimeout: Integer read GetConnectionTimeout write SetConnectionTimeout;
    property ResponseTimeout: Integer read GetResponseTimeout write SetResponseTimeout;
    property ProxySettings: TProxySettings read GetProxySettings write SetProxySettings;
  end;

  IHttpClientAPI = interface(IHttpClientParam)
    ['{CEE0EB49-85AA-42EB-B147-0E3C3C09EA6D}']
    function Get(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;
    function Get(const URL: string; const Response: TStream; const Headers: TNetHeaders): Integer; overload;
    function Delete(const Path: string; Response: TStringStream; const Headers: TNetHeaders): Integer;
    function Post(const URL: string; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;
    function Post(const URL: string; Body: TMultipartFormData; Response: TStringStream; const Headers: TNetHeaders): Integer; overload;
    function Post(const URL: string; Body: TJSONObject; Response: TStringStream; const Headers: TNetHeaders; OnReceiveData: TReceiveDataCallback): Integer; overload;
    function Patch(const URL: string; Body: TJSONObject; Response: TStringStream; const Headers: TNetHeaders): Integer;
  end;

implementation

end.
