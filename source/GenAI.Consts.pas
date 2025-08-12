unit GenAI.Consts;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils;

const
  DATE_FORMAT = 'yyyy-MM-dd';
  TIME_FORMAT = 'hh:nn:ss';
  DATE_TIME_FORMAT = DATE_FORMAT + ' ' + TIME_FORMAT;

  AudioTypeAccepted: TArray<string> = ['audio/wav', 'audio/mpeg', 'audio/webm', 'audio/opus', 'audio/ogg'];
  ImageTypeAccepted: TArray<string> = ['image/png', 'image/jpeg', 'image/gif', 'image/webp', 'binary/octet-stream'];
  DocTypeAccepted: TArray<string> = ['application/pdf'];

  ReasoningModels: TArray<string> = ['o1', 'o1-mini', 'o1-pro', 'o3', 'o3-mini', 'o4-mini'];

function IsReasoningModel(const Value: string): Boolean;

implementation

uses
  System.StrUtils;

function IsReasoningModel(const Value: string): Boolean;
begin
  Result := IndexStr(Value.Trim.Tolower, ReasoningModels) > -1;
end;

end.
