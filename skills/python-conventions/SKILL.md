---
name: python-conventions
description: Apply Python project conventions — uv for deps and builds, Ruff strict (E, F, I, UP, B, SIM, PTH, PIE, RUF, T201, PLC0415), mypy strict, pytest with pytest-cov and pytest-asyncio, vulture for dead code, pip-audit for dependency security, and a gitignored test.py for scratch experiments. Use when starting a Python project, writing or reviewing Python code, configuring Python tooling, or evaluating compliance with these defaults. Co-activates with running-tdd-cycles, reviewing-changes, and engineering-philosophy.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(uv *), Bash(uv run ruff *), Bash(uv run mypy *), Bash(uv run pytest *), Bash(uv run pip-audit *), Bash(uv run vulture *), Bash(uv run python *)
globs: "**/*.py"
paths: "**/*.py"
---

## Default Stack

If the repo doesn't define its own tooling, use:

- **UV** — dependency management, builds, running scripts
- **GitHub Actions** — CI/CD
- **Ruff** — linting and formatting, with these rule sets:
  - `E` (pycodestyle errors), `F` (pyflakes), `I` (isort), `UP` (pyupgrade)
  - `B` (flake8-bugbear), `SIM` (flake8-simplify), `PTH` (pathlib)
  - `PIE` (flake8-pie), `RUF` (ruff-specific), `T201` (no print)
  - `PLC0415` (import-outside-toplevel)
- **mypy** — strict mode (`strict = true`, `warn_return_any = true`, `warn_unused_configs = true`)
- **pytest** — testing (`pytest-cov`, `pytest-asyncio`)
- **vulture** — dead code detection
- **pip-audit** — dependency security audit

## Scratch Testing

**ALWAYS use `test.py`** in project root for:
- Ad-hoc testing, API calls, data exploration
- Any Python code that isn't a formal test or production code
- **NEVER use inline Python heredocs via Bash** (`uv run python3 << 'EOF'`)

Write code to `test.py`, then run with `uv run python test.py`. Comment out previous code — keeps history. Gitignored — never commit.
