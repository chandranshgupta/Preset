---
name: project-standard
description: Use at the start of any task in this repository, and whenever unsure which rule, skill or workflow applies — routes to the right stage of .agents/PROJECT.xml (PRESET, THROUGHOUT, FINAL_CHECK), the right skill, and the right module. Trigger on "set up", "start", "what should I do", "is this done", "what's missing", "how good is this", "improve", "release", and before any commit.
---

# Project standard (router)

The standard lives in `.agents/PROJECT.xml`. This skill decides **which part to load**. Never
load the XML whole; slice it:

```sh
sh .agents/bin/slice.sh list              # sections, stages, sizes
sh .agents/bin/slice.sh get THROUGHOUT    # one stage
sh .agents/bin/slice.sh get THR-16        # one rule (any id)
sh .agents/bin/slice.sh get router        # situation → skill / workflow
sh .agents/bin/slice.sh grep secret       # ids whose text matches
```

## Prime directives (win every conflict — `get prime_directives`)

| # | Directive | Skill that carries it |
|---|---|---|
| P1 | Nothing fake: no mock, placeholder or dummy data on an application path | `testing` (fakes stay in tests), `code-review` |
| P2 | Only real, dynamic, correct, live information; honest failure | `code-review`, `systematic-debugging` |
| P3 | No hallucination: name only what you observed this session | `verification-before-completion`, `final-check` |
| P4 | Decisions as numbered options, recommended first, with a default (`get response_style`) | every skill that asks the user |
| P5 | Memory triad in sync: BRAIN, FLOW, DECISION | `project-memory` |
| P6 | Modular, debuggable in isolation: one responsibility, typed contracts, no god files | `clean-code` (within scope), `code-review` |
| P7 | Secure by design: validated boundaries, safe files and parsing, no leaks, scanned deps | `security`, `threat-modeling-expert`, `dependency-management-deps-audit` |
| P8 | Isolated, self-healing runtime: `run.bat` / `run.sh` + control panel | `self-healing-launcher` |
| P9 | Pervasive tracing: trace id through every step, file/line/touched, trace mode + report | `observability-tracing` |

When two skills seem to disagree: `get harmony` (one owner per concern, written resolutions).

## First, every time

1. Read the constitution in `AGENTS.md` (below the managed block), `.agents/profile.xml`, and the
   triad `PROJECT_BRAIN.md`, `FLOW.md`, `DECISION.md`.
2. If `profile.xml` says `status="UNFILLED"`, you are in **PRESET** → skill `project-setup`.
3. Otherwise you are in **THROUGHOUT** → `get task_loop`, then the skill for the task class.
4. Before saying done → **FINAL_CHECK** → skill `final-check`.

## Stage → load → run

| Stage | Load | Skill | Workflow | Gate |
|---|---|---|---|---|
| PRESET | `get PRESET` | `project-setup` | `new-project` | `doctor.sh`, `precheck.sh --all` |
| THROUGHOUT | `get task_loop`, rules by id | by task class (below) | `start-task` | hook on every commit |
| FINAL_CHECK | `get FINAL_CHECK` | `final-check` | `finalize-task` | `precheck.sh --final` / `--release` |

## Task class → skill

| Task | Skill chain |
|---|---|
| New feature, component, behaviour | `grill-with-docs` → `to-spec` → `to-tickets` → `implement-spec` · `tdd` (small change: `brainstorming` → `to-spec` → `implement`) |
| Bug, failing test, surprise | `systematic-debugging` → `test-driven-development` (regression test) |
| Commit | `commit` |
| Review / pull request | `code-review` (parallel Spec / Standards / Security reviewers) → `pr`; after the merge `retro`. Verify review feedback against the code before applying it |
| Tests | `testing` |
| Security, secrets, auth | `security`; design-level `threat-modeling-expert` |
| Dependency change | `dependency-management-deps-audit` (rule THR-16: scan → fix → rescan) |
| CI | `ci`; provider patterns `github-actions-templates` |
| Release, deadline, publish | `release` |
| Branch done | `finishing-a-development-branch` |
| Isolation | `using-git-worktrees` |
| Independent parallel work | `dispatching-parallel-agents` |
| Design choice | `architecture-decision-records`, `project-memory` |
| Readability (only when asked) | `clean-code` |
| Open source / going public | `oss-excellence` (module `.agents/modules/oss/`) |
| Running the project, launcher, run modes | `self-healing-launcher` |
| Logging, tracing, explaining a result | `observability-tracing` |

Skills not shipped but named by the profile's archetype (`get archetype_floors`) can be imported:
`install.sh --skills-from <library> --only name1,name2`.

## Non-negotiables (full text `get laws`)

No fabrication · live paths, mocks only in tests · verify before asserting · secrets never travel ·
read before changing · scope discipline · no destructive ops, commits, pushes without approval ·
errors surface · isolated environments · never weaken a check · current facts from the source ·
proportion · preserve what works · respect licences · no overlapping edits · state limitations.

## When something is missing

If `PROJECT.xml` or a module is absent, say so and run `sh .agents/bin/doctor.sh`. Do not
reconstruct rule text from memory and present it as the standard.
