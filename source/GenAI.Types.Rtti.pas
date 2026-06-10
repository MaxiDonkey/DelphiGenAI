unit GenAI.Types.Rtti;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Rtti, GenAI.Exceptions;

type
  TRttiMemberAccess = record
  private
    class function FindMember(RttiType: TRttiType; const Name: string): TRttiMember; static;
  public
    class function GetValue<T>(Instance: TObject; const Name: string): T; static;
    class procedure SetValue<T>(Instance: TObject; const Name: string; const Value: T); static;
  end;

implementation

{ TRttiMemberAccess }

class function TRttiMemberAccess.FindMember(RttiType: TRttiType; const Name: string): TRttiMember;
begin
  Result := RttiType.GetField(Name);
  if Result = nil then
    Result := RttiType.GetProperty(Name);
end;

class function TRttiMemberAccess.GetValue<T>(Instance: TObject; const Name: string): T;
var
  Ctx: TRttiContext;
  RType: TRttiType;
  M: TRttiMember;
  V: TValue;
begin
  Ctx := TRttiContext.Create;
  RType := Ctx.GetType(Instance.ClassType);
  M := FindMember(RType, Name);

  if M = nil then
    raise TGenAIAPIException.CreateFmt('RTTI: member "%s" not found on %s', [Name, Instance.ClassName]);

  if M is TRttiField then
    V := TRttiField(M).GetValue(Instance)
  else
    V := TRttiProperty(M).GetValue(Instance);

  Result := V.AsType<T>;
end;

class procedure TRttiMemberAccess.SetValue<T>(Instance: TObject; const Name: string; const Value: T);
var
  Ctx: TRttiContext;
  RType: TRttiType;
  M: TRttiMember;
  TV: TValue;
begin
  Ctx := TRttiContext.Create;
  RType := Ctx.GetType(Instance.ClassType);
  M := FindMember(RType, Name);

  if M = nil then
    raise TGenAIAPIException.CreateFmt('RTTI: member "%s" not found on %s', [Name, Instance.ClassName]);

  TV := TValue.From<T>(Value);

  if M is TRttiField then
    TRttiField(M).SetValue(Instance, TV)
  else
    begin
      if not TRttiProperty(M).IsWritable then
        raise TGenAIAPIException.CreateFmt('RTTI: property "%s" on %s is read-only', [Name, Instance.ClassName]);
      TRttiProperty(M).SetValue(Instance, TV);
    end;
end;

end.
