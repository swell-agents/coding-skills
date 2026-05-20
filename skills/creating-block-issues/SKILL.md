---
name: creating-block-issues
description: Generate one "Implement Block X" GitHub issue per Spec Kit tasks.md PR-stack block, following the swell-wrapper coder-agent workflow convention.
allowed-tools: Read, Glob, Grep, Bash(gh issue *), Bash(gh label *), Bash(gh repo view *), Bash(git rev-parse *), Bash(git config --get *), Bash(cat *), Bash(ls *)
---

## When this skill applies

The target repo is a Spec Kit project: `.specify/` exists at repo root, and at least one `specs/<NNN>-<feature>/tasks.md` is present with `#### Block <X> — <name>` PR-stack headings (the structure produced by [`/coding-skills:speckit-tasks`](https://github.com/github/spec-kit) and aligned with [`implementing-blocks`](../implementing-blocks/SKILL.md)). The repo has a GitHub `origin` remote.

This skill creates **one tracking issue per Block**, not per task. No epic, no per-task issues. The wrapper-team coder-agent (or a human assignee) picks them up by label and runs the block-implement loop. The issue body is intentionally minimal (3 short bullets) and points at `tasks.md` as the source of truth; constitution, scars, conventions, and per-task acceptance criteria are NOT duplicated per issue (the daemon and humans both read those from the file at implementation time).

If the repo is not a Spec Kit project, or `tasks.md` does not use the `#### Block <X>` structure, use [`managing-github-issues`](../managing-github-issues/SKILL.md) `create-issues` mode for per-task epic + sub-issues instead, or fall back to manual `gh issue create`.

## Issue template (load-bearing)

Every block-issue body MUST match this exact shape — the wrapper team's [coder-agent-workflow](https://github.com/swell-agents/swell-wrapper/blob/main/docs/coder-agent-workflow.md) documents this convention and divergence either confuses humans or causes the daemon to skip the issue:

```markdown
- **Spec:** `specs/<NNN>-<feature>/tasks.md`
- **Block:** Block <X> — <name> (verbatim from the `####` heading in tasks.md)
- **Tasks:** T0NN-T0NN (tests), T0NN-T0NN (impl)
- **Notes:** <only when something is NOT already in tasks.md — human override, hint, or extra context. Omit the line if there's nothing to add.>
```

That is the entire body. No "ready criteria" recap, no scar list, no dispatch boilerplate.

**Cross-block dependencies are NOT recorded in the body.** They go through GitHub's native [Issue Dependencies](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/about-issues#about-issue-dependencies) feature (right sidebar → Development / Dependencies → Blocked by). Both humans and the daemon consume the graph from there; body-field "Blocked by: #N" lines drift away from reality the moment an issue closes.

## Required labels

Two labels MUST exist in the target repo before issue creation. The skill creates them idempotently:

```bash
gh label create ready --color 0E8A16 --description "Picked up by coder-agent daemon (or human assignee)" --force
gh label create swa-impl-block --color 1D76DB --description "Spec Kit block-implement path opt-in" --force
```

Every created block-issue gets both labels: `ready` (mandatory — the daemon polls for it) and `swa-impl-block` (opt-in for the `implementing-blocks` skill path vs. the classic TDD path).

## Execution flow

1. **Resolve active feature**. Read `.specify/feature.json` for `feature_directory`. If absent, fall back to the current branch's `<NNN>-<feature>` prefix. Resolve to `specs/<feature>/tasks.md`. Abort with a clear error message if no Spec Kit feature is detectable.

2. **Verify GitHub remote**. Run `git config --get remote.origin.url`. Must be a GitHub URL (`github.com:owner/repo.git` or `https://github.com/owner/repo.git`). Echo the resolved `<owner>/<repo>` back to the user before any state-changing operation. **Never create issues in a repo whose `origin` URL was not just echoed**.

3. **Parse tasks.md**. Extract all `#### Block <X> — <name>` headings. For each block:
   - Block letter (A, B, C, ...).
   - Short name (the part after `— `).
   - Task ID ranges: tests subsection (from the block heading down to the next `####` or `###` boundary in the "Tests for User Story" parent) + impl subsection (same scoping in the "Implementation for User Story" parent).
   - Optional block-level Notes from the caller (CLI arg or skill input); skip the Notes line if nothing was provided.

4. **Surface the plan before any write**. Echo the parsed block list + the resolved `<owner>/<repo>` + the would-be issue titles to the user. If the caller passed `--dry-run`, stop here and also render each issue's body verbatim; do NOT proceed to label/issue creation.

5. **Check for existing block-issues**. Run `gh issue list --label swa-impl-block --search "Implement Block <X> in:title" --state all` for each block. If any return a non-empty match, **abort** and report the existing issue numbers. Ask the user how to proceed (re-open via UI, skip the block, supersede with a new issue manually). Never overwrite or auto-close.

6. **Ensure labels exist**. Run the two `gh label create --force` commands from the Required labels section. Idempotent.

7. **Create issues** (one per block, in tasks.md order):

   ```bash
   gh issue create \
     --title "Implement Block <X> — <name>" \
     --label "ready,swa-impl-block" \
     --body "<rendered template>"
   ```

   Capture the returned issue number per block.

8. **Surface dependency-setting instructions** (no auto-write). Parse the "Block Dependency Graph" or "Dependencies & Execution Order" section of tasks.md; output a copy-pasteable instruction block for the user to set "Blocked by" relations via GitHub's UI:

   ```
   Set the following Blocked-by relations in GitHub
   (right sidebar → Development → Dependencies → Blocked by):

   - Issue #<B>: blocked by #<A>
   - Issue #<D>: blocked by #<B> and #<C>
   - Issue #<E>: blocked by #<D>
   - ...
   ```

   The skill does NOT call `gh api` to set the dependencies — as of authoring, GitHub's issue-dependency API is preview-only and `gh` CLI has no stable verb. Manual one-time setup is the documented contract.

9. **Final report**:

   ```
   Created N block-issues for feature <NNN>-<feature> in <owner>/<repo>:
     #<A> Implement Block A — <name>
     #<B> Implement Block B — <name>
     ...

   Next steps:
     1. Set Blocked-by relations per the instruction block above.
     2. Run `/coding-skills:pm next` (or wait for the coder-agent daemon) to pick up the first unblocked block.
   ```

## Activation modes

Single mode: **create-block-issues**. Argument shape (passed via the wrapping command):

- **Empty** → use the active feature from `.specify/feature.json`.
- **`<feature-dir>`** (e.g. `001-uptime-settlement`) → override the active-feature resolution.
- **`--dry-run`** → parse tasks.md and render the would-be issue bodies without calling `gh`. Always echo the parsed block list + dependency graph in dry-run mode.

## Safety rules

- **NEVER** create issues in a repo whose `origin` URL was not just echoed to the user. Hard requirement; this is the same protection `speckit-taskstoissues` enforces.
- **NEVER** overwrite existing block-issues. If step 5 finds a match, abort and report.
- **NEVER** skip the `ready` label — the daemon polls for it.
- **NEVER** include the constitution, scars, dispatch boilerplate, or per-task acceptance criteria in the body. The template is the documented contract; deviation creates drift between issue and tasks.md / CLAUDE.md.
- Echo every state-changing `gh` invocation back to the user before running it (`gh label create`, `gh issue create`).

## Anti-patterns

- **One issue per task.** Wrong granularity for a PR-stack project — generates 50-100 issues for a single feature, swamps the project board, and forces the daemon (or humans) to thread per-task issues into a per-Block PR anyway. Use `managing-github-issues` `create-issues` only if the project does NOT use Spec Kit blocks.
- **Epic issue bundling all blocks.** Adds a maintenance burden (the epic body has to be updated as blocks close) without giving a daemon-readable trigger. The native GitHub Project view + the dependency graph already give the same overview without bookkeeping.
- **Copying CLAUDE.md / constitution / scars into the body.** Source of truth lives in the file, not the issue. The daemon reads the file at implementation time; the issue body just points at it.
- **Cross-block dependency lines in the body** (e.g. "Blocked by: Block A"). Use GitHub's native Issue Dependencies feature instead — both humans and the daemon consume it from the sidebar. Body-field links drift when issues close.

## See also

- [`implementing-blocks`](../implementing-blocks/SKILL.md) — the skill that consumes these issues (TDD + review + draft PR + CI fix loop, one Block per invocation).
- [`managing-github-issues`](../managing-github-issues/SKILL.md) — per-task / epic issue creation for non-Spec-Kit projects.
- swell-wrapper [`docs/coder-agent-workflow.md`](https://github.com/swell-agents/swell-wrapper/blob/main/docs/coder-agent-workflow.md) — the canonical convention this skill encodes.
