
/*
*** 'DEV' DBS ***

USE [VeoSolutions_DEV]
use [VeoSolutions_QA]
use [VeoSolutions_Staging]
use [VeoSolutions_Preview]

*** Prod DBS ***

use [AFI_VEOSolutions]
use [CCDI_VEOSolutions]
use [EPLAN_VEOSolutions]
use [VEOSolutions]

*/

merge [dbo].[ThemeVariable] as tgt 
using (
    values
        ('3f2504e0-4f89-11d3-9a0c-0305e82c3301', 'color-banner-text', NULL, 'Justin Pope', getdate(), 'Justin Pope', getdate()),
        ('9a0c0305-e82c-3301-3f25-04e04f8911d3', 'bg-banner', NULL, 'Justin Pope', getdate(), 'Justin Pope', getdate()),
        ('4f8911d3-3f25-04e0-9a0c-0305e82c3301', 'color-beta-sup', NULL, 'Justin Pope', getdate(), 'Justin Pope', getdate())
) as scr (Id, CssName, TargetThemeLookupKey, Author, CreateDate, Modifier, ModifiedDate) on tgt.Id = scr.Id 
when matched then 
    update set tgt.CssName = scr.CssName, tgt.TargetThemeLookupKey = scr.TargetThemeLookupKey, tgt.Author = scr.Author, tgt.CreateDate = scr.CreateDate, tgt.Modifier = scr.Modifier, tgt.ModifiedDate = scr.ModifiedDate
when not matched then 
    insert (Id, CssName, TargetThemeLookupKey, Author, CreateDate, Modifier, ModifiedDate) values (scr.Id, scr.CssName, scr.TargetThemeLookupKey, scr.Author, scr.CreateDate, scr.Modifier, scr.ModifiedDate);

merge into [dbo].[ThemeVariableValue] as tgt
using (
    values ('3f2504e0-4f89-11d3-9a0c-0305e82c3301', 'default', '#000'),
           ('3f2504e0-4f89-11d3-9a0c-0305e82c3301', 'wild', '#ff00ff'),
           ('9a0c0305-e82c-3301-3f25-04e04f8911d3', 'default', '#05a76c'),
           ('9a0c0305-e82c-3301-3f25-04e04f8911d3', 'wild', '#00ff00'),
           ('4f8911d3-3f25-04e0-9a0c-0305e82c3301', 'default', '#118e5c'),
           ('4f8911d3-3f25-04e0-9a0c-0305e82c3301', 'wild', '#ff0000')
) as scr (ThemeVariableId, ThemeLookupKey, Value) on tgt.ThemeVariableId = scr.ThemeVariableId and tgt.ThemeLookupKey = scr.ThemeLookupKey
when matched then 
    update set tgt.Value = scr.Value
when not matched then 
    insert (Id, ThemeVariableId, ThemeLookupKey, Value, Author, CreateDate, Modifier, ModifiedDate) 
    values (NEWID(), scr.ThemeVariableId, scr.ThemeLookupKey, scr.Value, 'Justin Pope', getdate(), 'Justin Pope', getdate());