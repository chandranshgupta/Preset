#!/usr/bin/env bash
# doctor.sh - is the project preset in this repository intact and wired?
#
#   sh .agents/bin/doctor.sh [--ci]   (Windows PowerShell or cmd: .agents\bin\preset doctor)
#   --ci  on a CI runner: hook wiring is local config, so it is reported, not failed
#
# Checks: required files, hook wiring, line-ending rules, the AGENTS.md managed block, XML
# well-formedness (when a parser is available), skill frontmatter, Claude Code skill stubs,
# profile, constitution and triad state, legacy installs.
# Exit 0 healthy (notes allowed), 1 something is broken, 2 cannot run.

if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
set -uo pipefail

# Find the repo from the script's own location, so doctor can run from any folder.
HERE=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
ROOT=$(git -C "$HERE" rev-parse --show-toplevel 2>/dev/null || git rev-parse --show-toplevel 2>/dev/null) || {
  printf 'doctor: not inside a git repository\n' >&2; exit 2; }
cd "$ROOT" || exit 2

CI=0; [ "${1:-}" = "--ci" ] && CI=1
FAIL=0; NOTE=0
ok()   { printf '  ok     %s\n' "$*"; }
note() { NOTE=$((NOTE + 1)); printf '  note   %s\n' "$*"; }
bad()  { FAIL=$((FAIL + 1)); printf '  FAIL   %s\n' "$*"; }

printf 'doctor - %s - preset %s\n' "$ROOT" "$(tr -d '\r\n' <.agents/VERSION 2>/dev/null || echo unknown)"

# --- required files
for f in .agents/PROJECT.xml .agents/profile.xml .agents/bin/precheck.sh .agents/bin/slice.sh \
         .agents/bin/preset.sh .agents/bin/preset.cmd \
         .agents/skills/project-standard/SKILL.md .agents/skills/final-check/SKILL.md \
         .agents/skills/project-memory/SKILL.md \
         .agents/modules/oss/CORE.xml .agents/modules/oss/DIRECTIVE.xml \
         .githooks/pre-commit .githooks/commit-msg AGENTS.md; do
  [ -f "$f" ] && ok "$f" || bad "$f is missing - reinstall the preset"
done

# --- hook wiring
hp=$(git config --get core.hooksPath 2>/dev/null || true)
case "$hp" in
  .githooks) ok "core.hooksPath = .githooks (local config: re-run the installer on each new clone)" ;;
  '') if [ "$CI" -eq 1 ]; then note "core.hooksPath not set (expected on CI; the CI job is the gate here)"; else bad "core.hooksPath is not set - commits are not gated (reinstall, or: git config core.hooksPath .githooks)"; fi ;;
  *) note "core.hooksPath is \"$hp\" - make sure it calls .agents/bin/precheck.sh --staged" ;;
esac
for h in .githooks/pre-commit .githooks/commit-msg .agents/bin/precheck.sh; do
  [ -f "$h" ] && grep -q "$(printf '\r')" "$h" && bad "$h has CRLF line endings - bash will fail (check .gitattributes, then re-checkout)"
done
grep -q 'project-preset: keep shell scripts LF' .gitattributes 2>/dev/null \
  && ok ".gitattributes keeps shell scripts LF" || note ".gitattributes has no LF rule for *.sh - Windows clones may break the hooks"

# --- AGENTS.md managed block
if [ -f AGENTS.md ]; then
  b=$(grep -c 'project-preset:begin' AGENTS.md); e=$(grep -c 'project-preset:end' AGENTS.md)
  if [ "$b" -eq 1 ] && [ "$e" -eq 1 ]; then ok "AGENTS.md managed block present once"
  else bad "AGENTS.md has $b begin / $e end markers - expected exactly one each (reinstall repairs it)"; fi
  grep -q 'oss-excellence:begin' AGENTS.md && note "AGENTS.md still has a legacy oss-excellence block - reinstall replaces it"
  lines=$(wc -l <AGENTS.md | tr -d ' ')
  [ "$lines" -gt 250 ] && note "AGENTS.md is $lines lines - keep the constitution short (THR-27)"
  grep -q '<fill' AGENTS.md && note "constitution has <fill> placeholders - finish PRESET (PRE-09)"
fi

# --- profile and memory triad
if [ -f .agents/profile.xml ]; then
  if grep -q 'status="UNFILLED"' .agents/profile.xml; then note "profile.xml is UNFILLED - run PRESET (skill project-setup)"
  else ok "profile.xml filled"; fi
fi
for m in PROJECT_BRAIN.md FLOW.md DECISION.md; do
  if [ ! -f "$m" ]; then note "$m missing - the memory triad is incomplete (P5)"
  elif grep -q '<fill' "$m"; then note "$m still holds template placeholders"; fi
done

# --- is the XML well-formed
xml_files=$(ls .agents/PROJECT.xml .agents/profile.xml .agents/modules/*/*.xml 2>/dev/null)
py=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c 'print(1)' >/dev/null 2>&1; then py=$c; break; fi
done
if [ -n "$py" ]; then
  for x in $xml_files; do
    if msg=$("$py" -c 'import sys,xml.dom.minidom as m; m.parse(sys.argv[1])' "$x" 2>&1); then ok "$x well-formed"
    else bad "$x is not well-formed: $(printf '%s' "$msg" | tail -1)"; fi
  done
elif command -v xmllint >/dev/null 2>&1; then
  for x in $xml_files; do
    xmllint --noout "$x" 2>/dev/null && ok "$x well-formed" || bad "$x is not well-formed (xmllint)"
  done
else
  note "XML well-formedness UNVERIFIED - no python or xmllint on PATH"
fi

# --- skills and their Claude Code stubs
for s in .agents/skills/*/SKILL.md; do
  [ -f "$s" ] || continue
  d=$(basename "$(dirname "$s")")
  n=$(sed -n '2,6p' "$s" | tr -d '\r' | sed -nE 's/^name:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/p' | head -1)
  [ "$n" = "$d" ] || note "skill folder $d declares name '$n' - tools discover skills by name"
  stub=".claude/skills/$d/SKILL.md"
  if [ -d .claude/skills ] && [ ! -f "$stub" ]; then note "no Claude Code stub for skill $d (reinstall creates it)"; fi
done
ok "$(ls -d .agents/skills/*/ 2>/dev/null | wc -l | tr -d ' ') skills, $(ls .agents/workflows/*.md 2>/dev/null | wc -l | tr -d ' ') workflows"

# --- old (legacy) install
[ -d .oss-excellence ] && note "legacy .oss-excellence/ found - superseded by .agents/; remove it after checking .oss-excellence/allow was carried over"

printf '\n'
if [ "$FAIL" -gt 0 ]; then printf '%d problem(s), %d note(s) - preset is not healthy.\n' "$FAIL" "$NOTE"; exit 1; fi
printf 'healthy - %d note(s)\n' "$NOTE"
exit 0
