#!/usr/bin/env bash
# Given an issue number, parses "Blocked by: #X, #Y" from the body and
# reports whether all blockers are closed (so the issue can be unblocked).
#
# Usage: check_blockers.sh <issue-number>
#
# Exit codes:
#   0 — all blockers closed (issue is ready to unblock)
#   1 — some blockers still open
#   2 — no blockers found in body
#   3 — invocation error

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <issue-number>" >&2
    exit 3
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: 'gh' (GitHub CLI) is required." >&2
    exit 3
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: 'jq' is required." >&2
    exit 3
fi

issue="$1"

body="$(gh issue view "$issue" --json body --jq '.body')"

# Extract numbers after "Blocked by:" up to the next newline.
blockers="$(echo "$body" | grep -iE '^[[:space:]-]*\*?\*?Blocked by:?\*?\*?' | head -1 | grep -oE '#[0-9]+' | tr -d '#' | sort -u || true)"

if [[ -z "$blockers" ]]; then
    echo "No 'Blocked by:' line found in #$issue."
    exit 2
fi

echo "Issue #$issue blockers:"
all_closed=1
for b in $blockers; do
    state="$(gh issue view "$b" --json state --jq '.state' 2>/dev/null || echo "UNKNOWN")"
    case "$state" in
        CLOSED) printf "  #%s  CLOSED\n" "$b" ;;
        OPEN)   printf "  #%s  OPEN\n" "$b"; all_closed=0 ;;
        *)      printf "  #%s  %s\n" "$b" "$state"; all_closed=0 ;;
    esac
done

if [[ $all_closed -eq 1 ]]; then
    echo
    echo "All blockers closed. #$issue is ready to unblock:"
    echo "  gh issue edit $issue --remove-label blocked --add-label ready"
    exit 0
else
    echo
    echo "#$issue still has open blockers."
    exit 1
fi
