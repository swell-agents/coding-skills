---
purpose: Optional params.toml session pattern for Claude-Code consumers — canonical Skills are stateless
---

# Claude-Code session pattern (optional)

Canonical Anthropic Skills are stateless — they receive context per invocation and don't keep working state. The original `claude-toolkit` PM commands maintained a `params.toml` session file at the project root to remember "I'm currently working on issue #N, in phase X, on branch Y." That state lives entirely on the consumer side.

This document describes the pattern as an **opt-in extension** for Claude-Code consumers. Other harnesses (SkillNet, Cursor, Microsoft Agent Framework) don't need it; the skill works without any session state.

## File: `params.toml`

```toml
[Session]
current_issue = 42
issue_title = "Add JWT refresh-token endpoint"
phase = "red"
branch = "feat/42-jwt-refresh"
started_at = "2026-04-28T10:15:00Z"
worker = "@worker-a"
```

`current_issue = 0` means no active session.

## Where state interacts with this skill

- **start mode** — the consumer writes `params.toml` after `gh issue edit ... --add-label in-progress`. If the file already has `current_issue > 0`, warn before overwriting.
- **next mode** — the consumer reads `params.toml`; if a session is active, prepend `Currently working on #N (phase: X)` to the listing.
- **status mode** — same as next; the dashboard shows the active session at the top.
- **commit / PR completion** — clear the session (`current_issue = 0`).

## Why this isn't part of the canonical skill

- The skill should work for harnesses that don't have a project-root file convention.
- Multi-worker setups (e.g., a coder-agent fleet) need shared state, not a local file. Pinning the convention into the skill would be wrong for them.
- The state model is small enough that consumers can implement it in 20 lines of language-native code; baking it into the skill would force a specific TOML schema on everyone.

## Recommended consumer-side implementation

```python
# read
import tomllib, pathlib
state = tomllib.loads(pathlib.Path("params.toml").read_text()) if pathlib.Path("params.toml").exists() else {}
current = state.get("Session", {}).get("current_issue", 0)

# write (use tomli-w or write the lines directly — three keys, no nesting)
```

Keep it dumb. Don't reach for a database or a state library — `params.toml` is a single-process working file, not a system of record.

## Git policy

`params.toml` is **gitignored**. It's a local working file. The system of record is GitHub Issues; the file is a cache of "where am I right now," not durable state.
