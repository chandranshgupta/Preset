---
name: project-memory
description: Use before any non-trivial work and whenever work changes what exists, how it runs or why it is built that way — reads and synchronises the memory triad PROJECT_BRAIN.md (what is), FLOW.md (how it executes) and DECISION.md (why), at the cadence set in .agents/profile.xml, with honesty labels, the truth order, and no invented history.
---

# Project memory — the triad

Criteria: `sh .agents/bin/slice.sh get memory` (cadence, truth order, FLOW and DECISION formats),
rules THR-26, THR-38, FIN-08, FIN-11. Prime directive P5.

| File | Answers | Update when |
|---|---|---|
| `PROJECT_BRAIN.md` | what exists, its status, what is verified | boundaries or dependencies change; a schema or domain model changes; a subsystem is added or changes status; a test result changes; a root cause or edge case is found; prerequisites change |
| `FLOW.md` | how execution moves, entry to output, failure paths, fallback ladders | an execution path changes — in the same change |
| `DECISION.md` | why, what was rejected, what must stay true | an architectural, storage, contract, auth, concurrency, integration, recovery or trade-off choice is made or reversed |

Templates: `.agents/templates/`. Missing file → create it from the template with honest content.

## Cadence

Read `<memory_cadence>` in `.agents/profile.xml`:
- **MILESTONE** (default): update when a feature or phase finishes, a root cause is found, or a
  decision is made.
- **EVERY_TASK**: update before ending any task that changed code or behaviour. The commit gate
  warns when code is committed without a triad change.

Never for lint, formatting or trivial edits.

## Before non-trivial work

1. Read the three files.
2. Trace the real path from its entry point (do not trust FLOW.md blindly — confirm in code).
3. Check DECISION.md: does an entry constrain this change? If the change would reverse one,
   **stop and present options** (keep the decision / supersede it / adjust the change), with your
   recommendation first.
4. Make the minimal correct change and verify it by running it.
5. Update what the change affected.

## Truth order

Explicit project rules > verified code and passing tests > DECISION.md and FLOW.md >
PROJECT_BRAIN.md > older docs > inference. When a document contradicts verified code, fix the
document or label the conflict — never act on the stale text.

## Writing rules

- **FLOW**: exact files, functions and routes as a tree; mark each flow *Verified current* (with
  the proving command or test) or *Planned*; include failure paths and fallback ladders; never
  describe validation or behaviour that is not in code; remove obsolete flows.
- **DECISION**: `DEC-XXX` with Status, Date, Reversibility (Easy / Moderate / Hard), Context,
  Decision, Alternatives considered (only real ones, else "not evaluated"), Rationale, Consequences,
  Rejected alternatives, Constraints, Related. Supersede (`Superseded by DEC-YYY` /
  `Supersedes DEC-XXX`); never overwrite or erase.
- **BRAIN**: status understated rather than overstated; subsystems with evidence; dated check
  results with real commands.
- Labels everywhere: `[Status: Verified <command> <date>]` · `[Status: Inferred from code, not yet
  run]` · `[Status: Unverified / needs investigation]`.
- Never invent decisions, alternatives, features, API responses, benchmark numbers or security
  guarantees.

## Check it

```sh
sh .agents/bin/precheck.sh --final
```

It warns when backticked paths or relative links in the triad point at files that do not exist,
when template `<fill>` placeholders remain, and (EVERY_TASK) when code changed without the triad.
Resolve or explain each warning in the handoff (FIN-11, FIN-12).
