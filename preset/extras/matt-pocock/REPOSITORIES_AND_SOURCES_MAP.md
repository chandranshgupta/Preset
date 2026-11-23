# Repositories, Tools & Reference Sources Map

Complete inventory of every repository, primary doc, and foundational engineering book synthesized in this archive, clearly distinguishing **verbatim source artifacts** from **reconstructed production templates**.

---

## 1. Repositories in the Workflow

| Repository | URL | Purpose | Archive Coverage |
| :--- | :--- | :--- | :--- |
| **`mattpocock/skills`** | `https://github.com/mattpocock/skills` (`aihero.dev/skills`) | Core library of ~39 composable agent skills (`engineering/` + `productivity/`), installer CLI (`skills.sh`), and companion guides. | Verbatim `SKILL.md` bodies for `grill-me`, `grill-with-docs`, `grilling`, `to-spec`, and `improve-codebase-architecture`; faithful reconstructions of 15 additional core skills in `skills-pack/`. |
| **`mattpocock/course-video-manager`** | `https://github.com/mattpocock/course-video-manager` | Screen-shared production repo (~2,500 commits) demonstrating `CLAUDE.md`, root `GLOSSARY.md`, uppercase `CODING_STANDARDS.md`, 31 files in `docs/adr/`, `docs/agents/prompts/`, and `.github/workflows/`. | Full drop-in starter layout in `starter-repo-template/` modeling exact file names, glossary entities (`Course`, `Section`, `Course Version`, `Lesson`, `Draft Version`, `Beat`, `Script`, `Animatic`, `Materialization Cascade`), and coding rules. |
| **`mattpocock/sandcastle`** | `https://github.com/mattpocock/sandcastle` | Open-source TypeScript agent orchestration engine (`sandcastle.run()`) running agents inside isolated Docker, Podman, or Vercel sandboxes. | Integrated into `INTEGRATION_GUIDE.md` and `.github/workflows/agent-implement-issue.yml`. |
| **`mattpocock/dictionary-of-ai-coding`** | `https://github.com/mattpocock/dictionary-of-ai-coding` | Open-source visual concept graph & Markdown dictionary (`dictionary/*.md`) defining shared AI coding vocabulary (`smart zone`, `automated checks`, `software factory`, `sandboxes`). | Integrated into `INTEGRATION_GUIDE.md` and `starter-repo-template/AGENTS.md`. |
| **`personal-wiki/` (Private)** | Private repo (walked through at `[01:52:42]`–`[01:57:35]`) | Karpathy-style LLM-maintained Markdown wiki updated every 3 hours via cron from Tweets, Discord, Slack, and Gmail, plus daily standup & Pixel Watch voice triage. | Complete starter template in `personal-wiki-template/`. |

---

## 2. Primary Sources Synthesized

1. **YouTube Interview & Screen Shares:** *How to Actually Code with AI (ft. Matt Pocock)* — NetworkChuck (`https://www.youtube.com/watch?v=mU8WKII1gpk`, 2h 02m 36s).
2. **GitHub Repository:** `mattpocock/skills` (`https://github.com/mattpocock/skills`).
3. **AI Hero Skill Documentation:** *The `/grill-with-docs` Skill* (`https://www.aihero.dev/skills-grill-with-docs`).

---

## 3. Books & Foundational Engineering Concepts

* ***A Philosophy of Software Design* — John Ousterhout:** Tactical vs. strategic programming; deep modules vs. shallow modules.
* ***Domain-Driven Design* — Eric Evans:** Ubiquitous language shared across domain experts, agents, `GLOSSARY.md`, database schemas, and code.
* ***Working Effectively with Legacy Code* — Michael Feathers:** Seams, boundary testing, and code locality.
* ***The Pragmatic Programmer* — David Thomas & Andrew Hunt:** Small deliberate steps, feedback rate as speed limit, *"No-one knows exactly what they want."*
* ***Refactoring* — Martin Fowler:** Code smell taxonomy used as baseline in `/code-review`.
* ***Extreme Programming Explained* — Kent Beck:** Continuous daily investment in system design.
* **Smart Zone / Dumb Zone — Dex Horthy:** Keeping session context under ~150,000 tokens.
* **Trust Ladder — Lauren Tan (Potato):** Scaling agent autonomy via verifiable evidence and blast-radius gating.
