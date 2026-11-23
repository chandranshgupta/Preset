---
description: Robust end-to-end and browser-driven validation across stacks, from strategy to a stable CI suite
---

# QA and browser automation

Applies to projects with a web interface. Preset skills: `testing`, `test-driven-development`,
`systematic-debugging`, `verification-before-completion`, `ci`. Import if your library has them:
`playwright-skill`, `e2e-testing-patterns`, `browser-automation`, `go-playwright`, `test-fixing`.

## Guardrails
- Resilient, user-visible locators (roles, text, test ids) over fragile CSS/XPath.
- No hard-coded sleeps: condition waits and network interception.
- Isolated test data, cleaned up after runs.
- Same results headless in CI and headed locally.

## Steps

### 1. Prepare the strategy
Map business-critical journeys (auth, payment, core action, persistence). Environment, seed-data
and isolation rules. Success criteria, browser matrix, run frequency.

### 2. Implement
Page objects or modular actions targeting accessibility attributes. Explicit auto-waits for
visibility, animation stability and responses. Parallel runs; traces, video and screenshots on
failure. Go stacks may use a Go-native driver; JS/TS stacks use Playwright (workflow
`playwright-test`).

### 3. Triage and harden
Read traces, console logs, network recordings. Classify each failure: selector drift, timing,
environment, data, or a real bug — and fix by class (skill `systematic-debugging`). Run the suite
in CI with status reporting (skill `ci`).

## Principles
Test user behaviour · zero flakiness tolerance (fix or quarantine immediately, with an issue) ·
fast local subsets, full suite in CI.
