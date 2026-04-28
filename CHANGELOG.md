---
purpose: Versioned change log for the coding-skills repo
---

# Changelog

All notable changes to this repository will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] — 2026-04-28

First public release. Ten skills cover the full coding loop — five rule skills for language conventions, five workflow skills for the actions that operate on code.

### Added

- Repo skeleton: `LICENSE` (MIT), `README.md`, `INDEX.md`, `CONTRIBUTING.md`, `.gitignore`, `tests/frontmatter-validate.sh`, `tests/evaluate_with_skillnet_mcp.md`.
- Rule skills: `python-conventions`, `go-conventions`, `solidity-conventions`, `shell-discipline`, `engineering-philosophy`. Hybrid frontmatter (Anthropic + Cursor MDC `globs`/`paths`/`alwaysApply`).
- Workflow skills: `committing-changes` (with verbatim git hooks under `scripts/`), `running-tdd-cycles`, `reviewing-changes`, `designing-architecture`, `managing-github-issues` (with `gh`-based helper scripts under `scripts/`).
- 3–5 manual-scenario prompts per skill under `tests/manual-scenarios/`.
- Original Claude-Code agent and rule files preserved verbatim under each skill's `reference/` directory with a one-line header noting the original `model:` class.

### Source provenance

Distilled from `swell-agents/claude-toolkit` at the state of 2026-04 (`agents/`, `commands/`, `rules/`, `hooks/`). The toolkit repo is unchanged; this is a parallel canonical packaging.

### Excluded from migration

`setup.sh`, Claude-Code-only `model:` frontmatter, `[Extended thinking: …]` annotations, `@agent-name` references, `/slash-command` syntax, `params.toml` session state (documented as opt-in for Claude-Code consumers), and `agents/researcher.md` / `commands/research.md` / `skills/pdf/` (not coding-related). See `README.md` "Not migrated" table.
