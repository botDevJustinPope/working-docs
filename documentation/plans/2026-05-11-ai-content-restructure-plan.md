# AI-Content Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Execute the AI-Content directory restructure per spec [`2026-05-11-ai-content-restructure-design.md`](../specs/2026-05-11-ai-content-restructure-design.md). Move War Room artifacts into `AI-Content/WarRooms/{.metaData, Personas, PBI Posters, Additional Content}`, copy source photos into per-persona subfolders, delete one misfile, and update 9 in-repo references to the old path.

**Architecture:** Single PowerShell script `scripts/restructure-ai-content.ps1` executes all 8 phases sequentially with dry-run support and abort-on-first-error semantics. Reference-file text replacement happens inside the same script run (Phase 8) so the repo is never internally inconsistent between commit and migration. Per the project's CLAUDE.md, every commit requires explicit user approval — the plan calls this out at each commit step.

**Tech Stack:** PowerShell 7+ (project default per environment notes). No new dependencies.

---

## File structure

| File | Action | Responsibility |
|---|---|---|
| `scripts/restructure-ai-content.ps1` | Create | All 8 phases of the restructure incl. Phase 8 text replacements |
| `AI Content/` | Rename to `AI-Content/` (Phase 1) | Top-level content root |
| `AI-Content/WarRooms/` subtree | Populated (Phases 2–7) | New canonical War Room layout |
| `scripts/openai/New-WarRoomPoster.ps1` | Edit (Phase 8) | Default `$OutputPath` + docstring path mentions |
| `scripts/openai/New-OpenAIImage.ps1` | Edit (Phase 8) | Docstring example path |
| `documentation/skills/external-services/openai-scripts.md` | Edit (Phase 8) | 4 path mentions |
| `documentation/assistants/claude.md` | Edit (Phase 8) | 1 path mention |
| `documentation/assistants/chatgpt-instructions.md` | Edit (Phase 8) | 5 path mentions |
| `documentation/assistants/copilot-instructions.md` | Edit (Phase 8) | 1 path mention |
| `documentation/skills/README.md` | Edit (Phase 8) | 1 path mention |
| `documentation/skills/git/commit-conventions.md` | Edit (Phase 8) | 1 example path |
| `documentation/skills/git/add-conventions.md` | Edit (Phase 8) | 1 conceptual mention |
| `C:\Users\justinpo\.claude\projects\...\memory\war-room-state.md` | Edit (Task 5) | Reflect restructure landed; pivot to sub-project #2 |
| `C:\Users\justinpo\.claude\projects\...\memory\MEMORY.md` | Edit (Task 5) | Update index hook line for war-room-state |

---

## Note on TDD

This plan does NOT use the standard write-test → fail → impl → pass cycle. It's a one-shot filesystem migration script; the equivalent "test" is the script's built-in dry-run mode plus the post-migration verification in Task 4. Each task below still has explicit per-step checks and expected output.

---

### Task 1: Build the restructure script

**Files:**
- Create: `scripts/restructure-ai-content.ps1`

- [ ] **Step 1: Verify parent folder exists**

Run: `Test-Path scripts`
Expected: `True`. If `False`, create with `New-Item -ItemType Directory -Path scripts`.

- [ ] **Step 2: Write the complete script**

Create `scripts/restructure-ai-content.ps1` with this exact content:

```powershell
<#
.SYNOPSIS
    Restructure "AI Content" → "AI-Content/WarRooms/{...}" per the design spec
    documentation/specs/2026-05-11-ai-content-restructure-design.md.

.DESCRIPTION
    Executes 8 phases sequentially with dry-run support and abort-on-error:
      1. Rename top-level "AI Content" → "AI-Content"
      2. Create WarRooms/ subfolders (.metaData, Personas/{13}, PBI Posters, Additional Content)
      3. Move persona images into per-person subfolders
      4. Copy matching source photos from people/ into persona subfolders
      5. Sort WarRooms/Images/* into PBI Posters/ vs Additional Content/
         (rule: filename matches /operation/ case-insensitive → PBI Posters)
         + handle OperationSynchlist.png duplicate via SHA256 hash compare
      6. Delete WarRooms/Images/Claude Setup.exe
      7. Remove emptied folders (Images/, InfoGraphic/, content/war_room_personnel/)
      8. Update 9 in-repo references to the old path

.PARAMETER DryRun
    Print every planned operation without mutating the filesystem.

.PARAMETER Force
    Skip the interactive "y to proceed" confirmation.

.EXAMPLE
    .\scripts\restructure-ai-content.ps1 -DryRun
    Preview all operations.

.EXAMPLE
    .\scripts\restructure-ai-content.ps1
    Run for real; prompts before mutating.

.NOTES
    Run from the repo root. Close VS Code and any editors holding files open;
    the top-level rename in Phase 1 fails fast if files are locked.
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $RepoRoot

$OldRoot = 'AI Content'
$NewRoot = 'AI-Content'

# Personas: folder name, source poster filename, source photo filename, variants
$Personas = @(
    @{ Folder='JosephArellano_Anvil';      Poster='anvil_JosephArellano.png';      Photo='joseph_arellano.jpg';  Variants=@() }
    @{ Folder='ShelbyMansker_Archon';      Poster='archon_ShelbyMansker.png';      Photo='shelby_mansker.jpg';   Variants=@() }
    @{ Folder='EricHickey_Atlas';          Poster='atlas_erickhickey.png';         Photo='eric_hickey.jpg';      Variants=@() }
    @{ Folder='CharlieBradley_Blueprint';  Poster='blueprint_charilebradley.png';  Photo='charlie_bradley.jpg';  Variants=@() }
    @{ Folder='JoeEbeling_Chronos';        Poster='chronos_joeebeling.png';        Photo='joe_ebeling.jpg';      Variants=@() }
    @{ Folder='ReidWilson_Codeburst';      Poster='codeburst_reidwilson.png';      Photo='reid_wilson.jpg';      Variants=@(
        @{ From='codeburst_reidwilson_inthefield.png'; To='inthefield.png' }
    ) }
    @{ Folder='JenniferHickey_DTD';        Poster='dtd_jenniferhickey.png';        Photo='jennifer_hickey.jpg';  Variants=@() }
    @{ Folder='WalterMartinez_Hawkeye';    Poster='hawkeye_waltermartinex.png';    Photo='walter_martinez.jpg'; Variants=@() }
    @{ Folder='DanielArwe_Ironforge';      Poster='ironforge_DanielArwe.png';      Photo='daniel_arwe.jpg';      Variants=@() }
    @{ Folder='JustinPope_Overseer';       Poster='overseer_justinpope.png';       Photo='justin_pope.jpg';      Variants=@() }
    @{ Folder='SamKlepper_PrivateKlepper'; Poster='privateklepper_SamKlepper.png'; Photo='sam_klepper.jpg';      Variants=@() }
    @{ Folder='RobHobbs_Tactician';        Poster='tactician_robhobbs.png';        Photo='rob_hobs.jpg';         Variants=@(
        @{ From='tactician_robhobbs_cheesing.png'; To='cheesing.png' }
        @{ From='tactician_robhobbs_serious.png';  To='serious.png' }
    ) }
    @{ Folder='WadeWelch_Tinker';          Poster='tinker_wadewelch.png';          Photo='wade_welch.jpg';       Variants=@() }
)

# Phase 8: text replacements per reference file
$ReferenceEdits = @(
    @{ File='scripts/openai/New-WarRoomPoster.ps1';                     Edits=@(
        @{ Old='AI Content/War Room Posters'; New='AI-Content/WarRooms/PBI Posters' }
    ) }
    @{ File='scripts/openai/New-OpenAIImage.ps1';                       Edits=@(
        @{ Old='AI Content/foo.png'; New='AI-Content/foo.png' }
        @{ Old='AI Content convention'; New='AI-Content convention' }
    ) }
    @{ File='documentation/skills/external-services/openai-scripts.md'; Edits=@(
        @{ Old='AI Content/War Room Posters';      New='AI-Content/WarRooms/PBI Posters' }
        @{ Old='`AI Content/`';                    New='`AI-Content/`' }
        @{ Old='`AI Content`';                     New='`AI-Content`' }
        @{ Old='**AI Content filing conventions**'; New='**AI-Content filing conventions**' }
    ) }
    @{ File='documentation/assistants/claude.md';                       Edits=@(
        @{ Old='`AI Content/`';  New='`AI-Content/`' }
        @{ Old='**AI Content**'; New='**AI-Content**' }
    ) }
    @{ File='documentation/assistants/chatgpt-instructions.md';         Edits=@(
        @{ Old='AI Content/War Room Posters'; New='AI-Content/WarRooms/PBI Posters' }
        @{ Old='`AI Content/`';               New='`AI-Content/`' }
        @{ Old='`AI Content/<topic>/`';       New='`AI-Content/<topic>/`' }
        @{ Old='**AI Content**';              New='**AI-Content**' }
    ) }
    @{ File='documentation/assistants/copilot-instructions.md';         Edits=@(
        @{ Old='`AI Content/`';  New='`AI-Content/`' }
        @{ Old='**AI Content**'; New='**AI-Content**' }
    ) }
    @{ File='documentation/skills/README.md';                           Edits=@(
        @{ Old='`AI Content/`'; New='`AI-Content/`' }
    ) }
    @{ File='documentation/skills/git/commit-conventions.md';           Edits=@(
        @{ Old='AI Content/WarRoom/30900/'; New='AI-Content/WarRooms/PBI Posters/30900/' }
    ) }
    @{ File='documentation/skills/git/add-conventions.md';              Edits=@(
        @{ Old='AI Content,'; New='AI-Content,' }
    ) }
)

function Write-Action {
    param([string]$Verb, [string]$Detail)
    $color = if ($DryRun) { 'Yellow' } else { 'Cyan' }
    $prefix = if ($DryRun) { '[DRY] ' } else { '' }
    Write-Host ("  {0,-12} {1}" -f "${prefix}${Verb}", $Detail) -ForegroundColor $color
}

function Move-Asset {
    param([string]$From, [string]$To)
    if (-not (Test-Path -LiteralPath $From)) { throw "Source not found: $From" }
    if (Test-Path -LiteralPath $To)          { throw "Destination already exists: $To" }
    Write-Action 'Move' "$From -> $To"
    if (-not $DryRun) { Move-Item -LiteralPath $From -Destination $To }
}

function Copy-Asset {
    param([string]$From, [string]$To)
    if (-not (Test-Path -LiteralPath $From)) { throw "Source not found: $From" }
    if (Test-Path -LiteralPath $To)          { throw "Destination already exists: $To" }
    Write-Action 'Copy' "$From -> $To"
    if (-not $DryRun) { Copy-Item -LiteralPath $From -Destination $To }
}

function New-Folder {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) { return }
    Write-Action 'MkDir' $Path
    if (-not $DryRun) { New-Item -ItemType Directory -Path $Path | Out-Null }
}

function Remove-Asset {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    Write-Action 'Remove' $Path
    if (-not $DryRun) { Remove-Item -LiteralPath $Path -Force }
}

function Remove-EmptyFolder {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $items = Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($items.Count -gt 0) { Write-Warning "Folder not empty, skipping removal: $Path"; return }
    Write-Action 'RmDir' $Path
    if (-not $DryRun) { Remove-Item -LiteralPath $Path -Force }
}

function Invoke-Phase1 {
    Write-Host "`n=== Phase 1: Top-level rename ===" -ForegroundColor Green
    if (-not (Test-Path -LiteralPath $OldRoot)) {
        if (Test-Path -LiteralPath $NewRoot) {
            Write-Host "  Already renamed; skipping." -ForegroundColor Gray
            return
        }
        throw "Neither '$OldRoot' nor '$NewRoot' exists in $RepoRoot"
    }
    Write-Action 'Rename' "$OldRoot -> $NewRoot"
    if (-not $DryRun) { Rename-Item -LiteralPath $OldRoot -NewName $NewRoot }
}

function Invoke-Phase2 {
    Write-Host "`n=== Phase 2: Create WarRooms/ subfolders ===" -ForegroundColor Green
    $war = Join-Path $NewRoot 'WarRooms'
    New-Folder (Join-Path $war '.metaData')
    New-Folder (Join-Path $war 'Personas')
    New-Folder (Join-Path $war 'PBI Posters')
    New-Folder (Join-Path $war 'Additional Content')
    foreach ($p in $Personas) {
        New-Folder (Join-Path $war "Personas/$($p.Folder)")
        if ($p.Variants.Count -gt 0) {
            New-Folder (Join-Path $war "Personas/$($p.Folder)/variants")
        }
    }
}

function Invoke-Phase3 {
    Write-Host "`n=== Phase 3: Move persona images ===" -ForegroundColor Green
    $src  = Join-Path $NewRoot 'content/war_room_personnel'
    $dest = Join-Path $NewRoot 'WarRooms/Personas'
    foreach ($p in $Personas) {
        Move-Asset (Join-Path $src $p.Poster) (Join-Path $dest "$($p.Folder)/poster.png")
        foreach ($v in $p.Variants) {
            Move-Asset (Join-Path $src $v.From) (Join-Path $dest "$($p.Folder)/variants/$($v.To)")
        }
    }
}

function Invoke-Phase4 {
    Write-Host "`n=== Phase 4: Copy source photos ===" -ForegroundColor Green
    $src  = Join-Path $NewRoot 'people'
    $dest = Join-Path $NewRoot 'WarRooms/Personas'
    foreach ($p in $Personas) {
        Copy-Asset (Join-Path $src $p.Photo) (Join-Path $dest "$($p.Folder)/source.jpg")
    }
}

function Invoke-Phase5 {
    Write-Host "`n=== Phase 5: Sort posters into PBI Posters / Additional Content ===" -ForegroundColor Green
    $imagesDir  = Join-Path $NewRoot 'WarRooms/Images'
    $infoDir    = Join-Path $NewRoot 'WarRooms/InfoGraphic'
    $pbiDir     = Join-Path $NewRoot 'WarRooms/PBI Posters'
    $additional = Join-Path $NewRoot 'WarRooms/Additional Content'

    # Handle OperationSynchlist.png duplicate first
    $synch1 = Join-Path $imagesDir 'OperationSynchlist.png'
    $synch2 = Join-Path $infoDir   'OperationSynchlist.png'
    if ((Test-Path -LiteralPath $synch1) -and (Test-Path -LiteralPath $synch2)) {
        $h1 = (Get-FileHash -LiteralPath $synch1 -Algorithm SHA256).Hash
        $h2 = (Get-FileHash -LiteralPath $synch2 -Algorithm SHA256).Hash
        if ($h1 -eq $h2) {
            Write-Host "  OperationSynchlist.png: identical; discarding InfoGraphic copy." -ForegroundColor Gray
            Remove-Asset $synch2
        } else {
            Write-Host "  OperationSynchlist.png: differs; suffixing InfoGraphic copy." -ForegroundColor Gray
            Move-Asset $synch2 (Join-Path $pbiDir 'OperationSynchlist_infographic.png')
        }
    }

    # Sort remaining files in Images/
    Get-ChildItem -LiteralPath $imagesDir -File | ForEach-Object {
        if ($_.Name -eq 'Claude Setup.exe') { return }  # handled in Phase 6
        $target = if ($_.Name.ToLower() -match 'operation') { $pbiDir } else { $additional }
        Move-Asset $_.FullName (Join-Path $target $_.Name)
    }

    # Move anything still in InfoGraphic/
    if (Test-Path -LiteralPath $infoDir) {
        Get-ChildItem -LiteralPath $infoDir -File | ForEach-Object {
            $target = if ($_.Name.ToLower() -match 'operation') { $pbiDir } else { $additional }
            Move-Asset $_.FullName (Join-Path $target $_.Name)
        }
    }
}

function Invoke-Phase6 {
    Write-Host "`n=== Phase 6: Delete misfile ===" -ForegroundColor Green
    Remove-Asset (Join-Path $NewRoot 'WarRooms/Images/Claude Setup.exe')
}

function Invoke-Phase7 {
    Write-Host "`n=== Phase 7: Remove emptied folders ===" -ForegroundColor Green
    Remove-EmptyFolder (Join-Path $NewRoot 'WarRooms/Images')
    Remove-EmptyFolder (Join-Path $NewRoot 'WarRooms/InfoGraphic')
    Remove-EmptyFolder (Join-Path $NewRoot 'content/war_room_personnel')
}

function Invoke-Phase8 {
    Write-Host "`n=== Phase 8: Update in-repo references ===" -ForegroundColor Green
    foreach ($entry in $ReferenceEdits) {
        $path = $entry.File
        if (-not (Test-Path -LiteralPath $path)) { Write-Warning "Missing reference file: $path"; continue }
        $content = Get-Content -LiteralPath $path -Raw
        $modified = $false
        foreach ($edit in $entry.Edits) {
            if ($content.Contains($edit.Old)) {
                Write-Action 'Edit' "$path :: '$($edit.Old)' -> '$($edit.New)'"
                $content = $content.Replace($edit.Old, $edit.New)
                $modified = $true
            }
        }
        if ($modified -and -not $DryRun) {
            Set-Content -LiteralPath $path -Value $content -NoNewline
        }
    }
}

# --- Main ------------------------------------------------------------------

Write-Host "AI-Content restructure" -ForegroundColor Magenta
Write-Host "  Repo root: $RepoRoot" -ForegroundColor Magenta
Write-Host "  Mode:      $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })" -ForegroundColor Magenta

if (-not $DryRun -and -not $Force) {
    Write-Host "`nThis will: rename the top-level folder, move ~100 files, copy 13 source photos," -ForegroundColor Yellow
    Write-Host "delete one .exe, and edit 9 docs/scripts." -ForegroundColor Yellow
    $confirm = Read-Host "Proceed? (y/N)"
    if ($confirm -ne 'y') { Write-Host "Aborted."; exit 0 }
}

try {
    Invoke-Phase1
    Invoke-Phase2
    Invoke-Phase3
    Invoke-Phase4
    Invoke-Phase5
    Invoke-Phase6
    Invoke-Phase7
    Invoke-Phase8
    Write-Host "`nAll phases complete." -ForegroundColor Green
} catch {
    Write-Host "`nABORTED: $_" -ForegroundColor Red
    Write-Host "Filesystem may be in a partial state. Inspect manually before retry." -ForegroundColor Red
    exit 1
}
```

- [ ] **Step 3: Parse-check the script**

Run from repo root:
```powershell
pwsh -NoProfile -Command "$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw .\scripts\restructure-ai-content.ps1), [ref]$null); 'OK'"
```
Expected: prints `OK`. Any parse error indicates a syntax problem in the script — fix and re-run.

- [ ] **Step 4: Commit (REQUIRES USER APPROVAL per CLAUDE.md)**

Surface the staged diff to the user and wait for explicit "yes" before committing. Then:

```bash
git add scripts/restructure-ai-content.ps1
git commit -m "$(cat <<'EOF'
Add AI-Content restructure migration script

Implements all 8 phases per documentation/specs/2026-05-11-ai-content-restructure-design.md:
top-level rename, WarRooms/ subfolder creation, persona moves with per-person folders,
source-photo copies, poster sorting, misfile deletion, empty-folder cleanup, and
in-repo reference updates. Supports -DryRun and -Force.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Dry-run review

**Files:** None (executes the script with -DryRun)

- [ ] **Step 1: Close all editors holding files in `AI Content/`**

VS Code (if it has any file in `AI Content/` open), Word (`.docx` files), File Explorer windows pinned to the path. Phase 1's `Rename-Item` fails fast on locked files; better to catch the lock now than after Phase 2 has started.

- [ ] **Step 2: Run the dry run**

From the repo root:
```powershell
.\scripts\restructure-ai-content.ps1 -DryRun
```

- [ ] **Step 3: Verify expected output**

Expected output structure:

```
AI-Content restructure
  Repo root: C:\github\botdevjustinpope\working-docs
  Mode:      DRY RUN

=== Phase 1: Top-level rename ===
  [DRY] Rename   AI Content -> AI-Content

=== Phase 2: Create WarRooms/ subfolders ===
  [DRY] MkDir   <19 MkDir lines>

=== Phase 3: Move persona images ===
  [DRY] Move    <16 Move lines>     (13 posters + 3 variants)

=== Phase 4: Copy source photos ===
  [DRY] Copy    <13 Copy lines>

=== Phase 5: Sort posters into PBI Posters / Additional Content ===
  OperationSynchlist.png: <identical/differs> ...
  [DRY] Move    <~66-67 Move lines>

=== Phase 6: Delete misfile ===
  [DRY] Remove  AI-Content/WarRooms/Images/Claude Setup.exe

=== Phase 7: Remove emptied folders ===
  [DRY] RmDir   AI-Content/WarRooms/Images
  [DRY] RmDir   AI-Content/WarRooms/InfoGraphic
  [DRY] RmDir   AI-Content/content/war_room_personnel

=== Phase 8: Update in-repo references ===
  [DRY] Edit    <one line per replacement that would apply>

All phases complete.
```

Phase 2 count check: 4 top-level subfolders (`.metaData`, `Personas`, `PBI Posters`, `Additional Content`) + 13 persona folders + 2 `variants/` folders (Codeburst, Tactician) = **19 MkDir**.

Phase 5 count check: 67 files in `WarRooms/Images/` − 1 `Claude Setup.exe` (skipped) = 66 from Images/. Plus 1 from `InfoGraphic/` only if the Synchlist copies differ (otherwise the InfoGraphic Synchlist gets removed in the pre-loop). So **66 or 67 Move** lines.

If a phase throws or counts don't match, fix the script and re-run from Step 2.

- [ ] **Step 4: USER SIGNOFF — surface output and wait**

Pause here. Show the dry-run output to the user. Get explicit "go" before Task 3.

---

### Task 3: Execute the migration for real

**Files:** None (executes the committed script live)

- [ ] **Step 1: Re-confirm editors closed**

Same checks as Task 2 Step 1. Don't skip — VS Code re-opens recent files on launch.

- [ ] **Step 2: Run live**

```powershell
.\scripts\restructure-ai-content.ps1
```

When the prompt appears (`Proceed? (y/N)`), type `y` and press Enter.

- [ ] **Step 3: Capture the output**

The script ends with `All phases complete.` on success. If it ends with `ABORTED: <error>`, the filesystem is in a partial state — read the red message to know which phase failed, then inspect manually. Do NOT re-run the script blindly; the dry-run logic in Phase 1 will detect that the rename already happened and skip it, but later phases may collide with already-moved files.

---

### Task 4: Post-migration verification

**Files:** None (read-only checks)

- [ ] **Step 1: Verify top-level rename**

```powershell
Test-Path 'AI-Content'   # expected: True
Test-Path 'AI Content'   # expected: False
```

- [ ] **Step 2: Verify Personas/ structure**

```powershell
(Get-ChildItem 'AI-Content/WarRooms/Personas' -Directory).Count
```
Expected: **13**.

Spot check a persona with variants:
```powershell
Get-ChildItem 'AI-Content/WarRooms/Personas/RobHobbs_Tactician' -Recurse -File | Select-Object FullName
```
Expected files: `poster.png`, `source.jpg`, `variants/cheesing.png`, `variants/serious.png`.

Spot check a persona without variants:
```powershell
Get-ChildItem 'AI-Content/WarRooms/Personas/EricHickey_Atlas' -File | Select-Object Name
```
Expected files: `poster.png`, `source.jpg`.

- [ ] **Step 3: Verify PBI Posters and Additional Content counts**

```powershell
(Get-ChildItem 'AI-Content/WarRooms/PBI Posters' -File).Count
```
Expected: **43** if the two `OperationSynchlist.png` copies were identical (duplicate discarded), or **44** if they differed (one suffixed `_infographic.png`).

```powershell
(Get-ChildItem 'AI-Content/WarRooms/Additional Content' -File).Count
```
Expected: **24**.

- [ ] **Step 4: Verify emptied folders are gone**

```powershell
Test-Path 'AI-Content/WarRooms/Images'              # expected: False
Test-Path 'AI-Content/WarRooms/InfoGraphic'         # expected: False
Test-Path 'AI-Content/content/war_room_personnel'   # expected: False
```

- [ ] **Step 5: Verify reference updates**

Grep for the old path string in directories that should no longer reference it. Exclude the migration script itself (it literally contains the string as data) and the design spec (historical references):

```powershell
Select-String -Pattern 'AI Content' -Path documentation, scripts -Recurse |
    Where-Object {
        $_.Path -notlike '*restructure-ai-content.ps1' -and
        $_.Path -notlike '*\specs\*' -and
        $_.Path -notlike '*\plans\*'
    }
```
Expected: **zero matches**.

- [ ] **Step 6: Smoke test the OpenAI scripts parse**

```powershell
pwsh -NoProfile -Command "$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw .\scripts\openai\New-WarRoomPoster.ps1), [ref]$null); 'OK'"
pwsh -NoProfile -Command "$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw .\scripts\openai\New-OpenAIImage.ps1), [ref]$null); 'OK'"
```
Both expected to print `OK`.

- [ ] **Step 7: Surface verification results to user**

Print a summary table: top-level rename ✓, persona count, PBI Posters count, Additional Content count, emptied folders gone, grep returned zero, scripts parse. Wait for user acknowledgment before Task 5.

---

### Task 5: Update memory and commit the migration result

**Files:**
- Modify: `C:\Users\justinpo\.claude\projects\C--github-botdevjustinpope-working-docs\memory\war-room-state.md`
- Modify: `C:\Users\justinpo\.claude\projects\C--github-botdevjustinpope-working-docs\memory\MEMORY.md`

- [ ] **Step 1: Update `war-room-state.md`**

The current memory describes the restructure as PENDING and lists "Mismatches to fix when work resumes." After this migration, that's obsolete. Rewrite the file to:

- Frontmatter: update `name` and `description` so the entry indicates restructure landed YYYY-MM-DD and what's next (sub-project #2 aesthetic spec).
- Body: replace the "Existing assets..." and "Mismatches to fix..." sections with a "Current layout" section pointing to `AI-Content/WarRooms/{...}` and a "What's still pending" section listing sub-projects #2/#3/#4 with their dependencies.
- Update the morning-pickup steps so step 1 is "Ask about aesthetic spec direction" (sub-project #2), not "Ask about restructure."
- Update every path reference from `AI Content/WarRooms/Images/` (and similar) to the new `AI-Content/WarRooms/PBI Posters/` (or `Personas/`, etc.) form.

- [ ] **Step 2: Update `MEMORY.md` hook line for war-room-state**

The current line reads:
```
- [War Room state 2026-05-10 — restructure pending, Forge integration paused](war-room-state.md) — existing gallery at AI Content/WarRooms/Images/, Eric's-team personas built; resume in the morning
```

Replace with a new hook reflecting the post-restructure state. Example:
```
- [War Room state 2026-05-11 — restructure landed, aesthetic spec next](war-room-state.md) — AI-Content/WarRooms/{Personas,PBI Posters,Additional Content,.metaData} populated; sub-project #2 (aesthetic) is the next cycle
```

- [ ] **Step 3: Commit the migration result (REQUIRES USER APPROVAL per CLAUDE.md)**

Show the user the staged diff. Wait for explicit "yes." Then:

```bash
git add AI-Content scripts/openai/New-WarRoomPoster.ps1 scripts/openai/New-OpenAIImage.ps1 documentation/
git commit -m "$(cat <<'EOF'
Restructure AI-Content into WarRooms/{.metaData, Personas, PBI Posters, Additional Content}

- Top-level rename: 'AI Content' -> 'AI-Content'
- 13 persona subfolders, each with poster.png + source.jpg (+ variants/ where applicable)
- All Operation-style posters consolidated in PBI Posters/ (43 or 44 files
  depending on OperationSynchlist.png duplicate state)
- Deployments, PRs, ambient, abstract op_X style sheets in Additional Content/ (24)
- Updated 9 in-repo references to the old path
- Deleted misfile WarRooms/Images/Claude Setup.exe
- Removed emptied Images/, InfoGraphic/, content/war_room_personnel/

Unblocks Forge integration (sub-project #4) and aesthetic spec (sub-project #2).
See documentation/specs/2026-05-11-ai-content-restructure-design.md and
documentation/plans/2026-05-11-ai-content-restructure-plan.md.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

Note: the `.png` files inside `AI-Content/` were untracked before the rename. After Phase 1 they become `AI-Content/...` and remain untracked unless explicitly added. Confirm with the user whether they want the renamed images committed as a single tree (`git add AI-Content`) or kept untracked (matching their pre-restructure status). The above commit assumes "commit them so the rename is recorded."

- [ ] **Step 4: Push (REQUIRES USER APPROVAL per CLAUDE.md)**

Per the repo rules, pushes need explicit per-push approval. Ask the user if they want this pushed to `origin/main` now, or held locally.

```bash
git push origin main
```

---

## Self-review

**Spec coverage:**

| Spec section | Plan task |
|---|---|
| Phase 1 — top-level rename | Task 1 (build) + Task 3 (execute) ✓ |
| Phase 2 — WarRooms/ subfolder creation (incl. 13 personas + 2 variants/) | Task 1 ✓ |
| Phase 3 — move persona images (13 + 3 variants) | Task 1 ✓ |
| Phase 4 — copy source photos (13) | Task 1 ✓ |
| Phase 5 — sort posters by `operation` match + Synchlist hash compare | Task 1 ✓ |
| Phase 6 — delete `Claude Setup.exe` | Task 1 ✓ |
| Phase 7 — clean empty folders (3) | Task 1 ✓ |
| Phase 8 — update 9 reference files | Task 1 ✓ |
| Dry-run required | Task 2 ✓ |
| Confirmation prompt | Task 3 ✓ |
| Verification (folders gone, personas = 13, PBI = 43/44, Additional = 24, grep = 0) | Task 4 ✓ |
| Update `war-room-state.md` memory (implicit follow-up) | Task 5 ✓ |
| Commit gates per CLAUDE.md | Task 1 Step 4 + Task 5 Step 3 + Task 5 Step 4 ✓ |

**Placeholder scan:** No "TBD", "TODO", "implement later", "add appropriate error handling," or "similar to Task N" present. Every commit message is concrete. Every verification step has an expected value.

**Type/name consistency:** Persona folder names (`<RealName>_<Codename>` PascalCase, 13 entries) match between the spec, the script's `$Personas` array, and the verification spot checks. PowerShell function names (`Move-Asset`, `Copy-Asset`, `New-Folder`, `Remove-Asset`, `Remove-EmptyFolder`, `Write-Action`, `Invoke-Phase1`–`Invoke-Phase8`) used consistently. Reference-file paths in `$ReferenceEdits` match the spec's Phase 8 table.

**Known risk acknowledged:** The plan does not unit-test the script (no Pester in this repo, and the script is one-shot). Dry-run + post-migration verification is the substitute. Abort-on-error in the script + per-phase ordering means a partial state is recoverable manually but not automatically.
