with Themes_AllDBS as (
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Prod - WBS' as [Stack]
                            from [VDS_PROD].[VeoSolutions].[dbo].[Theme] t 
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Prod - WBS' as [Stack]
                            from [VDS_PROD].[VeoSolutions].[dbo].[Theme] t 
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VDS_PROD].[VeoSolutions].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Prod - AFI' as [Stack]
                            from [VDS_PROD].[AFI_VeoSolutions].[dbo].[Theme] t
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Prod - AFI' as [Stack]
                            from [VDS_PROD].[AFI_VeoSolutions].[dbo].[Theme] t
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VDS_PROD].[AFI_VeoSolutions].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 
                            UNION ALL
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Prod - CCDI' as [Stack]
                            from [VDS_PROD].[CCDI_VeoSolutions].[dbo].[Theme] t
                            UNION ALL
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Prod - CCDI' as [Stack]
                            from [VDS_PROD].[CCDI_VeoSolutions].[dbo].[Theme] t
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VDS_PROD].[CCDI_VeoSolutions].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Prod - EPLAN' as [Stack]
                            from [VDS_PROD].[EPLAN_VeoSolutions].[dbo].[Theme] t
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Prod - EPLAN' as [Stack]
                            from [VDS_PROD].[EPLAN_VeoSolutions].[dbo].[Theme] t
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VDS_PROD].[EPLAN_VeoSolutions].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Dev - DEV' as [Stack]
                            from [VeoSolutions_dev].[dbo].[Theme] t
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Dev - DEV' as [Stack]
                            from [VeoSolutions_dev].[dbo].[Theme] t
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VeoSolutions_dev].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Dev - QA' as [Stack]
                            from [VeoSolutions_qa].[dbo].[Theme] t
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Dev - QA' as [Stack]
                            from [VeoSolutions_qa].[dbo].[Theme] t
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VeoSolutions_qa].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Dev - STAGING' as [Stack]
                            from [VEOSolutions_STAGING].[dbo].[Theme] t
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Dev - STAGING' as [Stack]
                            from [VEOSolutions_STAGING].[dbo].[Theme] t
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VEOSolutions_STAGING].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'active' as [metric],
                                1 as [metricValue],
                                'Dev - PREVIEW' as [Stack]
                            from [VEOSolutions_PREVIEW].[dbo].[Theme] t
                            union all
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                'version' as [metric],
                                v.[Number] as [metricValue],
                                'Dev - PREVIEW' as [Stack]
                            from [VEOSolutions_PREVIEW].[dbo].[Theme] t
                                cross apply (
                                    select top 1
                                        v.Number 
                                    from [VEOSolutions_PREVIEW].[dbo].[ThemeVersion] v
                                    where v.[ThemeId] = t.[Id]
                                    order by v.[Number] desc
                                ) v 

                                ),
PivotedMetrics as (
    select 
        [ThemeId],
        [ThemeName],
        [metric],
        [Prod - WBS],
        [Prod - AFI],
        [Prod - CCDI],
        [Prod - EPLAN],
        [Dev - DEV],
        [Dev - QA],
        [Dev - STAGING],
        [Dev - PREVIEW]
    from Themes_AllDBS
    pivot (
        max([MetricValue])
        for [Stack] in (
            [Prod - WBS],
            [Prod - AFI],
            [Prod - CCDI],
            [Prod - EPLAN],
            [Dev - DEV],
            [Dev - QA],
            [Dev - STAGING],
            [Dev - PREVIEW]
        )
    ) as pvt
)
select 
    [ThemeId],
    [ThemeName],
    max(case when [metric] = 'version' then [Prod - WBS] end) as [Prod - WBS Version],
    max(case when [metric] = 'active' then [Prod - CCDI] end) as [Prod - CCDI Active],
    max(case when [metric] = 'version' then [Prod - CCDI] end) as [Prod - CCDI Version],
    max(case when [metric] = 'version' then [Prod - EPLAN] end) as [Prod - EPLAN Version],
    max(case when [metric] = 'version' then [Dev - DEV] end) as [Dev - DEV Version],
    max(case when [metric] = 'version' then [Dev - QA] end) as [Dev - QA Version],
    max(case when [metric] = 'version' then [Dev - STAGING] end) as [Dev - STAGING Version],
    max(case when [metric] = 'version' then [Dev - PREVIEW] end) as [Dev - PREVIEW Version]
from PivotedMetrics
group by [ThemeId], [ThemeName]