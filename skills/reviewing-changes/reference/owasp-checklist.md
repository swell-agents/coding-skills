---
purpose: OWASP Top 10 (2021) mapping with attack vectors and fix patterns for the security pass
---

# OWASP Top 10 — review checklist

The security pass in `SKILL.md` runs through this list. Each entry has the failure mode, an attack vector example, and the canonical fix pattern. Order matches OWASP's 2021 edition.

## A01 — Broken access control

- **Failure mode:** an endpoint that should require authorisation lacks the check, or relies on client-side hiding.
- **Attack vector:** Direct URL/API hit (`/admin/users` from a non-admin token); IDOR (`GET /orders/123` returns someone else's order because `user_id` isn't checked against the session).
- **Fix:** centralise authz at the boundary (decorator/middleware, not scattered `if` checks); test every protected route under three identities (anon, regular user, admin).

## A02 — Cryptographic failures

- **Failure mode:** weak algorithm, hardcoded key, missing TLS, predictable IV, MD5/SHA1 for security uses.
- **Attack vector:** offline brute-force; man-in-the-middle on plaintext channels; cross-tenant key reuse.
- **Fix:** use libraries (`cryptography`, `libsodium`); never roll your own crypto; rotate keys with KMS; TLS 1.2+ everywhere; hash passwords with `argon2id` (or `bcrypt` minimum).

## A03 — Injection

- **Failure mode:** unsanitised input concatenated into a query, command, template, or LDAP filter.
- **Attack vector:** SQL injection (`' OR 1=1 --`), command injection (`; rm -rf /`), template injection (`{{ 7*7 }}` in Jinja2), LDAP injection.
- **Fix:** parameterised queries (always); avoid `subprocess.run(shell=True)`; allowlist inputs; use ORMs.

## A04 — Insecure design

- **Failure mode:** the threat model is wrong before any code is written. Missing rate limits, missing audit log, "we'll add MFA later", trust boundary in the wrong place.
- **Attack vector:** depends on the missing control; usually credential stuffing, abuse, or repudiation.
- **Fix:** name the trust boundary; explicitly list controls (auth, authz, rate limit, audit, monitoring); design for least privilege.

## A05 — Security misconfiguration

- **Failure mode:** debug endpoints exposed, default creds, overly permissive CORS, verbose stack traces in prod, missing security headers.
- **Attack vector:** discovery via fingerprinting, easy pivot once one defaulted credential is found.
- **Fix:** infra-as-code with security baked in; SAST on CI; check `Content-Security-Policy`, `Strict-Transport-Security`, `X-Frame-Options`, `Referrer-Policy`.

## A06 — Vulnerable / outdated components

- **Failure mode:** dependency with a known CVE, unmaintained library, transitive vulnerability.
- **Attack vector:** any public exploit for the CVE, often pre-auth.
- **Fix:** `pip-audit` (Python), `npm audit` (Node), `govulncheck` (Go), `cargo audit` (Rust); Dependabot enabled and PRs merged promptly; pin versions; review supply chain.

## A07 — Identification and authentication failures

- **Failure mode:** weak token handling (predictable IDs, no expiry, in URLs), missing MFA, brute-forceable login, session fixation.
- **Attack vector:** credential stuffing, session hijacking, account takeover.
- **Fix:** use a battle-tested identity provider (OAuth2/OIDC); short token lifetimes + refresh; rate-limit + lockout; MFA for privileged operations.

## A08 — Software and data integrity failures

- **Failure mode:** insecure deserialisation, unsigned updates, CI pulling unpinned versions.
- **Attack vector:** malicious payload triggers RCE on `pickle.loads`; supply-chain attack via compromised registry; tampered build artefact.
- **Fix:** never deserialise untrusted data with formats that allow code execution; sign + verify artefacts; pin everything in CI; review the supply chain.

## A09 — Security logging and monitoring failures

- **Failure mode:** auth events not logged; logs not centralised; no alerting on anomalies; logs contain secrets.
- **Attack vector:** undetected breach for months; secrets leaked through log aggregator.
- **Fix:** log auth, authz failures, admin actions, payment events; centralise (SIEM); alert on patterns; redact secrets.

## A10 — Server-side request forgery (SSRF)

- **Failure mode:** server fetches a URL provided by the user without validating the destination.
- **Attack vector:** internal-network probing, cloud-metadata-endpoint exfiltration (`http://169.254.169.254/`).
- **Fix:** allowlist destinations; block link-local + metadata IPs; resolve DNS first and re-check after redirect.

## Smart-contract specific (Solidity)

When the diff touches `.sol` files, also check:

- **Reentrancy** — external call before state update; fix: checks-effects-interactions, or `ReentrancyGuard`.
- **Integer over/underflow** — `^0.8.0` reverts on overflow by default, but `unchecked { ... }` blocks bypass it; review every `unchecked`.
- **Unchecked external calls** — return value of low-level `call` ignored; failures swallowed.
- **Access control** — every privileged function has an `onlyOwner` (or role) modifier; constructor sets owner; ownership transfer is two-step.
- **Front-running / MEV** — public transactions can be sandwich-attacked; consider commit-reveal, slippage parameters, or batched auctions.
- **Signature replay** — signed messages used cross-chain or cross-contract; fix: include `chainid`, `address(this)`, and a nonce in the digest (EIP-712 helps).
- **`tx.origin` for auth** — never; always use `msg.sender`.
- **DELEGATECALL surface** — calling untrusted contracts via `delegatecall` can rewrite storage; review proxy upgrades carefully.
