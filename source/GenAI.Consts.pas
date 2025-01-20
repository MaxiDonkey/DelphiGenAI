unit GenAI.Consts;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

const
  DATE_FORMAT = 'yyyy-MM-dd';
  TIME_FORMAT = 'hh:nn:ss';
  DATE_TIME_FORMAT = DATE_FORMAT + ' ' + TIME_FORMAT;

  AudioTypeAccepted: TArray<string> = ['audio/x-wav', 'audio/mpeg'];
  ImageTypeAccepted: TArray<string> = ['image/png', 'image/jpeg', 'image/gif', 'image/webp'];

implementation

end.
