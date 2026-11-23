---
description: FINAL_CHECK at release level — freeze, gate, version, changelog, clean-room proof, tag with approval, sync claims
---

# Release

Skill `release`; rules `sh .agents/bin/slice.sh get RELEASE`. Public project: also skill
`oss-excellence` in release mode and `sh .agents/bin/slice.sh -f oss get timeboxed_sequence`.

## Guardrails
- Scope frozen; fixes only until the tag.
- Tag, publish, deploy or submit only with explicit approval.
- Artifacts built by CI from the tagged commit.

## Steps
1. Freeze and write down in/out scope.
2. `sh .agents/bin/precheck.sh --release` — blockers are the release work.
3. Version from the diff (major / minor / patch).
4. Changelog: Added / Changed / Fixed / Removed / Security, user-visible effects.
5. Clean-environment proof of the README path; keep the transcript.
6. Tag and publish with approval; checksums where supported; rollback ready for deployments.
7. Sync README, badges, support tables, memory files.
8. After a submission: record the commit; no history rewrites or visibility changes.
