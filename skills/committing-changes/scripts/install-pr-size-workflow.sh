#!/bin/bash
# Install the PR-size CI workflow + .gitattributes exclusions to the current repo.
# Run from the repo root. Idempotent: skips files that are already up to date.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"

WORKFLOW_SRC="$TEMPLATES_DIR/pr-size.yml"
WORKFLOW_DST="$REPO_ROOT/.github/workflows/pr-size.yml"

GITATTR_SRC="$TEMPLATES_DIR/gitattributes.example"
GITATTR_DST="$REPO_ROOT/.gitattributes"
GITATTR_MARKER="# Mark generated/vendored files so GitHub collapses them in PR diffs"

CHANGED=0

mkdir -p "$(dirname "$WORKFLOW_DST")"
if [[ -f "$WORKFLOW_DST" ]] && diff -q "$WORKFLOW_SRC" "$WORKFLOW_DST" > /dev/null 2>&1; then
    echo "  Up to date: .github/workflows/pr-size.yml"
else
    cp "$WORKFLOW_SRC" "$WORKFLOW_DST"
    echo "  Installed: .github/workflows/pr-size.yml"
    CHANGED=1
fi

if [[ -f "$GITATTR_DST" ]] && grep -qF "$GITATTR_MARKER" "$GITATTR_DST"; then
    echo "  Up to date: .gitattributes (already contains exclusion block)"
else
    if [[ -f "$GITATTR_DST" ]] && [[ -s "$GITATTR_DST" ]]; then
        printf '\n' >> "$GITATTR_DST"
    fi
    cat "$GITATTR_SRC" >> "$GITATTR_DST"
    echo "  Appended: .gitattributes exclusion block"
    CHANGED=1
fi

if [[ $CHANGED -eq 0 ]]; then
    echo "PR-size workflow already up to date."
else
    echo "Done. Review the diff, commit, and push."
fi
