/*
Run this script on:

        dev-sql.veodesignstudio.com.VEO_DEV    -  This database will be modified

to synchronize it with:

        dev-sql.veodesignstudio.com.WBS_Staging

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.1.27450 from Red Gate Software Ltd at 4/21/2026 10:55:22 AM

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
PRINT N'Dropping index [AK2RM00101] from [dbo].[RM00101]'
GO
DROP INDEX [AK2RM00101] ON [dbo].[RM00101]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[RM00101]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[RM00101] ALTER COLUMN [DEX_ROW_ID] ADD NOT FOR REPLICATION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [AK2RM00101] on [dbo].[RM00101]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK2RM00101] ON [dbo].[RM00101] ([CUSTNAME], [DEX_ROW_ID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_IV00103_ITEMNMBR_ITMVNTY_includes] on [dbo].[IV00103]'
GO
CREATE NONCLUSTERED INDEX [IX_IV00103_ITEMNMBR_ITMVNTY_includes] ON [dbo].[IV00103] ([ITEMNMBR], [ITMVNDTY]) INCLUDE ([VNDITNUM])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [ix_iv00103_itemnmbr_vendorid_includes] on [dbo].[IV00103]'
GO
CREATE NONCLUSTERED INDEX [ix_iv00103_itemnmbr_vendorid_includes] ON [dbo].[IV00103] ([ITEMNMBR], [VENDORID]) INCLUDE ([VNDITNUM])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dbo].[cabinet_colors]'
GO
ALTER TABLE [dbo].[cabinet_colors] ADD CONSTRAINT [UQ_color_name] UNIQUE NONCLUSTERED ([color_name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dbo].[cabinet_door_styles]'
GO
ALTER TABLE [dbo].[cabinet_door_styles] ADD CONSTRAINT [UQ_door_style_name] UNIQUE NONCLUSTERED ([name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[accent_per_sqft]'
GO
ALTER TABLE [dbo].[accent_per_sqft] ADD CONSTRAINT [fk_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[application_products]'
GO
ALTER TABLE [dbo].[application_products] ADD CONSTRAINT [FK_application_products_applications] FOREIGN KEY ([application_id]) REFERENCES [dbo].[applications] ([application_id])
GO
ALTER TABLE [dbo].[application_products] ADD CONSTRAINT [FK_application_products_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[areas_sub_areas]'
GO
ALTER TABLE [dbo].[areas_sub_areas] ADD CONSTRAINT [FK_areas_sub_areas_areas] FOREIGN KEY ([area_id]) REFERENCES [dbo].[areas] ([area_id])
GO
ALTER TABLE [dbo].[areas_sub_areas] ADD CONSTRAINT [FK_areas_sub_areas_sub_areas] FOREIGN KEY ([sub_area_id]) REFERENCES [dbo].[sub_areas] ([sub_area_id]) ON UPDATE CASCADE
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[builder_styles]'
GO
ALTER TABLE [dbo].[builder_styles] ADD CONSTRAINT [FK_builder_styles_applications] FOREIGN KEY ([application_id]) REFERENCES [dbo].[applications] ([application_id])
GO
ALTER TABLE [dbo].[builder_styles] ADD CONSTRAINT [FK_builder_styles_customers] FOREIGN KEY ([builder_id]) REFERENCES [dbo].[customers] ([custnmbr])
GO
ALTER TABLE [dbo].[builder_styles] ADD CONSTRAINT [FK_builder_styles_products] FOREIGN KEY ([product_id]) REFERENCES [dbo].[products] ([product_id])
GO
ALTER TABLE [dbo].[builder_styles] ADD CONSTRAINT [FK_builder_styles_system_item_types] FOREIGN KEY ([item_type]) REFERENCES [dbo].[system_item_types] ([type_id])
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
