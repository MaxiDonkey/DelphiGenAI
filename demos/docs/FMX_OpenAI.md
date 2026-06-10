# FMX_OpenAI

> Purpose of this document: explain how the `FMX_OpenAI` demo implements **Pythia-Webview2** with a real LLM vendor, here OpenAI through the `DelphiGenAI` SDK.
> The demo is not an exhaustive coverage of the OpenAI API. Its main purpose is to show where and how to plug a vendor into Pythia, while demonstrating a representative set of advanced features: streaming, files, vision, RAG/file_search, MCP, a custom skill, reasoning, image creation/editing, text-to-speech, microphone speech-to-text, and multi-turn context.
> It is the FMX / OpenAI counterpart of the [`VCL_Anthropic`](VCL_Anthropic.md) demo: the same teaching scenarios, ported to the OpenAI ecosystem and built with FireMonkey instead of VCL.

<br>

>[!IMPORTANT]
>
> `FMX_OpenAI` is a sample application. Its role is to show the integration contract between Pythia and a vendor SDK.
>
> The same pattern could be applied with `DelphiAnthropic` for Anthropic, `DelphiGemini` for Gemini, or `DelphiMistralAI` for Mistral. OpenAI is used here as a concrete case, not as an architectural limit.

___

<br>

## 1. Positioning

`Pythia-Webview2` provides the desktop interface: WebView2, HTML/CSS/JS, chat bubbles, panels, cards, files, sessions, and the JavaScript bridge to Delphi.

`FMX_OpenAI` provides the vendor layer: it reads the state produced by Pythia, converts it into an OpenAI **Responses API** payload, calls the `DelphiGenAI` SDK, streams the response back to the UI, and finalizes the conversation turn.

The demo therefore answers one precise question:

> How does a Delphi application take control of Pythia events and connect them to a real LLM vendor?

It does not try to reimplement all of OpenAI. It exposes enough surface area to understand the pattern:

- streamed text chat (Responses API);
- vision through attached images;
- PDF and text documents;
- archives and textual documents sent through the Files API;
- web search;
- reasoning / thinking (reasoning effort);
- structured output;
- MCP;
- custom skill `delphi-uses-graph`;
- knowledge indexing for retrieval (RAG via `file_search` vector stores);
- image creation and editing (Images API);
- text-to-speech and microphone speech-to-text;
- multi-turn context, either rebuilt locally or chained with `previous_response_id`;
- saving `JsonPrompt` and `JsonResponse` so history can be replayed correctly.

The card-driven agent examples are documented separately, in the demo's own walkthrough:
[`demos/FMX/pythia-openai/README.md`](../demos/FMX/pythia-openai/README.md).

---

## 2. Repository Location

| Element | Path | Role |
|---|---|---|
| FMX demo | `demos/FMX/pythia-openai` | Sample application that connects Pythia to OpenAI |
| Pythia component | `source` | Interfaces, event routing, adapters, VCL/FMX rendering, shared services |
| WebView2 UI | `assets` | HTML/CSS and JS templates injected into the WebView |
| UI scripts | `assets/scripts` | JS templates for bubbles, selectors, input, cards, sessions |
| Demo runtime data | `bin64/FMX_OpenAI/support` | JSON files for capabilities, models, MCP/skill/custom/agent cards |
| Custom skill | `bin64/FMX_OpenAI/delphi-uses-graph` | Custom skill bundle registered on the OpenAI side |

The main Delphi project is:

```text
demos/FMX/pythia-openai/FMX_OpenAI.dproj
```

---

## 3. Quick Architecture Read

Read the demo from top to bottom:

```text
Main.pas
  creates TFMXPythia
  attaches the host form (AttachHost)
  wires ServiceAdapter
  creates TOpenAIServices after WebView2 initialization

FMX.WVPythia.Services.pas
  implements the application service expected by Pythia
  routes input-submit to OpenAIVendor.AsyncAwaitStreamChat

Demo.OpenAI.Services.pas
  entry point (IVendorServices)
  routes each turn to a handler (text / image / speech-to-text / text-to-speech)
  wires the optional async services (upload, knowledge indexing, transcription)

Demo.OpenAI.TextTurn.pas
  builds the Responses payload, streams, handles tools, finalization

Demo.OpenAI.Context.pas
  rebuilds multi-turn history from PersistentChat,
  or defers to previous_response_id when cloud chaining is enabled

Demo.OpenAI.Helpers.pas
  converts TInputPromptState into Responses content and applies request parameters

Demo.OpenAI.Upload.pas / Demo.OpenAI.VectorFileStore.pas
  implement IFileUploadService and IKnowledgeIndexingService

Demo.OpenAI.AsyncUtils.pas
  groups auxiliary asynchronous operations:
  session renaming, transcription, file retrieval/deletion, custom skill sync
```

A more detailed unit dependency tree (and a per-unit responsibility table) lives in the demo's own [`README.md` → *Demo architecture*](../demos/FMX/pythia-openai/README.md#demo-architecture).

---

## 4. The Pythia Contract to Implement

The heart of the integration is not in OpenAI. It is in `source`. The contract is the same as for any other vendor — `FMX_OpenAI` uses exactly the interfaces described in [`VCL_Anthropic.md`](VCL_Anthropic.md#4-the-pythia-contract-to-implement), only the host framework changes (FMX instead of VCL).

### 4.1. `IPythiaBrowser`

`source/WVPythia.Chat.Interfaces.pas` exposes `IPythiaBrowser`, the interface used by an application to drive the WebView2 surface:

- `Display`, `DisplayStream`, `DisplayError`, `DisplaySuccess` to write into the chat;
- `Prompt`, `PromptMedia` to render the user side;
- `CardSelectorShow`, `CardSelectorSetData`, `ModelsSelectorShow` for panels;
- `GetSkillCardsFileName`, `GetMcpCardsFileName`, `GetMediaFolder`, and related methods to locate runtime files;
- `FileUploadService`, `KnowledgeIndexingService`, `AudioTranscriptionService` to delegate side artifacts to the vendor;
- `PersistentChat` to manage sessions and history.

In this demo, `TOpenAIServices` keeps a reference named `FBrowser: IPythiaBrowser`.

### 4.2. `IChatManagedItemDialogService`

`source/WVPythia.Adapter.pas` defines the adapter service that the WebView calls when the user performs an action. The base class `TCustomChatManagedItemDialogService` (`source/WVPythia.ManagedItemService.pas`) exposes overridable `Do*` methods; the important handoff point is:

```pascal
function DoActivateInputState(
  const AState: TInputPromptState;
  const AOnFinalize: TManagedItemFinalizeProc): Boolean; override;
```

It receives the `TInputPromptState` built by the DOM and a finalization callback. The vendor must handle the request, then call this callback with a `TManagedItemLLMResult`. The demo specializes the base class in `FMX.WVPythia.Services.pas`.

### 4.3. `TInputPromptState`

`source/WVPythia.Chat.ManagedFlow.pas` groups everything the user selected or typed:

- `Text`: prompt;
- `Models`: selected models;
- `Files`, `Images`, `KnowledgeSearch`: files and media;
- `Integration`: functions, MCP, skills, agents;
- `Thinking`, `WebSearch`, `DeepResearch`;
- `Media`: image creation, text-to-speech, speech-to-text routing;
- `RequestParams`: system prompt, max tokens, temperature, stop strings, top-p, structured output, and the vendor settings `usingPreviousId` / `store`;
- `Source`: raw JSON captured from the browser.

The demo turns this object into a `TStateBuffer` (`TStateBuffer.FromState`), so payload building can use a simple structure detached from the UI classes.

### 4.4. `TManagedItemLLMResult`

The finalization callback expects a `TManagedItemLLMResult`:

- `UsedModel`;
- `Response`;
- `Reasoning`;
- `PromptJson`;
- `ResponseJson`;
- generated file/image/audio/video lists;
- optional error state.

Pythia then uses this object to update the UI and persist the turn in `PersistentChat`.

---

## 5. Demo Startup

`Main.pas` shows the minimum FMX-side setup:

```pascal
Pythia := TOpenAIDemoPythia.Create(Layout1);
Pythia.AttachHost(Self);
Pythia.OnApiKeyChanged := UpdateApiKey;
Pythia.ServiceAdapter := TFMXChatManagedItemDialogService.Create;
Pythia.OnInitialized := DoOnInitialized;
Pythia.Update;
```

Three points are essential:

- `AttachHost(Self)` is the FMX-specific step that binds the component to the host form (the VCL demo does not need it).
- `ServiceAdapter` is supplied by the application. Pythia does not know how to call OpenAI by itself.
- `DoOnInitialized` is called after the WebView2 boot sequence; this is the right time to create the vendor, because runtime paths and internal Pythia services are available.

In `DoOnInitialized`, the demo creates:

```pascal
OpenAIVendor := TOpenAIServices.Create(
  Pythia,
  TOpenAIContext.CreateInstance(Pythia)
);
```

This line injects two dependencies into the vendor:

- the Pythia browser (`IPythiaBrowser`);
- the multi-turn context manager (`IContext`).

---

## 6. The FMX Application Service

`FMX.WVPythia.Services.pas` is intentionally thin. It adapts Pythia's abstract service to the demo by overriding the `Do*` methods and forwarding them to a small `TToolContainer`.

The central method is:

```pascal
class function TToolContainer.ActivateInputState(
  const AState: TInputPromptState;
  const AOnFinalize: TManagedItemFinalizeProc): Boolean;
begin
  Result :=
    Assigned(OpenAIVendor) and
    Assigned(AState) and
    Assigned(AOnFinalize);
  if not Result then
    Exit;

  OpenAIVendor.AsyncAwaitStreamChat(AState, AOnFinalize);
end;
```

This is where the Pythia world leaves the framework and enters the vendor. To integrate another SDK, this is exactly the delegation you would replace:

```text
Pythia input-submit
  -> TInputPromptState
  -> ServiceAdapter.DoActivateInputState
  -> Vendor.AsyncAwaitStreamChat
  -> TManagedItemLLMResult
  -> AOnFinalize
  -> Pythia UI + persistence
```

The other `TToolContainer` methods show the available extension points: function selection, MCP, skill, agent, custom item, settings, model selection, copy events, audio input. Most are intentionally left as no-ops, because this demo focuses on the OpenAI vendor path.

> **Agent cards.** `SelectAgentItem` deliberately returns `False`: the demo does not intercept the selection, it lets Pythia's standard agent-card selector populate `State.Integration.Agents`, and the agent run is then driven from `Demo.OpenAI.TextTurn` at submit time (see the demo README).

---

## 7. The OpenAI Vendor

`Demo.OpenAI.Services.pas` implements `IVendorServices` with `TOpenAIServices`.

### 7.1. Initialization

The constructor:

- reads the `openai` API key from `ApiKeySecretStore`;
- triggers `/api-key new openai` when no key is configured;
- creates the SDK client with `TGenAIFactory.CreateInstance`;
- configures the HTTP response timeout (30 minutes);
- installs `TOpenAIClientUtils` for auxiliary operations;
- synchronizes custom skills declared in the skill card file (`SkillCustomRegister`);
- wires automatic session renaming (`OnChatSessionAutoRename`);
- installs `TDownloadService` as the `IFileUploadService`;
- installs `TOpenAIKnowledgeIndexingService` as the `IKnowledgeIndexingService`;
- installs `TOpenAITranscriptionService` as the `IAudioTranscriptionService`, and reveals the microphone button (`ebMicrophone`).

This initialization shows that the vendor owns its own secrets, network client, upload constraints, and side services. Pythia only provides the injection points.

There is an important design nuance here: not all Pythia services are wired in `Main.pas`.

`Main.pas` connects the generic application foundation:

```pascal
Pythia.ServiceAdapter := TFMXChatManagedItemDialogService.Create;
Pythia.OnApiKeyChanged := UpdateApiKey;
Pythia.OnInitialized := DoOnInitialized;
```

By contrast, services that directly depend on OpenAI are wired in `TOpenAIServices.Create`, because they only make sense for this vendor:

```pascal
FBrowser.OnChatSessionAutoRename := ChatSessionRename;
FBrowser.FileUploadService :=
  TDownloadService.Create(FBrowser as IPythiaBrowser, FClient);
FBrowser.KnowledgeIndexingService :=
  TOpenAIKnowledgeIndexingService.Create(FBrowser as IPythiaBrowser, FClient);
FBrowser.AudioTranscriptionService :=
  TOpenAITranscriptionService.Create(FClientUtils);
```

These connections could technically have been made from `Main.pas`, but doing so would mix the Pythia host layer with OpenAI-specific details. Keeping them in `Demo.OpenAI.Services.pas` makes the responsibility clearer:

- `Main.pas` instantiates Pythia and the vendor;
- `FMX.WVPythia.Services.pas` adapts Pythia events to the application;
- `Demo.OpenAI.Services.pas` connects behaviors that require the OpenAI client.

This is especially visible for the three async services: uploading an attachment to the Files API, indexing a knowledge file into a vector store, or transcribing a microphone capture are all OpenAI decisions, so they are installed where the `FClient: IGenAI` client already exists. The same principle applies to automatic session renaming: Pythia exposes `OnChatSessionAutoRename`, but the renaming strategy belongs to the vendor — here `TOpenAIClientUtils.ASyncSessionRename` calls a lightweight model (`gpt-4.1`) to produce a short title.

### 7.1.1. OpenAI API Key Management

The API key follows the same separation.

Pythia provides the generic storage infrastructure through `ApiKeySecretStore` and the `/api-key new ...` command. The OpenAI demo only decides the logical key name:

```pascal
API_KEY_NAME = 'openai';
```

When the vendor starts, the constructor tries to read this key:

```pascal
if not FBrowser.ApiKeySecretStore.ReadSecret(API_KEY_NAME, OpenAI_key) then
  FBrowser.TryHandleAsCommand(Format('/api-key new %s', [API_KEY_NAME]));
```

If the key is missing, Pythia opens its API key entry flow through the command system. If the key exists, the vendor creates its client:

```pascal
FClient := TGenAIFactory.CreateInstance(OpenAI_key);
```

When the user changes the key from Pythia, `Main.pas` receives the `OnApiKeyChanged` event and calls `OpenAIVendor.UpdateApiKey` only when the changed key is `openai`. `UpdateApiKey` then rereads the secret and updates `FClient.APIKey`.

This is useful for integrators: Pythia does not know vendor key names. It provides storage, the dialog, and the change event; each vendor chooses its identifier and knows how to apply the new value to its SDK.

### 7.2. Turn Routing

`AsyncAwaitStreamChat` is the main entry point. Unlike a pure chat demo, it first inspects `State.Media` and routes the turn to the right handler:

```pascal
if State.Media.CreateImage then            // -> TOpenAIImageTurn   (Images API)
if Length(State.Media.SpeechToText) > 0    // -> TOpenAISTTTurn     (transcription)
if State.Media.TextToSpeech then           // -> TOpenAITTSTurn     (speech synthesis)
else                                        // -> TOpenAITextTurn    (Responses streaming)
```

Each turn handler is self-contained (separate payloads, SDK entry points and callbacks), which keeps the streaming text flow isolated from the media flows.

### 7.3. The Streaming Text Flow

`Demo.OpenAI.TextTurn.pas` owns the regular chat turn:

1. transforms `TInputPromptState` into `TStateBuffer`;
2. selects the text generation model;
3. builds and validates the Responses payload;
4. starts `FClient.Responses.AsyncAwaitCreateStream`;
5. sends text/reasoning deltas to `FBrowser.DisplayStream`;
6. accumulates request/response JSON and captures any container files produced by tools;
7. finalizes through `TFinalizeData` + a single-call emit guard (`EmitGuard.TryEmit`).

On cancellation, the demo displays the content already received and still finalizes the turn.

The payload is assembled by focused sub-builders:

| Method | Role |
|---|---|
| `TMessageContentBuilder.BuildContentBlocks` | Converts text, images, documents (PDF/text) and uploaded files into Responses input content |
| `IContext.BuildMessages` | Rebuilds the multi-turn input (local replay), or sends only the new message when chaining with `previous_response_id` |
| `TRequestSettingsBuilder.Apply` | Applies system instructions, max tokens, temperature, top-p, `store`, etc. |
| `ThinkingBuilder` | Maps Pythia `thinking` state into the Responses reasoning effort/config |
| `OutputConfigBuilder` | Applies structured output (JSON schema) when enabled |
| `ToolsBuilder` | Enables `web_search`, `file_search` (vector stores), MCP servers, and skills (shell container) |

A few OpenAI-specific points are worth noting:

- **`store` and `previous_response_id` are coupled to context management.** When *Use previous ID* is on, `store` is forced on so the previous response can be chained; otherwise the context is rebuilt locally. This is covered in the demo README → [*Context management*](../demos/FMX/pythia-openai/README.md#context-management).
- **`file_search`.** When knowledge files were indexed (now, or in earlier turns), their `vector_store_id`s are attached as a `file_search` tool and `ToolChoice` is forced to `file_search` (unless a skill shell is also requested).
- **MCP.** MCP cards are read from `FMX_OpenAI-mcp-cards.json`; for the `github` card the PAT is substituted into the `authorization` placeholder before the server entry is added.
- **Skills.** All skills are referenced by `skill_id` (+ version `latest`) inside a shell container — OpenAI has no built-in document-skill family equivalent to Anthropic's `xlsx`/`pptx`/`pdf`/`docx`.

---

## 8. Demo Functional Coverage

This section lists what the demo actually covers. It is exhaustive for the demo, not for OpenAI.

| Feature | Coverage | Main files |
|---|---|---|
| Pythia FMX boot | Creates `TFMXPythia`, `AttachHost`, injects `ServiceAdapter`, `OnInitialized`, `Update` | `Main.pas` |
| DOM to Delphi bridge | Routes `input-submit` to `IChatManagedItemDialogService` | `source/WVPythia.Chat.EventManager.pas`, `source/WVPythia.Chat.EventHandlers.pas` |
| Vendor service | Delegates Pythia state to OpenAI | `FMX.WVPythia.Services.pas`, `Demo.OpenAI.Services.pas` |
| Turn routing | Dispatches to text / image / STT / TTS handlers from `State.Media` | `Demo.OpenAI.Services.pas` |
| API key | Storage through `ApiKeySecretStore`, `/api-key new openai`, token update | `Main.pas`, `Demo.OpenAI.Services.pas` |
| Chat streaming | `Responses.AsyncAwaitCreateStream`, text/reasoning deltas, cancellation, finalization | `Demo.OpenAI.TextTurn.pas` |
| Turn persistence | Return through `TManagedItemLLMResult`, preservation of `PromptJson`/`ResponseJson` | `Demo.OpenAI.TextTurn.pas`, `Demo.OpenAI.Finalize.pas` |
| Multi-turn context | Local replay from `PersistentChat`, or `previous_response_id` chaining | `Demo.OpenAI.Context.pas` |
| Text | Responses input text content | `Demo.OpenAI.Helpers.pas` |
| Images (vision) | Image input content from attachments | `Demo.OpenAI.Helpers.pas` |
| PDF / text / HTML / Markdown | Document content, with textual documents routed via the Files API | `Demo.OpenAI.Helpers.pas`, `Demo.OpenAI.Upload.pas` |
| zip/tar/gz archives | Upload through Files API, then referenced by `file_id` | `Demo.OpenAI.Upload.pas` |
| File upload state | JS statuses `uploading`, `ready`, `failed`, send button blocked during upload | `Demo.OpenAI.Upload.pas`, `source/WVPythia.Chat.Interfaces.pas` |
| Knowledge indexing (RAG) | Vector store per file (upload → ingest → embed → ready), `file_search` retrieval, persistent cache | `Demo.OpenAI.VectorFileStore.pas` |
| Web search | Adds the `web_search` tool when `WebSearch` is active | `Demo.OpenAI.TextTurn.pas` |
| Reasoning / thinking | Maps Pythia thinking to Responses reasoning effort/config | `Demo.OpenAI.TextTurn.pas`, `Demo.OpenAI.Helpers.pas` |
| Structured output | Uses the output JSON schema when enabled in the settings panel | `Demo.OpenAI.Helpers.pas`, `Demo.OpenAI.TextTurn.pas` |
| MCP | Reads MCP JSON cards, injects servers (PAT substitution for `github`) | `Demo.OpenAI.TextTurn.pas`, `bin64/FMX_OpenAI/support/FMX_OpenAI-mcp-cards.json` |
| Custom skill | Referenced by `skill_id` inside a shell container | `Demo.OpenAI.Helpers.pas`, `Demo.OpenAI.TextTurn.pas` |
| Custom skill synchronization | Lists custom OpenAI skills, searches by name, creates when absent, patches the local ID | `Demo.OpenAI.AsyncUtils.pas`, `Demo.OpenAI.Services.pas` |
| Image creation / editing | Images API: `/images/generations` and `/images/edits` | `Demo.OpenAI.ImageTurn.pas` |
| Text-to-speech | Audio creation turn | `Demo.OpenAI.TTSTurn.pas` |
| Speech-to-text / microphone | Built-in mic capture + Whisper transcription (`whisper-1`), text inserted at the caret | `Demo.OpenAI.STTTurn.pas`, `Demo.OpenAI.Services.pas`, `Demo.OpenAI.AsyncUtils.pas` |
| Agent cards | Five card-driven OpenAI agent examples, orchestrated Delphi-side | `Demo.OpenAI.TextTurn.pas`, `Demo.OpenAI.Agent.*`, demo `README.md` |
| Session rename | Short summary through `gpt-4.1`, then Pythia session rename | `Demo.OpenAI.AsyncUtils.pas` |
| Errors | Displays through `DisplayError`, finalizes with `Error`/`ErrorMessage` | `Demo.OpenAI.TextTurn.pas`, `Demo.OpenAI.Finalize.pas` |

What the demo intentionally does not cover:

- full native custom model selection dialog;
- full settings editing from Delphi;
- a complete server-side conversation manager (the OpenAI Conversations API);
- deep research;
- every tool and endpoint variant available from OpenAI.

These omissions are not Pythia limitations. They are scope choices that keep the demo readable.

---

## 9. Multi-Turn Context

The OpenAI-specific part is `Demo.OpenAI.Context.pas`. The Responses API offers two distinct continuity strategies, and the demo keeps them separate:

- **Local replay** (default): `BuildMessages` rebuilds the input by replaying the previous turns from `PersistentChat`. It clones the last historical user message and the prior `response.output` items verbatim — preserving opaque items such as tool calls/results — and re-attaches the `file_search` vector stores used earlier (`HistoricalVectorStoreIds`). Uploaded `file_id` content is dropped during replay because those temporary uploads may no longer exist. With `store` left off, nothing is retained on OpenAI's servers.

- **Cloud chaining** (*Use previous ID* on): the demo sends only the new user message and sets `previous_response_id` to the last stored response id; OpenAI reconstructs the prior context server-side. This requires the responses to be stored.

`ShouldUsePreviousResponseId` gates the cloud path on both the `usingPreviousId` setting **and** the presence of a known previous response id. The end-user behavior, and the data-retention trade-off, are documented in the demo README → [*Context management*](../demos/FMX/pythia-openai/README.md#context-management).

The demo intentionally does not use OpenAI's separate Conversations API: the two strategies above already cover its needs.

---

## 10. Runtime Files and Cards

The demo configuration files live in:

```text
bin64/FMX_OpenAI/support
```

The most important ones for this demo are:

| File | Role |
|---|---|
| `FMX_OpenAI-capabilities.json` | Enables the visible Pythia buttons and panels |
| `FMX_OpenAI-model-list.json` | Lists the models shown by the selector |
| `FMX_OpenAI-mcp-cards.json` | Declares MCP entries usable by the Skills/MCP panel |
| `FMX_OpenAI-skill-cards.json` | Declares the custom skill(s) |
| `FMX_OpenAI-agent-cards.json` | Declares the five agent-card examples |
| `FMX_OpenAI-custom-cards.json` | Demo custom cards (e.g. image-creation options) |
| `FMX_OpenAI-projects.json` | Registered project folders for the Project button |

Pythia handles card display. The vendor then reads the selections from `TInputPromptState.Integration` (and `TInputPromptState.Media` for the media turns).

Skill routing is done in `TParamsGetter.GetSkills`: every selected skill is forwarded as a `skill_id` reference (version `latest`). Unlike Anthropic, there is no built-in document-skill family — all skills are custom and identified by their server-side id read from the JSON card.

---

## 11. The `delphi-uses-graph` Custom Skill

The demo includes a custom skill in:

```text
bin64/FMX_OpenAI/delphi-uses-graph
```

Structure:

```text
delphi-uses-graph/
  SKILL.md
  reference.md
  scripts/
    tool.py
```

This skill analyzes a Delphi/Object Pascal project and extracts the `uses` dependency graph between units. It produces a Mermaid/DOT graph, an SVG when Graphviz is available, and a Markdown report.

It is especially well suited for this demo for four reasons:

- it is rare in the Delphi ecosystem;
- it can analyze the demo itself, which makes the result very concrete;
- it does not depend on an external service while the skill runs: uploading an archive is enough;
- it combines well with other tools, for example to produce or analyze a final report.

### 11.1. Local Card

The card lives in:

```text
bin64/FMX_OpenAI/support/FMX_OpenAI-skill-cards.json
```

It contains an entry like:

```json
{
  "name": "delphi-uses-graph",
  "commentaire": "source: custom - Delphi `uses` dependency graph (Mermaid/DOT/SVG + cycles)",
  "badge": "",
  "content": "custom",
  "id": "skill_..."
}
```

The ID is the OpenAI server-side skill id. It can be missing, obsolete, or different depending on the account.

### 11.2. ID Synchronization

On startup, `TOpenAIServices.SkillCustomRegister` extracts the custom cards, then calls:

```pascal
FClientUtils.CustomSkillRegister(Item.ID, Item.Name);
```

The logic in `Demo.OpenAI.AsyncUtils.pas` (`TOpenAIClientUtils`) is:

1. list custom skills on the OpenAI side;
2. search for a skill whose name matches the card `name`, for example `delphi-uses-graph` (`FindCustomSkillIDByName`, case-insensitive, following result pages);
3. if the skill exists and the local ID differs, update the JSON card;
4. if the skill does not exist, register the `bin64/FMX_OpenAI/delphi-uses-graph` bundle and write the returned id into the card.

This approach avoids depending on a stale local ID.

### 11.3. Recommended Demo Scenario

Prepare an archive of a Delphi project (the demo's [README](../demos/FMX/pythia-openai/README.md#discovering-the-skills-cards) suggests `assets/media/pythia-anthropic.zip` as a ready-made example), select the `delphi-uses-graph` skill in the Skills panel, and attach the archive to the prompt.

Example prompt:

```text
Here is an archive of my Delphi project. Use the delphi-uses-graph skill to produce the uses graph between units. Filter the prefixes System,Winapi,Vcl,FMX,Anthropic,WVPythia so only my Demo.* units remain. Display the Mermaid diagram inline, and summarize the most depended-on units as well as any cycles.
```

The model should then use the skill, run `scripts/tool.py`, read the report, embed the Mermaid diagram, and attach the produced artifacts.

---

## 12. Complete User Flow

A typical chat turn follows this path:

```text
1. The user types a prompt in the WebView.
2. The JS templates assemble the state: text, files, models, cards, settings.
3. The WebView posts an `input-submit` event.
4. TBrowserEventManager routes the event to the handlers.
5. The handlers deserialize a TInputPromptState.
6. TFMXChatManagedItemDialogService receives the state.
7. TToolContainer.ActivateInputState calls OpenAIVendor.AsyncAwaitStreamChat.
8. TOpenAIServices routes the turn and (for text) TOpenAITextTurn builds the Responses payload.
9. The SDK streams deltas.
10. The demo calls FBrowser.DisplayStream.
11. At the end, TFinalizeData produces a TManagedItemLLMResult.
12. Pythia persists the turn, updates the UI, and makes the session reusable.
```

This flow is the skeleton to reproduce for any other vendor.

---

## 13. Adapting Another Vendor

To replace OpenAI with another SDK, keep Pythia and replace only the vendor layer.

The steps are:

1. create a service equivalent to `TOpenAIServices`;
2. read `TInputPromptState` or `TStateBuffer`;
3. choose the model from `State.Models`;
4. convert files/images/settings into the target SDK format;
5. stream the response with `IPythiaBrowser.DisplayStream`;
6. produce a final `TManagedItemLLMResult`;
7. call `AOnFinalize`.

The Pythia side does not change:

```pascal
Pythia.ServiceAdapter := TFMXChatManagedItemDialogService.Create;
```

Only the target of this call changes:

```pascal
OpenAIVendor.AsyncAwaitStreamChat(AState, AOnFinalize);
```

For Anthropic, Gemini, or Mistral, the vendor service would have the same general shape, but different payload builders.

---

## 14. Watch Points

- Call the `AOnFinalize` callback, even on error or cancellation, so Pythia can close the turn cleanly (the demo uses a single-call emit guard for this).
- Preserve `PromptJson` and `ResponseJson` when the vendor needs them to rebuild history.
- Do not assume files are ready immediately: `IFileUploadService.PendingCount` and `IKnowledgeIndexingService.PendingCount` are used to block sending until uploads/indexing complete.
- `previous_response_id` only works on **stored** responses; keep the `store` setting consistent with the *Use previous ID* option.
- Pythia cards provide a UI selection; the vendor still has to interpret their content (skill ids, MCP server entries, image options).
- Custom skill IDs are account-specific on OpenAI; they must be synchronized, not hard-coded forever.

---

## 15. Summary

`FMX_OpenAI` is a vendor integration demo, not a complete OpenAI client.

It shows:

- how to host Pythia in an FMX application;
- how to receive `TInputPromptState` through the `ServiceAdapter`;
- how to convert that state into a Responses API request;
- how to route text, image, speech-to-text and text-to-speech turns;
- how to stream back to the UI;
- how to finalize with `TManagedItemLLMResult`;
- how to handle files, RAG, MCP, skills, and multi-turn context;
- how to declare and synchronize a useful custom skill, `delphi-uses-graph`.

Once this mechanism is understood, the same pattern can connect other vendors without changing Pythia's WebView2 layer.
