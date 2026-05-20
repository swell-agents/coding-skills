# coding-skills

Canonical [Anthropic Agent Skills](https://docs.anthropic.com/en/docs/claude-code/skills) for software engineering — packaged in a portable, harness-agnostic format.

Each skill is a self-contained folder with `SKILL.md` (frontmatter + body), optional `scripts/`, and optional `reference/`. Skills are consumable by Claude Code, [SkillNet](https://github.com/zjunlp/SkillNet), Cursor 2.0 (via MDC frontmatter), OpenAI Codex Skills, and the Microsoft Agent Framework with no transformation.

Claude Code consumers also get parallel-friendly **agents** under `agents/` (e.g. `@code-reviewer`, `@security-auditor`, `@architect-review`) and **slash commands** under `commands/` (e.g. `/coding-skills:review`, `/coding-skills:tdd`, `/coding-skills:commit`) that wrap the skills — same source of truth, richer harness ergonomics. Other harnesses ignore the `agents/` and `commands/` directories.

## Skill catalogue

See [INDEX.md](INDEX.md) for the full list. Two kinds:

- **Workflow skills** — what to do (verbs): `running-tdd-cycles`, `reviewing-changes`, `designing-architecture`, `managing-github-issues`, `creating-block-issues` (Spec Kit projects — one issue per `tasks.md` PR-stack block), `committing-changes` (also installs an optional PR-size CI gate that fails PRs over 1000 changed lines, excluding tests/docs/lockfiles/generated), `implementing-blocks` (Spec Kit projects — one PR-stack block end-to-end).
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

Then `/reload-plugins`. All 12 skills become available (auto-activated by description), plus 3 parallel-review agents and 8 slash commands:

| Slash command | Wraps |
|---|---|
| `/coding-skills:review [scope]` | Three `@code-reviewer` + `@security-auditor` + `@architect-review` agents in parallel; aggregates into one Quality Gate Summary |
| `/coding-skills:commit [scope]` | `committing-changes` skill |
| `/coding-skills:tdd [requirement\|phase]` | `running-tdd-cycles` skill |
| `/coding-skills:pm <plan\|start\|next\|advance\|status\|create-issues>` | `managing-github-issues` skill |
| `/coding-skills:block-issues [feature\|--dry-run]` | `creating-block-issues` skill — one "Implement Block X" GitHub issue per Spec Kit `tasks.md` PR-stack block (coder-agent workflow convention) |
| `/coding-skills:design [topic]` | `designing-architecture` skill |
| `/coding-skills:block-implement [block\|next]` | `implementing-blocks` skill — one Spec Kit PR-stack block end-to-end (TDD + review + draft PR + CI fix loop) |
| `/coding-skills:bootstrap` | One-shot wiring: append engineering-skills block to existing `CLAUDE.md` / `.cursorrules`. Patch-only — never creates files; never touches `AGENTS.md`. |

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

The script is patch-only. It never creates instruction files; it only appends the engineering-skills block to ones that already exist.

- **`CLAUDE.md`** — if present, the script appends the engineering-skills reference block (idempotent via the `<!-- coding-skills-bootstrap -->` marker). If missing, no-op.
- **`AGENTS.md`** — never modified. Present is fine, absent is fine. The plugin does not opine on which instruction file is canonical; AGENTS.md as canonical, CLAUDE.md as canonical, or a mix is all acceptable.
- **`.cursorrules`** — if the file exists, the same engineering-skills block is appended. The script does not create it.
- **`.cursor/rules/`** — if the directory exists, no-op (you maintain rule files directly).

If none of those files exists, the script prints a hint and exits 0 — create whichever instruction file fits your project (per the rubric's R2: presence of any one is the bar), then re-run.

Re-running once the markers are in place is a no-op.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
