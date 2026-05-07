# VIR Implementation — Path B (raw REST, no Microsoft SDK)

> **Mermaid diagrams** — render natively on GitHub. In VS Code, install `bierner.markdown-mermaid` (the workspace's `.vscode/extensions.json` recommends it).

> **Parent plan:** [`VIR_Implementation_Plan.md`](./VIR_Implementation_Plan.md)
> **Sibling alternative:** [`VIR_Implementation_Plan_PathA_Microsoft_SDK.md`](./VIR_Implementation_Plan_PathA_Microsoft_SDK.md)
> **REST reference:**
> - Entra ID OAuth 2.0 client-credentials: <https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow>
> - Power BI REST: <https://learn.microsoft.com/en-us/rest/api/power-bi/>
> - Reports — GetReportInGroup: <https://learn.microsoft.com/en-us/rest/api/power-bi/reports/get-report-in-group>
> - EmbedToken — GenerateTokenForReportInGroup: <https://learn.microsoft.com/en-us/rest/api/power-bi/embed-token/reports-generate-token-in-group>

---

## 1. Path B in one sentence

Implement the same embed-for-your-customers flow as Path A, but call Entra ID and the Power BI REST API directly with `HttpClient` — no `Microsoft.Identity.Web`, no `Microsoft.PowerBI.Api` — exposing the result behind the same `IPowerBIEmbedTokenService` interface so VDS code can swap implementations with a single DI line.

---

## 2. Why Path B exists

We're keeping this path open because the Microsoft tutorial pulls in a lot of opinionated infrastructure to do something that, on the wire, is three HTTP calls. Path B trades a few hundred lines of explicit code for:

- **Zero new NuGet dependencies** beyond what's already in VDS (we use `System.Net.Http.Json` from the BCL and our existing JSON serializer).
- **Every URL, header, and JSON shape visible in our repo** — auditable in code review without consulting the SDK source.
- **Smaller attack surface** — fewer transitive packages to track CVEs against.
- **No coupling** to `Microsoft.Identity.Web`'s ASP.NET-Core-hosted assumptions. The service can run in any .NET host (worker service, Function, Lambda).

The cost: we own the HTTP code. We write the token cache. We mind the breaking changes (rare — these endpoints are stable).

> **Frontend caveat (same as Path A):** the browser still needs Microsoft's `powerbi-client` JS — Power BI's iframe expects the embed token to arrive via a `postMessage` handshake, not as a URL parameter, so *some* code on the page has to speak that protocol. **Path B is a backend choice.** That said, you do not have to take an npm dependency to use the library — see §6 for three loading strategies, including a vendored-script-tag option that keeps `package.json` untouched.

---

## 3. The wire protocol (no SDK to hide it)

Three HTTP calls, in order, per embed request.

### 3.1 Acquire an Entra access token (client credentials)

```
POST https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id={clientId}
&client_secret={clientSecret}
&scope=https%3A%2F%2Fanalysis.windows.net%2Fpowerbi%2Fapi%2F.default
```

Response (200):

```json
{
  "token_type": "Bearer",
  "expires_in": 3599,
  "ext_expires_in": 3599,
  "access_token": "eyJ0eXAiOiJKV1Qi..."
}
```

This token is reusable across reports for ~1 hour. **Cache it.**

### 3.2 Get the report (need `datasetId` and `embedUrl`)

```
GET https://api.powerbi.com/v1.0/myorg/groups/{workspaceId}/reports/{reportId}
Authorization: Bearer {access_token}
```

Response (200):

```json
{
  "id":         "<reportId>",
  "name":       "Sales Dashboard",
  "datasetId":  "<datasetId>",
  "embedUrl":   "https://app.powerbi.com/reportEmbed?reportId=...&groupId=...",
  "webUrl":     "https://app.powerbi.com/groups/.../reports/..."
}
```

### 3.3 Generate the embed token (with RLS effective identity)

```
POST https://api.powerbi.com/v1.0/myorg/groups/{workspaceId}/reports/{reportId}/GenerateToken
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "accessLevel": "View",
  "identities": [
    {
      "username":   "user@taylormorrison.com",
      "roles":      ["VdsViewer"],
      "datasets":   ["<datasetId>"],
      "customData": "<orgIds-or-userId>"
    }
  ]
}
```

Response (200):

```json
{
  "token":      "H4sIAAAAAAAEACWS...",
  "tokenId":    "...",
  "expiration": "2026-04-27T15:00:00Z"
}
```

Hand `token` (the embed token) and the `embedUrl` from step 3.2 back to the browser. That's the entire flow.

---

## 4. Configuration

```jsonc
// appsettings.json (secrets in Key Vault)
{
  "PowerBi": {
    "TenantId":      "<tenant-guid>",
    "ClientId":      "<vds-reporting-app-client-id>",
    "ClientSecret":  "<from-key-vault>",
    "Authority":     "https://login.microsoftonline.com",
    "Scope":         "https://analysis.windows.net/powerbi/api/.default",
    "ApiBaseUrl":    "https://api.powerbi.com/"
  }
}
```

Note: same values as Path A, just collapsed under one `PowerBi` section instead of split between `AzureAd` and `PowerBi`.

---

## 5. Backend implementation

### 5.1 DI registration (`Program.cs`)

```csharp
builder.Services.Configure<PowerBiOptions>(
    builder.Configuration.GetSection("PowerBi"));

// Named HttpClient for Entra (token endpoint).
builder.Services.AddHttpClient("entra", c =>
{
    c.BaseAddress = new Uri("https://login.microsoftonline.com/");
});

// Named HttpClient for Power BI.
builder.Services.AddHttpClient("powerbi", (sp, c) =>
{
    var opts = sp.GetRequiredService<IOptionsMonitor<PowerBiOptions>>().CurrentValue;
    c.BaseAddress = new Uri(opts.ApiBaseUrl);
});

builder.Services.AddSingleton<IEntraTokenCache, EntraTokenCache>();
builder.Services.AddSingleton<IPowerBIEmbedTokenService, RawRestPowerBIEmbedTokenService>();
```

### 5.2 The token cache (~30 LOC)

```csharp
internal interface IEntraTokenCache
{
    Task<string> GetAccessTokenAsync(CancellationToken ct);
}

internal sealed class EntraTokenCache : IEntraTokenCache
{
    private readonly IHttpClientFactory _http;
    private readonly IOptionsMonitor<PowerBiOptions> _options;
    private readonly SemaphoreSlim _lock = new(1, 1);

    private string? _token;
    private DateTimeOffset _expiresAt = DateTimeOffset.MinValue;

    public EntraTokenCache(IHttpClientFactory http, IOptionsMonitor<PowerBiOptions> options)
    {
        _http    = http;
        _options = options;
    }

    public async Task<string> GetAccessTokenAsync(CancellationToken ct)
    {
        // Refresh ~5 min before expiry to avoid race with downstream calls.
        if (_token is not null && DateTimeOffset.UtcNow < _expiresAt.AddMinutes(-5))
            return _token;

        await _lock.WaitAsync(ct).ConfigureAwait(false);
        try
        {
            if (_token is not null && DateTimeOffset.UtcNow < _expiresAt.AddMinutes(-5))
                return _token;

            var opts = _options.CurrentValue;
            var form = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["grant_type"]    = "client_credentials",
                ["client_id"]     = opts.ClientId,
                ["client_secret"] = opts.ClientSecret,
                ["scope"]         = opts.Scope
            });

            using var client = _http.CreateClient("entra");
            using var resp   = await client.PostAsync(
                $"{opts.TenantId}/oauth2/v2.0/token", form, ct).ConfigureAwait(false);
            resp.EnsureSuccessStatusCode();

            var body = await resp.Content
                .ReadFromJsonAsync<EntraTokenResponse>(cancellationToken: ct)
                .ConfigureAwait(false)
                ?? throw new InvalidOperationException("Empty token response.");

            _token     = body.access_token;
            _expiresAt = DateTimeOffset.UtcNow.AddSeconds(body.expires_in);
            return _token;
        }
        finally
        {
            _lock.Release();
        }
    }

    private sealed record EntraTokenResponse(string access_token, int expires_in);
}
```

That's the entire token-caching surface. No MSAL, no `ITokenAcquisition`, no `ConfidentialClientApplicationBuilder`. The `SemaphoreSlim` prevents a thundering-herd refresh under burst load.

> **On 401**: if a downstream call returns 401 with the cached token, force a refresh once and retry. Add this only after the spike proves it's needed.

### 5.3 The embed-token service

```csharp
internal sealed class RawRestPowerBIEmbedTokenService : IPowerBIEmbedTokenService
{
    private static readonly JsonSerializerOptions JsonOpts = new(JsonSerializerDefaults.Web);

    private readonly IHttpClientFactory _http;
    private readonly IEntraTokenCache _tokens;
    private readonly ILogger<RawRestPowerBIEmbedTokenService> _log;

    public RawRestPowerBIEmbedTokenService(
        IHttpClientFactory http,
        IEntraTokenCache tokens,
        ILogger<RawRestPowerBIEmbedTokenService> log)
    {
        _http   = http;
        _tokens = tokens;
        _log    = log;
    }

    public async Task<EmbedTokenResult> GetEmbedTokenAsync(
        Guid workspaceId,
        Guid reportId,
        EffectiveIdentity? effectiveIdentity,
        CancellationToken ct)
    {
        var accessToken = await _tokens.GetAccessTokenAsync(ct).ConfigureAwait(false);
        using var client = _http.CreateClient("powerbi");
        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", accessToken);

        // 1. GetReport.
        var reportUrl = $"v1.0/myorg/groups/{workspaceId}/reports/{reportId}";
        var report = await client
            .GetFromJsonAsync<PbiReport>(reportUrl, JsonOpts, ct)
            .ConfigureAwait(false)
            ?? throw new InvalidOperationException("Empty GetReport response.");

        // 2. GenerateToken.
        var generateUrl = $"v1.0/myorg/groups/{workspaceId}/reports/{reportId}/GenerateToken";
        var generateBody = new GenerateTokenRequest
        {
            AccessLevel = "View",
            Identities  = effectiveIdentity is null
                ? null
                : new[]
                  {
                      new PbiIdentity
                      {
                          Username   = effectiveIdentity.Username,
                          Roles      = effectiveIdentity.Roles?.ToArray(),
                          Datasets   = new[] { report.DatasetId },
                          CustomData = effectiveIdentity.CustomData is { Count: > 0 }
                                          ? string.Join(",", effectiveIdentity.CustomData)
                                          : null
                      }
                  }
        };

        using var resp = await client
            .PostAsJsonAsync(generateUrl, generateBody, JsonOpts, ct)
            .ConfigureAwait(false);
        resp.EnsureSuccessStatusCode();

        var token = await resp.Content
            .ReadFromJsonAsync<PbiEmbedTokenResponse>(JsonOpts, ct)
            .ConfigureAwait(false)
            ?? throw new InvalidOperationException("Empty GenerateToken response.");

        return new EmbedTokenResult(
            EmbedUrl:   report.EmbedUrl,
            EmbedToken: token.Token,
            ExpiresOn:  token.Expiration,
            ReportId:   Guid.Parse(report.Id),
            DatasetId:  Guid.Parse(report.DatasetId));
    }

    // Wire-format DTOs — kept private to this file so VDS code can't accidentally
    // depend on them. The public contract is EmbedTokenResult / EffectiveIdentity.

    private sealed record PbiReport(
        string Id,
        string Name,
        string DatasetId,
        string EmbedUrl);

    private sealed record GenerateTokenRequest
    {
        public string AccessLevel { get; init; } = "View";
        public PbiIdentity[]? Identities { get; init; }
    }

    private sealed record PbiIdentity
    {
        public string?   Username   { get; init; }
        public string[]? Roles      { get; init; }
        public string[]? Datasets   { get; init; }
        public string?   CustomData { get; init; }
    }

    private sealed record PbiEmbedTokenResponse(
        string Token,
        string TokenId,
        DateTimeOffset Expiration);
}
```

That's roughly **120 lines** for the entire service, not counting comments and DTOs. The wire shapes match the REST docs verbatim.

### 5.4 Endpoint

The endpoint is identical to Path A — it depends only on `IPowerBIEmbedTokenService`. See `VIR_Implementation_Plan_PathA_Microsoft_SDK.md` §5.3.

```csharp
app.MapGet("/api/reports/{reportKey}/embed", async (
    string reportKey,
    IReportCatalog catalog,
    IReportAuthorizer authz,
    IEffectiveIdentityBuilder identityBuilder,
    IPowerBIEmbedTokenService tokens,    // ← only this binding differs between paths
    HttpContext http,
    CancellationToken ct) =>
{
    if (!catalog.TryGet(reportKey, out var entry)) return Results.NotFound();
    if (!await authz.CanAccessAsync(http.User, entry, ct)) return Results.Forbid();

    var identity = await identityBuilder.BuildAsync(http.User, entry, ct);
    var result   = await tokens.GetEmbedTokenAsync(entry.WorkspaceId, entry.ReportId, identity, ct);

    return Results.Ok(new
    {
        embedUrl    = result.EmbedUrl,
        embedToken  = result.EmbedToken,
        reportId    = result.ReportId,
        expiresOn   = result.ExpiresOn
    });
}).RequireAuthorization();
```

---

## 5b. Discovery for the admin UI

The discovery endpoints (parent plan §4a) are GET calls, no body, same access token, same auth header. Two wire calls:

```
GET https://api.powerbi.com/v1.0/myorg/groups
GET https://api.powerbi.com/v1.0/myorg/groups/{workspaceId}/reports
```

Both return `{ "value": [ ... ] }` arrays.

```csharp
public interface IPowerBIDiscoveryService
{
    Task<IReadOnlyList<WorkspaceSummary>> ListWorkspacesAsync(CancellationToken ct);
    Task<IReadOnlyList<WorkspaceReport>> ListReportsAsync(Guid workspaceId, CancellationToken ct);
}

public sealed record WorkspaceSummary(Guid Id, string Name);

public sealed record WorkspaceReport(
    Guid    Id,
    string  Name,
    Guid    DatasetId,
    string? ReportType);

internal sealed class RawRestPowerBIDiscoveryService : IPowerBIDiscoveryService
{
    private static readonly JsonSerializerOptions JsonOpts = new(JsonSerializerDefaults.Web);

    private readonly IHttpClientFactory _http;
    private readonly IEntraTokenCache _tokens;

    public RawRestPowerBIDiscoveryService(
        IHttpClientFactory http, IEntraTokenCache tokens)
    {
        _http = http;
        _tokens = tokens;
    }

    public async Task<IReadOnlyList<WorkspaceSummary>> ListWorkspacesAsync(
        CancellationToken ct)
    {
        using var client = await CreateClientAsync(ct).ConfigureAwait(false);
        var resp = await client.GetFromJsonAsync<ListResponse<PbiGroup>>(
            "v1.0/myorg/groups", JsonOpts, ct).ConfigureAwait(false)
            ?? throw new InvalidOperationException("Empty groups response.");

        return resp.Value
            .Select(g => new WorkspaceSummary(Guid.Parse(g.Id), g.Name))
            .ToList();
    }

    public async Task<IReadOnlyList<WorkspaceReport>> ListReportsAsync(
        Guid workspaceId, CancellationToken ct)
    {
        using var client = await CreateClientAsync(ct).ConfigureAwait(false);
        var resp = await client.GetFromJsonAsync<ListResponse<PbiReport>>(
            $"v1.0/myorg/groups/{workspaceId}/reports", JsonOpts, ct).ConfigureAwait(false)
            ?? throw new InvalidOperationException("Empty reports response.");

        return resp.Value
            .Select(r => new WorkspaceReport(
                Guid.Parse(r.Id),
                r.Name,
                Guid.Parse(r.DatasetId),
                r.ReportType))
            .ToList();
    }

    private async Task<HttpClient> CreateClientAsync(CancellationToken ct)
    {
        var token = await _tokens.GetAccessTokenAsync(ct).ConfigureAwait(false);
        var client = _http.CreateClient("powerbi");
        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", token);
        return client;
    }

    // Wire DTOs — kept private; public surface is the records above.
    private sealed record ListResponse<T>(IReadOnlyList<T> Value);
    private sealed record PbiGroup(string Id, string Name);
    private sealed record PbiReport(string Id, string Name, string DatasetId, string? ReportType);
}
```

DI registration (alongside the embed-token service):

```csharp
builder.Services.AddSingleton<IPowerBIDiscoveryService, RawRestPowerBIDiscoveryService>();
```

**SP membership note — team boundary:** if `ListWorkspacesAsync` returns an empty array, the SP isn't a Member of any workspace yet. Workspace membership is **the BI team's responsibility (Daniel) on the workspace they own**, not a VDS code problem. The same condition is what produces 403s on the embed flow.

VDS's job is to **detect and surface this clearly**, not to fix it. See the parent plan §5a (responsibility matrix) and §5a.1 (symptom-to-owner triage) for the full picture.

> Discovery is the **admin's** capability, not the end user's. Mount these behind admin-only authorization. End users hit the catalog-backed list, never `GET .../reports` directly.

### 5b.1 Postman parity

The pre-spike Postman collection from §7 should grow two more requests once discovery is on the table:

```
4. List Workspaces        GET {{baseUrl}}v1.0/myorg/groups
5. List Reports in WS     GET {{baseUrl}}v1.0/myorg/groups/{{workspaceId}}/reports
```

Useful sanity-check: the workspace ID we hard-code in the spike *should* appear in #4's response, and the report ID we hard-code *should* appear in #5's. If they don't, the SP doesn't have access — fix that before writing any C#.

## 6. Frontend

VDS has two frontends: **Durandal** for the main app (where users view embedded reports) and **Aurelia** for the admin app (where admins manage the catalog via discovery endpoints). The framework-specific view-model and template code is **identical between Path A and Path B** — the canonical examples live in **Path A §6.2 (Durandal embed page)** and **§6.3 (Aurelia admin catalog page)**. This section covers what's *unique to Path B*: how `powerbi-client` itself gets onto the page without an npm install.

The browser does not know — and should not care — which backend path produced the embed token. The embed *call* is identical to Path A; what differs in Path B is **how `powerbi-client` itself reaches the page**, because Path B's whole posture is "no Microsoft packages in our build dependencies."

### 6.1 Why we still need `powerbi-client` JS at all

The embed iframe at `app.powerbi.com/reportEmbed?reportId=...&groupId=...` does not accept the embed token in the URL. Once it loads, it waits for a `postMessage` containing the token, the config, and a request/response correlation ID. The page then has to forward subsequent events (`ready`, `error`, page-changed, filter-changed) back to the iframe via the same channel.

That handshake is what `powerbi-client` implements. It's roughly 100 KB minified, ~30 KB gzipped, and lives on GitHub at <https://github.com/microsoft/powerbi-client>. Reimplementing it is possible but not advisable (§6.4).

### 6.2 Three ways to load it

Pick whichever matches your posture. All three end up calling `powerbi.embed(container, config)` on the page.

| # | Approach | What lands in the repo | Trade-off |
|---|---|---|---|
| 1 | **Vendored script** *(recommended for Path B)* | `wwwroot/lib/powerbi/powerbi.min.js` checked in | One auditable file. No npm, no CDN, no build-pipeline coupling. You re-vendor on demand (rarely needed). |
| 2 | **CDN script tag** | A `<script src="https://cdn.jsdelivr.net/...">` line | Zero install. External runtime dependency on jsdelivr/unpkg. Fine for spikes; not great if your security posture forbids third-party CDNs. |
| 3 | **npm install** | `"powerbi-client": "^2.x"` in `package.json` | Same as Path A. Useful only if VDS frontend is bundled and you want TS types. |

### 6.3 Approach 1 — vendored script (Path B's natural fit)

#### Drop the file in once

Download `powerbi.min.js` from the official release once, e.g.:

```bash
# Run this once at the repo root, then commit the file.
curl -L -o wwwroot/lib/powerbi/powerbi.min.js \
  https://cdn.jsdelivr.net/npm/powerbi-client@2.23.1/dist/powerbi.min.js

# Optional but recommended — capture the SHA-384 for SRI integrity.
openssl dgst -sha384 -binary wwwroot/lib/powerbi/powerbi.min.js | openssl base64 -A
```

Pin the version in the file path or filename (`powerbi-2.23.1.min.js`) so future upgrades are explicit.

#### Wire it into the main app shell (Durandal)

The vendored file becomes a global `<script>` in the Durandal shell — typically `index.html` or whichever HTML the main app boots from. Drop it before the RequireJS data-main / app-bootstrap script so `window.powerbi` and `window['powerbi-client'].models` exist by the time any view model runs.

```html
<!-- index.html (main app shell) -->
<script src="~/lib/powerbi/powerbi.min.js"
        integrity="sha384-<paste-from-openssl-above>"
        crossorigin="anonymous"></script>

<!-- ...then the existing app bootstrap, e.g. -->
<script src="~/lib/require/require.js" data-main="app/main"></script>
```

No bundler, no `import`, no `node_modules`. The Durandal page-level view model that actually does the embed lives in **Path A §6.2** — that example is path-agnostic (calls `window.powerbi.embed(...)` and reads from `window['powerbi-client'].models`), so it works identically with the npm install of Path A or this vendored script of Path B.

#### Wire it into the admin app shell (Aurelia)

Same idea — drop the `<script>` into the admin app's shell HTML before Aurelia bootstraps. The admin app **does not need** `powerbi-client` for catalog management (Path A §6.3 covers the catalog flow with plain JSON CRUD); only include the script if you're building the optional preview from Path A §6.4.

```html
<!-- admin index.html -->
<script src="/lib/powerbi/powerbi.min.js"
        integrity="sha384-..."
        crossorigin="anonymous"></script>

<body aurelia-app="main">
    <!-- ... -->
</body>
```

If you later decide to npm-install `powerbi-client` and let the Aurelia bundler pick it up, only the script tag goes away — the view-model code is unchanged.

### 6.4 Approach 2 — CDN script

Identical to §6.3 except the `<script src>` points at a CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/powerbi-client@2.23.1/dist/powerbi.min.js"
        integrity="sha384-<from cdn>"
        crossorigin="anonymous"></script>
```

Use this for spikes and disposable demos. **Pin the version**, never use `@latest`.

### 6.5 Approach 3 — npm install (Path A parity)

Same as Path A §6 — included for completeness:

```bash
npm install powerbi-client
```

```javascript
import * as pbi from "powerbi-client";
// ...
```

If we ever decide Path B should still take this dep "for tooling reasons," nothing in the backend changes.

### 6.6 What about reimplementing the handshake?

Possible. Not recommended. The protocol lives across four open-source packages (`window-post-message-proxy`, `http-post-message`, `router`, `powerbi-models`), totalling several hundred LOC. Microsoft can change it across versions. You'd save ~30 KB gzipped in exchange for owning a moving target. Done as an exercise, not as a product decision.

If you ever do need to do it (e.g. embedding inside an environment that absolutely cannot run the official library), start by reading <https://github.com/microsoft/powerbi-client/blob/master/src/embed.ts> — the entry point — and the `service.ts` postMessage routing.

### 6.7 Recommendation

**Approach 1 (vendored script) for Path B's spike and any production rollout that keeps the Path B posture.** It honors the "no Microsoft packages in our dependency manifests" goal while not bankrupting us trying to rewrite an embed protocol Microsoft already gives away for free.

The actual Durandal page that consumes the loaded global is **Path A §6.2** (and **§6.3** / **§6.4** for Aurelia admin patterns). Those examples don't change between paths — `window.powerbi.embed(container, config)` is the same call whether `powerbi-client` got there via npm install (Path A's natural fit) or via vendored `<script>` tag (Path B's natural fit).

---

## 7. Validating the wire format with Postman (pre-spike)

This is the path that aligns most cleanly with the action item from the 04/24 meeting: **invoke a filtered report via Postman before any VDS code is written.** Path A's tutorial walks through C# code; Path B's wire format *is* the Postman contract.

### 7.1 Postman collection structure

```
VIR / Power BI Embed (Pre-Spike)
├── 1. Get Entra Token        (POST {{tenantId}} /oauth2/v2.0/token)
├── 2. Get Report             (GET groups/{{workspaceId}}/reports/{{reportId}})
└── 3. Generate Embed Token   (POST .../GenerateToken)
```

### 7.2 Environment variables

```
tenantId       = <tenant-guid>
clientId       = <client-id>
clientSecret   = <secret>            (encrypted)
workspaceId    = <workspace-guid>
reportId       = <report-guid>
accessToken    = <set by request 1's test script>
embedToken     = <set by request 3's test script>
embedUrl       = <set by request 2's test script>
datasetId      = <set by request 2's test script>
```

### 7.3 Request-1 test script (writes tokens into the env)

```javascript
pm.test("token returned", function () {
  pm.response.to.have.status(200);
  const body = pm.response.json();
  pm.expect(body.access_token).to.be.a("string");
  pm.environment.set("accessToken", body.access_token);
});
```

### 7.4 Request-3 body (filtering one user with one org)

```json
{
  "accessLevel": "View",
  "identities": [
    {
      "username":   "ashley.carter@taylormorrison.com",
      "roles":      ["VdsViewer"],
      "datasets":   ["{{datasetId}}"],
      "customData": "TM-CHARLOTTE"
    }
  ]
}
```

### 7.5 Visual check

Drop the `embedUrl` + `embedToken` from the Postman responses into a small static HTML page that loads `powerbi-client` from CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/powerbi-client@2/dist/powerbi.min.js"></script>
<div id="c" style="height:800px"></div>
<script>
  const config = {
    type:        'report',
    embedUrl:    '<paste-from-postman>',
    accessToken: '<paste-from-postman>',
    tokenType:   window['powerbi-client'].models.TokenType.Embed,
    permissions: window['powerbi-client'].models.Permissions.Read,
    viewMode:    window['powerbi-client'].models.ViewMode.View
  };
  powerbi.embed(document.getElementById('c'), config);
</script>
```

If that page renders Daniel's filtered sample report, Path B is proven end-to-end before we touch the VDS codebase.

> **Pre-spike value:** this Postman → static HTML rig is exactly what Rob asked for in the meeting — proof we can drive the flow without VDS code. It also doubles as the contract test we re-run any time the Power BI REST API changes shape.

---

## 8. Effective identity (same content as Path A)

The DAX side of RLS doesn't care which HTTP client put the identity on the wire. See Path A §7 for the rules:

- `username` matches whatever the RLS DAX expects (`USERNAME()` vs `USERPRINCIPALNAME()`).
- `roles` must reference roles defined in the dataset.
- `datasets` must include the dataset the report binds to.
- `customData` is a single string ≤1024 chars; we use it for a small key (probably `userId`) and let the dataset join to get the org list.

---

## 9. Error handling

The SDK in Path A maps non-2xx responses into typed exceptions. In Path B we do this ourselves, with intent: only the cases that matter to our caller surface as exceptions; the rest log + retry.

| HTTP | Cause | Path B handling |
|---|---|---|
| 401 (Entra) | Wrong client secret / expired secret | Throw `InvalidOperationException`; service is misconfigured. Surface to ops. |
| 401 (Power BI, after Entra 200) | Cached access token rotated server-side | Force-refresh via `EntraTokenCache`, retry once. |
| 403 (Power BI) | SP not added to the workspace, or workspace not on capacity | Throw with explicit message — won't self-heal. Surface in audit log. |
| 404 (Power BI) | Wrong workspace/report ID | Throw `KeyNotFoundException`; catalog is wrong. |
| 429 | Rate limit (per capacity, per hour) | Read `Retry-After` header; surface `503` with same header to caller. |
| 5xx | Power BI transient | Retry once with jitter, then surface. |

A small Polly policy (~10 LOC) handles 429/5xx if we want to avoid hand-rolled `if/while`. Polly is already in VDS.

---

## 10. What we accept by choosing Path B

- **We own the token cache.** Singleton + semaphore — stable, but our code, our bug if it breaks.
- **No automatic distributed cache.** For multi-instance deployments wanting shared token state, swap in Redis. (Same problem Path A defers — but Path A has a one-line switch via `AddDistributedTokenCaches`.)
- **No auto-instrumentation of Entra/Power BI calls.** We log what we choose to log. Slightly more work; arguably better signal-to-noise.
- **Brittle to Entra token-endpoint shape changes.** The `oauth2/v2.0/token` endpoint is stable (it's the OAuth 2.0 RFC); changes are essentially never. But if Entra ever forces a new flow (e.g. `client_assertion` instead of `client_secret`), we adapt directly. Path A would absorb this in an SDK upgrade.
- **No Microsoft IntelliSense for response types.** We define our own DTOs from the REST docs. Mitigation: lock the DTO file to the doc URL in a comment.

---

## 11. Spike checklist (Path B)

- [ ] Build the three-step Postman collection (§7). **This is the meeting's pre-spike action item.**
- [ ] Confirm filtered report renders via the static HTML rig.
- [ ] Add `PowerBiOptions.cs`, `EntraTokenCache.cs`, `RawRestPowerBIEmbedTokenService.cs` to the reporting project. No NuGet additions.
- [ ] Wire DI per §5.1.
- [ ] Add the endpoint per §5.4 with hard-coded IDs.
- [ ] Pull `powerbi-client` via npm; reuse the page from Path A's spike.
- [ ] Confirm: same filtered report renders end-to-end with no MSAL or PBI SDK loaded.
- [ ] Toggle effective identity off; confirm full data set visible (proves RLS, not SP perms, is doing the filter).

If all eight check, Path B ships the same product as Path A with zero new packages.

---

## 12. Files this path adds

```
VeoDesignStudio.Reporting/
├── PowerBI/
│   ├── EntraTokenCache.cs                  (Path B)
│   ├── RawRestPowerBIEmbedTokenService.cs  (Path B implementation)
│   ├── PowerBiOptions.cs                   (Path B variant — single section)
│   └── EmbedTokenResult.cs                 (shared with Path A)
├── Api/
│   └── ReportEmbedEndpoint.cs              (shared with Path A)
└── DependencyInjection/
    └── ReportingServiceCollectionExtensions.cs   (DI lines, path-aware)
```

To switch from Path A to Path B post-spike: replace `Microsoft.PowerBI.Api` + `Microsoft.Identity.Web` registrations with the two singletons above, drop both NuGet packages, ship.

---

## 13. When NOT to choose Path B

If any of these become true, Path A is the better choice:

- **The team finds itself reimplementing MSAL features** (distributed cache, Managed Identity, certificate auth, conditional access). MSAL is a non-trivial library; rewriting it isn't free. Path A leans on it for free.
- **Power BI ships a feature that adds new request shape complexity** (e.g. multi-identity tokens with nested capabilities). Hand-maintaining DTOs becomes burdensome.
- **A second app in the org needs to do the same thing.** If we're on Path B and want to share, we'd extract a small internal NuGet — at which point Path A's package was already that, with Microsoft maintaining it.

For the VIR feature in isolation, none of these apply today.
