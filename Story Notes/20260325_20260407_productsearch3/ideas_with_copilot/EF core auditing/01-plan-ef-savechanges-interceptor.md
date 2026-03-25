# Plan 1: EF Core SaveChanges Interceptor with Generic Audit Tables

## Summary

This plan introduces a generalized EF Core auditing pipeline using `SaveChanges` interception plus code-first audit tables managed by EF migrations.

It is the cleanest modern infrastructure option for the EF-managed side of the system, but it does not solve the whole repository by itself because large parts of the solution still write through legacy DAL and stored procedures.

## Core idea

Add a shared audit infrastructure to the modern path that does all of the following in application code:

- stamps `Author`, `CreateDate`, `Modifier`, and `ModifiedDate`
- inspects `ChangeTracker` before save
- captures `Added`, `Modified`, and `Deleted` entities
- records immutable audit entries in the same transaction
- stores either snapshots, diffs, or both

A minimal design would introduce tables such as:

- `AuditBatch`
- `AuditEntry`
- optional `AuditFieldChange`

Those tables would be created via EF migrations in the relevant migrations projects rather than through the SQL projects.

## How it would fit this codebase

### New infrastructure

Likely additions would live around:

- `BuildOnTechnologies.VDS.Repository`
- `BuildOnTechnologies.VDS.Domain`
- `BuildOnTechnologies.VDS.Migrations.VeoSolutions`
- `BuildOnTechnologies.VDS.Migrations.VeoSolutionsSecurity`

Key building blocks:

- `IAuditActorProvider` to resolve the current user or service identity
- `ISaveChangesInterceptor` or DbContext override for audit capture
- code-first audit entities and maps
- entity opt-in rules so only supported entities participate at first

### How it would use existing code

This plan can reuse several existing concepts:

- `IAuditEntity` / `AuditEntity`
- repository save boundaries
- current EF migrations model
- current application concept of actor identity

It can also coexist with existing `EntityHistory` tables for high-value aggregates where generic diffs are not expressive enough.

## Strengths

- Most natural code-first option for EF-managed aggregates.
- Centralizes a concern that is currently scattered across use cases.
- Keeps audit writes in the same transaction.
- Removes per-use-case duplication for standard row auditing.
- Produces queryable audit data without needing `z_*` tables for the EF path.
- Aligns well with future modern-stack development.

## Weaknesses

- Does not see writes made through Insight.Database, stored procedures, admin SQL, or bulk paths.
- Risks creating audit gaps if triggers are removed too early.
- Generic field-diff auditing is technically useful but weaker than business-level history.
- Can become noisy if every tracked property is logged indiscriminately.

## Critique summary

The critique pass on this option was consistent:

- **Strong fit for the EF Core path**
- **Weak fit as a repo-wide replacement**

Most importantly, this plan falls short anywhere the write does not pass through EF `ChangeTracker`.

That includes:

- legacy DAL operations
- stored-procedure-heavy paths
- `TransactionScope` flows outside EF
- any direct SQL or maintenance scripts

The critique also highlighted that the existing `BlankTriggerAddingConvention` is a reminder that triggers are not incidental here; the runtime already expects them to exist.

## Recommended rollout

1. Inventory EF-managed tables versus legacy / SP-heavy tables.
2. Add interceptor-based auditing in shadow mode.
3. Compare interceptor output against existing trigger output for selected EF tables.
4. Keep triggers as the safety net during validation.
5. Migrate low-risk EF tables first.
6. Retire triggers only per table, and only after parity is proven.
7. Leave trigger auditing in place for legacy-heavy tables until those write paths are modernized.

## Best use of this plan

Use this plan if the goal is:

- to modernize auditing for EF-managed aggregates,
- to reduce manual audit wiring in the services layer,
- and to build an infrastructure foundation that is code-first for the modern stack.

## Where this plan is not enough

This plan is not enough if the goal is to fully replace the current SQL-trigger coverage across the entire application today.

## Verdict

This is a **good modern-path plan** and a **poor all-at-once replacement plan**.

It is viable if treated as an incremental modernization layer, not as the whole answer for the current mixed architecture.
