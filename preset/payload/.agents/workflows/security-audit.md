---
description: Structured security review and risk triage for any project, with web-application depth when there is a web surface
---

# Security audit

Skill `security` (commands and code paths); design-level skill `threat-modeling-expert`;
open-source depth `sh .agents/bin/slice.sh -f oss get SECURITY_AND_PRIVACY`.

## Guardrails
- Work only within the agreed scope and targets; authorised testing only.
- Prioritise real exploitability and business risk over theoretical scores.
- Never commit, log or quote a secret or personal data found during the audit.
- Claim a fix only after re-testing it.

## Steps

### 1. Scope and threat model
Entry points, user roles, data flows, external integrations, trust boundaries. In-scope and
out-of-scope targets. High-value assets and plausible attackers; attack trees for the riskiest
flows. Record as numbered controls: untrusted input → control → residual risk → mitigation.

### 2. Secrets and dependencies
`sh .agents/bin/precheck.sh --all`, history search for removed keys, ecosystem audit
(`dependency-management-deps-audit`). Scan → fix → rescan.

### 3. Authentication and authorisation
Session management, token validation, password handling, MFA. Insecure direct object references,
horizontal and vertical privilege escalation, role bypass. Authorisation on every route and data
access, server-side.

### 4. Input, API and output
Injection (SQL, command, template, path, deserialisation), SSRF, XSS. Validation, size limits,
parameter tampering, rate limiting. CORS, security headers, content security policy. Model output
reaching executors validated with an allowlist; prompt-injection cases as tests.

### 5. Configuration and surface
Debug modes, default credentials, error detail in responses, wide network binds, containers as
root, CI triggers with secrets in scope, unpinned actions in release paths.

### 6. Harden and verify
Concrete code-level fixes; add static analysis and dependency scanning to CI where justified;
re-test each fix and keep the test.

## Output
Findings: `severity — path:line — issue — exploit path — fix — retest evidence` · controls table ·
what was not tested and why · owner actions (rotation, private vulnerability reporting, settings).

## Principles
Defence in depth · zero-trust input · empirical proof.
