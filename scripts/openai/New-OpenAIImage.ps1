<#
.SYNOPSIS
    Generate an image with OpenAI's gpt-image-1 model and save it to disk.

.DESCRIPTION
    Reads the API key from User-scope env var CLAUDE_openAPI_security_key,
    posts the prompt to /v1/images/generations, decodes the b64_json payload,
    and writes the PNG bytes to OutputPath.

    Optionally writes a sidecar .prompt.txt file alongside the image so the
    prompt is preserved with the artifact, per the AI-Content convention.

    Usage docs at documentation/skills/external-services/openai-scripts.md

.PARAMETER Prompt
    The image prompt. Required.

.PARAMETER OutputPath
    Where to write the PNG. Required. Parent directories are created if missing.
    Relative paths resolve against the current directory.

.PARAMETER Size
    1024x1024, 1024x1536, 1536x1024, or auto. Default: 1024x1024.

.PARAMETER Model
    Default: gpt-image-1. DALL-E 3 is retired 2026-05-12 — do not use 'dall-e-3'.

.PARAMETER Quality
    low, medium, high, or auto. Default: high.

.PARAMETER WritePromptSidecar
    Also write OutputPath + '.prompt.txt' containing the prompt.

.EXAMPLE
    .\New-OpenAIImage.ps1 -Prompt "A dramatic war-room poster..." -OutputPath ".\poster.png"

.EXAMPLE
    .\New-OpenAIImage.ps1 -Prompt $p -OutputPath "AI-Content/foo.png" -WritePromptSidecar
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Prompt,

    [Parameter(Mandatory, Position = 1)]
    [string]$OutputPath,

    [ValidateSet('1024x1024', '1024x1536', '1536x1024', 'auto')]
    [string]$Size = '1024x1024',

    [string]$Model = 'gpt-image-1',

    [ValidateSet('low', 'medium', 'high', 'auto')]
    [string]$Quality = 'high',

    [switch]$WritePromptSidecar
)

$ErrorActionPreference = 'Stop'

$key = [Environment]::GetEnvironmentVariable('CLAUDE_openAPI_security_key', 'User')
if ([string]::IsNullOrWhiteSpace($key)) {
    throw "User-scope env var CLAUDE_openAPI_security_key is not set. See documentation/skills/external-services/openai-scripts.md for setup."
}

$resolved = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath
} else {
    Join-Path (Get-Location).Path $OutputPath
}

$outDir = Split-Path -Parent $resolved
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$body = [ordered]@{
    model   = $Model
    prompt  = $Prompt
    size    = $Size
    quality = $Quality
    n       = 1
} | ConvertTo-Json -Depth 6 -Compress

$response = Invoke-RestMethod `
    -Uri 'https://api.openai.com/v1/images/generations' `
    -Method Post `
    -Headers @{ Authorization = "Bearer $key"; 'Content-Type' = 'application/json' } `
    -Body $body

$b64 = $response.data[0].b64_json
if ([string]::IsNullOrWhiteSpace($b64)) {
    throw "API response did not contain b64_json image data. Raw response: $($response | ConvertTo-Json -Depth 5)"
}

[System.IO.File]::WriteAllBytes($resolved, [Convert]::FromBase64String($b64))

if ($WritePromptSidecar) {
    $sidecarPath = "$resolved.prompt.txt"
    Set-Content -LiteralPath $sidecarPath -Value $Prompt -Encoding UTF8
}

Get-Item -LiteralPath $resolved
