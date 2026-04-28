# coding-skills

Canonical [Anthropic Agent Skills](https://docs.anthropic.com/en/docs/claude-code/skills) for software engineering — packaged in a portable, harness-agnostic format.

Each skill is a self-contained folder with `SKILL.md` (frontmatter + body), optional `scripts/`, and optional `reference/`. Skills are consumable by Claude Code, [SkillNet](https://github.com/zjunlp/SkillNet), Cursor 2.0 (via MDC frontmatter), OpenAI Codex Skills, and the Microsoft Agent Framework with no transformation.

## Skill catalogue

See [INDEX.md](INDEX.md) for the full list. Two kinds:

- **Workflow skills** — what to do (verbs): `running-tdd-cycles`, `reviewing-changes`, `designing-architecture`, `managing-github-issues`, `committing-changes`.
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

Then `/reload-plugins`. All 10 skills become available; Claude Code auto-activates each one based on its description.

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

The script detects every instruction file the project uses (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`) and appends a coding-skills reference block to each. If none exist, it creates `CLAUDE.md`. Idempotent — re-running once the marker is in place is a no-op.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
