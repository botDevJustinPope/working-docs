/*
Run this script on:

        dev-sql.veodesignstudio.com.VEO_DEV    -  This database will be modified

to synchronize it with:

        dev-sql.veodesignstudio.com.WBS_Staging

You are recommended to back up your database before running this script

Script created by SQL Compare version 15.4.1.27450 from Red Gate Software Ltd at 4/21/2026 12:44:06 PM

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
PRINT N'Dropping constraints from [dbo].[color_vendor_cost_tiers]'
GO
ALTER TABLE [dbo].[color_vendor_cost_tiers] DROP CONSTRAINT [PK_color_vendor_cost_tiers]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping constraints from [dbo].[colors]'
GO
ALTER TABLE [dbo].[colors] DROP CONSTRAINT [DF_colors_color]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_color_vendor_cost_tiers] from [dbo].[color_vendor_cost_tiers]'
GO
DROP INDEX [IX_color_vendor_cost_tiers] ON [dbo].[color_vendor_cost_tiers]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors_part_no] from [dbo].[colors]'
GO
DROP INDEX [IX_colors_part_no] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors_1] from [dbo].[colors]'
GO
DROP INDEX [IX_colors_1] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [ix_colors_barcode_id] from [dbo].[colors]'
GO
DROP INDEX [ix_colors_barcode_id] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors_2] from [dbo].[colors]'
GO
DROP INDEX [IX_colors_2] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Dropping index [IX_colors] from [dbo].[colors]'
GO
DROP INDEX [IX_colors] ON [dbo].[colors]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[customers]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[customers] ADD
[tax_liable] [bit] NOT NULL CONSTRAINT [DF_customers_tax_liable] DEFAULT ((0)),
[tax_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[colors]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[colors] ADD
[replacement_part_no] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dbo].[colors]'
GO
ALTER TABLE [dbo].[colors] ADD CONSTRAINT [DF_colors_color] DEFAULT ('') FOR [color]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[colors] ADD CONSTRAINT [DF_colors_global_product_id] DEFAULT (newid()) FOR [global_product_id]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_part_no_include] on [dbo].[colors]'
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_colors_part_no_include] ON [dbo].[colors] ([part_no]) INCLUDE ([name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_barcode_id_Includes] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_barcode_id_Includes] ON [dbo].[colors] ([barcode_id]) INCLUDE ([part_no])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_product_id_stocking_code_includes] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_product_id_stocking_code_includes] ON [dbo].[colors] ([product_id], [stocking_code]) INCLUDE ([part_no], [style_id], [color_id], [name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [colors_product_id_style_id_default_related_item_includes] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [colors_product_id_style_id_default_related_item_includes] ON [dbo].[colors] ([product_id], [style_id], [default_related_item]) INCLUDE ([part_no])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_name] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_name] ON [dbo].[colors] ([name])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [ix_colors_global_product_id] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [ix_colors_global_product_id] ON [dbo].[colors] ([global_product_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_modified_date] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_modified_date] ON [dbo].[colors] ([modified_date])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_stocking_code] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_stocking_code] ON [dbo].[colors] ([stocking_code])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating index [IX_colors_style_id] on [dbo].[colors]'
GO
CREATE NONCLUSTERED INDEX [IX_colors_style_id] ON [dbo].[colors] ([style_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[color_vendor_cost_tiers]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[color_vendor_cost_tiers] ADD
[customer_id] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_color_vendor_cost_tiers_customer_id] DEFAULT (''),
[reorder_days] [int] NULL,
[package_quantity] [int] NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_color_vendor_cost_tiers] on [dbo].[color_vendor_cost_tiers]'
GO
ALTER TABLE [dbo].[color_vendor_cost_tiers] ADD CONSTRAINT [PK_color_vendor_cost_tiers] PRIMARY KEY CLUSTERED ([item_number], [vendor_id], [effective_date], [tier_desc], [cost], [customer_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[color_vendor_cost_tiers]'
GO
ALTER TABLE [dbo].[color_vendor_cost_tiers] ADD CONSTRAINT [FK_color_vendor_cost_tiers_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[colors_attachments]'
GO
ALTER TABLE [dbo].[colors_attachments] ADD CONSTRAINT [FK_colors_attachments_attachments] FOREIGN KEY ([attachment_id]) REFERENCES [dbo].[attachments] ([attachment_id])
GO
ALTER TABLE [dbo].[colors_attachments] ADD CONSTRAINT [FK_colors_attachments_colors] FOREIGN KEY ([product_id], [style_id], [color_id]) REFERENCES [dbo].[colors] ([product_id], [style_id], [color_id]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[colors_attachments] ADD CONSTRAINT [FK_colors_attachments_colors_attachment_types] FOREIGN KEY ([attachment_type]) REFERENCES [dbo].[colors_attachment_types] ([attachment_type])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[colors_attributes]'
GO
ALTER TABLE [dbo].[colors_attributes] ADD CONSTRAINT [FK_colors_attributes_colors] FOREIGN KEY ([product_id], [style_id], [color_id]) REFERENCES [dbo].[colors] ([product_id], [style_id], [color_id]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[colors_attributes] ADD CONSTRAINT [FK_colors_attributes_products] FOREIGN KEY ([product_id]) REFERENCES [dbo].[products] ([product_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_communities]'
GO
ALTER TABLE [dbo].[customers_communities] ADD CONSTRAINT [FK_customers_communities_communities] FOREIGN KEY ([community_id]) REFERENCES [dbo].[communities] ([community_id])
GO
ALTER TABLE [dbo].[customers_communities] ADD CONSTRAINT [FK_customers_communities_customers] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customers] ([custnmbr])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_communities_series]'
GO
ALTER TABLE [dbo].[customers_communities_series] ADD CONSTRAINT [FK_customers_communities_series_customers_communities] FOREIGN KEY ([customer_id], [community_id]) REFERENCES [dbo].[customers_communities] ([customer_id], [community_id])
GO
ALTER TABLE [dbo].[customers_communities_series] ADD CONSTRAINT [FK_customers_communities_series_customers_series] FOREIGN KEY ([customer_id], [series_id]) REFERENCES [dbo].[customers_series] ([custnmbr], [series_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_communities_series_plans]'
GO
ALTER TABLE [dbo].[customers_communities_series_plans] ADD CONSTRAINT [FK_customers_communities_series_plans_customers_communities_series] FOREIGN KEY ([customer_id], [community_id], [series_id]) REFERENCES [dbo].[customers_communities_series] ([customer_id], [community_id], [series_id])
GO
ALTER TABLE [dbo].[customers_communities_series_plans] ADD CONSTRAINT [FK_customers_communities_series_plans_customers_plans] FOREIGN KEY ([customer_id], [plan_id]) REFERENCES [dbo].[customers_plans] ([customer_id], [plan_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_items]'
GO
ALTER TABLE [dbo].[customers_items] ADD CONSTRAINT [FK_customers_items_applications] FOREIGN KEY ([application_id]) REFERENCES [dbo].[customers_items_applications] ([application_id])
GO
ALTER TABLE [dbo].[customers_items] ADD CONSTRAINT [FK_customers_items_customers] FOREIGN KEY ([customer_id]) REFERENCES [dbo].[customers] ([custnmbr])
GO
ALTER TABLE [dbo].[customers_items] ADD CONSTRAINT [FK_customers_items_customers_items_products] FOREIGN KEY ([product_id]) REFERENCES [dbo].[customers_items_products] ([product_id])
GO
ALTER TABLE [dbo].[customers_items] ADD CONSTRAINT [FK_customers_items_uom] FOREIGN KEY ([uom]) REFERENCES [dbo].[uom] ([uom_id])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[customers_items_price]'
GO
ALTER TABLE [dbo].[customers_items_price] ADD CONSTRAINT [FK_customers_items_price_customers_items] FOREIGN KEY ([item_key]) REFERENCES [dbo].[customers_items] ([item_key]) ON DELETE CASCADE
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
