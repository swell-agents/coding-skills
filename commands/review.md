---
description: Four-pass quality gate review (code quality + security + architecture + acceptance). Launches the code-reviewer, security-auditor, architect-review, and acceptance-auditor agents in parallel for opus-pinned, isolated-context review, then aggregates their findings. Use when you want the full parallel review flow before opening or merging a PR.
allowed-tools: Bash(git diff *), Bash(git log *), Bash(git rev-parse *), Bash(gh pr view *), Bash(gh pr diff *), Bash(gh issue view *)
---

Scope: $ARGUMENTS

If `$ARGUMENTS` is empty, default the scope to `git diff main...HEAD`. If it looks like a PR number, resolve it via `gh pr diff <N>`. Otherwise pass it through verbatim as the diff range.

Launch the four review agents **in parallel** — a single message with four Agent tool calls:

1. `@code-reviewer` — Pass 1, code quality
2. `@security-auditor` — Pass 2, security audit
3. `@architect-review` — Pass 3, architecture consistency
4. `@acceptance-auditor` — Pass 4, intent / spec alignment (does the diff solve the linked issue?)

Each agent returns a verdict line plus its findings. The first three return `PASS / NEEDS WORK / FAIL`; `acceptance-auditor` returns one or more of `SATISFIED / DRIFT / PARTIAL / OVERREACH / BLOCKED`.

Aggregate the four reports into one Quality Gate Summary table:

```
## Quality Gate Summary

| Review       | Verdict                | Critical | Major | Minor |
|--------------|------------------------|----------|-------|-------|
| Code         | pass/warn/fail         | N        | N     | N     |
| Security     | pass/warn/fail         | N        | N     | N     |
| Architecture | pass/warn/fail         | N        | N     | N     |
| Acceptance   | satisfied/drift/...    | N        | N     | N     |

**Overall**: PASS / NEEDS WORK / FAIL

### Action items
1. <Critical/Major items, ordered>
```

Map acceptance to overall: `SATISFIED` → pass; `DRIFT / PARTIAL / OVERREACH / BLOCKED` each block merge until resolved (overall = NEEDS WORK or FAIL). Then list every Critical and Major finding from all four passes with `Rule / Severity / Location / Issue / Fix`. Skip Minor unless the overall verdict is PASS (then include them as polish).

## When to use the inline skill instead

If parallel agents are unavailable in the current harness, fall back to invoking the `reviewing-changes` skill directly — it runs the same four passes in a single inline pass. The trade-off is no parallelism and no model-pinning, but the procedure is identical.
