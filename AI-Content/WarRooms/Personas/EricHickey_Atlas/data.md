# Eric Hickey — Atlas

**Real name:** Eric Hickey
**War Room codename:** Atlas — see [`persona.md`](./persona.md) for the in-universe write-up.
**Last updated:** 2026-05-14

---

## Role at the company

- **Title:** Director — Software Development
- **Team / department:** BuildOn Technologies — leads both the **VEO Design Studio Team** and the **VEO Indago Team**. Member of the Senior Leadership Team.
- **Start date / tenure:** Joined BuildOn November 2015 as Senior Technical Lead — VEO Indago. ~10 years 7 months tenure as of mid-2026. In the Director seat since February 2020 (~6 years 4 months).
- **Day-to-day:** Strategic direction across the two dev teams, interim Scrum Master for both, and a hands-on member of the Senior Leadership Team shaping company-wide decisions. The two teams have distinct surface areas: **VEO Design Studio** is the customer-facing homebuyer design-selection software; **VEO Indago** is an internal MRP (Material Requirements Planning) application that runs the production schedule for BuildOn's Reeveston countertop-manufacturing plant. Indago is back-of-house — not on the public Products page — and receives Manufacturing Orders from Echelon ERP. Eric runs leadership initiatives — internal training channels, the QA program, ongoing book clubs — alongside the regular delivery rhythm.

## Background

**Prior roles** (most recent first):

- **BuildOn Technologies** — Nov 2015 – present (~10 years 7 months total tenure)
  - Director — Software Development — Feb 2020 – present
  - Senior Technical Lead — VEO Design Studio — Oct 2019 – Feb 2020. Led the homebuyer option-selection app for the design-center experience; ran the .NET Framework → .NET Core conversion; introduced Entity Framework with repository / specification patterns; built a provider model to abstract the visualization vendor.
  - Senior Technical Lead — VEO Indago — Nov 2015 – Oct 2019. Led design + development of a residential countertop manufacturing app from inventory through shipping (eliminated paper processing, optimized machine + material usage, integrated external order/reporting). SPA in TypeScript + Aurelia; C# / ASP.NET MVC REST API; DDD; SQL Server + Entity Framework; CI/CD on Azure DevOps. Served as Scrum Master.
- **ABB** — Technical Lead — Jan 2013 – Sep 2015. Greenfield .NET / C# Process Safety Management product for oil & gas. Owned technical design, application structure, SDLC. DDD-based application with ASP.NET MVC + JavaScript front-end, JSON RESTful Web API, SQL Server + Entity Framework. Set up CI with Team Build, automated tests/deployments, style enforcement, static analysis. Established code review, coding standards, user-story management, source-control structure.
- **Black Knight** — May 2002 – Jan 2013 (~10 years 9 months total tenure)
  - Senior Software Architect — Nov 2008 – Jan 2013. Primary architect on the redesign of the legacy core engine that processes millions of messages per day for the largest US banks. Built highly configurable data transformations, storage, complex workflows using C#, MSMQ, XSLT, XML, MS SQL Server, WCF. PCI-compliance work (private data + encryption). Drove DDD-led design sessions.
  - Web Development Manager — Aug 2006 – Nov 2008. Led 6–10 web developers. Onboarded one of the nation's largest lending institutions on an accelerated timeline. Primary Production Support Team + Disaster Recovery Team (24-hour first responder for fail-over).
  - Senior Web Developer / Team Lead — Oct 2004 – Aug 2006. ASP.NET + C#; PDF upload + rules-engine work.
  - Web Developer — May 2002 – Oct 2004. ASP (VBScript), ASP.NET (C#), IIS. 24-hour on-call primary production support.
- **Secure Digital Assets** — Web Developer — Feb 2001 – Mar 2002. Web-based digital asset management system in VBScript / JavaScript / cross-platform HTML on IIS + ASP.
- **Frontera.com** — Web Developer — May 1999 – Feb 2001. ASP + VBScript site development and maintenance.

**Education:** Not listed on the LinkedIn PDF export.

**Domains of experience:**

- Loan Origination (Black Knight)
- Oil & Gas (ABB — Process Safety Management)
- Home Building (BuildOn — VEO Design Studio + Indago)

He explicitly frames this industry-hopping as deliberate adaptability rather than churn.

**Career arc:** Web developer → senior architect → technical lead → director. The recurring through-line is .NET / C# and Domain Driven Design — DDD appears as a design philosophy at three different employers, not a buzzword.

## Core skills

LinkedIn-listed top skills:

- Communication
- Engineering Management
- Technical Leadership

Demonstrated across the role history:

- .NET / C# (25-year foundation)
- ASP.NET MVC, ASP.NET Core, ASP.NET Web API
- Entity Framework, SQL Server
- Domain Driven Design (recurring at ABB, BuildOn, Black Knight)
- TypeScript + Aurelia (Indago SPA)
- Azure DevOps CI/CD (Indago)
- MSMQ, XSLT, XML, WCF (Black Knight core engine)
- Repository / specification patterns
- Provider-model / vendor-abstraction design
- Scrum / agile delivery (interim Scrum Master at BuildOn for both teams)
- Team leadership at multiple scales (6–10 devs at Black Knight; two full dev teams at BuildOn)

**Languages:** English.

## Notable contributions in this codebase / org

### Indago — confirmed via the repo

The `VeoIndago` codebase (`c:/github/botdevjustinpope/buildontechnologies/veoindago`) confirms Eric's LinkedIn description of his Senior-Technical-Lead-era ownership and shows it has continued under his Director tenure:

- **Indago is the MRP for countertop manufacturing** at the Reeveston plant. Receives Manufacturing Orders from Echelon; runs the production schedule; optimizes saw + workstation utilization across shifts. (`README.md` summary line.)
- **Stack matches the LinkedIn entry exactly:** .NET (now on 9) backend with DDD + layered architecture (`Api → Application → Service / Model / Repository / Infrastructure / Validation`), Entity Framework Core 9, Aurelia 1 + TypeScript frontend, Azure DevOps CI/CD. Newer additions in the current stack: MediatR, SignalR (SQL backplane), FluentValidation, Swashbuckle, Serilog.
- **Eric is an active contributor, not just a manager.** The branch convention `{user}/{story-number}/{purpose}` uses the example `ehickey/31895/order-collapse-fix` in `README.md` — the username prefix is his.
- **Production Schedule is the central domain object** in the application. A `handoff-production-schedule-refactor.pdf` at the repo root and pattern guidance in `.claude/rules/aurelia-frontend.md` ("Production Schedule constraints") indicate a recent significant refactor in this area.
- **The repo is Claude-Code-configured** — `.claude/CLAUDE.md`, scoped rules under `.claude/rules/`, the `buildontechnologies/skills` marketplace, and explicit example prompts referencing this codebase. Eric's team is set up for AI-assisted development; this is a deliberate posture, not an accident.

### Other BuildOn-era contributions from the LinkedIn export (Director level)

- **Co-architected a new product catalog management system using Domain Driven Design** — explicitly called out as enhancing end-user capability to manage very large product sets.
- Initiated a **full-stack professional development training channel** across the dev teams.
- Facilitated the introduction of a **robust Quality Assurance program** — improved product quality, fewer post-release defects.
- Initiated and led **multiple book clubs** as a learning + team-bonding mechanism.
- Streamlined project planning, resource allocation, software development processes more generally.

### Still TBD

PBI / Operation-poster anchors haven't been collected. Ask the user to point at the specific *Operations* (PBI posters) Eric led, anchored, or unblocked across the team's history.

## Public profile links

- **LinkedIn:** https://www.linkedin.com/in/ericphickey/
- **Personal email (on LinkedIn):** eric@thehickeys.org

## Source notes

- *LinkedIn profile PDF export (`Profile.pdf` at this folder root, 6 pages):* read 2026-05-13. All work-history dates, role descriptions, accomplishments, and listed top skills come directly from this PDF.
- *BuildOn corporate site (`buildontechnologies.com/about-us/` and `/products/`):* fetched 2026-05-13. Confirms title "Director — Software Development," confirms VEO Design Studio is customer-facing, confirms Echelon ERP is a distinct product owned by Cindy Pieper (Director of Development for VEO Echelon).
- *VEO Indago repository (`c:/github/botdevjustinpope/buildontechnologies/veoindago`, `README.md`):* read 2026-05-14. Source for the Indago domain definition (MRP, countertop manufacturing, Reeveston plant, upstream relationship with Echelon), the current stack, the `ehickey/...` branch-prefix evidence, and the Production-Schedule-refactor reference.
- *User account, 2026-05-14:* user clarified that "Echelon is an ERP app, Indago is something different that helps with manufacturing" and noted Indago is intentionally absent from the public website. That framing is reflected in the "Day-to-day" section.
- *Inferred:* the "Domain Driven Design through-line" framing is a derived observation across three employers, not a single LinkedIn statement. The "industry-hopping as deliberate" interpretation is paraphrased from his Summary section.
- *Not verified:* the personal email `eric@thehickeys.org` is on the LinkedIn export but is presumably a personal address; the BuildOn work address is not on the profile.

## Open questions

- Education / degrees — not on the LinkedIn export. Did Eric attend a specific university; is there a CS or engineering degree to record?
- BuildOn-specific Operations — which PBI posters did Eric directly lead, anchor, or unblock? The Indago codebase confirms the broad ownership; the per-Operation map is still missing.
- Confirmation of the **Atlas** codename's rationale — see `persona.md`, where a proposed reading is recorded for review.
