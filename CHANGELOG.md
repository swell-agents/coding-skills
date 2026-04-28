---
purpose: Versioned change log for the coding-skills repo
---

# Changelog

All notable changes to this repository will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

