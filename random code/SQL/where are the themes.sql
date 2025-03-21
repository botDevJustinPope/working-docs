with Themes_AllDBS as (
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Prod - WBS' as [Stack]
                            from [VDS_PROD].[VeoSolutions].[dbo].[Theme] t 
                            union 
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Prod - AFI' as [Stack]
                            from [VDS_PROD].[AFI_VeoSolutions].[dbo].[Theme] t
                            UNION
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Prod - CCDI' as [Stack]
                            from [VDS_PROD].[CCDI_VeoSolutions].[dbo].[Theme] t
                            union 
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Prod - EPLAN' as [Stack]
                            from [VDS_PROD].[EPLAN_VeoSolutions].[dbo].[Theme] t
                            union 
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Dev - DEV' as [Stack]
                            from [VeoSolutions_dev].[dbo].[Theme] t
                            union 
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Dev - QA' as [Stack]
                            from [VeoSolutions_qa].[dbo].[Theme] t
                            union 
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Dev - STAGING' as [Stack]
                            from [VEOSolutions_STAGING].[dbo].[Theme] t
                            union 
                            select 
                                t.[Id] as [ThemeId],
                                t.[Name] as [ThemeName],
                                1 as [active],
                                'Dev - PREVIEW' as [Stack]
                            from [VEOSolutions_PREVIEW].[dbo].[Theme] t )

select 
    pvt.*
from Themes_AllDBS 
pivot (
    max( [active] )
    for Stack in (
        [Prod - WBS],
        [Prod - AFI],
        [Prod - CCDI],
        [Prod - EPLAN],
        [Dev - DEV],
        [Dev - QA],
        [Dev - STAGING],
        [Dev - PREVIEW] )
) as pvt


