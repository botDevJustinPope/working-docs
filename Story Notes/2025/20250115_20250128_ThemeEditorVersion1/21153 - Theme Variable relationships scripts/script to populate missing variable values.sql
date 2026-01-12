--select * from VeoSolutions_DEV.dbo.theme
drop table if exists #themeDefault;
go

select 
    tvv.Id,
    tvv.ThemeLookupKey,
    tvv.ThemeVariableId,
    tvv.Value
into #themeDefault
from VeoSolutions_DEV.dbo.Theme t
    inner join VeoSolutions_DEV.dbo.ThemeVariableValue tvv on t.LookupKey = tvv.ThemeLookupKey 
    inner join VeoSolutions_DEV.dbo.ThemeVariable tv on tv.Id = tvv.ThemeVariableId
where t.LookupKey = 'default';
go

select 
    ThemeLookupKey,
    count([Value]) as [Count]
from VeoSolutions_DEV.dbo.ThemeVariableValue
group by ThemeLookupKey



SELECT 
    t.LookupKey,
    count(d.[Value]) as [Count]
from #themeDefault d
    inner join VeoSolutions_DEV.dbo.ThemeVariable tv on tv.Id = d.ThemeVariableId
    inner join VeoSolutions_DEV.dbo.Theme t on t.LookupKey <> d.ThemeLookupKey
    left join VeoSolutions_DEV.dbo.ThemeVariableValue tvv on tvv.ThemeLookupKey = t.LookupKey
                                                        and tvv.ThemeVariableId = d.ThemeVariableId
where tvv.ThemeVariableId is null
group by t.LookupKey