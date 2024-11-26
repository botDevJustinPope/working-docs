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

DECLARE @setting_id UNIQUEIDENTIFIER = 'B5A3CC62-749D-4643-9DD4-680CE521E03B';
DECLARE @setting_key NVARCHAR(50) = 'show_other_builder_appointments_as_busy';
DECLARE @setting_name NVARCHAR(100) = 'Show Other Builder Appointments as Busy';
DECLARE @setting_description NVARCHAR(300) = 'If on, the user will see ''busy'' for builder appointments when the builder is not one of the user''s builders.';
DECLARE @data_type NVARCHAR(50) = 'boolean';
	
IF NOT EXISTS (
    SELECT 1 
    FROM [dbo].[scheduling_settings] 
    WHERE id = @setting_id
)
BEGIN
    INSERT INTO [dbo].[scheduling_settings] (id, setting_key, setting_name, setting_description, data_type)
    VALUES (
        @setting_id, 
        @setting_key,
		@setting_name,
        @setting_description, 
        @data_type
    );
END;

SET @setting_id = '2929B54A-6416-4B2C-8BA5-327417FC343D';
SET @setting_key = 'show_designer_events_as_busy';
SET @setting_name = 'Show Designer Events as Busy';
SET @setting_description = 'If on, the user will see ''busy'' for designer events (PTO, meetings, etc.)';
SET @data_type = 'boolean';

IF NOT EXISTS (
    SELECT 1 
    FROM [dbo].[scheduling_settings] 
    WHERE id = @setting_id
)
BEGIN
    INSERT INTO [dbo].[scheduling_settings] (id, setting_key, setting_name, setting_description, data_type)
    VALUES (
        @setting_id, 
        @setting_key,
		@setting_name,
        @setting_description, 
        @data_type
    );
END;

--DOWN Script
--delete from scheduling_settings where id in ('B5A3CC62-749D-4643-9DD4-680CE521E03B', '2929B54A-6416-4B2C-8BA5-327417FC343D');