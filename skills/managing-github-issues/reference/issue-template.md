---
purpose: Issue body template — user story, acceptance criteria, dependencies, out-of-scope
---

# Issue body template

Use this exact structure for every task issue. The labels and the dependency-graph rendering depend on the `Blocked by` / `Unblocks` lines being parseable.

```markdown
## User story

As a [actor], I want [behaviour] so that [outcome].

## Acceptance criteria

- [ ] Given [context], when [action], then [result].
- [ ] Given [context], when [action], then [result].

## TDD focus

Failing test pins down: <one short sentence describing the behaviour the first failing test verifies>.

## Dependencies

- Blocked by: #X, #Y    (or "None")
- Unblocks: #Z          (or "None")

## Out of scope

- <explicit non-goal>
- <explicit non-goal>

## Notes

(Optional — links to design doc, related issues, prior art.)
```

## Why each section earns its place

- **User story** — anchors the task in user value, not implementation. Catches "this is just refactoring, no user impact" early — when that's true the task is a different kind, not a feature task.
- **Acceptance criteria** — testable assertions. Each criterion should be expressible as one or two failing tests. If a criterion can't be made testable, sharpen it until it can.
- **TDD focus** — pre-commits the first failing test. Forces you to think test-first before opening the issue.
- **Dependencies** — `Blocked by:` / `Unblocks:` are parsed by `check_blockers.sh` and by the dependency-graph renderer. Keep the format exact.
- **Out of scope** — prevents scope creep. The reviewer can reject "but it should also do X" with "X is in #other-issue."
- **Notes** — anything else. Optional.

## Epic body template

```markdown
## Summary

<2-3 sentence description of the feature and the user value.>

## Architecture

<Link to or paste the architecture doc from designing-architecture.>

## Tasks

- [ ] #N <task title>
- [ ] #M <task title>
- [ ] ...

## Out of scope

- <explicit non-goal at the feature level>

## Notes

(Optional — milestone, release tag, links.)
```

The `## Tasks` checklist is updated as task issues close (via the `advance` mode in the parent skill). The order should match dependency order — earliest-unblocked first.
