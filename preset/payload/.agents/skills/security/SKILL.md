---
name: security
description: Audit a repository or a change for leaked credentials, vulnerable dependencies, missing authorisation, injection paths and unsafe defaults, then report without ever printing a secret value. Use before publishing, when adding auth, input handling or a dependency, when model output reaches an executor, or when asked whether something is safe.
---

# Security

Criteria: `sh .agents/bin/slice.sh grep secur` → rules THR-10..THR-16, FIN-03, FIN-05. Open-source
depth: `sh .agents/bin/slice.sh -f oss get SECURITY_AND_PRIVACY` (rules `SEC-*`). Design-level:
skill `threat-modeling-expert`. Full audit: workflow `security-audit`.

## Never print a secret

Report `path:line` and the credential **type** — never the value, not even truncated, not even in
a test fixture. If one is live, say so, name the path, and recommend rotation before anything else.
Do not rewrite history, force-push, or rotate anything yourself (L08). A secret pasted into chat is
exposed: recommend rotation.

## 1. Tracked secrets

```sh
git ls-files | grep -Ei '\.env($|\.)|\.pem$|\.p12$|id_rsa|credentials|secrets?\.(json|ya?ml|toml)'
sh .agents/bin/precheck.sh --all
```

Then check the history for keys that were added and later removed — deleting a file does not
unpublish a key:

```sh
git log --all -p -S 'PRIVATE KEY' --oneline | head
git log --all --diff-filter=D --name-only --pretty=format: | sort -u | grep -Ei '\.env|secret|credential'
```

Also: keys inside notebooks, CI config, test fixtures, and committed build artifacts. A key in a
fixture is still a key if it ever worked. The gate is pattern-based; pair it with a real scanner
when one is available.

## 2. Dependencies (THR-16: scan → fix → rescan)

Run the ecosystem's audit, from the lockfile, and report the count and the highest severity:

```sh
npm audit --omit=dev        # or pnpm audit / yarn npm audit
pip-audit -r requirements.txt
cargo audit
govulncheck ./...
bundle audit check --update
```

If a connected scanner (for example an MCP security tool) exists, use it as well. No audit tool for
the ecosystem is a finding — mark the task UNSCANNED rather than skipping. So is a lockfile out of
sync with the manifest, or an unpinned `*`/`latest`/git-URL dependency. Deeper: skill
`dependency-management-deps-audit`.

## 3. Code paths that matter

- **Authorisation** — every object read or write scoped to the authenticated principal, server
  side, from the session rather than a client-supplied id. Look for `findById(req.params.id)`.
  Test two principals cannot read each other's data.
- **Injection** — string-built SQL, shell invocation with interpolated input, template rendering
  of user data, deserialisation of untrusted payloads, path joins from request data, SSRF from
  user-supplied URLs, unescaped HTML (XSS).
- **Model output** — any model text reaching a query, shell, file system or payment path must
  pass a deterministic validator with an allowlist; retrieved text is data, not instruction;
  injection attempts kept as tests (THR-12).
- **Defaults** — debug mode, permissive CORS, `--insecure`, admin accounts with default passwords,
  stack traces or local paths in responses, tokens in URLs and logs, missing security headers.
- **Limits** — timeouts, size and row caps, rate limits, concurrency caps on anything that can hang
  or cost money (THR-14).
- **Surface** — network listeners bound to `0.0.0.0` by default, a container running as root, a
  workflow triggered by `pull_request_target` with secrets in scope.

## 4. Reporting and disclosure (public projects)

- A `SECURITY.md` with a private reporting route, or a stated absence of one. Public issues as the
  only channel is a finding for any project that handles other people's data.
- Automated dependency updates configured, or explicitly not wanted.
- Actions pinned by major tag versus SHA, when the workflow handles secrets.

## Output

Rule table (THR / SEC rules: DONE / GAP / NA-with-reason / UNVERIFIED) · findings as
`severity — path:line — issue — exploit path — fix`, prioritised by real exploitability over
theoretical scores · what you ran and its exit status · what you could not test (no staging, no
second account) · owner-only actions, such as enabling private vulnerability reporting or rotating
a key. Claim a fix only after re-testing it.
