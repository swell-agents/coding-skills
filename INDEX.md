---
purpose: Human-readable catalogue of every skill in this repo
---

# Skill catalogue

Two layers: workflow skills (what to do), rule skills (conventions to apply). A typical task activates one workflow skill plus one or more rule skills — e.g., a Python TDD task pulls in `running-tdd-cycles` + `python-conventions`.

## Workflow skills

| Skill | When it activates |
|---|---|
| [running-tdd-cycles](skills/running-tdd-cycles/) | Strict red-green-refactor. User asks for TDD, a failing test first, or names a phase. |
| [reviewing-changes](skills/reviewing-changes/) | Layered code + security + architecture review on a diff or PR. |
| [designing-architecture](skills/designing-architecture/) | Pre-implementation design — components, libraries, data flow, schema. |
| [managing-github-issues](skills/managing-github-issues/) | Spec-driven decomposition into dependency-linked GitHub issues. |
| [committing-changes](skills/committing-changes/) | Feature branch + PR + commit-message hooks discipline. |

## Rule skills

| Skill | Activates on |
|---|---|
| [python-conventions](skills/python-conventions/) | `**/*.py` — uv, Ruff strict, mypy strict, pytest, vulture, pip-audit. |
| [go-conventions](skills/go-conventions/) | `**/*.go` — Go 1.25.x, vendored, golangci-lint v2 strict, gosec, govulncheck, reproducible builds. |
| [solidity-conventions](skills/solidity-conventions/) | `**/*.sol` — Foundry only, forge fmt, solhint:all strict. |
| [shell-discipline](skills/shell-discipline/) | All shell command invocations — one command per call, no inline env vars. |
| [engineering-philosophy](skills/engineering-philosophy/) | Design and tradeoff decisions — KISS, YAGNI, DRY, SOLID, no-magic, investigate-don't-mask. |

## Co-activation

Expected pairings (verified in `tests/manual-scenarios/`):

- Python TDD task → `running-tdd-cycles` + `python-conventions` + `engineering-philosophy`
- Solidity review → `reviewing-changes` + `solidity-conventions`
- Go feature design → `designing-architecture` + `go-conventions` + `engineering-philosophy`
- Any commit → `committing-changes` + `shell-discipline`
