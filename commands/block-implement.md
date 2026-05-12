---
description: Implement one PR-stack block from Spec Kit `tasks.md` end-to-end — TDD-strict subagent, five-pass review, language-appropriate gates, push, draft PR, CI fix loop. Use on a Spec Kit project; pass the block name verbatim or `next` to pick the next ready block.
argument-hint: "Optional block filter (e.g. 'Block A — Cert codec', 'next', empty = analyse and propose)"
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git fetch *), Bash(git status *), Bash(git checkout *), Bash(git pull --ff-only *), Bash(git push origin *), Bash(git push -u origin *), Bash(git rev-parse *), Bash(git log *), Bash(git diff *), Bash(git branch *), Bash(git add *), Bash(git commit *), Bash(git stash *), Bash(gh pr create *), Bash(gh pr checks *), Bash(gh pr view *), Bash(gh pr ready *), Bash(gh run view *), Bash(make *), Bash(uv run *), Bash(go test *), Bash(go vet *), Bash(golangci-lint *), Bash(forge *), Bash(solhint *), Bash(pip-audit *), Bash(govulncheck *), Bash(pytest *)
---

Scope: $ARGUMENTS

Invoke the `implementing-blocks` skill with `$ARGUMENTS` as the block filter. The skill is the single source of truth for:

- Spec Kit `tasks.md` parsing and block dependency analysis (Phase 0).
- Block-selection confirmation flow and branch naming `<NNN>-block-<letter>-<slug>` (Phase 1 + 1.5).
- TDD-strict subagent invocation against `/speckit-implement` (Phase 2).
- Five-pass parallel review via `reviewing-changes` with a 3-iteration cap (Phase 3).
- Language-appropriate final gates (Phase 4) — defers to `python-conventions` / `go-conventions` / `solidity-conventions`.
- Push, draft PR, CI watch, and CI fix loop with a 3-iteration cap (Phase 5).

Echo any state-changing `git` or `gh` command back to the user before running it.
