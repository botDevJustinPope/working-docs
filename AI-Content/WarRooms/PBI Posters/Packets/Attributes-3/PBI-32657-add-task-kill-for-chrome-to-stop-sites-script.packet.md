# Front Line Poster Forge Request

## Work Item
- ID: 32657
- Title: Add task kill for chrome to STOP sites script
- System / Product Area: VeoDesignStudio
- Feature Type: Product Backlog Item
- State: Done
- Assigned To: Daniel Arwe
- ADO Link: https://dev.azure.com/BuildOnTechnologies/ddde192e-e31e-4e51-af4b-3b7b4221266a/_workitems/edit/32657

## Narrative
- Problem:
During VDS deployments, the deployment can fail because a chrome process on one of the load balanced web servers has files locked. This is annoying because someone must remote into the server and perform a task kill call on the chrome process in order to free it up and then re-deploy. 

 
WE SHOULD ADD THIS TO STOP SCRIPT: 
taskkill /F /IM chrome.exe

taskkill /F /IM chromium.exe

- Desired Outcome (per Acceptance Criteria):
- add a task to kill chrome related processes on the servers as part of the STOP sites script 
- update the scripts on the production servers 
 validation ideas: 
- start chrome on a web server 
- execute the stop script on that server 
- verify the chrome process was terminated

- Primary Tension:
- Stakeholders / Personas:

## Visual Direction
- Poster Format: Vertical War-Room poster (portrait orientation, ~1024x1536)
- Mood: Retro / mission-accomplished — small but useful tactical win. Compare to existing MissionAccomplished_* posters under AI-Content/WarRooms/PBI Posters/.
- Visual Motifs:
- Required Text: "Add task kill for chrome to STOP sites script" (truncate if Forge's poster layout demands it)
- Text To Avoid: marketing-speak, generic stock imagery, anything implying release / shipping
- Color Notes:
- Style References: existing posters under AI-Content/WarRooms/PBI Posters/ (consult Forge's baked-in aesthetic)

## Repo Filing
- Target Folder: AI-Content/WarRooms/PBI Posters/
- Desired Filename: Operation<Codename>_PBI32657.png (codename assigned at generation time; mirrors existing naming)
- Prompt Sidecar Required: yes — save as AI-Content/WarRooms/PBI Posters/20260520_20260602_attributes_3/prompts/Operation<Codename>_PBI32657.txt

## Output Needed
- Prompt only: no
- Image generation: yes
- Critique / refinement: no
- Alternate concepts: no — single decisive composition
