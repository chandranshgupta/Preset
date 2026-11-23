# Production AI Engineering Integration Guide
**Complete Architectural & Operational Blueprint Synthesized from Matt Pocock's `mattpocock/skills`, `course-video-manager`, `sandcastle`, `dictionary-of-ai-coding`, AI Hero Docs (`/grill-with-docs`), and Live Walkthrough**

---

## Table of Contents
1. [Core Philosophy: Strategic vs. Tactical Programming](#1-core-philosophy-strategic-vs-tactical-programming)
2. [The 5-Repository Ecosystem & Architecture](#2-the-5-repository-ecosystem--architecture)
3. [Harness, Model & Reasoning Effort Configuration](#3-harness-model--reasoning-effort-configuration)
4. [Installation & Per-Repository Setup](#4-installation--per-repository-setup)
5. [The Main Engineering Loop (Step-by-Step Execution)](#5-the-main-engineering-loop-step-by-step-execution)
6. [Context Window Management ("Smart Zone vs. Dumb Zone")](#6-context-window-management-smart-zone-vs-dumb-zone)
7. [Domain Modeling: Ubiquitous Language (`GLOSSARY.md`) & Three-Gate ADRs](#7-domain-modeling-ubiquitous-language-glossarymd--three-gate-adrs)
8. [Codebase Architecture Hygiene: Deep Modules, Seams & Boundary Testing](#8-codebase-architecture-hygiene-deep-modules-seams--boundary-testing)
9. [Deterministic Guardrails & Feedback Loops](#9-deterministic-guardrails--feedback-loops)
10. [Scaling Trust & Building a Software Factory (CI/CD & Cron Automation)](#10-scaling-trust--building-a-software-factory-cicd--cron-automation)
11. [Production Security Hardening (Beyond Personal Software)](#11-production-security-hardening-beyond-personal-software)
12. [Known Failure Modes, Bugs & Verification Checklist](#12-known-failure-modes-bugs--verification-checklist)

---

## 1. Core Philosophy: Strategic vs. Tactical Programming

Drawing from John Ousterhout's *A Philosophy of Software Design*, software engineering divides into two distinct modes:

| Dimension | Tactical Programming | Strategic Programming |
| :--- | :--- | :--- |
| **Focus** | Winning today's battle — making the immediate feature or bugfix work right now. | Winning the war — keeping the codebase intelligible, modular, and safe to change 9 months from now. |
| **AI Capability** | **Extremely strong.** Models are benchmarked on isolated tactical tasks and excel at writing code quickly. | **Weak by default.** Agents optimize for immediate task completion and will steadily accumulate entropy ("slop"). |
| **Human Role** | Delegate to agents via scoped tickets, `/tdd` loops, and deterministic automated checks. | **Own this layer.** Curate ubiquitous language, deep module seams, specs, coding standards, and feedback loops. |

### Five Governing Principles
1. **Fix the Environment, Not Just the Model:** Instead of waiting for a newer model or cranking reasoning effort to maximum, improve the environment the agent operates in (`GLOSSARY.md`, `CODING_STANDARDS.md`, `docs/adr/`, strict types, fast seam tests, and clean module boundaries).
2. **Determinism Over Non-Determinism:** Whenever a constraint can be enforced deterministically (TypeScript compiler flags, strict ESLint/Biome rules, fast unit tests, CI pipelines), enforce it there rather than in a prose prompt. Deterministic checks cost **0 tokens** and run identically every time.
3. **Care About Design Every Day:** AI radically accelerates code output, which equally accelerates software entropy. Without daily architectural hygiene, an AI-authored repo degrades into an unmaintainable "ball of mud."
4. **Small, Composable Skills Over Heavy Frameworks:** Heavy meta-frameworks (BMAD, Spec-Kit, etc.) take away control and hide bugs inside rigid orchestration wrappers. Small, composable skills keep the human in charge of every critical transition.
5. **Climb the Trust Ladder Intentionally:** Scale from one supervised session to parallel worktree sub-agents and scheduled cron PRs only as your automated verification evidence and blast-radius controls mature.

---

## 2. The 5-Repository Ecosystem & Architecture

Matt Pocock's production setup spans five interconnected repositories/workspaces:

1. **`mattpocock/skills` (`~/.agents/skills/` / `aihero.dev/skills`)** — Public MIT repository of ~39 composable agent skills, partitioned strictly into **User-Invoked Orchestrators** (`disable-model-invocation: true`) and **Model-Invoked Primitives**.
2. **Product Repository (e.g., `mattpocock/course-video-manager`)** — Screen-shared production codebase (~2,500 commits) containing `CLAUDE.md`, root `GLOSSARY.md`, uppercase `CODING_STANDARDS.md`, 31 files under `docs/adr/`, `docs/agents/prompts/`, and `.github/workflows/`.
3. **`mattpocock/sandcastle`** — Open-source TypeScript agent orchestration engine (`sandcastle.run()`) that runs coding agents inside isolated sandboxes (Docker, Podman, or Vercel).
4. **`mattpocock/dictionary-of-ai-coding`** — Open-source Markdown knowledge graph (`dictionary/*.md`) defining shared AI engineering concepts (`smart zone`, `automated checks`, `software factory`, `sandboxes`) so humans and agents share exact terminology.
5. **`personal-wiki/` (Private Knowledge & Life-Ops Repo)** — A Karpathy-style LLM-maintained Markdown wiki updated every 3 hours via cron from Tweets/mentions, Discord, Slack, and Gmail, paired with a voice-dictated daily triage backlog (`todo-triage.md`).

---

## 3. Harness, Model & Reasoning Effort Configuration

### Recommended Toolchain
* **Agent Harness:** Claude Code (primary), OpenAI Codex CLI, GitHub Copilot CLI/VS Code, or Gemini CLI (all support the `SKILL.md` standard).
* **Editor & VCS:** VS Code + Git (using **Git worktrees** for parallel sub-agent tickets) + GitHub (Issues, Sub-Issues, Pull Requests, GitHub Actions).
* **Voice Input:** Whisper Flow (or OS dictation) to remove typing friction during `/grill-with-docs` interviews and offline brain-dumps.

### Model & Effort Rule (Token & Accuracy Optimization)
* **Default Effort = `medium` (or `low` for pure exploration):** Run your primary coding model (e.g., Claude Opus / Sonnet) on **`medium` effort** for day-to-day grilling, specking, and implementation.
* **Why `high` / `xhigh` / `max` Hurts Early Stages:**
  * Codebase exploration does not produce better insights from extra reasoning tokens—it simply reads more files, burns tokens early, and pushes your session into the **Dumb Zone** before implementation begins.
* **When to Escalate to `high` Effort:**
  * **Verification & QA:** Clicking through a live browser app, running performance traces, or executing adversarial security/bug checks.
  * **Deep Web Research & Hard Debugging:** Navigating noisy external docs or isolating elusive race conditions (`/diagnosing-bugs`).

---

## 4. Installation & Per-Repository Setup

### Step 1: Install `mattpocock/skills`
Pick **one** installation method per agent harness (installing both an auto-updating plugin and a manual `skills.sh` copy registers duplicate skills):

* **Claude Code (Auto-Updating Official Plugin — Recommended):**
  ```bash
  claude plugin install mattpocock-skills@claude-plugins-official
  ```
* **OpenAI Codex CLI:**
  ```bash
  codex plugin marketplace add mattpocock/skills
  codex plugin add mattpocock-skills@mattpocock
  ```
* **GitHub Copilot (CLI & VS Code):**
  ```bash
  copilot plugin marketplace add mattpocock/skills
  copilot plugin install mattpocock-skills@mattpocock
  ```
* **Gemini CLI:**
  ```bash
  gemini skills install https://github.com/mattpocock/skills.git --path skills/engineering
  gemini skills install https://github.com/mattpocock/skills.git --path skills/productivity
  ```
* **Universal / Editable Local Files (`skills.sh`):**
  ```bash
  # Install the full suite:
  npx skills@latest add mattpocock/skills

  # Or install just /grill-with-docs and its two required dependencies:
  npx skills@latest add mattpocock/skills --skill=grill-with-docs --skill=grilling --skill=domain-modeling
  ```

### Step 2: Initialize Your Target Repository
Inside your repo, run once:
```text
/setup-matt-pocock-skills
```
This configures:
1. **Issue Tracker:** GitHub Issues, GitLab, or local Markdown files.
2. **Triage Labels:** E.g., `ready-for-agent` (or custom repo aliases like `Sandcastle`).
3. **Domain Doc Layout:** Single-context (`GLOSSARY.md` at root + `docs/adr/`) or multi-context (`GLOSSARY-MAP.md` at root).

### Step 3: Drop In Starter Scaffolding
Copy the files from `starter-repo-template/` in this archive into your project root (`AGENTS.md`, `CLAUDE.md`, `CODING_STANDARDS.md`, `GLOSSARY.md`, `docs/adr/`, `docs/agents/`, and `.github/workflows/`), then adapt `CODING_STANDARDS.md` to your stack.

---

## 5. The Main Engineering Loop (Step-by-Step Execution)

```text
  ┌─────────────────────────────────────────────────────────────────────┐
  │ 1. /grill-with-docs  (Delegates to `grilling` + `domain-modeling`)  │
  │    • Sub-agents answer factual questions by reading the codebase    │
  │    • Walks a decision tree round-by-round with recommendations      │
  │    • Writes terms inline to GLOSSARY.md & 3-gate ADRs to docs/adr/  │
  └──────────────────────────────────┬──────────────────────────────────┘
                                     │
                     ┌───────────────┴───────────────┐
                     │  Does total work fit inside   │
                     │  < 150,000 tokens (Smart Zone)?│
                     └───────────────┬───────────────┘
                        YES          │          NO
                         │           │           │
                         ▼           │           ▼
  ┌──────────────────────────────┐   │  ┌───────────────────────────────┐
  │ 2a. /implement (Same Session)│   │  │ 2b. /to-spec (Same Session)   │
  │   • Drives /tdd at seams     │   │  │   • Synthesizes conversation  │
  │   • Runs /code-review        │   │  │   • Locks module seams        │
  │   • Commits to branch        │   │  │   • Publishes Spec to tracker │
  └──────────────────────────────┘   │  └───────────────┬───────────────┘
                                     │                  │
                                     │                  ▼
                                     │  ┌───────────────────────────────┐
                                     │  │ 3. /to-tickets (Fresh Session)│
                                     │  │   • Breaks Spec into ~150k-   │
                                     │  │     token tracer-bullet slices│
                                     │  │   • Declares blocking edges   │
                                     │  └───────────────┬───────────────┘
                                     │                  │
                                     │                  ▼
                                     │  ┌───────────────────────────────┐
                                     │  │ 4. /implement-spec (Fresh)    │
                                     │  │   • Parallel sub-agents in    │
                                     │  │     isolated Git worktrees    │
                                     │  │   • Merges to integration PR  │
                                     │  └───────────────┬───────────────┘
                                     │                  │
                                     └─────────┬────────┘
                                               ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │ 5. /code-review + /pr                                               │
  │    • Parallel Spec Reviewer + Standards Reviewer (+ Security)       │
  │    • PR body: Visual summary + Runtime evidence + Merge Danger      │
  └────────────────────────────────────┬────────────────────────────────┘
                                       ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │ 6. Human Merge Decision + /retro                                    │
  │    • Sampled review for 2-way doors; deep review for 1-way doors    │
  │    • /retro converts review comments into deterministic checks      │
  └─────────────────────────────────────────────────────────────────────┘
```

### Entry Skill Selection Matrix
| Scenario | Skill to Invoke |
| :--- | :--- |
| Working outside any directory / pure idea stress-testing | `/grill-me` |
| Repo + feature/refactor settleable in **one session** | `/grill-with-docs` |
| Effort too big for one session (greenfield build, major overhaul) | `/wayfinder` (maps decision tickets first, then hands slices to `/grill-with-docs`) |
| Existing repo with zero domain docs and no single feature yet | `/grill-with-docs` aimed at the repo (*"help me document my repo"*), paired with `/improve-codebase-architecture` |
| Decision blocked on knowledge in someone else's head | `/to-questionnaire` |
| Unsure which skill fits | `/ask-matt` |

---

## 6. Context Window Management ("Smart Zone vs. Dumb Zone")

Even when a model advertises a 1,000,000-token context window, attention degrades quadratically as tokens accumulate:

* **Smart Zone (`0` to `~150,000` tokens):** Sharp instruction following, accurate cross-file synthesis, low latency, low token cost.
* **Dumb Zone (`> 150,000` tokens):** Agent forgets negative requirements, softens edge cases, introduces subtle bugs, and slows down.

### Three Non-Negotiable Context Rules
1. **NEVER `/clear` Between `/grill-with-docs` and `/to-spec`:**
   * `/grill-with-docs` writes **domain terms** to `GLOSSARY.md` and **3-gate decisions** to `docs/adr/`. Everything else you agreed on (numeric defaults, ordering guarantees, negative constraints) lives **only in the conversation window**.
   * Hand that **exact same conversation** straight to `/to-spec` (or `/implement` for tiny changes).
   * **Verify the Spec Against Your Answers:** Re-read the generated Spec line-by-line against your grilling answers before publishing, because LLMs frequently soften strict constraints into weaker prose.
2. **Start Fresh Sessions After `/to-spec`:**
   * Run `/to-tickets` in a clean session reading the published Spec.
   * Run `/implement-spec` in a clean session; each sub-agent runs inside an isolated Git worktree with its own fresh `<150k`-token Smart Zone budget.
3. **Optimize Codebase Navigability:**
   * Large codebases do not inherently consume more tokens—*unstructured* codebases do. Ubiquitous `GLOSSARY.md` naming + deep modules let sub-agents find target files immediately.

---

## 7. Domain Modeling: Ubiquitous Language (`GLOSSARY.md`) & Three-Gate ADRs

### How `GLOSSARY.md` Works
* **Stateful & Inline:** Unlike `/grill-me` (which leaves everything in your head), `/grill-with-docs` writes resolved terms to `GLOSSARY.md` **inline the moment each term settles**—not in a batch at the end.
* **Pure Vocabulary Only:** `GLOSSARY.md` holds concise domain terms and tight definitions (e.g., *"the materialization cascade"* instead of a 20-word circumlocution). Never put implementation details, schemas, or spec prose in `GLOSSARY.md`.
* **Multi-Context Repositories (`GLOSSARY-MAP.md`):** If `GLOSSARY-MAP.md` exists at the repository root, `/grill-with-docs` routes terms to the matching bounded context's `GLOSSARY.md`.

### The Three Gates for Architectural Decision Records (`docs/adr/`)
A decision earns an ADR (`docs/adr/NNNN-slug.md`) **only when it passes all three gates simultaneously**:
1. **Hard to reverse** (high migration or rewrite cost later).
2. **Surprising without context** (a future engineer or agent reading the code would assume the opposite).
3. **A real trade-off** (both options had genuine merit).

*A session that produces a sharper `GLOSSARY.md` and zero ADRs is working exactly as designed.*

---

## 8. Codebase Architecture Hygiene: Deep Modules, Seams & Boundary Testing

### Deep Modules vs. Shallow Modules (Ousterhout)
* **Shallow Module (Anti-Pattern):** Thin wrappers or duplicated handlers (`problem-submit` and `duplicate-course` sharing ~150 near-identical lines) where interface complexity rivals implementation complexity.
* **Deep Module (Target):** Substantial functionality encapsulated behind a narrow, clean interface. You can "turn the lights off" inside the module because callers and tests interact only with its narrow entry point.

### Seams & Boundary Testing (Michael Feathers)
* **Anti-Pattern:** Unit tests coupled to internal helpers or constants—every internal refactor breaks tests and causes endless churn.
* **Production Pattern:** Identify the highest clean **seam** of a deep module and test external behavior through that seam using `/tdd` (red-green-refactor vertical slices).

### Continuous Refactoring Workflow
1. Run `/improve-codebase-architecture` every few days (or via daily cron).
2. Inspect the generated **HTML visual report** (`Before` vs. `After` module architecture diagrams).
3. Feed the top candidate into `/to-spec` -> `/to-tickets` -> `/implement-spec`.
4. If the report uses unfamiliar architectural vocabulary (*locality*, *seams*, *deep modules*), pass the report to `/teach` to generate interactive HTML lessons and quizzes.

---

## 9. Deterministic Guardrails & Feedback Loops

1. **Strict Static Types (`CODING_STANDARDS.md` + `tsconfig.json`):**
   * Enable `strict: true` and `noUncheckedIndexedAccess: true`.
   * Ban `any` (`@typescript-eslint/no-explicit-any: "error"`). Every `any` blinds the compiler feedback loop.
   * Use explicit, tagged domain errors (`Effect.fail(new TaggedError(...))`) rather than untyped exceptions.
2. **Harsh Linter Rules:**
   * Enforce module import boundaries and framework rules in ESLint/Biome so violations fail in `< 2 seconds`.
3. **Fast, Sharded Test Suite & Browser Verification:**
   * Keep seam unit tests fast (`npm run check`), shard slow integration suites across CI workers, and verify UI changes in a real headless browser.
4. **The `/retro` Ratchet:**
   * Run `/retro` after sessions or every ~5 automated PRs. Convert recurring human review feedback into deterministic lint rules, compiler checks, or seam tests first; only add prose rules to `CODING_STANDARDS.md` as a last resort.

---

## 10. Scaling Trust & Building a Software Factory (CI/CD & Cron Automation)

### Merge Danger Rubric (`/pr`)
Every PR includes:
1. **Visual Summary**
2. **Runtime Execution Evidence** (test trace or browser screenshot)
3. **Merge Danger Call:**
   * **One-Way Door vs. Two-Way Door:** Irreversible side effects (destructive migrations, external emails, billing/auth) vs. easily revertible code changes.
   * **Blast Radius:** `Small` vs. `Large` production impact.

| Door Type | Blast Radius | Human Review Policy |
| :--- | :--- | :--- |
| **Two-Way Door** | **Small** | **Sampled review** (e.g., inspect 1 in every 5 automated PRs once CI + `/code-review` pass). |
| **Two-Way Door** | **Large** | Review architectural diff & runtime evidence; merge once verified. |
| **One-Way Door** | **Small or Large** | **Mandatory deep human review** + security review + staging verification. |

### Deterministic CI/CD Deployment
* Never spend LLM tokens asking an agent to SSH into servers and deploy code. Trigger deterministic builds/deploys via GitHub Actions, Vercel, or Netlify on merge to `main`.

---

## 11. Production Security Hardening (Beyond Personal Software)

Matt explicitly notes that `course-video-manager` is single-user personal software, whereas **multi-user, commercial, fintech, or public production apps require a third review axis**:

1. **Add a Security Review Axis to `/code-review`:** Run your harness's security reviewer in parallel with the `Spec` and `Standards` reviewers on every PR.
2. **Enforce Security Invariants in `CODING_STANDARDS.md` & CI:**
   * Server-side authorization checks on every mutation/endpoint.
   * Parameterized queries / ORM-only database access (zero raw SQL string interpolation).
   * Startup environment validation (`Config` / Zod) + automated secret scanning (`gitleaks`) + dependency vulnerability audits (`npm audit` / Trivy) in CI.
3. **Treat Auth, Permissions, Payments & Migrations as `One-Way Doors`:** Require mandatory human sign-off before merge.

---

## 12. Known Failure Modes, Bugs & Verification Checklist

### Troubleshooting Matrix (From AI Hero `/grill-with-docs` Docs)
| Symptom | Root Cause | Fix |
| :--- | :--- | :--- |
| `/grill-with-docs` asks everything at once with no recommendations and never mentions `GLOSSARY.md`. | `grill-with-docs/SKILL.md` is a 1-line delegation (`Call the Skill tool twice, for "grilling" and "domain-modeling"`). The model failed to load one or both dependencies. | Confirm both `grilling` and `domain-modeling` are installed; ask the agent directly: *"Which skills did you load?"* |
| `/grill-with-docs` runs the interview, but no `GLOSSARY.md` or `docs/adr/` files appear on disk. | Known upstream bug when `grill-with-docs` runs *inside* an external spec-driven wrapper/pipeline, OR no terms/3-gate decisions qualified. | Invoke `/grill-with-docs` directly in the root repo session (not wrapped inside another pipeline). |
| Spec softens numeric defaults, ordering guarantees, or negative requirements agreed during grilling. | `/clear` was run before `/to-spec`, OR LLM prose compression softened hard rules. | Run `/to-spec` in the **same session** and manually audit the generated Spec against your grilling answers. |

### "It's Working If..." Verification Checklist
- [ ] `GLOSSARY.md` updates **inline during** `/grill-with-docs` (term by term), not in a dump at the end.
- [ ] `GLOSSARY.md` contains **pure vocabulary only**—zero implementation details or spec prose.
- [ ] Codebase questions are answered by sub-agents reading files, not asked of you.
- [ ] Sessions produce **0–1 ADRs** (only decisions passing all 3 gates).
- [ ] The agent pushes back when your phrasing conflicts with an existing `GLOSSARY.md` definition.
- [ ] Every PR includes visual summary, runtime evidence, and `One-way` vs. `Two-way door` + `Blast radius`.
