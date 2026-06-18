# Phone Screen — Jeff Moreau

**Date:** 2026-06-04
**Duration:** ~35 min
**Format:** Microsoft Teams (recorded)
**Transcript:** [[Phone Screen 2026-06-04.vtt|Raw transcript]]

## Summary

Easygoing, honest, collaboration-oriented conversation that **resolved the screen's central question favorably**: Jeff is not an AngularJS-only developer. He volunteered that at Elliott Electric/NacSpace he "was in charge of the upgrade from Angular 1 to Angular 2, where it introduced using TypeScript," and his most recent front-end work is **React** (the Venture healthcare-marketplace questionnaire at Liquiddevs), where he used React state to drive live conditional question visibility. That reframes the résumé's "AngularJS" as the *starting point of a migration he helped lead* and contradicts the snapshot's "beginner component-based" self-rank — he's a competent component-based dev. Backend, his self-ranked #1, held up: he nailed the EF change-tracking conceptual question ("exactly what I was looking for") and reasons sensibly about LINQ-vs-raw-SQL and query batching — but his EF/SQL specifics are **dated** ("back in the day when I was working with EF") and his method for validating EF-generated SQL was admittedly unsophisticated. Leveling reads as a **disciplined strong-mid IC, not an architect** — one solo end-to-end project (the wire-picking app) with a reactive performance-firefight as the "what I'd do differently" story, no architecture vocabulary. Strongest non-technical signal: he's genuinely drawn to the **hybrid collaboration model** ("the split schedule was one of the things that drew me to this position"), missing whiteboard sessions from being fully remote since 2021 — a clean culture/retention fit. Eric closed by naming a **team interview as the next step**.

## Question-by-question

### Retention motivation / what drew him (Open)
Not asked as a single question, but his motivation surfaced clearly and favorably. On learning the unfamiliar legacy SPAs and the coming Angular migration: **"I always wanted to push and learn new things. This is not a field where you can rest on your laurels... I've been voracious in taking in as much information as I can."** Later, unprompted, he named the **hybrid schedule** as a specific draw: **"the split schedule was one of the things that drew me to this position."** The pull reads as the *work and the collaboration model*, not merely re-employment — consistent with the low-flight-risk paper read.

### Frontend modernity — framework/version, component ownership, TypeScript (the question that decides VDS)
**Resolved, and better than the paper feared.**
- **Most recent FE = React**, the Venture healthcare-marketplace app at Liquiddevs. Single-page app; the application was a "sole page" with each question section as its own subpage. He used **React state to drive question visibility in live time without data fetching** — "they would select an answer that would now mean we need to show them this next question, and it would just immediately pop up after a quick re-render." Understands re-render mechanics.
- **State management:** used native React state; correctly identified Redux as "a state-based library for React" but noted they "were mostly using just the flat-out state that React provides." No overclaiming.
- **The AngularJS-vs-Angular-14 discrepancy is settled in his favor:** at Elliott Electric/NacSpace, **"we were in charge of the upgrade from Angular 1 to Angular 2, where it introduced using TypeScript into it."** So he did *modern, component-based, TypeScript* Angular when it was new — the résumé's "AngularJS" was the legacy origin of a migration, not his ceiling.
- **TypeScript: confirmed** — entered his toolkit via the Angular 2 migration.
- Net: the snapshot's **"beginner component-based" self-rank is contradicted** by real React component work plus an Angular 1→2 migration. Modern-SPA depth is real, if not cutting-edge (the React work is the most recent; Angular 2 was years ago).

### Backend depth — EF Core/SQL, LINQ vs stored procs, performance (verifies the #1 layer)
**Solid conceptually, but dated and shallow at the edges.**
- **LINQ** for simpler queries (one or two tables, join, filter). Knows **`AsNoTracking`** for read-only queries and that it "does speed up performance quite a bit"; mentioned indexes and "private keys" (likely meant primary keys). Reaches for **raw SQL** when queries get complex, the data set is large, or it's "hard to define in LINQ."
- Good instinct on **minimizing round-trips**: "each query in itself has a high load... if you can combine and fuse as many of them together into one and then do whatever programmatic ordering or filtering... through the web service afterwards."
- **Nailed the EF change-tracking probe:** keeps fetched records "in some sort of memory structure where it can track whether or not there have been changes made to them that it needs to commit later on... or roll back." Eric: **"that's exactly what I was looking for."**
- **The tell:** asked how he ensures EF-generated SQL is what he wants/performant, he was candid that his approach was weak and dated — **"back in the day when I was working with EF, I would probably just compare the results of a LINQ query to the actual raw query... do a quick visual check... Not a very robust way of doing things, but it was just what I did at the time."** Honest, but signals his hands-on EF work isn't recent and he didn't reach for profiling / logging generated SQL.

### End-to-end ownership + what he'd do differently (leveling: senior vs strong-mid)
**Strong-mid IC story, honestly told.** The **wire-picking app at NacSpace** (Elliott Electric's spinoff) — owned "from as close to the beginning of the life cycle as I was allowed," working from a concept and design doc he was handed, setting up the web services that read existing inventory databases. "Pretty solo project beginning to end." What he'd do differently: **performance**. A couple of weeks post-rollout he got a 9 PM call about unresponsive results — the query driving the view was slow and uncached; he "had to whip up something very hastily... at like 11 PM to midnight" to cache it. Framed as **"a life lesson... what can go wrong when you're not doing your due diligence."** Self-aware and accountable, but it's reactive firefighting on a solo mid-level project — **no architecture vocabulary, no architect-track signal**. Confirms the "disciplined implementer, not architect" read.

### Backend vs frontend going forward (settles the lean from his own preference)
**Backend-leaning, frontend-willing with a caveat.** "Back end has always been where I've been more comfortable," but "I tend to be someone who likes new challenges... moving into different areas." He'd "love to continue developing in front end" — **caveat: "I'm not very much of a visual design person. I definitely work better off of mockups that other people have done,"** describing an "almost obsessive compulsive" pixel-perfect streak that has been "a struggle." Useful: he's productive on FE *when designs/mockups are provided* — which is exactly the VDS situation.

### Not asked
- **Manufacturing / supply-chain / MRP domain (prep Q6)** — not asked directly, but his domain history surfaced fully (warehouse/inventory at Elliott Electric/NacSpace; talent marketplace at Avue/DoD; healthcare marketplace at Venture). No MRP/manufacturing; warehouse/inventory remains the only operational-data adjacency.
- **Salary $100–110K reconfirm · previous salary (still blank) · start timing · Tomball commute feasibility for the 3-day in-office split · ~8-month NacSpace→Liquiddevs gap** — the call didn't reach the rattle-off confirm items. All carry to the F2F. (Hybrid *appeal* was confirmed via his own question; physical commute feasibility from Tomball was not.)
- **Avue 3-month stint (prep Q7)** — effectively covered in his narrative: Avue "hit a downturn and did a layoff that included me and a large portion of the team," consistent with the recruiter's downsizing framing.

## Their questions
- **VDS team size?** → 2 developers, a manual tester/QA engineer, and a product owner; Eric noted VDS *should* be 4–5 developers and has unfilled recent attrition (the reason for hiring).
- **What's being built/extended on VDS?** → 3D room visualization (third-party tool + heavy asset-prep they want to bring in-house), expanding catalog/attribute capture and display (finishes like stainless vs matte black, door counts), and large-scale package offerings per customer.
- **Benefits of mid-week in-office?** → Eric's collaboration/culture answer (post-COVID culture & collaboration suffered; highly collaborative pairing teams; board-game lunch group; knowledge spread, fewer surprises).

## Observations
- **Honesty over polish throughout** — volunteered the unsophisticated EF-verification habit, the pixel-perfect FE struggle, and the performance-incident "life lesson" rather than spinning them. Reads as trustworthy and self-aware.
- **Learning orientation is consistent**, not a talking point — Angular 1→2, picking up RabbitMQ off a job description, "nothing really new under the sun."
- **Culture fit is the standout** — independently surfaced the hybrid/whiteboard collaboration as a draw; aligns directly with the team model Eric has spent two years building.
- **Depth is real but dated on the layer he ranks #1** — the EF/SQL specifics live "back in the day"; worth a more technical backend probe at F2F to gauge how quickly the rust comes off.
- **Minor employment-history wrinkle:** the ~6-year 2014–2020 employer is **Elliott Electric Supply**, which "spun off into" NacSpace (the hub labels this span "NacSpace"). Cosmetic; flag only if it matters for references.

## Evaluation

**Recommended fit_assessment:** Solid (confirmed, trending up)
**Recommended disposition:** (continue — advancing to team interview)

The screen does what a screen should: it retired the biggest paper risk. The "AngularJS / beginner component-based" worry was the single thing that could have killed VDS viability, and Jeff dispatched it himself — Angular 1→2 with TypeScript, plus recent React component work with sound state-driven rendering. On backend he hit the conceptual bullseye (change tracking) and reasons well about query cost, but the hands-on EF/SQL specifics are dated and his validation habits were thin, and the leveling evidence (one solo mid-level project, reactive perf fix, no architecture vocabulary) confirms **strong-mid, not senior-architect**. That keeps him squarely at **Solid** — and the favorable resolution of the FE question, plus a genuinely clean culture/retention read, nudges him toward the strong end of it rather than down. Nothing surfaced that argues against advancing.

## Net read vs. pre-screen

Pre-screen he was a backend-leaning mid-senior with a **big unresolved frontend question** and an "Either, tilting Indago" lean. Post-screen, the frontend question resolves *positively* (modern Angular history + recent React), which **shifts the lean toward VDS**: the upcoming Aurelia/Durandal→Angular migration is a near-perfect match for someone who lived the Angular 1→2 migration and is visibly excited about it, VDS is the team actually short-staffed, and his "backend-comfortable but happy on FE *with mockups*" preference fits VDS's design-provided workflow. Indago stays possible on backend strength alone — but per our standing rule, backend strength isn't an Indago-specific reason, and his domain doesn't map to MRP. The leveling and dated-EF findings are new, modest cautions but don't change the Solid grade.

## Next step

Eric told Jeff the next step is a **team interview** ("we would bring you in for an interview to meet the team... more technical, more people, more viewpoints"), coordinated through Marie (ProFound). Advancing looks like: schedule the F2F, **probe backend depth more technically** (how recent/deep the EF/SQL really is), and **clear the unasked confirm items** — reconfirm $100–110K, capture previous salary, confirm start timing, and check **Tomball commute feasibility for the 3-day in-office split** and the ~8-month NacSpace→Liquiddevs gap.
