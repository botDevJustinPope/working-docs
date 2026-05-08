# Assistant Permissions — Working-Docs

This document defines what an LLM assistant is authorized to do autonomously in this repository
without asking the user first. If an action is not listed here, ask before doing it.

The default posture for Working-Docs is **light-touch and ask-when-unsure** — this repo is a mix
of personal notes, work artifacts, AI-generated content, and references. Damage from a careless
edit is harder to undo than in a code repo because there are no tests to catch it.

This repo is **single-branch.** All work happens on `main`. There are no feature branches, no
PRs, and no merge workflow. Pushes exist solely for persistence and diff-viewing.

---

## Authorized Without Asking

### File operations
- Read any file in the repository.
- Create new files needed for the current task (notes, drafts, etc.) in an appropriate location.
- Edit existing files within the scope the user has agreed to.

### Git — read-only
- `git status`, `git log`, `git diff`, `git branch`, `git show <sha>`, etc.

### Git — staging
- Stage files (`git add`) as part of preparing a commit for user approval. Do not stage files
  outside the agreed scope of the change.
- **Do not stage files under tool-harness directories** such as `.claude/`. These contain
  per-developer assistant state and belong in `.gitignore`. If one appears in the working tree,
  remove it before proposing a commit.

### Drafting
- Draft commit messages, file outlines, persona descriptions, poster prompts, etc., for the user
  to review.

---

## Always Ask Before Doing

- **Committing.** Always present the staged diff and proposed commit message and wait for an
  explicit "yes" before running `git commit`.
- **Pushing.** Approval applies only to the push being confirmed — prior approval does not carry
  forward to future pushes.
- **Creating a branch.** Working-Docs is single-branch by design — do not create branches without
  an explicit user instruction to do so (and a clear reason).
- **Deleting committed files** or removing files that are not clearly scratch / drafts the user
  authored in this session.
- **Moving or renaming files** that already exist in the repo (filenames are often referenced
  from outside — meeting links, ADO comments, ChatGPT chats — and renames break those references
  silently).
- **Destructive git operations** (`reset --hard`, `rebase`, `force push`, `branch -D`, etc.).
- **Modifying `.gitignore`** or other repo-wide configuration unless directly required by the
  current task.
- **Reorganizing top-level directories** of the repo (e.g., moving `Story Notes/` somewhere new).
- **Generating large amounts of new content** (e.g., a full new directory of generated material)
  without first confirming scope and structure with the user.
- **Calling external services** (MCP servers, web APIs, image-generation endpoints) when the task
  has not already authorized that domain — confirm first.
