---
name: commit
description: Prepare and write a commit in this repository — scope the change, run the gate on the staged tree, write a conventional subject and a why-body, split when needed. Use before any git commit, when the commit hook rejects a change, or when asked to commit, amend, or squash. Never commit unless the user asked.
---

# Commit

Criteria: `sh .agents/bin/slice.sh get THR-22` (one intent, conventional subject),
`get THR-23` (gate on every commit), `get L09` (only when asked). For the open-source reasoning:
`sh .agents/bin/slice.sh -f oss get GIT-01`, `get GIT-02`.

## Procedure

1. **Confirm you were asked to commit.** Editing is not permission to commit (L09).
2. **Look at what is staged.** `git diff --staged --stat` and `git diff --staged`. If nothing is
   staged, stop and say so rather than staging on the user's behalf.
3. **Check the boundary.** Unrelated files in the index is a split, not a message problem. Stage
   only the files this change needs; leave anything you did not touch alone.
4. **Run the gate yourself** before committing, so a rejection is not the first you hear of it:
   `sh .agents/bin/precheck.sh --staged`. A `BLOCK` result is not negotiable.
5. **Write the subject.** `<type>(<scope>): <description>` — imperative, lowercase, no trailing
   period, about 72 characters. Types: `feat fix docs style refactor perf test build ci chore
   revert security`. Scope is the component or area, and only when it adds information.
   Match the repository's existing style if it differs (`git log --oneline -10`).
6. **Write the body only if it earns its place.** Blank line, then why this change and what it
   costs, wrapped at 72. Do not narrate files; the diff does that. Reference issues when relevant.
7. **Commit.** Then report the hash and the subject line you used. Do not push unless asked.

## Rules that are yours to keep

- Never `--no-verify` to get past the gate. Fix the finding, or record a reviewed exception in
  `.agents/allow`.
- Never commit a secret, a rendered `.env`, or build output, even if the pattern missed it.
  If you find a live credential in history, stop and report the path — do not rewrite history
  on your own (L08).
- Amend or add a follow-up? Only for a commit you just made in this session and that nobody has
  pulled. Otherwise a new commit.
- One logical change per commit; if the subject needs "and", consider splitting.
- Attribution trailers only if the repository or the user's own instructions call for them.

## Evidence to report

`git diff --staged --stat` summary, the gate output, and the resulting hash. If the gate warned
rather than blocked, say which warnings you accepted and why — an accepted warning is a decision,
not a pass.
