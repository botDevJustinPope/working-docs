# GitHub Copilot CLI Instructions — Working-Docs

> **This is a pointer stub.** The canonical GitHub Copilot CLI instructions for this repo live at
> **[`documentation/assistants/copilot-cli.md`](documentation/assistants/copilot-cli.md)**.
>
> Shared conventions that also apply to other LLM tools live under
> `documentation/skills/` and are referenced from each assistant's entry point.

## Load this file first

At the start of every session in this repo, read:

- `documentation/assistants/copilot-cli.md` — Copilot CLI entry point, lazy-load table, permissions, and co-author trailer

Then load specific convention files from `documentation/skills/` on demand, based on the lazy-load
table in the entry point — only when the current task touches that area.

## Critical rules (fallback summary)

If the full entry point cannot be loaded, these are the non-negotiable guardrails:

1. **Never commit without explicit user approval.** Present the staged diff and proposed commit message, then wait for "yes."
2. **Do not push without explicit user approval** for the specific push being requested. Prior approval does not carry forward to future pushes.
3. **Work happens on `main`.** This repo is single-branch by design — do not create branches or PRs. Pushes exist for persistence and diff-viewing only.
4. **Commit message format:** short imperative subject line, optional bullets explaining the why, plus the Copilot co-author trailer `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`.
