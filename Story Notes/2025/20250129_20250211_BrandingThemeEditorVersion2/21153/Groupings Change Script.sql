use VeoSolutions_DEV;
go

/*
select * from dbo.ThemeableVariable;
select * from dbo.ThemeableGroupVariable;
*/

/*
    1) process, set temp table with desired mappings that
    are to be changed or configured
    2.a) Guid of both VairableId and GroupVariableId utilize selects above if needed
    2.b) GroupVariableId is nullable if a VariableId should not be grouped
    2) merge on ThemableGroupVariableMapping
    2.a) updating esisting join on VariableId and updating the group
    2.b) inserting if VariableId is not present in group
    2.c) if VariableId is grouped and is moving to un-grouped, delete
*/
declare @strId1 as nvarchar(max) = '', @strId2 as nvarchar(max) = ''
declare @temp_Groupings as table (
    VariableId UNIQUEIDENTIFIER null,
    VariableCssName NVARCHAR(255) null,
    GroupVariableId UNIQUEIDENTIFIER null,
    GroupName NVARCHAR(255) null
);

insert into @temp_Groupings (VariableId, VariableCssName, GroupVariableId, GroupName)
values (null, 'textarea-bg', null, null),
       (null, 'filter-main-site-header', null, null);

-- based on input, confirm that the variables and groups exists and ensure that the ids are filled in

update g 
    set g.VariableId = v.Id 
from @temp_Groupings g 
    left join dbo.ThemeableVariable v on g.VariableCssName = v.CssName
where g.VariableId is null;

update g 
    set g.GroupVariableId = v.Id
from @temp_Groupings g
    left join dbo.ThemeableGroupVariable v on g.GroupName = v.[Name]
where g.GroupVariableId is null;

update g 
    set g.VariableCssName = v.CssName,
        g.GroupName = gv.[Name]
from @temp_Groupings g 
    left join dbo.ThemeableVariable v on g.VariableId = v.Id 
    left join dbo.ThemeableGroupVariable gv on gv.Id = g.GroupVariableId
where g.GroupVariableId is not null and g.VariableCssName is null;

declare @VariableId UNIQUEIDENTIFIER;
declare @GroupVariableId UNIQUEIDENTIFIER;
declare @VariableCssName NVARCHAR(255);
declare @GroupName NVARCHAR(255);
declare  ci cursor for select VariableId, VariableCssName, GroupVariableId, GroupName from @temp_Groupings;

open ci;
fetch next from ci into @VariableId, @VariableCssName, @GroupVariableId, @GroupName;
while @@fetch_status = 0
begin 
    select @GroupName = 'null'
    where @GroupName is NULL
    select @VariableCssName = 'null'
    where @VariableCssName is NULL

    if @VariableId is null
    begin 
        select 'Could not resolve VariableId for ' + @VariableCssName;
    end
    if @GroupVariableId is null and @GroupName <> 'null'
    begin 
        select 'Could not resolve GroupVariableId for ' + @GroupName;
    end
    if @GroupVariableId is not null and not exists(select * from dbo.ThemeableGroupVariable where Id = @GroupVariableId)
    begin 
        set @strId2 = coalesce(cast(@GroupVariableId as nvarchar(36)), 'null');
        Select 'GroupVariableId '+ @strId2 +' does not exist ';
    end
    if not exists(select * from dbo.ThemeableVariable where Id = @VariableId and @VariableId is not null)
    begin 
        set @strId1 = coalesce(cast(@VariableId as nvarchar(36)), 'null');
        Select 'VariableId '+ @strId1+' does not exist for ' + @VariableCssName;
    end
    if @VariableId is null or 
        (@GroupVariableId is null and @GroupName <> 'null') or 
        (not exists(select * from dbo.ThemeableGroupVariable where Id = @GroupVariableId) and @GroupVariableId is not null) or 
        (not exists(select * from dbo.ThemeableVariable where Id = @VariableId) and @VariableId is not null)
    begin
        set @strId2 = coalesce(cast(@GroupVariableId as nvarchar(36)), 'null');
        set @strId1 = coalesce(cast(@VariableId as nvarchar(36)), 'null');

        select 'Deleting row for VariableCssName: ' + @VariableCssName + ' and GroupName: ' + @GroupName + ' and VariableId: ' + @strId1 + ' and GroupVariableId: ' + @strId2;
        delete from @temp_Groupings where VariableId = @VariableId and GroupVariableId = @GroupVariableId and VariableCssName = @VariableCssName and GroupName = @GroupName;
    end

    fetch next from ci into @VariableId, @VariableCssName, @GroupVariableId, @GroupName;
end 
close ci;
deallocate ci;

merge dbo.ThemeableGroupVariableMapping as target 
using @temp_Groupings as source on target.ThemeableVariableId = source.VariableId
when matched and source.GroupVariableId is not null then 
    update set target.ThemeableGroupVariableId = source.GroupVariableId
when not matched and source.GroupVariableId is not null then 
    insert (ThemeableVariableId, ThemeableGroupVariableId) values (source.VariableId, source.GroupVariableId)
when matched and source.GroupVariableId is null then 
    delete;
    
declare s cursor for select VariableId, VariableCssName, GroupVariableId, GroupName from @temp_Groupings;
open s;
fetch next from s into @VariableId, @VariableCssName, @GroupVariableId, @GroupName;
while @@fetch_status = 0
begin 

    if @VariableId is not null and @GroupVariableId is null
    begin
        select 'Variable ' + @VariableCssName + ' is un-grouped';
    end
    if @VariableId is not null and @GroupVariableId is not null
    begin
        select 'Variable ' + @VariableCssName + ' is grouped in ' + @GroupName;
    end

    fetch next from s into @VariableId, @VariableCssName, @GroupVariableId, @GroupName;
end 
close s;
deallocate s;
