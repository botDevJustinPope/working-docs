use [VeoSolutionsSecurity]
go

/*
    VeoSolutionsSecurity Tables
        - organization_images
        - organization_images_categories
*/

create table [dbo].[organization_images_categories]
( 
	[category] VARCHAR(50) NOT NULL,
	[name] VARCHAR(50) NOT NULL,
	[description] VARCHAR(250) NOT NULL,
	CONSTRAINT [PK_organizations_images_categories] PRIMARY KEY CLUSTERED ([category]),
);
go 

/***********************************************************************************
    Populate organization_images_categories
************************************************************************************/
MERGE [dbo].[organization_images_categories] AS TGT
USING (
	values ('MISSING_IMAGE', 'Missing Image', 'Image utilized when there is not a product image to display.'),
	       ('PRIMARY_LOGO', 'Primary Logo', 'This logo is to be utilized within the context of the builder within the VDS application.')
) AS SRC ([category], [name], [description]) on TGT.[category] = SRC.[category]
WHEN NOT MATCHED BY TARGET THEN 
	INSERT ([category], [name], [description]) 
	VALUES (SRC.[category], SRC.[name], SRC.[description])
WHEN MATCHED THEN
	UPDATE
		SET TGT.[name] = SRC.[name],
			TGT.[description] = SRC.[description]
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

GO

/*
    Foreign Key
        - organization_images
    Note: creatation and check
*/

ALTER TABLE [dbo].[organization_images]  WITH CHECK ADD  CONSTRAINT [FK_organization_images_category] FOREIGN KEY([category])
REFERENCES [dbo].[organization_images_categories] ([category])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[organization_images] CHECK CONSTRAINT [FK_organization_images_category]
go

USE [VeoSolutions]
GO

/*
    VeoSolutions Synonyms
        - organization_images
        - organization_images_categories
*/

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images] FOR [VeoSolutionsSecurity].[dbo].[organization_images]
GO

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category] FOR [VeoSolutionsSecurity].[dbo].[organization_images_categories]
GO

/*
    VeoSolutions Procedure
        - vds_selCustomerLogo
*/

/*
================================================================================================
author: 		n/a
create date: 	n/a
descrition: 	Store Procedure to get customer logo
================================================================================================
modifier: 		Justin Pope
modified on: 	2024-12-05
description: 	looking at organization images instead of customer table
================================================================================================
select top 5 id from VEOSolutionsSecurity_DEV.dbo.organizations

================================================================================================
*/
alter procedure [dbo].[vds_selCustomerLogo]
-- declare @account_id uniqueidentifier = 'BAB32B7E-3ADA-497C-862E-E5083971CC59'
@organization_id uniqueidentifier = '3bf05014-1588-4942-94fd-7706ecb2cee2'
as

-- select top 1 * from veosolutionssecurity_users_login_sessions 
-- select external_organization_id from veosolutionssecurity_organizations where organization_id = @organization_id

select 
	oi.image_data
from 
	[VeoSolutionsSecurity_organizations] o
	inner join [VeoSolutionsSecurity_organization_images] oi on o.organization_id = oi.organization_id
	inner join [VeoSolutionsSecurity_organization_images_categories] oic on oi.category = oic.category
																		AND oic.category = 'PRIMARY_LOGO'
where 
	o.organization_id = @organization_id
GO

/*
    Populate organization_images from ECHELON customers table
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
go

use [AFI_VeoSolutionsSecurity]
go

/*
    VeoSolutionsSecurity Tables
        - organization_images
        - organization_images_categories
*/

create table [dbo].[organization_images_categories]
( 
	[category] VARCHAR(50) NOT NULL,
	[name] VARCHAR(50) NOT NULL,
	[description] VARCHAR(250) NOT NULL,
	CONSTRAINT [PK_organizations_images_categories] PRIMARY KEY CLUSTERED ([category]),
);
go 

/***********************************************************************************
    Populate organization_images_categories
************************************************************************************/
MERGE [dbo].[organization_images_categories] AS TGT
USING (
	values ('MISSING_IMAGE', 'Missing Image', 'Image utilized when there is not a product image to display.'),
	       ('PRIMARY_LOGO', 'Primary Logo', 'This logo is to be utilized within the context of the builder within the VDS application.')
) AS SRC ([category], [name], [description]) on TGT.[category] = SRC.[category]
WHEN NOT MATCHED BY TARGET THEN 
	INSERT ([category], [name], [description]) 
	VALUES (SRC.[category], SRC.[name], SRC.[description])
WHEN MATCHED THEN
	UPDATE
		SET TGT.[name] = SRC.[name],
			TGT.[description] = SRC.[description]
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

GO

/*
    Foreign Key
        - organization_images
    Note: creatation and check
*/

ALTER TABLE [dbo].[organization_images]  WITH CHECK ADD  CONSTRAINT [FK_organization_images_category] FOREIGN KEY([category])
REFERENCES [dbo].[organization_images_categories] ([category])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[organization_images] CHECK CONSTRAINT [FK_organization_images_category]
go

USE [AFI_VeoSolutions]
GO

/*
    AFI_VeoSolutions Synonyms
        - organization_images
        - organization_images_categories
*/

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images] FOR [AFI_VeoSolutionsSecurity].[dbo].[organization_images]
GO

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category] FOR [AFI_VeoSolutionsSecurity].[dbo].[organization_images_categories]
GO

/*
    AFI_VeoSolutions Procedure
        - vds_selCustomerLogo
*/

/*
================================================================================================
author: 		n/a
create date: 	n/a
descrition: 	Store Procedure to get customer logo
================================================================================================
modifier: 		Justin Pope
modified on: 	2024-12-05
description: 	looking at organization images instead of customer table
================================================================================================
select top 5 id from VEOSolutionsSecurity_DEV.dbo.organizations

================================================================================================
*/
alter procedure [dbo].[vds_selCustomerLogo]
-- declare @account_id uniqueidentifier = 'BAB32B7E-3ADA-497C-862E-E5083971CC59'
@organization_id uniqueidentifier = '3bf05014-1588-4942-94fd-7706ecb2cee2'
as

-- select top 1 * from veosolutionssecurity_users_login_sessions 
-- select external_organization_id from veosolutionssecurity_organizations where organization_id = @organization_id

select 
	oi.image_data
from 
	[VeoSolutionsSecurity_organizations] o
	inner join [VeoSolutionsSecurity_organization_images] oi on o.organization_id = oi.organization_id
	inner join [VeoSolutionsSecurity_organization_images_categories] oic on oi.category = oic.category
																		AND oic.category = 'PRIMARY_LOGO'
where 
	o.organization_id = @organization_id
GO

/*
    Populate organization_images from ECHELON customers table
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
go

use [CCDI_VeoSolutionsSecurity]
go

/*
    CCDI_VeoSolutionsSecurity Tables
        - organization_images
        - organization_images_categories
*/

create table [dbo].[organization_images_categories]
( 
	[category] VARCHAR(50) NOT NULL,
	[name] VARCHAR(50) NOT NULL,
	[description] VARCHAR(250) NOT NULL,
	CONSTRAINT [PK_organizations_images_categories] PRIMARY KEY CLUSTERED ([category]),
);
go 

/*
    Populate organization_images_categories
*/
MERGE [dbo].[organization_images_categories] AS TGT
USING (
	values ('MISSING_IMAGE', 'Missing Image', 'Image utilized when there is not a product image to display.'),
	       ('PRIMARY_LOGO', 'Primary Logo', 'This logo is to be utilized within the context of the builder within the VDS application.')
) AS SRC ([category], [name], [description]) on TGT.[category] = SRC.[category]
WHEN NOT MATCHED BY TARGET THEN 
	INSERT ([category], [name], [description]) 
	VALUES (SRC.[category], SRC.[name], SRC.[description])
WHEN MATCHED THEN
	UPDATE
		SET TGT.[name] = SRC.[name],
			TGT.[description] = SRC.[description]
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

GO

/*
    Foreign Key
        - organization_images
    Note: creatation and check
*/

ALTER TABLE [dbo].[organization_images]  WITH CHECK ADD  CONSTRAINT [FK_organization_images_category] FOREIGN KEY([category])
REFERENCES [dbo].[organization_images_categories] ([category])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[organization_images] CHECK CONSTRAINT [FK_organization_images_category]
go

USE [CCDI_VeoSolutions]
GO

/*
    CCDI_VeoSolutions Synonyms
        - organization_images
        - organization_images_categories
*/

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images] FOR [CCDI_VeoSolutionsSecurity].[dbo].[organization_images]
GO

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category] FOR [CCDI_VeoSolutionsSecurity].[dbo].[organization_images_categories]
GO

/*
    CCDI_VeoSolutions Procedure
        - vds_selCustomerLogo
*/

/*
================================================================================================
author: 		n/a
create date: 	n/a
descrition: 	Store Procedure to get customer logo
================================================================================================
modifier: 		Justin Pope
modified on: 	2024-12-05
description: 	looking at organization images instead of customer table
================================================================================================
select top 5 id from VEOSolutionsSecurity_DEV.dbo.organizations

================================================================================================
*/
alter procedure [dbo].[vds_selCustomerLogo]
-- declare @account_id uniqueidentifier = 'BAB32B7E-3ADA-497C-862E-E5083971CC59'
@organization_id uniqueidentifier = '3bf05014-1588-4942-94fd-7706ecb2cee2'
as

-- select top 1 * from veosolutionssecurity_users_login_sessions 
-- select external_organization_id from veosolutionssecurity_organizations where organization_id = @organization_id

select 
	oi.image_data
from 
	[VeoSolutionsSecurity_organizations] o
	inner join [VeoSolutionsSecurity_organization_images] oi on o.organization_id = oi.organization_id
	inner join [VeoSolutionsSecurity_organization_images_categories] oic on oi.category = oic.category
																		AND oic.category = 'PRIMARY_LOGO'
where 
	o.organization_id = @organization_id
GO

/*
    Populate organization_images from ECHELON customers table
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
go

use [EPLAN_VeoSolutionsSecurity]
go

/*
    EPLAN_VeoSolutionsSecurity Tables
        - organization_images
        - organization_images_categories
*/

create table [dbo].[organization_images_categories]
( 
	[category] VARCHAR(50) NOT NULL,
	[name] VARCHAR(50) NOT NULL,
	[description] VARCHAR(250) NOT NULL,
	CONSTRAINT [PK_organizations_images_categories] PRIMARY KEY CLUSTERED ([category]),
);
go 

/*
    Populate organization_images_categories
*/
MERGE [dbo].[organization_images_categories] AS TGT
USING (
	values ('MISSING_IMAGE', 'Missing Image', 'Image utilized when there is not a product image to display.'),
	       ('PRIMARY_LOGO', 'Primary Logo', 'This logo is to be utilized within the context of the builder within the VDS application.')
) AS SRC ([category], [name], [description]) on TGT.[category] = SRC.[category]
WHEN NOT MATCHED BY TARGET THEN 
	INSERT ([category], [name], [description]) 
	VALUES (SRC.[category], SRC.[name], SRC.[description])
WHEN MATCHED THEN
	UPDATE
		SET TGT.[name] = SRC.[name],
			TGT.[description] = SRC.[description]
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

GO

/*
    Foreign Key
        - organization_images
    Note: creatation and check
*/

ALTER TABLE [dbo].[organization_images]  WITH CHECK ADD  CONSTRAINT [FK_organization_images_category] FOREIGN KEY([category])
REFERENCES [dbo].[organization_images_categories] ([category])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[organization_images] CHECK CONSTRAINT [FK_organization_images_category]
go

USE [EPLAN_VeoSolutions]
GO

/*
    EPLAN_VeoSolutions Synonyms
        - organization_images
        - organization_images_categories
*/

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images] FOR [EPLAN_VeoSolutionsSecurity].[dbo].[organization_images]
GO

CREATE SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category] FOR [EPLAN_VeoSolutionsSecurity].[dbo].[organization_images_categories]
GO

/*
    EPLAN_VeoSolutions Procedure
        - vds_selCustomerLogo
*/

/*
================================================================================================
author: 		n/a
create date: 	n/a
descrition: 	Store Procedure to get customer logo
================================================================================================
modifier: 		Justin Pope
modified on: 	2024-12-05
description: 	looking at organization images instead of customer table
================================================================================================
select top 5 id from VEOSolutionsSecurity_DEV.dbo.organizations

================================================================================================
*/
alter procedure [dbo].[vds_selCustomerLogo]
-- declare @account_id uniqueidentifier = 'BAB32B7E-3ADA-497C-862E-E5083971CC59'
@organization_id uniqueidentifier = '3bf05014-1588-4942-94fd-7706ecb2cee2'
as

-- select top 1 * from veosolutionssecurity_users_login_sessions 
-- select external_organization_id from veosolutionssecurity_organizations where organization_id = @organization_id

select 
	oi.image_data
from 
	[VeoSolutionsSecurity_organizations] o
	inner join [VeoSolutionsSecurity_organization_images] oi on o.organization_id = oi.organization_id
	inner join [VeoSolutionsSecurity_organization_images_categories] oic on oi.category = oic.category
																		AND oic.category = 'PRIMARY_LOGO'
where 
	o.organization_id = @organization_id
GO

/*
    Populate organization_images from ECHELON customers table
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
go