---
description: Drive a full red-green-refactor TDD cycle for the requirement in $ARGUMENTS. Wraps the running-tdd-cycles skill — writes a failing test first, makes it pass with minimal code, then refactors with the test as a safety net. Supports Python (pytest), JS/TS (Jest/Vitest), Go (testing/T), Java (JUnit), Ruby (RSpec), Rust (cargo test), Solidity (forge).
allowed-tools: Read, Edit, Write, Glob, Grep, Bash(uv *), Bash(npm *), Bash(pnpm *), Bash(yarn *), Bash(go test *), Bash(go build *), Bash(forge test *), Bash(forge build *), Bash(cargo test *), Bash(pytest *), Bash(git status *), Bash(git diff *)
---

Scope: $ARGUMENTS

Invoke the `running-tdd-cycles` skill on the requirement above. The skill is the single source of truth for the red-green-refactor procedure, the fails-for-the-right-reason verification, and the refactor-only-when-green gating.

If `$ARGUMENTS` names a phase explicitly (`red`, `green`, `refactor`), run only that phase. Otherwise drive the full cycle.

Compose with the language-conventions skill that matches the touched files (`python-conventions`, `go-conventions`, `solidity-conventions`) and `engineering-philosophy`.
