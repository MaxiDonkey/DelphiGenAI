#!/usr/bin/env python3
"""
delphi-uses-graph — extract a unit-level `uses` dependency graph from a
Delphi / Object Pascal codebase.

See SKILL.md (overview) and reference.md (parsing rules, output schema,
CLI flags) in the parent skill folder.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import zipfile
from collections import defaultdict
from pathlib import Path

PAS_EXTS = {".pas", ".dpr", ".dpk"}
DEFAULT_IGNORE = "System,Winapi,Vcl,FMX,Data,Web,REST,IdGlobal"

UNIT_RE = re.compile(r"\bunit\s+([A-Za-z_][\w.]*)", re.IGNORECASE)
PROGRAM_RE = re.compile(
    r"\b(?:program|library|package)\s+([A-Za-z_][\w.]*)", re.IGNORECASE
)
USES_RE = re.compile(r"\buses\b([^;]*);", re.IGNORECASE | re.DOTALL)
INTF_RE = re.compile(r"\binterface\b", re.IGNORECASE)
IMPL_RE = re.compile(r"\bimplementation\b", re.IGNORECASE)


def strip_pascal_noise(src: str) -> str:
    """Replace Pascal strings and comments with spaces of equal length so
    byte offsets stay aligned with the original source."""
    out: list[str] = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        c2 = src[i:i + 2]
        if c == "'":
            j = i + 1
            while j < n:
                if src[j] == "'":
                    if j + 1 < n and src[j + 1] == "'":
                        j += 2
                        continue
                    j += 1
                    break
                j += 1
            out.append(" " * (j - i))
            i = j
        elif c2 == "//":
            j = src.find("\n", i)
            if j == -1:
                j = n
            out.append(" " * (j - i))
            i = j
        elif c2 == "(*":
            j = src.find("*)", i + 2)
            j = n if j == -1 else j + 2
            out.append(" " * (j - i))
            i = j
        elif c == "{":
            j = src.find("}", i + 1)
            j = n if j == -1 else j + 1
            out.append(" " * (j - i))
            i = j
        else:
            out.append(c)
            i += 1
    return "".join(out)


def parse_uses_list(block: str) -> list[str]:
    items: list[str] = []
    for raw in block.split(","):
        token = raw.strip()
        token = re.split(r"\s+in\s+", token, flags=re.IGNORECASE)[0].strip()
        if token:
            items.append(token)
    return items


def parse_file(path: Path) -> dict | None:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None
    clean = strip_pascal_noise(text)

    m_unit = UNIT_RE.search(clean)
    if m_unit:
        name = m_unit.group(1)
    else:
        m_prog = PROGRAM_RE.search(clean)
        name = m_prog.group(1) if m_prog else path.stem

    intf_match = INTF_RE.search(clean)
    impl_match = IMPL_RE.search(clean)
    intf_start = intf_match.start() if intf_match else 0
    impl_start = impl_match.start() if impl_match else len(clean)

    interface_uses: list[str] = []
    implementation_uses: list[str] = []

    for m in USES_RE.finditer(clean):
        items = parse_uses_list(m.group(1))
        if intf_match and intf_start <= m.start() < impl_start:
            interface_uses.extend(items)
        elif impl_match and m.start() >= impl_start:
            implementation_uses.extend(items)
        else:
            implementation_uses.extend(items)

    return {
        "unit_name": name,
        "defined_in": str(path),
        "interface_uses": interface_uses,
        "implementation_uses": implementation_uses,
    }


def gather_files(input_path: Path, workdir: Path) -> Path:
    if input_path.is_dir():
        return input_path
    if zipfile.is_zipfile(input_path):
        with zipfile.ZipFile(input_path) as zf:
            zf.extractall(workdir)
        return workdir
    if tarfile.is_tarfile(input_path):
        with tarfile.open(input_path) as tf:
            tf.extractall(workdir)
        return workdir
    raise SystemExit(f"Unsupported input: {input_path}")


def collect_units(root: Path) -> dict[str, dict]:
    units: dict[str, dict] = {}
    for p in root.rglob("*"):
        if p.suffix.lower() in PAS_EXTS and p.is_file():
            parsed = parse_file(p)
            if parsed:
                units[parsed["unit_name"]] = parsed
    return units


def edge_kept(target: str, ignored_prefixes: list[str], internal: set[str]) -> bool:
    if target in internal:
        return True
    low = target.lower()
    for p in ignored_prefixes:
        pl = p.lower()
        if low == pl or low.startswith(pl + "."):
            return False
    return True


def build_graph(
    units: dict[str, dict],
    scope: str,
    ignored: list[str],
) -> tuple[set[str], dict[str, list[str]]]:
    edges: dict[str, set[str]] = defaultdict(set)
    nodes: set[str] = set(units.keys())
    internal = set(units.keys())
    for name, info in units.items():
        targets: list[str] = []
        if scope in ("all", "interface"):
            targets += info["interface_uses"]
        if scope in ("all", "implementation"):
            targets += info["implementation_uses"]
        for t in targets:
            if not ignored or edge_kept(t, ignored, internal):
                edges[name].add(t)
                nodes.add(t)
    return nodes, {k: sorted(v) for k, v in edges.items()}


def tarjan_scc(
    nodes: set[str],
    edges: dict[str, list[str]],
) -> tuple[list[list[str]], list[str]]:
    index: dict[str, int] = {}
    lowlink: dict[str, int] = {}
    on_stack: set[str] = set()
    stack: list[str] = []
    counter = [0]
    sccs: list[list[str]] = []

    sys.setrecursionlimit(max(1000, len(nodes) * 4))

    def strongconnect(v: str) -> None:
        index[v] = lowlink[v] = counter[0]
        counter[0] += 1
        stack.append(v)
        on_stack.add(v)
        for w in edges.get(v, []):
            if w not in index:
                strongconnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif w in on_stack:
                lowlink[v] = min(lowlink[v], index[w])
        if lowlink[v] == index[v]:
            comp: list[str] = []
            while True:
                w = stack.pop()
                on_stack.discard(w)
                comp.append(w)
                if w == v:
                    break
            sccs.append(comp)

    for v in nodes:
        if v not in index:
            strongconnect(v)

    cycles = [c for c in sccs if len(c) > 1]
    self_loops = [v for v in nodes if v in edges.get(v, [])]
    return cycles, self_loops


def write_mermaid(
    nodes: set[str],
    edges: dict[str, list[str]],
    parsed_set: set[str],
    max_label: int,
) -> str:
    def lab(s: str) -> str:
        return s if len(s) <= max_label else s[: max_label - 1] + "…"

    def ident(s: str) -> str:
        return re.sub(r"\W", "_", s)

    lines = ["graph LR"]
    for n in sorted(nodes):
        cls = "internal" if n in parsed_set else "external"
        lines.append(f'    {ident(n)}["{lab(n)}"]:::{cls}')
    for src in sorted(edges):
        for t in edges[src]:
            lines.append(f"    {ident(src)} --> {ident(t)}")
    lines.append("    classDef internal fill:#e3f2fd,stroke:#1565c0,color:#0d47a1;")
    lines.append("    classDef external fill:#f5f5f5,stroke:#9e9e9e,color:#616161;")
    return "\n".join(lines) + "\n"


def write_dot(
    nodes: set[str],
    edges: dict[str, list[str]],
    parsed_set: set[str],
) -> str:
    def ident(s: str) -> str:
        return '"' + s.replace('"', '\\"') + '"'

    out = [
        "digraph uses {",
        "    rankdir=LR;",
        '    node [shape=box, fontname="Helvetica"];',
    ]
    for n in sorted(nodes):
        if n in parsed_set:
            out.append(f'    {ident(n)} [style=filled, fillcolor="#e3f2fd"];')
        else:
            out.append(
                f'    {ident(n)} [style=filled, fillcolor="#f5f5f5", fontcolor="#616161"];'
            )
    for src in sorted(edges):
        for t in edges[src]:
            out.append(f"    {ident(src)} -> {ident(t)};")
    out.append("}")
    return "\n".join(out) + "\n"


def fan_metrics(
    nodes: set[str],
    edges: dict[str, list[str]],
) -> tuple[dict[str, int], dict[str, int]]:
    fan_out = {n: len(edges.get(n, [])) for n in nodes}
    fan_in: dict[str, int] = defaultdict(int)
    for tgts in edges.values():
        for t in tgts:
            fan_in[t] += 1
    return dict(fan_in), fan_out


def write_report(
    out_path: Path,
    parsed: dict[str, dict],
    edges: dict[str, list[str]],
    cycles: list[list[str]],
    self_loops: list[str],
    fan_in: dict[str, int],
    fan_out: dict[str, int],
    svg_ok: bool,
    scope: str,
) -> None:
    parsed_set = set(parsed)
    total_edges = sum(len(v) for v in edges.values())
    top_in = sorted(parsed_set, key=lambda n: (-fan_in.get(n, 0), n))[:10]
    top_out = sorted(parsed_set, key=lambda n: (-fan_out.get(n, 0), n))[:10]
    orphans = sorted(
        n for n in parsed_set if fan_in.get(n, 0) == 0 and fan_out.get(n, 0) == 0
    )

    lines = [
        "# Delphi uses-graph report",
        "",
        f"- Parsed units: **{len(parsed_set)}**",
        f"- Edges (scope = `{scope}`): **{total_edges}**",
        f"- Cycles (size > 1): **{len(cycles)}**",
        f"- Self-loops: **{len(self_loops)}**",
        f"- Orphan units (no inbound and no outbound): **{len(orphans)}**",
        f"- SVG rendered: **{'yes' if svg_ok else 'no (graphviz `dot` not found on PATH)'}**",
        "",
        "## Top fan-in (most depended-upon)",
        "",
        "| Unit | fan-in |",
        "|---|---|",
    ]
    for n in top_in:
        lines.append(f"| `{n}` | {fan_in.get(n, 0)} |")

    lines += [
        "",
        "## Top fan-out (most dependencies)",
        "",
        "| Unit | fan-out |",
        "|---|---|",
    ]
    for n in top_out:
        lines.append(f"| `{n}` | {fan_out.get(n, 0)} |")

    if cycles:
        lines += ["", "## Cycles", ""]
        for i, comp in enumerate(cycles, 1):
            chain = " → ".join(comp) + f" → {comp[0]}"
            lines.append(f"{i}. {chain}")

    if self_loops:
        lines += ["", "## Self-loops", ""]
        for v in self_loops:
            lines.append(f"- `{v}`")

    if orphans:
        lines += ["", "## Orphans", ""]
        for v in orphans:
            lines.append(f"- `{v}`")

    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def relative_to_root(path_str: str, root: Path) -> str:
    try:
        return str(Path(path_str).resolve().relative_to(root.resolve()))
    except ValueError:
        return path_str


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Build a Delphi `uses` dependency graph from a project archive or directory."
    )
    ap.add_argument("--input", required=True, help="Zip / tar archive or directory")
    ap.add_argument("--output", required=True, help="Output directory")
    ap.add_argument(
        "--scope",
        choices=["all", "interface", "implementation"],
        default="all",
    )
    ap.add_argument(
        "--ignore-prefix",
        default=DEFAULT_IGNORE,
        help=(
            "Comma-separated prefixes filtered from edges (case-insensitive). "
            "Pass empty string to keep RTL / VCL targets."
        ),
    )
    ap.add_argument("--max-label", type=int, default=40)
    ap.add_argument("--include-orphans", action="store_true")
    args = ap.parse_args()

    in_path = Path(args.input).resolve()
    out_dir = Path(args.output).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    workdir = Path(tempfile.mkdtemp(prefix="duses_"))
    try:
        root = gather_files(in_path, workdir)
        units = collect_units(root)
        if not units:
            raise SystemExit("No .pas / .dpr / .dpk files found in the input.")

        ignored = [p.strip() for p in args.ignore_prefix.split(",") if p.strip()]
        nodes, edges = build_graph(units, args.scope, ignored)
        parsed_set = set(units.keys())

        if not args.include_orphans:
            connected = set(edges.keys()) | {t for v in edges.values() for t in v}
            nodes = {n for n in nodes if n in connected}

        cycles, self_loops = tarjan_scc(nodes, edges)
        fan_in, fan_out = fan_metrics(nodes, edges)

        deps = {
            u: {
                "defined_in": relative_to_root(info["defined_in"], root),
                "interface_uses": info["interface_uses"],
                "implementation_uses": info["implementation_uses"],
            }
            for u, info in units.items()
        }
        (out_dir / "dependencies.json").write_text(
            json.dumps(deps, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        (out_dir / "uses-graph.mmd").write_text(
            write_mermaid(nodes, edges, parsed_set, args.max_label),
            encoding="utf-8",
        )
        dot_src = write_dot(nodes, edges, parsed_set)
        (out_dir / "uses-graph.dot").write_text(dot_src, encoding="utf-8")

        svg_ok = False
        if shutil.which("dot"):
            try:
                subprocess.run(
                    ["dot", "-Tsvg", "-o", str(out_dir / "uses-graph.svg")],
                    input=dot_src,
                    text=True,
                    check=True,
                    timeout=60,
                )
                svg_ok = True
            except Exception:
                svg_ok = False

        write_report(
            out_dir / "report.md",
            units,
            edges,
            cycles,
            self_loops,
            fan_in,
            fan_out,
            svg_ok,
            args.scope,
        )

        total_edges = sum(len(v) for v in edges.values())
        print(
            f"OK — {len(units)} unit(s) parsed, {total_edges} edge(s), "
            f"{len(cycles)} cycle(s), SVG={'yes' if svg_ok else 'no'}."
        )
        print(f"Artifacts in: {out_dir}")
        return 0
    finally:
        shutil.rmtree(workdir, ignore_errors=True)


if __name__ == "__main__":
    raise SystemExit(main())
