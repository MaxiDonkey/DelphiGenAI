unit GenAI.API.Tests;

(*
  To execute unit tests proceed as follows :

  Declare
  -------
      uses
        DUnitX.TestFramework,
        DUnitX.Loggers.Console,
        DUnitX.TestRunner,
        GenAI.API.Tests, ... ;

  Process
  -------
      procedure TForm1.Button1Click(Sender: TObject);
      var
        Runner: ITestRunner;
        Results: IRunResults;
      begin
        TDUnitX.RegisterTestFixture(TGenAIAPITests);
        Runner := TDUnitX.CreateRunner;
        Results := Runner.Execute;
        if Results.AllPassed then
          Memo1.Lines.Add('All tests passed.')
        else
          Memo1.Lines.Add('Some tests failed.');
      end;

*)

interface

{$M+}

uses
  DUnitX.TestFramework, System.SysUtils, System.Classes, REST.JsonReflect,
  GenAI.API, GenAI.API.Params, GenAI.Types, GenAI.Exceptions;

type
  [TestFixture]
  TGenAIAPITests = class
  public
    [Test] procedure Test_TUrlParam_AddParameters;
    [Test] procedure Test_TGenAIConfiguration_BuildHeaders;
    [Test] procedure Test_TApiDeserializer_Deserialize;
    [Test] procedure Test_TApiDeserializer_Deserialize_MetadataAsstring;
    [Test] procedure Test_TApiDeserializer_RaiseErrors;
    [Test] procedure Test_TJSONParam_Serialization;
    [Test] procedure Test_TApiDeserializer_EmptyResponse;
    [Test] procedure Test_TUrlPaginationParams;
    [Test] procedure Test_TGenAIAPI_GetFileWithError;
  end;

  TTestModel = class(TObject)
  private
    FId: string;
    FName: string;
    FKind: string;
  public
    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Kind: string read FKind write FKind;
  end;

  TTestMetadata = class(TObject)
  private
    FId: string;
    FName: string;
    [JsonReflectAttribute(ctString, rtString, TMetadataInterceptor)]
    FMetadata: string;
  public
    property Id: string read FId write FId;
    property Name: string read FName write FName;
    property Metadata: string read FMetadata write FMetadata;
  end;

implementation

uses
  System.Net.URLClient;

type
  TTestGenAIConfiguration = class(TGenAIConfiguration);

  TTestTApiDeserializer = class(TApiDeserializer);

{ TGenAIAPITests }

procedure TGenAIAPITests.Test_TApiDeserializer_Deserialize;
{--- This ensures that data received from the API is correctly transformed into
     usable Delphi objects. }
begin
  var DeserializedObj: TTestModel := nil;
  var Deserializer := TTestTApiDeserializer.Create;
  var JsonInput := '{"name":"test_model","id":"123","kind":"object"}';
  try
    DeserializedObj := Deserializer.Deserialize<TTestModel>(200, JsonInput);
    Assert.IsNotNull(DeserializedObj, 'The deserialized object is null.');
    Assert.AreEqual('test_model', DeserializedObj.Name, 'The Name field is incorrect.');
    Assert.AreEqual('123', DeserializedObj.Id, 'The Id field is incorrect.');
    Assert.AreEqual('object', DeserializedObj.kind, 'The Kind field is incorrect.');
  finally
    DeserializedObj.Free;
    Deserializer.Free;
  end;
end;

procedure TGenAIAPITests.Test_TApiDeserializer_Deserialize_MetadataAsstring;
{--- This guarantees that the data retrieved from the API is properly transformed into objects,
     ensuring that metadata is correctly deserialized as strings and not in object form. }
begin
  var DeserializedObj: TTestMetadata := nil;
  var Deserializer := TTestTApiDeserializer.Create;
  var JsonInput := '{"name":"test_model","id":"123","metadata":{"key":"value"}}';
  try
    DeserializedObj := Deserializer.Deserialize<TTestMetadata>(200, JsonInput);
    Assert.IsNotNull(DeserializedObj, 'The deserialized object is null.');
    Assert.AreEqual('test_model', DeserializedObj.Name, 'The Name field is incorrect.');
    Assert.AreEqual('123', DeserializedObj.Id, 'The Id field is incorrect.');
    Assert.AreEqual('{"key":"value"}', DeserializedObj.Metadata, 'The Kind field is incorrect.');
  finally
    DeserializedObj.Free;
    Deserializer.Free;
  end;
end;

procedure TGenAIAPITests.Test_TApiDeserializer_EmptyResponse;
{--- Checking for an empty or non-JSON response throws the TGenAIInvalidResponseError exception. }
begin
  var Deserializer := TTestTApiDeserializer.Create;
  try
    Assert.WillRaise(
      procedure begin
        Deserializer.Deserialize<TTestModel>(200, '');
      end,
      TGenAIInvalidResponseError,
      'No exception thrown for empty response.'
    );
  finally
    Deserializer.Free;
  end;
end;

procedure TGenAIAPITests.Test_TApiDeserializer_RaiseErrors;
{--- This ensures that every type of API error is handled correctly by the exception system. }
begin
  var Deserializer := TTestTApiDeserializer.Create;

  try
    Assert.WillRaise(
      procedure begin
        Deserializer.DeserializeErrorData(401, '{"error": {"message": "Invalid API key", "code": 401}}');
      end,
      TGenAIAuthError,
      'TGenAIAuthError exception was not thrown for error 401.'
    );

    Assert.WillRaise(
      procedure begin
        Deserializer.DeserializeErrorData(403, '{"error": {"message": "Invalid API key", "code": 403}}');
      end,
      TGenAICountryNotSupportedError,
      'TGenAICountryNotSupportedError exception was not thrown for error 403.'
    );

    Assert.WillRaise(
      procedure begin
        Deserializer.DeserializeErrorData(429, '{"error": {"message": "Invalid API key", "code": 429}}');
      end,
      TGenAIRateLimitError,
      'TGenAIRateLimitError exception was not thrown for error 429.'
    );

    Assert.WillRaise(
      procedure begin
        Deserializer.DeserializeErrorData(500, '{"error": {"message": "Invalid API key", "code": 500}}');
      end,
      TGenAIServerError,
      'TGenAIServerError exception was not thrown for error 500.'
    );

    Assert.WillRaise(
      procedure begin
        Deserializer.DeserializeErrorData(503, '{"error": {"message": "Invalid API key", "code": 503}}');
      end,
      TGenAIEngineOverloadedError,
      'TGenAIEngineOverloadedError exception was not thrown for error 503.'
    );
  finally
    Deserializer.Free;
  end;
end;

procedure TGenAIAPITests.Test_TGenAIAPI_GetFileWithError;
{--- Ensure that an appropriate exception is thrown when a file download fails. }
begin
  var API := TGenAIAPI.Create('dummy_api_key');
  var Stream := TMemoryStream.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        API.GetFile('invalid/endpoint', Stream);
      end,
      TGenAIAPIException,
      'No exception thrown when downloading an invalid file.'
    );
  finally
    Stream.Free;
    API.Free;
  end;
end;

procedure TGenAIAPITests.Test_TGenAIConfiguration_BuildHeaders;
{--- This ensures that every request sent to the API is properly authenticated. }
begin
  var Config := TTestGenAIConfiguration.Create;
  try
    Config.APIKey := 'my_api_key';
    Config.Organization := 'my_organization';

    var Headers := Config.BuildHeaders;

    Assert.AreEqual('Bearer my_api_key', Headers[0].Value, 'The Authorization header is incorrect.');
    Assert.AreEqual('my_organization', Headers[1].Value, 'The OpenAI-Organization header is incorrect.');
  finally
    Config.Free;
  end;
end;

procedure TGenAIAPITests.Test_TJSONParam_Serialization;
{--- Verify that HTTP POST/GET requests correctly serialize JSON parameters. }
begin
  var JSONParam := TJSONParam.Create;
  try
    JSONParam.Add('param1', 'value1');
    JSONParam.Add('param2', 42);
    JSONParam.Add('param3', True);
    var JsonString := JSONParam.ToJsonString;
    Assert.IsTrue(JsonString.Contains('"param1":"value1"'), 'Parameter param1 missing or incorrect.');
    Assert.IsTrue(JsonString.Contains('"param2":42'), 'Incorrect parameter param2.');
    Assert.IsTrue(JsonString.Contains('"param3":true'), 'Incorrect parameter param3.');
  finally
    JSONParam.Free;
  end;
end;

procedure TGenAIAPITests.Test_TUrlPaginationParams;
{--- Verify that the TUrlPaginationParams class correctly handles pagination parameters. }
begin
  var PaginationParams := TUrlPaginationParams.Create;
  try
    PaginationParams.Limit(50).After('item_12345');
    Assert.AreEqual('?limit=50&after=item_12345', PaginationParams.Value,
      'The pagination settings are not correct.');
  finally
    PaginationParams.Free;
  end;
end;

procedure TGenAIAPITests.Test_TUrlParam_AddParameters;
{--- This ensures that all API requests use properly formatted URLs, avoiding HTTP
     errors due to mis-encoded parameters.}
begin
  var UrlParams := TUrlParam.Create;
  try
    UrlParams.Add('key1', 'value1');
    UrlParams.Add('key2', 'value 2');
    var ResultingUrl := UrlParams.Value;
    Assert.AreEqual('?key1=value1&key2=value%202', ResultingUrl,
      'URL parameters are not encoded correctly.');
  finally
    UrlParams.Free;
  end;

  {--- Verify that URL parameters containing special characters are correctly encoded. }
  UrlParams := TUrlParam.Create;
  try
    UrlParams.Add('param1', 'value with spaces');
    UrlParams.Add('param2', 'value&with=special%chars');
    var ResultingUrl := UrlParams.Value;
    Assert.AreEqual('?param1=value%20with%20spaces&param2=value%26with%3Dspecial%25chars', ResultingUrl,
      'URL parameters are not encoded correctly.');
  finally
    UrlParams.Free;
  end;
end;

end.
