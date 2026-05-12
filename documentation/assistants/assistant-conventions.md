# Assistant File Conventions — Working-Docs

How to keep the per-assistant entry points in `documentation/assistants/` consistent with each
other so every LLM tool the team uses (Claude Code, ChatGPT, GitHub Copilot, Codex, future
tools) sees the same shared rules and the same shared convention pointers.

This file is **mandatory reading before editing any file in `documentation/assistants/`.** If you
update only one assistant's entry point, the others silently diverge and the team gets
inconsistent behavior depending on which tool is in use.

This convention is modeled on the equivalent file in the VeoDesignStudio repo
(`documentation/assistants/assistant-conventions.md` over there), adapted for Working-Docs's
notes-and-artifacts focus and a five-assistant lineup (Claude Code, ChatGPT, Copilot IDE,
Copilot CLI, Codex).

---

## Files in Scope

| File | Purpose | Format |
|---|---|---|
| [`claude.md`](claude.md) | Claude Code entry point | Lazy-load table — file pointers loaded on demand by topic |
| [`chatgpt-instructions.md`](chatgpt-instructions.md) | ChatGPT entry point | Front-loaded conventions — ChatGPT cannot lazy-load from disk, so rules are inlined |
| [`copilot-instructions.md`](copilot-instructions.md) | GitHub Copilot IDE entry point | "Required Reading — Load at Session Start" — categorized lists of skill files, all enumerated up front |
| [`copilot-cli.md`](copilot-cli.md) | GitHub Copilot CLI entry point | Lazy-load table — file pointers loaded on demand by topic, plus Copilot CLI tooling notes |
| [`codex.md`](codex.md) | Codex entry point | Lazy-load table — file pointers loaded on demand by topic, plus Codex harness notes |
| [`assistant-permissions.md`](assistant-permissions.md) | Shared permissions for any LLM assistant | Single shared file referenced from every assistant entry point |
| Future: `gemini.md` / etc. | New tool entry points | Match the convention closest to the tool's native loading model |

The current entry points use different structural formats on purpose:

- **Claude** lazy-loads to preserve context (it can fetch convention files on demand).
- **ChatGPT** front-loads inline because it has no on-demand-load mechanism — it generally has
  only what's pasted into the conversation or saved into a Custom GPT system prompt.
- **Copilot IDE** front-loads pointers in a "Required Reading" list. Copilot IDE can read files
  in the workspace, but the convention is to enumerate them up front so the model sees them at
  session start rather than relying on a Claude-style lazy-load discipline it doesn't enforce.
- **Copilot CLI** lazy-loads like Claude, with extra tooling notes for shell, session state,
  MCP integration, and Windows path conventions.
- **Codex** lazy-loads like Claude, with extra harness-specific notes for shell, patching, and
  approval behavior.

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
  - `codex.md` → as a row in the lazy-load table, paired with the trigger condition.
- **Pointer to `assistant-permissions.md`.**
- **Pointer to this file.**

---

## What Does NOT Propagate (Tool-Specific)

These are deliberately per-assistant and **must not be copied across**:

| Concern | Tool-specific value |
|---|---|
| Co-author trailer | `Co-Authored-By: Claude <noreply@anthropic.com>` vs `Co-authored-by: ChatGPT <noreply@openai.com>` vs `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` (IDE) vs `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` (CLI) vs `Co-authored-by: Codex <noreply@openai.com>` |
| Memory-system reference | Only Claude has the file-based memory at `~/.claude/projects/...` |
| MCP server references | Tool-specific surface; Copilot CLI has GitHub MCP, Claude has configured MCP servers |
| Session-state reference | Only Copilot CLI has the per-session SQLite database at `~/.copilot/session-state/` |
| Loading-model commentary | Lazy-load language is Claude/Codex/Copilot-CLI-specific; "front-loaded inline" is ChatGPT-specific; "Required Reading — Load at Session Start" is Copilot-IDE-specific |
| `Always Ask Before Doing` items that name a tool's harness | E.g., `.claude/settings.json` is Claude-only; `.github/copilot-instructions.md` note is Copilot-CLI-only |
| Whether the tool can directly execute git / shell commands | Claude Code, Codex, and Copilot CLI can; Copilot IDE can in some contexts; ChatGPT generally cannot — the rules are framed accordingly |

If you find yourself writing a tool name (Claude / ChatGPT / Copilot / Codex / Gemini / …) into a shared
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
   - Edit `copilot-cli.md` in the *same turn*, adding a lazy-load row or updating the matching
     shared rule.
   - Edit `codex.md` in the *same turn*, adding a lazy-load row or updating the matching shared
     rule.
   - Repeat for any other future assistant entry point present in the folder.
4. If it is tool-specific, edit only the relevant file. Add a comment in the change noting *why*
   it's tool-specific so a future reviewer doesn't mistake it for a missed propagation.
5. When propagating a new shared `documentation/skills/...` file, also confirm the file itself
   exists at the path you are pointing to before adding the entry — broken pointers in any entry
   point are worse than a missing entry.

---

## Self-Audit (Quick)

When in doubt about whether the entry points are in sync, run this mental check:

1. Open `claude.md`, `chatgpt-instructions.md`, `copilot-instructions.md`, `copilot-cli.md`, and `codex.md` side by side.
2. For every `documentation/skills/...` pointer in `claude.md`'s lazy-load table, find the
   corresponding inlined section in `chatgpt-instructions.md`, the corresponding bullet in
   `copilot-instructions.md`'s Required Reading, the corresponding lazy-load row in
   `copilot-cli.md`, and the corresponding lazy-load row in `codex.md`.
3. For every Required-Reading bullet in `copilot-instructions.md`, find the corresponding
   lazy-load row in `claude.md`, inlined section in `chatgpt-instructions.md`, lazy-load row
   in `copilot-cli.md`, and lazy-load row in `codex.md`.
4. Cross-check the Critical Rules across all current entry points — phrasing can differ, intent
   must not.

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
- **2026-05-11** — Added the Codex entry point (`codex.md`) and updated the assistant file
  convention workflow to keep Codex aligned with Claude, ChatGPT, and Copilot.
- **2026-05-12** — Added the GitHub Copilot CLI entry point (`copilot-cli.md`) and root pointer
  stub (`COPILOT.md`). Clarified that `copilot-instructions.md` is for Copilot IDE and
  `copilot-cli.md` is for Copilot CLI (terminal). Updated Files in Scope, loading-model
  commentary, What Does NOT Propagate, propagation workflow, and self-audit for five assistants.
