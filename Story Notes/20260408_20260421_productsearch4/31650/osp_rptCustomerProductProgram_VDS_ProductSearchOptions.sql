SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE or ALTER PROCEDURE [dbo].[osp_rptCustomerProductProgram_VDS_ProductSearchOptions]
    @customer_id               VARCHAR(15),
    @spec_id                   INT,
    @plan_id                   INT,
    @effective_date            DATETIME,
    @search_term               VARCHAR(250) = NULL,
    @builder_overrides_enabled BIT          = 0
AS
/*
    Author:      Justin Pope
    Create date: 4/16/2026
    Description: Given a customer, spec, plan, and effective date, returns the estimated
                 option pricing items with resolved color parts for that plan.
                 Originally patterned on vds_selAllEstimatedOptionPricingItemsForNonSession_Yukon;
                 corrected in #31650 to align with vds_selEstimatedOptionPricingItemsForNonSession_Yukon:
                 reads opt_pricing_build_type and group_walls from customers to drive dynamic
                 build selection (max / min / std) and conditional bath-tile wall grouping.
                 Output: source_type, name, application, product, area, sub_area,
                         price, price_level, part_no, item_no, gpc_id, build_id
    Usage:
        EXEC [dbo].[osp_rptCustomerProductProgram_JKP]
            @customer_id               = 'TMH2010',
            @spec_id                   = 8279,
            @plan_id                   = 12345,
            @effective_date            = '2026-04-10',
            @search_term               = NULL,
            @builder_overrides_enabled = 0
*/
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- Step 1: Resolve plan_name — required by vds_optionPricingMaxMinBuilds
    -- ============================================================
    DECLARE @plan_name VARCHAR(50);
    SELECT @plan_name = [plan_name]
    FROM   [dbo].[plan_mstr] WITH (NOLOCK)
    WHERE  [plan_id] = @plan_id;

    -- ============================================================
    -- Step 1b: Resolve customer-level build behavior flags.
    --          opt_pricing_build_type drives which build (max/min/std)
    --          is selected per area.  group_walls controls whether bath-tile
    --          sub_areas are collapsed into a single "Tile Walls" row.
    -- ============================================================
    DECLARE @group_walls BIT, @build_type VARCHAR(10);
    SELECT
        @group_walls = [group_walls],
        @build_type  = [opt_pricing_build_type]
    FROM [dbo].[customers] WITH (NOLOCK)
    WHERE [custnmbr] = @customer_id;

    -- ============================================================
    -- Step 2: Resolve priceset effective date
    --         Max published effective_date on or before @effective_date
    --         for this spec + plan combination.
    -- ============================================================
    DECLARE @prices_landed_effective_date DATETIME;
    SELECT
        @prices_landed_effective_date = MAX([pl].[effective_date])
    FROM
        [dbo].[prices_landed] [pl] WITH (NOLOCK)
        LEFT JOIN [dbo].[plan_mstr] [pm] WITH (NOLOCK)
            ON  [pm].[plan_id]        = [pl].[plan_id]
        LEFT JOIN [dbo].[pricesets]  [ps] WITH (NOLOCK)
            ON  [ps].[spec_id]        = [pm].[spec_id]
            AND [ps].[effective_date] = [pl].[effective_date]
    WHERE
        [pm].[spec_id]            = @spec_id
        AND [pm].[plan_id]        = @plan_id
        AND [pm].[active]         = 1
        AND [pl].[effective_date] <= @effective_date
        AND [ps].[active]         = 1;

    -- ============================================================
    -- Step 3: Get max/min/std builds per application/product/area/sub_area.
    --         vds_optionPricingMaxMinBuilds lives on this (Echelon) server —
    --         no linked-server overhead.
    -- ============================================================
    DECLARE @MaxMinBuilds TABLE
    (
        [application_id] VARCHAR(10),
        [product_id]     VARCHAR(10),
        [area_id]        VARCHAR(10),
        [sub_area_id]    VARCHAR(10),
        [location_id]    INT,
        [max_build_id]   BIGINT,
        [max_build_desc] VARCHAR(100),
        [max_field_qty]  DECIMAL(18,2),
        [min_build_id]   BIGINT,
        [min_build_desc] VARCHAR(100),
        [min_field_qty]  DECIMAL(18,2),
        [std_build_id]   BIGINT,
        [std_build_desc] VARCHAR(100),
        [std_field_qty]  DECIMAL(18,2)
    );

    INSERT INTO @MaxMinBuilds
    EXEC [dbo].[vds_optionPricingMaxMinBuilds] @spec_id, @plan_name, @prices_landed_effective_date;

    -- ============================================================
    -- Step 4: Collect winning price-level rows.
    --         Joins prices_landed → @MaxMinBuilds to restrict to one
    --         representative build per area/sub_area.  Applies the same
    --         exclusion guards used by the legacy Yukon proc:
    --           • sai.excluded <> 1  (spec_areas_items exclusion)
    --           • asa.exclude_quick_price_display = 0  (display flag)
    --           • Brick elevation filter (product 'B' special-case areas only)
    --           • EXISTS plan_material.bill_qty > 0  (build must have positive material)
    -- ============================================================
    DECLARE @price_levels TABLE
    (
        [build_id]          BIGINT,
        [application_id]    VARCHAR(10),
        [product_id]        VARCHAR(10),
        [area_id]           VARCHAR(10),
        [sub_area_id]       VARCHAR(10),
        [location_id]       INT,
        [price_level_type]  VARCHAR(50),
        [price_level_id]    VARCHAR(500),
        [price_level_name]  VARCHAR(500),
        [price]             DECIMAL(18,2),
        [application]       VARCHAR(50),
        [product]           VARCHAR(50),
        [area]              VARCHAR(250),
        [sub_area]          VARCHAR(250),
        [build_desc]        VARCHAR(100)
    );

    INSERT INTO @price_levels
    SELECT DISTINCT
        [pl].[build_id],
        [pl].[application_id],
        [pl].[product_id],
        [pl].[area_id],
        [pl].[sub_area_id],
        [pl].[location_id],
        [pl].[item_type]                                                              AS [price_level_type],
        [pl].[item]                                                                   AS [price_level_id],
        ISNULL([bs].[builder_style_name], [pl].[customer_item_name])                  AS [price_level_name],
        CEILING([pl].[price_retail] / 10.0) * 10                                      AS [price],
        LTRIM(RTRIM([ap].[name]))                                                     AS [application],
        LTRIM(RTRIM([pr].[name]))                                                     AS [product],
        [ar].[name]                                                                   AS [area],
        [sar].[name]                                                                  AS [sub_area],
        -- build_desc drives the area-label swap in Step 6.
        -- When group_walls is on, bath-tile areas (application_id='3', room_group 2/3) get a
        -- composite label; otherwise the selected build_desc is used directly.
        CASE @group_walls
            WHEN 1 THEN
                CASE
                    WHEN [pl].[application_id] = '3' AND [rg].[code] IN (2, 3) THEN [ar].[name] + ' Walls'
                    ELSE CASE @build_type
                             WHEN 'maximum' THEN [mmb].[max_build_desc]
                             WHEN 'minimum' THEN [mmb].[min_build_desc]
                             ELSE                [mmb].[std_build_desc]
                         END
                END
            ELSE
                CASE @build_type
                    WHEN 'maximum' THEN [mmb].[max_build_desc]
                    WHEN 'minimum' THEN [mmb].[min_build_desc]
                    ELSE                [mmb].[std_build_desc]
                END
        END                                                                           AS [build_desc]
    FROM
        [dbo].[prices_landed] [pl] WITH (NOLOCK)
        -- Restrict to the winning build per area; build selected per customer opt_pricing_build_type.
        JOIN @MaxMinBuilds [mmb]
            ON  CASE @build_type
                    WHEN 'maximum' THEN [mmb].[max_build_id]
                    WHEN 'minimum' THEN [mmb].[min_build_id]
                    ELSE                [mmb].[std_build_id]
                END                     = [pl].[build_id]
            AND [mmb].[application_id]  = [pl].[application_id]
            AND [mmb].[product_id]      = [pl].[product_id]
            AND [mmb].[area_id]         = [pl].[area_id]
            AND [mmb].[sub_area_id]     = [pl].[sub_area_id]
        JOIN [dbo].[plan_builds] [pb] WITH (NOLOCK)
            ON  [pb].[build_id] = [pl].[build_id]
            AND [pb].[plan_id]  = [pl].[plan_id]
        JOIN [dbo].[plan_mstr] [pm] WITH (NOLOCK)
            ON  [pm].[plan_id]  = [pb].[plan_id]
        JOIN [dbo].[areas] [ar] WITH (NOLOCK)
            ON  [ar].[area_id]  = [pl].[area_id]
        LEFT JOIN [dbo].[room_groups] [rg] WITH (NOLOCK)
            ON  [rg].[code]     = [ar].[room_group]
        JOIN [dbo].[sub_areas] [sar] WITH (NOLOCK)
            ON  [sar].[sub_area_id]   = [pl].[sub_area_id]
        JOIN [dbo].[applications] [ap] WITH (NOLOCK)
            ON  [ap].[application_id] = [pl].[application_id]
        JOIN [dbo].[products] [pr] WITH (NOLOCK)
            ON  [pr].[product_id]     = [pl].[product_id]
        LEFT JOIN [dbo].[areas_sub_areas] [asa] WITH (NOLOCK)
            ON  [asa].[area_id]     = [ar].[area_id]
            AND [asa].[sub_area_id] = [sar].[sub_area_id]
        LEFT JOIN [dbo].[spec_areas_items] [sai] WITH (NOLOCK)
            ON  [sai].[spec_id]         = [pm].[spec_id]
            AND [sai].[application_id]  = [pl].[application_id]
            AND [sai].[product_id]      = [pl].[product_id]
            AND [sai].[area_id]         = [pl].[area_id]
            AND [sai].[sub_area_id]     = [pl].[sub_area_id]
            AND ([sai].[location_id]    = [pl].[location_id] OR [sai].[location_id] = 0)
            AND [sai].[item_type]       = [pl].[item_type]
            AND [sai].[item]            = [pl].[item]
        LEFT JOIN [dbo].[builder_styles] [bs] WITH (NOLOCK)
            ON  [bs].[builder_id]       = @customer_id
            AND [bs].[spec_id]          = [pm].[spec_id]
            AND [bs].[item_type]        = [pl].[item_type]
            AND [bs].[item]             = [pl].[item]
            AND [bs].[effective_date]   = @prices_landed_effective_date
    WHERE
        [pl].[plan_id]              = @plan_id
        AND [pm].[spec_id]          = @spec_id
        AND [pl].[effective_date]   = @prices_landed_effective_date
        AND [pm].[active]           = 1
        AND ([pm].[end_date] IS NULL OR [pm].[end_date] > GETDATE())
        AND ISNULL([sai].[excluded], 0)                                         <> 1
        AND ([asa].[exclude_quick_price_display] = 0 OR [asa].[exclude_quick_price_display] IS NULL)
        -- Brick elevation: only show specific area names to avoid noise
        AND ([pr].[product_id] != 'B' OR ([pr].[product_id] = 'B' AND [ar].[name] IN ('Whole House', 'Sides and Rear', 'Front Elevation')))
        -- Require at least one positive-qty material row for this build (avoids phantom builds)
        AND EXISTS
        (
            SELECT 1
            FROM [dbo].[plan_material] [pbm] WITH (NOLOCK)
            WHERE [pbm].[plan_id]  = [pl].[plan_id]
              AND [pbm].[build_id] = [pl].[build_id]
              AND [pbm].[bill_qty] > 0
        );

    -- ============================================================
    -- Step 5: Bath tile sub_area grouping.
    --         Only applied when the customer has group_walls = 1.
    --         Tile items in bath-room areas (room_group 2/3) collapse
    --         into a single "Tile Walls" sub_area per the legacy Yukon proc pattern.
    -- ============================================================
    IF @group_walls = 1
    BEGIN
        UPDATE [lv]
        SET
            [sub_area]    = CASE WHEN [lv].[application_id] = '3' AND [rg].[code] IN (2, 3) THEN 'Tile Walls' ELSE [lv].[sub_area] END,
            [sub_area_id] = CASE WHEN [lv].[application_id] = '3' AND [rg].[code] IN (2, 3) THEN 'TW'         ELSE [lv].[sub_area_id] END
        FROM
            @price_levels [lv]
            LEFT JOIN [dbo].[areas]       [ar] WITH (NOLOCK) ON [ar].[area_id] = [lv].[area_id]
            LEFT JOIN [dbo].[room_groups] [rg] WITH (NOLOCK) ON [rg].[code]   = [ar].[room_group];
    END

    -- Estimating can assign multiple location_ids to the same bath area/sub_area.
    -- Collapse them to the minimum location_id per group so downstream grouping works correctly.
    UPDATE [lv]
    SET    [location_id] = [canonical].[location_id]
    FROM   @price_levels [lv]
    JOIN
    (
        SELECT [area], [sub_area], MIN([location_id]) AS [location_id]
        FROM   @price_levels
        WHERE  [application_id] = '3'
        GROUP BY [area], [sub_area]
        HAVING COUNT(DISTINCT [location_id]) > 1
    ) [canonical]
        ON  [canonical].[area]     = [lv].[area]
        AND [canonical].[sub_area] = [lv].[sub_area]
    WHERE [lv].[application_id] = '3';

    -- Swap area label with build_desc when present (e.g. "Master Bath — 9×12" replaces area name)
    UPDATE @price_levels
    SET
        [area]     = ISNULL([build_desc], [area]),
        [sub_area] = CASE WHEN [build_desc] IS NOT NULL THEN '' ELSE [sub_area] END;

    -- ============================================================
    -- Step 6: Resolve individual color parts via 4-path spec_items traversal.
    --         All 4 paths join @price_levels so each color row carries the
    --         area/price context of its winning build.
    --         Uses native Echelon tables — no wbs_* or Veo_* synonyms.
    --
    --         Path 1: price_level_type = 'group', group_detail item_type = 'style'
    --                 group → styles_groups_detail (style) → styles → colors
    --         Path 2: price_level_type = 'group', group_detail item_type = 'color'
    --                 group → styles_groups_detail (color) → colors
    --         Path 3: price_level_type = 'style'
    --                 spec_items (style) → colors (product_id + style_id)
    --         Path 4: price_level_type = 'color'
    --                 spec_items (color) → colors (part_no direct match)
    -- ============================================================

    -- PATH 1: group → sgd (style) → styles → colors
    SELECT DISTINCT
        'estimated'                                                                   AS [source_type],
        CASE
            WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                THEN [cco].[color_private_label]
            ELSE [c].[color]
        END                                                                           AS [name],
        [pl].[application],
        [pl].[product],
        [pl].[area],
        [pl].[sub_area],
        [pl].[price],
        SUBSTRING([pl].[price_level_name], 1, 1000)                                   AS [price_level],
        [c].[part_no],
        NULL                                                                          AS [item_no],
        TRY_CAST([c].[global_product_id] AS UNIQUEIDENTIFIER)                         AS [gpc_id],
        [pl].[build_id]
    FROM
        @price_levels [pl]
        JOIN [dbo].[spec_items] [si] WITH (NOLOCK)
            ON  [si].[spec_id]          = @spec_id
            AND [si].[item_type]        = [pl].[price_level_type]
            AND [si].[item]             = [pl].[price_level_id]
            AND [si].[application_id]   = [pl].[application_id]
            AND [si].[product_id]       = [pl].[product_id]
        LEFT JOIN [dbo].[styles_groups] [sg] WITH (NOLOCK)
            ON  [sg].[group_id]         = [si].[item]
            AND [sg].[application_id]   = [si].[application_id]
            AND [sg].[product_id]       = [si].[product_id]
        LEFT JOIN [dbo].[styles_groups_detail] [sgd] WITH (NOLOCK)
            ON  [sgd].[group_id]        = [sg].[group_id]
            AND [sgd].[customer_id]     = @customer_id
            AND [sgd].[item_type]       = 'style'
            AND ([sgd].[effective_date] <= @prices_landed_effective_date OR [sgd].[effective_date] IS NULL)
            AND ([sgd].[end_date]       >= @prices_landed_effective_date OR [sgd].[end_date] IS NULL)
        LEFT JOIN [dbo].[styles] [s] WITH (NOLOCK)
            ON  [s].[product_id]    = [sg].[product_id]
            AND [s].[style_id]      = [sgd].[item]
        LEFT JOIN [dbo].[colors] [c] WITH (NOLOCK)
            ON  [c].[product_id]    = [s].[product_id]
            AND [c].[style_id]      = [s].[style_id]
        LEFT JOIN [dbo].[colors_customer_overrides] [cco] WITH (NOLOCK)
            ON  [cco].[part_no]     = [c].[part_no]
            AND [cco].[customer_id] = @customer_id
        LEFT JOIN [dbo].[stocking_codes] [sc] WITH (NOLOCK)
            ON  [sc].[code]         = [c].[stocking_code]
    WHERE
        [pl].[price_level_type]         = 'group'
        AND [sc].[homebuyer_selectable] = 1
        AND [c].[part_no] IS NOT NULL
        AND
        (
            CASE WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                 THEN [cco].[color_private_label] ELSE [c].[color] END
            LIKE '%' + ISNULL(@search_term, '') + '%'
            OR [c].[part_no] LIKE '%' + ISNULL(@search_term, '') + '%'
        )

    UNION ALL

    -- PATH 2: group → sgd (color) → colors
    SELECT DISTINCT
        'estimated'                                                                   AS [source_type],
        CASE
            WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                THEN [cco].[color_private_label]
            ELSE [c].[color]
        END                                                                           AS [name],
        [pl].[application],
        [pl].[product],
        [pl].[area],
        [pl].[sub_area],
        [pl].[price],
        SUBSTRING([pl].[price_level_name], 1, 1000)                                   AS [price_level],
        [c].[part_no],
        NULL                                                                          AS [item_no],
        TRY_CAST([c].[global_product_id] AS UNIQUEIDENTIFIER)                         AS [gpc_id],
        [pl].[build_id]
    FROM
        @price_levels [pl]
        JOIN [dbo].[spec_items] [si] WITH (NOLOCK)
            ON  [si].[spec_id]          = @spec_id
            AND [si].[item_type]        = [pl].[price_level_type]
            AND [si].[item]             = [pl].[price_level_id]
            AND [si].[application_id]   = [pl].[application_id]
            AND [si].[product_id]       = [pl].[product_id]
        LEFT JOIN [dbo].[styles_groups] [sg] WITH (NOLOCK)
            ON  [sg].[group_id]         = [si].[item]
            AND [sg].[application_id]   = [si].[application_id]
            AND [sg].[product_id]       = [si].[product_id]
        LEFT JOIN [dbo].[styles_groups_detail] [sgd] WITH (NOLOCK)
            ON  [sgd].[group_id]        = [sg].[group_id]
            AND [sgd].[customer_id]     = @customer_id
            AND [sgd].[item_type]       = 'color'
            AND ([sgd].[effective_date] <= @prices_landed_effective_date OR [sgd].[effective_date] IS NULL)
            AND ([sgd].[end_date]       >= @prices_landed_effective_date OR [sgd].[end_date] IS NULL)
        LEFT JOIN [dbo].[colors] [c] WITH (NOLOCK)
            ON  [c].[part_no]           = [sgd].[item]
        LEFT JOIN [dbo].[colors_customer_overrides] [cco] WITH (NOLOCK)
            ON  [cco].[part_no]         = [c].[part_no]
            AND [cco].[customer_id]     = @customer_id
        LEFT JOIN [dbo].[stocking_codes] [sc] WITH (NOLOCK)
            ON  [sc].[code]             = [c].[stocking_code]
    WHERE
        [pl].[price_level_type]         = 'group'
        AND [sc].[homebuyer_selectable] = 1
        AND [c].[part_no] IS NOT NULL
        AND
        (
            CASE WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                 THEN [cco].[color_private_label] ELSE [c].[color] END
            LIKE '%' + ISNULL(@search_term, '') + '%'
            OR [c].[part_no] LIKE '%' + ISNULL(@search_term, '') + '%'
        )

    UNION ALL

    -- PATH 3: spec_items (style) → colors via product_id + style_id
    SELECT DISTINCT
        'estimated'                                                                   AS [source_type],
        CASE
            WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                THEN [cco].[color_private_label]
            ELSE [c].[color]
        END                                                                           AS [name],
        [pl].[application],
        [pl].[product],
        [pl].[area],
        [pl].[sub_area],
        [pl].[price],
        SUBSTRING([pl].[price_level_name], 1, 1000)                                   AS [price_level],
        [c].[part_no],
        NULL                                                                          AS [item_no],
        TRY_CAST([c].[global_product_id] AS UNIQUEIDENTIFIER)                         AS [gpc_id],
        [pl].[build_id]
    FROM
        @price_levels [pl]
        JOIN [dbo].[spec_items] [si] WITH (NOLOCK)
            ON  [si].[spec_id]          = @spec_id
            AND [si].[item_type]        = [pl].[price_level_type]
            AND [si].[item]             = [pl].[price_level_id]
            AND [si].[application_id]   = [pl].[application_id]
            AND [si].[product_id]       = [pl].[product_id]
        LEFT JOIN [dbo].[colors] [c] WITH (NOLOCK)
            ON  [c].[product_id]        = [si].[product_id]
            AND [c].[style_id]          = [si].[item]
        LEFT JOIN [dbo].[colors_customer_overrides] [cco] WITH (NOLOCK)
            ON  [cco].[part_no]         = [c].[part_no]
            AND [cco].[customer_id]     = @customer_id
        LEFT JOIN [dbo].[stocking_codes] [sc] WITH (NOLOCK)
            ON  [sc].[code]             = [c].[stocking_code]
    WHERE
        [pl].[price_level_type]         = 'style'
        AND [sc].[homebuyer_selectable] = 1
        AND [c].[part_no] IS NOT NULL
        AND
        (
            CASE WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                 THEN [cco].[color_private_label] ELSE [c].[color] END
            LIKE '%' + ISNULL(@search_term, '') + '%'
            OR [c].[part_no] LIKE '%' + ISNULL(@search_term, '') + '%'
        )

    UNION ALL

    -- PATH 4: spec_items (color) → colors via direct part_no match
    SELECT DISTINCT
        'estimated'                                                                   AS [source_type],
        CASE
            WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                THEN [cco].[color_private_label]
            ELSE [c].[color]
        END                                                                           AS [name],
        [pl].[application],
        [pl].[product],
        [pl].[area],
        [pl].[sub_area],
        [pl].[price],
        SUBSTRING([pl].[price_level_name], 1, 1000)                                   AS [price_level],
        [c].[part_no],
        NULL                                                                          AS [item_no],
        TRY_CAST([c].[global_product_id] AS UNIQUEIDENTIFIER)                         AS [gpc_id],
        [pl].[build_id]
    FROM
        @price_levels [pl]
        JOIN [dbo].[spec_items] [si] WITH (NOLOCK)
            ON  [si].[spec_id]          = @spec_id
            AND [si].[item_type]        = [pl].[price_level_type]
            AND [si].[item]             = [pl].[price_level_id]
            AND [si].[application_id]   = [pl].[application_id]
            AND [si].[product_id]       = [pl].[product_id]
        LEFT JOIN [dbo].[colors] [c] WITH (NOLOCK)
            ON  [c].[part_no]           = [si].[item]
        LEFT JOIN [dbo].[colors_customer_overrides] [cco] WITH (NOLOCK)
            ON  [cco].[part_no]         = [c].[part_no]
            AND [cco].[customer_id]     = @customer_id
        LEFT JOIN [dbo].[stocking_codes] [sc] WITH (NOLOCK)
            ON  [sc].[code]             = [c].[stocking_code]
    WHERE
        [pl].[price_level_type]         = 'color'
        AND [sc].[homebuyer_selectable] = 1
        AND [c].[part_no] IS NOT NULL
        AND
        (
            CASE WHEN @builder_overrides_enabled = 1 AND DATALENGTH([cco].[color_private_label]) > 0
                 THEN [cco].[color_private_label] ELSE [c].[color] END
            LIKE '%' + ISNULL(@search_term, '') + '%'
            OR [c].[part_no] LIKE '%' + ISNULL(@search_term, '') + '%'
        )

    ORDER BY
        [area], [sub_area], [application], [product], [name];

END
GO
