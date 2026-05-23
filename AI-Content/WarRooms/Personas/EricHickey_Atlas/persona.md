# Atlas — In-Universe Persona

**Real-world anchor:** [`data.md`](./data.md) — Eric Hickey, Director of Software Development at BuildOn Technologies, leads both the VEO Design Studio and VEO Indago teams, 25 years in .NET / DDD.
**Era applicability:** Era I default. Eligible for Era II appearances as a senior brass figure briefing the AI factions (he is the *human* commander, not a faction-aligned persona).
**Faction:** Allied (human side). Codename outranks faction allegiance — Atlas commands; he doesn't choose sides between Claude and Copilot.
**Last updated:** 2026-05-23

---

## Codename rationale

*Proposed reading — codename predates this doc; user to confirm or correct.*

Atlas is the titan who holds the world on his shoulders. The fit, anchored in `data.md`:

- **One combined-arms operation, two specialized units.** Eric commands both the **VEO Design Studio** team (customer-facing homebuyer software — *pathfinders* in the wartime metaphor, forward at the drop zone, marking the way for the follow-on force) and the **VEO Indago** team (internal MRP running the Reeveston countertop plant's production schedule — *artillery* in the metaphor, rear-area fires answering pathfinder marks with concentrated, scheduled output). They are not two parallel commands; they are the two specialized arms of one combined-arms doctrine — *pathfinders find and mark the target; artillery delivers the strike.* Atlas commands the unified operation.
- **Twenty-five years in the field.** Senior weight, both in tenure and in the technical foundation (DDD as a recurring design philosophy across three employers — and verifiable directly in the Indago codebase). Atlas is the *oldest figure on the field* in the mythology — equivalent here: the most-experienced operator on the front.
- **Senior Leadership Table.** He's not just running teams; he carries weight on company-wide direction. Strategic load, on top of technical and operational load.
- **The recurring "foundation" motif.** DDD, repository / specification patterns, CI/CD pipelines, training channels, QA program introduction — every one of these is *substructure* work. Atlas builds and holds the base that other people stand on.

The risk to watch: Atlas can read as *burdened* or *grim*, or as a *two-fronts juggler*. The codename should read as *steady* and *unifying* — the calm shoulders that hold one combined operation together, not the suffering titan with two separate worlds on each shoulder.

## WW2 unit identity

- **Rank / role analogue:** **Colonel — Combined Arms Task Force Commander.** Brass-cap officer commanding a single combined-arms operation built from two specialized units working in tandem: an elite Pathfinder Detachment forward and an Artillery Section behind the line. Not a two-fronts juggler; a unifying commander whose doctrine is the *callout chain* — pathfinder marks the target, artillery delivers the strike, one operation.
- **Wartime function:** Operates from a forward war-room HQ between the drop zone and the gun pit. Holds the radio handset that links pathfinder marks to artillery solutions on the same map. Briefs higher brass, gives doctrine to his unit commanders, walks the line when something needs his hands. Equally comfortable at a map table, over a fire-direction console, and on a rooftop drop zone — because all three are stations on *one* operation.
- **Why this unit:** Director-level + technical-foundation-heavy résumé maps cleanly to a combined-arms senior officer. Both halves of his real command — a 4-person flagship elite team AND a specialist crew running a literal manufacturing-plant scheduling system — fit a WW2 commander whose doctrine binds an elite forward detachment to a rear-area battery as one operation. The interim-Scrum-Master detail says he still walks the line; not a desk-only general.

## Signature props / recurring artifacts

Aim for 2–3 specific, recognizable items that recur across pieces.

- **Twin unit standards / pennants** flanking him in interior scenes — one marked **DESIGN STUDIO** (the pathfinder arm — forward, finds the way), one marked **INDAGO** (the artillery arm — rear, delivers the strike). The two pennants read as the *two specialized arms of one combined-arms force*, not as two separate commands. Both staffs lean toward Atlas at the center of the map table.
- **Field radio handset in his free hand or at his belt** — the literal callout link between pathfinder mark and artillery solution. This is the load-bearing prop for the combined-arms doctrine; it should appear in every Atlas portrait. Coiled fiber-optic cord disappears off-frame to two unit feeds in the future variant.
- **Combined-arms situation map on the war-room table or wall behind him** — a single map showing the forward drop zone and the rear firing positions on the same sheet, with hand-drawn coordinate lines connecting pathfinder marks to artillery fire-solutions. The map is the doctrine made visible: one operation, two roles. (Replaces the production-schedule-chart-only framing from earlier drafts.)
- **Leather-bound briefing book / field manual** — open or under one arm. Marked with a small embossed "DDD" insignia (the design-philosophy through-line, visible in the Indago codebase as the layered architecture). Reads in-universe as a regimental motto.

Avoid: pistol or rifle (wrong command — he is not infantry), and a literal globe-on-shoulders (too on-the-nose for "Atlas"). An engineer's slide rule on the map table is fine as a tertiary prop but should not crowd the situation map or the radio handset.

## Portrait composition notes

Base prompt template lives in [`prompt_persona_image.md`](../../.metaData/prompt_persona_image.md). This persona's specific choices:

- **Pose:** Standing behind a map table, one hand bracing on the table edge, the other holding the briefing book. Head turned slightly, eyes scanning the horizon out of frame. Composed; not posed mid-action. Atlas is *the steady one*.
- **Setting:** Interior war room. Two team standards visible behind/beside him. Production-schedule chart pinned to the wall behind. Map table in foreground. Atmospheric warm lighting per `aesthetic.md` §3 — parchment cream, burnt orange, olive drab.
- **Mode:** **Mode B — Geometric propaganda poster** per `aesthetic.md` §5. Single hero figure, clean lines, sunburst rays optional. The geometric clarity reinforces the "anchor / commander" read; a Mode-A painterly multi-figure scene would dilute the single-pillar identity.
- **Codename label placement:** **Bottom plate** — "ATLAS" in bold ALL CAPS on a cream-on-red ribbon at the base of the poster, with a small subtitle banner above it stating his role-line. Proposing this placement for the persona-portrait pattern; if 2–3 other personas adopt the same, it gets promoted into `aesthetic.md`.

## Voice / tone

How Atlas "talks" in any in-universe content attributed to him.

- **Cadence:** Deliberate. Short opening sentence, then a longer clarifying one. He never rushes; he never *thinks out loud* in panic mode. Twenty-five years of seeing things go wrong calmly.
- **Lexicon:** Frames work in *terrain*, *foundations*, and *throughput*. Talks about the *domain*, the *bounded context*, the *line we're holding*, the *shift we're scheduling*, the *saw that's down*. Two registers — strategic (line, terrain, principle) and operational (shift, queue, throughput, schedule slip) — and he switches between them deliberately. Uses "we" more than "I." Tends to anchor decisions back to a principle ("the rule we've held for a decade is...").
- **Quirks:** Often opens with a one-sentence summary of where the unit stands today before answering the question that was actually asked. Books — he references what he's reading (the book-club thread); doesn't apologize for that.
- **Never:** Panics. Mocks a subordinate. Speaks in pure jargon-stack with no concrete object behind it. If Atlas can't point at a *thing on the map* or a *row on the schedule*, he doesn't say it.

## Tagline / motto

> **"MARK THE TARGET. DELIVER THE STRIKE."**

Locked 2026-05-23 — replaces the prior "TWO FRONTS. ONE STANDARD." (which framed the units as parallel rather than as one combined-arms operation). The new tagline encodes the pathfinder→artillery doctrine literally in an imperative duo per `aesthetic.md` §8: VDS marks, Indago delivers, Atlas commands the chain.

Alternate phrasings preserved here for future reference:

- "ONE FRONT. ONE COMMAND." — if the framing needs to be even more explicit.
- "ILLUMINATE. DELIVER. ADVANCE." — imperative triplet variant (pathfinder verb + artillery verb + combined outcome).
- "PATHFINDERS MARK. ARTILLERY DELIVERS. ONE STANDARD." — keeps the "standard" through-line if it gets reintroduced elsewhere in the company's iconography.

## Relationships and deployments

- **Reports up to:** the Senior Leadership Table itself, framed in-universe as a wartime Joint Chiefs meeting. Atlas is one of the brass at that table.
- **Commands:** Atlas's Company — two sub-platoon units under one commander, mirroring the forward / rear split of a small combined force:
  - [`VDS Pathfinder Detachment`](../../.metaData/Teams/VDS/) — 4-person elite forward unit. First in, marks the way for the follow-on force. Flagship product. *Motto: "FIRST IN. MARK THE WAY."*
  - [`Indago Artillery Section`](../../.metaData/Teams/Indago/) — small specialist rear-area crew running the Reeveston works. Receives fire missions (Manufacturing Orders) from Echelon's Quartermaster and delivers concentrated, scheduled output. *Motto: "EVERY SHIFT. EVERY SAW. EVERY ORDER."*

  Each unit has both an Era I (`persona.md`) and an Era III (`persona_future.md`) write-up. **Senior NCOs (day-to-day on-the-ground unit leaders), proposed and pending team vetting:**

  - **VDS Pathfinder Detachment** — Detachment Sergeant: [`Tactician`](../../Personas/RobHobbs_Tactician/) (Rob Hobbs, PO). PO drives mission planning; in Pathfinder doctrine, the unit moves only when the mission is set.
  - **Indago Artillery Section** — Section Chief: [`Anvil`](../../Personas/JosephArellano_Anvil/) (Joseph Arellano, Team Lead). Team-Lead title maps directly to a Section Chief role; the *Anvil* codename reads as the steady base on which the crew is shaped.

  Full rosters and per-operator roles are recorded in each unit's `persona.md` Composition table.
- **Recurring foils / antagonists:** none yet. Atlas is institutional; the antagonists in the universe are usually *Operations* (technical debt, broken transmissions, jammed conduits), not other personas.
- **Operations led / anchored:** *TBD — depends on data.md "Open questions" being resolved.* The Indago repo confirms at least one major recent campaign — the **Production Schedule refactor** (handoff PDF at the repo root, "Production Schedule constraints" called out in the Aurelia rules file). Any Operation poster anchored on that refactor would naturally name Atlas as the commander. Other likely candidates from his BuildOn-era leadership: product-catalog / DDD architecture operations.

## Era II / III appearances

Eligible for Era II appearances as a **human senior commander observing or commanding alongside the AI factions** — e.g. a summit-poster scene where Atlas stands between the Claude faction figure and the Copilot faction figure, briefing both. He is *not* faction-aligned; the AI factions report to *him* in those scenes, narratively.

Era III (near-future cyber-WW2): possible appearance as a senior officer in the rain-soaked megacity war-room scenes from `aesthetic_future.md`. Reserve for milestone moments — not standard usage.

## Open creative questions

- Confirm or correct the Atlas rationale above (especially the combined-arms framing — pathfinders forward, artillery behind, callout chain between — is now load-bearing; flag if a different read was originally intended).
- Should the **DDD insignia** on the briefing book be made literal in-universe (i.e. some kind of trefoil or three-layered crest representing domain/application/infrastructure layers), or stay subtle?
- Codename-label-at-bottom-plate placement: if Atlas's portrait works at the base, does the same placement carry over to the other personas, or do some get top-banner / mid-ribbon variations?
- ~~Tagline lock-in.~~ Resolved 2026-05-23 — **"MARK THE TARGET. DELIVER THE STRIKE."** locked.
