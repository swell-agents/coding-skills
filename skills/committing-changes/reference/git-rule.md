---
purpose: Verbatim copy of claude-toolkit/rules/git.md
---

# Original `rules/git.md`

Below is the unedited body of `swell-agents/claude-toolkit/rules/git.md`. The canonical `SKILL.md` integrates these rules into its Workflow + Rules sections for harness-agnostic consumption.

---

## Git Rules

- **NEVER push directly to main.** Always use feature branches + PRs.
- **NEVER merge branches or PRs.** Always let the user merge.
- **NEVER force-push.** No `--force`, no `--force-with-lease`. Create new commits instead.
- **One logical change per commit.**
- **Commit message format** (enforced by hook — `.claude/shared/hooks/commit-msg`):
  capital start, ≤72 chars, no trailing period, no Co-Authored-By
