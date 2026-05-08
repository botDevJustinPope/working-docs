# Push Conventions — Working-Docs

> **Approval gate.** Never push without explicit user approval for the specific push being
> requested — prior approval does not carry forward. See
> [`../../assistants/assistant-permissions.md`](../../assistants/assistant-permissions.md). This
> file covers the *purpose* of pushes in this repo and the mechanics around them.

## Why Pushes Exist Here

This repo is single-branch (`main`) and has no PRs, no merge workflow, and no CI/CD. Pushes
serve two purposes only:

1. **Persistence** — get the local commit onto GitHub so it isn't lost if the working machine
   does.
2. **Diff-viewing** — make the change visible in GitHub's web UI so the user (or someone they
   share a link with) can browse it.

That's it. A push does not trigger review, deploy, or any downstream automation.

---

## When to Push

- When the user explicitly asks for a push.
- When the user finishes a session and wants the work persisted before stepping away — but only
  after asking and getting "yes" for that specific push.

Do **not** push:

- Automatically after a commit.
- "While I'm here" between commits the user hasn't reviewed yet.
- To synchronize with GitHub on the assistant's initiative.

---

## Procedure

1. Confirm the user wants to push this specific commit (or set of commits) right now. Reference
   the SHA / subject line so it's clear what's being pushed.
2. Run:
   ```powershell
   git push
   ```
   (No flags by default. `git push -u origin main` only on the very first push if the upstream
   isn't set — and confirm the branch name is `main`.)
3. Report the result: success, or the failure with full output.
4. **Do not** force-push. `git push --force`, `git push --force-with-lease`, and equivalents are
   destructive — they require explicit user authorization and a clear reason. The fallback rule
   on destructive git operations in
   [`../../assistants/assistant-permissions.md`](../../assistants/assistant-permissions.md)
   applies.

---

## What NOT to Do

- **Never push without explicit user approval for the specific push being requested.** Approval
  for an earlier push does not carry forward.
- Don't force-push. Don't `--force-with-lease` either, unless the user explicitly asks.
- Don't push to a remote other than `origin`, or to a branch other than `main`, without explicit
  instruction.
- Don't auto-push after a commit completes — pushes are a separate, explicitly approved step.
