---
description: THROUGHOUT stage — the working loop for any task, from orientation to verified handoff
---

# Start a task (THROUGHOUT)

Loop and rules: `sh .agents/bin/slice.sh get THROUGHOUT` (or `get task_loop` for the loop alone).

## Guardrails
- Only what the task needs; report tangents instead of fixing them (L07).
- No mocks on application paths; unknown value → ask (L01, L02).
- Verify by running; unrun is UNVERIFIED (L03).
- No commit, push or destructive operation without explicit approval (L08, L09).

## Steps

### 1. Orient
Read the constitution (`AGENTS.md`), `.agents/profile.xml`, `PROJECT_BRAIN.md`, `FLOW.md`,
`DECISION.md`. Trace the real code path. If a codebase graph exists, query it first (THR-28).

### 2. Classify and pick the skill
| Task | Skill |
|---|---|
| feature / behaviour change | `grill-with-docs` → `to-spec` → `to-tickets` → `implement-spec` |
| bug / failing test | `systematic-debugging` |
| any code | `test-driven-development` |
| dependency change | `dependency-management-deps-audit` (scan → fix → rescan) |
| several independent parts | `dispatching-parallel-agents` |

### 3. Isolate
Longer feature work on its own branch or worktree (`using-git-worktrees`).

### 4. Test first
Write or identify the test that proves the change; watch it fail for the right reason.

### 5. Change
Smallest coherent change, project conventions, tests and docs with the behaviour. No refactor
while fixing. Announce any new datastore or cache before adding it (THR-04).

### 6. Verify
Run what the change could break; record command, exit status, counts.

### 7. Remember
At a milestone, update memory (skill `project-memory`).

### 8. Hand off
Workflow `finalize-task`.
