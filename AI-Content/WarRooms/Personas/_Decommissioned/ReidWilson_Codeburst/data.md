# Reid Wilson — Codeburst

**Real name:** Reid Wilson
**War Room codename:** Codeburst — see [`persona.md`](./persona.md) for the in-universe write-up.
**Last updated:** 2026-05-22

---

## Status

**Departed — voluntary, government job.** Per user account: Reid **voluntarily left and got a new job with the government the week of 2026-03-09.** LinkedIn profile (PDF in this folder) still shows "BuildOn Technologies — Full-Stack Software Developer — January 2022 - Present (4 years 5 months)" as of the PDF export; that "Present" tag is stale relative to the actual departure.

Effective BuildOn tenure (FTE): **January 2022 – ~March 2026** (~4 years 2 months), plus a prior summer-intern stint May–Aug 2021.

The Texas A&M senior capstone (BRL-CAD, sponsored by the **U.S. Army Futures Command**) foreshadowed the eventual government move.

---

## Role at the company

- **Title:** Full-Stack Software Developer.
- **Team / department:** BuildOn Technologies — VEO Design Studio. Per LinkedIn: *"the company's flagship website VEO Design Studio... a massive web app allowing homebuyers to design their dream home online."* He was not on the VDS roster locked in `Teams/VDS/data.md` (2026-05-14) — that 4-person roster was set after his departure.
- **Start date / tenure:** **Summer 2021** (intern, May–Aug 2021) → **January 2022 – ~March 2026** (FTE, ~4 yrs 2 mo).
- **Day-to-day:** Per LinkedIn — full-stack VDS work: SQL databases, C# in .NET, JS frameworks (Durandal, Aurelia, Angular), styling, deployment. Also explicitly: **"Bring new developers up to speed quickly"** — onboarding owner for the VDS codebase.

## Background

**Prior roles** (most recent first):

- **BuildOn Technologies** — Full-Stack Software Developer — Jan 2022 – ~Mar 2026 (~4 yrs 2 mo). Houston, TX.
- **BuildOn Technologies** — Full-Stack Software Developer (intern) — May 2021 – Aug 2021 (4 months). Houston, TX. Pre-FTE summer with the same team. Notable intern projects: redesigned the Admin-portal feature-flag page; created the **Builder Feature Audit** page; built the per-sub-area pricing popup in Design My Home.
- **iD Tech Camps** — Instructor — Jun 2019 – Aug 2019 (3 months). Houston (Rice University campus). Taught *Java Coding Minecraft Mods* to kids age 7–17. Offered Lead Instructor for Summer 2020 (camp cancelled — COVID).
- **Plato's Closet** — Cashier — summers 2015 + 2016. The Woodlands, TX.

**Education:**

- **Texas A&M University** — BS, **Computer Science** (minors: **Cybersecurity** and **Math**) — Aug 2017 – Dec 2021.
  - **Computer Science GPA 4.0** / cumulative GPA 3.9.
  - **Senior capstone:** collaborated with a **U.S. Army Futures Command** mentor on **BRL-CAD** using C and C++. Team awarded **1st place** in the CS-department-wide project showcase that semester.
- **Concordia Lutheran High School** — Aug 2013 – May 2017.

**Side project:**

- **Vizarri** — 2D RPG computer game, Unity + C#, developed as a hobby since early 2022. **Published to the Steam store January 2026**, with monthly updates. Implements state-stack architecture.

**Career arc:** TAMU CS-with-Cybersecurity-and-Math (2017–2021, capstone with US Army Futures Command) → BuildOn intern → BuildOn FTE 4+ years → **government job (Mar 2026 departure)**. The government move resonates with the capstone — likely a return-to-defense or federal-software arc.

**Domains of experience:**

- Homebuilder customer-facing software (VDS, ~4 years FTE + intern summer).
- Indie game development (Vizarri, Unity/C#, published).
- Defense / federal software (BRL-CAD capstone foreshadowing).

## Core skills

LinkedIn-listed top skills:

- Entity Framework
- Software Development
- Object-Oriented Programming (OOP)

Demonstrated across the role history:

- Full-stack VDS — **SQL, C# in .NET, JavaScript, TypeScript, HTML, CSS.**
- Front-end frameworks — **Durandal, Aurelia, Angular** (three SPA frameworks across his tenure, reflecting the VDS frontend's evolution).
- Database — **Microsoft SQL Server.**
- API testing — Postman.
- DevOps — **Azure DevOps**, Git.
- Process — Agile / Scrum.
- C / C++ (capstone era).
- Unity + C# (Vizarri side project).
- **Developer onboarding** — explicitly called out in his LinkedIn role description.

## Notable contributions in this codebase / org

### VDS — multi-year full-stack developer

The Reid-era VDS contributions on his LinkedIn are unusually well-documented for this persona set:

- **Reworked the Design My Home module** (the website's largest module) to support **sub-area selections** for greater granularity.
- **Reworked the 3D visualizer in Design My Home** to load **once instead of once per room entry** — drastically cut load times. Worked directly with the **3rd-party visualization vendor**.
- **Designed and implemented the elaborate theming system** — manipulates colors and fonts across the whole site. Each builder selects a theme; users that can switch builders see the active theme change at runtime. Built a **custom theme editor** that offloaded theme creation from developers to theme designers; individual CSS variables update dynamically from the database. Per his LinkedIn: *"loved by countless current and prospective builder customers."*

### Onboarding owner

LinkedIn explicitly lists **"Bring new developers up to speed quickly"** as a primary responsibility — Reid was the team's onboarding hand for the VDS codebase.

### Still TBD

PBI / Operation-poster anchors for the three named VDS projects above (Design My Home rework, visualizer rework, theming system) — strong candidates to be anchored as named Operations.

## Public profile links

- **LinkedIn:** https://www.linkedin.com/in/reidtwilson
- **Personal email (on LinkedIn):** reidwilson99@gmail.com
- **Steam store (Vizarri):** released Jan 2026 (URL not on LinkedIn export).

## Source notes

- *LinkedIn profile PDF export (`Profile.pdf` at this folder root, 4 pages):* read 2026-05-22. All work-history dates, role descriptions, listed top skills, education, GPA, capstone details, and the Vizarri side-project framing come directly from this PDF.
- *User account, 2026-05-22:* Reid **voluntarily left for a government job the week of 2026-03-09**. The LinkedIn "Present" tag on the BuildOn role is therefore stale.
- *Inferred:* the framing of Reid's government move as "a return-to-defense arc resonant with the BRL-CAD capstone" is an inference from the capstone's US-Army-Futures-Command sponsor + the federal-software move, not a direct LinkedIn statement.
- *Not verified:* the specific government agency or role Reid moved to. The PDF carries no signal; the user note states the fact of departure without naming the destination.

## Open questions

- **Codename Codeburst rationale** — confirm origin in `persona.md` once written; provisional reading is the high-throughput-developer pattern (Design My Home, 3D visualizer, theming system reworks).
- **Government destination** — agency, role, sensitivity level (insofar as it's appropriate to know).
- **Onboarding artifacts** — did Reid leave behind written onboarding material for the VDS codebase that's still being used?
- **The theming system's ongoing maintenance** — who picked up ownership after his departure? Worth flagging if it's now an unowned hot-spot.
- **Vizarri** — the Steam-published side project is a distinct biographical hook; worth confirming whether to surface it in `persona.md`.
