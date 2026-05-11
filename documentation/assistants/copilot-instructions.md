# Copilot Instructions — Working-Docs

> **This file is the GitHub Copilot entry point.** It is Copilot-specific — Claude Code uses
> `documentation/assistants/claude.md` and ChatGPT uses
> `documentation/assistants/chatgpt-instructions.md`. Shared conventions that apply to all three
> (and any future LLM tool) live under `documentation/skills/`.
>
> Copilot does not auto-discover this file from `documentation/assistants/`. To use it, either
> point Copilot at it via your Copilot configuration, or paste it into Copilot Chat at session
> start. (For workspace auto-discovery, you can mirror this file to
> `.github/copilot-instructions.md` — but keep the canonical content here so it stays in sync
> with the other entry points.)

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

## Required Reading — Load at Session Start

**At the start of every session, read and apply all of the following files before doing any
work.** These files contain conventions, rules, and permissions that govern all decisions in
this repo.

### Permissions
- `documentation/assistants/assistant-permissions.md`

### Assistant File Conventions
- `documentation/assistants/assistant-conventions.md` — required reading before editing any file in `documentation/assistants/`

### Git Workflow
- `documentation/skills/git/add-conventions.md`
- `documentation/skills/git/commit-conventions.md`
- `documentation/skills/git/push-conventions.md`

### External Services
- `documentation/skills/external-services/openai-scripts.md` — how to invoke `scripts/openai/` (chat completion, image generation, War Room poster wrapper)

### Shared Skills Index
- `documentation/skills/README.md` — index of shared conventions. Specific files will be added as the War Room and notes conventions are authored; once they exist, list them here under matching `### <Category>` headings.

---

## Starting Work — Default Sequence

1. **Confirm scope.** Ask the user what the change is for if it isn't obvious from context.
2. **Do the work** directly on `main`. Do not create a branch.
3. **Propose a commit** when a logical unit of work is done. Wait for explicit approval before running `git commit`.
4. **Propose a push** when the user wants the work persisted to GitHub. Each push is approved individually.

Pushes here are for persistence and diff-viewing — they do not kick off review or deployment.

---

## Critical Rules (Always Apply)

The full rules are in the assistant entry point and skill files above. These are the most
important guardrails:

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

## Copilot Co-author Trailer

When Copilot assists with a commit, append the following trailer to the commit message:

```
Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

---

## Copilot-Specific Tooling

This section is a stub for tool-scoped settings (env vars, scratch directories, MCP servers,
etc.) that are unique to Copilot's setup in this repo.

None are required at the moment because Working-Docs does not currently invoke external services
from Copilot. Add entries here as needed, mirroring the structure used in `claude.md`'s
"Claude-Specific Tooling" section.

---

## Permissions

Shared permissions for any LLM assistant in this repo live in
[`assistant-permissions.md`](assistant-permissions.md). They apply to Copilot in full — do not
duplicate them here.
