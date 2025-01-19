unit GenAI.Types;

interface

uses
  System.SysUtils, System.TypInfo, System.Rtti, GenAI.Consts, GenAI.API.Params;

type
  TEnumValueRecovery = class
    class function TypeRetrieve<T>(const Value: string; const References: TArray<string>): T;
  end;

  {$REGION 'GenAI.Chat'}

  TRole = (
    assistant,
    user,
    developer,
    system,
    tool
  );

  TRoleHelper = record Helper for TRole
    function ToString: string;
    class function Create(const Value: string): TRole; static;
  end;

  TRoleInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TAudioFormat = (
    /// <summary>
    /// input and output
    /// </summary>
    af_wav,
    /// <summary>
    /// input and output
    /// </summary>
    af_mp3,
    /// <summary>
    /// Only output
    /// </summary>
    af_flac,
    /// <summary>
    /// Only output
    /// </summary>
    af_opus,
    /// <summary>
    /// Only output
    /// </summary>
    af_pcm16
  );

  TAudioFormatHelper = record Helper for TAudioFormat
    function ToString: string;
    class function InputMimeType(const Value: string): TAudioFormat; static;
    class function Create(const Value: string): TAudioFormat; static;
  end;

  TImageDetail = (
    id_low,
    id_high,
    id_auto
  );

  TImageDetailHelper = record Helper for TImageDetail
    function ToString: string;
    class function Create(const Value: string): TImageDetail; static;
  end;

  TReasoningEffort = (
    re_low,
    re_medium,
    re_high
  );

  TReasoningEffortHelper = record Helper for TReasoningEffort
    function ToString: string;
    class function Create(const Value: string): TReasoningEffort; static;
  end;

  TModalities = (
    m_text,
    m_audio
  );

  TModalitiesHelper = record Helper for TModalities
    function ToString: string;
    class function Create(const Value: string): TModalities; static;
  end;

  TChatVoice = (
    ash,
    ballad,
    coral,
    sage,
    verse
  );

  TChatVoiceHelper = record Helper for TChatVoice
    function ToString: string;
    class function Create(const Value: string): TChatVoice; static;
  end;

  TToolChoice = (
    tc_none,
    tc_auto,
    tc_required);

  TToolChoiceHelper = record Helper for TToolChoice
    function ToString: string;
    class function Create(const Value: string): TToolChoice; static;
  end;

  TFinishReason = (
    fr_stop,
    fr_length,
    fr_content_filter,
    fr_tool_calls
  );

  TFinishReasonHelper = record Helper for TFinishReason
    function ToString: string;
    class function Create(const Value: string): TFinishReason; static;
  end;

  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TToolCalls = (
    tc_function
  );

  TToolCallsHelper = record Helper for TToolCalls
    function ToString: string;
    class function Create(const Value: string): TToolCalls; static;
  end;

  TToolCallsInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Audio'}

  TAudioVoice = (
    vt_alloy,
    vt_ash,
    vt_coral,
    vt_echo,
    vt_fable,
    vt_onyx,
    vt_nova,
    vt_sage,
    vt_shimmer
  );

  TAudioVoiceHelper = record Helper for TAudioVoice
    function ToString: string;
    class function Create(const Value: string): TAudioVoice; static;
  end;

  TSpeechFormat = (
    sf_mp3,
    sf_opus,
    sf_aac,
    sf_flac,
    sf_wav,
    sf_pcm
  );

  TSpeechFormatHelper = record Helper for TSpeechFormat
    function ToString: string;
    class function Create(const Value: string): TSpeechFormat; static;
  end;

  TTranscriptionResponseFormat = (
    tr_json,
    tr_text,
    tr_srt,
    tr_verbose_json,
    tr_vtt
  );

  TTranscriptionResponseFormatHelper = record Helper for TTranscriptionResponseFormat
    function ToString: string;
    class function Create(const Value: string): TTranscriptionResponseFormat; static;
  end;

  {$ENDREGION}

  {$REGION 'GenAI.Embeddings'}

  TEncodingFormat = (
    float,
    base64
  );

  TEncodingFormatHelper = record Helper for TEncodingFormat
    function ToString: string;
    class function Create(const Value: string): TEncodingFormat; static;
  end;

  {$ENDREGION}

implementation

uses
  System.StrUtils;

{ TEnumValueRecovery }

class function TEnumValueRecovery.TypeRetrieve<T>(const Value: string;
  const References: TArray<string>): T;
var
  pInfo: PTypeInfo;
begin
  pInfo := TypeInfo(T);
  if pInfo.Kind <> tkEnumeration then
    raise Exception.Create('TRecovery.TypeRetrieve<T>: T is not an enumerated type');

  var index := IndexStr(Value.ToLower, References);
  if index = -1 then
    raise Exception.CreateFmt('%s : Unable to retrieve enum value.', [Value]);

  Move(index, Result, SizeOf(Result));
end;

{ TRoleHelper }

class function TRoleHelper.Create(const Value: string): TRole;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TRole>(Value,
              ['assistant', 'user', 'developer', 'system', 'tool']);
end;

function TRoleHelper.ToString: string;
begin
  case Self of
    assistant:
      Exit('assistant');
    user:
      Exit('user');
    developer:
      Exit('developer');
    system:
      Exit('system');
    tool:
      Exit('tool');
  end;
end;

{ TAudioFormatHelper }

class function TAudioFormatHelper.Create(const Value: string): TAudioFormat;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TAudioFormat>(Value,
              ['wav', 'mp3', 'flac', 'opus', 'pcm16']);
end;

class function TAudioFormatHelper.InputMimeType(
  const Value: string): TAudioFormat;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TAudioFormat>(Value, AudioTypeAccepted);
end;

function TAudioFormatHelper.ToString: string;
begin
  case Self of
    af_wav:
      Exit('wav');
    af_mp3:
      Exit('mp3');
    af_flac:
      Exit('flac');
    af_opus:
      Exit('opus');
    af_pcm16:
      Exit('pcm16');
  end;
end;

{ TImageDetailHelper }

class function TImageDetailHelper.Create(const Value: string): TImageDetail;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TImageDetail>(Value, ['low', 'high', 'auto']);
end;

function TImageDetailHelper.ToString: string;
begin
  case Self of
    id_low:
      Exit('low');
    id_high:
      Exit('high');
    id_auto:
      Exit('auto');
  end;
end;

{ TReasoningEffortHelper }

class function TReasoningEffortHelper.Create(
  const Value: string): TReasoningEffort;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TReasoningEffort>(Value, ['low', 'medium', 'high']);
end;

function TReasoningEffortHelper.ToString: string;
begin
  case Self of
    re_low:
      Exit('low');
    re_medium:
      Exit('medium');
    re_high:
      Exit('high');
  end;
end;

{ TModalitiesHelper }

class function TModalitiesHelper.Create(const Value: string): TModalities;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TModalities>(Value, ['text', 'audio']);
end;

function TModalitiesHelper.ToString: string;
begin
  case Self of
    m_text:
      Exit('text');
    m_audio:
      Exit('audio');
  end;
end;

{ TChatVoiceHelper }

class function TChatVoiceHelper.Create(const Value: string): TChatVoice;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TChatVoice>(Value,
              ['ash', 'ballad', 'coral', 'sage', 'verse']);
end;

function TChatVoiceHelper.ToString: string;
begin
  case Self of
    ash:
      Exit('ash');
    ballad:
      Exit('ballad');
    coral:
      Exit('coral');
    sage:
      Exit('sage');
    verse:
      Exit('verse');
  end;
end;

{ TToolChoiceHelper }

class function TToolChoiceHelper.Create(const Value: string): TToolChoice;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TToolChoice>(Value, ['none', 'auto', 'required']);
end;

function TToolChoiceHelper.ToString: string;
begin
  case Self of
    tc_none:
      Exit('none');
    tc_auto:
      Exit('auto');
    tc_required:
      Exit('required');
  end;
end;

{ TFinishReasonHelper }

class function TFinishReasonHelper.Create(const Value: string): TFinishReason;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TFinishReason>(Value,
              ['stop', 'length', 'content_filter', 'tool_calls']);
end;

function TFinishReasonHelper.ToString: string;
begin
  case Self of
    fr_stop:
      Exit('stop');
    fr_length:
      Exit('length');
    fr_content_filter:
      Exit('content_filter');
    fr_tool_calls:
      Exit('tool_calls');
  end;
end;

{ TFinishReasonInterceptor }

function TFinishReasonInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFinishReason>.ToString;
end;

procedure TFinishReasonInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFinishReason.Create(Arg)));
end;

{ TRoleInterceptor }

function TRoleInterceptor.StringConverter(Data: TObject; Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TRole>.ToString;
end;

procedure TRoleInterceptor.StringReverter(Data: TObject; Field, Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TRole.Create(Arg)));
end;

{ TToolCallsHelper }

class function TToolCallsHelper.Create(const Value: string): TToolCalls;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TToolCalls>(Value, ['function']);
end;

function TToolCallsHelper.ToString: string;
begin
  case Self of
    tc_function:
      Exit('function');
  end;
end;

{ TToolCallsInterceptor }

function TToolCallsInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TToolCalls>.ToString;
end;

procedure TToolCallsInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TToolCalls.Create(Arg)));
end;

{ TAudioVoiceHelper }

class function TAudioVoiceHelper.Create(const Value: string): TAudioVoice;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TAudioVoice>(Value,
    ['alloy', 'ash', 'coral', 'echo', 'fable', 'onyx', 'nova', 'sage', 'shimmer']);
end;

function TAudioVoiceHelper.ToString: string;
begin
  case self of
    vt_alloy:
      Exit('alloy');
    vt_ash:
      Exit('ash');
    vt_coral:
      Exit('coral');
    vt_echo:
      Exit('echo');
    vt_fable:
      Exit('fable');
    vt_onyx:
      Exit('onyx');
    vt_nova:
      Exit('nova');
    vt_sage:
      Exit('sage');
    vt_shimmer:
      Exit('shimmer');
  end;
end;

{ TSpeechFormatHelper }

class function TSpeechFormatHelper.Create(const Value: string): TSpeechFormat;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TSpeechFormat>(Value,
              ['mp3', 'opus', 'aac', 'flac', 'wav', 'pcm']);
end;

function TSpeechFormatHelper.ToString: string;
begin
  case self of
    sf_mp3:
      Exit('mp3');
    sf_opus:
      Exit('opus');
    sf_aac:
      Exit('aac');
    sf_flac:
      Exit('flac');
    sf_wav:
      Exit('wav');
    sf_pcm:
      Exit('pcm');
  end;
end;

{ TTranscriptionResponseFormatHelper }

class function TTranscriptionResponseFormatHelper.Create(
  const Value: string): TTranscriptionResponseFormat;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TTranscriptionResponseFormat>(Value,
              ['json', 'text', 'srt', 'verbose_json', 'vtt']);
end;

function TTranscriptionResponseFormatHelper.ToString: string;
begin
  case Self of
    tr_json:
      Exit('json');
    tr_text:
      Exit('text');
    tr_srt:
      Exit('srt');
    tr_verbose_json:
      Exit('verbose_json');
    tr_vtt:
      Exit('vtt');
  end;
end;

{ TEncodingFormatHelper }

class function TEncodingFormatHelper.Create(
  const Value: string): TEncodingFormat;
begin
  Result := TEnumValueRecovery.TypeRetrieve<TEncodingFormat>(Value, ['float', 'base64']);
end;

function TEncodingFormatHelper.ToString: string;
begin
  case Self of
    float:
      Exit('float');
    base64:
      Exit('base64');
  end;
end;

end.
