---
name: shell-discipline
description: Apply shell-command discipline for agent invocations — one command per call (no &&, ;, or inline cd dir && cmd chains), no inline env vars (VAR=value cmd), and gh auth login or gh auth switch for GitHub auth (never prefix with GH_TOKEN=...). Use when invoking Bash commands as part of an agent workflow, writing shell snippets in a procedure, or reviewing how an agent issues shell commands. Improves readability, atomicity, and permission auditability since each command becomes one auditable tool call instead of an opaque chain. Composes with every workflow skill that issues shell commands.
allowed-tools:
---

## Shell Commands

- **One command per call** — keep commands small, readable, and atomic. Don't chain with `&&`, `;`, or `cd dir && command`. Use separate calls — first `cd`, then the command.
- **No inline env vars** — don't use `VAR=value command`. Set env separately or use proper auth tools.

## Git Auth

- Use `gh auth login` / `gh auth switch` to switch GitHub accounts — never prefix with `GH_TOKEN=...`.

## Why

Each chained command is one opaque action to the permission layer; splitting them gives one auditable tool call per intent. Inline env vars hide configuration in the command line and leak secrets into shell history; explicit auth tools (`gh auth login`) keep credentials in the keyring where they belong.
