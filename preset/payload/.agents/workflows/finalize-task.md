---
description: FINAL_CHECK stage — gate, run the declared checks, scan, review and hand off with evidence before calling anything done
---

# Finalize a task (FINAL_CHECK)

Skill `final-check`; rules `sh .agents/bin/slice.sh get FINAL_CHECK`.

## Guardrails
- Never say done, fixed or passing without a command run on the final state (L03).
- Never `--no-verify`, never loosen a test to get green (L12).
- Never print a secret value while reporting one (L05).

## Steps

### 1. Gate and declared checks
```sh
sh .agents/bin/precheck.sh --final
```
Runs the repository scan plus every command declared in `.agents/profile.xml`. Exit `1` means stop.

### 2. Security of the change
New or upgraded dependency → audit (THR-16): scan → fix → rescan. No scanner available → mark
the task UNSCANNED in the handoff.

### 3. Self-review
Skill `code-review` on `git diff` (parallel Spec, Standards & Security reviewers). Format PRs with `pr`
reviewer.

### 4. Truth sync
Docs, `.env.example`, constitution commands, memory files (skill `project-memory`).

### 5. Evidence before claims
Skill `verification-before-completion`: each success word points at a command you ran.

### 6. Hand off
```
Outcome · Changed · Verified (command → exit, counts) · Not verified (why) · Gate summary ·
Decisions · Owner actions · Next three
```
Commit only if asked (skill `commit`). Branch finished → skill `finishing-a-development-branch`.
Release → workflow `release`.
