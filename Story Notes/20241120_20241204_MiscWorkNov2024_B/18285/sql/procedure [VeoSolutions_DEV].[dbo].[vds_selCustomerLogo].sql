
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
