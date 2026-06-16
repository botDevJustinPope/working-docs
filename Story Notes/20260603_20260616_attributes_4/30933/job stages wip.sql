merge into [VeoSolutions_DEV].[dbo].[jobs_stages] as target
using (
select * from (
values
('573e9081-bc15-4f1c-805b-1688abf317c7', 1, 1, 'Stage One', dateadd(day, -1, getdate()), null, null, 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate()),
('573e9081-bc15-4f1c-805b-1688abf317c7', 1, 2, 'Stage Two', dateadd(day, 1, getdate()), null, null, 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate()),
('573e9081-bc15-4f1c-805b-1688abf317c7', 1, 3, 'Stage Three', dateadd(day, 2, getdate()), null, null, 'justinpo@buildontechnologies.com', getdate(), 'justinpo@buildontechnologies.com', getdate())
) as t (account_org_id, job_no, stage_id, stage_name, stage_date, stage_date_override, stage_date_override_author, author, created_date, modifier, modified_date) ) as [source]
on target.account_org_id = [source].account_org_id
and target.job_no = [source].job_no
and target.stage_id = [source].stage_id
when matched then 
    update set 
        stage_name = [source].stage_name,
        stage_date = [source].stage_date,
        stage_date_override = [source].stage_date_override,
        stage_date_override_author = [source].stage_date_override_author,
        modifier = [source].modifier,
        modified_date = [source].modified_date
when not matched then
    insert (account_org_id, job_no, stage_id, stage_name, stage_date, stage_date_override, stage_date_override_author, author, create_date, modifier, modified_date)
    values ([source].account_org_id, [source].job_no, [source].stage_id, [source].stage_name, [source].stage_date, [source].stage_date_override, [source].stage_date_override_author, [source].author, [source].created_date, [source].modifier, [source].modified_date)
when not matched by source then
    delete;

select * from [VeoSolutions_DEV].[dbo].[jobs_stages]

select 
    ao.account_org_id,
    ao.account_id,
    a.[name] as account_name,
    ao.organization_id,
    o.[name] as organization_name
from [VEOSolutionsSecurity_DEV].[dbo].[account_organizations] ao  
inner join [VeoSolutionsSecurity_DEV].[dbo].[accounts] a on a.account_id = ao.account_id
inner join [VeoSolutionsSecurity_DEV].[dbo].[organizations] o on o.organization_id = ao.organization_id
where ao.account_id = 'bab32b7e-3ada-497c-862e-e5083971cc59'

select
    cs.row_id,
    cs.item,
    cs.item_no,
    cs.stage,
    [items].*
/* update cs 
    set cs.stage = [items].stage */
from [VeoSolutions_DEV].[dbo].[catalog_selections] cs
    left join (
        SELECT '019e6a1b-0ec7-757d-af87-55ba543ccbfc' AS [ROW_ID], 1 AS [STAGE]
        UNION
        SELECT '019ecb82-8cae-7ca3-a085-6e20acf0ab27' AS [ROW_ID], 2 AS [STAGE]
        UNION
        SELECT '019ba307-d881-7abe-a218-9b1a0fdc0d57' AS [ROW_ID], 3 AS [STAGE]    ) as [items] ON [items].ROW_ID = cs.row_id
where cs.session_id = 'd336a465-17e2-4402-8e4a-c5b4e4004170'
    and cs.[application] = 'Flying Things'
