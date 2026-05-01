---
purpose: Versioned change log for the coding-skills repo
---

# Changelog

All notable changes to this repository will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

