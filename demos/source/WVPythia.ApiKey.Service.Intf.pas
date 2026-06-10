unit WVPythia.ApiKey.Service.Intf;

interface

uses
  WVPythia.Chat.Interfaces;

type
  /// <summary>
  /// Result of an operation on a key, to retrieve a clear message.
  /// </summary>
  TApiKeyOperationResult = record
    Success: Boolean;
    Message: string;
    class function Ok(const AMessage: string = ''): TApiKeyOperationResult; static;
    class function Fail(const AMessage: string): TApiKeyOperationResult; static;
  end;

  /// <summary>
  /// API key management service.
  /// <para>
  /// Abstraction: the plugin does not know WHERE or HOW the keys are stored
  /// </para>
  /// <para>
  /// (Windows registry, encrypted file, keychain, environment variable...)
  /// </para>
  /// </summary>
  IApiKeyService = interface
    ['{A7C3E812-4D5F-4B91-8E2A-9F6B3C7D1E40}']
    function GetBrowser: IPythiaBrowser;
    procedure SetBrowser(const Value: IPythiaBrowser);

    /// <summary>
    /// Create a key with the given name. It will fail if the key already exists.
    /// </summary>
    /// <remarks>
    /// The key value can be requested from the user beforehand, or generated according
    /// to your strategy—it's up to you to decide in the implementation.
    /// </remarks>
    function CreateKey(const AName: string): TApiKeyOperationResult;

    /// <summary>
    /// Deletes the key. Fails if it does not exist.
    /// </summary>
    function DeleteKey(const AName: string): TApiKeyOperationResult;

    /// <summary>
    /// Simply tests for presence. Does not raise an error, True/False.
    /// </summary>
    function Exists(const AName: string): Boolean;

    property Browser: IPythiaBrowser read GetBrowser write SetBrowser;
  end;

implementation

class function TApiKeyOperationResult.Ok(
  const AMessage: string): TApiKeyOperationResult;
begin
  Result.Success := True;
  Result.Message := AMessage;
end;

class function TApiKeyOperationResult.Fail(
  const AMessage: string): TApiKeyOperationResult;
begin
  Result.Success := False;
  Result.Message := AMessage;
end;

end.
