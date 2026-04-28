---
name: designing-architecture
description: Design technical architecture for a new feature, library selection, or data layer before implementation. Use when starting a new feature, choosing a library, picking a design pattern, or designing a database schema. Researches the ecosystem (awesome-lists, GitHub, package registries, ThoughtWorks Radar, DB-Engines, CNCF Landscape) under a bounded budget — at most 3 candidates compared per decision, at most 5 web fetches per session, one authoritative source per dimension over many shallow ones. Evaluates candidates on stars, recency, license, dep footprint, and docs quality; compares alternatives; emits a TDD-ready implementation plan with components, data flow, and an ASCII diagram. Covers application and database architecture (relational, document, key-value, time-series, graph, search). Read-only: designs only and hands the plan to running-tdd-cycles. Composes with python-conventions, go-conventions, solidity-conventions, engineering-philosophy.
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch, Bash(gh search repos *), Bash(gh repo view *), Bash(gh search code *), Bash(npm view *), Bash(pip show *), Bash(uv pip show *), Bash(uv tree *), Bash(cargo search *), Bash(cargo info *), Bash(go doc *), Bash(go list *)
---

## Methodology

### Phase 1 — Requirements

1. Parse the feature into functional and non-functional requirements (latency, throughput, availability, consistency, failure modes).
2. Identify constraints: language, framework, existing codebase, deployment target, regulatory.
3. Read the project's architecture map (often `docs/architecture.md`) — see `reviewing-changes/reference/architecture-map-pattern.md` for the convention. Identify integration points with existing modules.

### Phase 2 — Technology landscape scan

4. **Discover candidates.** Search awesome-lists (`awesome-<language>`, `awesome-<domain>`), GitHub by topic, package registries (PyPI, npm, crates.io). For data layer questions, also DB-Engines and CNCF Landscape.
5. **Evaluate each candidate** with consistent dimensions:
   - GitHub stars and trend, last commit, release cadence.
   - Open vs closed issue ratio.
   - Documentation quality (fetch the README; check for runnable examples).
   - License compatibility (MIT/Apache/BSD safe; AGPL/GPL needs deliberate decision).
   - Dependency footprint (transitive count, security history).
6. **Cross-check official docs.** Verify the library actually supports the exact use case — a star count doesn't.
7. **Compare alternatives** in a table with consistent rows and explicit trade-offs.

### Phase 3 — Pattern selection

8. Identify candidate patterns from problem shape:
   - **Creational** — Factory, Builder, Singleton (only if state is genuinely global).
   - **Structural** — Adapter, Decorator, Facade, Proxy.
   - **Behavioural** — Strategy, Observer, Command, Chain of Responsibility, State.
   - **Domain** — Repository, Unit of Work, Specification, Value Object.
   - **Architectural** — Hexagonal / ports-and-adapters, Pipes & Filters, Event-Driven, CQRS, Saga, Outbox.
9. Select the **minimum** patterns the problem needs. No pattern tourism.
10. Map selections to the project's conventions; don't introduce a new pattern when an existing one fits.

### Phase 4 — Design

11. Define component structure: classes / modules / interfaces / boundaries.
12. Define data flow: inputs → processing → outputs, including failure paths.
13. Define error-handling strategy (retry, dead-letter, circuit-breaker, idempotency keys).
14. Define configuration, secrets handling, dependency injection.
15. Produce an ASCII diagram showing components, dependencies, and data direction.

### Phase 5 — Implementation plan

16. Decompose into TDD-ready steps. Each step:
    - Sized for one red-green-refactor cycle.
    - Independently testable.
    - Delivers incremental value.
17. Order by dependency (what must exist before what).
18. Hand off to `running-tdd-cycles` for execution. Do not implement here.

## Database architecture overlay

When the design includes a data layer, run a parallel mini-pipeline:

1. **Pick the technology family.**
   - **Relational** (PostgreSQL, MySQL) — strong consistency, complex joins, transactions.
   - **Document** (MongoDB, DynamoDB) — flexible schema, horizontal scale, simple access.
   - **Key-value** (Redis, DynamoDB) — sub-ms reads, cache-like access.
   - **Time-series** (TimescaleDB, InfluxDB, ClickHouse) — append-heavy, time-range queries.
   - **Graph** (Neo4j, Neptune) — multi-hop relationships are first-class.
   - **Search** (Elasticsearch, OpenSearch, Meilisearch) — full-text, faceted filtering.
   - **NewSQL** (CockroachDB, Spanner, YugabyteDB) — global consistency at scale.
   Decide via CAP-theorem framing: which two of consistency, availability, partition tolerance does the workload force?

2. **Schema design.** Conceptual (ER diagram) → logical (3NF or deliberate denormalisation) → physical (data types, partitioning, sharding key). State trade-offs explicitly.

3. **Indexing strategy.** B-tree for equality/range, Hash for exact match, GiST/GIN for full-text/geometry, BRIN for huge ordered tables, partial/filtered indexes for hot subsets. Composite indexes ordered by query selectivity.

4. **Migration plan.** Zero-downtime where possible (expand → backfill → contract). Tooling (Alembic, Flyway, Liquibase, Prisma). Backward + forward compatibility for online deploys.

5. **Security and compliance.** RBAC and row-level security where applicable. At-rest + in-transit encryption. Audit logging for sensitive ops.

## Output

Produce a single Markdown document. The architecture document should be self-contained and feed directly into `running-tdd-cycles`.

```markdown
---
purpose: Architecture design for <feature>
---

# Architecture — <feature>

## 1. Requirements
Functional + non-functional, including SLA targets if relevant.

## 2. Technology selection

### Selected
| Library | Purpose | Stars | Last release | Why |
|---|---|---|---|---|
| ... | ... | ... | ... | ... |

### Rejected
| Library | Reason |
|---|---|
| ... | ... |

### Sources
- [1] <awesome-list URL>
- [2] <official docs URL>
- [3] <ThoughtWorks Radar entry>

## 3. Patterns
The patterns selected and the concrete reason each fits this problem.

## 4. Architecture
ASCII diagram + per-component description.

## 5. Data layer (if applicable)
Technology, schema, indexes, migration plan.

## 6. TDD-ready implementation plan
1. **Step 1: <title>** — <what to implement>; depends on: none; test: <what the failing test pins down>.
2. **Step 2: <title>** — ...
   ...

## 7. Open questions
Decisions that need user input before implementation begins.
```

## Behavioural traits

- **Research before recommending.** Never propose a library without checking GitHub activity, docs, and at least one alternative.
- **Minimum viable architecture.** Design only what the feature needs. No speculative abstractions.
- **Ecosystem first.** Always prefer established libraries to custom code. Check `awesome-*`, package registries, and official docs before writing anything bespoke.
- **Explicit trade-offs.** When choosing between alternatives, state what is gained and what is lost.
- **TDD-ready output.** Decompose every architecture into red-green-refactor-sized steps.
- **Codebase-aware.** Read the architecture map and existing code before designing. Follow established conventions.
- **No pattern tourism.** Apply a pattern only when it solves a concrete problem in the current feature.
- **Recency matters.** Prefer libraries with commits in the last six months and recent releases.

## Cross-references

- `running-tdd-cycles` — receives the implementation plan from this skill.
- `reviewing-changes` — verifies the implementation against this design.
- `python-conventions` / `go-conventions` / `solidity-conventions` — language-specific tooling and idioms feed into the design.
- `engineering-philosophy` — KISS, YAGNI, Use Libraries, No Magic dominate during design.

## Reference

- [reference/architect-agent.md](reference/architect-agent.md) — original Claude-Code architect agent verbatim (model: opus).
- [reference/database-architect-agent.md](reference/database-architect-agent.md) — original Claude-Code database-architect agent verbatim (model: opus).
- [reference/qualified-sources.md](reference/qualified-sources.md) — curated list of research sources (awesome-*, ThoughtWorks Radar, DB-Engines, CNCF Landscape, Refactoring.guru, Fowler's catalogue, 12-factor, OWASP).
- [reference/pattern-catalogue.md](reference/pattern-catalogue.md) — design pattern descriptions with applicability tests.
