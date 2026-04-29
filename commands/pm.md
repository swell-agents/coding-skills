---
description: Drive spec-driven project management via GitHub Issues. Wraps the managing-github-issues skill — decomposes a feature into dependency-linked task issues, picks up the next ready task, closes a batch when done, or shows a status dashboard depending on $ARGUMENTS.
allowed-tools: Bash(gh issue *), Bash(gh label *), Bash(gh pr *), Bash(git checkout -b *), Bash(git status *), Read
---

Scope: $ARGUMENTS

Invoke the `managing-github-issues` skill. Interpret `$ARGUMENTS` as one of:

- `plan <feature>` — decompose the feature into dependency-linked task issues.
- `start <number>` — pick up an issue and start the task.
- `next` — show ready (unblocked) issues.
- `advance` — close completed tasks and unblock downstream work.
- `status` — print the project dashboard.
- `create-issues` — batch-create issues from a plan file.

If `$ARGUMENTS` is empty, default to `next`.

The skill is the single source of truth for label conventions (`ready` / `blocked` / `epic` / `in-progress`), the "Blocked by: #N" linking convention, and the read-vs-write tool boundary (no force-push, no `gh repo` deletions, never merge a PR on the user's behalf).

Echo any state-changing `gh` command back to the user before running it.
