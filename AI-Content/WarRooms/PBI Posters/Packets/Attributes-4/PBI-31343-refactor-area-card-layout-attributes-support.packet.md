# Front Line Poster Forge Request

## Work Item
- ID: 31343
- Title: Attributes: Refactor Area card layout - part 2 (attributes support)
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Ready For Work
- Assigned To: Daniel Arwe
- Tags: attributes
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/31343

## Narrative
- Problem:
The Area card can't yet display or select attributes. With VCMS attribute support coming
online, the card layout must be refactored to show attribute names and values (thumbnail
images or string "chips"), handle more than two attributes with intuitive nav, truncate
long value names with hover-to-reveal, honor VCMS display ordering, and run a proper
selection flow — including saving and reloading attribute choices on the card.

- Desired Outcome (per Acceptance Criteria):
The refactored Area card displays attributes per the wireframes (name + values as
thumbnails or chips, 2 attributes without scroll, nav for >2, 14-char truncation with
hover, VCMS-defined ordering). Selection: clicking the checkbox on a card with unset
attributes opens the card; the user picks one value per attribute; cancel + save/confirm
buttons, save disabled until required values are chosen; on save the card is selected and
values persist. Active image: the first selected attribute value bearing an image replaces
the card's default (GPC) image.

- Primary Tension: A card built for simple notes vs. a card that must carry structured, image-bearing attribute selections.
- Stakeholders / Personas: Designers, buyers.

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Methodical engineering — a forward field workshop refitting equipment under lamplight, sparks and blueprints.
- Visual Motifs: A large "AREA CARD" panel on the workbench being reforged; attribute rows as thumbnails / string chips; CANCEL + SAVE/CONFIRM levers (SAVE locked until required chosen); active-image swap (GPC default replaced by first selected attribute-value image); "2 ATTRIBUTES — NO SCROLL" + ">2 → NAV" notes; truncated value name with hover tooltip.
- Cast: the four-person VDS Pathfinder Detachment, rendered to match supplied persona reference images —
  - IRONFORGE (Daniel Arwe, sapper/equipment hand — operation lead, and the actual ADO assignee) — workbench, reforging the card, fitting rows + save/confirm levers.
  - TACTICIAN (Rob Hobbs, mission planner) — card wireframe/blueprint, baton laying out attribute rows + nav.
  - OVERSEER (Justin Pope, senior operator) — holo-marker selecting values; the active-image swap ("FIRST IMAGE WINS").
  - HAWKEYE (Walter Martinez, spotter/verifier) — verifying truncation/hover + display ordering against a checklist.
- Required Text: "Attributes: Refactor Area card layout" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic); sibling Attributes-line posters (Operation Gated Advance, Field Report).
- Persona reference images supplied to Forge (character likeness):
  - Personas/RobHobbs_Tactician/poster_future.png
  - Personas/DanielArwe_Ironforge/poster_future.png
  - Personas/JustinPope_Overseer/poster_future.png
  - Personas/WalterMartinez_Hawkeye/poster_future.png

## Factions
- Team alone — no AI factions (Claude / Copilot). A UI refactor is ordinary team work, not
  AI-collaboration work, so factions are omitted per the additive-factions rule in
  prompt_ado_item_poster.md.

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/
- Desired Filename: OperationRetool_PBI31343.png
- Prompt Sidecar Required: yes — saved as AI-Content/WarRooms/PBI Posters/20260603_20260616_attributes_4/prompts/OperationRetool_PBI31343.txt

## Output Needed
- Prompt only: yes
- Image generation: no (will run through Front Line Poster Forge manually)
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
