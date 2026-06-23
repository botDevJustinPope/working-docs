# Front Line Poster Forge Request

## Work Item
- ID: 34203
- Title: Refresh Session reported broken
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Pulled into sprint (Attributes-5)
- Assigned To:
- Tags: attributes; bug
- ADO Link: https://dev.azure.com/BuildOnTechnologies/_workitems/edit/34203

## Narrative
- Problem:
Refresh Session — the capability the detachment shipped last sprint under Operation Refit
(PBI 30543) — has been reported broken. The report came in from Service and Support
(Jim Warnement / **Château**), routed forward to the engineering front with the alarm
"REFRESH SESSION IS BROKEN!" No one yet knows why it would be busted now; nothing in the
session-refresh code changed.

- Desired Outcome:
Trace the reported fault to its actual root cause before tearing the feature apart. The poster
is a START-of-mission piece — it depicts the discipline of root-cause analysis, not a verdict.
The team's veteran instinct (the recurring pattern that issues routed forward from the rear
often trace back to a data-setup problem rather than a code defect) appears as a *lead being
followed*, never as a printed conclusion that the bug is fake. Confirm the true source — code
vs. catalog-data setup — and trace it methodically.

- Primary Tension: A symptom reported from far behind the line ("IT'S BROKEN!") vs. a
  front-line detachment that refuses to dig into sound code on a hunch and instead traces the
  fault to its true source — a trail that, by long experience, often leads back toward the
  data set up at the rear.
- Stakeholders / Personas:
  - **Château** (James "Jim" Warnement, Director of Implementation, Service & Support) — the
    rear-HQ reporter who raised the alarm and reports the symptom from the map. Allied,
    affectionate roast: the gag is organizational distance, never malice; his issues are of
    *varying* validity, so the poster never declares this one fake. See
    `Personas/JamesWarnement_Chateau/`.
  - **VDS Pathfinder Detachment** — Overseer, Ironforge, Hawkeye, Tactician — the front-line
    unit that triages the dispatch and traces it to the root.

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait 2:3, ~1024x1536)
- Era: **Era III** (cyber-WW2 / "World War AI"), matching the rest of the Attributes-5 sprint.
  This promotes Château to Era III (user-approved 2026-06-23; his `poster_future.png` asset
  exists). Aged-paper / distressed-propaganda backbone must dominate; cyan is accent only.
- Mode: A — painterly war scene, two-zone split canvas (REAR HQ | THE FRONT), the zones joined
  by a traced fault-wire.
- Mood: methodical root-cause discipline. An alarm comes down from the rear; the detachment
  traces the fault to its source rather than tearing the sound feature apart. Start-of-mission
  resolve, not an after-action reveal.
- Visual Motifs:
  - **REAR HQ (Château):** grand château wall-map; field telephone at his mouth; map-pin /
    dispatch stamped "REFRESH SESSION — THIS IS BROKEN!" (the reported symptom); château comfort
    (armchair, fireplace, decanter); small placard quote "HOW HARD COULD IT BE?".
  - **THE FRONT (detachment):** a rig stenciled "DESIGN SESSION", sound and steady, one panel
    open only a crack (trace first, dig later); a traced signal/fault wire running from the rig
    back across the divide toward rear HQ; a root-cause / fault-tree board chalked "SYMPTOM:
    SESSION BROKEN → TRACE TO SOURCE"; a posted maxim card "MOST FAULTS TRACE TO THE DATA"; a
    panel tag "DON'T TEAR DOWN — TRACE FIRST".
- Cast & hierarchy: **Château and Overseer are co-leads** (both largest, front-lit, squared off
  across the zone divide). Supporting at reduced scale: Ironforge, Hawkeye, Tactician.
  - **CHÂTEAU** (James Warnement) — REAR co-lead. At his château wall-map, field telephone to
    mouth, reporting the symptom; comfortable and distant.
  - **OVERSEER** (Justin Pope, senior operator) — FRONT co-lead. One hand following the traced
    fault-wire back toward its source, the other staying the team's rush to tear into the rig.
  - **IRONFORGE** (Daniel Arwe, sapper / equipment hand) — at the sound "DESIGN SESSION" rig he
    built last sprint (Refit continuity), wrench held back/lowered — discipline over reflex.
  - **HAWKEYE** (Walter Martinez, spotter / verifier) — monocle-scope on the catalog data
    feeding the session, checking it against spec (verifying ground truth).
  - **TACTICIAN** (Rob Hobbs, mission planner) — at the root-cause / fault-tree board, keeping
    the trace and the method.
- Required Text: title "OPERATION ROOT CAUSE"; subtitle "PBI 34203 — REFRESH SESSION REPORTED
  BROKEN · TRACE IT TO THE ROOT"; bottom tagline "TRACE THE FAULT. FIND THE ROOT. FIX THE
  CAUSE."
- Text To Avoid: marketing-speak, generic stock imagery; anything that declares the bug fake or
  the report a "false alarm" (the work is real and the cause is still being traced); anything
  that frames Château as an enemy / saboteur / villain (he is Allied — affectionate roast only).
- Color Notes: Era III palette per `aesthetic.md` §3 — parchment cream / burnt orange / olive
  drab / propaganda red / deep brown backbone; electric cyan (#3FB3D8) sparing accent only
  (rig status light, traced fault-wire, map pins, monocle glow).
- Style References: sibling Attributes-5 Era III posters — Operation Crossfire (two co-leads
  precedent), Operation Green Light. Era III canon in `aesthetic.md` §2/§10 and
  `aesthetic_future.md`.
- Persona reference images supplied to Forge (character likeness), in attach order:
  1. Personas/JamesWarnement_Chateau/poster_future.png  → CHÂTEAU
  2. PBI Posters/team_images/overseer_poster_future.png → OVERSEER
  3. PBI Posters/team_images/ironforge_poster_future.png → IRONFORGE
  4. PBI Posters/team_images/hawkeye_poster_future.png  → HAWKEYE
  5. PBI Posters/team_images/tactician_poster_future.png → TACTICIAN

## Factions
- Team alone — no AI factions (Claude / Copilot / ChatGPT). A bug-triage / root-cause issue is
  ordinary team work, not AI-collaboration work, so factions are omitted per the
  additive-factions rule in `prompt_ado_item_poster.md`.

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/20260617_20260630_attributes_5/
- Desired Filename: OperationRootCause_PBI34203.png
- Prompt Sidecar Required: yes —
  - Poster prompt: AI-Content/WarRooms/PBI Posters/20260617_20260630_attributes_5/prompts/OperationRootCause_PBI34203.txt
  - Insignia prompt: AI-Content/WarRooms/PBI Posters/20260617_20260630_attributes_5/prompts/OperationRootCause_PBI34203_insignia.txt

## Output Needed
- Prompt only: yes
- Image generation: no (will run through Front Line Poster Forge manually)
- Critique / refinement: no
- Alternate concepts: no — single decisive composition (two-zone, Château + Overseer co-leads)
