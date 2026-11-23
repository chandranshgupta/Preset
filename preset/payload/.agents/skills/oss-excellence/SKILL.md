---
name: oss-excellence
description: Use when a project is or will become open source, or when asked "is this open-source ready", "audit this repo", "how good is this repository", "what should we improve to make it the best open-source project", or before making a repository public — runs the oss module (profile by archetype, five evidence levels, six gates, ESS/AVS scoring, ranked what-ifs) and returns evidence-backed findings.
---

# Open-source excellence (module router)

This skill routes into the **oss module** — one module of the project standard, not the whole
standard. The everyday rules live in `.agents/PROJECT.xml`; this module adds the depth a public
project needs.

| File | Role | Load policy |
|---|---|---|
| `.agents/modules/oss/CORE.xml` | procedure, gates, scoring, archetype floors, what-if seeds | load in full when this skill triggers |
| `.agents/modules/oss/DIRECTIVE.xml` | 125 rules, archetypes, what-if catalog, templates, glossary | load **one section or id** at a time |
| `.agents/bin/slice.sh -f oss` | section, phase and rule extractor | always the access path |
| `.agents/bin/precheck.sh` | gate | run, never read |

## Trigger table

| Situation | Do this |
|---|---|
| "Audit / review / how good is this repo" | CORE.xml → seven-step loop → report using `slice.sh -f oss get report_schema` (mode AUDIT, read-only) |
| "Improve / fix the repo" | CORE.xml → rank by leverage → implement P0/P1 only, under THROUGHOUT rules → re-run affected checks |
| "Release / publish / submit / make public" | CORE.xml + `slice.sh -f oss get timeboxed_sequence` + `precheck.sh --release` + skill `release` |
| New project that will be open source | mode BOOTSTRAP via skill `project-setup` (PRE-14) |
| Working one step of the loop | `slice.sh -f oss get PROFILE` (also VERIFY, EVALUATE, PRIORITIZE, WHATIF, ACT, REPORT) |
| "Which rules apply to a project like this" | `slice.sh -f oss get archetypes` |
| "What could we add / what's missing" | `slice.sh -f oss get whatif_catalog` |
| Any rule detail | `slice.sh -f oss get standards`, or `slice.sh -f oss get <ID>` (e.g. `SEC-03`) |
| A template (README, AGENTS, CI, PR, SECURITY, EVIDENCE_MAP, COMMIT) | `slice.sh -f oss get <TEMPLATE-ID>` |

## Non-negotiables

1. **Profile before judging.** Archetype, maturity, risk class, distribution, entry point,
   external dependencies, and what you cannot see. Reuse `.agents/profile.xml` when it is filled;
   verify it rather than trusting it. No verdict before this is written down.
2. **Five levels, never collapsed:** exists / configured / ran / passed / meaningful.
   A badge is not a run. A workflow file is not a green check.
3. **UNVERIFIED is a result, not a blank.** Unverified counts as zero in ESS and is reported
   as verification debt. Never round it up to "done".
4. **NA needs a written reason**, and NA may never be used to raise a score.
5. **Never invent a command result.** Report what you ran, its exit status, and what you
   could not run and why.
6. **Never commit or quote a secret.** If you find one, stop and report the path.
7. **Proportion.** Match the recommendation to the project's size, archetype and risk.
   Name the smallest sufficient version of every change.
8. **Preserve what is already good.** Do not edit files to demonstrate activity.
9. **Run the gate before you report done.** `sh .agents/bin/precheck.sh --final` for a change,
   `--release` before anything public, and paste the real output rather than asserting
   "all checks pass". The git hook covers commits; it does not cover your summary.

## Output shape

Load `slice.sh -f oss get report_schema` and follow it. The minimum: verdict, profile, gate table,
findings with a path or command as evidence, scores (ESS / AVS / verification debt), ranked
what-ifs each with a minimal version and a measurement, what to preserve, what not to do, what was
verified and how, what was not, owner-only actions, next three actions.

## When the module is absent

If `.agents/modules/oss/DIRECTIVE.xml` is missing, say so plainly and continue with CORE.xml,
PROJECT.xml and `precheck.sh`. Do not reconstruct the rule text from memory and present it as the
standard. Run `sh .agents/bin/doctor.sh`.
