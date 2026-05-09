#!/usr/bin/env bash
#
# Stamp each ai-native-reviewer template's first-line SHA-256 with its own
# current content hash, so the agent (R8) can detect drift between the plugin
# copy and a project's installed copy.
#
# Run after editing any template under
# skills/reviewing-changes/reference/ai-native-templates/.
#
# Usage:
#   bash scripts/sync-ai-native-rubric.sh
#
# Exit code: 0 always.

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL_DIR="$PLUGIN_ROOT/skills/reviewing-changes/reference/ai-native-templates"

echo "Stamping template SHA-256 first-line markers..."
for tpl in "$TPL_DIR"/*; do
  [[ -f "$tpl" ]] || continue
  # Compute SHA over file content excluding the SHA marker line itself,
  # otherwise the SHA changes every run and stamping is unstable.
  body_sha="$(grep -v '^# ai-native-reviewer-template-sha256:' "$tpl" | shasum -a 256 | awk '{print $1}')"
  marker="# ai-native-reviewer-template-sha256: $body_sha"

  if grep -q '^# ai-native-reviewer-template-sha256:' "$tpl"; then
    # Portable in-place rewrite (avoids `sed -i` BSD/GNU split).
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
