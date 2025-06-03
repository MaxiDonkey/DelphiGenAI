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

#### 2025, May 27 version 1.0.6
- Fix “No mapping for the Unicode character exists in the target multi-byte code page.” <br > 
For the `v1/responses` endpoint, buffer the incoming chunks and process them only once they’re fully received to avoid the error. 

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