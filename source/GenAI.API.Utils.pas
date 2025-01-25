unit GenAI.API.Utils;

interface

uses
  System.SysUtils;

const
  FIELDSASSTRING : TArray<string> = ['"metadata": {', '"metadata":{'];

type
  ICustomFieldsPrepare = interface
    ['{60B0EAB1-3C74-4ACE-8B33-6DA2B40485F9}']
    function Convert(const Value: string): string; overload;
  end;

  TDeserializationPrepare = class(TInterfacedObject, ICustomFieldsPrepare)
  private
    function UpdateFieldValue(const Value, Field: string): string; overload;
    function UpdateFieldValue(const Value: string; const Field: TArray<string>): string; overload;
  public
    function Convert(const Value: string): string;
    class function CreateInstance: ICustomFieldsPrepare;
  end;

implementation

{ TDeserializationPrepare }

function TDeserializationPrepare.UpdateFieldValue(const Value,
  Field: string): string;
begin
  Result := Value;
  var i := Pos(Field, Result);
  while (i > 0) and (i < Result.Length) do
    begin
      i := i + Field.Length - 1;
      Result[i] := '"';
      Inc(i);
      var j := 0;
      while (j > 0) or ((j = 0) and not (Result[i] = '}')) do
        begin
          case Result[i] of
            '{':
              Inc(j);
            '}':
              j := j - 1;
            '"':
              Result[i] := '`';
          end;
          Inc(i);
          if i > Result.Length then
            raise Exception.Create('Invalid JSON string');
        end;
      Result[i] := '"';
      i := Pos(Field, Result);
    end;
end;

class function TDeserializationPrepare.CreateInstance: ICustomFieldsPrepare;
begin
  Result := TDeserializationPrepare.Create;
end;

function TDeserializationPrepare.Convert(const Value: string): string;
begin
  Result := UpdateFieldValue(Value, FIELDSASSTRING);
end;

function TDeserializationPrepare.UpdateFieldValue(const Value: string;
  const Field: TArray<string>): string;
begin
  Result := Value;
  if Length(Field) > 0 then
    begin
      for var Item in Field do
        Result := UpdateFieldValue(Result, Item);
    end;
end;

end.
