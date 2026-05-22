#!/usr/bin/env bash
# bootstrap.sh — wire swell-agents/coding-skills into a project's existing
# instruction file(s) so engineering-philosophy and the rule skills are part
# of the always-loaded context, not just description-matched on retrieval.
#
# Behavior (patch-only — no stub files are created):
#   CLAUDE.md   — if present, append the engineering-skills footer block.
#                 Idempotent via `<!-- coding-skills-bootstrap -->` marker.
#   AGENTS.md   — never created, never modified. Present is fine; absent is
#                 fine. The plugin no longer opines on a canonical layout.
#   .cursorrules — if present, append the same footer block. Never created.
#
# If none of CLAUDE.md / AGENTS.md / .cursor/rules is present, the script
# prints a hint and exits 0 — create whichever instruction file fits your
# project, then re-run.
#
# Usage: run from the project root.
#   bash scripts/bootstrap.sh

set -euo pipefail

CS_MARKER="<!-- coding-skills-bootstrap -->"

append_cs_block() {
  cat >> "$1" <<'EOF'

<!-- coding-skills-bootstrap -->
## Engineering principles (from swell-agents/coding-skills)

This project applies the **engineering-philosophy** skill on every code change:

- **KISS** — simple over complex
- **YAGNI** — only what's needed now
- **DRY** — single source of truth, never copy-paste
- **SOLID** — single responsibility first; others when they fit
- **No magic** — explicit over implicit
- **Small steps** — one logical change per commit
- **Use libraries** — prefer established libs over reinventing
- **Investigate, don't mask** — fix root causes, not symptoms
- **Fail fast** — assertions, strict validation, early returns

Per-language conventions auto-activate when the file matches:
`coding-skills:python-conventions`, `coding-skills:go-conventions`,
`coding-skills:solidity-conventions`, `coding-skills:shell-discipline`.

Workflow skills: `coding-skills:running-tdd-cycles`,
`coding-skills:reviewing-changes`, `coding-skills:designing-architecture`,
`coding-skills:committing-changes`.

See https://github.com/swell-agents/coding-skills for the full skill set.
EOF
}

patched=0

# -- CLAUDE.md ---------------------------------------------------------------

if [ -f CLAUDE.md ]; then
  if grep -qF "$CS_MARKER" CLAUDE.md; then
    printf 'CLAUDE.md already references coding-skills (marker found). Skipping.\n'
  else
    append_cs_block CLAUDE.md
    printf 'Appended coding-skills reference to CLAUDE.md.\n'
  fi
  patched=1
fi

# -- AGENTS.md (informational only — never created, never modified) ----------

if [ -f AGENTS.md ]; then
  printf 'AGENTS.md present; not modified by bootstrap.\n'
  patched=1
fi

# -- .cursorrules (legacy, append-only) --------------------------------------

if [ -f .cursorrules ]; then
  if grep -qF "$CS_MARKER" .cursorrules; then
    printf '.cursorrules already references coding-skills (marker found). Skipping.\n'
  else
    append_cs_block .cursorrules
    printf 'Appended coding-skills reference to .cursorrules.\n'
  fi
  patched=1
fi

# -- .cursor/rules (modern Cursor layout — informational only) ---------------

if [ -d .cursor/rules ]; then
  printf '.cursor/rules/ present; not modified by bootstrap.\n'
  patched=1
fi

if [ "$patched" -eq 0 ]; then
  printf 'No instruction file found (CLAUDE.md / AGENTS.md / .cursorrules / .cursor/rules/).\n'
  printf 'Create one of them at the repo root, then re-run this script.\n'
fi
