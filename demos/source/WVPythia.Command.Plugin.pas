unit WVPythia.Command.Plugin;

interface

uses
  System.SysUtils, WVPythia.Command.Parser, WVPythia.Chat.Interfaces;

type
  /// <summary>
  /// Base class for creating a /xxx command.
  /// </summary>
  /// <remarks>
  /// Subclasses declare their actions in their constructor via AddAction
  /// (inherited from TCommandSpec), and implement DoExecute.
  /// </remarks>
  TCommandPlugin = class abstract(TCommandSpec, ICommandPlugin)
  strict protected
    function DoExecute(const Action: string;
      const Args: TArray<string>): TCommandExecResult; virtual; abstract;
  public
    // ICommandPlugin
    function GetName: string;
    function Execute(const Action: string;
      const Args: TArray<string>): TCommandExecResult;
  end;

implementation

{$REGION 'Dev notes'}

(*
    Developer Note

    These units define the command-plugin layer used by the browser input.

    The purpose of this layer is to expose controlled native extension points
    through slash-style commands typed in the chat input. A plugin is a Delphi
    command handler: it declares a command name, declares the actions it accepts,
    receives parsed arguments, and delegates the actual work to the relevant
    service or host-side code.

    This is not a dynamic plugin platform. Plugins are registered explicitly by
    Delphi code, kept in memory by the registry, and executed through the same
    validation path as the built-in commands. The goal is to keep command
    behavior predictable, auditable, and easy to extend without coupling the
    browser UI to every feature that may need a command entry point.

    -------------------------------------------------------------------------
                           Units involved
    -------------------------------------------------------------------------

    Browser.Command.Parser
      Parses raw input text into a TParsedCommand record and defines the
      command/action metadata used during validation.

    Browser.Command.Plugin
      Provides TCommandPlugin, the base class expected for executable command
      plugins.

    Browser.Command.Registry
      Owns registered plugins, validates parsed commands against their declared
      actions, and dispatches execution.

    Together, these units form the command layer used by TFMXBrowserCommandLine
    in FMX.Browser.Chat.

    -------------------------------------------------------------------------
                           Command syntax
    -------------------------------------------------------------------------

    Commands use this shape:

        /command-name action [arg1] [arg2] ...

    TCommandParser.TryParse applies the following rules:

        leading spaces are ignored before checking for "/"
        the first token after "/" is the command name
        the second token is the action name
        remaining tokens are stored as arguments
        command names and action names are normalized to lower case
        double-quoted strings are preserved as a single argument
        parsing only describes the command; it never executes it

    Examples:

        /config reset
        /config set theme dark
        /config set-title "My local session"

    The parser is intentionally syntax-level only. It does not know which
    commands exist, which actions are legal, or how many arguments an action
    accepts. Those checks belong to the registry.

    -------------------------------------------------------------------------
                           Plugin contract
    -------------------------------------------------------------------------

    Command plugins should inherit from TCommandPlugin.

    A plugin declares its command surface in its constructor:

        inherited Create('sample');
        AddAction('run', 1, 1);
        AddAction('reset', 0, 0);
        AddAction('append', 1, -1);

    AddAction defines the public shape of the command:

        action name
        minimum argument count
        maximum argument count
        MaxArgs = -1 means no upper limit

    Execution logic belongs in DoExecute.

    The declared action list is the validation contract. If DoExecute handles an
    action that was not declared with AddAction, the registry will reject that
    action before the plugin is called.

    This keeps command validation independent from implementation branches
    hidden inside DoExecute.

    -------------------------------------------------------------------------
                     Important inheritance invariant
    -------------------------------------------------------------------------

    TCommandRegistry stores plugins through ICommandPlugin, but action lookup
    currently relies on this cast:

        APlugin as TCommandSpec

    This means registered plugins are expected to inherit from TCommandPlugin,
    because TCommandPlugin itself inherits from TCommandSpec.

    Do not register an object that merely implements ICommandPlugin unless the
    registry is changed to expose action metadata through the interface. With
    the current design, TCommandPlugin is the supported base class.

    -------------------------------------------------------------------------
                       Registry responsibilities
    -------------------------------------------------------------------------

    TCommandRegistry is responsible for two distinct phases:

      1. Validate
         Parse the source text, resolve the target plugin, resolve the action,
         and check the argument count.

      2. Execute
         Dispatch a previously validated command to the matching plugin.

    Validate reports one of the following statuses:

        csNotACommand
        csOk
        csUnknownCommand
        csUnknownAction
        csWrongArgCount

    This separation allows the browser input layer to make a clear decision:

        non-command text continues through normal chat handling
        malformed command text displays a validation error
        valid command text is dispatched

    Command execution should normally go through Validate first. Execute still
    protects itself against invalid status or missing plugin, but that is a
    defensive path, not the normal flow.

    -------------------------------------------------------------------------
                           Registration model
    -------------------------------------------------------------------------

    Plugins are registered with:

        ICommandRegistry.RegisterPlugin

    Registration is name-based and case-insensitive. Command names are stored in
    lower case.

    Registering a plugin with an existing name replaces the previous plugin for
    that command name. This is a deliberate override mechanism and should be
    used consciously.

    The browser component creates its command registry during command-line layer
    construction. Additional commands can be registered by host code during
    browser initialization through the command-registration hook exposed by the
    browser component.

    -------------------------------------------------------------------------
                             Runtime flow
    -------------------------------------------------------------------------

    The normal runtime path is:

      1. The chat input text is passed to TryHandleAsCommand.
      2. TCommandRegistry.Validate parses and validates the text.
      3. csNotACommand returns False, allowing normal prompt handling.
      4. Validation errors are displayed through DisplayError.
      5. csOk dispatches the command through TCommandRegistry.Execute.
      6. The matching plugin receives the normalized action and arguments.
      7. The plugin returns a TCommandExecResult.
      8. On success, the input bubble is partially reset.
      9. On failure, the returned message is displayed as an error.

    From the input layer perspective, command dispatch is synchronous. Plugins
    should therefore avoid owning long-running workflows directly. When a command
    needs heavier work, DoExecute should delegate to an object that already owns
    the relevant lifetime, state, or UI feedback policy.

    -------------------------------------------------------------------------
                             Error policy
    -------------------------------------------------------------------------

    TCommandPlugin.Execute wraps DoExecute in a try / except block.

    Expected failures should be returned explicitly:

        TCommandExecResult.Fail(...)

    Successful handling should be returned explicitly:

        TCommandExecResult.Ok(...)

    Unexpected exceptions raised by DoExecute are converted into failed command
    results. This prevents command plugin errors from escaping into the browser
    input pipeline.

    Validation errors are handled before execution. Runtime errors are handled
    by the plugin wrapper.

    -------------------------------------------------------------------------
                       Architectural constraints
    -------------------------------------------------------------------------

      Keep plugins focused on command handling.
      Declare every supported action with AddAction.
      Keep command names stable once they are exposed.
      Treat command names as part of the component API.
      Register plugins explicitly; do not add implicit discovery here.
      Do not introduce dynamic loading in this layer.
      Do not bypass TCommandRegistry for validation.
      Do not put browser rendering logic inside command plugins.
      Do not let plugins become owners of unrelated application state.
      Delegate business logic, persistence, dialogs, network work, or longer
      workflows to services or host-side objects.
      Avoid command-name collisions unless overriding is intentional.

    -------------------------------------------------------------------------
                          Extension guideline
    -------------------------------------------------------------------------

    To add a command plugin:

      1. Create a class inheriting from TCommandPlugin.
      2. Call inherited Create with the command name.
      3. Declare every supported action with AddAction.
      4. Implement DoExecute.
      5. Register the plugin in the command registry during initialization.

    A command plugin should remain an adapter between parsed input and native
    code. The registry owns command validity; the plugin owns command execution;
    the underlying service owns the actual feature behavior.

    -------------------------------------------------------------------------
                        Host-side extension point
    -------------------------------------------------------------------------

    The browser component exposes a registration hook for host applications:

        TFMXPythia.OnRegisterCommandPlugins
        TVCLPythia.OnRegisterCommandPlugins

    This hook is the intended place to register custom command plugins.

    A host application can define its own TCommandPlugin descendant, declare its
    actions with AddAction, implement DoExecute, then register the plugin through
    the registry provided by the event.

    Custom plugins registered this way use the same parser, validation rules and
    execution path as the commands provided by the component.

    More advanced command scenarios can also combine a native command plugin
    with JavaScript injected into the browser UI and events routed through the
    bridge. That pattern is documented separately in the section dedicated to
    creating a command plugin coupled with custom UI JavaScript and bridge event
    handling.

*)

{$ENDREGION}

function TCommandPlugin.GetName: string;
begin
  Result := Name;
end;

function TCommandPlugin.Execute(const Action: string;
  const Args: TArray<string>): TCommandExecResult;
begin
  try
    Result := DoExecute(Action.ToLowerInvariant, Args);
  except
    on E: Exception do
      Result := TCommandExecResult.Fail(
        Format('Execution error : %s', [E.Message]));
  end;
end;

end.
