
DROP TABLE if EXISTS #temp_dbs

create table #temp_dbs (
    [name] sysname not null,
    [Notes] nvarchar(4000) null
)

DECLARE @db_cursor CURSOR 
SET @db_cursor = CURSOR FAST_FORWARD FOR
SELECT name FROM sys.databases where state = 0
OPEN @db_cursor
DECLARE @db_name sysname
FETCH NEXT FROM @db_cursor INTO @db_name
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    SET @sql = 'USE [' + @db_name + ']; 
                INSERT INTO #temp_dbs ([name], [Notes])
                SELECT ''' + @db_name + ''', ''Theme table exists for this db''
                from sys.tables t
					inner join sys.columns c on c.object_id = t.object_id
                where t.name = ''Theme'' and c.name = ''CssClass'' '
    EXEC sp_executesql @sql
    FETCH NEXT FROM @db_cursor INTO @db_name
END

CLOSE @db_cursor
DEALLOCATE @db_cursor

set @db_cursor = cursor FAST_FORWARD for
select [name] from #temp_dbs
open @db_cursor
fetch next from @db_cursor into @db_name
while @@FETCH_STATUS = 0
begin
    -- check the default theme record if the CssClass is null or empty
    SET @sql = 'USE [' + @db_name + ']; 
                UPDATE dbo.Theme
                SET [CssClass] = ''theme-default''
                WHERE LookupKey = ''default''
                '
    EXEC sp_executesql @sql
	fetch next from @db_cursor into @db_name


end
close @db_cursor
deallocate @db_cursor

SELECT * FROM #temp_dbs

select * from VEOSolutions_PREVIEW.dbo.theme