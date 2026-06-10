# Response helpers (`GenAI.Helpers`)

`GenAI.Helpers` is a **thin, fluent layer** that sits on top of [`GenAI.Responses.InputParams`](Responses.md#responses) to make composing `v1/responses` payloads pleasant — especially the **input context** (multi-turn messages, replayed **assistant** answers) and the tools array.

It introduces no new behaviour: every helper simply builds the same `InputParams` objects you would otherwise assemble by hand. You can therefore mix helpers and the raw SDK freely.

- [Purpose](#purpose)
- [Philosophy](#philosophy)
- [The `Generation` facade](#the-generation-facade)
- [Example 1 — a multi-turn payload](#example-1--a-multi-turn-payload)
- [Example 2 — a multimodal user message](#example-2--a-multimodal-user-message)
- [Dropping down to the raw SDK](#dropping-down-to-the-raw-sdk)

> To use the helpers, add `GenAI.Helpers` to your `uses` clause. The single entry point is the global `Generation` function.

___

<br>

## Purpose

Building the `input` of a Responses request by hand means assembling a `TArray<TInputListItem>` out of relatively verbose objects (`TInputMessage`, `TItemOutputMessage`, `TItemContent`, …). For a multi-turn conversation — where you replay previous **user** turns *and* **assistant** answers into the context — this quickly becomes noisy.

`GenAI.Helpers` lets you express the same intent declaratively:

```pascal
  Params.Input(
    Generation.MessageParts
      .User('What is the capital of France?')
      .Assistant('The capital of France is Paris.')   // assistant turn replayed into the context
      .User('And of Italy?')
  );
```

<br>

## Philosophy

- **Thin and transparent.** Each helper is a shortcut that returns ordinary `GenAI.Responses.InputParams` objects — no hidden state, no magic. Helpers and raw SDK compose in the same expression.
- **A builder at every level.** Each array you would normally pass raw (input items, message content, tools, annotations…) is exposed as a `TArrayBuilder<T>`: you chain `.AddXxx(...)`, and the builder *implicitly converts* to the `TArray<T>` the setter expects. No manual array literals.
- **Familiar vocabulary.** The unit mirrors `Anthropic.Helpers` region by region (`Generation`, `…Parts`, `User/Assistant/Developer/System`, `AddText/AddImage`, `CreateXxx`, `ToolChoice`), so switching SDKs keeps the same mental model.
- **Intentionally not exhaustive.** Only the most common, most useful blocks are surfaced. Anything rarer stays fully reachable through the raw SDK (see [below](#dropping-down-to-the-raw-sdk)).

<br>

## The `Generation` facade

Everything is reached from the global `Generation` function. It exposes three kinds of members:

```text
Generation
├── …Parts          → array builders (chain .AddXxx / .User / .Assistant …, cast to TArray<…>)
│   ├── MessageParts          input items        → Params.Input([...])
│   ├── ContentParts          a message's content (text / image / file / audio)
│   ├── ToolParts             tools              → Params.Tools([...])
│   └── OutputContentParts, AnnotationParts, ReasoningSummaryParts, …   (assistant replay sub-parts)
│
├── managers        → object factories (class properties)
│   ├── Payload      User / Developer / System / Assistant
│   ├── Content      Text / Image / File / Audio
│   ├── Context      CreateFunctionCall / CreateReasoning / CreateShellCall / …  (replay items)
│   └── Tool / ToolChoice / Computer / Shell / Output / Annotation
│
└── direct creators → request sub-configs
    └── CreateText / CreateJSONSchema / CreateReasoning / CreatePrompt / CreateContextManagement
```

The mental model:

| You want… | Use a… | Example |
| --- | --- | --- |
| an **array** the SDK expects (input, content, tools) | `Generation.…Parts` builder | `Generation.MessageParts.User('hi')` |
| a **single object** (a message, a replay item, a tool) | a `Generation` manager | `Generation.Payload.Assistant('Paris', 'msg_123')` |
| a request **sub-config** (text format, reasoning…) | a `Generation.CreateXxx` | `Generation.CreateReasoning` |

Builders and managers feed each other: a manager produces an item, a builder collects items into the array a `TResponsesParams` setter consumes.

<br>

## Example 1 — a multi-turn payload

Compose an input context that already contains a previous **assistant** answer, then ask a follow-up question.

```pascal
//uses GenAI, GenAI.Types, GenAI.Helpers, GenAI.Tutorial.VCL;

  var Value := Client.Responses.Create(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('gpt-5.5');
      Params.Input(
        Generation.MessageParts
          .Developer('You are a concise travel assistant.')
          .User('What is the capital of France?')
          .Assistant('The capital of France is Paris.')
          .User('And of Italy?')
      );
      Params.Store(False);
    end);
  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
```

`MessageParts` is a `TArrayBuilder<TInputListItem>`: `.Developer / .User / .Assistant` each append the matching item and return the builder, which `Params.Input` receives directly through its implicit conversion to `TArray<TInputListItem>`.

<br>

## Example 2 — a multimodal user message

A single user turn can carry several content blocks. Build them with `ContentParts`:

```pascal
//uses GenAI, GenAI.Types, GenAI.Helpers, GenAI.Tutorial.VCL;

  Params.Input(
    Generation.MessageParts
      .User(
        Generation.ContentParts
          .AddText('Describe this image and extract the key details.')
          .AddImage('c:\img.png')
      )
  );
```

Here `ContentParts` builds the message content (`AddText`, `AddImage`, `AddFile`, `AddAudio`), and `MessageParts.User(...)` wraps it into a user input item — no intermediate arrays or param objects to declare.

<br>

## Dropping down to the raw SDK

Because the helpers are intentionally partial, any item or configuration they do not surface can still be built with the raw `GenAI.Responses.InputParams` types and slotted in:

- `Generation.MessageParts.AddItem(<raw TInputListItem>)` appends an item the builder has no dedicated shortcut for;
- `Generation.Context.CreateXxx` exposes the less common replay items (function calls, reasoning, shell/apply-patch calls, MCP, computer calls, …) when you do need them.

In short: reach for the helpers for the common 90 %, and fall back to the raw SDK for the rest — both live in the same expression.

<br>

___

## See also

- [Responses](Responses.md#responses) — the endpoint these payloads are sent to.
- `GenAI.Helpers.pas` / `GenAI.Responses.InputParams.pas` — the source units behind this layer.
