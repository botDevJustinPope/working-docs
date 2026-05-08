# Commit Conventions — Working-Docs

> **Approval gate.** Never commit without explicit user approval. The "ask before committing"
> rule lives in
> [`../../assistants/assistant-permissions.md`](../../assistants/assistant-permissions.md);
> this file covers what a *good* commit message looks like once approval is granted.

This convention is adapted from the VeoDesignStudio repo
(`documentation/skills/git/commit-conventions.md` over there), with the ADO-story prefix made
optional because Working-Docs is not story-driven.

---

## Commit Message Format

```
<Short imperative description>

- Bullet describing what changed and why (if not obvious)
- Additional bullet for each logical change
- Keep bullets focused — one concern per bullet

<Co-authored-by trailer — see your assistant's entry file under documentation/assistants/>
```

For commits that relate to a specific ADO story, lead the subject with `#<storyId>`:

```
#31790 Capture flat-rate pricing PBI persona notes

- ...
```

The `#<storyId>` prefix is **optional** in this repo because Working-Docs is not ADO-story-driven
the way code repos are. Use it only when the commit is genuinely about a specific PBI and the
cross-reference is useful.

### Rules

- **Subject line:** Short, imperative description. No period at the end. Optional `#<storyId>`
  prefix.
- **Body:** Use `-` bullets. Each bullet covers one logical change. Explain the *why* when the
  *what* isn't self-evident. The body is **optional** for trivial edits (single-file note tweak,
  typo fix) — the subject line is enough in those cases.
- **Co-author trailer:** When an LLM assistant helped with the commit, include the co-author
  trailer specified by that assistant's entry file in `documentation/assistants/` (e.g.,
  `claude.md`, `chatgpt-instructions.md`, `copilot-instructions.md`). Omit the trailer entirely
  for commits authored without assistant involvement.
- **Scope:** One commit per logical unit of work. Grab-bag "misc updates" commits are tolerated
  in this repo for occasional dumps of unrelated note edits (there's no PR review pressure to
  keep diffs reviewable), but prefer focused commits when the work is genuinely focused.
- **Tense:** Imperative mood — "Add", "Fix", "Remove", "Update" — not "Added", "Fixed".

### Examples

```
Add War Room poster for product-search PBI

- Save the DALL·E poster under AI Content/WarRoom/30900/
- Cross-link from Story Notes/30900-product-search-component.md

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
#31790 Capture flat-rate pricing PBI persona notes

- Write up the BOM-pipeline persona under Story Notes/31790/
- Reference the persona from the existing meeting notes
```

```
Tidy up RedGate scratch folder

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## What NOT to Do

- **Never commit without explicit user authorization.** Before every `git commit`, present the
  staged changes and proposed commit message to the user and wait for approval. Do not commit
  autonomously, even if the changes are complete and correct.
- Don't commit secrets, credentials, connection strings, PATs, or API keys — even in scratch
  folders or AI-generated content. Treat any commit as if it will go to GitHub immediately.
- Don't commit large binaries that aren't load-bearing artifacts (intermediate exports, sample
  downloads, etc.) — they bloat the repo with no payoff.
- Don't bundle clearly unrelated changes when the user asked for a focused commit.
- Don't use vague messages like "fix stuff", "WIP", or bare "update" — even in this single-branch
  repo, the existing `update`-style commits in the history are an example of what to avoid going
  forward.
