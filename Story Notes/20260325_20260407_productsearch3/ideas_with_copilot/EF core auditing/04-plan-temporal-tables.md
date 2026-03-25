# Plan 4: SQL Server Temporal Tables with Blob-Aware Exceptions

## Summary

This plan replaces trigger-based row-history on eligible tables with SQL Server temporal tables, configured through EF Core mappings and migrations.

Of the options so far, this is the most direct answer to the goal of **getting away from triggers in the database** while still keeping database-native history. It also fits the desire to manage the configuration from the EF Core side rather than continuing to rely on hand-maintained `z_*` tables and `ot_ins_*` / `ot_upd_*` / `ot_del_*` triggers.

The biggest caveat is exactly the one you called out: temporal tables version the **entire row**. That makes them a poor default for entities with large payload columns such as `Content.Data` (`varbinary(max)`).

## Why this plan is attractive

Temporal tables solve several problems the trigger model creates today:

- no custom auditing triggers per table
- no separate `z_*` schema to keep in sync manually
- database-managed row history for inserts / updates / deletes
- point-in-time querying built into the temporal model
- a more declarative setup that EF Core can help manage

That makes temporal tables a strong candidate for ordinary relational entities where the row shape is mostly scalar columns and foreign keys.

## Why this is different from the first three plans

Plans 1 through 3 all move auditing toward application code.

Plan 4 is different:

- it still uses database-managed history,
- but it does so with a built-in SQL Server feature rather than custom triggers,
- and it can be rolled out from the code-first side through EF entity configuration and migrations.

So this is not the most DDD-pure option, but it is the cleanest option if the primary goal is specifically **trigger removal**.

## Repository-specific fit

### What makes it plausible here

The SQL projects currently target `Sql150` schema providers in the `.sqlproj` files, which is a positive sign for temporal-table support from a platform perspective.

The EF side already has:

- code-first entity maps in `BuildOnTechnologies.VDS.Migrations.VeoSolutions*`
- DbContexts in `BuildOnTechnologies.VDS.Repository`
- audit columns like `Author`, `CreateDate`, `Modifier`, `ModifiedDate`

That means there is already a workable code-first place to configure which entities should become temporal.

### What it would replace

For eligible tables, temporal tables would replace:

- `z_*` table copies
- trigger-generated row history
- a large part of the manual synchronization burden between base tables, z-tables, and trigger scripts

### Semantic gap versus `z_*` tables

Temporal tables replace row-history timing and point-in-time reconstruction well, but they do not automatically preserve the old `z_*` semantics.

In particular, the current trigger model records fields like:

- `z_user_name`
- `z_action`
- `z_time`

Temporal tables give you row versions and system-time periods, but they do not inherently know the application actor. In this repository, that means `Author` / `Modifier` must be set reliably on every write path if the team wants to preserve the same actor fidelity after moving away from triggers.

## The critical risk: large payload rows

The most important example is:

- `BuildOnTechnologies.VDS.Domain\Content\Content.cs`
- `BuildOnTechnologies.VDS.Migrations.VeoSolutions\EntityMaps\Content\Content.cs`

Key facts:

- `Content.Data` is mapped as `varbinary(max)`.
- `Content` is the shared storage location for images and files.
- `Content.Update(...)` allows metadata-only updates such as `FileName` changes.
- The blob and the metadata live in the same row.

That combination is a bad fit for blanket temporal-table adoption.

### Why it is a bad fit

Temporal history stores prior versions of the full row. So if a row contains a `varbinary(max)` payload and a user changes only:

- `FileName`, or
- `Modifier`, or
- `ModifiedDate`

then the history row still carries the old blob value because the full previous row is versioned.

For `Content`, that means repeated metadata updates can multiply storage consumption even when the binary content itself never changes.

In other words, the risk is not just “big files make history bigger.”

The bigger problem is:

**small metadata edits on a blob-bearing row can still create blob-sized history records.**

## Recommended temporal-table policy

Do **not** make every entity temporal by default.

Use a tiered policy.

### Tier 1: good temporal-table candidates

Entities whose rows are mostly:

- scalar fields
- normal strings
- GUID keys
- timestamps
- booleans
- small numeric values
- standard foreign-key relationships

These are the best candidates for replacing `z_*` trigger auditing with temporal tables.

### Tier 2: conditional candidates

Entities with:

- occasional large text columns
- wide rows but low update frequency
- moderate growth where point-in-time history is valuable

These need table-by-table review before temporalizing.

### Tier 3: poor temporal-table candidates

Entities with large binary or max-length payload columns, especially when metadata changes independently from payload changes.

`Content` belongs here.

## Recommended handling for `Content` and similar entities

There are three viable strategies.

### Option A: keep blob tables non-temporal

Do not temporalize `Content`.

Instead:

- keep ordinary audit columns on the row,
- record metadata-level audit in application history tables or a generic audit table,
- optionally record only content hash / size / MIME-type transitions rather than duplicating the binary payload.

This is the lowest-risk option.

### Option B: split metadata from payload

Refactor `Content` into two storage concerns:

- a temporal metadata table
- a non-temporal blob table holding `Data`

Example shape:

- `Content` or `ContentMetadata`: id, mime type, file name, content hash, length, audit fields
- `ContentBinary`: content id, binary data

Then:

- temporalize the metadata row
- keep the blob row non-temporal
- only create a new blob row when the actual file changes

This is the cleanest long-term design if the team wants temporal behavior around content metadata without replicating large blobs on every metadata edit.

### Option C: hybrid content versioning

Keep `Content` non-temporal, but introduce explicit content-version rows only when the binary payload changes.

That gives you:

- deliberate versioning for file changes,
- no automatic duplication on metadata-only edits,
- and more control than blanket temporalization.

## Benefits of the temporal-table approach

- Removes custom trigger maintenance for eligible tables.
- Gives built-in row history without managing `z_*` schemas manually.
- Works for non-EF writes too, as long as they hit the same temporalized table.
- Preserves one major advantage of the current trigger system: database-level coverage.
- Is easier to reason about than custom trigger code for many tables.

## Limits of the temporal-table approach

- Still keeps history in the database, not in the domain model.
- Records row history, not business intent.
- Does not by itself replace selective business-history patterns like `EntityHistory` where those are useful.
- Can create serious storage growth on blob-heavy or wide rows.
- Does not automatically preserve `z_user_name` / `z_action` style metadata unless the application consistently stamps actor fields.
- Requires careful rollout and retention strategy.

## Migration risks

1. **Storage growth**
   This is the biggest risk for rows with `varbinary(max)` or other large-value columns.

2. **Mixed architecture complexity**
   Temporal tables help with coverage, but they do not make the legacy DAL disappear. They simply give both EF and non-EF writes a common database history mechanism.

3. **History semantics change**
   Existing consumers of `z_*` tables may need rewritten queries or compatibility views.

4. **Not every table should be temporal**
   A blanket migration would likely recreate the same “one size fits all” problem the current trigger system has, only with a different mechanism.

## Recommended rollout

1. Inventory audited tables and classify them into temporal-friendly, conditional, and blob-heavy.
2. Start with a small set of ordinary relational tables that are actively written by both EF and non-EF paths.
3. Make actor-stamping requirements explicit so `Author` / `Modifier` stay trustworthy across EF, legacy DAL, and stored-procedure paths.
4. Add temporal configuration through EF and migrations for those tables.
5. Validate history queries, operational behavior, and actor fidelity.
6. Replace triggers table-by-table, not database-wide.
7. Keep `Content` and similar blob-bearing entities out of the first wave.
8. Decide separately whether `Content` should remain non-temporal or be refactored into metadata + payload tables.
9. As temporal rollout grows, replace the current blanket trigger convention with explicit per-entity trigger configuration so temporal and trigger-backed tables can coexist cleanly during migration.

## Recommendation

If the main goal is specifically **to stop relying on custom triggers**, this is the strongest option so far.

My recommendation would be:

- use temporal tables as the default replacement for **normal relational entities**,
- **exclude blob-heavy entities like `Content` from blanket temporalization**,
- and use either metadata/payload splitting or explicit application-managed versioning for those large-value cases.

## Verdict

Plan 4 is a viable and serious path forward.

For this repository, the best form of Plan 4 is not “make every table temporal.” It is:

**temporal tables by default for normal entities, explicit exceptions for large-payload entities, with `Content` as the clearest first exception.**
