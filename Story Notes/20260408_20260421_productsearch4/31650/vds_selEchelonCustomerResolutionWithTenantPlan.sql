CREATE PROCEDURE [dbo].[vds_selEchelonCustomerResolutionWithTenantPlan]
	@security_token  UNIQUEIDENTIFIER,
	@account_id      UNIQUEIDENTIFIER,
	@organization_id UNIQUEIDENTIFIER,
	@community_name  VARCHAR(100),
	@series_name     VARCHAR(100),
	@plan_name       VARCHAR(100)
AS
/*
	Author:      Justin Pope
	Create date: 4/16/2026
	Description: Resolves the Echelon/WBS context (spec, plan, effective date, external org) for a given 
				 VDS account + community + series + plan combination. Used by Track 2 of story #31650 to 
				 separate Phase 1 resolution (VeoSolutions-side) from the Echelon-native search proc 
				 (Echelon-side). Returns an empty result set when no match is found.
*/
BEGIN
	IF ([dbo].[vdsf_isValidSecurityToken](@security_token) = 0)
	BEGIN
		RAISERROR('Access Denied.', 16, 1)
		RETURN
	END

	SET NOCOUNT ON

	DECLARE @effective_date DATETIME = GETDATE()

	DECLARE @external_org_id VARCHAR(50)

	SELECT @external_org_id = vso.[external_organization_id]
	FROM   [VeoSolutionsSecurity_organizations] vso
		INNER JOIN [VeoSolutionsSecurity_account_organizations] vsao ON vsao.[organization_id] = vso.[organization_id]
	WHERE  vso.[organization_id] = @organization_id
		AND vsao.[account_id] = @account_id

	;WITH communities
	AS
	(
		SELECT
			vsm.[spec_id],
			vsm.[start_date],
			vc.[community_id],
			vc.[name] AS [community_name]
		FROM
			[Veo_spec_communities] vsc
			JOIN [Veo_spec_mstr] vsm ON vsm.[spec_id] = vsc.[spec_id]
			JOIN [Veo_communities] vc ON vc.[community_id] = vsc.[community_id]
			JOIN (
				-- Fetch VDS community names (builder names)
				SELECT
					aoc.[name] AS [community_name]
				FROM
					[VeoSolutionsSecurity_account_organization_communities] aoc
				WHERE
					aoc.[account_id]      = @account_id
					AND aoc.[organization_id] = @organization_id
					AND aoc.[name]            = @community_name

				UNION

				-- Fetch mapped community names (Wisenbaker names)
				SELECT
					aocm.[mapped_name] AS [community_name]
				FROM
					[VeoSolutionsSecurity_account_organization_communities] aoc
					JOIN [VeoSolutionsSecurity_account_organization_communities_mappings] aocm
						ON  aocm.[account_id]      = aoc.[account_id]
						AND aocm.[organization_id] = aoc.[organization_id]
						AND aocm.[community_id]    = aoc.[community_id]
				WHERE
					aoc.[account_id]      = @account_id
					AND aoc.[organization_id] = @organization_id
					AND aoc.[name]            = @community_name
				) vss_c ON vss_c.[community_name] = vc.[name]
		WHERE
			vsm.[builder_id]  = @external_org_id
			AND vsm.[start_date]  <= @effective_date
			AND (vsm.[end_date]   >= @effective_date OR vsm.[end_date] IS NULL)
			AND vsm.[active]      = 1
	),
	series
	AS
	(
		SELECT
			vsm.[spec_id],
			vsm.[start_date],
			vss.[series] AS [series_name]
		FROM
			[Veo_spec_series] vss
			JOIN [Veo_spec_mstr] vsm ON vsm.[spec_id] = vss.[spec_id]
			JOIN (
				-- Fetch VDS series names (builder names)
				SELECT
					aos.[name] AS [series_name]
				FROM
					[VeoSolutionsSecurity_account_organization_series] aos
				WHERE
					aos.[account_id]      = @account_id
					AND aos.[organization_id] = @organization_id
					AND aos.[name]            = @series_name

				UNION

				-- Fetch mapped series names (Wisenbaker names)
				SELECT
					aosm.[mapped_name] AS [series_name]
				FROM
					[VeoSolutionsSecurity_account_organization_series] aos
					JOIN [VeoSolutionsSecurity_account_organization_series_mappings] aosm
						ON  aosm.[account_id]      = aos.[account_id]
						AND aosm.[organization_id] = aos.[organization_id]
						AND aosm.[series_id]       = aos.[series_id]
				WHERE
					aos.[account_id]      = @account_id
					AND aos.[organization_id] = @organization_id
					AND aos.[name]            = @series_name
				) vss_s ON vss_s.[series_name] = vss.[series]
		WHERE
			vsm.[builder_id]  = @external_org_id
			AND vsm.[start_date]  <= @effective_date
			AND (vsm.[end_date]   >= @effective_date OR vsm.[end_date] IS NULL)
			AND vsm.[active]      = 1
	),
	plans
	AS
	(
		SELECT
			vsm.[spec_id],
			vsm.[start_date],
			vpm.[plan_id],
			vpm.[plan_name]
		FROM
			[Veo_plan_mstr] vpm
			JOIN [Veo_spec_mstr] vsm ON vsm.[spec_id] = vpm.[spec_id]
			JOIN (
				-- Fetch VDS plan names (builder names)
				SELECT
					aop.[name] AS [plans_name]
				FROM
					[VeoSolutionsSecurity_account_organization_plans] aop
				WHERE
					aop.[account_id]      = @account_id
					AND aop.[organization_id] = @organization_id
					AND aop.[name]            = @plan_name

				UNION

				-- Fetch mapped plan names (Wisenbaker names)
				SELECT
					aopm.[mapped_name] AS [plans_name]
				FROM
					[VeoSolutionsSecurity_account_organization_plans] aop
					LEFT JOIN [VeoSolutionsSecurity_account_organization_plans_mappings] aopm
						ON  aopm.[account_id]      = aop.[account_id]
						AND aopm.[organization_id] = aop.[organization_id]
						AND aopm.[plan_id]         = aop.[plan_id]
				WHERE
					aop.[account_id]      = @account_id
					AND aop.[organization_id] = @organization_id
					AND aop.[name]            = @plan_name
				) vss_p ON vss_p.[plans_name] = vpm.[plan_name]
		WHERE
			vsm.[builder_id]  = @external_org_id
			AND vsm.[start_date]  <= @effective_date
			AND (vsm.[end_date]   >= @effective_date OR vsm.[end_date] IS NULL)
			AND vsm.[active]      = 1
			AND (vpm.[end_date]   >= @effective_date OR vpm.[end_date] IS NULL)
			AND vpm.[active]      = 1
	)
	SELECT TOP 1
		sm.[spec_id]          AS [spec_id],
		pm.[plan_id]          AS [plan_id],
		p.[effective_date]    AS [effective_date],
		@external_org_id      AS [external_org_id]
	FROM
		[veo_spec_mstr]      sm
		JOIN [Veo_spec_communities] sc    ON sc.[spec_id]        = sm.[spec_id]
		JOIN [communities]          cte_c ON cte_c.[community_id] = sc.[community_id]
		                                 AND cte_c.[spec_id]       = sm.[spec_id]
		JOIN [veo_spec_series]      ss    ON ss.[spec_id]        = sm.[spec_id]
		JOIN [series]               cte_s ON cte_s.[series_name] = ss.[series]
		                                 AND cte_s.[spec_id]      = sm.[spec_id]
		JOIN [Veo_plan_mstr]        pm    ON pm.[spec_id]         = sm.[spec_id]
		JOIN [plans]                cte_p ON cte_p.[plan_id]      = pm.[plan_id]
		                                 AND cte_p.[spec_id]      = sm.[spec_id]
		JOIN [Veo_pricesets]        p     ON p.[spec_id]          = sm.[spec_id]
	WHERE
		sm.[builder_id]        = @external_org_id
		AND sm.[active]        = 1
		AND (sm.[end_date] IS NULL OR sm.[end_date] >= CONVERT(DATE, @effective_date))
		AND p.[active]         = 1
		AND p.[effective_date] <= @effective_date
	ORDER BY
		p.[effective_date] DESC

END
