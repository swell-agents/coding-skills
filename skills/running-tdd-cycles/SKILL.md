---
name: running-tdd-cycles
description: Drive strict red-green-refactor TDD discipline for any code change. Use when a user requests test-driven development, asks to write a failing test first, wants to add a feature one requirement at a time, or invokes a phase like red, green, or refactor. Coordinates failing-test generation, minimal implementation, and refactor-with-safety-net for Python (pytest), JS/TS (Jest/Vitest), Go (testing/T), Java (JUnit), Ruby (RSpec), Rust (cargo test), and Solidity (forge). Enforces test-first ordering, fails-for-the-right-reason verification, and refactor-only-when-green gating. Composes with python-conventions, go-conventions, solidity-conventions, and engineering-philosophy.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(pytest *), Bash(uv run pytest *), Bash(npm test *), Bash(npm run test *), Bash(npx vitest *), Bash(npx jest *), Bash(go test *), Bash(cargo test *), Bash(rspec *), Bash(mvn test *), Bash(gradle test *), Bash(forge test *), Bash(forge coverage *), Bash(git status *), Bash(git diff *), Bash(git add *), Bash(git commit *)
---

## Loop

For each new piece of behaviour:

```
1. Extract <requirement> — the smallest piece of logic that adds value.
2. RED      → write ONE failing test that pins down <requirement>.
3. GREEN    → write the minimal code that makes it pass.
4. REFACTOR → improve structure with the test as a safety net.
5. COMMIT   → one logical change per commit (defer to committing-changes).
6. Repeat 2–5 until the task is done.
7. REVIEW   → defer to reviewing-changes for the final pass.
```

Always one requirement per cycle. If the cycle feels big, the requirement was too big — split it.

## RED — write a failing test

- **One test, one requirement.** Don't write a test suite up front; one test, fail, pass, refactor, next.
- **Arrange-Act-Assert.** Three blocks, one assertion focus. Use `should_X_when_Y` naming where the framework allows it.
- **Fail for the right reason.** Run the test before writing implementation. The failure message must point at *missing behaviour*, not at a typo, missing import, or fixture mistake. If it doesn't, the test is wrong.
- **No premature edge cases.** Cover the happy path first. Edge cases (`null`, empty collections, boundary values, concurrent access, errors) get their own RED-GREEN-REFACTOR cycles.
- **Property-based when applicable.** Prefer `hypothesis` (Python), `fast-check` (JS/TS), or `quickcheck` (Haskell/Rust) for invariants. Example-based tests are for specific edge cases or documentation. See `reference/property-based-testing.md`.
- **Reuse strategies.** Before writing a generator, check `tests/strategies.py` (or the project equivalent) for shared fixtures/strategies. Add new ones back to the shared module.

### Framework cues

- **Python (pytest)** — fixtures with explicit scopes, `pytest.mark.parametrize` for multiple cases, `hypothesis` for properties.
- **JS/TS (Vitest/Jest)** — `vi.fn()` / `jest.fn()` mocks; `@testing-library/*` for components; `fast-check` for properties.
- **Go** — table-driven tests with subtests via `t.Run(name, func(t *testing.T) {...})`; `t.Parallel()` where safe.
- **Ruby (RSpec)** — `let` for lazy fixtures, `let!` for eager; nested `context` for branching scenarios.
- **Solidity (Foundry)** — `forge test -vvv`; parametric fuzz tests via `function testFoo(uint256 x)`; `bound(x, min, max)` not `if`-guards. See solidity-conventions.

## GREEN — minimal code to pass

- **Smallest possible change.** Hard-coded returns are fine for the first cycle. Triangulate (generalise) only when a second test forces it.
- **No bonus features.** Don't add error handling, logging, optimisation, or generality unless a test demands it. The next cycle will.
- **Don't modify the test.** If the test is wrong, go back to RED. If the test is right and the implementation is wrong, fix the implementation.
- **Run the full test suite after each change.** Confirm green; confirm no regression.

## REFACTOR — improve structure

- **Tests stay green throughout.** Run the suite after every micro-step.
- **Code smells to act on:** duplication (extract method/class), long methods (decompose), large classes (split SRP), long parameter lists (parameter object), feature envy (move method), primitive obsession (value object), switch statements driven by type (polymorphism), dead code (delete).
- **SOLID weights.** Single Responsibility first; the others when they pull their weight. See engineering-philosophy.
- **Tests refactor too.** Extract common fixtures, rename for clarity, eliminate test duplication. Coverage stays equal or improves.
- **Performance refactors are measured.** Profile before, profile after; commit the measurement alongside the change.
- **Refactoring is not optional.** If you skip it, technical debt compounds and the next RED gets harder to write.

## Anti-patterns

- Writing implementation before the test.
- Writing a test that already passes.
- Writing many tests at once and implementing them in a batch.
- Modifying a test to make it pass.
- Skipping refactor because "the test passed."
- Adding tests during the GREEN phase.
- Test-after rationalised as TDD.

If the discipline breaks: stop, identify the violated phase, revert to the last green state, resume from the right phase, note what went wrong.

## Validation checkpoints

**End of RED:** test exists, test fails, failure message names the missing behaviour, no false positive.

**End of GREEN:** all tests pass, the change is the minimum that could possibly work, the test wasn't modified, coverage didn't drop.

**End of REFACTOR:** all tests still pass, complexity (cyclomatic, length) at least no worse, duplication addressed, names readable, performance measured if performance was the goal.

## Scratch testing

Quick exploration belongs in a gitignored scratch file, not in production code or in the test suite:

- Python → `test.py` (see python-conventions and `reference/scratch-testing.md`).
- Go → `test.go` with `//go:build scratch` tag (see go-conventions).
- Solidity → `script/Scratch.s.sol` or `chisel` REPL (see solidity-conventions).

Never use inline heredocs (`uv run python << EOF`, `go run -`, `forge script --via-stdin`) — the file pattern keeps history and stays inspectable.

## Cross-references

- `committing-changes` — commit after every successful GREEN or REFACTOR phase.
- `reviewing-changes` — final pass after the loop ends.
- `python-conventions` / `go-conventions` / `solidity-conventions` — language-specific test runner setup.
- `engineering-philosophy` — Small Steps, Investigate-Don't-Mask, KISS, YAGNI all apply directly.

## Reference

- [reference/cycle-deep-dive.md](reference/cycle-deep-dive.md) — full 12-phase pipeline with coverage thresholds and metrics.
- [reference/tdd-orchestrator-agent.md](reference/tdd-orchestrator-agent.md) — original Claude-Code orchestrator agent verbatim (model: opus).
- [reference/test-automator-agent.md](reference/test-automator-agent.md) — original Claude-Code test-automator agent verbatim (model: sonnet).
- [reference/property-based-testing.md](reference/property-based-testing.md) — Hypothesis, fast-check, QuickCheck patterns.
- [reference/scratch-testing.md](reference/scratch-testing.md) — language-specific scratch-file patterns.
- [reference/tdd-workflow-rule.md](reference/tdd-workflow-rule.md) — original `rules/tdd-workflow.md` verbatim.
