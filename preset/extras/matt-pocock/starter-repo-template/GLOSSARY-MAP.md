# GLOSSARY-MAP.md (Optional — For Multi-Context Monorepos)

> Delete this file if your repository has a single domain context (`GLOSSARY.md` at root).
> When `GLOSSARY-MAP.md` exists at the repository root, `/grill-with-docs` and `domain-modeling` route resolved terms to the matching bounded context's `GLOSSARY.md`.

| Bounded Context | Directory Scope | Glossary Path |
| :--- | :--- | :--- |
| Core Billing & Ledger | `packages/billing/**` | `packages/billing/GLOSSARY.md` |
| Identity & Access | `packages/auth/**` | `packages/auth/GLOSSARY.md` |
| Web Application | `apps/web/**` | `apps/web/GLOSSARY.md` |
