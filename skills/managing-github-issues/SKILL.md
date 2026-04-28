---
name: managing-github-issues
description: Drive spec-driven project management via GitHub Issues — decompose a feature into dependency-linked task issues, label them ready / blocked / epic / in-progress, track progress, and unblock downstream tasks as upstream ones close. Use when planning a new feature with multiple tasks, creating issues from a plan, picking up a ready task, checking what's available to work on, closing a batch and needing to update dependent state, or asking for project status. Each task is sized for one TDD cycle (red-green-refactor) and links to its blockers via "Blocked by: #N" lines in the body. Composes with designing-architecture (which produces the plan), running-tdd-cycles (which executes one task), and committing-changes (which closes a task with a PR).
allowed-tools: Read, Write, Edit, Bash(gh issue *), Bash(gh label *), Bash(gh repo view *), Bash(gh pr *), Bash(git checkout *), Bash(git branch *), Bash(git status *), Bash(bash scripts/*)
---

## Activation modes

This skill covers six related activations. Pick the one that matches the user's intent.

| Mode | Trigger | Output |
|---|---|---|
| **plan** | "decompose this feature into tasks" | task list with dependencies + dependency graph |
| **create-issues** | "create GitHub issues from the plan" | epic + task issues with labels and `Blocked by` links |
| **next** | "what's ready to work on?" | list of ready tasks (and parallelisable subsets) |
| **start** | "start working on #N" | claim issue, create branch, kick off TDD |
| **advance** | "we just closed #M and #N" | unblock dependents, update epic checklist |
| **status** | "what's the project state?" | dashboard with progress bar and graph |

## Plan mode

The user has a feature; this skill produces a numbered task list ready for issue creation. Always delegate the architecture portion to `designing-architecture` before decomposing — the architecture defines the *how*, this skill defines the *what* and *when*.

For each task, emit:

```
### Task N: <title>

**User story.** As a [actor], I want [behaviour] so that [outcome].

**Acceptance criteria.**
- [ ] Given [context], when [action], then [result].
- [ ] ...

**Dependencies.**
- Blocked by: [task numbers] or "None".
- Unblocks: [task numbers] or "None".

**TDD focus.** What the failing test should verify.

**Effort.** XS / S / M / L.

**Out of scope.** What this task explicitly does NOT cover.
```

Then a dependency graph (see `reference/dependency-graph-rendering.md`):

```
Task 1 (ready) ──┬──> Task 4 (blocked)
Task 2 (ready) ──┤
Task 3 (ready) ──┘
```

**Splitting rule.** Split by user value, not technical layer. Each task delivers something testable end-to-end (or as close as the architecture allows). Total tasks should stay under ~10; if it grows beyond that, split the feature into multiple epics.

## Create-issues mode

Once the plan is approved, materialise it on GitHub.

```
bash <skills>/managing-github-issues/scripts/create_labels.sh
gh issue create --title "Epic: <feature name>" --body "<summary + checklist>" --label epic
# then for each task in dependency order:
gh issue create --title "<task title>" --body "<task body using reference/issue-template.md>" --label "ready"  # or "blocked"
```

After all task issues exist:

1. Edit each task body to replace `#TBD` placeholders with the real `#N` numbers in `Blocked by:` and `Unblocks:` lines.
2. Edit the epic body to render the checklist (`- [ ] #N <task title>`).
3. Report the issue numbers and the dependency graph.

## Next mode

Show actionable work. Run:

```
bash <skills>/managing-github-issues/scripts/list_ready.sh
```

Display:

```
Ready (no blockers):
  #10 Task A — unassigned
  #11 Task B — unassigned
  #12 Task C — assigned to @worker-a

Blocked:
  #13 Task D — blocked by #10, #11
```

Flag parallelisable subsets: tasks touching disjoint directories can run in parallel; tasks sharing files must be serialised.

## Start mode

```
gh issue view <N> --json number,title,body,labels
```

Verify the issue is `ready` (not `blocked`, not `in-progress` by someone else). Then:

```
gh issue edit <N> --add-assignee @me --add-label in-progress --remove-label ready
git checkout -b <type>/<N>-<short-description>
```

Then enter `running-tdd-cycles`. On completion the PR description includes `Closes #N` so the merge auto-closes the issue.

If the project tracks a session file (`params.toml`-style), update it now. Canonical Skills are stateless — see `reference/claude-code-session.md` for how Claude-Code consumers extend this skill with session state.

## Advance mode

After issues close, unblock dependents:

```
bash <skills>/managing-github-issues/scripts/check_blockers.sh <N>
```

The script reads each open `blocked` issue's body, parses `Blocked by: #X, #Y`, checks each blocker's state, and reports verdict per issue. For each issue with all blockers closed:

```
gh issue edit <N> --remove-label blocked --add-label ready
```

Update the epic checklist (mark closed task lines `- [x]`).

## Status mode

Render a dashboard:

```
## Project: <repo>

### Active session
<worker> | Issue: #N <title> | Phase: <red/green/refactor>
(or: No active work.)

### Epic: #M <feature>
Progress: ████████░░░░ 4/6 tasks (67%)

### Tasks
  Done:         #10 Task A, #11 Task B
  In progress:  #14 Task E (@worker-a)
  Ready:        #12 Task C, #15 Task F
  Blocked:      #13 Task D (by #12)

### Dependency graph
  #10 done ──┬──> #12 ready ──> #13 blocked
  #11 done ──┘
  #14 in-progress ──> #15 ready
```

Highlight: blocked issues whose blockers are all closed (call `advance`); ready issues with no assignee; in-progress issues with no recent commits (stale flag).

## Labels

The skill expects four labels — `ready`, `blocked`, `in-progress`, `epic`. The `create_labels.sh` script provisions them idempotently:

| Label | Colour | Meaning |
|---|---|---|
| `ready` | `0E8A16` | All blockers closed; can be picked up. |
| `blocked` | `D93F0B` | Has open blockers. |
| `in-progress` | `FBCA04` | Claimed; PR may or may not exist yet. |
| `epic` | `1D76DB` | Groups task issues; not implemented directly. |

## Cross-references

- `designing-architecture` — produces the architecture this skill decomposes into tasks.
- `running-tdd-cycles` — executes one task.
- `committing-changes` — closes the task with a feature branch + PR.
- `engineering-philosophy` — Small Steps and KISS map to "one task = one TDD cycle."

## Reference

- [scripts/create_labels.sh](scripts/create_labels.sh) — idempotent label provisioning.
- [scripts/list_ready.sh](scripts/list_ready.sh) — list open `ready` issues with assignment.
- [scripts/check_blockers.sh](scripts/check_blockers.sh) — verify whether `Blocked by` references are all closed.
- [reference/issue-template.md](reference/issue-template.md) — user-story / acceptance-criteria / dependencies / out-of-scope template.
- [reference/dependency-graph-rendering.md](reference/dependency-graph-rendering.md) — ASCII conventions for the graph in plan/status output.
- [reference/claude-code-session.md](reference/claude-code-session.md) — optional `params.toml` session pattern for Claude-Code consumers.
