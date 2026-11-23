#!/usr/bin/env bash
# Re-sync the unmodified Matt Pocock skills from a checkout of mattpocock/skills.
# Usage: sh tools/sync-matt-skills.sh ..        (inside the skills repo layout: preset/ next to skills/)
#        sh tools/sync-matt-skills.sh /path/to/mattpocock-skills-checkout
set -euo pipefail
UP=${1:?usage: sync-matt-skills.sh <path to mattpocock/skills checkout>}
HERE=$(cd "$(dirname "$0")/.." && pwd)
DEST="$HERE/payload/.agents/skills"
MANIFEST="$UP/.claude-plugin/plugin.json"
[ -f "$MANIFEST" ] || { echo "not a mattpocock/skills checkout: $MANIFEST missing" >&2; exit 2; }

# The promoted set is exactly the plugin manifest's "skills" array.
NAMES=$(python3 -I -c 'import json,sys; [print(p.rsplit("/",1)[1]) for p in json.load(open(sys.argv[1]))["skills"]]' "$MANIFEST")

new=0; changed=0
for n in $NAMES; do
  src=""
  for b in engineering productivity; do [ -d "$UP/skills/$b/$n" ] && src="$UP/skills/$b/$n"; done
  [ -n "$src" ] || { echo "missing upstream folder for $n" >&2; exit 2; }
  if [ -d "$DEST/$n" ]; then
    diff -rq "$src" "$DEST/$n" >/dev/null 2>&1 || { changed=$((changed + 1)); echo "  update $n"; }
    rm -rf "$DEST/$n"
  else
    new=$((new + 1)); echo "  new    $n"
  fi
  cp -r "$src" "$DEST/$n"
done

# VENDORED = every vendored skill a lean install may drop. code-review stays out: the final check needs a review skill.
OTHER=$(grep -vxF -e "$(printf '%s\n' $NAMES)" "$DEST/VENDORED" || true)
{ printf '%s\n' $NAMES | grep -vx code-review; printf '%s\n' $OTHER; } | grep -v '^$' | sort -u > "$DEST/VENDORED.tmp"
mv "$DEST/VENDORED.tmp" "$DEST/VENDORED"
echo "synced: $new new, $changed changed. upstream commit: $(git -C "$UP" rev-parse HEAD 2>/dev/null || echo unknown)"
echo "now update UPSTREAM.md (pinned commit), THIRD_PARTY.md, the PROJECT.xml skill catalogue and counts."
