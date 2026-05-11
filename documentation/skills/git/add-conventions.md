# Staging (`git add`) Conventions — Working-Docs

> **Authorized without asking.** Staging files is allowed without per-action approval (see
> [`../../assistants/assistant-permissions.md`](../../assistants/assistant-permissions.md)).
> This file covers *what to stage* and *what not to stage* once you're preparing a commit.

## Default Posture

- Stage **only** files that are part of the change the user agreed to.
- Use explicit paths (`git add <file>`) rather than wildcard staging (`git add .`,
  `git add -A`) so untracked files don't get pulled in by accident. Working-Docs has many
  intentionally untracked drafts and scratch artifacts; a wildcard add can sweep them into a
  commit silently.
- Always run `git status` after staging and **before** proposing the commit to the user, so the
  proposed commit message and the actual staged diff line up.

---

## What NOT to Stage

- **Tool-harness directories.** `.claude/`, `.copilot-tmp/`, `.claude-tmp/`, or any future
  per-developer LLM-tool state. These contain permission grants, scratch files, and IDE/session
  config — they belong in `.gitignore` and must never be committed. If one appears in the working
  tree, remove it (or add it to `.gitignore` first) before proposing a commit.
- **Secrets / credentials.** PATs, API keys, connection strings, OAuth tokens — never. Even in
  AI-Content, scratch folders, or notes that "won't go anywhere." Pushed history is exposed
  history.
- **Untracked drafts the user did not ask to include.** Working-Docs accumulates working notes
  that aren't ready to commit. When `git status` shows untracked files outside the agreed scope,
  ask the user whether they're in or out of this commit before staging them.
- **Large binaries that aren't artifacts.** Intermediate exports, downloaded reference material,
  sample files — confirm with the user before staging.

---

## Workflow

1. Identify the files the user authorized for the change.
2. Stage them by explicit path: `git add path\to\file1 path\to\file2`.
3. Run `git status` and review the staged set.
4. If anything unexpected appears (untracked drafts, harness dirs, etc.), pause and ask.
5. Proceed to the commit step (see [`commit-conventions.md`](commit-conventions.md)).

---

## What NOT to Do

- Don't use `git add .` or `git add -A` as a default — too easy to sweep in unintended files in
  a notes-and-artifacts repo.
- Don't stage files outside the agreed scope of the change without asking first.
- Don't restage a file the user removed from the staging set on purpose without confirming why
  it should go back in.
