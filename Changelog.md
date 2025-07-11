### 2025, June 14 version 1.1.0 (**Getit version**)
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