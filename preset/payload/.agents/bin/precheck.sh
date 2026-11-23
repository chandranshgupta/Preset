#!/usr/bin/env bash
# precheck.sh - the FINAL_CHECK gate of the project preset.
#
#   sh .agents/bin/precheck.sh --staged    (default) what is about to be committed  [git hook]
#   sh .agents/bin/precheck.sh --all       every tracked file + readiness + triad    [health]
#   sh .agents/bin/precheck.sh --final     --all, then run the commands declared in
#                                          .agents/profile.xml and report exit codes  [before "done"]
#   sh .agents/bin/precheck.sh --release   --final with every warning promoted to a blocker,
#                                          plus changelog, security policy, tag, filled profile
#   options: --strict (promote warnings)  --quiet (problems and summary only)
#            --no-run (with --final/--release: skip executing declared commands)
#   env:     PRESET_CMD_TIMEOUT=seconds per declared command (default 900; needs GNU timeout)
#            PRESET_MAX_BYTES=largest allowed tracked file (default 2097152)
#
# Exit status: 0 clean (warnings allowed), 1 blockers found, 2 cannot run.
#
# BLOCK - irreversible or review-blocking: private keys and tokens, tracked .env, build
#         artifacts, oversized blobs, conflict markers, a declared command that fails.
# WARN  - fix or consciously accept: credential-shaped values, swallowed exceptions, debugger
#         leftovers, machine paths and broken references in instruction or memory files,
#         memory triad out of sync, readiness gaps.
#
# Reviewed exceptions: .agents/allow, one glob per line, "<check>:<path>" or "<check>:".
# Windows PowerShell / cmd: .agents\bin\preset check --final

if [ -z "${BASH_VERSION:-}" ]; then exec bash "$0" "$@"; fi
set -uo pipefail

MODE=staged
STRICT=0
QUIET=0
RUN=1
RELEASE=0

usage() { sed -n '2,27p' "$0" | sed 's/^# \{0,1\}//'; }

for arg in "$@"; do
  case "$arg" in
    --staged)  MODE=staged ;;
    --all)     MODE=all ;;
    --final)   MODE=final ;;
    --release) MODE=final; STRICT=1; RELEASE=1 ;;
    --strict)  STRICT=1 ;;
    --quiet)   QUIET=1 ;;
    --no-run)  RUN=0 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'precheck: unknown option %s (try --help)\n' "$arg" >&2; exit 2 ;;
  esac
done

# Find the repo from the script's own location, so the gate can run from any folder.
HERE=$(cd "$(dirname "$0")" 2>/dev/null && pwd)
ROOT=$(git -C "$HERE" rev-parse --show-toplevel 2>/dev/null || git rev-parse --show-toplevel 2>/dev/null) || {
  printf 'precheck: not inside a git repository\n' >&2; exit 2; }
cd "$ROOT" || exit 2

ALLOW="$ROOT/.agents/allow"
PROFILE="$ROOT/.agents/profile.xml"
MAX_BYTES=${PRESET_MAX_BYTES:-${OSS_MAX_BYTES:-2097152}}
CMD_TIMEOUT=${PRESET_CMD_TIMEOUT:-900}
TRIAD="PROJECT_BRAIN.md FLOW.md DECISION.md"

BLOCKERS=0
WARNS=0
TMP=$(mktemp) || exit 2
OUT=$(mktemp) || exit 2
trap 'rm -f "$TMP" "$OUT"' EXIT

say()  { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }
note() { [ "$QUIET" -eq 1 ] || printf '  NOTE   %s\n' "$*"; }

allowed() { # $1 = the thing to look up, e.g. "artifact:dist/app.js"
  [ -f "$ALLOW" ] || return 1
  local pat
  while IFS= read -r pat || [ -n "$pat" ]; do
    pat=${pat%%#*}; pat=$(printf '%s' "$pat" | tr -d '\r' | sed 's/[[:space:]]*$//')
    [ -n "$pat" ] || continue
    # shellcheck disable=SC2254
    case "$1" in $pat) return 0 ;; esac
  done <"$ALLOW"
  return 1
}

block() { # $1 message, $2 check id, $3 (optional) path for the allowlist
  if allowed "$2:${3:-}"; then return 0; fi
  BLOCKERS=$((BLOCKERS + 1))
  printf '  BLOCK  %s   [%s]\n' "$1" "$2"
}

warn() {
  if allowed "$2:${3:-}"; then return 0; fi
  if [ "$STRICT" -eq 1 ]; then block "$1" "$2" "${3:-}"; return 0; fi
  WARNS=$((WARNS + 1))
  printf '  WARN   %s   [%s]\n' "$1" "$2"
}

profile_value() { # $1 element name -> its text, without extra whitespace
  [ -f "$PROFILE" ] || return 0
  sed -nE "s/.*<$1>([^<]*)<\/$1>.*/\1/p" "$PROFILE" | tr -d ' \r' | head -1
}

fsize() { stat -c %s "$1" 2>/dev/null || stat -f %z "$1" 2>/dev/null || wc -c <"$1" | tr -d ' '; }

list_files() {
  if [ "$MODE" = staged ]; then git diff --cached --name-only --diff-filter=ACMR
  else git ls-files; fi
}

# The preset's own scripts contain the very patterns this looks for; never scan them.
SELF_EXCLUDE='^(\.agents/bin/|\.oss-excellence/)'
CODE_EXT='\.(py|js|jsx|ts|tsx|mjs|cjs|java|kt|go|rb|php|cs|swift|rs|scala|dart|c|cc|cpp|h|hpp|vue|svelte)$'

# "path:line:content" records - in staged mode only the added lines, in all mode all tracked content.
records() {
  if [ "$MODE" = staged ]; then
    git diff --cached -U0 --no-color | awk '
      /^\+\+\+ b\// { f = substr($0, 7); ln = 0; next }
      /^\+\+\+ / { f = ""; next }
      /^@@/ { if (match($0, /\+[0-9]+/)) ln = substr($0, RSTART + 1, RLENGTH - 1) + 0; next }
      /^\+/ && f != "" { printf "%s:%d:%s\n", f, ln, substr($0, 2); ln++ }'
  else
    git grep -nI -e '' -- . 2>/dev/null
  fi | grep -vE "$SELF_EXCLUDE"
}

match_records() { # $1 = ERE pattern (-e is used because some patterns start with a dash)
  records | grep -E -e "$1"
}

hits_to() { # $1 severity function, $2 check, $3 start of the message; reads the TMP file
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    path=${hit%%:*}
    "$1" "$3: $(printf '%s' "$hit" | tr -d '\r' | cut -c1-160)" "$2" "$path"
  done <"$TMP"
}

say "precheck - $MODE$([ "$RELEASE" -eq 1 ] && printf ' (release)') - $ROOT"

# ---------------------------------------------------------------- structural
while IFS= read -r f; do
  [ -n "$f" ] || continue
  base=${f##*/}
  case "$f" in
    node_modules/*|*/node_modules/*|dist/*|*/dist/*|build/*|*/build/*|\
    .next/*|*/.next/*|__pycache__/*|*/__pycache__/*|*.pyc|\
    .venv/*|*/.venv/*|venv/*|*/venv/*|target/*|*/target/*|\
    *.o|*.so|*.dylib|*.dll|*.exe|*.class|*.log|.DS_Store|*/.DS_Store|Thumbs.db|*/Thumbs.db)
      block "build artifact is tracked: $f" "artifact" "$f" ;;
  esac
  case "$base" in
    .env|.env.*)
      case "$base" in
        *.example|*.sample|*.template) : ;;
        *) block "environment file is tracked: $f (use .env.example)" "env" "$f" ;;
      esac ;;
  esac
  if [ -f "$f" ]; then
    sz=$(fsize "$f")
    if [ "${sz:-0}" -gt "$MAX_BYTES" ] 2>/dev/null; then
      block "file is $((sz / 1024)) KiB, over the ${MAX_BYTES}-byte limit: $f" "size" "$f"
    fi
  fi
done < <(list_files)

# ------------------------------------------------------------------- secrets
HARD='-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|xox[baprs]-[A-Za-z0-9-]{10}|AIza[0-9A-Za-z_-]{35}|sk-[A-Za-z0-9_-]{20}|sk_live_[0-9A-Za-z]{16}|glpat-[A-Za-z0-9_-]{20}|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
SOFT='(password|passwd|secret|api[_-]?key|apikey|access[_-]?token|auth[_-]?token)[[:space:]]*[:=][[:space:]]*[^[:space:]]{8,}'

match_records "$HARD" >"$TMP" && hits_to block secret "possible credential"
match_records "$SOFT" 2>/dev/null \
  | grep -viE 'environ|process\.env|getenv|os\.Getenv|\$\{?[A-Z_]+\}?|example|changeme|placeholder|xxxx|<fill|your[_-]' >"$TMP" \
  && hits_to warn secret-soft "credential-shaped assignment, confirm it is not a real value"

# ----------------------------------------------------------- conflict markers
records | grep -E '^[^:]+:[0-9]+:(<<<<<<<|>>>>>>>|\|\|\|\|\|\|\|) ' >"$TMP" \
  && hits_to block conflict "unresolved merge marker"

# -------------------------------------------------------------- code hygiene
records | grep -E "^[^:]+$(printf '%s' "$CODE_EXT" | sed 's/\$$//'):" >"$OUT" || :

# swallowed errors: "except ...: pass" (same or next line), empty catch blocks
awk '
  { file = $0; sub(/:.*/, "", file); rest = $0; sub(/^[^:]+:[0-9]+:/, "", rest) }
  file == pf && prev ~ /^[[:space:]]*except([[:space:]].*)?:[[:space:]]*$/ && rest ~ /^[[:space:]]*pass[[:space:]]*$/ { print pline }
  rest ~ /except([[:space:]][^:]*)?:[[:space:]]*pass[[:space:]]*$/ { print $0 }
  rest ~ /catch[[:space:]]*(\([^)]*\))?[[:space:]]*\{[[:space:]]*\}/ { print $0 }
  { pf = file; prev = rest; pline = $0 }
' "$OUT" >"$TMP"
[ -s "$TMP" ] && hits_to warn swallowed "exception swallowed - surface it (L10)"

grep -E ':[0-9]+:[[:space:]]*(debugger;?|import pdb; ?pdb\.set_trace\(\)|pdb\.set_trace\(\)|breakpoint\(\)|binding\.pry)[[:space:]]*$' "$OUT" >"$TMP" \
  && hits_to warn debugger "debugger statement left in code"

# absolute paths tied to one machine in instruction and memory files
records | grep -E '^([^:]*\.md|[^:]*\.mdc|\.agents/[^:]*\.xml|\.cursorrules):' \
  | grep -E '[A-Za-z]:(\\{1,2}|/)Users(\\|/)|/home/[a-z_][a-z0-9_-]*/|/Users/[A-Za-z][A-Za-z0-9._-]*/' >"$TMP" \
  && hits_to warn machine-path "machine-specific path in an instruction file"

# ------------------------------------------------- triad sync (P5) - staged
cadence=$(profile_value memory_cadence)
if [ "$MODE" = staged ] && [ "$cadence" = "EVERY_TASK" ]; then
  staged=$(git diff --cached --name-only --diff-filter=ACMRD)
  if printf '%s\n' "$staged" | grep -qE "$CODE_EXT" \
     && ! printf '%s\n' "$staged" | grep -qxE 'PROJECT_BRAIN\.md|FLOW\.md|DECISION\.md'; then
    warn "code is being committed but no memory triad file changed (memory_cadence EVERY_TASK)" "memory-sync"
  fi
fi

# ---------------------------------------------------------------- readiness
if [ "$MODE" != staged ]; then
  tracked() { git ls-files -- "$@" | head -1; }
  readme=$(git ls-files | grep -iE '^README(\.[A-Za-z]+)?$' | head -1)

  if [ -z "$(tracked .gitignore)" ]; then
    warn "no .gitignore at the repository root (PRE-01)" "gitignore"
  elif ! grep -qE '(^|/)\.env' .gitignore 2>/dev/null; then
    warn ".gitignore does not cover .env files (PRE-01)" "gitignore"
  fi

  if ! git ls-files | grep -qE '^(LICEN[CS]E|COPYING)(\.[A-Za-z]+)?$'; then
    if [ -z "$readme" ] || ! grep -qiE 'proprietary|all rights reserved|licen[cs]e' "$readme" 2>/dev/null; then
      warn "no licence decision: add LICENSE, or state 'proprietary' in the README (PRE-11)" "licence"
    fi
  fi

  need_lock=""
  [ -n "$(tracked package.json)" ] && need_lock="npm-yarn-pnpm-bun"
  [ -n "$(tracked pyproject.toml requirements.txt)" ] && need_lock="$need_lock pip"
  [ -n "$(tracked Cargo.toml)" ] && need_lock="$need_lock cargo"
  [ -n "$(tracked go.mod)" ] && need_lock="$need_lock go"
  [ -n "$(tracked Gemfile)" ] && need_lock="$need_lock bundler"
  [ -n "$(tracked composer.json)" ] && need_lock="$need_lock composer"
  if [ -n "$need_lock" ]; then
    have_lock=""
    for lf in package-lock.json pnpm-lock.yaml yarn.lock bun.lockb bun.lock npm-shrinkwrap.json \
              uv.lock poetry.lock Pipfile.lock pdm.lock requirements.lock requirements.txt.lock \
              Cargo.lock go.sum Gemfile.lock composer.lock; do
      [ -n "$(tracked "$lf")" ] && have_lock="$have_lock $lf"
    done
    [ -n "$have_lock" ] || warn "dependency manifest present but no lockfile is tracked ($need_lock) (PRE-04)" "lockfile"
  fi

  if ! git ls-files | grep -qE '^\.github/workflows/.*\.ya?ml$|^\.gitlab-ci\.yml$|^\.circleci/|^Jenkinsfile$|^azure-pipelines\.ya?ml$|^bitbucket-pipelines\.yml$'; then
    warn "no CI definition found (PRE-08)" "ci"
  fi

  if [ -z "$readme" ]; then
    warn "no README at the repository root (PRE-05)" "readme"
  elif ! grep -q '```' "$readme" 2>/dev/null; then
    warn "README has no fenced code block - check the run and test commands are there (PRE-05)" "readme-quickstart"
  fi

  if [ -f AGENTS.md ] && grep -q '<fill' AGENTS.md; then
    warn "AGENTS.md constitution still has <fill> placeholders (PRE-09)" "constitution"
  fi
  if [ -f AGENTS.md ] && [ "$(wc -l <AGENTS.md | tr -d ' ')" -gt 250 ]; then
    warn "AGENTS.md is over 250 lines - keep it short and specific (THR-27)" "agents-length"
  fi
  if [ ! -f "$PROFILE" ]; then
    warn "no .agents/profile.xml - run the PRESET stage" "profile"
  elif grep -q 'status="UNFILLED"' "$PROFILE"; then
    warn "profile.xml is UNFILLED - run the PRESET stage (skill project-setup)" "profile"
  fi

  # ---------------------------------------- triad and references (P3, P5)
  for m in $TRIAD; do
    if [ ! -f "$m" ]; then
      warn "$m is missing - the memory triad is incomplete (PRE-10)" "memory" "$m"
    elif grep -q '<fill' "$m"; then
      warn "$m still has <fill> placeholders (PRE-10)" "memory" "$m"
    fi
  done

  # Backtick paths in the triad and constitution, and relative links in tracked markdown, must
  # point to something that exists. A reference to a missing file is either stale memory
  # or a made-up (hallucinated) path.
  : >"$TMP"
  for m in $TRIAD AGENTS.md; do
    [ -f "$m" ] || continue
    tr -d '\r' <"$m" | grep -n '`[^` ]*`' | while IFS= read -r line; do
      n=${line%%:*}
      printf '%s\n' "${line#*:}" | grep -oE '`[^` ]+`' | tr -d '`' | while IFS= read -r ref; do
        case "$ref" in *'<'*|*'>'*|*'*'*|*'$'*|*'{'*|http*|-*|/*|*'|'*|*'('*|*'='*) continue ;; esac
        ref=${ref%%:*}
        case "$ref" in
          */*|*.py|*.js|*.ts|*.tsx|*.jsx|*.md|*.xml|*.json|*.yml|*.yaml|*.toml|*.sh|*.bat|*.ps1|*.go|*.rs|*.java|*.rb|*.php|*.cs|*.sql|*.html|*.css|*.cfg|*.ini) ;;
          *) continue ;;
        esac
        [ -e "$ref" ] || printf '%s:%s:%s\n' "$m" "$n" "$ref"
      done
    done
  done >>"$TMP"
  git ls-files '*.md' | grep -vE "$SELF_EXCLUDE|^\.agents/(skills|workflows|templates)/" | while IFS= read -r m; do
    d=$(dirname "$m")
    tr -d '\r' <"$m" | grep -noE '\]\([^)# ]+' | while IFS= read -r hit; do
      n=${hit%%:*}; ref=${hit#*](}
      case "$ref" in http*|mailto:*|'#'*|/*|*'<'*|*:*) continue ;; esac
      [ -e "$d/$ref" ] || printf '%s:%s:%s\n' "$m" "$n" "$ref"
    done
  done >>"$TMP"
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    warn "reference to a file that does not exist: $hit (P3, FIN-12)" "broken-ref" "${hit%%:*}"
  done <"$TMP"

  # Code changed (in the working tree or index) but no triad file changed.
  changed=$( { git diff --name-only; git diff --cached --name-only; } 2>/dev/null | sort -u)
  if printf '%s\n' "$changed" | grep -qE "$CODE_EXT" \
     && ! printf '%s\n' "$changed" | grep -qxE 'PROJECT_BRAIN\.md|FLOW\.md|DECISION\.md'; then
    if [ "$cadence" = "EVERY_TASK" ]; then
      warn "uncommitted code changes but no memory triad update (memory_cadence EVERY_TASK)" "memory-sync"
    elif [ "$MODE" = final ]; then
      note "code changed without a triad update - fine unless a milestone was reached (P5, FIN-11)"
    fi
  fi
fi

# -------------------------------------------------------- declared commands
if [ "$MODE" = final ]; then
  if [ ! -f "$PROFILE" ]; then
    warn "cannot run declared commands: .agents/profile.xml is missing" "commands"
  else
    sed -nE 's/^[[:space:]]*<command[[:space:]]+id="([^"]+)"[^>]*>(.*)<\/command>.*$/\1	\2/p' "$PROFILE" \
      | sed -e 's/<!\[CDATA\[//; s/\]\]>//' \
            -e 's/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&apos;/'"'"'/g; s/&amp;/\&/g' \
      | tr -d '\r' | awk -F'\t' '$2 ~ /[^[:space:]]/' >"$TMP"
    if [ ! -s "$TMP" ]; then
      warn "no commands declared in .agents/profile.xml <commands> - nothing was executed" "commands"
    elif [ "$RUN" -eq 0 ]; then
      say "  SKIP   declared commands (--no-run): $(cut -f1 "$TMP" | tr '\n' ' ')"
    else
      # GNU timeout (gtimeout with coreutils on macOS). Windows System32's timeout.exe is a different
      # program, so check for GNU's signature, not the name.
      tmo=""
      for t in timeout gtimeout; do
        if command -v "$t" >/dev/null 2>&1 && "$t" --version 2>/dev/null | grep -qi 'coreutils\|gnu'; then tmo=$t; break; fi
      done
      [ -n "$tmo" ] || note "no GNU timeout available - declared commands run without a time limit"
      while IFS="$(printf '\t')" read -r cid ccmd; do
        start=$(date +%s)
        if [ -n "$tmo" ]; then "$tmo" "$CMD_TIMEOUT" sh -c "$ccmd" >"$OUT" 2>&1 </dev/null
        else sh -c "$ccmd" >"$OUT" 2>&1 </dev/null; fi
        rc=$?
        secs=$(( $(date +%s) - start ))
        if [ "$rc" -eq 0 ]; then
          say "  RUN    $cid: $ccmd -> exit 0 (${secs}s)"
        elif [ -n "$tmo" ] && [ "$rc" -eq 124 ]; then
          block "declared command timed out after ${CMD_TIMEOUT}s - $cid: $ccmd" "command-$cid"
          tail -n 15 "$OUT" | sed 's/^/         | /'
        else
          block "declared command failed - $cid: $ccmd -> exit $rc (${secs}s)" "command-$cid"
          tail -n 15 "$OUT" | sed 's/^/         | /'
        fi
      done <"$TMP"
    fi
  fi
fi

# ------------------------------------------------------------ release extras
if [ "$RELEASE" -eq 1 ]; then
  git ls-files | grep -qiE '^CHANGELOG(\.[A-Za-z]+)?$' || block "no CHANGELOG before a release" "changelog"
  visibility=$(profile_value visibility)
  case "$visibility" in
    PRIVATE|INTERNAL) : ;;
    *) git ls-files | grep -qE '^(SECURITY(\.[A-Za-z]+)?|\.github/SECURITY\.md)$' \
         || block "no SECURITY policy before a release (visibility: ${visibility:-unknown})" "security-policy" ;;
  esac
  [ -n "$(git tag --list | head -1)" ] \
    || block "no tags - the released state is not identifiable" "tag"
fi

# ------------------------------------------------------------------- summary
scanned=$(list_files | wc -l | tr -d ' ')
if [ "$BLOCKERS" -gt 0 ]; then
  printf '\n%d blocker(s), %d warning(s) across %s file(s) - stopped.\n' "$BLOCKERS" "$WARNS" "$scanned"
  printf 'Fix them, or record a reviewed exception in .agents/allow\n'
  [ "$MODE" = staged ] && printf 'To bypass knowingly: git commit --no-verify (a recorded decision, never a habit)\n'
  exit 1
fi
[ "$QUIET" -eq 1 ] && [ "$WARNS" -eq 0 ] && exit 0
printf 'clean - %d warning(s) across %s file(s)\n' "$WARNS" "$scanned"
exit 0
