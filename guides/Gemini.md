# Google Gemini compatibility

- [Client initialization](#client-initialization)
- [Text generation](#text-generation)
- [Thinking](#thinking)
- [Function calling](#function-calling)
- [Vision](#vision)
- [Generate an image](#generate-an-image)
- [Audio understanding](#audio-understanding)
- [Embeddings](#embeddings)
- [List models](#list-models)
- [Retrieve a model](#retrieve-a-model)
- [Notebook Colab](#notebook-colab)
___

## Client initialization

To initialize a client compatible with Gemini models, first [obtain an API key](https://aistudio.google.com/api-keys?hl=fr) from Google. Then create the `IGenAI` client instance as shown below:

```pascal
//uses GenAI, GenAI.Types;

  Client := TGenAIFactory.CreateGeminiInstance(GeminiKey);
```

>[!NOTE]
> A single application may instantiate multiple clients simultaneously:
> - one client to access OpenAI Cloud APIs
> - another client for Gemini Cloud APIs
> - and a third client for locally hosted models via LM Studio.

<br>

___

## Text generation

- [Non-streamed](#non-streamed)
- [Streamed](#streamed)

<br>

When targeting **Gemini models**, text generation is supported **exclusively** via the `/v1/chat/completions` endpoint.

The legacy `/v1/completions` endpoint and the agentic `/v1/responses` API are **not supported** for Gemini models.

To use this endpoint, please refer to the internal documentation available at the following link:
- [Chat/completions](ChatCompletion.md#text-generation) 

### Non-streamed

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params
        .Model('gemini-2.5-flash')
        .Messages([
          FromSystem('You are a comedian looking for jokes for your new show.'),
          FromUser('What is the difference between a mathematician and a physicist?')]);
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
//      Params
//        .Model('gemini-2.5-flash')
//        .Messages([
//          FromSystem('You are a comedian looking for jokes for your new show.'),
//          FromUser('What is the difference between a mathematician and a physicist?')]);
//      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
//    end);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;

  //Asynchronous promise example
//  Display(TutorialHub, 'This may take a few seconds.');
//  var Promise := Client.Chat.AsyncAwaitCreate(
//    procedure (Params: TChatParams)
//    begin
//      Params
//        .Model('gemini-2.5-flash')
//        .Messages([
//          FromSystem('You are a comedian looking for jokes for your new show.'),
//          FromUser('What is the difference between a mathematician and a physicist?')]);
//      TutorialHub.JSONRequest := Params.ToFormat(); //to display JSON Request
//    end);
//
//  promise
//    .&Then<string>(
//      function (Value: TChat): string
//      begin
//        for var Item in Value.Choices do
//          Result := Result + Item.Message.Content;
//        Display(TutorialHub, Value);
//        ShowMessage(Result);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

Please note that Gemini APIs do not support the `store` property, which is specific to OpenAI models.
If this property is included in a request, the API will return a **400 Bad Request error** indicating incompatible parameters.

<br>

### Streamed

Please note that Server-Sent Events (SSE) chunk generation differs significantly between Gemini and OpenAI models.
- OpenAI models emit one chunk per generated token.
- Gemini models emit a text segment per chunk, rather than token-level chunks.

As a result, fewer chunks are received when using a Gemini model compared to an OpenAI model.

Gemini models support including token usage information within SSE chunks, in the same way as OpenAI models.
This can be enabled using the following option: `StreamOptions(TIncludeUsage.New);`

However, Gemini models do not support obfuscation.
Attempting to enable this feature using: `StreamOptions(TIncludeObfuscation.New(False));` will result in a 400 Bad Request error.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Asynchronous example
  Client.Chat.AsynCreateStream(
    procedure(Params: TChatParams)
    begin
      Params
        .Model('gemini-2.5-flash')
        .Messages([
          FromSystem('You are a comedian looking for jokes for your new show.'),
          FromUser('What is the difference between a mathematician and a physicist?')])
        .StreamOptions(TIncludeUsage.New)
        .Stream;
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
//      Params
//        .Model('gemini-2.5-flash')
//        .Messages([
//          FromSystem('You are a comedian looking for jokes for your new show.'),
//          FromUser('What is the difference between a mathematician and a physicist?')])
//        .StreamOptions(TIncludeUsage.New)
//        .Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
//    begin
//      if (not IsDone) and Assigned(Chat) then
//        begin
//          DisplayStream(TutorialHub, Chat);
//        end;
//    end);

  //Asynchronous promise example
//  var Promise := Client.Chat.AsyncAwaitCreateStream(
//    procedure(Params: TChatParams)
//    begin
//      Params
//        .Model('gemini-2.5-flash')
//        .Messages([
//          FromSystem('You are a comedian looking for jokes for your new show.'),
//          FromUser('What is the difference between a mathematician and a physicist?')])
//        .StreamOptions(TIncludeUsage.New)
//        .Stream;
//      TutorialHub.JSONRequest := Params.ToFormat();
//    end,
//    function : TPromiseChatStream
//    begin
//      Result.Sender := TutorialHub;
//      Result.OnStart := Start;
//
//      Result.OnProgress :=
//        procedure (Sender: TObject; Chunk: TChat)
//        begin
//          DisplayStream(Sender, Chunk);
//        end;
//
//      Result.OnDoCancel := DoCancellation;
//
//      Result.OnCancellation :=
//        function (Sender: TObject): string
//        begin
//          Cancellation(Sender);
//        end
//    end);
//
//  Promise
//    .&Then<string>(
//      function (Value: string): string
//      begin
//        Result := Value;
//        ShowMessage(Result);
//      end)
//    .&Catch(
//      procedure (E: Exception)
//      begin
//        Display(TutorialHub, E.Message);
//      end);
```

<br>

___

## Thinking

Gemini 3 and Gemini 2.5 models are designed to better handle tasks involving advanced reasoning, delivering improved performance on complex problems.
To support this, the Gemini API exposes reasoning parameters that allow precise control over the level or limit of reasoning allocated to the model.

The control mechanisms differ depending on the model generation:
- Gemini 3 provides predefined reasoning levels, namely low and high.
- Gemini 2.5, by contrast, relies on explicit reasoning budgets, expressed as numerical values.

These mechanisms can be mapped to the reasoning effort levels of OpenAI models, as illustrated below.

>[!NOTE]
> The mapping below is a practical heuristic used to approximate OpenAI `reasoning_effort` levels.

| reasoning_effort (OpenAI) | thinking_level (Gemini 3) | thinking_budget (Gemini 2.5) |
| :---: | :---: | :---: |
| minimal | low | 1,024 |
| low | low | 1,024 |
| medium | high | 8,192 |
| high | high | 24,576 |

It is possible to disable reasoning by setting `reasoning_effort` to "none" for Gemini 2.5 models.

However, this option is not supported by `Gemini 2.5 Pro` or `Gemini 3` models, for which reasoning remains always enabled.

```pascal
 procedure (Params: TChatParams)
 begin
   Params
     .Model('gemini-2.5-flash')
     .Messages([
       FromSystem('Use french language'),
       FromUser('Explain to me how AI works')])
     .ReasoningEffort('low');
 end;
```

Gemini reasoning models also generate reasoning summaries.
Additional Gemini-specific fields can be included in a request by using the `extra_body` field.

Please note that `reasoning_effort` and `thinking_level` / `thinking_budget` provide overlapping functionality.
As a result, these options are mutually exclusive and cannot be used simultaneously.

```pascal
  procedure (Params: TChatParams)
  begin
    Params
      .Model('gemini-3-pro-preview')
      .Messages([
        FromSystem('Use french language'),
        FromUser('Explain to me how AI works')])
      .ExtraBody(
        TExtraBody.Create.ThinkingConfig(
          TThinkingConfig.Create
           .IncludeThoughts(True) ));
  end;
```

Gemini 3 supports OpenAI-compatible thinking signatures within the chat completion APIs.
A complete example is available in the [Thinking Signatures](https://ai.google.dev/gemini-api/docs/thought-signatures?hl=fr#openai) documentation.

<br>

___

## Function calling

Please refer to the code snippets provided for [function calls](ChatCompletion.md#function-calling) through the `v1/chat/completions` endpoint, as presented in the following section.

You should replace the model used in these examples with a ***Gemini 2, 2.5, or 3*** model, depending on your use case.

<br>

___

## Vision

The configuration below illustrates the JSON request body structure used for image content analysis.

For a complete overview of Vision capabilities, please refer to the [Vision section](ChatCompletion.md#vision) of the `v1/chat/completions` endpoint.

```pascal
var Url := 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg';
...

  procedure (Params: TChatParams)
  begin
    Params
      .Model('gemini-2.5-flash')
      .Messages([
         FromUser('What is in this image?', [Url]) 
       ]);
  end;
...
```

<br>

___

## Generate an image

The configuration below describes the structure of the JSON request body used for image generation.

```pascal
  ...
  procedure (Params: TImageCreateParams)
  begin
    Params
      .Model('imagen-4.0-generate-001')
      .Prompt('a portrait of a sheepadoodle wearing a cape')
      .ResponseFormat('b64_json')
      .N(1);
  end;
  ...
```

To access the code snippets, please refer to the internal documentation, section [DALL·E 3 model](Images.md#dall-e-3-model)

<br>

___

## Audio understanding

An example of asynchronous code demonstrating the transcription of an audio file into textual data is provided below.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  //Asynchronous example
  Client.Chat.AsynCreate(
    procedure (Params: TChatParams)
    begin
      Params
        .Model('gemini-2.5-flash')
        .Messages([
          FromUser('Transcribe this audio file.', ['VoiceRecorded.wav'])
          ]);
      TutorialHub.JSONRequest := Params.ToFormat();
    end,
    function : TAsynChat
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

Please refer to the internal documentation, section [Audio and Text-to-Text](ChatCompletion.md#audio-and-text-to-text).

<br>

___

## Embeddings

The example below shows synchronous code illustrating the vectorization of a text string.

```pascal
//uses GenAI, GenAI.Types, GenAI.Tutorial.VCL;

  TutorialHub.JSONRequestClear;

  //Synchronous example
  var Value := Client.Embeddings.Create(
    procedure (Params: TEmbeddingsParams)
    begin
      Params
        .Model('gemini-embedding-001')
        .Input('Your text string goes here');
      Params.EncodingFormat(TEncodingFormat.float);
    end);
  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
```

<br>

___

## List models

To list available models, you can directly reuse the code provided in the [List of models](Models.md#list-of-models) section of the `v1/chat/completions` endpoint.

<br>

___

## Retrieve a model

To retrieve available models, you can directly reuse the code provided in the [Retrieve a model](Models.md#retrieve-a-model) section of the `v1/chat/completions` endpoint.

<br>

___

## Notebook Colab

You may also review the **Google** [Colab notebook](https://colab.research.google.com/github/google-gemini/cookbook/blob/main/quickstarts/Get_started_OpenAI_Compatibility.ipynb?hl=eng) focused on **OpenAI** compatibility, which provides more detailed examples.

