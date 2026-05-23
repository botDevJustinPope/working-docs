# Indago — Artillery Section

**Real-world anchor:** [`data.md`](./data.md) — VEO Indago, internal MRP that runs the Reeveston countertop-manufacturing plant. Receives Manufacturing Orders from Echelon; schedules production across saws, workstations, and shifts.
**Commanding persona:** [`EricHickey_Atlas`](../../../Personas/EricHickey_Atlas/) — Colonel-equivalent commanding Atlas's Company.
**Era applicability:** Era I default. See [`persona_future.md`](./persona_future.md) for the Era III specialization.
**Faction:** Allied (human side).
**Last updated:** 2026-05-14

---

## Unit designation

*Updated 2026-05-14 per user direction — artillery / special-weapons framing.*

- **In-universe name:** **Indago Artillery Section** — "the Battery."
- **WW2 unit analogue:** **Artillery Section** — a small specialist crew within a battery, responsible for executing fire missions. Rear-area by position, decisive by output: the unit doesn't stand on the line, but it shapes what happens on the line. Every Manufacturing Order is a fire mission; every shipment from the Reeveston plant is a round on target.
- **Why this unit:** the previous Ordnance Works framing read the work too literally (factory, foundry). The artillery framing captures what *kind* of work it is:
  1. **Receives fire missions.** Real artillery receives fire missions from forward observers / fire-direction calls. Indago receives Manufacturing Orders from Echelon. The data flow is the same shape.
  2. **Schedules concentrated fires.** Real artillery batteries calculate firing solutions and assign rounds to tubes; Indago calculates production schedules and assigns work to saws and shifts. The optimization problem is the same shape.
  3. **Rear-area but decisive.** Artillery is *not* infantry — it doesn't make contact — but it determines whether the line holds. Indago doesn't touch the homebuyer, but it determines whether the homebuilder's order ships. The role-on-the-front is the same shape.
  4. **Prestige arm.** Artillery is its own branch of service, with its own pride and its own doctrine. Internal-tool teams running a real manufacturing plant deserve the same standing.
- **"Section" sized correctly.** A full battery is 4–6 guns and ~80 crew. A section is 1–2 guns with a small crew — sub-platoon, appropriate to a dev-team scale. Indago's actual headcount is unknown but is almost certainly section-sized rather than battery-sized.

Units considered and rejected: *Ordnance Works Platoon* (read the work too literally as factory production rather than fire-mission execution); *Special Weapons Section* (close — heavy weapons platoon doctrine also fits, but "artillery" carries more prestige and the "fire mission" metaphor is sharper); *Quartermaster Section* (wrong — Quartermaster handles supply and distribution; Indago *produces*, doesn't *distribute*).

## Position on the front

- **Rear-area, fortified gun position.** The Battery operates from a prepared emplacement — the Reeveston plant is the gun pit. Sandbagged, scheduled, throughput-measured.
- **Adjacent units:**
  - [`VDS`](../VDS/) — Pathfinder Detachment, sister unit under the same commander. Opposite end of the front (forward edge of contact). Shared doctrine via Atlas; shared little else day-to-day.
  - **Echelon ERP** — represented in-universe as a Quartermaster's office one echelon up. Echelon issues the Manufacturing Orders that translate to fire missions for the Battery. Echelon is *not* in the Battery's chain of command; it is a peer office whose calls are *honored*.
- **Upstream / downstream supply:** *receives* fire missions (Manufacturing Orders) from Echelon's Quartermaster. *Delivers* concentrated, scheduled output — finished materiel out of the Reeveston works. Throughput is the unit's measured contribution to the line.

## Emblem / unit patch

*Proposed — user to confirm.*

- **Primary symbol:** a **crossed howitzer barrel and circular saw blade**. The howitzer reads as artillery. The saw blade reads as the specific tool of the Reeveston works. The crossing — rather than stacking — gives a clean silhouette and ties the "artillery" abstraction to the actual production mechanic. A small **shell** below the cross point. A small **gear** in the upper-left field denotes the scheduling discipline.
- **Color treatment:** olive-drab background, cream howitzer + saw blade, burnt-orange shell, deep-brown outlines. Olive-drab dominance — vs. VDS's cream-dominant emblem — encodes the rear-area / industrial uniform feel.
- **Inscription / wordmark:** **INDAGO** in stencil-adjacent ALL CAPS along the bottom; smaller **ARTILLERY SECTION** subtitle banner above the wordmark.

## Doctrine

- **Cadence / tempo:** shift-driven, fire-mission-driven. The Battery's work-day is structured around production shifts and the incoming queue of fire missions from Echelon's Quartermaster.
- **Standing orders:**
  - *No fire mission is fired without a verified firing solution.* Every Manufacturing Order is assigned saw, shift, and run-type before it executes — never on the fly.
  - *Optimize the battery, not the individual tube.* The Section does not over-task one saw to ease another's load if total throughput drops. Battery-level utilization governs.
  - *The schedule survives outages.* Wall-sized printed production charts hang in the gun pit precisely so the Battery can keep firing if the screens go down.
- **Quirks:** speaks in saws, shifts, rounds, and grids. References machines by number ("saw 3 is down" / "tube 2 is cold") are common and unselfconscious. Trusts the chart — handwritten adjustments on the wall production chart are authoritative until the system catches up.
- **Never:** fires a round without a verified firing solution. Lets a tube sit cold when there is gettable work. Accepts a change-request without classifying it against the change-request lifecycle (real artifact in the codebase — `Wiki/Application-Documentation.md`).

## Motto

> **"EVERY SHIFT. EVERY SAW. EVERY ORDER."**

Noun-phrase triplet per `aesthetic.md` §8. Encodes the three axes the real Indago system optimizes against. Translates cleanly to artillery: *every shift = every fire-direction window; every saw = every tube; every order = every fire mission*. Alternates considered:

- "EVERY TUBE. EVERY ROUND. EVERY MISSION." *(pure artillery — strong, but loses the saw/shift specificity that distinguishes Indago from a generic artillery unit)*
- "RECEIVE THE MISSION. SCHEDULE THE FIRE. SHIP THE ROUND." *(imperative triplet — usable, but longer)*

Primary recommendation remains **"EVERY SHIFT. EVERY SAW. EVERY ORDER."** — it's the only motto that names the three axes Indago literally optimizes against, and it survives the artillery reframing without rewording.

## Composition

- **Commander:** [`EricHickey_Atlas`](../../../Personas/EricHickey_Atlas/) — Atlas commands the Company; the Artillery Section is one of two specialized units in his combined-arms force (the rear / artillery arm — VDS is the forward / pathfinder arm).
- **Named members of the Section** (3 crew, plus Atlas's command, per `data.md`):

  | Codename | Real role | Proposed role within the Artillery Section |
  |---|---|---|
  | [`Anvil`](../../../Personas/JosephArellano_Anvil/) | Team Lead | **Section Chief / Senior Crew Chief** — the NCO running the gun pit day-to-day. Team-Lead title maps directly to a Section Chief role; the *Anvil* codename reads as the steady base on which the gun crew is shaped. He is Atlas's on-the-ground Sergeant-equivalent for the Battery. |
  | [`DTD`](../../../Personas/JenniferHickey_DTD/) | PO | **Fire Direction Officer** — receives the fire missions (Manufacturing Orders) from the Quartermaster, computes the firing solution, sets the schedule. PO function maps cleanly to fire-direction officer doctrine: the gun pit does not fire until the FDO has the solution. *Codename heritage: DTD was earned in a prior QA-Lead role serving both VDS and Indago — the codename predates her current PO seat, retained as a callback (per user 2026-05-14). In-universe, this gives DTD a credible cross-unit history that no other Indago figure carries: she has worked the line on both fronts of Atlas's company.* |
  | [`Tinker`](../../../Personas/WadeWelch_Tinker/) | Software Developer | **Gun Crew / Tube Mechanic** — keeps the saws running, makes precise adjustments under load. *Tinker* codename reads as the operator whose specialty is small-mechanical work on live equipment. |

  All three roles are **proposed and pending the user's vetting with team members.**
- **Approximate section size:** **3 crew + Atlas commanding**, per `data.md`. Smaller than a real WW2 artillery section (typically 8–12); treat as a *minimum-crew* section. Do not inflate the figure count in posters.

## Relationships and deployments

- **Sister unit:** [`VDS Pathfinder Detachment`](../VDS/) — same company, same commander. Where the Pathfinders make first contact at the forward edge, the Battery delivers concentrated fires from the rear. The contrast is the point: VDS marks the zone; Indago fires on it. Together they *shape the field* for the rest of the homebuilding force.
- **Standing orders from above:** report up to Atlas. Atlas reports to the Senior Leadership Joint Chiefs. Echelon is *not* in Indago's chain of command, despite being the upstream order-source — it is a peer Quartermaster office whose calls are *honored*, not *obeyed*.
- **Recurring antagonist / foil:** Operations involving *jammed conduit*, *broken transmission of Manufacturing Orders*, *saw failure*, *shift-scheduling collapse*. The Battery's enemy is *the line going cold* — a fire mission that can't be fired, an order that can't be shipped.
- **Operations anchored on this unit:** the **Production Schedule refactor** (confirmed by the `handoff-production-schedule-refactor.pdf` in the repo root) is the strongest existing candidate. Specific Operation-poster mapping TBD — needs user input on which of the 44 posters in `WarRooms/PBI Posters/` were Indago-anchored.

## Open creative questions

- Confirm or correct the **Artillery Section** designation. Alternatives if it doesn't land: *Special Weapons Section*, *Heavy Mortar Section*, *Fire Direction Center*.
- Confirm or pick the emblem — crossed howitzer + saw blade is the proposal; alternatives include a stylized firing-solution grid, or a single dominant howitzer over a shell.
- Should the *Reeveston plant* become a named location in-universe (a specific town / battery position on the universe map)? If so, it deserves a one-line entry in `aesthetic.md`'s world geography.
- Senior crew chief is **Anvil (Joseph Arellano, Team Lead)** per the role table above — confirmed against the real-world Team-Lead title. Confirm or revise after the user vets with the team.
- Per-crew codename rationale and individual-portrait composition — deferred until each named member's own `persona.md` is drafted. The role table above is the entry point for that work.
- **`DTD` codename literal acronym** — origin is now known (prior QA-Lead-across-both-teams role); the literal acronym expansion is still open, to be locked when `JenniferHickey_DTD/persona.md` is drafted.
