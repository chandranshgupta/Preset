---
description: Generate a conventional commit from staged changes, through the gate, only when asked
---

# Git commit

Skill `commit`; rules THR-22, THR-23, L09.

## Guardrails
- Only analyse staged changes (`git diff --staged`); don't commit if nothing is staged.
- Conventional Commits; subject under 72 characters.
- Commit only when the user asked; never push without approval.
- Never `--no-verify`.

## Steps

### 1. Analyse staged changes
`git diff --staged --stat`, `git diff --staged`; identify type and scope. Unrelated files staged →
propose a split.

### 2. Run the gate
`sh .agents/bin/precheck.sh --staged`. A BLOCK is fixed, not bypassed.

### 3. Determine type
| Type | When |
|---|---|
| `feat` | new feature |
| `fix` | bug fix |
| `docs` | documentation only |
| `style` | formatting, no code change |
| `refactor` | neither fixes nor adds |
| `perf` | performance |
| `test` | tests |
| `build` | build system, dependencies |
| `ci` | pipeline |
| `chore` | tooling, housekeeping |
| `revert` | revert |
| `security` | security fix |

### 4. Scope (optional)
Component (`auth`, `api`, `ui`), feature area (`login`), or file kind (`deps`, `config`).

### 5. Write the message
`<type>(<scope>): <description>` — imperative ("add" not "added"), lowercase start, no period,
specific. Examples: `feat(auth): add OAuth2 login flow` · `fix: resolve null pointer in user
service` · `refactor(api): extract validation logic`.

### 6. Body if needed
Blank line; what and why, not how; wrap at 72; reference issues (`fixes #123`).

### 7. Confirm and commit
Present the message; commit with it, modify it, or add detail — as the user chooses. Report the hash.

## Principles
One commit = one logical change. If the subject needs "and", split. Check the house style with
`git log --oneline -10`. Reference: conventionalcommits.org.
