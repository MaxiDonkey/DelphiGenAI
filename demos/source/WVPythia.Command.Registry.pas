unit WVPythia.Command.Registry;

interface

uses
  System.SysUtils, System.Generics.Collections,
  WVPythia.Command.Parser, WVPythia.Chat.Interfaces, WVPythia.Strs;

type
  TCommandRegistry = class(TInterfacedObject, ICommandRegistry)
  private
    FPlugins: TDictionary<string, ICommandPlugin>;
    function FindAction(const APlugin: ICommandPlugin;
      const AActionName: string; out Spec: TActionSpec): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function RegisterPlugin(const APlugin: ICommandPlugin): ICommandPlugin;
    function Validate(const Source: string;
      out Res: TCommandResult): Boolean;
    function Execute(const Res: TCommandResult): TCommandExecResult;
  end;

implementation

{ TCommandRegistry }

constructor TCommandRegistry.Create;
begin
  inherited;
  FPlugins := TDictionary<string, ICommandPlugin>.Create;
end;

destructor TCommandRegistry.Destroy;
begin
  FPlugins.Free;
  inherited;
end;

function TCommandRegistry.RegisterPlugin(
  const APlugin: ICommandPlugin): ICommandPlugin;
begin
  if APlugin = nil then
    raise EArgumentNilException.Create(S_COMMAND_PLUGIN_NOT_BE_NULL);
  FPlugins.AddOrSetValue(APlugin.Name.ToLowerInvariant, APlugin);
  Result := APlugin;
end;

function TCommandRegistry.FindAction(const APlugin: ICommandPlugin;
  const AActionName: string; out Spec: TActionSpec): Boolean;
begin
  {--- The plugin is still also a TCommandSpec (by inheritance from TCommandPlugin). }
  var CmdSpec := APlugin as TCommandSpec;
  Result := CmdSpec.TryGetAction(AActionName, Spec);
end;

function TCommandRegistry.Validate(const Source: string;
  out Res: TCommandResult): Boolean;
var
  Plugin: ICommandPlugin;
  Action: TActionSpec;
  ArgCount: Integer;
begin
  Res := Default(TCommandResult);

  if not TCommandParser.TryParse(Source, Res.Parsed) then
    begin
      Res.Status := csNotACommand;
      Exit(False);
    end;

  if not FPlugins.TryGetValue(Res.Parsed.Name, Plugin) then
    begin
      Res.Status := csUnknownCommand;
      Res.Message := Format(S_COMMAND_UNKNOWN, [Res.Parsed.Name]);
      Exit(False);
    end;

  if (not Res.Parsed.HasAction) or
     (not FindAction(Plugin, Res.Parsed.Action, Action)) then
    begin
      Res.Status := csUnknownAction;
      if Res.Parsed.HasAction then
        Res.Message := Format(S_COMMAND_ACTION_UNKNOWN,
          [Res.Parsed.Name, Res.Parsed.Action])
      else
        Res.Message := Format(S_COMMAND_MISSING_ACTION, [Res.Parsed.Name]);
      Exit(False);
    end;

  ArgCount := Res.Parsed.ArgCount;
  if (ArgCount < Action.MinArgs) or
     ((Action.MaxArgs >= 0) and (ArgCount > Action.MaxArgs)) then
    begin
      Res.Status := csWrongArgCount;
      Res.Message := Format(
        S_COMMAND_INCORRECT_NUMBER_OF_ARGUMENTS,
        [Res.Parsed.Name, Res.Parsed.Action, ArgCount]);
      Exit(False);
    end;

  Res.Status := csOk;
  Result := True;
end;

function TCommandRegistry.Execute(
  const Res: TCommandResult): TCommandExecResult;
var
  Plugin: ICommandPlugin;
begin
  if Res.Status <> csOk then
    Exit(TCommandExecResult.Fail(Res.Message));

  if not FPlugins.TryGetValue(Res.Parsed.Name, Plugin) then
    Exit(TCommandExecResult.Fail(
      Format(S_COMMAND_NO_PLUGIN_FOR, [Res.Parsed.Name])));

  Result := Plugin.Execute(Res.Parsed.Action, Res.Parsed.Args);
end;

end.
