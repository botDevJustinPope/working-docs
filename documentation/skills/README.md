# Working-Docs Skills (Shared Conventions)

This directory holds shared convention files that apply across all LLM assistants used in this
repo (Claude Code, ChatGPT, GitHub Copilot, future tools).

Each file describes how a recurring kind of artifact in Working-Docs should be created, named,
filed, and cross-referenced.

The entry points in `documentation/assistants/` reference these files:

- `claude.md` references them in its **lazy-load table** — Claude loads each file only when the
  current task touches that area.
- `chatgpt-instructions.md` inlines the substance of each convention — ChatGPT cannot lazy-load
  from disk, so the rules themselves are summarized in its entry point.
- `copilot-instructions.md` lists them under **Required Reading — Load at Session Start** so
  Copilot picks them up at the start of every session.

When adding a new convention file here, follow the propagation workflow in
[`../assistants/assistant-conventions.md`](../assistants/assistant-conventions.md).

---

## Current Convention Files

| File | Purpose |
|---|---|
| `git/add-conventions.md` | What to stage and what not to stage; scope discipline |
| `git/commit-conventions.md` | Commit message format, scope rules, co-author trailer guidance |
| `git/push-conventions.md` | Per-push approval, persistence/diff-viewing purpose, force-push prohibition |
| `external-services/openai-scripts.md` | How to invoke `scripts/openai/` (chat completion, image generation, War Room poster wrapper) |

---

## Planned Convention Files

The following are reserved for upcoming work on the War Room aesthetic process. None of these
files exist yet — they will be authored in dedicated efforts as the process is refined:

| File | Purpose |
|---|---|
| `war-room/poster-conventions.md` | How to commission, name, and file a PBI creation War Room poster |
| `personas/persona-conventions.md` | How to write and file a personnel persona used in War Room and refinement |
| `notes/story-notes-conventions.md` | How to file notes for a specific ADO PBI / story under `Story Notes/` |
| `notes/meeting-notes-conventions.md` | How to file meeting notes under `Meeting Notes/` |
| `ai-content/ai-content-conventions.md` | How to file AI-generated images / posters under `AI Content/` (filename, prompt preservation, cross-references) |

When a stub above is filled in, also:

1. Confirm the corresponding lazy-load row in `documentation/assistants/claude.md` points at
   the real file path (and add a row if one wasn't already drafted).
2. Inline the rules into the appropriate section of
   `documentation/assistants/chatgpt-instructions.md`.

---

## Out of Scope for `documentation/skills/`

- **Project overview** — lives in each assistant entry point.
- **Critical rules** (commit / push approval, commit format, single-branch policy) — live in
  each assistant entry point.
- **Permissions** — live in `documentation/assistants/assistant-permissions.md`.
