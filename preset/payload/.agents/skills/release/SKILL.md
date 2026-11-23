---
name: release
description: Cut a release or a submission — freeze scope, choose the version, write the changelog from commits, prove the documented install path from a clean environment, tag, publish, and sync every claim. Use before tagging, publishing to a registry, deploying, submitting to a judge or client, or declaring a version ready; also under any deadline.
---

# Release

Criteria: `sh .agents/bin/slice.sh get RELEASE` (FINAL_CHECK level). Open-source depth:
`sh .agents/bin/slice.sh -f oss get RELEASE_AND_MAINTENANCE` (rules `REL-*`) and
`sh .agents/bin/slice.sh -f oss get timeboxed_sequence` for the deadline order.

## Sequence

1. **Freeze.** No new scope. Bug fixes only until the tag exists. Write down what is in and what
   is out; an unstated scope creeps. Under a deadline, stop features well before it.
2. **Gate.** `sh .agents/bin/precheck.sh --release`. Blockers here are the release, not an
   obstacle to it.
3. **Version.** Semver by compatibility, read from the diff rather than from optimism: breaking
   public behaviour is major, added behaviour is minor, fixed behaviour is patch. A project before
   1.0 still owes its users a note when something breaks.
4. **Changelog.** From the commit log, grouped `Added / Changed / Fixed / Removed / Security`, each
   line naming the user-visible effect and, where one exists, the issue. A changelog line is not
   a commit subject copy-pasted; it says what changed for the person using it.
5. **Prove the documented path.** In a clean environment — new directory, no dev dependencies, no
   pre-existing config — follow the README exactly as written. Install, run the example, observe
   the output. This is the step that catches the missing export, the undeclared dependency, the
   example that references a file the user does not have.
6. **Tag and publish — with approval (L09).** Annotated tag matching the version, artifact built by
   CI from the tagged commit rather than from a laptop, checksums or provenance where the ecosystem
   supports it. Deployments: rollback path and post-release health check ready first.
7. **Sync the claims.** README install line, badge versions, supported-version table, docs that
   state a version, memory files. A stale claim after a release is a defect users hit immediately.
8. **Do not disturb.** After a submission: no history rewrites, force pushes, or visibility changes
   while it may be under evaluation. Record the exact commit that was submitted.

## Common ways releases go wrong

- Published artifact differs from the tagged source (built on a machine, not in CI).
- The README's install command references a name or scope that was never published.
- `files`/`include`/`MANIFEST` omits something the runtime needs — the package works in the repo
  and fails on install.
- Version bumped in one manifest and not the others in a monorepo.
- Changelog written after the tag from memory, missing the breaking change.
- Release notes promise a feature that is merged but not in the tagged commit.
- Migrations shipped without a tested rollback.

## Report

Version and why that number · changelog entries · the clean-environment transcript (commands and
real output) · artifacts and their checksums · CI run that produced them · what remains manual and
owner-only (registry credentials, signing keys, publishing rights, deploy approval) · anything you
could not verify.
