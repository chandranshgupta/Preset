---
description: PRESET stage — profile a new or adopted repository and lay the floor before the first feature
---

# New project (PRESET)

Runs `.agents/PROJECT.xml` stage PRESET through skill `project-setup`. Load the rules with
`sh .agents/bin/slice.sh get PRESET`.

## Guardrails
- Existing project: read first, preserve what works, never re-scaffold (L06, L15).
- Ask before: licence choice, adding a datastore, anything destructive, any commit or push.
- Isolated environment only; nothing installed globally (L11).
- Only the floor items this archetype needs; each in its smallest sufficient version.

## Steps

### 1. Detect
New or existing? Read README, manifest, lockfile, tests, CI, instruction files, `git log`.

### 2. Profile
Fill `.agents/profile.xml` from evidence; ask the user only for purpose, visibility intent, risk,
deadline. Set `status="FILLED"`. Unknowns go under `<cannot_see>`.

### 3. Design with the user
New project or feature: skill `grill-with-docs`, then `to-spec`. Discuss the system design in
chat before writing code. Record DEC-001 (why this stack and structure).

### 4. Lay the floor (PRE-01..PRE-14)
`.gitignore` · isolated env + runtime pin · `.env.example` · manifest + lockfile · README minimum ·
one real test · lint/format · CI baseline (skill `ci`) · constitution in `AGENTS.md` · memory files
· licence decision · module layout and trust boundary · preflight and smoke once the path exists ·
oss module ADVISE run if it will be public.

### 5. Gate and prove
```sh
sh .agents/bin/doctor.sh
sh .agents/bin/precheck.sh --all
sh .agents/bin/precheck.sh --final
```

### 6. Report
Floor table (rule, DONE/GAP/NA/UNVERIFIED, evidence) · commands run with exit codes · not verified ·
up to seven ranked what-ifs and one thing not to do · owner actions.
