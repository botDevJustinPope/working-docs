# ChatGPT Instructions — Working-Docs

> **This file is the ChatGPT entry point.** It is ChatGPT-specific — Claude Code uses
> `documentation/assistants/claude.md` and GitHub Copilot uses
> `documentation/assistants/copilot-instructions.md`. Shared conventions that apply to all three
> (and any future LLM tool) live under `documentation/skills/`.
>
> ChatGPT does not have direct filesystem access to this repo. This file is intended to be
> **pasted into a ChatGPT conversation** at the start of work, or saved as the system instruction
> of a Custom GPT used to assist with Working-Docs tasks.
>
> Because ChatGPT cannot lazy-load files on demand, the operating rules are front-loaded here in
> full rather than referenced as separate skill files.

## Project Overview

Working-Docs is the personal / team working repository for Justin Pope at BuildOnTechnologies.
Unlike code repos (e.g., VeoDesignStudio), this repo holds notes, artifacts, and supporting
material rather than a deployable application.

Typical contents:

- **Meeting notes** — `Meeting Notes/`
- **Story notes** — `Story Notes/` (notes about ADO PBIs, often paired with War Room artifacts)
- **AI Content** — `AI Content/` (images, posters, generated artifacts produced with ChatGPT, DALL·E, etc.)
- **War Room artifacts** — PBI creation War Room posters, persona work, refinement output
- **Diagrams** — `diagrams/`
- **SQL Compare reports** — `SQLCompareReports/`
- **Reference / scratch** — `RedGate/`, `random code/`, `ZeroToMastery/`, `AngularTutorial/`, `OperationFaceLift/`, etc.

**Branching model: single branch.** All work happens directly on `main`. There are no feature
branches, no pull requests, and no merge workflow. Pushes exist solely to persist work to GitHub
and view diffs. Commits do not require an ADO story ID, though they may reference one when the
work relates to a specific PBI.

---

## How ChatGPT Operates Here

ChatGPT typically helps with this repo by:

- Drafting and refining text content (notes, posters, persona descriptions, ADO PBI descriptions).
- Generating imagery (DALL·E posters for War Room aesthetics) which is then saved into
  `AI Content/` by the user.
- Brainstorming structure for new sections of the repo before Justin authors or commits them.

ChatGPT generally does **not** execute git commands directly. When ChatGPT outputs a commit
message or other git-related artifact, it is a **proposal** that the user (or Claude Code) will
execute. The same approval gates that apply to Claude Code apply here.

---

## Critical Rules (Always Apply)

These mirror the rules that govern Claude Code in this repo so the team gets the same behavior
regardless of which LLM helped with a given step.

1. **Never produce a final commit without explicit user approval** of the staged diff and the
   proposed commit message.
2. **Do not propose a push** without confirming the specific push with the user. Approval applies
   only to that push — prior approval does not carry forward.
3. **Work happens on `main`.** Do not propose creating a branch or opening a PR. Working-Docs is
   single-branch by design — pushes exist for persistence and diff-viewing, not for review.
4. **Commit message format** (when ChatGPT is asked to draft one):
   ```
   <Short imperative description>

   - Bullet for each logical change (optional for trivial edits)
   - Explain the why when the what isn't obvious

   Co-authored-by: ChatGPT <noreply@openai.com>
   ```
   For changes that relate to a specific ADO story, lead the subject with `#<storyId>`.

---

## ChatGPT Co-author Trailer

When ChatGPT meaningfully drafted a commit, suggest the following trailer in the commit message
the user will run:

```
Co-authored-by: ChatGPT <noreply@openai.com>
```

(If a different convention is preferred — e.g., attributing a Custom GPT by name — update this
file and the corresponding entry in `assistant-conventions.md` in the same change.)

---

## Working-Docs Conventions — Front-Loaded

The following conventions apply to ChatGPT-assisted work in this repo. They are front-loaded
because ChatGPT cannot retrieve them on demand from disk. As more conventions are authored under
`documentation/skills/`, their substance will be inlined here in additional sections.

### Git workflow (add / commit / push)

The approval gates (commit, push) are in the **Critical Rules** section above. The mechanics
below apply once approval is granted.

**Staging (`git add`)**
- Stage only the files in scope for the agreed change. Use explicit paths, not `git add .` or
  `-A`.
- Never stage tool-harness directories (`.claude/`, `.copilot-tmp/`, `.claude-tmp/`), secrets,
  credentials, large non-artifact binaries, or untracked drafts the user didn't ask to include.

**Commit messages**
- Subject: short imperative line. No trailing period. Optional `#<storyId>` prefix when the
  commit relates to a specific ADO PBI (optional in this repo, not required).
- Body: `-` bullets, one concern per bullet, explain the *why* when the *what* isn't obvious.
  Body is optional for trivial edits.
- Append the assistant co-author trailer when an LLM meaningfully drafted the commit (see the
  ChatGPT trailer block above for ChatGPT-drafted commits).
- Avoid vague messages like "update" or "WIP".

**Pushes**
- Pushes here are for persistence and diff-viewing only — no review, no deploy.
- Each push is approved individually. Prior approval does not carry forward.
- Never propose a force push (`--force`, `--force-with-lease`) unless the user explicitly asks.

### Filing notes and artifacts (general guidance)

- **Meeting notes** go in `Meeting Notes/`. Filename guidance: `<YYYY-MM-DD> <subject>.md` or `.txt`.
- **Story notes** (per ADO PBI) go in `Story Notes/`. Use the PBI ID in the filename for
  cross-reference.
- **AI-generated images / posters** go in `AI Content/<topic>/`. Use descriptive filenames;
  preserve the original prompt next to the image where possible.
- **War Room PBI posters** are filed alongside the related Story Notes (or under `AI Content/`
  keyed by topic — exact convention TBD as part of the War Room refinement process).

### Personas

- Persona files describe stakeholders, roles, or characters used in War Room sessions and PBI
  refinement.
- A persona file should describe role, goals, frustrations, and the visual / aesthetic cues that
  ChatGPT should reuse when generating War Room imagery for that persona.
- Final location and filename convention will be established when
  `documentation/skills/personas/persona-conventions.md` is authored.

### War Room aesthetic process (initial scope)

This section will expand as the process is refined.

- **PBI creation War Room posters** — visually striking posters generated for each PBI to
  reinforce its identity in refinement and planning conversations.
- The poster should live next to its Story Notes in this repo.
- Personas referenced in the PBI should be cross-linked.

### Calling OpenAI from this repo

OpenAI calls (chat completion, image generation) happen via PowerShell scripts under
`scripts/openai/`, not through any LLM-tool-specific MCP integration. Since ChatGPT cannot run
shell commands, propose the exact command and the user runs it locally. Full usage docs are at
`documentation/skills/external-services/openai-scripts.md`.

Available scripts:

- `scripts/openai/Invoke-OpenAIChat.ps1 -Prompt "..."` — chat completion (default model
  `gpt-4o`). Returns the assistant message text. Optional `-System "..."`, `-Model "..."`,
  `-MaxTokens`, `-Temperature`, `-Raw`.
- `scripts/openai/New-OpenAIImage.ps1 -Prompt "..." -OutputPath "..."` — image generation
  (default model `gpt-image-1` — DALL-E 3 is retired 2026-05-12, do not request it). Saves a PNG
  to the given path. Add `-WritePromptSidecar` to write the prompt next to the image.
- `scripts/openai/New-WarRoomPoster.ps1 -PbiId <id> -Title "<title>"` — domain wrapper for PBI
  War Room posters. Saves to `AI Content/War Room Posters/PBI-<id>-<slug>.png` with a prompt
  sidecar. Optional `-StyleDirection "..."` injects extra aesthetic direction.

The scripts read the API key from User-scope env var `CLAUDE_openAPI_security_key`. Do not
include the API key in commands you propose — the scripts pick it up themselves.

---

## Planned conventions

The following shared convention files are reserved for upcoming work on the War Room aesthetic
process. They do not yet exist; the substance of each will be inlined into this file when it is
authored, per the propagation workflow in `assistant-conventions.md`.

- `documentation/skills/war-room/poster-conventions.md` — how to commission, name, and file a PBI creation War Room poster.
- `documentation/skills/personas/persona-conventions.md` — how to write and file a personnel persona used in War Room and refinement.
- `documentation/skills/notes/story-notes-conventions.md` — how to file notes for a specific ADO PBI / story.
- `documentation/skills/notes/meeting-notes-conventions.md` — how to file meeting notes.
- `documentation/skills/ai-content/ai-content-conventions.md` — how to file AI-generated imagery and preserve prompts.

---

## What This File Does NOT Cover

- Specific shared conventions in detail — those will live under `documentation/skills/` and be
  authored over time. As they are added, they will also be summarized into this file (since
  ChatGPT cannot lazy-load) by following the propagation rules in
  `documentation/assistants/assistant-conventions.md`.
- Permissions — see `documentation/assistants/assistant-permissions.md`.
- Tool installation, account setup, or harness configuration — out of scope for this repo.
