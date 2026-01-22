# NotFound() Method Bug Analysis & Impact Assessment

## Issue Summary
The `NotFound()` method in `BaseApiController.cs` (Line 88-92) is incorrectly returning a `BadRequest` (HTTP 400) response instead of a `NotFound` (HTTP 404) response.

```csharp
protected BadRequestObjectResult NotFound(string responseMessage)
{
    return BadRequest(new { Message = responseMessage });
}
```

**Problem**: This method returns `BadRequest()` which sends HTTP 400, but it should return HTTP 404.

---

## Endpoints Using NotFound()

### 1. **CabinetSelectionsController**
   
#### a) GetCabinetPartImage
- **Route**: `GET api/CabinetSelections/GetCabinetPartImage`
- **Location**: Line 142 in CabinetSelectionsController.cs
- **Purpose**: Returns image for a cabinet part; returns NotFound if no image exists
- **Attributes**: `[AllowAnonymous]`
- **Frontend Usage**: Used in `cabinetSelectionWizardManager.js` (Line 407)
  - Referenced in `getCompositeCabinetImageUrl()` method
  - Creates image URLs: `ajax.GetWebApiActionUrl("CabinetSelections", "GetCabinetPartImage", { id: part.PartNo });`
  
#### b) GetCabinetDoorStyleImage
- **Route**: `GET api/CabinetSelections/GetCabinetDoorStyleImage`
- **Location**: Line 172 in CabinetSelectionsController.cs
- **Purpose**: Returns image for cabinet door style; returns NotFound if no image exists
- **Attributes**: `[AllowAnonymous]`
- **Frontend Usage**: Used in `cabinetSelectionWizardManager.js` (Line 160)
  - Referenced as image URL in cabinet selection UI

#### c) GetCabinetSpeciesImage
- **Route**: `GET api/CabinetSelections/GetCabinetSpeciesImage`
- **Location**: Line 202 in CabinetSelectionsController.cs
- **Purpose**: Returns image for cabinet species; returns NotFound if no image exists
- **Attributes**: `[AllowAnonymous]`
- **Frontend Usage**: Used in `cabinetSelectionWizardManager.js` (Line 213)
  - Referenced in `_getUniqueSpeciesFromParts()` method

#### d) GetCabinetColorImage
- **Route**: `GET api/CabinetSelections/GetCabinetColorImage`
- **Location**: Line 232 in CabinetSelectionsController.cs
- **Purpose**: Returns image for cabinet color; returns NotFound if no image exists
- **Attributes**: `[AllowAnonymous]`
- **Frontend Usage**: Used in `cabinetSelectionWizardManager.js` (Line 267)
  - Referenced in `_getUniqueColorsFromParts()` method

#### e) GetCabinetDoorPanelImage
- **Route**: `GET api/CabinetSelections/GetCabinetDoorPanelImage`
- **Location**: Line 262 in CabinetSelectionsController.cs
- **Purpose**: Returns image for cabinet door panel; returns NotFound if no image exists
- **Attributes**: `[AllowAnonymous]`
- **Frontend Usage**: Used in `cabinetSelectionWizardManager.js` (Line 322)
  - Referenced in `_getUniqueDoorPanelsFromParts()` method

---

### 2. **DocumentController**

#### BuilderHasDocumentByType
- **Route**: `GET api/Document/BuilderHasDocumentByType`
- **Location**: Line 249 in DocumentController.cs
- **Purpose**: Checks if a document exists for an organization; returns 200 if found, 404 if not found
- **XML Documentation** (Line 232-233): 
  ```
  Returns a status 200 if the given organization has the specified document. 
  Returns status 404 (Not Found) if the organization does not have the document.
  ```
- **Frontend Usage**: Called in TWO locations:
  1. **prepareDesignSession.ts** (Line 25)
     - Checks for "Prepare For My Design Session" document
     - If found, opens document in new window
     - **Error Handling**: Currently wrapped in try-catch with no specific error handling
     ```typescript
     try {
         await DocumentService.builderHasDocumentByType(accountID, organizationID, docType);
         // Opens document if found
     } catch (error) {
         // Currently no specific handling for 404 vs 400
     }
     ```
  
  2. **welcomeDesignCenter.ts** (Line 23)
     - Checks for "Designer Message" document
     - If found, opens document in new window
     - **Error Handling**: Same pattern as above - no specific error handling

---

## Frontend Error Handling Analysis

### HttpClient Implementation (App/helpers/httpClient.ts)

The frontend's `HttpClient.get()` method (Line 119-138) handles all non-OK responses uniformly:

```typescript
export async function get(url: string, queryParameters?: object, ...): Promise<any> {
    // ... code ...
    let response = await request(url, 'GET', null, options);
    let content = await parseBodyByType(response);
    
    if (!response.ok) {
        throw new HttpStatusError(content, response.status, response.statusText);
    }
    return content;
}
```

**Key Finding**: The HttpClient throws an `HttpStatusError` for ANY non-OK status code, including:
- HTTP 400 (Bad Request) - currently being returned by NotFound()
- HTTP 404 (Not Found) - what NotFound() SHOULD return

### Current Frontend Impact

1. **Cabinet Image Endpoints** (GetCabinetPartImage, etc.)
   - Images are used as `<img>` tag src attributes in cabinetSelectionWizardManager.js
   - If image doesn't exist, a 400 is currently returned (incorrectly)
   - Browser treats 400 error response as broken image
   - **Impact**: Same visual result (broken image) but semantically incorrect HTTP status

2. **Document Check Endpoints** (BuilderHasDocumentByType)
   - Called in `try-catch` blocks in prepareDesignSession.ts and welcomeDesignCenter.ts
   - Currently both 404 and 400 would throw errors
   - **Current Behavior**: Exception caught, document not opened
   - **Issue**: Frontend logic cannot distinguish between "document not found" vs "bad request"
   - Both conditions currently result in document not being opened, which may or may not be intended

---

## Risk Assessment

### LOW RISK - Cabinet Image Methods
- **Why**: Frontend uses these as image src attributes
- **Current Behavior**: 400 response results in broken image
- **After Fix**: 404 response will also result in broken image
- **Change**: Only the HTTP status code changes; visual behavior is identical
- **Recommendation**: LOW RISK to fix

### MEDIUM RISK - BuilderHasDocumentByType
- **Why**: Frontend catches errors but doesn't differentiate between 404 and 400
- **Current Behavior**: 400 error is caught, document not opened
- **After Fix**: 404 error will be caught, document not opened
- **Change**: Only the HTTP status code changes; behavior is identical
- **Potential Issue**: If frontend code later wants to distinguish "not found" from "bad request", current catch blocks won't be updated
- **Recommendation**: MEDIUM RISK - review if frontend should have specific 404 handling

---

## Recommended Actions

### Option A: Fix NotFound() Method (Recommended)
1. Fix `BaseApiController.NotFound()` to return proper 404 status
2. Update the method to return `NotFoundObjectResult` instead of `BadRequestObjectResult`
3. All existing endpoints will start returning correct HTTP 404 status
4. Frontend behavior remains the same (errors are still caught)
5. HTTP semantics are corrected for API consumers
6. **No breaking changes** - frontend error handling remains functional

### Option B: Code Review Before Fix
1. Check if any frontend code or third-party integrations depend on 400 status from these endpoints
2. Verify with team that 404 is the intended behavior
3. Update documentation/comments if needed
4. Then proceed with Option A

---

## Summary Table

| Endpoint | Controller | HTTP Method | Returns 404 | Frontend Usage | Frontend Error Handling |
|----------|-----------|-------------|-------------|----------------|------------------------|
| GetCabinetPartImage | CabinetSelections | GET | Line 142 | cabinetSelectionWizardManager.js (img src) | None (browser handles) |
| GetCabinetDoorStyleImage | CabinetSelections | GET | Line 172 | cabinetSelectionWizardManager.js (img src) | None (browser handles) |
| GetCabinetSpeciesImage | CabinetSelections | GET | Line 202 | cabinetSelectionWizardManager.js (img src) | None (browser handles) |
| GetCabinetColorImage | CabinetSelections | GET | Line 232 | cabinetSelectionWizardManager.js (img src) | None (browser handles) |
| GetCabinetDoorPanelImage | CabinetSelections | GET | Line 250+ | cabinetSelectionWizardManager.js (img src) | None (browser handles) |
| BuilderHasDocumentByType | Document | GET | Line 249 | prepareDesignSession.ts, welcomeDesignCenter.ts | try-catch (no 404 specific) |

---

## Overload Analysis

**Note**: There appears to be a method overload issue. The base controller also has:
- `BadRequest(string responseMessage)` at Line 78-82
- `NotFound(string responseMessage)` at Line 88-92
- `StatusCode(int statusCode, string responseMessage)` at Line 97-101

These are all custom overloads, but `NotFound(string)` is calling `BadRequest()` internally, which is incorrect.
