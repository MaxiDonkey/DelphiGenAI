unit Demo.OpenAI.Strs;

interface

type
  TOpenAIDemoTranslations = record
  public
    class procedure Load(const Value: string); static;
    class procedure LoadFromLanguage(const LanguageFolder,
      Language: string); static;
  end;

var
  S_DEMO_TOOL_CONFIRMATION_TITLE: string =
    'Confirmation';
  S_DEMO_TOOL_ALLOW: string =
    'Allow';
  S_DEMO_TOOL_DENY: string =
    'Deny';
  S_DEMO_TOOL_ALLOW_CALL: string =
    'Allow this tool call?';
  S_DEMO_INTERRUPTED_BY_USER: string =
    'Interrupted by the user.';

implementation

uses
  System.SysUtils, System.IOUtils,
  WVPythia.JSON.SafeReader, WVPythia.TextFile.Helper;

{ TAnthropicDemoTranslations }

class procedure TOpenAIDemoTranslations.Load(const Value: string);
begin
  var JSONObject := TJsonReader.Parse(Value);

  S_DEMO_TOOL_CONFIRMATION_TITLE := JSONObject.AsString(
    'more.demo_anthropic_tool_confirmation_title',
    S_DEMO_TOOL_CONFIRMATION_TITLE);

  S_DEMO_TOOL_ALLOW := JSONObject.AsString(
    'more.demo_anthropic_tool_allow',
    S_DEMO_TOOL_ALLOW);

  S_DEMO_TOOL_DENY := JSONObject.AsString(
    'more.demo_anthropic_tool_deny',
    S_DEMO_TOOL_DENY);

  S_DEMO_TOOL_ALLOW_CALL := JSONObject.AsString(
    'more.demo_anthropic_tool_allow_call',
    S_DEMO_TOOL_ALLOW_CALL);

  S_DEMO_INTERRUPTED_BY_USER := JSONObject.AsString(
    'more.demo_anthropic_interrupted_by_user',
    S_DEMO_INTERRUPTED_BY_USER);
end;

class procedure TOpenAIDemoTranslations.LoadFromLanguage(
  const LanguageFolder, Language: string);
begin
  var FileName := TPath.Combine(LanguageFolder, Language + '.json');
  if not FileExists(FileName) then
    Exit;

  Load(TFileIOHelper.LoadFromFile(FileName));
end;

end.
