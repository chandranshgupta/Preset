---
description: Scope, build, test and ship a SaaS MVP quickly and safely
---

# Ship a SaaS MVP

Applies to WEB_APP + SERVICE_API products. Runs inside PRESET (steps 1-2) and THROUGHOUT (3-5),
ending in FINAL_CHECK at release level.

Preset skills: `brainstorming`, `to-spec`, `test-driven-development`, `systematic-debugging`,
`security`, `ci`, `release`. Import if available: `api-design-principles`,
`auth-implementation-patterns`, `postgres-patterns`, `frontend-patterns`, `observability-engineer`,
`postmortem-writing`, `playwright-skill`.

## Guardrails
- Strictly the core value proposition; no scope creep.
- Clean separation between API contracts and frontend logic.
- Automated tests on the critical happy path before release.
- Rollback and telemetry in place before going live.
- Announce any datastore before introducing it (THR-04).

## Steps

### 1. Plan the scope
Problem statement, target user, hard MVP boundaries; acceptance criteria per feature before code;
milestones as vertical slices — one core workflow that delivers value.

### 2. Backend and API
Data model with indexes and constraints; explicit REST or GraphQL contracts with schema
validation; authentication, sessions and per-object authorisation. Small vertical slices; contracts
documented and testable.

### 3. Frontend
Responsive components on a consistent design system; onboarding; empty, loading and error states;
wired to the API with error boundaries. Prioritise the happy path working end to end.

### 4. Test and validate
Unit and integration tests for business logic and endpoints; E2E for sign-up, core action and
payment (workflow `e2e-test`); systematic debugging of edge cases.

### 5. Ship safely
Deployment pipeline and environment rules; monitoring, logs and error tracking; rollback triggers,
migration safety, post-release health checks. Workflow `release`.

## Principles
Speed to value · contract first · verification before release.
