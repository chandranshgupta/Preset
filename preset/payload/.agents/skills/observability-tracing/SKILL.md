---
name: observability-tracing
description: Use when building or changing any core code path, when debugging a run, when a result needs explaining ("which file, line, step and rule produced this"), or when adding logging — instruments the project so a trace id flows from every entry point through every step, each step records file, function, line, what it touched, duration and status, and the launcher's trace mode adds line-level tracing with a report after the run (prime directive P9).
---

> Preset note: `.agents/PROJECT.xml` wins any conflict: nothing fake, name only what you observed,
> secrets never traced, decisions offered as numbered options. Combines with: `get harmony`.

# Observability and tracing (P9)

Criteria: `sh .agents/bin/slice.sh get P9`, `get THR-39`, `get THR-40`, `get THR-41`, profile
`observability` (TRACED by default). Combines with: `systematic-debugging` (read the trace before
guessing), `self-healing-launcher` (its launcher kit runs `run`, `trace` and `report` for you), `project-memory` (FLOW.md should match the trace).

## The model

| Layer | Always on? | What it records |
|---|---|---|
| Trace | yes | one id per entry point (request, CLI command, job, UI action), propagated everywhere |
| Span (step) | yes, on every core function | file, function, line, caller file:line, step index, depth, inputs as type/size, output type/size, duration, ok/error with error type, message and location |
| Touch | yes, at every I/O | resource kind (file, table, http, queue, cache, env), target, read/write/call, sizes or row counts |
| Lines | trace mode only | every project line executed, with hit counts |
| UI events | yes, if there is a UI | action name, context, same trace id passed to the backend |

Secrets and personal data are redacted at the tracer, never left to callers (THR-41).

## Python (template tested on Windows; stdlib only)

Copy `.agents/skills/observability-tracing/templates/trace_kit.py` into the package, then:

```python
from app.trace_kit import traced, touch, new_trace

@traced                                   # every core function, one span per call
def load_orders(path):
    touch("file", path, "read")           # every read/write/call of an outside resource
    ...

def main():                               # every entry point
    with new_trace("cli: report"):
        load_orders("data/orders.csv")
```

- `run` mode writes spans to `logs/trace/<run_id>.jsonl` (`APP_TRACE=1`).
- `trace` mode: `python app/trace_kit.py run -m app.main` adds line tracing (`sys.monitoring` on
  3.12+, `sys.settrace` before) and prints the report: steps in order with file:line, caller, time,
  touched resources, errors with their line, slowest steps, lines executed per file.
- `python app/trace_kit.py report` summarises the latest run; exit 1 if any step errored.
- Web frameworks: open `new_trace` in a middleware per request and return the trace id in a response
  header so a user can quote it. Threads and asyncio tasks inherit the context; for process pools,
  pass the trace id explicitly.

## Other stacks (adapt, then test — do not assume)

- **Node.js**: `AsyncLocalStorage` carries the trace id; a wrapper function records spans (use
  `new Error().stack` or the function name for location); line-level coverage via the
  `NODE_V8_COVERAGE=<dir>` environment variable or `c8`. Check the current docs for the Node version
  in use before writing it (L13).
- **Other languages**: use the platform's tracing library (OpenTelemetry SDKs exist for most) with
  the same fields; keep the JSONL-per-run output so the launcher's report mode works the same way.

## Rules

- Instrument as you build: a new core function without `@traced` (or the stack's equivalent) is
  unfinished work.
- Fallbacks are rungs in a visible ladder (THR-40): each rung logs that it was taken, and why.
- Never trace secret values; inputs default to type and size. `APP_TRACE_VALUES=1` adds short,
  redacted values for local debugging only.
- Line tracing is for debugging runs, never left on in production (cost).
- When FLOW.md and the trace disagree, one of them is wrong — find out which (THR-38).

## Verify

Run the launcher in `trace` mode and quote the report: the expected steps appear in order, each
touched resource is listed, an induced error shows its file:line, and no secret value appears in
`logs/trace/*.jsonl` (`grep -i` for the secret's name shows `***`).
