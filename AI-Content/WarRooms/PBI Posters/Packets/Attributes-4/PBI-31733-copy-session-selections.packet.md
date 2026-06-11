# Front Line Poster Forge Request

## Work Item
- ID: 31733
- Title: Attributes: Copy Session / Selections
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Ready For Work
- Assigned To: Justin Pope
- Tags:
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/31733

## Narrative
- Problem:
VCMS selectable attributes are live, but Copy Session and Copy Selections do not yet carry
attribute choices. When a designer copies a session to another user, or copies selections
from an inactive session into an active one, the catalog options arrive — but the formal
attribute values chosen on those options are left behind, and the duplicate is no longer a
faithful copy.

- Desired Outcome (per Acceptance Criteria):
For a builder with the selectable-attributes flag ON, both copy paths carry attribute
selections intact. Copy Session (from homebuyer summary, impersonating a buyer, with the
"include selections" checkbox marked) copies the catalog option into the new session with
the option selected and the same attribute values selected. Copy Selections (from an
inactive session into the active session) copies the catalog option with its attribute
values into the active session. Open question carried from the AC: if the option exists in
one session but not the other, is it added?

- Primary Tension: A copy that arrives hollow — options present, choices stripped — vs. a true duplicate where every selection travels with the session.
- Stakeholders / Personas: Designers copying sessions between users and consolidating selections across sessions; homebuyers whose choices must survive the transfer.

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Duplication post — a forward dispatch depot at night; a session pulled up to the transfer line to be copied in full. Carbon sheets pressed, manifests matched line by line, cargo moved crate-for-crate, nothing left on the origin dock. Lamplight on teletype brass, carbon-black fingertips.
- Visual Motifs: Twin field rigs stenciled "SESSION — SOURCE" and "SESSION — TARGET"; a teletype carbon press printing the duplicate transfer manifest; a transfer order with a checked stencil box "☑ INCLUDE SELECTIONS"; a cargo crate stenciled "CATALOG OPTION — ATTRIBUTES SELECTED" mid-hoist between rigs; a rubber stamp "COPIED IN FULL"; a chalked open question "OPTION IN ONE, NOT THE OTHER — ADD IT?"; a sticky note "FLAG: SELECTABLE ATTRIBUTES — ON".
- Cast: the four-person VDS Pathfinder Detachment, rendered to match supplied persona reference images — **OVERSEER leads this one**, dominant in the foreground; the other three support from the midground:
  - OVERSEER (Justin Pope, senior operator) — LEAD. At the duplication station, one hand pressing the carbon sheet through the teletype press, the other countersigning the transfer order; his multi-overlay HUD visor stacks both sessions' readouts side by side — the operator who sees source and target at once. Senior operator working the line himself, not commanding it.
  - IRONFORGE (Daniel Arwe, sapper/equipment hand) — support. Hoisting the stenciled cargo crate from the source rig across to the target rig — the physical transfer, crate-for-crate.
  - HAWKEYE (Walter Martinez, spotter/verifier) — support. Holding original and carbon side by side, monocle-scope down, ticking matched lines — every value matches or it doesn't ship.
  - TACTICIAN (Rob Hobbs, mission planner) — support. At the change board with both scenarios chalked — "A) COPY SESSION → ANOTHER USER" / "B) COPY SELECTIONS → ACTIVE SESSION" — and the open question chalked beneath.
- Required Text: "Attributes: Copy Session / Selections" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic); sibling Attributes-4 posters (Operation Refit, Operation Dispatch, Operation Retool, Operation Edgewatch, Operation Field Report).
- Persona reference images supplied to Forge (character likeness):
  - Personas/JustinPope_Overseer/poster_future.png
  - Personas/DanielArwe_Ironforge/poster_future.png
  - Personas/WalterMartinez_Hawkeye/poster_future.png
  - Personas/RobHobbs_Tactician/poster_future.png

## Factions
- Team alone — no AI factions (Claude / Copilot). Carrying attribute selections through
  copy paths is ordinary team work, not AI-collaboration work, so factions are omitted per
  the additive-factions rule in prompt_ado_item_poster.md.

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/
- Desired Filename: OperationCarbonCopy_PBI31733.png
- Prompt Sidecar Required: yes — saved as AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/prompts/OperationCarbonCopy_PBI31733.txt

## Output Needed
- Prompt only: yes
- Image generation: no (will run through Front Line Poster Forge manually)
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
