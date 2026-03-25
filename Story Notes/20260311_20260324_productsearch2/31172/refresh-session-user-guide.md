# Refresh Session User Guide

## Overview

Refresh Session helps a user bring an existing session up to date with catalog and pricing changes that became available after the session was created.

From the user's point of view, Refresh Session answers a simple question:

> "What has changed since this session started, and which of those changes should be added to this session now?"

It does that by analyzing the current session against the latest source data the application uses for refresh:

- estimated option structures from pricing / Echelon data
- non-estimated options from the builder catalog

The result is a list of changes that can be reviewed and, in many cases, applied.

## How a User Gets to Refresh Session

A user starts from the Homebuyer Summary page and looks at a session card for an active session.

If the user has permission to refresh sessions, the session card shows the **Refresh Session** action. After the user confirms the action, the application navigates to the Refresh Session page for that session.

Once the page loads, the analysis starts automatically. The user does not need to click another button to begin the first analysis.

## What the Application Checks

Refresh Session compares the current session with the latest available refresh data and looks for several kinds of differences.

The backend runs a fixed set of comparison processes. Together, those processes decide whether the session should show:

- new estimated content
- moved estimated content
- warnings
- new non-estimated content
- modified non-estimated content

### The Data the Analysis Starts With

Before comparing anything, Refresh Session loads the current session context into an analysis model.

That model includes:

- the current session
- the builder organization settings
- the current session builds
- the Echelon / estimated catalog for the session plan
- Echelon group details
- the session's current group details
- the builder's non-estimated catalog items
- the session's current non-estimated items
- the organization's refresh catalog mode

This is important because Refresh Session is not comparing against a generic catalog. It is comparing the session against the specific estimated and non-estimated data sources that apply to that session.

### Estimated Comparison Process 1: New Areas / Builds

The first estimated analyzer looks for builds that exist in the latest Echelon catalog but do not already exist in the session.

The comparison is done by checking whether the session already has a build with the same:

- application
- product
- area / build description

If no matching session build is found, Refresh Session treats that build as a **new area / build** and surfaces it as a `NewBuild` change.

In plain terms, this process asks:

> "Did the latest estimated data introduce an area/build combination this session does not already have?"

### Estimated Comparison Process 2: New Price Levels Inside Existing Builds

The second estimated analyzer looks inside builds that already exist in the session.

For each distinct session build, it:

- finds the Echelon price levels for that build
- filters those Echelon price levels down to group-type price levels
- compares those group items with the session's existing price levels for the same build

If an Echelon group price level exists for a build and the session does not already have a matching session price level for that build and group item, Refresh Session creates a `NewPriceLevel` change.

In plain terms, this process asks:

> "Inside a build the session already knows about, are there new price level groups that have been added since the session was created?"

### Estimated Comparison Process 3: New Field Color / Style Options in Existing Groups

The third estimated analyzer compares detailed option/group rows from Echelon with the session's current group-detail rows.

It only treats an item as a new option when all of the following are true:

- the item is **not** duplicated across multiple groups on the Echelon side
- the target group already exists in the session
- the session does **not** already contain an option with the same:
  - application ID
  - product ID
  - item

If those rules pass, Refresh Session creates a `NewOption` change pointing to the group that already exists in the session.

In plain terms, this process asks:

> "For groups the session already has, did the latest estimated data add a new option row that the session does not yet contain?"

### Estimated Comparison Process 4: Moved Options

The fourth estimated analyzer looks for options that still exist, but now belong to a different group or location than they did before.

It groups option rows using:

- item type
- item
- item description
- application ID
- product ID

Then it compares where those grouped rows live in:

- Echelon group details
- session group details

If the option exists in both places, but the source and target group / area / sub area no longer match, Refresh Session creates either:

- `MovedOption`, or
- `MovedSelectedOption`

`MovedSelectedOption` is used when the move affects currently selected content, and the analyzer also calculates the impacted areas plus whether the move causes a:

- price increase
- price decrease
- no price change

In plain terms, this process asks:

> "Is this still the same option, but now attached to a different price level or area/sub area than where the session currently has it?"

### Estimated Comparison Process 5: Warnings

The warning analyzer handles one of the more intricate situations.

It looks for option rows that appear in multiple groups and compares the group memberships between:

- Echelon
- the current VDS session

If an item exists in multiple groups and the group memberships do not match between the two sides, Refresh Session creates a `Warning` change.

This does not mean the item should automatically be moved or added. It means the data shape is complicated enough that the user should be warned before applying changes.

In plain terms, this process asks:

> "Is this option grouped in a multi-group way that differs between the latest source data and the current session?"

### Non-Estimated Comparison Process 1: New Non-Estimated Items

The first non-estimated analyzer compares builder catalog items against the session's current non-estimated items.

It uses a non-estimated comparer, and the exact comparer depends on the organization's refresh catalog mode.

In default mode, matching is based on:

- community
- series
- plan
- application
- product
- area
- sub area
- item number
- item

In item-number mode, matching is still product-structured, but the comparison effectively keys off:

- community
- series
- plan
- application
- product
- area
- sub area
- item number

and only items with an item number are included in analysis.

If a builder non-estimated item passes the comparer rules and no matching session non-estimated item is found, Refresh Session creates a `NewNonEstimatedItem` change.

In plain terms, this process asks:

> "Is this builder catalog item something the session does not already have according to refresh-session matching rules?"

### Non-Estimated Comparison Process 2: Modified Non-Estimated Items

The second non-estimated analyzer only runs when the organization's refresh catalog mode is **not** the default mode.

It first finds the builder-catalog match for each session non-estimated item using the same comparer rules described above.

Once a match is found, Refresh Session checks whether the builder item differs from the session item in one or more of these fields:

- item description
- rounded price
- GPC
- package flag

If one of those values changed, Refresh Session creates a `ModifiedNonEstimatedItem` change.

This is also where the UI can later separate items with price overrides from other modified items.

In plain terms, this process asks:

> "For the non-estimated items this session already has, does the matching builder-catalog version now look materially different?"

### One of the Most Important Comparison Limits

Refresh Session comparison logic is primarily built around legacy structural fields such as:

- application
- product
- area
- sub area
- item number
- item text

The category-aware parts of the application work differently. In features such as Design My Home and Design Selections, the category tree acts as an abstraction layer over the older application/product model. Those UI flows match and route options by category name and external ID so the user can work within categories and subcategories even though the underlying option data still traces back to application/product-style fields.

That means Refresh Session can behave differently from category-aware parts of the application even when both are working as designed: Refresh Session is comparing legacy structural fields, while the session UI can present those same options through a category/subcategory abstraction.

### How the Results Are Organized

After all analyzers run, the backend groups the detected changes into named change sets such as:

- `NewBuilds`
- `NewPriceLevels`
- `NewOptions`
- `MovedOptions`
- `MovedSelectedOptions`
- `Warning`
- `NewNonEstimatedItems`
- `ModifiedNonEstimatedItems`

Those change-set names are what allow the UI to present the results in user-friendly buckets and decide which items are auto-applied, selectable, or informational.

## What the User Sees

After analysis completes, the page can show several different kinds of results.

### Warnings

Warnings are shown at the top of the page so the user can see that there is something unusual or important to review.

Warnings are informational. They are not treated like selectable changes.

### Changes that Will Be Added Automatically

Some change types are treated as auto-apply items in the UI:

- new areas
- new field color / style options

These appear in a section that tells the user these changes will be added when changes are applied.

### Changes the User Can Select

Other changes appear in selectable sections. The user can review them and choose which ones to apply.

These include:

- added estimated price levels
- moved estimated options
- added non-estimated options
- updated non-estimated options
- updated non-estimated options with a price override

The page supports selecting all, deselecting all, and expanding non-estimated changes by application / product grouping.

### No Changes Found

If analysis completes without warnings, auto-applied changes, or selectable changes, the page shows **No changes found**.

## What "Apply Changes" Actually Does

When the user clicks **Apply Changes**, the application sends:

- selected individual change IDs
- selected change-set IDs for grouped changes

The backend then applies those changes to the session.

At a high level:

- new estimated structures are added to the session where appropriate
- moved estimated options are moved to the new target location
- new non-estimated items are copied into the session
- modified non-estimated items are updated in the session when allowed by catalog mode

After apply completes, the page shows results grouped into:

- **Applied**
- **Errors**
- **Ignored**

This gives the user a practical handoff:

- what was successfully added or updated
- what failed and needs attention
- what was left alone

## What Refresh Session Updates

Refresh Session is good at applying incremental session updates such as:

- new estimated structures that fit into the current session model
- moved estimated options
- new non-estimated options
- modified non-estimated option data such as description, price, GPC, or package status

It is designed around the idea that the session itself already exists and should be refreshed, not rebuilt from scratch.

## What Refresh Session Does Not Rebuild

Refresh Session does **not** recreate the session from the ground up.

In practical terms, that means it does not act like a brand new session creation. It does not fully rebuild the session's category structure, navigation structure, or overall organization model. Instead, it looks for differences and applies supported changes into the existing session.

This is important because a user may correctly expect refreshed content to appear, while still seeing the session remain organized according to the session's existing structure.

## Important Nuances for Users and Support

### 1. Refresh starts with the existing session

Refresh Session assumes the current session is still the thing being updated. It does not discard the session and create a replacement.

### 2. Estimated and non-estimated data behave differently

Estimated content depends on pricing / Echelon session data.

Non-estimated content depends on builder catalog data.

Because of that, it is possible for a session to see non-estimated changes even when estimated refresh changes are limited.

### 3. Some changes are grouped

The application groups certain change types into named change sets such as:

- `NewBuilds`
- `NewPriceLevels`
- `NewOptions`
- `MovedOptions`
- `MovedSelectedOptions`
- `NewNonEstimatedItems`
- `ModifiedNonEstimatedItems`

That grouping helps the user review related changes together.

### 4. A moved option can affect selected content

When an option moved from one price level or area / sub area to another is already tied to selected content, the UI can show impacted areas and whether the move results in:

- price increase
- price decrease
- no price change

### 5. Updated non-estimated items can be split by price override

The UI separates updated non-estimated items that have a price override from those that do not. That helps users and support understand why some updates deserve closer review before applying.

## When Refresh Session Is Most Helpful

Refresh Session is most helpful when the source data has changed in a way that fits the existing session structure, such as:

- newly published areas or builds
- new price levels
- new field color / style options
- moved options
- builder catalog updates for non-estimated items

## When a User May Need More Than a Refresh

If the builder's organization of applications, products, or categories has changed in a deeper way, Refresh Session may not tell the whole story of the newer category structure.

That is not because the feature failed. It is because Refresh Session is designed to reveal and apply supported changes inside an existing session, not fully remap the session to a newly reorganized category model.

For that deeper topic, see:

- `session-categories-vs-refresh-session.md`

## Technical References

This guide is based on code analysis of the following key files:

- `VeoDesignStudio\Controllers\Sessions\SessionChangesController.cs`
- `VeoDesignStudio\App\features\homebuyerSummary\sessionCard\sessionCard.js`
- `VeoDesignStudio\App\features\refreshSession\refreshSession.ts`
- `VeoDesignStudio\App\features\refreshSession\refreshSession.html`
- `BuildOnTechnologies.VDS.Services\RefreshSession\GetSessionChanges.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\ApplySessionChanges.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\SessionChangeAnalyzerFactory.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Models\GetSessionChangesResponseDTO.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Models\SessionChangeset.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForNewPriceLevelOptions.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForMovedPriceLevelOptions.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForNewBuilds.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForNewPricesLevelsInBuilds.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForWarning.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForNewNonEstimatedItems.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Analyzers\AnalyzeSessionForModifiedNonEstimatedItems.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\Models\NonEstimatedItemsComparisonDTO.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\NonEstimatedItemComparer\NonEstimatedItemComparer.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\NonEstimatedItemComparer\NonEstimatedItemDefaultComparer.cs`
- `BuildOnTechnologies.VDS.Services\RefreshSession\NonEstimatedItemComparer\NonEstimatedItemItemNoComparer.cs`
