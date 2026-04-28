---
purpose: Verbatim copy of claude-toolkit/commands/commit.md (Claude-Code slash-command form)
---

# Original `/commit` slash-command (Claude-Code-native)

Below is the unedited body of `swell-agents/claude-toolkit/commands/commit.md`. Preserved here for the Claude-Code consumer. The canonical `SKILL.md` rewrites the same content for harness-agnostic consumption.

---

Commit changes, push to remote, and create PR if needed.

## Workflow

1. **Install Hooks**
   - From the repo being committed, run: `bash <metawork-root>/.claude/shared/hooks/install-hooks.sh`

2. **Branch Check**
   - If on `main`: prompt for branch type and description, then `git checkout -b <type>/<description>`
   - Valid types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

3. **Auto-fix before commit**
   - Run project linter/formatter if configured (check CLAUDE.md for project-specific tools)
   - Pre-commit hooks will verify quality gates

4. **Commit & Push**
   - Stage all changes: `git add -A`
   - Generate concise commit message from diff
   - Commit and push: `git push -u origin <branch>`

5. **Merge Main**
   - `git fetch origin main && git merge origin/main`
   - If conflicts: resolve, commit merge, push
   - If clean: push

6. **PR Creation** (first push only)
   - Check if PR exists: `gh pr list --head <branch>`
   - If no PR: `gh pr create --fill`

7. **Branch Cleanup**
   - Delete local branches already merged into main: `git branch --merged main | grep -v '^\*\|main' | xargs -r git branch -d`
   - Prune remote tracking branches: `git fetch --prune`

## Rules

@rules/git.md
