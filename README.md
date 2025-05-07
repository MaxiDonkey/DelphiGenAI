# **Delphi GenAI - Optimized OpenAI Integration**


Welcome to `GenAI`, a powerful and flexible **Delphi library** integrating the latest innovations from `OpenAI` APIs. Designed for comprehensive support, it enables content generation, dialogue management, vision and speech processing, as well as audio interactions with precise control.
Built on advanced models with reasoning capabilities, such as `o1`, `o3` and `o4`, it provides tools for data manipulation, batch processing, function calling, file management, and content moderation. It also supports the `GPT-4.1` models, the teminaison points `v1/chat/completion`, `v1/responses` and offers seamless agent construction.
Additionally, `GenAI` streamlines assistant orchestration, message management, threads, and execution (runs), meeting the demands of modern projects. <br> <br>
Integrating OpenAI APIs into your Delphi apps has never been easier: enjoy streamlined network‑call management, built‑in unit testing, and a modular JSON‑configuration approach.
Check out the full [GenAI project](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/GenAI.md)
___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20on%20april%2019,%202025-blue)

<br>

NEW: 
- [Gpt-image-1 model](#gpt-image-1-model)
- [Responses vs. Chat Completions](#responses-vs-chat-completions)
- [Responses](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/Responses.md)
- [How do you structure advanced reasoning using Promises and pipelines?](#how-do-you-structure-advanced-reasoning-using-promises-and-pipelines)
___

<br>

- [Introduction](#introduction)
- [Documentation Overview](#documentation-overview)
- [TIPS for using the tutorial effectively](#tips-for-using-the-tutorial-effectively)
    - [Obtain an api key](#obtain-an-api-key)
    - [Strategies for quickly using the code examples](#strategies-for-quickly-using-the-code-examples)
- [Quick Start Guide](#quick-start-guide)
    - [Responses vs. Chat Completions](#responses-vs-chat-completions)
        - [Functional differences between the two endpoints](#functional-differences-between-the-two-endpoints)
        - [Chat completion](#chat-completion)
        - [Responses](#responses)
    - [Models](#models)
        - [List of models](#list-of-models)
        - [Retrieve a model](#retrieve-a-model)
        - [Delete a model](#delete-a-model)
    - [Image generation](#image-generation)
        - [Dall-e-3 model](#dall-e-3-model)
        - [Gpt-image-1 model](#gpt-image-1-model)
        - [Create image edit with gpt-image-1](#create-image-edit-with-gpt-image-1)
    - [Text to speech](#text-to-speech)
    - [Speech to text](#speech-to-text)
    - [Embeddings](#embeddings)
    - [Moderation](#moderation)
        - [Modarate text inputs](#modarate-text-inputs)
        - [Modarate images and text](#modarate-images-and-text)
    - [Files](#files)
        - [Files list](#files-list)
        - [File upload](#file-upload)
        - [File retrieve](#file-retrieve)
        - [File retrieve content](#file-retrieve-content)
        - [File Deletion](#file-deletion)
- [Beyond the Basics Advanced Usage](#beyond-the-basics-advanced-usage)  
- [Legacy](#legacy)
    - [Completion](#completion)
    - [Streamed completion](#streamed-completion)
- [Tips and tricks](#tips-and-tricks)
    - [How to prevent an error when closing an application while requests are still in progress?](#how-to-prevent-an-error-when-closing-an-application-while-requests-are-still-in-progress)
    - [How to execute multiple background requests to process a batch of responses?](#how-to-execute-multiple-background-requests-to-process-a-batch-of-responses)
    - [How to structure a chain of thought and develop advanced processing with GenAI?](#how-to-structure-a-chain-of-thought-and-develop-advanced-processing-with-genai)
    - [How do you structure advanced reasoning using Promises and pipelines?](#how-do-you-structure-advanced-reasoning-using-promises-and-pipelines)
- [GenAI functional coverage](#genai-functional-coverage)
- [Contributing](#contributing)
- [License](#license)

___

<br>

# Introduction

Following the development of several wrappers integrating solutions from [Anthropic (Claude)](https://github.com/MaxiDonkey/DelphiAnthropic), [Google (Gemini)](https://github.com/MaxiDonkey/DelphiGemini), [Mistral](https://github.com/MaxiDonkey/DelphiMistralAI), [GroqCloud](https://github.com/MaxiDonkey/DelphiStabilityAI), [Hugging Face](https://github.com/MaxiDonkey/DelphiHuggingFace), and [Deepseek](https://github.com/MaxiDonkey/DelphiDeepseek), `GenAI` now benefits from extensive feedback and experience. This feedback has enabled the creation of an optimized and advanced framework, specifically designed to meet the demands of large-scale projects developed using **Delphi**.

In its latest version, `GenAI` has been primarily optimized to fully leverage OpenAI’s endpoints while remaining easily adaptable for the integration of the other aforementioned wrappers.

<br>

**Comprehensive Integration with OpenAI** <br>
- `GenAI` is designed to support the **gpt-4o**, **chatgpt-4o**, **gpt-4.1**, **o1-pro**, **o3** and **o4** models, along with the latest developments in `OpenAI’s APIs`. This extensive coverage ensures maximum flexibility for projects leveraging the latest advancements in OpenAI's offerings.

<br>

**Document Structure** <br>
- This document is divided into two main sections:

   1. **Quick Start Guide** <br>
   A practical introduction to generating text or audio responses from various types of inputs:
      - Plain text
      - Image/text combinations
      - Document-based inputs (text)
      - Audio and audio/text data

  2. **Advanced Features in a Cookbook Format**
      - A detailed guide showcasing advanced features available through OpenAI, complete with practical code examples for easy integration into your applications.

<br>

**Technical Support and Code Examples**<br>
- Two support units, **VCL** and **FMX**, are included in the provided sources. These units simplify the implementation of the code examples and facilitate learning, with a focus on best practices for using `GenAI`.

For more information about the architecture of GenAI, please refer to [the dedicated page](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/GenAI.md). 

<br>

> [!IMPORTANT]
>
> This is an unofficial library. **OpenAI** does not provide any official library for `Delphi`.
> This repository contains `Delphi` implementation over [OpenAI](https://openai.com/) public API.

<br>

___

# Documentation Overview

Comprehensive Project Documentation Reference

- [Changelog](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/Changelog.md)
- [About this project](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/GenAI.md)
- [Chat completion](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/ChatCompletion.md)
- [Responses](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/Responses.md)
- [Beyond the Basics Advanced Usage](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/BeyondBasics.md)

<br>

# TIPS for using the tutorial effectively

## Obtain an api key

To initialize the API instance, you need to obtain an [API key from OpenAI](https://platform.openai.com/settings/organization/api-keys)

Once you have a token, you can initialize IGenAI interface, which is an entry point to the API.

>[!NOTE]
>```Delphi
>//uses GenAI, GenAI.Types;
>
>//Declare 
>//  Client: IGenAI;
>
>  Client := TGenAIFactory.CreateInstance(api_key);
>```

To streamline the use of the API wrapper, the process for declaring units has been simplified. Regardless of the methods being utilized, you only need to reference the following two core units:
`GenAI` and `GenAI.Types`.

<br>

>[!TIP]
> To effectively use the examples in this tutorial, particularly when working with asynchronous methods, it is recommended to define the client interfaces with the broadest possible scope. For optimal implementation, these clients should be declared in the application's `OnCreate` method.
>

<br>

## Strategies for quickly using the code examples

To streamline the implementation of the code examples provided in this tutorial, two support units have been included in the source code: `Deepseek.Tutorial.VCL` and `Deepseek.Tutorial.FMX` Based on the platform selected for testing the provided examples, you will need to initialize either the `TVCLTutorialHub` or `TFMXTutorialHub` class within the application's OnCreate event, as illustrated below:

>[!NOTE]
>```Delphi
>//uses GenAI.Tutorial.VCL;
>TutorialHub := TVCLTutorialHub.Create(Client, Memo1, Memo2, Memo3, Image1, Button1, MediaPlayer1);
>```

or

>[!NOTE]
>```Delphi
>//uses GenAI.Tutorial.FMX;
>TutorialHub := TFMXTutorialHub.Create(Client, Memo1, Memo2, Memo3, Image1, Button1, MediaPlayer1);
>```

Make sure to add a three ***TMemo***, a ***TImage***, a ***TButton*** and a ***TMediaPlayer*** components to your form beforehand.

The TButton will allow the interruption of any streamed reception.

<br>

___

# Quick Start Guide

## Responses vs. Chat Completions

The `v1/responses` API is the new core API, designed as an agentic primitive that combines the simplicity of chat completions with the power of action execution. It natively includes several built‑in tools:
- Web search
- File search
- Computer control

With these integrated capabilities, you can build more autonomous, agent‑oriented applications that not only generate text but also interact with their environment.

The `v1/responses` endpoint is intended to gradually replace `v1/chat/completions`, as it embodies a synthesis of current best practices in AI—especially for those looking to adopt an agentic approach.

To help you get up to speed on both endpoints, the two following documents provide detailed documentation, complete with numerous request examples and use cases:
- [v1/chat/completion](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/ChatCompletion.md#chat-completion)
- [v1/responses](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/Responses.md)

>[!NOTE]
>If you're a new user, we recommend using the Responses API.

<br>

### Functional differences between the two endpoints

|Capabilities | Chat Completions API | Responses API |
|--- |:---: | :---: |
|Text generation | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Audio  | <div align="center"><span style="color: green;">●</span></div> | Coming soon | 
| Vision | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Structured Outputs | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Function calling | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Web search | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| File search |  | <div align="center"><span style="color: green;">●</span></div> |
| Computer use |  | <div align="center"><span style="color: green;">●</span></div> |
| Code interpreter |  | Coming soon |

>[!WARNING]
> [Note from OpenAI](https://platform.openai.com/docs/guides/responses-vs-chat-completions#the-chat-completions-api-is-not-going-away) <br>
> The Chat Completions API is an industry standard for building AI applications, and we intend to continue supporting this API indefinitely. We're introducing the Responses API to simplify workflows involving tool use, code execution, and state management. We believe this new API primitive will allow us to more effectively enhance the OpenAI platform into the future.

<br>

### Chat completion

Check out the full [documentation](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/ChatCompletion.md#chat-completion)

[Text generation (Non streamed, Streamed, Multi-turn conversations), Generating Audio Responses with Chat (Audio and Text to Text, Audio to Audio, Audio multi-turn conversations), Vision (Analyze single source, Analyze multi-source, Low or high fidelity image understanding), Reasoning with o1, o3 or o4,  Web search...](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/ChatCompletion.md#chat-completion)

<br>

### Responses

Check out the full [documentation](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/Responses.md)

[Text generation (Non streamed, Streamed, Multi-turn conversations), Vision (Analyze single source, Analyze multi-source, Low or high fidelity image understanding), Reasoning with o1, o3 or o4, Web search, File search...](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/Responses.md)


<br>

___

## Models

Refert to [official documentation](https://platform.openai.com/docs/models).

### List of models

The list of available models can be retrieved from the Models API response. The models are ordered by release date, with the most recently published appearing first.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Models.AsynList(
    function : TAsynModels
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Models.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Retrieve a model

Retrieve a model using its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.ModelId := '...the id tio retrieve...';

  //Asynchronous example
  Client.Models.AsynRetrieve(TutorialHub.ModelId,
    function : TAsynModel
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Models.Retrieve(TutorialHub.ModelId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Delete a model

Deleting a model is only possible if the model is one of your fine-tuned models.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.ModelId := '...Id of the model to delete...';

  //Asynchronous example
  Client.Models.AsynDelete(TutorialHub.ModelId,
    function : TAsynDeletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Models.Delete(TutorialHub.ModelId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

___

## Image generation

Refer to [official documentation](https://platform.openai.com/docs/guides/images).

### Dall-e-3 model

Generation of an image using `dall-e-3`.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.FileName := 'Dalle3_01.png';

  //Asynchronous example
  Client.Images.AsynCreate(
    procedure (Params: TImageCreateParams)
    begin
      Params.Model('dall-e-3');
      Params.Prompt('A quarter dollar on a wooden floor close up.');
      Params.N(1);
      Params.Size('1024x1024');
      Params.Style('vivid');
      Params.ResponseFormat(TResponseFormat.url);
    end,
    function : TAsynGeneratedImages
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Images.Create(
//    procedure (Params: TImageCreateParams)
//    begin
//      Params.Model('dall-e-3');
//      Params.Prompt('A quarter dollar on a wooden floor close up.');
//      Params.N(1);
//      Params.Size('1024x1024');
//      Params.Style('vivid');
//      Params.ResponseFormat(url);
//      TutorialHub.JSONResponse := Value.JSONResponse;
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

Let’s take a closer look at how the `Display` method handles output to understand how the model’s response is managed.

```Delphi
procedure Display(Sender: TObject; Value: TGeneratedImages);
begin
  {--- Load image when url is not null. }
  if not TutorialHub.FileName.IsEmpty then
    begin
      if not Value.Data[0].Url.IsEmpty then
        Value.Data[0].Download(TutorialHub.FileName) else
        Value.Data[0].SaveToFile(TutorialHub.FileName);
    end;

  {--- Load image into a stream }
  var Stream := Value.Data[0].GetStream;
  try
    {--- Display the JSON response. }
    TutorialHub.JSONResponse := Value.JSONResponse;

    {--- Display the revised prompt. }
    Display(Sender, Value.Data[0].RevisedPrompt);

    {--- Load the stream into the TImage. }
    TutorialHub.Image.Picture.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;
```

`GenAI` offers optimized methods for managing image responses generated by the model. The `SaveToFile`, `Download`, and `GetStream` methods enable efficient handling of the received image content.

<br>

![Preview](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/DallePreview.png?raw=true "Preview")

<br>


### Gpt-image-1 model

Since May 5, 2025, OpenAI has offered the `gpt-image-1` model for image creation and editing. This new model delivers higher quality compared to `dall-e-2` and `dall-e-3`.

In the configuration, you now have four additional parameters for image generation:
- **background:** Allows you to set the transparency of the generated image’s background. Only supported by `gpt-image-1`. Must be one of `transparent`, `opaque`, or `auto` (default).

- **moderation:** Controls the content-moderation level for images generated by `gpt-image-1`. Must be either` low` (less restrictive filtering) or `auto` (default).

- **output_compression:** Specifies the compression level (0–100%) for the generated images. Only supported by `gpt-image-1` when using the `webp` or `jpeg` output formats; defaults to 100.

- **output_format:** Determines the format in which generated images are returned. Only supported by `gpt-image-1`. Must be one of `png`, `jpeg`, or `webp`.

<br>

Additionally, several existing parameters have been extended with new values for `gpt-image-1`:

quality: Supports `high`, `medium`, and `low`.

size: Supports `1536×1024` (landscape), `1024×1536` (portrait), or `auto` (default).

prompt: Allows up to 32,000 characters for `gpt-image-1` (versus 1,000 for `dall-e-2` and 4,000 for `dall-e-3`).

<br>

An example of image creation with gpt-image-1 (Asynchronous because response times are much longer):

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.FileName := 'GptImage1.png';

  //Increased reception timeout (ms) as the model takes longer
  Client.API.HttpClient.ResponseTimeout := 120000;

  //Asynchronous example
  Client.Images.AsynCreate(
    procedure (Params: TImageCreateParams)
    begin
      Params.Model('gpt-image-1'); //'dall-e-3');
      Params.Prompt('A realistic photo of a coffee cup with saucer on a transparent background');
      Params.N(1);
      Params.Size('1536x1024');
      Params.BackGround('transparent');
      Params.Moderation('low');
      Params.OutputFormat('png');
      Params.Quality('high');
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynGeneratedImages
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br>

![Preview](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/CreationGpt-image-1.png?raw=true "Preview")

<br>

>[!NOTE]
>We can notice in the returned JSON the usage values ​​which are not provided with the dall-e-2 and dall-e-3 models.

<br>

### Create image edit with gpt-image-1

Previously, I hadn’t gone into detail about the image-editing process, because the only model available at OpenAI—`DALL·E 2`—produced rather unconvincing results.

However, with `gpt-image-1`, the output quality is significantly higher.

To perform an edit:

1. Prepare your base image
     - Open the image you wish to modify and erase the area to be reworked using a transparency tool (brush or selection).

2. Generate the mask
     - The erased (transparent) region becomes the mask that you’ll supply to the model.

3. Compose your extended prompt
     - In your request, describe exactly what the model should insert into the masked area. You now have up to 32,000 tokens for a fully detailed description.

4. Execute the edit
     - Provide the model with both the masked image and your prompt; it will then know precisely where and how to apply the changes.

Below, you’ll find an example of the code to send to gpt-image-1 to initiate the edit.

<br>

```Delphi
  TutorialHub.FileName := 'Image-gpt-edit.png';

  //Increased reception timeout (ms) as the model takes longer
  Client.API.HttpClient.ResponseTimeout := 120000;

  //Asynchronous example
  Client.Images.AsynEdit(
    procedure (Params: TImageEditParams)
    begin
      Params.Model('gpt-image-1');
      Params.Image('Dalle05.png');          //<--- Unmodified image
      Params.Mask('Dalle05Mask.png');       //<--- Modified image with masked part
      Params.Prompt('Add a pink elephant'); //<--- Replace the mask by building this
      Params.Size('1024x1024');
    end,
    function : TAsynGeneratedImages
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br>

- Result with the hidden section:

![Preview](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/GptImageMask.png?raw=true "Preview")

- Result after editing:

![Preview](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/GptImageEditResult.png?raw=true "Preview")

___

## Text to speech

Convert a text into an audio file. Refer to [official documentation](https://platform.openai.com/docs/guides/text-to-speech)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.FileName := 'Speech.mp3';

  //Asynchronous example
  Client.Audio.AsynSpeech(
    procedure (Params: TSpeechParams)
    begin
      Params.Model('tts-1');
      Params.Input('Hi! what are you doing ?');
      Params.Voice('fable');
      Params.ResponseFormat(TSpeechFormat.mp3);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynSpeechResult
    begin
      Result.Sender := TutorialHub;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Audio.Speech(
//    procedure (Params: TSpeechParams)
//    begin
//      Params.Model('tts-1');
//      Params.Input('Hi! what are you doing ?');
//      Params.Voice(alloy);
//      Params.ResponseFormat(mp3);
//      TutorialHub.JSONResponse := Value.JSONResponse;
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;  
```
<br>

Let’s take a closer look at how the `Display` method handles output to understand how the model’s response is managed.

```Delphi
procedure Display(Sender: TObject; Value: TSpeechResult);
begin
  {--- Display the JSON response }
  TutorialHub.JSONResponse := Value.JSONResponse;

  {--- The file name can not be null }
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');

  {--- Save the audio into a file. }
  Value.SaveToFile(TutorialHub.FileName);

  {--- Play the audio result }
  TutorialHub.PlayAudio;
end;
```

`GenAI` provides methods to handle audio responses generated by the model. The `SaveToFile` and `GetStream` methods enable the manipulation of received audio content.

<br>

___

## Speech to text

Convert data audio into a text. Refer to [official documentation](https://platform.openai.com/docs/guides/speech-to-text) or this [page](https://platform.openai.com/docs/guides/audio).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequest := 'multipart';

  //Asynchronous example
  Client.Audio.AsynTranscription(
    procedure (Params: TTranscriptionParams)
    begin
      Params.&File('SpeechRecorded.wav');
      Params.Model('whisper-1');
      Params.ResponseFormat(TTranscriptionResponseFormat.verbose_json);
    end,
    function : TAsynTranscription
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Audio.Transcription(
//    procedure (Params: TTranscriptionParams)
//    begin
//      Params.&File('SpeechRecorded.wav');
//      Params.Model('whisper-1');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

___

## Embeddings

**OpenAI’s** text embeddings evaluate how closely related different text strings are. These embeddings serve as a powerful tool for various applications, including:

- **Search:** Ranking results based on their relevance to a given query.
- **Clustering:** Grouping similar text strings together based on shared characteristics.
- **Recommendations:** Suggesting items that share similar text content.
- **Anomaly detection:** Identifying outliers by finding text strings with minimal similarity to the rest.
- **Diversity measurement:** Analyzing the distribution of similarities within a dataset.
- **Classification:** Assigning text strings to the category or label they closely align with.

An embedding is represented as a vector, or a list of floating-point numbers. The relatedness between two text strings is determined by measuring the distance between their respective vectors: smaller distances indicate strong similarity, while larger distances imply weaker relatedness.

Refer to [official documentation](https://platform.openai.com/docs/guides/embeddings).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Embeddings.ASynCreate(
    procedure (Params: TEmbeddingsParams)
    begin
      Params.Input(['Hello', 'how', 'are you?']);
      Params.Model('text-embedding-3-large');
      Params.Dimensions(5);
      Params.EncodingFormat(TEncodingFormat.float);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynEmbeddings
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Embeddings.Create(
//    procedure (Params: TEmbeddingsParams)
//    begin
//      Params.Input(['Hello', 'how', 'are you?']);
//      Params.Model('text-embedding-3-large');
//      Params.Dimensions(5);
//      Params.EncodingFormat(TEncodingFormat.float);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

___

## Moderation

The moderation endpoint is a valuable resource for detecting potentially harmful text or images. When harmful content is identified, developers can take appropriate measures, such as filtering the content or managing user accounts responsible for the violations. This service is provided free of charge.

Available models for the moderation endpoint include:

- **omni-moderation-latest:** The most advanced model, supporting a wider range of content categorization and multi-modal inputs (both text and images).

- **text-moderation-latest (Legacy):** An older model designed exclusively for text-based inputs with limited categorization options. For new projects, the omni-moderation model is recommended due to its superior capabilities and broader input support.

Refer to the [official documentation](https://platform.openai.com/docs/guides/moderation).

<br>

### Modarate text inputs

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Moderation.AsynEvaluate(
    procedure (Params: TModerationParams)
    begin
      Params.Input('...text to classify goes here...');
      Params.Model('omni-moderation-latest');
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynModeration
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Moderation.Evaluate(
//    procedure (Params: TModerationParams)
//    begin
//      Params.Input('...text to classify goes here...');
//      Params.Model('omni-moderation-latest');
//      TutorialHub.JSONRequest := Params.ToFormat();
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

### Modarate images and text

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Ref := 'https://example.com/image.png';

  //Asynchronous example
  Client.Moderation.AsynEvaluate(
    procedure (Params: TModerationParams)
    begin
      Params.Input(['...text to classify goes here...', Ref]);
      Params.Model('omni-moderation-latest');
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynModeration
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Moderation.Evaluate(
//    procedure (Params: TModerationParams)
//    begin
//      Params.Input(['...text to classify goes here...', Ref]);
//      Params.Model('omni-moderation-latest');
//      TutorialHub.JSONRequest := Params.ToFormat();
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
<br>

`GenAI` offers an efficient and streamlined approach for handling categories and scores generated by the moderation process. Specifically, the display method is designed for simplicity and ease of use, as demonstrated in the example below.

```Delphi
procedure Display(Sender: TObject; Value: TModerationResult);
begin
 {--- GenAI built the FlaggedDetail property which contains only active moderation categories. }
  for var Item in Value.FlaggedDetail do
    Display(Sender, [
      EmptyStr,
      F(Item.Category.ToString, Item.Score.ToString(ffNumber, 3, 3))
    ]);
  Display(Sender);
end;

procedure Display(Sender: TObject; Value: TModeration);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Results do
    Display(Sender, Item);
  Display(Sender);
end;
```

<br>

___

## Files

Files are used to upload documents that can be used with features like **Assistants**, **Fine-tuning**, and **Batch API**.

<br/>

### Files list

Example without parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Files.AsynList(
    function : TAsynFiles
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Example using parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Files.AsynList(
    procedure (Params: TFileUrlParams)
    begin
      Params.Purpose('batch');
      Params.Limit(10);
    end,
    function : TAsynFiles
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.List(
//    procedure (Params: TFileUrlParams)
//    begin
//      Params.Purpose('batch');
//      Params.Limit(10);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Refer to [parameters documentation](https://platform.openai.com/docs/api-reference/files/list).

<br/>

### File upload

You can upload files for use across multiple endpoints. Each file can be as large as 512 MB, with a maximum combined storage limit of 100 GB per organization.

The Assistants API accommodates files containing up to 2 million tokens and accepts specific file formats. For more information, refer to the [Assistants Tools guide](https://platform.openai.com/docs/assistants/tools).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Files.AsynUpload(
    procedure (Params: TFileUploadParams)
    begin
      Params.&File('BatchExample.jsonl');
      Params.Purpose(TFilesPurpose.batch);
    end,
    function : TAsynFile
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.Upload(
//    procedure (Params: TFileUploadParams)
//    begin
//      Params.&File('BatchExample.jsonl');
//      Params.Purpose(fp_batch);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
Example with batch file.

<br/>

### File retrieve

Returns information about a specific file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id file to retrieve...';

  //Asynchronous example
  Client.Files.AsynRetrieve(TutorialHub.Id,
    function : TAsynFile
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.Retrieve(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### File retrieve content

Returns the contents of the specified file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of the file to retrieve content...';

  //Asynchronous example
  Client.Files.AsynRetrieveContent(TutorialHub.Id,
    function : TAsynFileContent
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Files.RetrieveContent(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### File Deletion

Delete a file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id file to delete...';

  //Synchronous example
  var Value := Client.Files.Delete(TutorialHub.Id);
  try
    Display(TutorialHub, F('Deleted', BoolToStr(Value.Deleted, True)));
  finally
    Value.Free;
  end;
```

<br/>

# Beyond the Basics Advanced Usage

[This section](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/BeyondBasics.md) covers the advanced use of OpenAI's APIs, including key features such as `upload` management, `batch` processing, `vector` stores, and the use of `assistants`, `threads`, `messages`, and `runs`. It also addresses model `fine-tuning` and includes a note on `distillation`.

<br>

___

# Legacy

For practical purposes, **completion APIs** can be utilized through `GenAI`, enabling the use of models such as ***gpt-3.5-turbo-instruct***, among others. However, the assistant system in Beta 1 is not supported by `GenAI`.

<br>

## Completion

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Completion.AsynCreate(
    procedure (Params: TCompletionParams)
    begin
      Params.Model('gpt-3.5-turbo-instruct');
      Params.Prompt('Give a simple explanation of what curiosity is, in one short sentence.');
      Params.Logprobs(5);
      Params.MaxTokens(96);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynCompletion
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Completion.Create(
//    procedure (Params: TCompletionParams)
//    begin
//      Params.Model('gpt-3.5-turbo-instruct');
//      Params.Prompt('Give a simple explanation of what curiosity is, in one short sentence.');
//      Params.Logprobs(5);
//      Params.MaxTokens(96);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
<br>

___

## Streamed completion

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Completion.AsynCreateStream(
    procedure (Params: TCompletionParams)
    begin
      Params.Model('gpt-3.5-turbo-instruct');
      Params.Prompt('Say this is a test');
      Params.MaxTokens(96);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynCompletionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Completion.CreateStream(
//    procedure (Params: TCompletionParams)
//    begin
//      Params.Model('gpt-3.5-turbo-instruct');
//      Params.Prompt('Say this is a test');
//      Params.MaxTokens(96);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Data: TCompletion; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Data) and not IsDone then
//        DisplayStream(TutorialHub, Data);
//    end);
```

<br>

___

# Tips and tricks

- #### How to prevent an error when closing an application while requests are still in progress?

Starting from version ***1.0.1 of GenAI***, the `GenAI.Monitoring` unit is **responsible for monitoring ongoing HTTP requests.**

The `Monitoring` interface is accessible by including the `GenAI.Monitoring` unit in the `uses` clause. <br>
Alternatively, you can access it via the `HttpMonitoring` function, declared in the `GenAI` unit.

**Usage Example**

```Delphi
//uses GenAI;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not HttpMonitoring.IsBusy;
  if not CanClose then
    MessageDLG(
      'Requests are still in progress. Please wait for them to complete before closing the application."',
      TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
end;

```

<br>

- #### How to execute multiple background requests to process a batch of responses?

In the `GenAI.Chat` unit, the `CreateParallel` method allows for executing multiple prompts asynchronously in the background ***(since the version 1.0.1 of GenAI)***.

Among the method's parameters, you can specify the model to be used for the entire batch of prompts. However, assigning a different model to each prompt individually is not supported.

**Usage Example**

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  Client.Chat.CreateParallel(
    procedure (Params: TBundleParams)
    begin
      Params.Prompts([
        'How many television channels were there in France in 1980?',
        'How many TV channels were there in Germany in 1980?.'
      ]);
      Params.System('Write the text in capital letters.');
      Params.Model('gpt-4o-mini');
    end,
    function : TAsynBundleList
    begin
      Result.Sender := TutorialHub;

      Result.OnStart :=
        procedure (Sender: TObject)
        begin
          Display(Sender, 'Start the job' + sLineBreak);
        end;

      Result.OnSuccess :=
        procedure (Sender: TObject; Bundle: TBundleList)
        begin
          // Background bundle processing
          for var Item in Bundle.Items do
            begin
              Display(Sender, 'Index : ' + Item.Index.ToString);
              Display(Sender, 'FinishIndex : ' + Item.FinishIndex.ToString);
              Display(Sender, Item.Prompt + sLineBreak);
              Display(Sender, Item.Response + sLineBreak + sLineBreak);
              // or Display(Sender, TChat(Item.Chat).Choices[0].Message.Content);
            end;
        end;

      Result.OnError := Display;
    end);
```

>[!TIP]
> The provided example is somewhat simplified. It would be better to adopt this approach with ***JSON-formatted outputs***, as this allows for the implementation of more complex and tailored processing during the final stages. 

<br>

- #### How to structure a chain of thought and develop advanced processing with GenAI?

To achieve this, it is recommended to use a Promise-based pattern to efficiently construct a chain of thought with GenAI. The [CerebraChain](https://github.com/MaxiDonkey/CerebraChainAI) project offers a method that can be used with GenAI.

<br>

- #### How do you structure advanced reasoning using Promises and pipelines?

Orchestrate AI thought chains elegantly and efficiently. By leveraging a dynamic pipeline model, a configurable sequential scheduler, and Promises, you can meet the complex requirements of working with modern AI models like OpenAI. Check out the [SynkFlow repository](https://github.com/MaxiDonkey/SynkFlowAI).

<br>

___

# GenAI functional coverage

Below, the table succinctly summarizes all OpenAI endpoints supported by the GenAI.

|End point | supported | 
|--- |:---: | 
| /assistants | <div align="center"><span style="color: green;">●</span></div> |
| /audio/speech | <div align="center"><span style="color: green;">●</span></div> |
| /audio/transcriptions | <div align="center"><span style="color: green;">●</span></div> |
| /audio/translations | <div align="center"><span style="color: green;">●</span></div> |
| /batches | <div align="center"><span style="color: green;">●</span></div> |
| /chat/completions | <div align="center"><span style="color: green;">●</span></div> |
| /completions | <div align="center"><span style="color: green;">●</span></div> |
| /embeddings | <div align="center"><span style="color: green;">●</span></div> |
| /evals |  |
| /files | <div align="center"><span style="color: green;">●</span></div> |
| /fine_tuning/ | <div align="center"><span style="color: green;">●</span></div> |
| /images | <div align="center"><span style="color: green;">●</span></div> |
| /models | <div align="center"><span style="color: green;">●</span></div> |
| /moderations | <div align="center"><span style="color: green;">●</span></div> |
| /organization |  |
| /realtime |  |
| /responses | <div align="center"><span style="color: green;">●</span></div> |
| /threads | <div align="center"><span style="color: green;">●</span></div> |
| /uploads | <div align="center"><span style="color: green;">●</span></div> |
| /vector_stores | <div align="center"><span style="color: green;">●</span></div> |

<br>

___

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

<br>

___

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.

<br>
