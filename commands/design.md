---
description: Design technical architecture for the feature, library selection, or schema in $ARGUMENTS before implementation. Wraps the designing-architecture skill — researches the ecosystem under a bounded budget (≤3 candidates per decision, ≤5 web fetches per session), evaluates on stars/recency/license/dep-footprint/docs quality, and emits a TDD-ready implementation plan with components, data flow, and an ASCII diagram.
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch, Bash(git ls-files), Bash(git log *)
---

Scope: $ARGUMENTS

Invoke the `designing-architecture` skill on the design question above. The skill is the single source of truth for the research budget, the candidate-comparison rubric, and the output shape (components, data flow, ASCII diagram, hand-off plan).

Read-only — this command never edits the diff or implements. The output is a plan that hands off to `running-tdd-cycles` (or `/coding-skills:tdd`) for execution.

Compose with the language-conventions skill that matches the target stack (`python-conventions`, `go-conventions`, `solidity-conventions`) and `engineering-philosophy`.
