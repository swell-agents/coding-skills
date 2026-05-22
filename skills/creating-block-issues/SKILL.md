---
name: creating-block-issues
description: Generate one "Implement Block X" GitHub issue per Spec Kit tasks.md PR-stack block, with a minimal body pointing at tasks.md as the source of truth.
allowed-tools: Read, Glob, Grep, Bash(gh issue *), Bash(gh repo view *), Bash(gh label *), Bash(gh api graphql *), Bash(git rev-parse *), Bash(git config --get *), Bash(cat *), Bash(ls *)
---

## When this skill applies

The target repo is a Spec Kit project: `.specify/` exists at repo root, and at least one `specs/<NNN>-<feature>/tasks.md` is present with `#### Block <X> — <name>` PR-stack headings (the structure produced by `/coding-skills:speckit-tasks` and aligned with [`implementing-blocks`](../implementing-blocks/SKILL.md)). The repo has a GitHub `origin` remote.

This skill creates **one tracking issue per Block**, not per task. No epic, no per-task issues. Whoever picks up the issue (a human assignee or an automation pipeline that polls GitHub) runs the block-implement loop. The issue body is intentionally minimal (3 short bullets) and points at `tasks.md` as the source of truth; constitution, scars, conventions, and per-task acceptance criteria are NOT duplicated per issue (the assignee reads them from the file at implementation time).

If the repo is not a Spec Kit project, or `tasks.md` does not use the `#### Block <X>` structure, fall back to manual `gh issue create` per the project's own issue conventions.

## Issue template (load-bearing)

Every block-issue body MUST match this exact shape — keeping the body minimal is the contract. Drift between issue and `tasks.md` is what we are explicitly avoiding:

```markdown
- **Spec:** `specs/<NNN>-<feature>/tasks.md`
- **Block:** Block <X> — <name> (verbatim from the `####` heading in tasks.md)
- **Tasks:** T0NN-T0NN (tests), T0NN-T0NN (impl)
- **Notes:** <only when something is NOT already in tasks.md — human override, hint, or extra context. Omit the line if there's nothing to add.>
```

That is the entire body. No "ready criteria" recap, no scar list, no dispatch boilerplate.

**Cross-block dependencies are NOT recorded in the body.** They go through GitHub's native [Issue Dependencies](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/about-issues#about-issue-dependencies) feature (right sidebar → Development / Dependencies → Blocked by). Body-field "Blocked by: #N" lines drift away from reality the moment an issue closes; the native graph stays accurate.

## Labels

Every issue this skill creates carries the `swa-impl-block` label. The label is the dispatch signal a downstream coder-agent daemon polls for; an unlabeled block-issue silently never gets picked up. The skill auto-creates the label in the target repo if missing (color `#0E8A16`, description `Spec Kit block-implement dispatch (coder-agent)`).

Additional project-specific labels (`ready`, priority, milestone) are NOT applied here — add them after creation with `gh issue edit <N> --add-label <name>` or via the GitHub UI.

If a consuming repo wants a different dispatch label name (or none), it can override at invocation time by passing `--label <name>` / `--no-label` through the wrapping `/coding-skills:block-issues` command. The default stays `swa-impl-block`.

## Execution flow

1. **Resolve active feature**. Read `.specify/feature.json` for `feature_directory`. If absent, fall back to the current branch's `<NNN>-<feature>` prefix. Resolve to `specs/<feature>/tasks.md`. Abort with a clear error message if no Spec Kit feature is detectable.

2. **Verify GitHub remote**. Run `git config --get remote.origin.url`. Must be a GitHub URL (`github.com:owner/repo.git` or `https://github.com/owner/repo.git`). Echo the resolved `<owner>/<repo>` back to the user before any state-changing operation. **Never create issues in a repo whose `origin` URL was not just echoed**.

3. **Parse tasks.md**. Extract all `#### Block <X> — <name>` headings. For each block:
   - Block letter (A, B, C, ...).
   - Short name (the part after `— `).
   - Task ID ranges: tests subsection (from the block heading down to the next `####` or `###` boundary in the "Tests for User Story" parent) + impl subsection (same scoping in the "Implementation for User Story" parent).
   - Optional block-level Notes from the caller (CLI arg or skill input); skip the Notes line if nothing was provided.

4. **Surface the plan before any write**. Echo the parsed block list + the resolved `<owner>/<repo>` + the would-be issue titles to the user. If the caller passed `--dry-run`, stop here and also render each issue's body verbatim; do NOT proceed to issue creation.

5. **Check for existing block-issues**. Run `gh issue list --search "Implement Block <X> in:title" --state all` for each block. If any return a non-empty match, **abort** and report the existing issue numbers. Ask the user how to proceed (re-open via UI, skip the block, supersede with a new issue manually). Never overwrite or auto-close.

6. **Ensure dispatch label exists** (unless `--no-label` was passed). Resolve the label name (default `swa-impl-block`, override via `--label <name>`). Run `gh label list --search <name>` to check. If absent, create it idempotently:

   ```bash
   gh label create swa-impl-block \
     --description "Spec Kit block-implement dispatch (coder-agent)" \
     --color "0E8A16"
   ```

   If `gh label create` fails because the label already exists (race), proceed silently. If it fails for any other reason (permissions), abort before creating any issues.

7. **Create issues** (one per block, in tasks.md order):

   ```bash
   gh issue create \
     --title "Implement Block <X> — <name>" \
     --body "<rendered template>" \
     --label swa-impl-block
   ```

   Omit `--label` only when `--no-label` was passed. Capture the returned issue number per block.

8. **Set Blocked-by relations via GraphQL** (Mode 1 only; skip in Mode 2 since custom subsets have no pre-known dep graph). Parse the "Block Dependency Graph" or "Dependencies & Execution Order" section of tasks.md to extract `{blocked_issue: [blocking_issues...]}` pairs. Then:

   a. **Fetch node IDs** for every created issue in one batched query:

      ```bash
      gh api graphql -f query='
        { repository(owner: "<owner>", name: "<repo>") {
            issue26: issue(number: <N1>) { id }
            issue27: issue(number: <N2>) { id }
            ...
          }
        }' --jq '.data.repository'
      ```

   b. **Fire `addBlockedBy` mutation per dep edge** (issue node IDs, not numbers):

      ```bash
      gh api graphql -f query='
        mutation { addBlockedBy(input: {
          issueId: "<blocked_node_id>",
          blockingIssueId: "<blocking_node_id>"
        }) { clientMutationId } }'
      ```

   c. **Error handling**: if a single edge fails (already-exists, insufficient scope, network), report the specific failure and continue with remaining edges; do NOT abort the run. The failing edges fall back to the human-instructions block below. Common failure modes:
      - `Resource not accessible by integration` → token lacks `issues:write` scope. Fall back to printing the human-readable Blocked-by instructions.
      - `An error occurred while validating the input: issue is already blocked by ...` → idempotent no-op; treat as success.

   d. **Fallback for unset / failed edges** (only when at least one edge failed in step (b/c)): print the copy-pasteable instruction block so the user can finish via UI:

      ```
      Could not auto-set the following Blocked-by relations
      (right sidebar → Development → Dependencies → Blocked by):

        - Issue #<B>: blocked by #<A>
        - Issue #<D>: blocked by #<B> and #<C>
      ```

      In the all-success path, skip this block entirely.

9. **Final report**:

   ```
   Created N block-issues for feature <NNN>-<feature> in <owner>/<repo>
   (label: swa-impl-block):
     #<A> Implement Block A — <name>
     #<B> Implement Block B — <name>
     ...

   Blocked-by relations set: K of M edges via addBlockedBy.
   (Or: "All M edges set successfully." / "K edges fell back to manual; see above.")

   Next step:
     - Apply any additional project-specific labels (`ready`, priority, milestone) via `gh issue edit <N> --add-label <name>` or the GitHub UI.
   ```

## Activation modes

Two modes:

### Mode 1: **all-blocks** (default)

Heading-driven. Creates one issue per `#### Block <X> — <name>` in `tasks.md`. Argument shape:

- **Empty** → use the active feature from `.specify/feature.json`. Attaches the default `swa-impl-block` label.
- **`<feature-dir>`** (e.g. `001-uptime-settlement`) → override the active-feature resolution.
- **`--dry-run`** → parse tasks.md and render the would-be issue bodies without calling `gh`. Always echo the parsed block list + dependency graph + resolved label in dry-run mode.
- **`--label <name>`** → override the default dispatch label name.
- **`--no-label`** → skip label attachment entirely (issues created bare).

### Mode 2: **subset** (single issue, custom scope)

Task-ID-driven. Creates exactly **one** issue covering an arbitrary subset of tasks — partial-block (e.g. Block A's SwellParameters half), cross-block (e.g. Fisher-Yates spanning Blocks B + C), or cross-phase (e.g. Phase 1 + Phase 2 + a Block A subset). The skill does NOT parse `####` headings in this mode — the caller asserts the scope.

Triggered by the presence of `--tasks`. Required args:

- **`--tasks <ids>`** → comma-separated task IDs with range support: `T008,T025-T027,T048`. Skill expands ranges (`T025-T027` → `T025,T026,T027`) and validates each ID exists in tasks.md; aborts with the missing IDs if any.
- **`--title <text>`** → the GitHub issue title. Convention: `Implement Block <X> (<subset name>) — <description>` so existing-issue search still works. Examples: `Implement Block A (SwellParameters) — epochEmission extension`, `Implement Block C (FisherYates) — Knuth shuffle library`.

Optional args:

- **`--notes <text>`** → free-form Notes line in the body. Use for human overrides not derivable from tasks.md (e.g. "MetaCertificateCodec deferred", "no upgrade ceremony per pre-deployment rule").
- **`--dry-run`** / **`--label <name>`** / **`--no-label`** → same semantics as Mode 1.

Mode-2 body shape:

```markdown
- **Spec:** `specs/<NNN>-<feature>/tasks.md`
- **Scope:** <verbatim from --title, with the "Implement " prefix stripped>
- **Tasks:** <expanded comma-separated task IDs from --tasks>
- **Notes:** <--notes value, omitted if absent>
```

Mode-2 differences from Mode 1's execution flow:

- Skip step 3's heading parsing; use the explicit `--tasks` list.
- Step 5 existing-issue check uses `--title` exact match instead of the `Implement Block <X>` pattern.
- Skip step 8's dependency graph (the caller knows their cross-issue deps; the skill can't infer them from a custom subset).
- Final report shows a single issue, not a list.

## Safety rules

- **NEVER** create issues in a repo whose `origin` URL was not just echoed to the user.
- **NEVER** overwrite existing block-issues. If step 5 finds a match, abort and report.
- **NEVER** include the constitution, scars, dispatch boilerplate, or per-task acceptance criteria in the body. The template is the contract; deviation creates drift between issue and `tasks.md` / `CLAUDE.md`.
- **NEVER** attach labels other than the one resolved in step 6 (default `swa-impl-block`, or whatever the caller passed via `--label`). Additional project-specific labels are the consuming project's PM-workflow concern — they go in via `gh issue edit` afterward.
- Echo every state-changing `gh issue create` / `gh label create` / `addBlockedBy` invocation back to the user before running it.
- **NEVER** silently drop a dep edge. If `addBlockedBy` fails for any edge, report it explicitly and surface that edge in the manual-fallback block.

## Anti-patterns

- **One issue per task.** Wrong granularity for a PR-stack project — generates 50-100 issues for a single feature, swamps the project board, and forces the assignee to thread per-task issues into a per-Block PR anyway. For non-Spec-Kit projects, drive issue creation manually with `gh issue create`.
- **Epic issue bundling all blocks.** Adds a maintenance burden (the epic body has to be updated as blocks close) without giving a richer signal than the native GitHub Project view + Issue Dependencies graph already provide.
- **Copying `CLAUDE.md` / constitution / scars into the body.** Source of truth lives in the file, not the issue. Both humans and any automation read `tasks.md` at implementation time; the issue body just points at it.
- **Cross-block dependency lines in the body** (e.g. "Blocked by: Block A"). Use GitHub's native Issue Dependencies feature instead — both humans and automation consume it from the sidebar. Body-field links drift when issues close.
- **Stuffing the issue with extra labels.** The single dispatch label (`swa-impl-block` by default) is the contract — it tells the downstream coder-agent the issue is ready to pick up. Priority, milestone, `ready`, `area/*` etc. are the consuming project's PM-workflow concern and go on after creation via `gh issue edit`. Baking multiple labels in here couples the skill to one project's workflow.

## See also

- [`implementing-blocks`](../implementing-blocks/SKILL.md) — the skill that consumes these issues (TDD + review + draft PR + CI fix loop, one Block per invocation).
