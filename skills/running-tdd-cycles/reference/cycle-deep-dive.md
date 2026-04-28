---
purpose: Full 12-phase TDD pipeline with coverage thresholds and metrics
---

# Full TDD pipeline

The canonical `SKILL.md` describes the 5-phase loop most teams actually run. This document keeps the longer 12-phase pipeline from the original `tdd-cycle` slash-command for projects that want stricter governance (regulated environments, training settings, very large refactors).

## Configuration

### Coverage thresholds

- Minimum line coverage: 80%.
- Minimum branch coverage: 75%.
- Critical path coverage: 100%.

### Refactoring triggers

- Cyclomatic complexity > 10.
- Method length > 20 lines.
- Class length > 200 lines.
- Duplicate code blocks > 3 lines.

## Phase 1 — Specification and design

1. **Requirements analysis.** Define acceptance criteria, identify edge cases, build a test scenario matrix. Ensure every requirement maps to a test scenario.
2. **Test architecture.** Design fixtures, mocks, and test data strategy so tests are isolated, fast, and reliable.

## Phase 2 — RED

3. **Write failing unit tests.** One per requirement. Cover happy path + planned edge cases. No production code yet.
4. **Verify failure.** Each test must fail for the right reason (missing implementation, not test errors). No false positives. **Gate:** do not proceed unless every test fails appropriately.

## Phase 3 — GREEN

5. **Minimal implementation.** Smallest code change that turns red to green. No bonus features, no premature optimisation.
6. **Verify success.** All tests pass. Coverage meets thresholds. No previously-green test broke. **Gate:** all green before moving to refactor.

## Phase 4 — REFACTOR

7. **Code refactor.** Apply SOLID. Remove duplication. Improve names. Optimise where measured. Tests stay green every step.
8. **Test refactor.** Extract common fixtures. Tighten test names. Eliminate test duplication. Coverage stays equal or improves.

## Phase 5 — Integration

9. **Failing integration tests.** Test component interactions, API contracts, data flow. Fail first.
10. **Implement integration.** Make integration tests pass.

## Phase 6 — Continuous improvement

11. **Performance + edge cases.** Stress tests, boundary tests, error recovery tests.
12. **Final review.** Verify TDD discipline was kept. Code quality, test quality, coverage. Implement critical suggestions while keeping tests green.

## Modes

- **Incremental.** One test at a time, end-to-end (RED → GREEN → REFACTOR), then next test. Default.
- **Suite.** All tests for a feature first (failing), then implementation (passing), then refactor. Reserved for very small features where the test suite is genuinely cohesive.

## Validation checkpoints

### RED

- All tests written before implementation.
- All tests fail with meaningful messages.
- Failures are due to missing implementation, not setup errors.
- No test passes accidentally.

### GREEN

- All tests pass.
- No code beyond what tests require.
- Coverage meets thresholds.
- No test was modified to make it pass.

### REFACTOR

- All tests still pass.
- Code complexity reduced.
- Duplication eliminated.
- Performance improved or at least preserved.
- Test readability improved.

## Metrics

- Time in each phase (RED / GREEN / REFACTOR).
- Test-implementation cycle count.
- Coverage progression over time.
- Refactoring frequency.
- Defect escape rate (bugs found post-merge that the test suite missed).

## Failure recovery

If discipline breaks:

1. Stop.
2. Identify which phase was violated.
3. Roll back to the last valid state.
4. Resume from the correct phase.
5. Document the lesson.

## Anti-patterns

- Implementation before tests.
- Tests that already pass.
- Skipping refactor.
- Many features without tests.
- Modifying tests to make them pass.
- Ignoring failing tests.
- "I'll add the tests after."
