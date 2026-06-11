# VEO Database Codification — Design Options

> **Status:** Draft for design iteration. Lives in Working-Docs (`projects/veo-database-codification/`) while the design is fleshed out; once ADO work items exist and implementation starts, per-PBI plan files get created in the VeoDesignStudio repo under `documentation/plans/` per its `planning-plan-conventions`.
> **Author:** Justin Pope (drafted with Claude)
> **Date:** 2026-06-11
> **Revision note (2026-06-11):** corrected the original framing — VEO is **not** fed by builder/customer data paths from the VDS side. It is a **thin, one-way, read-only mirror of a database owned by the Echelon team**. Today: schema is propagated with RedGate SQL Compare; data is moved by an in-house app called **DataSync**.
> **Sources:** VDS repo — `Databases/VeoSolutions/VeoSolutions.sqlproj`, `Databases/ReferenceDacPacs/`, `.claude/rules/persistence.md`, `database-veosolutions-dev-publish` / `database-efcore-migrations` skills; scoping answers from Justin (2026-06-11)

---

## 1. Context & Problem Statement

The VEO database is a **thin mirror of a source database owned and maintained by the Echelon team**. It exists so VDS can read Echelon-originated data (plans, options, products, styles, communities) without coupling to the source system directly. The flow is strictly one-way: Echelon source → VEO mirror; VDS never writes to VEO.

In the VeoDesignStudio codebase, VEO exists **only as an external reference**:

- A pre-built binary `Databases/ReferenceDacPacs/VEO.dacpac` (~579 KB, checked in, manually refreshed) referenced by `VeoSolutions.sqlproj` and `VeoSolutionsSecurity.sqlproj` via `<ArtifactReference>` with `DatabaseSqlCmdVariable=VEO`.
- The `$(VEO)` SQLCMD variable mapped per environment in every publish profile: `Veo_DEV`, `Veo_QA`, `VEO_PREVIEW`, `Veo_STAGING`, local `Veo`, and per-customer production names (`CCDI_Veo`, `AFI_VEO`, `EPLAN_VEO` under `PublishProfiles/Production/`).
- 117 VeoSolutions stored procedures reference the VEO mirror through 75 `Veo_*` synonyms (e.g. `Veo_plan_mstr`, `Veo_products_options`, `Veo_communities`, `veo_colors`); none reference `$(VEO)` directly. Full inventory: [`veo-proc-synonym-references.md`](./veo-proc-synonym-references.md). *(An earlier case-sensitive grep counted 89 — corrected by the case-insensitive synonym scan.)*

**How the mirror is maintained today** — entirely outside the codebase:

- **Schema:** RedGate SQL Compare runs propagate schema changes from the Echelon source to the VEO mirror databases. Operator-driven; no versioned record in the VDS repo of what changed or when.
- **Data:** an in-house app, **DataSync**, moves data into the mirror. It lives outside the VDS codebase and dev cycle.

**Problems this creates:**

1. VEO schema changes are invisible to the VDS development cycle — the checked-in dacpac is a stale snapshot, so SSDT builds can pass against a schema that no longer matches any live mirror.
2. There is no change-management process: a RedGate compare run has no diff in source control, no review, and no traceability when a source schema change breaks the 117 VeoSolutions procs that read the mirror.
3. Mirror maintenance is tool-and-operator driven (SQL Compare + DataSync) rather than codified: not repeatable per environment from source control, not versioned, and not testable within VDS dev cycles.

**Constraints established during scoping (2026-06-11, Justin):**

| Decision | Answer |
|---|---|
| VEO schema source of truth | **The Echelon team** — VDS does not take ownership; it needs a reliable way to *pull changes in* |
| Scope of this design | Schema codification **and** sync-service concept. Refactoring the 117 consuming procs is **out of scope** |
| Sync service role | ~~Builder/customer data feeds~~ **Corrected:** maintain the VEO mirror from the Echelon source — successor to (or codification of) DataSync |
| Direction | Strictly one-way, read-only from the VDS side: Echelon source → VEO mirror; VDS never writes to VEO |
| Mirror scope (full vs. subset) | **To be designed** — one of the dimensions this doc iterates on |

## 2. Goals & Non-Goals

**Goals**

- VEO schema changes become visible, versioned, and reviewable inside the VDS dev cycle.
- The VEO reference VDS builds against is deterministic, refreshed by process, and provably matches what is deployed to the mirror environments.
- Environment parity: the same schema version is traceable from DEV through customer prod (`CCDI_Veo`, `AFI_VEO`, `EPLAN_VEO`).
- A codified service/app — designed against the codified schema — that keeps mirror **data** in sync from the Echelon source, replacing or formalizing DataSync.

**Non-Goals**

- Taking ownership of the source schema away from the Echelon team.
- Refactoring the existing 117 `Veo_*`-referencing procedures / 75 synonyms (future phase).
- Any VDS-side writes into VEO — the mirror stays read-only to VDS.

## 3. Design Dimensions

The solution decomposes into three semi-independent choices:

- **A — Schema consumption:** how the VEO schema gets codified and pulled into the VDS repo from the Echelon team.
- **B — Schema deployment & sync-state boundary:** how mirror environments get schema updates, and where the sync service keeps its own state (it can't live in a mirror).
- **C — Data sync architecture:** what form the DataSync successor takes.

A and C connect: once the schema is codified (A), the sync service can be built and tested against that schema as a contract — table shapes, keys, and the mirror-scope definition all become code.

---

## 4. Option Set A — Schema Consumption (pulling VEO schema from the Echelon team)

### A1 — Status quo + automated dacpac refresh

A pipeline (Echelon-side, or a VDS pipeline running `sqlpackage /a:Extract` against a reference mirror) produces a fresh `VEO.dacpac` and opens an automated PR updating `Databases/ReferenceDacPacs/VEO.dacpac`.

- **Pros:** smallest change; no `.sqlproj` modifications; the PR *is* the change notification (binary, but the build break surfaces incompatibilities); works even if the Echelon team has no SSDT source — extract-from-live suffices.
- **Cons:** binary diffs are unreviewable directly; still a snapshot model; refresh cadence is a policy choice, not enforced.

### A2 — Versioned dacpac artifact feed

Echelon-side CI publishes `VEO.dacpac` as a versioned package (Azure DevOps Artifacts/NuGet). VDS pins a version and restores the dacpac at build time; consuming a new VEO version is a one-line version bump in a PR.

- **Pros:** real versioning + provenance; no binaries in git; explicit, reviewable upgrade moments; the natural long-term shape for a cross-team contract; the same versioned artifact can drive mirror deployment (see B0).
- **Cons:** requires Echelon-team CI buy-in; classic `.sqlproj` doesn't restore package database references natively — either a pre-build restore step copies the dacpac into `ReferenceDacPacs/`, or the Databases projects migrate to the SDK-style `Microsoft.Build.Sql` format (a meaningful migration of its own, which also interacts with the VS-18-MSBuild publish constraint).

### A3 — Git submodule/subtree of the Echelon repo's SSDT source

If the Echelon repo holds the source schema as an SSDT project, mount it into the VDS solution and build the dacpac from source.

- **Pros:** full source-level visibility — schema diffs reviewable line by line; local builds always match the pinned commit.
- **Cons:** only works if the schema actually exists as SSDT source upstream; submodule ergonomics across the team's bare-repo/worktree clone styles; couples VDS builds to another repo's structure and conventions; if the mirror is a *subset* (see §5/§8), the upstream project models more than VDS needs.

### A4 — Mirrored SSDT project in VDS (`Databases/VEO/`)

Maintain the mirror schema as a first-class SSDT project in the VDS repo, synced from Echelon releases via schema compare.

- **Pros:** best in-repo experience; schema fully greppable; VDS publishes mirrors itself; **if the mirror is a deliberate subset, this project *is* the natural place to define that subset** — the mirror schema becomes a VDS-owned contract derived from (not identical to) the source.
- **Cons:** a second source of truth with ongoing sync labor — though materially less risky here than in the general case, because the mirror is read-only and the "sync" is exactly the schema-compare activity already happening today, just landed in source control instead of run-and-forgotten.

### A5 — EF Core migrations project for the VEO schema

Model the mirror schema as EF entity maps (e.g. `BuildOnTechnologies.VDS.Migrations.Veo`, mirroring the existing VeoSolutions/VeoSolutionsSecurity migrations projects + `Repository.Harness` pattern), with upstream changes captured as migrations.

- **Pros:** the team already runs this pattern; schema changes become reviewable C# diffs; a DbContext over the mirror falls out for free, which the C2 sync service wants anyway.
- **Cons — the ownership-direction mismatch:**
  - Migrations are **change-based and authored**; the mirror is **state-based and received**. Every Echelon-side change must be hand-translated into a migration + snapshot update — the RedGate-compare labor reincarnated, with *silent snapshot drift* when someone forgets (vs. dacpac, where the build break is the alarm).
  - The VeoSolutions SSDT build still needs a `VEO.dacpac` to resolve the 117 procs / 75 synonyms — so A5 doesn't replace an A1/A2/A4 artifact, it adds a second representation to keep honest.
  - `__EFMigrationsHistory` would live inside the mirror database — a VDS-owned object in VEO, the same conflict that demoted B3 (source-driven schema compares would flag or drop it).
  - EF model fidelity for legacy SQL shapes (exact constraint names, extended properties, odd legacy structures) is weaker than dacpac capture; the mirror would be codified only as faithfully as the entity maps bother to be.
  - VDS never writes to VEO, so EF's main payoff — the model-first dev loop for entities you own — doesn't apply to the mirror.
  - A scaffold-based variant (re-scaffold the DbContext from a refreshed mirror, let `migrations add` capture the diff) automates the translation but inherits scaffold churn and still leaves the dacpac requirement.

**Where EF Core *does* fit in this design:** (a) **B2 sidecar state** — the sync service's watermarks/run-history tables belong in the existing EF migrations projects, which own exactly this kind of schema; (b) a **migration-less, read-only DbContext** over the mirror for the C2 sync service and any modern-layer reads — entity maps without a migrations assembly, validated against the codified schema (the §6 drift guard) rather than maintained as one.

### Comparison

| | A1 auto-refresh | A2 artifact feed | A3 submodule | A4 in-repo project | A5 EF migrations |
|---|---|---|---|---|---|
| Change visibility | Low (binary PR) | Medium (version bump + release notes) | High (source diff) | High (source diff) | High (C# diff) |
| Drift risk | Medium | Low | Low | Medium (mitigated by drift-check pipeline) | **High** (silent snapshot drift) |
| Echelon-team burden | Low | Medium | Low–Medium | None | None |
| Works without SSDT source upstream | **Yes** (extract) | **Yes** (extract) | No | **Yes** | Yes |
| Supports a *subset* mirror contract | No (snapshot of whole) | Only if upstream builds a subset dacpac | No | **Yes** | Yes |
| Satisfies SSDT build reference | Yes | Yes | Yes | Yes | **No** (still needs a dacpac) |
| Effort to adopt | Low | Medium | Medium | High | High (and ongoing translation) |

> **Note (revised after the mirror correction):** A4 was originally "listed for completeness; not recommended." The mirror model improves its standing: if the mirror scope ends up being a deliberate subset that VDS defines, someone has to own that subset definition — and an in-repo SSDT project is the most natural artifact for it. A4's drift risk is also bounded because today's RedGate compare process *is already* manual mirror-sync; A4 just makes it reviewable.

**Pivotal unknown:** whether the Echelon repo holds the schema as SSDT source or only as live databases — and whether the mirror is full-schema or subset (§8 Q1, Q5).

---

## 5. Option Set B — Schema Deployment & Sync-State Boundary

Two related questions: who deploys schema to the mirror environments, and where does the sync service keep its operational state.

### B0 — Mirror schema deployment (replacing RedGate SQL Compare runs)

Today RedGate SQL Compare propagates schema source → mirror, out-of-band. Once schema is codified (any A option), mirror deployment can become a **dacpac publish** (`sqlpackage /a:Publish`) from the same artifact VDS builds against:

- The reference VDS compiles against and the schema deployed to `Veo_DEV` … `CCDI_Veo` are *the same versioned artifact* — parity is structural, not aspirational.
- Publishes are pipeline steps with history, not operator sessions.
- RedGate compare can remain as a *drift-detection* check (scheduled compare source-vs-mirror that alerts) rather than the deployment mechanism.

This is less an option than a consequence of doing A — but it needs agreement on who runs the publish (VDS pipeline vs. Echelon team) per environment.

### B1 — Sync-service state via change requests to the Echelon team

All operational-state schema (watermarks, run history, batch staging) is requested into the source/mirror schema. Gates every sync-service iteration on another team's cycle; also pollutes a mirror with non-mirror objects. Poor fit.

### B2 — Sidecar persistence owned by VDS *(recommended)*

Sync-service state lives in schema VDS already owns — new tables in `VeoSolutions` (existing SSDT + EF dual management, `z_` audit conventions, publish profiles all apply) or a distinct database if isolation is preferred. VEO receives mirror **data only**; its schema stays purely a reflection of the source.

### B3 — VDS-owned schema inside the VEO database

~~Viable middle ground if cross-DB transactions prove painful.~~ **Demoted after the mirror correction:** putting VDS-owned objects inside VEO conflicts with the mirror model — schema-compare/publish runs from the source would flag or drop them, and the mirror stops being a thin reflection. Only worth revisiting if staging-swap mechanics (§6) demand same-database staging tables, and then only with an agreed carve-out schema excluded from compares.

---

## 6. Option Set C — Data Sync Architecture (Echelon source → VEO mirror)

**Current state:** the in-house **DataSync** app moves data into the mirror, outside the VDS codebase. The design question is what its codified successor looks like — a service built *in* the VDS codebase, against the codified schema from Option Set A. (Whether it replaces DataSync outright or wraps/formalizes it is §8 Q3.)

### C1 — Hangfire job inside the VeoDesignStudio app

Hangfire server + dashboard are already configured in `Startup.cs` (precedent: `TenantProgramController`'s RefreshTenantProgram wrapper). A scheduled job pulls from the source and refreshes the mirror.

- **Pros:** zero new infrastructure; dashboard, retries, scheduling for free; fastest path to a working sync.
- **Cons:** couples mirror refresh to the buyer-facing web app's lifecycle — deploys and restarts interrupt syncs; large refreshes contend with user traffic; per-customer prod topology gets awkward (the app instance would need reach into both source and mirror per tenant).

### C2 — Standalone worker service — the DataSync successor *(likely primary)*

A new deployable (e.g. `BuildOnTechnologies.VDS.VeoMirrorSync`, .NET worker/`BackgroundService`) whose single job is source → mirror data sync. Built against the codified schema; consumes the modern layers where useful.

- **Pros:** the sync's deployment/scale/schedule decouples from the web app — exactly the "manageable within our dev cycles" goal; clean home for watermarking, merge logic, scope filtering, and drift checks; testable in isolation (spin up source-shaped and mirror-shaped DBs from the codified schema in CI); per-environment/per-customer config is first-class.
- **Cons:** net-new deployable (hosting, monitoring, config); duplicates some bootstrapping.

### C3 — Platform-level sync (SQL replication / log shipping / CDC-driven copy)

Let SQL Server do it: transactional replication or a CDC-fed copy job from source to mirror.

- **Pros:** battle-tested, low-latency, no app code to maintain for the copy itself.
- **Cons:** runs against the stated intent ("leverage the database in code to create a new service/app"); subset/transform scope is awkward in replication; per-customer prod topologies multiply replication admin; visibility/debugging lives in DBA tooling, not the dev cycle. Included as the baseline any C2 design should justify itself against.

### C4 — Hybrid: platform change-detection + app-level apply

CDC or rowversion high-water marks on the source feed a VDS-owned worker (C2) that applies changes to the mirror as idempotent, scope-filtered merges.

- **Pros:** incremental sync without polling-diff cost; the app layer keeps scope/transform/audit control; best fit if the mirror is a subset.
- **Cons:** requires Echelon-team agreement to enable CDC/rowversion reads on the source; two moving parts.

### Cross-cutting concerns (any C option)

- **Refresh model:** full refresh vs. incremental. Full refresh is simplest and matches "thin mirror," but per-customer prod sizes may force incremental (watermark/CDC).
- **Consumer-safe swaps:** 117 procs read the mirror continuously. Refreshes should be atomic from the reader's perspective — staging-table + `sp_rename`/synonym swap or partition switch, so readers never see half-synced state.
- **Idempotency:** merge keyed on source natural keys; a re-run after failure converges rather than duplicates.
- **Scope as code:** the mirror-scope definition (full vs. subset — to be designed) lives in the sync service's config/schema contract, versioned with it.
- **Schema-drift guard:** before syncing, the service validates mirror schema version against the codified schema it was built for (ties A and C together); mismatch → halt and alert rather than corrupt.
- **One-way enforcement:** service credentials are read-only on source, write on mirror; VDS app credentials stay read-only on the mirror.
- **Multi-tenancy:** per-customer prod mirrors (`CCDI_Veo`, `AFI_VEO`, `EPLAN_VEO`) — and presumably per-customer sources — mean per-tenant connection config; one service with tenant config beats per-customer forks.
- **Operational state:** run history, watermarks, row counts, validation results in the B2 sidecar — with `z_` auditing per VDS persistence conventions.

---

## 7. Strawman Recommendation (to iterate on)

1. **A1 now → A2 next, A4 if subset:** automate dacpac refresh immediately (kills the stale-snapshot problem cheaply); pursue a versioned artifact feed with the Echelon team as the durable contract. If the mirror-scope design lands on a deliberate subset, promote A4 — an in-repo `Databases/VEO/` project that *defines* the subset contract.
2. **B0 + B2:** mirror schema deployment becomes dacpac publish from the versioned artifact (RedGate compare demoted to drift detection); all sync-service state in VDS-owned schema; VEO receives data only.
3. **C2, with C4 as the growth path:** a standalone worker service as the codified DataSync successor — full-refresh with consumer-safe swaps to start, watermark/CDC incremental (C4) when size or latency demands it. Data access via a migration-less, read-only DbContext over the mirror (see A5 — EF for *modeling*, not for migrating the mirror); sidecar state managed through the existing EF migrations projects (B2).

## 8. Open Questions

| # | Question | Why it matters | Owner |
|---|---|---|---|
| 1 | Does the Echelon team hold the source schema as SSDT/source in their repo, or only as live databases? | Decides A2 vs A3 viability; A1/A4 work either way | Justin → Echelon team |
| 2 | What is the actual cadence/volume of source schema change, and how do we hear about it today? | Sizes the refresh automation and the pain being solved | Echelon team |
| 3 | DataSync specifics: who owns it, where does it live, what does it sync (tables, full vs. incremental), on what schedule, and what are its known gaps? | Replace vs. wrap decision; requirements baseline for C2 | Justin → DataSync owner |
| 4 | RedGate SQL Compare runs: who runs them, when, against which environments? Any saved compare projects/reports (e.g. `SQLCompareReports/` in this repo)? | Current-state evidence for B0; what the dacpac-publish flow must replace | Justin |
| 5 | Mirror scope: is the mirror today the full source schema or already a subset? Should the target state be a deliberate subset (dependency analysis of the 117 procs)? | Drives A4 vs A1/A2 and the C scope-as-code contract | Design (this doc) |
| 6 | Can a VDS-owned service get network/credential access to the Echelon source DB per environment and per customer prod? | Feasibility of C2/C4 direct DB-to-DB sync | Justin / DevOps |
| 7 | Does the source have CDC or rowversion availability (or could it)? | Gates C4 incremental | Echelon team |
| 8 | Per-customer prod mirrors — is there one source per customer, or one shared source? | Multi-tenant sync topology | Echelon team |
| 9 | ADO epic + feature IDs for this effort | Branch naming and commit references once implementation starts in the VDS repo | Justin |

## 9. Suggested Next Steps

1. Iterate on this doc — challenge the option framing and the strawman in §7.
2. Resolve open questions 1–3 (Echelon repo state, DataSync specifics) — they gate both A and C.
3. Run the mirror-scope analysis (Q5): the proc→synonym inventory is done ([`veo-proc-synonym-references.md`](./veo-proc-synonym-references.md) — 117 procs across 59 of the 75 synonyms; 16 synonyms have no proc references). Remaining: column-level usage, plus views/functions/triggers as consumers.
4. Create the ADO epic/feature; spin up per-PBI plan files in the VDS repo under `documentation/plans/` (spike candidates: A1 refresh automation; C2 walking skeleton with consumer-safe swap).
