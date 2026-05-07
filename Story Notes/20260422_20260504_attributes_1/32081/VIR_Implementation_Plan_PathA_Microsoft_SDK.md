# VIR Implementation — Path A (Microsoft SDK, tutorial-aligned)

> **Mermaid diagrams** — render natively on GitHub. In VS Code, install `bierner.markdown-mermaid` (the workspace's `.vscode/extensions.json` recommends it).

> **Parent plan:** [`VIR_Implementation_Plan.md`](./VIR_Implementation_Plan.md)
> **Sibling alternative:** [`VIR_Implementation_Plan_PathB_Raw_REST.md`](./VIR_Implementation_Plan_PathB_Raw_REST.md)
> **Reference tutorial:** <https://learn.microsoft.com/en-us/power-bi/developer/embedded/embed-customer-app>
> **Reference sample:** <https://github.com/PowerBiDevCamp/DOTNET5-AppOwnsData-Tutorial>

---

## 1. Path A in one sentence

Implement embed-for-your-customers using the Microsoft tutorial verbatim — `Microsoft.Identity.Web` for token acquisition, `Microsoft.PowerBI.Api` for Power BI calls — and expose the result behind our own `IPowerBIEmbedTokenService` interface so VDS code never imports those namespaces directly.

---

## 2. Why Path A

- **Already proven** by the Microsoft sample app. Token caching, refresh, error mapping, telemetry — all handled.
- **Familiar shape** for any .NET developer who's done OIDC. `IConfidentialClientApplication` and `PowerBIClient` are well-documented.
- **Fast spike**: the entire backend can be ~150 LOC of glue code on top of the tutorial.
- **Explicit upgrade path**: when Power BI adds API features (e.g. new token grant types), Microsoft ships an SDK update.

The cost is dependency surface — see §10.

---

## 3. Dependencies to add

### 3.1 NuGet (backend)

```xml
<!-- VeoDesignStudio.Reporting.csproj or wherever the embed service lives -->
<ItemGroup>
  <PackageReference Include="Microsoft.Identity.Web" Version="3.*" />
  <PackageReference Include="Microsoft.PowerBI.Api" Version="4.*" />
</ItemGroup>
```

`Microsoft.Identity.Web.UI` is **not** required — that package adds Razor pages for *user* sign-in. We're doing client-credentials (app-only), no UI.

Transitively this pulls:

- `Microsoft.Identity.Client` (MSAL.NET)
- `Microsoft.Identity.Abstractions`
- `Microsoft.IdentityModel.*` (token validation)
- `Microsoft.Rest.ClientRuntime` (for the PBI SDK's HTTP layer)

Roughly 25 packages once resolved. None are giant; total install size is single-digit MB.

### 3.2 npm (frontend)

```bash
npm install powerbi-client
```

Also needed in Path B — the embed client library is shared.

---

## 4. Configuration

### 4.1 Reusing VDS's existing OIDC configuration

VDS already has Entra ID configuration in place from the prior Okta/OIDC work — `Microsoft.Identity.Web` reads it from an `AzureAd` section. Path A can reuse much of that shape rather than introducing a fresh, parallel block.

Field-by-field, what carries over and what doesn't:

| Field already in OIDC config | Reusable? | Why |
|---|---|---|
| `AzureAd:Instance` | ✅ Identical | Same Entra login authority |
| `AzureAd:TenantId` | ✅ Identical | Same Entra tenant |
| `AzureAd:ClientId` | ⚠️ Depends — see §4.3 | Shared only if you reuse the same Entra app for both flows |
| `AzureAd:ClientSecret` / `ClientCredentials` | ⚠️ Same caveat | Tied to whichever `ClientId` you choose |
| `AzureAd:CallbackPath`, `SignedOutCallbackPath`, `Domain` | ❌ Not used by app-only flow | These only matter for user-sign-in (delegated) flows |

### 4.2 The configuration block

```jsonc
// appsettings.json (production secrets in Key Vault, not here)
{
  "AzureAd": {
    // ⤵ Already set by the existing OIDC config — leave as-is.
    "Instance": "https://login.microsoftonline.com/",
    "TenantId": "<tenant-guid>",

    // ⤵ Either reuse the OIDC app's ClientId/Secret (Option 1 in §4.3)
    //    or replace these with a dedicated reporting-app credential
    //    (Option 2 in §4.3 — recommended for production).
    "ClientId":          "<see §4.3>",
    "ClientCredentials": [
      {
        "SourceType":   "ClientSecret",
        "ClientSecret": "<from-key-vault>"
      }
      // For prod, prefer:
      // { "SourceType": "KeyVault", "KeyVaultUrl": "...", "KeyVaultCertificateName": "..." }
    ]
  },
  "PowerBi": {
    "ServiceRootUrl": "https://api.powerbi.com/",
    "Scope":          "https://analysis.windows.net/powerbi/api/.default"
  }
}
```

Notes:

- Use `ClientCredentials` (the `Microsoft.Identity.Web` v3+ shape), not the older `ClientSecret` top-level field. Same effect, future-proof.
- The `.default` scope suffix is **required** for client-credentials flow.
- `ServiceRootUrl` should never be hard-coded — the URL differs in sovereign clouds.

### 4.3 One Entra app, or two?

The decision driving `ClientId` is whether the existing OIDC Entra app should also act as the Power BI service principal, or whether a dedicated reporting app is registered alongside it.

**Option 1 — Reuse the existing OIDC Entra app**

- Add Power BI API permissions (`Tenant.Read.All` or workspace-scoped equivalents) to the existing app registration.
- Add that app's service principal as a Member of the Power BI workspace.
- Same `ClientId` and `ClientCredentials` for both user sign-in and Power BI calls.
- ✅ Fastest to spike. One secret to rotate. Single line in `appsettings.json`.
- ❌ The same credential now authorizes user sign-in *and* Power BI data access — they can't be rotated, revoked, or scoped independently. Compromise of either flow exposes both. Audit narrative is "this app does everything."

**Option 2 — Dedicated reporting Entra app, shared tenant fields** *(recommended for production)*

- Register a new "VDS Reporting" Entra app. Grant it the Power BI permissions and add only its service principal to the workspace.
- The existing OIDC app keeps its current scope (user sign-in only).
- Both apps live in the same tenant, so `AzureAd:Instance` and `AzureAd:TenantId` are unchanged. Only `AzureAd:ClientId` and `AzureAd:ClientCredentials` reference the new app.
- ✅ Standard production pattern. Independent rotation, independent revocation, clean audit boundary.
- ❌ Two app registrations and two credentials to manage. DevOps owns both.

If you want **both flows wired in the same app config without touching OIDC config**, namespace the reporting credentials so they're distinct. Microsoft.Identity.Web supports this via `AddTokenAcquisition` reading from a different section name:

```jsonc
{
  "AzureAd": {
    // ↳ Existing OIDC settings — untouched.
    "Instance":  "https://login.microsoftonline.com/",
    "TenantId":  "<tenant-guid>",
    "ClientId":  "<existing-oidc-app-client-id>",
    "ClientCredentials": [ { "SourceType": "...", "ClientSecret": "..." } ],
    "Domain":    "...",
    "CallbackPath": "/signin-oidc"
  },
  "AzureAdReporting": {
    // ↳ New section, only the fields the Power BI flow needs.
    "Instance":  "https://login.microsoftonline.com/",
    "TenantId":  "<tenant-guid>",            // same tenant — same value
    "ClientId":  "<vds-reporting-app-client-id>",
    "ClientCredentials": [ { "SourceType": "KeyVault", "KeyVaultUrl": "...", "KeyVaultCertificateName": "..." } ]
  },
  "PowerBi": {
    "ServiceRootUrl": "https://api.powerbi.com/",
    "Scope":          "https://analysis.windows.net/powerbi/api/.default"
  }
}
```

The DI line in §5.1 changes by one argument when using the namespaced section — see §5.1 Note.

### 4.4 Recommendation

- **Spike:** Option 1 if the existing OIDC app's owner (Justin / Aaron) is comfortable adding Power BI permissions to it temporarily. Pulls one variable out of "things to set up before the spike." Document it as a spike-only choice and plan to migrate.
- **Ship:** Option 2 with the namespaced section above. DevOps will likely push for this regardless — it's the pattern Aaron sees in every other production .NET app.

---

## 5. Backend wiring

### 5.1 DI registration (`Program.cs` / `Startup.cs`)

```csharp
using Microsoft.Identity.Web;

var builder = WebApplication.CreateBuilder(args);

// Token acquisition for app-only Power BI calls.
// AddTokenAcquisition (not AddMicrosoftIdentityWebApp) because we do NOT
// need the OIDC user-sign-in middleware — VDS already authenticates the user.
builder.Services
    .AddTokenAcquisition()
    .AddInMemoryTokenCaches();

// Bind the Entra options that AddTokenAcquisition will read.
// Default: read from "AzureAd" — the existing OIDC section.
// Use this if the OIDC Entra app is also serving as the Power BI service
// principal (Option 1 in §4.3).
builder.Services.Configure<MicrosoftIdentityOptions>(
    builder.Configuration.GetSection("AzureAd"));

builder.Services.Configure<PowerBiOptions>(
    builder.Configuration.GetSection("PowerBi"));

builder.Services.AddSingleton<IPowerBIEmbedTokenService, PowerBIEmbedTokenService>();
```

> **Deviation from the tutorial:** the tutorial calls `AddMicrosoftIdentityWebAppAuthentication(...)` because its sample app is an MVC app where the *user* signs in with Microsoft Entra. VDS does not work that way — VDS already has its own user authentication, and only needs **app-only** tokens to call Power BI. `AddTokenAcquisition()` + `AddInMemoryTokenCaches()` is the minimal pair we need.

> **Note — namespaced section (Option 2 in §4.3):** if VDS uses a separate Entra app for Power BI and you've added an `AzureAdReporting` section per §4.3, bind the options against that section instead, so the existing OIDC `AzureAd` config stays untouched:
>
> ```csharp
> builder.Services.Configure<MicrosoftIdentityOptions>(
>     builder.Configuration.GetSection("AzureAdReporting"));
> ```
>
> If both flows live in the same app, register OIDC against `AzureAd` (its existing wiring) and reporting against `AzureAdReporting` using named options — `Microsoft.Identity.Web` supports multiple authentication schemes via the `IConfidentialClientApplicationBuilder` pattern; consult the docs if and when you need that.

### 5.2 The service implementation

```csharp
using Microsoft.Identity.Web;
using Microsoft.PowerBI.Api;
using Microsoft.PowerBI.Api.Models;
using Microsoft.Rest;

internal sealed class PowerBIEmbedTokenService : IPowerBIEmbedTokenService
{
    private static readonly string[] Scopes =
        new[] { "https://analysis.windows.net/powerbi/api/.default" };

    private readonly ITokenAcquisition _tokenAcquisition;
    private readonly IOptionsMonitor<PowerBiOptions> _options;
    private readonly ILogger<PowerBIEmbedTokenService> _log;

    public PowerBIEmbedTokenService(
        ITokenAcquisition tokenAcquisition,
        IOptionsMonitor<PowerBiOptions> options,
        ILogger<PowerBIEmbedTokenService> log)
    {
        _tokenAcquisition = tokenAcquisition;
        _options          = options;
        _log              = log;
    }

    public async Task<EmbedTokenResult> GetEmbedTokenAsync(
        Guid workspaceId,
        Guid reportId,
        EffectiveIdentity? effectiveIdentity,
        CancellationToken ct)
    {
        // 1. Acquire an Entra access token (app-only, client-credentials).
        var accessToken = await _tokenAcquisition
            .GetAccessTokenForAppAsync(Scopes[0])
            .ConfigureAwait(false);

        // 2. Build the Power BI client for the duration of this call.
        using var pbi = new PowerBIClient(
            new Uri(_options.CurrentValue.ServiceRootUrl),
            new TokenCredentials(accessToken, "Bearer"));

        // 3. Fetch the report (need the dataset ID and embed URL).
        var report = await pbi.Reports
            .GetReportInGroupAsync(workspaceId, reportId, ct)
            .ConfigureAwait(false);

        // 4. Build the GenerateToken request, injecting RLS effective identity.
        var tokenRequest = new GenerateTokenRequest(
            accessLevel: TokenAccessLevel.View,
            datasetId: report.DatasetId,
            identities: BuildIdentities(effectiveIdentity, report.DatasetId));

        // 5. Generate the embed token.
        var embed = await pbi.Reports
            .GenerateTokenInGroupAsync(workspaceId, reportId, tokenRequest, ct)
            .ConfigureAwait(false);

        return new EmbedTokenResult(
            EmbedUrl:   report.EmbedUrl,
            EmbedToken: embed.Token,
            ExpiresOn:  embed.Expiration,
            ReportId:   report.Id,
            DatasetId:  Guid.Parse(report.DatasetId));
    }

    private static IList<EffectiveIdentity>? BuildIdentities(
        EffectiveIdentity? id, string datasetId)
    {
        if (id is null) return null;

        return new List<EffectiveIdentity>
        {
            new EffectiveIdentity(
                username:   id.Username,
                roles:      id.Roles?.ToList(),
                customData: id.CustomData is { Count: > 0 }
                              ? string.Join(",", id.CustomData)  // PBI custom data is a single string
                              : null,
                datasets:   new List<string> { datasetId })
        };
    }
}

internal sealed class PowerBiOptions
{
    public string ServiceRootUrl { get; init; } = "https://api.powerbi.com/";
    public string Scope          { get; init; } = "https://analysis.windows.net/powerbi/api/.default";
}
```

> The tutorial creates the `PowerBIClient` once and reuses it. In practice the SDK constructor is cheap and the underlying `HttpClient` is what matters; we follow `using` for clarity. If profiling shows construction overhead, switch to a singleton with `IHttpClientFactory`.

### 5.3 Endpoint

```csharp
app.MapGet("/api/reports/{reportKey}/embed",
    async (string reportKey,
           IReportCatalog catalog,
           IReportAuthorizer authz,
           IEffectiveIdentityBuilder identityBuilder,
           IPowerBIEmbedTokenService tokens,
           HttpContext http,
           CancellationToken ct) =>
{
    if (!catalog.TryGet(reportKey, out var entry)) return Results.NotFound();
    if (!await authz.CanAccessAsync(http.User, entry, ct)) return Results.Forbid();

    var identity = await identityBuilder.BuildAsync(http.User, entry, ct);
    var result   = await tokens.GetEmbedTokenAsync(
        entry.WorkspaceId, entry.ReportId, identity, ct);

    return Results.Ok(new
    {
        embedUrl    = result.EmbedUrl,
        embedToken  = result.EmbedToken,
        reportId    = result.ReportId,
        expiresOn   = result.ExpiresOn
    });
})
.RequireAuthorization();   // VDS standard auth — proves who the user is
```

`IReportCatalog`, `IReportAuthorizer`, `IEffectiveIdentityBuilder` are VDS-side concerns described in the parent plan §4–5. They are independent of which path is chosen.

---

## 5b. Discovery for the admin UI

The same `PowerBIClient` used for embed-token generation also exposes the discovery endpoints (parent plan §4a). Sketch:

```csharp
public interface IPowerBIDiscoveryService
{
    Task<IReadOnlyList<WorkspaceSummary>> ListWorkspacesAsync(
        CancellationToken ct);

    Task<IReadOnlyList<WorkspaceReport>> ListReportsAsync(
        Guid workspaceId, CancellationToken ct);
}

public sealed record WorkspaceSummary(Guid Id, string Name);

public sealed record WorkspaceReport(
    Guid    Id,
    string  Name,
    Guid    DatasetId,
    string? ReportType);     // "PowerBIReport" | "PaginatedReport"

internal sealed class PowerBIDiscoveryService : IPowerBIDiscoveryService
{
    private readonly ITokenAcquisition _tokenAcquisition;
    private readonly IOptionsMonitor<PowerBiOptions> _options;

    public PowerBIDiscoveryService(
        ITokenAcquisition tokenAcquisition,
        IOptionsMonitor<PowerBiOptions> options)
    {
        _tokenAcquisition = tokenAcquisition;
        _options = options;
    }

    public async Task<IReadOnlyList<WorkspaceSummary>> ListWorkspacesAsync(
        CancellationToken ct)
    {
        using var pbi = await CreateClientAsync(ct).ConfigureAwait(false);
        var groups = await pbi.Groups.GetGroupsAsync(cancellationToken: ct)
            .ConfigureAwait(false);
        return groups.Value
            .Select(g => new WorkspaceSummary(Guid.Parse(g.Id), g.Name))
            .ToList();
    }

    public async Task<IReadOnlyList<WorkspaceReport>> ListReportsAsync(
        Guid workspaceId, CancellationToken ct)
    {
        using var pbi = await CreateClientAsync(ct).ConfigureAwait(false);
        var reports = await pbi.Reports
            .GetReportsInGroupAsync(workspaceId, ct)
            .ConfigureAwait(false);
        return reports.Value
            .Select(r => new WorkspaceReport(
                Guid.Parse(r.Id),
                r.Name,
                Guid.Parse(r.DatasetId),
                r.ReportType))
            .ToList();
    }

    private async Task<PowerBIClient> CreateClientAsync(CancellationToken ct)
    {
        var token = await _tokenAcquisition
            .GetAccessTokenForAppAsync("https://analysis.windows.net/powerbi/api/.default")
            .ConfigureAwait(false);
        return new PowerBIClient(
            new Uri(_options.CurrentValue.ServiceRootUrl),
            new TokenCredentials(token, "Bearer"));
    }
}
```

**Important — team boundary:** for `GetGroupsAsync` to return a workspace, the service principal must have been added to that workspace as a **Member** (or higher). That step is **the BI team's responsibility (Daniel) on the workspace they own**, not VDS code's. If discovery returns an empty list, the most common cause is "service principal not yet added to the workspace" — same root cause as the embed flow's 403s.

VDS's job is to **detect this clearly and surface it** (the empty list, a 403 with a specific message), not to fix it. See the parent plan §5a for the full responsibility matrix and §5a.1 for symptom-to-owner triage.

> Discovery is the **admin's** capability, not the end user's. Mount these behind admin-only authorization. End users hit the catalog-backed list, never `GetReportsInGroup` directly.

## 6. Frontend wiring

VDS has two frontends, and each one consumes a different slice of the API:

| App | Stack | Talks to | Needs `powerbi-client`? |
|---|---|---|---|
| Main app (end users view reports) | **Durandal** + Knockout + RequireJS | `GET /api/reports/{key}/embed` | ✅ Yes — for the embed handshake |
| Admin app (catalog management) | **Aurelia** | `/api/admin/workspaces`, `/api/admin/catalog`, etc. | ❌ No — plain JSON CRUD |

Both apps target the same `IPowerBIEmbedTokenService` endpoint shape, so this section is identical between Path A and Path B. The only thing that differs across paths is *how `powerbi-client` reaches the page* (npm install vs. vendored script vs. CDN); that's covered in **Path B §6.2–6.5** and applies equally here.

### 6.1 Loading `powerbi-client`

Path A already takes Microsoft NuGet dependencies, so `npm install powerbi-client` is a consistent posture. If the main app's build doesn't have a bundler (Durandal apps often run unbundled on RequireJS), the **vendored-script-tag** approach from Path B §6.3 is a clean drop-in — just put `<script src="~/lib/powerbi/powerbi.min.js">` in the main shell HTML before your app boots.

For the rest of this section, the embed code assumes `window.powerbi` and `window['powerbi-client'].models` are available — true with either approach.

### 6.2 Main app — Durandal report embed page

A page-level view model that: (1) fetches the embed token in `activate`, (2) embeds the report on `attached`, (3) tears down on `detached` so route changes don't leak iframes.

**View model — `viewmodels/report.js`:**

```javascript
define(['plugins/http', 'knockout'], function (http, ko) {

    var ReportViewModel = function () {
        this.reportKey    = null;
        this.embedData    = null;     // populated by activate(); read in attached()
        this.report       = null;     // the powerbi.embed result
        this.errorMessage = ko.observable(null);
    };

    // Durandal awaits the returned promise before composing the view, so
    // attached() is guaranteed to see embedData populated when activate() succeeds.
    ReportViewModel.prototype.activate = function (params) {
        var self = this;
        self.reportKey = params.reportKey;
        return http.get('/api/reports/' + encodeURIComponent(self.reportKey) + '/embed')
            .then(function (data) { self.embedData = data; })
            .fail(function (xhr) {
                self.errorMessage('Failed to load report (' + xhr.status + ').');
            });
    };

    ReportViewModel.prototype.attached = function (view) {
        if (!this.embedData) return; // activate failed; the error banner is showing

        var container = view.querySelector('#vds-report-container');
        var models    = window['powerbi-client'].models;

        var config = {
            type:        'report',
            id:          this.embedData.reportId,
            embedUrl:    this.embedData.embedUrl,
            accessToken: this.embedData.embedToken,
            tokenType:   models.TokenType.Embed,    // Embed, NOT Aad — this is app-owns-data
            permissions: models.Permissions.Read,
            viewMode:    models.ViewMode.View,
            settings: {
                panes: {
                    filters:        { expanded: false, visible: true },
                    pageNavigation: { visible: true }
                }
            }
        };

        this.report = window.powerbi.embed(container, config);

        // Surface report-side failures to the UI (RLS errors, dataset errors, etc.)
        var self = this;
        this.report.on('error', function (evt) {
            self.errorMessage('Report error: ' + (evt.detail && evt.detail.message));
        });
    };

    ReportViewModel.prototype.detached = function (view) {
        var container = view && view.querySelector('#vds-report-container');
        if (container) window.powerbi.reset(container);
        this.report = null;
    };

    return ReportViewModel;
});
```

**View — `views/report.html`:**

```html
<div>
    <div data-bind="visible: errorMessage" class="alert alert-danger">
        <span data-bind="text: errorMessage"></span>
    </div>
    <div id="vds-report-container" style="height: 800px;"></div>
</div>
```

**Routing** — wire into the existing Durandal router config:

```javascript
router.map([
    { route: 'reports/:reportKey', moduleId: 'viewmodels/report', title: 'Report' }
]);
```

Notes:

- `tokenType: Embed` is correct for app-owns-data. `Aad` is for *embed-for-your-organization* (each user has their own Power BI account) — **not** our flow.
- Always call `powerbi.reset(container)` on `detached`. Otherwise, navigating between two report routes leaks the previous embed and you'll see odd UI state on the second one.
- The embed instance's `error` event is worth wiring up early — most RLS misconfigurations surface here, and they're easy to mistake for "VDS is broken" otherwise.

### 6.3 Admin app — Aurelia catalog management page

The admin app does not embed reports; it lists workspace reports via the discovery endpoints from §5b and writes catalog rows. No `powerbi-client` involved.

This is **Aurelia 1.x** syntax. If admin is on Aurelia 2, the template is the same; the lifecycle method names change (`activate`→`binding`/`bound`, `detached`→`detaching`/`unbinding`).

**View model — `pages/add-report.js`:**

```javascript
import { inject } from 'aurelia-framework';
import { HttpClient, json } from 'aurelia-fetch-client';

@inject(HttpClient)
export class AddReportPage {

    constructor(http) {
        this.http = http;
        this.workspaces          = [];
        this.selectedWorkspaceId = null;
        this.candidates          = [];
        this.selectedReport      = null;
        this.form = {
            displayName:         '',
            description:         '',
            category:            '',
            requiredFeatureFlag: '',
            requiredAccessRole:  ''
        };
        this.errorMessage = null;
    }

    async activate() {
        const resp = await this.http.fetch('/api/admin/workspaces');
        if (!resp.ok) {
            this.errorMessage = `Workspace list failed (${resp.status}).`;
            return;
        }
        this.workspaces = await resp.json();
    }

    // Aurelia change-handler convention: <prop>Changed
    async selectedWorkspaceIdChanged(newValue) {
        this.candidates     = [];
        this.selectedReport = null;
        if (!newValue) return;
        const resp = await this.http.fetch(`/api/admin/workspaces/${newValue}/reports`);
        if (!resp.ok) {
            this.errorMessage = `Report list failed (${resp.status}).`;
            return;
        }
        this.candidates = await resp.json();
    }

    selectReport(report) {
        this.selectedReport = report;
        if (!this.form.displayName) this.form.displayName = report.name;
    }

    async save() {
        const body = {
            workspaceId:         this.selectedWorkspaceId,
            reportId:            this.selectedReport.id,
            datasetId:           this.selectedReport.datasetId,
            displayName:         this.form.displayName,
            description:         this.form.description,
            category:            this.form.category,
            requiredFeatureFlag: this.form.requiredFeatureFlag,
            requiredAccessRole:  this.form.requiredAccessRole
        };
        const resp = await this.http.fetch('/api/admin/catalog', {
            method: 'POST',
            body:   json(body)
        });
        if (!resp.ok) {
            this.errorMessage = `Save failed (${resp.status}).`;
            return;
        }
        // router.navigateToRoute('catalog-list');
    }
}
```

**View — `pages/add-report.html`:**

```html
<template>
    <h2>Add a report</h2>

    <div if.bind="errorMessage" class="alert alert-danger">${errorMessage}</div>

    <label>Workspace
        <select value.bind="selectedWorkspaceId">
            <option model.bind="null">— choose —</option>
            <option repeat.for="ws of workspaces" model.bind="ws.id">${ws.name}</option>
        </select>
    </label>

    <ul if.bind="candidates.length">
        <li repeat.for="r of candidates">
            <button click.delegate="selectReport(r)">Select</button>
            ${r.name} <small>(${r.reportType})</small>
        </li>
    </ul>

    <form if.bind="selectedReport" submit.delegate="save()">
        <p>Catalog entry for <strong>${selectedReport.name}</strong></p>
        <label>Display name <input value.bind="form.displayName"></label>
        <label>Description <textarea value.bind="form.description"></textarea></label>
        <label>Category <input value.bind="form.category"></label>
        <label>Feature flag <input value.bind="form.requiredFeatureFlag"></label>
        <label>Access role <input value.bind="form.requiredAccessRole"></label>
        <button type="submit">Save to catalog</button>
    </form>
</template>
```

Notes:

- `aurelia-fetch-client` is idiomatic for Aurelia. If admin uses the older `aurelia-http-client` (XHR-based), the call shapes are similar with different method names — `httpClient.createRequest('/...').asGet().send()`.
- The `selectedWorkspaceIdChanged` convention assumes the property is bindable from the template; with `value.bind` on the `<select>`, Aurelia wires this automatically. If the property is plain (not bindable), use a `dispatchedEvent` or call a method explicitly from the template.

### 6.4 Optional — preview a report from admin (Aurelia)

If admin needs to verify a candidate before saving to the catalog, embed it the same way as the main app: include `powerbi-client` (same loading options as §6.1), `@inject(Element)` to get a DOM ref, embed in `attached`, reset in `detached`. The embed code is structurally identical to the Durandal example in §6.2 — just translated into Aurelia's class + lifecycle shape. Treat this as a follow-up; basic catalog management doesn't need it.

---

## 7. Effective identity — getting RLS right

The `effectiveIdentity` parameter is what makes RLS work for our app-owns-data flow. It's the source of every RLS bug in the wild.

```csharp
// In IEffectiveIdentityBuilder, materialise from the VDS principal.
var identity = new EffectiveIdentity(
    Username:   user.GetVdsUserId().ToString(),     // matches RLS rule expectations
    Roles:      new[] { "VdsViewer" },              // role names defined in the semantic model
    CustomData: orgIds,                             // list of account-org GUIDs
    DatasetId:  entry.DatasetId);                   // not used here but kept for symmetry
```

**Pitfalls:**

- `Username` must match what the RLS DAX expects. If the rule is `[UserPrincipalName] = USERPRINCIPALNAME()`, send the email. If it's `[UserId] = USERNAME()`, send the user ID. **Coordinate the exact string with Daniel before the spike** — the contract lives in the DAX, not the docs.
- `Roles` must reference roles **that actually exist** in the dataset. A typo silently grants access to no rows.
- `CustomData` is a **single string** in the SDK, not a list. We join with commas; the DAX side parses with `PATHCONTAINS` or string functions. (See §9.)
- The identity's `Datasets` list must contain the dataset ID of the report being embedded — the SDK enforces this.

**Test technique:** create a test user that should see exactly 3 rows. If it sees 0, the username is wrong. If it sees all rows, the SP bypassed RLS (identity wasn't sent or `Roles` is empty).

---

## 8. Token caching behavior (built-in)

`Microsoft.Identity.Web` does the following automatically once `AddInMemoryTokenCaches()` is registered:

- Caches Entra access tokens per app + scope. Reuses across requests.
- Refreshes ~5 minutes before expiry.
- Uses MSAL's underlying singleton — no per-request construction.

We don't write any cache code in Path A. (Path B re-implements this in ~30 LOC.)

For multi-instance deployments that want a shared cache (e.g. behind a load balancer), swap in `AddDistributedTokenCaches()` and a Redis backing store. Not needed for our spike.

---

## 9. Custom data limits and gotchas

The Power BI `EffectiveIdentity.CustomData` field has hard limits:

- **Maximum length: 1,024 characters** (server-side rejection above that).
- Treated as a single string opaque to Power BI.
- Available in DAX as `CUSTOMDATA()`.

Our payload of `accountOrgIds` could exceed 1024 chars for users with hundreds of orgs (rare but possible — corporate-level Taylor Morrison-style accounts). Mitigations:

1. **Compress to short codes**: have the data warehouse expose `orgShortId` (4-6 char) instead of GUID.
2. **Use roles for the common case**: define `OrgScopedViewer` role with the filter `[OrgId] IN VALUES(UserOrgMapping[OrgId])` and a backing table that the dataset already knows about. Then the only thing in `CustomData` is the user identifier.
3. **Move to a server-side join**: include `userId` in CustomData; the semantic model has a `UserOrgs` table that joins user → orgs. This is the cleanest pattern and is what Daniel will likely build.

Working assumption: **option 3** is what we ship. CustomData carries `userId` (or email + stack), and the dataset joins to get the org list.

---

## 10. What we accept by choosing Path A

- **~25 transitive packages.** Audit the lock file once; treat any new ones in upgrades as a code review concern.
- **Coupling to `Microsoft.Identity.Web`'s opinions** — it expects ASP.NET Core hosting, configures `HttpClient`s under the hood, takes over MSAL configuration. If we ever host the embed-token service outside ASP.NET (worker service, Function), we'd have to switch to MSAL directly. Not blocking.
- **Auto-instrumentation** — `Microsoft.Identity.Web` adds its own ILogger output. Verbose by default; tune `Logging.LogLevel.Microsoft.Identity` in `appsettings.json`.
- **Update cadence** — the SDK ships every few months. We'll follow it; not a meaningful burden.

If any of these become a real problem, swap to Path B. The DI line is the only thing that changes.

---

## 11. Spike checklist (Path A)

- [ ] Add the two NuGet packages to the reporting project.
- [ ] Wire DI per §5.1.
- [ ] Implement `PowerBIEmbedTokenService` per §5.2.
- [ ] Add the endpoint per §5.3 with hard-coded `workspaceId`, `reportId`, and a single fixed effective identity.
- [ ] Pull `powerbi-client` via npm in the VDS frontend.
- [ ] Add a minimal page that calls the endpoint and embeds.
- [ ] Confirm: filtered report renders in browser inside VDS for an authenticated VDS user.
- [ ] Toggle the effective identity off and confirm: report shows *all* rows (proving RLS is the layer doing the filtering, not the SP's permissions).

If all eight check, Path A is shippable. We then bolt on the catalog, authorization layers, and discovery endpoint in subsequent stories.

---

## 12. Files this path adds

```
VeoDesignStudio.Reporting/
├── PowerBI/
│   ├── PowerBIEmbedTokenService.cs       (Path A implementation)
│   ├── PowerBiOptions.cs
│   └── EmbedTokenResult.cs               (shared with Path B)
├── Api/
│   └── ReportEmbedEndpoint.cs            (shared with Path B)
└── DependencyInjection/
    └── ReportingServiceCollectionExtensions.cs   (DI lines, path-aware)
```

The only file that changes when porting to Path B is `PowerBIEmbedTokenService.cs`.
