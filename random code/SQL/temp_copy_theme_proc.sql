DECLARE @ThemeId UNIQUEIDENTIFIER = 'd4d24aa9-974d-455a-b7a2-d3fe77c0247b';




merge VeoSolutions_QA.dbo.Theme as target
using VeoSolutions_DEV.dbo.Theme as source on source.Id = target.Id 
                                         and source.Id = @ThemeId
when not matched by target THEN
    INSERT (Id, LookupKey, Name, Description, CssClass, Author, BaseThemeId, CreateDate, ModifiedDate, Modifier)
    VALUES (source.Id, source.LookupKey, source.Name, source.Description, source.CssClass, source.Author, source.BaseThemeId, source.CreateDate, source.ModifiedDate, source.Modifier)
when matched then 
    update set 
        target.LookupKey = source.LookupKey,
        target.Name = source.Name,
        target.Description = source.Description,
        target.CssClass = source.CssClass,
        target.BaseThemeId = source.BaseThemeId,
        target.ModifiedDate = source.ModifiedDate,
        target.Modifier = source.Modifier;

merge VeoSolutions_QA.dbo.ThemeableVariableValue as target 
using VeoSolutions_DEV.dbo.ThemeableVariableValue as source on source.ThemeId = target.ThemeId 
                                                        and source.ThemeableVariableId = target.ThemeableVariableId
                                                        and source.ThemeId = @ThemeId
when not matched by target THEN
    INSERT (ThemeId, ThemeableVariableId, Value, Author, CreateDate, ModifiedDate, Modifier)
    VALUES (source.ThemeId, source.ThemeableVariableId, source.Value, source.Author, source.CreateDate, source.ModifiedDate, source.Modifier)
when matched then
    update set 
        target.Value = source.Value,
        target.ModifiedDate = source.ModifiedDate,
        target.Modifier = source.Modifier
when not matched by source and target.ThemeId = @ThemeId THEN
    DELETE;

merge VeoSolutions_QA.dbo.ThemeableGroupVariableValue as TARGET
using VeoSolutions_DEV.dbo.ThemeableGroupVariableValue as SOURCE on SOURCE.ThemeId = TARGET.ThemeId 
                                                                and SOURCE.ThemeableGroupVariableId = TARGET.ThemeableGroupVariableId
                                                                and SOURCE.ThemeId = @ThemeId
when not matched by TARGET then 
    INSERT (ThemeId, ThemeableGroupVariableId, Value, Author, CreateDate, ModifiedDate, Modifier)
    VALUES (SOURCE.ThemeId, SOURCE.ThemeableGroupVariableId, SOURCE.Value, SOURCE.Author, SOURCE.CreateDate, SOURCE.ModifiedDate, SOURCE.Modifier)
when matched then 
    update set 
        TARGET.Value = SOURCE.Value,
        TARGET.ModifiedDate = SOURCE.ModifiedDate,
        TARGET.Modifier = SOURCE.Modifier
when not matched by source and target.ThemeId = @ThemeId THEN
    DELETE;

merge VeoSolutions_QA.dbo.ThemeablePaletteVariableValue as TARGET
using VeoSolutions_DEV.dbo.ThemeablePaletteVariableValue as SOURCE on SOURCE.ThemeId = TARGET.ThemeId 
                                                                  and SOURCE.ThemeablePaletteVariableId = TARGET.ThemeablePaletteVariableId
                                                                  and SOURCE.ThemeId = @ThemeId
when not matched by TARGET then 
    INSERT (ThemeId, ThemeablePaletteVariableId, Value, Author, CreateDate, ModifiedDate, Modifier)
    VALUES (SOURCE.ThemeId, SOURCE.ThemeablePaletteVariableId, SOURCE.Value, SOURCE.Author, SOURCE.CreateDate, SOURCE.ModifiedDate, SOURCE.Modifier)
when matched then 
    update set 
        TARGET.Value = SOURCE.Value,
        TARGET.ModifiedDate = SOURCE.ModifiedDate,
        TARGET.Modifier = SOURCE.Modifier
when not matched by source and target.ThemeId = @ThemeId THEN
    DELETE;