---
purpose: Compact design pattern catalogue with applicability tests, used during pattern selection in designing-architecture
---

# Pattern catalogue

Patterns grouped by Gang-of-Four category and architectural scope. Each entry is the *applicability test* — when a pattern earns its keep — not the implementation. For implementation, see Refactoring.guru.

The skill applies the **YAGNI test** to every selection: if you can't articulate the concrete problem the pattern solves in the current feature, don't use it. Pattern tourism creates indirection without value.

## Creational

- **Factory Method** — *use when* construction logic depends on a runtime decision (subtype/config) and you want callers to be agnostic to it. *Don't use when* there's only one product type — direct instantiation is simpler.
- **Abstract Factory** — *use when* you need families of related products that vary together (UI widget kit per OS). Rare outside cross-platform code.
- **Builder** — *use when* an object has many optional parameters and a phased construction (HTTP request builders, query builders).
- **Singleton** — *use when* state is genuinely global (process-wide config, connection pool). *Don't use as* a global-variable convenience; it kills testability.
- **Prototype** — *use when* cloning is materially cheaper than reconstructing.

## Structural

- **Adapter** — *use when* an existing implementation has the right behaviour but the wrong interface. Common when wrapping third-party libraries.
- **Bridge** — *use when* an abstraction and its implementation should vary independently. The classic case is multiple persistence backends behind one repository interface.
- **Composite** — *use when* clients should treat individual objects and compositions of them uniformly (filesystem trees, UI component hierarchies).
- **Decorator** — *use when* you need to add behaviour to instances at runtime without subclass explosion (logging, caching, retry around an HTTP client).
- **Facade** — *use when* a subsystem has a complex API and most callers only need a slice of it.
- **Flyweight** — *use when* you have huge numbers of nearly-identical objects and memory is bounded.
- **Proxy** — *use when* the real subject is expensive to access (lazy loading, remote calls) or you need access control / instrumentation around it.

## Behavioural

- **Chain of Responsibility** — *use when* a request should be processed by one of several handlers and the choice is dynamic (middleware pipelines).
- **Command** — *use when* you need to parameterise actions (undo/redo, queued operations, RPC).
- **Iterator** — language-built-in in most modern languages; rarely an explicit pattern decision.
- **Mediator** — *use when* component-to-component communication has become a graph; centralise it through a mediator.
- **Memento** — *use when* you need snapshots without exposing internals (undo systems, transactional rollback).
- **Observer** — *use when* one object's state change should notify many others; consider event-bus / pub-sub at scale.
- **State** — *use when* an object's behaviour depends on a state machine and the state count is non-trivial.
- **Strategy** — *use when* an algorithm has interchangeable variants chosen at runtime (sort comparator, compression algorithm, retry policy).
- **Template Method** — *use when* a multi-step algorithm has fixed structure but variable steps. Often replaced by Strategy + composition; favour composition.
- **Visitor** — *use when* you need to add operations to a stable type hierarchy without modifying the types. Heavy machinery; reach for it only when other options have failed.

## Domain (DDD)

- **Repository** — *use when* persistence concerns should be hidden from the domain. The collection-like interface (`add`, `remove`, `find_by_id`) is the test; if your "repository" has 30 query methods, it's actually a DAO.
- **Unit of Work** — *use when* multiple repository operations should commit or rollback as one transaction.
- **Specification** — *use when* domain queries grow combinatorially (filter rules, eligibility checks); composable specs avoid `if`-tree sprawl.
- **Value Object** — *use when* an attribute is defined by its value and is immutable (Money, EmailAddress, GeoCoordinate). Replaces primitive-obsession smells.
- **Entity** — *use when* identity matters across changes (User, Order). Entities have ID; value objects don't.
- **Domain Event** — *use when* something domain-meaningful happened that other parts of the system care about (`OrderPaid`, `UserDeactivated`). Pairs with the Outbox pattern for reliability.

## Architectural

- **Hexagonal / Ports-and-Adapters** — *use when* the domain should be independent of frameworks, databases, and transport. Default for non-trivial services.
- **Pipes & Filters** — *use when* a stream of data passes through stateless transformations (ETL, log processing).
- **Event-Driven** — *use when* services communicate asynchronously and the producer doesn't care who consumes. Pairs with message brokers.
- **CQRS** — *use when* read and write models diverge enough that one schema can't serve both well. Adds operational complexity; don't reach for it lightly.
- **Saga** — *use when* a long-running business transaction spans multiple services and must be coordinated with compensating actions.
- **Outbox** — *use when* a domain event must be published reliably alongside a database commit. The transactional outbox + relay is the canonical fix for "I dispatched the event but the DB rolled back."
- **Strangler Fig** — *use when* replacing a legacy system incrementally. The new system shadows the old until the old can be deleted.
- **Branch by Abstraction** — *use when* a long-running internal change should ship behind an interface so trunk stays releasable.

## Quick selection heuristics

- **Two implementations of the same thing chosen at runtime** → Strategy.
- **Optional cross-cutting wrapping** → Decorator.
- **Hide a complex collaborator** → Facade or Adapter.
- **Persistence behind a clean interface** → Repository (and Unit of Work for batched commits).
- **Multi-step business transaction across services** → Saga + Outbox.
- **Rich state-dependent behaviour on one object** → State.
- **Add operations to a closed hierarchy** → Visitor (last resort).
- **Cross-cutting concerns on every request** → Chain of Responsibility (middleware).
