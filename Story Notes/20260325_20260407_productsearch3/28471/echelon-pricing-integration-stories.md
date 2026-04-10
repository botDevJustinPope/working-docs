# Echelon Pricing Integration — ADO Story Notes

**Epic / Feature Context:**  
Echelon is introducing a flat rate pricing module. This work represents a series of iterative improvements to how VeoDesignStudio handles pricing — starting with support for the new flat rate price type in the current internal pipeline, then progressively replacing internal pricing logic with Echelon-provided endpoints, and finally refactoring the part selection flow to use Echelon as the source of truth for both parts and pricing.

---

## Phase 1 — Flat Rate Pricing Support in Existing Pricing Pipeline

### Story 1.A — Confirm Flat Rate Pricing Behavior with Echelon Team

**Description:**  
Before any code changes are made, we need to align with Jim and the Echelon team on the specifics of flat rate pricing. The outcome of this conversation will directly drive the implementation scope of Stories 1.B, 1.C, and 1.D.

**Acceptance Criteria:**
- [ ] Confirmed: What is the exact `price_type` string returned for flat rate pricing? (`"flat_rate"`, `"flat"`, etc.)
- [ ] Confirmed: Does flat rate apply to the **bom line itself** (non-options path), the **options** (options path), or both?
- [ ] Confirmed: For option lines — does flat rate pricing mean a fixed total price (qty = 1), or is it still a per-unit price multiplied by qty?
- [ ] Confirmed: Does a `BillQty` adjustment need to occur for flat rate items, similar to how `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` sets `BillQty = 1` for area-priced items?
- [ ] Confirmed: Does the existing `vds_vs_selItemPrice` stored procedure already return the flat rate `price_type`, or does the SP need to be updated to return new flat rate pricing data?
- [ ] Confirmed: Does the floor price guard in `PriceBuild.AdjustBomLinePricing` (which prevents a repriced bom line from going below its original price level price) still apply to flat rate items?
- [ ] All confirmed details are documented and shared with the development team.

**Notes:**  
This is a discovery/alignment story. No code changes are expected. Output is a confirmed specification.

---

### Story 1.B — Add `IsFlatRatePrice` Property to `PriceDomainModel`

**Description:**  
`PriceDomainModel` is the result object produced by `PricingDomainRepository.GetBomItemPriceAsync()`. It currently has a computed `IsAreaPrice` property that checks `PriceType == "AREA"`. We need to add an equivalent `IsFlatRatePrice` property to allow `PriceBomLine` and other consumers to branch on flat rate pricing without magic string comparisons scattered through the code.

**Affected Files:**
- `BuildOnTechnologies.VDS.Legacy.Domain/Entities/PriceDomainModel.cs`

**Acceptance Criteria:**
- [ ] `PriceDomainModel` has a new `IsFlatRatePrice` computed bool property
- [ ] `IsFlatRatePrice` uses a case-insensitive comparison against the confirmed flat rate price type string from Story 1.A
- [ ] XML summary doc comment is added explaining the property
- [ ] Existing unit tests for `PriceDomainModel` (if any) are updated; new test(s) added for `IsFlatRatePrice`
- [ ] No breaking changes to existing `PriceType` consumers

**Dependencies:** Story 1.A must be complete (need the confirmed price type string).

---

### Story 1.C — Handle Flat Rate Price Type in `PriceBomLine.Invoke`

**Description:**  
`PriceBomLine.Invoke` is the core use case responsible for repricing a bom line. For bom lines with options (the `HasOptions` path), it currently handles three price type branches explicitly: `"percent"`, `"unit"`, and `""` (field line). A flat rate price type needs to be added as a new branch.

The exact behavior (qty=1 fixed total vs. per-unit) will come from Story 1.A. Additionally, assess whether a `BillQty` adjustment method is needed for flat rate, similar to `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` on the non-options path.

**Affected Files:**
- `BuildOnTechnologies.VDS.Legacy.Domain/UseCases/Pricing/PriceBomLine.cs`

**Acceptance Criteria:**
- [ ] A new `if (price.IsFlatRatePrice)` branch exists in the options loop (lines ~116–146 in current code)
- [ ] Branch behavior correctly reflects flat rate semantics confirmed in Story 1.A
- [ ] If flat rate applies to the non-options path as well: `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea` is extended or a new analogous method is added for flat rate
- [ ] `PriceBomLine` uses `price.IsFlatRatePrice` (from Story 1.B) rather than a raw string comparison
- [ ] Unit tests cover: flat rate option line is priced correctly; flat rate does not interfere with existing `percent`, `unit`, or `""` price type branches
- [ ] Build passes with no errors or warnings

**Dependencies:** Story 1.A (confirmed behavior), Story 1.B (`IsFlatRatePrice` property).

---

### Story 1.D — Assess and Update `vds_vs_selItemPrice` SP for Flat Rate

**Description:**  
`PricingDomainRepository.GetBomItemPriceAsync()` calls the `vds_vs_selItemPrice` stored procedure to retrieve pricing data. If Echelon's flat rate pricing requires new data to be returned (e.g., a new price type value or additional columns), the SP and/or its result mapping in the repository may need to be updated.

**Affected Files (conditional on Story 1.A outcome):**
- `Databases/VeoSolutions/dbo/Stored Procedures/vds_vs_selItemPrice.sql`
- `BuildOnTechnologies.VDS.Legacy.Dal/Repositories/PricingDomainRepository.cs`

**Acceptance Criteria:**
- [ ] Story 1.A confirms whether SP changes are needed
- [ ] If SP changes needed: `vds_vs_selItemPrice` returns the flat rate `price_type` string correctly
- [ ] If SP changes needed: `PricingDomainRepository` correctly maps the new/updated result columns to `PriceDomainModel`
- [ ] If no SP changes needed: this story is closed as no-op with documentation confirming why
- [ ] End-to-end: a flat rate item in the database flows through the SP → repository → `PriceDomainModel.IsFlatRatePrice == true`

**Dependencies:** Story 1.A.

---

## Phase 2 — Obsolete Internal Pricing via Echelon Pricing Endpoints

> **Prerequisite:** Echelon pricing endpoints are deployed and accessible in the target environment.

### Story 2.A — Add Pricing Methods to `IEchelonRepository`

**Description:**  
`IEchelonRepository` is an existing interface (already injected in `GetBuildItemsForBomLine`) currently used for retrieving builder image overrides from Echelon. We need to extend it with pricing methods so that `PriceBomLine` and `PriceBuild` can call Echelon pricing endpoints through the same repository abstraction.

**Affected Files:**
- `BuildOnTechnologies.VDS.Legacy.Domain/Boundaries/Repositories/IEchelonRepository.cs` (interface)
- Echelon repository implementation (DAL layer)

**Acceptance Criteria:**
- [ ] `IEchelonRepository` exposes at minimum `Task<PriceDomainModel> GetBomLinePriceAsync(PriceBomItemDTO priceParms, Guid securityToken)`
- [ ] If a "price whole build" endpoint is available: `Task<IList<PriceDomainModel>> GetBuildPriceAsync(...)` is also added
- [ ] Echelon repository implementation makes the correct HTTP call(s) to the Echelon pricing endpoint(s)
- [ ] Echelon response is mapped to `PriceDomainModel` such that all downstream consumers (`AdjustBomLinePricing`, `AdjustBomLinePriceResultBillQtyIfPriceTypeIsArea`, etc.) work without modification
- [ ] Error/timeout handling: if Echelon endpoint is unreachable, a `PriceDomainModel` with a `PricingError` message is returned (do not throw unhandled exception)
- [ ] Unit/integration tests cover happy path and error path for pricing calls
- [ ] Existing `GetEchelonImagesByImageIds` functionality is unaffected

---

### Story 2.B — Create `PriceBomLineViaEchelon` Use Case

**Description:**  
Create a new use case class `PriceBomLineViaEchelon` that implements the existing `IPriceBomLine` interface. This class will replace the current `PriceBomLine` class (which calls the internal `vds_vs_selItemPrice` SP) with a version that calls the Echelon pricing endpoint via `IEchelonRepository`.

By implementing the same interface, no consumers of `IPriceBomLine` (`PriceBuild`, `GetBuildItemsForBomLine`) need to change — only the DI registration changes.

**Affected Files:**
- New file: `BuildOnTechnologies.VDS.Legacy.Domain/UseCases/Pricing/PriceBomLineViaEchelon.cs`
- DI registration (wherever `IPriceBomLine` is bound)

**Acceptance Criteria:**
- [ ] `PriceBomLineViaEchelon` implements `IPriceBomLine`
- [ ] Calls `IEchelonRepository.GetBomLinePriceAsync` (from Story 2.A) instead of `IPricingDomainRepository.GetBomItemPriceAsync`
- [ ] All existing bom line pricing behaviors are preserved: tile rounding, credit item adjustment, area bill qty adjustment, `BuilderMarkupHBPricing` handling
- [ ] Unit tests for `PriceBomLineViaEchelon` mirror the existing tests for `PriceBomLine`
- [ ] DI registration is updated to bind `IPriceBomLine` → `PriceBomLineViaEchelon` (or feature-flagged)
- [ ] End-to-end test: repricing a bom line flows through Echelon endpoint and produces correct prices on the build

**Dependencies:** Story 2.A.

---

### Story 2.C — Create `PriceBuildViaEchelon` Use Case (if Echelon provides a build-level endpoint)

**Description:**  
If Echelon provides a "price whole build" endpoint, create `PriceBuildViaEchelon` implementing `IPriceBuild` that replaces the per-bom-line loop in `PriceBuild.UpdateBuildPricingAsync` with a single Echelon call. This reduces chattiness and allows Echelon to apply its own pricing rules holistically across the build.

**Affected Files:**
- New file: `BuildOnTechnologies.VDS.Legacy.Domain/UseCases/Pricing/PriceBuildViaEchelon.cs`
- DI registration

**Acceptance Criteria:**
- [ ] `PriceBuildViaEchelon` implements `IPriceBuild`
- [ ] Calls `IEchelonRepository.GetBuildPriceAsync` (from Story 2.A)
- [ ] Maps Echelon response back onto bom line entities (`BuilderPrice`, `HomeownerPrice`, `PriceType`, `PricingLayer`)
- [ ] `PriceBuild.AdjustBomLinePricing` floor guard logic is preserved (do not allow prices to drop below price level original)
- [ ] `build.SelectionTotal` and `build.UpdateSelectedStatus` are still calculated after repricing
- [ ] Unit tests cover happy path, pricing error handling, and credit bom lines
- [ ] DI registration updated

**Dependencies:** Story 2.A.

---

### Story 2.D — Mark `PriceBomLine` and `PriceBuild` as `[Obsolete]`

**Description:**  
Once Echelon-backed use cases (Stories 2.B and 2.C) are stable and verified in production, mark the legacy internal pricing classes as obsolete. Do not delete them yet — retain for rollback safety.

**Affected Files:**
- `BuildOnTechnologies.VDS.Legacy.Domain/UseCases/Pricing/PriceBomLine.cs`
- `BuildOnTechnologies.VDS.Legacy.Domain/UseCases/Pricing/PriceBuild.cs`

**Acceptance Criteria:**
- [ ] `[Obsolete("Use PriceBomLineViaEchelon. Will be removed in a future release.")]` added to `PriceBomLine`
- [ ] `[Obsolete("Use PriceBuildViaEchelon. Will be removed in a future release.")]` added to `PriceBuild`
- [ ] Build produces expected obsolete warnings (not errors)
- [ ] No existing DI registrations bind directly to the obsoleted classes (all should bind via interface)

**Dependencies:** Stories 2.B and 2.C verified in production.

---

## Phase 3 — Refactor GetBuildItemsForBomLine with Echelon Parts + Pricing

> **Prerequisite:** Phase 2 Echelon pricing is stable. Echelon parts search endpoint is deployed.

### Story 3.A — Add Parts Search Methods to `IEchelonRepository`

**Description:**  
Echelon will provide a parts search endpoint that returns the available selections for a given bom line. This extends `IEchelonRepository` with a new parts search method so that `GetBuildItemsForBomLine` can optionally fetch its available item list from Echelon rather than the internal `IBuildItemRepository`.

**Affected Files:**
- `BuildOnTechnologies.VDS.Legacy.Domain/Boundaries/Repositories/IEchelonRepository.cs`
- Echelon repository implementation

**Acceptance Criteria:**
- [ ] `IEchelonRepository` exposes `Task<IList<BuildItem>> GetAvailablePartsForBomLineAsync(...)` (or equivalent DTO)
- [ ] Method accepts enough context to identify the bom line type (field, sink, edge, grout, cabinet hardware, accent, standard) and filter criteria
- [ ] Returns a result that maps to `AvailableBuildItemDto` compatible with the existing `GetBuildItems` flow
- [ ] Error path: if Echelon parts endpoint fails, method throws or returns empty list (to be decided — document the decision)
- [ ] Unit tests cover happy path and error path

---

### Story 3.B — Refactor `GetBuildItemsForBomLine` to Use Echelon Parts and Pricing

**Description:**  
`GetBuildItemsForBomLine` currently calls `IBuildItemRepository` for part selection and `IPriceBomLine` for display pricing. With Echelon providing both capabilities, we can refactor to route through Echelon. This should be feature-flagged initially so individual bom line types can be migrated incrementally without a big-bang cutover.

`IEchelonRepository` is already injected in `GetBuildItemsForBomLine` (used for builder image overrides), so no constructor changes are needed — only new method calls are added.

**Affected Files:**
- `BuildOnTechnologies.VDS.Legacy.Domain/UseCases/BuildSelections/GetBuildItemsForBomLine.cs`

**Acceptance Criteria:**
- [ ] `GetBuildItems()` checks a feature flag (or Echelon availability) before routing to Echelon vs. internal `_buildItemRepo`
- [ ] When Echelon path is active: calls `IEchelonRepository.GetAvailablePartsForBomLineAsync` (Story 3.A)
- [ ] When Echelon path is active: `PriceBomDetailLine()` uses `PriceBomLineViaEchelon` (Phase 2) — this is already handled if DI is correctly set up
- [ ] When Echelon path is inactive: existing `_buildItemRepo` path is completely unchanged (no regression)
- [ ] `ProcessBuilderOverrideImages` (existing Echelon image override logic) continues to function on both paths
- [ ] `ProcessSelectableInventory` (slab selection for countertops) continues to work on both paths
- [ ] Rollout plan documented: which bom line types to migrate first, how to verify, how to roll back
- [ ] Unit tests updated to cover both Echelon path and internal path

**Dependencies:** Stories 2.B, 3.A.

---

## Dependency Summary

```
Story 1.A  →  Stories 1.B, 1.C, 1.D  (Phase 1 all blocked on Echelon confirmation)
Story 1.B  →  Story 1.C
Story 2.A  →  Stories 2.B, 2.C, 3.A
Story 2.B  →  Story 2.D, Story 3.B
Story 2.C  →  Story 2.D
Story 3.A  →  Story 3.B
```

Phase 1 can start as soon as Jim/Echelon confirms flat rate details.  
Phase 2 and 3 require Echelon endpoints to be deployed.
