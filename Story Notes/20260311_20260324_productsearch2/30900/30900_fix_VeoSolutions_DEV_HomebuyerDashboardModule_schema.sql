/*
    Purpose:
      Bring VeoSolutions_DEV dbo.HomebuyerDashboardModule back in line with
      the EF-managed schema already present in QA and Preview.

    Confirmed drift in DEV:
      - ModuleInfo column is missing
      - Title is nvarchar(50) instead of nvarchar(35)

    Confirmed non-drift in other audited Homebuyer Dashboard tables:
      - HomebuyerDashboardStep
      - HomebuyerDashboardLink
      - CustomHomebuyerDashboardModule
      - CustomHomebuyerDashboardStep
      - CustomHomebuyerDashboardLink
      - DisabledHomebuyerDashboardModule
*/

USE [VeoSolutions_DEV];
GO

DECLARE @lifestyleSnapshotModuleId UNIQUEIDENTIFIER = 'F028B707-A3A4-4045-A8CB-C598BDCDEBC7';
DECLARE @moduleInfo NVARCHAR(250) = N'By disabling this module, the homebuyer will be routed to their dashboard on first login rather than seeing the usual landing page with the survey.';

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.HomebuyerDashboardModule', N'U') IS NULL
    BEGIN
        RAISERROR(N'dbo.HomebuyerDashboardModule was not found in VeoSolutions_DEV.', 16, 1);
    END;

    IF COL_LENGTH(N'dbo.HomebuyerDashboardModule', N'ModuleInfo') IS NULL
    BEGIN
        ALTER TABLE dbo.HomebuyerDashboardModule
        ADD ModuleInfo NVARCHAR(250) NULL;
    END;

    UPDATE dbo.HomebuyerDashboardModule
    SET Title = LEFT(Title, 35)
    WHERE LEN(Title) > 35;

    IF EXISTS
    (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = N'dbo'
          AND TABLE_NAME = N'HomebuyerDashboardModule'
          AND COLUMN_NAME = N'Title'
          AND CHARACTER_MAXIMUM_LENGTH <> 35
    )
    BEGIN
        ALTER TABLE dbo.HomebuyerDashboardModule
        ALTER COLUMN Title NVARCHAR(35) NOT NULL;
    END;

    UPDATE dbo.HomebuyerDashboardModule
    SET ModuleInfo = @moduleInfo
    WHERE Id = @lifestyleSnapshotModuleId
      AND ISNULL(ModuleInfo, N'') <> @moduleInfo;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    DECLARE @errorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @errorSeverity INT = ERROR_SEVERITY();
    DECLARE @errorState INT = ERROR_STATE();

    RAISERROR(@errorMessage, @errorSeverity, @errorState);
END CATCH;
GO

SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = N'dbo'
  AND c.TABLE_NAME = N'HomebuyerDashboardModule'
ORDER BY c.ORDINAL_POSITION;
GO

SELECT
    Id,
    Code,
    Title,
    ModuleInfo
FROM dbo.HomebuyerDashboardModule
WHERE Id = 'F028B707-A3A4-4045-A8CB-C598BDCDEBC7';
GO
