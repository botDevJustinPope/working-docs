# VDS as an OIDC Authorization Provider — Requirements & Implementation Plan

**Stories:** [31094](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31094) / Epic [31093](https://dev.azure.com/BuildOnTechnologies/VeoDesignStudio/_workitems/edit/31093)  
**Author:** Justin Pope  
**Context:** Pre-work VDS must complete before integrating with the BI Reports Portal

---

## The Core Problem

The BI Reports Portal initiative (Epic 31093 / Story 31094) assumes VDS can issue OAuth 2.0 / OIDC tokens that the BI app can validate. **VDS cannot do that today.**

This document captures what VDS currently is, what it is not, and everything that must be built before any BI portal integration work can begin.

---

## What VDS Currently Is (Auth Reality)

### Main Application (`VeoDesignStudio`)
- Uses a **custom proprietary authentication token** — a `UNIQUEIDENTIFIER` (GUID) stored in the `users_login_sessions` table in the `VeoSolutionsSecurity` database.
- Users authenticate via `POST /api/authenticate` (username + password), and on success they receive this GUID token. Subsequent requests carry it as a bearer-like header.
- This token is **not a JWT**. There is no signing key, no issuer claim, no expiry embedded in the token itself — validity is looked up in the database.
- VDS **acts as an OIDC Relying Party** (consumer). It can authenticate users via third-party OIDC providers (e.g., Azure B2C, generic OIDC configs in the `OIDCConfiguration` table). This is the inbound SSO capability built via `AuthenticateVDSUserAfterThirdPartyAuthentication`.

### Integration API (`VeoDesignStudio.Integration.Api`)
- Uses **API Key authentication** via the `AspNetCore.Authentication.ApiKey` package.
- API keys are registered in the `integration_clients` table in the Security DB.
- Authorization policies (`TenantAccessPolicy`, `HomebuyerAccessPolicy`, `SessionAccessPolicy`) layer on top of the API key scheme.

### What Does NOT Exist
| Capability | Status |
|---|---|
| OAuth 2.0 Authorization Server | ❌ Not implemented |
| OIDC Discovery Document (`/.well-known/openid-configuration`) | ❌ Not implemented |
| JWT issuance (access tokens, ID tokens) | ❌ Not implemented |
| JWKS endpoint (public key for token validation) | ❌ Not implemented |
| Token signing key management | ❌ Not implemented |
| OAuth 2.0 client registry (OAuth apps table) | ❌ Not implemented |
| Authorization Code Flow + PKCE | ❌ Not implemented |
| Client Credentials Flow (M2M) | ❌ Not implemented |
| Token introspection endpoint | ❌ Not implemented |
| Scopes / claims definition for external consumers | ❌ Not implemented |

---

## Why This Matters for the BI Reporting Portal

For the BI Reports Portal to securely call VDS APIs or access VDS data on behalf of users, it needs a standard, verifiable mechanism. The industry-standard approach — and the one my pushback to the PO was based on — is **OAuth 2.0 / OIDC**:

- The BI portal must be able to validate that a request comes from an authenticated VDS user.
- VDS must issue JWTs that the BI portal can validate against a public JWKS endpoint.
- Credentials should never be shared between systems. API keys are not appropriate here — they're too coarse and not user-delegated.
- Anything short of OIDC compliance is a security gap that will need to be revisited under compliance scrutiny.

**My position:** VDS should own the Authorization Provider role. We know our users, roles, organizations, and permissions. The BI app should be a consumer of that trust — not the reverse.

---

## What VDS Must Build — The Required Work

### 1. Choose an Authorization Server Framework

Building a compliant OAuth 2.0 / OIDC server from scratch is strongly discouraged — it is complex, security-sensitive, and well-covered by existing libraries.

**Recommended: [OpenIddict](https://documentation.openiddict.com/)**
- Free, open source (Apache 2.0), actively maintained.
- Native ASP.NET Core integration.
- Supports Entity Framework Core (VDS already uses EF).
- Supports Authorization Code + PKCE, Client Credentials, Refresh Token, Device flows.
- Standards-compliant OIDC Discovery, JWKS, token introspection, revocation.

**Alternative: [Duende IdentityServer](https://duendesoftware.com/)**
- Gold standard, full-featured.
- **Requires a commercial license** for production use (significant cost). Not recommended unless already budgeted.

**Not Recommended: Custom JWT implementation**
- High implementation risk. Easy to introduce vulnerabilities. Reinvents a solved problem.

---

### 2. New Database Schema — OAuth Clients Table

VDS needs a table to register OAuth 2.0 client applications. OpenIddict manages this via its own schema (EF migrations), but the key entities are:

- **Applications** — each OAuth client (e.g., the BI portal) registered with:
  - `client_id` and hashed `client_secret`
  - Allowed grant types (`authorization_code`, `client_credentials`)
  - Allowed redirect URIs
  - Allowed scopes
  - Display name

- **Authorizations** — records of user consent/authorization grants
- **Tokens** — issued tokens (for introspection / revocation)
- **Scopes** — defined permission scopes (e.g., `reports:read`, `sessions:read`)

These would live in the `VeoSolutionsSecurity` database (or a new dedicated database, which is worth discussing). OpenIddict generates EF migrations for these.

---

### 3. Token Signing Key Management

VDS will need to generate and manage RSA (or ECDSA) key pairs for signing JWTs.

- In development: can use auto-generated ephemeral keys.
- In production: keys **must** be stored securely — Azure Key Vault is the right answer here (VDS already deploys to Azure).
- Key rotation must be supported without downtime (JWKS endpoint should expose multiple public keys; old keys should remain valid until all tokens signed with them expire).

**Work items:**
- Set up Azure Key Vault integration for signing key storage.
- Implement key rotation strategy.
- Expose `/.well-known/jwks` endpoint returning current public signing keys.

---

### 4. OIDC Discovery Document Endpoint

Expose `/.well-known/openid-configuration` (on the VDS main app or Integration API — to be decided). This document advertises:

```json
{
  "issuer": "https://vds.buildontechnologies.com",
  "authorization_endpoint": "https://vds.buildontechnologies.com/connect/authorize",
  "token_endpoint": "https://vds.buildontechnologies.com/connect/token",
  "jwks_uri": "https://vds.buildontechnologies.com/.well-known/jwks",
  "userinfo_endpoint": "https://vds.buildontechnologies.com/connect/userinfo",
  "response_types_supported": ["code"],
  "grant_types_supported": ["authorization_code", "client_credentials", "refresh_token"],
  "scopes_supported": ["openid", "email", "profile", "reports:read"],
  "subject_types_supported": ["public"],
  "id_token_signing_alg_values_supported": ["RS256"]
}
```

OpenIddict generates this automatically once configured.

---

### 5. JWT Claims Design

VDS must define what claims go into issued JWTs. These need to map from VDS's existing user/role model.

Minimum required claims (OIDC core spec):
| Claim | Source |
|---|---|
| `sub` | `user_id` (GUID) from `users` table |
| `email` | `users.email` |
| `name` | User display name |
| `iss` | VDS issuer URI |
| `aud` | Client ID of the requesting app |
| `exp` | Token expiry |
| `iat` | Issued-at time |

VDS-specific claims to add:
| Claim | Source |
|---|---|
| `vds_role` | User role from `roles` / `role_users` tables |
| `vds_org` | Organization ID(s) the user belongs to |
| `vds_permissions` | Relevant permissions from `permissions` / `role_permissions` |
| `tenant_id` | If multi-tenant context is relevant to the BI app |

The exact claim set should be agreed upon with the BI portal team — they need to know what they can assert when a token is presented to them.

---

### 6. OAuth 2.0 Flows to Support

#### For the BI Reports Portal — Two Scenarios:

**Scenario A: User-Delegated Access (Authorization Code Flow + PKCE)**  
A user is logged into VDS. The BI portal redirects them to VDS to authorize access. VDS returns an authorization code; the BI portal exchanges it for an access token. The BI portal then calls VDS APIs on behalf of the user.

This is appropriate if the BI portal is user-facing and needs to know *who* the user is.

**Scenario B: Machine-to-Machine / Service Account (Client Credentials Flow)**  
The BI portal authenticates as itself (not on behalf of a user) using a `client_id` and `client_secret`. This is appropriate for background data sync, report generation, or any server-side process not tied to a specific user session.

Both flows should be supported. The BI portal team and PO need to decide which scenario applies to their architecture.

---

### 7. VDS API Updates — Accept JWT Bearer Tokens

Currently, the Integration API uses API Key authentication. To accept tokens issued by VDS's new Authorization Server, the Integration API (and potentially the main app) needs to be updated:

- Add JWT Bearer authentication scheme alongside the existing API Key scheme.
- Use `services.AddAuthentication().AddJwtBearer(...)` configured to validate against VDS's own JWKS endpoint.
- Protect BI-relevant endpoints with an appropriate policy (`[Authorize(Policy = "BIReportsPolicy")]`).

This is additive — existing API Key consumers are not broken.

---

### 8. Scope of Change in `VeoDesignStudio.Integration.Api\Startup.cs`

The current `ConfigureAuthenticationServices` method:

```csharp
private void ConfigureAuthenticationServices(IServiceCollection services)
{
    services.AddAuthentication(ApiKeyDefaults.AuthenticationScheme)
        .AddApiKeyInHeaderOrQueryParams<ApiKeyProvider>(options => { ... });
}
```

Needs to evolve to:

```csharp
services.AddAuthentication()
    .AddApiKeyInHeaderOrQueryParams<ApiKeyProvider>(options => { ... })  // existing, unchanged
    .AddJwtBearer("VdsOidc", options =>
    {
        options.Authority = config["Oidc:Issuer"];
        options.Audience = config["Oidc:Audience"];
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true
        };
    });
```

And new authorization policies:

```csharp
options.AddPolicy("BIReportsAccessPolicy", policy =>
{
    policy.AuthenticationSchemes.Add("VdsOidc");
    policy.RequireAuthenticatedUser();
    policy.RequireClaim("scope", "reports:read");
});
```

---

### 9. Work to NOT Do in VDS (BI Portal's Responsibility)

To be clear about the split:

| Work Item | Owner |
|---|---|
| Validate VDS-issued JWTs using the JWKS endpoint | BI Portal team |
| Configure BI portal as an OAuth client in VDS | BI Portal team + VDS admin setup |
| Implement the Authorization Code redirect flow in the BI portal | BI Portal team |
| Define what reports/data are accessed and how | BI Portal team |
| Store/refresh access tokens in the BI portal | BI Portal team |

VDS's job ends at issuing valid, standards-compliant tokens and securing the endpoints the BI portal needs to call.

---

## Summary of VDS Stories to Create

These are the discrete pieces of work that should be scoped as their own stories under Epic 31093 (or a new dedicated OIDC epic, which I'd argue for):

1. **Evaluate & Select Authorization Server Framework** — spike/ADR for OpenIddict vs alternatives.
2. **Implement OAuth 2.0 Authorization Server (OpenIddict)** — install, configure, migrations.
3. **Signing Key Infrastructure** — Azure Key Vault integration, key rotation, JWKS endpoint.
4. **JWT Claims Mapping** — define VDS claims, implement claims principal transformation from VDS user model.
5. **Register BI Portal as an OAuth Client** — client app record, allowed scopes, grant types.
6. **Update Integration API to Accept JWT Bearer Tokens** — additive auth scheme, new policies.
7. **Security Review / Penetration Test Scope Update** — any auth architecture change warrants a security review pass.

---

## Appendix: Current Auth Architecture Reference

| Component | Location | Auth Mechanism |
|---|---|---|
| `VeoDesignStudio` (main app) | `VeoDesignStudio\Controllers\Api\AuthenticationController.cs` | Custom GUID token (username/password) + Third-party OIDC (relying party) |
| `VeoDesignStudio.Integration.Api` | `VeoDesignStudio.Integration.Api\Authentication\ApiKeyProvider.cs` | API Key (from `integration_clients` table) |
| OIDC Relying Party (inbound SSO) | `BuildOnTechnologies.VDS.Services\Authentication\AuthenticateVDSUserAfterThirdPartyAuthentication.cs` | Consumes external OIDC providers via `OIDCHelper` |
| Security token store | `Databases\VeoSolutionsSecurity\dbo\Tables\users_login_sessions.sql` | GUID stored in DB, validated on each request |
| OIDC provider configs (inbound) | `BuildOnTechnologies.VDS.Domain\Authorization\OIDCConfiguration.cs` | Config for external providers VDS trusts |
