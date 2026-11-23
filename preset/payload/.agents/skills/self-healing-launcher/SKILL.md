---
name: self-healing-launcher
description: Use when a project needs a way to run, when setup keeps failing on new machines, when adding run, trace, test or diagnose modes, or at PRESET for any project with code — installs the launcher kit in this skill (run.bat for Windows, run.sh for macOS/Linux, launcher.py arrow-key control panel, preflight.py checks) that finds the runtime, builds and heals the isolated environment, installs from the lockfile, checks ports, folders and .env, and runs every mode with tracing (prime directive P8).
---

> Preset note: `.agents/PROJECT.xml` wins any conflict: nothing fake, name only what you observed,
> no system-setting changes, decisions offered as numbered options. Combines with: `get harmony`.

# Self-healing launcher (P8)

Criteria: `sh .agents/bin/slice.sh get P8`, `get PRE-15`, `get THR-09`, law L11.

## The kit (in this skill's `templates/` folder; stdlib only; tested on Windows)

| File | Copy to | Role |
|---|---|---|
| `templates/run.bat` | project root | **Windows bootstrap** (~60 lines): UTF-8, finds Python (rejects the Store stub), rebuilds a stale `.venv`, `--rebuild`, then starts `launcher.py` |
| `templates/run.sh` | project root, `chmod +x` | **macOS/Linux bootstrap**, same behaviour |
| `templates/launcher.py` | project root | **the control panel**, one file for every OS — menu, healing, all modes |
| `templates/preflight.py` | project root (or the package) | the checks, also runnable alone |
| `../observability-tracing/templates/trace_kit.py` | inside the package, e.g. `app/trace_kit.py` | tracing behind `run`, `trace`, `report` (P9) |

Why this split: Python may not exist yet, so only the bootstrap is batch/shell; everything else is
one Python file, so Windows and macOS/Linux behave identically and the logic is testable (THR-09).

## What the user sees

```
╭─ My Project ─────────────────────────────── session 20261022-191306-4740a9 ─╮
│ python 3.12.10 · .venv ok · deps ok · module app.main                        │
│ last: Test · exit 0 · run 20261022-191318-8391f7                             │
├──────────────────────────────────────────────────────────────────────────────┤
│ ❯ 1  Run         start the app with step tracing                             │
│   2  Trace       run with line-level tracing, report after                   │
│   3  Test        offline test suite                                          │
│   4  Test all    offline + live tests (network, keys)                        │
│   5  Diagnose    preflight: python, packages, port, folders, .env            │
│   6  Report      summarise the latest trace                                  │
│   7  Repair      reinstall dependencies                                      │
│   8  Ports       who is using port 8000                                      │
│   9  Logs        recent launcher runs and the latest log                     │
╰─ Up/Down move · Enter run · 1-9 jump · q quit ───────────────────────────────╯
```

- Arrow keys / `j` `k`, Enter, number keys, `q` or Esc. Colour via ANSI (enabled for this console
  only — no registry edits), ASCII fallback with `--plain` or `NO_COLOR`.
- Every action: `[ OK ] [HEAL] [WARN] [FAIL] [INFO]` lines, then a footer with exit code, duration,
  the session log and the trace file. Returns to the menu.
- Direct mode for agents and CI: `run.bat test --yes` (no prompts, exit code = the action's).
- Piped input (no terminal): falls back to a numbered list read from stdin.

## Healing, in order

1. Bootstrap: Python ≥ `PY_MIN` (PATH, `py -3`, standard install folders) → `.venv` (rebuilt if
   stale or from another machine) → `launcher.py`.
2. Dependencies: probes `PROBE_IMPORTS`; reinstalls when an import is missing or `requirements.txt`
   changed since the last install; retries without the pip cache; details go to the log.
3. Folders in `DATA_DIRS` created; `.env` created from `.env.example` if missing — and preflight
   then **refuses to run on blank values**, listing the key names (never values).
4. Preflight before run, trace and test; `diagnose` runs it alone. Exit 2 from a project preflight
   means warnings: the run continues and says so.
5. Server mode: opens the browser after start, offers a restart when the server crashes, `ports`
   shows who holds the port and stops it only after an explicit yes.

## Adapting

Edit only the settings block at the top of `launcher.py` (and `PY_MIN` in the bootstraps):
`APP_NAME`, `APP_KIND` (`module` or `server`), `APP_MODULE`, `SERVER_ARGS`, `PORT` (or a `port.txt`
file, or the `PORT` environment variable), `PROBE_IMPORTS`, `REQUIREMENTS`, `DATA_DIRS`,
`TRACE_KIT`, `TEST_LIVE_MARKER`, and `EXTRA_ACTIONS` for project-specific modes (batch ingestion,
stress test…) — each one a single call into real code.

- Other lockfiles: change `install()` to the ecosystem's frozen install, looked up for the tool
  version in use (L13): `uv sync --frozen`, `pip install -r requirements.lock`…
- Non-Python projects: keep the bootstrap + one control-panel file + preflight split; write the
  panel in the project's language or keep this Python panel if Python is available.
- Declare the launcher in `.agents/profile.xml` so FINAL_CHECK runs what users run:
  `<command id="test">cmd //c run.bat test --yes</command>` (Git Bash on Windows) or
  `<command id="test">./run.sh test --yes</command>`.

## Never

Change system settings (registry, global PATH, fonts, terminal themes); install globally; download
and run tools without asking; continue into a broken run; fall back to fake data; print a secret.
Opt-in tool downloads (a portable JDK, a browser engine) are allowed only as a menu action that
asks first and verifies a published checksum.

## Verify

Run each action on a clean checkout and on a deliberately broken one (delete `.venv`, blank a
`.env` value, occupy the port, change `requirements.txt`) and quote the real output.
