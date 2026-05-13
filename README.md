# coding-skills

Canonical [Anthropic Agent Skills](https://docs.anthropic.com/en/docs/claude-code/skills) for software engineering — packaged in a portable, harness-agnostic format.

Each skill is a self-contained folder with `SKILL.md` (frontmatter + body), optional `scripts/`, and optional `reference/`. Skills are consumable by Claude Code, [SkillNet](https://github.com/zjunlp/SkillNet), Cursor 2.0 (via MDC frontmatter), OpenAI Codex Skills, and the Microsoft Agent Framework with no transformation.

Claude Code consumers also get parallel-friendly **agents** under `agents/` (e.g. `@code-reviewer`, `@security-auditor`, `@architect-review`) and **slash commands** under `commands/` (e.g. `/coding-skills:review`, `/coding-skills:tdd`, `/coding-skills:commit`) that wrap the skills — same source of truth, richer harness ergonomics. Other harnesses ignore the `agents/` and `commands/` directories.

## Skill catalogue

See [INDEX.md](INDEX.md) for the full list. Two kinds:

- **Workflow skills** — what to do (verbs): `running-tdd-cycles`, `reviewing-changes`, `designing-architecture`, `managing-github-issues`, `committing-changes` (also installs an optional PR-size CI gate that fails PRs over 1000 changed lines, excluding tests/docs/lockfiles/generated), `implementing-blocks` (Spec Kit projects — one PR-stack block end-to-end).
- **Rule skills** — conventions to apply (nouns): `python-conventions`, `go-conventions`, `solidity-conventions`, `shell-discipline`, `engineering-philosophy`.

Workflow skills cross-reference rule skills; agents activate the rule skill alongside the workflow skill when the file or language matches.

## Frontmatter convention

Every `SKILL.md` uses a hybrid of Anthropic Skills (required) + Cursor MDC (optional, for auto-activation in Cursor):

```yaml
---
# Anthropic Skills
name: python-conventions
description: Apply Python project conventions ... Use when writing or reviewing Python code ...
allowed-tools: Read, Bash(uv *), Bash(uv run ruff *), ...

# Cursor MDC (ignored by Anthropic, used by Cursor)
globs: "**/*.py"
paths: "**/*.py"
---
```

Fields explicitly excluded from canonical SKILL.md frontmatter:

- `model:` — Claude-Code-only; original agent model class is preserved as a one-line header in `reference/<agent>.md`.

## Install

### Claude Code (plugin)

Inside any Claude Code session:

```
/plugin marketplace add swell-agents/coding-skills
/plugin install coding-skills@swell-agents
```

Then `/reload-plugins`. All 11 skills become available (auto-activated by description), plus 3 parallel-review agents and 7 slash commands:

| Slash command | Wraps |
|---|---|
| `/coding-skills:review [scope]` | Three `@code-reviewer` + `@security-auditor` + `@architect-review` agents in parallel; aggregates into one Quality Gate Summary |
| `/coding-skills:commit [scope]` | `committing-changes` skill |
| `/coding-skills:tdd [requirement\|phase]` | `running-tdd-cycles` skill |
| `/coding-skills:pm <plan\|start\|next\|advance\|status\|create-issues>` | `managing-github-issues` skill |
| `/coding-skills:design [topic]` | `designing-architecture` skill |
| `/coding-skills:block-implement [block\|next]` | `implementing-blocks` skill — one Spec Kit PR-stack block end-to-end (TDD + review + draft PR + CI fix loop) |
| `/coding-skills:bootstrap` | One-shot wiring: append engineering-skills block to canonical `CLAUDE.md` and create `AGENTS.md` as a pointer (refuses to overwrite substantive `AGENTS.md`) |

### Claude Code (manual)

Clone the repo and symlink individual skills into `~/.claude/skills/`.

### SkillNet

```
skillnet download https://github.com/swell-agents/coding-skills/tree/main/skills/<skill-name>
```

### Cursor

Add the repo path to your project's MDC source roots; the `globs:` / `paths:` frontmatter drives auto-activation.

## Bootstrap a project

Skills are description-matched at retrieval; that is good enough for most cases but not guaranteed. When a project should *always* apply the engineering principles — not just when the matcher fires — patch the project's instruction file once:

In Claude Code:

```
/coding-skills:bootstrap
```

In any other harness:

```bash
bash ~/.claude/plugins/swell-agents/coding-skills/scripts/bootstrap.sh
# or, after `git clone`:
bash scripts/bootstrap.sh
```

The script enforces a Claude-first convention:

- **`CLAUDE.md`** is the canonical, single source of truth for repo instructions. The script appends a coding-skills reference block (idempotent via the `<!-- coding-skills-bootstrap -->` marker) and creates the file if missing.
- **`AGENTS.md`** is intentionally a thin pointer to `CLAUDE.md` so non-Claude harnesses (Codex, Cursor, Copilot, Gemini) land on the same content without duplicating it. The script writes the canonical pointer template if `AGENTS.md` is missing. If `AGENTS.md` already exists with substantive content, the script refuses to overwrite it and prints a warning — user content is never silently destroyed.
- **`.cursorrules`** (legacy): if the file exists, the same engineering-skills block is appended. The script does not create it.

In-use examples of the convention: [`swell-storage-contracts`](https://github.com/swell-agents/swell-storage-contracts/blob/main/AGENTS.md), [`swell-wrapper`](https://github.com/swell-agents/swell-wrapper), [`coder-agent`](https://github.com/swell-agents/coder-agent/blob/main/AGENTS.md).

Re-running once the markers are in place is a no-op.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
