use [VeoSolutions_DEV];
go


declare @LookupKey NVARCHAR(50) = '', -- lookup key of the new theme to create
        @Name NVARCHAR(50) = '', -- name of the new theme to create
        @Description NVARCHAR(50) = '', -- description of the new theme to create
        @CssClass NVARCHAR(50) = '', -- css class of the new theme to create
        @Author NVARCHAR(50) = '', -- author of the new theme to create
        @TargetCopyLookupKey NVARCHAR(50) = '', -- lookup key of the theme to copy from
        @DeleteCurrentState BIT = 0 -- whether to delete the current state of the new theme

declare @BaseThemeId UNIQUEIDENTIFIER = ( select [Id] from dbo.Theme where [LookupKey] = 'default' )

-- insert into new theme
merge into dbo.Theme as [target]
using ( select @LookupKey as [LookupKey], @Name as [Name], @Description as [Description], @CssClass as [CssClass], @Author as [Author]) as [source] on [source].[LookupKey] = [target].[LookupKey]
when not matched then 
    insert ([Id], [LookupKey], [Name], [Description], [CssClass], [Author], [BaseThemeId], [CreateDate], [ModifiedDate], [Modifier])
    values (newid(), [source].[LookupKey], [source].[Name], [source].[Description], [source].[CssClass], [source].[Author], @BaseThemeId, getdate(), getdate(), [source].[Author])
when matched then 
    update
        set [Name] = [source].[Name], 
            [Description] = [source].[Description], 
            [CssClass] = [source].[CssClass], 
            [ModifiedDate] = getdate(), 
            [Modifier] = [source].[Author];

-- merge over themevariablevalues
merge into dbo.ThemeableVariableValue as [target]
using ( 
        select 
            [t2].[Id] as [ThemeId],
            [tvv].[ThemeableVariableId],
            [tvv].[Value]
        from dbo.ThemeableVariableValue as [tvv]
            inner join dbo.Theme as [t1] on [tvv].[ThemeId] = [t1].[Id]  
                                       and [t1].[LookupKey] = @TargetCopyLookupKey
            left join dbo.Theme as [t2] on [t2].[LookupKey] = @LookupKey ) as [source] on [source].[ThemeableVariableId] = [target].[ThemeableVariableId] and [source].[ThemeId] = [target].[ThemeId]
when not matched then 
    insert ([ThemeId], [ThemeableVariableId], [Value])
    values ([source].[ThemeId], [source].[ThemeableVariableId], [source].[Value])
when matched then 
    update
        set [Value] = [source].[Value]
when not matched by source and @DeleteCurrentState = 1 and [target].[ThemeId] = (select [Id] from dbo.Theme where [LookupKey] = @LookupKey) then
    delete;

-- merge over themevariablegroupvalues
merge into dbo.ThemeableGroupVariableValue as [target]
using ( 
        select 
            [t2].[Id] as [ThemeId],
            [tgvv].[ThemeableGroupVariableId],
            [tgvv].[Value]
        from dbo.ThemeableGroupVariableValue as [tgvv]
            inner join dbo.Theme as [t1] on [tgvv].[ThemeId] = [t1].[Id]  
                                       and [t1].[LookupKey] = @TargetCopyLookupKey
            left join dbo.Theme as [t2] on [t2].[LookupKey] = @LookupKey ) as [source] on [source].[ThemeableGroupVariableId] = [target].[ThemeableGroupVariableId] and [source].[ThemeId] = [target].[ThemeId]
when not matched then 
    insert ([ThemeId], [ThemeableGroupVariableId], [Value])
    values ([source].[ThemeId], [source].[ThemeableGroupVariableId], [source].[Value])
when matched then 
    update
        set [Value] = [source].[Value]
when not matched by source and @DeleteCurrentState = 1 and [target].[ThemeId] = (select [Id] from dbo.Theme where [LookupKey] = @LookupKey) then
    delete;
