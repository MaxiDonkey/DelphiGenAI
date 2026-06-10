unit WVPythia.Strs;

interface

uses
  System.SysUtils, WVPythia.JSON.SafeReader;

const
  MD_LINEBREAK = sLineBreak + '<br>' + sLineBreak + '<br>' + sLineBreak;

type
  TStringTranslation = record
    class procedure FromLanguageContent(const Value: string;
      const CustomProc: TProc); static;
  end;

var
  {--- Developper only: no translation }

  S_DESERIALIZATON_ERROR: string =
    'An error occurred while deserializing the JSON source';

  S_INVALID_PAYLOAD_EXPECTED_VALID_JSON: string =
    'Invalid handler payload: expected valid JSON';

  S_DIALOG_SERVICE_NOT_ASSIGNETD: string =
    'DialogService not assigned';
  S_WEB_DECISION_DLG_ALREADY_PENDING_FMT: string =
    'A WebDecisionDlg request is already pending: %s';


  {--- Shared with user }

  S_DELETE_QA: string =
    'Please confirm the deletion of the current question and answer, along with all subsequent entries.';
  S_DELETE_CHAT_SESSION: string =
    'Are you sure? #10 This action is irreversible and will delete all messages in this chat.';
  S_ABORTED_OPERATION: string =
    'Operation cancelled';
  S_ABORTED: string =
    MD_LINEBREAK + 'Operation aborted...';
  S_MODEL_FILE_NOT_FOUND_FMT: string =
    '%s : file created. #10Please open this file and instruct the list of available models.';

  S_WELCOME: string =
    'Welcome to your workspace';

  S_BATCH_BEGIN_ERROR: string =
    'Batch display rendering activation failed.';
  S_BATCH_END_ERROR: string =
    'Batch rendering release failed';
  S_FOCUS_ERROR: string =
    'The input bubble could not receive focus';
  S_STOP_AUDIO_MEDIA_ERROR: string =
    'Audio media shutdown failed';
  S_STOP_VIDEO_MEDIA_ERROR: string =
    'Video media shutdown failed';
  S_AUDIO_RECORDING_START_ERROR: string =
    'Audio recording could not be started';
  S_AUDIO_RECORDING_STOP_ERROR: string =
    'Audio recording could not be stopped';
  S_AUDIO_RECORDING_SWITCH_ERROR: string =
    'Audio recording could not be toggled';
  S_INTERNAL_THEME_ERROR: string =
    'Unable to update the page theme';
  S_DESERIALIZATION_ERROR_FMT: string =
    'Deserialization error: invalid JSON input %s';
  S_STRUCTURED_OUTPUT_ERROR: string =
    '''Structured Output'' invalid: Please change its value in the settings.';
  S_CARD_JSON_FILE_NOT_FOUND: string =
    'No JSON file supports %s';

  S_MODELS_CATEGORIES_COUNT_ERROR: string =
    'Please define categories for default models';
  S_INVALID_CATEGORIES_FILE_ERROR: string =
    'Invalid JSON file for Categories';
  S_TEXT_GENERATION_CANT_HANDLED_ERROR: string =
    'No default model: text generation cannot be processed';
  S_IMAGE_CREATION_ABORTED_ERROR: string =
    'No default model configured: Image creation aborted';
  S_VIDEO_CREATION_ABORTED_ERROR: string =
    'No default model configured: Video creation aborted';
  S_AUDIO_CREATION_ABORTED_ERROR: string =
    'No default model configured: Audio creation aborted';
  S_STT_OPERATION_ABORTED_ERROR: string =
    'No default model configured: STT operation aborted';
  S_TTS_OPERATION_ABORTED_ERROR: string =
    'No default model configured: TTS operation aborted';
  S_DEEP_RESEARCH_OPERATION_ABORTED_ERROR: string =
    'No default model configured: Deep Reasearch operation aborted';
  S_MISSING_DEFAULT_MODELS_ERROR: string =
    'Missing default models for some categories. Check Model Settings';

  S_API_KEY_EMPTY_NAME_ERROR: string =
    'The key name cannot be empty.';
  S_API_KEY_ENTER_DIALOG_PROMPT: string =
    'Please enter the API key value for %s';
  S_API_KEY_NOT_FOUND: string =
    '%s: Api Key not found';
  S_API_KEY_DELETED: string =
    '%s: Api Key has been deleted';
  S_API_KEY_EXISTS: string =
    '%s: Api Key exists';
  S_API_KEY_MODIFIED: string =
    '%s: Api Key has been modified.';
  S_API_KEY_INSERTED: string =
    '%s: Api Key has been inserted.';

  S_COMMAND_PLUGIN_NOT_BE_NULL: string =
    'Plugin cannot be nil';
  S_COMMAND_UNKNOWN: string =
    'Unknown command : /%s';
  S_COMMAND_ACTION_UNKNOWN: string =
    'Action unknown : /%s %s';
  S_COMMAND_MISSING_ACTION: string =
    'Missing action for /%s';
  S_COMMAND_INCORRECT_NUMBER_OF_ARGUMENTS: string =
    'Incorrect number of arguments for /%s %s (received %d)';
  S_COMMAND_NO_PLUGIN_FOR: string =
    'No plugin for /%s';
  S_TOOL_GROUP_LABEL: string =
    'Tools used';
  S_WEB_DECISION_DLG_TITLE: string =
    'Confirmation';
  S_WEB_DECISION_DLG_MESSAGE: string =
    'Please confirm.';
  S_WEB_DECISION_DLG_OK: string =
    'OK';
  S_WEB_DECISION_DLG_CANCEL: string =
    'Cancel';
  S_WEB_DECISION_DLG_CLOSE: string =
    'Close';

implementation

{ TStringTranslation }

class procedure TStringTranslation.FromLanguageContent(const Value: string;
  const CustomProc: TProc);
begin
  var JSONObject := TJsonReader.Parse(Value);
  S_DELETE_QA := JSONObject.AsString(
    'more.delete_qa',
    S_DELETE_QA);

  S_DELETE_CHAT_SESSION := JSONObject.AsString(
    'more.delete_chat_session',
    S_DELETE_CHAT_SESSION);

  S_ABORTED_OPERATION := JSONObject.AsString(
    'more.aborted_operation',
    S_ABORTED_OPERATION);

  S_ABORTED := MD_LINEBREAK + JSONObject.AsString(
    'more.aborted',
    MD_LINEBREAK + S_ABORTED);

  S_MODEL_FILE_NOT_FOUND_FMT := JSONObject.AsString(
    'more.model_file_not_found',
    S_MODEL_FILE_NOT_FOUND_FMT);

  S_WELCOME := JSONObject.AsString(
    'more.welcome',
    S_WELCOME);

  S_BATCH_BEGIN_ERROR := JSONObject.AsString(
    'more.batch_begin_error',
    S_BATCH_BEGIN_ERROR);

  S_BATCH_END_ERROR := JSONObject.AsString(
    'more.batch_end_error',
    S_BATCH_END_ERROR);

  S_FOCUS_ERROR := JSONObject.AsString(
    'more.focus_error',
    S_FOCUS_ERROR);

  S_STOP_AUDIO_MEDIA_ERROR := JSONObject.AsString(
    'more.stop_audio_media_error',
    S_STOP_AUDIO_MEDIA_ERROR);

  S_STOP_VIDEO_MEDIA_ERROR := JSONObject.AsString(
    'more.stop_video_media_error',
    S_STOP_VIDEO_MEDIA_ERROR);

  S_AUDIO_RECORDING_START_ERROR := JSONObject.AsString(
    'more.audio_recording_start_error',
    S_AUDIO_RECORDING_START_ERROR);

  S_AUDIO_RECORDING_STOP_ERROR := JSONObject.AsString(
    'more.audio_recording_stop_error',
    S_AUDIO_RECORDING_STOP_ERROR);

  S_AUDIO_RECORDING_SWITCH_ERROR := JSONObject.AsString(
    'more.audio_recording_switch_error',
    S_AUDIO_RECORDING_SWITCH_ERROR);

  S_INTERNAL_THEME_ERROR := JSONObject.AsString(
    'more.internal_theme_error',
    S_INTERNAL_THEME_ERROR);

  S_DESERIALIZATION_ERROR_FMT := JSONObject.AsString(
    'more.deserialization_error',
    S_DESERIALIZATION_ERROR_FMT);

  S_STRUCTURED_OUTPUT_ERROR := JSONObject.AsString(
    'more.structured_output_error',
    S_STRUCTURED_OUTPUT_ERROR);

  S_CARD_JSON_FILE_NOT_FOUND :=
    JSONObject.AsString(
    'more.card_json_file_not_found',
    S_CARD_JSON_FILE_NOT_FOUND);

  S_MODELS_CATEGORIES_COUNT_ERROR :=
    JSONObject.AsString(
    'more.models_categories_count_error',
    S_MODELS_CATEGORIES_COUNT_ERROR);

  S_INVALID_CATEGORIES_FILE_ERROR :=
    JSONObject.AsString(
    'more.invalid_categories_file_error',
    S_INVALID_CATEGORIES_FILE_ERROR);

  S_TEXT_GENERATION_CANT_HANDLED_ERROR :=
    JSONObject.AsString(
    'more.text_generation_cant_handled_error',
    S_TEXT_GENERATION_CANT_HANDLED_ERROR);

  S_IMAGE_CREATION_ABORTED_ERROR :=
    JSONObject.AsString(
    'more.image_creation_aborted_error',
    S_IMAGE_CREATION_ABORTED_ERROR);

  S_VIDEO_CREATION_ABORTED_ERROR :=
    JSONObject.AsString(
    'more.video_creation_aborted_error',
    S_VIDEO_CREATION_ABORTED_ERROR);

  S_AUDIO_CREATION_ABORTED_ERROR :=
    JSONObject.AsString(
    'more.audio_creation_aborted_error',
    S_AUDIO_CREATION_ABORTED_ERROR);

  S_STT_OPERATION_ABORTED_ERROR :=
    JSONObject.AsString(
    'more.stt_operation_aborted_error',
    S_STT_OPERATION_ABORTED_ERROR);

  S_TTS_OPERATION_ABORTED_ERROR :=
    JSONObject.AsString(
    'more.tts_operation_aborted_error',
    S_TTS_OPERATION_ABORTED_ERROR);

  S_DEEP_RESEARCH_OPERATION_ABORTED_ERROR :=
    JSONObject.AsString(
    'more.deep_research_operation_aborted_error',
    S_DEEP_RESEARCH_OPERATION_ABORTED_ERROR);

  S_MISSING_DEFAULT_MODELS_ERROR :=
    JSONObject.AsString(
    'more.missing_default_models_error',
    S_MISSING_DEFAULT_MODELS_ERROR);

  S_API_KEY_EMPTY_NAME_ERROR :=
    JSONObject.AsString(
    'more.api_key_empty_name_error',
    S_API_KEY_EMPTY_NAME_ERROR);

  S_API_KEY_ENTER_DIALOG_PROMPT :=
    JSONObject.AsString(
    'more.api_key_enter_dialog_prompt',
    S_API_KEY_ENTER_DIALOG_PROMPT);

  S_API_KEY_NOT_FOUND :=
    JSONObject.AsString(
    'more.api_key_not_found',
    S_API_KEY_NOT_FOUND);

  S_API_KEY_DELETED :=
    JSONObject.AsString(
    'more.api_key_deleted',
    S_API_KEY_DELETED);

  S_API_KEY_EXISTS :=
    JSONObject.AsString(
    'more.api_key_exists',
    S_API_KEY_EXISTS);

  S_API_KEY_MODIFIED :=
    JSONObject.AsString(
    'more.api_key_modified',
    S_API_KEY_MODIFIED);

  S_API_KEY_INSERTED :=
    JSONObject.AsString(
    'more.api_key_inserted',
    S_API_KEY_INSERTED);

  S_COMMAND_PLUGIN_NOT_BE_NULL :=
    JSONObject.AsString(
    'more.command_plugin_not_be_null',
    S_COMMAND_PLUGIN_NOT_BE_NULL);

  S_COMMAND_UNKNOWN :=
    JSONObject.AsString(
    'more.command_unknown',
    S_COMMAND_UNKNOWN);

  S_COMMAND_ACTION_UNKNOWN :=
    JSONObject.AsString(
    'more.command_action_unknown',
    S_COMMAND_ACTION_UNKNOWN);

  S_COMMAND_MISSING_ACTION :=
    JSONObject.AsString(
    'more.command_missing_action',
    S_COMMAND_MISSING_ACTION);

  S_COMMAND_INCORRECT_NUMBER_OF_ARGUMENTS :=
    JSONObject.AsString(
    'more.command_incorrect_number_of_arguments',
    S_COMMAND_INCORRECT_NUMBER_OF_ARGUMENTS);

  S_COMMAND_NO_PLUGIN_FOR :=
    JSONObject.AsString(
    'more.command_no_plugin_for',
    S_COMMAND_NO_PLUGIN_FOR);

  S_TOOL_GROUP_LABEL :=
    JSONObject.AsString(
    'display.toolGroup.label',
    S_TOOL_GROUP_LABEL);

  S_WEB_DECISION_DLG_TITLE :=
    JSONObject.AsString(
    'more.web_decision_dlg_title',
    S_WEB_DECISION_DLG_TITLE);

  S_WEB_DECISION_DLG_MESSAGE :=
    JSONObject.AsString(
    'more.web_decision_dlg_message',
    S_WEB_DECISION_DLG_MESSAGE);

  S_WEB_DECISION_DLG_OK :=
    JSONObject.AsString(
    'more.web_decision_dlg_ok',
    S_WEB_DECISION_DLG_OK);

  S_WEB_DECISION_DLG_CANCEL :=
    JSONObject.AsString(
    'more.web_decision_dlg_cancel',
    S_WEB_DECISION_DLG_CANCEL);

  S_WEB_DECISION_DLG_CLOSE :=
    JSONObject.AsString(
    'more.web_decision_dlg_close',
    S_WEB_DECISION_DLG_CLOSE);

  {--- Add custom translation }
  if Assigned(CustomProc) then
    CustomProc();
end;

end.

