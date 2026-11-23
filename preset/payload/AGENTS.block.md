<!-- project-preset:begin — managed by project-preset/install; edits inside this block are replaced on reinstall -->

## Agent operating standard (project-preset + matt-pocock hybrid)

### Prime directives — these win every conflict

1. **Nothing fake.** No mock, stub, placeholder, canned answer, fake progress or dummy data on any
   application path. Test fixtures stay in tests, labelled.
2. **Only real, dynamic, correct, live information.** Values come from real inputs, services and
   computation, change when their source changes, and fail honestly. Facts that can change are
   fetched from the source, not recalled.
3. **No hallucination.** Name only files, functions, commands, flags, APIs and results you observed
   in this session. Unobserved → look it up, or say UNVERIFIED. "I don't know" beats a guess.
4. **Multi-option responses.** Any decision for the user → 2-4 numbered options, recommended first,
   one-line trade-off each, and the default. A bare number reply means "do that option".
5. **Memory triad & glossary in sync.** Read `PROJECT_BRAIN.md` (what is) · `FLOW.md` (how) ·
   `DECISION.md` (why) · `GLOSSARY.md` (ubiquitous terms) before non-trivial work; update triad at
   the cadence in `.agents/profile.xml` and `GLOSSARY.md` inline during grilling (`THR-44`).
6. **Modular, debuggable in isolation.** Deep modules with narrow typed contracts at clean seams,
   testable at the seam alone, no god files (`P6`, `THR-45`).
7. **Secure by design.** Validate every boundary, files checked by content, linear-time parsing
   with limits, errors that leak nothing, secrets only in the environment, deps scanned on change.
8. **Isolated, self-healing runtime.** Nothing global. One launcher per platform (`run.bat` /
   `run.sh`) heals the environment and offers run · trace · test · diagnose (skill
   `self-healing-launcher`).
9. **Pervasive tracing.** A trace id flows from every entry point through every step; each step
   records file, function, line, what it touched, duration, status. `run trace` adds line-level
   tracing and prints a report after the run (skill `observability-tracing`).

How these combine with every skill: `get harmony` (one owner per concern, no contradictions).

Also always: verify before asserting (run it, read real output) · secrets never in code, logs,
chat or commits · keep sessions inside the `<150k`-token Smart Zone (`THR-43`: never `/clear`
between `/grill-with-docs` and `/to-spec`; use fresh worktrees for `/to-tickets` &
`/implement-spec`) · no destructive ops, commits, pushes or PRs without explicit approval ·
errors surface, never swallowed · never weaken a check. Full text: `get prime_directives`, `get laws`.

### Where everything is

**Agents: read `.agents/INTEGRATION.md` first** (situation → skill map, flow, definition of done).

**Main file: `.agents/PROJECT.xml`** — load one piece at a time, never the whole file:
`sh .agents/bin/slice.sh get <SECTION-or-ID>` (Windows PowerShell/cmd: `.agents\bin\preset slice get <ID>`).

| Stage | When | Load | Run |
|---|---|---|---|
| **PRESET** | new repo, or first session here | `get PRESET`, skills `project-setup`, `setup-matt-pocock-skills` | fill `.agents/profile.xml`, `GLOSSARY.md`; `doctor` |
| **GRILL & SPEC** | shaping features or architecture | skills `grill-with-docs` → `to-spec` (same session) → `to-tickets` (fresh) | inline `GLOSSARY.md` + 3-gate `docs/adr/` |
| **THROUGHOUT** | every implementation task | `get task_loop`, `get router`, skills `implement` / `implement-spec`, `tdd` | seam tests first, isolated worktrees |
| **FINAL_CHECK** | before commit · "done" · PR · release | `get FINAL_CHECK`, skills `code-review`, `pr`, `final-check`, `retro` | `precheck --staged` · `--final` · `--release` |

Read before non-trivial work: the **constitution** below this block, `.agents/profile.xml`,
`CODING_STANDARDS.md`, `GLOSSARY.md`, `docs/adr/`, and the triad. Skills: `.agents/skills/`
(52 skills). Modules: `.agents/modules/oss/` and `.agents/modules/matt-pocock/`.

Precedence: P1–P9 > user's explicit instruction > constitution & profile > `PROJECT.xml` > modules > skills.
Conflicts are reported as options, never silently resolved.

<!-- project-preset:end -->
