<#
.SYNOPSIS
    Call OpenAI's chat-completion API and return the assistant's reply.

.DESCRIPTION
    Reads the API key from User-scope env var CLAUDE_openAPI_security_key,
    posts a single user message (with optional system prompt) to
    /v1/chat/completions, and returns the assistant message content as a string.

    Usage docs and conventions live at
    documentation/skills/external-services/openai-scripts.md

.PARAMETER Prompt
    User message content. Required.

.PARAMETER System
    Optional system prompt prepended before the user message.

.PARAMETER Model
    Chat model id. Default: gpt-4o.

.PARAMETER MaxTokens
    Max completion tokens. Default: 4096.

.PARAMETER Temperature
    Sampling temperature 0..2. Default: 0.7.

.PARAMETER Raw
    Return the full API response object instead of the message string.

.EXAMPLE
    .\Invoke-OpenAIChat.ps1 -Prompt "Summarize gpt-image-1 vs DALL-E 3 in one paragraph."

.EXAMPLE
    .\Invoke-OpenAIChat.ps1 -Prompt "Refine this PBI title: 'Search component'" `
        -System "You are a product owner with twenty years of experience."
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Prompt,

    [string]$System,

    [string]$Model = 'gpt-4o',

    [int]$MaxTokens = 4096,

    [double]$Temperature = 0.7,

    [switch]$Raw
)

$ErrorActionPreference = 'Stop'

$key = [Environment]::GetEnvironmentVariable('CLAUDE_openAPI_security_key', 'User')
if ([string]::IsNullOrWhiteSpace($key)) {
    throw "User-scope env var CLAUDE_openAPI_security_key is not set. See documentation/skills/external-services/openai-scripts.md for setup."
}

$messages = @()
if ($System) { $messages += [ordered]@{ role = 'system'; content = $System } }
$messages += [ordered]@{ role = 'user'; content = $Prompt }

$body = [ordered]@{
    model       = $Model
    messages    = $messages
    max_tokens  = $MaxTokens
    temperature = $Temperature
} | ConvertTo-Json -Depth 8 -Compress

$response = Invoke-RestMethod `
    -Uri 'https://api.openai.com/v1/chat/completions' `
    -Method Post `
    -Headers @{ Authorization = "Bearer $key"; 'Content-Type' = 'application/json' } `
    -Body $body

if ($Raw) { return $response }
$response.choices[0].message.content
