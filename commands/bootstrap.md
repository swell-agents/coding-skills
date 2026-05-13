---
description: Append the engineering-skills block to existing instruction files (CLAUDE.md / .cursorrules).
allowed-tools: Bash(bash *), Read
---

Run the coding-skills bootstrap script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh
```

The script is patch-only — it never creates stub files. Per-file behavior:

- **`CLAUDE.md`** — if present, append the engineering-skills reference block (idempotent via `<!-- coding-skills-bootstrap -->`). If missing, no-op.
- **`AGENTS.md`** — never modified. Present is fine, absent is fine. The plugin no longer opines on which instruction file is canonical.
- **`.cursorrules`** — if present, append the same block. Never created.
- **`.cursor/rules/`** — if present, no-op (modern Cursor rules layout; the user maintains rule files directly).

If none of those files exists, the script prints a hint and exits 0 — the user creates whichever instruction file fits their project, then re-runs.

After it completes, summarize for the user: which files were patched, which already had the marker, and (if none existed) the hint to create one and re-run.
