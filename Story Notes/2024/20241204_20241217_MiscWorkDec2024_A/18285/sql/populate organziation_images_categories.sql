
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

/***********************************************************************************
dbo.organization_images_categories
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