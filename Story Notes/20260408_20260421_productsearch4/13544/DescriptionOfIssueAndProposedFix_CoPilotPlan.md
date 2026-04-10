# Plan: Improve `customImageLoaderBinding.js`

## File
`VeoDesignStudio/App/helpers/koCustomBindings/customImageLoaderBinding.js`

## Overview
`imageLoader` is a Knockout custom binding used in **36 places** across the homebuyer app. It handles loading states and error fallback for `<img>` elements. The binding is widely relied on but contains one definite bug, one silent bug, and several design issues that should be cleaned up.

---

## Current Behavior Summary

- **Primary value**: URL string for the image to load
- **Optional bindings**: `notFoundCss` (default: `"missingImage"`), `notFoundCssIpad` (default: `"missingImageIpad"`), `loaderCss` (default: `"simpleLoader"`), `callback` (optional function)
- **On load**: removes loader class, calls `callback(true)` if provided
- **On error**: adds `notFoundCss` + `notFoundCssIpad`, sets `src` to a 1×1 transparent GIF, calls `callback(false)`
- **On no/null src**: adds both not-found classes, sets `src` to transparent GIF

### Usage Stats (from surveying all 36 usages)
| Override | Count |
|----------|-------|
| `callback` override | 5 usages (`partImage`, `freeform`, `catalogCardDetails`, `catalogItemCard`, `photoZoom`) |
| `notFoundCss` override | **0** |
| `notFoundCssIpad` override | **0** |
| `loaderCss` override | **0** |

---

## Issues Found

### Issue 1 — **Bug: Event listener accumulation on rapid updates** ⚠️ (Highest Priority)

**What**: Knockout calls `update` every time the bound observable changes. Each call to `update` creates new `imageLoadedFunc` and `imageErrorFunc` closure instances and attaches them as event listeners. The old listeners are *not removed* before new ones are added — they only remove themselves after firing. If the observable changes N times before the first image load resolves, there will be N pending listener pairs on the element.

**Effect**: When the image finally loads, all N listeners fire:
- The callback (if provided) is called N times
- Loader/error CSS classes are toggled N times  
- In the worst case (e.g., `callback: repositionShare` in `photoZoom.html`), layout repositioning logic runs multiple times unexpectedly

**Where it matters most**: Components that change their image URL observable frequently (e.g., carousels, selection lists, cabinet wizards), and any component using a `callback`.

**Fix**: Store the current listener references on the element and remove them at the start of each `update` call before adding new ones.

```js
// At the start of update, before adding new listeners:
if (element._imageLoadedFunc) {
    element.removeEventListener("load", element._imageLoadedFunc, false);
    element.removeEventListener("error", element._imageErrorFunc, false);
}

// After creating imageLoadedFunc and imageErrorFunc:
element._imageLoadedFunc = imageLoadedFunc;
element._imageErrorFunc = imageErrorFunc;
```

---

### Issue 2 — **Bug: `loaderCss` class not removed when `src` becomes null/empty** ⚠️

**What**: Lines 38–39 remove `notFoundCss` and `notFoundCssIpad` at the start of `update` (to reset state from a previous update). However, `loaderCss` is **never removed** in the no-src branch (lines 42–55).

**Effect**: If an image URL observable changes from a valid URL (while still loading — spinner visible) to `null`/`undefined`, the spinner class (`simpleLoader`) stays on the element indefinitely. The element shows both the missing-image placeholder AND the loading spinner simultaneously.

**Fix**: Remove `loaderCss` in the no-src branch, alongside the existing not-found class removals:

```js
// In the no-src branch, before return:
element.classList.remove(loaderCss);
element.classList.add(notFoundCss);
// ...
```

---

### Issue 3 — **Design: `notFoundCssIpad` is not device-aware and adds no value** 

**What**: The binding always applies `notFoundCssIpad` (default: `"missingImageIpad"`) on error and on no-src, on **every device** — desktop, mobile, and iPad. The name implies iPad-specificity, but the JS has no user-agent check. No usage in the codebase overrides this parameter (0/36 usages), meaning it is always the default `"missingImageIpad"`.

**Effect**: The binding adds a misleading iPad-specific class to every image on every device on error. The `.missingImageIpad` CSS class is not defined in `_missingImage.scss` or `_loader.scss` — it may have no effect at all currently, which makes it dead code in the JS.

**Recommendation**: 
- Remove the `notFoundCssIpad` binding parameter entirely from the JS
- Remove the `notFoundCssIpad` class toggling from the `update` function
- If iPad-specific styling is genuinely needed, add a `@media` query to `_missingImage.scss` instead

---

### Issue 4 — **Design: Inconsistent null-guard on `notFoundCss`**

**What**: The no-src path (lines 43–48) wraps `classList.add(notFoundCss)` and `classList.add(notFoundCssIpad)` in `if (notFoundCss)` / `if (notFoundCssIpad)` guards. The error path (lines 74–75) does **not** guard — it calls `element.classList.add(notFoundCss)` unconditionally.

**Effect**: If someone passes `notFoundCss: null` or `notFoundCss: ""` (a valid override to disable the class), the no-src path handles it safely but the error path throws or adds an empty class string.

**Fix**: Wrap error-path class additions in the same null/empty guards:

```js
if (notFoundCss) {
    element.classList.add(notFoundCss);
}
```

---

### Issue 5 — **Design: Legacy AMD/RequireJS module format**

**What**: The file uses `require(['knockout'], function(ko) { ... })` — the older AMD pattern used before the project adopted TypeScript. All other new bindings in the `koCustomBindings` folder are either `.ts` or newer `.js` patterns.

**Recommendation**: Convert to a TypeScript module (`.ts`) file consistent with the rest of the codebase, following the same pattern as other bindings in the folder. This would also enable proper type checking and IntelliSense.

This is a lower-priority improvement that can be done independently of the bug fixes.

---

## Proposed Improved Implementation

The following is a corrected version of the binding with all bugs and Issues 1–4 addressed:

```js
require(['knockout'], function (ko) {
    "use strict";

    if (ko && ko.bindingHandlers && ko.bindingHandlers.imageLoader) {
        return;
    }

    var smallDataUri = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

    ko.bindingHandlers.imageLoader = {

        update: function (element, valueAccessor, allBindings) {

            var src = ko.unwrap(valueAccessor()),
                notFoundCss = allBindings.has("notFoundCss") ? allBindings.get("notFoundCss") : "missingImage",
                loaderCss   = allBindings.has("loaderCss")   ? allBindings.get("loaderCss")   : "simpleLoader",
                callback    = allBindings.has("callback")    ? allBindings.get("callback")    : undefined;

            if (element.nodeName !== "IMG") {
                return;
            }

            // ISSUE 1 FIX: Remove any previously registered listeners before adding new ones
            if (element._imageLoadedFunc) {
                element.removeEventListener("load",  element._imageLoadedFunc, false);
                element.removeEventListener("error", element._imageErrorFunc,  false);
                element._imageLoadedFunc = null;
                element._imageErrorFunc  = null;
            }

            // Reset state from previous update
            element.classList.remove(notFoundCss);

            if (!src) {
                // ISSUE 2 FIX: Remove loader class when src becomes null/empty
                element.classList.remove(loaderCss);

                // ISSUE 4 FIX: Guard is already present here — keep it
                if (notFoundCss) {
                    element.classList.add(notFoundCss);
                }

                element.src = smallDataUri;
                return;
            }

            if (loaderCss) {
                element.classList.add(loaderCss);
            }

            var imageLoadedFunc = function () {
                element.classList.remove(loaderCss);
                element.removeEventListener("load",  imageLoadedFunc, false);
                element.removeEventListener("error", imageErrorFunc,  false);
                element._imageLoadedFunc = null;
                element._imageErrorFunc  = null;
                if (callback) { callback(true); }
            };

            var imageErrorFunc = function () {
                element.classList.remove(loaderCss);

                // ISSUE 4 FIX: Guard on error path, consistent with no-src path
                if (notFoundCss) {
                    element.classList.add(notFoundCss);
                }

                element.removeEventListener("load",  imageLoadedFunc, false);
                element.removeEventListener("error", imageErrorFunc,  false);
                element._imageLoadedFunc = null;
                element._imageErrorFunc  = null;
                if (callback) { callback(false); }
                element.src = smallDataUri;
            };

            // ISSUE 1 FIX: Store references so next update can clean them up
            element._imageLoadedFunc = imageLoadedFunc;
            element._imageErrorFunc  = imageErrorFunc;

            element.addEventListener("load",  imageLoadedFunc, false);
            element.addEventListener("error", imageErrorFunc,  false);

            element.src = src;
        }

    };

    return {};
});
```

### Changes from original:
| Line(s) | Change | Reason |
|---------|--------|--------|
| Before `classList.remove` | Remove previously stored listeners via `element._imageLoadedFunc/ErrorFunc` | Issue 1 — prevents listener accumulation |
| `if (!src)` branch | Add `element.classList.remove(loaderCss)` | Issue 2 — clears spinner on null src |
| `if (!src)` branch | Remove `notFoundCssIpad` toggling | Issue 3 — remove iPad-specific class |
| Error path | Remove `notFoundCssIpad` toggling | Issue 3 — remove iPad-specific class |
| Error path | Wrap `classList.add(notFoundCss)` in null guard | Issue 4 — consistent null guard |
| After creating handlers | `element._imageLoadedFunc = ...; element._imageErrorFunc = ...` | Issue 1 — store for next update |
| Inside handlers | Clear `element._imageLoadedFunc/ErrorFunc = null` after self-removal | Issue 1 — cleanup after firing |

---

## CSS Change (if `notFoundCssIpad` is removed per Issue 3)

If iPad-specific missing image styling is genuinely needed, add to `_missingImage.scss`:

```scss
@media only screen and (min-device-width: 768px) and (max-device-width: 1024px) {
    .missingImage {
        // iPad-specific overrides here
    }
}
```

---

## Implementation Order

1. **Fix Issue 1** (listener accumulation) — highest risk of user-visible bugs
2. **Fix Issue 2** (loaderCss not cleared) — visible spinner persistence bug
3. **Fix Issue 4** (null guard inconsistency) — defensive correctness
4. **Remove `notFoundCssIpad`** (Issue 3) — confirm `.missingImageIpad` is unused first (grep all SCSS for the class definition)
5. **TypeScript conversion** (Issue 5) — separate task, lower priority


---

## Symptom Analysis: Sporadic Org Missing Image Fallback

### Described Symptom
Fetching a specific organization's missing image sometimes fails quietly and falls back to the CSS hard-coded image, causing inconsistency.

### Server-Side: Two Fallback Paths in `ImageController`

There are actually two distinct server-side responses that affect what the `<img>` element sees:

**`GET /api/Image/organizations/{orgId}/missingImage`:**

| Scenario | Server returns | `<img>` receives | Visual result |
|----------|---------------|-----------------|---------------|
| Org has MISSING_IMAGE with data | 200 + binary | Org image loads | ✅ Org image |
| Org has MISSING_IMAGE record but `ImageData == null` (line 163) | 404 NotFound | HTTP error | ❌ CSS fallback |
| Org has no MISSING_IMAGE record (EntityNotFoundException) | 302 → `/api/Image/missingImages/source_image` | Follows redirect | ↓ |
| ↳ Global missing image has data | 200 + binary | Global image loads | ✅ Global image |
| ↳ Global missing image entity exists but `SourceImage == null` (line 87) | 404 NotFound | HTTP error | ❌ CSS fallback |
| ↳ Global missing image entity not found | 302 → `/content/images/missing-image.png` | Static PNG loads | ✅ Static PNG |

**Key finding**: Line 163 in `ImageController` returns a bare `NotFound()` when an org's image record exists but has no binary data uploaded. This is a legitimate server-side gap that can cause the CSS fallback — *silently*, because the binding swallows the 404 without surfacing it to the application.

---

### Binding Issue 1 Contribution: How the Race Condition Produces the Same Symptom

Most components load their observable asynchronously: the image URL starts as `null`, then updates to the org URL once data arrives. In Knockout, if *anything* causes a re-evaluation of the binding (parent observable change, computed dependency, etc.), `update` fires again.

**The race that produces a false fallback:**

```
Step 1: update(null)
  → no listeners added, notFoundCss applied, element.src = smallDataUri (loads instantly)

Step 2: update("/api/Image/organizations/{orgId}/missingImage")
  → notFoundCss removed, loaderCss added, **Listener Set A registered**, src = orgUrl
  → HTTP request starts (in flight)...

Step 3: update(null) [observable briefly resets — e.g., parent re-renders]
  → notFoundCss re-applied, element.src = smallDataUri
  → **Listener Set A is still registered**

Step 4: smallDataUri loads instantly
  → **Listener Set A's imageLoadedFunc fires**
    → removes loaderCss (spinner gone)
    → calls callback(true)  ← FALSE POSITIVE: signals success
    → Listener Set A removes itself

Result: element shows CSS fallback (notFoundCss applied in Step 3)
        binding is in "done" state (no listeners, callback fired as success)
        the orgUrl HTTP response, when it eventually arrives, has no listener to handle it

```

This is "failing quietly": the binding reports success (no error state, callback fires as true), but the displayed image is the CSS fallback, not the org image.

**Why it's sporadic**: The race occurs only when a null-transition `update` fires between the orgUrl `update` and the HTTP response arriving. Fast network or cached responses may resolve before any re-evaluation, so the bug only manifests under certain timing conditions.

---

### Verdict: Are the Issues Related?

**Issue 1 (listener accumulation) directly causes the sporadic symptom.** The exact mechanism is:
- `update(null)` fires while a previous `update(orgUrl)` has listeners registered and an HTTP request in flight
- Setting `element.src = smallDataUri` triggers an immediate load event that fires the stale listener
- The binding enters a "done" state while showing the CSS fallback

**The server-side `NotFound()` on null `ImageData` (line 163) is a separate but compounding issue.** Even if Issue 1 is fixed, an org with a null `ImageData` row will still silently fall back to CSS. This should also be addressed.

---

### Additional Fix Recommended: `ImageController` Line 163

When `organizationImage.ImageData == null`, returning `NotFound()` is ambiguous — the record exists but has no data. This falls through to the binding's error handler silently. Consider:

```csharp
// Instead of:
return NotFound();

// Consider redirecting to the global missing image, consistent with the exception path:
return Redirect(ImageUrlHelper.GetMissingImageUrl());
```

This would make the "no data" case behave the same as the "no record" case, and would give the user a proper fallback image instead of triggering the CSS fallback.

