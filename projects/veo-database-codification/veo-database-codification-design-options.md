# VEO Database Codification — Design Options

> **Status:** Draft for design iteration. Lives in Working-Docs (`projects/veo-database-codification/`) while the design is fleshed out; once ADO work items exist and implementation starts, per-PBI plan files get created in the VeoDesignStudio repo under `documentation/plans/` per its `planning-plan-conventions`.
> **Author:** Justin Pope (drafted with Claude)
> **Date:** 2026-06-11
> **Revision note (2026-06-11):** corrected the original framing — VEO is **not** fed by builder/customer data paths from the VDS side. It is a **thin, one-way, read-only mirror of a database owned by the Echelon team**. Today: schema is propagated with RedGate SQL Compare; data is moved by an in-house app called **DataSync**.
> **Revision note (2026-06-22):** three findings from scoping refine the design. (1) Per Cindy (Echelon team manager), Echelon's WBS source database is **not codified in GitHub** — there is no upstream SSDT/source project, only live databases. (2) VEO is **not a true mirror**: it deliberately **drops foreign keys, triggers, indexes** and similar objects, so propagating a source change means *adapting* it, not copying it — VEO is a **transformed/simplified projection**, not a faithful reflection. (3) Deployment is gated by project type — **SSDT projects are not deployed in the VDS pipeline** (changing that in production is possible but unlikely), whereas **EF Core migrations already run in production**. These turn Option Set A into a genuine SSDT-vs-EF-Core fork (both viable) and reshape B and C accordingly.
> **Sources:** VDS repo — `Databases/VeoSolutions/VeoSolutions.sqlproj`, `Databases/ReferenceDacPacs/`, `.claude/rules/persistence.md`, `database-veosolutions-dev-publish` / `database-efcore-migrations` skills; scoping answers from Justin (2026-06-11, 2026-06-22); Echelon-team input via Cindy (2026-06-22)

---

## 1. Context & Problem Statement

The VEO database is a **transformed, one-way projection of a source database owned and maintained by the Echelon team** — historically called a "mirror," but it is *not* a faithful copy: foreign keys, triggers, indexes, and similar objects are deliberately dropped on the way in. It exists so VDS can read Echelon-originated data (plans, options, products, styles, communities) without coupling to the source system directly. The flow is strictly one-way: Echelon source → VEO projection; VDS never writes to VEO. (This doc still says "mirror" for continuity — read it as "simplified projection.")

In the VeoDesignStudio codebase, VEO exists **only as an external reference**:

- A pre-built binary `Databases/ReferenceDacPacs/VEO.dacpac` (~579 KB, checked in, manually refreshed) referenced by `VeoSolutions.sqlproj` and `VeoSolutionsSecurity.sqlproj` via `<ArtifactReference>` with `DatabaseSqlCmdVariable=VEO`.
- The `$(VEO)` SQLCMD variable mapped per environment in every publish profile: `Veo_DEV`, `Veo_QA`, `VEO_PREVIEW`, `Veo_STAGING`, local `Veo`, and per-customer production names (`CCDI_Veo`, `AFI_VEO`, `EPLAN_VEO` under `PublishProfiles/Production/`).
- 117 VeoSolutions stored procedures reference the VEO mirror through 75 `Veo_*` synonyms (e.g. `Veo_plan_mstr`, `Veo_products_options`, `Veo_communities`, `veo_colors`); none reference `$(VEO)` directly. Full inventory: [`veo-proc-synonym-references.md`](./veo-proc-synonym-references.md). *(An earlier case-sensitive grep counted 89 — corrected by the case-insensitive synonym scan.)*

**How the mirror is maintained today** — entirely outside the codebase:

- **Schema:** RedGate SQL Compare surfaces the diff between the Echelon source and the VEO databases and is run **as part of the deployment process** to sync schema; an operator **adapts** the relevant changes into the mirror (dropping FKs/triggers/indexes as the projection requires). It is not a straight compare-and-apply — it is compare-and-curate. Reactive, not scheduled: changes happen as VDS takes on work that touches VEO (no cadence). No versioned record in the VDS repo of what changed or when.
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
| Echelon source state | **Live databases only — not codified in GitHub** (Cindy, 2026-06-22). No upstream SSDT/source project to consume |
| Mirror fidelity | **Not a true mirror — a deliberate transformation.** FKs, triggers, indexes dropped; source changes are adapted, not copied |
| Deployment by project type | **SSDT not deployed in the VDS pipeline** (changeable in prod, unlikely); **EF Core migrations run in production** |

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

- **A — Schema consumption:** how the VEO schema gets codified and pulled into the VDS repo from the Echelon team. With no upstream SSDT source to consume, this narrows to an **SSDT-project-vs-EF-Core fork** (A4 vs A5) — both viable, see §4.
- **B — Schema deployment & sync-state boundary:** how mirror environments get schema updates, and where the sync service keeps its own state (it can't live in a mirror).
- **C — Data sync architecture:** what form the DataSync successor takes.

A and C connect: once the schema is codified (A), the sync service can be built and tested against that schema as a contract — table shapes, keys, and the mirror-scope definition all become code.

---

## 4. Option Set A — Schema Consumption (pulling VEO schema from the Echelon team)

### A1 — Status quo + automated dacpac refresh

A pipeline (Echelon-side, or a VDS pipeline running `sqlpackage /a:Extract` against a reference mirror) produces a fresh `VEO.dacpac` and opens an automated PR updating `Databases/ReferenceDacPacs/VEO.dacpac`.

- **Pros:** smallest change; no `.sqlproj` modifications; the PR *is* the change notification (binary, but the build break surfaces incompatibilities); works even if the Echelon team has no SSDT source — extract-from-live suffices.
- **Cons:** binary diffs are unreviewable directly; still a snapshot model; refresh trigger is a policy choice, not enforced.
- **Status (2026-06-22): the cheap interim.** With no schema-change cadence (Q2 — changes happen as VDS takes on VEO-touching work), trigger this refresh **on demand / at PR time for VEO-touching work** rather than on a schedule.

### A2 — Versioned dacpac artifact feed

Echelon-side CI publishes `VEO.dacpac` as a versioned package (Azure DevOps Artifacts/NuGet). VDS pins a version and restores the dacpac at build time; consuming a new VEO version is a one-line version bump in a PR.

- **Pros:** real versioning + provenance; no binaries in git; explicit, reviewable upgrade moments; the natural long-term shape for a cross-team contract; the same versioned artifact can drive mirror deployment (see B0).
- **Cons:** requires Echelon-team CI buy-in; classic `.sqlproj` doesn't restore package database references natively — either a pre-build restore step copies the dacpac into `ReferenceDacPacs/`, or the Databases projects migrate to the SDK-style `Microsoft.Build.Sql` format (a meaningful migration of its own, which also interacts with the VS-18-MSBuild publish constraint).
- **Status (2026-06-22): unlikely.** Requires Echelon to stand up CI and emit a versioned artifact from a source they don't codify — no SSDT/source project exists upstream (Cindy). Parked unless Echelon's tooling changes.

### A3 — Git submodule/subtree of the Echelon repo's SSDT source

If the Echelon repo holds the source schema as an SSDT project, mount it into the VDS solution and build the dacpac from source.

- **Pros:** full source-level visibility — schema diffs reviewable line by line; local builds always match the pinned commit.
- **Cons:** only works if the schema actually exists as SSDT source upstream; submodule ergonomics across the team's bare-repo/worktree clone styles; couples VDS builds to another repo's structure and conventions; if the mirror is a *subset* (see §5/§8), the upstream project models more than VDS needs.
- **Status (2026-06-22): ruled out.** Confirmed (Cindy) that Echelon holds no codified/SSDT source — the precondition for this option fails.

### A4 — Mirrored SSDT project in VDS (`Databases/VEO/`)

Maintain the mirror schema as a first-class SSDT project in the VDS repo, synced from Echelon releases via schema compare.

- **Pros:** best in-repo experience; schema fully greppable; VDS publishes mirrors itself; **if the mirror is a deliberate subset, this project *is* the natural place to define that subset** — the mirror schema becomes a VDS-owned contract derived from (not identical to) the source.
- **Cons:** a second source of truth with ongoing sync labor — though materially less risky here than in the general case, because the mirror is read-only and the "sync" is exactly the schema-compare activity already happening today, just landed in source control instead of run-and-forgotten.
- **Status (2026-06-22): live path #1.** Now that the mirror is confirmed to be a deliberate transformation (drops FKs/triggers/indexes), this project is the natural home for the *drop-rules* — the codified definition of how the source projects down to VEO. Deployment caveat: SSDT doesn't publish in the pipeline today (see §5), so choosing A4 means either adding a dacpac-publish step or keeping deployment manual.

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

> **Status (2026-06-22): live path #2 — substantially re-rated upward.** Two refinements neutralize the cons above:
> - **The fidelity con is largely moot.** A5 was downgraded for weak capture of constraint names, triggers, indexes, and odd legacy structures — but the projection *deliberately drops exactly those*. A FK-free, trigger-free, index-light schema of plain tables and columns is an *ideal* EF Core target, not a weak one.
> - **EF is the only representation that deploys in today's pipeline.** SSDT doesn't publish in the VDS pipeline; EF Core migrations already run in production (§5). So EF gives codified schema *and* a deployment path, where SSDT (A4) needs a new pipeline step.
>
> Two cons survive and must be managed: (1) the VeoSolutions SSDT build still needs a `VEO.dacpac` for the 117 procs / 75 synonyms — so even under A5, a dacpac is **extracted from a migrated throwaway DB in CI** as a build-reference byproduct; (2) `__EFMigrationsHistory` lives in VEO (a VDS-owned object in the projection) — acceptable now that VDS owns the projection definition and the RedGate compare is demoted to an input signal rather than a drop-everything deployer, but it should be excluded from any source-vs-VEO compare scope.

**Beyond modeling the mirror itself, EF Core also fits here:** (a) **B2 sidecar state** — the sync service's watermarks/run-history tables belong in the existing EF migrations projects, which own exactly this kind of schema; (b) a **migration-less, read-only DbContext** over the mirror for the sync service and any modern-layer reads — entity maps without a migrations assembly, validated against the codified schema (the §6 drift guard) rather than maintained as one. (Under the A5-as-primary path, the migrations project and this read DbContext can share entity maps.)

### Comparison

| | A1 auto-refresh | A2 artifact feed | A3 submodule | A4 in-repo SSDT | A5 EF migrations |
|---|---|---|---|---|---|
| Change visibility | Low (binary PR) | Medium (version bump) | High (source diff) | High (source diff) | High (C# diff) |
| Drift risk | Medium | Low | Low | Medium (drift-check pipeline) | Medium (authored migrations — same curate labor as A4) |
| Echelon-team burden | Low | Medium | Low–Medium | None | None |
| Works without upstream SSDT source | **Yes** (extract) | Yes (only if Echelon builds it — see status) | **No** | **Yes** | **Yes** |
| Supports a *transformed/subset* projection | No (snapshot of whole) | Only if upstream builds it | No | **Yes** (defines drop-rules) | **Yes** (drop-rules as entity maps) |
| Satisfies SSDT build reference (117 procs) | Yes | Yes | Yes | Yes | **No** directly — dacpac extracted from migrated DB as byproduct |
| Deploys via existing VDS pipeline | No (manual) | No (manual) | No (manual) | **No** — needs new dacpac-publish step | **Yes** — migrations already run in prod |
| Status after 2026-06-22 | Interim only | **Unlikely** | **Ruled out** | **Live path #1** | **Live path #2** |

> **The A4-vs-A5 fork (both viable — decision deferred).** With A1 as a cheap interim and A2/A3 pruned, the real choice is **SSDT project (A4)** vs **EF Core migrations (A5)**, and the refinements make both defensible:
> - **A4 (SSDT):** best in-repo schema fidelity and the most natural home for the drop-rules; produces the build-reference dacpac directly; *but* doesn't deploy in the pipeline without a new publish step.
> - **A5 (EF Core):** reviewable C# diffs, deploys via the existing migration pipeline, and the simplified projection removes its old fidelity penalty; *but* needs a dacpac extracted as a byproduct for the SSDT build, and puts `__EFMigrationsHistory` inside VEO.
>
> The two are not mutually exclusive — a hybrid (SSDT owns the dacpac/build reference; EF owns deployment + the read model) is possible but carries dual-representation upkeep. Pick after Q5 (projection scope) and the deployment-ownership question (Q10) are settled.

**Pivotal unknown (narrowed):** Q1 is now answered — Echelon holds **live databases only**, no SSDT source (so A2/A3 are out). The remaining unknown is the projection scope (full-schema-minus-objects vs. a table subset, §8 Q5), which informs but doesn't decide the A4-vs-A5 fork.

---

## 5. Option Set B — Schema Deployment & Sync-State Boundary

Two related questions: who deploys schema to the mirror environments, and where does the sync service keep its operational state.

### B0 — Mirror schema deployment (the project-type fork)

Today RedGate SQL Compare is run **as part of the deployment process** to sync schema between databases — operator-driven and reactive to VEO-touching work (Q2/Q4). The codified A-path replaces that compare-and-sync step with either a dacpac publish or EF migrations. How that gets codified depends directly on the Option-Set-A choice, because **deployment in the VDS pipeline is gated by project type**:

- **If A4 (SSDT):** deployment becomes a **dacpac publish** (`sqlpackage /a:Publish`) from the same artifact VDS builds against — *replacing the RedGate compare step the deployment process already runs* (Q4), not bolting deployment onto a process that had none. SSDT projects aren't published in the pipeline today, so it's still a new publish mechanism (technically straightforward; flagged unlikely-but-possible for production). Until then, A4 deployment stays manual.
- **If A5 (EF Core):** deployment is **migrations**, which **already run in production** in the VDS pipeline. No new mechanism — the mirror joins the existing migration flow. This is the single biggest argument for A5.

Either way:

- The reference VDS compiles against and the schema deployed to `Veo_DEV` … `CCDI_Veo` should be the *same versioned artifact/migration set* — parity becomes structural, not aspirational.
- **RedGate SQL Compare demotes from deployer to input signal.** Because VEO is a deliberate transformation, a raw source-vs-VEO compare is *permanently non-empty* (the dropped FKs/triggers/indexes always diff). So the compare becomes "the source changed — go author the corresponding migration/SSDT change," and any drift *check* must compare VEO against the **codified intended schema**, not against the source.
- **A build-reference dacpac is required regardless.** The VeoSolutions SSDT build needs a `VEO.dacpac` to resolve the 117 procs / 75 synonyms. Under A4 it falls out of the build; under A5 it's extracted from a migrated DB in CI.

This needs agreement on **who runs deployment** (VDS pipeline vs. Echelon team) per environment.

### B1 — Sync-service state via change requests to the Echelon team

All operational-state schema (watermarks, run history, batch staging) is requested into the source/mirror schema. Gates every sync-service iteration on another team's cycle; also pollutes a mirror with non-mirror objects. Poor fit.

### B2 — Sidecar persistence owned by VDS *(recommended)*

Sync-service state lives in schema VDS already owns — new tables in `VeoSolutions` (existing SSDT + EF dual management, `z_` audit conventions, publish profiles all apply) or a distinct database if isolation is preferred. VEO receives mirror **data only**; its schema stays purely the transformed projection. (If A5 is chosen, this state is a natural fit for an EF migrations project — the same machinery that would model the mirror.)

### B3 — VDS-owned schema inside the VEO database

~~Viable middle ground if cross-DB transactions prove painful.~~ **Demoted after the mirror correction:** putting VDS-owned objects inside VEO conflicts with the mirror model — schema-compare/publish runs from the source would flag or drop them, and the mirror stops being a thin reflection. Only worth revisiting if staging-swap mechanics (§6) demand same-database staging tables, and then only with an agreed carve-out schema excluded from compares.

---

## 6. Option Set C — Data Sync Architecture (Echelon source → VEO mirror)

> **Scope (2026-06-22): optional / secondary.** Schema codification (A + B) is the primary task; the data-sync successor is a stretch goal. It is captured here so the schema contract is designed with it in mind, not committed to for this phase.

**Current state:** the in-house **DataSync** app moves data into the mirror, outside the VDS codebase. The design question is what its codified successor looks like — a service built *in* the VDS codebase, against the codified schema from Option Set A. (Whether it replaces DataSync outright or wraps/formalizes it is §8 Q3.)

### C1 — Hangfire job inside the VeoDesignStudio app

Hangfire server + dashboard are already configured in `Startup.cs` (precedent: `TenantProgramController`'s RefreshTenantProgram wrapper). A scheduled job pulls from the source and refreshes the mirror.

- **Pros:** zero new infrastructure; dashboard, retries, scheduling for free; fastest path to a working sync.
- **Cons:** couples mirror refresh to the buyer-facing web app's lifecycle — deploys and restarts interrupt syncs; large refreshes contend with user traffic; per-customer prod topology gets awkward (the app instance would need reach into both source and mirror per tenant).
- **Status (2026-06-22): preferred.** Hangfire is **additive to the existing app** (server + dashboard already configured) rather than a whole new deployable — the deciding factor over C2. Pairs naturally with C5 (Hangfire triggers an SSIS/ETL package).

### C2 — Standalone worker service — the DataSync successor *(deprioritized — a whole new app)*

A new deployable (e.g. `BuildOnTechnologies.VDS.VeoMirrorSync`, .NET worker/`BackgroundService`) whose single job is source → mirror data sync. Built against the codified schema; consumes the modern layers where useful.

- **Pros:** the sync's deployment/scale/schedule decouples from the web app — exactly the "manageable within our dev cycles" goal; clean home for watermarking, merge logic, scope filtering, and drift checks; testable in isolation (spin up source-shaped and mirror-shaped DBs from the codified schema in CI); per-environment/per-customer config is first-class.
- **Cons:** net-new deployable (hosting, monitoring, config); duplicates some bootstrapping.
- **Status (2026-06-22): less likely.** Strong on isolation, but it's a net-new deployable; the team prefers adding to the existing app (C1) over standing up another service.

### C3 — Platform-level sync (SQL replication / log shipping / CDC-driven copy)

Let SQL Server do it: transactional replication or a CDC-fed copy job from source to mirror.

- **Pros:** battle-tested, low-latency, no app code to maintain for the copy itself.
- **Cons:** runs against the stated intent ("leverage the database in code to create a new service/app"); subset/transform scope is awkward in replication; per-customer prod topologies multiply replication admin; visibility/debugging lives in DBA tooling, not the dev cycle. Included as the baseline any app-level design should justify itself against.
- **Status (2026-06-22): ruled out.** Confirmed — because VEO is not a true mirror (objects dropped, shapes transformed), SQL replication / log shipping / CDC-copy can't reproduce the projection. Dead.

### C4 — Hybrid: platform change-detection + app-level apply

CDC or rowversion high-water marks on the source feed a VDS-owned worker (C2) that applies changes to the mirror as idempotent, scope-filtered merges.

- **Pros:** incremental sync without polling-diff cost; the app layer keeps scope/transform/audit control; best fit if the mirror is a subset.
- **Cons:** requires Echelon-team agreement to enable CDC/rowversion reads on the source; two moving parts.
- **Status (2026-06-22): growth path.** Gated on Echelon enabling CDC/rowversion (Q7). Revisit only when full-refresh size/latency forces incremental.

### C5 — SSIS / ETL package, orchestrated by Hangfire *(realistic transform engine)*

Because the projection *transforms* the source (drops objects, reshapes), the copy step is genuinely an ETL job, not a replication. An **SSIS package** (or equivalent ETL) encodes the table-by-table extract/transform/load, and a **Hangfire job (C1) triggers and monitors the package runs** on schedule. This pairs the two options raised in scoping: Hangfire for orchestration, SSIS for the heavy transform.

- **Pros:** ETL tooling is built for exactly this transform-on-copy; packages are independently testable and runnable; Hangfire gives scheduling/retries/dashboard with no new app.
- **Cons:** SSIS is a separate authoring/deployment surface (SSISDB, project deployment) outside the C# dev loop; transform logic lives in DTSX, not in the codified-schema-aware C# layer; debugging spans two tools.
- **Status (2026-06-22): leading pairing with C1.** Most realistic if the transform is non-trivial and you want to keep it out of the web app's request path.

### Cross-cutting concerns (any C option)

- **Refresh model:** full refresh vs. incremental. Full refresh is simplest and matches "thin mirror," but per-customer prod sizes may force incremental (watermark/CDC).
- **Consumer-safe swaps:** 117 procs read the mirror continuously. Refreshes should be atomic from the reader's perspective — staging-table + `sp_rename`/synonym swap or partition switch, so readers never see half-synced state.
- **Idempotency:** merge keyed on source natural keys; a re-run after failure converges rather than duplicates.
- **Scope as code:** the scope definition lives in the sync service's config/schema contract, versioned with it — three layers: which **customers** sync (Q8: only certain ones, not all), which **tables**, and the per-table `WHERE` filter below.
- **Per-table sync filters (carry-over from DataSync):** DataSync exposes a free-form `WHERE`-clause field per synced table, letting an operator scope what each table pulls at a given time. The successor must keep this flexibility — filters as versioned, per-table config in the scope contract.
- **Referential intelligence (new, beyond DataSync):** before/while applying a filtered pull, validate that the filter (or source-side relationships) won't orphan rows — e.g. a child row arrives whose parent the `WHERE` clause excluded. Because the projection itself *drops* FKs, this integrity check lives in the sync logic, not in the mirror's constraints: dependency-aware load ordering plus a pre-flight check that flags would-be-orphaned rows rather than silently importing them.
- **Schema-drift guard:** before syncing, the service validates mirror schema version against the codified schema it was built for (ties A and C together); mismatch → halt and alert rather than corrupt.
- **One-way enforcement:** service credentials are read-only on source, write on mirror; VDS app credentials stay read-only on the mirror. (Source access is feasible — Q6, attainable via Cindy — but per-environment **service accounts** still need provisioning beyond Justin's personal access.)
- **Multi-tenancy:** confirmed **per-customer source → per-customer mirror** (`CCDI_Veo`, `AFI_VEO`, `EPLAN_VEO`), and **only certain customers sync** (not all — Q8). So config carries both per-tenant connections *and* a customer-selection list; one service with tenant config beats per-customer forks.
- **Operational state:** run history, watermarks, row counts, validation results in the B2 sidecar — with `z_` auditing per VDS persistence conventions.

---

## 7. Strawman Recommendation (to iterate on)

1. **A1 now → then choose A4 or A5 (both viable):** automate dacpac refresh immediately (kills the stale-snapshot problem cheaply, and works against live-only Echelon via extract). A2/A3 are out — no upstream SSDT source. The durable representation is then a deliberate **SSDT-vs-EF-Core decision**: A4 owns the drop-rules and emits the build-reference dacpac directly but needs a new publish step to deploy; A5 deploys via the existing migration pipeline and the simplified projection suits it well, at the cost of an extracted build-reference dacpac and `__EFMigrationsHistory` in VEO. Decide after Q5 (projection scope) and Q10 (deployment ownership) are settled.
2. **B0 follows A; B2 regardless:** the deployment mechanism is whatever the A-choice implies (A4 → add a dacpac-publish step; A5 → existing migrations). RedGate compare demotes to an *input signal* (source-vs-VEO is permanently non-empty by design); any drift *check* runs VEO against the codified intended schema. All sync-service state in VDS-owned schema (B2); VEO receives data only.
3. **C is optional — leaning Hangfire (C1) + SSIS (C5):** if pursued, a Hangfire job (additive to the existing app) orchestrates an SSIS/ETL package that performs the transform-on-copy; full-refresh with consumer-safe swaps to start, CDC/rowversion incremental (C4) only if size/latency demand it and Echelon can enable it. Carry over DataSync's per-table `WHERE` filters and add referential pre-flight checks. Replication (C3) and a standalone worker (C2) are both deprioritized.

## 8. Open Questions

| # | Question | Why it matters | Owner |
|---|---|---|---|
| 1 | ~~Does the Echelon team hold the source schema as SSDT/source, or only live databases?~~ **RESOLVED (Cindy, 2026-06-22): live databases only — not codified in GitHub.** A2/A3 out; A1/A4/A5 work via extract. | Decided A2/A3 are off the table | ✅ Closed |
| 2 | ~~Cadence/volume of source schema change, and how we hear about it?~~ **RESOLVED (Justin, 2026-06-22): no cadence — changes happen reactively, as VDS takes on work that touches the VEO database.** | Refresh automation should be **work-triggered** (on VEO-touching work / at PR time), not a scheduled poll | ✅ Closed |
| 3 | DataSync specifics: who owns it, where does it live, what does it sync (tables, full vs. incremental), on what schedule, and what are its known gaps? *(Known so far: per-table free-form `WHERE`-clause field for sync scoping — a requirement to carry forward, §6.)* | Replace vs. wrap decision; requirements baseline for the C successor | Justin → DataSync owner |
| 4 | ~~RedGate SQL Compare: who runs it, when, against which environments?~~ **RESOLVED (Justin, 2026-06-22): RedGate SQL Compare is used *during the deployment process* to sync schema between databases.** So today's schema deployment *is* a RedGate compare-and-sync step — exactly what the codified A-path (dacpac publish or EF migrations) would replace. | Current-state evidence for B0 | ✅ Closed |
| 5 | ~~Mirror scope: full schema or subset; trim further?~~ **RESOLVED (Justin, 2026-06-22): the mirror is the deliberate transformation it is today** (FKs/triggers/indexes dropped); no deliberate re-subsetting planned for this phase. Customer-row scoping is handled separately (Q8). | Sets the A-path schema contract; deeper proc-dependency trimming is a possible later phase | ✅ Closed |
| 6 | ~~Can a VDS-owned service get network/credential access to the Echelon source per environment/customer?~~ **RESOLVED (Justin, 2026-06-22): yes — attainable via Cindy; Justin already has personal access.** Direct source reads are feasible; per-environment **service-account** provisioning still to be requested. | Feasibility of C2/C4/C5 direct source reads | ✅ Closed |
| 7 | Does the source have CDC or rowversion availability (or could it)? | Gates C4 incremental | Echelon team |
| 8 | ~~Per-customer mirrors — one source per customer, or shared?~~ **RESOLVED (Echelon via Justin, 2026-06-22): per-customer source, and only *certain* customers come over (not all).** Topology is per-customer source → per-customer mirror, with a customer-selection layer above the per-table filters. | Multi-tenant sync topology + customer-selection scope | ✅ Closed |
| 9 | ADO epic + feature IDs for this effort *(open — Justin to locate where the ADO source item lives, 2026-06-22)* | Branch naming and commit references once implementation starts in the VDS repo | Justin |
| 10 | Appetite for changing the pipeline to deploy SSDT (dacpac publish), vs. committing to EF Core migrations for VEO deployment? | The deciding input for the A4-vs-A5 fork | Justin / DevOps |

## 9. Suggested Next Steps

1. Iterate on this doc — challenge the option framing and the strawman in §7.
2. Resolve remaining open questions — **Q1 closed** (Echelon is live-only); still need DataSync specifics (Q3) and the A4-vs-A5 deployment decision (Q10). These gate both A and C.
3. Run the mirror-scope analysis (Q5): the proc→synonym inventory is done ([`veo-proc-synonym-references.md`](./veo-proc-synonym-references.md) — 117 procs across 59 of the 75 synonyms; 16 synonyms have no proc references). Remaining: column-level usage, plus views/functions/triggers as consumers.
4. Create the ADO epic/feature; spin up per-PBI plan files in the VDS repo under `documentation/plans/` (spike candidates: A1 refresh automation; an A4-vs-A5 proof — model a handful of VEO tables both ways and confirm the EF→dacpac extract satisfies the SSDT build; if C is pursued, a Hangfire-triggered SSIS package skeleton with a consumer-safe swap).
