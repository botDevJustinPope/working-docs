insert into [VDS_Prod].[VeoSolutions].[dbo].[Theme] ( [Id], [LookupKey], [Name], [Description], [CssClass], [Author], [BaseThemeId], [CreateDate], [Modifier], [ModifiedDate] )
Select 
    ht.Id,
    ht.LookupKey,
    ht.Name,
    '',
    ht.CssClass,
    'Justin Pope',
    t.Id as [BaseThemeId],
    GETDATE(),
    'Justin Pope',
    GETDATE()
from [VEOSolutions_STAGING].dbo.Theme ht
    inner join [VDS_Prod].[VeoSolutions].[dbo].[Theme] t on t.LookupKey = 'default'
where ht.Id = 'd35129c5-451e-4e91-bd51-34aad43ba189'

insert into [VDS_Prod].[VeoSolutions].[dbo].[ThemeableVariableValue] ( [ThemeId], [ThemeableVariableId], [Value], [Author], [CreateDate], [Modifier], [ModifiedDate] )
SELECT
    tvv.ThemeId,
    tvv.ThemeableVariableId,
    tvv.Value,
    'Justin Pope',
    GETDATE(),
    'Justin Pope',
    GETDATE()
from [VEOSolutions_STAGING].dbo.Theme ht
    inner join [VEOSolutions_STAGING].dbo.ThemeableVariableValue tvv on tvv.ThemeId = ht.Id
    inner join [VDS_Prod].[VeoSolutions].[dbo].[ThemeableVariable] p_tv on p_tv.Id = tvv.ThemeableVariableId
where ht.Id = 'd35129c5-451e-4e91-bd51-34aad43ba189'


insert into [VDS_Prod].[EPLAN_VeoSolutions].[dbo].[Theme] ( [Id], [LookupKey], [Name], [Description], [CssClass], [Author], [BaseThemeId], [CreateDate], [Modifier], [ModifiedDate] )
Select 
    ht.Id,
    ht.LookupKey,
    ht.Name,
    '',
    ht.CssClass,
    'Justin Pope',
    t.Id as [BaseThemeId],
    GETDATE(),
    'Justin Pope',
    GETDATE()
from [VEOSolutions_STAGING].dbo.Theme ht
    inner join [VDS_Prod].[EPLAN_VeoSolutions].[dbo].[Theme] t on t.LookupKey = 'default'
where ht.Id = 'd35129c5-451e-4e91-bd51-34aad43ba189'

insert into [VDS_Prod].[EPLAN_VeoSolutions].[dbo].[ThemeableVariableValue] ( [ThemeId], [ThemeableVariableId], [Value], [Author], [CreateDate], [Modifier], [ModifiedDate] )
SELECT
    tvv.ThemeId,
    tvv.ThemeableVariableId,
    tvv.Value,
    'Justin Pope',
    GETDATE(),
    'Justin Pope',
    GETDATE()
from [VEOSolutions_STAGING].dbo.Theme ht
    inner join [VEOSolutions_STAGING].dbo.ThemeableVariableValue tvv on tvv.ThemeId = ht.Id
    inner join [VDS_Prod].[EPLAN_VeoSolutions].[dbo].[ThemeableVariable] p_tv on p_tv.Id = tvv.ThemeableVariableId
where ht.Id = 'd35129c5-451e-4e91-bd51-34aad43ba189'