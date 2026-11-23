---
description: Model a complex business domain with explicit boundaries, applying DDD only where complexity justifies it
---

# Design a DDD core domain

Applies only when business rules dominate and several bounded areas emerge. For CRUD-shaped
projects, rule THR-07 (minimum that solves the problem) wins — say so and stop.

Preset skills: `brainstorming`, `architecture-decision-records`, `test-driven-development`,
`project-memory`. Import if available: `domain-driven-design`, `ddd-strategic-design`,
`ddd-context-mapping`, `ddd-tactical-patterns`, `cqrs-implementation`, `event-store-design`,
`event-sourcing-architect`, `saga-orchestration`.

## Guardrails
- Apply DDD selectively; justify the overhead in a decision record.
- Keep infrastructure out of the domain model.
- Transactional consistency only within an aggregate.
- Context boundaries and anti-corruption layers defined before integrating systems.

## Steps

### 1. Assess fit and scope
Domain complexity versus CRUD; ADR on why DDD, where it stays light, what success looks like;
stakeholders and core goals.

### 2. Strategic model
Core, supporting and generic subdomains; a ubiquitous-language glossary shared with domain experts;
explicit bounded contexts; ownership assigned before tactical decisions.

### 3. Context map
Relationships (shared kernel, customer-supplier, conformist, anti-corruption layer); contracts, DTO
mappings, event formats; ACLs in front of legacy or third-party models.

### 4. Tactical model
Entities and immutable value objects that enforce invariants at construction; aggregates with clear
roots; repository interfaces; domain events on state change. Start from invariants and transaction
boundaries, not tables or endpoints. Test-first.

### 5. Evented patterns, selectively
CQRS where read and write needs diverge; event sourcing where audit or replay is required; sagas or
process managers for cross-context consistency — each with its trade-off recorded.

## Principles
Business language alignment · one aggregate per transaction · an aggregate root is never invalid.
