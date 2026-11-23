# CLAUDE.md

See `AGENTS.md` for universal repository rules.

## Triage Labels
- Canonical agent-ready label: `ready-for-agent` (customize in `docs/agents/triage-labels.md` if your repo uses a custom alias such as `Sandcastle`).

## Domain Documentation Layout
- Single-context layout: `GLOSSARY.md` at repository root and numbered ADRs under `docs/adr/`.
- Keep CLI/API help text and `GLOSSARY.md` synchronized whenever domain vocabulary changes.

## Verification Commands
- Run static checks (`typecheck` + `lint`) and unit/seam tests before opening or updating any Pull Request.
- Any change affecting user-facing UI must be verified in a real headless browser with screenshot/DOM evidence attached to the PR.
