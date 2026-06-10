unit WVPythia.Command.Plugin.ApiKey;

interface

uses
  System.SysUtils, WVPythia.Command.Plugin, WVPythia.Chat.Interfaces,
  WVPythia.ApiKey.Service.Intf;

type
  TApiKeyPlugin = class(TCommandPlugin)
  strict private
    FService: IApiKeyService;
  strict protected
    function DoExecute(const Action: string;
      const Args: TArray<string>): TCommandExecResult; override;
  public
    constructor Create(const AService: IApiKeyService);
  end;

implementation

{$REGION 'Dev notes'}

(*
    Developer Note — API key command plugin

    These units implement the built-in command plugin used to manage named API
    keys from the browser input.

    The command exposed to the user is:

        /api-key <action> <name>

    The plugin is part of the command layer, but the actual API key behavior is
    delegated to a service. This keeps command parsing, command dispatch and API
    key handling separated.

    -------------------------------------------------------------------------
                             Units involved
    -------------------------------------------------------------------------

    Browser.Command.Plugin.ApiKey
      Declares TApiKeyPlugin, the command plugin registered under the
      "api-key" command name.

    Browser.ApiKey.Service.Intf
      Declares IApiKeyService and TApiKeyOperationResult. This is the contract
      used by the plugin; it keeps the command layer independent from the
      storage and UI details.

    Browser.ApiKey.Service
      Provides the default implementation of IApiKeyService. It uses the
      browser facade to prompt for secret values, access the configured secret
      store, persist the list of known key names, refresh API key state, and
      display user feedback.

    -------------------------------------------------------------------------
                           Command surface
    -------------------------------------------------------------------------

    TApiKeyPlugin registers the following actions:

        /api-key new    <name>
        /api-key delete <name>
        /api-key exists <name>

    Each action expects exactly one argument: the logical name of the key.

    The command argument is the name of the key, not the secret value itself.
    Secret values should not be passed directly on the command line.

    -------------------------------------------------------------------------
                              Plugin role
    -------------------------------------------------------------------------

    TApiKeyPlugin is deliberately thin.

    It inherits from TCommandPlugin, declares the "api-key" command name, adds
    the supported actions with AddAction, and delegates execution to
    IApiKeyService.

    The plugin does not decide where keys are stored, how the UI asks for a
    secret value, or how the browser refreshes API key state. Those details
    belong to the service and to the browser implementation behind IBrowser.

    This gives the command layer one clear responsibility: map a validated
    command action to the corresponding service call.

    -------------------------------------------------------------------------
                            Service contract
    -------------------------------------------------------------------------

    IApiKeyService exposes three operations:

      • CreateKey
      • DeleteKey
      • Exists

    It also receives an IBrowser instance through its Browser property.

    The browser reference is required because API key handling is not isolated
    from the browser shell:

      • creating a key opens a hidden input request in the UI
      • deleting a key updates the persisted key-name list
      • checking a key reports feedback through the browser
      • changes may trigger browser-side refresh logic

    The interface hides the storage strategy from the command plugin. A service
    implementation may rely on the default browser secret store, or be replaced
    by another implementation if the host needs a different policy.

    -------------------------------------------------------------------------
                           Name normalization
    -------------------------------------------------------------------------

    The default service normalizes key names with:

        Trim.ToLowerInvariant

    API key names are therefore treated as case-insensitive identifiers, and
    leading or trailing spaces are ignored.

    The normalized name is used when checking existence and when maintaining the
    JSON list of known key names.

    The original name may still be used in user-facing messages so that feedback
    stays close to what the user typed.

    -------------------------------------------------------------------------
                            Creating a key
    -------------------------------------------------------------------------

    The "new" action does not create the secret value directly from the command
    text.

    Instead, TApiKeyService.CreateKey asks the browser to display a hidden input
    request:

        BrowserInput(..., Hidden = True)

    This lets the command start the operation without exposing the secret in the
    slash command itself.

    The rest of the value-capture flow belongs to the browser input bridge and
    to the API key handling already implemented by the browser component.

    -------------------------------------------------------------------------
                             Deleting a key
    -------------------------------------------------------------------------

    The "delete" action first checks the persisted list of API key names through
    ApiKeyNamesAsJsonString.

    If the requested key name is not present, the service displays a warning and
    returns a failed operation result.

    If the key exists, the service:

      1. deletes the secret from ApiKeySecretStore
      2. removes the normalized name from the JSON key-name list
      3. writes the updated JSON back through ApiKeyNamesAsJsonString
      4. calls ApiKeyValuesUpdate
      5. displays a success message

    The JSON file tracks key names only. Secret values belong to the secret
    store.

    -------------------------------------------------------------------------
                           Checking existence
    -------------------------------------------------------------------------

    The "exists" action reads the secret store with the normalized key name.

    The service does not return the secret value. It only reports whether a
    stored value is present.

    Feedback is displayed through the browser:

      • success when the key exists
      • warning when the key is not found

    -------------------------------------------------------------------------
                           Browser integration
    -------------------------------------------------------------------------

    The default API key service depends on the browser facade instead of
    directly depending on a concrete FMX or VCL browser class.

    The browser provides the operations needed by the service:

      • prompting for a hidden input value
      • displaying errors, warnings and success messages
      • reading and writing the API key names JSON
      • accessing the configured secret store
      • notifying that API key values changed

    During browser initialization, the browser instance is injected into the
    service before the command is used.

    -------------------------------------------------------------------------
                             Registration
    -------------------------------------------------------------------------

    The API key plugin is registered by the browser command-line layer during
    command-line initialization:

        RegisterPlugin(TApiKeyPlugin.Create(FApiKeyService));

    It then follows the same parser, validation and dispatch path as any other
    command plugin.

    Host-defined command plugins can be registered separately through the
    browser command-registration hook. The API key plugin does not require a
    special dispatch path.

    -------------------------------------------------------------------------
                        Error and result policy
    -------------------------------------------------------------------------

    IApiKeyService methods return TApiKeyOperationResult so that service-level
    operations can report success or failure with a message.

    Browser-facing feedback is currently also emitted by the service itself
    through DisplayError, DisplayWarning or DisplaySuccess.

    If command-level success status becomes important for this plugin, keep the
    policy consistent by letting TApiKeyPlugin.DoExecute propagate the service
    result instead of replacing it with a generic command result.

    -------------------------------------------------------------------------
                         Architectural constraints
    -------------------------------------------------------------------------

    • Keep TApiKeyPlugin as a command adapter.
    • Keep storage and UI details inside the service or browser facade.
    • Do not pass secret values directly through the slash command.
    • Normalize key names before storage lookup or JSON-name updates.
    • Store key names and secret values separately.
    • Do not expose secret values in command results or browser messages.
    • Use the browser secret store instead of introducing plugin-local storage.
    • Use ApiKeyValuesUpdate after mutations so the browser can refresh state.
    • Keep the service replaceable through IApiKeyService.
    • Keep the command registered through the normal command registry.

    -------------------------------------------------------------------------
                            Extension guideline
    -------------------------------------------------------------------------

    To change the storage or prompting policy, replace the IApiKeyService
    implementation rather than modifying the command plugin.

    To change the command surface, update TApiKeyPlugin by declaring the new
    action with AddAction, then delegate the behavior to IApiKeyService or to
    another service object.

    The intended dependency direction is:

        command plugin -> IApiKeyService -> IBrowser / secret store

    The command plugin should remain the entry point. The service owns the API
    key behavior. The browser owns UI feedback, input capture, persistence hooks
    and secret-store access.

    -------------------------------------------------------------------------
                             Related units
    -------------------------------------------------------------------------

    The API key command is split across three units. When reviewing or changing
    this feature, these are the files to inspect first:

      • Browser.Command.Plugin.ApiKey
        Command plugin exposed through "/api-key". Declares the supported
        actions and delegates execution to the API key service.

      • Browser.ApiKey.Service.Intf
        Service contract used by the plugin. Declares IApiKeyService and the
        operation-result type returned by API key operations.

      • Browser.ApiKey.Service
        Default service implementation. Handles key-name normalization,
        browser feedback, secret-store access, persisted key-name updates and
        API key state refresh.

*)

{$ENDREGION}

constructor TApiKeyPlugin.Create(const AService: IApiKeyService);
begin
  inherited Create('api-key');
  FService := AService;
  AddAction('new',    1, 1);
  AddAction('delete', 1, 1);
  AddAction('exists', 1, 1);
end;

function TApiKeyPlugin.DoExecute(const Action: string;
  const Args: TArray<string>): TCommandExecResult;
begin
  var KeyName := Args[0];
  if Action = 'new' then
    begin
      FService.CreateKey(KeyName);
      Result := TCommandExecResult.Ok(Format('%s created', [KeyName]));
    end
  else
  if Action = 'delete' then
    begin
      FService.DeleteKey(KeyName);
      Result := TCommandExecResult.Ok(Format('%s deleted', [KeyName]));
    end
  else
  if Action = 'exists' then
    begin
      if FService.Exists(KeyName) then
        Result := TCommandExecResult.Ok(Format('%s finded.', [KeyName]))
      else
        Result := TCommandExecResult.Ok(Format('%s not found.', [KeyName]));
    end
  else
    Result := TCommandExecResult.Fail('Unmanaged action');
end;

end.
