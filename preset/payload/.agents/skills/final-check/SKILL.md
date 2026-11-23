---
name: final-check
description: Use before saying any task is done, fixed or passing, before handing work back, before committing, and before any release or submission — runs .agents/bin/precheck.sh at the right level, executes the project's declared lint/test/build/smoke commands, walks the FIN checklist and produces an evidence-backed handoff. Never claim success without it.
---

# Final check (FINAL_CHECK stage)

Criteria: `sh .agents/bin/slice.sh get FINAL_CHECK` (levels COMMIT, TASK, RELEASE; rules FIN-01..FIN-10).

## Pick the level

| Level | When | Command |
|---|---|---|
| COMMIT | every commit (the git hook runs it; run it yourself first) | `sh .agents/bin/precheck.sh --staged` |
| TASK | before saying done | `sh .agents/bin/precheck.sh --final` |
| RELEASE | before tag, publish, submit, make public | `sh .agents/bin/precheck.sh --release`, then skill `release` |

`--final` = repository scan + runs every non-empty `<command>` in `.agents/profile.xml`
(lint, test, build, smoke, preflight) and reports real exit codes. If no commands are declared,
that is a finding: declare them, do not invent them.

Exit codes: `0` clean (warnings allowed) · `1` blockers · `2` cannot run.

## Checklist (answer each with evidence)

| Id | Question | Evidence |
|---|---|---|
| FIN-01 | Gate output quoted; no BLOCK; each accepted WARN named with a reason? | precheck output |
| FIN-02 | Every declared command run on the final state? Unrun → UNVERIFIED + blocker | exit codes, counts |
| FIN-03 | No secret, personal data or machine path in diff, message, logs, report? | `git diff`, gate |
| FIN-04 | No mock / placeholder / hard-coded answer on an application path? | diff review |
| FIN-05 | New or changed deps scanned (THR-16) and licences checked? Else UNSCANNED | audit output |
| FIN-06 | Diff only what the task needs; tangents listed, not changed? | `git diff --stat` |
| FIN-07 | Docs, example config, constitution commands still true? | commands re-run |
| FIN-08 | Memory updated if a milestone was reached; decision recorded? | memory diff |
| FIN-09 | Self-review done (skill `code-review`); independent review for larger changes? | findings |
| FIN-10 | Owner-only actions named? | handoff |
| FIN-11 | Triad (BRAIN, FLOW, DECISION) in sync with the code, per the profile's cadence? | triad diff, gate |
| FIN-12 | Every path, function, command, flag, API and link you named was observed this session? | gate broken-reference warnings, your reads |

Then apply skill `verification-before-completion`: every success word in the handoff points at a
command you ran in this state.

## Handoff shape

```
Outcome: <one line>
Changed: <files and behaviour>
Verified: <command> → exit <n>, <counts>   (one line each)
Not verified: <what> — <blocker>
Gate: <precheck summary line>
Decisions: <DEC ids or none>
Owner actions: <rotate / approve / push / settings>
Next: <three actions>
```

If anything needs the user's decision (accept a warning, commit, push, choose a fix), end with
numbered options, recommended first, and the default (prime directive P4):

```
**Decision: <one line>**
1. **<option> (recommended)** — <effect>. Trade-off: <cost>.
2. **<option>** — <effect>. Trade-off: <cost>.
Reply with a number. If you say nothing, I will <default>.
```

## Never

`--no-verify`; loosening a test to get green; "should work"; reporting a command you did not run;
pasting a secret value while reporting one.
