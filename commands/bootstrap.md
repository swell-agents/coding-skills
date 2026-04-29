---
description: Wire swell-agents/coding-skills into this project's instruction file (CLAUDE.md / AGENTS.md / .cursorrules) so engineering-philosophy and the rule-skill set are always-loaded context, not just retrieval-matched.
allowed-tools: Bash(bash *), Read
---

Run the coding-skills bootstrap script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh
```

The script detects every instruction file in the current project (CLAUDE.md, AGENTS.md, .cursorrules), patches each with a coding-skills reference block, and creates CLAUDE.md if none exist. Idempotent — re-running after the marker is in place is a no-op.

After it completes, summarize for the user: which files were patched, which already had the marker, and whether a new file was created.
