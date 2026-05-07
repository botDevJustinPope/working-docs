/*
Run this script on:

        dev-sql.veodesignstudio.com.VEO_DEV    -  This database will be modified

to synchronize it with:

        dev-sql.veodesignstudio.com.WBS_Staging

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.1.27450 from Red Gate Software Ltd at 4/21/2026 12:46:43 PM

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
PRINT N'Altering [dbo].[estimates]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[estimates] ADD
[base_plan_id] [int] NOT NULL CONSTRAINT [DF_estimates_base_plan_id] DEFAULT ((-1))
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_patterns]'
GO
ALTER TABLE [dbo].[customers_patterns] ADD CONSTRAINT [FK_customers_patterns_customers] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customers] ([custnmbr]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[customers_patterns] ADD CONSTRAINT [FK_customers_patterns_product_patterns] FOREIGN KEY ([pattern_id]) REFERENCES [dbo].[product_patterns] ([pattern_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_product_split_areas]'
GO
ALTER TABLE [dbo].[customers_product_split_areas] ADD CONSTRAINT [FK_customers_product_split_areas_customers] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customers] ([custnmbr])
GO
ALTER TABLE [dbo].[customers_product_split_areas] ADD CONSTRAINT [FK_customers_product_split_areas_products] FOREIGN KEY ([product_id]) REFERENCES [dbo].[products] ([product_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_product_split_directives]'
GO
ALTER TABLE [dbo].[customers_product_split_directives] ADD CONSTRAINT [FK_customers_product_split_directives_customers] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customers] ([custnmbr])
GO
ALTER TABLE [dbo].[customers_product_split_directives] ADD CONSTRAINT [FK_customers_product_split_directives_products] FOREIGN KEY ([product_id]) REFERENCES [dbo].[products] ([product_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[esc_reference_keys]'
GO
ALTER TABLE [dbo].[esc_reference_keys] ADD CONSTRAINT [FK_esc_reference_keys_areas] FOREIGN KEY ([area_id]) REFERENCES [dbo].[areas] ([area_id]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[esc_reference_keys] ADD CONSTRAINT [FK_esc_reference_keys_sub_areas] FOREIGN KEY ([sub_area_id]) REFERENCES [dbo].[sub_areas] ([sub_area_id]) ON UPDATE CASCADE
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[esc_system_user_type_functions]'
GO
ALTER TABLE [dbo].[esc_system_user_type_functions] ADD CONSTRAINT [FK_esc_system_user_type_functions_esc_system_user_types] FOREIGN KEY ([user_type_id]) REFERENCES [dbo].[esc_system_user_types] ([user_type])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[esc_system_user_types]'
GO
ALTER TABLE [dbo].[esc_system_user_types] ADD CONSTRAINT [FK_esc_system_user_types_esc_system_user_types] FOREIGN KEY ([user_type]) REFERENCES [dbo].[esc_system_user_types] ([user_type])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[esc_users_events_params]'
GO
ALTER TABLE [dbo].[esc_users_events_params] ADD CONSTRAINT [FK_esc_users_events_params_esc_users_events] FOREIGN KEY ([event_id]) REFERENCES [dbo].[esc_users_events] ([event_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[esc_virtual_showroom_detail]'
GO
ALTER TABLE [dbo].[esc_virtual_showroom_detail] ADD CONSTRAINT [FK_esc_virtual_showroom_detail_esc_virtual_showroom] FOREIGN KEY ([room_id]) REFERENCES [dbo].[esc_virtual_showroom] ([room_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[estimates_bill_of_material_detail]'
GO
ALTER TABLE [dbo].[estimates_bill_of_material_detail] ADD CONSTRAINT [FK_estimates_bill_of_material_detail_estimates_bill_of_material_plan] FOREIGN KEY ([estimate_id], [bill_of_material_plan_id]) REFERENCES [dbo].[estimates_bill_of_material_plan] ([estimate_id], [bill_of_material_plan_id]) ON DELETE CASCADE
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
