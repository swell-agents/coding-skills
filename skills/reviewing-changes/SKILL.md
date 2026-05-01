---
name: reviewing-changes
description: Run a layered quality gate over a code change — code quality, security audit, and architecture consistency, in that order. Use after writing or modifying code, before opening or merging a PR, when reviewing a diff or branch, or when asked for a code review, security audit, or architecture review. Produces severity-ranked findings (Critical / Major / Minor) tied to file:line, each with a concrete fix. Covers OWASP Top 10, SOLID, KISS / YAGNI / DRY, ruff + mypy for Python, golangci-lint for Go, solhint for Solidity, and common perf pitfalls (N+1, unbounded loops, leaks, missing indexes). For diffs over ~500 lines or 20 files, scopes the linter sweep to touched packages first and widens on demand. Read-only: never edits the diff, never runs unscoped Bash — every tool is a fixed command pattern (Bash(git diff *), Bash(uv run ruff *), Bash(golangci-lint *)). Composes with python-conventions, go-conventions, solidity-conventions, engineering-philosophy.
allowed-tools: Read, Grep, Glob, Bash(git diff *), Bash(git log *), Bash(git show *), Bash(git status *), Bash(git rev-parse *), Bash(gh pr view *), Bash(gh pr diff *), Bash(gh pr list *), Bash(uv run ruff *), Bash(uv run mypy *), Bash(uv run pip-audit *), Bash(npm audit *), Bash(golangci-lint *), Bash(govulncheck *), Bash(gosec *), Bash(solhint *), Bash(forge fmt --check), WebSearch, WebFetch
---

## Process

Always run the three passes in order. Findings flow into one combined verdict.

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
- **Custom code where a library exists** — flag reinvented validators, parsers, ORMs, retry logic, etc.
- **Pattern compliance** — clean architecture / DDD bounded contexts, only when the project documents a pattern.

## Output

```
## Quality Gate Summary

| Review       | Verdict        | Critical | Major | Minor |
|--------------|----------------|----------|-------|-------|
| Code         | pass/warn/fail | N        | N     | N     |
| Security     | pass/warn/fail | N        | N     | N     |
| Architecture | pass/warn/fail | N        | N     | N     |

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

Each is a thin shim that reads this `SKILL.md` and applies its scoped pass; the `/coding-skills:review` slash command spawns the three in parallel under `model: opus`.
