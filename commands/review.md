---
description: Three-pass quality gate review (code quality + security + architecture). Launches the code-reviewer, security-auditor, and architect-review agents in parallel for opus-pinned, isolated-context review, then aggregates their findings. Use when you want the full parallel review flow before opening or merging a PR.
allowed-tools: Bash(git diff *), Bash(git log *), Bash(git rev-parse *), Bash(gh pr view *), Bash(gh pr diff *)
---

Scope: $ARGUMENTS

If `$ARGUMENTS` is empty, default the scope to `git diff main...HEAD`. If it looks like a PR number, resolve it via `gh pr diff <N>`. Otherwise pass it through verbatim as the diff range.

Launch the three review agents **in parallel** — a single message with three Agent tool calls:

1. `@code-reviewer` — Pass 1, code quality
2. `@security-auditor` — Pass 2, security audit
3. `@architect-review` — Pass 3, architecture consistency

Each agent applies the `reviewing-changes` skill scoped to its pass and returns a verdict line plus its findings.

Aggregate the three reports into one Quality Gate Summary table:

```
## Quality Gate Summary

| Review       | Verdict        | Critical | Major | Minor |
|--------------|----------------|----------|-------|-------|
| Code         | pass/warn/fail | N        | N     | N     |
| Security     | pass/warn/fail | N        | N     | N     |
| Architecture | pass/warn/fail | N        | N     | N     |

**Overall**: PASS / NEEDS WORK / FAIL

### Action items
1. <Critical/Major items, ordered>
```

Then list every Critical and Major finding from all three passes with `Rule / Severity / Location / Issue / Fix`. Skip Minor unless the overall verdict is PASS (then include them as polish).

## When to use the inline skill instead

If parallel agents are unavailable in the current harness, fall back to invoking the `reviewing-changes` skill directly — it runs the same three passes in a single inline pass. The trade-off is no parallelism and no model-pinning, but the procedure is identical.
