# Front Line Poster Forge Request

## Work Item
- ID: 33444
- Title: EDGE labor not found
- System / Product Area: VeoDesignStudio
- Feature Type: Bug
- State: Ready For Work
- Assigned To: Justin Pope
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/33444

## Narrative
- Problem:
A labor record comes back "not found" from the EDGE system — the expected labor data is
missing when queried. The acceptance criteria is open-ended: research the cause and, if
possible, fix it. The story is a hunt: trace the line to where the record should be and
find the gap.

- Desired Outcome (per Acceptance Criteria):
Research and, if possible, fix the issue — identify why EDGE returns "labor not found" and
restore the missing record / close the gap so labor resolves correctly.

- Primary Tension: A record that should exist returns 404 — finding where it went.
- Stakeholders / Personas:

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Tense investigation — a night search at the forward edge of the line, hunting a record that never arrived. Searchlights, CRT-glow, determined tracing.
- Visual Motifs: Forward signals/listening post; teletype-CRT reading "EDGE :: LABOR NOT FOUND — 404"; empty crate stenciled "LABOR"; severed fiber-optic cable; wall map with a "MISSING" pin over a gap in the supply route.
- Cast: the four-person VDS Pathfinder Detachment, rendered to match supplied persona reference images —
  - TACTICIAN (Rob Hobbs, mission planner) — wall map, baton on the "MISSING" pin, directing the search.
  - OVERSEER (Justin Pope, senior operator) — hand on holo-marker querying EDGE; the "LABOR NOT FOUND — 404" CRT.
  - IRONFORGE (Daniel Arwe, sapper/equipment hand) — empty "LABOR" crate, tracing the severed fiber-optic cable.
  - HAWKEYE (Walter Martinez, spotter/verifier) — range-finder past the wire + the blank manifest line stamped "NOT FOUND".
- Required Text: "EDGE labor not found" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying the bug is already resolved / shipped
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic); Era III cyber-WW2 house style of the Attributes sprint series.
- Persona reference images supplied to Forge (character likeness):
  - Personas/RobHobbs_Tactician/poster_future.png
  - Personas/DanielArwe_Ironforge/poster_future.png
  - Personas/JustinPope_Overseer/poster_future.png
  - Personas/WalterMartinez_Hawkeye/poster_future.png

## Factions
- Team alone — no AI factions (Claude / Copilot). A bug fix is ordinary team work, not
  AI-collaboration work, so factions are omitted per the additive-factions rule in
  prompt_ado_item_poster.md.

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/
- Desired Filename: OperationEdgewatch_PBI33444.png
- Prompt Sidecar Required: yes — saved as AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/prompts/OperationEdgewatch_PBI33444.txt

## Output Needed
- Prompt only: yes
- Image generation: no (will run through Front Line Poster Forge manually)
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
