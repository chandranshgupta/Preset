# ADR-0001: Strict Isolation Between Local Workspace State and Remote Publishing

- **Status:** Accepted
- **Date:** 2026-08-24

## Context
During local authoring and automated agent runs, lessons, scripts, and animatics undergo rapid iterative edits (`Draft Version`). Publishing updates external platform state and triggers downstream asset builds (`Course Version`).

## Decision
All local CLI/editor operations and automated agent test runs operate exclusively against local filesystem/database state. Remote platform synchronization is isolated behind a single explicit `publishCourseVersion` seam that requires either explicit human confirmation (`One-way door`) or verified CI release tags.

## Alternatives Considered & Trade-Offs
- **Option A (Chosen — Explicit Local/Remote Split):** Prevents accidental external side effects during agent loops; requires an explicit publish step.
- **Option B (Rejected — Auto-Sync on Save):** Simpler mental model, but turns routine agent edits into irreversible remote mutations (`One-way doors`).

## Consequences
- Agents can freely create, edit, and test `Draft Version` states without network credentials or risk of corrupting live releases.
- Any PR modifying the `publishCourseVersion` seam is automatically classified as a `One-way door` requiring human review.
