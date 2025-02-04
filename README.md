# GenAI for OpenAI

___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20on%20february%2004,%202025-blue)

<br/>
<br/>

- [Introduction](#Introduction)
- [TIPS for using the tutorial effectively](#TIPS-for-using-the-tutorial-effectively)
    - [Obtain an api key](#Obtain-an-api-key)
    - [Strategies for quickly using the code examples](#Strategies-for-quickly-using-the-code-examples)
- [Quick Start Guide](#Quick-Start-Guide)
    - [Text generation](#Text-generation)
        - [Non streamed](#Non-streamed) 
        - [Streamed](#Streamed)
        - [Multi-turn conversation](#Multi-turn-conversation) 
    - [Generating Audio Responses with Chat](#Generating-Audio-Responses-with-Chat)
    - [Input Audio for Chat](#Input-Audio-for-Chat)
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

### Multi-turn conversation

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

For example, the `GPT-4o-Audio-Preview` model can process audio both as input and output.

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
//    end);
//  try
//    DisplayAudio(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[:NOTE]
>- The Params.Audio('ash', 'mp3') function allows you to select the output voice and specify the desired audio data format.
>
>- **What modalities are supported by gpt-4o-audio-preview**
>   - text in → text + audio out
>    - audio in → text + audio out
>    - audio in → text out
>    - text + audio in → text + audio out
>    - text + audio in → text out 

<br/>

Let’s take a closer look at how the `DisplayAudio` method handles output to understand how the model’s response is managed.

```Delphi
procedure DisplayAudio(Sender: TObject; Value: TChat);
begin
  {--- Display the JSON response. }
  TutorialHub.JSONResponse := Value.JSONResponse;

  {--- We need an audio filename for the tutorial. }
  if TutorialHub.FileName.IsEmpty then
    raise Exception.Create('Set filename value in HFTutorial instance');

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

**What modalities are supported by gpt-4o-audio-preview** <br/>

- The `gpt-4o-audio-preview` model requires either audio output or audio input to be used at this time. Acceptable combinations of input and output are:

    - text in → text + audio out
    - audio in → text + audio out
    - audio in → text out
    - text + audio in → text + audio out
    - text + audio in → text out

Refer to official [documentation](https://platform.openai.com/docs/guides/audio?example=audio-in).

<br/>

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.