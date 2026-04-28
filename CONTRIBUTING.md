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
description: <what + when>   # ≤1024 chars, front-load what and when
allowed-tools: <list>        # optional; only tool patterns the skill needs

globs: "<glob>"              # optional; Cursor MDC auto-activation
paths: "<glob>"              # optional; Cursor MDC fallback
alwaysApply: true            # optional; Cursor MDC; only for engineering-philosophy
---
```

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
