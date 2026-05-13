---
description: Wire coding-skills into CLAUDE.md (canonical) and make AGENTS.md a pointer.
allowed-tools: Bash(bash *), Read
---

Run the coding-skills bootstrap script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh
```

The script enforces the Claude-first convention:

- **`CLAUDE.md`** is the canonical, single source of truth. The script appends a coding-skills reference block (idempotent via `<!-- coding-skills-bootstrap -->`) and creates the file if it does not exist.
- **`AGENTS.md`** is intentionally a thin pointer to `CLAUDE.md` so non-Claude harnesses (Codex, Cursor, Copilot, Gemini) land on the same content without duplicating it. The script writes the canonical pointer template if `AGENTS.md` is missing. If `AGENTS.md` already exists with substantive content, the script REFUSES to overwrite it and prints a warning instead — content is never silently destroyed.
- **`.cursorrules`** (legacy): if the file exists, the same coding-skills reference block is appended. The script does not create it.

After it completes, summarize for the user: which files were patched, which already had the marker, whether a new file was created, and whether `AGENTS.md` needs manual reduction to the pointer template (relay the warning verbatim).
