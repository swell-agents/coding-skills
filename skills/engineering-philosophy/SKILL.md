---
name: engineering-philosophy
description: Apply core engineering principles to every code-related decision — KISS (simple over complex), YAGNI (only what's needed now), DRY (single source of truth, never copy-paste), OOP and SOLID (single responsibility first), no magic (explicit over implicit), small commits, prefer libraries over reinvention, no backwards-compatibility shims, automate quality checks in CI, investigate root causes instead of masking symptoms, fail fast (assertions, strict validation, early returns), and be brief (imperative output, compress prose but never operational checklists). Use any time you write, edit, design, refactor, or review code, regardless of language — these principles are judgement weights for every coding task, not just architecture or review. Always co-activates with running-tdd-cycles, reviewing-changes, designing-architecture, committing-changes, and every per-language convention skill.
alwaysApply: true
---

## Principles

- **Architecture** — Class responsibilities defined in the project's architecture map (often `docs/architecture.md`).
- **KISS** — Simple solutions over complex ones.
- **YAGNI** — Build only what's needed now. Less code is better.
- **DRY** — Single source of truth. Never copy-paste.
- **OOP** — Follow OOP approach and best practices.
- **SOLID** — Enforce Single Responsibility; keep the others in mind when possible.
- **No Magic** — Make everything explicit. No hidden behaviour or implicit transformations.
- **Small Steps** — Minimal changes, commit often.
- **Use Libraries** — Prefer established libraries (ORMs, validators, parsers) over reimplementing features. Check the ecosystem before writing custom code.
- **Backwards Compatibility** — Don't keep code for backwards-compatibility purposes.
- **CI** — Automate all possible quality checks.
- **Investigate, Don't Mask** — When a check fails or unexpected behaviour occurs, investigate the root cause instead of adding defensive code to mask the symptom.
- **Fail Fast** — Detect and surface errors immediately at the point of failure. Use assertions, strict validation, and early returns.
- **Be Brief** — Imperative output. No preamble, no recap, no restating the task back. Compress *response prose*, never *operational checklists*: keep every named rule, severity word, sub-check, and category from the active skill verbatim — cut the explanation around them, not the rule itself. Applies to chat replies, commit messages, PR bodies, review findings, and any other text the agent emits.

## Application

These principles are *judgement weights*, not rules. When two principles conflict, this skill defers to the workflow skill driving the task:

- During `designing-architecture`: KISS, YAGNI, Use Libraries, and No Magic dominate. Reject premature abstractions and speculative configurability.
- During `reviewing-changes`: SOLID, DRY, Investigate-Don't-Mask, and Fail Fast dominate. Flag defensive try/except that hides root causes; flag duplication; flag oversized classes.
- During `running-tdd-cycles`: Small Steps and Fail Fast dominate. One requirement per red-green-refactor; one logical change per commit.

When a user proposes a change that violates one of these principles, name the principle and explain the consequence — don't just refuse.
