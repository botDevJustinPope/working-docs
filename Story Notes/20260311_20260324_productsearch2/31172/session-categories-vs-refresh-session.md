# Session Categories vs. Refresh Session

## Purpose of This Note

This document explains an important distinction in the application:

- **session categories** describe how the session is organized for navigation and display
- **Refresh Session** analyzes and applies supported changes inside an existing session

Those two things are related, but they are not the same system.

That distinction matters for enhanced categories, because Refresh Session appears to use older product / item comparison assumptions even though other parts of the application now support richer category behavior.

## Short Version

Session categories are created and merged through dedicated session/category logic.

Refresh Session does not appear to rebuild those session categories when it analyzes changes. Instead, Refresh Session compares and applies changes using fields such as:

- application
- product
- area
- sub area
- item
- item number

That means enhanced category behavior can exist elsewhere in the application without being fully represented inside Refresh Session.

## What Session Categories Are

Session categories are the category records stored for a session and then turned into a category tree for the UI.

At a high level, they define the session's application / product hierarchy and carry flags such as:

- `HasEstimatedOptions`
- `HasNonEstimatedOptions`

They also support display behavior that changes when the `use_enhanced_categories` feature is enabled.

In other words, session categories are part of how the application organizes and presents the session.

## Where Session Categories Come From

Session categories are created during session creation.

When a session is created, the application:

- gathers prices landed / estimated price level data
- gathers catalog category data
- aligns price levels to application / product categories
- creates `SessionCategory` records for the session

This work happens in `CreateSession.cs`, especially in:

- `ConstructSessionCategories(...)`
- `AddSessionCategories(...)`

That is an important design point:

> session categories are established as part of session creation, not Refresh Session analysis

## How Session Categories Are Used Elsewhere

Other application features retrieve and merge session categories with current session options.

The main use case for that is:

- `BuildOnTechnologies.VDS.Services\Session\GetSessionCategoriesMergedWithOptions.cs`

That use case:

- reads stored session categories
- checks whether enhanced categories are enabled
- merges in estimated option presence
- merges in non-estimated option presence
- updates totals and flags used by the UI

This merged category tree is then consumed by features such as:

- Design My Home
- Design Selections
- Option Pricing

Examples:

- `DesignSessionController.cs` exposes `api/sessions/{sessionId}/GetSessionCategories`
- `designMyHomeService.ts` calls that endpoint
- `designMyHome.ts` loads session categories for the session view
- `GetOptionPricingAppMenuForSession.cs` uses the same merged category pipeline for Option Pricing

## Where Enhanced Categories Show Up

Enhanced categories are not just a UI label change.

The code shows explicit enhanced-category-aware behavior, including:

- feature-flag checks for `use_enhanced_categories`
- `CategoryDisplayName` logic that can prefer category name over external ID
- Option Pricing comments and payload logic that account for category names and external IDs differing under enhanced categories

This means the category-aware parts of the application already understand that:

- displayed category names may differ from legacy application / product identifiers
- category structure can be richer than the older product-based model

## How Refresh Session Works Differently

Refresh Session does not seem to use the session-category pipeline as its source of truth for change analysis.

Instead, it loads:

- estimated catalog data
- session builds
- echelon group details
- session group details
- builder non-estimated items
- session non-estimated items

It then runs analyzers to detect supported changes.

For non-estimated item comparisons, the refresh logic builds comparison DTOs that contain:

- community
- series
- plan
- application
- product
- area
- sub area
- item number
- item
- price
- GPC
- package flag

This is one of the clearest proof points in this analysis: Refresh Session comparison is based on legacy structural fields rather than the category/subcategory abstraction used elsewhere in the application.

## Why That Matters

The most important distinction is not really whether `CategoryId` exists on certain models. The more important point is that the option flows users interact with are not driven by category IDs as the main comparison key.

During session creation, `CreateSession.cs` creates the session category structure, but it does not create the estimated and non-estimated options by assigning category IDs and then using those IDs as the main way options are shown to the user.

Instead, the user-facing flows use the category structure to abstract and organize option data that still fundamentally comes from application/product-style fields.

Examples from the UI confirm this pattern:

- Design My Home matches session categories to room options by comparing the option's `application` value to the category's `categoryName` or `externalId`
- Design My Home matches products to subcategories by comparing option `product` values to subcategory `categoryName` or `externalId`
- Design Selections resolves the selected application and product by preferring `selectedApplicationExternalId` / `selectedProductExternalId`, then falling back to `selectedApplication` / `selectedProduct`

So the application clearly has category-aware behavior elsewhere, but that behavior is primarily an abstraction and presentation layer over application/product data rather than a category-ID-driven option model.

## What Refresh Session Appears to Compare Instead

For non-estimated items, refresh matching is based on older product / item comparison rules.

In default mode, the comparer matches on:

- community
- series
- plan
- application
- product
- area
- sub area
- item number
- item

In item-number mode, the comparer still relies on the same structure, but uses item number as the stronger identity rule and only includes rows with an item number.

For estimated option movement, the analysis also keys off legacy-style identifiers such as:

- application ID
- product ID
- item
- group ID
- area ID
- sub area ID

Again, this is refresh logic built around product / group relationships rather than the category/subcategory abstraction used elsewhere in the session UI.

## What Refresh Session Does Not Seem to Do

Based on the code reviewed, Refresh Session does **not** appear to:

- rebuild session categories
- re-run the category abstraction layer as the core comparison engine
- use category/subcategory presentation as part of refresh comparison logic
- reinterpret refresh results through the enhanced-categories hierarchy before presenting them

That does not mean Refresh Session is broken.

It means Refresh Session is solving a narrower problem:

> detect supported changes against an existing session model and apply them into that model

## Practical Pain Points and Mismatches

### 1. Category-aware UI vs. product-based refresh comparison

A user may navigate the session through enhanced categories, but Refresh Session may still reveal changes according to older application / product / item relationships.

Practical effect:

- the UI elsewhere in the app may feel category-aware
- Refresh Session may feel more legacy and product-oriented

### 2. The UI can be category-aware while refresh matching remains application/product-based

If category placement changes without a meaningful application / product / item identity change, Refresh Session may not treat that as an important change.

Practical effect:

- a user may see category organization differences elsewhere in the app
- Refresh Session may not surface that as a change to review

### 3. Session categories are created up front, while refresh is incremental

Session creation builds category records. Refresh Session applies incremental changes later.

Practical effect:

- refresh is good at adding or updating supported content
- refresh is not a full category re-synchronization mechanism

### 4. Enhanced categories can change display meaning

The codebase already contains enhanced-category logic where displayed category names can differ from legacy external IDs.

Practical effect:

- a business user may see categories in Design My Home or Option Pricing that do not map one-to-one with how Refresh Session is reasoning about item changes

### 5. Some backend flows may still reference categories, but option presentation is abstracted at the UI level

Some backend flows still reference session categories, but that should not be confused with how options are actually surfaced and navigated in the main session experiences.

Practical effect:

- the application can still store or look up category relationships in certain backend flows
- but Refresh Session still appears to decide what changed based on legacy structural fields rather than the category abstraction layer itself

## Why Refresh Session Still Looks Safe for the Core Use Case

For the core refresh use case, the current implementation still looks internally consistent.

Refresh Session seems intended to answer:

- what supported estimated changes were added or moved
- what supported non-estimated items are new
- what supported non-estimated items were modified

Within that scope, the code is consistent about using its chosen comparison rules.

So the safer conclusion is:

> Refresh Session does not appear to break simply because enhanced categories exist.

The better concern is different:

> Refresh Session may not tell the full enhanced-category story, because it does not seem to compare or apply changes through the same category model used elsewhere.

## Recommended Business Interpretation

It is safest to describe Refresh Session this way:

- Refresh Session updates supported session content
- Refresh Session does not fully re-category or re-structure the session
- Enhanced categories improve how sessions are organized and displayed elsewhere
- Those two behaviors can coexist, but they do not appear to be driven by the same comparison model

## Recommended Proof Points

If the team wants stronger proof beyond code review, the most valuable validation cases are:

1. Create a session with enhanced categories enabled.

2. Introduce a change where category placement changes, but the legacy application / product / item identity stays effectively the same.

3. Run Refresh Session and confirm whether anything is revealed.

4. Compare the Refresh Session results with:

- Design My Home category presentation
- Design Selections category presentation
- Option Pricing application / product presentation

5. Repeat with non-estimated items that have:

- the same item number but a different category placement
- the same application / product but different category/subcategory presentation
- price overrides

These tests would help prove whether the pain point is:

- a true defect
- or an expected limitation of the current refresh design

## Key Evidence Reviewed

### Refresh Session flow and comparison logic

- `VeoDesignStudio\Controllers\Sessions\SessionChangesController.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\GetSessionChanges.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\ApplySessionChanges.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Models\NonEstimatedItemsComparisonDTO.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\NonEstimatedItemComparer\NonEstimatedItemComparer.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\NonEstimatedItemComparer\NonEstimatedItemDefaultComparer.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\NonEstimatedItemComparer\NonEstimatedItemItemNoComparer.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForNewNonEstimatedItems.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForModifiedNonEstimatedItems.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForNewPriceLevelOptions.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForMovedPriceLevelOptions.cs`

### Session categories and category-aware UI flows

- `BuildOnTechnologies.VDS.Services\Session\CreateSession.cs`
- `BuildOnTechnologies.VDS.Services\Session\GetSessionCategoriesMergedWithOptions.cs`
- `BuildOnTechnologies.VDS.Services\Catalog\GetOptionPricingAppMenuForSession.cs`
- `VeoDesignStudio\Controllers\Api\DesignSessionController.cs`
- `VeoDesignStudio\App\services\designMyHomeService.ts`
- `VeoDesignStudio\App\services\optionPricingService.ts`
- `VeoDesignStudio\App\features\designMyHome\designMyHome.ts`
- `VeoDesignStudio\App\features\designMyHome\content\roomOptionSelector\applicationsPanel\applicationsPanel.ts`
- `VeoDesignStudio\App\features\designMyHome\content\roomOptionSelector\roomOptionSelectorState.ts`
- `VeoDesignStudio\App\features\designMyHome\content\roomOptionSelector\listArea\listArea.ts`
- `VeoDesignStudio\App\features\designSelections\navList\navList.ts`
- `VeoDesignStudio\App\features\designSelections\selectionsList\selectionsList.ts`
- `VeoDesignStudio\App\features\optionPricing\applicationProductList\applicationProductList.ts`
- `BuildOnTechnologies.VDS.Legacy.Domain\Entities\SessionCategory.cs`
- `BuildOnTechnologies.VDS.Legacy.Domain\DTOs\Catalog\CategoryDto.cs`

## Bottom Line

Refresh Session and enhanced categories are not the same subsystem.

Refresh Session appears safe for its current incremental-update purpose.

But it also appears to operate with older application / product / item matching assumptions, while the rest of the session experience can present those same options through a category/subcategory abstraction. That means Refresh Session may not expose or reconcile all of the category-level differences that enhanced categories make visible elsewhere in the application.
