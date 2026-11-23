---
name: ci
description: Add or repair continuous integration — one workflow that installs from the lockfile and runs lint and the offline tests, plus only the extra jobs that answer a named question. Use when a repo has no CI, a workflow has never run, CI is slow or red for environmental reasons, or when asked to add a pipeline — even for a small project.
---

# CI

Criteria: `sh .agents/bin/slice.sh get PRE-08`. Open-source depth:
`sh .agents/bin/slice.sh -f oss get AUTOMATION` (rules `CI-*`), template
`sh .agents/bin/slice.sh -f oss get CI`. Provider patterns: skill `github-actions-templates`.

## The baseline is smaller than people think

One workflow, triggered on push to the default branch and on pull request:

1. check out
2. install the toolchain at a pinned version
3. install **from the lockfile** (frozen, no resolution drift)
4. lint / format check
5. run the offline test suite (live tests excluded by marker)

with `permissions: contents: read` at the top level. That is the whole required pipeline for most
repositories — and it is worth having even for a small one, because it is the cheapest proof that
the project still works. Everything else must justify itself with a question no earlier job answers.

## Procedure

1. **Read what exists.** `ls .github/workflows .gitlab-ci.yml .circleci Jenkinsfile`. A workflow
   file that has never produced a run is not CI — check the run history before believing it.
2. **Find the real commands** in `.agents/profile.xml`, the manifest, `Makefile`, `justfile`, or
   CONTRIBUTING — not from memory of the ecosystem. If no single documented test command exists,
   that is the first fix.
3. **Write the baseline** for the provider in use. Keep the toolchain version pinned to the one the
   lockfile assumes; use the provider's cache keyed on the lockfile.
4. **Make it fail honestly.** No `|| true`, no `continue-on-error` on the test step, no test step
   that only builds, no matrix over versions nobody supports (L12).
5. **Optionally gate the preset itself**: a step `sh .agents/bin/precheck.sh --all` makes the commit
   gate unskippable (a hook can be bypassed with `--no-verify`; a required check cannot).
6. **Prove it ran.** Push only when the user approves (L09), then read the run: job names, step
   outcomes, duration, the test counts in the log. A green badge without a run behind it is worse
   than no badge.

## What to add next, in order

| Addition | Question it answers | When it is worth it |
|---|---|---|
| Dependency update bot | are we falling behind? | as soon as there is one runtime dependency |
| Cache for the toolchain + deps | why is CI four minutes? | when the run exceeds ~2 minutes |
| Matrix over supported runtimes / OS | do we actually support both? | when the README claims more than one |
| Per-unit jobs | which half broke? | split frontend/backend or multi-package repos |
| Production build / contract freshness | does the shipped thing build? is the schema stale? | web apps, APIs |
| Release job on tag | how does a user get this? | when there is a version and an artifact |
| Secret / dependency / static scan | did we ship a key or a CVE? | before public launch, always |
| Coverage upload | what is untested? | only when someone will act on it |

Never add a job to make the matrix look thorough. Every job answers a named question.

## Report

The workflow path · that it has run, with the run outcome and duration · how long the test step
took · which jobs you added and the question each answers · what is deliberately absent and why ·
the settings you cannot change from the repository (branch protection, required checks) as owner
actions.
