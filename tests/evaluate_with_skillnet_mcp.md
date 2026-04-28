---
purpose: Procedure for running SkillNet MCP evaluation against this repo's skills
---

# SkillNet MCP evaluation

## Prerequisites

A Claude Code project with the `skillnet` MCP server wired up. Reference setup: `/Users/catena/claude_dir/Metawork/projects/catena2w/explore-ai/.mcp.json`.

## Per-skill evaluation

From inside a session that has the `skillnet` MCP enabled:

```
evaluate_skill target=/absolute/path/to/coding-skills/skills/<name>
```

Returns a 5-dim score (Safety, Completeness, Executability, Maintainability, Cost-awareness). Iterate `description` and body until the score is "Good" on all five dimensions.

Common iteration moves:
- **Safety low** — `allowed-tools` is over-broad or missing; tighten to specific tool/glob patterns.
- **Completeness low** — body skips a step that the description promises; either trim the description or extend the body.
- **Executability low** — instructions ambiguous about *when* the skill should activate; add concrete trigger phrases to `description`.
- **Maintainability low** — body has Claude-Code-only references (`@agent`, `/slash`, `[Extended thinking]`); rewrite to skill-name prose, push verbatim into `reference/`.
- **Cost-awareness low** — body assumes unbounded tool calls; add early-exit heuristics or scope limits.

## Whole-repo analysis

After all 10 skills are in place:

```
analyze_skills skills_dir=/absolute/path/to/coding-skills/skills
```

Look for:
- **Description overlap** between `running-tdd-cycles` ↔ `reviewing-changes` (likely friction).
- **Description overlap** between `engineering-philosophy` ↔ `reviewing-changes` (likely — both apply to a diff).
- **Compose-with edges** confirming workflow ↔ rule pairings (e.g., `running-tdd-cycles` `compose_with` `python-conventions`).
- **Coverage gaps** — if `analyze_skills` reports a missing skill in a typical coding flow, decide whether to add it now or defer.

## Manual scenarios

For each skill, run 3–5 prompts from `tests/manual-scenarios/<skill>.md` in a Claude Code session that has this repo as a skill source. Verify the right skill (and expected co-activations) fires. If a prompt fails to retrieve the intended skill, treat the canonical body as the bug, not the prompt.
