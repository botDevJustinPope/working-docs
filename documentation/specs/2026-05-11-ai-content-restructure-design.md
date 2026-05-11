# AI-Content Restructure — Design

**Date:** 2026-05-11
**Status:** Approved — ready for implementation plan
**Scope:** Sub-project #1 of the War Room follow-up work. Restructures the `AI Content/` directory into `AI-Content/WarRooms/{.metaData, Personas, PBI Posters, Additional Content}` and updates the 9 in-repo references to the old path. Sub-projects #2 (aesthetic spec), #3 (persona update plan), and #4 (Forge integration resume) are deferred to separate brainstorming cycles and depend on this one landing first.

---

## Why this restructure

The current `AI Content/` directory mixes War Room artifacts (personas, operation posters, ambient imagery, infographics) with unrelated content (memes, WorldWarAI banners, source photos), with files scattered across `WarRooms/Images/`, `WarRooms/InfoGraphic/`, `content/war_room_personnel/`, `CardTemplates/`, and the root. The Forge integration (paused on 2026-05-10) needs a stable target path. The future aesthetic spec needs a clear home. This restructure consolidates everything War-Room into `AI-Content/WarRooms/` and leaves the rest alone.

The morning-pickup memory (`war-room-state.md`) called this out as the gating step before any further code changes. This spec satisfies that gate.

---

## Target structure

```
AI-Content/                              (renamed from "AI Content")
├── WarRooms/
│   ├── .metaData/                       (empty this session; populated in sub-project #2)
│   ├── Personas/
│   │   ├── JosephArellano_Anvil/
│   │   │   ├── poster.png
│   │   │   └── source.jpg
│   │   ├── ShelbyMansker_Archon/
│   │   ├── EricHickey_Atlas/
│   │   ├── CharlieBradley_Blueprint/        (folder name fixes "charile" typo)
│   │   ├── JoeEbeling_Chronos/
│   │   ├── ReidWilson_Codeburst/
│   │   │   ├── poster.png
│   │   │   ├── source.jpg
│   │   │   └── variants/
│   │   │       └── inthefield.png
│   │   ├── JenniferHickey_DTD/
│   │   ├── WalterMartinez_Hawkeye/          (folder name fixes "martinex" typo)
│   │   ├── DanielArwe_Ironforge/
│   │   ├── JustinPope_Overseer/
│   │   ├── SamKlepper_PrivateKlepper/
│   │   ├── RobHobbs_Tactician/
│   │   │   ├── poster.png
│   │   │   ├── source.jpg
│   │   │   └── variants/
│   │   │       ├── cheesing.png
│   │   │       └── serious.png
│   │   └── WadeWelch_Tinker/
│   ├── PBI Posters/                     (~44 Operation-style files, names unchanged)
│   └── Additional Content/              (~24 files: deployments, PRs, ambient, abstract op_X)
│
├── CardTemplates/                       (untouched)
├── content/                             (untouched, minus war_room_personnel/)
├── people/                              (untouched — source.jpg in Personas/ is a COPY)
└── (loose root files untouched)
```

### Persona folder convention

- Folder names: `<RealName>_<Codename>/` (PascalCase, no spaces). Reverse of the existing image filename convention.
- Inside each persona folder:
  - `poster.png` — the in-character War Room poster (moved from `content/war_room_personnel/`).
  - `source.jpg` — the real-name reference photo (copied from `people/`; original stays).
  - `variants/` — only when alternate poses exist. Variant filenames drop the codename and real-name prefix: `inthefield.png`, `cheesing.png`, `serious.png`.
- Folder names correct two typos present in the source filenames (`charilebradley` → `CharlieBradley`, `waltermartinex` → `WalterMartinez`).
- `PrivateKlepper` is preserved as-is even though "Private" reads as a rank rather than a codename — flagged for sub-project #2 to revisit.
- No `bio.md` files created this session (deferred to sub-project #3).

### PBI Posters bucket

- Holds every Operation-named poster (with or without a PBI ID embedded in the filename), including capitalization variants (`Operation X`, `OperationX`, `operation_x`), prefixed variants (`Canceled Operation X`, `MissionAccomplished_OperationY`), and the PR-Operation files (`PR Operation Field Manual`).
- Filenames are NOT normalized in this session — the naming convention will be authored as `WarRooms/.metaData/naming.md` in sub-project #2 and applied as a batch rename later.
- `OperationSynchlist.png` exists in both `WarRooms/Images/` and `WarRooms/InfoGraphic/`. The migration script compares them via file hash; identical → move one and discard the dup; different → suffix the InfoGraphic copy as `OperationSynchlist_infographic.png`.

### Additional Content bucket

Catch-all for War Room imagery that isn't an Operation poster:

- Deployments/RCs: `deployment 2026.02.02.png`, `deployment 2026_03_30.png`, `deployment 2026_04_27.png`, `deployment 2026_04_27 completed.png`, `hotfix_deployment_2026_04_02.png`, `rc_20260511.png`
- PRs (non-Operation): `pr_approval.png`, `pr_ready.png`
- Ambient: `TheJim.png`, `Retreat.png`, `parking_lot.png`, `possible_contact.png`, `memorandum.png`, `random bug.png`
- Abstract `op_X` style sheets: `op_backdrop.png`, `op_chronopulse.png`, `op_echelon.png`, `op_overseer.png`, `op_packscope.png`, `op_prism.png`, `op_scriptwave.png`, `op_spectrum.png`, `op_typeface.png`

### .metaData/

Empty this session. Will hold the WarRoom-wide aesthetic spec (`aesthetic.md`) and naming convention (`naming.md`) authored in sub-project #2. No per-asset generation sidecars in this design — those are deferred to the Forge integration cycle.

### Out of scope (intentionally untouched)

- `CardTemplates/` (all 12 files, including persona-named `.docx`)
- `content/funny/`, `content/WorldWarAI/`, `content/basematerial/`, `content/cardtemplating/`, `content/WarCartoonContent.png`, `content/gigem_aggies.png`, `content/github_profile.png`
- `people/` (source photos remain canonical; copies live in Personas/)
- Loose root files: `needyBirds.png`

---

## Migration mechanics

Executed as a single PowerShell script (target: `scripts/restructure-ai-content.ps1`). Script must support a dry-run mode that prints every planned operation before any mutation, and require explicit confirmation to proceed.

### Phase ordering (sequential — later phases assume earlier ones succeeded)

1. **Rename top-level** — `Rename-Item "AI Content" "AI-Content"`. Fails fast if any file is locked.
2. **Create WarRooms/ subfolders** — `.metaData/`, `Personas/` + 13 persona subfolders, `PBI Posters/`, `Additional Content/`.
3. **Move persona images** — for each persona, `Move-Item` the PNG from `content/war_room_personnel/` → `WarRooms/Personas/<Folder>/poster.png`. Variant PNGs go to `variants/` with shortened names.
4. **Copy source photos** — for each persona, `Copy-Item` the matching jpg from `people/` → `WarRooms/Personas/<Folder>/source.jpg`. `people/` untouched.
5. **Sort posters** — every Operation-named file from `WarRooms/Images/` + `WarRooms/InfoGraphic/OperationSynchlist.png` → `WarRooms/PBI Posters/`. Everything else from `WarRooms/Images/` → `WarRooms/Additional Content/`. Hash-compare `OperationSynchlist.png` duplicates per rule above.
6. **Delete misfile** — `Remove-Item "WarRooms/Images/Claude Setup.exe"`.
7. **Clean empty folders** — remove `WarRooms/Images/`, `WarRooms/InfoGraphic/`, `content/war_room_personnel/` once empty.
8. **Update references** — text replacement across the 9 files listed below.

### Files requiring text replacement (Phase 8)

| File | Edits |
|---|---|
| `scripts/openai/New-WarRoomPoster.ps1` | Default `$OutputPath` (L86): `AI Content/War Room Posters` → `AI-Content/WarRooms/PBI Posters`. Docstring lines 8 + 29: same. |
| `scripts/openai/New-OpenAIImage.ps1` | Docstring example L38: `AI Content/foo.png` → `AI-Content/foo.png`. |
| `documentation/skills/external-services/openai-scripts.md` | 4 mentions of `AI Content` and `War Room Posters`. |
| `documentation/assistants/claude.md` | 1 mention (L21). |
| `documentation/assistants/chatgpt-instructions.md` | 5 mentions including the `War Room Posters` script-path reference. |
| `documentation/assistants/copilot-instructions.md` | 1 mention (L24). |
| `documentation/skills/README.md` | 1 mention (L45). |
| `documentation/skills/git/commit-conventions.md` | Example path L59: `AI Content/WarRoom/30900/` → `AI-Content/WarRooms/PBI Posters/30900/`. |
| `documentation/skills/git/add-conventions.md` | 1 conceptual mention (L26). |

### Safety properties

- **Dry-run first.** The script prints every planned operation as a summary table and requires `y` to proceed.
- **Abort on first failure.** `$ErrorActionPreference = 'Stop'` plus try/catch around each phase; partial states are documented in error output.
- **No git safety net for .png files.** Image assets are not tracked. Recovery from a botched run depends on filesystem state. The dry-run is the only guard — run with VS Code and all editors closed to avoid file locks during the top-level rename.
- **Idempotent skip logic** is NOT required for v1. The script assumes a fresh run on the current "before" state. If aborted mid-flight, the script's error message tells the user what's been done so they can resume manually.

### Verification after run

- `AI-Content/WarRooms/Images/` and `AI-Content/WarRooms/InfoGraphic/` and `AI-Content/content/war_room_personnel/` no longer exist.
- `AI-Content/WarRooms/Personas/` contains exactly 13 subfolders, each with `poster.png` + `source.jpg` (and `variants/` where applicable).
- `AI-Content/WarRooms/PBI Posters/` file count = 43 if the two `OperationSynchlist.png` copies are identical (duplicate discarded), 44 if different (one suffixed).
- `AI-Content/WarRooms/Additional Content/` file count = 24 files.
- `grep -r "AI Content" documentation/ scripts/` returns zero matches.

---

## Queued sub-projects

The War Room follow-up work is decomposed into four sub-projects. This spec covers #1; sections below sketch #2, #3, #4 so each next cycle has a starting point and inherited follow-ups aren't lost.

---

### Sub-project #2 — War Room aesthetic spec & naming conventions

**Goal:** Author `WarRooms/.metaData/aesthetic.md` and `WarRooms/.metaData/naming.md`. Apply the naming convention as a batch rename to existing posters once finalized.

**Depends on:** Sub-project #1 (this spec) landed — folders exist.

**Inputs needed from user before brainstorming:**

- Sample posters that exemplify the desired aesthetic (palette, typography, framing).
- Tone direction (gritty / heroic / propaganda / parody / etc.).
- Whether the abstract `op_X` style sheets (now in Additional Content) should be promoted to `.metaData/styles/` as canonical reference, kept as ambient, or deleted.

**Decisions to drive out:**

- Visual language: color palette, typography, recurring motifs, treatment of text overlays.
- Naming convention: format for poster filenames (e.g. `Operation_Snake_Case_<PBI>.png` vs. `OperationPascalCase.png`), variant suffixing rule, PBI-ID convention.
- Batch rename plan for the ~44 PBI Posters and ~24 Additional Content files.
- `PrivateKlepper` folder rename decision (preserve as-is or normalize to a codename-style label).
- Whether per-persona `bio.md` schema is defined here or in sub-project #3.

**Open follow-ups inherited from sub-project #1 (captured during file-allocation walkthrough):**

- Filename typo `Operation Contnet Vault.png` (vs. existing `operation_content_vault.png` — possibly the same poster filed twice).
- Multiple variants of the same poster: `Operation Field Manual.png` + `PR Operation Field Manual.png` + `PR Operation Field Manual v2.png`; `Operation Dashboard Forge Poster.png` + `... TM imposed.png`; `Operation Iron Ledger.png` + `Canceled Operation Iron Ledger.png`; `OperationEmptyRoster.png` + `MissionAccomplished_OperationEmptyRoster.png`.
- Naming format split across existing files: `Operation X` (spaces), `OperationX` (concatenated), `operation_x` (snake_case), `op_X` (abstract style sheets, now in Additional Content).

---

### Sub-project #3 — Persona update plan

**Goal:** Refresh the 13 existing persona posters using the locked aesthetic. Add `bio.md` to each persona folder. Decide handling of variants and of people who appear in memes but don't have a persona poster yet.

**Depends on:** Sub-project #2 (aesthetic must be locked before re-generation begins).

**Inputs needed from user:**

- Whether existing source photos in `people/` are still current or need re-shooting.
- Backstory / rank / role / team / era metadata per persona (raw content for `bio.md`).
- Decisions on people who appear in memes but lack a persona poster: Aaron Gladstone (codename "Shockwave"? implied by `shockwave_aarongladstone.png` in `content/funny/`), Tammy Spence ("Siren"? implied by `siren_tammyspence.png`), James Warnement.

**Decisions to drive out:**

- Re-generate all 13 posters in one batch, or only specific ones?
- `bio.md` schema fields (codename, rank, role, real name, team, era, signature gear, catchphrase?).
- Variant strategy: do all personas get `_inthefield`-style variants for consistency, or only when there's narrative reason?
- New personas to commission for people currently missing one.
- Whether the existing 3 `_cartoon.png` files in `people/` (EricHickey, JustinPope, RogerWang) become persona variants or stay as separate `content/funny/`-adjacent artifacts.

---

### Sub-project #4 — Forge integration resume

**Goal:** Build `scripts/openai/Start-PosterForge.ps1` (interactive REPL) and finish iteration of `scripts/openai/New-WarRoomPoster.ps1`'s baked-in `$basePrompt` so it reflects the locked aesthetic.

**Depends on:** Sub-project #1 (paths exist) + Sub-project #2 (aesthetic drives `$basePrompt` and the output filename convention).

**Inputs needed from user (per the war-room-state memory, morning-pickup step #3):**

- Front Line Poster Forge Custom GPT settings: **Instructions**, **Description**, **Conversation Starters**, **Knowledge files**, and **Capabilities**.

**Implementation sketch (carried forward from `war-room-state.md`):**

- Forge instructions filed at `documentation/skills/war-room/poster-forge.system.md` (canonical, version-controlled, loaded by the script as system prompt).
- REPL flow:
  1. User submits PBI metadata (ID, title, description, acceptance criteria) + optional direction.
  2. GPT returns an outline; user iterates with more direction or says `generate`.
  3. On `generate`: final-prompt extraction message → pipe into `New-OpenAIImage.ps1` with `gpt-image-1`.
  4. Save `.png` + `.prompt.txt` + `.conversation.json` sidecars under `AI-Content/WarRooms/PBI Posters/`.
- Per-asset metadata sidecars (`.prompt.txt`, `.conversation.json`, optional `.meta.json`) get formally specified here — they were deferred out of sub-project #1's spec.
- Propagation of the new skill file per `documentation/skills/assistant-conventions.md` once it lands.

**Decisions to drive out:**

- Sidecar schema (`.meta.json` fields: model, prompt, style direction, PBI ID, timestamp, conversation turn count, etc.).
- Whether `New-WarRoomPoster.ps1` and `Start-PosterForge.ps1` remain separate scripts or merge into one with modes.
- Whether to keep the MCP alternative at `documentation/setup/openai-mcp.md` as a labeled fallback path or retire it now that scripts are working.
- Output filename convention for Forge-generated posters (must align with `WarRooms/.metaData/naming.md` from sub-project #2).
