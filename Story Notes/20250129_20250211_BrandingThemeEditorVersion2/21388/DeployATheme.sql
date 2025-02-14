use [VeoSolutions_Staging] -- database to copy from
go
/*
    In the purpose to keep the dev sql server from knowing/contaminating the production server, this script will do the following:
    - Script out the inserts for taking a theme from VeoSolutions_Staging and inserting it into a production VeoSolution database
        Tables to insert into:
            dbo.Theme
            dbo.ThemeableVariableValue
            dbo.ThemeableGroupVariableValue


    notes: the print has an extra comma and the font value has appostraphes this is issues
*/

declare @themeId UNIQUEIDENTIFIER = (select [Id] from dbo.Theme where [Name] = 'Default') -- Theme Id to copy
       ,@Database NVARCHAR(100) = 'VeoSolutions' -- database name to copy to
       ,@sql nvarchar(max) = ''
       ,@cnt int = 0
       ,@message nvarchar(max) = '';

if not exists(select * from sys.databases where name = @Database union select * from [VDS_PROD].[master].sys.databases where name = @Database)
begin
    set @message = 'No Database to copy to. '+@Database+' does not exist in any context.';
    RAISERROR(@message, 16, 1);
    return;
end


DECLARE @Id UNIQUEIDENTIFIER,
        @LookupKey NVARCHAR(50),
        @Name NVARCHAR(50),
        @Description NVARCHAR(500),
        @CssClass NVARCHAR(50),
        @Author NVARCHAR(100),
        @BaseThemeId UNIQUEIDENTIFIER,
        @CreateDate DATETIME,
        @ModifiedDate DATETIME,
        @Modifier NVARCHAR(100)

select 
    @Id = [Id],
    @LookupKey = [LookupKey],
    @Name = [Name],
    @Description = [Description],
    @CssClass = [CssClass],
    @Author = [Author],
    @BaseThemeId = [BaseThemeId],
    @CreateDate = [CreateDate],
    @ModifiedDate = [ModifiedDate],
    @Modifier = [Modifier]
FROM dbo.Theme
WHERE Id = @themeId

-- set the database context to the target database
print 'USE [' + @Database + '];' + char(13) + char(10) + 'go' + char(13) + char(13) + char(10);

-- begin try
print 'BEGIN TRY' + char(13) + char(10) + char(13) + char(10);
-- begin a transaction
print 'BEGIN TRANSACTION;' + char(13) + char(10) + char(13) + char(10);

declare @stringID NVARCHAR(50) = cast(@Id as nvarchar(50)),
         @stringBaseThemeId NVARCHAR(50) = CASE WHEN @BaseThemeId IS NOT NULL THEN cast(@BaseThemeId as nvarchar(50)) ELSE 'NULL' END
if (@Id IS NOT NULL)
begin 
    -- Insert into dbo.Theme
    print 'INSERT INTO dbo.Theme (Id, LookupKey, Name, Description, CssClass, Author, BaseThemeId, CreateDate, ModifiedDate, Modifier)' + char(13) + char(10) + 
                    'VALUES (''' + CAST(@Id AS NVARCHAR(50)) + ''', ''' + @LookupKey + ''', ''' + @Name + ''', ''' + @Description + ''', ''' + @CssClass + ''', ''' + @Author + ''', ' +
    CASE WHEN @BaseThemeId IS NOT NULL THEN '''' + CAST(@BaseThemeId AS NVARCHAR(50)) + '''' ELSE 'NULL' END + ', ''' + convert(varchar, @CreateDate, 120) + ''', ''' + convert(varchar, @ModifiedDate, 120) + ''', ''' + @Modifier + ''');' + char(13)  + char(10) + char(13) + char(10);
END
else
BEGIN
    print '/*' + char(13) + char(10) +' No Theme to copy ' + char(13) + char(10) +' @Id is null' + char(13) + char(10) +'*/' + char(13) + char(10)
END

declare @ThemeableVariableId UNIQUEIDENTIFIER,
        @Value NVARCHAR(500),
        @ThemeableGroupVariableId UNIQUEIDENTIFIER

if exists(select * from dbo.ThemeableVariableValue where ThemeId = @themeId)
begin
    set @cnt = (select count(*) from dbo.ThemeableVariableValue where ThemeId = @themeId);
    print 'INSERT INTO dbo.ThemeableVariableValue ' + char(13) + char(10) + 'Values ';

    declare curThemeableVariableValue cursor for 
        Select 
            [ThemeableVariableId],
            [Value]
        from dbo.ThemeableVariableValue
        where ThemeId = @themeId
    open curThemeableVariableValue
    fetch next from curThemeableVariableValue into @ThemeableVariableId, @Value
    while @@fetch_status = 0
    begin
        declare @stringThemeableVariableId NVARCHAR(50) = cast(@ThemeableVariableId as nvarchar(50))

        -- check @Value and escape ' if needed
        if @Value like '%''%'
            set @Value = replace(@Value, '''', '''''')

        set @sql = '(''' + CAST(@Id AS NVARCHAR(50)) + ''', ''' + @stringThemeableVariableId + ''', ''' + @Value + ''', ''' + @Author + ''', ''' + convert(varchar, @CreateDate, 120) + ''', ''' + @Modifier + ''', ''' + convert(varchar, @ModifiedDate, 120) + ''')';
        
        if @cnt > 1
            set @sql += ', ' + char(13) + char(10)
        else
            set @sql += ';' + char(13) + char(10) + char(13) + char(10)

        set @cnt -= 1;

        print @sql;
        
        fetch next from curThemeableVariableValue into @ThemeableVariableId, @Value
    end
    close curThemeableVariableValue
    deallocate curThemeableVariableValue
end
ELSE
begin 
    print '/* No ThemeableVariableValue to copy */' + char(13) + char(10)
end

if exists(select * from dbo.ThemeableGroupVariableValue where ThemeId = @themeId)
begin
    set @cnt = (select count(*) from dbo.ThemeableGroupVariableValue where ThemeId = @themeId);
    print 'INSERT INTO dbo.ThemeableGroupVariableValue (ThemeId, ThemeableGroupVariableId, Value, Author, CreateDate, Modifier, ModifiedDate)' + char(13) + char(10) + 'VALUES '
    declare curThemeableGroupVariableValue cursor for 
        Select 
            [ThemeableGroupVariableId],
            [Value]
        from dbo.ThemeableGroupVariableValue
        where ThemeId = @themeId
    open curThemeableGroupVariableValue
    fetch next from curThemeableGroupVariableValue into @ThemeableGroupVariableId, @Value
    while @@fetch_status = 0
    begin
        declare @stringThemeableGroupVariableId NVARCHAR(50) = cast(@ThemeableGroupVariableId as nvarchar(50))
        set @sql =  '(''' + CAST(@Id AS NVARCHAR(50)) + ''', ''' + @stringThemeableGroupVariableId + ''', ''' + @Value + ''', ''' + @Author + ''', ''' + convert(varchar, @CreateDate, 120) + ''', ''' + @Modifier + ''', ''' + convert(varchar, @ModifiedDate, 120) + ''')';
        
        
        if @cnt > 1
            set @sql += ', ' + char(13) + char(10)
        else
            set @sql += ';' + char(13) + char(10) + char(13) + char(10)

        set @cnt -= 1;

        print @sql;
        
        fetch next from curThemeableGroupVariableValue into @ThemeableGroupVariableId, @Value        
    end
    close curThemeableGroupVariableValue
    deallocate curThemeableGroupVariableValue
end
ELSE
begin 
    print '/* No ThemeableGroupVariableValue to copy */' + char(13) + char(10)
end

-- commit the transaction
print 'COMMIT TRANSACTION;' + char(13) + char(10) + char(13) + char(10);

-- end try
print 'END TRY' + char(13) + char(10) + char(13) + char(10);
-- begin catch
print 'BEGIN CATCH' + char(13) + char(10) + char(13) + char(10);
-- rollback the transaction
print 'ROLLBACK TRANSACTION;' + char(13) + char(10) + char(13) + char(10);
-- throw error
print 'throw;' + char(13) + char(10) + char(13) + char(10);
-- end catch
print 'END CATCH' + char(13) + char(10) + char(13) + char(10);