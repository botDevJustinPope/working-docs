# OpenAI Scripts — Usage

How any LLM assistant (Claude Code, ChatGPT, Copilot) and any human user should invoke the
OpenAI integration scripts under `scripts/openai/`. These scripts are the **primary** path for
calling OpenAI from this repo because they are version-controlled, transparent, and usable
outside any single LLM tool.

> **Alternative:** an MCP-server path also exists for Claude Code only — see
> [`../../setup/openai-mcp.md`](../../setup/openai-mcp.md). Prefer the scripts unless you have a
> specific reason to use MCP.

---

## Prerequisites

- **PowerShell 7+** (`pwsh`).
- **OpenAI API key** set as a User-scope environment variable named
  `CLAUDE_openAPI_security_key`. Verify:
  ```powershell
  [Environment]::GetEnvironmentVariable('CLAUDE_openAPI_security_key', 'User')
  ```
  If empty, set it (replace `sk-proj-...` with the real key):
  ```powershell
  [Environment]::SetEnvironmentVariable('CLAUDE_openAPI_security_key', 'sk-proj-...', 'User')
  ```
  Then restart PowerShell so the value is visible to new processes.
- **Active OpenAI billing.** Image generation requires a paid plan — free-trial credits do not
  include image access.

---

## Scripts

All scripts live under `scripts/openai/` and use PowerShell's comment-based help — run
`Get-Help .\scripts\openai\<script>.ps1 -Full` for the full parameter docs.

### `Invoke-OpenAIChat.ps1`

Chat completion against any chat model (default `gpt-4o`). Returns the assistant message string.

```powershell
.\scripts\openai\Invoke-OpenAIChat.ps1 -Prompt "Summarize gpt-image-1 vs DALL-E 3 in one paragraph."
```

With a system prompt:
```powershell
.\scripts\openai\Invoke-OpenAIChat.ps1 `
    -Prompt "Refine this PBI title: 'Search component'" `
    -System "You are a senior product owner."
```

Add `-Raw` to get the full API response object instead of just the text.

### `New-OpenAIImage.ps1`

Image generation against `gpt-image-1` (DALL-E 3 is retired **2026-05-12** — **do not** pass
`-Model dall-e-3`). Writes a PNG to `-OutputPath`.

```powershell
.\scripts\openai\New-OpenAIImage.ps1 `
    -Prompt "A dramatic war-room poster for 'Product Search Component'." `
    -OutputPath ".\poster.png"
```

Add `-WritePromptSidecar` to also write `<OutputPath>.prompt.txt` next to the image, preserving
the prompt with the artifact (this is the convention for anything saved under `AI-Content/`).

### `New-WarRoomPoster.ps1`

Domain wrapper for PBI War Room posters. Bakes in a minimal poster prompt template and writes to
`AI-Content/WarRooms/PBI Posters/PBI-<id>-<slug>.png` with a `.prompt.txt` sidecar.

```powershell
.\scripts\openai\New-WarRoomPoster.ps1 -PbiId 12345 -Title "Product Search Component"
```

The aesthetic template inside this script is intentionally minimal — the full War Room aesthetic
is being refined under `documentation/skills/war-room/`. Use `-StyleDirection` to inject extra
direction without modifying the script:
```powershell
.\scripts\openai\New-WarRoomPoster.ps1 -PbiId 67890 -Title "Inventory Sync" `
    -StyleDirection "Cold-war propaganda style, red and beige palette."
```

Run this from the **repo root** so the default output path lands inside `AI-Content/`.

---

## How LLM Assistants Should Use These Scripts

The scripts are the canonical way for any assistant in this repo to invoke OpenAI:

- **Claude Code** — can call the scripts via its PowerShell tool. Confirm with the user before
  each call (per the *Always Ask Before Doing — Calling external services* permission). Surface
  the exact command before running it.
- **ChatGPT** — does not have shell access. Output the exact command for the user to run, then
  ask them to paste back the result (text reply or image path).
- **Copilot** — can call the scripts via its terminal integration when available; otherwise
  follow ChatGPT's pattern of proposing the command for the user.

In all three cases, **do not paste the API key into prompts or tool output.** The scripts read it
from the User-scope env var; that is the only place it should appear.

---

## Cost Awareness

Image generation is per-image priced. Check
[openai.com/api/pricing/](https://openai.com/api/pricing/) for current rates before generating in
bulk. For one-off poster generation the cost is negligible; for batch runs across many PBIs it
adds up.

---

## What This Skill Does NOT Cover

- **MCP-server setup** — see [`../../setup/openai-mcp.md`](../../setup/openai-mcp.md).
- **AI-Content filing conventions** (where the poster lives long-term, how to cross-reference it
  from Story Notes) — will be authored at `../ai-content/ai-content-conventions.md`.
- **War Room aesthetic standards** (what makes a *good* poster) — will be authored at
  `../war-room/poster-conventions.md`.
