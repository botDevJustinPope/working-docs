declare @org_name_seacrch_pattern nvarchar(500) = '%taylor%morrison%';

with [source] as (
    select 
        dev_org.organization_id,
        bf.feature_id,
        bf.value,
        'justinpo@buildontechnologies.com' as [user],
        getdate() as [dateTime]
    from  [VeoSolutions_dev].[dbo].[vss_organizations] dev_org
    left join [VeoSolutions_QA].[dbo].[vss_organizations] qa_org on dev_org.[name] = qa_org.[name]
    left join  [VeoSolutions_QA].dbo.builder_features bf on bf.organization_id = qa_org.organization_id
    inner join [VeoSolutions_DEV].dbo.features f on f.id = bf.feature_id 
where dev_org.[name] like @org_name_seacrch_pattern )

merge into [VeoSolutions_dev].dbo.builder_features as target
using [source] as source on source.organization_id = target.organization_id and source.feature_id = target.feature_id
when matched then 
    update set target.value = source.value,
               target.[modifier] = source.[user],
               target.[modified_date] = source.[dateTime]
when not matched by target then 
    insert (organization_id, feature_id, [value], [author], [create_date], [modifier], [modified_date]) 
    values (source.organization_id, source.feature_id, source.value, source.[user], source.[dateTime], source.[user], source.[dateTime]);