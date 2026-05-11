<#
.SYNOPSIS
    Restructure "AI Content" -> "AI-Content/WarRooms/{...}" per the design spec
    documentation/specs/2026-05-11-ai-content-restructure-design.md.

.DESCRIPTION
    Executes 8 phases sequentially with dry-run support and abort-on-error:
      1. Rename top-level "AI Content" -> "AI-Content"
      2. Create WarRooms/ subfolders (.metaData, Personas/{13}, PBI Posters, Additional Content)
      3. Move persona images into per-person subfolders
      4. Copy matching source photos from people/ into persona subfolders
      5. Sort WarRooms/Images/* into PBI Posters/ vs Additional Content/
         (rule: filename matches /operation/ case-insensitive -> PBI Posters)
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

# In dry-run mode, Phase 1's rename is skipped, so subsequent phases must
# read source files from the OLD root. Destinations are always logged
# under the NEW root (where they'd actually land in live mode).
$LiveRoot = if ($DryRun) { $OldRoot } else { $NewRoot }

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
    if ($DryRun) {
        # In dry-run mode the prior phases' moves didn't actually happen,
        # so we can't verify emptiness. Show the intended action.
        Write-Action 'RmDir' "$Path (if empty)"
        return
    }
    $items = Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($items.Count -gt 0) { Write-Warning "Folder not empty, skipping removal: $Path"; return }
    Write-Action 'RmDir' $Path
    Remove-Item -LiteralPath $Path -Force
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
    $src  = Join-Path $LiveRoot 'content/war_room_personnel'
    $dest = Join-Path $NewRoot  'WarRooms/Personas'
    foreach ($p in $Personas) {
        Move-Asset (Join-Path $src $p.Poster) (Join-Path $dest "$($p.Folder)/poster.png")
        foreach ($v in $p.Variants) {
            Move-Asset (Join-Path $src $v.From) (Join-Path $dest "$($p.Folder)/variants/$($v.To)")
        }
    }
}

function Invoke-Phase4 {
    Write-Host "`n=== Phase 4: Copy source photos ===" -ForegroundColor Green
    $src  = Join-Path $LiveRoot 'people'
    $dest = Join-Path $NewRoot  'WarRooms/Personas'
    foreach ($p in $Personas) {
        Copy-Asset (Join-Path $src $p.Photo) (Join-Path $dest "$($p.Folder)/source.jpg")
    }
}

function Invoke-Phase5 {
    Write-Host "`n=== Phase 5: Sort posters into PBI Posters / Additional Content ===" -ForegroundColor Green
    $imagesDir  = Join-Path $LiveRoot 'WarRooms/Images'
    $infoDir    = Join-Path $LiveRoot 'WarRooms/InfoGraphic'
    $pbiDir     = Join-Path $NewRoot  'WarRooms/PBI Posters'
    $additional = Join-Path $NewRoot  'WarRooms/Additional Content'

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
    Remove-Asset (Join-Path $LiveRoot 'WarRooms/Images/Claude Setup.exe')
}

function Invoke-Phase7 {
    Write-Host "`n=== Phase 7: Remove emptied folders ===" -ForegroundColor Green
    Remove-EmptyFolder (Join-Path $LiveRoot 'WarRooms/Images')
    Remove-EmptyFolder (Join-Path $LiveRoot 'WarRooms/InfoGraphic')
    Remove-EmptyFolder (Join-Path $LiveRoot 'content/war_room_personnel')
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
