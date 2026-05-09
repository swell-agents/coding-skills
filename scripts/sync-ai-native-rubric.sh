#!/usr/bin/env bash
#
# Sync helper for the ai-native-reviewer plugin assets.
#
# Two responsibilities:
#   1. Stamp each template's first-line SHA-256 with its own current content hash,
#      so the agent can detect drift between the plugin copy and a project's
#      installed copy (R8 mechanical check).
#   2. Surface a freshness warning if the source compilation
#      (`cto-agent/compilations/ai-coding-best-practices.md`) has been edited
#      after RUBRIC.md, suggesting a manual re-summarisation may be due.
#
# Usage:
#   bash scripts/sync-ai-native-rubric.sh                 # default cto-agent path
#   CTO_AGENT_DIR=/path/to/cto-agent bash scripts/sync-ai-native-rubric.sh
#
# Exit codes: 0 always (script is informational, never blocks CI).

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL_DIR="$PLUGIN_ROOT/skills/reviewing-changes/reference/ai-native-templates"
RUBRIC="$PLUGIN_ROOT/skills/reviewing-changes/reference/ai-native-rubric.md"
CTO_AGENT_DIR="${CTO_AGENT_DIR:-$PLUGIN_ROOT/../../swell-agent/cto-agent}"
COMPILATION="$CTO_AGENT_DIR/compilations/ai-coding-best-practices.md"

#
# 1. Stamp template SHAs
#
echo "Stamping template SHA-256 first-line markers..."
for tpl in "$TPL_DIR"/*; do
  [[ -f "$tpl" ]] || continue
  # Compute SHA over the file content excluding the SHA marker line itself,
  # otherwise the SHA changes every run and stamping is unstable.
  body_sha="$(grep -v '^# ai-native-reviewer-template-sha256:' "$tpl" | shasum -a 256 | awk '{print $1}')"
  marker="# ai-native-reviewer-template-sha256: $body_sha"

  # Replace existing marker line in place; create one at the top if missing.
  if grep -q '^# ai-native-reviewer-template-sha256:' "$tpl"; then
    # Use a sed alternative since `sed -i` is not portable across BSD/GNU and the
    # plugin contributor may be on macOS. Rewrite via temp file.
    tmp="$(mktemp)"
    awk -v m="$marker" '
      /^# ai-native-reviewer-template-sha256:/ { print m; next }
      { print }
    ' "$tpl" > "$tmp"
    mv "$tmp" "$tpl"
  else
    tmp="$(mktemp)"
    {
      printf '%s\n' "$marker"
      cat "$tpl"
    } > "$tmp"
    mv "$tmp" "$tpl"
  fi

  echo "  stamped $(basename "$tpl") -> $body_sha"
done

#
# 2. Freshness check against the source compilation in cto-agent
#
echo
if [[ ! -f "$COMPILATION" ]]; then
  echo "[freshness] Source compilation not found at: $COMPILATION"
  echo "            Set CTO_AGENT_DIR=/path/to/cto-agent if it lives elsewhere."
  exit 0
fi

# Use mtime on macOS (-f) or GNU stat (-c). Try both.
mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}

comp_mtime="$(mtime "$COMPILATION")"
rubric_mtime="$(mtime "$RUBRIC")"

if (( comp_mtime > rubric_mtime )); then
  echo "[freshness] $COMPILATION is newer than $RUBRIC."
  echo "            Re-summarise the rubric manually (R1..R8 structure must be preserved)."
  echo "            Diff hint: diff <(grep -v '^>' '$COMPILATION') <(grep -v '^>' '$RUBRIC')"
else
  echo "[freshness] RUBRIC.md is up to date (mtime: $(date -r "$rubric_mtime" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "$rubric_mtime"))."
fi
