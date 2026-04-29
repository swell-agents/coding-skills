---
purpose: Versioned change log for the coding-skills repo
---

# Changelog

All notable changes to this repository will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

