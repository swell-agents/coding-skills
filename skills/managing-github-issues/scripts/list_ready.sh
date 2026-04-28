#!/usr/bin/env bash
# List open issues with the `ready` label, including assignee info.

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
    echo "ERROR: 'gh' (GitHub CLI) is required." >&2
    exit 1
fi

gh issue list \
    --label ready \
    --state open \
    --json number,title,assignees,labels \
    --template '{{range .}}#{{.number}} {{.title}} — {{if .assignees}}assigned to {{range .assignees}}@{{.login}} {{end}}{{else}}unassigned{{end}}{{"\n"}}{{end}}'
