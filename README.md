# Delphi GenAI - Optimized OpenAI Integration

___
![Delphi async/await supported](https://img.shields.io/badge/Delphi%20async%2Fawait-supported-blue)
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.4/11/12-ffffba)
[![GetIt – Available](https://img.shields.io/badge/GetIt-Available-baffc9?logo=delphi&logoColor=white)](https://getitnow.embarcadero.com/genai-optimized-openai-integration-wrapper/)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-baffc9)
[![LS Studio supported](https://img.shields.io/badge/LM%20Studio-supported-blue)](https://lmstudio.ai/)

___

### New
- GetIt current version: 1.4.0
- [Changelog v2.0.0](Changelog.md#2026-june-9-version-200)
- [Functional Demo (Pythia UI)](#functional-demo)
- [Responses Helper](guides/ResponseHelper.md#response-helpers-genaihelpers)
- [Skills](guides/Skills.md#skills)
- [Run models locally with LM Studio](guides/LMStudio.md#run-models-locally-with-lm-studio)
- [Provider Support and OpenAI API Compatibility](guides/Provider-Support-and-OpenAI-API.md)

___

## Two quick examples

>[!TIP]
>To obtain an API key, see https://platform.openai.com/settings/organization/api-keys

<br>

- Non-streamed example:

  ```pascal
  //uses GenAI, GenAI.Types;

    var API_Key := 'OPENAI_API_KEY';
    Client := TGenAIFactory.CreateInstance(API_KEY);

    //JSON payload
    var Payload: TResponsesParamsProc :=
      procedure(Params: TResponsesParams)
      begin
        Params
          .Model('gpt-5.5')
          .Input('What is the difference between a mathematician and a physicist?')
          .Store(False);  // Response not stored
      end;

    //Synchronous example
    var Value := Client.Responses.Create(Payload);

    try
      for var Item in Value.Output do
        for var SubItem in Item.Content do
          Memo1.Lines.Text := SubItem.Text;
    finally
      Value.Free;
    end;
  ```

<br>

- Streamed example (SSE):

  ```pascal
  //uses GenAI, GenAI.Types;

  var Client: IGenAI;
  var API_Key := 'OPENAI_API_KEY';
  Client := TGenAIFactory.CreateInstance(API_KEY);

  procedure TForm1.Test;
  begin
    //JSON payload
    var Payload: TResponsesParamsProc :=
      procedure(Params: TResponsesParams)
      begin
        Params
          .Model('gpt-5.5')
          .Input('What is the difference between a mathematician and a physicist?')
          .Stream
          .Store(False);  // Response not stored
      end;

    //Streamed callback
    var CallBack: TResponseEvent :=
      procedure(var Value: TResponseStream; IsDone: Boolean; var Cancel: Boolean)
      begin
        if not Assigned(Value) or IsDone then
          Exit;

        if Value.&Type = TResponseStreamType.output_text_delta then
          begin
            Memo1.Lines.Text := Memo1.Lines.Text + Value.Delta;
            Application.ProcessMessages;
          end;
      end;

    //Synchronous streamed example
    Client.Responses.CreateStream(Payload, CallBack);
  end;
  ```

<br>

You only ever need to reference two core units — `GenAI` and `GenAI.Types` — whatever method you use. The same client can target OpenAI, a local LM Studio server, or Google Gemini:

>[!NOTE]
>```pascal
>//uses GenAI, GenAI.Types;
>//  Client: IGenAI;
>
>  // OpenAI
>  Client := TGenAIFactory.CreateInstance(openAI_api_key);
>
>  // Local model (LM Studio – OpenAI-compatible server)
>  Client := TGenAIFactory.CreateLMSInstance; // default: http://127.0.0.1:1234/v1
>
>  // Google Gemini (OpenAI-compatible surface)
>  Client := TGenAIFactory.CreateGeminiInstance(gemini_api_key);
>```

<br>

___

Summary
- [Introduction](#introduction)
- [Philosophy and Scope](#philosophy-and-scope)
- [Documentation](#documentation)
- [Responses vs. Chat Completions](#responses-vs-chat-completions)
- [Functional Demo](#functional-demo)
- [Functional coverage](#functional-coverage)
- [Tips and tricks](#tips-and-tricks)
- [Removed in 2.0.0](#removed-in-200)
- [Contributing](#contributing)
- [License](#license)

___

<br>

## Introduction

> **Built with Delphi 12 Community Edition** (v12.1 Patch 1)
>The wrapper itself is MIT-licensed.
>You can compile and test it **free of charge with Delphi CE**; any recent commercial Delphi edition works as well.

<br>

**DelphiGenAI** is a full OpenAI wrapper for Delphi, covering the entire platform: text, vision, audio, image generation, embeddings, conversations, containers, and the latest `v1/responses` agentic workflows. It offers a unified interface with sync/async/await support across major Delphi platforms, making it easy to leverage modern multimodal and tool-based AI capabilities in Delphi applications.

<br>

> [!IMPORTANT]
>
> This is an unofficial library. **OpenAI** does not provide any official library for `Delphi`.
> This repository contains a `Delphi` implementation over the [OpenAI](https://openai.com/) public API.

<br>

>[!TIP]
> When working with asynchronous methods, declare the `IGenAI` client with the broadest possible scope — ideally in the application's `OnCreate`.

<br>

___

## Philosophy and Scope

OpenAI exposes two complementary text surfaces:
- the **Chat Completions API** (`v1/chat/completions`) — the established, single-call chat interface;
- the **Responses API** (`v1/responses`) — the new agentic primitive that adds built-in tools and state management on top of the same idea, and is intended to gradually replace Chat Completions.

Around them sits the rest of the platform: audio, images, embeddings, files, vector stores, batch, fine-tuning, moderation, containers, skills, conversations and realtime.

DelphiGenAI is, by design, a **strict one-to-one mapping of the OpenAI API**: it does not introduce provider-specific extensions, fallbacks or behavioral adaptations on top of the vendor surface. Its goals are:
- **faithful mapping** of every supported endpoint and parameter;
- **Delphi-first ergonomics** (fluent builders, strongly typed results), not JSON-first usage;
- a **uniform execution model** across endpoints (synchronous, asynchronous and promise-based);
- **clear boundaries** with non-OpenAI vendors, which are reachable only insofar as they expose an OpenAI-compatible surface (see [Provider Support](guides/Provider-Support-and-OpenAI-API.md)).

### Core execution modes

- **Standard generation** — blocking or promise-based; the full response is returned at once. Suitable for background or batch workflows.
- **SSE streaming** — synchronous or asynchronous, with **session-level** (per-chunk) or **event-level** (per typed event) callbacks for fine-grained interception of the response stream.
- **Tool-driven & agentic workflows** — function calling and built-in tools (web search, file search, code interpreter, image generation, remote MCP, shell, apply patch, skills) with strict schema validation, plus the supporting agentic plumbing: Code Interpreter **containers** and automatic context **compaction**.
- **Multiple providers** — the same `IGenAI` client targets OpenAI, a local LM Studio server, Google Gemini, or any OpenAI-compatible endpoint.

These distinctions are applied consistently at the API level and in the documentation.

<br>

___

## Documentation

The documentation is organized as **focused Markdown guides**, each covering one capability. They are all listed, explained and ordered in a single entry point:

- **[Documentation index — `guides/guides.md`](guides/guides.md#guides)** — start here.
- [Changelog](Changelog.md#2026-june-9-version-200)
- [About this project](guides/GenAI.md#about-this-project)

Each guide provides Delphi-first examples (synchronous, asynchronous and promise-based), not raw JSON.

<br>

___

## Responses vs. Chat Completions

The `v1/responses` API is the new core API: an agentic primitive that combines the simplicity of chat completions with built-in tools (web search, file search, computer use, image generation, remote MCP, code interpreter, skills, containers). It is intended to gradually replace `v1/chat/completions`.

>[!NOTE]
>If you're a new user, we recommend the **Responses API**.

| Capabilities | [Chat Completions](guides/ChatCompletion.md#chat-completion) | [Responses](guides/Responses.md#responses) |
|--- |:---: | :---: |
| Text generation | ● | ● |
| Audio | ● | Coming soon |
| Vision | ● | ● |
| Structured Outputs | ● | ● |
| Function calling | ● | ● |
| Web search | ● | ● |
| File search | | ● |
| Computer use | | ● |
| Code interpreter | | ● |
| Image generation | | ● |
| Remote MCP | | ● |
| Reasoning summaries | | ● |
| Skills | | ● |
| Containers | | ● |

>[!WARNING]
> [Note from OpenAI](https://platform.openai.com/docs/guides/responses-vs-chat-completions#the-chat-completions-api-is-not-going-away) <br>
> The Chat Completions API is an industry standard for building AI applications, and we intend to continue supporting it indefinitely. The Responses API simplifies workflows involving tool use, code execution, and state management.

<br>

___

## Functional Demo

This repository includes a working **FMX** demo in the [demos](demos) folder, built on top of [Pythia-WebView2](https://github.com/MaxiDonkey/Pythia-webView2), used here as the host application for the wrapper.

This demo matters for users of the wrapper because it shows **DelphiGenAI running inside a real application flow**, not only through isolated code snippets. It demonstrates how the `IGenAI` client is connected to a UI-oriented conversation layer over the **Responses API**, with asynchronous SSE streaming, request/response JSON traceability, function / MCP / skill / agent cards, image creation and editing (Images API), file upload through the Files API, knowledge indexing into a vector store for retrieval (RAG), and microphone capture with Whisper speech-to-text.

One key part of the demo is the context reconstruction layer (`Demo.OpenAI.Context.pas`). It offers two continuity strategies that together cover the demo's needs without relying on the separate Conversations API: a **local context rebuild**, where Delphi reconstructs richer message context from the stored JSON request and streamed JSON response — text blocks, reasoning blocks, tool calls and matching tool results, MCP exchanges and web-search results — while taking the previously used tools into account; or **cloud chaining** via `previous_response_id`, where OpenAI keeps the conversation state server-side. Both are off by default, so nothing is retained on OpenAI's servers unless you explicitly opt in.

The guides keep the didactic path: each API surface is explained independently, with focused Delphi examples. The demo is the complementary reference: it shows how those capabilities cooperate end-to-end in a functional Delphi application, and it provides a practical starting point for validating your API key, runtime setup and optional MCP / skill / agent configuration.

For a full, step-by-step explanation of **how the SDK is plugged into Pythia** — the integration contract, the `IGenAI` ↔ Pythia event flow, turn routing, the async services, multi-turn context and the `delphi-uses-graph` custom skill — see the dedicated walkthrough: **[`demos/docs/FMX_OpenAI.md`](demos/docs/FMX_OpenAI.md)**. See also the demo-specific setup notes in [demos/README.md](demos/README.md).

<br>

___

## Functional coverage

OpenAI endpoints supported by GenAI. Browse the matching guide for each one from the **[documentation index](guides/guides.md)**.

| Endpoint | Supported | Status / notes |
|--- |:---: |:---: |
| /audio/speech | <div align="center"><span style="color: green;">●</span></div> | ![updated](https://img.shields.io/badge/UPDATED-003399?style=flat) |
| /audio/transcriptions | <div align="center"><span style="color: green;">●</span></div> | ![updated](https://img.shields.io/badge/UPDATED-003399?style=flat) |
| /audio/translations | <div align="center"><span style="color: green;">●</span></div> | ![updated](https://img.shields.io/badge/UPDATED-003399?style=flat) |
| /batches | <div align="center"><span style="color: green;">●</span></div> | |
| /chat/completions | <div align="center"><span style="color: green;">●</span></div> | |
| /chatkit | | |
| /completions | <div align="center"><span style="color: green;">●</span></div> | ![legacy](https://img.shields.io/badge/LEGACY-fuchsia) |
| /containers | <div align="center"><span style="color: green;">●</span></div> | ![updated](https://img.shields.io/badge/UPDATED-003399?style=flat) |
| /conversations | <div align="center"><span style="color: green;">●</span></div> | |
| /embeddings | <div align="center"><span style="color: green;">●</span></div> | |
| /evals | | |
| /files | <div align="center"><span style="color: green;">●</span></div> | |
| /fine_tuning | <div align="center"><span style="color: green;">●</span></div> | |
| /images | <div align="center"><span style="color: green;">●</span></div> | |
| /models | <div align="center"><span style="color: green;">●</span></div> | |
| /moderations | <div align="center"><span style="color: green;">●</span></div> | |
| /organization | | |
| /realtime | <div align="center"><span style="color: green;">●</span></div> | |
| /responses | <div align="center"><span style="color: green;">●</span></div> | ![updated](https://img.shields.io/badge/UPDATED-003399?style=flat) |
| /skills | <div align="center"><span style="color: green;">●</span></div> | ![new](https://img.shields.io/badge/NEW-006400?style=flat) |
| /uploads | <div align="center"><span style="color: green;">●</span></div> | |
| /vector_stores | <div align="center"><span style="color: green;">●</span></div> | |

<br>

___

## Tips and tricks

#### How to prevent an error when closing an application while requests are still in progress?

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

___

## Removed in 2.0.0

**OpenAI Assistants API** — deprecated since 1.3.0 (OpenAI deprecation announced August 26, 2025), now **removed**. Migrate to the **Responses** and **Conversations** APIs (see the [migration guide](https://platform.openai.com/docs/assistants/migration)).
Removed units: `GenAI.Assistants.pas`, `GenAI.Messages.pas`, `GenAI.Threads.pas`, `GenAI.Runs.pas`, `GenAI.RunSteps.pas`.

**Sora video API** (`v1/videos`) — **removed**. Removed unit: `GenAI.Video.pas`.

> The last release shipping these units is **1.4.3**; their sources remain available there for reference and backward compatibility.

<br>

___

## Contributing

Pull requests are welcome. If you're planning a major change, please open an issue first to discuss it.

<br>

___

## License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.

<br>
