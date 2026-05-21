# Claude Code Instructions — Working-Docs

> **This file is the Claude Code entry point.** It is Claude-specific — ChatGPT uses
> `documentation/assistants/chatgpt-instructions.md`, GitHub Copilot IDE uses
> `documentation/assistants/copilot-instructions.md`, GitHub Copilot CLI uses
> `documentation/assistants/copilot-cli.md`, and Codex uses
> `documentation/assistants/codex.md`. Shared conventions that apply to all current and future
> LLM tools live under `documentation/skills/`.
>
> Claude Code does not auto-discover this file from the repo root. Load it explicitly at session
> start with: *"Read `documentation/assistants/claude.md`."*

## Project Overview

Working-Docs is the personal / team working repository for Justin Pope at BuildOnTechnologies.
Unlike code repos (e.g., VeoDesignStudio), this repo holds notes, artifacts, and supporting
material rather than a deployable application.

Typical contents:

- **Meeting notes** — `Meeting Notes/`
- **Story notes** — `Story Notes/` (notes about ADO PBIs, often paired with War Room artifacts)
- **AI-Content** — `AI-Content/` (images, posters, generated artifacts produced with ChatGPT, DALL·E, etc.)
- **War Room artifacts** — PBI creation War Room posters, persona work, refinement output
- **Diagrams** — `diagrams/`
- **SQL Compare reports** — `SQLCompareReports/`
- **Reference / scratch** — `RedGate/`, `random code/`, `ZeroToMastery/`, `AngularTutorial/`, `OperationFaceLift/`, etc.

**Branching model: single branch.** All work happens directly on `main`. There are no feature
branches, no pull requests, and no merge workflow. Pushes exist solely to persist work to GitHub
and view diffs. Commits do not require an ADO story ID, though they may reference one when the
work relates to a specific PBI.

---

## Reading Conventions — Lazy Load

Do not preload every convention file. Load the specific file when the current task touches that
area. This preserves context for actual work.

| When the task involves… | Load |
|---|---|
| Any change in this repo (always) | This file, plus `documentation/assistants/assistant-permissions.md` |
| Editing any file under `documentation/assistants/` | `documentation/assistants/assistant-conventions.md` |
| Staging files for commit (`git add`) | `documentation/skills/git/add-conventions.md` |
| Authoring a commit message | `documentation/skills/git/commit-conventions.md` |
| Pushing to GitHub | `documentation/skills/git/push-conventions.md` |
| Calling OpenAI (chat completion, image generation, War Room posters) | `documentation/skills/external-services/openai-scripts.md` |
| Working with Front Line Poster Forge or its API-equivalent workflow | `documentation/skills/external-services/front-line-poster-forge.md` |

Additional rows will be added as War Room and notes conventions are authored under
`documentation/skills/`. See [Planned skills](#planned-skills) below for the current backlog.

---

## Starting Work — Default Sequence

1. **Confirm scope.** Ask the user what the change is for if it isn't obvious from context.
2. **Do the work** directly on `main`. Do not create a branch.
3. **Propose a commit** when a logical unit of work is done. Wait for explicit approval before running `git commit`.
4. **Propose a push** when the user wants the work persisted to GitHub. Each push is approved individually.

Pushes here are for persistence and diff-viewing — they do not kick off review or deployment.

---

## Critical Rules (Always Apply)

1. **Never commit without explicit user approval.** Always present staged diff + proposed commit
   message and wait for a "yes" before running `git commit`.

2. **Do not push without explicit user approval** for the specific push being requested. Approval
   applies only to that push — prior approval does not carry forward to future pushes.

3. **Work happens on `main`.** Do not create a branch in this repo. Working-Docs is single-branch
   by design — pushes exist for persistence and diff-viewing, not for review or merge.

4. **Commit message format:**
   ```
   <Short imperative description>

   - Bullet for each logical change (optional for trivial edits)
   - Explain the why when the what isn't obvious

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
   For changes that relate to a specific ADO story, lead the subject with `#<storyId>` (mirroring
   the VeoDesignStudio convention) so the commit cross-references cleanly.

---

## Claude Co-author Trailer

When Claude Code assists with a commit, append the following trailer to the commit message:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Claude-Specific Tooling

### Memory system

Claude Code's file-based memory for this repo lives at:

```
C:\Users\justinpo\.claude\projects\C--github-botdevjustinpope-working-docs\memory\
```

Use it to persist user preferences, feedback, and project context across sessions, per the
auto-memory guidance in the system prompt.

### MCP servers

Use any configured MCP servers (Figma, etc.) when the task references their domain. Do not
authenticate to a new MCP server without confirming with the user first.

### Azure DevOps access (PAT)

When a task needs to read or query Azure DevOps work items (sprint pulls, PBI lookups for War
Room posters, kickoff flows, etc.), authenticate using a Personal Access Token (PAT) from the
**User-scope** environment variable:

```
CLAUDE_ADO_PAT
```

This mirrors the existing `CLAUDE_openAPI_security_key` convention — all repo-owned secrets
Claude consumes are prefixed `CLAUDE_` and live at User scope. Defaults:

- **Org:** `https://dev.azure.com/BuildonTechnologies`
- **Project:** `VeoDesignStudio`

**Setup (one-time, by the user):**

```powershell
[Environment]::SetEnvironmentVariable('CLAUDE_ADO_PAT', '<pat-value>', 'User')
# Restart PowerShell so new processes inherit the value.
```

PAT scopes needed depend on the task — for War Room poster and kickoff workflows, **Work Items:
Read** is sufficient.

**Usage from PowerShell (REST) — preferred path:**

```powershell
$pat = $env:CLAUDE_ADO_PAT
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{ Authorization = "Basic $auth" }
Invoke-RestMethod -Headers $headers `
    -Uri "https://dev.azure.com/BuildonTechnologies/VeoDesignStudio/_apis/wit/workitems/<id>?api-version=7.1"
```

**Usage from `az` CLI (alternative):**

The `az devops` extension reads from the env var `AZURE_DEVOPS_EXT_PAT`, not `CLAUDE_ADO_PAT`.
Bridge them per-invocation only — don't permanently duplicate the secret:

```powershell
$env:AZURE_DEVOPS_EXT_PAT = $env:CLAUDE_ADO_PAT  # process-scope only
az boards query --org "https://dev.azure.com/BuildonTechnologies" --project "VeoDesignStudio" --wiql "..."
```

If `az devops` isn't installed, install with `az extension add --name azure-devops`. On a machine
where the extension auto-install fails (Windows pip error `3221225477` /
`STATUS_ACCESS_VIOLATION`), run that command once from an elevated shell.

**Rules:**

- **Never print, echo, or interpolate the PAT value into stdout, files, or commit content.** The
  auto-mode classifier will block commands that leak the value; this is intentional. Pass the PAT
  via the env var directly to whatever tool consumes it.
- **Do not commit the PAT** to any file in the repo (`config/*.json`, scripts, sidecars, etc.).
- If the PAT needs to rotate, just update the User-scope env var — no code change required.

When ADO connectivity is needed and `CLAUDE_ADO_PAT` is not yet set in the current session
(check with `[Environment]::GetEnvironmentVariable('CLAUDE_ADO_PAT','User')` — length only, never
the value), tell the user; do not attempt to scrape the ADO web UI as a workaround.

---

## Permissions

Shared permissions for any LLM assistant in this repo live in
[`assistant-permissions.md`](assistant-permissions.md). They apply to Claude Code in full — do
not duplicate them here.

### Claude-specific additions — Authorized Without Asking

- Use the memory system above to persist user preferences and project context.
- Use TaskCreate / TaskUpdate to track multi-step work within a session.

### Claude-specific additions — Always Ask Before Doing

- Modifying `.claude/settings.json`, hooks, or any other Claude Code harness configuration.

---

## Planned skills

The following shared convention files are reserved for upcoming work on the War Room aesthetic
process and the broader notes/artifacts workflow. They do not yet exist; lazy-load rows will be
added to the table above once each file is authored.

- `documentation/skills/war-room/poster-conventions.md` — how to commission, name, and file a PBI creation War Room poster.
- `documentation/skills/personas/persona-conventions.md` — how to write and file a personnel persona used in War Room and refinement.
- `documentation/skills/notes/story-notes-conventions.md` — how to file notes for a specific ADO PBI / story.
- `documentation/skills/notes/meeting-notes-conventions.md` — how to file meeting notes.
- `documentation/skills/ai-content/ai-content-conventions.md` — how to file AI-generated imagery and preserve prompts.

When one of these is authored, follow the propagation workflow in
[`assistant-conventions.md`](assistant-conventions.md) so the corresponding assistant entry
points get updated in the same change.
