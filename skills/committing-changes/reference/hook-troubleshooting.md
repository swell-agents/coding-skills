---
purpose: Common failure modes for the commit-msg, pre-commit, and pre-push hooks
---

# Hook troubleshooting

Failure modes in order of frequency.

## commit-msg

**`ERROR: Subject line is N chars (max 72).`** — Tighten the subject. If you genuinely need more context, put it in the body (blank line after subject, then prose). Don't pre-emptively split into two commits unless the change is also two logical changes.

**`ERROR: Subject must start with a capital letter (imperative mood).`** — Use `Add`, `Fix`, `Refactor`, not `added`, `adds`, `fixed`. The hook checks the first character only; `feat: add ...` lower-case after the prefix will still fail.

**`ERROR: Subject must not end with a period.`** — Drop the period. The subject is a title, not a sentence.

**`ERROR: Co-Authored-By lines are not allowed.`** — Remove the trailer. The agent's authorship is implicit in the workflow; no need to spam `Co-Authored-By: Claude` into history.

## pre-commit

The hook runs the project's lint/format/test stack. Failure modes are project-specific. The general rule: **don't `--no-verify`**. If a hook fails, fix the underlying issue and create a *new* commit. Bypassing hooks is the path that produced the bug the hook was added to catch.

If the hook is wrong (e.g., the linter has a rule that genuinely doesn't apply here), fix the linter config and commit *that* change separately, then retry the original commit.

## pre-push

**`ERROR: Direct push to 'main' is not allowed.`** — Create a feature branch:
```
git checkout -b <type>/<description>
git push -u origin <type>/<description>
```
Then `gh pr create --fill`.

If the hook is genuinely in the way (e.g., one-person repo, you really do want to push to main), don't disable it — change your workflow. The hook exists because every project that allowed direct pushes eventually broke `main` for everyone.

## Hook is not running at all

```
ls -la .git/hooks/
```
If `commit-msg` / `pre-push` aren't there, run the installer:
```
bash <skills>/committing-changes/scripts/install-hooks.sh
```

If they exist but aren't running, check executable bit:
```
chmod +x .git/hooks/commit-msg .git/hooks/pre-push
```

If you're in a worktree, hooks live in the *main* git dir; use `git rev-parse --git-dir` to find the right `hooks/` to populate. The installer handles this.
