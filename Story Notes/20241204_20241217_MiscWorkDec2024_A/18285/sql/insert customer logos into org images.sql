
/*
**** WARNING ****

NEW SYNONMYS FOR ORGANIZATION_IMAGES AND ORGANIZATION_IMAGES_CATEGORIES

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

merge VeoSolutionsSecurity_organization_images as [TARGET]
using (
    select 
        [org].[organization_id] as [organization_id],
        'PRIMARY_LOGO' as [category],
        'image/png' as [file_type],
        [cust].[image_data] as [image_data]
    from VeoSolutionsSecurity_organizations [org]
        inner join Veo_customers [cust] on [cust].[custnmbr] = [org].[external_organization_id]
    where [cust].[image_data] is not null ) as [SOURCE] on [TARGET].[organization_id] = [SOURCE].[organization_id] and [TARGET].[category] = [SOURCE].[category]
when matched then
    update set
        [TARGET].[file_type] = [SOURCE].[file_type],
        [TARGET].[image_data] = [SOURCE].[image_data],
        [TARGET].[modifier] = CURRENT_USER,
        [TARGET].[modified_date] = GETDATE()
when not matched then
    insert ([organization_id], [category], [file_type], [image_data], [id], [author], [created_date], [modifier], [modified_date])
    values ([SOURCE].[organization_id], [SOURCE].[category], [SOURCE].[file_type], [SOURCE].[image_data], NEWID(), CURRENT_USER, GETDATE(), CURRENT_USER, GETDATE());


