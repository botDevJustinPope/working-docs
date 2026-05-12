# GitHub Copilot CLI Instructions — Working-Docs

> **This file is the GitHub Copilot CLI entry point.** It is Copilot-CLI-specific — Claude Code
> uses `documentation/assistants/claude.md`, ChatGPT uses
> `documentation/assistants/chatgpt-instructions.md`, GitHub Copilot IDE uses
> `documentation/assistants/copilot-instructions.md`, and Codex uses
> `documentation/assistants/codex.md`. Shared conventions that apply to all current and future
> LLM tools live under `documentation/skills/`.
>
> GitHub Copilot CLI does not auto-discover this file from the repo root. Load it explicitly at
> session start with: *"Read `documentation/assistants/copilot-cli.md`."* Or configure it as a
> custom instruction in your Copilot CLI per-repo settings pointing to `COPILOT.md` at the root,
> which re-directs here.

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

   Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
   ```
   For changes that relate to a specific ADO story, lead the subject with `#<storyId>` so the
   commit cross-references cleanly.

---

## Copilot CLI Co-author Trailer

When GitHub Copilot CLI assists with a commit, append the following trailer to the commit message:

```
Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## Copilot CLI–Specific Tooling

### Shell and workspace

- Copilot CLI operates from a Windows PowerShell context. Use Windows-style paths with
  backslashes (`\`) as the path separator.
- The working directory for this repo is `C:\GitHub\botDevJustinPope\working-docs`.
- Prefer the built-in `view`, `grep`, and `glob` tools over raw PowerShell reads when inspecting
  files. Fall back to PowerShell only when those tools cannot meet the need.
- Use `git --no-pager` for git commands that may page output.

### Session state

Copilot CLI maintains per-session state in a SQLite database at:

```
C:\Users\justinpo\.copilot\session-state\<session-id>\
```

Use the session database for tracking multi-step task progress, todo lists, and batch operations
within a session. Session state does not persist across sessions — use git commits to persist
actual work.

### GitHub MCP integration

Copilot CLI has access to GitHub MCP tools (issues, pull requests, workflow runs, code search).
Use these when the task requires GitHub API data or cross-repository research. Read-only MCP
calls are authorized without asking; write operations (creating issues, PRs, comments) require
explicit user approval.

### OpenAI scripts

When running OpenAI scripts, use PowerShell from the repo root. Full usage docs are at
`documentation/skills/external-services/openai-scripts.md`.

### Copilot CLI configuration

Do not modify `.github/copilot-instructions.md` (governs Copilot IDE, shared with team members),
`COPILOT.md` (this tool's root pointer stub), or any Copilot CLI system configuration files
unless the user explicitly asks for that configuration work.

---

## Permissions

Shared permissions for any LLM assistant in this repo live in
[`assistant-permissions.md`](assistant-permissions.md). They apply to Copilot CLI in full — do
not duplicate them here.

### Copilot CLI–specific additions — Authorized Without Asking

- Use the session database to track multi-step task progress and todo items within the session.
- Run read-only file inspection using built-in tools (`view`, `grep`, `glob`) to understand the
  current state before making changes.
- Use GitHub MCP tools for read-only operations (listing issues, searching code, reading commits,
  checking workflow runs).

### Copilot CLI–specific additions — Always Ask Before Doing

- Modifying `.github/copilot-instructions.md` — this file governs the Copilot IDE and affects
  all team members; changes propagate beyond this tool.
- Creating GitHub issues, pull requests, or public comments — these are public and persistent.
- Running scripts that call external services (OpenAI endpoints, MCP servers with write access)
  unless the user has already authorized that exact domain of work in the current session.
- Modifying Copilot CLI system configuration files (`~/.config/gh-copilot/` or equivalent).

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
