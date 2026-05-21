---
description: Create one "Implement Block X" GitHub issue per Spec Kit tasks.md PR-stack block, with a minimal body pointing at tasks.md as the source of truth.
allowed-tools: Read, Glob, Grep, Bash(gh issue *), Bash(gh repo view *), Bash(gh label *), Bash(git rev-parse *), Bash(git config --get *), Bash(cat *), Bash(ls *)
---

Scope: $ARGUMENTS

Invoke the `creating-block-issues` skill. Two modes:

**Mode 1 — all-blocks (default):** creates one issue per `#### Block <X>` heading in `tasks.md`. `$ARGUMENTS`:

- **Empty** → use the active Spec Kit feature from `.specify/feature.json`.
- **`<feature-dir>`** (e.g. `001-uptime-settlement`) → override active-feature resolution.
- **`--dry-run`** → parse tasks.md and render the would-be issue bodies without calling `gh`. Echoes the parsed block list, dependency graph, and resolved dispatch label.
- **`--label <name>`** → override the default dispatch label name.
- **`--no-label`** → create issues bare (no dispatch label attached).

**Mode 2 — subset (single issue, custom scope):** creates exactly one issue covering an arbitrary task subset (partial-block, cross-block, or cross-phase). Triggered by `--tasks`. Required args:

- **`--tasks <ids>`** → comma list with range support: `T008,T025-T027,T048`. Validated against tasks.md.
- **`--title <text>`** → issue title. Convention: `Implement Block <X> (<subset name>) — <description>`.

Optional in Mode 2: `--notes <text>`, plus the same `--dry-run` / `--label` / `--no-label` flags as Mode 1.

The skill attaches the dispatch label `swa-impl-block` to every issue it creates (auto-creating the label in the target repo if missing, color `#0E8A16`), and (Mode 1 only) surfaces a copy-pasteable "Blocked by" instruction block for the user to set GitHub-native Issue Dependencies via the right sidebar.

The dispatch label is the signal a downstream coder-agent daemon polls for. Additional project-specific labels (`ready`, priority, milestone) are NOT applied by this command — add them after with `gh issue edit <N> --add-label <name>` or via the UI.

Echo the resolved `<owner>/<repo>` back before any state-changing `gh` call. Never create issues in a repo whose `origin` URL was not just echoed.

Counterpart: [`/coding-skills:block-implement`](block-implement.md) implements one Block end-to-end (TDD + review + draft PR + CI fix loop) from the issues this command creates.
