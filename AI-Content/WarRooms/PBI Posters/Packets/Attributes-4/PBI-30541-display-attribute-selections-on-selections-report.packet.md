# Front Line Poster Forge Request

## Work Item
- ID: 30541
- Title: Attributes: Display attribute selections on selections report
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Ready For Work
- Assigned To: Justin Pope
- Tags: attributes
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/30541

## Narrative
- Problem:
VCMS now supports selectable attributes associated with product options. The selections
report does not yet surface them. Designers want formal attribute values shown rather than
free-text notes on catalog cards, and buyers want to see the attributes associated with
the products they chose.

- Desired Outcome (per Acceptance Criteria):
On the selections report, for a session with options that have attribute values selected:
display each attribute and its selected value in a "selected options" section, and if a
selected attribute value has an associated image, surface the first selected attribute
image as the "main" image for the catalog item on the report.

- Primary Tension: Choices buried in notes vs. every selected attribute legible on the record.
- Stakeholders / Personas: Designers, integration customers, buyers.

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Clarifying, decisive — assembling the field report so every choice is on the record. Methodical compilation, warm lamp light.
- Visual Motifs: Briefing wall posting a "SELECTIONS REPORT"; a pinned "MAIN IMAGE" product photo from a selected attribute value; a "SELECTED OPTIONS" column of stamped attribute:value cards; messy hand-written catalog notes set aside in favor of clean stamped values.
- Cast: the four-person VDS Pathfinder Detachment, rendered to match supplied persona reference images —
  - TACTICIAN (Rob Hobbs, mission planner) — head of the board, baton, directing the report layout.
  - OVERSEER (Justin Pope, senior operator) — hand on holo-marker, transferring values into the "SELECTED OPTIONS" column.
  - HAWKEYE (Walter Martinez, spotter/verifier) — verifying each value-card against the catalog, ticking the checklist.
  - IRONFORGE (Daniel Arwe, sapper/equipment hand) — pinning the framed "MAIN IMAGE" + wiring the holographic catalog card.
- Required Text: "Attributes: Display attribute selections on selections report" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic); sibling Attributes-line posters (Operation Gated Advance, Bedrock, Session Vault).
- Persona reference images supplied to Forge (character likeness):
  - Personas/RobHobbs_Tactician/poster_future.png
  - Personas/DanielArwe_Ironforge/poster_future.png
  - Personas/JustinPope_Overseer/poster_future.png
  - Personas/WalterMartinez_Hawkeye/poster_future.png

## Factions
- Team alone — no AI factions (Claude / Copilot). A reporting/display feature is ordinary
  team work, not AI-collaboration work, so factions are omitted per the additive-factions
  rule in prompt_ado_item_poster.md.

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/
- Desired Filename: OperationFieldReport_PBI30541.png
- Prompt Sidecar Required: yes — saved as AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/prompts/OperationFieldReport_PBI30541.txt

## Output Needed
- Prompt only: yes
- Image generation: no (will run through Front Line Poster Forge manually)
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
