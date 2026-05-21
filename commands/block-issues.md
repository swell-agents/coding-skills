---
description: Create one "Implement Block X" GitHub issue per Spec Kit tasks.md PR-stack block, with a minimal body pointing at tasks.md as the source of truth.
allowed-tools: Read, Glob, Grep, Bash(gh issue *), Bash(gh repo view *), Bash(gh label *), Bash(git rev-parse *), Bash(git config --get *), Bash(cat *), Bash(ls *)
---

Scope: $ARGUMENTS

Invoke the `creating-block-issues` skill. `$ARGUMENTS` is one of:

- **Empty** → use the active Spec Kit feature from `.specify/feature.json`.
- **`<feature-dir>`** (e.g. `001-uptime-settlement`) → override active-feature resolution.
- **`--dry-run`** → parse tasks.md and render the would-be issue bodies without calling `gh`. Echoes the parsed block list, dependency graph, and the resolved dispatch label.
- **`--label <name>`** → override the default dispatch label name.
- **`--no-label`** → create issues bare (no dispatch label attached).

The skill creates one issue per `#### Block <X> — <name>` heading in `specs/<feature>/tasks.md` (minimal 3-bullet body, no epic), attaches the dispatch label `swa-impl-block` to each (auto-creating it in the target repo if missing, color `#0E8A16`), and surfaces a copy-pasteable "Blocked by" instruction block for the user to set GitHub-native Issue Dependencies via the right sidebar.

The dispatch label is the signal a downstream coder-agent daemon polls for. Additional project-specific labels (`ready`, priority, milestone) are NOT applied by this command — add them after with `gh issue edit <N> --add-label <name>` or via the UI.

Echo the resolved `<owner>/<repo>` back before any state-changing `gh` call. Never create issues in a repo whose `origin` URL was not just echoed.

Counterpart: [`/coding-skills:block-implement`](block-implement.md) implements one Block end-to-end (TDD + review + draft PR + CI fix loop) from the issues this command creates.
