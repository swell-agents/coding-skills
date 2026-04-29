#!/usr/bin/env bash
# bootstrap.sh — wire swell-agents/coding-skills into a project's instruction
# file(s) so engineering-philosophy and the rule skills are part of the
# always-loaded context, not just description-matched on retrieval.
#
# Detects CLAUDE.md (Claude Code), AGENTS.md (OpenAI Codex / cross-tool), and
# .cursorrules (Cursor) — patches every file that exists, creates CLAUDE.md if
# none do. Idempotent: re-running is a no-op once the marker is present.
#
# Usage: run from the project root.
#   bash scripts/bootstrap.sh

set -euo pipefail

MARKER="<!-- coding-skills-bootstrap -->"
CANDIDATES=(CLAUDE.md AGENTS.md .cursorrules)

append_block() {
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

patched=0
existed=0
for target in "${CANDIDATES[@]}"; do
  [ -f "$target" ] || continue
  existed=1
  if grep -qF "$MARKER" "$target"; then
    printf '%s already references coding-skills (marker found). Skipping.\n' "$target"
  else
    append_block "$target"
    printf 'Appended coding-skills reference to %s\n' "$target"
    patched=$((patched + 1))
  fi
done

if [ "$existed" -eq 0 ]; then
  printf '# Project instructions\n' > CLAUDE.md
  append_block CLAUDE.md
  printf 'Created CLAUDE.md with coding-skills reference.\n'
fi
