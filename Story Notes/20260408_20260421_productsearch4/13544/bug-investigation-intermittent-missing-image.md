# Bug Investigation: Intermittent Missing Image on Non-Estimated Item Cards

## 🔖 Checkpoint — 2026-04-09

### What's done
| Item | File |
|------|------|
| ✅ Retry logic (3 attempts, linear backoff) | `GetGpcProductDefaultImage.cs` |
| ✅ Content-type validation (`IsValidImage`) | `GetGpcProductDefaultImage.cs` |
| ✅ Exception + warning logging via `IVdsLogger` | `GetGpcProductDefaultImage.cs` |
| ✅ Postman request — Get GPC Product Default Image | `VDS.postman_collection.json` |
| ✅ Fix listener accumulation (Issue 1) | `customImageLoaderBinding.js` |
| ✅ Fix `loaderCss` not cleared on null src (Issue 2) | `customImageLoaderBinding.js` |
| ✅ Remove `notFoundCssIpad` dead param (Issue 3) | `customImageLoaderBinding.js` |
| ✅ Null guard on error path (Issue 4) | `customImageLoaderBinding.js` |
| ✅ `ImageController` — log warning + redirect on null `ImageData` for `MISSING_IMAGE` category | `ImageController.cs` |
| ✅ Unit tests — `GpcProductDataContext` (single `It.IsAny` mock, pipeline dispatch, combined validation) | `GpcProductDataContext.cs` (new) |
| ✅ Unit tests — `GetGpcProductDefaultImageTests` (13 tests: invalid inputs, valid scenarios, retry, logging) | `GetGpcProductDefaultImageTests.cs` (new) |
| ✅ Fix `.Result` blocking calls → `await` across all methods | `GpcRepository.cs` |

### What's next
| Item | File |
|------|------|
| ⬜ `ImageController` — redirect other image categories on null `ImageData` (currently still `NotFound()`) | `ImageController.cs` |
| ⬜ Convert `customImageLoaderBinding.js` to TypeScript (Issue 5 — lower priority) | `customImageLoaderBinding.js` → `.ts` |
| ⬜ Migrate to `IHttpClientFactory` (follow-up story) | `GpcRepository.cs` |

---

## Problem Statement

Users sporadically see the **"PHOTO UNAVAILABLE"** placeholder on item cards that have valid GPC images. The bug is intermittent and difficult to reproduce, suggesting a race condition, a timing-sensitive network issue, or corrupted/non-image data flowing through the pipeline undetected.

---

## Code Traced

| Layer | File | Method |
|-------|------|--------|
| Template | `VeoDesignStudio\App\components\nonEstimatedItemsView\subcomponents\nonEstimatedItemCard\nonEstimatedItemCard.html` | Line 17 — `imageLoader` binding |
| Front-end binding | `VeoDesignStudio\App\helpers\koCustomBindings\customImageLoaderBinding.js` | `ko.bindingHandlers.imageLoader.update` |
| Model | `VeoDesignStudio\App\components\nonEstimatedItemsView\models\nonEstimatedItem.ts` | `NonEstimatedItem` constructor |
| Controller | `VeoDesignStudio\Controllers\Options\NonEstimatedOptionController.cs` | `GetNonEstimatedOptionGpcDefaultImage` |
| Service | `BuildOnTechnologies.VDS.Services\Gpc\GetGpcProductDefaultImage.cs` | `_Invoke` |
| Repository | `BuildOnTechnologies.VDS.Legacy.Dal\Repositories\GpcRepository.cs` | `GetGpcProductDefaultImage` |

---

## Root Cause Analysis

### 🔴 Root Cause 1 (Primary) — GPC Response Content Not Validated
**File:** `GpcRepository.cs` — `GetGpcProductDefaultImage`

```csharp
var apiResponse = await MakeHttpRequest(url, method);

var image = apiResponse.Content.ReadAsByteArrayAsync().Result;

return new GpcImage()
{
    ContentType = apiResponse.Content.Headers.ContentType.MediaType,
    ImageData = image,
};
```

`MakeHttpRequest` correctly throws on non-2xx HTTP responses. However, when GPC returns **HTTP 200 with non-image content** (e.g., an HTML error page, an empty body, or a truncated/corrupted byte stream), the code blindly reads and returns those bytes. The controller then forwards them to the browser as a `FileContentResult`.

**The browser receives bytes it cannot decode as an image → fires an `error` event → `customImageLoaderBinding` applies the `missingImage` CSS → "PHOTO UNAVAILABLE" appears.**

Three unguarded failure paths:
1. `ContentType` header is `null` → `NullReferenceException` on `.MediaType`
2. `MediaType` is `text/html` or another non-image type (GPC error page returned as HTTP 200)
3. `ImageData` is zero bytes (empty body)

Paths 1 and 3 cause an exception that is silently swallowed in the service layer (see Root Cause 2). Path 2 quietly returns a `GpcImage` whose bytes aren't actually an image — the browser rejects it.

---

### 🔴 Root Cause 2 (Primary) — Silent Exception Swallowing, No Logging
**File:** `GetGpcProductDefaultImage.cs` — `_Invoke`

```csharp
catch
{
    // Do not throw exception and return missing image
}

return null;
```

Every exception — network timeout, `NullReferenceException` from a null `ContentType` header, any other failure — is **silently discarded with no logging**. This makes the bug completely invisible in production diagnostics. We cannot tell how often this path is hit or what is causing it without adding logging.

---

### 🟡 Root Cause 3 (Secondary) — Stale Event Listener Accumulation in `customImageLoaderBinding.js`
**File:** `customImageLoaderBinding.js` — `update`

```javascript
element.addEventListener("load", imageLoadedFunc, false);
element.addEventListener("error", imageErrorFunc, false);

element.src = src;
```

The `update` handler registers new `load` and `error` listeners every time it is called, but **never removes previously registered listeners before adding new ones**. The listeners only remove themselves *after* they fire.

If `update` runs again (e.g., because a parent KO observable updates) before the first `load`/`error` fires:
- Old `imageErrorFunc` from the previous call is still attached.
- Some browsers fire an `error` event for the abandoned `src` request when `src` is reassigned.
- That stale handler fires → `missingImage` CSS is applied → the card shows "PHOTO UNAVAILABLE" **even though the new image loads successfully moments later**.

This explains the **"seldom and somewhat random"** nature: it depends on browser implementation details and network/JS timing.

---

### 🟢 Contributing Issue — `.Result` Blocking Calls in `GpcRepository`
**File:** `GpcRepository.cs`

```csharp
var image = apiResponse.Content.ReadAsByteArrayAsync().Result;
// Also present in GetGpcProduct and GetGpcProducts
```

Using `.Result` (sync-over-async) on `Task`-returning methods can cause **thread-pool deadlocks** under load in ASP.NET. Under high concurrency, GPC requests could stall, timeout, and ultimately hit the silent exception path described above.

---

### 🟢 Contributing Issue — `HttpClient` Instantiated Per-Repository Instance
**File:** `GpcRepository.cs`

```csharp
private readonly HttpClient _httpClient = new HttpClient();
```

Not using `IHttpClientFactory` means no connection pooling or DNS refresh. Under load this can lead to **socket exhaustion**, causing GPC image requests to fail.

---

## Plan of Action

### Phase 1 — Instrument to Confirm (Zero Behavior Risk)

**1. Add structured logging in `GpcRepository.GetGpcProductDefaultImage`**

Log the `ContentType`, byte length, and the GPC URL for every response received. This will surface in production whether GPC is returning non-image or empty data.

**2. Add exception logging in `GetGpcProductDefaultImage._Invoke` catch block**

Replace the silent `// Do not throw...` comment with a structured log call recording exception type, message, and `gpcId`. This is the single highest-value change for diagnosing the bug with zero risk.

---

### Phase 2 — Fix the Backend Root Cause

**3. Validate GPC response content in `GpcRepository.GetGpcProductDefaultImage`**

Before constructing and returning the `GpcImage`, add guards:
- Check `ContentType` header is not null.
- Check `MediaType` starts with `image/`.
- Check `ImageData.Length > 0`.

If any check fails, throw an `InvalidOperationException` with a descriptive message. The service layer's `catch` will handle it and return `null`, which causes the controller to redirect to the org missing image — the correct fallback.

**4. Fix `.Result` blocking calls throughout `GpcRepository`**

Replace all `.Result` calls with `await` to eliminate the deadlock risk under load:
```csharp
// Before
var image = apiResponse.Content.ReadAsByteArrayAsync().Result;
// After
var image = await apiResponse.Content.ReadAsByteArrayAsync();
```

---

### Phase 3 — Fix the Frontend Race Condition

**5. Fix stale event listener accumulation in `customImageLoaderBinding.js`**

Store the previous handler references on the element so they can be removed at the start of the next `update` call:
```javascript
// At start of update, remove any stale handlers
if (element._imageLoadedFunc) {
    element.removeEventListener("load", element._imageLoadedFunc, false);
    element.removeEventListener("error", element._imageErrorFunc, false);
}
// ... define new handlers ...
element._imageLoadedFunc = imageLoadedFunc;
element._imageErrorFunc = imageErrorFunc;
// ... add listeners and set src ...
```

---

### Phase 4 — Structural Follow-up (Optional / Separate Story)

**6. Migrate `GpcRepository` to `IHttpClientFactory`**

Register a named `HttpClient` via `IHttpClientFactory` in DI for GPC API calls. This enables connection pooling, DNS refresh, and consistent timeout configuration.

---

## Files to Change

| File | Changes | Status |
|------|---------|--------|
| `BuildOnTechnologies.VDS.Services\Gpc\GetGpcProductDefaultImage.cs` | Retry logic, content-type validation, exception logging | ✅ Done |
| `BuildOnTechnologies.VDS.Services.Tests\Gpc\GetGpcProductDefaultImageTests.cs` | New unit test class covering retry, validation, and logging behaviour | ✅ Done |
| `BuildOnTechnologies.VDS.Services.Tests\Gpc\GpcProductDataContext.cs` | New DataContext with `It.IsAny` mock dispatch, per-scenario response pipeline, combined validation | ✅ Done |
| `VeoDesignStudio\Postman\VDS.postman_collection.json` | New "Get GPC Product Default Image" request in nonEstimatedOptions folder | ✅ Done |
| `VeoDesignStudio\App\helpers\koCustomBindings\customImageLoaderBinding.js` | Issues 1–4 fixed: listener accumulation, loaderCss on null, notFoundCssIpad removed, null guard | ✅ Done |
| `VeoDesignStudio\Controllers\Api\ImageController.cs` | Log warning + redirect for MISSING_IMAGE category when ImageData is null | ✅ Done (partial — other categories still return NotFound) |
| `BuildOnTechnologies.VDS.Legacy.Dal\Repositories\GpcRepository.cs` | Fix `.Result` → `await` blocking calls | ✅ Done |

---

## Implementation Order

```
Phase 1 (logging) → confirmed via service + ImageController work      ✅ DONE
Phase 2 (backend fix) → GetGpcProductDefaultImage.cs                  ✅ DONE
Phase 3 (frontend fix) → customImageLoaderBinding.js Issues 1–4       ✅ DONE
Phase 4 (unit tests) → GetGpcProductDefaultImageTests.cs               ✅ DONE
Phase 5 (GpcRepository async) → fix .Result blocking calls             ✅ DONE
Phase 6 (ImageController full fix) → null ImageData redirect all cats  ⬜ TODO
Phase 7 (TypeScript conversion) → customImageLoaderBinding.js → .ts    ⬜ TODO (low priority)
Phase 8 (IHttpClientFactory) → separate follow-up story                ⬜ TODO
```

**Postman collection** — ✅ Done. "Get GPC Product Default Image" request added to the nonEstimatedOptions folder.
Tests included: status 200, `Content-Type` starts with `image/`, response body is non-empty.

---

## Changes Made

### ✅ `BuildOnTechnologies.VDS.Services\Gpc\GetGpcProductDefaultImage.cs`
**Completed: 2026-04-09**

#### What changed

**Before** — single attempt, null check only, all exceptions silently swallowed with no logging:
```csharp
public GetGpcProductDefaultImage(IGpcRepository gpcRepository)
{
    _gpcRepository = gpcRepository;
}

protected override async Task<GpcImage> _Invoke()
{
    try
    {
        var image = await _gpcRepository.GetGpcProductDefaultImage(_gpcId, _imageSize);

        if (image != null)
        {
            return image;
        }
    }
    catch
    {
        // Do not throw exception and return missing image
    }

    return null;
}
```

**After** — 3-attempt retry loop with content-type validation, warning/error logging, and linear backoff:
```csharp
private const int MaxAttempts = 3;

public GetGpcProductDefaultImage(IGpcRepository gpcRepository, IVdsLogger<GetGpcProductDefaultImage> logger)
{
    _gpcRepository = gpcRepository;
    _logger = logger;
}

protected override async Task<GpcImage> _Invoke()
{
    for (int attempt = 1; attempt <= MaxAttempts; attempt++)
    {
        try
        {
            var image = await _gpcRepository.GetGpcProductDefaultImage(_gpcId, _imageSize);

            if (IsValidImage(image))
            {
                return image;
            }

            _logger.LogWarning(
                "GPC image response failed content validation for gpcId={0}, imageSize={1} on attempt {2}/{3}. ContentType={4}, DataLength={5}",
                _gpcId, _imageSize, attempt, MaxAttempts,
                image?.ContentType ?? "(null)",
                image?.ImageData?.Length.ToString() ?? "(null)");
        }
        catch (Exception ex)
        {
            _logger.LogError(
                "Exception retrieving GPC image for gpcId={0}, imageSize={1} on attempt {2}/{3}. {4}: {5}",
                _gpcId, _imageSize, attempt, MaxAttempts,
                ex.GetType().Name, ex.Message);
        }

        if (attempt < MaxAttempts)
        {
            await Task.Delay(TimeSpan.FromMilliseconds(200 * attempt));
        }
    }

    _logger.LogError(
        "All {0} attempts failed to retrieve a valid GPC image for gpcId={1}, imageSize={2}. Falling back to missing image.",
        MaxAttempts, _gpcId, _imageSize);

    return null;
}

private static bool IsValidImage(GpcImage image)
{
    return image != null
        && !string.IsNullOrWhiteSpace(image.ContentType)
        && image.ContentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase)
        && image.ImageData != null
        && image.ImageData.Length > 0;
}
```

#### Key decisions
- **`IVdsLogger<GetGpcProductDefaultImage>` injected** — already registered as an open generic (`AddTransient(typeof(IVdsLogger<>), typeof(VdsLogger<>))`) in both `VeoDesignStudio\Startup.cs` and `VeoDesignStudio.Integration.Api\Startup.cs`. No DI registration changes required.
- **`IsValidImage` checks `ContentType` not just null** — guards against null `ContentType` header, non-image MIME types (e.g., `text/html` error pages returned as HTTP 200), and zero-length `ImageData`.
- **Retry with linear backoff** — 200ms after attempt 1, 400ms after attempt 2. `MaxAttempts = 3` is a constant for easy tuning.
- **Warning log on bad content** — records the actual `ContentType` and byte length returned by GPC so production logs will surface exactly what is wrong.
- **Error log on exception** — replaces the silent catch with exception type and message, making previously invisible failures visible.
- **Final error log after exhausting all retries** — clear signal before the `null` fallback causes the controller to redirect to the org missing image.

---

### ✅ `VeoDesignStudio\Postman\VDS.postman_collection.json`
**Completed: 2026-04-09**

Added **"Get GPC Product Default Image"** request to the `nonEstimatedOptions` folder.

- **Method:** `GET`
- **URL:** `{{url}}/api/gpc/products/{{gpc_id}}/images/first?organizationId={{organization_id}}&imageSize=full`
- **Auth:** No `Authorization` header required — endpoint is decorated `[AllowAnonymous]`
- **Test scripts:**
  - Status code is 200
  - `Content-Type` response header matches `image/*`
  - Response body is non-empty (`responseSize > 0`)

> **Variables needed:** `gpc_id` (a valid GPC product ID), `organization_id` (the org GUID for the missing image fallback).

---

### ✅ `BuildOnTechnologies.VDS.Services.Tests\Gpc\GetGpcProductDefaultImageTests.cs` + `GpcProductDataContext.cs`
**Completed: 2026-04-09**

Two new files created under `BuildOnTechnologies.VDS.Services.Tests\Gpc\`. All 13 tests pass.

#### `GpcProductDataContext` — key design decisions

- **Single `It.IsAny<string>()` repository setup** following the `OIDCContext` pattern. A `Dictionary<string, Queue<Func<Task<GpcImage>>>>` (response pipeline) maps each scenario gpcId to an ordered queue of Task-returning lambdas. The `Returns` lambda dequeues the next response, using `Task.FromException` for throw scenarios — no `SetupSequence` per scenario needed.
- **`_expectedCallCounts` lookup table** registers the exact number of repository calls expected per scenario (1× for first-attempt success, 2× for one-retry-then-success, 3× for all-fail).
- **`ValidateGetGpcProductDefaultImageReturn(result, gpcId)`** is a single combined assertion method covering all three concerns:
  1. Return value (correct image data, or `null` for fallback scenarios)
  2. Repository called with the exact `gpcId`/`imageSize` strings the expected number of times
  3. Logger assertions per scenario — precise `Times.Exactly`/`Times.Never` for `LogWarning` (content validation failures) and `LogError` (per-exception + exhausted-retries message)

#### Test inventory (13 tests)

| # | Test | Covers |
|---|------|--------|
| 1 | `UseCase_ThrowsException_WhenNotConfigured` | Inherited from `BaseUseCaseTests` |
| 2 | `UseCase_ThrowsExceptions` TestCase1 | Null `gpcId` → `ArgumentNullException` |
| 3 | `UseCase_ThrowsExceptions` TestCase2 | Whitespace `gpcId` → `ArgumentNullException` |
| 4 | `UseCase_ThrowsExceptions` TestCase3 | Null `imageSize` → `ArgumentNullException` |
| 5 | `UseCase_ReturnsValidResponse` TestCase1 | Valid JPEG on attempt 1; repo called once; no logs |
| 6 | `UseCase_ReturnsValidResponse` TestCase2 | Valid PNG on attempt 1; repo called once; no logs |
| 7 | `UseCase_ReturnsValidResponse` TestCase3 | HTML on attempt 1 → valid JPEG on attempt 2; 1 warning; no error |
| 8 | `UseCase_ReturnsValidResponse` TestCase4 | Exception on attempt 1 → valid JPEG on attempt 2; 1 error; no warning |
| 9 | `UseCase_ReturnsValidResponse` TestCase5 | All 3 return HTML content type → `null`; 3 warnings; 1 exhausted-retries error |
| 10 | `UseCase_ReturnsValidResponse` TestCase6 | All 3 throw → `null`; 3 per-exception errors + 1 exhausted-retries error; no warnings |
| 11 | `UseCase_ReturnsValidResponse` TestCase7 | All 3 return null `ContentType` → `null`; 3 warnings; 1 exhausted-retries error |
| 12 | `UseCase_ReturnsValidResponse` TestCase8 | All 3 return empty `ImageData` → `null`; 3 warnings; 1 exhausted-retries error |
| 13 | `UseCase_ReturnsValidResponse` TestCase9 | All 3 return null `GpcImage` → `null`; 3 warnings; 1 exhausted-retries error |

---

### ✅ `VeoDesignStudio\App\helpers\koCustomBindings\customImageLoaderBinding.js`
**Completed (verified 2026-04-09) — see also: `DescriptionOfIssueAndProposedFix_CoPilotPlan.md`**

All four bugs/design issues from `DescriptionOfIssueAndProposedFix_CoPilotPlan.md` are confirmed applied in the current file:

| Issue | Description | Status |
|-------|-------------|--------|
| Issue 1 | Stale event listener accumulation on rapid `update` calls | ✅ Fixed — `element._imageLoadedFunc/ErrorFunc` stored on element; removed at start of each `update` and nulled after firing |
| Issue 2 | `loaderCss` (spinner) not removed when `src` becomes `null`/`undefined` | ✅ Fixed — `element.classList.remove(loaderCss)` added in the no-src branch |
| Issue 3 | `notFoundCssIpad` dead parameter applied unconditionally on all devices | ✅ Fixed — parameter and all toggling removed entirely from the binding |
| Issue 4 | Inconsistent null guard on `notFoundCss` between no-src and error paths | ✅ Fixed — error path now wrapped in `if (notFoundCss)` guard, matching the no-src path |
| Issue 5 | Legacy AMD `require([...])` module format | ⬜ Not done — TypeScript conversion is a separate lower-priority task |

#### Still open from `DescriptionOfIssueAndProposedFix_CoPilotPlan.md`

**`ImageController.cs` null `ImageData` handling (line 162 area):**
The plan recommended redirecting to the global missing image when an org image record exists but `ImageData == null`. The fix was **partially applied**:
- ✅ Warning logged when `ImageData` is null
- ✅ Redirects to `GetMissingImageUrl()` when `imageCategory == "MISSING_IMAGE"`
- ⬜ **Still returns `NotFound()` for all other `imageCategory` values** — these will still trigger the CSS fallback in the browser instead of gracefully falling back to a proper image

---

### ✅ `BuildOnTechnologies.VDS.Legacy.Dal\Repositories\GpcRepository.cs`
**Completed: 2026-04-09**

Replaced all sync-over-async `.Result` blocking calls with `await` to eliminate thread-pool deadlock risk under load.

| Method | Before | After |
|--------|--------|-------|
| `GetGpcProduct` | `ReadAsStringAsync().Result` | `await ReadAsStringAsync()` |
| `GetGpcProducts` | `ReadAsStringAsync().Result` | `await ReadAsStringAsync()` |
| `GetDataFromGpcDocument` | `ReadAsByteArrayAsync().Result` | `await ReadAsByteArrayAsync()` |
| `MakeHttpRequest` (error path) | `ReadAsStringAsync().Result` | `await ReadAsStringAsync()` |

`GetGpcProductDefaultImage` had already been fixed to use `await` (applied by the developer directly).
