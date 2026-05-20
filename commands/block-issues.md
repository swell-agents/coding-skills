---
description: Create one "Implement Block X" GitHub issue per Spec Kit tasks.md PR-stack block. Follows the swell-wrapper coder-agent workflow convention.
allowed-tools: Read, Glob, Grep, Bash(gh issue *), Bash(gh label *), Bash(gh repo view *), Bash(git rev-parse *), Bash(git config --get *), Bash(cat *), Bash(ls *)
---

Scope: $ARGUMENTS

Invoke the `creating-block-issues` skill. `$ARGUMENTS` is one of:

- **Empty** → use the active Spec Kit feature from `.specify/feature.json`.
- **`<feature-dir>`** (e.g. `001-uptime-settlement`) → override active-feature resolution.
- **`--dry-run`** → parse tasks.md and render the would-be issue bodies without calling `gh`. Always echoes the parsed block list + dependency graph in dry-run mode.

The skill creates one issue per `#### Block <X> — <name>` heading in `specs/<feature>/tasks.md`, applies labels `ready` + `swa-impl-block`, and surfaces a copy-pasteable "Blocked by" instruction block for the user to set GitHub-native Issue Dependencies via the right sidebar.

Echo the resolved `<owner>/<repo>` back before any state-changing `gh` call. Never create issues in a repo whose `origin` URL was not just echoed.

Counterpart: [`/coding-skills:block-implement`](block-implement.md) implements one Block end-to-end (TDD + review + draft PR + CI fix loop) from the issues this command creates.
