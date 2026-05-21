# Front Line Poster Forge Request

## Work Item
- ID: 30531
- Title: Attributes: Feature Flags & Component Strategy
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Ready For Work
- Assigned To: 
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/30531

## Narrative
- Problem:
Feature Overview: 
VCMS now supports a concept of selectable attributes associated with product options. 
Designers would like to choose formal attribute values over entering notes on the catalog cards 
Integration customers would like to receive attributes (with their codes) in the integration API selections output 
Buyers want to see additional attributes associated with products [mvp 2] 
Buyers would like to display imagery associated with attribute values [later] 
-------------------------------------------------------------------------------------------------------------------------- 
Intent: 
The intent of this work items is to create feature flags to support incremental development of the attributes 
feature in Design Selections and in other areas of the system 

 
-------------------------------------------------------------------------------------------------------------------------- 
Resources: 
https://www.figma.com/board/ibjLoxR8TqRNXCuwy1j7cp/Product-Owner-Design-Boards?node-id=1433-262&t=jIA8y0G4VzW1o1xz-4
 

 
--------------------------------------------------------------------------------------------------------------------------

- Desired Outcome (per Acceptance Criteria):
New Feature Flag: 
A new feature flag is created that can be toggled on or off in VEO Admin associated with a builder organization: 
 
Name: Support Selectable Attributes (VCMS) 
Description: When ON, the system will fetch and display selectable attributes associated with VCMS product options. 

 
Visual Indicator: 
When the feature flag is ON, 
and the catalog source for a builder organization is VCMS 
the catalog cards in Design Selections have some visual indicator that selectable attributes are enabled 

 
New Feature Flag: 
A new feature flag is created to help us manage the rollout of layout changes to the Catalog cards in OP/DMH and the Area cards in Design Selections. 
Name: Option Cards 2.0 (or 3.0?) 
Description: When ON, the catalog item cards in Option Pricing and Design My Home and the Area cards in Design Selections will use the v2 component. 

 
Visual Indicator: 
- show empty template for the v2 card instead? 
- show a banner instead? 
 

 

 
Some Scenarios: 
- catalog may be staging data for attributes (manually) and want the new card layouts, but not the attributes yet 
- they want training for users before we turn it on?

- Primary Tension:
- Stakeholders / Personas:

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Determined, strategic, decisive — fits the existing War Room aesthetic
- Visual Motifs:
- Required Text: "Attributes: Feature Flags & Component Strategy" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic)

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/
- Desired Filename: Operation<Codename>_PBI30531.png (codename assigned at generation time; mirrors existing naming)
- Prompt Sidecar Required: yes — save as AI-Content/WarRooms/PBI Posters/Prompt Files/Operation<Codename>_PBI30531.txt

## Output Needed
- Prompt only: no
- Image generation: yes
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
