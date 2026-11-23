# AGENTS.md

This repository follows Matt Pocock's composable AI engineering workflow (`mattpocock/skills`).

## Ubiquitous Language & Domain Decisions
- Before exploring, planning, specking, or writing code, read `GLOSSARY.md` at the repository root (or follow `GLOSSARY-MAP.md` if present).
- Always use exact domain terms from `GLOSSARY.md` across variable names, module names, database schemas, tests, and documentation.
- Before making architectural changes, read `docs/adr/` to respect past hard-to-reverse decisions.

## Coding Standards & Verification
- Follow every rule in `CODING_STANDARDS.md`.
- Prefer deterministic enforcement (strict types, linter rules, fast seam tests) over prose workarounds.
- Keep context windows inside the `<150,000`-token Smart Zone: never carry bloated exploration history into implementation; use fresh worktrees/sessions per ticket when executing multi-ticket specs.

## Workflow Chain
1. `/grill-with-docs` — Align requirements, update `GLOSSARY.md` inline, record 3-gate ADRs in `docs/adr/`.
2. `/to-spec` (in the SAME session) — Synthesize settled decisions into a Spec with explicit module seams.
3. `/to-tickets` (fresh session) — Break Spec into `<150k`-token tracer-bullet tickets with blocking edges.
4. `/implement` or `/implement-spec` — Build via `/tdd` at pre-agreed seams.
5. `/code-review` + `/pr` — Adversarial Spec + Standards (+ Security) review, then PR with visual summary, runtime evidence, and merge-danger rating.
6. `/retro` — Convert recurring review feedback into deterministic lint/type/test checks.
