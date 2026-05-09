---
purpose: Repo-local rules for working on this skill catalogue
---

# CLAUDE.md — coding-skills repo

This file is the always-loaded instruction file for sessions editing skills in this repo. It complements `CONTRIBUTING.md` (which covers the full add/modify procedure).

## Skill description rule (load-bearing)

Every `SKILL.md` `description:` field must be **~80 characters** — one short imperative sentence stating what the skill does. Hard cap: 120 chars (the validator warns above 120 and fails above 1024).

Why: Anthropic Skills loads every skill's name+description into every session prompt. Long descriptions bloat context, dilute the trigger signal, and bias retrieval toward the most verbose skill regardless of fit. Front-load *what* the skill does; defer *how / when / co-activation* to the body — the retrieval matcher reads the whole metadata payload, so terse is sharper.

Examples:

- ✅ `Apply Python conventions — uv, Ruff strict, mypy strict, pytest, pip-audit.` (76)
- ✅ `Drive strict red-green-refactor TDD discipline on any code change, any language.` (80)
- ❌ Multi-clause "Use when …, supports …, composes with …, never does …" (overflows)

The rule applies to:

- `skills/*/SKILL.md` — all 10 skills (enforced by `tests/frontmatter-validate.sh`).
- `agents/*.md` — the parallel-review subagents (Claude-Code-only; same retrieval pressure).
- `commands/*.md` — slash commands (same retrieval pressure).

What goes where:

| Belongs in `description` | Belongs in body |
|---|---|
| One verb + object — what the skill does | Activation conditions, edge cases |
| Distinguishing keyword if name is generic | Tool list rationale, anti-patterns |
| | Co-activation graph with sibling skills |

## When changing a skill

Bump `.claude-plugin/plugin.json` `version` and add a `CHANGELOG.md` entry. The plugin manifest must always match the content being shipped — see `memory/feedback_plugin_versioning.md`.

Workflow-skill bullets describe rules abstractly; lockfile / symbol / algorithm specifics belong in the per-language conventions skill (see `memory/feedback_skill_wording.md`).

## Validation

Before committing:

```bash
bash tests/frontmatter-validate.sh
```

Output `OK` for every skill = green. A `WARN` line means a description crept past 120 chars; tighten before merging.
