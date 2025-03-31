declare @ThemeId UNIQUEIDENTIFIER = '10a814cc-bad9-42b3-b7bd-1d0ba438b3b9';

select 
    [base].ThemeId,
    [base].Theme_Name,
    [base].ThemeableVariableId,
    [base].Variable_Name,
    [dev_values].Value as [Dev_Value],
    [dev_values].modifier as [Dev_Modifier],
    [dev_values].modifieddate as [Dev_ModifiedDate],
    [qa_values].Value as [QA_Value],
    [qa_values].modifier as [QA_Modifier],
    [qa_values].modifieddate as [QA_ModifiedDate],
    [preview_values].Value as [Preview_Value],
    [preview_values].modifier as [Preview_Modifier],
    [preview_values].modifieddate as [Preview_ModifiedDate],
    [staging_values].Value as [Staging_Value],
    [staging_values].modifier as [Staging_Modifier],
    [staging_values].modifieddate as [Staging_ModifiedDate],
    [WBS_values].[Value] as [WBS_Value],
    [WBS_values].[modifier] as [WBS_Modifier],
    [WBS_values].[modifieddate] as [WBS_ModifiedDate],
    [AFI_values].[Value] as [AFI_Value],
    [AFI_values].[modifier] as [AFI_Modifier],
    [AFI_values].[modifieddate] as [AFI_ModifiedDate],
    [EPLAN_values].[Value] as [EPLAN_Value],
    [EPLAN_values].[modifier] as [EPLAN_Modifier],
    [EPLAN_values].[modifieddate] as [EPLAN_ModifiedDate],
    [CCDI_values].[Value] as [CCDI_Value],
    [CCDI_values].[modifier] as [CCDI_Modifier],
    [CCDI_values].[modifieddate] as [CCDI_ModifiedDate]
from (
        select 
            t.Id as [ThemeId],
            t.[Name] as [Theme_Name],
            tv.Id as [ThemeableVariableId],
            tv.[CssName] as [Variable_Name]
        from VeoSolutions_DEV.dbo.Theme t
            inner join VeoSolutions_DEV.dbo.ThemeableVariable tv on 1=1
        where t.Id = @ThemeId
            and tv.CssName = 'btn-secondary' ) [base]    
    outer APPLY (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
        select 
            tvv.[Value] as [Value], 
            tvv.[modifier],
            tvv.[modifieddate],
            1 as [rank]
        from VeoSolutions_DEV.dbo.ThemeableVariableValue tvv
        where tvv.ThemeId = [base].ThemeId
            and tvv.ThemeableVariableId = [base].ThemeableVariableId
        UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
        order by r.[rank] desc ) [dev_values]
    outer APPLY (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
            select 
                tvv.[Value] as [Value], 
                tvv.[modifier],
                tvv.[modifieddate],
                1 as [rank]
            from VeoSolutions_QA.dbo.ThemeableVariableValue tvv
            where tvv.ThemeId = [base].ThemeId
                and tvv.ThemeableVariableId = [base].ThemeableVariableId
            UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
            order by r.[rank] desc ) [qa_values]
    outer APPLY (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
            select 
                tvv.[Value] as [Value], 
                tvv.[modifier],
                tvv.[modifieddate],
                1 as [rank]
            from VEOSolutions_PREVIEW.dbo.ThemeableVariableValue tvv
            where tvv.ThemeId = [base].ThemeId
                and tvv.ThemeableVariableId = [base].ThemeableVariableId
            UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
        order by r.[rank] desc ) [preview_values]
    outer APPLY (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
        select 
                tvv.[Value] as [Value], 
                tvv.[modifier],
                tvv.[modifieddate],
                1 as [rank]
        from VEOSolutions_STAGING.dbo.ThemeableVariableValue tvv
        where tvv.ThemeId = [base].ThemeId
            and tvv.ThemeableVariableId = [base].ThemeableVariableId
        UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
        order by r.[rank] desc ) [staging_values]
    outer apply (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
            select 
                tvv.[Value] as [Value], 
                tvv.[modifier],
                tvv.[modifieddate],
                1 as [rank]
            from [VDS_PROD].[VeoSolutions].dbo.ThemeableVariableValue tvv
            where tvv.ThemeId = [base].ThemeId
                and tvv.ThemeableVariableId = [base].ThemeableVariableId
            UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
        order by r.[rank] desc ) [WBS_values]
    outer apply (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
            select 
                tvv.[Value] as [Value], 
                tvv.[modifier],
                tvv.[modifieddate],
                1 as [rank]
            from [VDS_PROD].[EPLAN_VeoSolutions].dbo.ThemeableVariableValue tvv
            where tvv.ThemeId = [base].ThemeId
                and tvv.ThemeableVariableId = [base].ThemeableVariableId
            UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
        order by r.[rank] desc ) [EPLAN_values]
    outer apply (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
            select 
                tvv.[Value] as [Value], 
                tvv.[modifier],
                tvv.[modifieddate],
                1 as [rank]
            from [VDS_PROD].[CCDI_VeoSolutions].dbo.ThemeableVariableValue tvv
            where tvv.ThemeId = [base].ThemeId
                and tvv.ThemeableVariableId = [base].ThemeableVariableId
            UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
        order by r.[rank] desc ) [CCDI_values]
    outer apply (
        select top 1
            r.[Value],
            r.[modifier],
            r.[modifieddate]
        from (
            select 
                tvv.[Value] as [Value], 
                tvv.[modifier],
                tvv.[modifieddate],
                1 as [rank]
            from [VDS_PROD].[AFI_VeoSolutions].dbo.ThemeableVariableValue tvv
            where tvv.ThemeId = [base].ThemeId
                and tvv.ThemeableVariableId = [base].ThemeableVariableId
            UNION
            select 'null value' as [Value], 
            'n/a' as [modifier],
            null as [modifieddate],
            0 as [rank] ) r
        order by r.[rank] desc ) [AFI_values]