unit GenAI.Functions.Example;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGenAI
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, GenAI.Functions.Core, GenAI.Schema, GenAI.Types;
type
  TWeatherReportFunction = class(TFunctionCore)
  protected
    function GetDescription: string; override;
    function GetName: string; override;
    function GetParameters: string; override;
  public
    function Execute(const Arguments: string): string; override;
    class function CreateInstance(const IsStrict: Boolean = False): IFunctionCore;
  end;

implementation

uses
  System.StrUtils, System.JSON;

{ TWeatherReportFunction }

class function TWeatherReportFunction.CreateInstance(const IsStrict: Boolean): IFunctionCore;
begin
  Result := TWeatherReportFunction.create(IsStrict);
end;

function TWeatherReportFunction.Execute(const Arguments: string): string;

  procedure AddToReport(const Value: TJSONObject;
    Temperature: Integer; Forecast: TArray<string>);
  begin
    Value.AddPair('temperature', TJSONNumber.Create(Temperature));
    Value.AddPair('forecast', TJSONArray.Create(Forecast[0], Forecast[1]));
  end;

begin
  Result := EmptyStr;
  var Location := EmptyStr;
  var UnitType := EmptyStr;

  {--- Parse arguments to retrieve parameters }
  var JSON := TJSONObject.ParseJSONValue(Arguments) as TJSONObject;
  try
    if Assigned(JSON) then
    try
      Location := JSON.GetValue('location', '');
      UnitType := JSON.GetValue('unit', '');
    finally
      JSON.Free;
    end;
  except
    Location := EmptyStr;
  end;

  {--- Stop the treatment if location is empty }
  if Location.IsEmpty then
    Exit;

  {--- Build the response }
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('location', Location);
    JSON.AddPair('unit', UnitType);
    if Location.ToLower.IndexOf('paris') > -1 then
      AddToReport(JSON, 14, ['rainy', 'low visibility'])
    else
    if Location.ToLower.IndexOf('marseille') > -1 then
      AddToReport(JSON, 29, ['sunny', 'windy']);
    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end; {Execute}

function TWeatherReportFunction.GetDescription: string;
begin
  Result := 'Get the current weather in a given location.';
end;

function TWeatherReportFunction.GetName: string;
begin
  Result := 'get_weather';
end;

function TWeatherReportFunction.GetParameters: string;
begin
// for Delphi 10.3 et 11
//  Result :=
//    '{'+
//    '"type": "object",'+
//    '"properties": {'+
//         '"location": {'+
//             '"type": "string",'+
//             '"description": "The city and department, e.g. Marseille, 13"'+
//         '},'+
//         '"unit": {'+
//             '"type": "string",'+
//             '"enum": ["celsius", "fahrenheit"]'+
//         '}'+
//     '},'+
//     '"required": ["location"],'+
//     '"additionalProperties": false'+
//  '}';


// for Delphi 12 with triple quotes
//  Result :=
//    '''
//      {
//        "type": "object",
//        "properties": {
//             "location": {
//                 "type": "string",
//                 "description": "The city and department, e.g. Marseille, 13"
//             },
//             "unit": {
//                 "type": "string",
//                 "enum": ["celsius", "fahrenheit"]
//             }
//         },
//         "required": ["location"],
//         "additionalProperties": false
//      }
//    ''';


  {--- If we use the TSchemaParams class defined in the MistralAI.Schema.pas unit }
//  var Schema := TSchemaParams.New(
//    procedure (var Params: TSchemaParams)
//    begin
//      Params.&Type(TSchemaType.object);
//      Params.Properties('properties',
//        procedure (var Params: TSchemaParams)
//        begin
//          Params.Properties('location',
//            procedure (var Params: TSchemaParams)
//            begin
//              Params.&Type(TSchemaType.string);
//              Params.Description('The city and state, e.g. San Francisco, CA');
//            end);
//          Params.Properties('unit',
//            procedure (var Params: TSchemaParams)
//            begin
//              Params.&Type(TSchemaType.string);
//              Params.Enum(['celsius', 'fahrenheit']);
//            end);
//        end);
//      Params.Required(['location', 'unit']);
//      Params.Add('additionalProperties', false);
//    end);
//  Result := Schema.ToJsonString(True);

  var Schema := TSchemaParams.Create
        .&Type(TSchemaType.object)
        .Properties('properties',
          TSchemaParams.Create
            .Properties('location',
               TSchemaParams.Create
                 .&Type(TSchemaType.string)
                 .Description('The city and state, e.g. San Francisco, CA')
               )
            .Properties('unit',
               TSchemaParams.Create
                 .&Type(TSchemaType.string)
                 .Enum(['celsius', 'fahrenheit'])
               )
            )
        .Required(['location', 'unit'])
        .Add('additionalProperties', false);
  Result := Schema.ToJsonString(True);
end;

end.
