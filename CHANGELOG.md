---
purpose: Versioned change log for the coding-skills repo
---

# Changelog

All notable changes to this repository will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **Review rubric** (`skills/reviewing-changes/reference/ai-native-rubric.md`) — three scope updates driven by reviewer over-strictness:
  - **R2 weakened.** Pass condition is now "at least one of AGENTS.md / CLAUDE.md / `.cursor/rules/` exists at repo root." The section-structure checklist (Build/Run, Test, Architecture, Conventions, Never-do) is downgraded to guidance — content can legitimately live in linked skills, ADRs, or per-language convention files.
  - **R4 narrowed.** ADR requirement now applies only to projects using Spec Kit (detected via `specs/` with `plan.md`/`tasks.md`, or `.specify/`). Non-Spec-Kit projects record R4 as N/A.
  - **R7 replaced.** Old R7 (explicit logging conventions in the instruction file) removed — logging belongs in per-language convention skills, not the review gate. New R7 is "Minimize context: delete, don't tombstone." Sources: Anthropic [effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents); Augment Code 2026 study on AGENTS.md curation showing auto-generated context hurts task success in 5/8 settings (+2.45–3.92 steps, +20–23% cost); QCon London 2026 "The Right 300 Tokens Beat 100k Noisy Ones."
- `agents/ai-native-reviewer.md`, `skills/reviewing-changes/SKILL.md` — updated to match the new rubric (drop logging check, gate R4 on Spec-Kit detection, weaken R2 to presence-only, enforce R7 minimize-context findings).
- **Bootstrap is patch-only.** `scripts/bootstrap.sh` no longer creates stub files. `CLAUDE.md` present → append engineering-skills block (idempotent via `<!-- coding-skills-bootstrap -->`). `.cursorrules` present → same. `AGENTS.md` is never created and never modified. If no instruction file exists, the script prints a hint and exits 0. Removed the `write_agents_pointer` function, the `AGENTS_MARKER` constant, and the canonical-pointer template — this reverses the Claude-first opinion introduced earlier in this Unreleased cycle and aligns the script with the weakened R2.
- `commands/bootstrap.md`, `README.md`, `INDEX.md` — documented the patch-only behavior.

### Removed

- `scripts/bootstrap.sh` — `write_agents_pointer` function, `AGENTS_MARKER` constant, and `agents_md_is_pointer` helper. No replacement; the script no longer generates or detects pointer templates.

## [1.8.7] — 2026-05-22

### Fixed

- **`skills/reviewing-changes/reference/ai-native-templates/check-ai-practices.sh`** — R5 diff-size check no longer kills the script when run with an empty diff. The CI workflow at `.github/workflows/test.yml` triggered by `push: branches: [main]` re-runs the script on the just-merged commit; in that context `PR_BASE` defaults to `main`, `HEAD == main`, and `git diff --shortstat main...HEAD` is empty. The original R5 pipeline ran the empty output through `grep -oE '[0-9]+ insertion|...'`, which exited 1 on empty input; under `set -euo pipefail` this collapsed the script after R2/R3 PASS and the CI failed with "Process completed with exit code 1" before R5 ever printed. Fix: capture `git diff --shortstat` output first, treat empty as `diff_lines=0` explicitly, run the grep pipeline only on non-empty input. Semantically equivalent ("no diff = 0 lines"); now prints `[R5 PASS] PR diff 0 lines (limit: 1000)` on main HEAD. First found in `swell-storage-contracts` ([PR #45](https://github.com/swell-agents/swell-storage-contracts/pull/45)) where main CI had been red for 5+ consecutive runs.

### Changed

- `.claude-plugin/plugin.json` — version 1.8.6 → 1.8.7.

## [1.8.6] — 2026-05-21

### Added

- **`agents/acceptance-auditor.md`** — Spec Kit bookkeeping check (bidirectional). When the contract is resolved via the Spec Kit fallback path (1c), the auditor now captures the block's task list and each task's `[ ]`/`[X]` status, expands the issue body's `Tasks:` line into a flat T-ID set, and emits `Bookkeeping` findings (new Major-severity rule axis) for two failure modes:
  - *Landed-but-unmarked* — diff modifies the file(s) named in a task's description but `tasks.md` still shows `- [ ] T0NN`. Per `coding-skills:implementing-blocks` TDD-fence and Spec Kit's `speckit-implement` SKILL, completed tasks MUST be flipped to `- [X]` in the same PR.
  - *Marked-but-unimplemented* — `tasks.md` shows `- [X] T0NN` but the diff does not touch the file(s) named in the task description. Catches premature checkbox flips.
  - Pure-prose tasks (ADRs, gate-runs, doc-only without a quoted file path) are treated as *implementation signal unknown* and deferred to the existing Drift / Partial / Overreach scope comparison; the bookkeeping rule does not over-fire on them.
  - Driven by coder-agent daemon (aggelion) shipping `swa-impl-block` PRs that landed code cleanly but never flipped the `[ ]` → `[X]` checkboxes in `tasks.md`, leaving the spec doc out of sync with reality across multiple PRs. The TDD-fence rule was already in the subagent prompt at two layers (`implementing-blocks:95` and `speckit-implement:170`); the auditor now gates on it.

### Changed

- `.claude-plugin/plugin.json` — version 1.8.5 → 1.8.6.

## [1.8.5] — 2026-05-21

### Added

- **`skills/solidity-conventions/SKILL.md`** — two new sections promoted from `swell-storage-contracts/CLAUDE.md` (and duplicated in `swell-wrapper/CLAUDE.md`):
  - **Events and Logging**: past-tense names, indexed params for filterable keys, emit-after-store ordering, no raw blobs already public on chain, no `console2.log` in production contracts, event-signature changes are ABI changes and update specs in the same commit.
  - **NatSpec**: `@inheritdoc IThing` on impl entries with a matching interface signature instead of restated `@notice` prose (matches OZ / Aave / Compound / Uniswap convention; avoids interface/impl doc drift). `@notice` direct for constants, internal helpers, custom errors, and modifiers with no interface counterpart.
- **`skills/engineering-philosophy/SKILL.md`** — new principle **No Number Without Measurement**: gas / latency / throughput / proof-size figures in docs must come from a test run, profile, fixture, or upstream spec citation. Author-quoted "approximately X" without a source is a future-self trap; remove or measure. Same applies to scaling claims.
- **`skills/running-tdd-cycles/SKILL.md`** — RED-phase rule **Test names are claims, not labels**: verify the fixture shape, input source, and assertion target match the test name before the test goes green. A test named `test_decodesV4Quote` that loads a V5 fixture silently pins the wrong invariant.
- **`skills/committing-changes/SKILL.md`** — branch prefix list extended with `infra/` (CI, tooling, dependency bumps, infrastructure changes) and `ai-native/` (AI-native engineering practice updates: agent rubrics, skill changes, automation). The `pre-push` hook does not enforce prefixes; this is documentation guidance.

### Changed

- `.claude-plugin/plugin.json` — version 1.8.4 → 1.8.5.

## [1.8.4] — 2026-05-21

### Changed

- **`skills/creating-block-issues/SKILL.md`** — step 7 (formerly "Surface dependency-setting instructions (no auto-write)") rewritten to **auto-write Blocked-by relations via GraphQL `addBlockedBy`**. Mode 1 only (Mode 2 has no pre-known dep graph). Flow: batched node-ID fetch for all created issues in one GraphQL query → per-edge `addBlockedBy(issueId, blockingIssueId)` mutation → manual-fallback instruction block printed only for edges that failed (insufficient scope, network, etc.). Reverses the 1.8.2 "no auto-write" stance, which cited the dependency API as preview-only; that's now stable. Idempotent on "already blocked by" errors; never silently drops an edge.
- `commands/block-issues.md` — documents the auto-write behaviour and the manual-fallback path.
- `.claude-plugin/plugin.json` — version 1.8.3 → 1.8.4.

## [1.8.3] — 2026-05-21

### Added

- **`skills/creating-block-issues/SKILL.md`** — **subset mode** (Mode 2): create exactly one issue covering an arbitrary task subset (partial-block, cross-block, or cross-phase) via `--tasks T008,T025-T027,T048 --title "Implement Block C (FisherYates) — ..."`. Skill expands ID ranges, validates each ID against `tasks.md`, skips the heading-driven parse and dependency-graph surfacing (caller asserts the scope). Mode 2 body shape uses `**Scope:**` instead of `**Block:**`. Motivated by three real cases on `swell-storage-contracts` (#26/#27/#28) where the existing all-blocks mode couldn't produce the desired subset without restructuring `tasks.md` headings.

### Changed

- **`skills/creating-block-issues/SKILL.md`** — every issue the skill creates now carries a dispatch label (default `swa-impl-block`). The label is the signal a downstream coder-agent daemon polls for; an unlabeled block-issue silently never gets picked up. The skill auto-creates the label in the target repo if missing (color `#0E8A16`, description `Spec Kit block-implement dispatch (coder-agent)`). New CLI overrides: `--label <name>` to use a different dispatch label name, `--no-label` to skip attachment entirely. Reverses the 1.8.2 vendor-neutral "no labels applied" stance: the dispatch label is a load-bearing part of the contract, not a project-specific style choice. Additional labels (`ready`, priority, milestone) remain the consuming project's PM-workflow concern.
- `commands/block-issues.md` — surfaces the new `--tasks` / `--title` / `--notes` subset-mode args alongside the `--label` / `--no-label` flags.
- `.claude-plugin/plugin.json` — version 1.8.2 → 1.8.3.

## [1.8.2] — 2026-05-20

### Added

- `skills/creating-block-issues/SKILL.md` — generate one "Implement Block X" GitHub issue per Spec Kit `tasks.md` PR-stack `#### Block <X> — <name>` heading. One issue per Block (not per task), minimal 3-bullet body (`Spec` / `Block` / `Tasks` / optional `Notes`) pointing at `tasks.md` as the source of truth. No labels applied or created by the skill — label conventions are project-specific and live with the project's PM workflow ([`managing-github-issues`](skills/managing-github-issues/) or equivalent). Cross-block dependencies via GitHub's native Issue Dependencies feature, not body fields. Surfaces a copy-pasteable "Blocked by" instruction block for the user to set in the GitHub UI; never auto-overwrites existing block-issues; never creates issues in a repo whose `origin` URL was not just echoed.
- `commands/block-issues.md` — `/coding-skills:block-issues` slash command wrapping the new skill. Args: empty (use active feature from `.specify/feature.json`), `<feature-dir>` (override), or `--dry-run` (parse + render without `gh` calls).
- `INDEX.md`, `README.md` — list the new skill + command alongside `managing-github-issues` / `implementing-blocks` / `/coding-skills:pm` / `/coding-skills:block-implement`.

### Changed

- `.claude-plugin/plugin.json` — version 1.8.1 → 1.8.2; description updated to "Twelve engineering skills + five parallel-review agents + eight slash commands".

## [1.8.1] — 2026-05-14

### Added

- `skills/go-conventions/SKILL.md` — **testify mandate** in the Testing section, folded in from human-review feedback on `swell-wrapper` PR #36 (sourced via `swell-wrapper/.claude/skills/pr-lessons/SKILL.md`). Every `_test.go` must use `github.com/stretchr/testify/{require,assert}` instead of hand-written `if err != nil { t.Fatalf(...) }` / `if got != want { t.Errorf(...) }` plumbing. Includes a translation table and the `(t, want, got)` argument-order rule.

### Changed

- `.claude-plugin/plugin.json` — version 1.8.0 → 1.8.1.

## [1.7.1] — 2026-05-12

### Added

- `skills/go-conventions/SKILL.md` — two new sections folded in from human-review feedback on `swell-wrapper` PR #24 (sourced via `swell-wrapper/.claude/skills/pr-lessons/SKILL.md`):
  - **Protobuf Layout** — `.proto` sources live under a top-level `proto/<pkg>/`, generated `.pb.go` lives next to its consumer at `internal/<pkg>/<protopkg>/`; descriptive `.proto` filenames (not `v1.proto`); canonical `protoc --go_opt=paths=source_relative` invocation; regenerate via `make generate`.
  - **Domain / Codec Separation** — domain types do not import codec-generated symbols; conversion happens at the codec boundary in unexported `toProtoX` / `fromProtoX` helpers; public APIs take domain types. Acceptance check: `git grep -l '<pbpkg>\.' internal/` must return only `codec.go` + generated `.pb.go`. Generalisable to any wire format (proto / CBOR / JSON), not proto-specific.

### Changed

- `.claude-plugin/plugin.json` — version 1.7.0 → 1.7.1.

## [1.7.0] — 2026-05-12

### Added

- `skills/implementing-blocks/SKILL.md` — new workflow skill that drives one PR-stack block from a Spec Kit `tasks.md` end-to-end: Phase 0 dependency analysis, Phase 1 block selection, Phase 1.5 branch setup (`<NNN>-block-<letter>-<slug>`), Phase 2 TDD-strict subagent against `/speckit-implement`, Phase 3 five-pass parallel review via `reviewing-changes` (3-iteration cap), Phase 4 language-appropriate final gates (defers to `python-conventions` / `go-conventions` / `solidity-conventions`), Phase 5 push + draft PR + CI watch + CI fix loop (3-iteration cap). Ported and generalised from `swell-wrapper/.claude/commands/block-implement.md`; project-specific gates (`make build-reproducible`, Constitution refs, PR #13 scar) replaced with language-skill delegation.
- `commands/block-implement.md` — thin wrapper invoking `implementing-blocks` with `$ARGUMENTS` as the block filter.
- `INDEX.md` — `implementing-blocks` listed under workflow skills; `/coding-skills:block-implement` listed under slash commands.

### Changed

- `.claude-plugin/plugin.json` — version 1.6.0 → 1.7.0; description updated to "Eleven engineering skills + five parallel-review agents + seven slash commands".

## [1.6.0] — 2026-05-09

### Changed

- All ten `skills/*/SKILL.md` `description:` fields compressed from ~600–1020 chars to ~75–84 chars (one short imperative sentence each). Same change applied to the four review agents whose descriptions were inflated by the "four/five-pass review" preamble. Rationale: every skill's name+description is loaded into every session prompt, so long descriptions bloat context, dilute the trigger signal, and bias retrieval toward the most verbose skill regardless of fit. Body content (activation conditions, co-activation graph, tool rationale) is unchanged — those details belong below the frontmatter, not in it.
- `CONTRIBUTING.md` — frontmatter rule updated from `≤1024 chars` to `~80 chars` with a hard cap of 120, plus do/don't examples and a "what belongs in description vs body" table.
- `tests/frontmatter-validate.sh` — added a `WARN` for any description over 120 chars (the 1024-char hard fail still applies).
- `skills/reviewing-changes/SKILL.md` — fixed Pass-numbering bug introduced in 1.4.0/1.5.0 (Pass 4 and Pass 5 had been inserted between Pass 2 and Pass 3, leaving Pass 3 last). Body order is now Pass 1 → Pass 2 → Pass 3 → Pass 4 → Pass 5; intro updated from "three passes" to "five passes".
- `agents/code-reviewer.md`, `agents/security-auditor.md`, `agents/architect-review.md`, `agents/acceptance-auditor.md` — prose updated from "four sibling reviewers" / "three sibling verdicts" / "four-pass review" to the five-sibling reality (ai-native-reviewer was added in 1.5.0 but its sibling references were not back-propagated). The "Skip Pass X" lists now name all four other passes.
- `commands/review.md` — fallback-mode prose updated from "the same four passes" to "the same five passes".
- `skills/shell-discipline/SKILL.md` — removed empty `allowed-tools:` field (the skill is purely advisory and invokes no tools).
- `.claude-plugin/plugin.json` — version 1.5.0 → 1.6.0; description compressed to match the new rule.

### Added

- `CLAUDE.md` at the repo root — repo-local instruction file pointing to the description rule, validation step, and existing memory entries.
- `skills/go-conventions/SKILL.md` — added a `## Reference` section pointing at `reference/golangci.yaml.example`, which had been shipping but never linked from the skill body.

## [1.5.0] — 2026-05-09

### Added

- `agents/ai-native-reviewer.md` — fifth parallel-review agent (model: opus). Validates a diff and the surrounding project against the empirical rubric for working with AI coding agents (R1..R8): comments WHY-not-WHAT, instruction-file presence + single-source-of-truth (R2.1), tests prefer real objects over mocks, ADRs for vibe-architecting decisions, PR / review hygiene, conversational interaction patterns, logging conventions, and bundled CI templates. Read-only — same toolset shape as sibling reviewers.
- `skills/reviewing-changes/reference/ai-native-rubric.md` — eight rules R1..R8 (with R2.1 sub-rule) grounded in published empirical work; each rule cites the underlying paper(s) (vitale2026impact, lulla2026impact, hora2026are, konrad2026architecture, watanabe2025use, agarwal2026ai, tang2026programming, ouatiti2026do, galster2026configuring, ma2026zoro, …).
- `skills/reviewing-changes/reference/ai-native-templates/check-ai-practices.sh` — three deterministic mechanical checks (instruction-file presence, mock-framework pre-screen, PR diff size). Project-agnostic.
- `skills/reviewing-changes/reference/ai-native-templates/ai-practices.yml` — GitHub Action wrapping `check-ai-practices.sh`.
- `skills/reviewing-changes/reference/ai-native-templates/pr-size-check.yml` — standalone PR-size gate (default 1000 lines, override via `large-pr-ok` label).

### Changed

- `commands/review.md` — `/coding-skills:review` now spawns five agents in parallel (was four); aggregate Quality Gate Summary table gains an "AI-Native Practices" row.
- `skills/reviewing-changes/SKILL.md` — Pass 4 (Acceptance) and Pass 5 (AI-Native Practices) documented; live-shim registry expanded from three to five.
- `.claude-plugin/plugin.json` — version 1.4.0 → 1.5.0; description names the new fifth agent.

## [1.4.0] — 2026-05-08

### Added

- `agents/acceptance-auditor.md` — fourth parallel-review agent (model: opus). Verifies that a diff actually solves the contract along three axes (Drift / Partial / Overreach), emitting `Blocked` when no contract is resolvable. Contract resolution chain: linked GitHub issue (`gh issue view`) → PR description (`gh pr view`) → **Spec Kit fallback** for `.specify/` projects (discovers the active feature via `Glob specs/*/tasks.md`, picks by branch-name `<NNN>` prefix or highest `<NNN>`, resolves the relevant `#### Block <X> — <name>` from explicit prompt context, branch pattern `<NNN>-block-<letter>-...`, `[Spec Kit] Implement Block <X>` commit subjects, or touched-file overlap).
- `commands/review.md` — description and orchestration bumped to four-pass; `/coding-skills:review` now launches four agents in parallel and aggregates an "Acceptance" column into the Quality Gate Summary table.

### Changed

- `.claude-plugin/plugin.json` — version 1.3.3 → 1.4.0; description names the new fourth agent.

## [1.3.3] — 2026-05-01

### Added

- `skills/engineering-philosophy/SKILL.md` — new "Be Brief" principle. Imperative output, no preamble, no recap; compress response prose, never operational checklists (named rules, severity words, sub-checks, categories survive verbatim). Applies to chat replies, commit messages, PR bodies, review findings, and any other text the agent emits. Inspired by [Max Taylor's Caveman benchmark](https://www.maxtaylor.me/articles/i-benchmarked-caveman-against-two-words), which showed that two words ("Be brief") cut tokens 34% with no quality loss — and that flat compression *can* drop required terminology, hence the explicit "never compress checklists" carve-out. Since `engineering-philosophy` has `alwaysApply: true`, this principle propagates to every consumer of the plugin without per-skill edits.

## [1.3.2] — 2026-05-01

### Changed

- `skills/reviewing-changes/SKILL.md` Pass 3 — strengthened the "library exists, don't reinvent" bullet. Reinventing primitives the ecosystem already solves (crypto, encoding, parsers, wire codecs, retry/rate-limiting, ORMs, validators) is now presumptive Critical. Three sub-checks: "already in tree" (if the lockfile already pulls in a library that exports the function being hand-rolled, it's Critical regardless of LoC), "justification still valid" (stale comments that justified hand-rolling expire once the dep is in the tree), and "what to grep for" (custom encoders, raw wire-protocol bytes as constants, hand-rolled crypto, hand-written auth-token verification, custom retry-with-backoff loops). Stack-agnostic.

## [1.3.1] — 2026-05-01

### Removed

- `skills/reviewing-changes/reference/code-reviewer-agent.md`, `security-auditor-agent.md`, `architect-review-agent.md` — verbatim copies of the original pre-migration Claude-Code subagents. They were no longer in the data flow (the live `agents/` shims supersede them, delegating to `SKILL.md` for procedure), and they still pointed at the obsolete `.claude/shared/rules/*.md` paths from the pre-migration claude-toolkit layout. ~200 lines of stale fork removed.

### Changed

- `skills/reviewing-changes/SKILL.md` Reference section — drops the three deleted reference files; adds a pointer to the live `agents/` shims as the parallel-execution surface.

## [1.3.0] — 2026-04-29

### Added

- `agents/code-reviewer.md`, `agents/security-auditor.md`, `agents/architect-review.md` — Claude-Code-only thin wrappers (model: opus) that scope the `reviewing-changes` skill to one pass each. Agent bodies `Read` the skill at runtime, so the skill stays the single source of truth and bumps propagate automatically.
- `commands/review.md` — `/coding-skills:review [scope]` launches the three review agents in parallel and aggregates their findings into one Quality Gate Summary table.
- `commands/commit.md`, `commands/tdd.md`, `commands/pm.md`, `commands/design.md` — slash-command wrappers around `committing-changes`, `running-tdd-cycles`, `managing-github-issues`, and `designing-architecture` respectively. Each is a ~10-line delegator; the wrapped skill remains the source of truth.

### Changed

- `README.md` and `INDEX.md` — document the new `agents/` and `commands/` directories and the harness matrix (Claude Code uses the wrappers; Cursor / Codex / SkillNet ignore them and use the skills directly).
- `.claude-plugin/plugin.json` — version bump 1.2.0 → 1.3.0; description mentions the new agents and commands.

## [1.2.0] — 2026-04-29

### Added

- `skills/committing-changes/templates/pr-size.yml` — GitHub Actions workflow using `codelytv/pr-size-labeler@v1`. Labels `size/xs|s|m|l|xl` and fails when a PR exceeds 1000 changed lines, excluding tests, docs, lockfiles, vendored deps, and generated protobuf code. Threshold rationale: SmartBear/Cisco code-review study finds defect detection drops from ~87% (≤100 LOC) to ~28% (>1000 LOC); Google data shows median review time doubles per +100 LOC.
- `skills/committing-changes/templates/gitattributes.example` — `linguist-generated`/`linguist-vendored` block for common lockfiles, generated protobuf code, and vendored deps so GitHub collapses them in PR diffs and size labelers skip them.
- `skills/committing-changes/scripts/install-pr-size-workflow.sh` — idempotent installer that drops the workflow into `.github/workflows/` and appends the `.gitattributes` block.
- `.github/workflows/pr-size.yml` and `.gitattributes` at the repo root — dogfooding the new gate on this repo's own PRs.

### Changed

- `skills/committing-changes/SKILL.md` — install step documents the new workflow installer; Rules add a one-line PR-size cap; Reference lists the new template + script files.

## [1.1.0] — 2026-04-28

### Added

- `scripts/bootstrap.sh` — harness-agnostic shell script that detects every instruction file in a project (CLAUDE.md / AGENTS.md / .cursorrules) and patches each with a coding-skills reference block, creating CLAUDE.md if none exist. Idempotent via a `<!-- coding-skills-bootstrap -->` marker.
- `commands/bootstrap.md` — Claude Code slash-command wrapper (`/coding-skills:bootstrap`) that runs the bootstrap script via `${CLAUDE_PLUGIN_ROOT}`.

### Changed

- `engineering-philosophy` description widened to fire on any code-related task (write / edit / design / refactor / review), not just architecture and review. Co-activation list now spans every workflow + per-language skill.

## [1.0.0] — 2026-04-28

First public release. Ten skills cover the full coding loop — five rule skills for language conventions, five workflow skills for the actions that operate on code.

### Added

- Repo skeleton: `LICENSE` (MIT), `README.md`, `INDEX.md`, `CONTRIBUTING.md`, `.gitignore`, `tests/frontmatter-validate.sh`, `tests/evaluate_with_skillnet_mcp.md`.
- Rule skills: `python-conventions`, `go-conventions`, `solidity-conventions`, `shell-discipline`, `engineering-philosophy`. Hybrid frontmatter (Anthropic + Cursor MDC `globs`/`paths`/`alwaysApply`).
- Workflow skills: `committing-changes` (with verbatim git hooks under `scripts/`), `running-tdd-cycles`, `reviewing-changes`, `designing-architecture`, `managing-github-issues` (with `gh`-based helper scripts under `scripts/`).
- 3–5 manual-scenario prompts per skill under `tests/manual-scenarios/`.
- Original Claude-Code agent and rule files preserved verbatim under each skill's `reference/` directory with a one-line header noting the original `model:` class.

