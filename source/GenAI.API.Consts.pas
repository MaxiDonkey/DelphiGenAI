unit GenAI.API.Consts;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

const
  /// <summary>
  /// JSON field names whose object or array values must be shielded before the
  /// REST deserializer sees them.
  /// </summary>
  /// <remarks>
  /// These free-form fields commonly carry metadata, schemas, headers or other
  /// polymorphic payloads. Shielding preserves the nested JSON shape through
  /// string-based REST interceptors, then <c>TJsonPolyUnshield</c> restores it.
  /// </remarks>
  PROTECTED_FIELD: TArray<string> = [
    'metadata',
    'response_format',
    'attributes',
    'schema',
    'env',
    'headers',
    'input_schema',
    'variables'
  ];

implementation

end.
