merge into VeoSolutions_Staging.dbo.Theme as target
using (
    select
        t.[Id],
        t.[LookupKey],
        t.[Name],
        t.[Description],
        t.[CssClass],
        'justinpo' as [Author],
        t.[BaseThemeId],
        GETDATE() as [CreateDate],
        GETDATE() as [ModifiedDate],
        'justinpo' as [Modifier]
    from VeoSolutions_DEV.dbo.Theme t
    where t.[Name] = 'Historymaker' ) as source on target.Id = source.Id
when matched then update set
    target.[LookupKey] = source.[LookupKey],
    target.[Name] = source.[Name],
    target.[Description] = source.[Description],
    target.[CssClass] = source.[CssClass],
    target.[Author] = source.[Author],
    target.[BaseThemeId] = source.[BaseThemeId],
    target.[CreateDate] = source.[CreateDate],
    target.[ModifiedDate] = source.[ModifiedDate],
    target.[Modifier] = source.[Modifier]
when not matched then insert ([Id], [LookupKey], [Name], [Description], [CssClass], [Author], [BaseThemeId], [CreateDate], [ModifiedDate], [Modifier])
values (source.[Id], source.[LookupKey], source.[Name], source.[Description], source.[CssClass], source.[Author], source.[BaseThemeId], source.[CreateDate], source.[ModifiedDate], source.[Modifier]);


merge into VeoSolutions_Staging.dbo.ThemeableVariableValue as [target]
using (
select 
	tvv.[ThemeId],
	tvv.[ThemeableVariableId],
	tvv.[Value],
	'justinpo' as [Author],
	GETDATE() as [CreateDate],
	'justinpo' as [Modifier],
	GETDATE() as [ModifiedDate]
from VeoSolutions_DEV.dbo.[ThemeableVariableValue] tvv
	inner join VeoSolutions_DEV.dbo.Theme t on t.Id = tvv.ThemeId
where t.[Name] = 'Historymaker' ) as source on target.ThemeId = source.ThemeId and target.ThemeableVariableId = source.ThemeableVariableId
when matched then update set
    [target].[Value] = source.[Value],
    [target].[Author] = source.[Author],
    [target].[CreateDate] = source.[CreateDate],
    [target].[ModifiedDate] = source.[ModifiedDate],
    [target].[Modifier] = source.[Modifier]
when not matched then insert ([ThemeId], [ThemeableVariableId], [Value], [Author], [CreateDate], [ModifiedDate], [Modifier])
values (source.[ThemeId], source.[ThemeableVariableId], source.[Value], source.[Author], source.[CreateDate], source.[ModifiedDate], source.[Modifier]);

MERGE into VeoSolutions_Staging.dbo.ThemeableGroupVariableValue as [target]
using (
select 
	tgvv.[ThemeId],
	tgvv.[ThemeableGroupVariableId],
	tgvv.[Value],
	'justinpo' as [Author],
	GETDATE() as [CreateDate],
	'justinpo' as [Modifier],
	GETDATE() as [ModifiedDate]
from VeoSolutions_DEV.dbo.[ThemeableGroupVariableValue] tgvv
	inner join VeoSolutions_DEV.dbo.Theme t on t.Id = tgvv.ThemeId
where t.[Name] = 'Historymaker' ) as source on target.ThemeId = source.ThemeId and target.ThemeableGroupVariableId = source.ThemeableGroupVariableId
when matched then update set
    [target].[Value] = source.[Value],
    [target].[Author] = source.[Author],
    [target].[CreateDate] = source.[CreateDate],
    [target].[ModifiedDate] = source.[ModifiedDate],
    [target].[Modifier] = source.[Modifier]
when not matched then insert ([ThemeId], [ThemeableGroupVariableId], [Value], [Author], [CreateDate], [ModifiedDate], [Modifier])
values (source.[ThemeId], source.[ThemeableGroupVariableId], source.[Value], source.[Author], source.[CreateDate], source.[ModifiedDate], source.[Modifier]);