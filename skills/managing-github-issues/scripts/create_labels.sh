#!/usr/bin/env bash
# Idempotent label provisioning for managing-github-issues.
# Safe to run repeatedly; --force updates colour/description if drifted.

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: 'gh' (GitHub CLI) is required." >&2
    exit 1
fi

gh label create ready       --color "0E8A16" --description "No blockers, can be picked up"   --force
gh label create blocked     --color "D93F0B" --description "Waiting on other issues"         --force
gh label create in-progress --color "FBCA04" --description "Claimed; work in progress"       --force
gh label create epic        --color "1D76DB" --description "Epic / feature group"            --force

echo "Labels provisioned: ready, blocked, in-progress, epic."
