
insert into VeoSolutionsSecurity_dev.dbo.organization_images
select 
    newid() as [id],
	[org].[organization_id] as [organization_id],
    'BUILDER_LOGO' as [category],
    'image/jpeg' as [file_type],
    [cust].[image_data] as [image_data],
    CURRENT_USER as [author],
    GETDATE() as [created_date],
    CURRENT_USER as [modifier],
    GETDATE() as [modified_date]
from VeoSolutionsSecurity_DEV.dbo.organizations [org]
	inner join [Veo_DEV].[dbo].[customers] [cust] on [cust].[custnmbr] = [org].[external_organization_id]
where [cust].[image_data] is not null