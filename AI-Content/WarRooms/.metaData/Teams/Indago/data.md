# Indago — VEO Indago

**Internal handle:** Indago
**Product name:** VEO Indago (no public marketing presence as of 2026-05-14)
**Persona file:** [`persona.md`](./persona.md) — in-universe write-up as a unit under Atlas.
**Commanding persona:** [`EricHickey_Atlas`](../../../Personas/EricHickey_Atlas/) — Director of Software Development, BuildOn Technologies (Senior Leadership Team).
**Last updated:** 2026-05-14

---

## What this team owns

Indago owns **VEO Indago** — a Material Requirements Planning (MRP) application for countertop manufacturing. Per the repository README: *"Indago is a Material Requirements Planning application for countertop manufacturing. It receives Manufacturing Orders from Echelon and runs the Reeveston manufacturing plant's production schedule, optimizing saw and workstation utilization across shifts."*

Key responsibilities:

- Ingest Manufacturing Orders from **Echelon ERP** (the customer-facing order system owned by a different team).
- Run the **production schedule** for the Reeveston manufacturing plant.
- **Optimize saw and workstation utilization** across shifts.
- Manage the manufacturing order lifecycle: orders, sales-order types, change requests, run types (per the Wiki's `Application-Documentation.md` reference in the README).

The application is back-of-house: it does not interact with homebuyers or with public-facing sales surfaces. Its users are plant operators, schedulers, and (per the example branch name in the README) developers like `ehickey`.

## Where it sits in the company

- **Surface:** internal / back-of-house. Operates the actual factory.
- **Upstream / downstream systems:**
  - **Upstream:** receives Manufacturing Orders from **Echelon ERP** (owned by Cindy Pieper's team).
  - **Downstream:** drives the **Reeveston manufacturing plant** — physical saws, workstations, shifts.
- **Public on the corporate site?** No — Indago is not listed on `buildontechnologies.com/products`. The website presents Echelon ERP and VEO Design Studio as the two customer-facing products; Indago is an operational tool, not a product line.

## Team composition

- **Commander:** [`EricHickey_Atlas`](../../../Personas/EricHickey_Atlas/) — Director of Software Development. Eric has led Indago in some form since at least November 2015 (he came in as Senior Technical Lead — VEO Indago at that point, per his LinkedIn). He continues as the commanding persona today.
- **Team members (3, plus Eric's command):**

  | Real name | Codename / persona folder | Role on the team |
  |---|---|---|
  | Jennifer Hickey | [`JenniferHickey_DTD`](../../../Personas/JenniferHickey_DTD/) | Product Owner |
  | Joseph Arellano | [`JosephArellano_Anvil`](../../../Personas/JosephArellano_Anvil/) | Team Lead |
  | Wade Welch | [`WadeWelch_Tinker`](../../../Personas/WadeWelch_Tinker/) | Software Developer |

  All three have existing persona folders. Per user account 2026-05-14.

  **Note on Jennifer Hickey (DTD):** Jennifer's current role is PO on Indago, but the **DTD codename comes from a prior role** — she was a **QA Lead serving both VDS and Indago** before transitioning to the Indago PO seat. Per user 2026-05-14: "DTD doesn't necessarily fit her current position but it is fun due to her previous engagement." Useful context for both her own future persona.md and for any in-universe scene where the codename's earlier-career meaning gets called back to.
- **Headcount:** **3 people on the team plus Eric** (effective unit size: 4). Per user account 2026-05-14.
- **Structure:** single team with an explicit **Team Lead** (Joseph Arellano / Anvil). Interim Scrum Master at the company level is Eric himself per his LinkedIn; day-to-day technical leadership runs through Anvil.

## Tech stack

Pulled directly from `c:/github/botdevjustinpope/buildontechnologies/veoindago/README.md`:

- **Backend:** .NET 9, C# (nullable enabled). MediatR. Serilog. SignalR with a SQL backplane. FluentValidation. Swashbuckle.
- **Architecture:** DDD + layered — `Api → Application → Service / Model / Repository / Infrastructure / Validation`.
- **ORM:** Entity Framework Core 9.
- **Frontend:** Aurelia 1 + TypeScript 4 (ES5/AMD), Aurelia CLI, Sass, Syncfusion ej2.
- **Tests:** MSTest + Moq + EF Sqlite (backend); Karma + Jasmine (frontend).
- **CI/CD:** Azure DevOps Pipelines (master trigger).
- **Database:** SQL Server (LocalDB or full) 2019+.
- **Local dev ports:** API on `http://localhost:1380`, frontend on `http://localhost:9090`.

Branch / PR conventions (from the README):

- Default branch: `master`.
- Branch naming: `{user}/{story-number}/{purpose}` — e.g. `ehickey/31895/order-collapse-fix`.
- 2 reviewers required per PR; requester cannot self-review.
- CI runs on merge to `master` (not as a PR gate); local verification is expected before opening the PR.

## The Reeveston plant

The physical site Indago drives.

- **Name:** the Reeveston manufacturing plant (referenced by name in the Indago `README.md`).
- **Function:** countertop manufacturing. Indago schedules saw and workstation utilization across shifts to keep the plant's throughput aligned with the Manufacturing Order queue coming in from Echelon ERP.
- **Operators:** plant operators and schedulers on-site at the plant; the Indago dev team is *not* the plant operations team. Indago is the *system* that runs the schedule; humans at Reeveston run the physical line.
- **In-universe role:** the Reeveston works is the gun emplacement / battery position for the Indago Artillery Section (see `persona.md`). Every Manufacturing Order is a fire mission delivered from Reeveston.
- **Geographic location:** not directly stated in the README or the public corporate site. "Reeveston" doesn't surface in a quick search as a well-known town — likely an internal name for the actual physical plant, or a small locale near a BuildOn customer site. Worth confirming with the user before any persona content treats it as a real-world place.

This section is intentionally short. Anything that's *certain* lives here; anything inferred or speculative is held back in **Open questions** below.

## History

- **2001:** "Echelon" launched, originally deployed for countertops (per [BuildOn About Us](https://www.buildontechnologies.com/about-us/) corporate history). This is upstream lineage that later split — Echelon is now ERP for interior-finish companies, while Indago is the MRP that runs the actual plant.
- **November 2015:** Eric Hickey joined as Senior Technical Lead — VEO Indago. Per his LinkedIn, he led design + development of a Single Page Application (TypeScript + Aurelia), C# / ASP.NET MVC REST API backend, DDD with SQL Server + Entity Framework, and Azure DevOps CI/CD with automated tests and deployments. Served as Scrum Master.
- **October 2019:** Eric transitioned to Senior Technical Lead — VEO Design Studio; presumably continued some Indago oversight given his later Director scope.
- **February 2020 – present:** Eric leads both Indago and VDS as Director of Software Development.
- **Recent (pre-2026-05-14):** a significant **Production Schedule refactor** — the repo contains a `handoff-production-schedule-refactor.pdf` at the root, and the Aurelia-frontend rules file in `.claude/rules/` is explicitly scoped around "Production Schedule constraints."
- **Recent (pre-2026-05-14):** the codebase has migrated to .NET 9 and EF Core 9; MediatR, SignalR with a SQL backplane, FluentValidation, and Swashbuckle have been added to the stack since the 2019-era LinkedIn description. The frontend remains on Aurelia 1 + TypeScript 4. The repository has been Claude-Code-configured (`.claude/CLAUDE.md`, scoped `.claude/rules/`, `buildontechnologies/skills` marketplace).

## Notable Operations (PBI posters) anchored on this team

*TBD — needs user input.* The Production Schedule refactor is a strong candidate to have an anchored Operation poster; needs confirmation.

## Source notes

- *Indago repository README (`c:/github/botdevjustinpope/buildontechnologies/veoindago/README.md`):* read 2026-05-14. Source for the domain definition (MRP, countertop manufacturing, Reeveston plant), the complete tech stack, the branch/PR conventions, the Production Schedule refactor reference, and the Claude-Code-configured posture.
- *Eric Hickey's LinkedIn PDF (`../../../Personas/EricHickey_Atlas/Profile.pdf`):* read 2026-05-13. Source for the 2015 founding-era technical work (SPA + Aurelia + TypeScript, REST API in ASP.NET MVC, DDD, SQL Server + Entity Framework, Azure DevOps CI/CD, Scrum Master role).
- *BuildOn corporate site `buildontechnologies.com/about-us/` and `/products/`:* fetched 2026-05-13. Source for the 2001 Echelon-for-countertops history; also confirms Indago's absence from the public product list.
- *User account, 2026-05-14:* user clarified Indago and Echelon are distinct products — Echelon is the ERP, Indago handles manufacturing — and that Indago is intentionally absent from the public website. User also provided the full 3-person Indago team roster: Jennifer Hickey (PO, DTD), Joseph Arellano (Team Lead, Anvil), Wade Welch (SWE, Tinker). User accepted the Artillery Section unit designation + motto, and asked for the Reeveston plant to be marked in this file (see dedicated section above). **Additional note on Jennifer Hickey:** user clarified her DTD codename traces to a prior **QA Lead** role that served both VDS and Indago — codename predates her current Indago-PO role and is retained as fun-historical handle rather than a fit-the-current-job descriptor.
- *Inferred:* the Production Schedule refactor's *recency* is inferred from the `handoff-production-schedule-refactor.pdf` sitting at the repo root (handoff documents tend to be recent) and the `.claude/rules/aurelia-frontend.md` carrying "Production Schedule constraints" guidance. Exact dates not verified.

## Open questions

- The Reeveston plant's actual geographic location — is "Reeveston" a real town, an internal codename for the physical site, or something else?
- Production Schedule refactor — when did it happen, who led it, and is it the anchor for one of the existing Operation posters in `WarRooms/PBI Posters/`?
- The 2001 "Echelon deployed for countertops" history vs. today's Indago — is Indago a direct descendant of that 2001 system, a clean-sheet rewrite, or somewhere in between?
- The Wiki/ folder (`Wiki/Application-Documentation.md`, `Wiki/Patterns-and-Practices/`, `Wiki/Build-and-Release-Documentation/`, `Wiki/Automated-Testing-Guides/`) almost certainly tightens this `data.md` further. Worth a follow-up read if a deeper Indago profile is needed.
- The `DTD` codename — *origin* is now known (prior QA-Lead-across-both-teams role per user 2026-05-14), but the **literal acronym expansion is still open**. Worth locking when `JenniferHickey_DTD/persona.md` is drafted.
- Roster will be vetted by the user with the team members themselves before persona.md / persona_future.md role assignments are locked.
