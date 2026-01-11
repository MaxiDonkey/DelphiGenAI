# Provider Support and OpenAI API Compatibility

GenAI is a **direct, one-to-one implementation** of the OpenAI API, designed to be used from Delphi in the absence of official vendor SDKs.

Support for other AI providers is therefore based on how closely their APIs align with OpenAI’s interface. Because there is **no formal or standardized generative AI API** across vendors, compatibility is limited to the **common subset of endpoints** they expose.

In practice, this subset primarily includes `v1/chat/completions`, with more limited and provider-dependent support for `v1/responses`. Endpoints, features, or behaviors outside this shared surface are vendor-specific and fall beyond what GenAI can support without breaking its strict OpenAI parity.

<br>

- [Client instantiation overview](#client-instantiation-overview)
- [Google Gemini compatibility](#google-gemini-compatibility)
- [Anthropic Claude compatibility](#anthropic-claude-compatibility)
- [DeepSeek compatibility](#deepseek-compatibility)
- [X-ai Grok compatibility](#x-ai-grok-compatibility)
- [Other vendor compatibility](#other-vendor-compatibility)
- [Frequently asked questions](#frequently-asked-questions)

<br>

___

>[!IMPORTANT]
> **Design boundary**: GenAI strictly implements the OpenAI API as-is. It does not introduce provider-specific extensions, fallbacks, or behavioral adaptations. Compatibility with non-OpenAI vendors is entirely determined by the API surfaces they expose.

<br>

## Client instantiation overview

GenAI provides explicit factory methods for creating API clients targeting specific providers or OpenAI-compatible endpoints. Each method onfigures the underlying client with the appropriate base URL and expected API surface.

The table below summarizes the available instantiation options.

| Provider / Target | Factory method | Notes |
|------------------|---------------|-------|
| OpenAI | `CreateInstance(apiKey)` | Default OpenAI API (`https://api.openai.com/v1`) |
| **LM Studio (local)** | `CreateLMSInstance([baseUrl])` | Local OpenAI-compatible server |
| Google Gemini | `CreateGeminiInstance(apiKey)` | OpenAI-compatible Gemini endpoint |
| Anthropic Claude | `CreateClaudeInstance(apiKey)` | Anthropic OpenAI compatibility layer |
| DeepSeek | `CreateDeepSeekInstance(apiKey)` | OpenAI-style `v1/chat/completions` |
| xAI Grok | `CreateGrokInstance(apiKey)` | Supports `/chat/completions` and `/responses` |
| Custom / External | `CreateExternalInstance(baseUrl, apiKey)` | Third-party OpenAI-compatible APIs |

All factory methods return an `IGenAI` instance and preserve strict OpenAI API parity.

<br>

## Google Gemini compatibility

Starting with version **1.4.2**, **DelphiGenAI** provides optional support for running **Google Gemini models** through an **OpenAI-compatible API surface**.
If you haven't configured an API key yet, refer to [Obtain an API Key](#obtain-an-api-key).

This integration allows Gemini models to be accessed using the same high-level abstractions and routing logic as OpenAI models, enabling seamless experimentation or hybrid deployments without changing application architecture.

This compatibility layer enables access to **recent and current Google Gemini models**, including the **Gemini 3 family**, as they are exposed through Google’s OpenAI-compatible API surface.

**DelphiGenAI** does not hardcode model versions and relies on the `/models` endpoint for discovery, allowing applications to automatically benefit from newly released Gemini models without requiring structural changes.

> [!NOTE]
> Gemini support is **partial**. Some OpenAI request properties are not supported by Gemini models and may be ignored or adapted internally.

### Supported endpoints

The following OpenAI-style endpoints are compatible with Gemini models when using `CreateGeminiInstance`:

| Endpoint | Supported | Notes |
|---|:---:|---|
| `/chat/completions` | <div align="center"><span style="color: green;">●</span></div> | Text-based chat completion |
| `/images/generations` | <div align="center"><span style="color: green;">●</span></div> | Image generation |
| `/embeddings` | <div align="center"><span style="color: green;">●</span></div> | Vector embeddings |
| `/models` | <div align="center"><span style="color: green;">●</span></div> | Model discovery |

When targeting **Gemini models**, support is currently limited to the endpoints listed above.

<br>

### Limitations and behavioral differences

While **DelphiGenAI** preserves a unified API surface, **Gemini models do not implement the full OpenAI feature set**.  
Certain request parameters, advanced capabilities, or response properties may be unavailable or behave differently.

All supported features, ignored parameters, and model-specific constraints are documented in detail here:

- [Google Gemini integration guide](guides/Gemini.md)

This document should be considered the **authoritative reference** for understanding how **DelphiGenAI** maps OpenAI semantics onto Gemini models.

<br>

### Client Instantiation

```pascal
  Client := TGenAIFactory.CreateGeminiInstance(api_Key);
```

<br>

## Anthropic Claude compatibility

Anthropic provides an OpenAI-compatible API layer that allows Claude models to be accessed through the `v1/chat/completions` endpoint.

When used with GenAI, Claude support is therefore limited to this endpoint and depends entirely on Anthropic’s OpenAI compatibility layer. No attempt is made to adapt, extend, or normalize Claude-specific features beyond OpenAI semantics.

This compatibility layer is explicitly described by Anthropic as a convenience mechanism for evaluation and comparison purposes. For access to Claude’s full feature set (Structured Outputs, extended reasoning, PDF processing, citations, prompt caching, and other native capabilities), the official Anthropic API must be used.

<br>

### Supported endpoints

| Endpoint | Supported | Notes |
|--------|-----------|------|
| `/chat/completions` | ● | Text-based chat completion |

<br>

### Notes and behavioral differences

- System and developer messages are internally concatenated into a single initial system prompt.
- Unsupported OpenAI request fields are silently ignored by the Claude compatibility layer.
- Error formats follow OpenAI conventions, but error messages may differ.

For a detailed and authoritative description of supported fields and limitations, refer to:

[Anthropic OpenAI compatibility documentation](https://platform.claude.com/docs/en/api/openai-sdk)

<br>

### Client Instantiation

```pascal
  Client := TGenAIFactory.CreateClaudeInstance(api_Key);
```

<br>

## DeepSeek compatibility

DeepSeek exposes an API surface that closely mirrors the OpenAI `v1/chat/completions` endpoint, making it naturally compatible with GenAI’s one-to-one OpenAI API implementation.

Because this compatibility is achieved through a request and response structure that is very aligned to OpenAI’s `v1/chat/completions`, DeepSeek models can be used with GenAI without requiring a dedicated provider-specific integration.

<br>

### Supported endpoints

| Endpoint | Supported | Notes |
|--------|-----------|------|
| `/chat/completions` | ● | Text-based chat completion |

<br>

### Notes

- Support is limited to the OpenAI-style `v1/chat/completions` endpoint.
- The `v1/responses` endpoint is not supported by DeepSeek at this time.
- Vendor-specific APIs, alternative compatibility layers (such as Anthropic-style
  interfaces), and extended features are outside the scope of GenAI.

GenAI relies exclusively on OpenAI-compatible semantics and does not integrate or [document DeepSeek-specific](https://api-docs.deepseek.com/) API variants.

<br>

### Client Instantiation

```pascal
  Client := TGenAIFactory.CreateDeepSeekInstance(api_Key);
```

<br>

## X-ai Grok compatibility

The xAI Grok API exposes endpoints whose request and response structures are closely aligned with OpenAI’s `v1/chat/completions` and `v1/responses` semantics.

Based on direct validation, these endpoints can be used with GenAI without introducing any Grok-specific integration layer. Both streaming and non-streaming modes are supported for the tested endpoints.

<br>

### Supported endpoints

| Endpoint | Supported | Notes |
|--------|-----------|------|
| `/chat/completions` | ● | Text-based chat completion |
| `/responses` | ● | Unified response endpoint |

<br>

### Scope and limitations

- Compatibility is based on observed behavior and validated request/response formats.
- Only the endpoints listed above have been tested and are considered supported.
- Other xAI endpoints, features, or extensions have not been evaluated and may not behave consistently with OpenAI semantics.
- GenAI does not attempt to discover, adapt, or document xAI-specific API features.

Users interested in additional Grok capabilities should refer to the official [xAI documentation](https://docs.x.ai/docs) and SDKs.

<br>

### Client Instantiation

```pascal
  Client := TGenAIFactory.CreateGrokInstance(api_Key);
```

<br>

## Other vendor compatibility

GenAI also allows creating a configurable instance that targets a **custom external API endpoint**
via `CreateExternalInstance`.

This mechanism is intended for APIs that are **compatible or partially compatible with the OpenAI API** and that expose a similar HTTP and JSON contract. GenAI does not perform any automatic adaptation, normalization, or feature discovery for external providers.

When using an external endpoint, the caller is responsible for ensuring that:
- The provided `BaseUrl` points to a valid API root (commonly ending with `/v1`, but not necessarily, depending on the provider).
- The target service actually supports the OpenAI-style routes being invoked (such as `/chat/completions` or `/responses`).

> **Compatibility note**  
> Because external endpoints may diverge from OpenAI semantics, full GenAI functionality
> is **not guaranteed**. Unsupported endpoints, request fields, or response schemas may result
> in runtime API errors. GenAI deliberately does not attempt to compensate for or abstract
> provider-specific behavior.

The examples below illustrate how to configure GenAI for third-party services that expose an OpenAI-compatible interface.

<br>

### GroqCloud

```pascal
  var GroqCloudUrl := 'https://api.groq.com/openai/v1';
  var GroqCloudKey := 'gsk_key';
  Client := TGenAIFactory.CreateExternalInstance(GroqCloudUrl, GroqCloudKey);
``` 

This configuration has been **validated** using the OpenAI-style `v1/chat/completions` endpoint with the model:
- `qwen/qwen3-32b`

While only this model/endpoint combination has been explicitly tested, GroqCloud provides a relatively homogeneous execution environment. Other chat-capable models exposed through the same OpenAI-style endpoint are expected to behave similarly, although this has not been individually validated within GenAI.

<br>

### Hugging Face

```pascal
  var HuggingFaceUrl := 'https://router.huggingface.co/v1';
  var HuggingFaceKey := 'hf_key';
  Client := TGenAIFactory.CreateExternalInstance(HuggingFaceUrl, HuggingFaceKey);
```

This configuration has been validated using the OpenAI-style v1/chat/completions endpoint with the model:
- `google/gemma-3-27b-it:scaleway`

Because Hugging Face exposes a very large and rapidly evolving catalog of models, it can serve as a valuable experimentation platform for testing recent architectures and capabilities, provided that the selected model is served through an OpenAI-compatible inference endpoint.

Model availability, parameter support, and runtime behavior vary by provider and deployment backend. GenAI does not attempt to detect or adapt to these differences.

<br>

## Frequently asked questions

**Does GenAI guarantee full compatibility with non-OpenAI providers?**  
No. Compatibility depends entirely on the API surface exposed by each provider.

**Why is `v1/chat/completions` the most widely supported endpoint?**  
It is currently the most stable and commonly implemented interface across vendors.

**Will GenAI add provider-specific features in the future?**  
No. GenAI intentionally preserves strict OpenAI API parity.