---
description: End-to-end tests for critical user journeys with the detected framework
---

# End-to-end test

Applies when the profile has a user interface or a whole-system journey. Skill `testing`; rule
THR-21 (end-to-end only for the few journeys that need it).

## Guardrails
- Detect existing E2E setup before writing tests.
- Test user flows, not implementation.
- Reliable, not flaky: condition-based waits, never fixed sleeps.
- Real local instance of the app; seeded, isolated test data, cleaned up afterwards.

## Steps

### 1. Understand what to test
Which journey · critical paths (sign-in, core action, payment, data persistence) · known flaky
areas · browsers or platforms that must work.

### 2. Detect the framework
Playwright (`playwright.config.*`) · Cypress (`cypress.config.*`) · Selenium · Puppeteer.
None: recommend Playwright for new web projects (workflow `playwright-test`) and ask first.

### 3. Write the cases
Scenario name · preconditions · user actions · assertions on outcomes the user sees.

### 4. Handle async
Wait for visible elements and network responses; no arbitrary timeouts; retries only in CI and
only as a flake signal, never as a fix.

### 5. Run and verify
Headed first to watch it; then headless; then in CI. Debug failures with traces and screenshots.

## Principles
Test what users do · deterministic · isolated data · clean up · a flaky test is a defect.
Deeper: workflow `qa-browser-automation`.
