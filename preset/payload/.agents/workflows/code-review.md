---
description: Comprehensive code review for correctness, security, tests, architecture, readability and performance
---

# Code review

Skill `code-review` (procedure and verdicts); this workflow adds the full checklist.

## Guardrails
- Significant issues over style nitpicks; the formatter decides style.
- Every finding has a location and a suggested fix.
- Respect the project's conventions; no major refactor unless requested.
- Run something before saying "looks correct".

## Steps

### 1. Understand context
Purpose of the change · files in scope · specific concerns · feature, fix or refactor?

### 2. Analyse the project
Language, framework, linters/formatters present, conventions in similar code, the constitution.

### 3. Run it
The narrowest test or invocation that would fail if the change's claim were false.

### 4. Checklist
**Security** — no hard-coded secrets · input validated at the boundary · parameterised queries ·
output escaped (XSS) · authn/authz server-side per object · sensitive data not logged · model
output validated before execution.

**Bugs and logic** — null, empty, boundary values · async/await used correctly · no race
conditions · errors handled, never swallowed · no unbounded loops or recursion · no mock or
hard-coded answer on an application path.

**Architecture** — single responsibility · no circular dependencies · appropriate abstraction ·
consistent with existing patterns · separation of concerns · config, not code, for what varies.

**Testing** — new behaviour covered · tests fail when the change is reverted · edge cases · mocks
only at boundaries.

**Readability** — clear names · comments for non-obvious logic · named constants · functions of
reasonable length.

**Performance** — no N+1 queries · nothing expensive inside loops · caching only where explicit
and bounded · no leaks · fitting data structures.

### 5. Document findings
`severity — path:line — problem — why it matters — suggested fix`.

| Severity | Examples |
|---|---|
| BLOCKER | security vulnerability, data loss, broken build, false claim |
| MAJOR | wrong result on realistic input, missing validation, missing test for new logic |
| MINOR | clarity, structure, small performance |
| NIT | taste — say so |

### 6. Summarise
Counts by severity · verdict (approve / request changes / cannot judge without running X) · what
was run · good patterns worth keeping.

## Principles
Be constructive: explain why, offer alternatives, praise good patterns. Be practical: prioritise
impact, incremental improvements, don't block on nits.
