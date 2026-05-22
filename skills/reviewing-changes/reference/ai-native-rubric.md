# AI-Native Coding Rubric

> Compact rubric for the `ai-native-reviewer` agent. Each rule is grounded in published empirical work on AI-native coding; citation keys (e.g. `[vitale2026impact]`) point to the underlying papers — search arXiv or Google Scholar by key. The rubric is maintained manually; updates reach the agent via the next plugin release.

## Rule R1 — Comments must convey WHY, not WHAT

Comments are load-bearing for LLM coding (bug-fixing ~3× [vitale2026impact]; code-generation accuracy span −90%…+67% depending on quality [imani2025inside]; legacy-code comprehension improves substantially [sabetto2025impact]). Inaccurate comments degrade reasoning ~23% (CodeCrash). The rule is not "skip comments to save context" — that intuition is empirically wrong. The rule is:

- Write comments only for invariants, magic numbers with derivation, hidden constraints, security assumptions, or surprising behaviour.
- Do **not** write comments that restate the code (`// increment counter`) or describe scope/PR context (`// added for the X flow`).
- Magic numbers without comment = anti-pattern (Anthropic Skills authoring guide, [imani2025inside] internal-concept activation).
- Stale comment = comment that does not match the code it documents = Major.

## Rule R2 — Durable agent context belongs in instruction files

Empirical: AGENTS.md cuts agent runtime −28.64% and output tokens −16.58% [lulla2026impact]; AGENTS.md is the emerging interoperable standard across Claude Code, Codex, Cursor, Copilot, Gemini in 2,923 OSS repos [galster2026configuring]; effective manifests are action-oriented (Build/Run, Architecture, Conventions) [chatlatanagulchai2025use]; cursor rules cluster into 5 themes (Conventions, Guidelines, Project Information, LLM Directives, Examples) [jiang2025empirical].

- Project must have **at least one** of AGENTS.md / CLAUDE.md / `.cursor/rules/` at repo root. Presence is the bar; absence is the only Major.
- Recommended (but not required) sections when authoring a fresh file: Build/Run, Test, Architecture summary, Conventions, Never-do. Treat as guidance, not a checklist to grade against — content can also live in linked skills, ADRs, or per-language convention files.
- Every workflow / Make-target / file referenced in the instruction file must actually exist (broken pointer = Major).
- Static rules decay mid-session [ma2026zoro] — long-session projects benefit from a re-anchor trigger ("Before each new subtask, re-verify constraints"), but its absence is at most Minor.

### R2.1 — Single source of truth across instruction files

When multiple instruction files coexist (AGENTS.md + CLAUDE.md + .cursor/rules/), one is canonical and the others are either thin pointers (`See @AGENTS.md` / `@AGENTS.md`) or hold only tool-specific extensions (e.g., a CLAUDE.md section listing `/coding-skills:*` slash commands that other tools won't honor). Recommended canonical: **AGENTS.md** — emerging interoperable standard across Codex, Claude Code, Copilot, Cursor, Gemini per [galster2026configuring]; Cursor has explicitly deprecated `.cursorrules` in favor of AGENTS.md.

Duplicating substantive content (build commands, conventions, architecture summaries) across multiple files = **Major**. Drift between copies produces contradictory documentation, which is the CodeCrash failure mode (23% reasoning collapse from misleading inline guidance) at the manifest layer. Detection: any non-pointer file ≥10 lines that overlaps with the canonical file's content beyond a thin tool-specific delta.

Acceptable patterns:
- One canonical file (AGENTS.md), no others — simplest.
- AGENTS.md canonical + CLAUDE.md as one-line pointer (`@AGENTS.md`) for harnesses that auto-load only `CLAUDE.md`.
- AGENTS.md canonical + tool-specific extensions in CLAUDE.md / `.cursor/rules/*.mdc` containing only what the canonical file cannot express (slash commands, IDE-rule glob scopes).

## Rule R3 — Tests prefer real objects over mocks

Empirical: agents generate mocks in 36% of test commits vs 26% for humans [hora2026are]. Mocked tests are easier for agents to produce but provide weaker correctness guarantees.

- Mock only at true I/O boundaries (HTTP, filesystem, time, network, external processes).
- Hand-rolled fakes that satisfy real interfaces > heavy mocking frameworks (gomock, mockery, testify/mock).
- TDD-first for delegated work: failing test commits before implementation; reduces "agent passes its own tests" failure mode.

## Rule R4 — Architectural decisions need ADRs (Spec-Kit projects only)

Empirical: agents make 5 categories of implicit architectural decisions silently (framework selection, task decomposition, default configuration, scaffolding, integration protocols) — "vibe architecting" [konrad2026architecture]. Agentic refactoring stays shallow (median class LOC delta −15.25 [horikawa2025agentic]) — structural redesign remains human work.

**Scope:** This rule applies **only to projects using Spec Kit** (detected by presence of `specs/` directory with block-structured `plan.md` / `tasks.md` artefacts, or a `.specify/` config). Non-Spec-Kit projects: skip R4 — record "N/A (not a Spec-Kit project)" and move on. The ADR discipline assumes the upstream planning artefacts that Spec Kit produces; outside that context, ADRs duplicate work that lives in PR descriptions and design docs.

For Spec-Kit projects:

- Every prompt-level architectural choice (framework, schema, protocol, deployment topology) → ADR in `docs/adr/`.
- Bare "refactor this module" delegations without target structure → Major.
- ADR includes: context, decision, consequences, alternatives considered, file:line references.

## Rule R5 — Code review and PR hygiene survive AI throughput

Empirical: 83.8% PR acceptance rate is reviewer behaviour, not correctness signal [watanabe2025use]. Autonomous-agent deployment causes persistent +18-39% rise in static-analysis warnings and cognitive complexity [agarwal2026ai].

- CI lint pin must be a fixed version, not `latest`. `golangci-lint version: latest` = Critical (non-reproducible gate).
- PR diff > 1000 lines without commit-by-commit decomposition = Minor (one logical change per PR).
- Security stack present where stack supports it (gosec + govulncheck + semgrep for Go; pip-audit for Python; solhint for Solidity).
- Every claim in AGENTS.md about a CI gate must correspond to an actual workflow file. Missing referenced workflow = Major.

## Rule R6 — Conversational interaction is iterative, not one-shot

Empirical: progressive specification dominates real developer-AI sessions [tang2026programming]; incremental collaboration resolves 83% of issues vs 38% for one-shot delegation (Kumar et al., cited in [tang2026programming]).

- Tasks decomposed to verifiable-output scale per prompt.
- One-shot delegation of multi-day features without intermediate verification = Major.
- Spec Kit `tasks.md` block structure satisfies this when used.

## Rule R7 — Minimize context: delete, don't tombstone

Empirical: every line in AGENTS.md / CLAUDE.md / skill files / agent definitions loads before every turn, so context the agent doesn't actually use is subtracted from the conversation budget. Anthropic context-engineering guidance is "the smallest possible set of high-signal tokens" [anthropic2026context]; hand-curated context files outperform LLM-generated ones in 5/8 settings, with auto-generation adding 2.45–3.92 extra steps per task and 20–23% inference cost [augment2026agentsmd]; long context also triggers "lost in the middle" rule dropout in long sessions [ma2026zoro].

- **Delete, don't tombstone.** When a rule / section / comment is removed, remove it. No `(removed)` markers, no commented-out blocks, no "previously this said …" preambles. Git history is the audit trail.
- **Shorten when you can.** If a passage can be cut without losing decision-relevant content, cut it. One real snippet beats three paragraphs of description.
- Applies to: this rubric, SKILL.md, AGENTS.md / CLAUDE.md, agent definitions, slash-command bodies, in-code comments.

## Rule R8 — Mechanical checks must be in CI

A small subset of this rubric is deterministic and cheap: it should not depend on a per-PR LLM agent. The `coding-skills` plugin ships three minimal templates covering the truly-mechanical parts of R2, R3, R5:

- `skills/reviewing-changes/reference/ai-native-templates/check-ai-practices.sh` — three checks: (a) instruction file (AGENTS.md / CLAUDE.md / .cursor/rules/) exists at repo root [R2]; (b) mock-framework imports detected in `*_test.go` [R3, pre-screen for judgement pass]; (c) PR diff size threshold [R5].
- `skills/reviewing-changes/reference/ai-native-templates/ai-practices.yml` — GitHub Action wrapping `check-ai-practices.sh` on PR.
- `skills/committing-changes/templates/pr-size.yml` — GitHub Action using `codelytv/pr-size-labeler` that labels the PR `size/xs..size/xl` and fails on `size/xl` (>1000 changed lines, excluding tests, docs, lockfiles, vendored/generated files) [R5].

Agent verifies template installation by comparing the plugin's reference copy to the project's installed copy via `Read` + content diff.

- Templates not installed → Minor per missing template (concrete fix: copy command).
- Template installed but content differs from plugin reference → Minor (project may have legitimately customised; do not auto-fail).
- Everything in this rubric outside of the three checks above is judgement-pass for the agent. Do not mechanise rules whose application is contextual.
