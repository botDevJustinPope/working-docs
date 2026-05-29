# Front Line Poster Forge Request

## Work Item
- ID: 30533
- Title: Attributes: Create Session
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Ready For Work
- Assigned To: 
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/30533

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
The intent of this work items is to create a design session and store product option attribute data in the session snapshot 
so that we can surface it in the Design Selections module for the designer to choose. 
 
-------------------------------------------------------------------------------------------------------------------------- 
Resources: 
Selectable_Product_Attributes_Design_Doc_VDS.docx 
https://www.figma.com/board/ibjLoxR8TqRNXCuwy1j7cp/Product-Owner-Design-Boards?node-id=1441-320&t=jIA8y0G4VzW1o1xz-4

- Desired Outcome (per Acceptance Criteria):
Given that: 
the feature flag "Support Selectable Attributes" is ON for a given organization, 
and attributes are defined in VCMS for at least one product option for this organization 

 
Create Session: 
- when a session is created containing the option, the selectable attributes and values are persisted in the session snapshot and can be verified somehow either in the UI or by running an attached SQL query

- Primary Tension:
- Stakeholders / Personas:

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Determined, strategic, decisive — fits the existing War Room aesthetic
- Visual Motifs:
- Required Text: "Attributes: Create Session" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic)

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/
- Desired Filename: Operation<Codename>_PBI30533.png (codename assigned at generation time; mirrors existing naming)
- Prompt Sidecar Required: yes — save as AI-Content/WarRooms/PBI Posters/20260520_20260602_attributes_3/prompts/Operation<Codename>_PBI30533.txt

## Output Needed
- Prompt only: no
- Image generation: yes
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
