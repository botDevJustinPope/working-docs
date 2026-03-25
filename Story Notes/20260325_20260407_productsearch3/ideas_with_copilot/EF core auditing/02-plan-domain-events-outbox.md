# Plan 2: Domain Events + Outbox + Audit Projection

## Summary

This plan moves auditing toward a more DDD-centered model by recording business events rather than just table mutations.

It is the most domain-aligned option of the three, but it also has the largest adoption and platform cost. In this codebase, it should be treated as additive to technical auditing rather than an immediate replacement for row-level audit coverage.

## Core idea

Instead of centering the audit trail on table changes, center it on domain behavior.

Examples:

- `AccountCreated`
- `TenantUpdated`
- `PlanRemoved`
- `BuilderTrainingLinkDeleted`

Those events would be raised by aggregates or use cases, persisted through an outbox table, and projected into a queryable audit read model such as:

- `AuditEvent`
- `AuditProjection`
- optional aggregate-specific read models

The resulting trail emphasizes business intent, actor identity, and aggregate meaning.

## How it would fit this codebase

### New infrastructure needed

This option would require several platform concepts that the codebase does not currently have in generalized form:

- domain event contracts
- aggregate event collection
- outbox persistence
- dispatcher or projector
- idempotent event processing
- versioning / replay rules
- actor and tenant correlation propagation

### Relationship to existing patterns

This plan is conceptually closest to the existing `EntityHistory` pattern because both are business-aware and code-first.

However, it is much broader in scope than the current manual history entities. It would turn isolated history patterns into an actual cross-cutting event pipeline.

## Strengths

- Best alignment with DDD and aggregate boundaries.
- Captures business intent instead of only row state.
- Encourages explicit modeling of meaningful changes.
- Supports rich audit UX and business reporting.
- Avoids treating every audit need as a persistence problem.

## Weaknesses

- Does not automatically provide forensic row-level coverage.
- Requires significant platform work before it provides value everywhere.
- Demands adoption discipline across many services and aggregates.
- Legacy write paths cannot participate naturally without adapters or decorators.
- Replacing z-table consumers would require new projections or compatibility layers.

## Critique summary

The critique pass considered this plan promising but too optimistic if positioned as a direct replacement.

The strongest critique points were:

- it should be **additive, not a replacement**
- business events do not cover every low-level mutation the way SQL triggers do
- outbox + projector + replay + idempotency is significant platform work
- legacy DAL decoration is harder than it sounds in a `TransactionScope` world

The critique also noted that existing consumers may depend on row-style audit semantics, so any move to event-based auditing would need compatible projections rather than a clean break.

## Recommended rollout

1. Inventory current audit consumers and define the target event envelope.
2. Pilot domain events on one EF aggregate that already has explicit history behavior.
3. Persist events via an outbox in the same transaction.
4. Build a projection optimized for reporting and support workflows.
5. Keep the technical row-change audit layer in place while the business audit stream matures.
6. Add adapters around selected legacy flows only where the business value is high.
7. Treat full trigger retirement as a separate later decision, not a prerequisite.

## Best use of this plan

Use this plan if the goal is:

- to get a high-quality business audit story,
- to model meaningful actions rather than raw persistence deltas,
- and to move the modern domain toward explicit event-driven behavior.

## Where this plan is not enough

This plan is not enough if the goal is to preserve the current guarantee that every mutation is recorded regardless of caller.

On its own, it is also not the quickest path to parity in a system with large non-EF write surfaces.

## Verdict

This is the **best long-term DDD option**, but not the best immediate replacement for the current SQL-trigger auditing model.

If chosen, it should ride alongside a technical audit layer rather than trying to replace it from day one.
