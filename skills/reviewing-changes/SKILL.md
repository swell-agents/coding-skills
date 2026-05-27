---
name: reviewing-changes
description: Five-pass review of a diff: code, security, architecture, acceptance, AI-native.
allowed-tools: Read, Grep, Glob, Bash(git diff *), Bash(git log *), Bash(git show *), Bash(git status *), Bash(git rev-parse *), Bash(gh pr view *), Bash(gh pr diff *), Bash(gh pr list *), Bash(uv run ruff *), Bash(uv run mypy *), Bash(uv run pip-audit *), Bash(npm audit *), Bash(golangci-lint *), Bash(govulncheck *), Bash(gosec *), Bash(solhint *), Bash(forge fmt --check), WebSearch, WebFetch
---

## Process

Always run the five passes in order. Findings flow into one combined verdict.

### 1. Read the rules

Before any pass, internalise the language-rule skill that matches the diff (python-conventions, go-conventions, solidity-conventions, …) and engineering-philosophy. The rule skills are the source of truth — don't invent additional standards.

### 2. See the change

```
git diff <base>...HEAD
git log <base>..HEAD --oneline
```

For a GitHub PR:

```
gh pr view <N>
gh pr diff <N>
```

### 3. Pass 1 — Code quality

Check, in order:

- **Philosophy violations** — over-engineering (KISS, YAGNI), duplication (DRY), magic behaviour (No Magic), copy-paste-modified blocks.
- **Redundant entity & local-pattern reuse**: when the diff adds a function, accessor, or code path the repo already provides (an auto-generated getter, a wider getter that subsumes a narrower one, an idiom a sibling file implements), reuse the existing form instead of a second variant. DRY and YAGNI span the whole repo, not just this diff.
- **SOLID violations** — Single Responsibility first; flag classes/files that grew a second responsibility.
- **Naming, readability, complexity** — function lengths, parameter lists, deeply nested conditionals, clever one-liners that hide intent.
- **Test coverage** — was the change tested? If TDD discipline applied, was the failing test committed first?
- **Tooling compliance** — ruff/mypy strict for Python, golangci-lint for Go, solhint:all for Solidity, forge fmt --check for Solidity formatting.
- **Configuration safety** — production timeouts, connection pools, missing retries, missing rate limits.

### 4. Pass 2 — Security audit

Check, in order, against OWASP Top 10:

- **Injection** — SQL, command, LDAP, template, header injection via unsanitised input.
- **Broken authentication** — weak token handling, missing MFA, fragile session management.
- **Broken access control** — missing authz checks, privilege escalation, IDOR (insecure direct object reference).
- **Sensitive data exposure** — secrets in logs, error messages, or response bodies; missing TLS; weak ciphers.
- **Misconfiguration** — overly permissive CORS, missing security headers, debug endpoints exposed.
- **Vulnerable components** — `pip-audit` / `npm audit` / `govulncheck` / dep CVEs.
- **XSS** — unencoded output rendered as HTML/JS; missing CSP.
- **Insecure deserialisation** — `pickle.loads` on untrusted input, similar in JS/Java.
- **Insufficient logging and monitoring** — security-relevant events not logged, no alerting.
- **Cryptographic issues** — weak algorithms, hardcoded keys, missing key rotation, predictable IVs.
- **Smart-contract specific (if Solidity)** — reentrancy, integer over/underflow, unchecked external calls, access control on `onlyOwner`-style modifiers, front-running, MEV exposure, signature replay.

See `reference/owasp-checklist.md` for the canonical mapping with attack-vector notes.

### 5. Pass 3 — Architecture consistency

- **Architecture map** — does the diff respect the `docs/architecture.md` (or equivalent) responsibility split? See `reference/architecture-map-pattern.md`.
- **Layer violations** — dependencies pointing the wrong way (e.g., domain importing infrastructure).
- **Boundary erosion** — public methods sneaking into private packages; circular dependencies.
- **Missing abstractions** — same logic implemented twice with minor variations.
- **Custom code where a library exists** — presumptive Critical when the diff reinvents primitives the ecosystem already solves (cryptography, encoding, standard-format parsers, wire codecs, retry/rate-limiting, ORMs, validators). Major for general utility code with a battle-tested equivalent. Three sub-checks:
  - **Already in tree** — if the project's lockfile already pulls in a library that exports the function being hand-rolled, the hand-rolled version is Critical regardless of LoC. Don't import one symbol and reinvent the others.
  - **Justification still valid** — comments that justified hand-rolling earlier ("avoid coupling", "keep dep tree small", "minimise binary size") must still hold for *this* diff. Once the dep is in the tree, the original reason has expired.
  - **What to grep for** — custom encoders for standard formats, raw wire-protocol bytes as constants, hand-rolled crypto primitives, hand-written auth-token verification, custom retry-with-backoff loops.
- **Pattern compliance** — clean architecture / DDD bounded contexts, only when the project documents a pattern.

### 6. Pass 4 — Acceptance / intent alignment

Does the diff actually solve the contract — linked GitHub issue, PR description, or active Spec Kit `specs/<NNN>-<feature>/tasks.md` Block? Cover the three axes:

- **Drift** — diff implements something related but not the asked feature.
- **Partial** — diff covers some required behaviours but misses others.
- **Overreach** — diff includes changes the issue did not request.

See `agents/acceptance-auditor.md` for the full procedure.

### 7. Pass 5 — AI-Native-Coding Practices

Validates the diff and the surrounding project against the empirically-grounded rubric for working with AI coding agents. Eight rules, citation-grounded:

- **R1** — Comments WHY not WHAT (load-bearing for LLM coding; inaccurate comments harmful).
- **R2** — Durable agent context belongs in instruction files. At least one of AGENTS.md / CLAUDE.md / `.cursor/rules/` must exist at repo root; section structure is guidance, not a graded checklist.
- **R3** — Tests prefer real objects over mocks; mock only at I/O boundaries.
- **R4** — Architectural decisions need ADRs — **only for projects using Spec Kit** (detected via `specs/` + `plan.md`/`tasks.md` or `.specify/`). Non-Spec-Kit projects skip R4.
- **R5** — Code review and PR hygiene survive AI throughput (small commits, decomposed PRs).
- **R6** — Conversational interaction is iterative, not one-shot.
- **R7** — Minimize context: delete, don't tombstone. Every line in always-loaded files costs every turn — remove rather than mark removed.
- **R8** — Mechanical-rubric subset belongs in CI; bundled templates ship with the plugin.

The rubric, with citations, lives at `reference/ai-native-rubric.md`. The mechanical-check templates ship at `reference/ai-native-templates/`. See `agents/ai-native-reviewer.md` for the full procedure.

## Output

```
## Quality Gate Summary

| Review              | Verdict        | Critical | Major | Minor |
|---------------------|----------------|----------|-------|-------|
| Code                | pass/warn/fail | N        | N     | N     |
| Security            | pass/warn/fail | N        | N     | N     |
| Architecture        | pass/warn/fail | N        | N     | N     |
| Acceptance          | pass/warn/fail | N        | N     | N     |
| AI-Native Practices | pass/warn/fail | N        | N     | N     |

**Overall**: PASS / NEEDS WORK / FAIL

### Action items
1. <Critical/Major items, ordered>
```

For each individual finding:

- **Rule** — which rule was violated (with the language-rule skill or engineering-philosophy reference) or "best practice" if no codified rule.
- **Severity** — Critical / Major / Minor.
- **Location** — `file:line`.
- **Issue** — what's wrong and (for security) the attack vector.
- **Fix** — concrete suggestion, with a short code example when it clarifies the change.

## Behavioural traits

- Constructive, educational tone. Teach; don't just flag.
- Specific, actionable feedback. "This is too complex" without a fix is useless.
- Severity matches reality. Critical for "this could ship a bug or a CVE today"; Major for "this will hurt within six months"; Minor for style and polish.
- Practical over theoretical security risks. If an attack requires three impossible preconditions, mark Minor.
- Defence in depth. Multiple weak controls beat one perfect control.
- Read-only. This skill never edits the diff itself; it reports.

## Cross-references

- `running-tdd-cycles` — preceding workflow; review confirms TDD discipline.
- `committing-changes` — commit-message + branch hygiene checks fold into the code-quality pass.
- `python-conventions` / `go-conventions` / `solidity-conventions` — the language rule the diff is being checked against.
- `engineering-philosophy` — KISS, YAGNI, DRY, SOLID weights for code-quality and architecture passes.

## Reference

- [reference/owasp-checklist.md](reference/owasp-checklist.md) — canonical OWASP Top 10 mapping with attack vectors and fix patterns.
- [reference/architecture-map-pattern.md](reference/architecture-map-pattern.md) — the optional `docs/architecture.md` convention this skill expects.

The live subagent shims that wrap this skill for parallel execution live one level up:

- `agents/code-reviewer.md` — Pass 1 (code quality)
- `agents/security-auditor.md` — Pass 2 (security)
- `agents/architect-review.md` — Pass 3 (architecture)
- `agents/acceptance-auditor.md` — Pass 4 (acceptance / intent)
- `agents/ai-native-reviewer.md` — Pass 5 (AI-native-coding practices)

Each is a thin shim that reads this `SKILL.md` (and, for Pass 5, also `reference/ai-native-rubric.md`) and applies its scoped pass; the `/coding-skills:review` slash command spawns the five in parallel under `model: opus`.
