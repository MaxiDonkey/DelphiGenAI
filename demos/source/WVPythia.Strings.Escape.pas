unit WVPythia.Strings.Escape;

interface

uses
  System.SysUtils;

type
  TEscapeHelper = record
  public
    class function EscapeJSString(const S: string; const FullJson: Boolean = True): string; static;
    class function EscapeHTML(const S: string): string; static;
    class function ToPreformattedHTML(const S: string): string; static;
  end;

implementation

{ TEscapeHelper }

class function TEscapeHelper.EscapeHTML(const S: string): string;
const
  Entities: array[0..4] of array[0..1] of string = (
    ('&', '&amp;'),
    ('<', '&lt;'),
    ('>', '&gt;'),
    ('"', '&quot;'),
    ('''', '&#39;')
  );
var
  i: Integer;
begin
  Result := S;
  for i := Low(Entities) to High(Entities) do
    Result := Result.Replace(Entities[i][0], Entities[i][1], [rfReplaceAll]);
end;

class function TEscapeHelper.EscapeJSString(const S: string;
  const FullJson: Boolean): string;
var
  c: Char;
begin
  Result := '';
  for var i := 1 to Length(S) do
    begin
      c := S[i];
      case c of
        '"': Result := Result + '\"';
        '\': Result := Result + '\\';
        '/': Result := Result + '\/';
        #8: Result := Result + '\b';
        #9: Result := Result + '\t';
        #10: Result := Result + '\n';
        #11: Result := Result + '\u000B';
        #12: Result := Result + '\f';
        #13: Result := Result + '\r';

      else
        if (Ord(c) < 32) or (Ord(c) > 126) then
          Result := Result + '\u' + IntToHex(Ord(c), 4)
        else
          Result := Result + c;
      end;
    end;
  if FullJson then
    Result := Format('"%s"', [Result]);
end;

class function TEscapeHelper.ToPreformattedHTML(const S: string): string;
begin
  Result :=
    '<pre style="white-space: pre-wrap; word-break: break-word; margin:0;">' +
    EscapeHTML(S) +
    '</pre>';
end;

end.
