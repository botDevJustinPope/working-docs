use [VEOSolutions];
go

declare @start_date datetime2(0) = '2026-04-01 00:00:00';
declare @end_date   datetime2(0) = '2026-05-12 23:59:59';
declare @provider_id uniqueidentifier = 'cc4c17fb-25ed-47f2-af05-af576bbaf6ee';

-- Use half-open range to avoid missing fractional-second rows at day end.
declare @end_date_exclusive datetime2(0) = dateadd(day, 1, cast(@end_date as date));

with vp as (
    select top (1)
        vp.[Id],
        vp.[RenderTimeout]
    from [dbo].[VisualizationProvider] vp
    where vp.[Id] = @provider_id
),
cte_view_scene_event_logs as (
    select
        el.[event_log_id],
        el.[event_log_date],
        el.[organization_id],
        el.[category],
        el.[action],
        el.[user_id],
        j.[session_id],
        j.[account_id],
        j.[room_id],
        j.[scene_id]
    from [dbo].[event_log] el
    cross apply openjson(el.data) with (
        [session_id]      uniqueidentifier '$.sessionID',
        [account_id]      uniqueidentifier '$.accountID',
        [organization_id] uniqueidentifier '$.organizationID',
        [room_id]         uniqueidentifier '$.roomID',
        [scene_id]        uniqueidentifier '$.sceneID'
    ) j
    where el.[category] = 'visualizer'
      and el.[action] = 'view_scene'
      and el.[event_log_date] >= @start_date
      and el.[event_log_date] < @end_date_exclusive
),
cte_timeout_event_logs as (
    select
        el.[event_log_id],
        el.[event_log_date],
        el.[organization_id],
        el.[category],
        el.[action],
        el.[user_id],
        j.[session_id],
        j.[streamUrl]
    from [dbo].[event_log] el
    cross apply openjson(el.[data]) with (
        [session_id] uniqueidentifier '$.sessionID',
        [streamUrl]  nvarchar(500)    '$.streamUrl'
    ) j
    where el.[category] = 'visualizer'
      and el.[action] = 'error_timeout'
      and el.[event_log_date] >= @start_date
      and el.[event_log_date] < @end_date_exclusive
),
account_org_data as (
    select
        a.[account_id],
        a.[name] as account_name,
        o.[organization_id],
        o.[name] as organization_name
    from [dbo].[VeoSolutionsSecurity_account_organizations] ao
    inner join [dbo].[VeoSolutionsSecurity_accounts] a
        on ao.[account_id] = a.[account_id]
    inner join [dbo].[vss_organizations] o
        on ao.[organization_id] = o.[organization_id]
),
error_view_linkage as (
    select
        v.[session_id],
        v.[event_log_id] as [view_event_log_id],
        t.[event_log_id] as [timeout_event_log_id]
    from cte_timeout_event_logs t
    cross join vp
    outer apply (
        select top (1)
            v_log.[event_log_id],
            v_log.[session_id]
        from cte_view_scene_event_logs v_log
        where v_log.[session_id] = t.[session_id]
          and v_log.[organization_id] = t.[organization_id]
          and t.[event_log_date] >= v_log.[event_log_date]
          and t.[event_log_date] <= dateadd(second, vp.[RenderTimeout] + 5, v_log.[event_log_date])
        order by v_log.[event_log_date] desc
    ) v
    where v.[event_log_id] is not null
)

select
    v_log.[event_log_date] as [view_event_log_date],
    'WBS' as [view_stack],
    v_log.[account_id],
    a.[account_name],
    v_log.[organization_id] as [view_organization_id],
    a.[organization_name],
    v_log.[category] as [view_category],
    v_log.[action] as [view_action],
    v_log.[user_id] as [view_user_id],
    u.[first_name] + ' ' + u.[last_name] as [user_full_name],
    v_log.[session_id],
    v_log.[room_id],
    r.[name] as [room_name],
    s.[RoomIdentifier],
    s.[Specifier],
    s.[Discriminator],
    t_log.[event_log_date] as [timeout_event_log_date],
    t_log.[streamUrl] as [timeout_stream_url]
from error_view_linkage l
inner join cte_view_scene_event_logs v_log
    on l.[view_event_log_id] = v_log.[event_log_id]
inner join cte_timeout_event_logs t_log
    on l.[timeout_event_log_id] = t_log.[event_log_id]
inner join account_org_data a
    on a.[account_id] = v_log.[account_id]
   and a.[organization_id] = v_log.[organization_id]
inner join dbo.[VeoSolutionsSecurity_users] u
    on u.[user_id] = v_log.[user_id]
inner join dbo.[rooms] r
    on r.[id] = v_log.[room_id]
inner join dbo.[VisualizationProviderSceneConfiguration] s
    on s.[SceneId] = v_log.[scene_id]
order by v_log.[event_log_date] desc;