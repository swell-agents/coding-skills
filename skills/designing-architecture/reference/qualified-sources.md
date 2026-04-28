---
purpose: Curated research sources for library selection, architecture patterns, and technology evaluation
---

# Qualified sources

The architect skill researches *qualified* resources — community- or industry-vetted catalogues — not arbitrary blog posts. Sorted by use case.

## Library discovery

| Source | What it's good for |
|---|---|
| `github.com/sindresorhus/awesome` | Master index of every `awesome-*` list. Start here. |
| `awesome-<language>` (e.g. `awesome-python`, `awesome-rust`, `awesome-go`, `awesome-solidity`) | Curated list of well-maintained libraries by language, organised by topic. |
| `awesome-<domain>` (e.g. `awesome-machine-learning`, `awesome-web-scraping`, `awesome-distributed-systems`) | Cross-language curation by problem domain. |
| GitHub Search (`gh search repos`) | By stars, language, topic tags. Sort by `--sort=updated` to find actively maintained options. |
| **PyPI** (`pypi.org`) / **npm** (`npmjs.com`) / **crates.io** / **pkg.go.dev` | Package registries with download stats, dep counts, and last-release dates. |
| **Libraries.io** | Cross-platform metrics — useful for comparing the same dependency across registries. |

## Architecture patterns

| Source | What it's good for |
|---|---|
| **Refactoring.guru** | Design pattern catalogue with diagrams and example code in many languages. Best starting point for "which pattern is this?" |
| **Martin Fowler's catalogue** (`martinfowler.com/eaaCatalog/`) | Enterprise patterns (Repository, Unit of Work, Service Layer, etc.). Authoritative. |
| **Fowler's blog** | Big-picture architecture (microservices, event-sourcing, CQRS). |
| **Microsoft Architecture Center** | `learn.microsoft.com/azure/architecture/patterns/` — cloud-flavoured patterns with explicit trade-offs. |
| **Google Cloud Architecture** | `cloud.google.com/architecture` — reference architectures with Google-specific implementations. |
| **AWS Well-Architected Framework** | Five-pillar framework (operational excellence, security, reliability, performance efficiency, cost). |

## Technology evaluation

| Source | What it's good for |
|---|---|
| **ThoughtWorks Technology Radar** (`thoughtworks.com/radar`) | Quarterly technology maturity assessment (Adopt / Trial / Assess / Hold). Best signal of "is this safe to bet on?" |
| **StackShare** (`stackshare.io`) | Real-world technology stacks — useful sanity check on combinations that work in production. |
| **DB-Engines** (`db-engines.com`) | Database popularity trends; comparison matrix per workload type. |
| **CNCF Landscape** (`landscape.cncf.io`) | Cloud-native ecosystem map — orchestration, observability, networking, runtime. |

## Best practices

| Source | What it's good for |
|---|---|
| **12-Factor App** (`12factor.net`) | The canonical service-design checklist. |
| **OWASP** (`owasp.org`) | Security best practices — see `reviewing-changes/reference/owasp-checklist.md`. |
| **Language style guides** | PEP 8 + PEP 257 (Python), Effective Go, the Rust API Guidelines. |

## Anti-sources

These sources are popular but unreliable for architecture decisions:

- **Hacker News comments.** Useful for vibes; never primary source.
- **Stack Overflow.** Great for "how do I use X"; bad for "should I use X."
- **Single tutorials / blog posts.** A pattern in one article is one opinion. Look for cross-source corroboration.
- **AI-generated comparisons.** Confidently wrong about library activity and feature support.

## How to actually use these

1. Start with the relevant `awesome-*` list and the ThoughtWorks Radar.
2. Pick three candidates and check each on GitHub: stars, last commit, release cadence, open-issue ratio.
3. Read the official README of each candidate; verify the use case is supported.
4. Cross-reference DB-Engines / StackShare / Libraries.io for the second opinion.
5. Decide; document the trade-offs.

If a candidate looks promising but you can't find any of these signals on it, treat it as untested — don't bet a feature on it.
