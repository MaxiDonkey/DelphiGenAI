# delphi-uses-graph — reference

Detailed reference for the parser, the output schema and the CLI of
`scripts/tool.py`. Read this before modifying parsing rules.

## Pascal `uses` clause syntax

A unit may declare two `uses` clauses, one per section:

```pascal
unit MyUnit;

interface

uses
  System.SysUtils, System.Classes,    // dotted unit names
  Other.Unit in 'src\Other.Unit.pas'; // file alias

implementation

uses
  Helpers, {$IFDEF DEBUG} Logger {$ENDIF};
```

A `program`, `library` or `package` file (`.dpr` / `.dpk`) carries a
single `uses` clause that lists the units it pulls in. The skill treats
that single clause as the program's `implementation_uses`.

## Parser rules

Implemented in `scripts/tool.py`:

1. **Strings** (`'...'`) are stripped first. A single quote is escaped as
   `''`.
2. **Comments** are stripped next: `// ... <EOL>`, `{ ... }` and
   `(* ... *)`. Compiler directives such as `{$IFDEF DEBUG}` live inside
   `{ ... }` and are also stripped — their payload is never material to
   the `uses` graph.
3. **Stripped regions are replaced with spaces**, not removed. Byte
   offsets stay aligned with the original source so positional checks
   (`interface` vs `implementation`) remain accurate.
4. **Keywords** (`unit`, `program`, `library`, `package`, `interface`,
   `implementation`, `uses`) are matched case-insensitively.
5. **Unit name** comes from `unit <Name>;` if present, otherwise from
   `program | library | package <Name>`. As a last resort it falls back
   to the file stem.
6. **`uses` clauses** run from the keyword `uses` to the next `;`. Items
   are split on commas. Each item may carry an `in '<path>'` alias —
   only the unit name is kept, the alias is dropped.
7. **Section assignment**: a `uses` clause appearing before
   `implementation` and at or after `interface` is filed under
   `interface_uses`. A clause at or after `implementation` is filed
   under `implementation_uses`. For program / library / package files
   that have neither keyword, the clause is filed under
   `implementation_uses` so it still contributes to the graph.

## Output schema (`dependencies.json`)

```json
{
  "MyUnit": {
    "defined_in": "src/MyUnit.pas",
    "interface_uses": ["System.SysUtils", "Other.Unit"],
    "implementation_uses": ["Helpers"]
  }
}
```

Paths in `defined_in` are relative to the input root when possible,
absolute otherwise.

## Graph model

- **Nodes** are unit names. A node is *internal* if at least one source
  file defined it, *external* otherwise (typically RTL / third-party).
- **Edges** are directed: `A -> B` means *A uses B*.
- The `--scope` flag controls which `uses` clauses contribute edges
  (`interface`, `implementation` or both — default `all`).
- The `--ignore-prefix` flag removes edges whose target starts with any
  of the given prefixes (case-insensitive, dotted boundary). Internal
  units are never removed by this filter.

## Cycle detection

Tarjan's strongly connected components is run over the directed graph.

- Components of size > 1 are reported as cycles in `report.md`.
- Self-loops (`A -> A`, rare but legal via mutual `interface` /
  `implementation` patterns of the same name) are reported separately.

## CLI flags

| Flag                  | Default                                          | Purpose                                                                              |
| --------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------ |
| `--input PATH`        | required                                         | Zip / tar archive or directory containing `.pas` / `.dpr` / `.dpk`                   |
| `--output DIR`        | required                                         | Where artifacts are written (created if missing)                                     |
| `--scope`             | `all`                                            | `interface`, `implementation`, or `all`                                              |
| `--ignore-prefix STR` | `System,Winapi,Vcl,FMX,Data,Web,REST,IdGlobal`   | Comma-separated prefixes filtered from edges. Pass `""` to keep RTL / VCL targets.   |
| `--max-label N`       | `40`                                             | Truncate node labels in the Mermaid output                                           |
| `--include-orphans`   | off                                              | Keep units with no inbound and no outbound edges                                     |

## Optional SVG rendering

If the `dot` binary is on `PATH`, the script invokes it to produce
`uses-graph.svg`. If absent, the SVG step is skipped and a note is added
to `report.md`. The `.dot` source is always written so the user can
render it later.

## Limitations

- `{$INCLUDE ...}` directives are not expanded — only the file that
  contains the directive is parsed.
- Conditional sections enclosed by `{$IFDEF X} ... {$ELSE} ... {$ENDIF}`
  are stripped along with the directive comment, so units used only
  under a specific symbol are not currently distinguished.
- Generic / namespace aliasing inside `uses` (rare) is not modeled.
