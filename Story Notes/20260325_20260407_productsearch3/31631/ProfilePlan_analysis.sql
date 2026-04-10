declare @profile_plan_elements table (
    [account_id] uniqueidentifier,
    [organization_id] uniqueidentifier,
    [organization_name] varchar(250),
    [community_name] varchar(250),
    [community_id] uniqueidentifier,
    [series_name] varchar(250),
    [series_id] uniqueidentifier,
    [plan_name] varchar(250),
    [plan_id] uniqueidentifier,
    [tenant_plan_id] uniqueidentifier
);
insert into @profile_plan_elements
select 
    pp_grouped.account_id,
    pp_grouped.organization_id,
    pp_grouped.organization_name,
    pp_grouped.community_name,
    [communities].community_id,
    pp_grouped.[series_name],
    [series].[series_id],
    pp_grouped.[plan_name],
    [plans].[plan_id],
    [tenant_plan].[tenant_plan_id]
from (
    select 
        vss_ao.account_id,
        vss_ao.organization_id,
        vss_o.[name] as organization_name,
        pp.[community_name] as [community_name],
        pp.[series] as [series_name],
        pp.[plan_name] as [plan_name]
    from [dbo].[account_organization_user_profile_plan] pp
        inner join [vss_organizations] vss_o on vss_o.organization_id = pp.organization_id
        inner join [dbo].[VeoSolutionsSecurity_account_organizations] vss_ao on vss_ao.organization_id = pp.organization_id
            and vss_ao.account_id = pp.account_id
    group by vss_ao.account_id, vss_ao.organization_id, vss_o.[name], pp.[community_name], pp.[series], pp.[plan_name]
) pp_grouped
outer apply (
    select c.[community_id]
    from [dbo].[VeoSolutionsSecurity_account_organization_communities] c
    where c.account_id = pp_grouped.account_id
        and c.organization_id = pp_grouped.organization_id
        and c.[name] = LTRIM(RTRIM(pp_grouped.community_name))
) [communities]
outer apply (
    select s.[series_id]
    from [dbo].[VeoSolutionsSecurity_account_organization_series] s
    where s.account_id = pp_grouped.account_id
        and s.organization_id = pp_grouped.organization_id
        and s.[name] = LTRIM(RTRIM(pp_grouped.series_name))
) [series]
outer apply (
    select p.[plan_id]
    from [dbo].[VeoSolutionsSecurity_account_organization_plans] p
    where p.account_id = pp_grouped.account_id
        and p.organization_id = pp_grouped.organization_id
        and p.[name] = LTRIM(RTRIM(pp_grouped.plan_name))
) [plans]
outer apply (
    select t.[id] as [tenant_plan_id]
    from [dbo].[VeoSolutionsSecurity_account_org_community_series_plan] t
    where t.[account_id] = pp_grouped.account_id
        and t.[organization_id] = pp_grouped.organization_id
        and t.[community_id] = communities.community_id
        and t.[series_id] = series.series_id
        and t.[plan_id] = plans.plan_id
) [tenant_plan];

-- Duplicate communitites
select distinct 
    ppe.account_id,
    ppe.organization_id,
    ppe.community_name,
    ppe.community_id,
    case when ppe.tenant_plan_id is not null then 'Yes' else 'No' end as [is_apart_of_tenant_plan]
from @profile_plan_elements ppe
cross apply (
    select 1 as [found_duplicate]
    from @profile_plan_elements c_ppe
    where c_ppe.account_id = ppe.account_id
        and c_ppe.organization_id = ppe.organization_id
        and c_ppe.community_name = ppe.community_name
        and c_ppe.community_id != ppe.community_id
) cross_check

-- Duplicate series
select distinct 
    ppe.account_id,
    ppe.organization_id,
    ppe.series_name,
    ppe.series_id,
    case when ppe.tenant_plan_id is not null then 'Yes' else 'No' end as [is_part_of_tenant_plan]
from @profile_plan_elements ppe 
cross apply (
    select 1 as [found_duplicate]
    from @profile_plan_elements c_ppe
    where c_ppe.account_id = ppe.account_id
        and c_ppe.organization_id = ppe.organization_id
        and c_ppe.series_name = ppe.series_name
        and c_ppe.series_id != ppe.series_id
) cross_check

-- Duplicate plans
select distinct 
    ppe.account_id,
    ppe.organization_id,
    ppe.plan_name,
    ppe.plan_id,
    case when ppe.tenant_plan_id is not null then 'Yes' else 'No' end as [is_part_of_tenant_plan]
from @profile_plan_elements