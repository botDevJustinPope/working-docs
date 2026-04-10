-- ===========================================================================
-- Deployment Script: Product Search Stored Procedures
-- Story:  20260408_20260421_productsearch4
-- Date:   2026-04-10
-- Author: Justin Pope
-- ===========================================================================
-- Deploys two stored procedures to all four production VeoSolutions databases:
--
--   1. [dbo].[vds_selSessionProductSearchOptions]
--   2. [dbo].[vds_selNonSessionEstimatedProductSearchOptions]
--
-- Connect to the production SQL server and execute this script as-is.
-- ===========================================================================

SET NOCOUNT ON;
GO
-- ===========================================================================
-- [VeoSolutions]
-- ===========================================================================

PRINT '=========================================================';
PRINT ' Deploying to [VeoSolutions]';
PRINT '=========================================================';

USE [VeoSolutions];
GO

PRINT '  vds_selSessionProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selSessionProductSearchOptions]
	@session_id                UNIQUEIDENTIFIER,
	@security_token            UNIQUEIDENTIFIER,
	@search_term               VARCHAR(250)     = NULL,
	@builder_overrides_enabled BIT              = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-09
	Description:
		Returns a unified result set of ALL estimated (field colors) and
		non-estimated (catalog) items for a session, intended for product search.

		Estimated items are resolved set-based across all builds via CTEs, replacing the
		per-build N+1 pattern of vds_selHomebuyerCatalogBuilds +
		vds_selHomebuyerCatalogFieldColorsForBuild.  The same four color-resolution
		paths are preserved (group→style→color, group→color, style→color, color).

		Non-estimated items mirror vds_selSessionCatalogItems
		(catalog_selections WHERE source IN ('catalog', 'user')).

	Modified: Justin Pope
	Date: 2026-03-23
	Description: Reworked the estimated-item query to materialize session/build
		helpers in temp tables, preserve the existing field-color hierarchy with
		ordered insert statements, and continue exclusion handling through
		dbo.vdsf_selSpecAreaExcludedParts.

	Modified: Justin Pope
	Date: 2026-04-01
	Description: Product Option search was returning more builds than were on the session. Adding condition
		limits those to only those on the session.



	Modified: Justin Pope
	Date: 2026-04-07
	Description: Propagate option_pricing_display from catalog_selections through the
		estimated-item pipeline (#price_levels → #resolved_colors) so estimated items
		carry the actual value instead of a hardcoded 1.

	Output columns:
		source_type              VARCHAR(20)       -- 'estimated' | 'non_estimated'
		name                     VARCHAR(1500)     -- part name (respects builder overrides for estimated)
		application              VARCHAR(100)
		product                  VARCHAR(100)
		area                     VARCHAR(250)
		sub_area                 VARCHAR(250)
		price                    DECIMAL(18,4)
		price_level              VARCHAR(1000)     -- NULL for non-estimated
		part_no                  VARCHAR(250)      -- NULL for non-estimated
		item_no                  VARCHAR(250)      -- NULL for estimated
		gpc_id                   UNIQUEIDENTIFIER  -- NULL for estimated when cast fails
		option_pricing_display   BIT               -- catalog_selections value option_pricing_display
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'
	DECLARE @search_pattern VARCHAR(252) = '%' + ISNULL(@search_term, '') + '%'

	-- Final unified result set returned to the API.
	CREATE TABLE #parts
	(
		[source_type]            VARCHAR(20),
		[name]                   VARCHAR(1500),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[price]                  DECIMAL(18,4),
		[price_level]            VARCHAR(1000),
		[part_no]                VARCHAR(250),
		[item_no]                VARCHAR(250),
		[gpc_id]                 UNIQUEIDENTIFIER,
		[build_id]               INT,
		[option_pricing_display] BIT
	);

	-- Session build context drives both estimated-color resolution and exclusions.
	CREATE TABLE #builds
	(
		[session_id]     UNIQUEIDENTIFIER,
		[spec_id]        INT,
		[builder_id]     VARCHAR(20),
		[build_id]       INT NOT NULL PRIMARY KEY,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[location_id]    INT
	);

	-- Price levels are filtered up front to the only types that can resolve field colors.
	CREATE TABLE #price_levels
	(
		[session_id]         UNIQUEIDENTIFIER,
		[build_id]           INT,
		[spec_id]            INT,
		[builder_id]         VARCHAR(20),
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_name]   VARCHAR(1500),
		[price_level_type]   VARCHAR(10),
		[price_level_id]     VARCHAR(81),
		[price_level_price]      DECIMAL(18,4),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[option_pricing_display] BIT,
		PRIMARY KEY ([price_level_type], [spec_id], [application_id], [product_id], [price_level_id], [build_id], [area_id], [sub_area_id])
	);

	-- Session group detail is split by item_type so the two group-based paths stay narrow.
	CREATE TABLE #session_group_styles
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	CREATE TABLE #session_group_colors
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	-- The resolved color set is populated in priority order with INSERT ... SELECT ... WHERE NOT EXISTS queries so earlier paths win.
	CREATE TABLE #resolved_colors
	(
		[spec_id]            INT,
		[build_id]           INT,
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_id]     VARCHAR(81),
		[price_level_name]   VARCHAR(1500),
		[price_level_price]  DECIMAL(18,4),
		[application]        VARCHAR(100),
		[product]            VARCHAR(100),
		[area]               VARCHAR(250),
		[sub_area]           VARCHAR(250),
		[part_no]            VARCHAR(81),
		[stocking_code]      VARCHAR(50),
		[global_product_id]  VARCHAR(100),
		[part_name_official]     VARCHAR(1500),
		[option_pricing_display] BIT,
		PRIMARY KEY ([build_id], [price_level_id], [part_no])
	);

	-- Exclusions stay centralized through the shared function so behavior matches other callers.
	CREATE TABLE #spec_area_exclusions
	(
		[spec_id]        INT,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[part_no]        VARCHAR(81),
		PRIMARY KEY ([spec_id], [application_id], [product_id], [area_id], [sub_area_id], [part_no])
	);

	INSERT INTO #builds
	(
		[session_id],
		[spec_id],
		[builder_id],
		[build_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id]
	)
	SELECT
		s.[session_id],
		vpm.[spec_id],
		vsm.[builder_id],
		vpb.[build_id],
		vpb.[application_id],
		vpb.[product_id],
		vpb.[area_id],
		vpb.[sub_area_id],
		vpb.[location_id]
	FROM
		[account_organization_user_profile_plan_catalog_sessions] s
		JOIN [catalog_selections_areas] csa ON csa.[session_id] = s.[session_id]
												AND csa.[area_selected] = 1
		JOIN [veo_spec_mstr] vsm ON vsm.[spec_id] = s.[spec_id]
		JOIN [veo_plan_mstr] vpm ON vpm.[spec_id] = vsm.[spec_id]
		JOIN [veo_plan_builds] vpb
			ON  vpb.[plan_id] = vpm.[plan_id]
			AND vpb.[build_id] = csa.[build_id]
	WHERE
		s.[session_id] = @session_id;

	INSERT INTO #price_levels
	(
		[session_id],
		[build_id],
		[spec_id],
		[builder_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id],
		[price_level_name],
		[price_level_type],
		[price_level_id],
		[price_level_price],
		[application],
		[product],
		[area],
		[sub_area],
		[option_pricing_display]
	)
	SELECT
		b.[session_id],
		b.[build_id],
		b.[spec_id],
		b.[builder_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		b.[location_id],
		cs.[item]                    AS [price_level_name],
		cs.[item_type]               AS [price_level_type],
		cs.[item_no]                 AS [price_level_id],
		cs.[price]                   AS [price_level_price],
		cs.[application],
		cs.[product],
		cs.[area],
		cs.[sub_area],
		cs.[option_pricing_display]
	FROM
		#builds b
		JOIN [catalog_selections] cs
			ON  cs.[session_id] = b.[session_id]
			AND cs.[build_id] = b.[build_id]
	WHERE
		cs.[item_type] IN ('group', 'style', 'color');

	INSERT INTO #session_group_styles
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'style';

	INSERT INTO #session_group_colors
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'color';

	-- =============================================
	-- #1 spec_items --> groups -> styles -> colors
	-- =============================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_styles sgs
			ON  sgs.[group_id] = sg.[group_id]
			AND sgs.[area_id] IN ('', pl.[area_id])
			AND sgs.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [Veo_styles] s
			ON  s.[product_id] = sg.[product_id]
			AND s.[style_id] = sgs.[item]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = s.[product_id]
			AND c.[style_id] = s.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		and not exists(
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		)


	-- =========================================
	-- #2 spec_items --> groups -> colors
	-- =========================================
	INSERT INTO #resolved_colors 
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_colors sgc
			ON  sgc.[group_id] = sg.[group_id]
			AND sgc.[area_id] IN ('', pl.[area_id])
			AND sgc.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [veo_colors] c ON c.[part_no] = sgc.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);

	-- =========================================
	-- #3 spec_items --> styles -> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = si.[product_id]
			AND c.[style_id] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'style'
		AND s.[class] = @item_class
		AND NOT EXISTS(
			SELECT 1 FROM #resolved_colors rc
			WHERE rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);
	
	-- =========================================
	-- #4 spec_items --> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'color'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			SELECT 1 FROM #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);	

	-- Preserve shared exclusion behavior by routing session/build combinations
	-- through the existing function instead of re-implementing exclusion logic here.
	INSERT INTO #spec_area_exclusions
	(
		[spec_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[part_no]
	)
	SELECT DISTINCT
		b.[spec_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		e.[part_no]
	FROM
		#builds b
		CROSS APPLY dbo.[vdsf_selSpecAreaExcludedParts]
		(
			@session_id,
			b.[spec_id],
			b.[application_id],
			b.[product_id],
			b.[area_id],
			b.[sub_area_id],
			b.[location_id],
			'field'
		) e;

	-- Estimated search rows come from the resolved field-color set after selectable
	-- and exclusion filtering are applied.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT
		'estimated' AS [source_type],
		rc.[part_name_official] AS [name],
		rc.[application] AS [application],
		rc.[product] AS [product],
		rc.[area] AS [area],
		rc.[sub_area] AS [sub_area],
		rc.[price_level_price] AS [price],
		SUBSTRING(rc.[price_level_name], 1, 1000) AS [price_level],
		rc.[part_no] AS [part_no],
		NULL AS [item_no],
		TRY_CAST(rc.[global_product_id] AS UNIQUEIDENTIFIER) AS [gpc_id],
		rc.[build_id] AS [build_id],
		rc.[option_pricing_display] AS [option_pricing_display]
	FROM
		#resolved_colors rc
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = rc.[stocking_code]
		LEFT JOIN #spec_area_exclusions sae
			ON  sae.[spec_id] = rc.[spec_id]
			AND sae.[application_id] = rc.[application_id]
			AND sae.[product_id] = rc.[product_id]
			AND sae.[area_id] = rc.[area_id]
			AND sae.[sub_area_id] = rc.[sub_area_id]
			AND sae.[part_no] = rc.[part_no]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND sae.[part_no] IS NULL
		AND
		(
			rc.[part_name_official] LIKE @search_pattern
			OR rc.[part_no] LIKE @search_pattern
		);

	-- Non-estimated search rows continue to come directly from catalog selections.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT DISTINCT
		'non_estimated' AS [source_type],
		SUBSTRING(cs.[item], 1, 1500) AS [name],
		cs.[application] AS [application],
		cs.[product] AS [product],
		a.[name] AS [area],
		sa.[name] AS [sub_area],
		cs.[price] AS [price],
		NULL AS [price_level],
		NULL AS [part_no],
		cs.[item_no] AS [item_no],
		TRY_CAST(cs.[gpc] AS UNIQUEIDENTIFIER) AS [gpc_id],
		NULL AS [build_id],
		cs.[option_pricing_display] AS [option_pricing_display]
	FROM
		[dbo].[catalog_selections] cs
		LEFT JOIN [veo_areas] a ON a.[area_id] = cs.[area]
		LEFT JOIN [veo_sub_areas] sa ON sa.[sub_area_id] = cs.[sub_area]
	WHERE
		cs.[session_id] = @session_id
		AND cs.[source] IN ('catalog', 'user')
		AND
		(
			cs.[item] LIKE @search_pattern
			OR cs.[item_no] LIKE @search_pattern
		);

	SELECT * FROM #parts;
END
GO

PRINT '  vds_selNonSessionEstimatedProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selNonSessionEstimatedProductSearchOptions]
	@security_token            UNIQUEIDENTIFIER,
	@account_id                UNIQUEIDENTIFIER,
	@organization_id           UNIQUEIDENTIFIER,
	@community_name            VARCHAR(100),
	@series_name               VARCHAR(100),
	@plan_name                 VARCHAR(100),
	@search_term               VARCHAR(250),
	@builder_overrides_enabled BIT = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-16
	Description:
		Returns estimated (field color) items for a non-session product search.
		Replaces the multi-step, N+1 Yukon pattern in GetNonSessionProductSearchOptions:
		  - community/series/plan resolution from VeoSolutionsSecurity mapping tables
		  - active spec + plan + effective date resolution through Veo/WBS data
		  - max build per area via window functions (replaces vds_optionPricingMaxMinBuilds cursor)
		  - color resolution via four paths mirroring vds_selSessionProductSearchOptions
		  - builder name overrides via veo_colors_customer_overrides

		All in a single DB round-trip against VeoSolutions using local synonyms for
		Veo and WBS data.

	Output columns (matches @parts shape of vds_selSessionProductSearchOptions):
		source_type   VARCHAR(20)       -- always 'estimated'
		name          VARCHAR(1500)     -- part name (respects builder overrides)
		application   VARCHAR(100)
		product       VARCHAR(100)
		area          VARCHAR(250)      -- display name
		sub_area      VARCHAR(250)      -- display name
		price         DECIMAL(18,4)
		price_level   VARCHAR(1000)     -- price level display name
		part_no       VARCHAR(250)
		item_no       VARCHAR(250)      -- always NULL for estimated
		gpc_id        UNIQUEIDENTIFIER  -- always NULL for estimated
		build_id      INT

	Modified: Justin Pope
	Date: 2026-04-02
	Description:
		Fixed an issue where multiple builds for the same area/sub_area were producing
		duplicate rows in the result set. The build_candidates CTE was using RANK() partitioned
		by (application_id, product_id, area_id, sub_area_id, location_id). Two problems:
		  1. RANK() assigns the same rank to tied rows (equal bill_qty), so multiple builds
		     could share build_rank = 1 for the same partition.
		  2. Including location_id in the partition meant that a single area/sub_area with
		     multiple location rows in prices_landed produced one winning build per location,
		     causing the same area/sub_area to appear multiple times downstream.
		Fix: Changed RANK() to ROW_NUMBER() and removed location_id from the PARTITION BY,
		so exactly one build is selected per application/product/area/sub_area. Added
		build_id DESC as a deterministic tiebreaker when bill_qty values are equal.
		location_id was also removed from the selected_builds, price_levels, and resolved_colors
		CTEs since it is not part of the output and was the source of the fan-out.
	Modified: Daniela
	Date: 2026-04-07
	Description:
		Two additional alignment fixes with vds_selEstimatedOptionPricingItemsForNonSession_Yukon:
		  1. Price rounding: price_level_price now applies CEILING(price / 10.0) * 10 to match
		     the outer proc's ((CEILING(SUM(price_retail) / 10)) * 10) rounding.
		  2. Zero/negative area exclusion: build_candidates now uses an EXISTS against wbs_plan_material
		     (matching on plan_id + build_id, any item) to require at least one positive bill_qty row —
		     mirroring the outer proc's pbm.bill_qty > 0 filter. The original fix used the narrow pm2
		     'field'-item join which incorrectly excluded builds like "All Carpeted Areas" that don't
		     carry a 'field' item for every area combination.

	Modified: Daniela
	Date: 2026-04-07
	Description:
		Aligned build selection and area labeling with vds_selEstimatedOptionPricingItemsForNonSession_Yukon
		so that the area and build_id values returned here match what that proc returns for the same plan.
		Two root causes addressed:
		  1. Build selection now respects the builder's opt_pricing_build_type setting (read from
		     wbs_customers). Previously it always selected the maximum build. Now it supports
		     'maximum', 'minimum', and default (standard/is_std) modes.
		  2. The area column is now replaced with build_desc (the build's display name from
		     plan_builds), mirroring the outer proc's Step 8 area-label swap. When @group_walls=1,
		     tile items in bathrooms (room_group 2 or 3) are grouped into "<AreaName> Walls".
		Also: renamed the max_builds CTE to selected_builds for clarity, added wbs_customers and
		wbs_room_groups synonyms to support the new logic.
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'

	-- ============================================================
	-- Phase 1 — Resolve candidate names and match a Veo spec/plan
	-- ============================================================
	DECLARE @effective_date DATETIME = GETDATE()
	DECLARE @effective_date_no_time DATE = CONVERT(DATE, @effective_date)

	DECLARE @external_org_id VARCHAR(50)

	DECLARE @resolved_spec_id INT
	DECLARE @active_spec_id INT
	DECLARE @prices_landed_effective_date DATETIME
	DECLARE @plan_id INT
	
	-- external_organization_id (builder_id in WBS)
	SELECT @external_org_id = vso.[external_organization_id]
	FROM   [VeoSolutionsSecurity_organizations] vso
		inner join [VeoSolutionsSecurity_account_organizations] vsao on vsao.[organization_id] = vso.[organization_id]
	WHERE  vso.[organization_id] = @organization_id
		and vsao.[account_id] = @account_id;
		
	;WITH communities
    AS
    (
        select 
            vsm.[spec_id],
            vsm.[start_date],
            vc.community_id,
            vc.[name] as [community_name]
        from 
            Veo_spec_communities vsc
            JOIN Veo_spec_mstr vsm on vsm.spec_id = vsc.spec_id
            JOIN Veo_communities vc on vc.community_id = vsc.community_id
            JOIN (
                -- Fetch VDS community names (builder names)
                SELECT
                    aoc.name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name

                UNION

                -- Fetch mapped community names (Wisenbaker names)
                SELECT
                    aocm.mapped_name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                    JOIN VeoSolutionsSecurity_account_organization_communities_mappings aocm  ON aocm.account_id = aoc.account_id AND aocm.organization_id = aoc.organization_id AND aocm.community_id = aoc.community_id
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name
                    ) vss_c on vss_c.community_name = vc.[name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
	series
    AS
    (
        SELECT
            vsm.spec_id,
            vsm.[start_date],
            vss.series as [series_name]
        FROM
            Veo_spec_series vss
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vss.spec_id
            JOIN (
                -- Fetch VDS series names (builder names)
                SELECT
                    aos.name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name

                UNION

                -- Fetch mapped series names (Wisenbaker names)
                SELECT
                    aosm.mapped_name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                    JOIN VeoSolutionsSecurity_account_organization_series_mappings aosm ON aosm.account_id = aos.account_id AND aosm.organization_id = aos.organization_id AND aosm.series_id = aos.series_id
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name
                    ) vss_s on vss_s.series_name = vss.series
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
    plans
    AS
    (
        SELECT
            vsm.[spec_id],
            vsm.[start_date],
            vpm.[plan_id] as [plan_id],
            vpm.[plan_name] as [plan_name]
        FROM
            Veo_plan_mstr vpm
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vpm.[spec_id]
            JOIN (        
                -- Fetch VDS plans names
                SELECT
                    aop.name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name

                union

                -- Fetch mapped plans names
                SELECT
                    aopm.mapped_name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                    LEFT JOIN VeoSolutionsSecurity_account_organization_plans_mappings aopm
                        ON aopm.account_id = aop.account_id
                        AND aopm.organization_id = aop.organization_id
                        AND aopm.plan_id = aop.plan_id
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name
                    ) vss_p  on vss_p.[plans_name] = vpm.[plan_name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
            and (vpm.end_date >= @effective_date or vpm.end_date is null)
            and vpm.active = 1
       )
	SELECT top 1
        @active_spec_id = sm.[spec_id], 
        @prices_landed_effective_date = p.effective_date, 
        @plan_id = pm.plan_id
	FROM
		[wbs_spec_mstr]        sm
		JOIN [wbs_spec_communities] sc    ON sc.[spec_id]       = sm.[spec_id]
        join [communities]          cte_c on cte_c.community_id = sc.community_id
                                         and cte_c.spec_id      = sm.spec_id
		JOIN [wbs_spec_series]      ss    ON ss.[spec_id]       = sm.[spec_id]
        join [series]               cte_s on cte_s.series_name  = ss.series
                                         and cte_s.spec_id      = sm.spec_id
        JOIN [wbs_plan_mstr]        pm    on pm.spec_id         = sm.spec_id
        join [plans]                cte_p on cte_p.plan_id      = pm.plan_id
                                         and cte_p.spec_id      = sm.spec_id
		JOIN [wbs_pricesets]        p     ON p.[spec_id]        = sm.[spec_id]
	WHERE
		sm.[builder_id]    = @external_org_id
		AND sm.[active]        = 1
		AND (sm.[end_date] IS NULL OR sm.[end_date] >= CONVERT(DATE, @effective_date))
		AND p.[active]         = 1
		AND p.[effective_date] <= @effective_date
	ORDER BY
		p.[effective_date] DESC

	IF @account_id IS NULL OR @organization_id IS NULL OR @active_spec_id IS NULL OR @plan_id IS NULL OR @prices_landed_effective_date IS NULL
		RETURN

	-- Read build-selection behavior configured per builder in the customers table.
	-- @build_type : 'maximum' | 'minimum' | '' (empty = standard/default)
	-- @group_walls: 1 = merge bath tile walls into a single area row
	DECLARE @build_type  VARCHAR(10) = ''
	DECLARE @group_walls BIT         = 0
	SELECT
		@build_type  = ISNULL(c.[opt_pricing_build_type], ''),
		@group_walls = ISNULL(c.[group_walls], 0)
	FROM [wbs_customers] c
	WHERE c.[custnmbr] = @external_org_id

	-- ============================================================
	-- Output collector
	-- ============================================================
	DECLARE @parts TABLE
	(
		[source_type] VARCHAR(20),
		[name]        VARCHAR(1500),
		[application] VARCHAR(100),
		[product]     VARCHAR(100),
		[area]        VARCHAR(250),
		[sub_area]    VARCHAR(250),
		[price]       DECIMAL(18,4),
		[price_level] VARCHAR(1000),
		[part_no]     VARCHAR(250),
		[item_no]     VARCHAR(250),
		[gpc_id]      UNIQUEIDENTIFIER,
		[build_id]    INT
	)

	-- ============================================================
	-- Phase 3+4 — Build selection CTE + price levels + color resolution
	-- ============================================================
	;WITH
	-- Determine the single representative build per application/product/area/sub_area.
	-- Partitioned WITHOUT location_id so that multiple locations for the same area/sub_area
	-- do not produce multiple winning builds and duplicate rows in the final output.
	-- ROW_NUMBER (not RANK) guarantees exactly one winner even when bill_qty ties.
	-- Only builds that have at least one plan_material row with bill_qty > 0 are considered
	-- (mirrors the outer proc's pbm.bill_qty > 0 filter via a broad EXISTS, not limited to the
	-- 'field' item, to avoid incorrectly excluding builds like "All Carpeted Areas" that may not
	-- carry a 'field' item in plan_material for every application/product/area combination).
	-- Build selection is driven by @build_type (read from wbs_customers):
	--   'maximum' → highest bill_qty wins; build_id DESC breaks ties
	--   'minimum' → lowest bill_qty wins; build_id DESC breaks ties
	--   default   → is_std build wins; bill_qty DESC and build_id DESC break ties
	-- Exception: cabinets (application_id='10', product_id='Y') always use their is_std build.
	[build_candidates] AS
	(
		SELECT
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[build_id],
			pb.[build_desc],
			ROW_NUMBER() OVER
			(
				PARTITION BY pl.[application_id], pl.[product_id], pl.[area_id], pl.[sub_area_id]
				ORDER BY
					-- Cabinets: std build always wins regardless of @build_type
					CASE
						WHEN pl.[application_id] = '10' AND pl.[product_id] = 'Y' AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- For default/std build_type: is_std build takes priority over bill_qty
					CASE
						WHEN ISNULL(@build_type, '') NOT IN ('maximum', 'minimum') AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- bill_qty: negated for 'minimum' so DESC sort always selects the correct extreme
					CASE
						WHEN @build_type = 'minimum'
							THEN -ISNULL(pm2.[bill_qty], 0)
						ELSE ISNULL(pm2.[bill_qty], 0)
					END DESC,
					pl.[build_id] DESC
			) AS [build_rank]
		FROM
			[wbs_prices_landed]  pl
			LEFT JOIN [wbs_plan_builds]  pb
				ON  pb.[build_id]       = pl.[build_id]
				AND pb.[plan_id]        = pl.[plan_id]
			LEFT JOIN [wbs_plan_material] pm2
				ON  pm2.[plan_id]       = pb.[plan_id]
				AND pm2.[build_id]      = pb.[build_id]
				AND pm2.[application_id] = pb.[application_id]
				AND pm2.[product_id]    = pb.[product_id]
				AND pm2.[area_id]       = pb.[area_id]
				AND pm2.[sub_area_id]   = pb.[sub_area_id]
				AND pm2.[location_id]   = pb.[location_id]
				AND pm2.[item_id]       = 'field'
		WHERE
			pl.[plan_id]        = @plan_id
			AND pl.[effective_date] = @prices_landed_effective_date
			AND EXISTS
			(
				-- Mirror the outer proc's pbm.bill_qty > 0 filter: require at least one
				-- plan_material row for this plan+build (any item) to have positive bill_qty.
				-- Using a broad EXISTS rather than the pm2 'field'-item join avoids incorrectly
				-- excluding builds whose field item is absent or uses a different item classification.
				SELECT 1
				FROM [wbs_plan_material] pm3
				WHERE pm3.[plan_id]  = pl.[plan_id]
				  AND pm3.[build_id] = pl.[build_id]
				  AND pm3.[bill_qty] > 0
			)
	),
	[selected_builds] AS
	(
		SELECT [application_id], [product_id], [area_id], [sub_area_id], [build_id], [build_desc]
		FROM   [build_candidates]
		WHERE  [build_rank] = 1
	),
	-- Price levels: prices_landed rows for the selected build, with display names applied.
	-- Mirrors what vds_selEstimatedOptionPricingItemsForNonSession_Yukon returns
	-- but as a CTE rather than a separate procedure call.
	-- area is replaced with build_desc (mirroring the outer proc's Step 8 area-label swap).
	-- When @group_walls=1, tile items in bathrooms (room_group 2 or 3) are grouped into
	-- a single "<AreaName> Walls" area with sub_area cleared.
	[price_levels] AS
	(
		SELECT DISTINCT
			mb.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[item_type]                                        AS [price_level_type],
			pl.[item]                                             AS [price_level_id],
			ISNULL(bs.[builder_style_name], pl.[customer_item_name]) AS [price_level_name],
			CEILING(pl.[price_retail] / 10.0) * 10               AS [price_level_price],
			LTRIM(RTRIM(ap.[name]))                               AS [application],
			LTRIM(RTRIM(pr.[name]))                               AS [product],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ar.[name] + ' Walls'
				ELSE mb.[build_desc]
			END                                                   AS [area],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ''
				WHEN mb.[build_desc] IS NOT NULL
					THEN ''
				ELSE sar.[name]
			END                                                   AS [sub_area]
		FROM
			[wbs_prices_landed]      pl
			JOIN [selected_builds] mb
				ON  mb.[build_id]       = pl.[build_id]
				AND mb.[application_id] = pl.[application_id]
				AND mb.[product_id]     = pl.[product_id]
				AND mb.[area_id]        = pl.[area_id]
				AND mb.[sub_area_id]    = pl.[sub_area_id]
			JOIN [wbs_plan_builds]   pb  ON pb.[build_id]      = pl.[build_id]
			                                           AND pb.[plan_id]       = pl.[plan_id]
			JOIN [wbs_plan_mstr]     pm  ON pm.[plan_id]       = pb.[plan_id]
			JOIN [wbs_areas]         ar  ON ar.[area_id]       = pl.[area_id]
			LEFT JOIN [wbs_room_groups] rg ON rg.[code]        = ar.[room_group]
			JOIN [wbs_sub_areas]     sar ON sar.[sub_area_id]  = pl.[sub_area_id]
			JOIN [wbs_applications]  ap  ON ap.[application_id] = pl.[application_id]
			JOIN [wbs_products]      pr  ON pr.[product_id]    = pl.[product_id]
			LEFT JOIN [wbs_spec_areas_items] sai
				ON  sai.[spec_id]       = pm.[spec_id]
				AND sai.[application_id] = pl.[application_id]
				AND sai.[product_id]    = pl.[product_id]
				AND sai.[area_id]       = pl.[area_id]
				AND sai.[sub_area_id]   = pl.[sub_area_id]
				AND (sai.[location_id]  = pl.[location_id] OR sai.[location_id] = 0)
				AND sai.[item_type]     = pl.[item_type]
				AND sai.[item]          = pl.[item]
			LEFT JOIN [wbs_areas_sub_areas] asa
				ON  asa.[area_id]       = ar.[area_id]
				AND asa.[sub_area_id]   = sar.[sub_area_id]
			LEFT JOIN [wbs_builder_styles] bs
				ON  bs.[builder_id]     = @external_org_id
				AND bs.[spec_id]        = pm.[spec_id]
				AND bs.[item_type]      = pl.[item_type]
				AND bs.[item]           = pl.[item]
				AND bs.[effective_date] = @prices_landed_effective_date
		WHERE
			pl.[plan_id]                  =  @plan_id
			AND pm.[spec_id]              =  @active_spec_id
			AND pm.[plan_id]              =  @plan_id
			AND pl.[effective_date]       =  @prices_landed_effective_date
			AND ISNULL(sai.[excluded], 0) <> 1
			AND (asa.[exclude_quick_price_display] = 0 OR asa.[exclude_quick_price_display] IS NULL)
			AND pm.[active]               =  1
			AND (pm.[end_date] IS NULL OR pm.[end_date] > GETDATE())
	),
	-- Resolve parts (colors) from price levels.
	-- Four paths mirror vds_selSessionProductSearchOptions resolved_colors CTE.
	-- Key difference from session: uses [wbs_spec_items] (not veo_spec_items)
	-- and [wbs_styles_groups_detail] (not catalog_selections_group_detail)
	-- since there is no homebuyer session selection to reference.
	[resolved_colors] AS
	(
		-- Path 1: spec_items (group) → styles_groups_detail (style) → styles → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'style'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = sg.[product_id]
				AND s.[style_id]   = sgd.[item]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = s.[product_id]
				AND c.[style_id]   = s.[style_id]
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 2: spec_items (group) → styles_groups_detail (color) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'color'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [veo_colors] c ON c.[part_no] = sgd.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 3: spec_items (style) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = si.[product_id]
				AND c.[style_id]   = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'style'

		UNION ALL

		-- Path 4: spec_items (color) → colors (direct part_no match)
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'color'
	)
	INSERT INTO @parts ([source_type], [name], [application], [product], [area], [sub_area], [price], [price_level], [part_no], [item_no], [gpc_id], [build_id])
	SELECT DISTINCT
		'estimated'                                          AS [source_type],
		c.[part_name_official]                               AS [name],
		c.[application]                                      AS [application],
		c.[product]                                          AS [product],
		c.[area]                                             AS [area],
		c.[sub_area]                                         AS [sub_area],
		c.[price_level_price]                                AS [price],
		SUBSTRING(c.[price_level_name], 1, 1000)             AS [price_level],
		c.[part_no]                                          AS [part_no],
		NULL                                                 AS [item_no],
		TRY_CAST(c.[global_product_id] AS UNIQUEIDENTIFIER)  AS [gpc_id],
		c.[build_id]                                         AS [build_id]
	FROM
		[resolved_colors] c
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = c.[stocking_code]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND (
			c.[part_name_official] LIKE '%' + ISNULL(@search_term, '') + '%'
			OR c.[part_no]         LIKE '%' + ISNULL(@search_term, '') + '%'
		)

	SELECT * FROM @parts
END
GO

PRINT ' [VeoSolutions] complete.';
GO

-- ===========================================================================
-- [EPLAN_VeoSolutions]
-- ===========================================================================

PRINT '=========================================================';
PRINT ' Deploying to [EPLAN_VeoSolutions]';
PRINT '=========================================================';

USE [EPLAN_VeoSolutions];
GO

PRINT '  vds_selSessionProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selSessionProductSearchOptions]
	@session_id                UNIQUEIDENTIFIER,
	@security_token            UNIQUEIDENTIFIER,
	@search_term               VARCHAR(250)     = NULL,
	@builder_overrides_enabled BIT              = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-09
	Description:
		Returns a unified result set of ALL estimated (field colors) and
		non-estimated (catalog) items for a session, intended for product search.

		Estimated items are resolved set-based across all builds via CTEs, replacing the
		per-build N+1 pattern of vds_selHomebuyerCatalogBuilds +
		vds_selHomebuyerCatalogFieldColorsForBuild.  The same four color-resolution
		paths are preserved (group→style→color, group→color, style→color, color).

		Non-estimated items mirror vds_selSessionCatalogItems
		(catalog_selections WHERE source IN ('catalog', 'user')).

	Modified: Justin Pope
	Date: 2026-03-23
	Description: Reworked the estimated-item query to materialize session/build
		helpers in temp tables, preserve the existing field-color hierarchy with
		ordered insert statements, and continue exclusion handling through
		dbo.vdsf_selSpecAreaExcludedParts.

	Modified: Justin Pope
	Date: 2026-04-01
	Description: Product Option search was returning more builds than were on the session. Adding condition
		limits those to only those on the session.



	Modified: Justin Pope
	Date: 2026-04-07
	Description: Propagate option_pricing_display from catalog_selections through the
		estimated-item pipeline (#price_levels → #resolved_colors) so estimated items
		carry the actual value instead of a hardcoded 1.

	Output columns:
		source_type              VARCHAR(20)       -- 'estimated' | 'non_estimated'
		name                     VARCHAR(1500)     -- part name (respects builder overrides for estimated)
		application              VARCHAR(100)
		product                  VARCHAR(100)
		area                     VARCHAR(250)
		sub_area                 VARCHAR(250)
		price                    DECIMAL(18,4)
		price_level              VARCHAR(1000)     -- NULL for non-estimated
		part_no                  VARCHAR(250)      -- NULL for non-estimated
		item_no                  VARCHAR(250)      -- NULL for estimated
		gpc_id                   UNIQUEIDENTIFIER  -- NULL for estimated when cast fails
		option_pricing_display   BIT               -- catalog_selections value option_pricing_display
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'
	DECLARE @search_pattern VARCHAR(252) = '%' + ISNULL(@search_term, '') + '%'

	-- Final unified result set returned to the API.
	CREATE TABLE #parts
	(
		[source_type]            VARCHAR(20),
		[name]                   VARCHAR(1500),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[price]                  DECIMAL(18,4),
		[price_level]            VARCHAR(1000),
		[part_no]                VARCHAR(250),
		[item_no]                VARCHAR(250),
		[gpc_id]                 UNIQUEIDENTIFIER,
		[build_id]               INT,
		[option_pricing_display] BIT
	);

	-- Session build context drives both estimated-color resolution and exclusions.
	CREATE TABLE #builds
	(
		[session_id]     UNIQUEIDENTIFIER,
		[spec_id]        INT,
		[builder_id]     VARCHAR(20),
		[build_id]       INT NOT NULL PRIMARY KEY,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[location_id]    INT
	);

	-- Price levels are filtered up front to the only types that can resolve field colors.
	CREATE TABLE #price_levels
	(
		[session_id]         UNIQUEIDENTIFIER,
		[build_id]           INT,
		[spec_id]            INT,
		[builder_id]         VARCHAR(20),
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_name]   VARCHAR(1500),
		[price_level_type]   VARCHAR(10),
		[price_level_id]     VARCHAR(81),
		[price_level_price]      DECIMAL(18,4),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[option_pricing_display] BIT,
		PRIMARY KEY ([price_level_type], [spec_id], [application_id], [product_id], [price_level_id], [build_id], [area_id], [sub_area_id])
	);

	-- Session group detail is split by item_type so the two group-based paths stay narrow.
	CREATE TABLE #session_group_styles
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	CREATE TABLE #session_group_colors
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	-- The resolved color set is populated in priority order with INSERT ... SELECT ... WHERE NOT EXISTS queries so earlier paths win.
	CREATE TABLE #resolved_colors
	(
		[spec_id]            INT,
		[build_id]           INT,
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_id]     VARCHAR(81),
		[price_level_name]   VARCHAR(1500),
		[price_level_price]  DECIMAL(18,4),
		[application]        VARCHAR(100),
		[product]            VARCHAR(100),
		[area]               VARCHAR(250),
		[sub_area]           VARCHAR(250),
		[part_no]            VARCHAR(81),
		[stocking_code]      VARCHAR(50),
		[global_product_id]  VARCHAR(100),
		[part_name_official]     VARCHAR(1500),
		[option_pricing_display] BIT,
		PRIMARY KEY ([build_id], [price_level_id], [part_no])
	);

	-- Exclusions stay centralized through the shared function so behavior matches other callers.
	CREATE TABLE #spec_area_exclusions
	(
		[spec_id]        INT,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[part_no]        VARCHAR(81),
		PRIMARY KEY ([spec_id], [application_id], [product_id], [area_id], [sub_area_id], [part_no])
	);

	INSERT INTO #builds
	(
		[session_id],
		[spec_id],
		[builder_id],
		[build_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id]
	)
	SELECT
		s.[session_id],
		vpm.[spec_id],
		vsm.[builder_id],
		vpb.[build_id],
		vpb.[application_id],
		vpb.[product_id],
		vpb.[area_id],
		vpb.[sub_area_id],
		vpb.[location_id]
	FROM
		[account_organization_user_profile_plan_catalog_sessions] s
		JOIN [catalog_selections_areas] csa ON csa.[session_id] = s.[session_id]
												AND csa.[area_selected] = 1
		JOIN [veo_spec_mstr] vsm ON vsm.[spec_id] = s.[spec_id]
		JOIN [veo_plan_mstr] vpm ON vpm.[spec_id] = vsm.[spec_id]
		JOIN [veo_plan_builds] vpb
			ON  vpb.[plan_id] = vpm.[plan_id]
			AND vpb.[build_id] = csa.[build_id]
	WHERE
		s.[session_id] = @session_id;

	INSERT INTO #price_levels
	(
		[session_id],
		[build_id],
		[spec_id],
		[builder_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id],
		[price_level_name],
		[price_level_type],
		[price_level_id],
		[price_level_price],
		[application],
		[product],
		[area],
		[sub_area],
		[option_pricing_display]
	)
	SELECT
		b.[session_id],
		b.[build_id],
		b.[spec_id],
		b.[builder_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		b.[location_id],
		cs.[item]                    AS [price_level_name],
		cs.[item_type]               AS [price_level_type],
		cs.[item_no]                 AS [price_level_id],
		cs.[price]                   AS [price_level_price],
		cs.[application],
		cs.[product],
		cs.[area],
		cs.[sub_area],
		cs.[option_pricing_display]
	FROM
		#builds b
		JOIN [catalog_selections] cs
			ON  cs.[session_id] = b.[session_id]
			AND cs.[build_id] = b.[build_id]
	WHERE
		cs.[item_type] IN ('group', 'style', 'color');

	INSERT INTO #session_group_styles
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'style';

	INSERT INTO #session_group_colors
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'color';

	-- =============================================
	-- #1 spec_items --> groups -> styles -> colors
	-- =============================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_styles sgs
			ON  sgs.[group_id] = sg.[group_id]
			AND sgs.[area_id] IN ('', pl.[area_id])
			AND sgs.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [Veo_styles] s
			ON  s.[product_id] = sg.[product_id]
			AND s.[style_id] = sgs.[item]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = s.[product_id]
			AND c.[style_id] = s.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		and not exists(
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		)


	-- =========================================
	-- #2 spec_items --> groups -> colors
	-- =========================================
	INSERT INTO #resolved_colors 
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_colors sgc
			ON  sgc.[group_id] = sg.[group_id]
			AND sgc.[area_id] IN ('', pl.[area_id])
			AND sgc.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [veo_colors] c ON c.[part_no] = sgc.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);

	-- =========================================
	-- #3 spec_items --> styles -> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = si.[product_id]
			AND c.[style_id] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'style'
		AND s.[class] = @item_class
		AND NOT EXISTS(
			SELECT 1 FROM #resolved_colors rc
			WHERE rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);
	
	-- =========================================
	-- #4 spec_items --> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'color'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			SELECT 1 FROM #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);	

	-- Preserve shared exclusion behavior by routing session/build combinations
	-- through the existing function instead of re-implementing exclusion logic here.
	INSERT INTO #spec_area_exclusions
	(
		[spec_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[part_no]
	)
	SELECT DISTINCT
		b.[spec_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		e.[part_no]
	FROM
		#builds b
		CROSS APPLY dbo.[vdsf_selSpecAreaExcludedParts]
		(
			@session_id,
			b.[spec_id],
			b.[application_id],
			b.[product_id],
			b.[area_id],
			b.[sub_area_id],
			b.[location_id],
			'field'
		) e;

	-- Estimated search rows come from the resolved field-color set after selectable
	-- and exclusion filtering are applied.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT
		'estimated' AS [source_type],
		rc.[part_name_official] AS [name],
		rc.[application] AS [application],
		rc.[product] AS [product],
		rc.[area] AS [area],
		rc.[sub_area] AS [sub_area],
		rc.[price_level_price] AS [price],
		SUBSTRING(rc.[price_level_name], 1, 1000) AS [price_level],
		rc.[part_no] AS [part_no],
		NULL AS [item_no],
		TRY_CAST(rc.[global_product_id] AS UNIQUEIDENTIFIER) AS [gpc_id],
		rc.[build_id] AS [build_id],
		rc.[option_pricing_display] AS [option_pricing_display]
	FROM
		#resolved_colors rc
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = rc.[stocking_code]
		LEFT JOIN #spec_area_exclusions sae
			ON  sae.[spec_id] = rc.[spec_id]
			AND sae.[application_id] = rc.[application_id]
			AND sae.[product_id] = rc.[product_id]
			AND sae.[area_id] = rc.[area_id]
			AND sae.[sub_area_id] = rc.[sub_area_id]
			AND sae.[part_no] = rc.[part_no]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND sae.[part_no] IS NULL
		AND
		(
			rc.[part_name_official] LIKE @search_pattern
			OR rc.[part_no] LIKE @search_pattern
		);

	-- Non-estimated search rows continue to come directly from catalog selections.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT DISTINCT
		'non_estimated' AS [source_type],
		SUBSTRING(cs.[item], 1, 1500) AS [name],
		cs.[application] AS [application],
		cs.[product] AS [product],
		a.[name] AS [area],
		sa.[name] AS [sub_area],
		cs.[price] AS [price],
		NULL AS [price_level],
		NULL AS [part_no],
		cs.[item_no] AS [item_no],
		TRY_CAST(cs.[gpc] AS UNIQUEIDENTIFIER) AS [gpc_id],
		NULL AS [build_id],
		cs.[option_pricing_display] AS [option_pricing_display]
	FROM
		[dbo].[catalog_selections] cs
		LEFT JOIN [veo_areas] a ON a.[area_id] = cs.[area]
		LEFT JOIN [veo_sub_areas] sa ON sa.[sub_area_id] = cs.[sub_area]
	WHERE
		cs.[session_id] = @session_id
		AND cs.[source] IN ('catalog', 'user')
		AND
		(
			cs.[item] LIKE @search_pattern
			OR cs.[item_no] LIKE @search_pattern
		);

	SELECT * FROM #parts;
END
GO

PRINT '  vds_selNonSessionEstimatedProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selNonSessionEstimatedProductSearchOptions]
	@security_token            UNIQUEIDENTIFIER,
	@account_id                UNIQUEIDENTIFIER,
	@organization_id           UNIQUEIDENTIFIER,
	@community_name            VARCHAR(100),
	@series_name               VARCHAR(100),
	@plan_name                 VARCHAR(100),
	@search_term               VARCHAR(250),
	@builder_overrides_enabled BIT = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-16
	Description:
		Returns estimated (field color) items for a non-session product search.
		Replaces the multi-step, N+1 Yukon pattern in GetNonSessionProductSearchOptions:
		  - community/series/plan resolution from VeoSolutionsSecurity mapping tables
		  - active spec + plan + effective date resolution through Veo/WBS data
		  - max build per area via window functions (replaces vds_optionPricingMaxMinBuilds cursor)
		  - color resolution via four paths mirroring vds_selSessionProductSearchOptions
		  - builder name overrides via veo_colors_customer_overrides

		All in a single DB round-trip against VeoSolutions using local synonyms for
		Veo and WBS data.

	Output columns (matches @parts shape of vds_selSessionProductSearchOptions):
		source_type   VARCHAR(20)       -- always 'estimated'
		name          VARCHAR(1500)     -- part name (respects builder overrides)
		application   VARCHAR(100)
		product       VARCHAR(100)
		area          VARCHAR(250)      -- display name
		sub_area      VARCHAR(250)      -- display name
		price         DECIMAL(18,4)
		price_level   VARCHAR(1000)     -- price level display name
		part_no       VARCHAR(250)
		item_no       VARCHAR(250)      -- always NULL for estimated
		gpc_id        UNIQUEIDENTIFIER  -- always NULL for estimated
		build_id      INT

	Modified: Justin Pope
	Date: 2026-04-02
	Description:
		Fixed an issue where multiple builds for the same area/sub_area were producing
		duplicate rows in the result set. The build_candidates CTE was using RANK() partitioned
		by (application_id, product_id, area_id, sub_area_id, location_id). Two problems:
		  1. RANK() assigns the same rank to tied rows (equal bill_qty), so multiple builds
		     could share build_rank = 1 for the same partition.
		  2. Including location_id in the partition meant that a single area/sub_area with
		     multiple location rows in prices_landed produced one winning build per location,
		     causing the same area/sub_area to appear multiple times downstream.
		Fix: Changed RANK() to ROW_NUMBER() and removed location_id from the PARTITION BY,
		so exactly one build is selected per application/product/area/sub_area. Added
		build_id DESC as a deterministic tiebreaker when bill_qty values are equal.
		location_id was also removed from the selected_builds, price_levels, and resolved_colors
		CTEs since it is not part of the output and was the source of the fan-out.
	Modified: Daniela
	Date: 2026-04-07
	Description:
		Two additional alignment fixes with vds_selEstimatedOptionPricingItemsForNonSession_Yukon:
		  1. Price rounding: price_level_price now applies CEILING(price / 10.0) * 10 to match
		     the outer proc's ((CEILING(SUM(price_retail) / 10)) * 10) rounding.
		  2. Zero/negative area exclusion: build_candidates now uses an EXISTS against wbs_plan_material
		     (matching on plan_id + build_id, any item) to require at least one positive bill_qty row —
		     mirroring the outer proc's pbm.bill_qty > 0 filter. The original fix used the narrow pm2
		     'field'-item join which incorrectly excluded builds like "All Carpeted Areas" that don't
		     carry a 'field' item for every area combination.

	Modified: Daniela
	Date: 2026-04-07
	Description:
		Aligned build selection and area labeling with vds_selEstimatedOptionPricingItemsForNonSession_Yukon
		so that the area and build_id values returned here match what that proc returns for the same plan.
		Two root causes addressed:
		  1. Build selection now respects the builder's opt_pricing_build_type setting (read from
		     wbs_customers). Previously it always selected the maximum build. Now it supports
		     'maximum', 'minimum', and default (standard/is_std) modes.
		  2. The area column is now replaced with build_desc (the build's display name from
		     plan_builds), mirroring the outer proc's Step 8 area-label swap. When @group_walls=1,
		     tile items in bathrooms (room_group 2 or 3) are grouped into "<AreaName> Walls".
		Also: renamed the max_builds CTE to selected_builds for clarity, added wbs_customers and
		wbs_room_groups synonyms to support the new logic.
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'

	-- ============================================================
	-- Phase 1 — Resolve candidate names and match a Veo spec/plan
	-- ============================================================
	DECLARE @effective_date DATETIME = GETDATE()
	DECLARE @effective_date_no_time DATE = CONVERT(DATE, @effective_date)

	DECLARE @external_org_id VARCHAR(50)

	DECLARE @resolved_spec_id INT
	DECLARE @active_spec_id INT
	DECLARE @prices_landed_effective_date DATETIME
	DECLARE @plan_id INT
	
	-- external_organization_id (builder_id in WBS)
	SELECT @external_org_id = vso.[external_organization_id]
	FROM   [VeoSolutionsSecurity_organizations] vso
		inner join [VeoSolutionsSecurity_account_organizations] vsao on vsao.[organization_id] = vso.[organization_id]
	WHERE  vso.[organization_id] = @organization_id
		and vsao.[account_id] = @account_id;
		
	;WITH communities
    AS
    (
        select 
            vsm.[spec_id],
            vsm.[start_date],
            vc.community_id,
            vc.[name] as [community_name]
        from 
            Veo_spec_communities vsc
            JOIN Veo_spec_mstr vsm on vsm.spec_id = vsc.spec_id
            JOIN Veo_communities vc on vc.community_id = vsc.community_id
            JOIN (
                -- Fetch VDS community names (builder names)
                SELECT
                    aoc.name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name

                UNION

                -- Fetch mapped community names (Wisenbaker names)
                SELECT
                    aocm.mapped_name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                    JOIN VeoSolutionsSecurity_account_organization_communities_mappings aocm  ON aocm.account_id = aoc.account_id AND aocm.organization_id = aoc.organization_id AND aocm.community_id = aoc.community_id
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name
                    ) vss_c on vss_c.community_name = vc.[name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
	series
    AS
    (
        SELECT
            vsm.spec_id,
            vsm.[start_date],
            vss.series as [series_name]
        FROM
            Veo_spec_series vss
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vss.spec_id
            JOIN (
                -- Fetch VDS series names (builder names)
                SELECT
                    aos.name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name

                UNION

                -- Fetch mapped series names (Wisenbaker names)
                SELECT
                    aosm.mapped_name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                    JOIN VeoSolutionsSecurity_account_organization_series_mappings aosm ON aosm.account_id = aos.account_id AND aosm.organization_id = aos.organization_id AND aosm.series_id = aos.series_id
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name
                    ) vss_s on vss_s.series_name = vss.series
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
    plans
    AS
    (
        SELECT
            vsm.[spec_id],
            vsm.[start_date],
            vpm.[plan_id] as [plan_id],
            vpm.[plan_name] as [plan_name]
        FROM
            Veo_plan_mstr vpm
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vpm.[spec_id]
            JOIN (        
                -- Fetch VDS plans names
                SELECT
                    aop.name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name

                union

                -- Fetch mapped plans names
                SELECT
                    aopm.mapped_name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                    LEFT JOIN VeoSolutionsSecurity_account_organization_plans_mappings aopm
                        ON aopm.account_id = aop.account_id
                        AND aopm.organization_id = aop.organization_id
                        AND aopm.plan_id = aop.plan_id
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name
                    ) vss_p  on vss_p.[plans_name] = vpm.[plan_name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
            and (vpm.end_date >= @effective_date or vpm.end_date is null)
            and vpm.active = 1
       )
	SELECT top 1
        @active_spec_id = sm.[spec_id], 
        @prices_landed_effective_date = p.effective_date, 
        @plan_id = pm.plan_id
	FROM
		[wbs_spec_mstr]        sm
		JOIN [wbs_spec_communities] sc    ON sc.[spec_id]       = sm.[spec_id]
        join [communities]          cte_c on cte_c.community_id = sc.community_id
                                         and cte_c.spec_id      = sm.spec_id
		JOIN [wbs_spec_series]      ss    ON ss.[spec_id]       = sm.[spec_id]
        join [series]               cte_s on cte_s.series_name  = ss.series
                                         and cte_s.spec_id      = sm.spec_id
        JOIN [wbs_plan_mstr]        pm    on pm.spec_id         = sm.spec_id
        join [plans]                cte_p on cte_p.plan_id      = pm.plan_id
                                         and cte_p.spec_id      = sm.spec_id
		JOIN [wbs_pricesets]        p     ON p.[spec_id]        = sm.[spec_id]
	WHERE
		sm.[builder_id]    = @external_org_id
		AND sm.[active]        = 1
		AND (sm.[end_date] IS NULL OR sm.[end_date] >= CONVERT(DATE, @effective_date))
		AND p.[active]         = 1
		AND p.[effective_date] <= @effective_date
	ORDER BY
		p.[effective_date] DESC

	IF @account_id IS NULL OR @organization_id IS NULL OR @active_spec_id IS NULL OR @plan_id IS NULL OR @prices_landed_effective_date IS NULL
		RETURN

	-- Read build-selection behavior configured per builder in the customers table.
	-- @build_type : 'maximum' | 'minimum' | '' (empty = standard/default)
	-- @group_walls: 1 = merge bath tile walls into a single area row
	DECLARE @build_type  VARCHAR(10) = ''
	DECLARE @group_walls BIT         = 0
	SELECT
		@build_type  = ISNULL(c.[opt_pricing_build_type], ''),
		@group_walls = ISNULL(c.[group_walls], 0)
	FROM [wbs_customers] c
	WHERE c.[custnmbr] = @external_org_id

	-- ============================================================
	-- Output collector
	-- ============================================================
	DECLARE @parts TABLE
	(
		[source_type] VARCHAR(20),
		[name]        VARCHAR(1500),
		[application] VARCHAR(100),
		[product]     VARCHAR(100),
		[area]        VARCHAR(250),
		[sub_area]    VARCHAR(250),
		[price]       DECIMAL(18,4),
		[price_level] VARCHAR(1000),
		[part_no]     VARCHAR(250),
		[item_no]     VARCHAR(250),
		[gpc_id]      UNIQUEIDENTIFIER,
		[build_id]    INT
	)

	-- ============================================================
	-- Phase 3+4 — Build selection CTE + price levels + color resolution
	-- ============================================================
	;WITH
	-- Determine the single representative build per application/product/area/sub_area.
	-- Partitioned WITHOUT location_id so that multiple locations for the same area/sub_area
	-- do not produce multiple winning builds and duplicate rows in the final output.
	-- ROW_NUMBER (not RANK) guarantees exactly one winner even when bill_qty ties.
	-- Only builds that have at least one plan_material row with bill_qty > 0 are considered
	-- (mirrors the outer proc's pbm.bill_qty > 0 filter via a broad EXISTS, not limited to the
	-- 'field' item, to avoid incorrectly excluding builds like "All Carpeted Areas" that may not
	-- carry a 'field' item in plan_material for every application/product/area combination).
	-- Build selection is driven by @build_type (read from wbs_customers):
	--   'maximum' → highest bill_qty wins; build_id DESC breaks ties
	--   'minimum' → lowest bill_qty wins; build_id DESC breaks ties
	--   default   → is_std build wins; bill_qty DESC and build_id DESC break ties
	-- Exception: cabinets (application_id='10', product_id='Y') always use their is_std build.
	[build_candidates] AS
	(
		SELECT
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[build_id],
			pb.[build_desc],
			ROW_NUMBER() OVER
			(
				PARTITION BY pl.[application_id], pl.[product_id], pl.[area_id], pl.[sub_area_id]
				ORDER BY
					-- Cabinets: std build always wins regardless of @build_type
					CASE
						WHEN pl.[application_id] = '10' AND pl.[product_id] = 'Y' AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- For default/std build_type: is_std build takes priority over bill_qty
					CASE
						WHEN ISNULL(@build_type, '') NOT IN ('maximum', 'minimum') AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- bill_qty: negated for 'minimum' so DESC sort always selects the correct extreme
					CASE
						WHEN @build_type = 'minimum'
							THEN -ISNULL(pm2.[bill_qty], 0)
						ELSE ISNULL(pm2.[bill_qty], 0)
					END DESC,
					pl.[build_id] DESC
			) AS [build_rank]
		FROM
			[wbs_prices_landed]  pl
			LEFT JOIN [wbs_plan_builds]  pb
				ON  pb.[build_id]       = pl.[build_id]
				AND pb.[plan_id]        = pl.[plan_id]
			LEFT JOIN [wbs_plan_material] pm2
				ON  pm2.[plan_id]       = pb.[plan_id]
				AND pm2.[build_id]      = pb.[build_id]
				AND pm2.[application_id] = pb.[application_id]
				AND pm2.[product_id]    = pb.[product_id]
				AND pm2.[area_id]       = pb.[area_id]
				AND pm2.[sub_area_id]   = pb.[sub_area_id]
				AND pm2.[location_id]   = pb.[location_id]
				AND pm2.[item_id]       = 'field'
		WHERE
			pl.[plan_id]        = @plan_id
			AND pl.[effective_date] = @prices_landed_effective_date
			AND EXISTS
			(
				-- Mirror the outer proc's pbm.bill_qty > 0 filter: require at least one
				-- plan_material row for this plan+build (any item) to have positive bill_qty.
				-- Using a broad EXISTS rather than the pm2 'field'-item join avoids incorrectly
				-- excluding builds whose field item is absent or uses a different item classification.
				SELECT 1
				FROM [wbs_plan_material] pm3
				WHERE pm3.[plan_id]  = pl.[plan_id]
				  AND pm3.[build_id] = pl.[build_id]
				  AND pm3.[bill_qty] > 0
			)
	),
	[selected_builds] AS
	(
		SELECT [application_id], [product_id], [area_id], [sub_area_id], [build_id], [build_desc]
		FROM   [build_candidates]
		WHERE  [build_rank] = 1
	),
	-- Price levels: prices_landed rows for the selected build, with display names applied.
	-- Mirrors what vds_selEstimatedOptionPricingItemsForNonSession_Yukon returns
	-- but as a CTE rather than a separate procedure call.
	-- area is replaced with build_desc (mirroring the outer proc's Step 8 area-label swap).
	-- When @group_walls=1, tile items in bathrooms (room_group 2 or 3) are grouped into
	-- a single "<AreaName> Walls" area with sub_area cleared.
	[price_levels] AS
	(
		SELECT DISTINCT
			mb.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[item_type]                                        AS [price_level_type],
			pl.[item]                                             AS [price_level_id],
			ISNULL(bs.[builder_style_name], pl.[customer_item_name]) AS [price_level_name],
			CEILING(pl.[price_retail] / 10.0) * 10               AS [price_level_price],
			LTRIM(RTRIM(ap.[name]))                               AS [application],
			LTRIM(RTRIM(pr.[name]))                               AS [product],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ar.[name] + ' Walls'
				ELSE mb.[build_desc]
			END                                                   AS [area],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ''
				WHEN mb.[build_desc] IS NOT NULL
					THEN ''
				ELSE sar.[name]
			END                                                   AS [sub_area]
		FROM
			[wbs_prices_landed]      pl
			JOIN [selected_builds] mb
				ON  mb.[build_id]       = pl.[build_id]
				AND mb.[application_id] = pl.[application_id]
				AND mb.[product_id]     = pl.[product_id]
				AND mb.[area_id]        = pl.[area_id]
				AND mb.[sub_area_id]    = pl.[sub_area_id]
			JOIN [wbs_plan_builds]   pb  ON pb.[build_id]      = pl.[build_id]
			                                           AND pb.[plan_id]       = pl.[plan_id]
			JOIN [wbs_plan_mstr]     pm  ON pm.[plan_id]       = pb.[plan_id]
			JOIN [wbs_areas]         ar  ON ar.[area_id]       = pl.[area_id]
			LEFT JOIN [wbs_room_groups] rg ON rg.[code]        = ar.[room_group]
			JOIN [wbs_sub_areas]     sar ON sar.[sub_area_id]  = pl.[sub_area_id]
			JOIN [wbs_applications]  ap  ON ap.[application_id] = pl.[application_id]
			JOIN [wbs_products]      pr  ON pr.[product_id]    = pl.[product_id]
			LEFT JOIN [wbs_spec_areas_items] sai
				ON  sai.[spec_id]       = pm.[spec_id]
				AND sai.[application_id] = pl.[application_id]
				AND sai.[product_id]    = pl.[product_id]
				AND sai.[area_id]       = pl.[area_id]
				AND sai.[sub_area_id]   = pl.[sub_area_id]
				AND (sai.[location_id]  = pl.[location_id] OR sai.[location_id] = 0)
				AND sai.[item_type]     = pl.[item_type]
				AND sai.[item]          = pl.[item]
			LEFT JOIN [wbs_areas_sub_areas] asa
				ON  asa.[area_id]       = ar.[area_id]
				AND asa.[sub_area_id]   = sar.[sub_area_id]
			LEFT JOIN [wbs_builder_styles] bs
				ON  bs.[builder_id]     = @external_org_id
				AND bs.[spec_id]        = pm.[spec_id]
				AND bs.[item_type]      = pl.[item_type]
				AND bs.[item]           = pl.[item]
				AND bs.[effective_date] = @prices_landed_effective_date
		WHERE
			pl.[plan_id]                  =  @plan_id
			AND pm.[spec_id]              =  @active_spec_id
			AND pm.[plan_id]              =  @plan_id
			AND pl.[effective_date]       =  @prices_landed_effective_date
			AND ISNULL(sai.[excluded], 0) <> 1
			AND (asa.[exclude_quick_price_display] = 0 OR asa.[exclude_quick_price_display] IS NULL)
			AND pm.[active]               =  1
			AND (pm.[end_date] IS NULL OR pm.[end_date] > GETDATE())
	),
	-- Resolve parts (colors) from price levels.
	-- Four paths mirror vds_selSessionProductSearchOptions resolved_colors CTE.
	-- Key difference from session: uses [wbs_spec_items] (not veo_spec_items)
	-- and [wbs_styles_groups_detail] (not catalog_selections_group_detail)
	-- since there is no homebuyer session selection to reference.
	[resolved_colors] AS
	(
		-- Path 1: spec_items (group) → styles_groups_detail (style) → styles → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'style'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = sg.[product_id]
				AND s.[style_id]   = sgd.[item]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = s.[product_id]
				AND c.[style_id]   = s.[style_id]
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 2: spec_items (group) → styles_groups_detail (color) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'color'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [veo_colors] c ON c.[part_no] = sgd.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 3: spec_items (style) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = si.[product_id]
				AND c.[style_id]   = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'style'

		UNION ALL

		-- Path 4: spec_items (color) → colors (direct part_no match)
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'color'
	)
	INSERT INTO @parts ([source_type], [name], [application], [product], [area], [sub_area], [price], [price_level], [part_no], [item_no], [gpc_id], [build_id])
	SELECT DISTINCT
		'estimated'                                          AS [source_type],
		c.[part_name_official]                               AS [name],
		c.[application]                                      AS [application],
		c.[product]                                          AS [product],
		c.[area]                                             AS [area],
		c.[sub_area]                                         AS [sub_area],
		c.[price_level_price]                                AS [price],
		SUBSTRING(c.[price_level_name], 1, 1000)             AS [price_level],
		c.[part_no]                                          AS [part_no],
		NULL                                                 AS [item_no],
		TRY_CAST(c.[global_product_id] AS UNIQUEIDENTIFIER)  AS [gpc_id],
		c.[build_id]                                         AS [build_id]
	FROM
		[resolved_colors] c
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = c.[stocking_code]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND (
			c.[part_name_official] LIKE '%' + ISNULL(@search_term, '') + '%'
			OR c.[part_no]         LIKE '%' + ISNULL(@search_term, '') + '%'
		)

	SELECT * FROM @parts
END
GO

PRINT ' [EPLAN_VeoSolutions] complete.';
GO

-- ===========================================================================
-- [AFI_VeoSolutions]
-- ===========================================================================

PRINT '=========================================================';
PRINT ' Deploying to [AFI_VeoSolutions]';
PRINT '=========================================================';

USE [AFI_VeoSolutions];
GO

PRINT '  vds_selSessionProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selSessionProductSearchOptions]
	@session_id                UNIQUEIDENTIFIER,
	@security_token            UNIQUEIDENTIFIER,
	@search_term               VARCHAR(250)     = NULL,
	@builder_overrides_enabled BIT              = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-09
	Description:
		Returns a unified result set of ALL estimated (field colors) and
		non-estimated (catalog) items for a session, intended for product search.

		Estimated items are resolved set-based across all builds via CTEs, replacing the
		per-build N+1 pattern of vds_selHomebuyerCatalogBuilds +
		vds_selHomebuyerCatalogFieldColorsForBuild.  The same four color-resolution
		paths are preserved (group→style→color, group→color, style→color, color).

		Non-estimated items mirror vds_selSessionCatalogItems
		(catalog_selections WHERE source IN ('catalog', 'user')).

	Modified: Justin Pope
	Date: 2026-03-23
	Description: Reworked the estimated-item query to materialize session/build
		helpers in temp tables, preserve the existing field-color hierarchy with
		ordered insert statements, and continue exclusion handling through
		dbo.vdsf_selSpecAreaExcludedParts.

	Modified: Justin Pope
	Date: 2026-04-01
	Description: Product Option search was returning more builds than were on the session. Adding condition
		limits those to only those on the session.



	Modified: Justin Pope
	Date: 2026-04-07
	Description: Propagate option_pricing_display from catalog_selections through the
		estimated-item pipeline (#price_levels → #resolved_colors) so estimated items
		carry the actual value instead of a hardcoded 1.

	Output columns:
		source_type              VARCHAR(20)       -- 'estimated' | 'non_estimated'
		name                     VARCHAR(1500)     -- part name (respects builder overrides for estimated)
		application              VARCHAR(100)
		product                  VARCHAR(100)
		area                     VARCHAR(250)
		sub_area                 VARCHAR(250)
		price                    DECIMAL(18,4)
		price_level              VARCHAR(1000)     -- NULL for non-estimated
		part_no                  VARCHAR(250)      -- NULL for non-estimated
		item_no                  VARCHAR(250)      -- NULL for estimated
		gpc_id                   UNIQUEIDENTIFIER  -- NULL for estimated when cast fails
		option_pricing_display   BIT               -- catalog_selections value option_pricing_display
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'
	DECLARE @search_pattern VARCHAR(252) = '%' + ISNULL(@search_term, '') + '%'

	-- Final unified result set returned to the API.
	CREATE TABLE #parts
	(
		[source_type]            VARCHAR(20),
		[name]                   VARCHAR(1500),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[price]                  DECIMAL(18,4),
		[price_level]            VARCHAR(1000),
		[part_no]                VARCHAR(250),
		[item_no]                VARCHAR(250),
		[gpc_id]                 UNIQUEIDENTIFIER,
		[build_id]               INT,
		[option_pricing_display] BIT
	);

	-- Session build context drives both estimated-color resolution and exclusions.
	CREATE TABLE #builds
	(
		[session_id]     UNIQUEIDENTIFIER,
		[spec_id]        INT,
		[builder_id]     VARCHAR(20),
		[build_id]       INT NOT NULL PRIMARY KEY,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[location_id]    INT
	);

	-- Price levels are filtered up front to the only types that can resolve field colors.
	CREATE TABLE #price_levels
	(
		[session_id]         UNIQUEIDENTIFIER,
		[build_id]           INT,
		[spec_id]            INT,
		[builder_id]         VARCHAR(20),
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_name]   VARCHAR(1500),
		[price_level_type]   VARCHAR(10),
		[price_level_id]     VARCHAR(81),
		[price_level_price]      DECIMAL(18,4),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[option_pricing_display] BIT,
		PRIMARY KEY ([price_level_type], [spec_id], [application_id], [product_id], [price_level_id], [build_id], [area_id], [sub_area_id])
	);

	-- Session group detail is split by item_type so the two group-based paths stay narrow.
	CREATE TABLE #session_group_styles
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	CREATE TABLE #session_group_colors
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	-- The resolved color set is populated in priority order with INSERT ... SELECT ... WHERE NOT EXISTS queries so earlier paths win.
	CREATE TABLE #resolved_colors
	(
		[spec_id]            INT,
		[build_id]           INT,
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_id]     VARCHAR(81),
		[price_level_name]   VARCHAR(1500),
		[price_level_price]  DECIMAL(18,4),
		[application]        VARCHAR(100),
		[product]            VARCHAR(100),
		[area]               VARCHAR(250),
		[sub_area]           VARCHAR(250),
		[part_no]            VARCHAR(81),
		[stocking_code]      VARCHAR(50),
		[global_product_id]  VARCHAR(100),
		[part_name_official]     VARCHAR(1500),
		[option_pricing_display] BIT,
		PRIMARY KEY ([build_id], [price_level_id], [part_no])
	);

	-- Exclusions stay centralized through the shared function so behavior matches other callers.
	CREATE TABLE #spec_area_exclusions
	(
		[spec_id]        INT,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[part_no]        VARCHAR(81),
		PRIMARY KEY ([spec_id], [application_id], [product_id], [area_id], [sub_area_id], [part_no])
	);

	INSERT INTO #builds
	(
		[session_id],
		[spec_id],
		[builder_id],
		[build_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id]
	)
	SELECT
		s.[session_id],
		vpm.[spec_id],
		vsm.[builder_id],
		vpb.[build_id],
		vpb.[application_id],
		vpb.[product_id],
		vpb.[area_id],
		vpb.[sub_area_id],
		vpb.[location_id]
	FROM
		[account_organization_user_profile_plan_catalog_sessions] s
		JOIN [catalog_selections_areas] csa ON csa.[session_id] = s.[session_id]
												AND csa.[area_selected] = 1
		JOIN [veo_spec_mstr] vsm ON vsm.[spec_id] = s.[spec_id]
		JOIN [veo_plan_mstr] vpm ON vpm.[spec_id] = vsm.[spec_id]
		JOIN [veo_plan_builds] vpb
			ON  vpb.[plan_id] = vpm.[plan_id]
			AND vpb.[build_id] = csa.[build_id]
	WHERE
		s.[session_id] = @session_id;

	INSERT INTO #price_levels
	(
		[session_id],
		[build_id],
		[spec_id],
		[builder_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id],
		[price_level_name],
		[price_level_type],
		[price_level_id],
		[price_level_price],
		[application],
		[product],
		[area],
		[sub_area],
		[option_pricing_display]
	)
	SELECT
		b.[session_id],
		b.[build_id],
		b.[spec_id],
		b.[builder_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		b.[location_id],
		cs.[item]                    AS [price_level_name],
		cs.[item_type]               AS [price_level_type],
		cs.[item_no]                 AS [price_level_id],
		cs.[price]                   AS [price_level_price],
		cs.[application],
		cs.[product],
		cs.[area],
		cs.[sub_area],
		cs.[option_pricing_display]
	FROM
		#builds b
		JOIN [catalog_selections] cs
			ON  cs.[session_id] = b.[session_id]
			AND cs.[build_id] = b.[build_id]
	WHERE
		cs.[item_type] IN ('group', 'style', 'color');

	INSERT INTO #session_group_styles
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'style';

	INSERT INTO #session_group_colors
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'color';

	-- =============================================
	-- #1 spec_items --> groups -> styles -> colors
	-- =============================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_styles sgs
			ON  sgs.[group_id] = sg.[group_id]
			AND sgs.[area_id] IN ('', pl.[area_id])
			AND sgs.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [Veo_styles] s
			ON  s.[product_id] = sg.[product_id]
			AND s.[style_id] = sgs.[item]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = s.[product_id]
			AND c.[style_id] = s.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		and not exists(
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		)


	-- =========================================
	-- #2 spec_items --> groups -> colors
	-- =========================================
	INSERT INTO #resolved_colors 
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_colors sgc
			ON  sgc.[group_id] = sg.[group_id]
			AND sgc.[area_id] IN ('', pl.[area_id])
			AND sgc.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [veo_colors] c ON c.[part_no] = sgc.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);

	-- =========================================
	-- #3 spec_items --> styles -> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = si.[product_id]
			AND c.[style_id] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'style'
		AND s.[class] = @item_class
		AND NOT EXISTS(
			SELECT 1 FROM #resolved_colors rc
			WHERE rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);
	
	-- =========================================
	-- #4 spec_items --> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'color'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			SELECT 1 FROM #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);	

	-- Preserve shared exclusion behavior by routing session/build combinations
	-- through the existing function instead of re-implementing exclusion logic here.
	INSERT INTO #spec_area_exclusions
	(
		[spec_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[part_no]
	)
	SELECT DISTINCT
		b.[spec_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		e.[part_no]
	FROM
		#builds b
		CROSS APPLY dbo.[vdsf_selSpecAreaExcludedParts]
		(
			@session_id,
			b.[spec_id],
			b.[application_id],
			b.[product_id],
			b.[area_id],
			b.[sub_area_id],
			b.[location_id],
			'field'
		) e;

	-- Estimated search rows come from the resolved field-color set after selectable
	-- and exclusion filtering are applied.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT
		'estimated' AS [source_type],
		rc.[part_name_official] AS [name],
		rc.[application] AS [application],
		rc.[product] AS [product],
		rc.[area] AS [area],
		rc.[sub_area] AS [sub_area],
		rc.[price_level_price] AS [price],
		SUBSTRING(rc.[price_level_name], 1, 1000) AS [price_level],
		rc.[part_no] AS [part_no],
		NULL AS [item_no],
		TRY_CAST(rc.[global_product_id] AS UNIQUEIDENTIFIER) AS [gpc_id],
		rc.[build_id] AS [build_id],
		rc.[option_pricing_display] AS [option_pricing_display]
	FROM
		#resolved_colors rc
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = rc.[stocking_code]
		LEFT JOIN #spec_area_exclusions sae
			ON  sae.[spec_id] = rc.[spec_id]
			AND sae.[application_id] = rc.[application_id]
			AND sae.[product_id] = rc.[product_id]
			AND sae.[area_id] = rc.[area_id]
			AND sae.[sub_area_id] = rc.[sub_area_id]
			AND sae.[part_no] = rc.[part_no]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND sae.[part_no] IS NULL
		AND
		(
			rc.[part_name_official] LIKE @search_pattern
			OR rc.[part_no] LIKE @search_pattern
		);

	-- Non-estimated search rows continue to come directly from catalog selections.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT DISTINCT
		'non_estimated' AS [source_type],
		SUBSTRING(cs.[item], 1, 1500) AS [name],
		cs.[application] AS [application],
		cs.[product] AS [product],
		a.[name] AS [area],
		sa.[name] AS [sub_area],
		cs.[price] AS [price],
		NULL AS [price_level],
		NULL AS [part_no],
		cs.[item_no] AS [item_no],
		TRY_CAST(cs.[gpc] AS UNIQUEIDENTIFIER) AS [gpc_id],
		NULL AS [build_id],
		cs.[option_pricing_display] AS [option_pricing_display]
	FROM
		[dbo].[catalog_selections] cs
		LEFT JOIN [veo_areas] a ON a.[area_id] = cs.[area]
		LEFT JOIN [veo_sub_areas] sa ON sa.[sub_area_id] = cs.[sub_area]
	WHERE
		cs.[session_id] = @session_id
		AND cs.[source] IN ('catalog', 'user')
		AND
		(
			cs.[item] LIKE @search_pattern
			OR cs.[item_no] LIKE @search_pattern
		);

	SELECT * FROM #parts;
END
GO

PRINT '  vds_selNonSessionEstimatedProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selNonSessionEstimatedProductSearchOptions]
	@security_token            UNIQUEIDENTIFIER,
	@account_id                UNIQUEIDENTIFIER,
	@organization_id           UNIQUEIDENTIFIER,
	@community_name            VARCHAR(100),
	@series_name               VARCHAR(100),
	@plan_name                 VARCHAR(100),
	@search_term               VARCHAR(250),
	@builder_overrides_enabled BIT = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-16
	Description:
		Returns estimated (field color) items for a non-session product search.
		Replaces the multi-step, N+1 Yukon pattern in GetNonSessionProductSearchOptions:
		  - community/series/plan resolution from VeoSolutionsSecurity mapping tables
		  - active spec + plan + effective date resolution through Veo/WBS data
		  - max build per area via window functions (replaces vds_optionPricingMaxMinBuilds cursor)
		  - color resolution via four paths mirroring vds_selSessionProductSearchOptions
		  - builder name overrides via veo_colors_customer_overrides

		All in a single DB round-trip against VeoSolutions using local synonyms for
		Veo and WBS data.

	Output columns (matches @parts shape of vds_selSessionProductSearchOptions):
		source_type   VARCHAR(20)       -- always 'estimated'
		name          VARCHAR(1500)     -- part name (respects builder overrides)
		application   VARCHAR(100)
		product       VARCHAR(100)
		area          VARCHAR(250)      -- display name
		sub_area      VARCHAR(250)      -- display name
		price         DECIMAL(18,4)
		price_level   VARCHAR(1000)     -- price level display name
		part_no       VARCHAR(250)
		item_no       VARCHAR(250)      -- always NULL for estimated
		gpc_id        UNIQUEIDENTIFIER  -- always NULL for estimated
		build_id      INT

	Modified: Justin Pope
	Date: 2026-04-02
	Description:
		Fixed an issue where multiple builds for the same area/sub_area were producing
		duplicate rows in the result set. The build_candidates CTE was using RANK() partitioned
		by (application_id, product_id, area_id, sub_area_id, location_id). Two problems:
		  1. RANK() assigns the same rank to tied rows (equal bill_qty), so multiple builds
		     could share build_rank = 1 for the same partition.
		  2. Including location_id in the partition meant that a single area/sub_area with
		     multiple location rows in prices_landed produced one winning build per location,
		     causing the same area/sub_area to appear multiple times downstream.
		Fix: Changed RANK() to ROW_NUMBER() and removed location_id from the PARTITION BY,
		so exactly one build is selected per application/product/area/sub_area. Added
		build_id DESC as a deterministic tiebreaker when bill_qty values are equal.
		location_id was also removed from the selected_builds, price_levels, and resolved_colors
		CTEs since it is not part of the output and was the source of the fan-out.
	Modified: Daniela
	Date: 2026-04-07
	Description:
		Two additional alignment fixes with vds_selEstimatedOptionPricingItemsForNonSession_Yukon:
		  1. Price rounding: price_level_price now applies CEILING(price / 10.0) * 10 to match
		     the outer proc's ((CEILING(SUM(price_retail) / 10)) * 10) rounding.
		  2. Zero/negative area exclusion: build_candidates now uses an EXISTS against wbs_plan_material
		     (matching on plan_id + build_id, any item) to require at least one positive bill_qty row —
		     mirroring the outer proc's pbm.bill_qty > 0 filter. The original fix used the narrow pm2
		     'field'-item join which incorrectly excluded builds like "All Carpeted Areas" that don't
		     carry a 'field' item for every area combination.

	Modified: Daniela
	Date: 2026-04-07
	Description:
		Aligned build selection and area labeling with vds_selEstimatedOptionPricingItemsForNonSession_Yukon
		so that the area and build_id values returned here match what that proc returns for the same plan.
		Two root causes addressed:
		  1. Build selection now respects the builder's opt_pricing_build_type setting (read from
		     wbs_customers). Previously it always selected the maximum build. Now it supports
		     'maximum', 'minimum', and default (standard/is_std) modes.
		  2. The area column is now replaced with build_desc (the build's display name from
		     plan_builds), mirroring the outer proc's Step 8 area-label swap. When @group_walls=1,
		     tile items in bathrooms (room_group 2 or 3) are grouped into "<AreaName> Walls".
		Also: renamed the max_builds CTE to selected_builds for clarity, added wbs_customers and
		wbs_room_groups synonyms to support the new logic.
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'

	-- ============================================================
	-- Phase 1 — Resolve candidate names and match a Veo spec/plan
	-- ============================================================
	DECLARE @effective_date DATETIME = GETDATE()
	DECLARE @effective_date_no_time DATE = CONVERT(DATE, @effective_date)

	DECLARE @external_org_id VARCHAR(50)

	DECLARE @resolved_spec_id INT
	DECLARE @active_spec_id INT
	DECLARE @prices_landed_effective_date DATETIME
	DECLARE @plan_id INT
	
	-- external_organization_id (builder_id in WBS)
	SELECT @external_org_id = vso.[external_organization_id]
	FROM   [VeoSolutionsSecurity_organizations] vso
		inner join [VeoSolutionsSecurity_account_organizations] vsao on vsao.[organization_id] = vso.[organization_id]
	WHERE  vso.[organization_id] = @organization_id
		and vsao.[account_id] = @account_id;
		
	;WITH communities
    AS
    (
        select 
            vsm.[spec_id],
            vsm.[start_date],
            vc.community_id,
            vc.[name] as [community_name]
        from 
            Veo_spec_communities vsc
            JOIN Veo_spec_mstr vsm on vsm.spec_id = vsc.spec_id
            JOIN Veo_communities vc on vc.community_id = vsc.community_id
            JOIN (
                -- Fetch VDS community names (builder names)
                SELECT
                    aoc.name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name

                UNION

                -- Fetch mapped community names (Wisenbaker names)
                SELECT
                    aocm.mapped_name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                    JOIN VeoSolutionsSecurity_account_organization_communities_mappings aocm  ON aocm.account_id = aoc.account_id AND aocm.organization_id = aoc.organization_id AND aocm.community_id = aoc.community_id
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name
                    ) vss_c on vss_c.community_name = vc.[name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
	series
    AS
    (
        SELECT
            vsm.spec_id,
            vsm.[start_date],
            vss.series as [series_name]
        FROM
            Veo_spec_series vss
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vss.spec_id
            JOIN (
                -- Fetch VDS series names (builder names)
                SELECT
                    aos.name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name

                UNION

                -- Fetch mapped series names (Wisenbaker names)
                SELECT
                    aosm.mapped_name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                    JOIN VeoSolutionsSecurity_account_organization_series_mappings aosm ON aosm.account_id = aos.account_id AND aosm.organization_id = aos.organization_id AND aosm.series_id = aos.series_id
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name
                    ) vss_s on vss_s.series_name = vss.series
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
    plans
    AS
    (
        SELECT
            vsm.[spec_id],
            vsm.[start_date],
            vpm.[plan_id] as [plan_id],
            vpm.[plan_name] as [plan_name]
        FROM
            Veo_plan_mstr vpm
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vpm.[spec_id]
            JOIN (        
                -- Fetch VDS plans names
                SELECT
                    aop.name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name

                union

                -- Fetch mapped plans names
                SELECT
                    aopm.mapped_name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                    LEFT JOIN VeoSolutionsSecurity_account_organization_plans_mappings aopm
                        ON aopm.account_id = aop.account_id
                        AND aopm.organization_id = aop.organization_id
                        AND aopm.plan_id = aop.plan_id
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name
                    ) vss_p  on vss_p.[plans_name] = vpm.[plan_name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
            and (vpm.end_date >= @effective_date or vpm.end_date is null)
            and vpm.active = 1
       )
	SELECT top 1
        @active_spec_id = sm.[spec_id], 
        @prices_landed_effective_date = p.effective_date, 
        @plan_id = pm.plan_id
	FROM
		[wbs_spec_mstr]        sm
		JOIN [wbs_spec_communities] sc    ON sc.[spec_id]       = sm.[spec_id]
        join [communities]          cte_c on cte_c.community_id = sc.community_id
                                         and cte_c.spec_id      = sm.spec_id
		JOIN [wbs_spec_series]      ss    ON ss.[spec_id]       = sm.[spec_id]
        join [series]               cte_s on cte_s.series_name  = ss.series
                                         and cte_s.spec_id      = sm.spec_id
        JOIN [wbs_plan_mstr]        pm    on pm.spec_id         = sm.spec_id
        join [plans]                cte_p on cte_p.plan_id      = pm.plan_id
                                         and cte_p.spec_id      = sm.spec_id
		JOIN [wbs_pricesets]        p     ON p.[spec_id]        = sm.[spec_id]
	WHERE
		sm.[builder_id]    = @external_org_id
		AND sm.[active]        = 1
		AND (sm.[end_date] IS NULL OR sm.[end_date] >= CONVERT(DATE, @effective_date))
		AND p.[active]         = 1
		AND p.[effective_date] <= @effective_date
	ORDER BY
		p.[effective_date] DESC

	IF @account_id IS NULL OR @organization_id IS NULL OR @active_spec_id IS NULL OR @plan_id IS NULL OR @prices_landed_effective_date IS NULL
		RETURN

	-- Read build-selection behavior configured per builder in the customers table.
	-- @build_type : 'maximum' | 'minimum' | '' (empty = standard/default)
	-- @group_walls: 1 = merge bath tile walls into a single area row
	DECLARE @build_type  VARCHAR(10) = ''
	DECLARE @group_walls BIT         = 0
	SELECT
		@build_type  = ISNULL(c.[opt_pricing_build_type], ''),
		@group_walls = ISNULL(c.[group_walls], 0)
	FROM [wbs_customers] c
	WHERE c.[custnmbr] = @external_org_id

	-- ============================================================
	-- Output collector
	-- ============================================================
	DECLARE @parts TABLE
	(
		[source_type] VARCHAR(20),
		[name]        VARCHAR(1500),
		[application] VARCHAR(100),
		[product]     VARCHAR(100),
		[area]        VARCHAR(250),
		[sub_area]    VARCHAR(250),
		[price]       DECIMAL(18,4),
		[price_level] VARCHAR(1000),
		[part_no]     VARCHAR(250),
		[item_no]     VARCHAR(250),
		[gpc_id]      UNIQUEIDENTIFIER,
		[build_id]    INT
	)

	-- ============================================================
	-- Phase 3+4 — Build selection CTE + price levels + color resolution
	-- ============================================================
	;WITH
	-- Determine the single representative build per application/product/area/sub_area.
	-- Partitioned WITHOUT location_id so that multiple locations for the same area/sub_area
	-- do not produce multiple winning builds and duplicate rows in the final output.
	-- ROW_NUMBER (not RANK) guarantees exactly one winner even when bill_qty ties.
	-- Only builds that have at least one plan_material row with bill_qty > 0 are considered
	-- (mirrors the outer proc's pbm.bill_qty > 0 filter via a broad EXISTS, not limited to the
	-- 'field' item, to avoid incorrectly excluding builds like "All Carpeted Areas" that may not
	-- carry a 'field' item in plan_material for every application/product/area combination).
	-- Build selection is driven by @build_type (read from wbs_customers):
	--   'maximum' → highest bill_qty wins; build_id DESC breaks ties
	--   'minimum' → lowest bill_qty wins; build_id DESC breaks ties
	--   default   → is_std build wins; bill_qty DESC and build_id DESC break ties
	-- Exception: cabinets (application_id='10', product_id='Y') always use their is_std build.
	[build_candidates] AS
	(
		SELECT
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[build_id],
			pb.[build_desc],
			ROW_NUMBER() OVER
			(
				PARTITION BY pl.[application_id], pl.[product_id], pl.[area_id], pl.[sub_area_id]
				ORDER BY
					-- Cabinets: std build always wins regardless of @build_type
					CASE
						WHEN pl.[application_id] = '10' AND pl.[product_id] = 'Y' AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- For default/std build_type: is_std build takes priority over bill_qty
					CASE
						WHEN ISNULL(@build_type, '') NOT IN ('maximum', 'minimum') AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- bill_qty: negated for 'minimum' so DESC sort always selects the correct extreme
					CASE
						WHEN @build_type = 'minimum'
							THEN -ISNULL(pm2.[bill_qty], 0)
						ELSE ISNULL(pm2.[bill_qty], 0)
					END DESC,
					pl.[build_id] DESC
			) AS [build_rank]
		FROM
			[wbs_prices_landed]  pl
			LEFT JOIN [wbs_plan_builds]  pb
				ON  pb.[build_id]       = pl.[build_id]
				AND pb.[plan_id]        = pl.[plan_id]
			LEFT JOIN [wbs_plan_material] pm2
				ON  pm2.[plan_id]       = pb.[plan_id]
				AND pm2.[build_id]      = pb.[build_id]
				AND pm2.[application_id] = pb.[application_id]
				AND pm2.[product_id]    = pb.[product_id]
				AND pm2.[area_id]       = pb.[area_id]
				AND pm2.[sub_area_id]   = pb.[sub_area_id]
				AND pm2.[location_id]   = pb.[location_id]
				AND pm2.[item_id]       = 'field'
		WHERE
			pl.[plan_id]        = @plan_id
			AND pl.[effective_date] = @prices_landed_effective_date
			AND EXISTS
			(
				-- Mirror the outer proc's pbm.bill_qty > 0 filter: require at least one
				-- plan_material row for this plan+build (any item) to have positive bill_qty.
				-- Using a broad EXISTS rather than the pm2 'field'-item join avoids incorrectly
				-- excluding builds whose field item is absent or uses a different item classification.
				SELECT 1
				FROM [wbs_plan_material] pm3
				WHERE pm3.[plan_id]  = pl.[plan_id]
				  AND pm3.[build_id] = pl.[build_id]
				  AND pm3.[bill_qty] > 0
			)
	),
	[selected_builds] AS
	(
		SELECT [application_id], [product_id], [area_id], [sub_area_id], [build_id], [build_desc]
		FROM   [build_candidates]
		WHERE  [build_rank] = 1
	),
	-- Price levels: prices_landed rows for the selected build, with display names applied.
	-- Mirrors what vds_selEstimatedOptionPricingItemsForNonSession_Yukon returns
	-- but as a CTE rather than a separate procedure call.
	-- area is replaced with build_desc (mirroring the outer proc's Step 8 area-label swap).
	-- When @group_walls=1, tile items in bathrooms (room_group 2 or 3) are grouped into
	-- a single "<AreaName> Walls" area with sub_area cleared.
	[price_levels] AS
	(
		SELECT DISTINCT
			mb.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[item_type]                                        AS [price_level_type],
			pl.[item]                                             AS [price_level_id],
			ISNULL(bs.[builder_style_name], pl.[customer_item_name]) AS [price_level_name],
			CEILING(pl.[price_retail] / 10.0) * 10               AS [price_level_price],
			LTRIM(RTRIM(ap.[name]))                               AS [application],
			LTRIM(RTRIM(pr.[name]))                               AS [product],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ar.[name] + ' Walls'
				ELSE mb.[build_desc]
			END                                                   AS [area],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ''
				WHEN mb.[build_desc] IS NOT NULL
					THEN ''
				ELSE sar.[name]
			END                                                   AS [sub_area]
		FROM
			[wbs_prices_landed]      pl
			JOIN [selected_builds] mb
				ON  mb.[build_id]       = pl.[build_id]
				AND mb.[application_id] = pl.[application_id]
				AND mb.[product_id]     = pl.[product_id]
				AND mb.[area_id]        = pl.[area_id]
				AND mb.[sub_area_id]    = pl.[sub_area_id]
			JOIN [wbs_plan_builds]   pb  ON pb.[build_id]      = pl.[build_id]
			                                           AND pb.[plan_id]       = pl.[plan_id]
			JOIN [wbs_plan_mstr]     pm  ON pm.[plan_id]       = pb.[plan_id]
			JOIN [wbs_areas]         ar  ON ar.[area_id]       = pl.[area_id]
			LEFT JOIN [wbs_room_groups] rg ON rg.[code]        = ar.[room_group]
			JOIN [wbs_sub_areas]     sar ON sar.[sub_area_id]  = pl.[sub_area_id]
			JOIN [wbs_applications]  ap  ON ap.[application_id] = pl.[application_id]
			JOIN [wbs_products]      pr  ON pr.[product_id]    = pl.[product_id]
			LEFT JOIN [wbs_spec_areas_items] sai
				ON  sai.[spec_id]       = pm.[spec_id]
				AND sai.[application_id] = pl.[application_id]
				AND sai.[product_id]    = pl.[product_id]
				AND sai.[area_id]       = pl.[area_id]
				AND sai.[sub_area_id]   = pl.[sub_area_id]
				AND (sai.[location_id]  = pl.[location_id] OR sai.[location_id] = 0)
				AND sai.[item_type]     = pl.[item_type]
				AND sai.[item]          = pl.[item]
			LEFT JOIN [wbs_areas_sub_areas] asa
				ON  asa.[area_id]       = ar.[area_id]
				AND asa.[sub_area_id]   = sar.[sub_area_id]
			LEFT JOIN [wbs_builder_styles] bs
				ON  bs.[builder_id]     = @external_org_id
				AND bs.[spec_id]        = pm.[spec_id]
				AND bs.[item_type]      = pl.[item_type]
				AND bs.[item]           = pl.[item]
				AND bs.[effective_date] = @prices_landed_effective_date
		WHERE
			pl.[plan_id]                  =  @plan_id
			AND pm.[spec_id]              =  @active_spec_id
			AND pm.[plan_id]              =  @plan_id
			AND pl.[effective_date]       =  @prices_landed_effective_date
			AND ISNULL(sai.[excluded], 0) <> 1
			AND (asa.[exclude_quick_price_display] = 0 OR asa.[exclude_quick_price_display] IS NULL)
			AND pm.[active]               =  1
			AND (pm.[end_date] IS NULL OR pm.[end_date] > GETDATE())
	),
	-- Resolve parts (colors) from price levels.
	-- Four paths mirror vds_selSessionProductSearchOptions resolved_colors CTE.
	-- Key difference from session: uses [wbs_spec_items] (not veo_spec_items)
	-- and [wbs_styles_groups_detail] (not catalog_selections_group_detail)
	-- since there is no homebuyer session selection to reference.
	[resolved_colors] AS
	(
		-- Path 1: spec_items (group) → styles_groups_detail (style) → styles → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'style'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = sg.[product_id]
				AND s.[style_id]   = sgd.[item]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = s.[product_id]
				AND c.[style_id]   = s.[style_id]
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 2: spec_items (group) → styles_groups_detail (color) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'color'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [veo_colors] c ON c.[part_no] = sgd.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 3: spec_items (style) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = si.[product_id]
				AND c.[style_id]   = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'style'

		UNION ALL

		-- Path 4: spec_items (color) → colors (direct part_no match)
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'color'
	)
	INSERT INTO @parts ([source_type], [name], [application], [product], [area], [sub_area], [price], [price_level], [part_no], [item_no], [gpc_id], [build_id])
	SELECT DISTINCT
		'estimated'                                          AS [source_type],
		c.[part_name_official]                               AS [name],
		c.[application]                                      AS [application],
		c.[product]                                          AS [product],
		c.[area]                                             AS [area],
		c.[sub_area]                                         AS [sub_area],
		c.[price_level_price]                                AS [price],
		SUBSTRING(c.[price_level_name], 1, 1000)             AS [price_level],
		c.[part_no]                                          AS [part_no],
		NULL                                                 AS [item_no],
		TRY_CAST(c.[global_product_id] AS UNIQUEIDENTIFIER)  AS [gpc_id],
		c.[build_id]                                         AS [build_id]
	FROM
		[resolved_colors] c
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = c.[stocking_code]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND (
			c.[part_name_official] LIKE '%' + ISNULL(@search_term, '') + '%'
			OR c.[part_no]         LIKE '%' + ISNULL(@search_term, '') + '%'
		)

	SELECT * FROM @parts
END
GO

PRINT ' [AFI_VeoSolutions] complete.';
GO

-- ===========================================================================
-- [CCDI_VeoSolutions]
-- ===========================================================================

PRINT '=========================================================';
PRINT ' Deploying to [CCDI_VeoSolutions]';
PRINT '=========================================================';

USE [CCDI_VeoSolutions];
GO

PRINT '  vds_selSessionProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selSessionProductSearchOptions]
	@session_id                UNIQUEIDENTIFIER,
	@security_token            UNIQUEIDENTIFIER,
	@search_term               VARCHAR(250)     = NULL,
	@builder_overrides_enabled BIT              = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-09
	Description:
		Returns a unified result set of ALL estimated (field colors) and
		non-estimated (catalog) items for a session, intended for product search.

		Estimated items are resolved set-based across all builds via CTEs, replacing the
		per-build N+1 pattern of vds_selHomebuyerCatalogBuilds +
		vds_selHomebuyerCatalogFieldColorsForBuild.  The same four color-resolution
		paths are preserved (group→style→color, group→color, style→color, color).

		Non-estimated items mirror vds_selSessionCatalogItems
		(catalog_selections WHERE source IN ('catalog', 'user')).

	Modified: Justin Pope
	Date: 2026-03-23
	Description: Reworked the estimated-item query to materialize session/build
		helpers in temp tables, preserve the existing field-color hierarchy with
		ordered insert statements, and continue exclusion handling through
		dbo.vdsf_selSpecAreaExcludedParts.

	Modified: Justin Pope
	Date: 2026-04-01
	Description: Product Option search was returning more builds than were on the session. Adding condition
		limits those to only those on the session.



	Modified: Justin Pope
	Date: 2026-04-07
	Description: Propagate option_pricing_display from catalog_selections through the
		estimated-item pipeline (#price_levels → #resolved_colors) so estimated items
		carry the actual value instead of a hardcoded 1.

	Output columns:
		source_type              VARCHAR(20)       -- 'estimated' | 'non_estimated'
		name                     VARCHAR(1500)     -- part name (respects builder overrides for estimated)
		application              VARCHAR(100)
		product                  VARCHAR(100)
		area                     VARCHAR(250)
		sub_area                 VARCHAR(250)
		price                    DECIMAL(18,4)
		price_level              VARCHAR(1000)     -- NULL for non-estimated
		part_no                  VARCHAR(250)      -- NULL for non-estimated
		item_no                  VARCHAR(250)      -- NULL for estimated
		gpc_id                   UNIQUEIDENTIFIER  -- NULL for estimated when cast fails
		option_pricing_display   BIT               -- catalog_selections value option_pricing_display
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'
	DECLARE @search_pattern VARCHAR(252) = '%' + ISNULL(@search_term, '') + '%'

	-- Final unified result set returned to the API.
	CREATE TABLE #parts
	(
		[source_type]            VARCHAR(20),
		[name]                   VARCHAR(1500),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[price]                  DECIMAL(18,4),
		[price_level]            VARCHAR(1000),
		[part_no]                VARCHAR(250),
		[item_no]                VARCHAR(250),
		[gpc_id]                 UNIQUEIDENTIFIER,
		[build_id]               INT,
		[option_pricing_display] BIT
	);

	-- Session build context drives both estimated-color resolution and exclusions.
	CREATE TABLE #builds
	(
		[session_id]     UNIQUEIDENTIFIER,
		[spec_id]        INT,
		[builder_id]     VARCHAR(20),
		[build_id]       INT NOT NULL PRIMARY KEY,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[location_id]    INT
	);

	-- Price levels are filtered up front to the only types that can resolve field colors.
	CREATE TABLE #price_levels
	(
		[session_id]         UNIQUEIDENTIFIER,
		[build_id]           INT,
		[spec_id]            INT,
		[builder_id]         VARCHAR(20),
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_name]   VARCHAR(1500),
		[price_level_type]   VARCHAR(10),
		[price_level_id]     VARCHAR(81),
		[price_level_price]      DECIMAL(18,4),
		[application]            VARCHAR(100),
		[product]                VARCHAR(100),
		[area]                   VARCHAR(250),
		[sub_area]               VARCHAR(250),
		[option_pricing_display] BIT,
		PRIMARY KEY ([price_level_type], [spec_id], [application_id], [product_id], [price_level_id], [build_id], [area_id], [sub_area_id])
	);

	-- Session group detail is split by item_type so the two group-based paths stay narrow.
	CREATE TABLE #session_group_styles
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	CREATE TABLE #session_group_colors
	(
		[group_id]    INT,
		[area_id]     VARCHAR(10),
		[sub_area_id] VARCHAR(10),
		[item]        VARCHAR(81),
		PRIMARY KEY ([group_id], [area_id], [sub_area_id], [item])
	);

	-- The resolved color set is populated in priority order with INSERT ... SELECT ... WHERE NOT EXISTS queries so earlier paths win.
	CREATE TABLE #resolved_colors
	(
		[spec_id]            INT,
		[build_id]           INT,
		[application_id]     VARCHAR(10),
		[product_id]         VARCHAR(10),
		[area_id]            VARCHAR(50),
		[sub_area_id]        VARCHAR(50),
		[location_id]        INT,
		[price_level_id]     VARCHAR(81),
		[price_level_name]   VARCHAR(1500),
		[price_level_price]  DECIMAL(18,4),
		[application]        VARCHAR(100),
		[product]            VARCHAR(100),
		[area]               VARCHAR(250),
		[sub_area]           VARCHAR(250),
		[part_no]            VARCHAR(81),
		[stocking_code]      VARCHAR(50),
		[global_product_id]  VARCHAR(100),
		[part_name_official]     VARCHAR(1500),
		[option_pricing_display] BIT,
		PRIMARY KEY ([build_id], [price_level_id], [part_no])
	);

	-- Exclusions stay centralized through the shared function so behavior matches other callers.
	CREATE TABLE #spec_area_exclusions
	(
		[spec_id]        INT,
		[application_id] VARCHAR(10),
		[product_id]     VARCHAR(10),
		[area_id]        VARCHAR(50),
		[sub_area_id]    VARCHAR(50),
		[part_no]        VARCHAR(81),
		PRIMARY KEY ([spec_id], [application_id], [product_id], [area_id], [sub_area_id], [part_no])
	);

	INSERT INTO #builds
	(
		[session_id],
		[spec_id],
		[builder_id],
		[build_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id]
	)
	SELECT
		s.[session_id],
		vpm.[spec_id],
		vsm.[builder_id],
		vpb.[build_id],
		vpb.[application_id],
		vpb.[product_id],
		vpb.[area_id],
		vpb.[sub_area_id],
		vpb.[location_id]
	FROM
		[account_organization_user_profile_plan_catalog_sessions] s
		JOIN [catalog_selections_areas] csa ON csa.[session_id] = s.[session_id]
												AND csa.[area_selected] = 1
		JOIN [veo_spec_mstr] vsm ON vsm.[spec_id] = s.[spec_id]
		JOIN [veo_plan_mstr] vpm ON vpm.[spec_id] = vsm.[spec_id]
		JOIN [veo_plan_builds] vpb
			ON  vpb.[plan_id] = vpm.[plan_id]
			AND vpb.[build_id] = csa.[build_id]
	WHERE
		s.[session_id] = @session_id;

	INSERT INTO #price_levels
	(
		[session_id],
		[build_id],
		[spec_id],
		[builder_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[location_id],
		[price_level_name],
		[price_level_type],
		[price_level_id],
		[price_level_price],
		[application],
		[product],
		[area],
		[sub_area],
		[option_pricing_display]
	)
	SELECT
		b.[session_id],
		b.[build_id],
		b.[spec_id],
		b.[builder_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		b.[location_id],
		cs.[item]                    AS [price_level_name],
		cs.[item_type]               AS [price_level_type],
		cs.[item_no]                 AS [price_level_id],
		cs.[price]                   AS [price_level_price],
		cs.[application],
		cs.[product],
		cs.[area],
		cs.[sub_area],
		cs.[option_pricing_display]
	FROM
		#builds b
		JOIN [catalog_selections] cs
			ON  cs.[session_id] = b.[session_id]
			AND cs.[build_id] = b.[build_id]
	WHERE
		cs.[item_type] IN ('group', 'style', 'color');

	INSERT INTO #session_group_styles
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'style';

	INSERT INTO #session_group_colors
	(
		[group_id],
		[area_id],
		[sub_area_id],
		[item]
	)
	SELECT DISTINCT
		sgd.[group_id],
		ISNULL(sgd.[area_id], '') AS [area_id],
		ISNULL(sgd.[sub_area_id], '') AS [sub_area_id],
		sgd.[item]
	FROM
		[catalog_selections_group_detail] sgd
	WHERE
		sgd.[session_id] = @session_id
		AND sgd.[item_type] = 'color';

	-- =============================================
	-- #1 spec_items --> groups -> styles -> colors
	-- =============================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_styles sgs
			ON  sgs.[group_id] = sg.[group_id]
			AND sgs.[area_id] IN ('', pl.[area_id])
			AND sgs.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [Veo_styles] s
			ON  s.[product_id] = sg.[product_id]
			AND s.[style_id] = sgs.[item]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = s.[product_id]
			AND c.[style_id] = s.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		and not exists(
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		)


	-- =========================================
	-- #2 spec_items --> groups -> colors
	-- =========================================
	INSERT INTO #resolved_colors 
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
		LEFT JOIN #session_group_colors sgc
			ON  sgc.[group_id] = sg.[group_id]
			AND sgc.[area_id] IN ('', pl.[area_id])
			AND sgc.[sub_area_id] IN ('', pl.[sub_area_id])
		LEFT JOIN [veo_colors] c ON c.[part_no] = sgc.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'group'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			select 1 from #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);

	-- =========================================
	-- #3 spec_items --> styles -> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c
			ON  c.[product_id] = si.[product_id]
			AND c.[style_id] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'style'
		AND s.[class] = @item_class
		AND NOT EXISTS(
			SELECT 1 FROM #resolved_colors rc
			WHERE rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);
	
	-- =========================================
	-- #4 spec_items --> colors
	-- =========================================
	INSERT INTO #resolved_colors
	SELECT DISTINCT
		pl.[spec_id],
		pl.[build_id],
		pl.[application_id],
		pl.[product_id],
		pl.[area_id],
		pl.[sub_area_id],
		pl.[location_id],
		pl.[price_level_id],
		pl.[price_level_name],
		pl.[price_level_price],
		pl.[application],
		pl.[product],
		pl.[area],
		pl.[sub_area],
		c.[part_no],
		c.[stocking_code],
		c.[global_product_id],
		CASE
			WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
				THEN cco.[color_private_label]
			ELSE c.[name]
		END AS [part_name_official],
		pl.[option_pricing_display]
	FROM
		#price_levels pl
		JOIN [veo_spec_items] si
			ON  si.[item_type] = pl.[price_level_type]
			AND si.[item] = pl.[price_level_id]
			AND si.[spec_id] = pl.[spec_id]
			AND si.[application_id] = pl.[application_id]
			AND si.[product_id] = pl.[product_id]
		LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
		LEFT JOIN [veo_styles] s
			ON  s.[product_id] = c.[product_id]
			AND s.[style_id] = c.[style_id]
		LEFT JOIN [veo_colors_customer_overrides] cco
			ON  cco.[part_no] = c.[part_no]
			AND cco.[customer_id] = pl.[builder_id]
	WHERE
		pl.[price_level_type] = 'color'
		AND s.[class] = @item_class
		AND NOT EXISTS (
			SELECT 1 FROM #resolved_colors rc
			where rc.[build_id] = pl.[build_id]
				AND rc.[price_level_id] = pl.[price_level_id]
				AND rc.[part_no] = c.[part_no]
		);	

	-- Preserve shared exclusion behavior by routing session/build combinations
	-- through the existing function instead of re-implementing exclusion logic here.
	INSERT INTO #spec_area_exclusions
	(
		[spec_id],
		[application_id],
		[product_id],
		[area_id],
		[sub_area_id],
		[part_no]
	)
	SELECT DISTINCT
		b.[spec_id],
		b.[application_id],
		b.[product_id],
		b.[area_id],
		b.[sub_area_id],
		e.[part_no]
	FROM
		#builds b
		CROSS APPLY dbo.[vdsf_selSpecAreaExcludedParts]
		(
			@session_id,
			b.[spec_id],
			b.[application_id],
			b.[product_id],
			b.[area_id],
			b.[sub_area_id],
			b.[location_id],
			'field'
		) e;

	-- Estimated search rows come from the resolved field-color set after selectable
	-- and exclusion filtering are applied.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT
		'estimated' AS [source_type],
		rc.[part_name_official] AS [name],
		rc.[application] AS [application],
		rc.[product] AS [product],
		rc.[area] AS [area],
		rc.[sub_area] AS [sub_area],
		rc.[price_level_price] AS [price],
		SUBSTRING(rc.[price_level_name], 1, 1000) AS [price_level],
		rc.[part_no] AS [part_no],
		NULL AS [item_no],
		TRY_CAST(rc.[global_product_id] AS UNIQUEIDENTIFIER) AS [gpc_id],
		rc.[build_id] AS [build_id],
		rc.[option_pricing_display] AS [option_pricing_display]
	FROM
		#resolved_colors rc
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = rc.[stocking_code]
		LEFT JOIN #spec_area_exclusions sae
			ON  sae.[spec_id] = rc.[spec_id]
			AND sae.[application_id] = rc.[application_id]
			AND sae.[product_id] = rc.[product_id]
			AND sae.[area_id] = rc.[area_id]
			AND sae.[sub_area_id] = rc.[sub_area_id]
			AND sae.[part_no] = rc.[part_no]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND sae.[part_no] IS NULL
		AND
		(
			rc.[part_name_official] LIKE @search_pattern
			OR rc.[part_no] LIKE @search_pattern
		);

	-- Non-estimated search rows continue to come directly from catalog selections.
	INSERT INTO #parts
	(
		[source_type],
		[name],
		[application],
		[product],
		[area],
		[sub_area],
		[price],
		[price_level],
		[part_no],
		[item_no],
		[gpc_id],
		[build_id],
		[option_pricing_display]
	)
	SELECT DISTINCT
		'non_estimated' AS [source_type],
		SUBSTRING(cs.[item], 1, 1500) AS [name],
		cs.[application] AS [application],
		cs.[product] AS [product],
		a.[name] AS [area],
		sa.[name] AS [sub_area],
		cs.[price] AS [price],
		NULL AS [price_level],
		NULL AS [part_no],
		cs.[item_no] AS [item_no],
		TRY_CAST(cs.[gpc] AS UNIQUEIDENTIFIER) AS [gpc_id],
		NULL AS [build_id],
		cs.[option_pricing_display] AS [option_pricing_display]
	FROM
		[dbo].[catalog_selections] cs
		LEFT JOIN [veo_areas] a ON a.[area_id] = cs.[area]
		LEFT JOIN [veo_sub_areas] sa ON sa.[sub_area_id] = cs.[sub_area]
	WHERE
		cs.[session_id] = @session_id
		AND cs.[source] IN ('catalog', 'user')
		AND
		(
			cs.[item] LIKE @search_pattern
			OR cs.[item_no] LIKE @search_pattern
		);

	SELECT * FROM #parts;
END
GO

PRINT '  vds_selNonSessionEstimatedProductSearchOptions...';
GO

CREATE OR ALTER PROCEDURE [dbo].[vds_selNonSessionEstimatedProductSearchOptions]
	@security_token            UNIQUEIDENTIFIER,
	@account_id                UNIQUEIDENTIFIER,
	@organization_id           UNIQUEIDENTIFIER,
	@community_name            VARCHAR(100),
	@series_name               VARCHAR(100),
	@plan_name                 VARCHAR(100),
	@search_term               VARCHAR(250),
	@builder_overrides_enabled BIT = 0
AS
/*
	Author: Justin Pope
	Date: 2026-03-16
	Description:
		Returns estimated (field color) items for a non-session product search.
		Replaces the multi-step, N+1 Yukon pattern in GetNonSessionProductSearchOptions:
		  - community/series/plan resolution from VeoSolutionsSecurity mapping tables
		  - active spec + plan + effective date resolution through Veo/WBS data
		  - max build per area via window functions (replaces vds_optionPricingMaxMinBuilds cursor)
		  - color resolution via four paths mirroring vds_selSessionProductSearchOptions
		  - builder name overrides via veo_colors_customer_overrides

		All in a single DB round-trip against VeoSolutions using local synonyms for
		Veo and WBS data.

	Output columns (matches @parts shape of vds_selSessionProductSearchOptions):
		source_type   VARCHAR(20)       -- always 'estimated'
		name          VARCHAR(1500)     -- part name (respects builder overrides)
		application   VARCHAR(100)
		product       VARCHAR(100)
		area          VARCHAR(250)      -- display name
		sub_area      VARCHAR(250)      -- display name
		price         DECIMAL(18,4)
		price_level   VARCHAR(1000)     -- price level display name
		part_no       VARCHAR(250)
		item_no       VARCHAR(250)      -- always NULL for estimated
		gpc_id        UNIQUEIDENTIFIER  -- always NULL for estimated
		build_id      INT

	Modified: Justin Pope
	Date: 2026-04-02
	Description:
		Fixed an issue where multiple builds for the same area/sub_area were producing
		duplicate rows in the result set. The build_candidates CTE was using RANK() partitioned
		by (application_id, product_id, area_id, sub_area_id, location_id). Two problems:
		  1. RANK() assigns the same rank to tied rows (equal bill_qty), so multiple builds
		     could share build_rank = 1 for the same partition.
		  2. Including location_id in the partition meant that a single area/sub_area with
		     multiple location rows in prices_landed produced one winning build per location,
		     causing the same area/sub_area to appear multiple times downstream.
		Fix: Changed RANK() to ROW_NUMBER() and removed location_id from the PARTITION BY,
		so exactly one build is selected per application/product/area/sub_area. Added
		build_id DESC as a deterministic tiebreaker when bill_qty values are equal.
		location_id was also removed from the selected_builds, price_levels, and resolved_colors
		CTEs since it is not part of the output and was the source of the fan-out.
	Modified: Daniela
	Date: 2026-04-07
	Description:
		Two additional alignment fixes with vds_selEstimatedOptionPricingItemsForNonSession_Yukon:
		  1. Price rounding: price_level_price now applies CEILING(price / 10.0) * 10 to match
		     the outer proc's ((CEILING(SUM(price_retail) / 10)) * 10) rounding.
		  2. Zero/negative area exclusion: build_candidates now uses an EXISTS against wbs_plan_material
		     (matching on plan_id + build_id, any item) to require at least one positive bill_qty row —
		     mirroring the outer proc's pbm.bill_qty > 0 filter. The original fix used the narrow pm2
		     'field'-item join which incorrectly excluded builds like "All Carpeted Areas" that don't
		     carry a 'field' item for every area combination.

	Modified: Daniela
	Date: 2026-04-07
	Description:
		Aligned build selection and area labeling with vds_selEstimatedOptionPricingItemsForNonSession_Yukon
		so that the area and build_id values returned here match what that proc returns for the same plan.
		Two root causes addressed:
		  1. Build selection now respects the builder's opt_pricing_build_type setting (read from
		     wbs_customers). Previously it always selected the maximum build. Now it supports
		     'maximum', 'minimum', and default (standard/is_std) modes.
		  2. The area column is now replaced with build_desc (the build's display name from
		     plan_builds), mirroring the outer proc's Step 8 area-label swap. When @group_walls=1,
		     tile items in bathrooms (room_group 2 or 3) are grouped into "<AreaName> Walls".
		Also: renamed the max_builds CTE to selected_builds for clarity, added wbs_customers and
		wbs_room_groups synonyms to support the new logic.
*/
BEGIN
	IF (dbo.vdsf_isValidSecurityToken(@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @item_class VARCHAR(50) = 'field'

	-- ============================================================
	-- Phase 1 — Resolve candidate names and match a Veo spec/plan
	-- ============================================================
	DECLARE @effective_date DATETIME = GETDATE()
	DECLARE @effective_date_no_time DATE = CONVERT(DATE, @effective_date)

	DECLARE @external_org_id VARCHAR(50)

	DECLARE @resolved_spec_id INT
	DECLARE @active_spec_id INT
	DECLARE @prices_landed_effective_date DATETIME
	DECLARE @plan_id INT
	
	-- external_organization_id (builder_id in WBS)
	SELECT @external_org_id = vso.[external_organization_id]
	FROM   [VeoSolutionsSecurity_organizations] vso
		inner join [VeoSolutionsSecurity_account_organizations] vsao on vsao.[organization_id] = vso.[organization_id]
	WHERE  vso.[organization_id] = @organization_id
		and vsao.[account_id] = @account_id;
		
	;WITH communities
    AS
    (
        select 
            vsm.[spec_id],
            vsm.[start_date],
            vc.community_id,
            vc.[name] as [community_name]
        from 
            Veo_spec_communities vsc
            JOIN Veo_spec_mstr vsm on vsm.spec_id = vsc.spec_id
            JOIN Veo_communities vc on vc.community_id = vsc.community_id
            JOIN (
                -- Fetch VDS community names (builder names)
                SELECT
                    aoc.name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name

                UNION

                -- Fetch mapped community names (Wisenbaker names)
                SELECT
                    aocm.mapped_name AS community_name
                FROM
                    VeoSolutionsSecurity_account_organization_communities aoc 
                    JOIN VeoSolutionsSecurity_account_organization_communities_mappings aocm  ON aocm.account_id = aoc.account_id AND aocm.organization_id = aoc.organization_id AND aocm.community_id = aoc.community_id
                WHERE
                    aoc.account_id = @account_id
                    AND aoc.organization_id = @organization_id
                    AND aoc.name = @community_name
                    ) vss_c on vss_c.community_name = vc.[name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
	series
    AS
    (
        SELECT
            vsm.spec_id,
            vsm.[start_date],
            vss.series as [series_name]
        FROM
            Veo_spec_series vss
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vss.spec_id
            JOIN (
                -- Fetch VDS series names (builder names)
                SELECT
                    aos.name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name

                UNION

                -- Fetch mapped series names (Wisenbaker names)
                SELECT
                    aosm.mapped_name AS series_name
                FROM
                    VeoSolutionsSecurity_account_organization_series aos 
                    JOIN VeoSolutionsSecurity_account_organization_series_mappings aosm ON aosm.account_id = aos.account_id AND aosm.organization_id = aos.organization_id AND aosm.series_id = aos.series_id
                WHERE
                    aos.account_id = @account_id
                    AND aos.organization_id = @organization_id
                    AND aos.name = @series_name
                    ) vss_s on vss_s.series_name = vss.series
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
    ),
    plans
    AS
    (
        SELECT
            vsm.[spec_id],
            vsm.[start_date],
            vpm.[plan_id] as [plan_id],
            vpm.[plan_name] as [plan_name]
        FROM
            Veo_plan_mstr vpm
            JOIN Veo_spec_mstr vsm ON vsm.spec_id = vpm.[spec_id]
            JOIN (        
                -- Fetch VDS plans names
                SELECT
                    aop.name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name

                union

                -- Fetch mapped plans names
                SELECT
                    aopm.mapped_name as plans_name
                FROM
                    VeoSolutionsSecurity_account_organization_plans aop
                    LEFT JOIN VeoSolutionsSecurity_account_organization_plans_mappings aopm
                        ON aopm.account_id = aop.account_id
                        AND aopm.organization_id = aop.organization_id
                        AND aopm.plan_id = aop.plan_id
                WHERE
                    aop.account_id = @account_id
                    and aop.organization_id = @organization_id
                    and aop.name = @plan_name
                    ) vss_p  on vss_p.[plans_name] = vpm.[plan_name]
        where
            vsm.builder_id = @external_org_id
            and vsm.[start_date] <= @effective_date
            and (vsm.[end_date] >= @effective_date OR vsm.[end_date] IS NULL)
            and vsm.active = 1
            and (vpm.end_date >= @effective_date or vpm.end_date is null)
            and vpm.active = 1
       )
	SELECT top 1
        @active_spec_id = sm.[spec_id], 
        @prices_landed_effective_date = p.effective_date, 
        @plan_id = pm.plan_id
	FROM
		[wbs_spec_mstr]        sm
		JOIN [wbs_spec_communities] sc    ON sc.[spec_id]       = sm.[spec_id]
        join [communities]          cte_c on cte_c.community_id = sc.community_id
                                         and cte_c.spec_id      = sm.spec_id
		JOIN [wbs_spec_series]      ss    ON ss.[spec_id]       = sm.[spec_id]
        join [series]               cte_s on cte_s.series_name  = ss.series
                                         and cte_s.spec_id      = sm.spec_id
        JOIN [wbs_plan_mstr]        pm    on pm.spec_id         = sm.spec_id
        join [plans]                cte_p on cte_p.plan_id      = pm.plan_id
                                         and cte_p.spec_id      = sm.spec_id
		JOIN [wbs_pricesets]        p     ON p.[spec_id]        = sm.[spec_id]
	WHERE
		sm.[builder_id]    = @external_org_id
		AND sm.[active]        = 1
		AND (sm.[end_date] IS NULL OR sm.[end_date] >= CONVERT(DATE, @effective_date))
		AND p.[active]         = 1
		AND p.[effective_date] <= @effective_date
	ORDER BY
		p.[effective_date] DESC

	IF @account_id IS NULL OR @organization_id IS NULL OR @active_spec_id IS NULL OR @plan_id IS NULL OR @prices_landed_effective_date IS NULL
		RETURN

	-- Read build-selection behavior configured per builder in the customers table.
	-- @build_type : 'maximum' | 'minimum' | '' (empty = standard/default)
	-- @group_walls: 1 = merge bath tile walls into a single area row
	DECLARE @build_type  VARCHAR(10) = ''
	DECLARE @group_walls BIT         = 0
	SELECT
		@build_type  = ISNULL(c.[opt_pricing_build_type], ''),
		@group_walls = ISNULL(c.[group_walls], 0)
	FROM [wbs_customers] c
	WHERE c.[custnmbr] = @external_org_id

	-- ============================================================
	-- Output collector
	-- ============================================================
	DECLARE @parts TABLE
	(
		[source_type] VARCHAR(20),
		[name]        VARCHAR(1500),
		[application] VARCHAR(100),
		[product]     VARCHAR(100),
		[area]        VARCHAR(250),
		[sub_area]    VARCHAR(250),
		[price]       DECIMAL(18,4),
		[price_level] VARCHAR(1000),
		[part_no]     VARCHAR(250),
		[item_no]     VARCHAR(250),
		[gpc_id]      UNIQUEIDENTIFIER,
		[build_id]    INT
	)

	-- ============================================================
	-- Phase 3+4 — Build selection CTE + price levels + color resolution
	-- ============================================================
	;WITH
	-- Determine the single representative build per application/product/area/sub_area.
	-- Partitioned WITHOUT location_id so that multiple locations for the same area/sub_area
	-- do not produce multiple winning builds and duplicate rows in the final output.
	-- ROW_NUMBER (not RANK) guarantees exactly one winner even when bill_qty ties.
	-- Only builds that have at least one plan_material row with bill_qty > 0 are considered
	-- (mirrors the outer proc's pbm.bill_qty > 0 filter via a broad EXISTS, not limited to the
	-- 'field' item, to avoid incorrectly excluding builds like "All Carpeted Areas" that may not
	-- carry a 'field' item in plan_material for every application/product/area combination).
	-- Build selection is driven by @build_type (read from wbs_customers):
	--   'maximum' → highest bill_qty wins; build_id DESC breaks ties
	--   'minimum' → lowest bill_qty wins; build_id DESC breaks ties
	--   default   → is_std build wins; bill_qty DESC and build_id DESC break ties
	-- Exception: cabinets (application_id='10', product_id='Y') always use their is_std build.
	[build_candidates] AS
	(
		SELECT
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[build_id],
			pb.[build_desc],
			ROW_NUMBER() OVER
			(
				PARTITION BY pl.[application_id], pl.[product_id], pl.[area_id], pl.[sub_area_id]
				ORDER BY
					-- Cabinets: std build always wins regardless of @build_type
					CASE
						WHEN pl.[application_id] = '10' AND pl.[product_id] = 'Y' AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- For default/std build_type: is_std build takes priority over bill_qty
					CASE
						WHEN ISNULL(@build_type, '') NOT IN ('maximum', 'minimum') AND pb.[is_std] = 1
							THEN 0
						ELSE 1
					END,
					-- bill_qty: negated for 'minimum' so DESC sort always selects the correct extreme
					CASE
						WHEN @build_type = 'minimum'
							THEN -ISNULL(pm2.[bill_qty], 0)
						ELSE ISNULL(pm2.[bill_qty], 0)
					END DESC,
					pl.[build_id] DESC
			) AS [build_rank]
		FROM
			[wbs_prices_landed]  pl
			LEFT JOIN [wbs_plan_builds]  pb
				ON  pb.[build_id]       = pl.[build_id]
				AND pb.[plan_id]        = pl.[plan_id]
			LEFT JOIN [wbs_plan_material] pm2
				ON  pm2.[plan_id]       = pb.[plan_id]
				AND pm2.[build_id]      = pb.[build_id]
				AND pm2.[application_id] = pb.[application_id]
				AND pm2.[product_id]    = pb.[product_id]
				AND pm2.[area_id]       = pb.[area_id]
				AND pm2.[sub_area_id]   = pb.[sub_area_id]
				AND pm2.[location_id]   = pb.[location_id]
				AND pm2.[item_id]       = 'field'
		WHERE
			pl.[plan_id]        = @plan_id
			AND pl.[effective_date] = @prices_landed_effective_date
			AND EXISTS
			(
				-- Mirror the outer proc's pbm.bill_qty > 0 filter: require at least one
				-- plan_material row for this plan+build (any item) to have positive bill_qty.
				-- Using a broad EXISTS rather than the pm2 'field'-item join avoids incorrectly
				-- excluding builds whose field item is absent or uses a different item classification.
				SELECT 1
				FROM [wbs_plan_material] pm3
				WHERE pm3.[plan_id]  = pl.[plan_id]
				  AND pm3.[build_id] = pl.[build_id]
				  AND pm3.[bill_qty] > 0
			)
	),
	[selected_builds] AS
	(
		SELECT [application_id], [product_id], [area_id], [sub_area_id], [build_id], [build_desc]
		FROM   [build_candidates]
		WHERE  [build_rank] = 1
	),
	-- Price levels: prices_landed rows for the selected build, with display names applied.
	-- Mirrors what vds_selEstimatedOptionPricingItemsForNonSession_Yukon returns
	-- but as a CTE rather than a separate procedure call.
	-- area is replaced with build_desc (mirroring the outer proc's Step 8 area-label swap).
	-- When @group_walls=1, tile items in bathrooms (room_group 2 or 3) are grouped into
	-- a single "<AreaName> Walls" area with sub_area cleared.
	[price_levels] AS
	(
		SELECT DISTINCT
			mb.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[item_type]                                        AS [price_level_type],
			pl.[item]                                             AS [price_level_id],
			ISNULL(bs.[builder_style_name], pl.[customer_item_name]) AS [price_level_name],
			CEILING(pl.[price_retail] / 10.0) * 10               AS [price_level_price],
			LTRIM(RTRIM(ap.[name]))                               AS [application],
			LTRIM(RTRIM(pr.[name]))                               AS [product],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ar.[name] + ' Walls'
				ELSE mb.[build_desc]
			END                                                   AS [area],
			CASE
				WHEN @group_walls = 1 AND pl.[application_id] = '3' AND rg.[code] IN (2, 3)
					THEN ''
				WHEN mb.[build_desc] IS NOT NULL
					THEN ''
				ELSE sar.[name]
			END                                                   AS [sub_area]
		FROM
			[wbs_prices_landed]      pl
			JOIN [selected_builds] mb
				ON  mb.[build_id]       = pl.[build_id]
				AND mb.[application_id] = pl.[application_id]
				AND mb.[product_id]     = pl.[product_id]
				AND mb.[area_id]        = pl.[area_id]
				AND mb.[sub_area_id]    = pl.[sub_area_id]
			JOIN [wbs_plan_builds]   pb  ON pb.[build_id]      = pl.[build_id]
			                                           AND pb.[plan_id]       = pl.[plan_id]
			JOIN [wbs_plan_mstr]     pm  ON pm.[plan_id]       = pb.[plan_id]
			JOIN [wbs_areas]         ar  ON ar.[area_id]       = pl.[area_id]
			LEFT JOIN [wbs_room_groups] rg ON rg.[code]        = ar.[room_group]
			JOIN [wbs_sub_areas]     sar ON sar.[sub_area_id]  = pl.[sub_area_id]
			JOIN [wbs_applications]  ap  ON ap.[application_id] = pl.[application_id]
			JOIN [wbs_products]      pr  ON pr.[product_id]    = pl.[product_id]
			LEFT JOIN [wbs_spec_areas_items] sai
				ON  sai.[spec_id]       = pm.[spec_id]
				AND sai.[application_id] = pl.[application_id]
				AND sai.[product_id]    = pl.[product_id]
				AND sai.[area_id]       = pl.[area_id]
				AND sai.[sub_area_id]   = pl.[sub_area_id]
				AND (sai.[location_id]  = pl.[location_id] OR sai.[location_id] = 0)
				AND sai.[item_type]     = pl.[item_type]
				AND sai.[item]          = pl.[item]
			LEFT JOIN [wbs_areas_sub_areas] asa
				ON  asa.[area_id]       = ar.[area_id]
				AND asa.[sub_area_id]   = sar.[sub_area_id]
			LEFT JOIN [wbs_builder_styles] bs
				ON  bs.[builder_id]     = @external_org_id
				AND bs.[spec_id]        = pm.[spec_id]
				AND bs.[item_type]      = pl.[item_type]
				AND bs.[item]           = pl.[item]
				AND bs.[effective_date] = @prices_landed_effective_date
		WHERE
			pl.[plan_id]                  =  @plan_id
			AND pm.[spec_id]              =  @active_spec_id
			AND pm.[plan_id]              =  @plan_id
			AND pl.[effective_date]       =  @prices_landed_effective_date
			AND ISNULL(sai.[excluded], 0) <> 1
			AND (asa.[exclude_quick_price_display] = 0 OR asa.[exclude_quick_price_display] IS NULL)
			AND pm.[active]               =  1
			AND (pm.[end_date] IS NULL OR pm.[end_date] > GETDATE())
	),
	-- Resolve parts (colors) from price levels.
	-- Four paths mirror vds_selSessionProductSearchOptions resolved_colors CTE.
	-- Key difference from session: uses [wbs_spec_items] (not veo_spec_items)
	-- and [wbs_styles_groups_detail] (not catalog_selections_group_detail)
	-- since there is no homebuyer session selection to reference.
	[resolved_colors] AS
	(
		-- Path 1: spec_items (group) → styles_groups_detail (style) → styles → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'style'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = sg.[product_id]
				AND s.[style_id]   = sgd.[item]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = s.[product_id]
				AND c.[style_id]   = s.[style_id]
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 2: spec_items (group) → styles_groups_detail (color) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [Veo_styles_groups] sg ON sg.[group_id] = si.[item]
			LEFT JOIN [wbs_styles_groups_detail] sgd
				ON  sgd.[group_id]    = sg.[group_id]
				AND sgd.[customer_id] = @external_org_id
				AND sgd.[item_type]   = 'color'
				AND CAST(sgd.[effective_date] AS DATE) <= CAST(GETDATE() AS DATE)
				AND (sgd.[end_date] IS NULL OR CAST(sgd.[end_date] AS DATE) > CAST(GETDATE() AS DATE))
			LEFT JOIN [veo_colors] c ON c.[part_no] = sgd.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'group'

		UNION ALL

		-- Path 3: spec_items (style) → colors
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c
				ON  c.[product_id] = si.[product_id]
				AND c.[style_id]   = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'style'

		UNION ALL

		-- Path 4: spec_items (color) → colors (direct part_no match)
		SELECT DISTINCT
			pl.[build_id],
			pl.[application_id],
			pl.[product_id],
			pl.[area_id],
			pl.[sub_area_id],
			pl.[price_level_id],
			pl.[price_level_name],
			pl.[price_level_price],
			pl.[application],
			pl.[product],
			pl.[area],
			pl.[sub_area],
			c.[part_no],
			c.[stocking_code],
			c.[global_product_id],
			CASE
				WHEN @builder_overrides_enabled = 1 AND DATALENGTH(cco.[color_private_label]) > 0
					THEN cco.[color_private_label]
				ELSE c.[name]
			END AS [part_name_official]
		FROM
			[price_levels] pl
			JOIN [wbs_spec_items] si
				ON  si.[item_type]      = pl.[price_level_type]
				AND si.[item]           = pl.[price_level_id]
				AND si.[spec_id]        = @active_spec_id
				AND si.[application_id] = pl.[application_id]
				AND si.[product_id]     = pl.[product_id]
			LEFT JOIN [veo_colors] c ON c.[part_no] = si.[item]
			LEFT JOIN [Veo_styles] s
				ON  s.[product_id] = c.[product_id]
				AND s.[style_id]   = c.[style_id]
				AND s.[class]      = @item_class
			LEFT JOIN [veo_colors_customer_overrides] cco
				ON  cco.[part_no]     = c.[part_no]
				AND cco.[customer_id] = @external_org_id
		WHERE
			pl.[price_level_type] = 'color'
	)
	INSERT INTO @parts ([source_type], [name], [application], [product], [area], [sub_area], [price], [price_level], [part_no], [item_no], [gpc_id], [build_id])
	SELECT DISTINCT
		'estimated'                                          AS [source_type],
		c.[part_name_official]                               AS [name],
		c.[application]                                      AS [application],
		c.[product]                                          AS [product],
		c.[area]                                             AS [area],
		c.[sub_area]                                         AS [sub_area],
		c.[price_level_price]                                AS [price],
		SUBSTRING(c.[price_level_name], 1, 1000)             AS [price_level],
		c.[part_no]                                          AS [part_no],
		NULL                                                 AS [item_no],
		TRY_CAST(c.[global_product_id] AS UNIQUEIDENTIFIER)  AS [gpc_id],
		c.[build_id]                                         AS [build_id]
	FROM
		[resolved_colors] c
		JOIN [Veo_stocking_codes] vsc ON vsc.[code] = c.[stocking_code]
	WHERE
		vsc.[homebuyer_selectable] = 1
		AND (
			c.[part_name_official] LIKE '%' + ISNULL(@search_term, '') + '%'
			OR c.[part_no]         LIKE '%' + ISNULL(@search_term, '') + '%'
		)

	SELECT * FROM @parts
END
GO

PRINT ' [CCDI_VeoSolutions] complete.';
GO

PRINT '=========================================================';
PRINT ' All databases deployed.';
PRINT '=========================================================';
GO
