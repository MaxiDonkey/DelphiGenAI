unit GenAI.Errors;

interface

type
  TErrorCore = class abstract;

  TErrorDetail = class
  private
    FCode: Int64;
    FType: string;
    FMessage: string;
    FParam: string;
  public
    property Code: Int64 read FCode write FCode;
    property &Type: string read FType write FType;
    property Message: string read FMessage write FMessage;
    property Param: string read FParam write FParam;
  end;

  TError = class(TErrorCore)
  private
    FError: TErrorDetail;
  public
    property Error: TErrorDetail read FError write FError;
    destructor Destroy; override;
  end;

implementation

{ TError }

destructor TError.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

end.
