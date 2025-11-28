# Delphi GenAI - Optimized OpenAI Integration

___
![Delphi async/await supported](https://img.shields.io/badge/Delphi%20async%2Fawait-supported-blue)
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.4/11/12-ffffba)
[![GetIt – Available](https://img.shields.io/badge/GetIt-Available-baffc9?logo=delphi&logoColor=white)](https://getitnow.embarcadero.com/genai-optimized-openai-integration-wrapper/)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-baffc9)
![GitHub](https://img.shields.io/badge/Updated%20on%20November%2028,%202025-blue)

<br>

#### NEW: 
- GetIt current version: 1.3.0
- [Changelog v1.4](Changelog.md)
- [Local model support via LM Studio (OpenAI-compatible server)](guides/LMStudio.md#run-models-locally-with-lm-studio)
- [Deep Research](guides/DeepResearch.md#deep-research)
- [Videos using SORA](guides/Videos.md#videos)
- [Realtime](guides/Realtime.md#realtime)
___

<br>

- [Introduction](#introduction)
- [Documentation Overview](#documentation-overview)
- [Tips for using the tutorial effectively](#tips-for-using-the-tutorial-effectively)
    - [Obtain an API Key](#obtain-an-api-key)
    - [Code examples](#code-examples)
    - [Strategies for quickly using the code examples](#strategies-for-quickly-using-the-code-examples)
    - [Use file2knowledge](#use-file2knowledge)
- [Local model support via LM Studio](guides/LMStudio.md#run-models-locally-with-lm-studio)
- [GenAI functional coverage](#genai-functional-coverage)
- [Quick Start Guide](#quick-start-guide)
    - [Responses vs. Chat Completions](#responses-vs-chat-completions)
        - [Functional differences between the two endpoints](#functional-differences-between-the-two-endpoints)
        - [Chat completion](#chat-completion)
        - [Responses](#responses)            
- [Tips and tricks](#tips-and-tricks)
    - [How to prevent an error when closing an application while requests are still in progress?](#how-to-prevent-an-error-when-closing-an-application-while-requests-are-still-in-progress)
    - [How to execute multiple background requests to process a batch of responses?](#how-to-execute-multiple-background-requests-to-process-a-batch-of-responses)
    - [How to structure a chain of thought and develop advanced processing with GenAI?](#how-to-structure-a-chain-of-thought-and-develop-advanced-processing-with-genai)
    - [How do you structure advanced reasoning using Promises and pipelines?](#how-do-you-structure-advanced-reasoning-using-promises-and-pipelines)
    - [How to implement Deep Research?](#how-to-implement-deep-research-)
- [Deprecated](#deprecated)
- [Contributing](#contributing)
- [License](#license)

___

<br>

# Introduction

> **Built with Delphi 12 Community Edition** (v12.1 Patch 1)  
>The wrapper itself is MIT-licensed.  
>You can compile and test it **free of charge with Delphi CE**; any recent commercial Delphi edition works as well.

**DelphiGenAI** is a full OpenAI wrapper for Delphi, covering the entire platform: text, vision, audio, image generation, video (Sora-2), embeddings, conversations, containers, and the latest `v1/responses` agentic workflows. It offers a unified interface with sync/async/await support across major Delphi platforms, making it easy to leverage modern multimodal and tool-based AI capabilities in Delphi applications.

<br>

> [!IMPORTANT]
>
> This is an unofficial library. **OpenAI** does not provide any official library for `Delphi`.
> This repository contains `Delphi` implementation over [OpenAI](https://openai.com/) public API.

<br>

___

# Documentation Overview

Comprehensive Project Documentation Reference

- [Changelog](Changelog.md)
- [About this project](guides/GenAI.md#about-this-project)
- Detailed documentation with synchronous and asynchronous examples is located in the [guides folder](guides).

<br>

___

# Tips for using the tutorial effectively

## Obtain an API Key

To initialize the API instance, you need to obtain an [API key from OpenAI](https://platform.openai.com/settings/organization/api-keys)

Once you have a token, you can initialize IGenAI interface, which is an entry point to the API.

>[!NOTE]
>```pascal
>//uses GenAI, GenAI.Types;
>
>//Declare 
>//  Client: IGenAI;
>
>  // Cloud clients
>  Client := TGenAIFactory.CreateInstance(api_key);
>
>
>  // Local client (LM Studio – OpenAI compatible server)
>  Client := TGenAIFactory.CreateLMSInstance; // default: http://127.0.0.1:1234/v1
>
>  // or
>  //Client := TGenAIFactory.CreateLMSInstance('http://192.168.1.10:1234');
> ```

To streamline the use of the API wrapper, the process for declaring units has been simplified. Regardless of which methods you use, you only need to reference the following two core units:
`GenAI` and `GenAI.Types`.

<br>

>[!TIP]
> To effectively use the examples in this tutorial, particularly when working with asynchronous methods, it is recommended to define the client interfaces with the broadest possible scope. For optimal implementation, these clients should be declared in the application's `OnCreate` method.
>

<br>

## Code examples

The **OpenAI API** lets you plug advanced models into your applications and production workflows in just a few lines of code. Once billing is enabled on your account, your API keys become active and you can start making requests — including your first call to the chat endpoint within seconds.

- [Synchronous code example](#synchronous-code-example)
- [Asynchronous code example](#asynchronous-code-example)

<br>

### Synchronous code example

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  var API_Key := 'OPENAI_API_KEY';
  var Client := TGenAIFactory.CreateInstance(API_KEY);

  var Value := Client.Responses.Create(
    procedure (Params: TResponsesParams)
    begin
      Params
        .Model('gpt-4.1-mini')
        .Input('What is the difference between a mathematician and a physicist?')
        .Store(False);  // Response not stored
    end);
  try
    for var Item in Value.Output do
      for var SubItem in Item.Content do
        Memo1.Text := SubItem.Text;
  finally
    Value.Free;
  end;
```

<br>

### Asynchronous code example

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

var Client: IGenAI;

procedure TForm1.Test;
begin
  var API_Key := 'OPENAI_API_KEY';
  Client := TGenAIFactory.CreateInstance(API_KEY);

  Client.Responses.AsynCreate(
    procedure (Params: TResponsesParams)
    begin
      Params
        .Model('gpt-4.1-mini')
        .Input('What is the difference between a mathematician and a physicist?')
        .Store(False);  // Response not stored
    end,
    function : TAsynResponse
    begin
      Result.OnStart :=
        procedure (Sender: TObject)
        begin
          Memo1.Lines.Text := 'Please wait...';
        end;

      Result.OnSuccess :=
        procedure (Sender: TObject; Value: TResponse)
        begin
          for var Item in Value.Output do
            for var SubItem in Item.Content do
              Memo1.Text := SubItem.Text;
        end;

      Result.OnError :=
        procedure (Sender: TObject; Error: string)
        begin
          Memo1.Lines.Text := Error;
        end;
    end);
end;
```

<br>

## Strategies for quickly using the code examples

To streamline the implementation of the code examples provided in this tutorial, two support units have been included in the source code: `GenAI.Tutorial.VCL` and `GenAI.Tutorial.FMX` Based on the platform selected for testing the provided examples, you will need to initialize either the `TVCLTutorialHub` or `TFMXTutorialHub` class within the application's OnCreate event, as illustrated below:

>[!IMPORTANT]
>In this repository, you will find in the [`sample`](https://github.com/MaxiDonkey/DelphiGenAI/tree/main/sample) folder two ***ZIP archives***, each containing a template to easily test all the code examples provided in this tutorial. 
>Extract the `VCL` or `FMX` version depending on your target platform for testing. 
>Next, add the path to the DelphiGenAI library in your project’s options, then copy and paste the code examples for immediate execution. 
>
>These two archives are designed to fully leverage the TutorialHub middleware and enable rapid upskilling with DelphiGenAI.

- [**`VCL`**](https://github.com/MaxiDonkey/DelphiGenAI/tree/main/sample) support with TutorialHUB: ***TestGenAI_VCL.zip***

- [**`FMX`**](https://github.com/MaxiDonkey/DelphiGenAI/tree/main/sample) support with TutorialHUB: ***TestGenAI_FMX.zip***

<br>

## [Use file2knowledge](https://github.com/MaxiDonkey/file2knowledge)

This [project](https://github.com/MaxiDonkey/file2knowledge/blob/main/README.md), built with `DelphiGenAI` , allows you to consult GenAI documentation and code in order to streamline and accelerate your upskilling.

<p align="center">
  <img src="https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/File2knowledge.png?raw=true" width="700"/>
</p>

<br>

___

# GenAI functional coverage

Below, the table succinctly summarizes all OpenAI endpoints supported by the GenAI.

|End point | supported | status / notes|
|--- |:---: |:---: | 
| [/assistants](guides/Deprecated.md#assistants) | <div align="center"><span style="color: green;">●</span></div> | ![deprecated](https://img.shields.io/badge/DEPRECATED-orange) |
| [/audio/speech](guides/Audio.md#text-to-speech) | <div align="center"><span style="color: green;">●</span></div> | |
| [/audio/transcriptions](guides/Audio.md#speech-to-text) | <div align="center"><span style="color: green;">●</span></div> | |
| [/audio/translations](guides/Audio.md#speech-to-text) | <div align="center"><span style="color: green;">●</span></div> | |
| [/batches](guides/Batch.md#batch) | <div align="center"><span style="color: green;">●</span></div> | |
| [/chat/completions](guides/ChatCompletion.md#chat-completion) | <div align="center"><span style="color: green;">●</span></div> | |
| /chatkit |  | |
| [/completions](guides/Legacy.md#legacy) | <div align="center"><span style="color: green;">●</span></div> | ![legacy](https://img.shields.io/badge/LEGACY-fuchsia) |
| [/containers](guides/Containers.md#containers-managment) | <div align="center"><span style="color: green;">●</span></div> | ![new](https://img.shields.io/badge/NEW-006400?style=flat) |
| [/conversations](guides/Conversations.md#conversations) | <div align="center"><span style="color: green;">●</span></div> | ![new](https://img.shields.io/badge/NEW-006400?style=flat) |
| [/embeddings](guides/Embeddings.md#embeddings) | <div align="center"><span style="color: green;">●</span></div> | |
| /evals |  | |
| [/files](guides/Files.md#files) | <div align="center"><span style="color: green;">●</span></div> | |
| [/fine_tuning](guides/FineTuning.md#fine-tuning) | <div align="center"><span style="color: green;">●</span></div> | |
| [/images](guides/Images.md#image-generation) | <div align="center"><span style="color: green;">●</span></div> | |
| [/models](guides/Models.md#models) | <div align="center"><span style="color: green;">●</span></div> | |
| [/moderations](guides/Moderation.md#moderation) | <div align="center"><span style="color: green;">●</span></div> | |
| /organization |  | |
| [/realtime](guides/Realtime.md#realtime) | <div align="center"><span style="color: green;">●</span></div> | ![new](https://img.shields.io/badge/NEW-006400?style=flat) |
| [/responses](guides/Responses.md#responses) | <div align="center"><span style="color: green;">●</span></div> | ![updated](https://img.shields.io/badge/UPDATED-003399?style=flat) |
| [/threads](guides/Deprecated.md#threads) | <div align="center"><span style="color: green;">●</span></div> | ![deprecated](https://img.shields.io/badge/DEPRECATED-orange) |
| [/uploads](guides/Uploads.md#uploads) | <div align="center"><span style="color: green;">●</span></div> | |
| [/vector_stores](guides/VectorStore.md#vector-store-managment) | <div align="center"><span style="color: green;">●</span></div> | |
| [/videos](guides/Videos.md#videos) | <div align="center"><span style="color: green;">●</span></div> | ![new](https://img.shields.io/badge/NEW-006400?style=flat) |

<br>

___

# Quick Start Guide

## Responses vs. Chat Completions

The `v1/responses` API is the new core API, designed as an agentic primitive that combines the simplicity of chat completions with the power of action execution. It natively includes several built‑in tools:
- Web search
- File search
- Computer control
- Image generation
- Remote MCP
- Code interpreter

With these integrated capabilities, you can build more autonomous, agent‑oriented applications that not only generate text but also interact with their environment.

The `v1/responses` endpoint is intended to gradually replace `v1/chat/completions`, as it embodies a synthesis of current best practices in AI—especially for those looking to adopt an agentic approach.

To help you get up to speed on both endpoints, the two following documents provide detailed documentation, complete with numerous request examples and use cases:
- [v1/chat/completion](guides/ChatCompletion.md#chat-completion)
- [v1/responses](guides/Responses.md#responses)

>[!NOTE]
>If you're a new user, we recommend using the Responses API.

<br>

### Functional differences between the two endpoints

|Capabilities | [Chat Completions API](guides/ChatCompletion.md#chat-completion) | [Responses API](guides/Responses.md#responses) |
|--- |:---: | :---: |
|Text generation | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Audio  | <div align="center"><span style="color: green;">●</span></div> | Coming soon | 
| Vision | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Structured Outputs | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Function calling | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| Web search | <div align="center"><span style="color: green;">●</span></div> | <div align="center"><span style="color: green;">●</span></div> |
| File search |  | <div align="center"><span style="color: green;">●</span></div> |
| Computer use |  | <div align="center"><span style="color: green;">●</span></div> |
| Code interpreter |  | <div align="center"><span style="color: green;">●</span></div> |
| Image generation | | <div align="center"><span style="color: green;">●</span></div> |
| Remote MCP | | <div align="center"><span style="color: green;">●</span></div> |
| Reasoning summaries | | <div align="center"><span style="color: green;">●</span></div> |


>[!WARNING]
> [Note from OpenAI](https://platform.openai.com/docs/guides/responses-vs-chat-completions#the-chat-completions-api-is-not-going-away) <br>
> The Chat Completions API is an industry standard for building AI applications, and we intend to continue supporting this API indefinitely. We're introducing the Responses API to simplify workflows involving tool use, code execution, and state management. We believe this new API primitive will allow us to more effectively enhance the OpenAI platform into the future.

<br>

### [Chat completion](guides/ChatCompletion.md#chat-completion)

Check out the full [documentation](guides/ChatCompletion.md#chat-completion)

Text generation (Non streamed, Streamed, Multi-turn conversations), Generating Audio Responses with Chat (Audio and Text to Text, Audio to Audio, Audio multi-turn conversations), Vision (Analyze single source, Analyze multi-source, Low or high fidelity image understanding), Reasoning with o1, o3 or o4,  Web search...

<br>

### [Responses](guides/Responses.md#responses)

Check out the full [documentation](guides/Responses.md#responses)

Text generation (Non streamed, Streamed, Multi-turn conversations), Vision (Analyze single source, Analyze multi-source, Low or high fidelity image understanding), Reasoning with o1, o3 or o4, Web search, File search...

<br>

___

# Tips and tricks

- #### How to prevent an error when closing an application while requests are still in progress?

Starting from version ***1.0.1 of GenAI***, the `GenAI.Monitoring` unit is **responsible for monitoring ongoing HTTP requests.**

The `Monitoring` interface is accessible by including the `GenAI.Monitoring` unit in the `uses` clause. 
Alternatively, you can access it via the `HttpMonitoring` function, declared in the `GenAI` unit.

**Usage Example**

```pascal
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

```pascal
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

#### How to implement Deep Research ?

This document details the implementation of the **Deep Research** function as integrated within the **File2Knowledge** project; a demonstration application designed to showcase the use of the **DelphiGenAI** wrapper.

Although *File2Knowledge* is built using the **VCL** framework, all concepts and code components described here are **fully transferable to FMX**.  
The project was designed with a strict **separation of concerns** between the user interface, application logic, and the OpenAI integration layer.  
This ensures that the asynchronous execution workflow of **Deep Research** remains independent of the visual framework.

Accordingly, this documentation should be regarded as a **best-practice reference** for implementing OpenAI’s *Deep Research* feature within modern Delphi applications.

For additional information:
- [Internal documentation](guides/DeepResearch.md#deep-research)
- [Official OpenAI documentation](https://platform.openai.com/docs/guides/deep-research)
- [*File2Knowledge* project repository](https://github.com/MaxiDonkey/file2knowledge) 

<br>

___

# Deprecated

## Deprecation of the OpenAI Assistants API

OpenAI announced the deprecation of the Assistants API on **August 26, 2025**, with permanent removal scheduled for **August 26, 2026**.
This API is being replaced by the new ***Responses API*** and ***Conversations API***, launched in March 2025, which integrate and simplify all functionality previously provided by the Assistants API.

To ensure future compatibility, it is strongly recommended to migrate your integrations to the Responses and Conversations APIs as soon as possible.
See the [Assistants-to-Conversations migration guide](https://platform.openai.com/docs/assistants/migration) for more details.

Affected units:
`GenAI.Messages.pas`, `GenAI.Threads.pas`, `GenAI.Run.pas`, `GenAI.RunSteps.pas`

<br>

___

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

<br>

___

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.

<br>
