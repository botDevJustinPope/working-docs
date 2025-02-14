/*

    This script is to copy a theme from the dev server into the production server

*/

use [VeoSolutions_Staging]; -- Dev database to copy from
go


declare @LookupKey NVARCHAR(50) = '', -- lookup key of the new theme to create
        @Name NVARCHAR(50) = '', -- name of the new theme to create
        @Description NVARCHAR(50) = '', -- description of the new theme to create
        @CssClass NVARCHAR(50) = '', -- css class of the new theme to create
        @Author NVARCHAR(50) = '', -- author of the new theme to create
        @TargetCopyLookupKey NVARCHAR(50) = '', -- lookup key of the theme to copy from
        @DeleteCurrentState BIT = 0, -- whether to delete the current state of the new theme
        @SourceDatabase NVARCHAR(200) = 'VeoSolutions_Staging', -- database to copy from
        @TargetDatabase NVARCHAR(200) = 'VeoSolutions', -- database to copy to
        @sql nvarchar(max) = '',
        @execute bit = 0;


declare @BaseThemeId UNIQUEIDENTIFIER = ( select [Id] from dbo.Theme where [LookupKey] = 'default' )


if exists (select * from [VDS_PROD].[master].[sys].[databases] where name = @TargetDatabase)
begin

    -- script insert into Theme table
    set @sql = 'USE [' + @SourceDatabase + '];' + char(13) + char(10) + 'go' + char(13) + char(10) + char(13) + char(10);

    set @sql += '/*' + char(13) + char(10) + char(9) + 'This script is to copy a theme from the dev server into the production server' + char(13) + char(10) + char(9) + 'This inserts into Theme' + char(13) + char(10) + '*/' + char(13) + char(10) + char(13) + char(10);

    set @sql += 'merge into [VDS_PROD].['+@TargetDatabase+'].dbo.Theme as [target]' + char(13) + char(10) +
                'using ( select [LookupKey], [Name], [Description], [CssClass], [Author] from dbo.Theme where [LookupKey] = ''' + @TargetCopyLookupKey + ''') as [source]' + char(13) + char(10) +
                char(9) + 'on [source].[LookupKey] = [target].[LookupKey]' + char(13) + char(10) +
                'when not matched then' + char(13) + char(10) +
                char(9) + 'insert ([Id], [LookupKey], [Name], [Description], [CssClass], [Author], [BaseThemeId], [CreateDate], [ModifiedDate], [Modifier])' + char(13) + char(10) +
                char(9) + 'values (newid(), [source].[LookupKey], [source].[Name], [source].[Description], [source].[CssClass], [source].[Author], @BaseThemeId, getdate(), getdate(), [source].[Author])' + char(13) + char(10) +
                'when matched then' + char(13) + char(10) +
                char(9) + 'update' + char(13) + char(10) +
                char(9) + char(9) + 'set [Name] = [source].[Name], ' + char(13) + char(10) +
                char(9) + char(9) + char(9) + '[Description] = [source].[Description], ' + char(13) + char(10) +
                char(9) + char(9) + char(9) + '[CssClass] = [source].[CssClass], ' + char(13) + char(10) +
                char(9) + char(9) + char(9) + '[ModifiedDate] = getdate(), ' + char(13) + char(10) +
                char(9) + char(9) + char(9) + '[Modifier] = [source].[Author];' + char(13) + char(10)

    if @execute = 1
        exec sp_executesql @sql;
    else
        print @sql;

    -- script insert into ThemableVariabbleValue table
    set @sql = 'USE [' + @SourceDatabase + '];' + char(13) + char(10) + 'go' + char(13) + char(10) + char(13) + char(10);

    set @sql += '/*' + char(13) + char(10) + char(9) +'This inserts into ThemeableVariableValue' + char(13) + char(10) + '*/' + char(13) + char(10) + char(13) + char(10);
    set @sql += 'merge into [VDS_PROD].['+@TargetDatabase+'].dbo.ThemeableVariableValue as [target]' + char(13) + char(10) +
                'using ( select [t2].[Id] as [ThemeId], [tvv].[ThemeableVariableId], [tvv].[Value] from dbo.ThemeableVariableValue as [tvv]' + char(13) + char(10) +
                char(9) + 'inner join dbo.Theme as [t1] on [tvv].[ThemeId] = [t1].[Id]  and [t1].[LookupKey] = ''' + @TargetCopyLookupKey + '''' + char(13) + char(10) +
                char(9) + 'left join [VDS_PROD].[' + @SourceDatabase + '].dbo.Theme as [t2] on [t2].[LookupKey] = ''' + @LookupKey + ''') as [source]' + char(13) + char(10) +
                char(9) + 'on [source].[ThemeableVariableId] = [target].[ThemeableVariableId] and [source].[ThemeId] = [target].[ThemeId]' + char(13) + char(10) +
                'when not matched then' + char(13) + char(10) +
                char(9) + 'insert ([ThemeId], [ThemeableVariableId], [Value])' + char(13) + char(10) +
                char(9) + 'values ([source].[ThemeId], [source].[ThemeableVariableId], [source].[Value])' + char(13) + char(10) +
                'when matched then' + char(13) + char(10) +
                char(9) + 'update'  + char(13) + char(10) +
                char(9) + char(9) +'set [Value] = [source].[Value];'

    if @execute = 1
        exec sp_executesql @sql;
    else
        print @sql;

    -- script insert into ThemableGroupVariableValue table
    set @sql = 'USE [' + @SourceDatabase + '];' + char(13) + char(10) + 'go' + char(13) + char(10) + char(13) + char(10);
    set @sql += '/*' + char(13) + char(10) + char(9) +'This inserts into ThemeableGroupVariableValue' + char(13) + char(10) + '*/' + char(13) + char(10) + char(13) + char(10);
    set @sql += 'merge into [VDS_PROD].['+@TargetDatabase+'].dbo.ThemeableGroupVariableValue as [target]' + char(13) + char(10) +
                'using ( select [t2].[Id] as [ThemeId], [tgvv].[ThemeableGroupVariableId], [tgvv].[Value] from dbo.ThemeableGroupVariableValue as [tgvv]' + char(13) + char(10) +
                char(9) + 'inner join dbo.Theme as [t1] on [tgvv].[ThemeId] = [t1].[Id]  and [t1].[LookupKey] = ''' + @TargetCopyLookupKey + '''' + char(13) + char(10) +
                char(9) + 'left join [VDS_PROD].[' + @SourceDatabase + '].dbo.Theme as [t2] on [t2].[LookupKey] = ''' + @LookupKey + ''') as [source]' + char(13) + char(10) +
                char(9) + 'on [source].[ThemeableGroupVariableId] = [target].[ThemeableGroupVariableId] and [source].[ThemeId] = [target].[ThemeId]' + char(13) + char(10) +
                'when not matched then' + char(13) + char(10) +
                char(9) + 'insert ([ThemeId], [ThemeableGroupVariableId], [Value])' + char(13) + char(10) +
                char(9) + 'values ([source].[ThemeId], [source].[ThemeableGroupVariableId], [source].[Value])' + char(13) + char(10) +
                'when matched then' + char(13) + char(10) +
                char(9) + 'update'  + char(13) + char(10) +
                char(9) + char(9) +'set [Value] = [source].[Value];'

    if @execute = 1
        exec sp_executesql @sql;
    else
        print @sql;

end
else 
begin 
    print 'The target database does not exists'
end