declare 
	@security_token            UNIQUEIDENTIFIER,
	/*
	STAGGERED-QA
	@account_id                UNIQUEIDENTIFIER = 'BAB32B7E-3ADA-497C-862E-E5083971CC59',
	@organization_id           UNIQUEIDENTIFIER = '8AAECC3A-2D9E-4500-B0CF-D79D947D33A7',
	@community_name            VARCHAR(100) = 'Lakes of Pine Forest',
	@series_name               VARCHAR(100) = 'Series 1',
	@plan_name                 VARCHAR(100) = 'Aransas',
	*/
	/* 
	NON-STAGGERED - QA
	*/
	@account_id                UNIQUEIDENTIFIER = '1EEAA9A3-CD2A-43B2-A727-37F5ACBCB7AC',
	@organization_id           UNIQUEIDENTIFIER = '49687F1F-DEC8-484D-B7C3-C193DA7C873D',
	@community_name            VARCHAR(100) = 'LAKES IN BAY COLONY',
	@series_name               VARCHAR(100) = 'Royce (101)',
	@plan_name                 VARCHAR(100) = 'Bastrop',
	@base_plan_name            VARCHAR(100)     = NULL,
	@search_term               VARCHAR(250)     = NULL,
	@builder_overrides_enabled BIT              = 0;
	
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
    select * from communities
	/*SELECT 
        sm.spec_id, pm.plan_id, p.effective_date
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
		p.[effective_date] DESC*/

    select @account_id, @organization_id, @active_spec_id, @plan_id, @prices_landed_effective_date

	IF @account_id IS NULL OR @organization_id IS NULL OR @active_spec_id IS NULL OR @plan_id IS NULL OR @prices_landed_effective_date IS NULL
		RETURN