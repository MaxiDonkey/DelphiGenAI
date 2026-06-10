unit WVPythia.Template.Manager;

interface

{$REGION  'Dev notes : Manager.TemplateProvider'}

(*
  DESIGN NOTE:
  ============

  This component dynamically manages template loading.
  - The "AlwaysReloading" mode (see TemplateAllwaysReloading) is ideal during development:
    it reloads template files on every access, making quick iterations easy without restarting the app.
  - The "NeverReloading" mode (see TemplateNeverReloading) is intended for a more typical/stable use,
    where files are loaded just once for performance.

  No advanced caching logic here�this is intentional:
  goal = clarity & simplicity for the community.

*)

{$ENDREGION}

uses
  System.SysUtils, System.IOUtils, WVPythia.TextFile.Helper;

const
  TEMPLATE_PATH = '..\assets';

type
  TTemplateType = (
    main_html,
    js_response,
    js_prompt,
    js_waitfor,
    js_inputbubble,
    js_scrollButtons,
    js_images,
    js_promptFile,
    js_audio,
    js_audioRecording,
    js_video,
    js_displayfile,
    js_selector,
    js_confirmationDialog,
    js_filesMenager,
    js_errors,
    js_requestParams,
    js_bootstrapDictionary,
    js_models,
    js_chatFooter,
    js_cardSelector,
    js_promptSummary,
    js_inputDialog,
    js_activityLogo,
    js_webDecision,
    js_injectionEnded);

  TTemplateTypeHelper = record Helper for TTemplateType
  private
    const
      FileNames: array[TTemplateType] of string = (
        'index.htm',
        'scripts\DisplayTemplate.js',
        'scripts\PromptTemplate.js',
        'scripts\ReasoningTemplate.js',
        'scripts\InputBubbleTemplate.js',
        'scripts\ScrollButtonsTemplate.js',
        'scripts\DisplayImageTemplate.js',
        'scripts\PromptFileTemplate.js',
        'scripts\DisplayAudioTemplate.js',
        'scripts\AudioRecordingTemplate.js',
        'scripts\DisplayVideoTemplate.js',
        'scripts\DisplayFileTemplate.js',
        'scripts\SelectorTemplate.js',
        'scripts\ConfirmationDialogTemplate.js',
        'scripts\FilesDrawerTemplate.js',
        'scripts\ErrorsTemplate.js',
        'scripts\RequestParamsTemplate.js',
        'scripts\BootstrapDictionaryTemplate.js',
        'scripts\ModelsTemplate.js',
        'scripts\ChatFooterTemplate.js',
        'scripts\CardSelectorTemplate.js',
        'scripts\PromptSummaryTemplate.js',
        'scripts\InputDialogTemplate.js',
        'scripts\ActivityLogoTemplate.js',
        'scripts\WebDecisionDlgTemplate.js',
        'scripts\InjectionEndedTemplate.js'
      );
  public
    function ToString: string;
  end;

  ITemplateProvider = interface
    ['{3DE4085F-1AE3-4C4D-93D3-BA7130FF5C96}']
    function GetInitialHtml: string;
    function GetDisplayTemplate: string;
    function GetReasoningTemplate: string;
    function GetPromptTemplate: string;
    function GetInputBubble: string;
    function GetScrollButtonsTemplate: string;
    function GetImagesTemplate: string;
    function GetPromptFileTemplate: string;
    function GetAudioTemplate: string;
    function GetAudioRecordingTemplate: string;
    function GetVideoTemplate: string;
    function GetDisplayfileTemplate: string;
    function GetSelectorTemplate: string;
    function GetConfirmationDialogTemplate: string;
    function GetFilesDrawerTemplate: string;
    function GetErrorsTemplate: string;
    function GetRequestParamsTemplate: string;
    function GetBootstrapDictionaryTemplate: string;
    function GetModelsTemplate: string;
    function GetChatFooterTemplate: string;
    function GetCardSelectorTemplate: string;
    function GetPromptSummaryTemplate: string;
    function GetInputDialogTemplate: string;
    function GetActivityLogoTemplate: string;
    function GetWebDecisionTemplate: string;
    function GetInjectionEndedTemplate: string;

    function LoadCustomTemplate(const FileName: string): string;

    /// <summary>
    /// Enables automatic reloading of template files from the specified directory on each access.
    /// This is recommended for development or rapid prototyping, as it reflects any changes to the template files immediately.
    /// </summary>
    /// <param name="APath">
    /// Optional path to the directory containing template files. If empty, uses the default template path.
    /// </param>
    procedure TemplateAllwaysReloading(const APath: string = '');

    /// <summary>
    /// Disables automatic reloading, causing all template files to be loaded only once and cached in memory.
    /// This improves performance and stability for production use, but changes to template files require an application restart.
    /// </summary>
    procedure TemplateNeverReloading;

    /// <summary>
    /// Sets the directory path where template files are located.
    /// </summary>
    /// <param name="Value">
    /// The file system path to use for loading template files.
    /// </param>
    procedure SetTemplatePath(const Value: string);

    /// <summary>
    /// Gets the HTML template used for initial page rendering.
    /// </summary>
    /// <returns>
    /// The content of the initial HTML template.
    /// </returns>
    property InitialHtml: string read GetInitialHtml;

    property DisplayTemplate: string read GetDisplayTemplate;
    property ReasoningTemplate: string read GetReasoningTemplate;
    property PromptTemplate: string read GetPromptTemplate;
    property InputBubbleTemplate: string read GetInputBubble;
    property ScrollButtonsTemplate: string read GetScrollButtonsTemplate;
    property ImagesTemplate: string read GetImagesTemplate;
    property PromptFileTemplate: string read GetPromptFileTemplate;
    property AudioTemplate: string read GetAudioTemplate;
    property AudioRecordingTemplate: string read GetAudioRecordingTemplate;
    property VideoTemplate: string read GetVideoTemplate;
    property DisplayfileTemplate: string read GetDisplayfileTemplate;
    property SelectorTemplate: string read GetSelectorTemplate;
    property ConfirmationDialogTemplate: string read GetConfirmationDialogTemplate;
    property FilesDrawerTemplate: string read GetFilesDrawerTemplate;
    property ErrorsTemplate: string read GetErrorsTemplate;
    property RequestParamsTemplate: string read GetRequestParamsTemplate;
    property BootstrapDictionaryTemplate: string read GetBootstrapDictionaryTemplate;
    property ChatFooterTemplate: string read GetChatFooterTemplate;
    property CardSelectorTemplate: string read GetCardSelectorTemplate;
    property PromptSummaryTemplate: string read GetPromptSummaryTemplate;
    property ModelsTemplate: string read GetModelsTemplate;
    property InputDialogTemplate: string read GetInputDialogTemplate;
    property ActivityLogoTemplate: string read GetActivityLogoTemplate;
    property WebDecisionTemplate: string read GetWebDecisionTemplate;
    property InjectionEndedTemplate: string read GetInjectionEndedTemplate;
  end;

  TEdgeInjection = class(TInterfacedObject, ITemplateProvider)
  private
    FInitialHtml: string;
    FDisplayTemplate: string;
    FReasoningTemplate: string;
    FPromptTemplate: string;
    FInputBubbleTemplate: string;
    FScrollButtonsTemplate: string;
    FImagesTemplate: string;
    FPromptFileTemplate: string;
    FAudioTemplate: string;
    FAudioRecordingTemplate: string;
    FVideoTemplate: string;
    FDisplayfileTemplate: string;
    FSelectorTemplate: string;
    FConfirmationDialogTemplate: string;
    FFilesDrawerTemplate: string;
    FErrorsTemplate: string;
    FRequestParamsTemplate: string;
    FBootstrapDictionaryTemplate: string;
    FModelsTemplate: string;
    FChatFooterTemplate: string;
    FCardSelectorTemplate: string;
    FPromptSummaryTemplate: string;
    FInputDialogTemplate: string;
    FActivityLogoTemplate: string;
    FWebDecisionTemplate: string;
    FInjectionEndedTemplate: string;

    FAlwaysReloading: Boolean;
    FPath: string;

    function LoadTemplate(const FileName: string): string;
    function LoadCustomTemplate(const FileName: string): string;
    procedure InitializeTemplates;

    function GetInitialHtml: string;
    function GetDisplayTemplate: string;
    function GetReasoningTemplate: string;
    function GetPromptTemplate: string;
    function GetInputBubble: string;
    function GetScrollButtonsTemplate: string;
    function GetImagesTemplate: string;
    function GetPromptFileTemplate: string;
    function GetAudioTemplate: string;
    function GetAudioRecordingTemplate: string;
    function GetVideoTemplate: string;
    function GetDisplayfileTemplate: string;
    function GetConfirmationDialogTemplate: string;
    function GetFilesDrawerTemplate: string;
    function GetErrorsTemplate: string;
    function GetRequestParamsTemplate: string;
    function GetBootstrapDictionaryTemplate: string;
    function GetModelsTemplate: string;
    function GetChatFooterTemplate: string;
    function GetCardSelectorTemplate: string;
    function GetPromptSummaryTemplate: string;
    function GetInputDialogTemplate: string;
    function GetActivityLogoTemplate: string;
    function GetWebDecisionTemplate: string;
    function GetInjectionEndedTemplate: string;

    function GetSelectorTemplate: string;
    function GetPath(const Path: string; const BaseDir: string = ''): string;
  public
    constructor Create;

    /// <summary>
    /// Enables automatic reloading of template files from the specified directory on each access.
    /// This is recommended for development or rapid prototyping, as it reflects any changes to the template files immediately.
    /// </summary>
    /// <param name="APath">
    /// Optional path to the directory containing template files. If empty, uses the default template path.
    /// </param>
    procedure TemplateAllwaysReloading(const APath: string = '');

    /// <summary>
    /// Disables automatic reloading, causing all template files to be loaded only once and cached in memory.
    /// This improves performance and stability for production use, but changes to template files require an application restart.
    /// </summary>
    procedure TemplateNeverReloading;

    /// <summary>
    /// Sets the directory path where template files are located.
    /// </summary>
    /// <param name="Value">
    /// The file system path to use for loading template files.
    /// </param>
    procedure SetTemplatePath(const Value: string);

    /// <summary>
    /// Gets the HTML template used for initial page rendering.
    /// </summary>
    /// <returns>
    /// The content of the initial HTML template.
    /// </returns>
    property InitialHtml: string read GetInitialHtml;
  end;

implementation

{ TEdgeInjection }

constructor TEdgeInjection.Create;
begin
  inherited Create;
  FPath := TEMPLATE_PATH;
  FAlwaysReloading := False;
  InitializeTemplates;
end;

function TEdgeInjection.GetActivityLogoTemplate: string;
begin
  if FAlwaysReloading then
    FActivityLogoTemplate := LoadTemplate(js_activityLogo.ToString);
  Result := FActivityLogoTemplate;
end;

function TEdgeInjection.GetAudioTemplate: string;
begin
  if FAlwaysReloading then
    FAudioTemplate := LoadTemplate(js_audio.ToString);
  Result := FAudioTemplate;
end;

function TEdgeInjection.GetAudioRecordingTemplate: string;
begin
  if FAlwaysReloading then
    FAudioRecordingTemplate := LoadTemplate(js_audioRecording.ToString);
  Result := FAudioRecordingTemplate;
end;

function TEdgeInjection.GetBootstrapDictionaryTemplate: string;
begin
  if FAlwaysReloading then
    FBootstrapDictionaryTemplate := LoadTemplate(js_bootstrapDictionary.ToString);
  Result := FBootstrapDictionaryTemplate;
end;

function TEdgeInjection.GetChatFooterTemplate: string;
begin
  if FAlwaysReloading then
    FChatFooterTemplate := LoadTemplate(js_chatFooter.ToString);
  Result := FChatFooterTemplate;
end;

function TEdgeInjection.GetConfirmationDialogTemplate: string;
begin
  if FAlwaysReloading then
    FConfirmationDialogTemplate := LoadTemplate(js_confirmationDialog.ToString);
  Result := FConfirmationDialogTemplate;
end;

function TEdgeInjection.GetDisplayfileTemplate: string;
begin
  if FAlwaysReloading then
    FDisplayfileTemplate := LoadTemplate(js_displayfile.ToString);
  Result := FDisplayfileTemplate;
end;

function TEdgeInjection.GetDisplayTemplate: string;
begin
  if FAlwaysReloading then
    FDisplayTemplate := LoadTemplate(js_response.ToString);
  Result := FDisplayTemplate;
end;

function TEdgeInjection.GetErrorsTemplate: string;
begin
  if FAlwaysReloading then
    FErrorsTemplate := LoadTemplate(js_errors.ToString);
  Result := FErrorsTemplate;
end;

function TEdgeInjection.GetFilesDrawerTemplate: string;
begin
  if FAlwaysReloading then
    FFilesDrawerTemplate := LoadTemplate(js_filesMenager.ToString);
  Result := FFilesDrawerTemplate;
end;

function TEdgeInjection.GetImagesTemplate: string;
begin
  if FAlwaysReloading then
    FImagesTemplate := LoadTemplate(js_images.ToString);
  Result := FImagesTemplate;
end;

function TEdgeInjection.GetInitialHtml: string;
begin
  if FAlwaysReloading then
    FInitialHtml := LoadTemplate(main_html.ToString);
  Result := FInitialHtml;
end;

function TEdgeInjection.GetInjectionEndedTemplate: string;
begin
  if FAlwaysReloading then
    FInjectionEndedTemplate := LoadTemplate(js_injectionEnded.ToString);
  Result := FInjectionEndedTemplate;
end;

function TEdgeInjection.GetInputBubble: string;
begin
  if FAlwaysReloading then
    FInputBubbleTemplate := LoadTemplate(js_inputbubble.ToString);
  Result := FInputBubbleTemplate;
end;

function TEdgeInjection.GetInputDialogTemplate: string;
begin
  if FAlwaysReloading then
    FInputDialogTemplate := LoadTemplate(js_inputDialog.ToString);
  Result := FInputDialogTemplate;
end;

function TEdgeInjection.GetModelsTemplate: string;
begin
  if FAlwaysReloading then
    FModelsTemplate := LoadTemplate(js_models.ToString);
  Result := FModelsTemplate;
end;

function TEdgeInjection.GetPath(const Path, BaseDir: string): string;
begin
  if TPath.IsPathRooted(Path) then
    Result := Path
  else
    if not BaseDir.Trim.IsEmpty then
      Result := TPath.GetFullPath(TPath.Combine(BaseDir, Path))
    else
      Result := TPath.GetFullPath(Path);
end;

function TEdgeInjection.GetPromptFileTemplate: string;
begin
  if FAlwaysReloading then
    FPromptFileTemplate := LoadTemplate(js_promptFile.ToString);
  Result := FPromptFileTemplate;
end;

function TEdgeInjection.GetPromptSummaryTemplate: string;
begin
  if FAlwaysReloading then
    FPromptSummaryTemplate := LoadTemplate(js_promptSummary.ToString);
  Result := FPromptSummaryTemplate;
end;

function TEdgeInjection.GetPromptTemplate: string;
begin
  if FAlwaysReloading then
    FPromptTemplate := LoadTemplate(js_prompt.ToString);
  Result := FPromptTemplate;
end;

function TEdgeInjection.GetReasoningTemplate: string;
begin
  if FAlwaysReloading then
    FReasoningTemplate := LoadTemplate(js_waitfor.ToString);
  Result := FReasoningTemplate;
end;

function TEdgeInjection.GetRequestParamsTemplate: string;
begin
  if FAlwaysReloading then
    FRequestParamsTemplate := LoadTemplate(js_requestParams.ToString);
  Result := FRequestParamsTemplate;
end;

function TEdgeInjection.GetScrollButtonsTemplate: string;
begin
  if FAlwaysReloading then
    FScrollButtonsTemplate := LoadTemplate(js_scrollButtons.ToString);
  Result := FScrollButtonsTemplate;
end;

function TEdgeInjection.GetSelectorTemplate: string;
begin
  if FAlwaysReloading then
    FSelectorTemplate := LoadTemplate(js_selector.ToString);
  Result := FSelectorTemplate;
end;

function TEdgeInjection.GetCardSelectorTemplate: string;
begin
  if FAlwaysReloading then
    FCardSelectorTemplate := LoadTemplate(js_CardSelector.ToString);
  Result := FCardSelectorTemplate;
end;

function TEdgeInjection.GetVideoTemplate: string;
begin
  if FAlwaysReloading then
    FVideoTemplate := LoadTemplate(js_video.ToString);
  Result := FVideoTemplate;
end;

function TEdgeInjection.GetWebDecisionTemplate: string;
begin
  if FAlwaysReloading then
    FWebDecisionTemplate := LoadTemplate(js_webDecision.ToString);
  Result := FWebDecisionTemplate;
end;

procedure TEdgeInjection.InitializeTemplates;
begin
  FInitialHtml := LoadTemplate(main_html.ToString);
  FBootstrapDictionaryTemplate := LoadTemplate(js_bootstrapDictionary.ToString);
  FDisplayTemplate := LoadTemplate(js_response.ToString);
  FPromptTemplate := LoadTemplate(js_prompt.ToString);
  FReasoningTemplate := LoadTemplate(js_waitfor.ToString);
  FRequestParamsTemplate := LoadTemplate(js_requestParams.ToString);
  FInputBubbleTemplate := LoadTemplate(js_inputbubble.ToString);
  FScrollButtonsTemplate := LoadTemplate(js_scrollButtons.ToString);
  FPromptSummaryTemplate := LoadTemplate(js_promptSummary.ToString);
  FImagesTemplate := LoadTemplate(js_images.ToString);
  FPromptFileTemplate := LoadTemplate(js_promptFile.ToString);
  FAudioTemplate := LoadTemplate(js_audio.ToString);
  FAudioRecordingTemplate := LoadTemplate(js_audioRecording.ToString);
  FVideoTemplate := LoadTemplate(js_video.ToString);
  FDisplayfileTemplate := LoadTemplate(js_displayfile.ToString);
  FSelectorTemplate := LoadTemplate(js_selector.ToString);
  FConfirmationDialogTemplate := LoadTemplate(js_confirmationDialog.ToString);
  FFilesDrawerTemplate := LoadTemplate(js_filesMenager.ToString);
  FErrorsTemplate := LoadTemplate(js_errors.ToString);
  FModelsTemplate := LoadTemplate(js_models.ToString);
  FChatFooterTemplate := LoadTemplate(js_chatFooter.ToString);
  FCardSelectorTemplate := LoadTemplate(js_cardSelector.ToString);
  FInputDialogTemplate := LoadTemplate(js_inputDialog.ToString);
  FActivityLogoTemplate := LoadTemplate(js_activityLogo.ToString);
  FWebDecisionTemplate := LoadTemplate(js_webDecision.ToString);
  FInjectionEndedTemplate := LoadTemplate(js_injectionEnded.ToString);
end;

function TEdgeInjection.LoadCustomTemplate(const FileName: string): string;
begin
  Result := TFileIOHelper.LoadFromFile(FileName);
end;

function TEdgeInjection.LoadTemplate(const FileName: string): string;
var
  GetHtmlPath: string;
begin
  if FPath.isEmpty then
    GetHtmlPath := TPath.Combine('', FileName)
  else
    GetHtmlPath := TPath.Combine(GetPath(FPath), FileName);

  Result := TFileIOHelper.LoadFromFile(GetHtmlPath);
end;

procedure TEdgeInjection.SetTemplatePath(const Value: string);
begin
  FPath := Value;
end;

procedure TEdgeInjection.TemplateAllwaysReloading(const APath: string);
begin
  {--- Enable lazy loading - do not reload all models here as this would penalize performance }
  if not APath.Trim.IsEmpty then
    FPath := APath;
  FAlwaysReloading := True;
end;

procedure TEdgeInjection.TemplateNeverReloading;
begin
  FAlwaysReloading := False;
end;

{ TTemplateTypeHelper }

function TTemplateTypeHelper.ToString: string;
begin
  Result := FileNames[Self];
end;

end.
