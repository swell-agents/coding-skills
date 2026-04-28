---
purpose: Documents the optional docs/architecture.md convention that reviewing-changes leans on for the architecture pass
---

# `docs/architecture.md` — optional architecture map convention

The architecture pass in this skill works best when the project has a short, authoritative document mapping classes/modules to responsibilities. This document is **optional** — when missing, the pass falls back to general principles (SOLID, DDD, layer hygiene). When present, it becomes the source of truth for "is this class doing what it's supposed to?"

## Recommended structure

A single Markdown file at `docs/architecture.md` (or whatever path the project documents in `CLAUDE.md` / `AGENTS.md` / `README.md`):

```markdown
# Architecture

## Modules / packages

| Module | Responsibility | Depends on |
|---|---|---|
| `auth/` | issue and verify session tokens; password hashing | `db/`, `crypto/` |
| `orders/` | order lifecycle (create → pay → fulfil → close) | `db/`, `inventory/`, `payment/` |
| `inventory/` | stock counts, reservations, releases | `db/` |
| `payment/` | charge/refund via external PSP; idempotency keys | `crypto/` |

## Layering

   web → application → domain → infrastructure
                 ↑           ↑
                 └── never points back ──┘

## Key invariants

- An `Order` is never paid more than once (idempotency-key constraint).
- An `InventoryReservation` releases on cancel or expiry.
- All money values are `Decimal`, never `float`.
```

## What the architecture pass does with this

- **Module responsibility check.** A diff that adds payment-gateway code to `auth/` is a layer/responsibility violation regardless of how clean the code is.
- **Dependency direction check.** If `domain/` starts importing `infrastructure/`, that's an arrow pointing the wrong way.
- **Invariant check.** When the pass sees a change near an enumerated invariant, it specifically tests whether the invariant still holds.

## When to write or update it

- **Write it once** at the start of a project, even if rough. A bad version beats none — it gives the review pass something to point at.
- **Update it when** a module's responsibility changes (often during a big refactor or feature merge), or when a new module appears.
- **Don't update it for every PR.** The map is structural; PRs are change events. If every PR triggers a map edit, the map is being used as a changelog — wrong tool.

## When it's missing

The architecture pass falls back to:

- SOLID, especially Single Responsibility — flag classes/modules that have grown a second responsibility.
- DDD — bounded contexts inferred from package layout.
- Clean Architecture — direction of dependencies (domain shouldn't import infrastructure).

A finding in this fallback mode should usually carry a **Minor "consider documenting"** suggestion to write the map.
