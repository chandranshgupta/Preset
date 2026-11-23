---
description: Write meaningful unit tests with the project's detected framework
---

# Unit testing

Skills `testing` and `test-driven-development`; rules THR-19..THR-21.

## Guardrails
- Never assume a framework; detect it. None present → ask the user before adding one.
- Test behaviour, not implementation; each test independent and isolated.
- Descriptive names: "should <behaviour> when <condition>".
- Mocks live in tests only, at the boundary.

## Steps

### 1. Understand what to test
Files or functions · edge cases · external services to fake · existing patterns to follow.

### 2. Detect the setup
- JS/TS: Jest (`jest.config.*`), Vitest (`vitest.config.*`), Mocha, Testing Library.
- Python: pytest (`pytest.ini`, `conftest.py`, `pyproject.toml`), unittest.
- Go `go test`, Rust `cargo test`, JVM JUnit, .NET xUnit/NUnit; otherwise the manifest.

### 3. Analyse the code
Purpose, inputs, outputs, side effects; edge cases (null, empty, boundary, large, malformed);
dependencies to fake.

### 4. Write tests — Arrange, Act, Assert
Group with `describe` (or equivalent); one primary assertion per test where possible.

### 5. Fake only the boundary
Network, database, file system, third-party services, time. Reset between tests. Verify
interactions only when they are the behaviour.

### 6. Run and verify
Run the suite; record counts and time; revert-test new tests (they must fail without the change).

## Patterns
Pure functions: input → output, many variations. Async: success and error paths, no sleeps.
UI components: render, interaction, conditional rendering — not internals. Hooks/composables:
framework utilities, state changes, side effects.

## Principles
Public API over internals · happy path, error path and edge cases · fast and deterministic (no
random, no real clock) · tests near the code or in the project's test folder, named consistently ·
coverage serves critical paths, never a vanity number.
