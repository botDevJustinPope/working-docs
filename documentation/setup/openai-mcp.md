# OpenAI MCP Setup — Claude Code

One-time walkthrough for connecting Claude Code to OpenAI's API (chat completion + image
generation) via an MCP server. Once complete, Claude Code sessions get tools for invoking GPT
models and generating images directly in conversation.

> Authored 2026-05-08 based on the MCP ecosystem at that time. If significant time has passed,
> verify the recommended MCP server is still actively maintained before installing.

---

## What This Enables

After setup, Claude Code (in any repo on this machine) can:

- Call GPT-4-class models (gpt-4o, o1, etc.) for chat completion — "ask GPT for a second
  opinion on this draft."
- Generate images via `gpt-image-1` (OpenAI's current image model after DALL·E 3 was retired)
  and save them to disk.

Primary use case in working-docs: **generating War Room PBI posters** without leaving the
Claude Code session.

---

## Prerequisites

- **Node.js 18+** installed and on `PATH`. Verify:
  ```powershell
  node --version
  ```
  Install from https://nodejs.org/ (LTS) if missing.

- **Active OpenAI billing.** Image generation requires a paid OpenAI account — free-trial
  credits do not include image access. Add a payment method at
  https://platform.openai.com/account/billing/payment-methods.

---

## Step 1 — Create an OpenAI API Key

1. Sign in at https://platform.openai.com/
2. Open **API keys**: https://platform.openai.com/api-keys
3. Click **Create new secret key**
4. Name it identifiably (e.g., `claude-code-working-docs`)
5. Default permissions ("All") are fine
6. **Copy the key immediately** — it's shown only once. Store it in your password manager

---

## Step 2 — Set the Env Var

Set `OPENAI_API_KEY` in **User** scope on Windows so it persists across sessions:

```powershell
[Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "sk-...", "User")
```

Replace `sk-...` with the actual key from Step 1.

> **Why `OPENAI_API_KEY` and not `CLAUDE_OPENAI_KEY`?**
> The recommended MCP server reads `OPENAI_API_KEY` by convention, and there's no other tool on
> this machine using a raw OpenAI key today. If a future integration needs a separate scope,
> switch to `CLAUDE_OPENAI_KEY` and remap via the MCP config's `env` block.

After setting the var, **restart PowerShell** (and Claude Code in Step 5) so the new value is
visible to processes launched from there.

Verify:
```powershell
[Environment]::GetEnvironmentVariable("OPENAI_API_KEY", "User")
```

---

## Step 3 — MCP Server Choice

**Recommended:** [`@jezweb/openai-mcp`](https://github.com/jezweb/openai-mcp)

- MIT-licensed, actively maintained
- One server, both capabilities (chat completion + image generation)
- Runs via `npx` — no global install required

**Alternatives** (skip unless you have a reason):

- [`@mzxrai/mcp-openai`](https://github.com/mzxrai/mcp-openai) — chat only, no images
- [`Garoth/dalle-mcp`](https://github.com/Garoth/dalle-mcp) — images only

---

## Step 4 — Register the MCP Server with Claude Code

User-scope is the right scope here — the integration should be available in every repo, not
just working-docs.

### Option A — Claude Code CLI (preferred)

```powershell
claude mcp add openai --scope user -- npx -y @jezweb/openai-mcp@latest
```

The `--` separator is important: everything after it is the command Claude Code will run for
the server.

### Option B — Edit `~/.claude/settings.json` manually

If the CLI doesn't cooperate, edit `C:\Users\<you>\.claude\settings.json` and merge in:

```json
{
  "mcpServers": {
    "openai": {
      "command": "npx",
      "args": ["-y", "@jezweb/openai-mcp@latest"],
      "env": {
        "OPENAI_API_KEY": "${OPENAI_API_KEY}"
      }
    }
  }
}
```

`${OPENAI_API_KEY}` expands the env var from Step 2. Prefer the env-var path so the key never
ends up on disk inside `settings.json`.

> **Approval gate.** Per `documentation/assistants/claude.md`, modifying `.claude/settings.json`
> is "Always Ask Before Doing" for an LLM assistant. If Claude Code is doing this for you, it
> must show the diff and wait for your approval before writing.

---

## Step 5 — Restart Claude Code

Registration only takes effect on a fresh session. Exit any current session and launch a new
one. (This is also when the env var from Step 2 becomes visible to Claude Code if you set it in
the same session.)

---

## Step 6 — Smoke Test

In the new Claude Code session, ask:

> List the MCP tools available from the openai server.

Expected: tool names along the lines of `mcp__openai__chat_completion`,
`mcp__openai__create_image` (exact names depend on the server's exposed surface). If the
server isn't loaded, those tools will be missing entirely.

Then test each capability:

- **Chat:** "Ask GPT-4o to summarize the differences between gpt-image-1 and DALL·E 3 in one
  paragraph." Claude should invoke the chat tool and return GPT's response.
- **Image:** "Generate a 1024×1024 image of a dramatic War Room poster for a PBI titled
  'Product Search Component' and save it to a temp path." Claude should invoke the image tool
  and produce a file path.

---

## Gotchas

- **Restart Claude Code after env-var changes.** User-scope env vars don't propagate into
  already-running processes.
- **Image-model deprecation watch:** DALL·E 3 is being retired on **2026-05-12** (just days
  from this doc's authoring). Use `gpt-image-1` (or `gpt-image-1-mini`) from the start. The
  jezweb server supports both — bias prompts toward `gpt-image-1`.
- **Node.js path issues on Windows:** if `npx` isn't found, confirm Node's installer added it
  to your **User** PATH (not just System), and restart PowerShell.
- **API-key permission scopes:** default "All" is fine. If you created a restricted key,
  ensure **Chat completion** and **Image generation** are both enabled.
- **Rate limits:** OpenAI's standard tier limits chat and image calls per minute. For
  occasional poster generation, you'll never hit them. Heavy batch use may.
- **Cost awareness:** image generation is per-image priced. Check
  https://openai.com/api/pricing/ for current rates before generating in bulk.

---

## After Setup

When the smoke tests pass, this doc becomes a reference for future Claude Code sessions —
the OpenAI MCP is part of the environment.

Follow-ups worth considering once setup is stable:

- Author `documentation/skills/external-services/openai-mcp-usage.md` describing *usage*
  conventions (preferred prompts, where to save generated posters, how to capture the prompt
  alongside the image, model choice for different artifact types).
- Once the War Room aesthetic process is refined (poster-conventions, persona-conventions),
  reference the OpenAI MCP from those convention files as the recommended generation surface.
- Add a lazy-load row in `documentation/assistants/claude.md` pointing at the usage skill once
  it exists, so Claude knows to load it when the task involves OpenAI tools.
