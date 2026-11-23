#!/usr/bin/env bash
# install.sh - install the project preset into a git repository (Linux, macOS, Git Bash).
#
#   ./install.sh [--target DIR] [options]
#
#   --target DIR          repository to install into (default: current directory)
#   --force               refresh preset-owned files (scripts, skills, workflows, hooks, templates)
#   --upgrade-standard    also replace PROJECT.xml and modules/, keeping a .bak of each
#   --no-hooks            place the files but do not set core.hooksPath
#   --no-memory           do not create PROJECT_BRAIN.md, FLOW.md, DECISION.md
#   --no-adapters         do not create CLAUDE.md, GEMINI.md, .agent/ aliases, .claude/skills stubs
#   --no-vendored         skip the vendored third-party skills (lean install)
#   --with-ci             also add .github/workflows/preset-gate.yml (the gate in CI)
#                         (without it, the installer only suggests the CI gate)
#   --skills-from DIR     also import every skill folder found under DIR into .agents/skills/
#   --only a,b,c          with --skills-from, import only these skill names
#
# Ownership: preset-owned files are written if absent (or with --force); standards only if absent
# (or with --upgrade-standard); project-owned files (profile.xml, allow, memory triad, adapters,
# CI file, the AGENTS.md constitution) are created once and never overwritten. The AGENTS.md
# managed block is replaced in place on every run. Safe to re-run. Remove with uninstall.sh.

if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
set -uo pipefail

SRC=$(cd "$(dirname "$0")" && pwd)
PAYLOAD="$SRC/payload"
TARGET="."
HOOKS=1; FORCE=0; UPGRADE=0; MEMORY=1; ADAPTERS=1; VENDORED=1; WITH_CI=0
SKILLS_FROM=""; ONLY=""

usage() { sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --target)           TARGET=${2:-}; shift 2 || { usage; exit 2; } ;;
    --force)            FORCE=1; shift ;;
    --upgrade-standard) UPGRADE=1; shift ;;
    --no-hooks)         HOOKS=0; shift ;;
    --no-memory)        MEMORY=0; shift ;;
    --no-adapters)      ADAPTERS=0; shift ;;
    --no-vendored)      VENDORED=0; shift ;;
    --with-ci)          WITH_CI=1; shift ;;
    --skills-from)      SKILLS_FROM=${2:-}; shift 2 || { usage; exit 2; } ;;
    --only)             ONLY=${2:-}; shift 2 || { usage; exit 2; } ;;
    -h|--help)          usage; exit 0 ;;
    *) printf 'install: unknown option %s (try --help)\n' "$1" >&2; exit 2 ;;
  esac
done

[ -d "$PAYLOAD/.agents" ] || { printf 'install: payload/ missing beside install.sh\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'install: git is not on PATH\n' >&2; exit 2; }

ROOT=$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null) || {
  printf 'install: %s is not a git repository (run git init first)\n' "$TARGET" >&2; exit 2; }

printf 'project-preset %s -> %s\n' "$(tr -d '\r\n' <"$PAYLOAD/.agents/VERSION")" "$ROOT"

VENDORED_LIST=$(tr -d '\r' <"$PAYLOAD/.agents/skills/VENDORED" 2>/dev/null || true)
is_vendored() { printf '%s\n' "$VENDORED_LIST" | grep -qx "$1"; }

WROTE=0; KEPT=0
put() { # $1 full source path, $2 path inside ROOT, $3 policy: preset|standard|project
  local from=$1 rel=$2 to="$ROOT/$2"
  mkdir -p "$(dirname "$to")" || { printf '  FAIL   %s\n' "$rel" >&2; return 1; }
  if [ -e "$to" ]; then
    if cmp -s "$from" "$to"; then KEPT=$((KEPT + 1)); return 0; fi
    case "$3" in
      preset)   [ "$FORCE" -eq 1 ] || { printf '  keep   %s (differs; --force refreshes)\n' "$rel"; KEPT=$((KEPT + 1)); return 0; } ;;
      standard) [ "$UPGRADE" -eq 1 ] || { printf '  keep   %s (customised or older; --upgrade-standard replaces)\n' "$rel"; KEPT=$((KEPT + 1)); return 0; }
                cp "$to" "$to.bak" && printf '  backup %s.bak\n' "$rel" ;;
      project)  KEPT=$((KEPT + 1)); return 0 ;;
    esac
  fi
  cp "$from" "$to" || { printf '  FAIL   %s\n' "$rel" >&2; return 1; }
  case "$rel" in *.sh|.githooks/*) chmod +x "$to" 2>/dev/null ;; esac
  WROTE=$((WROTE + 1))
  printf '  write  %s\n' "$rel"
}

# 1. Every file in payload/.agents, copied according to its owner.
while IFS= read -r f; do
  rel=${f#"$PAYLOAD"/}
  case "$rel" in
    .agents/skills/*/*)
      skill=${rel#.agents/skills/}; skill=${skill%%/*}
      if [ "$VENDORED" -eq 0 ] && is_vendored "$skill"; then continue; fi ;;
  esac
  case "$rel" in
    .agents/profile.xml|.agents/allow) put "$f" "$rel" project ;;
    .agents/PROJECT.xml|.agents/modules/*) put "$f" "$rel" standard ;;
    *) put "$f" "$rel" preset ;;
  esac
done < <(cd "$PAYLOAD" && find .agents -type f ! -path '*/__pycache__/*' ! -name '*.pyc' | sort | sed "s|^|$PAYLOAD/|")

# 2. Hooks. The old oss-excellence preset's hook would still run the old gate,
#    so we replace it even without --force.
for h in pre-commit commit-msg; do
  if grep -q 'oss-excellence' "$ROOT/.githooks/$h" 2>/dev/null; then
    cp "$PAYLOAD/.githooks/$h" "$ROOT/.githooks/$h" && chmod +x "$ROOT/.githooks/$h" 2>/dev/null
    WROTE=$((WROTE + 1)); printf '  write  .githooks/%s (replaced legacy oss-excellence hook)\n' "$h"
  else
    put "$PAYLOAD/.githooks/$h" ".githooks/$h" preset
  fi
done

# 3. Memory triad (BRAIN, FLOW, DECISION) from templates: created only once.
if [ "$MEMORY" -eq 1 ]; then
  for m in PROJECT_BRAIN.md FLOW.md DECISION.md; do put "$PAYLOAD/.agents/templates/$m" "$m" project; done
fi

# 4. Adapters for tools that do not read AGENTS.md or .agents/skills themselves.
if [ "$ADAPTERS" -eq 1 ]; then
  while IFS= read -r f; do
    rel=${f#"$PAYLOAD/adapters"/}
    put "$f" "$rel" project
  done < <(cd "$PAYLOAD/adapters" && find . -type f | sort | sed "s|^\./|$PAYLOAD/adapters/|")

  # Claude Code looks for skills in .claude/skills. The stub holds the real skill's name and
  # description (so it triggers) and points to the real file (so content does not drift).
  # Only stubs made by the installer are rewritten; a user's own skill with the same name wins.
  stubs=0
  for s in "$ROOT"/.agents/skills/*/SKILL.md; do
    [ -f "$s" ] || continue
    name=$(basename "$(dirname "$s")")
    stub="$ROOT/.claude/skills/$name/SKILL.md"
    if [ -f "$stub" ] && ! grep -q 'project-preset:stub' "$stub"; then
      printf '  keep   .claude/skills/%s (your own skill, not a preset stub)\n' "$name"; continue
    fi
    tmp=$(mktemp) || exit 2
    {
      printf -- '---\n'
      tr -d '\r' <"$s" | sed -n '2,12p' | sed -n '/^---$/q;p' | grep -E '^(name|description):'
      printf -- '---\n\n<!-- project-preset:stub - generated by the installer; do not edit -->\n'
      printf 'Read `.agents/skills/%s/SKILL.md` in full and follow it. Supporting files sit beside it.\n' "$name"
      printf 'Precedence: `.agents/PROJECT.xml` (prime directives first) wins any conflict.\n'
    } >"$tmp"
    if [ -f "$stub" ] && cmp -s "$tmp" "$stub"; then rm -f "$tmp"; continue; fi
    mkdir -p "$(dirname "$stub")" && mv "$tmp" "$stub" && stubs=$((stubs + 1))
  done
  [ "$stubs" -gt 0 ] && printf '  write  .claude/skills/* (%s Claude Code discovery stubs)\n' "$stubs"
fi

# 5. Optional: the gate in CI (created once, then it belongs to the project).
[ "$WITH_CI" -eq 1 ] && put "$PAYLOAD/extras/ci/preset-gate.yml" ".github/workflows/preset-gate.yml" project

# 6. Optional skill import: whole folders are copied; files that already exist are kept.
if [ -n "$SKILLS_FROM" ]; then
  [ -d "$SKILLS_FROM" ] || { printf 'install: --skills-from %s is not a directory\n' "$SKILLS_FROM" >&2; exit 2; }
  imported=0 skipped=0
  for src in "$SKILLS_FROM"/*/; do
    [ -f "$src/SKILL.md" ] || continue
    name=$(basename "$src")
    if [ -n "$ONLY" ] && ! printf '%s' "$ONLY" | tr ',' '\n' | tr -d ' ' | grep -qx "$name"; then
      skipped=$((skipped + 1)); continue
    fi
    while IFS= read -r f; do
      dest="$ROOT/.agents/skills/$name/${f#"$src"}"
      [ -e "$dest" ] && continue
      mkdir -p "$(dirname "$dest")" && cp "$f" "$dest"
    done < <(find "$src" -type f)
    imported=$((imported + 1))
    printf '  import .agents/skills/%s\n' "$name"
  done
  printf '  skills %s imported, %s not selected (re-run to create their Claude Code stubs)\n' "$imported" "$skipped"
fi

# 7. Old oss-excellence install: carry the reviewed exceptions over to the new allow once.
if [ -f "$ROOT/.oss-excellence/allow" ] && ! grep -q 'carried over from .oss-excellence' "$ROOT/.agents/allow" 2>/dev/null; then
  entries=$(grep -vE '^[[:space:]]*(#|$)' "$ROOT/.oss-excellence/allow" || true)
  if [ -n "$entries" ]; then
    { printf '\n# carried over from .oss-excellence/allow\n'; printf '%s\n' "$entries"; } >>"$ROOT/.agents/allow"
    printf '  carry  .oss-excellence/allow -> .agents/allow\n'
  fi
fi
[ -d "$ROOT/.oss-excellence" ] && printf '  note   legacy .oss-excellence/ found - superseded by .agents/; delete it when you are satisfied\n'

# 8. Line endings: shell scripts and hooks must always stay LF, even with core.autocrlf on (after a fresh clone
#    bash fails on the carriage return); Windows batch files must stay CRLF (LF-only
#    batch files can make cmd jump to the wrong label).
attrs="$ROOT/.gitattributes"
added=0
for rule in '*.sh text eol=lf' '.githooks/* text eol=lf' '*.cmd text eol=crlf' '*.bat text eol=crlf'; do
  grep -qxF "$rule" "$attrs" 2>/dev/null && continue
  if [ "$added" -eq 0 ]; then
    { [ -s "$attrs" ] && [ -n "$(tail -c1 "$attrs")" ] && printf '\n'
      grep -q 'project-preset: keep shell scripts LF' "$attrs" 2>/dev/null || printf '# project-preset: keep shell scripts LF\n'; } >>"$attrs"
  fi
  printf '%s\n' "$rule" >>"$attrs"; added=$((added + 1))
done
[ "$added" -gt 0 ] && printf '  update .gitattributes (%s line-ending rule(s))\n' "$added"

# 9. AGENTS.md: replace the managed block in place (including the old oss-excellence block);
#    if the file exists but has no block, add it at the top; if there is no file, create it from the block + constitution.
agents="$ROOT/AGENTS.md"
block="$PAYLOAD/AGENTS.block.md"
if [ -f "$agents" ] && grep -qE '(project-preset|oss-excellence):begin' "$agents"; then
  tmp=$(mktemp) || exit 2
  awk -v blk="$block" '
    /(project-preset|oss-excellence):begin/ {
      if (!done) { while ((getline l < blk) > 0) print l; close(blk); done = 1 }
      skip = 1; next
    }
    skip && /(project-preset|oss-excellence):end/ { skip = 0; next }
    !skip { print }
  ' "$agents" >"$tmp"
  if cmp -s "$tmp" "$agents"; then rm -f "$tmp"; KEPT=$((KEPT + 1))
  else cat "$tmp" >"$agents" && rm -f "$tmp" && printf '  update AGENTS.md (managed block replaced in place)\n'; fi
elif [ -f "$agents" ]; then
  tmp=$(mktemp) || exit 2
  { cat "$block"; printf '\n'; cat "$agents"; } >"$tmp" && cat "$tmp" >"$agents" && rm -f "$tmp"
  printf '  update AGENTS.md (managed block added above your existing content - that is now the constitution)\n'
else
  { cat "$block"; printf '\n'; cat "$PAYLOAD/.agents/templates/CONSTITUTION.md"; } >"$agents"
  printf '  write  AGENTS.md (managed block + constitution template)\n'
fi

# 9b. .gitignore: replace or add the preset's managed block (agent tooling and local secrets).
gi="$ROOT/.gitignore"
gblock="$PAYLOAD/gitignore.block"
if [ -f "$gi" ] && grep -qE 'project-preset:begin' "$gi"; then
  tmp=$(mktemp) || exit 2
  awk -v blk="$gblock" '
    /project-preset:begin/ {
      if (!done) { while ((getline l < blk) > 0) print l; close(blk); done = 1 }
      skip = 1; next
    }
    skip && /project-preset:end/ { skip = 0; next }
    !skip { print }
  ' "$gi" >"$tmp"
  if cmp -s "$tmp" "$gi"; then rm -f "$tmp"; KEPT=$((KEPT + 1))
  else cat "$tmp" >"$gi" && rm -f "$tmp" && printf '  update .gitignore (managed block replaced in place)\n'; fi
elif [ -f "$gi" ]; then
  { [ -s "$gi" ] && [ -n "$(tail -c1 "$gi")" ] && printf '\n'; cat "$gblock"; } >>"$gi"
  printf '  update .gitignore (managed block appended)\n'
else
  cp "$gblock" "$gi" && printf '  write  .gitignore (managed block)\n'
fi

# 10. Wire the hooks into git (core.hooksPath).
if [ "$HOOKS" -eq 1 ]; then
  current=$(git -C "$ROOT" config --get core.hooksPath 2>/dev/null || true)
  case "$current" in
    ''|.githooks)
      [ "$current" = .githooks ] || { git -C "$ROOT" config core.hooksPath .githooks && printf '  hooks  core.hooksPath = .githooks\n'; } ;;
    *)
      printf '  keep   core.hooksPath is already "%s" - hooks not activated\n' "$current"
      printf '         call .agents/bin/precheck.sh --staged from that manager, or: git config core.hooksPath .githooks\n' ;;
  esac
fi

printf '\n%s written, %s already in place.\n' "$WROTE" "$KEPT"
# CI gate is only suggested, never added on its own: a public repo should opt in deliberately.
[ "$WITH_CI" -eq 0 ] && [ ! -f "$ROOT/.github/workflows/preset-gate.yml" ] && \
  printf 'Suggested (not added): CI gate on every push and pull request - re-run with --with-ci (-WithCi on PowerShell).\n'
printf 'Next:  sh .agents/bin/doctor.sh             (Windows PowerShell/cmd: .agents\\bin\\preset doctor)\n'
printf '       ask your agent to run the PRESET stage (skill project-setup)\n'
printf '       sh .agents/bin/precheck.sh --final     (before calling anything done)\n'
