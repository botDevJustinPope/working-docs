# Front Line Poster Forge Request

## Work Item
- ID: 30542
- Title: Attributes: Add selected attributes to integration api / selections end point(s)
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Ready For Work
- Assigned To:
- Tags: attributes
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/30542

## Narrative
- Problem:
Integration customers consume design selections through the Integration API, but the
/selections response does not yet include the attributes and values a designer chose. With
VCMS selectable attributes online, integration partners need those attributes (with their
codes) emitted downstream.

- Desired Outcome (per Acceptance Criteria):
For a builder with the selectable-attributes flag ON and a session containing a product
option with an attribute value selected, the endpoint /sessions/{sessionId}/selections
returns all attribute and attribute-value selections for each non-estimated selection — the
structure carrying attribute id + name and the selected attribute value id + name + image
url (when present).

- Primary Tension: Selections that stop at the UI vs. selections that travel downstream to integration partners intact.
- Stakeholders / Personas: Integration customers.

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Transmission / dispatch — a signal-corps relay sending the selections downstream over the wire. Glowing fiber-optic lines, transmitter glow.
- Visual Motifs: Forward signals-relay station; teletype-CRT printing a "/sessions/{id}/selections" payload with rows attributeId/attributeName, valueId/valueName, imageUrl; a fiber-optic trunk line running to a downstream bunker flagged "INTEGRATION CUSTOMERS"; a "CHANNEL LIVE" tag.
- Cast: the four-person VDS Pathfinder Detachment, rendered to match supplied persona reference images —
  - OVERSEER (Justin Pope, senior operator) — transmitter console, keying the dispatch; the "/selections" payload CRT.
  - HAWKEYE (Walter Martinez, spotter/verifier) — verifying the payload fields against a manifest checklist before it ships.
  - TACTICIAN (Rob Hobbs, mission planner) — wall map, baton tracing the route to "INTEGRATION CUSTOMERS".
  - IRONFORGE (Daniel Arwe, sapper/equipment hand) — maintaining the transmitter rig / fiber-optic trunk, "CHANNEL LIVE".
- Required Text: "Attributes: Add selected attributes to integration API / selections endpoint" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic); sibling Attributes-line posters (Operation Gated Advance, Field Report).
- Persona reference images supplied to Forge (character likeness):
  - Personas/RobHobbs_Tactician/poster_future.png
  - Personas/DanielArwe_Ironforge/poster_future.png
  - Personas/JustinPope_Overseer/poster_future.png
  - Personas/WalterMartinez_Hawkeye/poster_future.png

## Factions
- Team alone — no AI factions (Claude / Copilot). An API/integration feature is ordinary
  team work, not AI-collaboration work, so factions are omitted per the additive-factions
  rule in prompt_ado_item_poster.md.

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/
- Desired Filename: OperationDispatch_PBI30542.png
- Prompt Sidecar Required: yes — saved as AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/prompts/OperationDispatch_PBI30542.txt

## Output Needed
- Prompt only: yes
- Image generation: no (will run through Front Line Poster Forge manually)
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
