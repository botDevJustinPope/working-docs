# Front Line Poster Forge Request

## Work Item
- ID: 30543
- Title: Attributes: Support refresh session
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Ready For Work
- Assigned To:
- Tags: added; attributes
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/30543

## Narrative
- Problem:
VCMS selectable attributes are live, but Refresh Session does not yet pick up attribute
changes made in the catalog. When attributes or attribute values are added, removed, or
renamed on catalog options, an existing design session has no way to see those changes,
review them, and bring itself up to current catalog spec.

- Desired Outcome (per Acceptance Criteria):
For a builder with the selectable-attributes flag ON, refresh session surfaces newly found
attributes and attribute values so the user can review and selectively apply them; surfaces
removed attributes and values the user can elect to apply (with a warning and an extra
opt-in step when the removed value — or its parent attribute — is currently selected in the
session); propagates in-place name changes where the ID is static (selection survives, the
display name updates); and audits every attribute-related change applied to the session.

- Primary Tension: A session frozen against a stale catalog vs. a session refit to current spec — with the user choosing each change, never having it forced.
- Stakeholders / Personas: Designers maintaining long-lived sessions; integration customers downstream of accurate selections.

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Depot refit — a forward repair bay at night; the session pulled off the line for a refit. New parts arriving, dead parts pulled, every swap inspected, signed for, and logged. Lamplight on oiled steel, sparks from the bench.
- Visual Motifs: A field rig stenciled "DESIGN SESSION" mid-refit; incoming crate "NEW ATTRIBUTES — REVIEW & APPLY"; outbound bin "REMOVED FROM CATALOG"; a pulled part wired with a red warning tag "IN USE — CONFIRM REMOVAL" awaiting an extra sign-off; a re-stenciled crate (same serial, new name) chalked "SAME ID · NEW NAME"; an audit ledger logging every applied change; a sticky note "FLAG: SELECTABLE ATTRIBUTES — ON".
- Cast: the four-person VDS Pathfinder Detachment, rendered to match supplied persona reference images — **IRONFORGE leads this one**, dominant in the foreground; the other three support from the midground:
  - IRONFORGE (Daniel Arwe, sapper/equipment hand) — LEAD. At the refit bench, wrench in hand, seating a new attribute-value component into the session rig; the incoming/outbound crates and the warning-tagged part are his station.
  - OVERSEER (Justin Pope, senior operator) — support. At the teletype-CRT printing the refresh manifest (found/added/removed rows), marker-tablet ready to countersign the change order.
  - HAWKEYE (Walter Martinez, spotter/verifier) — support. Checking each incoming and outgoing part against the manifest, ticking what the user elected to apply.
  - TACTICIAN (Rob Hobbs, mission planner) — support. At the change board, keeping the audit ledger — every applied change chalked and logged.
- Required Text: "Attributes: Support refresh session" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic); sibling Attributes-4 posters (Operation Dispatch, Operation Retool, Operation Edgewatch, Operation Field Report).
- Persona reference images supplied to Forge (character likeness):
  - Personas/DanielArwe_Ironforge/poster_future.png
  - Personas/JustinPope_Overseer/poster_future.png
  - Personas/WalterMartinez_Hawkeye/poster_future.png
  - Personas/RobHobbs_Tactician/poster_future.png

## Factions
- Team alone — no AI factions (Claude / Copilot). A refresh-session refactor is ordinary
  team work, not AI-collaboration work, so factions are omitted per the additive-factions
  rule in prompt_ado_item_poster.md.

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/
- Desired Filename: OperationRefit_PBI30543.png
- Prompt Sidecar Required: yes — saved as AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/prompts/OperationRefit_PBI30543.txt

## Output Needed
- Prompt only: yes
- Image generation: no (will run through Front Line Poster Forge manually)
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
