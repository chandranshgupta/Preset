---
name: testing
description: Decide what to test and prove the tests mean something — find the suite, pick behaviour over implementation, add a regression test for every fix, keep the offline run fast, mark live tests. Use when adding or changing tests, when asked to raise coverage, or when a change has no test. Pairs with test-driven-development for the red-green loop.
---

# Testing

Criteria: `sh .agents/bin/slice.sh get THR-19`, `get THR-20`, `get THR-21`. Open-source depth:
`sh .agents/bin/slice.sh -f oss get TESTING` (rules `TST-*`). Workflows: `unit-test`,
`e2e-test`, `test-coverage`.

## Find the truth first

```sh
ls; cat package.json pyproject.toml Cargo.toml go.mod 2>/dev/null   # what runner exists
```

Detect the framework (Jest, Vitest, Mocha, pytest, unittest, go test, cargo test, JUnit…) — never
assume one. Then run the suite exactly as documented — not a command you invented. Record the
timing and the pass/skip counts. If the default selection skips tests for missing credentials,
that is a finding, not a pass. If no runner exists, ask the user which framework before adding one.

## What to test, by what the project is

| Project | Test this | Do not spend effort on |
|---|---|---|
| Library / package | public API contracts, error types, boundary inputs, serialisation round-trips | internal helpers with no behaviour |
| CLI | argument parsing, exit codes, stdout/stderr shape, one end-to-end invocation | flag combinations nobody uses |
| Service / API | authorisation per object, validation rejects, idempotency, error status codes | the framework's routing |
| Web / UI | the critical user journeys end to end, empty/loading/error states | snapshots of every component |
| Pipeline / data | schema of inputs and outputs, idempotent re-run, a known fixture end to end | intermediate transformations in isolation |
| Model-backed app | the deterministic boundary around the model, prompt and output validation, cost/latency guards; an evaluation set run against the real model | assertions on model wording |

## Making a test mean something

- **Revert test.** Undo the fix or the feature in your head: does the test go red? If it stays
  green, it tests the mock, the framework, or nothing.
- **Arrange, act, assert.** One reason to fail. A test that breaks for five reasons hides which one.
- **No sleeps.** Deterministic time, injected clocks, fake transports, condition-based waits.
  A suite with `sleep` is a suite that flakes in CI.
- **Mock at the boundary only** (network, database, file system, clock, third-party services);
  reset mocks between tests. Mocks live in tests, never in application code (L02).
- **Mark live tests.** Anything needing credentials, a model, hardware or the network carries a
  marker and is excluded from the default run, with a documented command to run it (THR-20).
- **Fixtures small enough to read.** A 400-line golden file nobody reviews is not a test.
- **Assertions, not snapshots of everything.** A snapshot that changes on every unrelated edit
  trains people to accept red.
- **Regression test per defect.** Name it for the defect. Before the fix, it must fail.
- **Descriptive names**: "should <behaviour> when <condition>". Independent, isolated tests.

## Coverage

Coverage is a map of what to inspect, not a score to maximise. Read the uncovered lines in the
files that matter (parsing, money, permissions, state transitions, error paths) and decide. Never
add assertion-free tests to move the number, and never gate a merge on a percentage the project
has not maintained.

## Report

Command run · duration · counts (passed/skipped/failed) · what you added and the revert-test answer
for each · coverage movement, if measured, with the caveat that it is a signal · what remains
untested and why.
