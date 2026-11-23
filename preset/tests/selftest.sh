#!/usr/bin/env bash
# selftest.sh - prove the project preset works on this machine (Linux, macOS, Git Bash).
#
#   bash tests/selftest.sh            run everything; exit 0 only if every check passed
#   KEEP=1 bash tests/selftest.sh     keep the temporary repositories for inspection
#
# Needs: bash, git, and the usual POSIX tools. Python is optional (XML and kit checks are
# skipped, and reported as skipped, when it is missing). Nothing outside a temp folder is touched.

if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
set -u

PRESET=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d 2>/dev/null || mktemp -d -t preset)
PASS=0; FAIL=0; SKIP=0
export GIT_AUTHOR_NAME=selftest GIT_AUTHOR_EMAIL=selftest@example.invalid
export GIT_COMMITTER_NAME=selftest GIT_COMMITTER_EMAIL=selftest@example.invalid
export GIT_CONFIG_NOSYSTEM=1 NO_COLOR=1
export PYTHONPYCACHEPREFIX="$WORK/pycache"   # never leave __pycache__ inside the payload
unset PRESET_ENFORCE_COMMITS OSS_ENFORCE_COMMITS

cleanup() { [ "${KEEP:-0}" = 1 ] && printf 'kept: %s\n' "$WORK" || rm -rf "$WORK"; }
trap cleanup EXIT

ok()   { PASS=$((PASS + 1)); printf '  pass  %s\n' "$1"; }
bad()  { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$1"; [ -n "${2:-}" ] && printf '%s\n' "$2" | sed 's/^/        | /' | head -20; }
skip() { SKIP=$((SKIP + 1)); printf '  skip  %s\n' "$1"; }
section() { printf '\n== %s\n' "$1"; }

expect_ok()   { local d=$1; shift; local out; if out=$("$@" 2>&1); then ok "$d"; else bad "$d (exit $?)" "$out"; fi; }
expect_fail() { local d=$1; shift; local out; if out=$("$@" 2>&1); then bad "$d (expected failure)" "$out"; else ok "$d"; fi; }
has()     { grep -q -- "$2" "$1" 2>/dev/null; }
lacks()   { ! grep -q -- "$2" "$1" 2>/dev/null; }

newrepo() { # $1 folder -> naya git repo
  mkdir -p "$1" && git -c init.defaultBranch=main init -q "$1" && git -C "$1" config commit.gpgsign false
}
install_into() { bash "$PRESET/install.sh" --target "$@" ; }

PY=""
for c in python3 python; do command -v "$c" >/dev/null 2>&1 && "$c" -c 'print(1)' >/dev/null 2>&1 && { PY=$c; break; }; done

printf 'project-preset selftest - %s - bash %s - %s\n' "$(uname -s 2>/dev/null)" "$BASH_VERSION" "$(git --version)"
printf 'awk: %s\n' "$(awk --version 2>/dev/null | head -1 || awk -W version 2>/dev/null | head -1 || echo unknown)"

# ---------------------------------------------------------------- 1. static
section "1. standard files are consistent"
A="$PRESET/payload/.agents"
S="$A/bin/slice.sh"
if [ -n "$PY" ]; then
  out=$("$PY" - "$A" <<'EOF'
import sys, os, glob, collections, xml.etree.ElementTree as E
base = sys.argv[1]; problems = []
for f in ["PROJECT.xml", "profile.xml", "modules/oss/CORE.xml", "modules/oss/DIRECTIVE.xml", "modules/matt-pocock/CORE.xml", "modules/matt-pocock/DIRECTIVE.xml"]:
    try:
        r = E.parse(os.path.join(base, f)).getroot()
    except E.ParseError as e:
        problems.append(f"{f}: {e}"); continue
    ids = [e.get("id") for e in r.iter() if e.get("id")]
    d = [k for k, v in collections.Counter(ids).items() if v > 1]
    if d: problems.append(f"{f}: duplicate ids {d}")
r = E.parse(os.path.join(base, "PROJECT.xml")).getroot()
sk = {e.get("name") for e in r.iter("skill") if e.get("name")}
wf = {e.get("name") for e in r.iter("workflow") if e.get("name")}
disk_sk = {os.path.basename(os.path.dirname(p)) for p in glob.glob(os.path.join(base, "skills/*/SKILL.md"))}
disk_wf = {os.path.basename(p)[:-3] for p in glob.glob(os.path.join(base, "workflows/*.md"))}
if sk != disk_sk: problems.append(f"skills index vs disk: {sorted(sk ^ disk_sk)}")
if wf != disk_wf: problems.append(f"workflows index vs disk: {sorted(wf ^ disk_wf)}")
if len(list(r.iter("directive"))) != 9: problems.append("expected 9 prime directives")
print("\n".join(problems))
EOF
)
  [ -z "$out" ] && ok "XML well-formed, ids unique, skill and workflow index match disk, 9 directives" || bad "standard consistency" "$out"
else
  skip "XML checks (no python)"
fi

missing=""
for id in $(grep -rhoE '\b(L[0-9]{2}|PRE-[0-9]{2}|THR-[0-9]{2}|FIN-[0-9]{2}|WIF-[0-9]{2}|RS-[0-9]{2}|H-[A-Z]+)\b' \
              "$PRESET/payload/AGENTS.block.md" "$A/skills" "$A/workflows" "$A/templates" "$A/PROJECT.xml" 2>/dev/null \
            | grep -vE '^H-(TTP|EAD)$' | sort -u); do
  bash "$S" get "$id" >/dev/null 2>&1 || missing="$missing $id"
done
[ -z "$missing" ] && ok "every rule id cited in skills, workflows, templates and AGENTS block exists" || bad "ids cited but missing:$missing"

missing=""
for t in $(grep -rhoE 'slice\.sh get [A-Za-z_0-9-]+' "$PRESET/payload" | awk '{print $3}' | sort -u); do
  bash "$S" get "$t" >/dev/null 2>&1 || missing="$missing $t"
done
for t in $(grep -rhoE 'slice\.sh -f oss get [A-Za-z_0-9-]+' "$PRESET/payload" | awk '{print $5}' | sort -u); do
  bash "$S" -f oss get "$t" >/dev/null 2>&1 || missing="$missing oss:$t"
done
[ -z "$missing" ] && ok "every 'slice.sh get' target named in the docs resolves" || bad "unresolved slice targets:$missing"

bad_skill=""
for f in "$A"/skills/*/SKILL.md; do
  d=$(basename "$(dirname "$f")")
  n=$(sed -n '2,6p' "$f" | tr -d '\r' | sed -nE 's/^name:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/p' | head -1)
  [ "$n" = "$d" ] || bad_skill="$bad_skill $d"
  grep -q '^description:' "$f" || bad_skill="$bad_skill $d(no-description)"
done
[ -z "$bad_skill" ] && ok "every skill has name == folder and a description" || bad "skill frontmatter:$bad_skill"

for i in 1 2 3 4 5 6 7 8 9; do grep -q "^$i\. \*\*" "$PRESET/payload/AGENTS.block.md" || missing="$missing P$i"; done
[ -z "${missing// /}" ] && ok "AGENTS.md block lists all nine prime directives" || bad "AGENTS block directives missing:$missing"

out=$(LC_ALL=C grep -nE '[^ -~	]' "$A"/bin/*.sh "$PRESET/payload/.githooks/"* 2>/dev/null)
[ -z "$out" ] && ok "gate scripts print ASCII only (safe on any console code page)" || bad "non-ASCII in scripts" "$out"

for f in "$PRESET/install.sh" "$PRESET/uninstall.sh" "$A"/bin/*.sh "$PRESET/payload/.githooks/"* \
         "$A/skills/self-healing-launcher/templates/run.sh"; do
  bash -n "$f" 2>/dev/null || bad "syntax: $f"
done && ok "all shell scripts parse"

# ----------------------------------------------------------- 2. fresh install
section "2. fresh install"
R="$WORK/fresh"; newrepo "$R"
expect_ok "install exits 0" install_into "$R"
for f in AGENTS.md CLAUDE.md GEMINI.md PROJECT_BRAIN.md FLOW.md DECISION.md .gitattributes \
         .agents/PROJECT.xml .agents/profile.xml .agents/bin/precheck.sh .agents/bin/preset.cmd \
         .agents/modules/oss/DIRECTIVE.xml .githooks/pre-commit .agent/workflows/finalize_task.md \
         .agents/skills/self-healing-launcher/templates/launcher.py; do
  [ -f "$R/$f" ] || bad "missing after install: $f"
done; ok "expected files present"
[ "$(grep -c 'project-preset:begin' "$R/AGENTS.md")" = 1 ] && ok "AGENTS.md has one managed block" || bad "AGENTS.md block count"
[ "$(git -C "$R" config core.hooksPath)" = ".githooks" ] && ok "core.hooksPath = .githooks" || bad "hooksPath not set"
[ "$(grep -cE '^\*\.sh text eol=lf$|^\.githooks/\* text eol=lf$|^\*\.cmd text eol=crlf$|^\*\.bat text eol=crlf$' "$R/.gitattributes")" = 4 ] \
  && ok ".gitattributes has the 4 line-ending rules" || bad ".gitattributes rules" "$(cat "$R/.gitattributes")"
n_sk=$(ls -d "$R"/.agents/skills/*/ | wc -l | tr -d ' '); n_st=$(ls -d "$R"/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
[ "$n_sk" = "$n_st" ] && ok "Claude Code stubs for all $n_sk skills" || bad "stubs $n_st vs skills $n_sk"
has "$R/.claude/skills/code-review/SKILL.md" '^description:' && ok "stub carries the skill description" || bad "stub description"
expect_ok "doctor reports healthy" bash "$R/.agents/bin/doctor.sh"
expect_ok "preset.sh dispatcher runs doctor" bash "$R/.agents/bin/preset.sh" doctor

# --------------------------------------------------------- 3. commit through gate
section "3. the gate on real commits"
( cd "$R" && git add -A && git commit -q -m "chore: install project preset" ) >"$WORK/c1.log" 2>&1 \
  && ok "the whole preset commits through its own gate" || bad "preset commit blocked" "$(cat "$WORK/c1.log")"
base_commits=$(git -C "$R" rev-list --count HEAD)
k="AKIA"; printf 'aws = "%s%s"\n' "$k" "ABCDEFGHIJKLMNOP" >"$R/leak.py"
( cd "$R" && git add leak.py && git commit -q -m "feat: add config" ) >"$WORK/c2.log" 2>&1
[ "$(git -C "$R" rev-list --count HEAD)" = "$base_commits" ] && has "$WORK/c2.log" 'possible credential' \
  && ok "a cloud key is blocked and the commit does not happen" || bad "secret not blocked" "$(cat "$WORK/c2.log")"
git -C "$R" rm -q --cached leak.py; rm -f "$R/leak.py"

mkdir -p "$R/src" "$R/docs"
printf 'def f():\n    try:\n        g()\n    except Exception:\n        pass\n    breakpoint()\n' >"$R/src/app.py"
printf 'run it from /home/someone/project\n' >"$R/docs/notes.md"
printf 'X=1\n' >"$R/.env"
git -C "$R" add -f src docs .env
out=$(cd "$R" && bash .agents/bin/precheck.sh --staged 2>&1); rc=$?
[ $rc = 1 ] && printf '%s' "$out" | grep -q '\[env\]' && ok "tracked .env blocks" || bad ".env not blocked" "$out"
for chk in swallowed debugger machine-path; do
  printf '%s' "$out" | grep -q "\[$chk\]" && ok "warns: $chk" || bad "no $chk warning" "$out"
done
git -C "$R" rm -q -r --cached src docs .env; rm -rf "$R/src" "$R/docs" "$R/.env"

# ------------------------------------------------------- 4. final and release
section "4. --final runs declared commands; --release blocks"
P="$R/.agents/profile.xml"; tmp="$WORK/p.xml"
awk '{ sub(/<command id="lint"><\/command>/, "<command id=\"lint\">echo lint-ok \\&amp;\\&amp; true</command>");
       sub(/<command id="test"><\/command>/, "<command id=\"test\">echo boom; exit 3</command>"); print }' "$P" >"$tmp" && cat "$tmp" >"$P"
out=$(cd "$R" && bash .agents/bin/precheck.sh --final 2>&1); rc=$?
printf '%s' "$out" | grep -q 'lint: echo lint-ok && true -> exit 0' && ok "declared command runs (XML entities decoded)" || bad "lint command" "$out"
[ $rc = 1 ] && printf '%s' "$out" | grep -q 'command-test' && ok "failing declared command blocks, output shown" || bad "failing command did not block" "$out"
if command -v timeout >/dev/null 2>&1 && timeout --version 2>/dev/null | grep -qi 'gnu\|coreutils' \
   || command -v gtimeout >/dev/null 2>&1; then
  awk '{ sub(/echo boom; exit 3/, "sleep 5"); print }' "$P" >"$tmp" && cat "$tmp" >"$P"
  out=$(cd "$R" && PRESET_CMD_TIMEOUT=1 bash .agents/bin/precheck.sh --final 2>&1)
  printf '%s' "$out" | grep -q 'timed out after 1s' && ok "declared command timeout enforced" || bad "timeout not enforced" "$out"
else
  skip "timeout check (no GNU timeout here)"
fi
git -C "$R" checkout -q -- .agents/profile.xml
out=$(cd "$R" && bash .agents/bin/precheck.sh --release --no-run 2>&1); rc=$?
[ $rc = 1 ] && printf '%s' "$out" | grep -q '\[changelog\]' && printf '%s' "$out" | grep -q '\[tag\]' \
  && ok "--release blocks on changelog, tag and placeholders" || bad "--release" "$out"

# ------------------------------------------------------------- 5. triad sync
section "5. memory triad and references (P3, P5)"
printf '# FLOW\nEntry: `src/missing_module.py`:main\n' >"$R/FLOW.md"
out=$(cd "$R" && bash .agents/bin/precheck.sh --all 2>&1)
printf '%s' "$out" | grep -q 'broken-ref' && printf '%s' "$out" | grep -q 'src/missing_module.py' \
  && ok "triad reference to a missing file is flagged" || bad "broken ref not flagged" "$out"
git -C "$R" checkout -q -- FLOW.md
awk '{ sub(/<memory_cadence>MILESTONE</, "<memory_cadence>EVERY_TASK<"); print }' "$P" >"$tmp" && cat "$tmp" >"$P"
printf 'print(1)\n' >"$R/tool.py"; git -C "$R" add tool.py .agents/profile.xml
out=$(cd "$R" && bash .agents/bin/precheck.sh --staged 2>&1)
printf '%s' "$out" | grep -q 'memory-sync' && ok "EVERY_TASK: code commit without a triad change warns" || bad "memory-sync" "$out"
git -C "$R" reset -q; git -C "$R" checkout -q -- .agents/profile.xml; rm -f "$R/tool.py"

# ---------------------------------------------------------- 6. reinstall etc.
section "6. re-install, existing files, migration, options"
printf 'my rule: never touch prod\n' >>"$R/AGENTS.md"
out=$(install_into "$R" 2>&1)
printf '%s' "$out" | grep -q '^0 written' && ok "re-install writes nothing new" || bad "re-install not idempotent" "$out"
has "$R/AGENTS.md" 'never touch prod' && [ "$(grep -c 'project-preset:begin' "$R/AGENTS.md")" = 1 ] \
  && ok "re-install keeps user text, one block" || bad "AGENTS.md after re-install"

E2="$WORK/existing"; newrepo "$E2"; printf '# Existing\n\n- keep this\n' >"$E2/AGENTS.md"
install_into "$E2" >/dev/null 2>&1
head -1 "$E2/AGENTS.md" | grep -q 'project-preset:begin' && has "$E2/AGENTS.md" 'keep this' \
  && ok "existing AGENTS.md: block prepended, content kept" || bad "existing AGENTS.md"

L="$WORK/legacy"; newrepo "$L"; mkdir -p "$L/.oss-excellence" "$L/.githooks"
printf '<!-- oss-excellence:begin -->\nold\n<!-- oss-excellence:end -->\n\nHouse rule\n' >"$L/AGENTS.md"
printf '#!/bin/sh\n# oss-excellence preset\nexec .oss-excellence/precheck.sh\n' >"$L/.githooks/pre-commit"
printf 'artifact:dist/app.js\n' >"$L/.oss-excellence/allow"
install_into "$L" >/dev/null 2>&1
lacks "$L/AGENTS.md" 'oss-excellence:begin' && has "$L/AGENTS.md" 'House rule' && has "$L/.githooks/pre-commit" 'agents/bin/precheck' \
  && has "$L/.agents/allow" 'artifact:dist/app.js' && ok "legacy oss-excellence repo migrated (block, hook, allowlist)" || bad "legacy migration"

U="$WORK/ownskill"; newrepo "$U"; mkdir -p "$U/.claude/skills/code-review"; printf -- '---\nname: code-review\ndescription: mine\n---\nmine\n' >"$U/.claude/skills/code-review/SKILL.md"
install_into "$U" >/dev/null 2>&1
has "$U/.claude/skills/code-review/SKILL.md" 'description: mine' && ok "a user's own .claude skill is never overwritten" || bad "own skill overwritten"

N="$WORK/lean"; newrepo "$N"; install_into "$N" --no-vendored --with-ci --no-memory >/dev/null 2>&1
[ ! -d "$N/.agents/skills/brainstorming" ] && [ -d "$N/.agents/skills/code-review" ] && [ -f "$N/.github/workflows/preset-gate.yml" ] \
  && [ ! -f "$N/FLOW.md" ] && ok "--no-vendored, --with-ci, --no-memory" || bad "install options"

# ------------------------------------------------------------ 7. odd paths
section "7. paths with spaces and non-ASCII characters"
W="$WORK/my project परियोजना"; newrepo "$W"
expect_ok "install into a path with spaces and Devanagari" install_into "$W"
( cd "$W" && git add -A && git commit -q -m "chore: install project preset" ) >/dev/null 2>&1 && ok "commit through the gate there" || bad "commit in unicode path"
expect_ok "doctor there" bash "$W/.agents/bin/doctor.sh"

# --------------------------------------------------------- 8. commit message
section "8. commit-msg hook"
m="$WORK/msg"; printf 'did stuff\n' >"$m"
expect_ok "non-conventional subject warns by default" sh "$R/.githooks/commit-msg" "$m"
expect_fail "PRESET_ENFORCE_COMMITS=1 blocks it" env PRESET_ENFORCE_COMMITS=1 sh "$R/.githooks/commit-msg" "$m"
printf 'Merge branch x\n' >"$m"; expect_ok "merge messages pass" env PRESET_ENFORCE_COMMITS=1 sh "$R/.githooks/commit-msg" "$m"

# --------------------------------------------------------------- 9. slicing
section "9. slice.sh"
expect_ok "get PRESET" bash "$S" get PRESET
expect_ok "get THR-41" bash "$S" get THR-41
expect_ok "get harmony" bash "$S" get harmony
expect_ok "-f oss get SEC-03" bash "$S" -f oss get SEC-03
expect_ok "-f oss get 2 (phase by number)" bash "$S" -f oss get 2
[ "$(bash "$S" grep secret | wc -l | tr -d ' ')" -gt 3 ] && ok "grep finds rule ids" || bad "slice grep"
expect_fail "unknown id fails" bash "$S" get NOPE-99

# --------------------------------------------------------- 10. launcher + trace kits
section "10. launcher kit and trace kit (P8, P9)"
K="$A/skills/self-healing-launcher/templates"; TK="$A/skills/observability-tracing/templates/trace_kit.py"
if [ -n "$PY" ]; then
  expect_ok "kit files compile" "$PY" -m py_compile "$K/launcher.py" "$K/preflight.py" "$TK"
  D="$WORK/app"; mkdir -p "$D/app"; cp "$K/launcher.py" "$K/preflight.py" "$D/"; cp "$TK" "$D/app/"; : >"$D/app/__init__.py"
  cat >"$D/app/main.py" <<'EOF'
from app.trace_kit import traced, touch, new_trace

@traced
def load(path, password="x"):
    touch("file", path, "read")
    return [1, 2, 3]

@traced
def boom():
    raise ValueError("bad")

if __name__ == "__main__":
    with new_trace("selftest"):
        print(sum(load("data.csv", password="hunter2")))
        try:
            boom()
        except ValueError:
            print("handled")
EOF
  out=$(cd "$D" && "$PY" app/trace_kit.py run -m app.main 2>&1)
  printf '%s' "$out" | grep -q 'load  app/main.py:3' && printf '%s' "$out" | grep -q 'ValueError: bad  at app/main.py:10' \
    && printf '%s' "$out" | grep -q 'lines executed' && ok "trace mode: spans with file:line, error location, line coverage" || bad "trace kit" "$out"
  if grep -hq '"password": "\*\*\*"' "$D"/logs/trace/*.jsonl && ! grep -rq hunter2 "$D/logs"; then
    ok "trace redacts secret-named inputs (the value is never written)"
  else
    bad "redaction" "$(head -c 600 "$D"/logs/trace/*.jsonl)"
  fi
  printf 'API_KEY=\n' >"$D/.env.example"; cp "$D/.env.example" "$D/.env"
  out=$(cd "$D" && "$PY" preflight.py --dirs logs 2>&1); rc=$?
  [ $rc = 1 ] && printf '%s' "$out" | grep -q 'no value for: API_KEY' && ok "preflight refuses blank .env values (names only)" || bad "preflight blank env" "$out"
  printf 'API_KEY=abc\n' >"$D/.env"
  out=$(cd "$D" && "$PY" launcher.py diagnose --yes 2>&1); rc=$?
  [ $rc = 0 ] && printf '%s' "$out" | grep -q 'preflight passed' && ok "launcher diagnose (direct mode)" || bad "launcher diagnose" "$out"
  out=$(cd "$D" && LAUNCHER_KEYS="down,down,enter,q" "$PY" launcher.py --plain 2>&1); rc=$?
  [ $rc = 0 ] && printf '%s' "$out" | grep -q '> 3  Test' && printf '%s' "$out" | grep -q 'Test - exit' \
    && ok "launcher menu: arrows move, Enter runs, q quits" || bad "launcher menu" "$out"
  grep -q "$(printf '\r')" "$K/run.sh" && bad "run.sh has CRLF" || ok "run.sh is LF"
else
  skip "launcher and trace kits (no python)"
fi

# ---------------------------------------------------------------- 11. uninstall
section "11. uninstall"
expect_ok "uninstall --yes" bash "$PRESET/uninstall.sh" --target "$R" --yes
[ ! -d "$R/.agents/bin" ] && [ ! -f "$R/.agents/PROJECT.xml" ] && [ -f "$R/FLOW.md" ] && [ -f "$R/.agents/profile.xml" ] \
  && ok "preset removed; triad and profile kept" || bad "uninstall result" "$(ls -la "$R" "$R/.agents" 2>&1)"
lacks "$R/AGENTS.md" 'project-preset:begin' && has "$R/AGENTS.md" 'never touch prod' && ok "block removed, constitution kept" || bad "AGENTS.md after uninstall"
[ -z "$(git -C "$R" config --get core.hooksPath)" ] && ok "core.hooksPath unset" || bad "hooksPath still set"
[ ! -d "$R/.claude/skills/code-review" ] && ok "Claude stubs removed" || bad "stubs left behind"

# Inside the skills repo layout (preset/ next to skills/): the bundled Matt Pocock copies must equal upstream's.
UPREPO=$(cd "$PRESET/.." 2>/dev/null && pwd)
if [ -f "$UPREPO/.claude-plugin/plugin.json" ] && [ -d "$UPREPO/skills/engineering" ]; then
  drift=""
  for d in "$UPREPO"/skills/engineering/*/ "$UPREPO"/skills/productivity/*/; do
    n=$(basename "$d"); [ -f "$d/SKILL.md" ] || continue
    grep -q "\"./skills/[a-z]*/$n\"" "$UPREPO/.claude-plugin/plugin.json" || continue
    diff -rq "$d" "$PRESET/payload/.agents/skills/$n" >/dev/null 2>&1 || drift="$drift $n"
  done
  [ -z "$drift" ] && ok "bundled Matt Pocock skills are byte-identical to ../skills" || bad "bundled skills drifted from ../skills:$drift (run tools/sync-matt-skills.sh ..)"
else
  skip "not inside the skills repo layout: upstream identity check skipped"
fi

printf '\n%d passed, %d failed, %d skipped\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ]
