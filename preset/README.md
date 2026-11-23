# project-preset

One install that gives any repository, in any language, a standing operating standard for AI
coding agents. Nine prime directives sit on top of it, and three stages run through it.

## The nine prime directives (they win every conflict)

| # | Directive | What enforces it |
|---|---|---|
| 1 | **Nothing fake**: no mock, placeholder, canned answer, fake progress or dummy data on an application path | laws L01/L02, THR-37, FIN-04 |
| 2 | **Only real, dynamic, correct, live information**: from the source, changes when the source changes, fails honestly | L13, THR-02/03/38/40 |
| 3 | **No hallucination**: name only what was observed this session; "I don't know" beats a guess | L19, FIN-12, gate flags references to missing files |
| 4 | **Multi-option responses**: decisions as 2-4 numbered options, recommended first, with a default | L20, `response_style` |
| 5 | **Memory triad in sync**: `PROJECT_BRAIN.md` (what is) · `FLOW.md` (how) · `DECISION.md` (why) | THR-26, FIN-11, gate triad checks |
| 6 | **Modular, debuggable in isolation**: one responsibility, typed contracts, no god files | THR-05/31/32 |
| 7 | **Secure by design**: validated boundaries, content-checked files, linear-time parsing, no leaks, scanned deps | THR-10..16, THR-33..36, gate |
| 8 | **Isolated, self-healing runtime**: `run.bat` / `run.sh` heal the environment and run every mode | PRE-15, skill `self-healing-launcher` |
| 9 | **Pervasive tracing**: a trace id through every step; file, line, what was touched; line-level trace mode | THR-39/40/41, skill `observability-tracing` |

## The three stages

| Stage | When | What it does |
|---|---|---|
| **PRESET** | before the first feature, or the first session on an existing repo | profiles the project, lays only the floor that kind of project needs, installs the gate and launcher, proves the first green run |
| **THROUGHOUT** | every task | the task loop (orient, plan, isolate, test first, change, verify, remember, hand off) and the rules by area (`THR-*`) |
| **FINAL_CHECK** | before every commit, before "done", before a release | the gate, the project's declared commands actually executed, a checklist, an evidence-backed handoff |

Open source is **one module** (`.agents/modules/oss/`), switched on when the project is or will
become public.

**Harmony.** Every concern has one owner skill; the others contribute. Known tensions have
written resolutions, for example "plans that say git commit" versus "no commit without approval".
Where two good practices genuinely differ, the project picks once in `profile.xml`: memory
cadence, observability level, priorities. Read it with `get harmony`.

## In plain English

- **`AGENTS.md`** is what every agent reads first. Its managed block lists the nine directives and
  points into `.agents/PROJECT.xml`. Below the block is your **constitution**: 10-40 lines true only
  for this project.
- **`.agents/PROJECT.xml`** is the main file. Agents load one piece at a time
  (`slice.sh get THROUGHOUT`, `get THR-41`), never the whole file.
- **`.agents/profile.xml`** says what this project is and lists its real commands. The final check
  runs them, so "tests pass" is something the gate proved.
- **Skills** (`.agents/skills/`, 52) are procedures. 12 were written for this preset, two of which
  ship tested code kits (the launcher and the tracer). 40 are vendored (13 from the superpowers
  and community families, 27 unmodified copies of Matt Pocock's skills), each with a one-line note that the standard wins. **Workflows** (`.agents/workflows/`,
  16) are runbooks.
- **The gate** (`precheck.sh`, wired as a git hook) stops secrets, `.env` files, build output, huge
  files and merge markers. It warns on swallowed errors, debugger leftovers, machine paths,
  references to files that don't exist, and code changed without a triad update.

## Install

The target must be a git repository (`git init` first if it is new).

| OS | Run |
|---|---|
| Windows (double-click or cmd) | `install.cmd C:\code\my-project` |
| Windows PowerShell | `powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target C:\code\my-project` |
| Git Bash, Linux, macOS | `./install.sh --target /path/to/my-project` |

Windows needs Git for Windows. It provides the bash that the hooks use, and every entry point runs
the same `install.sh` through it, so results are byte-identical (tested).

| Option (sh / PowerShell) | Effect |
|---|---|
| `--force` / `-Force` | refresh preset-owned files: scripts, skills, workflows, hooks, templates |
| `--upgrade-standard` / `-UpgradeStandard` | also replace `PROJECT.xml` and `modules/`, keeping `.bak` copies |
| `--no-hooks` / `-NoHooks` | do not set `core.hooksPath` |
| `--no-memory` / `-NoMemory` | do not create the triad files |
| `--no-adapters` / `-NoAdapters` | no `CLAUDE.md`, `GEMINI.md`, `.agent/` aliases, `.claude/skills` stubs |
| `--no-vendored` / `-NoVendored` | lean install without the vendored skills (`code-review` is always kept) |
| `--with-ci` / `-WithCi` | add `.github/workflows/preset-gate.yml` (the gate in CI, unskippable). Without it the installer only prints a suggestion; nothing is added to CI on its own |
| `--skills-from DIR --only a,b` / `-SkillsFrom DIR -Only a,b` | import more skill folders |
| `uninstall.sh` / `install.ps1 -Uninstall [-Purge] [-Yes]` | remove the preset; the triad and your constitution are always kept |

Then tell your agent: **"run the PRESET stage"** (skill `project-setup`). It fills the profile and
the constitution with you (asking as numbered options), lays the floor, installs the launcher, and
reports what-ifs.

## Daily use

```sh
sh .agents/bin/doctor.sh                 # is the preset intact and wired?
sh .agents/bin/slice.sh get THROUGHOUT   # one stage;  get THR-16  one rule;  get harmony
sh .agents/bin/precheck.sh --final       # before "done": scan + run declared commands
sh .agents/bin/precheck.sh --release     # before tag / publish / submit
```

On Windows PowerShell or cmd, where there is no `sh` on PATH, use `.agents\bin\preset`:
`.agents\bin\preset doctor` · `.agents\bin\preset check --final` · `.agents\bin\preset slice get P9`.

The launcher kit, once the PRESET stage copies it into your project:

```text
run.bat                 arrow-key control panel (./run.sh on macOS/Linux)
run.bat run | trace | test [--all|--live] | diagnose | report | repair | ports | logs
run.bat --rebuild       rebuild .venv          flags: --plain  --yes
```

## The gate

| Level | Command | Blocks | Warns |
|---|---|---|---|
| commit (hook) | `--staged` | private keys, cloud/platform tokens, tracked `.env`, build artifacts, files > 2 MiB, merge markers | credential-shaped values, swallowed exceptions, debugger leftovers, machine paths; code without triad (EVERY_TASK) |
| task | `--final` | the above + a declared command that fails or times out | + `.gitignore`, licence decision, lockfile, CI, README commands, unfilled profile/constitution/triad, references to missing files |
| release | `--release` | everything promoted, + no CHANGELOG, no SECURITY policy (unless private), no tag | |

Exit codes: `0` clean (warnings allowed) · `1` blockers · `2` cannot run. Exceptions are recorded,
not hidden: one `check:path` glob per line in `.agents/allow`. Declared commands time out after
`PRESET_CMD_TIMEOUT` seconds (default 900) where GNU `timeout` exists.

## Tests of the preset itself

```sh
bash tests/selftest.sh                                          # 59 checks
powershell -ExecutionPolicy Bypass -File tests\selftest-windows.ps1   # 21 checks: PS 5.1/7, cmd, run.bat
```

## What was verified, and what was not

- **Verified on Windows 10:**
  - `tests/selftest.sh` passes 59/59 under Git Bash (bash 5.3, GNU awk).
  - `tests/selftest-windows.ps1` passes 21/21 under Windows PowerShell 5.1 and PowerShell 7.6.
  - Installs from bash, PowerShell and cmd are byte-identical.
  - Paths with spaces and Devanagari characters work.
  - The `run.bat` launcher was tested in every direct mode and through scripted menu navigation.
- **Not run: macOS and Linux.** The scripts are written for them:
  - bash 3.2 compatible;
  - no GNU-only flags;
  - BSD `stat` handled;
  - LF line endings enforced.

  Nothing has been executed there. `tests/selftest.sh` is the check to run on those systems.
- The gate is pattern-based, not a full secret scanner. Hooks are per-clone local config: re-run
  the installer after cloning, or use `--with-ci`.
- Licences of the vendored community skills were not verified (see `.agents/skills/THIRD_PARTY.md`).

## Coming from oss-excellence-preset

Run the new installer on the repo. It:
- replaces the old `AGENTS.md` block and hooks;
- carries `.oss-excellence/allow` entries into `.agents/allow`;
- tells you the old folder can go.

`CORE.xml` and `DIRECTIVE.xml` move to `.agents/modules/oss/` with their content intact.
