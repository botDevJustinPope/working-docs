# Codex Instructions - Working-Docs

> **This file is the Codex entry point.** It is Codex-specific - Claude Code uses
> `documentation/assistants/claude.md`, ChatGPT uses
> `documentation/assistants/chatgpt-instructions.md`, and GitHub Copilot uses
> `documentation/assistants/copilot-instructions.md`. Shared conventions that apply to all
> current and future LLM tools live under `documentation/skills/`.
>
> Load this file explicitly at session start with: *"Read
> `documentation/assistants/codex.md`."*

## Project Overview

Working-Docs is the personal / team working repository for Justin Pope at BuildOnTechnologies.
Unlike code repos (e.g., VeoDesignStudio), this repo holds notes, artifacts, and supporting
material rather than a deployable application.

Typical contents:

- **Meeting notes** - `Meeting Notes/`
- **Story notes** - `Story Notes/` (notes about ADO PBIs, often paired with War Room artifacts)
- **AI-Content** - `AI-Content/` (images, posters, generated artifacts produced with ChatGPT,
  DALL-E, etc.)
- **War Room artifacts** - PBI creation War Room posters, persona work, refinement output
- **Diagrams** - `diagrams/`
- **SQL Compare reports** - `SQLCompareReports/`
- **Reference / scratch** - `RedGate/`, `random code/`, `ZeroToMastery/`, `AngularTutorial/`,
  `OperationFaceLift/`, etc.

**Branching model: single branch.** All work happens directly on `main`. There are no feature
branches, no pull requests, and no merge workflow. Pushes exist solely to persist work to GitHub
and view diffs. Commits do not require an ADO story ID, though they may reference one when the
work relates to a specific PBI.

---

## Reading Conventions - Lazy Load

Do not preload every convention file. Load the specific file when the current task touches that
area. This preserves context for actual work.

| When the task involves... | Load |
|---|---|
| Any change in this repo (always) | This file, plus `documentation/assistants/assistant-permissions.md` |
| Editing any file under `documentation/assistants/` | `documentation/assistants/assistant-conventions.md` |
| Staging files for commit (`git add`) | `documentation/skills/git/add-conventions.md` |
| Authoring a commit message | `documentation/skills/git/commit-conventions.md` |
| Pushing to GitHub | `documentation/skills/git/push-conventions.md` |
| Calling OpenAI (chat completion, image generation, War Room posters) | `documentation/skills/external-services/openai-scripts.md` |

Additional rows will be added as War Room and notes conventions are authored under
`documentation/skills/`. See [Planned skills](#planned-skills) below for the current backlog.

---

## Starting Work - Default Sequence

1. **Confirm scope.** Ask the user what the change is for if it is not obvious from context.
2. **Inspect first.** Read the relevant notes, convention files, and nearby examples before
   changing files.
3. **Do the work** directly on `main`. Do not create a branch.
4. **Propose a commit** when a logical unit of work is done. Wait for explicit approval before
   running `git commit`.
5. **Propose a push** when the user wants the work persisted to GitHub. Each push is approved
   individually.

Pushes here are for persistence and diff-viewing - they do not kick off review or deployment.

---

## Critical Rules (Always Apply)

1. **Never commit without explicit user approval.** Always present staged diff + proposed commit
   message and wait for a "yes" before running `git commit`.

2. **Do not push without explicit user approval** for the specific push being requested. Approval
   applies only to that push - prior approval does not carry forward to future pushes.

3. **Work happens on `main`.** Do not create a branch in this repo. Working-Docs is single-branch
   by design - pushes exist for persistence and diff-viewing, not for review or merge.

4. **Commit message format:**
   ```text
   <Short imperative description>

   - Bullet for each logical change (optional for trivial edits)
   - Explain the why when the what isn't obvious

   Co-authored-by: Codex <noreply@openai.com>
   ```
   For changes that relate to a specific ADO story, lead the subject with `#<storyId>` so the
   commit cross-references cleanly.

---

## Codex Co-author Trailer

When Codex meaningfully assists with a commit, append the following trailer to the commit
message:

```text
Co-authored-by: Codex <noreply@openai.com>
```

---

## Codex-Specific Tooling

### Workspace and shell

- Use PowerShell from the repository root unless the user asks for a different shell.
- Prefer `rg` / `rg --files` for search and file discovery.
- Use `apply_patch` for manual text edits so changes stay reviewable.
- Respect any sandbox or approval prompts from the Codex harness. If a command needs network,
  filesystem access outside the workspace, GUI access, or another privileged operation, ask
  through the harness approval flow.

### Repo-local external services

OpenAI calls for repo artifacts should go through the PowerShell scripts under `scripts/openai/`
when that path is available and the user has authorized the service call. Load
`documentation/skills/external-services/openai-scripts.md` before proposing or running those
commands.

### Codex harness configuration

Do not modify Codex harness files, `$CODEX_HOME`, local skills, plugins, or approval settings
unless the user explicitly asks for that configuration work.

---

## Permissions

Shared permissions for any LLM assistant in this repo live in
[`assistant-permissions.md`](assistant-permissions.md). They apply to Codex in full - do not
duplicate them here.

### Codex-specific additions - Authorized Without Asking

- Run read-only workspace inspection commands needed to understand the current task.
- Keep a lightweight task plan for multi-step edits when it helps track progress.

### Codex-specific additions - Always Ask Before Doing

- Changing Codex harness configuration, installed skills, plugins, or approval policy.
- Running commands that require network access or write outside the workspace unless the user has
  already authorized that exact domain of work.

---

## Planned Skills

The following shared convention files are reserved for upcoming work on the War Room aesthetic
process and the broader notes/artifacts workflow. They do not yet exist; lazy-load rows will be
added to the table above once each file is authored.

- `documentation/skills/war-room/poster-conventions.md` - how to commission, name, and file a PBI creation War Room poster.
- `documentation/skills/personas/persona-conventions.md` - how to write and file a personnel persona used in War Room and refinement.
- `documentation/skills/notes/story-notes-conventions.md` - how to file notes for a specific ADO PBI / story.
- `documentation/skills/notes/meeting-notes-conventions.md` - how to file meeting notes.
- `documentation/skills/ai-content/ai-content-conventions.md` - how to file AI-generated imagery and preserve prompts.

When one of these is authored, follow the propagation workflow in
[`assistant-conventions.md`](assistant-conventions.md) so all assistant entry points stay aligned.
