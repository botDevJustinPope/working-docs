<#
.SYNOPSIS
    Send a chat completion request to OpenAI, optionally with image attachments
    (vision). Returns the assistant message text and optionally saves the
    full conversation + response JSON.

.DESCRIPTION
    Reads the API key from User-scope env var CLAUDE_openAPI_security_key,
    builds a multimodal /v1/chat/completions payload, posts it, and returns
    the assistant's text reply. Images are base64-encoded inline as data URLs.

    Usage docs at documentation/skills/external-services/openai-scripts.md

.PARAMETER UserPrompt
    The user message text. Required.

.PARAMETER SystemPrompt
    Optional system message to set role/context.

.PARAMETER ImagePath
    Zero or more image paths to attach to the user message. PNG/JPG/JPEG/GIF/WEBP.
    Each is base64-encoded and embedded as a data URL.

.PARAMETER Model
    Default: gpt-4o (vision-capable). Other vision-capable choices: gpt-4o-mini, gpt-5.

.PARAMETER MaxTokens
    Cap on response tokens. Default: 4000.

.PARAMETER Temperature
    Sampling temperature. Default: 0.7.

.PARAMETER ImageDetail
    OpenAI vision detail level: low | high | auto. Default: auto.

.PARAMETER OutputPath
    Optional. If set, writes two files alongside it:
      - OutputPath              — assistant's text reply (UTF-8)
      - OutputPath + '.json'    — full request + response payload for provenance

.EXAMPLE
    .\Send-OpenAIChat.ps1 -UserPrompt "Hello, who are you?"

.EXAMPLE
    .\Send-OpenAIChat.ps1 `
        -SystemPrompt "You are an art director analyzing war-themed posters." `
        -UserPrompt "Describe the visual language of these images." `
        -ImagePath @('poster1.png','poster2.png') `
        -OutputPath '.\analysis.txt'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$UserPrompt,

    [string]$SystemPrompt,

    [string[]]$ImagePath,

    [string]$Model = 'gpt-4o',

    [int]$MaxTokens = 4000,

    [double]$Temperature = 0.7,

    [ValidateSet('low', 'high', 'auto')]
    [string]$ImageDetail = 'auto',

    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

$key = [Environment]::GetEnvironmentVariable('CLAUDE_openAPI_security_key', 'User')
if ([string]::IsNullOrWhiteSpace($key)) {
    throw "User-scope env var CLAUDE_openAPI_security_key is not set. See documentation/skills/external-services/openai-scripts.md for setup."
}

function Get-MimeType {
    param([string]$Path)
    switch -Regex ([System.IO.Path]::GetExtension($Path).ToLower()) {
        '\.png$'         { 'image/png' }
        '\.jpe?g$'       { 'image/jpeg' }
        '\.gif$'         { 'image/gif' }
        '\.webp$'        { 'image/webp' }
        default          { throw "Unsupported image extension: $Path" }
    }
}

# Build user content: text + optional inlined images
$userContent = New-Object System.Collections.ArrayList
$null = $userContent.Add([ordered]@{ type = 'text'; text = $UserPrompt })

foreach ($img in $ImagePath) {
    $resolved = if ([System.IO.Path]::IsPathRooted($img)) { $img } else { (Resolve-Path -LiteralPath $img).Path }
    if (-not (Test-Path -LiteralPath $resolved)) { throw "Image not found: $img" }
    $mime = Get-MimeType $resolved
    $bytes = [System.IO.File]::ReadAllBytes($resolved)
    $b64 = [Convert]::ToBase64String($bytes)
    $null = $userContent.Add([ordered]@{
        type      = 'image_url'
        image_url = [ordered]@{
            url    = "data:$mime;base64,$b64"
            detail = $ImageDetail
        }
    })
}

# Build messages array
$messages = New-Object System.Collections.ArrayList
if (-not [string]::IsNullOrWhiteSpace($SystemPrompt)) {
    $null = $messages.Add([ordered]@{ role = 'system'; content = $SystemPrompt })
}
$null = $messages.Add([ordered]@{ role = 'user'; content = $userContent })

$body = [ordered]@{
    model       = $Model
    messages    = $messages
    max_tokens  = $MaxTokens
    temperature = $Temperature
} | ConvertTo-Json -Depth 10 -Compress

$response = Invoke-RestMethod `
    -Uri 'https://api.openai.com/v1/chat/completions' `
    -Method Post `
    -Headers @{ Authorization = "Bearer $key"; 'Content-Type' = 'application/json' } `
    -Body $body

$reply = $response.choices[0].message.content
if ([string]::IsNullOrWhiteSpace($reply)) {
    throw "API response did not contain a message reply. Raw response: $($response | ConvertTo-Json -Depth 6)"
}

if ($OutputPath) {
    $resolved = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        $OutputPath
    } else {
        Join-Path (Get-Location).Path $OutputPath
    }
    $outDir = Split-Path -Parent $resolved
    if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
    Set-Content -LiteralPath $resolved -Value $reply -Encoding UTF8

    # Sidecar: full conversation + response (minus the base64 image bytes, which would balloon the file)
    $messagesForLog = $messages | ForEach-Object {
        $m = [ordered]@{ role = $_.role }
        if ($_.content -is [string]) {
            $m.content = $_.content
        } else {
            $m.content = $_.content | ForEach-Object {
                if ($_.type -eq 'image_url') {
                    [ordered]@{ type = 'image_url'; image_url = [ordered]@{ url = '<base64 elided>'; detail = $_.image_url.detail } }
                } else { $_ }
            }
        }
        $m
    }
    $log = [ordered]@{
        model       = $Model
        max_tokens  = $MaxTokens
        temperature = $Temperature
        images      = @($ImagePath)
        messages    = $messagesForLog
        usage       = $response.usage
        reply       = $reply
    } | ConvertTo-Json -Depth 12
    Set-Content -LiteralPath "$resolved.json" -Value $log -Encoding UTF8
}

$reply
