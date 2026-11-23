# .agents: the project standard, installed

| Path | Owner | What it is |
|---|---|---|
| `PROJECT.xml` | preset | **Main file.** Prime directives P1-P9, response style, harmony, laws, the PRESET / THROUGHOUT / FINAL_CHECK stages, rules, router, memory, what-ifs |
| `profile.xml` | this project | What this project is, its switches (cadence, observability, priorities) and real commands (`--final` runs them) |
| `modules/oss/` | preset | Open-source module: `CORE.xml` (procedure) + `DIRECTIVE.xml` (125 rules) |
| `INTEGRATION.md` | preset | **Operating manual for agents**: situation → skill map, flow, rules, definition of done |
| `modules/matt-pocock/` | preset | Matt Pocock chain: `CORE.xml` (grill → spec → tickets → implement → review → retro) + `DIRECTIVE.xml` (MP-01..16) |
| `skills/` | preset | 52 procedures; `self-healing-launcher/templates` and `observability-tracing/templates` hold tested code kits |
| `workflows/` | preset | 16 step-by-step runbooks |
| `templates/` | preset | Constitution and memory-triad templates |
| `bin/precheck.sh` | preset | The gate: `--staged` · `--all` · `--final` · `--release` |
| `bin/doctor.sh` | preset | Is the preset intact and wired? (`--ci` on runners) |
| `bin/slice.sh` | preset | Print one section or id of any XML here |
| `bin/preset.sh`, `bin/preset.cmd` | preset | One entry point: `check`, `doctor`, `slice` (`.cmd` for PowerShell/cmd) |
| `allow` | this project | Reviewed exceptions for the gate |
| `VERSION` | preset | Installed preset version |

Preset-owned files are refreshed by `install --force`. Standards (`PROJECT.xml`, `modules/`) are
replaced only by `install --upgrade-standard`, which keeps a `.bak`. Project-owned files are never
overwritten.

```sh
sh .agents/bin/doctor.sh                  # health          (Windows: .agents\bin\preset doctor)
sh .agents/bin/slice.sh get prime_directives
sh .agents/bin/slice.sh get harmony       # how rules and skills combine
sh .agents/bin/slice.sh -f oss get SEC-03
sh .agents/bin/precheck.sh --final        # before saying done
```
