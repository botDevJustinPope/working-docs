/*
Run this script on:

        sql.veodesignstudio.com.VEOSolutions    -  This database will be modified

to synchronize it with:

        dev-sql.veodesignstudio.com.VEOSolutions_STAGING

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.1.27450 from Red Gate Software Ltd at 8/15/2025 9:44:48 AM

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping constraints from [dbo].[AareasRenderableProduct]'
GO
ALTER TABLE [dbo].[AareasRenderableProduct] DROP CONSTRAINT [PK_AareasRenderableProduct]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[sp_BlitzCache]'
GO
DROP PROCEDURE [dbo].[sp_BlitzCache]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[themevariable_backup12042024]'
GO
DROP TABLE [dbo].[themevariable_backup12042024]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[themevaraiblevalue_backup12042024]'
GO
DROP TABLE [dbo].[themevaraiblevalue_backup12042024]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[AareasRenderableProduct]'
GO
DROP TABLE [dbo].[AareasRenderableProduct]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vf_IgnoreUsers]'
GO
DROP FUNCTION [dbo].[vf_IgnoreUsers]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selVisualizationErrorReport]'
GO
DROP PROCEDURE [dbo].[vds_selVisualizationErrorReport]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vdsf_selAddedBuilderFlagsFromVeoSolutions]'
GO
DROP FUNCTION [dbo].[vdsf_selAddedBuilderFlagsFromVeoSolutions]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selEstimatedArea]'
GO
DROP PROCEDURE [dbo].[vds_selEstimatedArea]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selEstimatedAreasWizard]'
GO
DROP PROCEDURE [dbo].[vds_selEstimatedAreasWizard]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selEstimatedAreaSelections]'
GO
DROP PROCEDURE [dbo].[vds_selEstimatedAreaSelections]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selEstimatedAreasBySession]'
GO
DROP PROCEDURE [dbo].[vds_selEstimatedAreasBySession]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vs_rptUnsentInvoices]'
GO
DROP PROCEDURE [dbo].[vs_rptUnsentInvoices]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_getNonestimatedApplication]'
GO
DROP PROCEDURE [dbo].[vds_getNonestimatedApplication]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selLegacyRole]'
GO
DROP PROCEDURE [dbo].[vds_selLegacyRole]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selGpcProduct]'
GO
DROP PROCEDURE [dbo].[vds_selGpcProduct]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[tvf_selFirstLastAppointmentDate]'
GO
DROP FUNCTION [dbo].[tvf_selFirstLastAppointmentDate]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[po_getSystemUsage]'
GO
DROP PROCEDURE [dbo].[po_getSystemUsage]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[integration_revenuePrediction_tst]'
GO
DROP PROCEDURE [dbo].[integration_revenuePrediction_tst]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_getArea]'
GO
DROP PROCEDURE [dbo].[vds_getArea]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_authorizeApiKey]'
GO
DROP PROCEDURE [dbo].[vds_authorizeApiKey]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selCheckStaggeredCustomerBySession]'
GO
DROP PROCEDURE [dbo].[vds_selCheckStaggeredCustomerBySession]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_getDoesEmailExistInSpecifiedBuilder]'
GO
DROP PROCEDURE [dbo].[vds_getDoesEmailExistInSpecifiedBuilder]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vs_selDCSessionsAndInvoices]'
GO
DROP PROCEDURE [dbo].[vs_selDCSessionsAndInvoices]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_getDoesEmailExistInDifferentBuilder]'
GO
DROP PROCEDURE [dbo].[vds_getDoesEmailExistInDifferentBuilder]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_getAccountIdByOrganizationId]'
GO
DROP PROCEDURE [dbo].[vds_getAccountIdByOrganizationId]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vdsv_selAddedBuilderFlagsFromVeoSolutions]'
GO
DROP VIEW [dbo].[vdsv_selAddedBuilderFlagsFromVeoSolutions]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selEstimatedAreasWizardBuildData]'
GO
DROP PROCEDURE [dbo].[vds_selEstimatedAreasWizardBuildData]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_updHomebuyer]'
GO
DROP PROCEDURE [dbo].[vds_updHomebuyer]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selAllPlansForProfile]'
GO
DROP PROCEDURE [dbo].[vds_selAllPlansForProfile]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selNonCreditAreaBuildsByApplication]'
GO
DROP PROCEDURE [dbo].[vds_selNonCreditAreaBuildsByApplication]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vdsf_getAreaFieldPercentageType]'
GO
DROP FUNCTION [dbo].[vdsf_getAreaFieldPercentageType]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selBuyerSurveyResponses]'
GO
DROP PROCEDURE [dbo].[vds_selBuyerSurveyResponses]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vdsf_getAreaFieldPercentage]'
GO
DROP FUNCTION [dbo].[vdsf_getAreaFieldPercentage]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vdsf_getbuilderMarkupHBPricing]'
GO
DROP FUNCTION [dbo].[vdsf_getbuilderMarkupHBPricing]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_get_restricted_application_product_by_applicationid_and_productid]'
GO
DROP PROCEDURE [dbo].[vds_get_restricted_application_product_by_applicationid_and_productid]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_get_all_restricted_application_product]'
GO
DROP PROCEDURE [dbo].[vds_get_all_restricted_application_product]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_delete_restricted_application_product]'
GO
DROP PROCEDURE [dbo].[vds_delete_restricted_application_product]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selPriceLevelFiltersFromOptionPricing]'
GO
DROP PROCEDURE [dbo].[vds_selPriceLevelFiltersFromOptionPricing]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[dev_buyerReadinessScore]'
GO
DROP PROCEDURE [dbo].[dev_buyerReadinessScore]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_getAllAreas]'
GO
DROP PROCEDURE [dbo].[vds_getAllAreas]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selSpecCustomMaterialItems]'
GO
DROP PROCEDURE [dbo].[vds_selSpecCustomMaterialItems]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_updFirstVisitToDMH]'
GO
DROP PROCEDURE [dbo].[vds_updFirstVisitToDMH]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selSpecificProductOptionsAndPriceLevels]'
GO
DROP PROCEDURE [dbo].[vds_selSpecificProductOptionsAndPriceLevels]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_getDesignSessionWizardBuildData]'
GO
DROP PROCEDURE [dbo].[vds_getDesignSessionWizardBuildData]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vdsf_getAreaSelectionTotal]'
GO
DROP FUNCTION [dbo].[vdsf_getAreaSelectionTotal]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping [dbo].[vds_selSpecCustomEdgeItems]'
GO
DROP PROCEDURE [dbo].[vds_selSpecCustomEdgeItems]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
