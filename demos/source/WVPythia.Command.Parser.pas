unit WVPythia.Command.Parser;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TCommandStatus = (
    csNotACommand,
    csOk,
    csUnknownCommand,
    csUnknownAction,
    csWrongArgCount
  );

  TParsedCommand = record
    Name: string;
    Action: string;
    Args: TArray<string>;
    Raw: string;
    function HasAction: Boolean;
    function ArgCount: Integer;
  end;

  TCommandParser = record
  strict private
    class function Tokenize(const Source: string): TArray<string>; static;
  public

    class function TryParse(const Source: string;
      out Parsed: TParsedCommand): Boolean; static;
  end;

  TCommandResult = record
    Status: TCommandStatus;
    Parsed: TParsedCommand;
    Message: string;
    function IsSuccess: Boolean;
  end;

  TActionSpec = record
    Name: string;
    MinArgs: Integer;
    MaxArgs: Integer;     // -1 = no upper limit
  end;

  TCommandSpec = class(TInterfacedObject)
  private
    FName: string;
    FActions: TDictionary<string, TActionSpec>;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    function AddAction(const AName: string;
      AMinArgs: Integer = 0; AMaxArgs: Integer = -1): TCommandSpec;
    function TryGetAction(const AName: string;
      out Spec: TActionSpec): Boolean;
    property Name: string read FName;
  end;

implementation

{ TParsedCommand }

function TParsedCommand.HasAction: Boolean;
begin
  Result := not Action.IsEmpty;
end;

function TParsedCommand.ArgCount: Integer;
begin
  Result := Length(Args);
end;

{ TCommandParser }

class function TCommandParser.Tokenize(const Source: string): TArray<string>;
begin
  var List := TList<string>.Create;
  var Current := TStringBuilder.Create;
  try
    var InQuote := False;
    var Len := Source.Length;
    var I := 1;

    while I <= Len do
      begin
        var C := Source[I];
        if InQuote then
          begin
            if C = '"' then
              InQuote := False
            else
              Current.Append(C);
          end
        else
        begin
          case C of
            '"':
              InQuote := True;
            ' ', #9:
              if Current.Length > 0 then
                begin
                  List.Add(Current.ToString);
                  Current.Clear;
                end;
          else
            Current.Append(C);
          end;
        end;
        Inc(I);
      end;

    if Current.Length > 0 then
      List.Add(Current.ToString);

    Result := List.ToArray;
  finally
    Current.Free;
    List.Free;
  end;
end;

class function TCommandParser.TryParse(const Source: string;
  out Parsed: TParsedCommand): Boolean;
begin
  Parsed := Default(TParsedCommand);
  Parsed.Raw := Source;

  var Trimmed := Source.TrimLeft;
  if Trimmed.IsEmpty or (Trimmed[1] <> '/') then
    Exit(False);

  var Tokens := Tokenize(Trimmed.Substring(1));
  if Length(Tokens) = 0 then
    Exit(False);

  Parsed.Name := Tokens[0].ToLowerInvariant;
  if Length(Tokens) >= 2 then
    Parsed.Action := Tokens[1].ToLowerInvariant;

  if Length(Tokens) >= 3 then
    Parsed.Args := Copy(Tokens, 2, Length(Tokens) - 2);

  Result := True;
end;

{ TCommandSpec }

constructor TCommandSpec.Create(const AName: string);
begin
  inherited Create;
  FName := AName.ToLowerInvariant;
  FActions := TDictionary<string, TActionSpec>.Create;
end;

destructor TCommandSpec.Destroy;
begin
  FActions.Free;
  inherited;
end;

function TCommandSpec.AddAction(const AName: string;
  AMinArgs, AMaxArgs: Integer): TCommandSpec;
begin
  var Spec := Default(TActionSpec);
  Spec.Name := AName.ToLowerInvariant;
  Spec.MinArgs := AMinArgs;
  Spec.MaxArgs := AMaxArgs;
  FActions.AddOrSetValue(Spec.Name, Spec);
  Result := Self;
end;

function TCommandSpec.TryGetAction(const AName: string;
  out Spec: TActionSpec): Boolean;
begin
  Result := FActions.TryGetValue(AName.ToLowerInvariant, Spec);
end;

{ TCommandResult }

function TCommandResult.IsSuccess: Boolean;
begin
  Result := Status = csOk;
end;

end.
