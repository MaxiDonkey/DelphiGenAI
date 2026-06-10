# Guides

Index of every guide in this folder, organized in three parts: what's new in 2.0.0, the OpenAI API endpoints, and the remaining topic guides.

___

<br>

## What's new in 2.0.0

If you are upgrading, start here for an overview of the architectural changes introduced in version 2.0.0 and what they mean for SDK users.

- [Version 2.0.0 — what changed under the hood](Version2News.md)

<br>

___

## OpenAI API

Guides for each OpenAI capability, beginning with the two core text APIs, then the other features in the order of the README functional-coverage table. The matching endpoint is given in parentheses for reference only.

- [Text generation & agents](Responses.md#responses) — the modern core API for text, vision, reasoning and built-in tools (web/file search, function calling, MCP, code interpreter). *(`v1/responses`)*
- [Chat completions](ChatCompletion.md#chat-completion) — the classic chat API: text, vision, audio and reasoning. *(`v1/chat/completions`)*
- [Text to speech](Audio.md#text-to-speech) — generate spoken audio from text. *(`v1/audio/speech`)*
- [Speech to text](Audio.md#speech-to-text) — transcribe an audio file into text. *(`v1/audio/transcriptions`)*
- [Audio translation](Audio.md#speech-to-text) — translate spoken audio into English text. *(`v1/audio/translations`)*
- [Batch processing](Batch.md#batch) — run large sets of requests asynchronously, at lower cost. *(`v1/batches`)*
- [Legacy text completions](Legacy.md#legacy) — the older completion API, kept for backward compatibility. *(`v1/completions`)*
- [Code Interpreter containers](Containers.md#containers-managment) — create and manage the sandboxes that run the Code Interpreter tool. *(`v1/containers`)*
- [Conversations](Conversations.md#conversations) — persist and reuse conversation state across requests. *(`v1/conversations`)*
- [Embeddings](Embeddings.md#embeddings) — turn text into vectors for search and similarity. *(`v1/embeddings`)*
- [Files](Files.md#files) — upload and manage files used by other features. *(`v1/files`)*
- [Fine-tuning](FineTuning.md#fine-tuning) — train a customized model on your own data. *(`v1/fine_tuning`)*
- [Image generation & editing](Images.md#image-generation) — create and edit images. *(`v1/images`)*
- [Models](Models.md#models) — list and inspect the available models. *(`v1/models`)*
- [Moderation](Moderation.md#moderation) — check content against the usage policies. *(`v1/moderations`)*
- [Realtime](Realtime.md#realtime) — low-latency streaming audio/text interactions. *(`v1/realtime`)*
- [Skills](Skills.md#skills) — package reusable, executable capabilities the model can use on demand. *(`v1/skills`)*
- [Uploads](Uploads.md#uploads) — send very large files in multiple parts. *(`v1/uploads`)*
- [Vector stores](VectorStore.md#vector-store-managment) — managed databases that power file search. *(`v1/vector_stores`)*

<br>

___

## More guides

Cross-cutting topics and helpers that are not tied to a single endpoint.

- [About this project](GenAI.md#about-this-project) — what DelphiGenAI is, its design, and how the documentation is organized.
- [Response payload helpers](ResponseHelper.md) — a fluent layer (`GenAI.Helpers`) to compose `v1/responses` payloads without manipulating raw arrays.
- [Deep Research](DeepResearch.md#deep-research) — implement OpenAI's autonomous, multi-step research workflow.
- [Run models locally with LM Studio](LMStudio.md#run-models-locally-with-lm-studio) — route your calls to a local, OpenAI-compatible LM Studio server.
- [Use Google Gemini models](Gemini.md) — target Google's Gemini models through their OpenAI-compatible surface.
- [Provider support & OpenAI API compatibility](Provider-Support-and-OpenAI-API.md) — which third-party OpenAI-compatible providers work, and what their limits are.
