# Design — Teams PBI Group-Chat Kickoff Flow

**Date:** 2026-05-20
**Status:** Draft — awaiting user review. Open items called out as `[DECIDE NEXT SESSION]`.
**Owner:** Justin Pope
**Related memory:** [[working-docs-single-branch]], [[war-room-state]] (poster generation context)

## 1. Purpose

When a PBI is pulled into the active sprint, automate the kickoff:

1. Create a Microsoft Teams **group chat** for that PBI.
2. Add the right people (core roster + per-PBI extras).
3. Post a first message with the PBI context so the chat is usable immediately.
4. *(Future)* Attach a war-room poster image generated via the **Front Line Poster Forge** custom GPT.

The flow is run interactively by the user (or by Claude on the user's behalf) at sprint planning time, one invocation per PBI.

## 2. Scope

### In scope (this spec)

- Pulling PBI data from Azure DevOps by work-item ID.
- Creating a Teams group chat via Microsoft Graph (delegated auth).
- Adding members from a fixed core roster + per-PBI extras provided at runtime.
- Setting the chat's `topic` to a deterministic name.
- Posting a kickoff message with PBI metadata, description, and acceptance criteria.
- Local PowerShell script + config + roster file, mirroring the existing `scripts/openai/` layout.

### Out of scope (separate follow-up spec)

- **War-room poster generation.** The custom-GPT-driven image is its own sub-project. OpenAI API billing is still the gating constraint ([[war-room-state]]); the alternative is browser automation (Playwright) against `chat.openai.com`, which has its own auth/ToS/fragility considerations. We'll design that in a follow-up spec. This spec leaves a clearly-marked **poster placeholder** in the kickoff message so the image can be added later without changing the kickoff flow.
- Two-way chat (reading replies, reactions). Send-only for now.
- Scheduled / recurring digests.
- Channel-in-Team creation (we settled on group chats, not channels).

## 3. Architecture

```
+--------------------+      +--------------------+      +---------------------+
| User / Claude      | ---> | New-PbiGroupChat   | ---> | Azure DevOps REST   |
| (interactive run)  |      |  .ps1 (entry pt.)  |      |  /workitems/{id}    |
+--------------------+      +--------------------+      +---------------------+
                                     |
                                     v
                            +--------------------+      +---------------------+
                            | Microsoft.Graph    | ---> | Graph API           |
                            |  PS module         |      |  POST /chats        |
                            | (delegated auth)   |      |  POST /chats/.../   |
                            +--------------------+      |       messages      |
                                                        +---------------------+
```

**Boundaries:**

- `New-PbiGroupChat.ps1` — orchestrator. Parses args, calls AzDO module, calls Graph module, formats message.
- `AzureDevOps.psm1` (or inline functions in script) — single responsibility: fetch a work item, return a strongly-shaped object.
- `TeamsGraph.psm1` (or inline) — single responsibility: create chat, add members, set topic, send message. Thin wrappers around `Microsoft.Graph` cmdlets.
- `config/roster.json` — core roster + alias-to-UPN mapping. Human-edited.
- `config/teams.json` — script settings (AzDO org/project URL, message template path, etc.).

Keeping AzDO and Graph in separate units lets us test the AzDO side without touching Teams and vice versa.

## 4. Inputs

CLI signature (target):

```powershell
New-PbiGroupChat.ps1 -PbiId 31790 [-ExtraMembers 'alice@buildon...','bob@buildon...'] [-DryRun] [-KickoffNote "Tuesday 10am sync"]
```

| Arg | Required | Meaning |
|---|---|---|
| `-PbiId` | yes | Azure DevOps work item ID |
| `-ExtraMembers` | no | UPNs or roster aliases to add on top of the core roster |
| `-DryRun` | no | Resolve PBI + render message, but do not call Graph |
| `-KickoffNote` | no | Free-text intro you want above the PBI block in the first message |

## 5. Auth

### Azure DevOps

- Personal Access Token in User-scope env var `AZURE_DEVOPS_EXT_PAT` (Work Items: Read scope). See `documentation/assistants/claude.md` → "Azure DevOps access (PAT)" for the shared convention.
- Org + project read from `config/teams.json`.
- `[DECIDE NEXT SESSION]` confirm AzDO org URL and project name to bake into config (current best guess based on PBI ID format: a single org/project — user to confirm).

### Microsoft Graph

- `Microsoft.Graph` PowerShell module, delegated auth.
- `Connect-MgGraph -Scopes 'Chat.Create','ChatMessage.Send','User.Read.Basic.All'` — interactive sign-in on first run; token cached for subsequent runs.
  - `User.Read.Basic.All` is needed to resolve member UPNs to AAD user IDs.
- Tenant: user's primary tenant (BuildOn Technologies based on `userEmail`).
- No app registration required for delegated flow on Microsoft-published scopes; if the tenant blocks user consent we fall back to admin consent for the same scopes.

## 6. Roster & member resolution

`config/roster.json`:

```json
{
  "core": [
    "justinpo@buildontechnologies.com"
  ],
  "aliases": {
    "atlas": "erichickey@buildontechnologies.com"
  }
}
```

- `core` is always added.
- `-ExtraMembers` accepts either UPNs (passed through) or aliases (looked up in `aliases`).
- Each member is resolved to AAD user ID via `Get-MgUser -UserId <upn>`.
- Members added to the group chat via the chat creation payload (`members` array with `roles: ['owner']` for core, `['guest']`... actually all `['owner']` for group chats per Graph requirements).

`[DECIDE NEXT SESSION]` confirm the initial core roster (just `justinpo@...` for now, or others always-on too).

## 7. Chat topic / naming

Topic set on creation:

```
PBI {PbiId} — {Title (truncated to 100 chars)}
```

Example: `PBI 31790 — Refactor poster forge prompt builder`

Graph caps chat `topic` at ~250 chars; we truncate the title at 100 to leave headroom.

## 8. Kickoff message contents

Posted as a single Graph `chatMessage` with `contentType: 'html'`. Structure:

If `-KickoffNote` is supplied it appears as the first paragraph, otherwise the message starts directly with the PBI header block.

```
{KickoffNote, if any}

PBI {ID} — {Title}
State: {State}    Assigned to: {AssignedTo}
Link: {WebUrl}

Description:
{Description, HTML-sanitized}

Acceptance Criteria:
{AcceptanceCriteria, HTML-sanitized}

--- Poster ---
[Placeholder — war-room poster will be attached once the Forge integration ships]
```

Fields pulled from AzDO work item:
- `System.Title`
- `System.State`
- `System.AssignedTo.displayName`
- `Microsoft.VSTS.Common.AcceptanceCriteria`
- `System.Description`
- `_links.html.href` (web URL)

`[DECIDE NEXT SESSION]` final field selection — the list above is the proposed default. Confirm or trim/add.

## 9. Error handling

Fail fast and loud — this is an interactive tool, not a daemon.

- **AzDO 404 / unauthorized:** print a clear "PBI {id} not found or PAT lacks scope" and exit non-zero.
- **Graph auth failure:** surface `Connect-MgGraph` error and exit; do not silently retry.
- **Member not resolvable:** abort before chat creation, list which UPNs/aliases failed. Don't create a half-populated chat.
- **Chat creation succeeds but message send fails:** print the chat ID so the user can recover manually; exit non-zero.
- `-DryRun` skips all writes; prints the resolved member list, topic, and message body to stdout.

## 10. Testing

- **AzDO module:** mock HTTP layer; unit test the work-item-to-shape mapper against a captured fixture.
- **Graph module:** test the payload-shaping functions (chat-create body, message body) against fixtures. Do not hit live Graph in unit tests.
- **Integration test:** an opt-in `Test-PbiGroupChat.ps1` that runs against a real PBI with `-DryRun` to validate AzDO connectivity + message rendering end-to-end without creating a chat.
- **Smoke test:** one real run against a throwaway PBI, with a roster of just the user, verified manually in Teams.

## 11. File layout

```
scripts/teams/
  New-PbiGroupChat.ps1            # entry point
  Modules/
    AzureDevOps.psm1              # work-item fetch + shape
    TeamsGraph.psm1               # chat create + member resolve + send
    MessageFormat.psm1            # builds the kickoff HTML
  config/
    teams.json                    # org/project, defaults
    roster.json                   # core members + aliases
  tests/
    AzureDevOps.Tests.ps1
    TeamsGraph.Tests.ps1
    MessageFormat.Tests.ps1
    Test-PbiGroupChat.ps1         # opt-in integration
documentation/skills/external-services/
  teams-graph.md                  # new — quick reference (auth, scopes, common cmdlets)
```

Mirrors `scripts/openai/` conventions.

## 12. Open items to close next session

- `[DECIDE NEXT SESSION]` Final kickoff message field list (proposed default in §8).
- `[DECIDE NEXT SESSION]` AzDO org + project to bake into `config/teams.json`.
- `[DECIDE NEXT SESSION]` Initial core roster contents.
- `[DECIDE NEXT SESSION]` Whether tenant policy allows delegated consent for the listed Graph scopes, or whether we need admin consent up-front. (Easy to test: just try `Connect-MgGraph` and see what happens.)
- **Follow-up spec:** war-room poster generation (Playwright vs API-once-billing-restored vs hybrid). Tracked separately so this flow can ship without it.

## 13. Decisions already locked

- Microsoft Teams **group chats**, not channels-in-a-Team.
- **Delegated** Graph auth, not app-only.
- PBI source is **Azure DevOps** work items.
- Membership = **fixed core roster + per-PBI extras** named at runtime.
- Poster step is **deferred** to a separate spec; kickoff message includes a placeholder.
- Send-only for now (no reply/reaction reading).
