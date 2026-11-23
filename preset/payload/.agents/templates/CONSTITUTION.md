## Project constitution — <fill: project name>

<!-- Owned by this project; the installer never edits anything outside the managed block above.
     Keep it 10-40 lines of truth that is specific to THIS project. Generic advice lives in
     .agents/PROJECT.xml. Replace every <fill: ...>; precheck --release blocks while any remain. -->

### Mission
<fill: one paragraph — what must work, for whom, and what "done" means here>

### Invariants (never violate)
- <fill: the property the system must always hold>
- <fill: the trust boundary — where untrusted input is validated>
- <fill: what must never be committed or logged>

### Module map (one responsibility each)
| Path | Responsibility | May call |
|---|---|---|
| <fill> | <fill> | <fill> |

### Commands that actually work
Declared in `.agents/profile.xml` → `<commands>`; `sh .agents/bin/precheck.sh --final` runs them.
- Setup: `<fill>`
- Test: `<fill>`
- Run: `<fill>`

### Never do here
- <fill: the project-specific trap, e.g. "never hard-code table names; datasets come from config">

### Deliberately not adopted
- <fill: generic rules from PROJECT.xml that do not fit this project, and why>
