use [VEOSolutionsSecurity_DEV];
go

create table [dbo].[organization_images_categories]
( 
	[category] VARCHAR(50) NOT NULL,
	[name] VARCHAR(50) NOT NULL,
	[description] VARCHAR(250) NOT NULL,
	CONSTRAINT [PK_organizations_images_categories] PRIMARY KEY CLUSTERED ([category]),
);
go 

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

select * from [dbo].[organization_images_categories];
select * from [dbo].[organization_images]