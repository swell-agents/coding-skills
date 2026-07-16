---
description: Four-pass quality gate (code, security, architecture, acceptance); AI-native pass opt-in via `ai-native`.
allowed-tools: Bash(git diff *), Bash(git log *), Bash(git rev-parse *), Bash(gh pr view *), Bash(gh pr diff *), Bash(gh issue view *)
---

Scope: $ARGUMENTS

If `$ARGUMENTS` is empty, default the scope to `git diff main...HEAD`. If it looks like a PR number, resolve it via `gh pr diff <N>`. Otherwise pass it through verbatim as the diff range (after stripping the `ai-native` keyword, see below).

Launch the four review agents **in parallel** — a single message with four Agent tool calls:

1. `@code-reviewer` — Pass 1, code quality
2. `@security-auditor` — Pass 2, security audit
3. `@architect-review` — Pass 3, architecture consistency
4. `@acceptance-auditor` — Pass 4, intent / spec alignment (does the diff solve the linked issue?)

**Opt-in fifth pass**: only when `$ARGUMENTS` contains the keyword `ai-native` (or the user explicitly asks for it), also launch `@ai-native-reviewer` — AI-native-coding practices (rubric R1..R8 in `${CLAUDE_PLUGIN_ROOT}/skills/reviewing-changes/reference/ai-native-rubric.md`). Do not run it by default: some repos are deliberately not AI-native and should not be graded against that rubric.

Each agent returns a verdict line (`PASS / NEEDS WORK / FAIL`) plus its findings.

Aggregate the reports into one Quality Gate Summary table:

```
## Quality Gate Summary

| Review             | Verdict        | Critical | Major | Minor |
|--------------------|----------------|----------|-------|-------|
| Code               | pass/warn/fail | N        | N     | N     |
| Security           | pass/warn/fail | N        | N     | N     |
| Architecture       | pass/warn/fail | N        | N     | N     |
| Acceptance         | pass/warn/fail | N        | N     | N     |

Append an `AI-Native Practices` row only when the opt-in pass ran.

**Overall**: PASS / NEEDS WORK / FAIL

### Action items
1. <Critical/Major items, ordered>
```

Then list every Critical and Major finding from all passes with `Rule / Severity / Location / Issue / Fix`. Skip Minor unless the overall verdict is PASS (then include them as polish).

## When to use the inline skill instead

If parallel agents are unavailable in the current harness, fall back to invoking the `reviewing-changes` skill directly — it runs the same passes in a single inline pass. The trade-off is no parallelism and no model-pinning, but the procedure is identical.
