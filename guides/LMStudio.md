# Run models locally with LM Studio


- [Using LM Studio as a local OpenAI-compatible backend](#using-lm-studio-as-a-local-openai-compatible-backend)
- [Supported LM Studio endpoints](#supported-lm-studio-endpoints)
- [GGUF Broad Adoption in the Local Ecosystem](#gguf-broad-adoption-in-the-local-ecosystem)
- [Downloading models with LM Studio (HuggingFace integration)](#downloading-models-with-lm-studio-huggingface-integration)
- [Usage examples](#usage-examples)

<br>

___

>[!WARNING]
>This section is not a tutorial about LM Studio.  
>It only explains what is required to use LM Studio as a local backend for the Delphi **GenAI** wrapper.

<br>

## Using LM Studio as a local OpenAI-compatible backend

Download LM Studio: [https://lmstudio.ai](https://lmstudio.ai)

This section assumes you are already familiar with LM Studio (loading models, starting its local OpenAI server, selecting a port, etc.).

<br>

LM Studio exposes a minimal but fully OpenAI-compatible HTTP server.
Because the Delphi **GenAI** wrapper sends standard OpenAI-format requests, you can run **any GGUF model supported by LM Studio** as a drop-in replacement for cloud OpenAI models.

Example of model families supported through LM Studio:
- mistralai/mistral-7b-instruct-v0.3
- openai/gpt-oss-20b (official OpenAI open-weight model)
- Llama 3 / 3.1
- Gemma, Falcon, Qwen, NousResearch, etc.

To select a model:

```pascal
Params.Model('model-name-as-exposed-by-LM-Studio');
```

>[!NOTE]
> LM Studio may rename models in the OpenAI Server panel.
>Always check the exact identifier displayed there.

<br>

## Supported LM Studio endpoints

LM Studio currently implements the following OpenAI endpoints:

| HTTP | Endpoint | GenAI Route |
| :---: |:---: |:---: | 
| GET | v1/models | TGenAI.Models |
| POST | v1/responses | TGenAI.Responses |
| POST | v1/chat/completions | TGenAI.Chat |
| POST | v1/completions | TGenAI.Completions |
| POST | v1/embeddings | TGenAI.Embeddings |

The Delphi GenAI wrapper implements the entire OpenAI API surface, but when configured for LM Studio, only these endpoints will be functional, as they are the only ones exposed by LM Studio.

All these routes also benefit from the full Delphi **GenAI** feature set, exactly as with the OpenAI cloud API.
This includes:
- synchronous execution
- asynchronous execution
- streaming
- promises
- tools / function calling (if supported by the model)
- JSON mode
- parallel prompts

<br>

## GGUF Broad Adoption in the Local Ecosystem

>[!NOTE]
> GGUF is a universal, compact and optimized format for running LLMs locally on lightweight CPU/GPU systems, with built-in quantization and fully embedded metadata.

GGUF is now the standard format across virtually all local runtimes:
- llama.cpp (reference runtime)
- LM Studio
- Ollama (partially / internal conversion)
- Text Generation Web UI
- KoboldCpp
- Rustformers / candle
- LangChain local runtimes
- and many others.

Most open-weight models on HuggingFace provide GGUF builds, making them directly compatible with LM Studio.

<br>

## Downloading models with LM Studio ([HuggingFace models](https://huggingface.co/models) integration)

LM Studio can download **GGUF** models directly from **HuggingFace** using the `lms` command-line tool. ***Refer to the official documentation: [LM Studio's CLI](https://lmstudio.ai/docs/cli#lms--lm-studios-cli)***. 
This allows you to run high-quality models locally, without depending on OpenAI’s cloud API.

#### Example: downloading OpenAI’s official open-weight model

- `openai/gpt-oss-20b`
  A medium-sized open-weight model suitable for local inference.
  (21B parameters with ~3.6B active parameters.)

  #### Download via LM Studio: 
  ```bash
  lms get openai/gpt-oss-20b
  ```
  Once downloaded, the model appears automatically in LM Studio’s OpenAI Server panel.
  
  <br>

  You can then use it directly with the Delphi GenAI wrapper:
  ```pascal
  Params.Model('openai/gpt-oss-20b');
  ```

<br>

  #### This applies to all GGUF models supported by LM Studio
  Simply run:
  ```bash
  lms get <namespace/model>
  ```
  
  Then select the model:
  ```pascal
  Params.Model('<namespace/model>');
  ```
  
  LM Studio handles downloading, indexing, loading the GGUF weights, and exposing the model through the OpenAI-compatible HTTP API.

<br>

## Usage examples

Ensure that the LM Studio HTTP server is running.
You can verify this in the LM Studio UI, or start the server manually:
```bash
lms server start
```
For more information, refer to the [LMS documentation](https://lmstudio.ai/docs/cli/serve/server-start#lms-server-start)

<br>

To initialize the API instance:

>[!NOTE]
>```pascal
>//uses GenAI, GenAI.Types;
>
>//Declare 
>//  Client: IGenAI;
>
>  // Local client (LM Studio – OpenAI compatible server)
>  Client := TGenAIFactory.CreateLMSInstance; // default: http://127.0.0.1:1234/v1
>
>  // or
>  //Client := TGenAIFactory.CreateLMSInstance('http://192.168.1.10:1234');
> ```

<br>

### Model List

Endpoint : `GET /v1/models`

Refer to the [***code snippets***](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/guides/Models.md#list-of-models) which can be used directly in this context.


You can also monitor the request directly in LM Studio:
<p align="center">
  <img src="https://raw.githubusercontent.com/MaxiDonkey/DelphiGenAI/main/images/LMStudio.png" width="300"/>
</p>

<br>

### Using the `v1/responses` endpoint

- Non-streaming example with the `openai/gpt-oss-20b` model

  ```pascal
  //uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynCreate(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('openai/gpt-oss-20b');
      Params.Input('What is the difference between a mathematician and a physicist?');
      Params.Store(False);  // Response not stored
      //Params.conversation('conv_68f4de2260348193b6cbaa1a55d6673905e7c3018568d016'); to use conversation
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponse
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess :=
        procedure (Sender: TObject; Response: TResponse)
        begin
          Display(Sender, Response);
          Ids.Add(Response.Id);
        end;
      Result.OnError := Display;
    end);
  ```
 
<p align="center">
  <img src="https://raw.githubusercontent.com/MaxiDonkey/DelphiGenAI/main/images/LMStudioNoStreamed.png" width="300"/>
</p>

<br>

- Streaming example with the `deepseek/deepseek-r1-0528-qwen3-8b` model

  Ensure that the model `deepseek/deepseek-r1-0528-qwen3-8b` has been added to LM Studio’s model list. If not, run:

  ```bash
  lms get deepseek/deepseek-r1-0528-qwen3-8b

  ```

  <br>

  Code using Delphi GenAI:
  ```pascal
  //uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Responses.AsynCreateStream(
    procedure(Params: TResponsesParams)
    begin
      Params.Model('deepseek/deepseek-r1-0528-qwen3-8b');
      Params.Input('What is the difference between a mathematician and a physicist?');
      Params.Store(False);  // Response not stored
      Params.Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynResponseStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := Cancellation;
    end);
  ```

<p align="center">
  <img src="https://raw.githubusercontent.com/MaxiDonkey/DelphiGenAI/main/images/LMStudioStreamed.png" width="300"/>
</p>
