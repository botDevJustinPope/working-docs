
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

ALTER TABLE [dbo].[organization_images]  WITH CHECK ADD  CONSTRAINT [FK_organization_images_category] FOREIGN KEY([category])
REFERENCES [dbo].[organization_images_categories] ([category])
ON UPDATE CASCADE
ON DELETE CASCADE
GO