declare @session_id uniqueidentifier = '4de6c539-1044-462c-bb42-ebcebf8a265b',
        @security_token uniqueidentifier = '01234567-89AB-CDEF-0000-123456789ABC';

select * from [dbo].[catalog_selections] cs
where cs.session_id = @session_id and 
cs.[row_id] in ('01978421-a44a-79e1-b54d-b5512d0eb547', '01978421-a44c-7050-9737-224e85778f13')

select * from [dbo].[catalog_selections] cs
where cs.session_id = @session_id and cs.[create_date] >= dateadd(day, -1, getdate())

--execute [dbo].[vds_selBuilds] @session_id, '', '', 'Cabinets', 0, 0, 0, @security_token;

/*
select * from [dbo].[catalog_selections]
where [item] like 'VCMS Test Kitchen Package 1Description%' and session_id = @session_id

select * from [dbo].[catalog_selections]
where [item] like 'Signature Concerto Collection - Canvas 4.0 Note%' and session_id = @session_id
*/

/*
update cs 
set cs.[item] = mods.[item]
from [dbo].[catalog_selections] cs
cross apply (
    select 'new item 1' as [item]
    where cs.[row_id] = '019ecba9-d096-7097-b45b-503db2463734'
    union
    select 'new item 2' as [item]
    where cs.[row_id] = '019e6a1b-0ec7-757d-af87-55ba543ccbfc'
    union
    select 'new item 3' as [item]
    where cs.[row_id] = '019ecb82-8cae-7ca3-a085-6e20acf0ab27'
    union
    select 'new item 4' as [item]
    where cs.[row_id] = '019ba307-d881-7abe-a218-9b1a0fdc0d57'
) mods
where cs.session_id = @session_id

select * from [dbo].[catalog_selections]
where [application] = 'Flying Things' and session_id = @session_id
*/


select
    [session].session_id,
    [tenants].[account_org_id] as [tenant_id],
    [tenants].[account_id],
    [a].[name] as [account_name],
    [tenants].[organization_id],
    [o].[name] as [organization_name],
    [c].[community_id],
    [c].[name] as [community_name],
    [s].[series_id],
    [s].[name] as [series_name],
    [p].[plan_id],
    [p].[name] as [plan_name]
from [dbo].[account_organization_user_profile_plan_catalog_sessions] [session]
inner join [dbo].[VeoSolutionsSecurity_account_organizations] [tenants] on [session].organization_id = [tenants].organization_id
                                                                        and [session].[account_id] = [tenants].[account_id]
inner join [dbo].[vss_organizations] [o] on [session].organization_id = [o].organization_id
inner join [dbo].[VeoSolutionsSecurity_accounts] [a] on [session].[account_id] = [a].[account_id]
left join [dbo].[VeoSolutionsSecurity_account_organization_communities] [c] on [o].organization_id = [c].organization_id
                                                                            and [a].[account_id] = [c].[account_id]
                                                                            and [session].[community_name]= [c].[name]
left join [dbo].[VeoSolutionsSecurity_account_organization_series] [s] on [o].organization_id = [s].organization_id
                                                                            and [a].[account_id] = [s].[account_id]
                                                                            and [session].[series]= [s].[name]
left join [dbo].[VeoSolutionsSecurity_account_organization_plans] [p] on [o].[organization_id] = [p].[organization_id]
                                                                            and [a].[account_id] = [p].[account_id]
                                                                            and [session].[plan_name]= [p].[name]
inner join [dbo].[VeoSolutionsSecurity_account_org_community_series_plan] [tp] on [o].[organization_id] = [tp].[organization_id]
                                                                            and [a].[account_id] = [tp].[account_id]
                                                                            and [c].[community_id]= [tp].[community_id]
                                                                            and [s].[series_id]= [tp].[series_id]
                                                                            and [p].[plan_id]= [tp].[plan_id]
where [session].session_id = @session_id

/**/