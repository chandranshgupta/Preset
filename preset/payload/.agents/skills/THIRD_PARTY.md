# Skills: origin

**Authored for this preset** (cite `.agents/PROJECT.xml` rules by id): `project-standard`,
`project-setup`, `project-memory`, `final-check`, `commit`, `testing`, `security`, `ci`,
`release`, `oss-excellence`, `self-healing-launcher`, `observability-tracing`
(their `templates/` folders hold tested, stdlib-only code: launcher kit and trace kit).

**Vendored** (content unchanged except a one-line precedence note under the frontmatter) from a personal skill library, so the preset carries proven procedures
instead of re-inventing them:

| Skill | Upstream as declared in the skill or its family |
|---|---|
| brainstorming, executing-plans, systematic-debugging, test-driven-development, verification-before-completion, finishing-a-development-branch, using-git-worktrees, dispatching-parallel-agents | the "superpowers" skill family (MIT-licensed upstream) |
| ask-matt, code-review, codebase-design, diagnosing-bugs, domain-modeling, grill-me, grill-with-docs, grilling, handoff, implement, implement-spec, improve-codebase-architecture, pr, prototype, research, retro, setup-matt-pocock-skills, tdd, teach, to-questionnaire, to-spec, to-tickets, triage, wait-what, wayfinder, wizard, writing-for-agents | `mattpocock/skills` at commit `abeeaf9`, MIT, copied unmodified (see `UPSTREAM.md`; licence: the repo-root `LICENSE`) |
| clean-code | `source:` ClawForge, per its frontmatter |
| architecture-decision-records, dependency-management-deps-audit, github-actions-templates, threat-modeling-expert | `source: community`, per their frontmatter |

Notes:

- Licence terms of the community skills were **not verified** here; check upstream before
  redistributing this preset publicly (law L16).
- Some vendored skills refer to siblings as `superpowers:<name>`; that means the skill of the same
  name in this folder.
- Precedence: if a vendored skill conflicts with `PROJECT.xml` (for example on when to commit), the
  standard wins (L09: no commit or push without explicit approval).
- Add more with `install.sh --skills-from <library> --only a,b`; whole skill folders are copied.
- Machine-readable list of vendored skills: `.agents/skills/VENDORED` (installer `--no-vendored` skips them).

- `writing-plans`, `requesting-code-review`, `receiving-code-review` and the authored `review` skill were retired in 2.3.0 and replaced by `to-spec` / `to-tickets` / `code-review`.
- `code-review` is deliberately **not** listed in `VENDORED`: the final check depends on a review skill, so lean (`--no-vendored`) installs keep it.
