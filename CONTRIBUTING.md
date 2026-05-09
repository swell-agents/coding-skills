---
purpose: How to add or modify a skill in this repo
---

# Contributing

## Adding a skill

1. Create `skills/<kebab-name>/SKILL.md` with hybrid frontmatter (see below).
2. Add `scripts/` only if the skill ships executable code. Mark scripts executable (`chmod +x`).
3. Add `reference/` for verbatim source material (original agent definitions, deeper how-to docs, examples). One level deep only.
4. Add an entry in `INDEX.md` under the right section (workflow vs rule).
5. Add 3–5 sample prompts in `tests/manual-scenarios/<skill>.md` that should retrieve the skill.
6. Run `tests/frontmatter-validate.sh` (must pass).
7. Run SkillNet MCP `evaluate_skill` against the skill's absolute path; iterate until "Good" on all five dimensions.

## Frontmatter

```yaml
---
name: <kebab-name>           # ≤64 chars, lowercase + hyphens
description: <what>          # ~80 chars, single sentence (see rule below)
allowed-tools: <list>        # optional; only tool patterns the skill needs

globs: "<glob>"              # optional; Cursor MDC auto-activation
paths: "<glob>"              # optional; Cursor MDC fallback
alwaysApply: true            # optional; Cursor MDC; only for engineering-philosophy
---
```

### Description rule

Keep `description` to **~80 characters** — one short imperative sentence stating what the skill does. Hard cap: 120 chars (validator warns above 120).

- ✅ `Apply Python conventions — uv, Ruff strict, mypy strict, pytest, pip-audit.` (76)
- ✅ `Drive strict red-green-refactor TDD discipline on any code change, any language.` (80)
- ❌ `Apply Python project conventions — uv for deps and builds, Ruff strict (E, F, I, UP, B, SIM, …), mypy strict (strict = true, warn_return_any = true …), pytest with pytest-cov and pytest-asyncio, …` (overflows at retrieval time)

**Why short.** Anthropic Skills loads every skill's name+description into every session prompt. Long descriptions (>200 chars) bloat context, weight matching toward the most verbose skill regardless of fit, and dilute the trigger signal. Front-load *what* the skill does; defer *how / when / co-activation* to the body. The retrieval matcher reads the whole metadata payload — terse is sharper.

**What goes where.**

| Belongs in `description` | Belongs in body |
|---|---|
| One verb + object — what the skill does | Activation conditions, edge cases |
| Distinguishing keyword if name is generic | Tool list rationale, anti-patterns |
| | Co-activation graph with sibling skills |

Fields **never** to include: `model:` (Claude-Code-only — preserve original in `reference/<agent>.md` header instead).

## Body conventions

- ≤500 lines (warn-don't-fail).
- Use skill-name prose for cross-references (`the running-tdd-cycles skill`), never `@agent-name` or `/slash-command` syntax.
- Strip `[Extended thinking: …]` annotations from the distilled body; keep them in `reference/<verbatim>.md`.

## Modifying a skill

- Bump `name` only on a breaking rename (rare). Prefer in-place description tightening.
- Re-run `evaluate_skill` after every body or description change.
- Add a `CHANGELOG.md` line per meaningful change.

## License

By contributing, you agree your contributions are licensed under MIT (see `LICENSE`).
