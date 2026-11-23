---
name: project-setup
description: Use before the first feature of a new project, or the first session on an existing repository that has the preset but an unfilled profile — profiles the project from evidence, writes .agents/profile.xml and the constitution, lays only the floor items its archetype needs (ignore rules, isolated env, lockfile, README, first test, CI, memory files, licence decision), proves the first green run, and proposes ranked what-ifs.
---

# Project setup (PRESET stage)

Criteria: `sh .agents/bin/slice.sh get PRESET` (rules PRE-01..PRE-14) and `get profile_schema`.

## 1. Detect

```sh
git status; git log --oneline -15; ls -la
cat package.json pyproject.toml Cargo.toml go.mod pom.xml *.csproj 2>/dev/null | head -80
ls .github/workflows .gitlab-ci.yml 2>/dev/null
```

- **New** (empty or a few files): you will lay the floor.
- **Existing**: read README, manifest, tests, CI, existing instruction files and history first.
  Preserve what works. Never re-scaffold a working project. Record what already satisfies a PRE
  rule under another name.

## 2. Profile

Fill `.agents/profile.xml` from files, then set `status="FILLED"` and `updated="<date>"`.
Ask the user only what files cannot answer — usually: purpose in one sentence, visibility intent
(private / open source), risk (personal data? money? irreversible actions?), deadline, priorities
(for example how much UI polish is in scope), memory cadence (MILESTONE or EVERY_TASK) and
observability (BASIC or TRACED). Ask as numbered options with your recommendation first.
Unknown stays empty and goes under `<cannot_see>`. Put the real, working commands in `<commands>`;
leave a command empty rather than guessing it.

## 3. Plan before building (new project or feature)

Sketch approach and system design with the user first — skill `grill-with-docs` then `to-spec` (or `brainstorming` for a quick design pass, which also ends in
`to-spec`). Do not generate a plan and start building unilaterally.

## 4. Lay the floor — only what this archetype needs

| Rule | Item | Smallest sufficient version |
|---|---|---|
| PRE-01 | `.gitignore` | stack build output, deps, caches, venvs, editor/OS files, `.env*` except examples, key files |
| PRE-02 | isolation | venv / version manager / container; runtime version file |
| PRE-03 | config | `.env.example` with every key and a placeholder; startup error names a missing key |
| PRE-04 | lockfile | manifest + committed lockfile; one install command that uses it exactly |
| PRE-05 | README | what, honest status, prerequisites, run command, test command |
| PRE-06 | first test | one real test on the primary path |
| PRE-07 | lint/format | ecosystem defaults, one command |
| PRE-08 | CI | one job: locked install, lint, offline tests, `permissions: contents: read` (skill `ci`) |
| PRE-09 | constitution | `AGENTS.md` below the managed block, from `.agents/templates/CONSTITUTION.md` |
| PRE-10 | memory | `PROJECT_BRAIN.md`, `FLOW.md`, `DECISION.md` with DEC-001 (why this stack) |
| PRE-11 | licence | deliberate: LICENSE file for open source, or "proprietary" stated in README |
| PRE-12 | layout | one responsibility per module, dependency direction, trust boundary named |
| PRE-13 | preflight + smoke | once the primary path exists |
| PRE-14 | oss module | if open source is intended: skill `oss-excellence` in ADVISE mode |
| PRE-15 | launcher (P8) | copy the kit from skill `self-healing-launcher` (`run.bat`, `run.sh`, `launcher.py`, `preflight.py`), edit its settings block, verify every mode |
| P9 | tracing | copy `trace_kit.py` from skill `observability-tracing` into the package; `@traced` on core functions, `touch()` at I/O, `new_trace()` at entry points; verify with `run trace` |
| P6, P7 | structure and security | module map with typed contracts and the trust boundary in the constitution; `.env.example` validated at startup; skill `security` for anything HIGH risk |

Mark each DONE / GAP / NA (one-line reason) / UNVERIFIED. NA is never a way to skip work.
Ask before choosing a licence, adding a datastore (THR-04) or anything destructive.

## 5. Gate and prove

```sh
sh .agents/bin/doctor.sh            # preset healthy: hooks, files, XML, block
sh .agents/bin/precheck.sh --all    # repository health
sh .agents/bin/precheck.sh --final  # runs your declared commands; this is the baseline
```

Quote the real output. The first green `--final` is the baseline every later task is compared to.

## 6. Report

Profile summary · floor table (rule, status, evidence) · commands run with exit status ·
not verified and why · what-ifs (at most seven, ranked; `get whatifs` for the shape) with one
thing **not** to do · owner actions (remote, branch protection, secrets, licence choice).

Do not commit or push unless asked.
