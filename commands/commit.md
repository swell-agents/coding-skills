---
description: Commit work with feature-branch + PR discipline. Wraps the committing-changes skill — installs commit-msg/pre-commit/pre-push hooks if missing, branches off main if on a protected branch, runs the project's lint/format/test, generates a conformant commit message, pushes, and opens a PR via gh pr create.
allowed-tools: Bash(git *), Bash(gh pr *), Bash(gh auth status), Read
---

Scope: $ARGUMENTS

Invoke the `committing-changes` skill. If `$ARGUMENTS` is provided, treat it as the intended commit message or scope hint; otherwise let the skill infer the message from the staged diff.

The skill is the single source of truth for:

- Commit-message rules (capital start, ≤72 chars, no trailing period, no Co-Authored-By, one logical change per commit).
- Branch protection (never push to main, never force-push, never merge a PR on the user's behalf).
- Hook installation (commit-msg + pre-commit + pre-push) and the optional PR-size CI gate.

Echo any state-changing `git` or `gh` command back to the user before running it.
