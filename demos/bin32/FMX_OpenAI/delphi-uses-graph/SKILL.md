---
name: delphi-uses-graph
description: Analyzes a Delphi / Object Pascal codebase to extract unit-level `uses` dependencies. Use when the user uploads a zip / archive of a Delphi project, or a folder of .pas / .dpr / .dpk files, and asks for a dependency graph, architecture map, cycle detection, fan-in / fan-out coupling analysis, or wants to know how units relate. Produces a Mermaid diagram, Graphviz DOT, optional SVG, JSON dependency dump, and markdown report.
---

# Delphi uses-graph skill

This skill builds a directed graph of `uses` dependencies between Delphi /
Object Pascal units, computes coupling metrics, and detects circular
dependencies.

## OpenAI Responses container note

This OpenAI-adapted bundle is intended to be registered through the OpenAI
Skills API and attached to a Responses shell/container tool as a
`skill_reference`. The analysis logic is vendor-neutral; the OpenAI-specific
requirement is that the container can run Python and can read the uploaded
Delphi project files.

## When to use this skill

- The user uploads an archive (`.zip`, `.tar`, `.tar.gz`) containing a Delphi
  project, or a folder of `.pas` / `.dpr` / `.dpk` sources, and asks for an
  architecture map or a dependency graph.
- The user asks "which unit depends on what?", "are there cycles?",
  "what's the fan-in / fan-out?" against a Delphi codebase.
- The user wants a visual artifact (Mermaid, SVG, DOT) summarizing unit-level
  coupling.

Do not use this skill for non-Pascal codebases.

## Inputs

The skill expects exactly one of:

1. A `.zip` / `.tar` / `.tar.gz` archive of a Delphi project.
2. A directory already containing `.pas`, `.dpr`, or `.dpk` files.

If the user pastes raw Pascal source instead, persist it to one or more
temporary `.pas` files first, then point `--input` at their parent directory.

## Workflow

1. Locate the input archive or directory in the working area.
2. Run `scripts/tool.py` with `--input` pointing at it and `--output` pointing
   at a fresh output folder.
3. Read the generated `report.md` and summarize parsed units, fan-in/fan-out,
   cycles, and orphan units.
4. Attach or surface the generated artifacts: Mermaid, DOT, SVG when present,
   JSON, and report. Embed `uses-graph.mmd` inline when the conversation
   surface supports Mermaid rendering.

## Quick start

```bash
python scripts/tool.py \
    --input  /path/to/project.zip \
    --output /path/to/out
```

If the container exposes `python3` instead of `python`, use `python3` with the
same arguments.

Useful flags, with full details in `reference.md`:

- `--scope {all,interface,implementation}` - which `uses` sections to
  consider. Default `all`.
- `--ignore-prefix LIST` - drop edges whose target starts with one of these
  comma-separated prefixes, case-insensitive. Default:
  `System,Winapi,Vcl,FMX,Data,Web,REST,IdGlobal`. Pass `""` to keep RTL/VCL.
- `--max-label N` - truncate node labels in the Mermaid output. Default `40`.
- `--include-orphans` - keep units that have no inbound and no outbound edges
  in the graph.

## Outputs

Files written in `--output`:

| File | Purpose |
| --- | --- |
| `dependencies.json` | Raw graph: `{ unit: { defined_in, interface_uses, implementation_uses } }` |
| `uses-graph.mmd` | Mermaid `graph LR` ready to embed in markdown |
| `uses-graph.dot` | Graphviz DOT source |
| `uses-graph.svg` | SVG rendering, only when the `dot` binary is available on `PATH` |
| `report.md` | Human-readable summary: counts, hotspots, cycles, orphans |

## Notes

- RTL / VCL / FMX targets are filtered by default to keep the diagram readable.
  The user's own units are never filtered.
- Cycle detection uses Tarjan's strongly connected components on the directed
  graph. Edge `A -> B` means `A uses B`. Self-loops are reported separately.
- Pascal `uses` syntax has several edge cases: dotted names, `in '<path>'`
  aliases, conditional defines, and three comment styles. Read `reference.md`
  before changing the parser.
