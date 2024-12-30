USE [VeoSolutions]
GO

if exists (select * from sys.synonyms where name = 'VeoSolutionsSecurity_organization_images_category')
    drop SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category];
GO

USE [AFI_VeoSolutions]
GO

if exists (select * from sys.synonyms where name = 'VeoSolutionsSecurity_organization_images_category')
    drop SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category];
GO

USE [CCDI_VeoSolutions]
GO

if exists (select * from sys.synonyms where name = 'VeoSolutionsSecurity_organization_images_category')
    drop SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category];
GO

USE [EPLAN_VeoSolutions]
GO

if exists (select * from sys.synonyms where name = 'VeoSolutionsSecurity_organization_images_category')
    drop SYNONYM [dbo].[VeoSolutionsSecurity_organization_images_category];
GO