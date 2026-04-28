---
purpose: ASCII conventions for the dependency graphs emitted by plan and status modes
---

# Dependency graph rendering

The plan and status outputs include a small ASCII graph showing which tasks are ready, blocked, in progress, or done, and how they depend on each other. Keep the conventions consistent across modes so a reader can scan one graph against another over time.

## Node format

```
#<N> <state>
```

`<N>` is the GitHub issue number when one exists; otherwise `Task <N>` for plan-mode preview before issues are created. `<state>` is one of:

| State | Glyph | Notes |
|---|---|---|
| done | `✓` or `done` | Issue closed. |
| in-progress | `…` or `in-progress` | `in-progress` label, may have an open PR. |
| ready | `ready` | `ready` label, no assignee. |
| ready (assigned) | `@user` | `ready` (or `in-progress`) and assigned. |
| blocked | `blocked` | `blocked` label. Show blockers in parens if it fits. |

In ASCII output prefer the bare word over the glyph for grep-ability; reserve glyphs for the status dashboard.

## Edges

- Right-arrow for "blocks": `──>` or `-->` — read as "the left node must finish before the right starts."
- Branching uses `┬─`, `├─`, `└─`. Plain ASCII is fine if the graph is small.

## Layout

- Order top-to-bottom by topological sort. Roots (no blockers) at the top.
- Group siblings with the same blockers under a single fan-out.
- Wrap at ~80 columns; if the graph won't fit, split by feature area.

## Examples

**Plan mode (no issue numbers yet):**

```
Task 1 (ready) ──┬──> Task 4 (blocked by 1, 2, 3)
Task 2 (ready) ──┤
Task 3 (ready) ──┘
                       └──> Task 5 (blocked by 4)
```

**Status mode (issues exist):**

```
#10 done   ──┬──> #12 ready ──> #13 blocked
#11 done   ──┘
#14 in-progress ──> #15 ready
```

**Done state in the middle of a graph:**

```
#10 done ──> #12 done ──> #13 in-progress ──> #14 blocked
                              ↑
                              └── #15 ready (parallel branch joins here)
```

## When to omit the graph

- Single root node, no branches → just list the tasks; the graph adds no information.
- Total tasks ≤ 3 → list is enough.
- Graph would wrap past ~30 lines → split it by sub-feature, or render only the *current frontier* (in-progress + immediate dependents) in status mode.

## How to generate

For plan mode, render from the `Blocked by:` / `Unblocks:` lines directly.

For status mode, build the graph in memory:

```bash
# pseudocode
for issue in $(gh issue list --label "ready,blocked,in-progress,epic" --json number); do
    body=$(gh issue view "$issue" --json body --jq '.body')
    blockers=$(echo "$body" | grep -i 'Blocked by' | grep -oE '#[0-9]+')
    state=$(label_for_issue "$issue")
    add_node "$issue" "$state" "$blockers"
done
render_graph
```

Keep this loop in a project-side helper rather than baking it into a skill script — graph rendering style varies enough that one shared implementation tends to please nobody.
