# Version 2.0.0 — what changed under the hood

This guide is for developers already using the SDK. Most everyday code is **unchanged** — you still call `Client.Responses.Create(...)`, `Client.Chat.AsyncAwaitCreate(...)`, and so on. What changed in 2.0.0 is the **architecture of the low-level layers**, which were realigned with the Anthropic Delphi SDK so the two SDKs share the same design and can be maintained together. The result is more robust deserialization, better forward-compatibility, and cleaner handling of the highly polymorphic `v1/responses` payloads.

- [Unified low-level layers](#unified-low-level-layers)
    - [Two-step deserialization with a rehydration pass](#two-step-deserialization-with-a-rehydration-pass)
    - [Safer, simpler metadata handling](#safer-simpler-metadata-handling)
    - [Rewritten type layer (enums on the wire)](#rewritten-type-layer-enums-on-the-wire)
- [Polymorphism for v1/responses](#polymorphism-for-v1responses)
- [Event-level streaming](#event-level-streaming)
- [Unified media handling (base64 / data URI / MIME)](#unified-media-handling-base64--data-uri--mime)

___

<br>

## Unified low-level layers

The transport and (de)serialization layers were rewritten to mirror the Anthropic SDK, region by region. Three changes matter most to you.

### Two-step deserialization with a rehydration pass

The legacy path-based JSON normalizer (`GenAI.API.Normalizer` / `TJSONNormalizer`, which rewrote the payload *before* mapping) has been **removed**. In its place, `TApiDeserializer.Parse<T>` (in `GenAI.API.pas`) deserializes in **two steps**:

1. **Object mapping** — the payload is mapped to the Delphi object graph (`TJson.JsonToObject<T>`), after the JSON shield has prepared free-form fields (see below).
2. **Rehydration** — when `T` derives from `TJSONFingerprint`, the formatted raw JSON is stored on `JSONResponse` and bound to **every** fingerprint in the graph (`TJSONFingerprintBinder.Bind`); then `InternalFinalizeDeserialize` runs each DTO's `AfterDeserialize`, where the object **re-parses its own JSON** to rebuild the polymorphic or streaming content that plain RTTI cannot resolve.

The pass is exception-safe: if anything fails after allocation, the partial instance is freed before re-raising.

**Why it matters:** polymorphic reconstruction is now *local* to each DTO instead of relying on global path rules, and the original payload always remains available through the `JSONResponse` property.

<br>

### Safer, simpler metadata handling

Free-form or variable fields (those listed in `PROTECTED_FIELD`) cannot always be bound to a fixed class. Two small units keep this robust and safe:

- **`GenAI.API.JSONShield`** exposes `ICustomFieldsPrepare` (the `MetadataManager`): before the first mapping pass it *shields* protected fields, carrying their nested object/array as an opaque string so embedded quotes, backslashes or arbitrary structures cannot corrupt the parse. The behaviour is switchable through `MetadataAsObject` (when `True`, those fields are expected as proper objects/arrays instead).
- **`GenAI.Types.Rtti`** provides `TRttiMemberAccess`, a minimal, defensive RTTI accessor (`GetValue<T>` / `SetValue<T>` by member name) that raises a clear `TGenAIAPIException` when a member is missing or read-only.

In addition, the fingerprint binder bounds its graph traversal (a configurable maximum node count with an `OnTruncated` callback), so very large or deep payloads cannot cause runaway work.

**Why it matters:** robustness (free-form fields no longer break the parse) and safety (bounded traversal, explicit fail-loud access).

### Rewritten type layer (enums on the wire)

`GenAI.Types.pas` was rewritten on top of the new **`GenAI.Types.EnumWire`**. Enum ↔ API-string conversion is now centralized in `TEnumWire` (generic `Parse` / `TryParse` / `ToString`, alias-aware, cached, case-insensitive), and each enum exposes a record helper (`Create` / `Parse` / `TryToParse` / `ToString`).

Crucially, **every enum gains an `sdk_unknown` member**: an unrecognized wire value is mapped to `sdk_unknown` instead of raising (the strict `Parse` still raises; the `TryToParse` form falls back).

**Why it matters:** when OpenAI introduces a new enum value, your deserialization keeps working instead of crashing — and enum handling is now consistent across the whole SDK.

<br>

___

## Polymorphism for v1/responses

The `v1/responses` payloads are deeply polymorphic: the `output` array mixes message / reasoning / tool-call items, content blocks vary, and several fields are *string-or-object* (`tool_choice`) or *string-or-array* (`instructions`). Delphi RTTI and `JsonToObject` cannot map these on their own.

`GenAI.Responses.OutputParams.pas` handles this with the rehydration pass described above:

- polymorphic fields are excluded from default marshalling with `[JSONMarshalled(False)]`;
- the DTO overrides `AfterDeserialize` / `ContentUpdate`, which re-parse the object's own `JSONResponse` with a `TJsonReader` and materialize the correct typed sub-objects — for example, building `TInstructions` items from an `instructions` array, or a typed `tool_choice` from either a bare string (`none` / `auto` / `required`) or an object.

**Why it matters:** you always receive correctly typed `Output`, content and tool-call objects, while the untouched payload stays accessible on `JSONResponse`.

<br>

___

## Event-level streaming

Previously, streaming exposed a single **session-level** callback: `AsynCreateStream` with `OnProgress`, handing you each raw `TResponseStream` chunk to inspect and aggregate yourself.

2.0.0 adds an **event-level** model, again aligned with the Anthropic SDK, through two new units:

- **`GenAI.Responses.StreamCallbacks`** — an aggregation DTO `TResponsesEventData` (with tool-call / tool-result snapshots) and a rich per-event callback record `TResponseStreamEventCallBack`. Each handler receives `(Sender: TObject; Event: TResponsesEventData)` and targets a specific event: `OnCreated`, `OnInProgress`, `OnOutputTextDelta`, `OnOutputTextDone`, `OnFunctionCallArgumentsDelta`, `OnFileSearchCall*`, `OnWebSearchCall*`, `OnReasoning*`, `OnImageGenerationCall*`, `OnMcp*`, `OnCodeInterpreterCall*`, `OnCompleted`, `OnError`, …
- **`GenAI.Responses.StreamEngine`** — an `IResponsesEventEngineManager` that, for each chunk, aggregates it into the buffer and dispatches it to the matching typed handler (a flat *Aggregate + Dispatch* pass; the buffer is reset on the `created` event).

You opt in by passing an engine to the streaming route methods — `Client.Responses.CreateStream(ParamProc, Event, StreamEvents)` or `AsyncAwaitCreateStream(ParamProc, StreamEvents)` (which resolves with the aggregated `TResponsesEventData`). The classic per-chunk `OnProgress` path still exists.

```pascal
//uses GenAI, GenAI.Types, GenAI.Responses.StreamCallbacks, GenAI.Responses.StreamEngine;

  var Engine := TResponsesEventEngineManagerFactory.CreateInstance(
    function : TResponseStreamEventCallBack
    begin
      Result.OnOutputTextDelta :=
        procedure (Sender: TObject; Event: TResponsesEventData)
        begin
          // a new text fragment is available in the aggregated buffer
        end;

      Result.OnCompleted :=
        procedure (Sender: TObject; Event: TResponsesEventData)
        begin
          // the response is complete
        end;
    end);

  Client.Responses.AsyncAwaitCreateStream(
    procedure (Params: TResponsesParams)
    begin
      Params.Model('gpt-5.5');
      Params.Input('Tell me a short story.');
      Params.Stream;
    end,
    Engine);
```

**Why it matters:** you subscribe to exactly the events you care about and read aggregated, already-typed state from `TResponsesEventData`, instead of decoding raw chunks by hand.

<br>

___

## Unified media handling (base64 / data URI / MIME)

The new **`GenAI.Net.MediaCodec`** unit centralizes everything related to encoding multimodal inputs, which used to be scattered. The `TMediaCodec` record offers, as static functions:

- **base64** — `EncodeBase64` (from a file path, text, stream or bytes) and `DecodeBase64ToString / ToBytes / ToStream / ToFile`, each with a fail-safe `TryDecodeBase64To*` variant; plus `NormalizeBase64`;
- **data URIs** — `EncodeDataUri` (file / text / stream / bytes + MIME type) and `TryDecodeDataUriToBytes / ToStream / ToString / ToFile` (which also return the MIME type), plus `TryGetDataUriMimeType`;
- **MIME & files** — `GetMimeType`, `GetFileSize`, `IsUri`, `IsDataUri`, and `TryToBytes` / `TryToDataUri`;
- **remote content** — `TryUrlToBytes` / `TryUrlToStream` to fetch a URL into bytes or a stream with its content type.

(`TUriCodec.ExtractURIFileName` complements it for URI path handling.)

```pascal
//uses GenAI.Net.MediaCodec;

  var B64 := TMediaCodec.EncodeBase64('c:\img.png');
  var Uri := TMediaCodec.EncodeDataUri('c:\img.png', TMediaCodec.GetMimeType('c:\img.png'));

  if TMediaCodec.IsDataUri(SomeValue) then
    { ... };
```

**Why it matters:** one consistent, fail-safe API for preparing images, files and audio, instead of ad-hoc base64/MIME code at each call site.

<br>

___

> In short: your request/response code keeps working as before; 2.0.0 makes the layers underneath more robust, forward-compatible, and consistent with the Anthropic SDK.
