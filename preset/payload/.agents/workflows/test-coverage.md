---
description: Improve meaningful test coverage on the paths that matter
---

# Test coverage

Skill `testing` (section Coverage).

## Guardrails
- Meaningful coverage, not numbers; never assertion-free tests.
- Critical paths first; do not test framework or boilerplate code.
- Keep tests maintainable.

## Steps

### 1. Measure
`npm run test -- --coverage` · `pytest --cov` · `go test -cover ./...` · `cargo llvm-cov` — or the
project's declared command. Record the baseline.

### 2. Understand gaps
Which files matter (parsing, money, permissions, state transitions, error handling)? Is there a
target the project actually maintains?

### 3. Prioritise
Business-critical logic → complex functions → error paths → edge cases.

### 4. Write tests
For each gap: understand the behaviour, list cases, write the test, revert-test it.

### 5. Verify
Re-run coverage, report the movement as a signal, and name what stays uncovered and why.

## Principles
100% coverage does not mean bug-free · test behaviour, not implementation · critical paths first ·
avoid testing boilerplate.
