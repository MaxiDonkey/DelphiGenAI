unit GenAI.API.DeserializerToString;

interface

uses
  System.SysUtils, GenAI.Consts;

const
  FieldsAsString : TArray<string> = ['"metadata": {', '"metadata":{'];

type
  IDeserializeToString = interface
    ['{60B0EAB1-3C74-4ACE-8B33-6DA2B40485F9}']
    function Replace(const Value: string): string; overload;
  end;

  TDeserializeToString = class(TInterfacedObject, IDeserializeToString)
  private
    function FieldAsString(const Value, Field: string): string; overload;
    function FieldAsString(const Value: string; const Field: TArray<string>): string; overload;
  public
    function Replace(const Value: string): string; overload;
    class function CreateInstance: IDeserializeToString;
  end;

implementation

{ TDeserializeToString }

function TDeserializeToString.FieldAsString(const Value,
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

class function TDeserializeToString.CreateInstance: IDeserializeToString;
begin
  Result := TDeserializeToString.Create;
end;

function TDeserializeToString.Replace(const Value: string): string;
begin
  Result := FieldAsString(Value, FieldsAsString);
end;

function TDeserializeToString.FieldAsString(const Value: string;
  const Field: TArray<string>): string;
begin
  Result := Value;
  if Length(Field) > 0 then
    begin
      for var Item in Field do
        Result := FieldAsString(Result, Item);
    end;
end;

end.
