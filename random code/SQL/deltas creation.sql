
insert into [master].[dbo].[JKP_ThemeVariableValue_Deltas]
select 
    t1.[Theme] as [Theme],
    t1.CssName as [SourceVariable],
    t1.Value as [SourceValue],
    t2.CssName as [TargetVariable],
    t2.Value as [TargetValue],
    SQRT(POWER(t1.H - t2.H, 2)) as [HDelta],
    SQRT(POWER(t1.S - t2.S, 2)) as [SDelta],
    SQRT(POWER(t1.L - t2.L, 2)) as [LDelta],
    SQRT(POWER(t1.R - t2.R, 2)) as [RDelta],
    SQRT(POWER(t1.G - t2.G, 2)) as [GDelta],
    SQRT(POWER(t1.B - t2.B, 2)) as [BDelta]
from [master].[dbo].[JKP_ThemeVariableValue_JustColors] t1
    left join [master].[dbo].[JKP_ThemeVariableValue_JustColors] t2 on t1.CssName <> t2.CssName




