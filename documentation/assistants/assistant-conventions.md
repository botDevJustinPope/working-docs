# Assistant File Conventions — Working-Docs

How to keep the per-assistant entry points in `documentation/assistants/` consistent with each
other so every LLM tool the team uses (Claude Code, ChatGPT, GitHub Copilot, future tools) sees
the same shared rules and the same shared convention pointers.

This file is **mandatory reading before editing any file in `documentation/assistants/`.** If you
update only one assistant's entry point, the others silently diverge and the team gets
inconsistent behavior depending on which tool is in use.

This convention is modeled on the equivalent file in the VeoDesignStudio repo
(`documentation/assistants/assistant-conventions.md` over there), adapted for Working-Docs's
notes-and-artifacts focus and a three-assistant lineup (Claude Code, ChatGPT, Copilot).

---

## Files in Scope

| File | Purpose | Format |
|---|---|---|
| [`claude.md`](claude.md) | Claude Code entry point | Lazy-load table — file pointers loaded on demand by topic |
| [`chatgpt-instructions.md`](chatgpt-instructions.md) | ChatGPT entry point | Front-loaded conventions — ChatGPT cannot lazy-load from disk, so rules are inlined |
| [`copilot-instructions.md`](copilot-instructions.md) | GitHub Copilot entry point | "Required Reading — Load at Session Start" — categorized lists of skill files, all enumerated up front |
| [`assistant-permissions.md`](assistant-permissions.md) | Shared permissions for any LLM assistant | Single shared file referenced from all three entry points |
| Future: `gemini.md` / etc. | New tool entry points | Match the convention closest to the tool's native loading model |

The three current entry points use different structural formats on purpose:

- **Claude** lazy-loads to preserve context (it can fetch convention files on demand).
- **ChatGPT** front-loads inline because it has no on-demand-load mechanism — it generally has
  only what's pasted into the conversation or saved into a Custom GPT system prompt.
- **Copilot** front-loads pointers in a "Required Reading" list. Copilot can read files in the
  workspace, but the convention is to enumerate them up front so the model sees them at session
  start rather than relying on a Claude-style lazy-load discipline it doesn't enforce.

**Translate the change into each file's format; do not copy-paste verbatim.**

---

## What Propagates (Always)

Any change in this list must land in **every** assistant entry point in the same edit:

- **Critical Rules.** Commit approval, push approval, single-branch policy, commit-message
  format. These are non-negotiable team rules — they cannot diverge by tool.
- **Project overview / typical contents.** All entry points should describe Working-Docs the
  same way.
- **Convention-file references** for new shared files added under `documentation/skills/`. If
  one entry point knows about a convention, the others must know too. The *form* differs:
  - `claude.md` → as a row in the lazy-load table, paired with the trigger condition.
  - `chatgpt-instructions.md` → as an inlined section in the "Working-Docs Conventions —
    Front-Loaded" area, summarizing the rules so ChatGPT can act on them without filesystem
    access.
  - `copilot-instructions.md` → as a bullet under the appropriate `### <Category>` heading
    inside the **Required Reading — Load at Session Start** section. Add a new heading if the
    file does not fit any existing category.
- **Pointer to `assistant-permissions.md`.**
- **Pointer to this file.**

---

## What Does NOT Propagate (Tool-Specific)

These are deliberately per-assistant and **must not be copied across**:

| Concern | Tool-specific value |
|---|---|
| Co-author trailer | `Co-Authored-By: Claude <noreply@anthropic.com>` vs `Co-authored-by: ChatGPT <noreply@openai.com>` vs `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` |
| Memory-system reference | Only Claude has the file-based memory at `~/.claude/projects/...` |
| MCP server references | Tool-specific surface |
| Loading-model commentary | "Lazy-load" language is Claude-specific; "front-loaded inline" is ChatGPT-specific; "Required Reading — Load at Session Start" is Copilot-specific |
| `Always Ask Before Doing` items that name a tool's harness | E.g., `.claude/settings.json` is Claude-only |
| Whether the tool can directly execute git / shell commands | Claude Code can; Copilot can in some contexts; ChatGPT generally cannot — the rules are framed accordingly |

If you find yourself writing a tool name (Claude / ChatGPT / Copilot / Gemini / …) into a shared
rule, stop and reconsider — either the rule belongs in the tool's own entry point, or the rule
needs to be reworded to be tool-agnostic.

---

## Workflow — When You Are About to Edit an Assistant File

1. **Read this file** (you may already have, courtesy of the lazy-load entry).
2. Decide which bucket the change is in: *propagates* or *tool-specific*.
3. If it propagates:
   - Edit `claude.md` (add a lazy-load row, update a Critical Rule, etc.).
   - Edit `chatgpt-instructions.md` in the *same turn*, translating the change to its
     front-loaded format (i.e., inline the substance of the new convention rather than just
     adding a pointer).
   - Edit `copilot-instructions.md` in the *same turn*, adding a bullet to the appropriate
     Required-Reading category.
   - Repeat for any other future assistant entry point present in the folder.
4. If it is tool-specific, edit only the relevant file. Add a comment in the change noting *why*
   it's tool-specific so a future reviewer doesn't mistake it for a missed propagation.
5. When propagating a new shared `documentation/skills/...` file, also confirm the file itself
   exists at the path you are pointing to before adding the entry — broken pointers in any entry
   point are worse than a missing entry.

---

## Self-Audit (Quick)

When in doubt about whether the entry points are in sync, run this mental check:

1. Open `claude.md`, `chatgpt-instructions.md`, and `copilot-instructions.md` side by side.
2. For every `documentation/skills/...` pointer in `claude.md`'s lazy-load table, find the
   corresponding inlined section in `chatgpt-instructions.md` and the corresponding bullet in
   `copilot-instructions.md`'s Required Reading.
3. For every Required-Reading bullet in `copilot-instructions.md`, find the corresponding
   lazy-load row in `claude.md` and inlined section in `chatgpt-instructions.md`.
4. Cross-check the Critical Rules across all three — phrasing can differ, intent must not.

If anything is missing in any file, fix it as a small, dedicated change.

---

## What This File Does NOT Cover

- **The content of any specific shared convention** — see the file the entry points point to under
  `documentation/skills/...` (war-room, personas, notes, ai-content, etc.).
- **Permissions** — see [`assistant-permissions.md`](assistant-permissions.md).
- **Tool installation, IDE setup, or harness configuration** — those are the assistant tool's own
  docs, not this repo's concern.

---

## Changelog

- **2026-05-08** — Initial draft. Translated from the VeoDesignStudio assistant-conventions
  pattern for the Working-Docs notes-and-artifacts repository, with the second entry point being
  ChatGPT (front-loaded) instead of GitHub Copilot.
- **2026-05-08** — Added the GitHub Copilot entry point as a third stubbed assistant
  (`copilot-instructions.md`). Updated Files in Scope, propagation rules, self-audit, and
  what-does-not-propagate to cover three entry points instead of two.
