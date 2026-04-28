# coding-skills

Canonical [Anthropic Agent Skills](https://docs.anthropic.com/en/docs/claude-code/skills) for software engineering — distilled from [`swell-agents/claude-toolkit`](https://github.com/swell-agents/claude-toolkit) into a portable, harness-agnostic format.

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

### SkillNet

```
skillnet add https://github.com/swell-agents/coding-skills
```

### Claude Code

Clone into `~/.claude/skills/` or symlink individual skills.

### Cursor

Add the repo path to your project's MDC source roots; the `globs:` / `paths:` frontmatter drives auto-activation.

## Not migrated from claude-toolkit

The following are intentionally excluded from this repo. They live in [`swell-agents/claude-toolkit`](https://github.com/swell-agents/claude-toolkit) and stay there:

| Artefact | Reason |
|---|---|
| `setup.sh` | Claude-Code symlink installer; canonical Skills are discovered by directory scan. |
| `model:` frontmatter on agents | Not a canonical Skills field. Preserved verbatim in `reference/`. |
| `[Extended thinking: …]` annotations | Claude-Code-only UI hint. Preserved verbatim in `reference/`. |
| `@agent-name` cross-references | Claude-Code subagent invocation syntax. Rewritten to skill-name prose in bodies. |
| `/slash-command` syntax | Claude-Code-specific. Rewritten to skill names in bodies. |
| `params.toml` session state | Claude-Code-CLI working state. Canonical Skills are stateless. Documented as opt-in in `managing-github-issues/reference/`. |
| `agents/researcher.md`, `commands/research.md`, `skills/pdf/` | Not coding-related. |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
