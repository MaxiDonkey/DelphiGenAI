unit GenAI.Gemini.Extra_body;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.JSON,
  GenAI.API.Params, GenAI.Types;

type
  TThinkingConfig = class(TJSONParam)
    function IncludeThoughts(const Value: Boolean): TThinkingConfig;
    function ThinkingBudget(const Value: Integer): TThinkingConfig;
    function ThinkingLevel(const Value: ThinkingLevelType): TThinkingConfig; overload;
    function ThinkingLevel(const Value: string): TThinkingConfig; overload;
  end;

  TExtraBody = class(TJSONParam)
    function ThinkingConfig(const Value: TThinkingConfig): TExtraBody;
    function CachedContent(const Value: string): TExtraBody;
  end;

implementation

{ TThinkingConfig }

function TThinkingConfig.IncludeThoughts(const Value: Boolean): TThinkingConfig;
begin
  Result := TThinkingConfig(Add('includeThoughts', Value));
end;

function TThinkingConfig.ThinkingBudget(const Value: Integer): TThinkingConfig;
begin
  Result := TThinkingConfig(Add('thinkingBudget', Value));
end;

function TThinkingConfig.ThinkingLevel(const Value: string): TThinkingConfig;
begin
  Result := TThinkingConfig(Add('thinkingLevel', ThinkingLevelType.Create(Value).ToString));
end;

function TThinkingConfig.ThinkingLevel(
  const Value: ThinkingLevelType): TThinkingConfig;
begin
  Result := TThinkingConfig(Add('thinkingLevel', Value.ToString));
end;

{ TExtraBody }

function TExtraBody.CachedContent(const Value: string): TExtraBody;
begin
  Result := TExtraBody(Add('cached_content', Value));
end;

function TExtraBody.ThinkingConfig(const Value: TThinkingConfig): TExtraBody;
begin
  Result := TExtraBody(Add('thinking_config', Value.Detach));
end;

end.
