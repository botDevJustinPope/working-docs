use VeoSolutions_DEV;
go

merge into dbo.Theme as target
using (
    Select 
        'historymaker' as LookupKey,
        'Historymaker' as [Name],
        'Historymaker Homes theme' as [Description],
        'historymaker' as [CssClass],
        '8162223d-2857-4e57-80f3-1e7183173746' as [BaseThemeId],
        'justinpo' as [Author]
) as source on target.LookupKey = source.LookupKey
when matched then
    update set
        target.[Name] = source.[Name],
        target.[Description] = source.[Description],
        target.CssClass = source.CssClass,
        target.BaseThemeId = source.BaseThemeId,
        target.[Author] = source.[Author],
        target.ModifiedDate = getdate(),
        target.Modifier = 'justinpo'
when not matched then
    insert (Id, LookupKey, [Name], [Description], CssClass, BaseThemeId, [Author], CreateDate, ModifiedDate, Modifier)
    values (newid(), source.LookupKey, source.[Name], source.[Description], source.CssClass, source.BaseThemeId, source.[Author], getdate(), getdate(), source.[Author]);

select * from dbo.Theme where LookupKey = 'historymaker';