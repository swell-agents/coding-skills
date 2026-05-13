#!/usr/bin/env bash
# bootstrap.sh — wire swell-agents/coding-skills into a project's instruction
# file(s) so engineering-philosophy and the rule skills are part of the
# always-loaded context, not just description-matched on retrieval.
#
# Convention (Claude-first repo):
#   CLAUDE.md  — canonical, single source of truth for repo instructions.
#                Receives the engineering-skills auto-load footer block.
#   AGENTS.md  — intentionally a thin pointer to CLAUDE.md so non-Claude
#                harnesses (Codex, Cursor, Copilot, Gemini) land on the same
#                content without duplicating it.
#   .cursorrules — if it exists, gets the same footer block (legacy harness;
#                  Cursor projects that have already moved to AGENTS.md don't
#                  need this).
#
# Behavior:
#   - CLAUDE.md: append the engineering-skills footer block. Idempotent via
#     `<!-- coding-skills-bootstrap -->` marker. Created if missing.
#   - AGENTS.md: write the canonical pointer template if missing. If the file
#     already exists and is the pointer (marker present or content match),
#     no-op. If the file exists with substantive other content, REFUSE to
#     overwrite and print a clear warning telling the user to manually reduce
#     it to the pointer. Never silently destroys user content.
#   - .cursorrules: append the engineering-skills footer block if the file
#     exists. Never created.
#
# Usage: run from the project root.
#   bash scripts/bootstrap.sh

set -euo pipefail

CS_MARKER="<!-- coding-skills-bootstrap -->"
AGENTS_MARKER="<!-- coding-skills-agents-pointer -->"

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
`coding-skills:managing-github-issues`, `coding-skills:committing-changes`.

See https://github.com/swell-agents/coding-skills for the full skill set.
EOF
}

write_agents_pointer() {
  cat > "$1" <<'EOF'
---
purpose: Pointer to the canonical instruction file (CLAUDE.md)
---

<!-- coding-skills-agents-pointer -->
# Agents

Canonical instructions for this repo live in [`CLAUDE.md`](CLAUDE.md). Read
that file. This is a Claude-first repo — `CLAUDE.md` is the single source of
truth and `AGENTS.md` is intentionally just this pointer so other harnesses
(Codex, Cursor, Copilot, Gemini) land on the same content without duplicating
it here.
EOF
}

# Heuristic: does an existing AGENTS.md already follow the pointer convention?
# Returns 0 if it is the pointer (safe to leave alone), non-zero otherwise.
agents_md_is_pointer() {
  local f="$1"
  # Either the explicit marker is present, or the canonical pointer prose is.
  grep -qF "$AGENTS_MARKER" "$f" && return 0
  grep -qF "intentionally just this pointer" "$f" && return 0
  return 1
}

# -- CLAUDE.md (canonical) ---------------------------------------------------

if [ -f CLAUDE.md ]; then
  if grep -qF "$CS_MARKER" CLAUDE.md; then
    printf 'CLAUDE.md already references coding-skills (marker found). Skipping.\n'
  else
    append_cs_block CLAUDE.md
    printf 'Appended coding-skills reference to CLAUDE.md.\n'
  fi
else
  printf '# Project instructions\n' > CLAUDE.md
  append_cs_block CLAUDE.md
  printf 'Created CLAUDE.md with coding-skills reference.\n'
fi

# -- AGENTS.md (pointer) -----------------------------------------------------

if [ -f AGENTS.md ]; then
  if agents_md_is_pointer AGENTS.md; then
    printf 'AGENTS.md is already the canonical pointer. Skipping.\n'
  else
    printf 'WARNING: AGENTS.md exists with substantive content; not overwriting.\n' >&2
    printf '         This repo uses the Claude-first convention: AGENTS.md should be a\n' >&2
    printf '         thin pointer to CLAUDE.md so non-Claude harnesses land on the same\n' >&2
    printf '         content. Move any unique content from AGENTS.md into CLAUDE.md,\n' >&2
    printf '         then replace AGENTS.md with the pointer template:\n' >&2
    printf '\n' >&2
    printf '             ---\n' >&2
    printf '             purpose: Pointer to the canonical instruction file (CLAUDE.md)\n' >&2
    printf '             ---\n' >&2
    printf '\n' >&2
    printf '             <!-- coding-skills-agents-pointer -->\n' >&2
    printf '             # Agents\n' >&2
    printf '\n' >&2
    printf '             Canonical instructions for this repo live in [`CLAUDE.md`](CLAUDE.md).\n' >&2
    printf '             Read that file. This is a Claude-first repo — `CLAUDE.md` is the\n' >&2
    printf '             single source of truth and `AGENTS.md` is intentionally just this\n' >&2
    printf '             pointer so other harnesses (Codex, Cursor, Copilot, Gemini) land on\n' >&2
    printf '             the same content without duplicating it here.\n' >&2
    printf '\n' >&2
    printf '         Or delete AGENTS.md entirely and re-run this script to regenerate it.\n' >&2
  fi
else
  write_agents_pointer AGENTS.md
  printf 'Created AGENTS.md as canonical pointer to CLAUDE.md.\n'
fi

# -- .cursorrules (legacy, append-only) --------------------------------------

if [ -f .cursorrules ]; then
  if grep -qF "$CS_MARKER" .cursorrules; then
    printf '.cursorrules already references coding-skills (marker found). Skipping.\n'
  else
    append_cs_block .cursorrules
    printf 'Appended coding-skills reference to .cursorrules.\n'
  fi
fi
