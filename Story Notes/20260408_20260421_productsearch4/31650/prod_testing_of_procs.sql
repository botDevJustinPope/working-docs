/*
I want to create a script that tests the execution time of a stored procedure in SQL Server.
*/
declare @securityToken UNIQUEIDENTIFIER = '01234567-89AB-CDEF-0000-123456789ABC';

-- search terms to test for the stored procedure
declare @search_terms table (term VARCHAR(250))
insert into @search_terms (term) 
values ('white'), 
       ('black'), 
       ('blue'),
       ('Maple'),
       ('Maple Square'),
       ('American Plan'),
       ('Crema Classico'),
       ('Granite'),
       ('Brookstone'),
       ('Marble');

declare @customer_aocsp table (
    DB_stack VARCHAR(50),
    OrganizationName VARCHAR(250),
    AccountID UNIQUEIDENTIFIER,
    OrganizationID UNIQUEIDENTIFIER,
    CommunityID UNIQUEIDENTIFIER,
    CommunityName VARCHAR(250),
    SeriesID UNIQUEIDENTIFIER,
    SeriesName VARCHAR(250),
    PlanID UNIQUEIDENTIFIER,
    PlanName VARCHAR(250),
    number_of_profile_plans int,
    external_customer_id varchar(50) null,
    spec_id int null,
    plan_id int null,
    effectiveDate datetime null
)
insert into @customer_aocsp (DB_stack, OrganizationName, AccountID, OrganizationID, CommunityID, CommunityName, SeriesID, SeriesName, PlanID, PlanName, number_of_profile_plans)
select 
    'VEOSolutions' as [DB_stack],
    o.[name] as [OrganizationName], 
    ao.account_id as [AccountID], 
    ao.organization_id as [OrganizationID], 
    aocsp.community_id as [CommunityID], 
    aoc.[name] as [CommunityName], 
    aocsp.series_id as [SeriesID], 
    aos.[name] as [SeriesName], 
    aocsp.plan_id as [PlanID], 
    aop.[name] as [PlanName],
    profile_plans.[number] as [number_of_profile_plans]
from [VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organizations] as ao 
inner join [VEOSolutions].[dbo].[vss_organizations] as o on o.organization_id = ao.organization_id
inner join [VEOSolutions].[dbo].[VeoSolutionsSecurity_account_org_community_series_plan] as aocsp on aocsp.organization_id = ao.organization_id
                                                                                             and aocsp.account_id = ao.account_id
                                                                                             and aocsp.is_archived = 0
inner join [VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_communities] as aoc on aoc.organization_id = ao.organization_id
                                                                                             and aoc.account_id = ao.account_id
                                                                                             and aoc.community_id = aocsp.community_id
                                                                                             and aoc.archive = 0
inner join [VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_series] as aos on aos.organization_id = ao.organization_id
                                                                                             and aos.account_id = ao.account_id
                                                                                              and aos.series_id = aocsp.series_id
                                                                                              and aos.archive = 0
inner join [VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_plans] as aop on aop.organization_id = ao.organization_id
                                                                                             and aop.account_id = ao.account_id 
                                                                                             and aop.plan_id = aocsp.plan_id
                                                                                             and aop.archive = 0
outer apply (
    select 
    count(*) as [number]
    from [VeoSolutions].[dbo].[account_organization_user_profile_plan] as aoupp
    where aoupp.organization_id = ao.organization_id
      and aoupp.account_id = ao.account_id
      and aoupp.community_name = aoc.[name]
      and aoupp.series = aos.[name]
      and aoupp.plan_name = aop.[name]
) as profile_plans
/*
-- EPLAN
UNION ALL
select 
    'EPLAN_VEOSolutions' as [DB_stack],
    o.[name] as [OrganizationName], 
    ao.account_id as [AccountID], 
    ao.organization_id as [OrganizationID], 
    aocsp.community_id as [CommunityID], 
    aoc.[name] as [CommunityName], 
    aocsp.series_id as [SeriesID], 
    aos.[name] as [SeriesName], 
    aocsp.plan_id as [PlanID], 
    aop.[name] as [PlanName],
    profile_plans.[number] as [number_of_profile_plans]
from [EPLAN_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organizations] as ao 
inner join [EPLAN_VEOSolutions].[dbo].[vss_organizations] as o on o.organization_id = ao.organization_id
inner join [EPLAN_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_org_community_series_plan] as aocsp on aocsp.organization_id = ao.organization_id
                                                                                             and aocsp.account_id = ao.account_id
                                                                                             and aocsp.is_archived = 0
inner join [EPLAN_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_communities] as aoc on aoc.organization_id = ao.organization_id
                                                                                             and aoc.account_id = ao.account_id
                                                                                             and aoc.community_id = aocsp.community_id
                                                                                             and aoc.archive = 0
inner join [EPLAN_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_series] as aos on aos.organization_id = ao.organization_id
                                                                                             and aos.account_id = ao.account_id
                                                                                              and aos.series_id = aocsp.series_id
                                                                                              and aos.archive = 0
inner join [EPLAN_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_plans] as aop on aop.organization_id = ao.organization_id
                                                                                             and aop.account_id = ao.account_id 
                                                                                             and aop.plan_id = aocsp.plan_id
                                                                                             and aop.archive = 0
outer apply (
    select 
    count(*) as [number]
    from [EPLAN_VEOSolutions].[dbo].[account_organization_user_profile_plan] as aoupp
    where aoupp.organization_id = ao.organization_id
      and aoupp.account_id = ao.account_id
      and aoupp.community_name = aoc.[name]
      and aoupp.series = aos.[name]
      and aoupp.plan_name = aop.[name]
) as profile_plans
-- CCDI
UNION ALL
select 
    'CCDI_VEOSolutions' as [DB_stack],
    o.[name] as [OrganizationName], 
    ao.account_id as [AccountID], 
    ao.organization_id as [OrganizationID], 
    aocsp.community_id as [CommunityID], 
    aoc.[name] as [CommunityName], 
    aocsp.series_id as [SeriesID], 
    aos.[name] as [SeriesName], 
    aocsp.plan_id as [PlanID], 
    aop.[name] as [PlanName],
    profile_plans.[number] as [number_of_profile_plans]
from [CCDI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organizations] as ao 
inner join [CCDI_VEOSolutions].[dbo].[vss_organizations] as o on o.organization_id = ao.organization_id
inner join [CCDI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_org_community_series_plan] as aocsp on aocsp.organization_id = ao.organization_id
                                                                                             and aocsp.account_id = ao.account_id
                                                                                             and aocsp.is_archived = 0
inner join [CCDI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_communities] as aoc on aoc.organization_id = ao.organization_id
                                                                                             and aoc.account_id = ao.account_id
                                                                                             and aoc.community_id = aocsp.community_id
                                                                                             and aoc.archive = 0
inner join [CCDI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_series] as aos on aos.organization_id = ao.organization_id
                                                                                             and aos.account_id = ao.account_id
                                                                                              and aos.series_id = aocsp.series_id
                                                                                              and aos.archive = 0
inner join [CCDI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_plans] as aop on aop.organization_id = ao.organization_id
                                                                                             and aop.account_id = ao.account_id 
                                                                                             and aop.plan_id = aocsp.plan_id
                                                                                             and aop.archive = 0
outer apply (
    select 
    count(*) as [number]
    from [CCDI_VEOSolutions].[dbo].[account_organization_user_profile_plan] as aoupp
    where aoupp.organization_id = ao.organization_id
      and aoupp.account_id = ao.account_id
      and aoupp.community_name = aoc.[name]
      and aoupp.series = aos.[name]
      and aoupp.plan_name = aop.[name]
) as profile_plans
-- AFI
UNION ALL
select 
    'AFI_VEOSolutions' as [DB_stack],
    o.[name] as [OrganizationName], 
    ao.account_id as [AccountID], 
    ao.organization_id as [OrganizationID], 
    aocsp.community_id as [CommunityID], 
    aoc.[name] as [CommunityName], 
    aocsp.series_id as [SeriesID], 
    aos.[name] as [SeriesName], 
    aocsp.plan_id as [PlanID], 
    aop.[name] as [PlanName],
    profile_plans.[number] as [number_of_profile_plans]
from [AFI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organizations] as ao 
inner join [AFI_VEOSolutions].[dbo].[vss_organizations] as o on o.organization_id = ao.organization_id
inner join [AFI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_org_community_series_plan] as aocsp on aocsp.organization_id = ao.organization_id
                                                                                             and aocsp.account_id = ao.account_id
                                                                                             and aocsp.is_archived = 0
inner join [AFI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_communities] as aoc on aoc.organization_id = ao.organization_id
                                                                                             and aoc.account_id = ao.account_id
                                                                                             and aoc.community_id = aocsp.community_id
                                                                                             and aoc.archive = 0
inner join [AFI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_series] as aos on aos.organization_id = ao.organization_id
                                                                                             and aos.account_id = ao.account_id
                                                                                              and aos.series_id = aocsp.series_id
                                                                                              and aos.archive = 0
inner join [AFI_VEOSolutions].[dbo].[VeoSolutionsSecurity_account_organization_plans] as aop on aop.organization_id = ao.organization_id
                                                                                             and aop.account_id = ao.account_id 
                                                                                             and aop.plan_id = aocsp.plan_id
                                                                                             and aop.archive = 0
outer apply (
    select 
    count(*) as [number]
    from [AFI_VEOSolutions].[dbo].[account_organization_user_profile_plan] as aoupp
    where aoupp.organization_id = ao.organization_id
      and aoupp.account_id = ao.account_id
      and aoupp.community_name = aoc.[name]
      and aoupp.series = aos.[name]
      and aoupp.plan_name = aop.[name]
) as profile_plans;*/

select count(*) from @customer_aocsp;

;WITH RankedPlans AS
(
    SELECT
        c.DB_stack,
        c.OrganizationName,
        c.AccountID,
        c.OrganizationID,
        c.CommunityID,
        c.CommunityName,
        c.SeriesID,
        c.SeriesName,
        c.PlanID,
        c.PlanName,
        c.number_of_profile_plans,
        c.external_customer_id,
        c.spec_id,
        c.plan_id,
        c.effectiveDate,
        ROW_NUMBER() OVER
        (
            PARTITION BY c.DB_stack, c.OrganizationID, c.AccountID
            ORDER BY c.number_of_profile_plans DESC, c.PlanName ASC
        ) AS rn
    FROM @customer_aocsp AS c
)

delete c1
from @customer_aocsp c1 
left join (
    SELECT
        DB_stack,
        OrganizationName,
        AccountID,
        OrganizationID,
        CommunityID,
        CommunityName,
        SeriesID,
        SeriesName,
        PlanID,
        PlanName,
        number_of_profile_plans,
        external_customer_id,
        spec_id,
        plan_id,
        effectiveDate,
        rn
    FROM RankedPlans ) as top_profiles on c1.DB_stack = top_profiles.DB_stack
                                                                    and c1.OrganizationID = top_profiles.OrganizationID
                                                                    and c1.AccountID = top_profiles.AccountID
                                                                    and c1.CommunityID = top_profiles.CommunityID
                                                                    and c1.SeriesID = top_profiles.SeriesID
                                                                    and c1.PlanID = top_profiles.PlanID
where rn > 5;


/*
declare @account_id UNIQUEIDENTIFIER,
        @organization_id UNIQUEIDENTIFIER,
        @community_name VARCHAR(250),
        @series_name VARCHAR(250),
        @plan_name VARCHAR(250);
    
DECLARE @proc_result TABLE
(
    spec_id INT,
    plan_id INT,
    effectiveDate DATETIME,
    external_customer_id VARCHAR(50)
);

declare resovle_spec cursor local FAST_FORWARD for 
select AccountID, OrganizationID, CommunityName, SeriesName, PlanName from @customer_aocsp

open resovle_spec

fetch next from resovle_spec into @account_id, @organization_id, @community_name, @series_name, @plan_name

while @@FETCH_STATUS = 0
BEGIN 
    print 'Processing AccountID: ' + CAST(@account_id AS VARCHAR(50)) + ', OrganizationID: ' + CAST(@organization_id AS VARCHAR(50)) + ', CommunityName: ' + @community_name + ', SeriesName: ' + @series_name + ', PlanName: ' + @plan_name;

    -- execute the stored procedure and capture the external_customer_id, spec_id, plan_id, and effectiveDate
    declare @external_customer_id varchar(50),
            @spec_id int,
            @plan_id int,
            @effectiveDate datetime;

    insert into @proc_result (external_customer_id, spec_id, plan_id, effectiveDate)
    exec [VeoSolutions].[dbo].[vds_selEchelonCustomerResolutionWithTenantPlan]
        @securityToken,
        @account_id,
        @organization_id,
        @community_name,
        @series_name,
        @plan_name;

    update c 
    set c.external_customer_id = pr.external_customer_id,
        c.spec_id = pr.spec_id,
        c.plan_id = pr.plan_id,
        c.effectiveDate = pr.effectiveDate
    from @customer_aocsp c
    inner join @proc_result pr on 1=1
    where c.AccountID = @account_id
      and c.OrganizationID = @organization_id
      and c.CommunityName = @community_name
      and c.SeriesName = @series_name
      and c.PlanName = @plan_name;

    fetch next from resovle_spec into @account_id, @organization_id, @community_name, @series_name, @plan_name
END
close resovle_spec
deallocate resovle_spec
*/

select * from @customer_aocsp