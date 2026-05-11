<#
.SYNOPSIS
    Generate a War Room poster for an ADO PBI using OpenAI's gpt-image-1 model.

.DESCRIPTION
    Domain wrapper around New-OpenAIImage.ps1. Builds a poster prompt from the
    PBI metadata, generates the image, and saves it under
    'AI-Content/WarRooms/PBI Posters/' with a .prompt.txt sidecar so the prompt is
    preserved with the artifact.

    The aesthetic template baked in here is intentionally minimal — the full
    War Room aesthetic is being refined under documentation/skills/war-room/.
    Use -StyleDirection to inject extra aesthetic direction without modifying
    this script.

    Usage docs at documentation/skills/external-services/openai-scripts.md

.PARAMETER PbiId
    The ADO PBI id. Used in filename and prompt.

.PARAMETER Title
    The PBI title. Used in the prompt.

.PARAMETER StyleDirection
    Extra aesthetic direction appended to the baked-in prompt template.

.PARAMETER OutputPath
    Override the default output location. Default:
    'AI-Content/WarRooms/PBI Posters/PBI-<id>-<slug>.png' resolved relative to the
    current directory (run from repo root for the default to land correctly).

.PARAMETER Size
    1024x1024, 1024x1536, 1536x1024, or auto. Default: 1024x1536 (vertical poster).

.PARAMETER Quality
    low, medium, high, or auto. Default: high.

.EXAMPLE
    .\New-WarRoomPoster.ps1 -PbiId 12345 -Title "Product Search Component"

.EXAMPLE
    .\New-WarRoomPoster.ps1 -PbiId 67890 -Title "Inventory Sync" `
        -StyleDirection "Cold-war propaganda style, red and beige palette."
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$PbiId,

    [Parameter(Mandatory, Position = 1)]
    [string]$Title,

    [string]$StyleDirection,

    [string]$OutputPath,

    [ValidateSet('1024x1024', '1024x1536', '1536x1024', 'auto')]
    [string]$Size = '1024x1536',

    [ValidateSet('low', 'medium', 'high', 'auto')]
    [string]$Quality = 'high'
)

$ErrorActionPreference = 'Stop'

$basePrompt = @"
A dramatic War Room poster commissioned to give a software product backlog item
its own visual identity for refinement and planning sessions. The poster is for
PBI #$PbiId, titled "$Title".

The composition must read as a single bold visual — confident, decisive, and
worth pinning to a wall. Include the PBI title visibly. Avoid generic stock
imagery; favor a specific, memorable visual hook tied to the title's subject.
"@

if ($StyleDirection) {
    $prompt = "$basePrompt`n`nAdditional direction: $StyleDirection"
} else {
    $prompt = $basePrompt
}

if (-not $OutputPath) {
    $slug = ($Title -replace '[^a-zA-Z0-9 ]', '' -replace '\s+', '-').ToLowerInvariant().Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) { $slug = 'untitled' }
    if ($slug.Length -gt 60) { $slug = $slug.Substring(0, 60).TrimEnd('-') }
    $OutputPath = Join-Path 'AI-Content/WarRooms/PBI Posters' "PBI-$PbiId-$slug.png"
}

$scriptDir = Split-Path -Parent $PSCommandPath
$imageScript = Join-Path $scriptDir 'New-OpenAIImage.ps1'

& $imageScript `
    -Prompt $prompt `
    -OutputPath $OutputPath `
    -Size $Size `
    -Quality $Quality `
    -WritePromptSidecar
