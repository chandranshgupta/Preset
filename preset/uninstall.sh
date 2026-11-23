#!/usr/bin/env bash
# uninstall.sh - remove the project preset from a git repository (Linux, macOS, Git Bash).
#
#   ./uninstall.sh [--target DIR] [--purge] [--yes]
#
#   Removes: preset scripts, skills shipped by the preset, workflows, templates, standards
#   (PROJECT.xml, modules/), hooks, Claude Code stubs, unmodified adapters, the AGENTS.md managed
#   block, the .gitattributes rules it added, and core.hooksPath if it points at .githooks.
#   Keeps (your project's knowledge): the memory triad, the AGENTS.md constitution, any adapter
#   or skill you changed or added, profile.xml and allow - unless --purge, which also removes
#   profile.xml and allow. The triad and the constitution are never removed.
#   --yes  do not ask for confirmation.
#
# Files are deleted, not moved: commit or stash first if you want them back.

if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
set -uo pipefail

SRC=$(cd "$(dirname "$0")" && pwd)
PAYLOAD="$SRC/payload"
TARGET="."; PURGE=0; YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET=${2:-}; shift 2 || exit 2 ;;
    --purge)  PURGE=1; shift ;;
    --yes|-y) YES=1; shift ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf 'uninstall: unknown option %s\n' "$1" >&2; exit 2 ;;
  esac
done

ROOT=$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null) || {
  printf 'uninstall: %s is not a git repository\n' "$TARGET" >&2; exit 2; }
[ -d "$ROOT/.agents" ] || { printf 'uninstall: no .agents/ in %s - nothing to remove\n' "$ROOT"; exit 0; }

if [ "$YES" -eq 0 ]; then
  printf 'Remove the project preset from %s%s? [y/N] ' "$ROOT" "$([ "$PURGE" -eq 1 ] && printf ' (including profile.xml and allow)')"
  read -r answer
  case "$answer" in y|Y|yes|YES) ;; *) printf 'nothing removed\n'; exit 0 ;; esac
fi

rm_path() { [ -e "$ROOT/$1" ] || return 0; rm -rf "$ROOT/$1" && printf '  remove %s\n' "$1"; }

# The preset's own folders and files.
for p in .agents/bin .agents/workflows .agents/templates .agents/modules .agents/PROJECT.xml \
         .agents/README.md .agents/VERSION .agents/skills/THIRD_PARTY.md .agents/skills/VENDORED; do
  rm_path "$p"
done
# Only the skills that shipped with the preset; imported or hand-written skills stay.
for d in "$PAYLOAD"/.agents/skills/*/; do
  name=$(basename "$d"); rm_path ".agents/skills/$name"
done
# Claude Code stubs made by the installer.
for s in "$ROOT"/.claude/skills/*/SKILL.md; do
  [ -f "$s" ] && grep -q 'project-preset:stub' "$s" && rm_path ".claude/skills/$(basename "$(dirname "$s")")"
done
# Hooks: remove only when they are ours.
for h in pre-commit commit-msg; do
  grep -q 'project-preset' "$ROOT/.githooks/$h" 2>/dev/null && rm_path ".githooks/$h"
done
# Adapters: remove only when the user has not changed them.
while IFS= read -r f; do
  rel=${f#"$PAYLOAD/adapters"/}
  [ -f "$ROOT/$rel" ] && cmp -s "$f" "$ROOT/$rel" && rm_path "$rel"
done < <(cd "$PAYLOAD/adapters" && find . -type f | sed "s|^\./|$PAYLOAD/adapters/|")
[ "$PURGE" -eq 1 ] && { rm_path .agents/profile.xml; rm_path .agents/allow; }

# Clean up any empty folders left behind.
for d in .agents/skills .agents .claude/skills .claude .githooks .agent/workflows .agent/rules .agent; do
  [ -d "$ROOT/$d" ] && rmdir "$ROOT/$d" 2>/dev/null && printf '  remove %s/ (empty)\n' "$d"
done

# Remove the AGENTS.md managed block, keep the constitution.
if [ -f "$ROOT/AGENTS.md" ] && grep -q 'project-preset:begin' "$ROOT/AGENTS.md"; then
  tmp=$(mktemp) || exit 2
  awk '/project-preset:begin/{skip=1;next} skip&&/project-preset:end/{skip=0;next} !skip{print}' "$ROOT/AGENTS.md" \
    | sed '/./,$!d' >"$tmp"
  cat "$tmp" >"$ROOT/AGENTS.md"; rm -f "$tmp"
  printf '  update AGENTS.md (managed block removed, constitution kept)\n'
fi

# The preset block in .gitignore (nothing else).
if [ -f "$ROOT/.gitignore" ] && grep -qE 'project-preset:begin' "$ROOT/.gitignore"; then
  tmp=$(mktemp) || exit 2
  awk '/project-preset:begin/ {skip = 1; next} skip && /project-preset:end/ {skip = 0; next} !skip {print}' \
    "$ROOT/.gitignore" >"$tmp"
  if [ -s "$tmp" ]; then cat "$tmp" >"$ROOT/.gitignore"; else rm -f "$ROOT/.gitignore"; fi
  rm -f "$tmp"; printf '  update .gitignore (preset block removed)\n'
fi

# The .gitattributes rules that the preset added.
if [ -f "$ROOT/.gitattributes" ]; then
  tmp=$(mktemp) || exit 2
  grep -vxF -e '# project-preset: keep shell scripts LF' -e '*.sh text eol=lf' \
            -e '.githooks/* text eol=lf' -e '*.cmd text eol=crlf' -e '*.bat text eol=crlf' "$ROOT/.gitattributes" >"$tmp" || true
  if [ -s "$tmp" ]; then cat "$tmp" >"$ROOT/.gitattributes"; else rm -f "$ROOT/.gitattributes"; fi
  rm -f "$tmp"; printf '  update .gitattributes (preset rules removed)\n'
fi

if [ "$(git -C "$ROOT" config --get core.hooksPath 2>/dev/null)" = ".githooks" ]; then
  git -C "$ROOT" config --unset core.hooksPath && printf '  hooks  core.hooksPath unset\n'
fi

printf '\nKept: PROJECT_BRAIN.md, FLOW.md, DECISION.md, the AGENTS.md constitution%s.\n' \
  "$([ "$PURGE" -eq 0 ] && printf ', .agents/profile.xml, .agents/allow')"
