#!/usr/bin/env bash
# slice.sh - print one piece of a standard XML so an agent loads kilobytes, not the whole file.
#
#   sh .agents/bin/slice.sh [-f FILE] list            sections and addressable blocks, with sizes
#   sh .agents/bin/slice.sh [-f FILE] get NAME        a section by tag (laws, router, memory...)
#                                                     or any element by id (PRESET, THR-07, SEC-03)
#   sh .agents/bin/slice.sh [-f FILE] grep PATTERN    ids of rules/laws/items whose text matches
#   sh .agents/bin/slice.sh [-f FILE] ids             every id with its element name
#
#   -f project   .agents/PROJECT.xml            (default)
#   -f oss       .agents/modules/oss/DIRECTIVE.xml
#   -f oss-core  .agents/modules/oss/CORE.xml
#   -f profile   .agents/profile.xml
#   -f PATH      any XML laid out one element per line
#
# get also accepts phase numbers for the oss directive (get 2 = EVALUATE) and is
# case-insensitive for ids. Dependencies: bash, grep, sed, awk.

if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
set -uo pipefail

HERE=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
AGENTS_DIR=$(dirname "$HERE")

die() { printf 'slice: %s\n' "$*" >&2; exit 1; }

resolve() {
  case "$1" in
    project|'')   printf '%s\n' "$AGENTS_DIR/PROJECT.xml" ;;
    oss)          printf '%s\n' "$AGENTS_DIR/modules/oss/DIRECTIVE.xml" ;;
    oss-core)     printf '%s\n' "$AGENTS_DIR/modules/oss/CORE.xml" ;;
    mp|matt-pocock) printf '%s\n' "$AGENTS_DIR/modules/matt-pocock/DIRECTIVE.xml" ;;
    mp-core)      printf '%s\n' "$AGENTS_DIR/modules/matt-pocock/CORE.xml" ;;
    profile)      printf '%s\n' "$AGENTS_DIR/profile.xml" ;;
    *)            printf '%s\n' "$1" ;;
  esac
}

FILE=$(resolve "${SLICE_FILE:-project}")
while [ $# -gt 0 ]; do
  case "$1" in
    -f|--file) FILE=$(resolve "${2:-}"); shift 2 || die "-f needs a value" ;;
    *) break ;;
  esac
done

cmd=${1:-list}
arg=${2:-}

case "$cmd" in -h|--help|help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac

[ -f "$FILE" ] || die "no XML at $FILE (run sh .agents/bin/doctor.sh)"

size() { sed -n "$1,$2p" "$FILE" | wc -c | tr -d ' '; }

# span_end START -> the last line of the element that opens on line START.
span_end() {
  awk -v s="$1" '
    NR == s {
      line = $0
      if (!match(line, /<[A-Za-z_][A-Za-z0-9_.-]*/)) { print s; exit }
      tag = substr(line, RSTART + 1, RLENGTH - 1)
      if (line ~ /\/>[[:space:]]*$/ || index(line, "</" tag ">")) { print s; exit }
      next
    }
    NR > s && tag != "" {
      if ($0 ~ "^[[:space:]]*</" tag ">[[:space:]]*$") { print NR; exit }
    }
  ' "$FILE"
}

# The line on which the element named TAG opens (first match).
find_tag() {
  grep -nE "^[[:space:]]*<$1([[:space:]>/]|$)" "$FILE" 2>/dev/null | head -1 | cut -d: -f1
}

# The line where the element with id=ID opens (case-insensitive),
# or an oss phase by its n="" number.
find_id() {
  awk -v want="$1" '
    BEGIN { want = toupper(want) }
    /^[[:space:]]*<[A-Za-z_]/ {
      if (match($0, /[[:space:]]id="[^"]+"/)) {
        id = substr($0, RSTART + 5, RLENGTH - 6)
        if (toupper(id) == want) { print NR; exit }
      }
      if (want ~ /^[0-9]+$/ && $0 ~ /^[[:space:]]*<phase[[:space:]]/ && match($0, /n="[0-9]+"/)) {
        if (substr($0, RSTART + 3, RLENGTH - 4) == want) { print NR; exit }
      }
    }' "$FILE"
}

case "$cmd" in
list)
  root_indent=$(awk '/^[[:space:]]*<[A-Za-z_]/ && !/^<\?/ { match($0, /^[[:space:]]*/); print RLENGTH; exit }' "$FILE")
  child_indent=$((root_indent + 2))
  printf '%s\n' "$FILE"
  printf '%-34s %-6s %-6s %s\n' SECTION START END BYTES
  awk -v ci="$child_indent" '
    {
      match($0, /^[[:space:]]*/)
      if (RLENGTH == ci && substr($0, ci + 1, 1) == "<" && substr($0, ci + 2, 1) ~ /[A-Za-z_]/) print NR
    }' "$FILE" | while read -r s; do
      e=$(span_end "$s")
      name=$(sed -n "${s}p" "$FILE" | sed -E 's/^[[:space:]]*<([A-Za-z_][A-Za-z0-9_.-]*).*/\1/')
      id=$(sed -n "${s}p" "$FILE" | sed -nE 's/.*[[:space:]]id="([^"]+)".*/\1/p')
      label=$name; [ -n "$id" ] && label="$name:$id"
      printf '%-34s %-6s %-6s %s\n' "$label" "$s" "$e" "$(size "$s" "$e")"
    done
  printf '\n%s\n' 'addressable blocks (get <ID>):'
  grep -nE '^[[:space:]]*<(stage|phase|level|domain|module|task_loop)[[:space:]>]' "$FILE" \
    | while IFS=: read -r s rest; do
        id=$(printf '%s' "$rest" | sed -nE 's/.*[[:space:]]id="([^"]+)".*/\1/p')
        tag=$(printf '%s' "$rest" | sed -E 's/^[[:space:]]*<([A-Za-z_]+).*/\1/')
        e=$(span_end "$s")
        printf '  %-32s %-6s %-6s %s\n' "$tag:${id:-$tag}" "$s" "$e" "$(size "$s" "$e")"
      done
  printf '\ntotal %s bytes - get NAME prints one piece, grep PATTERN finds ids\n' "$(wc -c <"$FILE" | tr -d ' ')"
  ;;

get)
  [ -n "$arg" ] || die "usage: slice.sh get <section-or-id>  (see: slice.sh list)"
  s=$(find_tag "$arg")
  [ -n "${s:-}" ] || s=$(find_id "$arg")
  [ -n "${s:-}" ] || die "nothing named or with id '$arg' in $(basename "$FILE") (try: slice.sh ids)"
  e=$(span_end "$s"); [ -n "${e:-}" ] || e=$s
  sed -n "${s},${e}p" "$FILE"
  ;;

grep)
  [ -n "$arg" ] || die "usage: slice.sh grep <pattern>"
  awk -v pat="$arg" '
    BEGIN { pat = tolower(pat) }
    function finish() { if (cur != "" && hit) printf "%-14s %s\n", cur, tag; cur = ""; hit = 0; tag = "" }
    /^[[:space:]]*<(rule|law|gate|item|template|archetype|floor|axis|seed|route|level|step|predicate|term)[[:space:]>]/ {
      if (cur == "" && match($0, /[[:space:]]id="[^"]+"/)) {
        cur = substr($0, RSTART + 5, RLENGTH - 6); hit = 0
        t = $0; sub(/^[[:space:]]*</, "", t); sub(/[[:space:]>].*/, "", t); tag = t
      }
    }
    cur != "" { if (index(tolower($0), pat)) hit = 1 }
    cur != "" && (index($0, "</" tag ">") || $0 ~ /\/>[[:space:]]*$/) { finish() }
  ' "$FILE"
  ;;

ids)
  awk '
    /^[[:space:]]*<[A-Za-z_]/ && match($0, /[[:space:]]id="[^"]+"/) {
      id = substr($0, RSTART + 5, RLENGTH - 6)
      t = $0; sub(/^[[:space:]]*</, "", t); sub(/[[:space:]>].*/, "", t)
      printf "%-28s %s\n", id, t
    }' "$FILE"
  ;;

*)
  die "unknown command '$cmd' (list | get | grep | ids)"
  ;;
esac
