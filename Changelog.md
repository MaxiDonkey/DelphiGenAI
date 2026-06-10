#### 2026, June 9 version 2.0.0

**Helpers**

- Added `GenAI.Helpers.pas`, a fluent layer over `GenAI.Responses.InputParams` (reached through the `Generation` facade) that simplifies writing `v1/responses` payloads and rebuilding a session context — multi-turn input with replayed assistant messages.

<br>

**Skills API**

- Added `GenAI.Skills.pas`: full coverage of the OpenAI Skills API through `Client.Skills` (create, list, retrieve, update the default version, delete, download the bundle) and `Client.Skills.Versions` (create, list, retrieve, delete and download immutable skill versions).

<br>

**Responses API**

- Extended the `v1/responses` coverage with new request parameters: `PromptCacheRetention` (`in_memory` / `24h` extended prompt caching) and `ContextManagement` (automatic `compaction` driven by a `compact_threshold`).
- Added the `Compact` / `AsynCompact` / `AsyncAwaitCompact` operation (`responses/compact`) returning a `TResponseCompaction` for stateless context-window compaction.
- Added support for new built-in tools: local/function shell, apply patch, skills, tool search, namespace, web search filters, file-search ranking options, `allowed_tools` tool choice, and Code Interpreter container network policy.

<br>

**Containers API**

- Aligned `GenAI.Containers.pas` and `GenAI.ContainerFiles.pas` with the latest OpenAI Containers API: new container creation parameters (`MemoryLimit`, `NetworkPolicy` with allowlist and domain secrets, `Skills`), additional container fields (`memory_limit`, `network_policy`, `last_active_at`), and a `SaveToFile` method on container file content.

<br>

**Architecture & low-level layers** (details in the [Version 2.0.0 — what changed under the hood](guides/Version2News.md) guide)

- Realigned the low-level layers on the Anthropic SDK design so both SDKs share the same deserialization, type and streaming model.
- Reworked deserialization into a two-step pass with a rehydration phase: the raw JSON is bound to every `TJSONFingerprint` and each DTO rebuilds its polymorphic content in `AfterDeserialize` (the legacy path-based `GenAI.API.Normalizer` is removed).
- Hardened metadata handling for robustness and safety with `GenAI.API.JSONShield` (shields free-form protected fields), `GenAI.Types.Rtti` (safe RTTI member access) and a bounded graph traversal in the fingerprint binder.
- Rewrote the type layer on top of `GenAI.Types.EnumWire`: centralized enum ↔ wire conversion with an `sdk_unknown` fallback, so unknown server-side values no longer break deserialization.
- Improved polymorphic handling of `v1/responses` payloads in `GenAI.Responses.OutputParams.pas` (polymorphic fields excluded from default marshalling and rebuilt from the raw JSON).
- Added event-level streaming for `v1/responses`: `GenAI.Responses.StreamCallbacks.pas` (per-event callbacks + aggregation buffer) and `GenAI.Responses.StreamEngine.pas` (event engine/dispatcher), alongside the existing session/progress callback.
- Added `GenAI.Net.MediaCodec.pas` for unified base64 / data URI / MIME handling (encode/decode with safe `Try*` variants, MIME resolution, URL fetch).

<br>

**Removal of the Assistants API units**

Deprecated since version 1.3.0 (following OpenAI's August 26, 2025 deprecation announcement), the Assistants API units are now **removed** from the wrapper:

- `GenAI.Assistants.pas`
- `GenAI.Messages.pas`
- `GenAI.Threads.pas`
- `GenAI.Runs.pas`
- `GenAI.RunSteps.pas`

Migrate any remaining integrations to the `v1/conversations` and `v1/responses` endpoints, which supersede this API.
The last release shipping these units is **1.4.3**; their sources remain available there for reference and backward compatibility.

<br>

**Removal of the Sora video API**

The `v1/videos` endpoint (Sora text-to-video / image-to-video generation) introduced in 1.3.0 is now **removed**:

- `GenAI.Video.pas`

<br>

**Documentation**

- Removed the *Deprecated* (Assistants, Threads, Messages, Runs, Run steps) and *Videos* guides from the `guides` folder.
- Updated the README functional coverage table and endpoint references accordingly.
- Refreshed the *Containers* guide to document the new container parameters, fields and the `SaveToFile` helper.
- Refreshed the *Responses* guide to document prompt cache retention, context management / compaction and the new 2.0.0 tools.
- Added a *Skills* guide covering skill and skill-version management.

<br>

#### 2026, January 11 version 1.4.3

Added explicit support for multiple **OpenAI-compatible third-party providers** through dedicated factory methods and a configurable external endpoint.

  GenAI remains a strict, one-to-one implementation of the OpenAI API.
  Compatibility with non-OpenAI vendors depends entirely on the API surface they expose.

  Newly documented provider integrations include:

  - **Anthropic Claude**
    ```pascal
    Client := TGenAIFactory.CreateClaudeInstance(apiKey);
    ```
    Uses Anthropic’s OpenAI compatibility layer.
    Support is limited to the `v1/chat/completions` endpoint.

  - **DeepSeek**
    ```pascal
    Client := TGenAIFactory.CreateDeepSeekInstance(apiKey);
    ```
    Near-aligned with OpenAI’s `v1/chat/completions` endpoint.
    No support for `v1/responses` at this time.

  - **xAI Grok**
    ```pascal
    Client := TGenAIFactory.CreateGrokInstance(apiKey);
    ```
    Validated support for both `v1/chat/completions` and `v1/responses`
    (streaming and non-streaming).

  - **Generic OpenAI-compatible endpoints**
    ```pascal
    Client := TGenAIFactory.CreateExternalInstance(baseUrl, apiKey);
    ```
    Allows targeting third-party services exposing an OpenAI-style HTTP/JSON API
    (e.g. GroqCloud, Hugging Face).

- Added comprehensive documentation section:
  **“Provider Support and OpenAI API Compatibility”** describing supported endpoints, limitations, and design boundaries.

- Clarified design constraints: GenAI does not introduce provider-specific extensions, fallbacks, or behavioral adaptations. Unsupported fields or endpoints may result in runtime API errors.

<br>

#### 2025, December 13 version 1.4.2
- Added optional support for running Google Gemini models

```pascal
var GeminiKey := 'my_gemini_key';
var Client := TGenAIFactory.CreateGeminiInstance(GeminiKey);              
```
Creates a **GenAI** instance configured to target Google's Gemini models through an OpenAI-compatible API surface. 
Gemini models can be accessed using the OpenAI-style routes provided by this library.

<br>

- Internal HTTP access hardening (API unit)
Replaced direct `HttpClient.Get/Post/...` calls with per-request clients created via `NewHttpClient`.
This centralizes and enforces HTTP configuration/validation (timeouts, proxy settings, API settings checks), improves isolation between requests, and makes the transport layer easier to control and mock for tests. 

<br>

#### 2025, December 1 version 1.4.1
- Added `TContent` fluent builder to compose `TArray<TItemContent>`: .AddPrompt/.AddImage/.AddFile/.AddAudio + implicit cast to TArray<TItemContent>.
- Improved data URI support: GetMimeType extracts MIME from data: and GetUrlOrEncodeBase64 now passes through data: inputs (no re-encoding).
- Added `TDataURI` (GenAI.NetEncoding.DataURI) to build data: URIs from TBytes, TStream, and text (CreateText with charset, optional Encoding, optional BOM).
- Hardened `GenAI.Httpx` helpers: stronger input validation and explicit rejection of data: in URL-only methods.

<br>

### 2025, November 27 version 1.4.0 (**GetIt version**)
- Added optional support for running models locally via ***LM Studio***.
  You can now route all calls through an OpenAI-compatible ***LM Studio*** server by using:

```pascal
var Client := TGenAIFactory.CreateLMSInstance;               // default http://127.0.0.1:1234/v1
// or:
var Client := TGenAIFactory.CreateLMSInstance('http://...'); // "/v1" is appended automatically when missing
```

<br>

#### 2025, October 30 version 1.3.1

- **Added the `web_search` enumeration value** to the `TResponseToolsType` enum *(unit: `GenAI.Types`, line 1832)*.

- **Fixed memory management** by explicitly releasing the container in the `TResponseCodeInterpreter` class to prevent an error when freeing a `TResponse` instance that uses the Code Interpreter tool (unit: `GenAI.Responses.OutputParams`, line 1689).

- **Extended tool choice system** by adding the `TMCPToolParams` and `TCustomToolChoiceParams` classes, both derived from `TResponseToolChoiceParams`.

<br>

#### 2025, October 19 version 1.3.0 

**Deprecation of Assistants API units**

OpenAI announced the deprecation of the Assistants API on August 26, 2025, with permanent removal scheduled for August 26, 2026.  
The following units are now marked as deprecated within the wrapper:

- `GenAI.Messages.pas`  
- `GenAI.Threads.pas`  
- `GenAI.Run.pas`  
- `GenAI.RunSteps.pas`

These remain functional for backward compatibility but should no longer be used for new developments. Migration to the `v1/conversations` and `v1/responses` endpoints is strongly recommended.  
A dedicated Assistants-to-Conversations migration guide has been added to the documentation.

<br>

**New API endpoint: `v1/conversations`**

- Implements the new Conversations API introduced by OpenAI in March 2025.
- Enables persistent conversation management and structured context building for use with `v1/responses`.
- New Delphi types (`TConversation`, `TConversationMessage`, etc.) for creating, updating and listing conversation threads.
- Supports streamed responses, tool execution, system/developer messages, caching (`prompt_cache_key`) and safety identifiers.

<br>

**New API endpoint: `v1/containers` (Code Interpreter execution environment)**

- Full support for creating and managing remote execution containers used by the Code Interpreter tool.
- File upload, Python code execution, artifact retrieval and container lifecycle are now available through the `GenAI.Containers.*` namespace.
- Provides low-level control over execution state and outputs.

<br>

**New API endpoint: `v1/video` (Sora video generation)**

- Adds access to OpenAI’s Sora API for text-to-video and image-to-video generation with audio.
- Task status tracking supported (`queued`, `in_progress`, `completed`, `failed`).
- New `GenAI.Video.*` units cover request/response typing, metadata (resolution, duration, fps, audio inclusion, seed, safety information, etc.).

<br>

**Realtime API (separate module)**

Although outside the core HTTP-based GenAI wrapper, a separate implementation has been introduced to support OpenAI’s Realtime API (WebRTC):

- Real-time audio/text/vision streaming interactions with models.
- Supports live reasoning, tool usage and code execution.
- Documented in the project's *Realtime* section. This module is optional and not required for standard REST usage.

<br>

**Additional updates**

- Documentation (README, TutorialHub) updated to reflect the Conversations + Responses workflow.
- Compiler warnings added for deprecated Assistants API units.
- `InputParams` and `OutputParams` updated to maintain compatibility with new endpoints.
- Foundation prepared for the complete removal of Assistants API in a future release.

<br>

#### 2025, August 14 version 1.2.1
- Fix the destructor `TResponseOutputComputer.Destroy;` method in `GenAI.Responses.OutputParams module`.

<br>

#### 2025, August 12 version 1.2.0 
**Modifications to ensure full use of the gtp-5 model**

- JSON Normalization Before Deserialization
  - New `GenAI.API.Normalizer` module (`TJSONNormalizer`, `TWrapKind`, `TNormalizationRule`) to unify polymorphic fields (e.g., string vs. object).
  - Direct integration in the HTTP layer: new `Get(..., Path)` overloads allow targeted normalization of a JSON subtree before object mapping.

- Canceling Background Requests
  - New `Responses.AsyncAwaitCancel(response_id)` method to cancel an asynchronous (`background = true`) response, with full callback support (`OnStart`, `OnSuccess`, `OnError`).

- Streaming Enhancements
  - Extended typed coverage for streaming events and outputs (MCP, Code Interpreter, Image Generation, etc.) via new `Responses.OutputParams` classes (`TResponseOutput*`, `TResponseImageGenerationTool`, `TResponseCodeInterpreter`, etc.).

- New Types and Parameters
  - InputParams: full coverage for computer interactions, local shell, MCP, web search, code, image generation, reasoning, text/JSON formats, tool choice/hosted tool, and file search filters.
  - OutputParams: states (`Created`, `InProgress`, etc.), events (`Added`, `Delta`), usage metrics, and statistics.
  - New enums (`TOutputIncluding`, `TReasoningGenerateSummary`, `TFidelityType`, etc.).

- API `v1/chat/completions`
  - New parameters:
    - `prompt_cache_key` (prompt caching)
    - `safety_identifier` (stable ID for safety monitoring)
    - `verbosity` (low/medium/high)

- API `v1/responses`
  - New parameters:
    - `max_tool_calls`
    - `prompt` (template reference via `TPromptParams`)
    - `prompt_cache_key`, `safety_identifier`
    - `stream_options`, `top_logprobs`, `verbosity`

- Structured System and Developer Messages
  - New overloads:
    - `TMessagePayload.Developer(const Content: TArray; const Name: string = '')`
    - `TMessagePayload.System(const Content: TArray; const Name: string = '')`
  - Improves parity between plain text and structured content flows.

<br>

#### 2025, June 14 version 1.1.0 
- Given the project’s rapid progress, it’s now essential to embed versioning directly into the GenAI wrapper’s source code. For any client implementing the IGenAI interface, the version number can be retrieved via the Version property, for example:
```Delphi
var version = Client.Version;
```
- `Async/await` methods have been rolled out across all APIs with sensitive endpoints. Consequently, the tutorial’s code snippets have been enriched to provide readers with ready-to-use examples via ***TutorialHub***.

- For endpoints dedicated to `fine-tuning` and `batch` processing, adding ***async/await*** isn’t relevant—those operations can incur significant response delays—so only the asynchronous approach has been adopted.

- The endpoints responsible for configuring and running assistants haven’t been updated, as OpenAI plans to remove that functionality in the near future.

- The demonstration project code for [file2knowledge](https://github.com/MaxiDonkey/file2knowledge), which leverages the `v1/responses` endpoint, has been updated to include advanced usage examples using asynchronous (async/await) methods. You can check out the units in the [`Providers`](https://github.com/MaxiDonkey/file2knowledge/tree/main/providers) folder to explore the various illustrations. Finally, the `GenAI` tutorial will automatically insert links to this project whenever they prove relevant.

- `AsyncAwaitCreateStream` now handles the error event directly, immediately rejecting the promise on the `v1/responses` endpoint. 

<br>

#### 2025, June 4 version 1.0.7 
- Added streaming events to the `v1/responses` endpoint.
    - response.image_generation_call.completed
    - response.image_generation_call.generating
    - response.image_generation_call.in_progress
    - response.image_generation_call.partial_image
    - response.mcp_call.arguments.delta
    - response.mcp_call.arguments.done
    - response.mcp_call.completed
    - response.mcp_call.failed
    - response.mcp_call.in_progress
    - response.mcp_list_tools.completed
    - response.mcp_list_tools.failed
    - response.mcp_list_tools.in_progress
    - response.queued
    - response.reasoning.delta
    - response.reasoning.done
    - response.reasoning_summary.delta
    - response.reasoning_summary.done

- Expanded the v1/responses endpoint with new tools:
   - **Code Interpreter:** lets models write and run Python to solve problems.
   - **Image Generation:** enables models to create or edit images.
   - **Remote MCP:** allows models to delegate tasks to remote MCP servers.

- Introduced `AsyncAwaitCreate` and `AsyncAwaitCreateStream` methods for `v1/responses`; these are intended to replace `AsyncCreate` and `AsyncCreateStream`. 
    - Allow chaining of asynchronous processing in the form of a pipeline
    - Refer to [`GenAI.Responses.pas`](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/source/GenAI.Responses.pas) unit.
    - Eventually, many other wrapper methods will be adapted to meet this principle.

- Added the `GenAI.Async.Promise` unit, providing **JavaScript-style** asynchronous task chaining.

<br>

#### 2025, May 27 version 1.0.6
- Fix “No mapping for the Unicode character exists in the target multi-byte code page.” <br > 
For the `v1/responses` endpoint, buffer the incoming chunks and process them only once they’re fully received to avoid the error. 

<br>

#### 2025, May 27 version 1.0.5
- Fix Stream Events v1/responses endpoint

- `gpt-image-1`: Support for new image creation and editing model

- Fix GenAI.Schema.pas, [issue #6.](https://github.com/MaxiDonkey/DelphiGenAI/issues/6)

- `v1/responses` add streaming events : Allowing you to follow reasoning during a streamed call <br>
      - response.reasoning_summary_part (added & done )  <br>
      - response.reasoning_summary_text (delta & done)  <br>

<br>

#### 2025, April 19 version 1.0.3
- `v1/responses` end point management for agent construction : <br>
 The Responses API combines the simplicity of `v1/chat/completions` with built‑in tools (web search, file exploration, system automation) to power action‑oriented applications.

- Stored `v1/chat/completions` Management : <br>
  Full CRUD operations on saved conversations and completions.

- Parallel‑Mode Web Search (`v1/chat/completion` & `v1/responses`) : <br> 
  Simultaneous execution of queries for `v1/chat/completions` and `v1/responses` to accelerate and enrich results.

- Optimized SSE Algorithm for Streaming : <br>
  Enhanced reception and parsing of SSE streams for improved efficiency and speed.

<br>

#### 2025, March 12 version 1.0.2
- Web search 

- Parallel mode - add "system" parameter

<br>

#### 2025, February 28 version 1.0.1
- Http request monitoring.

- Background execute prompt batch 