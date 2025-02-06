# **Delphi GenAI - Optimized OpenAI Integration**

Welcome to `GenAI`, a powerful and flexible Delphi library designed to integrate the capabilities of the latest **OpenAI APIs**. This project, carefully and rigorously developed, is aimed at developers seeking a robust solution for content generation, dialogue management, vision, and much more.
___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20on%20february%2008,%202025-blue)

<br/>

- [Introduction](#Introduction)
- [TIPS for using the tutorial effectively](#TIPS-for-using-the-tutorial-effectively)
    - [Obtain an api key](#Obtain-an-api-key)
    - [Strategies for quickly using the code examples](#Strategies-for-quickly-using-the-code-examples)
- [Quick Start Guide](#Quick-Start-Guide)
    - [Text generation](#Text-generation)
        - [Non streamed](#Non-streamed) 
        - [Streamed](#Streamed)
        - [Multi-turn conversations](#Multi-turn-conversations) 
    - [Generating Audio Responses with Chat](#Generating-Audio-Responses-with-Chat)
    - [Input Audio for Chat](#Input-Audio-for-Chat)
        - [Audio and Text to Text](#Audio-and-Text-to-Text)
        - [Audio to Audio](#Audio-to-Audio)
        - [Audio multi-turn conversations](#Audio-multi-turn-conversations)
    - [Vision](#Vision)
        - [Analyze single source](#Analyze-single-source)
        - [Analyze multi-source](#Analyze-multi-source)
        - [Low or high fidelity image understanding](#Low-or-high-fidelity-image-understanding)
    - [Image generation](#Image-generation)
    - [Text to speech](#Text-to-speech)
    - [Speech to text](#Speech-to-text)
    - [Reasoning with o1 or o3](#Reasoning-with-o1-or-o3)
    - [Embeddings](#Embeddings)
    - [Moderation](#Moderation)
        - [Modarate text inputs](#Modarate-text-inputs)
        - [Modarate images and text](#Modarate-images-and-text)
- [Beyond the Basics Advanced Usage](#Beyond-the-Basics-Advanced-Usage)
    - [Function calling](#Function-calling)
    - [Models](#Models)
        - [List of models](#List-of-models)
        - [Retrieve a model](#Retrieve-a-model)
        - [Delete a model](#Delete-a-model)
    - [Files](#Files)
        - [Files list](#Files-list)
        - [File upload](#File-upload)
        - [File retrieve](#File-retrieve)
        - [File retrieve content](#File-retrieve-content)
        - [File Deletion](#File-Deletion)
    - [Uploads](#Uploads)
        - [Upload create](#Upload-create)
        - [Upload cancel](#Upload-cancel)
        - [Upload add part](#Upload-add-part)
        - [Upload complete](#Upload-complete)
    - [Batch](#Batch)
        - [Batch create](#Batch-create)
        - [Batch List](#Batch-List)
        - [Batch retrieve](#Batch-retrieve)
        - [Batch cancel](#Batch-cancel)
        - [Batch output viewer](#Batch-output-viewer)
    - [Fine tuning](#Fine-tuning)
        - [Fine tuning create](#Fine-tuning-create)
        - [Fine tuning list](#Fine-tuning-list)
        - [Fine tuning cancel](#Fine-tuning-cancel)
        - [Fine tuning events](#Fine-tuning-events)
        - [Fine tuning check point](#Fine-tuning-check-point)
        - [Fine tuning retrieve](#Fine-tuning-retrieve)
- [Contributing](#contributing)
- [License](#license)


<br/>
<br/>

# Introduction

Following the development of several wrappers integrating solutions from [Anthropic (Claude)](https://github.com/MaxiDonkey/DelphiAnthropic), [Google (Gemini)](https://github.com/MaxiDonkey/DelphiGemini), [Mistral](https://github.com/MaxiDonkey/DelphiMistralAI), [GroqCloud](https://github.com/MaxiDonkey/DelphiStabilityAI), [Hugging Face](https://github.com/MaxiDonkey/DelphiHuggingFace), and [Deepseek](https://github.com/MaxiDonkey/DelphiDeepseek), `GenAI` now benefits from extensive feedback and experience. This feedback has enabled the creation of an optimized and advanced framework, specifically designed to meet the demands of large-scale projects developed using **Delphi**.

In its latest version, `GenAI` has been primarily optimized to fully leverage OpenAI’s endpoints while remaining easily adaptable for the integration of the other aforementioned wrappers.

<br/>

**Comprehensive Integration with OpenAI** <br/>
- `GenAI` is designed to support the **GPT-4o**, **O1**, and **O3** models, along with the latest developments in `OpenAI’s APIs`. This extensive coverage ensures maximum flexibility for projects leveraging the latest advancements in OpenAI's offerings.

<br/>

**Document Structure** <br/>
- This document is divided into two main sections:

   1. **Quick Start Guide** <br/>
   A practical introduction to generating text or audio responses from various types of inputs:
      - Plain text
      - Image/text combinations
      - Document-based inputs (text)
      - Audio and audio/text data

  2. **Advanced Features in a Cookbook Format**
      - A detailed guide showcasing advanced features available through OpenAI, complete with practical code examples for easy integration into your applications.

<br/>

**Technical Support and Code Examples**<br/>
- Two support units, **VCL** and **FMX**, are included in the provided sources. These units simplify the implementation of the code examples and facilitate learning, with a focus on best practices for using `GenAI`.

For more information about the architecture of GenAI, please refer to [the dedicated page](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/GenAI.md). 


<br/>

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

<br/>

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

<br/>

# Quick Start Guide

## Text generation

You can send a structured list of input messages containing only text content, and the model will generate the next message in the conversation.

The Chat API can be used for both single-turn requests and multi-turn, stateless conversations.

### Non streamed

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
        FromSystem('You are a comedian looking for jokes for your new show.'),
        FromUser('What is the difference between a mathematician and a physicist?')
      ]);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o');
//      Params.Messages([
//        FromSystem('You are a comedian looking for jokes for your new show.'),
//        FromUser('What is the difference between a mathematician and a physicist?')
//      ]);
//      Params.MaxCompletionTokens(1024)
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

By using the GenAI.Tutorial.VCL unit along with the initialization described [above](#Strategies-for-quickly-using-the-code-examples), you can achieve results similar to the example shown below.

![Preview](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/GenAIChatRequest.png?raw=true "Preview")

<br/>

### Streamed

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
          FromSystem('You are a comedian looking for jokes for your new show.'),
          FromUser('What is the difference between a mathematician and a physicist?')]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o');
//      Params.Messages([
//          Payload.System('You are a comedian looking for jokes for your new show.'),
//          Payload.User('What is the difference between a mathematician and a physicist?')]);
//      Params.MaxCompletionTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if (not IsDone) and Assigned(Chat) then
//        begin
//          DisplayStream(TutorialHub, Chat);
//        end;
//    end);
```

![Preview](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/GenAIChatStreamedRequest.png?raw=true "Preview")

<br/>

### Multi-turn conversations

The `GenAI Chat API` enables the creation of interactive chat experiences tailored to your users' needs. Its chat functionality supports multiple rounds of questions and answers, allowing users to gradually work toward solutions or receive help with complex, multi-step issues. This capability is especially useful for applications requiring ongoing interaction, such as:

- **Chatbots**
- **Educational tools**
- **Customer support assistants**

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
          FromDeveloper('You are a funny domestic assistant.'),
          FromUser('Hello'),
          FromAssistant('Great to meet you. What would you like to know?'),
          FromUser('I have two dogs in my house. How many paws are in my house?') ]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o');
//      Params.Messages([
//          FromDeveloper('You are a funny domestic assistant.'),
//          FromUser('Hello'),
//          FromAssistant('Great to meet you. What would you like to know?'),
//          FromUser('I have two dogs in my house. How many paws are in my house?') ]);
//      Params.MaxCompletionTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if (not IsDone) and Assigned(Chat) then
//        begin
//          DisplayStream(TutorialHub, Chat);
//        end;
//    end);
```

>[!TIP]
>The `FromUser` and `FromAssistant` methods simplify role management and enhance code readability, eliminating the need to use **TMessagePayload** (e.g., **TMessagePayload.User('Hello'))**. Similarly, `FromDeveloper`, `FromSystem`, and `FromTool` improve code clarity. For details on these methods and their configurations, refer to the `GenAI.pas` unit.
>

<br/>

## Generating Audio Responses with Chat

Beyond generating text and images, certain models enable the creation of spoken audio responses from prompts and the use of audio inputs to interact with the model. Audio inputs can provide richer information than text alone, allowing the model to capture tone, inflection, and other nuances.

These audio features can be leveraged to:

- Produce a spoken audio summary from a text body (text input, audio output)
- Conduct sentiment analysis on an audio recording (audio input, text output)
- Facilitate asynchronous speech-to-speech interactions with the model (audio input, audio output)

For example, the `GPT-4o-Audio-Preview` model can process audio both as input and output. Please note, this model does not have vision capability.

Refer to official [documentation](https://platform.openai.com/docs/guides/audio?example=audio-out).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;
  
  TutorialHub.JSONRequestClear;
  TutorialHub.FileName := 'AudioResponse.mp3';

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('ballad', 'mp3');
      Params.Messages([
        FromUser('Is a golden retriever a good family dog?')
      ]);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-audio-preview');
//      Params.Modalities(['text', 'audio']);
//      Params.Audio('ash', 'mp3');
//      Params.Messages([
//        FromUser('Is a golden retriever a good family dog?')
//      ]);
//      Params.MaxCompletionTokens(1024)
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    DisplayAudio(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!NOTE]
>  The **Params.Audio('ash', 'mp3')** function allows you to select the output voice and specify the desired audio data format.
>
>  About **Params.Modalities(['text', 'audio'])**; modalities supported by gpt-4o-audio-preview**
>   - text in → text + audio out
>   - audio in → text + audio out
>   - audio in → text out
>   - text + audio in → text + audio out
>   - text + audio in → text out 

<br/>

Let’s take a closer look at how the `DisplayAudio` method handles output to understand how the model’s response is managed.

```Delphi
procedure DisplayAudio(Sender: TObject; Value: TChat);
begin
  {--- Display the JSON response }
  TutorialHub.JSONResponse := Value.JSONResponse;

  {--- We need an audio filename for the tutorial }
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');

  {--- Store the audio Id. }
  TutorialHub.AudioId := Value.Choices[0].Message.Audio.Id;

  {--- Store the audio transcript. }
  TutorialHub.Transcript := Value.Choices[0].Message.Audio.Transcript;

  {--- The audio response is stored in a file. }
  Value.Choices[0].Message.Audio.SaveToFile(TutorialHub.FileName);

  {--- Display the textual response. }
  Display(Sender, Value.Choices[0].Message.Audio.Transcript);

  {--- Play audio response. }
  TutorialHub.PlayAudio;
  Display(Sender, sLineBreak);
end;
```

`GenAI` provides methods to handle audio responses generated by the model. The `SaveToFile` and `GetStream` methods enable the manipulation of received audio content.

<br/>

## Input Audio for Chat

Refer to official [documentation](https://platform.openai.com/docs/guides/audio?example=audio-in).

### Audio and Text to Text

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  var Ref := 'https://cdn.openai.com/API/docs/audio/alloy.wav';

  //Asynchronous example
  Client.Chat.ASynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text']); 
      Params.Messages([
        FromUser('What is in this recording?', [Ref])
      ]);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display; 
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-audio-preview');
//      Params.Modalities(['text']);
//      Params.Messages([
//        FromUser('What is in this recording?', [Ref])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

### Audio to Audio

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;
  TutorialHub.FileName := 'Response.mp3';

  //Asynchronous example
  Client.Chat.ASynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('ash', 'mp3');
      Params.Messages([
        FromUser(['SpeechRecorded.mp3'])
      ]);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Chat.Create(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-audio-preview');
//      Params.Modalities(['text', 'audio']);
//      Params.Audio('ash', 'mp3');
//      Params.Messages([
//        FromUser(['SpeechRecorded.mp3'])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    DisplayAudio(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

>[!WARNING]
> OpenAI provides other models for simple speech to text and text to speech - when your task requires those conversions (and not dynamic content from a model), the `TTS` and `STT` models will be more performant and cost-efficient.

<br/>

### Audio multi-turn conversations

TutorialHub retains the ID of the most recent audio response. To proceed, simply construct the message as follows:

```Delphi
  ...
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('ash', 'mp3');
      Params.Messages([
        FromUser('Is a golden retriever a good family dog?'),
        FromAssistantAudioId(TutorialHub.AudioId),   //or FromAssistantAudioId(TutorialHub.Transcript),
        FromUser('Why do you say they are loyal?')
      ]);
  ...
```

The `message.audio.id` value above provides an identifier that you can use in an assistant message for a new `/chat/completions` request, as in the example above.

It is also possible to omit the audio ID and use the associated text via `Message.Audio.Transcript` instead. However, the model will not be able to analyze the emotions contained in the audio portion of the message.

>[!CAUTION]
>Of course, this is just a simple example. TutorialHub is designed solely to showcase `GenAI`. In a more general scenario, it would be necessary to maintain a history of **audio IDs** to accurately build the conversation history.

<br/>

## Vision

Refert to the [official documentation](https://platform.openai.com/docs/guides/vision).

### Analyze single source

`GenAI` processes images from both web sources and local files uniformly. It manages the submission of the source to the API, thereby simplifying the developer's task. Therefore, in this example, we will handle sources in the form of a ***URL*** and ***base-64 encoded*** data.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Url := 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg';
  //var Ref := 'D:\My_folder\Images\My_image.png'; //This content will be encoded in base-64 by GenAI
  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-mini');
      Params.Messages([
        FromUser('What is in this image?', [Url])
        //FromUser('What is in this image?', [Ref])
      ]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-mini');
//      Params.Messages([
//        FromUser('What is in this image?', [Url])
//        //FromUser('What is in this image?', [Ref])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Chat) and not IsDone then
//        DisplayStream(TutorialHub, Chat);
//    end);
```
This example uses streaming. The non-streamed version is straightforward to implement, so it is not covered here.

<br/>

### Analyze multi-source

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var Url1 := 'https://tripfixers.com/wp-content/uploads/2019/11/eiffel-tower-with-snow.jpeg';
  var Url2 := 'https://assets.visitorscoverage.com/production/wp-content/uploads/2024/04/AdobeStock_626542468-min-1024x683.jpeg';
  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-mini');
      Params.Messages([
        FromUser('What are the differences between two images?', [Url1, Url2])
      ]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);

  //Synchronous example
//  var Value := Client.Chat.CreateStream(
//    procedure (Params: TChatParams)
//    begin
//      Params.Model('gpt-4o-mini');
//      Params.Messages([
//        FromUser('What are the differences between two images?', [Url1, Url2])
//      ]);
//      Params.MaxCompletionTokens(1024);
//      Params.Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if Assigned(Chat) and not IsDone then
//        DisplayStream(TutorialHub, Chat);
//    end);
```

<br/>

### Low or high fidelity image understanding

The detail parameter, which includes three options—**low**, **high**, and **auto**—allows you to customize how the model interprets the image and generates its textual representation. By default, the **auto** setting is applied, where the model evaluates the input image size and automatically selects either the **low** or **high** mode.

- **low mode** activates "low resolution" processing, where the model works with a 512px x 512px version of the image, represented using 85 tokens. This option is ideal for applications where speed and efficiency are prioritized over high detail, as it reduces response time and token consumption.

- **high mode** activates "high resolution" processing. Initially, the model examines the low-resolution image using 85 tokens, then refines its understanding by analyzing detailed segments of the image, dedicating 170 tokens per 512px x 512px tile. This mode is suited for cases requiring precise image details.

`GenAI` allows the addition of `detail=high` or `detail=low` directly in the URL, thereby simplifying the activation of the detail option as follows:

```Delphi
  var Url1 := 'https://tripfixers.com/wp-content/uploads/2019/11/eiffel-tower-with-snow.jpeg detail=high';
  //or
  var Url1 := 'https://tripfixers.com/wp-content/uploads/2019/11/eiffel-tower-with-snow.jpeg detail=low';
```

The same process is applied to the local file paths.

<br/>

## Image generation

Refer to [official documentation](https://platform.openai.com/docs/guides/images).

Generation of an image using `DALL·E 3`.

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

<br/>

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

<br/>

![Preview](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/DallePreview.png?raw=true "Preview")

<br/>


>[!WARNING]
>**OpenAI** also offers the ability to edit and generate variations from an image using the `DALL-E 2` model. These features are integrated into `GenAI` and can be easily found in the `GenAI.Images.pas` unit. 
>
>However, no practical examples will be provided here. This is due to the fact that **OpenAI’s image-related models** are not regularly updated, and no official announcements regarding new models have been made. 
>
>If you have significant needs in this area, I recommend using the [`DelphiStability wrapper`](https://github.com/MaxiDonkey/DelphiStabilityAI), which provides far more extensive capabilities for creating and modifying images

<br/>

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
<br/>

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

<br/>

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

<br/>

## Reasoning with o1 or o3

**Advanced models for reasoning and problem-solving.**
Reasoning models, such as **OpenAI’s** `o1` and `o3-mini`, are large language models trained using reinforcement learning to handle complex reasoning tasks. These models “think” before generating a response by forming a detailed internal chain of reasoning. This approach allows them to excel in areas like advanced problem-solving, coding, scientific analysis, and multi-step planning within agent-driven workflows.

Similar to GPT models, they offer two options: a smaller, faster, and more cost-effective model (`o3-mini`) and a larger model (`o1`) that, while slower and more expensive per token, often produces higher-quality responses for challenging tasks and demonstrates stronger generalization across various domains.

Since these models can require response times ranging from a few seconds to several tens of seconds, it is more prudent and efficient to use asynchronous methods when using them.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('o3-mini');
      Params.Messages([
        FromUser('Write a bash script that takes a matrix represented as a string with format \"[1,2],[3,4],[5,6]\" and prints the transpose in the same format.')
      ]);
      Params.ReasoningEffort(TReasoningEffort.medium);
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
```

<br/>

The OpenAI `o1` and `o3` series models are highly capable across several advanced tasks, including:

- **Implementing complex algorithms and generating code:** For example, a prompt can instruct the o1 model to refactor a React component based on specific requirements.

- **Developing multi-step plans:** The models can create detailed plans, such as generating a complete filesystem structure and providing Python code that fulfills the given use case.

- **Supporting STEM research:** The models have demonstrated strong performance in scientific and technical research tasks, with prompts designed for basic research yielding highly effective results.

For more information, consult the [official documentation](https://platform.openai.com/docs/guides/reasoning).

<br/>

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

<br/>

## Moderation

The moderation endpoint is a valuable resource for detecting potentially harmful text or images. When harmful content is identified, developers can take appropriate measures, such as filtering the content or managing user accounts responsible for the violations. This service is provided free of charge.

Available models for the moderation endpoint include:

- **omni-moderation-latest:** The most advanced model, supporting a wider range of content categorization and multi-modal inputs (both text and images).

- **text-moderation-latest (Legacy):** An older model designed exclusively for text-based inputs with limited categorization options. For new projects, the omni-moderation model is recommended due to its superior capabilities and broader input support.

Refer to the [official documentation](https://platform.openai.com/docs/guides/moderation).

<br/>

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

<br/>

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
<br/>

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

<br/>

# Beyond the Basics Advanced Usage

## Function calling

Allow models to access data and execute actions. <br/>
Function calling offers a robust and versatile method for OpenAI models to interact with your code or external services, serving two main purposes:

- **Data Retrieval:** Access real-time information to enhance the model's responses (RAG). This is particularly beneficial for searching knowledge bases and extracting specific data from APIs (e.g., obtaining the current weather).

- **Action Execution:** Carry out tasks such as form submissions, API calls, updating the application state (UI/frontend or backend), or executing agent-driven workflows (e.g., transferring a conversation).

Refer to the [official documentation](https://platform.openai.com/docs/guides/function-calling?example=get-weather).

<br/>

**Use case : What’s the weather in Paris?**

In the `GenAI.Functions.Example` unit, there is a class that defines a function which OpenAI can choose to use or not, depending on the options provided. This class inherits from a parent class defined in the `GenAI.Functions.Core` unit. To create new functions, you can derive from the `TFunctionCore` class and define a new plugin.

In this unit, this schema will be used for function calls.
```Json
{
    "type": "object",
    "properties": {
         "location": {
             "type": "string",
             "description": "The city and department, e.g. Marseille, 13"
         },
         "unit": {
             "type": "string",
             "enum": ["celsius", "fahrenheit"]
         }
     },
     "required": ["location"],
     "additionalProperties": false
}
```

<br/>

1. We will use the TWeatherReportFunction plugin defined in the `GenAI.Functions.Example` unit.

```Delphi
  var Weather := TWeatherReportFunction.CreateInstance;
  //or
  var Weather := TWeatherReportFunction.CreateInstance(True);  //To activate `Strict` option

  //See step 3
```
<br/>

2. We then define a method to display the result of the query using the Weather tool.

With this tutorial, a method is defined within TutorialHub. Let’s take a closer look at how this method works.

- A. The first method display a stream text. 

```Delphi
procedure TVCLTutorialHub.DisplayWeatherStream(const Value: string);
begin
  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
          FromSystem('You are a weather presenter on a prime time TV channel.'),
          FromUser(Value)]);
      Params.MaxCompletionTokens(1024);
      Params.Stream;
    end,
    function : TAsynChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
end;
```

<br/>

- B. The second method use audio with response.

```Delphi
procedure TVCLTutorialHub.DisplayWeatherAudio(const Value: string);
begin
  FileName := 'AudioWeather.mp3';

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o-audio-preview');
      Params.Modalities(['text', 'audio']);
      Params.Audio('verse', 'mp3');
      Params.Messages([
        FromSystem('You are a weather presenter on a prime time TV channel.'),
        FromUser(Value)
      ]);
      Params.MaxCompletionTokens(1024);
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayAudio;
      Result.OnError := Display;
    end);
end;
```

<br/>

3. Building the query using the Weather tool. (Simply copy/paste this last code to test the usage of the functions.)

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL, GenAI.Functions.Example;

  TutorialHub.JSONRequestClear;
  var Weather := TWeatherReportFunction.CreateInstance(True);
//  TutorialHub.ToolCall := TutorialHub.DisplayWeatherStream;
// or
  TutorialHub.ToolCall := TutorialHub.DisplayWeatherAudio;
  TutorialHub.Tool := Weather;

  //Synchronous example
  var Value := Client.Chat.Create(
    procedure (Params: TChatParams)
    begin
      Params.Model('gpt-4o');
      Params.Messages([
        FromUser('What is the weather in Paris?')
      ]);
      Params.Tools([Weather]);
      Params.ToolChoice(TToolChoice.auto);
      Params.MaxCompletionTokens(1024);
      TutorialHub.JSONRequest := Params.ToFormat();
    end);
  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
```

Let's look at how the display method handles the function call.

```Delphi
procedure Display(Sender: TObject; Value: TChat);
begin
  TutorialHub.JSONResponse := Value.JSONResponse;
  for var Item in Value.Choices do
    {--- Examine FinishReason }
    if Item.FinishReason = TFinishReason.tool_calls then
      begin
        if Assigned(TutorialHub.ToolCall) then
          begin
            for var Func in Item.Message.ToolCalls do
              begin
                Display(Sender, Func.&function.Arguments);
                var Evaluation := TutorialHub.Tool.Execute(Func.&function.Arguments);
                Display(Sender, Evaluation);
                Display(Sender);
                TutorialHub.ToolCall(Evaluation);
              end;
          end;
      end
    else
      begin
        Display(Sender, Item.Message.Content);
      end;
  Display(Sender, sLineBreak);
end;
```

<br/>

>[!WARNING]
>Ensure user confirmation for actions like sending emails or making purchases to avoid unintended consequences.

<br/>

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

## Uploads

Allows you to upload large files in multiple parts.

<br/>

### Upload create

An intermediate [Upload](https://platform.openai.com/docs/api-reference/uploads/object) object is created, allowing you to attach multiple [parts](https://platform.openai.com/docs/api-reference/uploads/part-object). The maximum size for an Upload is 8 GB, and it will automatically expire one hour after creation.

Once the Upload is finalized, a [File](https://platform.openai.com/docs/api-reference/files/object) object is generated, incorporating all the uploaded parts. This File object can then be used seamlessly across our platform, functioning like any regular file.

For certain `purposes`, specifying the correct `mime_type` is essential. Be sure to consult the documentation to identify the supported MIME types that suit your use case.

Guidance for [Assistants](https://platform.openai.com/docs/assistants/tools/file-search#supported-files):
For details on selecting the appropriate file extensions for different scenarios, refer to the documentation on [File creation](https://platform.openai.com/docs/api-reference/files/create).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Uploads.AsynCreate(
    procedure (Params: TUploadCreateParams)
    begin
      Params.Purpose('fine-tune');
      Params.Filename('BatchExample.jsonl');
      Params.bytes(FileSize('BatchExample.jsonl'));
      Params.MimeType('text/jsonl');
    end,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Uploads.Create(
//    procedure (Params: TUploadCreateParams)
//    begin
//      Params.Purpose('fine-tune');
//      Params.Filename('BatchExample.jsonl');
//      Params.bytes(FileSize('BatchExample.jsonl'));
//      Params.MimeType('text/jsonl');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Upload cancel

Cancels the Upload. No Parts may be added after an Upload is cancelled.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynCancel(TutorialHub.Id,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Uploads.Cancel(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Upload add part

Adds a [Part](https://platform.openai.com/docs/api-reference/uploads/part-object) to an [Upload](https://platform.openai.com/docs/api-reference/uploads/object) object. A Part represents a chunk of bytes from the file you are trying to upload.

Each Part can be at most 64 MB, and you can add Parts until you hit the Upload maximum of 8 GB.

It is possible to add multiple Parts in parallel. You can decide the intended order of the Parts when you [complete the Upload](https://platform.openai.com/docs/api-reference/uploads/complete).

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynAddPart(TutorialHub.Id,
    procedure (Params: TUploadPartParams)
    begin
      Params.Data('BatchExample.jsonl');
    end,
    function : TAsynUploadPart
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Asynchronous example
//  var Value := Client.Uploads.AddPart(TutorialHub.Id,
//    procedure (Params: TUploadPartParams)
//    begin
//      Params.Data('BatchExample.jsonl');
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Upload complete

Completes the [Upload](https://platform.openai.com/docs/api-reference/uploads/object).

Within the returned Upload object, there is a nested [File](https://platform.openai.com/docs/api-reference/files/object) object that is ready to use in the rest of the platform.

You can specify the order of the Parts by passing in an ordered list of the Part IDs.

The number of bytes uploaded upon completion must match the number of bytes initially specified when creating the Upload object. No Parts may be added after an Upload is completed.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := 'upload_679207849ec8819086bc0e54f5c66d62';

  //Asynchronous example
  Client.Uploads.AsynComplete(TutorialHub.Id,
    procedure (Params: TUploadCompleteParams)
    begin
      Params.PartIds(['BatchExample.jsonl'])
    end,
    function : TAsynUpload
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Asynchronous example
//  var Value := Client.Uploads.Complete(TutorialHub.Id,
//    procedure (Params: TUploadCompleteParams)
//    begin
//      Params.PartIds(['BatchExample.jsonl'])
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

## Batch

Create large batches of API requests for asynchronous processing. The Batch API returns completions within 24 hours for a 50% discount. Related guide: [Batch](https://platform.openai.com/docs/guides/batch)

<br/>

### Batch create

Creates and executes a batch from an uploaded file of requests.

For our example, the contents of the batch JSONL file are as follows :

BatchExample.jsonl
```JSON
{"custom_id": "request-1", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-4o-mini", "messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "What is 2+2?"}]}}
{"custom_id": "request-2", "method": "POST", "url": "/v1/chat/completions", "body": {"model": "gpt-4o-mini", "messages": [{"role": "system", "content": "You are a helpful assistant."}, {"role": "user", "content": "What is the topology definition?"}]}}
```

Use the [File upload](#File-upload) method and get the ID referring to the JSONL file.

<br/>

Now create the batch as follow :

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...id of BatchExample.jsonl...';

 {--- If needed, then create metadata }
  var MetaData := TJSONObject.Create
    .AddPair('customer_id', 'user_123456789')
    .AddPair('batch_description', 'Nightly eval job');

  //Asynchronous example
  Client.Batch.AsynCreate(
    procedure (Params: TBatchCreateParams)
    begin
      Params.InputFileId(TutorialHub.Id);
      Params.Endpoint('/v1/chat/completions');
      Params.CompletionWindow('24h');
      Params.Metadata(MetaData);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);


  //Synchronous example
//  var Value := Client.Batch.Create(
//    procedure (Params: TBatchCreateParams)
//    begin
//      Params.InputFileId(TutorialHub.Id);
//      Params.Endpoint('/v1/chat/completions');
//      Params.CompletionWindow('24h');
//      Params.Metadata(MetaData);
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!TIP]
> `GenAI` provides, through the `IBatchJSONBuilder` interface (available in the `GenAI.Batch.Interfaces` unit and implemented in the `GenAI.Batch.Builder` unit), powerful tools to easily build batch files from collected data. For further details, refer to the two units mentioned above.


<br/>

### Batch List

List your organization's batches.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Batch.AsynList(
    procedure (Params: TUrlPaginationParams)
    begin
      Params.Limit(4);
    end,
    function : TAsynBatches
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.List(
//    procedure (Params: TUrlPaginationParams)
//    begin
//      Params.Limit(4);
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

With out request parameters

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Batch.AsynList(
    function : TAsynBatches
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

Refer to [parameters documentation](https://platform.openai.com/docs/api-reference/batch/list).

<br/>

### Batch retrieve

Retrieves a batch using its ID.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of batch to retrieve...';

  //Asynchronous example
  Client.Batch.AsynRetrieve(TutorialHub.Id,
    function : TAsynBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.Retrieve(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Batch cancel

Cancels an in-progress batch. The batch will be in status `cancelling` for up to 10 minutes, before changing to `cancelled`, where it will have partial results (if any) available in the output file.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of batch to cancel...';

  //Asynchronous example
  Client.Batch.AsynCancel(TutorialHub.Id,
    function : TAsynBatch
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);

  //Synchronous example
//  var Value := Client.Batch.Cancel(TutorialHub.Id);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br/>

### Batch output viewer

Open and view the results obtained after processing the batch.

```Delphi
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.Id := '...Id of batch...';
  var Output := EmptyStr;

  var Value := Client.Files.RetrieveContent(TutorialHub.Id);
  try
    Output := Value.Content;
  finally
    Value.Free;
  end;

  for var Item in JSONLChatReader.Deserialize(Output) do
    try
      Display(TutorialHub, Item.Response.Body);
    finally
      Item.Free;
    end;
```

>[!TIP]
> `GenAI` provides, through the `IJSONLReader` interface (available in the `GenAI.Batch.Interfaces` unit and implemented in the `GenAI.Batch.Reader` unit), powerful tools to easily read batch files content. For further details, refer to the two units mentioned above.

<br/>

## Fine tuning

Handle fine-tuning tasks to customize a model according to your specific training dataset. Relevant guide: [Model fine-tuning](https://platform.openai.com/docs/guides/fine-tuning).

After determining that fine-tuning is the appropriate approach (meaning you’ve already optimized your prompt to its full potential and identified remaining issues with the model), the next step is to prepare the training data. You’ll need to create a varied collection of sample conversations that resemble the types of interactions the model will handle during inference in production.

<br/>

### Fine tuning create

#### 1. Preparing your dataset

Each data sample should follow the format used by the ***Chat Completions API***, consisting of a list of messages where each message includes a role, content, and an optional name. Some of these training examples should specifically address situations where the current model's responses are inadequate, with the assistant messages in the dataset reflecting the ideal outcomes you want the model to generate.

Example format

```JSON
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "What's the capital of France?"}, {"role": "assistant", "content": "Paris, as if everyone doesn't know that already."}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "Who wrote 'Romeo and Juliet'?"}, {"role": "assistant", "content": "Oh, just some guy named William Shakespeare. Ever heard of him?"}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "How far is the Moon from Earth?"}, {"role": "assistant", "content": "Around 384,400 kilometers. Give or take a few, like that really matters."}]}
```

Multi-turn chat examples

```JSON
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "What's the capital of France?"}, {"role": "assistant", "content": "Paris", "weight": 0}, {"role": "user", "content": "Can you be more sarcastic?"}, {"role": "assistant", "content": "Paris, as if everyone doesn't know that already.", "weight": 1}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "Who wrote 'Romeo and Juliet'?"}, {"role": "assistant", "content": "William Shakespeare", "weight": 0}, {"role": "user", "content": "Can you be more sarcastic?"}, {"role": "assistant", "content": "Oh, just some guy named William Shakespeare. Ever heard of him?", "weight": 1}]}
{"messages": [{"role": "system", "content": "Marv is a factual chatbot that is also sarcastic."}, {"role": "user", "content": "How far is the Moon from Earth?"}, {"role": "assistant", "content": "384,400 kilometers", "weight": 0}, {"role": "user", "content": "Can you be more sarcastic?"}, {"role": "assistant", "content": "Around 384,400 kilometers. Give or take a few, like that really matters.", "weight": 1}]}
```

To fine-tune a model, you need to provide at least 10 examples. Generally, noticeable improvements can be observed with fine-tuning using 50 to 100 training examples, especially with gpt-4o-mini and gpt-3.5-turbo. However, the appropriate number of examples can vary significantly depending on the specific use case.

<br/>

#### 2. Upload dataset







<br/>

### Fine tuning list

<br/>

### Fine tuning cancel

<br/>

### Fine tuning events

<br/>

### Fine tuning check point

<br/>

### Fine tuning retrieve

<br/>

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.