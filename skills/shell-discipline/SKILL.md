---
name: shell-discipline
description: Shell discipline — one command per call, no inline env vars, gh auth login.
---

## Shell Commands

- **One command per call** — keep commands small, readable, and atomic. Don't chain with `&&`, `;`, or `cd dir && command`. Use separate calls — first `cd`, then the command.
- **No inline env vars** — don't use `VAR=value command`. Set env separately or use proper auth tools.

## Git Auth

- Use `gh auth login` / `gh auth switch` to switch GitHub accounts — never prefix with `GH_TOKEN=...`.

## Why

Each chained command is one opaque action to the permission layer; splitting them gives one auditable tool call per intent. Inline env vars hide configuration in the command line and leak secrets into shell history; explicit auth tools (`gh auth login`) keep credentials in the keyring where they belong.

## Prerequisites

- A POSIX shell (bash or zsh).
- For the Git Auth rule: `gh` CLI installed and authenticated.

## Failure modes

- **`gh auth login` fails or token expired.** Re-run `gh auth login -h github.com` interactively, then `gh auth status` to verify. Don't paste the token into a shell command.
- **Account switch needed.** `gh auth switch -u <user>`. If that user's token is invalid, re-auth that account before switching.
- **Command needs elevated privileges.** Set up the privilege out-of-band (sudoers entry, group membership) rather than prefixing the command with `sudo` inline; an unattended agent shouldn't be entering passwords.
- **Shell aliases that hide what runs.** Avoid invoking aliases in agent procedures; spell out the real command so it's auditable.
