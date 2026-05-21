# Design — Teams Graph Integration via Custom Azure AD App Registration

**Date:** 2026-05-20
**Status:** Draft — awaiting user review. Open items called out as `[DECIDE NEXT SESSION]`.
**Owner:** Justin Pope
**Supersedes:** §5 ("Auth") of [`2026-05-20-teams-pbi-group-chat-design.md`](2026-05-20-teams-pbi-group-chat-design.md). All other sections of that spec remain authoritative.
**Related memory:** [[working-docs-single-branch]]

## 1. Purpose

The kickoff spec assumed delegated Graph auth against the **Microsoft-published** `Microsoft Graph Command Line Tools` app (i.e. plain `Connect-MgGraph -Scopes ...`). We're replacing that with a **custom single-tenant Azure AD app registration** so we have:

- Explicit, audited control over the Graph scopes Claude / the script can request.
- A stable AAD identity in the BuildOn tenant that survives tenant policy changes that would block the public Microsoft client.
- The ability to pre-grant admin consent once, rather than per-user, per-scope, per-machine.

The Teams Graph MCP path is **out** — we are not using the `claude.ai Microsoft 365` MCP connector. All Graph traffic for the kickoff flow goes through the local PowerShell script using credentials from this app registration.

## 2. Blocker

We cannot run the kickoff flow end-to-end until the app registration exists in the BuildOn tenant. The app registration is a prerequisite for every other piece of the integration.

Until the registration is in place, the kickoff script can still be developed and dry-run-tested with mocked Graph calls (per §10 of the kickoff spec), but no live chat creation is possible.

## 3. App registration — required configuration

To be created in the BuildOn Azure AD tenant.

| Field | Value |
|---|---|
| Display name | `Working-Docs — PBI Kickoff Automation` |
| Supported account types | **Single tenant** (Accounts in this organizational directory only) |
| Tenant | BuildOn Technologies (`[DECIDE NEXT SESSION]` — confirm tenant ID) |
| Application type | **Public client / native** (no client secret) — see §4 |
| Redirect URI | `http://localhost` (public client redirect; required for MSAL interactive auth on Windows) |
| Allow public client flows | **Yes** (Authentication → Advanced settings) |

## 4. Auth flow — delegated, public client

We use **delegated** auth, not app-only, because Teams chats are inherently user-context resources: created chats are owned by the signed-in user, and the kickoff message is "from" that user. App-only `Chat.Create` exists but requires resource-specific consent (RSC) per-chat and adds significant complexity for no benefit in this flow.

**Public client (no client secret)** rather than confidential client (with secret) because:

- The script runs on Justin's workstation as Justin's user — there's no server to hide a secret on.
- MSAL on Windows persists refresh tokens in the encrypted token cache (DPAPI-backed) so interactive sign-in only happens on first run (or after token-cache expiry).
- No secret rotation problem.

The first-run sign-in is interactive (browser opens). Subsequent runs use the cached refresh token silently.

## 5. Required Graph permissions (delegated)

To be added under **API permissions → Microsoft Graph → Delegated permissions**:

| Permission | Why |
|---|---|
| `Chat.Create` | Create the group chat for the PBI |
| `ChatMessage.Send` | Post the kickoff message |
| `User.Read.Basic.All` | Resolve member UPNs / aliases to AAD user IDs for the chat creation payload |
| `User.Read` | Sign-in (automatically required) |

**Admin consent:**

- Whether admin consent is required depends on tenant policy. `Chat.Create` and `ChatMessage.Send` are typically user-consentable, but BuildOn may have restricted user consent.
- `[DECIDE NEXT SESSION]` — confirm with tenant admin whether we need an admin consent grant up-front, or whether per-user consent on first sign-in works. Easy to test: try interactive sign-in, see whether consent screen succeeds.

## 6. Runtime — how the script picks it up

The script (`New-PbiGroupChat.ps1`, per the kickoff spec) calls `Connect-MgGraph` with the custom app's identifiers:

```powershell
Connect-MgGraph `
    -ClientId   $env:TEAMS_APP_CLIENT_ID `
    -TenantId   $env:TEAMS_APP_TENANT_ID `
    -Scopes     'Chat.Create','ChatMessage.Send','User.Read.Basic.All' `
    -NoWelcome
```

- `$env:TEAMS_APP_CLIENT_ID` — the **Application (client) ID** GUID from the app registration. User-scope env var, set once at setup time.
- `$env:TEAMS_APP_TENANT_ID` — the **Directory (tenant) ID** GUID for BuildOn. User-scope env var.
- Neither is a secret. They are not sensitive; they identify the app and tenant but cannot be used to authenticate without the user's interactive sign-in.
- The token cache lives in the default MSAL location (`%LOCALAPPDATA%\.IdentityService\` on Windows) and is DPAPI-encrypted per-user.

`config/teams.json` (per the kickoff spec) may also store `ClientId` and `TenantId` as a backup / for documentation; env vars take precedence.

## 7. Setup checklist — handoff to Justin

When ready to unblock implementation, Justin (or a BuildOn AAD admin if user-self-service is blocked) executes:

1. Azure portal → Azure Active Directory → App registrations → **New registration**.
2. Name: `Working-Docs — PBI Kickoff Automation`. Single tenant. Redirect URI: Public client / native → `http://localhost`.
3. **Authentication** → Advanced settings → Allow public client flows = **Yes**. Save.
4. **API permissions** → Add a permission → Microsoft Graph → Delegated permissions → add `Chat.Create`, `ChatMessage.Send`, `User.Read.Basic.All` (and confirm `User.Read` is present). Save.
5. If admin consent is required by tenant policy: **Grant admin consent for BuildOn Technologies**.
6. **Overview** tab → copy **Application (client) ID** and **Directory (tenant) ID**.
7. On Justin's machine:
   ```powershell
   [Environment]::SetEnvironmentVariable('TEAMS_APP_CLIENT_ID', '<client-id-guid>', 'User')
   [Environment]::SetEnvironmentVariable('TEAMS_APP_TENANT_ID', '<tenant-id-guid>', 'User')
   ```
   Restart PowerShell so new processes see the values.
8. Smoke-test:
   ```powershell
   Connect-MgGraph `
       -ClientId $env:TEAMS_APP_CLIENT_ID `
       -TenantId $env:TEAMS_APP_TENANT_ID `
       -Scopes 'Chat.Create','ChatMessage.Send','User.Read.Basic.All'
   Get-MgUser -UserId justinpo@buildontechnologies.com
   ```
   If `Get-MgUser` returns a user object, the app reg + consent are working.

## 8. Failure modes & recovery

| Symptom | Likely cause | Recovery |
|---|---|---|
| `AADSTS65001: The user or administrator has not consented...` | Tenant policy requires admin consent for the requested scopes | Have a tenant admin grant admin consent on the app reg's API permissions page |
| `AADSTS50194: Application is not configured as a multi-tenant...` | App reg is single-tenant but auth is targeting a different tenant | Verify `$env:TEAMS_APP_TENANT_ID` matches the BuildOn tenant |
| Browser redirect to `http://localhost` fails | "Allow public client flows" not enabled, or redirect URI not registered | Re-check §3 / §7 step 3 |
| `Insufficient privileges to complete the operation` on `POST /chats` | Scopes not granted to the app reg, or consent not granted to the user | Re-check API permissions list; re-run interactive sign-in to surface a fresh consent prompt |

## 9. Open items

- `[DECIDE NEXT SESSION]` Confirm BuildOn tenant ID.
- `[DECIDE NEXT SESSION]` Confirm whether Justin can self-register apps in the BuildOn tenant, or whether an admin needs to do it.
- `[DECIDE NEXT SESSION]` Confirm whether admin consent is required for the listed scopes under BuildOn's user-consent policy.
- `[DECIDE NEXT SESSION]` App display name — `Working-Docs — PBI Kickoff Automation` is a proposal; confirm or adjust to fit any BuildOn naming convention for internal apps.

## 10. Decisions already locked

- **Custom app registration**, not the Microsoft-published public app.
- **Single tenant** (BuildOn only).
- **Delegated** auth, **public client** (no secret), MSAL token cache for silent refresh.
- Scopes: `Chat.Create`, `ChatMessage.Send`, `User.Read.Basic.All` (+ `User.Read`).
- Client ID + Tenant ID delivered to the script via **User-scope env vars** (`TEAMS_APP_CLIENT_ID`, `TEAMS_APP_TENANT_ID`), not committed to the repo.
- **No** MCP — all Graph traffic goes through the local script.
