unit GenAI.Responses.Helpers;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.StrUtils, GenAI.NetEncoding.Base64, GenAI.Httpx, GenAI.Consts;

type
  /// <summary>
  /// Provides helper methods for determining MIME types, extracting file names and details,
  /// and checking if a MIME type corresponds to an image or PDF document.
  /// </summary>
  TFormatHelper = record
    const S_DETAIL = 'detail=';
    const S_FILEID = 'file_id';
    /// <summary>
    /// Retrieves the MIME type for the given file location or URL and extracts any detail parameter.
    /// </summary>
    /// <param name="FileLocation">The path or URL of the file, optionally containing a "detail=" parameter.</param>
    /// <param name="Detail">Output parameter that receives the detail string if present; otherwise returns an empty string.</param>
    /// <returns>The MIME type as a string, or "file_id" for unknown or remote identifiers.</returns>
    class function GetMimeType(const FileLocation: string; var Detail: string): string; overload; static;
    /// <summary>
    /// Retrieves the MIME type for the given file location or URL.
    /// </summary>
    /// <param name="FileLocation">The path or URL of the file.</param>
    /// <returns>The MIME type as a string, or "file_id" if the file does not exist locally.</returns>
    class function GetMimeType(const FileLocation: string): string; overload; static;
    /// <summary>
    /// Extracts the base file name and detail parameter from a file location string.
    /// </summary>
    /// <param name="FileLocation">The full file location, potentially including a "detail=" query segment.</param>
    /// <param name="Detail">Output parameter that receives the detail value if found; otherwise returns an empty string.
    /// </param>
    /// <returns>The base file name or URL without the detail segment.</returns>
    class function ExtractFileName(const FileLocation: string; var Detail: string): string; static;
    /// <summary>
    /// Checks if the specified MIME type represents a PDF document.
    /// </summary>
    /// <param name="MimeType">The MIME type to check.</param>
    /// <returns>True if the MIME type corresponds to a PDF; otherwise False.</returns>
    class function IsPDFDocument(const MimeType: string): Boolean; static;
    /// <summary>
    /// Checks if the specified MIME type represents an accepted image document.
    /// </summary>
    /// <param name="MimeType">The MIME type to check.</param>
    /// <returns>True if the MIME type corresponds to an image; otherwise False.</returns>
    class function IsImageDocument(const MimeType: string): Boolean; static;
  end;

implementation

{ TFormatHelper }

class function TFormatHelper.ExtractFileName(const FileLocation: string;
  var Detail: string): string;
begin
  var index := FileLocation.Trim.ToLower.IndexOf(S_DETAIL);
  if index > -1 then
    begin
      Detail := FileLocation.Trim.ToLower.Substring(index + length(S_DETAIL)).Trim;
      Result := FileLocation.Trim.ToLower.Substring(0, index - 1).Trim;
    end
  else
    begin
      Detail := EmptyStr;
      Result := FileLocation;
    end;
end;

class function TFormatHelper.GetMimeType(const FileLocation: string;
  var Detail: string): string;
begin
  var Filename := ExtractFileName(FileLocation, Detail);

  {--- Retrieve MimeType }
  if Filename.ToLower.StartsWith('http') then
    begin
      THttpx.UrlCheck(Filename);
      Result := THttpx.GetMimeType(Filename)
    end
  else
  if FileExists(FileName) then
    begin
      Result := GenAI.NetEncoding.Base64.GetMimeType(Filename);
    end
  else
    Result := S_FILEID;
end;

class function TFormatHelper.GetMimeType(const FileLocation: string): string;
var
  Detail: string;
begin
  Result := GetMimeType(FileLocation, Detail);
end;

class function TFormatHelper.IsImageDocument(const MimeType: string): Boolean;
begin
  Result := IndexStr(MimeType.Trim.ToLower, ImageTypeAccepted) <> -1;
end;

class function TFormatHelper.IsPDFDocument(const MimeType: string): Boolean;
begin
  Result := IndexStr(MimeType.Trim.ToLower, DocTypeAccepted) <> -1;
end;

end.
