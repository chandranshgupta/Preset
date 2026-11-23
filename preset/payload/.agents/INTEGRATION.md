# INTEGRATION: read this first, then act

Audience: **any AI agent** working in a repository that has this preset installed (`.agents/` exists).
Goal: after reading this one file you know where everything is, which procedure to run for the
situation you are in, and what "done" means. Do not load the whole of `PROJECT.xml`; load slices.

## 0. What this is

`project-preset` (the operating standard: nine prime directives P1-P9, three stages, a gate) merged
with Matt Pocock's AI engineering system (grill → spec → tickets → implement → review → PR → retro).
The preset is the **constitution**; the Matt Pocock material is a **module and set of skills** that run
inside it. If they ever disagree, the preset wins (see section 7).

## 1. Orient in 60 seconds (always do this first)

```sh
cat AGENTS.md                              # the managed block + this project's own constitution
sh .agents/bin/doctor.sh                   # is the preset intact and wired?  (Windows: .agents\bin\preset doctor)
sh .agents/bin/slice.sh get prime_directives
sh .agents/bin/slice.sh get THROUGHOUT     # the task loop
```

Then read, if they exist: `.agents/profile.xml` (what the project is, its real commands) ·
`GLOSSARY.md` / `GLOSSARY-MAP.md` · `CODING_STANDARDS.md` · `docs/adr/` · the memory triad
`PROJECT_BRAIN.md` (what is) · `FLOW.md` (how it runs) · `DECISION.md` (why).

Never claim a file, command or behaviour you did not observe this session (P3, L19).

## 2. Pick your situation → run this

| Situation | Do this |
|---|---|
| Fresh repo, or `profile.xml` says `status` is not `FILLED` | Skill `project-setup` (PRESET stage), then skill `setup-matt-pocock-skills` once to bind the issue tracker, triage label and glossary layout |
| New feature / architecture change | `grill-with-docs` → `to-spec` **in the same session** → `to-tickets` (fresh session) → `implement-spec` (one worktree + fresh sub-agent per ready ticket) |
| Multi-session initiative | `wayfinder` first, then the chain above per decision |
| Small, fully specified change | `implement` (drives `tdd`, ends with `code-review`). Quick design pass wanted: `brainstorming` → `to-spec` |
| Bug / failing test / surprise | `diagnosing-bugs` (or `systematic-debugging`), regression test at the public seam via `tdd` |
| Code smells, hard-to-test area | `codebase-design`, then `improve-codebase-architecture` on high-churn hotspots |
| Domain words unclear | `domain-modeling` (writes `GLOSSARY.md` inline) |
| Before commit / "done" / PR | `code-review` → `pr` → `final-check` (`sh .agents/bin/precheck.sh --final`) |
| After a review cycle or ~5 automated PRs | `retro` (turn repeated feedback into compiler / lint / seam-test checks) |
| Release / going public | `release`; open source also module `.agents/modules/oss/` |
| User asks "why/how does Matt do X" | `ask-matt` |
| Writing prompts or skills for agents | `writing-for-agents` |
| Issues or external PRs to sort | `triage` |
| A design question a throwaway can answer | `prototype` |
| Facts from primary sources, kept in the repo | `research` |
| Steps only the human can perform (credentials, dashboards) | `wizard` |
| Ending a session, or passing work on | `handoff` |
| A decision you cannot make alone | `to-questionnaire` |
| The user says the last message did not land | `wait-what` |

If two rows fit, pick the first and say so. Unsure → offer 2-4 numbered options, recommended first,
with a default (P4, L20).

## 3. The flow in one picture

```text
PRESET        project-setup ─ setup-matt-pocock-skills ─ doctor
GRILL+SPEC    grill-with-docs ──(same session, NEVER /clear)──► to-spec
TICKETS       to-tickets          fresh session, vertical tracer bullets, each < 150k tokens
IMPLEMENT     implement-spec ─► tdd at module seams ─► one git worktree per ticket
FINAL_CHECK   code-review ─► pr ─► precheck --final ─► (merge) ─► retro
```

Machine-readable: `sh .agents/bin/slice.sh -f mp-core get GRILL` (a phase) and `sh .agents/bin/slice.sh -f mp get MP-05` (a rule, MP-01..16).
Rule ids added by the merge: `THR-43` context hygiene · `THR-44` glossary · `THR-45` deep modules and
three-gate ADRs · `FIN-16` PR rubric and retro ratchet.

## 4. Where things live

| Path | What |
|---|---|
| `AGENTS.md` | Entry point every agent reads; managed block + project constitution |
| `.agents/PROJECT.xml` | Main standard. Load by slice: `slice.sh get <SECTION-or-ID>` |
| `.agents/profile.xml` | Project profile and real commands (`--final` runs them) |
| `.agents/modules/matt-pocock/` | `CORE.xml` (phase chain) · `DIRECTIVE.xml` (MP rules) |
| `.agents/modules/oss/` | Open-source module |
| `.agents/skills/` | 52 skills; each is `SKILL.md` + supporting files |
| `.agents/workflows/` | 16 runbooks (`start-task`, `finalize-task`, `code-review`, ...) |
| `.agents/templates/domain/` | Starter `GLOSSARY.md`, `GLOSSARY-MAP.md`, `CODING_STANDARDS.md`, ADR template |
| `.agents/bin/` | `doctor`, `precheck` (the gate), `slice`, `preset` |
| `GLOSSARY.md`, `docs/adr/` | Project vocabulary and three-gate decisions (create from templates) |
| `DECISION.md` | Master decision ledger; index of every ADR |

## 5. Non-negotiables (short form, full text via `get prime_directives` and `get laws`)

1. Nothing fake, no hallucination: only observed, live, real information; "I don't know" beats a guess.
2. Decisions are numbered options with a recommendation and a default.
3. Keep the memory triad and `GLOSSARY.md` in sync with your change.
4. Deep modules, narrow typed contracts, tests at the seam; no god files.
5. Secure by design; secrets never in code, logs, chat or commits.
6. **No commit, push, PR, publish or destructive operation without the user's explicit approval** (L09),
   even if a vendored skill says "commit now".
7. Keep each session under about 150k tokens (THR-43). Never `/clear` between grilling and the spec.
8. Never weaken a check to make it pass. Errors surface; they are not swallowed.

## 6. Definition of done

- Tests written first at the public seam and passing; the project's declared commands pass.
- `sh .agents/bin/precheck.sh --final` exits 0 (warnings explained, blockers none).
- `code-review` run on the diff (Spec + Standards reviewers, plus Security for auth, data, public boundaries);
  review feedback was verified against the code before being applied.
- `GLOSSARY.md`, ADRs (only if all three gates hold), and the triad updated.
- PR (if one was requested) has the visual summary, runtime evidence and the One-Way/Two-Way Door + Blast
  Radius rating. Your handoff states what you ran and its real output.

## 7. Conflicts and precedence

`P1-P9` > the user's explicit instruction > constitution and `profile.xml` > `PROJECT.xml` > modules > skills.
Report a conflict as options; do not resolve it silently. Examples already resolved:

- Vendored skill says commit / push / open PR → **ask first** (L09).
- `brainstorming` vs `grill-with-docs`: both lead to `to-spec`. Use `grill-with-docs` for non-trivial work,
  `brainstorming` for a quick design pass. Never run both on the same decision.
- `executing-plans` vs `implement-spec`: use `implement-spec` for a published Spec with tickets;
  `executing-plans` only for a plan the user hands you.
- Matt's `tdd` and the preset's `test-driven-development`: same discipline; prefer `tdd` (seam-focused).

Retired in 2.3.0 (do not look for them): `writing-plans` → `to-spec` / `to-tickets`; `review`,
`requesting-code-review`, `receiving-code-review` → `code-review`.

## 8. If something is off

| Symptom | Fix |
|---|---|
| `doctor` fails | Re-run installer with `--force`; check `git` and `bash` are present (Windows needs Git for Windows) |
| `grill-with-docs` asks everything at once or skips `GLOSSARY.md` | `grilling` and `domain-modeling` must both exist in `.agents/skills/`; run `/grill-with-docs` in the repo root session (MP-BUG-01/02) |
| The spec softens a strict rule | You cleared context before `to-spec`; redo the grilling and audit the spec line by line (MP-BUG-03) |
| A skill you expect is missing | It was installed with `--no-vendored`; rerun the installer without it. `code-review` is always installed |
| Not sure which rule applies | `sh .agents/bin/slice.sh get router`, then `get harmony` |

CI automation templates from the Matt Pocock system (`agent-implement-issue.yml`, `daily-architecture-review.yml`,
`ci-deterministic-checks.yml`) are **not** auto-installed. They ship in the preset repo under
`extras/matt-pocock/starter-repo-template/.github/workflows/`; copy them only when the user asks, and only after
the trust ladder (supervised → worktree sub-agents → scheduled PRs) has been earned.
