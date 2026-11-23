---
trigger: always_on
description: Operating standard for this repository — read AGENTS.md, then route through .agents/PROJECT.xml.
---

# Project standard

Read `AGENTS.md` at the repository root before any task: its managed block routes to
`.agents/PROJECT.xml` (stages PRESET, THROUGHOUT, FINAL_CHECK), and the constitution below it
holds this project's own invariants and commands.

- Load one piece at a time: `sh .agents/bin/slice.sh get <SECTION-or-ID>`.
- Skills: `.agents/skills/` (router `project-standard`). Workflows: `.agents/workflows/`.
- Before saying done: `sh .agents/bin/precheck.sh --final`.
