# Plan 3: Hybrid Audit Coordinator Across EF Core and Legacy Write Paths

## Summary

This plan introduces a code-first `AuditCoordinator` / `AuditWriter` that is not limited to EF Core.

It is the most pragmatic option for this repository because it acknowledges the actual architecture: EF Core in the modern path, Insight.Database and stored procedures in the legacy path, and SQL triggers still acting as the only universal safety net.

## Core idea

Create a shared application-level auditing component that can accept audit envelopes from multiple write mechanisms.

Sources would include:

- EF Core `ChangeTracker` / save pipeline for modern writes
- repository or use-case hooks where needed
- legacy DAL boundary decorators or `UnitOfWork` wrappers
- explicit before / after snapshot providers for selected high-value legacy flows

The coordinator would write immutable code-first audit records into shared audit tables, for example:

- `AuditEnvelope`
- `AuditFieldChange`
- optional typed projections for especially important aggregates

## How it would fit this codebase

### Why this matches the repository better than Plan 1

Unlike an EF-only interceptor, this approach can be designed to absorb both:

- modern EF-managed writes
- legacy non-EF writes

That makes it the only one of the three plans that is explicitly shaped around the repository as it exists today, not just around the modern stack.

### How it can reuse existing patterns

This plan can build on:

- `IAuditEntity` / `AuditEntity`
- the selective `EntityHistory` pattern
- repository save boundaries
- legacy unit-of-work boundaries
- existing authenticated user / security-token context

It also allows the team to keep generic audit storage while adding typed history projections where business readability matters.

## Strengths

- Best architectural fit for the current mixed codebase.
- Can cover both EF and legacy writes.
- Supports gradual migration off triggers instead of forcing a big-bang replacement.
- Makes auditing an application concern without pretending all writes are EF-managed.
- Can standardize correlation IDs, actor identity, tenant context, and action semantics across paths.

## Weaknesses

- More moving parts than a pure EF interceptor.
- Legacy wrappers can become tedious if there are too many boundary variations.
- Fidelity may differ by path: EF can provide field-level diffs, while legacy may only provide operation-level snapshots unless more work is done.
- During migration, there is a real risk of duplicate logging from triggers, coordinator writes, and existing history entities.

## Critique summary

This option received the strongest fit assessment of the three.

The critique highlighted these points:

- good fit for the split EF + legacy architecture
- realistic path to broad code-first coverage
- easy to underestimate complexity and duplication risk
- must be transactionally aligned with both EF saves and legacy `TransactionScope` writes
- should define one canonical audit model, with typed projections only where useful

The most important caution was not to let the design fragment into:

- generic field-change records for some entities,
- typed history for others,
- and trigger output for everything else,

without a clear canonical contract tying them together.

## Recommended rollout

1. Inventory write paths and rank them by business value and modernization readiness.
2. Define one canonical audit envelope with required fields such as actor, tenant, action, entity type, entity key, timestamp, correlation ID, and before / after availability.
3. Implement the shared writer and storage model first.
4. Integrate EF writes through a save pipeline or repository hook.
5. Pilot legacy wrappers at a few high-value transaction boundaries.
6. Run the coordinator in parallel with existing triggers and compare outputs.
7. Retire triggers only per table and only when a specific write path has proven parity.

## Best use of this plan

Use this plan if the goal is:

- to make auditing code-first without pretending the repository is already EF-only,
- to unify audit metadata across modern and legacy paths,
- and to create a realistic migration bridge away from persistence-owned auditing.

## Where this plan still needs discipline

This plan will fail if it is allowed to become an unstructured pile of wrappers and special cases.

To succeed, it needs:

- a canonical audit contract
- clear boundary ownership
- correlation and idempotency rules
- explicit rollout sequencing
- a policy for when typed history tables are warranted

## Verdict

This is the **best near- to mid-term fit for this codebase**.

It is not the simplest option, but it is the most realistic code-first transition plan because it respects the current split between EF Core and legacy write paths.
