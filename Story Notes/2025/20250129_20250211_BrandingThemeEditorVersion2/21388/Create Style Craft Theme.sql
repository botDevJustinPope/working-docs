MERGE INTO VeoSolutions_Dev.dbo.Theme
USING (
    select * from (values ('style_craft', 'Style Craft', 'Stylecraft is a family-owned business that values passion, hard-work, and the experience we provide.', 'style-craft', '8162223d-2857-4e57-80f3-1e7183173746', 'justinpo')) as t (LookupKey, [Name], [Description], CssClass, BaseThemeId, [Author])
    ) as source ON Theme.LookupKey = source.LookupKey
WHEN MATCHED THEN
    UPDATE SET
        Theme.[Name] = source.[Name],
        Theme.[Description] = source.[Description],
        Theme.CssClass = source.CssClass,
        Theme.BaseThemeId = source.BaseThemeId,
        Theme.[Author] = source.[Author],
        Theme.ModifiedDate = getdate(),
        Theme.Modifier = 'justinpo'
WHEN NOT MATCHED THEN
    INSERT (Id, LookupKey, [Name], [Description], CssClass, BaseThemeId, [Author], CreateDate, ModifiedDate, Modifier)
    VALUES (NEWID() ,source.LookupKey, source.[Name], source.[Description], source.CssClass, source.BaseThemeId, source.[Author], getdate(), getdate(), 'justinpo');


select * from VeoSolutions_DEV.dbo.Theme