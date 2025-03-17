declare @sql nvarchar(max) = '';
declare @db_name sysname;

drop table if exists #temp_dbs

create table #temp_dbs (
    [name] sysname not null
)

declare @db_cursor cursor
set @db_cursor = cursor fast_forward for
select name from sys.databases where state = 0 and name not in ('VEOSolutions_STAGING', 'VEOSolutions_ROGER',
                                                                                        'VeoSolutions_REID',
                                                                                        'VEOSolutions_DANIEL')
open @db_cursor
fetch next from @db_cursor into @db_name
while @@fetch_status = 0
begin 
    set @sql =  'USE [' + @db_name + ']; 
                INSERT INTO #temp_dbs ([name])
                SELECT ''' + @db_name + '''
                from sys.tables t
                where t.name = ''Theme'' '
    exec sp_executesql @sql
    fetch next from @db_cursor into @db_name
end

close @db_cursor
deallocate @db_cursor

select * from #temp_dbs

set @db_cursor = cursor fast_forward for
select [name] from #temp_dbs
open @db_cursor
fetch next from @db_cursor into @db_name
while @@fetch_status = 0
BEGIN

set @sql = 'USE ['+@db_name+'];
    merge dbo.builder_features as target 
    using (
        select 
            o.organization_id as organization_id,
            65 as feature_id,
            1 as [value],
            SYSTEM_USER as author,
            GETDATE() as created_date,
            SYSTEM_USER as modifier,
            GETDATE() as modified_date
        from dbo.VeoSolutionsSecurity_organizations o 
            left join dbo.Theme t on o.theme_lookup_key = t.LookupKey
        where t.Name <> ''Default'' and t.Name is not null ) as source on target.organization_id = source.organization_id 
                                                         and target.feature_id = source.feature_id
    when matched then 
        update set target.[value] = source.[value],
                   target.modifier = source.modifier,
                   target.modified_date = source.modified_date
    when not matched then 
        insert (organization_id, feature_id, [value], author, create_date, modifier, modified_date)
        values (source.organization_id, source.feature_id, source.[value], source.author, source.created_date, source.modifier, source.modified_date);'


    exec sp_executesql @sql
    fetch next from @db_cursor into @db_name
end 
