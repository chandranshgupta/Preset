# Changelog

## Unreleased

## 2.3.0-hybrid

### Added
- **Matt Pocock module** (`.agents/modules/matt-pocock/`): grill → spec → tickets → implement → review → PR → retro
  chain, rules MP-01..16, `slice.sh get mp` / `mp-core`. New rules THR-43 (context hygiene), THR-44 (glossary),
  THR-45 (deep modules, three-gate ADRs), FIN-16 (PR rubric, retro ratchet); concerns H-GLOSSARY and H-PR.
- 20 skills: ask-matt, code-review, codebase-design, diagnosing-bugs, domain-modeling, grill-me, grill-with-docs,
  grilling, implement, implement-spec, improve-codebase-architecture, pr, retro, setup-matt-pocock-skills, tdd,
  teach, to-spec, to-tickets, wayfinder, writing-for-agents (each with a precedence footer).
- `.agents/INTEGRATION.md` (operating manual for agents) and `AGENT_START_HERE.md` (install/verify guide).
- `extras/matt-pocock/`: reference CI workflows, wiki template, starter repo, source map (not auto-installed).

### Changed
- Retired `writing-plans`, `requesting-code-review`, `receiving-code-review` and the authored `review` skill;
  replaced by `to-spec` / `to-tickets` / `code-review`. All references updated; review feedback is still verified
  before it is applied (H-REVIEW).
- `code-review` is no longer on the `VENDORED` list, so `--no-vendored` installs keep a review skill.
- Workflows and the AGENTS.md block route features through grill-with-docs → to-spec → to-tickets → implement-spec.
- Fixed a stray backspace character that corrupted `.agents\bin\preset` in `AGENTS.block.md`.
- Self-test updated for the renamed skill (59 checks).
- The 20 bundled Matt Pocock skills were stale copies with a footer added to each. Replaced by **27 unmodified
  copies** of upstream's promoted set at a pinned commit (adds `triage`, `prototype`, `research`, `wizard`,
  `handoff`, `to-questionnaire`, `wait-what`); see `UPSTREAM.md` and `tools/sync-matt-skills.sh`. Precedence is stated in AGENTS.md, the stubs and `INTEGRATION.md`.
- `extras/matt-pocock/` is labelled as unofficial, unverified reference material.

- The package now lives as `preset/` inside the unmodified `mattpocock/skills` tree. Self-test gained a byte-identity
  check of the bundled skills against `../skills` (60 checks).

### Removed
- Rule **THR-42** (code comments in Hinglish) and every mention of it. The id is retired, not reused. All
  Hinglish comments in scripts, hooks, installers and launcher templates were translated to English.

### Changed
- Installer writes a managed `.gitignore` block (`project-preset:begin` / `:end`) that ignores the
  generated agent adapters (`.agent/`, `.claude/skills/`) and local `.env` files. Re-runs replace
  the block in place; `uninstall.sh` removes it.
- The CI gate is no longer implied: without `--with-ci` / `-WithCi` the installer prints a one-line
  suggestion at the end and adds no workflow.

## 2.2.0

### Added
- **Prime directives P1-P9** at the top of `PROJECT.xml` and the AGENTS.md block, winning every
  conflict: nothing fake; only real, dynamic, correct, live information; no hallucination;
  multi-option responses; memory triad in sync; modular and debuggable in isolation; secure by
  design; isolated self-healing runtime; pervasive observability and tracing.
- `response_style`: decisions as numbered options with a recommendation and a default. Laws L19
  (grounded claims only) and L20 (options, not monologues).
- `harmony`: one owner per concern, written resolutions for every known tension between rules and
  skills, and profile switches where good practices genuinely differ.
- Rules folded in from earlier project rule sets: truth order (THR-38), typed module contracts and
  no god files (THR-31, THR-32), untrusted files, linear-time parsing, structured errors, `.env`
  validated against the example (THR-33..36), UI bound to live data (THR-37), observability,
  visible fallback ladders and connected safe tracing (THR-39..41), the self-healing launcher
  (PRE-15), and triad and reference checks (FIN-11, FIN-12).
- Memory section rebuilt: update triggers per file, cadence (MILESTONE or EVERY_TASK), truth order,
  a FLOW tree standard (Verified vs Planned), DECISION format with reversibility, rejected
  alternatives and constraints.
- Profile fields: `priorities`, `memory_cadence`, `observability` (TRACED by default), `response_style`.
- Skill `self-healing-launcher` with a tested kit:
  - `run.bat` / `run.sh` bootstraps;
  - `launcher.py`, an arrow-key control panel with run, trace, test, diagnose, report, repair,
    ports and logs;
  - `preflight.py`.
- Skill `observability-tracing` with `trace_kit.py`: connected spans (file, function, line,
  caller, touched resources, duration, status), secret redaction, line-level trace mode, and a
  post-run report.
- Gate:
  - references in the triad, the constitution and markdown links that point at missing files;
  - code changes without a triad update;
  - declared-command timeout;
  - ASCII-only output;
  - works from any working directory.
- `preset.cmd` / `preset.sh` entry point (PowerShell and cmd have no `sh` on PATH); `doctor --ci`.
- Installer: `--no-vendored`, `--with-ci`, Claude Code discovery stubs in `.claude/skills`, LF/CRLF
  rules for `.sh`, hooks, `.cmd` and `.bat`, cache files never installed. `uninstall.sh` and
  `install.ps1 -Uninstall`.
- Self-tests: `tests/selftest.sh` (59 checks) and `tests/selftest-windows.ps1` (21 checks).

- Rule THR-42: code comments are written in Hinglish (Hindi in Roman script); also in the AGENTS.md block.

### Changed
- `install.ps1` and `install.cmd` run `install.sh` through Git for Windows' bash. All entry points
  are byte-identical.
- The pre-commit hook fails closed with instructions when bash is missing.
- Vendored skills carry a one-line precedence note under their frontmatter.

### Fixed
- `profile.xml` comment contained `--` (invalid XML).
- Legacy oss-excellence hooks survived migration.
- `--` and non-ASCII output broke on some consoles.
- The tracer pointed implicit traces at itself.
- Preflight accepted blank `.env` values.

## 2.0.0 - project-preset (supersedes oss-excellence-preset)

- `.agents/PROJECT.xml` as the main standard with PRESET / THROUGHOUT / FINAL_CHECK.
- The OSS standard became a module at `.agents/modules/oss/`.
- `oss-*` skills became general skills, and vendored procedure skills were added.
- Workflows, templates and adapters added.
- `doctor.sh`, a generalised `slice.sh`, and the `--final` gate level.
