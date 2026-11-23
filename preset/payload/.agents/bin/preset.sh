#!/usr/bin/env bash
# preset.sh - one entry point for the project preset's tools.
#
#   sh .agents/bin/preset.sh check [--staged|--all|--final|--release] [options]
#   sh .agents/bin/preset.sh doctor
#   sh .agents/bin/preset.sh slice [-f project|oss|oss-core|profile] list|get|grep|ids [arg]
#
# Windows PowerShell or cmd (no sh on PATH):  .agents\bin\preset check --final

if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
HERE=$(cd "$(dirname "$0")" && pwd)

cmd=${1:-help}
[ $# -gt 0 ] && shift
case "$cmd" in
  check|precheck) exec bash "$HERE/precheck.sh" "$@" ;;
  doctor)         exec bash "$HERE/doctor.sh" "$@" ;;
  slice)          exec bash "$HERE/slice.sh" "$@" ;;
  help|-h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
  *) printf 'preset: unknown command %s (check | doctor | slice | help)\n' "$cmd" >&2; exit 2 ;;
esac
