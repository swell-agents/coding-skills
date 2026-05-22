#!/usr/bin/env bash
#
# Mechanical AI-native-coding checks. Deterministic, cheap, project-agnostic.
# Source rubric: ${CLAUDE_PLUGIN_ROOT}/skills/reviewing-changes/reference/ai-native-rubric.md
#
# Three checks only. Everything else is judgement-pass for the ai-native-reviewer agent.
#
#   R2: instruction file exists at repo root
#   R3: mock-framework imports detected (pre-screen, not auto-fail)
#   R5: PR diff size threshold
#
# Exit codes: 0 = all checks passed (or only warnings), 1 = one or more hard failures.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

PR_BASE="${PR_BASE:-main}"
DIFF_LIMIT="${AI_PRACTICES_DIFF_LIMIT:-1000}"
LARGE_PR_LABEL="${AI_PRACTICES_LARGE_PR_LABEL:-large-pr-ok}"

fail=0
warn=0

#
# R2 — Instruction file at repo root
#
if [[ -f AGENTS.md || -f CLAUDE.md || -d .cursor/rules ]]; then
  echo "[R2 PASS] Instruction file present (AGENTS.md / CLAUDE.md / .cursor/rules/)."
else
  echo "[R2 FAIL] No instruction file found at repo root. Add AGENTS.md (preferred — interoperable across tools) or CLAUDE.md or .cursor/rules/."
  echo "          Empirical: AGENTS.md cuts agent runtime -28.64% / output tokens -16.58% [lulla2026impact]."
  fail=1
fi

#
# R3 — Mock-framework imports (pre-screen, warn only)
#
mock_hits="$(grep -rEln '"github.com/golang/mock/gomock"|"github.com/stretchr/testify/mock"|"github.com/vektra/mockery|"go.uber.org/mock' --include='*_test.go' . 2>/dev/null || true)"
if [[ -n "$mock_hits" ]]; then
  count="$(echo "$mock_hits" | wc -l | tr -d ' ')"
  echo "[R3 WARN] Mock-framework imports found in $count test file(s). Mocks at I/O boundaries are fine; scattered mocks reduce correctness signal [hora2026are]."
  echo "$mock_hits" | sed 's/^/          /'
  warn=1
else
  echo "[R3 PASS] No heavy mock-framework imports in test files."
fi

#
# R5 — PR diff size
#
if git rev-parse --verify "$PR_BASE" >/dev/null 2>&1; then
  # Capture shortstat first so an empty diff (e.g. running on `main` itself
  # via the `push: branches: [main]` trigger) does not collapse the grep
  # pipeline under `set -euo pipefail` (the first grep would exit 1 on
  # empty input and kill the script before R5 ever prints).
  shortstat="$(git diff --shortstat "$PR_BASE...HEAD" 2>/dev/null || true)"
  if [[ -z "$shortstat" ]]; then
    diff_lines=0
  else
    diff_lines="$(echo "$shortstat" | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | grep -oE '[0-9]+' | awk '{s+=$1} END {print s+0}')"
  fi
  if [[ "$diff_lines" -gt "$DIFF_LIMIT" ]]; then
    if [[ "${PR_LABELS:-}" == *"$LARGE_PR_LABEL"* ]]; then
      echo "[R5 SKIP] Diff $diff_lines lines exceeds $DIFF_LIMIT but '$LARGE_PR_LABEL' label is set."
    else
      echo "[R5 FAIL] PR diff is $diff_lines lines (limit: $DIFF_LIMIT). Decompose into smaller commits or apply '$LARGE_PR_LABEL' label."
      echo "          Empirical: small commits keep verification feasible — Fowler 'document ruthlessly' / Larridin AI-native-engineering-team."
      fail=1
    fi
  else
    echo "[R5 PASS] PR diff $diff_lines lines (limit: $DIFF_LIMIT)."
  fi
else
  echo "[R5 SKIP] Base ref '$PR_BASE' not found locally; skipping diff-size check."
fi

#
# Summary
#
echo
if [[ "$fail" -ne 0 ]]; then
  echo "ai-practices: FAIL (one or more hard checks failed)"
  exit 1
elif [[ "$warn" -ne 0 ]]; then
  echo "ai-practices: PASS with warnings"
  exit 0
else
  echo "ai-practices: PASS"
  exit 0
fi
