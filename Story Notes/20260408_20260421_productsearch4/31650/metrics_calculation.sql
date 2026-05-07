use [VeoSolutions_DEV];
go

declare @division datetime = '2026-04-20 00:00:00';

with event_data as (
select
    organization_id,
    event_log_date,
    category,
    community,
    series,
    [plan],
    elevation,
    sessionId,
    module,
    resultCount,
    searchTerm,
    execution_time.executionTimeSec
from [dbo].[event_log]
cross apply openjson([data]) with (
    [community] varchar(100) '$.community',
    [series] varchar(100) '$.series',
    [plan] varchar(100) '$.plan',
    [elevation] varchar(100) '$.elevation',
    [sessionId] varchar(100) '$.sessionId',
    [module] varchar(100) '$.module',
    [resultCount] int '$.resultCount',
    [executionTimeMs] int '$.executionTimeMs',
    [searchTerm] varchar(250) '$.searchTerm'
) [json_data]
cross apply (
    select CAST([json_data].[executionTimeMs] / 1000.0 AS decimal(20,4)) as [executionTimeSec]
) [execution_time]
where [action] = 'perform_search' 
and [json_data].[sessionId] is null
and [json_data].[module] = 'option_pricing'
and [json_data].[executionTimeMs] < 88000
),
terms as (
select distinct 
    organization_id,    
    community,
    series,
    [plan],
    searchTerm
from event_data
),
pre_changes_searches as (
    select 
        *
    from event_data
    where event_log_date < @division
),
post_changes_searches as (
    select 
        *
    from event_data
    where event_log_date >= @division
),
average_execution_time_pre_changes as (
    select 
        pcs.organization_id,
        pcs.community,
        pcs.series,
        pcs.[plan],
        pcs.searchTerm,
        avg(pcs.[executionTimeSec]) as [averageExecutionTimeSec]
    from pre_changes_searches pcs
    inner join terms t
        on pcs.organization_id = t.organization_id
        and pcs.community = t.community
        and pcs.series = t.series
        and pcs.[plan] = t.[plan]
        and pcs.searchTerm = t.searchTerm
    group by 
        pcs.organization_id,
        pcs.community,
        pcs.series,
        pcs.[plan],
        pcs.searchTerm
),
average_execution_time_post_changes as (
    select 
        pcs.organization_id,
        pcs.community,
        pcs.series,
        pcs.[plan],
        pcs.searchTerm,
        avg(pcs.[executionTimeSec]) as [averageExecutionTimeSec]
    from post_changes_searches pcs
    inner join terms t
        on pcs.organization_id = t.organization_id
        and pcs.community = t.community
        and pcs.series = t.series
        and pcs.[plan] = t.[plan]
        and pcs.searchTerm = t.searchTerm
    group by 
        pcs.organization_id,
        pcs.community,
        pcs.series,
        pcs.[plan],
        pcs.searchTerm
),
pre_grand_total as (
    select 
        organization_id,
        community,
        series,
        [plan],
        avg([executionTimeSec]) as [grandTotalExecutionTimeSec]
    from pre_changes_searches
    group by 
        organization_id,
        community,
        series,
        [plan]
),
post_grand_total as (
    select 
        organization_id,
        community,
        series,
        [plan],
        avg([executionTimeSec]) as [grandTotalExecutionTimeSec]
    from post_changes_searches
    group by 
        organization_id,
        community,
        series,
        [plan]
)

-- Query to compare grand total execution times before and after changes
-- based grouped by organization, community, series, and plan
select 
    pgt.organization_id,
    pgt.community,
    pgt.series,
    pgt.[plan],
    pgt.[grandTotalExecutionTimeSec] as [grandTotalExecutionTimePreChangesSec],
    pgt2.[grandTotalExecutionTimeSec] as [grandTotalExecutionTimePostChangesSec]
from pre_grand_total pgt
left join post_grand_total pgt2 on pgt2.organization_id = pgt.organization_id
    and pgt2.community = pgt.community
    and pgt2.series = pgt.series
    and pgt2.[plan] = pgt.[plan]

/*
-- Query to compare average execution times before and after changes
-- based grouped by organization, community, series, plan, and search term
select 
    t.organization_id,
    t.community,
    t.series,
    t.[plan],
    t.searchTerm,
    aepc.[averageExecutionTimeSec] as [averageExecutionTimePreChangesSec],
    aepoc.[averageExecutionTimeSec] as [averageExecutionTimePostChangesSec]
from terms t
left join average_execution_time_pre_changes aepc on aepc.organization_id = t.organization_id
    and aepc.community = t.community
    and aepc.series = t.series
    and aepc.[plan] = t.[plan]
    and aepc.searchTerm = t.searchTerm
left join average_execution_time_post_changes aepoc on aepoc.organization_id = t.organization_id
    and aepoc.community = t.community
    and aepoc.series = t.series
    and aepoc.[plan] = t.[plan]
    and aepoc.searchTerm = t.searchTerm
order by t.organization_id, t.community, t.series, t.[plan], t.searchTerm 
*/