# Pythia OpenAI FMX Demo

- [GitHub MCP setup](#github-mcp-setup)
- [Discovering the skills cards](#discovering-the-skills-cards)
- [Discovering the agent cards](#discovering-the-agent-cards)
- [Context management](#context-management)
- [Demo architecture](#demo-architecture)
- [Where to dig in the code](#where-to-dig-in-the-code)
___

<br>

This demo mirrors the [Pythia Anthropic VCL demo](../../VCL/pythia-anthropic/README.md):
the same teaching scenarios are reproduced here, ported to the OpenAI ecosystem
(GenAI SDK, Responses API, `gpt-5`) and built with **FMX** instead of VCL. If you
already went through the Anthropic walkthrough, everything below will feel
familiar — only the vendor wiring changes.

<br>

## GitHub MCP setup

<p align="center">
  <img src="docs/images/screenshots/mcp-cards.png?raw=true" width="500"/>
</p>

The demo ships with a pre-wired GitHub MCP server entry, but it cannot connect to GitHub on its own — it needs a personal access token (PAT) issued from your GitHub account.

A second card, **Weather service**, is also pre-wired and needs no token: it points at a public demo MCP endpoint with `require_approval` set to `never`, so you can exercise the MCP flow with zero configuration before tackling the GitHub setup.

### 1. Create a Personal Access Token

1. Sign in to your GitHub account.
2. Open **https://github.com/settings/personal-access-tokens**.
3. Click **Generate new token** and follow the prompts. Pick the scopes you actually need; the demo does not require any specific scope by itself, the scopes you select will determine what the MCP server is allowed to do on your behalf.
4. Copy the generated token. GitHub only shows it once.

### 2. Register the token in the demo

Open the MCP cards configuration file shipped alongside the compiled demo:

```
bin64\FMX_OpenAI\support\FMX_OpenAI-mcp-cards.json
```

Locate the `github` entry and paste your PAT into the `pat` field, replacing the placeholder value:

```json
{
  "id": "github",
  "name": "Github",
  "commentaire": "GitHub access via PAT to be provided",
  "badge": "",
  "content": "{\"type\":\"mcp\",\"server_url\":\"https:\/\/api.githubcopilot.com\/mcp\/\",\"server_label\":\"Github\",\"authorization\":\"%s\",\"require_approval\":\"never\"}",
  "pat": "your github pat"
}
```

Save the file. The next time the demo loads the MCP card, the PAT is substituted into the `authorization` placeholder of `content` and the GitHub MCP server becomes usable.

### A note on automation

This step is intentionally manual in the demo. In a production application you would typically wrap PAT entry behind a small UI (for example a settings dialog backed by the OS secret store) and have the application write the token into the card itself, rather than asking the user to edit a JSON file by hand. We did not implement that flow here so the configuration surface stays explicit and easy to inspect while reading the demo.

## Security reminder

A GitHub PAT grants real access to your GitHub account. Treat the JSON file as you would any credential file:

- Do not commit it with a real token inside.
- Do not share it.
- Revoke the token from the GitHub settings page as soon as you no longer need it.

<br>

## Discovering the skills cards

<p align="center">
  <img src="docs/images/screenshots/skills-cards.png?raw=true" width="500"/>
</p>

To understand how the demo skill available from its card in the skills list works, you must provide a ZIP file containing a Delphi project and all of its source files.

The file available in the [assets\media\pythia-anthropic.zip](../../../assets/media) folder can be used as an example and attached to your prompt.

Next, try using the following text as your prompt:
> Here is an archive of my Delphi project. It uses the `delphi-uses-graph` skill to generate a graph of unit usage. It filters out the prefixes `System`, `Winapi`, `Vcl`, `FMX`, `Anthropic`, and `WVPythia` to keep only my Demo units.* It displays the Mermaid diagram online and summarizes the most dependent units (top fan-in) as well as any cycles.

<p align="center">
  <img src="docs/images/screenshots/skill-prompt.png?raw=true" width="500"/>
</p>

>[!NOTE]
>The skill is defined in the folder shown below and registered as a custom skill on the OpenAI side, making it usable from the demo. [delphi-uses-graph](../../../bin64/FMX_OpenAI/delphi-uses-graph)
>
>If it is not already registered, the OpenAI demo application handles the registration process. It also checks that the skill is available when the demo application starts.

<br>

# Discovering the agent cards

Five cards ship with the `FMX_OpenAI` demo. They reproduce the five Anthropic
demo cards, adapted to OpenAI. Run them in order — each one grants the agent a
bit more power.

| # | Card                       | What it shows                                  |
|---|----------------------------|------------------------------------------------|
| 1 | Research Analyst           | single agent, web search, no project needed    |
| 2 | Local Project Review       | sub-agent, read-only on your project           |
| 3 | Supervised Exploration     | same, but **asks** before each tool call       |
| 4 | Safe Code Patch            | proposes a unified diff, writes nothing        |
| 5 | Sandbox To Local Code Edit | edits a workspace copy, patches your disk after **your** confirmation |

> **No Managed Agents here.** OpenAI does not provide Anthropic-style Managed
> Agents. Pythia runs these cards through a vendor-specific OpenAI agent
> service: Delphi orchestrates the coordinator and sub-agent turns with the
> Responses API (`delphi_sequential` orchestration), exposes the allowed
> project tools, and handles the confirmation policy through the Pythia UI.

## Where the cards live

- **Registry (UI side):**
  [`bin64/FMX_OpenAI/support/FMX_OpenAI-agent-cards.json`](../../../bin64/FMX_OpenAI/support/FMX_OpenAI-agent-cards.json)
- **Inline JSON** for cards 1–3 (compact, fits in `content`).
- **Markdown definitions** for cards 4–5 (richer, referenced via `md_path`):
  - [`openai-safe-code-patch-agent.md`](../../../bin64/FMX_OpenAI/openai-safe-code-patch-agent.md?plain=1)
  - [`openai-sandbox-to-local-code-edit-agent.md`](../../../bin64/FMX_OpenAI/openai-sandbox-to-local-code-edit-agent.md?plain=1)

> Both links use GitHub's `?plain=1` raw view so the YAML front matter — which
> declares the agent's topology, tools and policies — stays visible. Without
> it, the rendered Markdown hides that header.

<br>

<p align="center">
  <img src="docs/images/screenshots/card-agent-selector.png?raw=true" width="500"/>
</p>

---

## Card 1 — Research Analyst

Single agent, `gpt-5`. OpenAI `web_search` is `always_allow`; nothing else.

**No project needed.**

**Try this:**
> Produce a short, sourced briefing on the public state of OpenAI's Responses
> API as of today. Group findings by theme, cite every claim with a URL, and
> flag anything you could not verify.

You should see interleaved tool calls and assistant text, with URL citations
in the final answer. No confirmation pops up.

<p align="center">
  <img src="docs/images/screenshots/Agent-prompt_1.png?raw=true" width="500"/>
</p>

---

## Card 2 — Local Project Review

Coordinator + sub-agent **Code Inspector**. Read-only: `read`, `glob`, `grep`
(`always_allow`). No write, no `edit`. Inspector reads at most 12 files.

**Setup:** click the **Project** button on the input bubble and pick a small
local folder. Pythia uploads a bounded copy of it and exposes it to the agent
through the project tools.

**Try this:**
> Review the selected project. Identify up to five concrete issues (correctness,
> safety, clarity), citing the exact file path for each. Group your answer as
> Findings / Severity / Recommendations.

You get three sections, each finding tied to a real path. Nothing is written.

<p align="center">
  <img src="docs/images/screenshots/Agent-prompt_2.png?raw=true" width="500"/>
</p>

---

## Card 3 — Supervised Exploration

Same shape as card 2, but the sub-agent's tools are `always_ask` — Pythia
prompts you before each call. The sub-agent has a tight budget: one `glob`,
up to three `read`, at most one `grep`.

**Setup:** same as card 2 (a small selected project).

**Try this:**
> Give me a one-paragraph summary of what this project is, plus a short list
> of its most notable files. Use the smallest number of tool calls.

The point here is to *experience* the confirmation dialogs (labels come from
[`Demo.OpenAI.Strs.pas`](Demo.OpenAI.Strs.pas)). Deny one to see the
clean *"Interrupted by the user."* path.

<p align="center">
  <img src="docs/images/screenshots/Agent-prompt_3.png?raw=true" width="500"/>
</p>

---

## Card 4 — Safe Code Patch

Multi-agent (Markdown-defined): **Code Locator** finds the spot, **Patch
Author** drafts a diff. Neither has `edit`. Coordinator reviews and returns
the diff in a fixed format.

**Setup:** any small selected project.

**Try this:**
> In the selected project, propose the smallest safe patch that improves
> one specific user-visible string for clarity. Pick the string yourself,
> explain the choice, then return the unified diff between the
> `PYTHIA_UNIFIED_DIFF_BEGIN/END` markers. Do not modify any file.

**Required answer shape** (three sections, in this order):

1. **Patch Summary** — files affected, intent.
2. **Unified Diff** between `PYTHIA_UNIFIED_DIFF_BEGIN` / `…_END`, in
   standard unified diff syntax with local relative paths in the `---` /
   `+++` headers.
3. **Validation Notes** — why the patch is narrow, suggested test or
   manual check.

Your disk is untouched: this card *proposes*, nothing more.

<p align="center">
  <img src="docs/images/screenshots/Agent-prompt_4.png?raw=true" width="500"/>
</p>

---

## Card 5 — Sandbox To Local Code Edit

The full round-trip. **Code Locator** finds, **Sandbox Editor** edits the
workspace copy (its `edit` tool is `always_ask`), the coordinator returns
**two** machine-readable blocks. Pythia spots them and asks *you* before
touching your local file.

**The boundary the card teaches:**
1. Your folder is prepared as a controlled project workspace for this run.
2. Agents edit only that workspace copy.
3. The answer returns a manifest + a unified diff.
4. Pythia — not the agent — applies the diff locally, after your confirmation.

The coordinator must never claim your disk was modified.

### Validation test (patches the demo's own source)

The point of this test is to let the agent **find the work itself** — no file
hint, no symbol name, just an intent and a contract.

**Setup — choose one of these two options:**

> ⚠️ The local apply step really modifies the file on disk. There is no
> built-in undo.

- **Recommended — work on a copy.** Duplicate `demos\FMX\pythia-openai`
  somewhere outside the repo (e.g. `D:\sandbox\pythia-openai-copy`) and
  point the **Project** button at that copy. You can throw the copy away
  afterwards.
- **Direct — work on the demo source itself.** Pick
  `demos\FMX\pythia-openai` directly. Commit or back up the folder
  first; otherwise the change is permanent for your working tree.

**Try this:**
> In the selected project, find the error message shown when an agent card
> is missing or unsupported (the one that mentions both *not found* and
> *unsupported*).
>
> Goal:
> - modify only that message so it states the card can be defined either
>   via `content` or via `md_path`;
> - touch a single file;
> - do not change any business behavior;
> - do not reformat code.
>
> Expected work:
> 1. locate the relevant file;
> 2. modify only the workspace copy with the `edit` tool if needed;
> 3. return the Local Apply Manifest between the
>    `PYTHIA_LOCAL_APPLY_MANIFEST_BEGIN` / `PYTHIA_LOCAL_APPLY_MANIFEST_END`
>    markers;
> 4. return the Unified Diff between the
>    `PYTHIA_UNIFIED_DIFF_BEGIN` / `PYTHIA_UNIFIED_DIFF_END` markers;
> 5. state the manual check to run after local application.

**Required answer shape** (four sections, in this order):

1. **Cloud Edit Summary** — workspace files changed, intent, local files
   expected to change.
2. **Local Apply Manifest** between `PYTHIA_LOCAL_APPLY_MANIFEST_BEGIN` /
   `…_END`. Key-value text (not JSON) with at least `root_hint`, `files`,
   and for each file `sandbox_path`, `local_relative_path`, `change_type`,
   `requires_user_confirmation`.
3. **Unified Diff** between `PYTHIA_UNIFIED_DIFF_BEGIN` / `…_END`.
4. **Validation Notes** — why the edit is narrow, suggested local check.

> **Path gotcha:** `local_relative_path` is relative to `root_hint`. If the
> sandbox path is `…/workspace/project/Foo.pas`, the local relative path is
> `Foo.pas`, **not** `project/Foo.pas`.

**What you should see, in order:**
1. `code-locator` globs/greps the project and reports back where the error
   message lives.
2. `sandbox-editor` asks before its `edit` call → you allow it.
3. The final answer contains both marker blocks above, with a real file
   path filled in and the new wording referencing `content` and `md_path`.
4. Pythia detects the markers and asks for a local-apply confirmation.
5. After you confirm, the matching `.pas` file on disk carries the new
   message; to see it live, temporarily break the cards registry (e.g.
   rename an agent `id` so it no longer matches the selection) and relaunch
   the demo — the new wording appears.

<p align="center">
  <img src="docs/images/screenshots/Agent-prompt_5.png?raw=true" width="500"/>
</p>

<br>

## Context management

<p align="center">
  <img src="docs/images/screenshots/previous-response-id.png?raw=true" width="500"/>
</p>

- When the ***Use previous ID*** option is enabled, the context for the current turn is built on the OpenAI side through `previous_response_id`. This only works on stored responses, so it requires the responses to be retained on OpenAI's servers, where the conversation state stays available.

- When the ***Use previous ID*** option is disabled, the Pythia demo rebuilds the context itself through `Demo.OpenAI.Context.pas`, taking into account the tools used during previous turns. Combined with the separate `store` setting left off (its default), nothing is retained on OpenAI's servers.

>[!NOTE]
>***Use previous ID*** and `store` are two distinct request settings (both off by default): chaining with `previous_response_id` only works while the prior responses are stored.

>[!NOTE]
>The demo offers two continuity strategies — local context rebuild, or cloud chaining via `previous_response_id` — which together cover its needs, so it does not rely on OpenAI's separate Conversations API.
>
>You can still implement your own layer on that API. If you do, keep in mind that the conversation data will then be retained on OpenAI's servers.

<br>

## Demo architecture

The demo is wired around a single entry point, `Demo.OpenAI.Services` (the
`IVendorServices` implementation). The host form (`Main`) and the FMX glue
(`FMX.WVPythia.Services`) create it; from there, every Pythia turn is routed to
one of four turn handlers, and a handful of shared foundation units do the
rendering, finalization and parsing.

The tree below groups the demo units (`Demo.OpenAI.*`) under that entry point.
Indentation reads as *"is used by its parent"*. Only internal units are shown —
the `GenAI.*` SDK and the `WVPythia.*` component units are left out.

```text
Demo.OpenAI.Services                       entry point — IVendorServices
│
├─ Turn handlers
│   ├─ Demo.OpenAI.TextTurn                 text turn + agent-card examples
│   │   └─ Agents
│   │       ├─ Demo.OpenAI.Agent.Cards
│   │       ├─ Demo.OpenAI.Agent.Markdown
│   │       ├─ Demo.OpenAI.Agent.ProjectReview
│   │       ├─ Demo.OpenAI.Agent.TurnDisplay
│   │       └─ Demo.OpenAI.Agent.LocalApply
│   ├─ Demo.OpenAI.ImageTurn                image creation / editing
│   ├─ Demo.OpenAI.STTTurn                  speech-to-text
│   └─ Demo.OpenAI.TTSTurn                  text-to-speech
│
├─ Conversation
│   └─ Demo.OpenAI.Context                  continuity (replay / chaining)
│
├─ Vendor async services
│   ├─ Demo.OpenAI.Upload                   file upload (Files API)
│   └─ Demo.OpenAI.VectorFileStore          knowledge indexing (RAG)
│
└─ Helpers / foundation                     shared by every handler above
    ├─ Demo.OpenAI.AsyncUtils
    ├─ Demo.OpenAI.DisplayBlocks
    ├─ Demo.OpenAI.Finalize
    ├─ Demo.OpenAI.Helpers
    ├─ Demo.OpenAI.JsonResponse.Helper
    └─ Demo.OpenAI.Strs
```

The *Helpers / foundation* units are not exclusive to `Services`: the turn
handlers and the agents reuse them too (rendering, finalization, parsing,
strings). They are listed once, at the bottom, to keep the tree flat.

### Unit responsibilities

| Unit | Role |
|------|------|
| `Demo.OpenAI.Services` | **Entry point.** `IVendorServices` implementation: routes each turn to a handler, wires the optional async services, owns the API key and session lifecycle. Also hosts `TOpenAITranscriptionService` (Whisper STT). |
| `Demo.OpenAI.TextTurn` | Streaming text turn over the Responses API; also drives the card-defined OpenAI agent examples (consumes the whole `Agent.*` layer). |
| `Demo.OpenAI.ImageTurn` | Image turn over the Images API — creation (`/images/generations`) and editing (`/images/edits`). |
| `Demo.OpenAI.TTSTurn` | Text-to-speech audio-creation turn. |
| `Demo.OpenAI.STTTurn` | Speech-to-text turn for an attached audio file. |
| `Demo.OpenAI.Context` | Conversation continuity: local replay vs. cloud chaining (`previous_response_id`); builds the Responses input items. |
| `Demo.OpenAI.AsyncUtils` | `IOpenAIClientUtils`: async client helpers (session rename, custom-skill registration, transcription, file download/delete, retrieval). |
| `Demo.OpenAI.Upload` | `IFileUploadService` (`TDownloadService`): offloads attachments to the Files API and references them by `file_id`. |
| `Demo.OpenAI.VectorFileStore` | `IKnowledgeIndexingService` (`TOpenAIKnowledgeIndexingService`): indexes knowledge files into a `file_search` vector store (RAG), with a persistent cache. |
| `Demo.OpenAI.DisplayBlocks` | Centralized rendering of assistant / status / tool display blocks. |
| `Demo.OpenAI.Finalize` | End-of-turn snapshot (`TFinalizeData`) and single-call emit guard. |
| `Demo.OpenAI.Helpers` | Shared payload helpers (e.g. message content builder). |
| `Demo.OpenAI.JsonResponse.Helper` | JSON response parsing helpers. |
| `Demo.OpenAI.Strs` | Localized demo strings (confirmation labels, etc.). |
| `Demo.OpenAI.Agent.Cards` | Typed agent-card model + JSON envelope loader. |
| `Demo.OpenAI.Agent.Markdown` | Markdown (YAML frontmatter) agent-card loader; complements `Agent.Cards`. |
| `Demo.OpenAI.Agent.ProjectReview` | Builds prompts and orchestrates the sequential coordinator / sub-agent turns over the selected project. |
| `Demo.OpenAI.Agent.TurnDisplay` | Display adapter for agent runs (assistant text, status, tool use/result). |
| `Demo.OpenAI.Agent.LocalApply` | Extracts the `PYTHIA_*` manifest + unified diff and applies it to the local project. |

<br>

## Where to dig in the code

| Layer                  | Units                                                                              |
|------------------------|------------------------------------------------------------------------------------|
| Card model & loading   | `Demo.OpenAI.Agent.Cards`, `Demo.OpenAI.Agent.Markdown`                            |
| Agent run & prompts    | `Demo.OpenAI.Agent.ProjectReview`, `Demo.OpenAI.Agent.TurnDisplay`                 |
| Local project bridge   | `Demo.OpenAI.Upload` (upload), `Demo.OpenAI.Agent.LocalApply` (apply manifest + diff) |
| Vendor flow & continuity | `Demo.OpenAI.Services`, `Demo.OpenAI.Context`                                     |

All units live under [`demos/FMX/pythia-openai`](.) with the
`Demo.OpenAI.` prefix.
