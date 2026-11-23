# AGENT START HERE: installing and verifying `preset/` (project-preset + Matt Pocock skills)

Layout: this folder lives at `preset/` inside a copy of the `mattpocock/skills` tree. Everything outside
`preset/` is upstream, unmodified (see `UPSTREAM.md`). Run everything below from inside `preset/`.

If you are an AI agent that was handed this folder or zip, follow this file top to bottom.

## What you have

A one-command installer that puts an operating standard and 52 skills into a target git repository.
`payload/` is what gets installed, `extras/matt-pocock/` is reference material (CI workflows, wiki
template, starter repo files) that the installer does **not** copy, `tests/` proves it works.

## Steps

1. **Check prerequisites**: `git`, `bash` (Windows: Git for Windows), `python3`. The target must be a git repo
   (`git init` if new).
2. **Prove the package first**: `bash tests/selftest.sh` → expect `0 failed`. If anything fails, stop and report
   the failing line; do not install.
3. **Install** (ask the user for the target path if you do not have one):
   `./install.sh --target /path/to/repo` (Windows: `install.cmd C:\path` or `install.ps1 -Target ...`).
   Options: `--force` refresh · `--upgrade-standard` replace PROJECT.xml and modules (keeps .bak) ·
   `--no-vendored` lean · `--with-ci` add the gate workflow · `--no-hooks` · `--no-memory` · `--no-adapters`.
4. **Verify in the target**: `sh .agents/bin/doctor.sh` must pass.
5. **Hand over to the operating manual**: read `<target>/.agents/INTEGRATION.md` and follow it. Then run the
   PRESET stage (skill `project-setup`, then `setup-matt-pocock-skills`) with the user.
6. Do not commit or push in the target repo unless the user says so.

## Package map

| Path | What |
|---|---|
| `install.sh` / `.ps1` / `.cmd`, `uninstall.sh` | Installers |
| `payload/AGENTS.block.md` | Managed block written into the target's `AGENTS.md` |
| `payload/.agents/INTEGRATION.md` | **The operating manual for agents** (situation → skill map, flow, rules) |
| `payload/.agents/PROJECT.xml` | The standard (P1-P9, laws, stages, rules) |
| `payload/.agents/modules/matt-pocock/` | Matt Pocock chain (`CORE.xml`) and rules (`DIRECTIVE.xml`) |
| `payload/.agents/skills/` | 52 skills (12 authored, 40 vendored) |
| `UPSTREAM.md`, `tools/sync-matt-skills.sh` | Pinned upstream commit, update steps and the re-sync script for the bundled Matt Pocock skills |
| `extras/matt-pocock/` | Unofficial reference only: CI workflows, personal-wiki template, starter repo, source map |
| `tests/` | `selftest.sh`, `selftest-windows.ps1` |
| `CHANGELOG.md` | What changed; see 2.3.0 for the merge |

## Maintaining this package (if asked to edit it)

- Matt Pocock skills are unmodified copies: never edit them here; re-sync with `tools/sync-matt-skills.sh` and report skill problems upstream.
- Add or rename a skill → update `payload/.agents/skills/THIRD_PARTY.md`, `VENDORED` (only if lean installs may
  drop it), the skill catalogue in `PROJECT.xml`, the counts in `README.md`, `.agents/README.md`,
  `INTEGRATION.md` and `AGENTS.block.md`, then rerun `tests/selftest.sh`.
- Never leave a reference to a skill that does not exist: `grep -rn "<skill-name>" payload` must be clean.
- Edit files with a tool that preserves backslashes (a `\b` once became a backspace character in
  `AGENTS.block.md`).
