#### 2025
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