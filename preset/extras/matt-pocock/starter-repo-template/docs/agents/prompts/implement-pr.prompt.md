# Prompt Skeleton: Implement Issue and Open Pull Request

1. Load `AGENTS.md`, `GLOSSARY.md`, `CODING_STANDARDS.md`, and `docs/adr/`.
2. Create an isolated feature branch for issue `#{{ISSUE_NUMBER}}`.
3. Implement the vertical slice using `/tdd` (failing seam test -> minimal implementation -> refactor).
4. Run full static checks (`typecheck`, `lint`) and test suite.
5. Run `/code-review` (Spec axis + Standards axis) and fix any findings.
6. Open a Pull Request formatted with `/pr` (Visual Summary, Execution Evidence, and Merge Danger: `One-way` vs. `Two-way door` + `Blast Radius`).
