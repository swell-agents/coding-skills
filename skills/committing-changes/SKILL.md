---
name: committing-changes
description: Commit work with feature-branch + PR discipline and enforce commit-message rules via git hooks. Use when committing code, opening a PR, or setting up a new repo's commit hygiene. Installs three git hooks (commit-msg subject rules, pre-commit auto-checks, pre-push protect-main), creates a feature branch from main if needed, runs the project's lint/format/test before commit, generates a conformant commit message (capital start, ≤72 chars, no trailing period, no Co-Authored-By, one logical change per commit), pushes, opens a PR via gh pr create, and prunes merged branches. Never pushes to main, never merges PRs, never force-pushes. Co-activates with shell-discipline and engineering-philosophy.
allowed-tools: Read, Edit, Write, Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git add *), Bash(git commit *), Bash(git push *), Bash(git checkout *), Bash(git branch *), Bash(git merge *), Bash(git fetch *), Bash(git rev-parse *), Bash(gh pr *), Bash(gh repo *), Bash(bash scripts/install-hooks.sh)
---

## Workflow

1. **Install hooks** (once per repo).
   From inside the repo, run the installer that ships with this skill:
   ```
   bash <skills>/committing-changes/scripts/install-hooks.sh
   ```
   This copies `commit-msg` and `pre-push` into `.git/hooks/` and makes them executable. Idempotent.

2. **Branch check.** If on `main`, switch to a feature branch:
   ```
   git checkout -b <type>/<description>
   ```
   Valid `type` prefixes: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`.

3. **Auto-fix before commit.** Run the project's linter/formatter (e.g., `ruff format && ruff check` for Python, `golangci-lint run` for Go, `forge fmt && solhint` for Solidity). The pre-commit hook (if installed) runs the project's full quality gate.

4. **Commit & push.**
   ```
   git add <specific paths>
   git commit -m "<subject conforming to rules below>"
   git push -u origin <branch>
   ```

5. **Sync with main.**
   ```
   git fetch origin main
   git merge origin/main
   ```
   Resolve conflicts; commit the merge; push.

6. **PR creation** (first push only).
   ```
   gh pr list --head <branch>
   gh pr create --fill   # if no PR exists yet
   ```

7. **Branch cleanup** (after the user has merged).
   ```
   git fetch --prune
   git branch --merged main | grep -v '^\*\|main' | xargs -r git branch -d
   ```

## Rules

- **Never push directly to `main`.** Always feature branches + PRs. The `pre-push` hook blocks this.
- **Never merge branches or PRs.** Always let the user merge.
- **Never force-push.** No `--force`, no `--force-with-lease`. Create new commits instead.
- **One logical change per commit.**
- **Commit-message subject** (enforced by `commit-msg` hook):
  - Capital start (imperative mood: "Add", "Fix", "Refactor", not "added"/"adds").
  - ≤ 72 chars.
  - No trailing period.
  - No `Co-Authored-By:` lines.

## Why this discipline

Each rule traces to a specific failure mode:
- *No direct push to main* → no broken `main`, every change is reviewable.
- *No agent-side merge* → the human keeps the merge decision; agents never close the loop unilaterally.
- *No force-push* → preserves history; reviewers can trust commit hashes.
- *One logical change per commit* → bisect works; reverts are surgical.
- *Subject rules* → consistent log readability; no noisy attribution lines.

## Cross-references

- `shell-discipline` — issue these `git`/`gh` commands one per call, no `&&` chains.
- `engineering-philosophy` — "Small Steps" and "Investigate, Don't Mask" map directly to one-logical-change-per-commit and don't-disable-failing-hooks.

## Reference

- [scripts/commit-msg](scripts/commit-msg) — subject-line rules enforcer.
- [scripts/pre-commit](scripts/pre-commit) — runs project's lint/format/test before commit.
- [scripts/pre-push](scripts/pre-push) — blocks direct push to `main`/`master`.
- [scripts/install-hooks.sh](scripts/install-hooks.sh) — idempotent installer.
- [reference/commit-md-original.md](reference/commit-md-original.md) — original Claude-Code `commit.md` command verbatim.
- [reference/git-rule.md](reference/git-rule.md) — original `rules/git.md` verbatim.
- [reference/hook-troubleshooting.md](reference/hook-troubleshooting.md) — common failure modes + fixes.
