#!/bin/bash
# Install git hooks to the current repo's git dir.
# Works from any directory: root repo, submodule, or worktree.
# Idempotent: skips hooks that are already up to date.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

mkdir -p "$HOOKS_DIR"

CHANGED=0

for HOOK in pre-push commit-msg; do
    if [[ -f "$HOOKS_DIR/$HOOK" ]] && diff -q "$SCRIPT_DIR/$HOOK" "$HOOKS_DIR/$HOOK" > /dev/null 2>&1; then
        continue
    fi
    cp "$SCRIPT_DIR/$HOOK" "$HOOKS_DIR/$HOOK"
    chmod +x "$HOOKS_DIR/$HOOK"
    echo "  Installed: $HOOK"
    CHANGED=1
done

if [[ $CHANGED -eq 0 ]]; then
    echo "Git hooks already up to date."
else
    echo "Done. Git hooks installed successfully."
fi
