# Current State: SQL Trigger Auditing vs EF Core Auditing in Veo Design Studio

## Executive summary

Today the broadest and most reliable audit trail in this codebase lives in the SQL projects, not in EF Core.

The SQL projects implement row-level auditing with `ot_ins_*`, `ot_upd_*`, and `ot_del_*` triggers that write into `z_*` tables. That gives the system one very important property: changes are captured regardless of whether they come from EF Core, Insight.Database, stored procedures, admin scripts, or direct SQL fixes.

On the EF Core side, the domain model already understands audit-related concepts such as `Author`, `CreateDate`, `Modifier`, and `ModifiedDate`, and the modern code path has a small but real `EntityHistory` pattern. However, there is no generalized EF save pipeline that turns tracked changes into a uniform audit record. The result is a split world: database-first auditing for coverage, application-level history for selected features, and no single code-first auditing framework that spans the solution.

## SQL projects: the current source of truth for broad audit coverage

### Relevant projects

- `Databases\VeoSolutions\VeoSolutions.sqlproj`
- `Databases\VeoSolutionsSecurity\VeoSolutionsSecurity.sqlproj`
- `Databases\VeoSolutionsArchive\VeoSolutionsArchive.sqlproj`
- `Databases\Server\Server.sqlproj`

### Trigger and `z_*` table pattern

The clearest implementation lives in:

- `Databases\VeoSolutions\dbo\Stored Procedures\create_z_table.sql`
- `Databases\VeoSolutions\dbo\Stored Procedures\esp_createTableTriggers.sql`
- `Databases\VeoSolutionsSecurity\dbo\Stored Procedures\create_z_table.sql`
- `Databases\VeoSolutionsSecurity\dbo\Stored Procedures\esp_createTableTriggers.sql`

Those scripts generate a companion `z_<table_name>` table that mirrors the source table and adds:

- `z_user_name`
- `z_action`
- `z_time`
- `auto_number`

They also generate three triggers per audited table:

- `ot_ins_<table>`
- `ot_upd_<table>`
- `ot_del_<table>`

The update trigger also standardizes `modifier` and `modified_date` updates on the base table before writing the audit row.

### Representative example

A representative audited table pair exists under:

- `Databases\VeoSolutions\dbo\Tables\catalog_selections\catalog_selections.sql`
- `Databases\VeoSolutions\dbo\Tables\catalog_selections\z_catalog_selections.sql`
- `Databases\VeoSolutions\dbo\Tables\catalog_selections\ot_ins_catalog_selections.sql`
- `Databases\VeoSolutions\dbo\Tables\catalog_selections\ot_upd_catalog_selections.sql`
- `Databases\VeoSolutions\dbo\Tables\catalog_selections\ot_del_catalog_selections.sql`

That example shows two important facts:

1. The trigger model is not only auditing. It can also perform additional persistence-side work such as updating change-log tables.
2. The audit payload is row-oriented and lossless for that table shape. It stores the post-operation row state plus `insert` / `update` / `delete` metadata.

### What the SQL approach does well

- Captures writes from every caller, not just EF Core.
- Runs in the same transaction as the data mutation.
- Requires no cooperation from the application layer once installed.
- Produces a forensic, row-level history that is easy to reason about from a database perspective.

### What the SQL approach costs

- Audit behavior is centered in the persistence layer rather than the domain model.
- Trigger logic is hard to discover from application code.
- The audit shape is row-change oriented, not business-intent oriented.
- Cross-table behavior can become implicit and surprising.
- Schema evolution requires maintaining base tables, `z_*` tables, and trigger scripts together.

## EF Core and domain model: partially audit-aware, but not audit-driven

### Relevant projects

- `BuildOnTechnologies.VDS.Domain`
- `BuildOnTechnologies.VDS.Repository`
- `BuildOnTechnologies.VDS.Migrations.VeoSolutions`
- `BuildOnTechnologies.VDS.Migrations.VeoSolutionsSecurity`

### Domain abstractions that already exist

The domain already has audit-oriented abstractions:

- `BuildOnTechnologies.VDS.Domain\AuditEntity.cs`
- `BuildOnTechnologies.VDS.Domain\EntityHistory.cs`
- `BuildOnTechnologies.VDS.Domain\EntityHistoryAction.cs`

`AuditEntity` defines the familiar audit columns:

- `Author`
- `CreateDate`
- `Modifier`
- `ModifiedDate`

Many domain entities implement `IAuditEntity` directly or mirror those properties in the aggregate.

Examples:

- `BuildOnTechnologies.VDS.Domain\Accounts\Account.cs`
- `BuildOnTechnologies.VDS.Domain\Users\User.cs`
- `BuildOnTechnologies.VDS.Domain\Tenants\Tenant.cs`

### DbContexts and EF configuration

EF Core lives primarily in:

- `BuildOnTechnologies.VDS.Repository\VDSDbContext.cs`
- `BuildOnTechnologies.VDS.Repository\VDSSecurityDbContext.cs`

Both contexts load mappings from the migrations assemblies via `ApplyConfigurationsFromAssembly(...)`.

Entity maps live in the migrations projects, for example:

- `BuildOnTechnologies.VDS.Migrations.VeoSolutionsSecurity\EntityMaps\Accounts\Account.cs`
- `BuildOnTechnologies.VDS.Migrations.VeoSolutionsSecurity\EntityMaps\Users\ZUser.cs`

This means the EF model is code-first enough to express table mappings and migrations, but not yet code-first in the sense of owning auditing behavior.

### EF is currently adapted to the trigger world

A key signal is:

- `BuildOnTechnologies.VDS.Repository\Conventions\BlankTriggerAddingConvetion.cs`

That convention adds placeholder triggers to EF model metadata so EF Core operates correctly with SQL Server tables that have real database triggers.

In other words, EF Core has already been bent around the trigger-based auditing design. The existence of this convention is strong evidence that trigger-backed tables are still treated as a first-class constraint in the runtime architecture.

### Repository and save pipeline state

The generic repository is here:

- `BuildOnTechnologies.VDS.Repository\Repository.cs`

Its `SaveChanges()` method inspects `ChangeTracker` entries but does not turn them into audit records. It ultimately delegates to `Context.SaveChangesAsync()` without a general-purpose audit interceptor, change diff builder, or domain event dispatcher.

That means the modern EF path currently has:

- tracked entities
- entity maps
- migrations
- audit columns on entities

but not:

- a generalized code-first audit trail
- a unified save interceptor
- a domain event pipeline that emits audit events automatically

## Existing code-first history pattern: real, but selective

There is already a small application-driven history pattern in the modern stack.

Key pieces include:

- `BuildOnTechnologies.VDS.Domain\EntityHistory.cs`
- `BuildOnTechnologies.VDS.Domain\VisualizationProgram\VisualizationProgramHistory.cs`
- `BuildOnTechnologies.VDS.Domain\BuilderTrainingLink\BuilderTrainingLinkHistory.cs`
- matching repositories and entity maps in the repository / migrations layers

Representative service usage exists in:

- `BuildOnTechnologies.VDS.Services\VisualizationProgram\CreateVisualizationProgram.cs`
- `BuildOnTechnologies.VDS.Services\VisualizationProgram\UpdateVisualizationProgram.cs`
- `BuildOnTechnologies.VDS.Services\BuilderTrainingLinks\SaveBuilderTrainingLink.cs`
- `BuildOnTechnologies.VDS.Services\BuilderTrainingLinks\DeleteBuilderTrainingLinks.cs`

In those flows, the application explicitly creates a history entity with `EntityHistoryAction.Insert`, `Update`, or `Delete`, then persists it along with the aggregate.

This matters because it proves three things:

1. The codebase already accepts code-first audit history as a pattern.
2. The pattern is feature-specific, not platform-wide.
3. The current implementation captures business-level history only where someone deliberately wired it in.

## Legacy data access remains a major constraint

The legacy path still writes through Insight.Database and transaction-scoped units of work, for example:

- `BuildOnTechnologies.VDS.Legacy.Dal\InsightUnitOfWork.cs`

That path does not participate in EF Core `ChangeTracker` and does not benefit from any EF-only audit solution.

This is the main reason the SQL trigger strategy has stayed valuable: it covers both modern and legacy writes.

## The real mismatch today

The current architecture has three layers of audit-related concepts, but they do not form one cohesive model.

### Layer 1: SQL row-change auditing

This is broad, automatic, and persistence-centered.

### Layer 2: domain audit columns

This models authorship and timestamps, but not a full audit trail.

### Layer 3: selective application history entities

This is code-first and closer to DDD, but only exists for a subset of features.

The missing piece is a generalized code-first auditing mechanism that:

- works naturally with EF Core,
- does not leak too much business behavior into SQL,
- and still respects the fact that not all writes come through EF today.

## Constraints any future code-first audit solution must satisfy

A viable replacement or evolution path should account for all of the following:

1. **Mixed write paths**
   The repo still has both EF Core and legacy Insight / stored-procedure write paths.

2. **Transactional integrity**
   Audit records must commit or roll back with the business write.

3. **Actor propagation**
   The solution must consistently capture user / service identity.

4. **DDD fit**
   For important aggregates, business-intent history is more useful than raw row diffs alone.

5. **Forensic coverage**
   The current trigger model catches more than EF can see. Any replacement has to explain what happens to those writes.

6. **Incremental rollout**
   A big-bang trigger removal would be risky in this codebase.

## Bottom line

The current lay of the land is this:

- SQL owns the only truly universal audit trail.
- EF Core models audit fields and some history entities, but not a generalized audit framework.
- The modern path is capable of moving toward code-first auditing.
- The legacy path is the biggest reason a pure EF-only solution is not enough yet.

That makes a gradual transition strategy much more realistic than an immediate trigger replacement.
