# VDS as an OIDC Authorization Provider — Proposed Work

**Audience:** VDS development team
**Author:** Justin Pope
**Status:** Working draft / position paper — not a finalized ADR. Intended to drive team discussion, story creation, and estimation.
**Related:**
- Epic [31092 — VEO Intelligence Reporting](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31092)
- Feature [31093 — VIR: Design & Planning](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31093)
- Feature [31127 — VIR: Foundational](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31127)
- Spike [31094 — Spike: VEO Intelligence Reporting](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31094)

---

## TL;DR

The VIR spike (31094) and the VIR foundational feature (31127) both assume VDS can issue and sign JWTs that the VIR portal can validate. **VDS cannot do that today.** None of the existing stories in the VIR backlog deliver that capability — they consume it.

The work to turn VDS into an OIDC-capable authorization provider is an **epic-sized effort in its own right** that needs to land before we can honestly integrate with the BI reporting team. This document proposes that body of work as a set of stories we can size and schedule.

---

## Why This Is Its Own Epic

Skim the existing VIR backlog and the auth gap becomes obvious:

| Work item | What it assumes | What it delivers for auth |
|---|---|---|
| [31094 Spike](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31094) | VDS emits a signed JWT with `orgId`, `userId`, `reportKey`, `exp`, `aud`, `iss` | Nothing — consumes tokens |
| [31370 Launcher UI](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31370) | Launching a report opens a new tab "correctly" | Nothing — consumes tokens |
| [31471 Validate Security](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31471) | Bookmarked report URLs honor expiration, revocation, disabled users, feature-flag state | Nothing — relies on token lifetime and introspection that doesn't exist |
| [31127 Foundational](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31127) AC | "Launch report" securely | Nothing — the AC is silent on how security is enforced |

The minimum honest delivery of the spike requires VDS to:

1. Hold a signing key
2. Mint a signed JWT on demand
3. Publish a public key the portal can use to validate

That's not a line of code we can slip into another story. It's new infrastructure that needs design, review, and its own test story.

---

## What VDS Currently Is (Auth Inventory)

### Main app (`VeoDesignStudio`)
- Custom GUID auth token (`UNIQUEIDENTIFIER`) stored in `users_login_sessions` (`VeoSolutionsSecurity`)
- Not a JWT — no signing, no claims, no embedded expiry
- Already an **OIDC Relying Party** (consumes third-party OIDC via `OIDCHelper` and `OIDCConfiguration`)

### Integration API (`VeoDesignStudio.Integration.Api`)
- API key authentication (`integration_clients` table)
- Policies: `TenantAccessPolicy`, `HomebuyerAccessPolicy`, `SessionAccessPolicy`

### What does NOT exist
| Capability | Status |
|---|---|
| JWT issuance | Missing |
| Token signing key management | Missing |
| JWKS endpoint | Missing |
| OIDC discovery document | Missing |
| OAuth client registry (client apps) | Missing |
| Token introspection / revocation | Missing |
| Authorization Code + PKCE flow | Missing |
| Client Credentials flow | Missing |
| Scope / claim contract for external consumers | Missing |

---

## Architectural Givens (Not Open For This Round)

These are decisions we're taking into this epic so we don't re-litigate them in every story:

1. **New capability inside the existing VDS API** — not a new deployable service. We layer OIDC provider responsibilities onto the existing app so we don't carry another deployment unit and reuse existing infrastructure (logging, telemetry, identity DB access).
2. **Schema lives in the `VeoSolutions` database**, not `VeoSolutionsSecurity`. `VeoSolutionsSecurity` is a SQL-first schema; the OIDC work leans on EF Core migrations that don't fit that model cleanly.
3. **Reuse existing OIDC code where possible.** `OIDCHelper`, `OIDCConfiguration`, and the relying-party claims parsing in `AuthenticateVDSUserAfterThirdPartyAuthentication` should inform — and where possible supply — primitives for the outbound provider work.
4. **Multi-tenancy specifics are deferred.** The exact tenancy contract (how `orgId`/`tenant_id` show up in tokens, how the VIR portal scopes data) gets nailed down with the BI reporting team during integration. We build the token infrastructure with a pluggable claims pipeline so that deferral is safe.

Framework choice (OpenIddict vs. Duende vs. hand-rolled) is **not** decided here — that is story 1.

---

## Proposed Stories

The intent is a new feature (or sibling epic) under [Epic 31092](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31092) titled something like **"VDS OIDC Authorization Provider — Foundation"**, owned by the VDS dev team, that lands before any VIR feature (31127) story is scheduled.

### Story 1 — ADR: Authorization Server Framework Selection
**Intent:** Decide, in writing, which framework VDS adopts for token issuance.

**Acceptance criteria:**
- ADR published covering OpenIddict, Duende IdentityServer, and hand-rolled options
- Decision rationale includes: licensing cost, standards compliance, ASP.NET Core fit, EF Core fit, maintenance/bus factor
- Working recommendation: **OpenIddict** (Apache 2.0, native EF support, standards-compliant)
- ADR reviewed and accepted by team before story 2 starts

**Estimated shape:** spike / 1–2 days. No production code.

---

### Story 2 — Install & Configure Authorization Server
**Intent:** Land the chosen framework in the VDS API with the minimum wiring needed to issue tokens.

**Acceptance criteria:**
- Chosen framework installed and registered in VDS API startup
- EF migrations generated against the `VeoSolutions` database (not `VeoSolutionsSecurity`)
- Application, Authorization, Token, Scope entities exist per the framework's schema
- Local dev uses ephemeral signing keys; production key handling is deferred to story 3
- Smoke test: VDS issues a signed JWT for a hard-coded test client and we can validate it offline

**Dependencies:** Story 1

---

### Story 3 — Signing Key Infrastructure
**Intent:** Production-grade signing key management with rotation support.

**Acceptance criteria:**
- Azure Key Vault integration for signing key storage (RSA or ECDSA — algorithm decision captured in ADR)
- Key generation and rotation strategy documented and implemented
- JWKS endpoint (`/.well-known/jwks`) exposes current + recent public keys so tokens signed with rotated-out keys remain valid until expiry
- Per-environment key separation (dev, staging, prod) — no shared keys across envs
- Runbook for emergency key rotation

**Dependencies:** Story 2

**Open question for team:** Does VDS already have Key Vault in its deployment story, or is this net-new Azure integration work? If net-new, the story size grows materially.

---

### Story 4 — OIDC Discovery Endpoint
**Intent:** Stand up `/.well-known/openid-configuration` so the VIR portal (and future consumers) can auto-configure against VDS.

**Acceptance criteria:**
- Endpoint returns valid OIDC discovery document
- Advertised endpoints resolve: `issuer`, `authorization_endpoint`, `token_endpoint`, `jwks_uri`, `userinfo_endpoint`
- Advertised signing algorithms match what the signing key infrastructure emits
- Issuer URI is environment-aware (dev / staging / prod)
- Document passes an OIDC discovery validator (e.g., standard RP test tools)

**Dependencies:** Stories 2, 3

---

### Story 5 — Claims Contract & Claims Principal Mapping
**Intent:** Define and implement how VDS's user model flows into issued JWTs.

**Acceptance criteria:**
- Written claims contract covering, at minimum:
  - Standard OIDC: `sub`, `iss`, `aud`, `exp`, `iat`, `email`, `name`
  - VDS-specific: `vds_role`, `vds_org` (or `orgId`), relevant permission claims, `tenant_id` hook (populated conditionally — see note)
  - VIR-specific: `reportKey` (populated at issuance time, not baked into user profile)
- Implementation: claims transformation service reads from VDS user/role/org model and emits the above
- Unit tests cover role- and permission-mapped claim population
- Contract reviewed with whoever represents the BI reporting team so they know what they can trust

**Notes for team:**
- `tenant_id` is on the list but its exact semantics are deferred to BI integration discussions. Build the pipeline so adding a claim later is a code change, not a schema change.
- If we find the user permission set is too large to stuff into a JWT comfortably, we fall back to a reference-token + userinfo lookup pattern. Flag this during implementation.

**Dependencies:** Stories 2, 4

---

### Story 6 — Register VIR Portal as an OAuth Client
**Intent:** Give VDS the ability to recognize the VIR portal as a registered relying party.

**Acceptance criteria:**
- Admin-side mechanism (seeded data, migration, or admin UI — team decision) to register a client with:
  - `client_id`, hashed `client_secret` (if confidential)
  - Allowed redirect URIs
  - Allowed grant types (see story 7)
  - Allowed scopes (e.g., `vir:launch`, `openid`, `profile`)
  - Display name
- VIR portal's actual client record created in each environment
- Documentation for how to register future clients

**Dependencies:** Story 2

---

### Story 7 — "Launch Report" Token Issuance Integration
**Intent:** Wire the actual VIR hand-off: when a VDS user clicks Launch, VDS mints a short-lived signed JWT for the VIR portal.

**Acceptance criteria:**
- VDS server-side endpoint that, given an authenticated VDS session and a `reportKey`, issues a signed JWT containing the claims from story 5 plus `reportKey`
- Token TTL is short (suggest 2–5 minutes — team decision; capture in claims contract)
- Token is audience-bound to the VIR portal client
- The "Launch Report" UI (from [31370](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31370)) calls this endpoint and opens `VEOReportingPortal/sso?token=...&reportKey=...` in a new tab
- Event-log entry recorded per issuance (ties into [31371](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31371))

**Dependencies:** Stories 3, 5, 6

**Open question for team:** This flow is a front-channel SSO hand-off, not a full OAuth Authorization Code flow. That's fine for the spike and MVP. But if we want VDS to support the full Auth Code + PKCE flow for future integrations, that should be a separate story once this epic lands. Not in scope here.

---

### Story 8 — Token Lifetime, Revocation & Session Semantics
**Intent:** Make the behavior in [31471](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31471) actually enforceable.

**Acceptance criteria:**
- Short token TTL (design decision from story 7) enforced
- Documented behavior for each scenario in 31471:
  - User bookmarks URL → expired token rejected by portal (TTL)
  - User access revoked → next token request fails; already-issued tokens die at TTL
  - User disabled → next token request fails; already-issued tokens die at TTL
  - Feature flag off → next token request fails
- If stricter than "die at TTL" is required, implement either token introspection endpoint **or** short enough TTL that the gap is acceptable (team decides, writes up rationale)
- Integration test that exercises each scenario

**Dependencies:** Stories 3, 5, 7

**Open question for team:** Story 31471 implies saved URLs should honor revocation *immediately*. Pure JWTs don't support that cleanly without introspection. We need to agree on what "immediately" means here — "within N minutes" is cheap; "within seconds" requires introspection infrastructure.

---

## Scope Explicitly NOT in This Epic

To keep this epic sized honestly, these things are **not** proposed here. They become follow-up epics once the foundation is in place:

- Full OAuth 2.0 Authorization Code + PKCE flow (not needed for VIR front-channel hand-off)
- Client Credentials (M2M) flow
- Integration API accepting VDS-issued JWTs as an alternative to API keys
- Deprecating the custom GUID session token in favor of JWTs
- Consent screens / dynamic client registration
- Formal security review / third-party pen test (should be scheduled, but tracked separately under the security backlog, not this epic)

---

## Known Open Questions

These need team input before or during execution — they don't block the epic from being created but should be resolved before the corresponding stories start.

1. **Framework choice** — OpenIddict is the working recommendation but story 1 is the actual decision
2. **Signing algorithm** — RS256 vs. ES256
3. **Key Vault integration** — existing VDS Azure infrastructure or net-new
4. **Token TTL** — 2 minutes? 5? 15?
5. **Revocation semantics** — how immediate is "immediate" for 31471
6. **Tenancy claim contract** — deferred to BI integration, but we need a placeholder shape so stories 5 and 7 have something concrete to ship
7. **Where the Discovery endpoint is hosted** — on VDS main app, Integration API, or both. Leaning main app since that's where users authenticate.
8. **`vds_permissions` claim size** — if a typical user's permission set is too large, we pivot to reference tokens + userinfo. Watch for this during story 5.

---

## Mapping to Original PO-Facing Requirements Doc

For continuity with `VDS_OIDC_Authorization_Provider_Requirements.md`:

| Original story | This epic |
|---|---|
| 1. Evaluate & Select Framework | Story 1 |
| 2. Implement OAuth 2.0 Server (OpenIddict) | Story 2 |
| 3. Signing Key Infrastructure | Story 3 |
| 4. JWT Claims Mapping | Story 5 |
| 5. Register BI Portal as OAuth Client | Story 6 |
| 6. Update Integration API to Accept JWT Bearer Tokens | **Out of scope** — follow-up epic |
| 7. Security Review / Pen Test | **Out of scope** — tracked on security backlog |
| *(new)* | Story 4 — Discovery endpoint (implied by original but not a standalone story) |
| *(new)* | Story 7 — Launch Report token issuance (implied by VIR spike but not in original) |
| *(new)* | Story 8 — Token lifetime & revocation (implied by 31471 but not in original) |

---

## What I'm Asking The Team For

1. **Concur that this is epic-sized** and belongs as a sibling to (or predecessor of) the VIR foundational work, not threaded into it.
2. **Challenge the story breakdown** — splits, merges, missing pieces.
3. **Weigh in on the architectural givens** above. If anyone disagrees with the "new capability in VDS API" or "schema in VeoSolutions DB" calls, raise it before we create stories.
4. **Answer the open questions** that are answerable without the BI team in the room.
5. **Agree on sequencing** — do we pause VIR spike scheduling until story 3 or 4 lands, or do we parallelize.
