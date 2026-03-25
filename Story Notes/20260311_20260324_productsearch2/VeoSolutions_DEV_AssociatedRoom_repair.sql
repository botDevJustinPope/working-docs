USE [VeoSolutions_DEV];
GO

/*
Purpose
=======
Repair the drifted dbo.AssociatedRoom table in VeoSolutions_DEV so it matches the
current EF migration/model shape for the structural items we can verify safely:

Expected by EF snapshot / migrations
------------------------------------
- Columns:
    OrganizationId uniqueidentifier NOT NULL
    PlanId uniqueidentifier NOT NULL
    RoomId uniqueidentifier NOT NULL
    SceneId uniqueidentifier NOT NULL
    VisualizationProviderId uniqueidentifier NOT NULL
- Primary key:
    (OrganizationId, PlanId, RoomId)
- Indexes:
    IX_AssociatedRoom_SceneId
    IX_AssociatedRoom_VisualizationProviderId
- Foreign keys:
    FK_AssociatedRoom_Scene_SceneId
    FK_AssociatedRoom_VisualizationProvider_VisualizationProviderId

Observed drift in DEV
---------------------
- Migration history claims Add_AssociatedRoom_PlanId was applied.
- Actual table is missing PlanId.
- PK is still (OrganizationId, RoomId).
- Foreign keys are missing.
- AssociatedRoom_Trigger is missing, but no trigger definition was found in source control.

Notes
=====
- This script makes a full backup copy of dbo.AssociatedRoom before changing anything.
- PlanId is restored exactly as the migration did: NOT NULL with default Guid.Empty.
- This script does NOT recreate AssociatedRoom_Trigger because a trusted definition
  was not found in the repository. It prints a warning instead.
- This script also reports missing Scene / VisualizationProvider triggers because
  the current EF snapshot references them too.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @TargetTable sysname = N'dbo.AssociatedRoom';
DECLARE @BackupTableName sysname = N'AssociatedRoom_Backup_' +
    CONVERT(varchar(8), GETDATE(), 112) + N'_' +
    REPLACE(CONVERT(varchar(8), GETDATE(), 108), N':', N'');
DECLARE @BackupFullName nvarchar(400) = N'dbo.' + QUOTENAME(@BackupTableName);
DECLARE @sql nvarchar(max);

IF OBJECT_ID(@TargetTable, N'U') IS NULL
BEGIN
    THROW 51000, 'dbo.AssociatedRoom was not found in VeoSolutions_DEV.', 1;
END;

PRINT 'Starting AssociatedRoom repair script.';
PRINT 'Backup table will be created as ' + @BackupFullName + '.';

BEGIN TRY
    BEGIN TRANSACTION;

    SET @sql = N'SELECT * INTO ' + @BackupFullName + N' FROM dbo.AssociatedRoom;';
    EXEC sys.sp_executesql @sql;

    PRINT 'Backup created successfully.';

    IF COL_LENGTH('dbo.AssociatedRoom', 'PlanId') IS NULL
    BEGIN
        PRINT 'Adding missing PlanId column.';

        ALTER TABLE dbo.AssociatedRoom
        ADD PlanId uniqueidentifier NOT NULL
            CONSTRAINT DF_AssociatedRoom_PlanId DEFAULT ('00000000-0000-0000-0000-000000000000');
    END
    ELSE
    BEGIN
        PRINT 'PlanId already exists; skipping column add.';
    END;

    IF EXISTS
    (
        SELECT 1
        FROM sys.key_constraints kc
        WHERE kc.parent_object_id = OBJECT_ID(N'dbo.AssociatedRoom')
          AND kc.[type] = 'PK'
          AND kc.[name] = N'PK_AssociatedRoom'
    )
    BEGIN
        PRINT 'Dropping current PK_AssociatedRoom.';
        ALTER TABLE dbo.AssociatedRoom DROP CONSTRAINT PK_AssociatedRoom;
    END;

    PRINT 'Validating foreign key target rows before FK recreation.';

    IF EXISTS
    (
        SELECT 1
        FROM dbo.AssociatedRoom ar
        LEFT JOIN dbo.Scene s ON s.Id = ar.SceneId
        WHERE s.Id IS NULL
    )
    BEGIN
        THROW 51001, 'AssociatedRoom contains SceneId values that do not exist in dbo.Scene. Fix orphaned rows before recreating the FK.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.AssociatedRoom ar
        LEFT JOIN dbo.VisualizationProvider vp ON vp.Id = ar.VisualizationProviderId
        WHERE vp.Id IS NULL
    )
    BEGIN
        THROW 51002, 'AssociatedRoom contains VisualizationProviderId values that do not exist in dbo.VisualizationProvider. Fix orphaned rows before recreating the FK.', 1;
    END;

    PRINT 'Recreating PK_AssociatedRoom as (OrganizationId, PlanId, RoomId).';

    ALTER TABLE dbo.AssociatedRoom
    ADD CONSTRAINT PK_AssociatedRoom
        PRIMARY KEY CLUSTERED (OrganizationId, PlanId, RoomId);

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.AssociatedRoom')
          AND [name] = N'IX_AssociatedRoom_SceneId'
    )
    BEGIN
        PRINT 'Creating IX_AssociatedRoom_SceneId.';
        CREATE NONCLUSTERED INDEX IX_AssociatedRoom_SceneId
            ON dbo.AssociatedRoom (SceneId);
    END
    ELSE
    BEGIN
        PRINT 'IX_AssociatedRoom_SceneId already exists; skipping.';
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.AssociatedRoom')
          AND [name] = N'IX_AssociatedRoom_VisualizationProviderId'
    )
    BEGIN
        PRINT 'Creating IX_AssociatedRoom_VisualizationProviderId.';
        CREATE NONCLUSTERED INDEX IX_AssociatedRoom_VisualizationProviderId
            ON dbo.AssociatedRoom (VisualizationProviderId);
    END
    ELSE
    BEGIN
        PRINT 'IX_AssociatedRoom_VisualizationProviderId already exists; skipping.';
    END;

    IF EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE parent_object_id = OBJECT_ID(N'dbo.AssociatedRoom')
          AND [name] = N'FK_AssociatedRoom_Scene_SceneId'
    )
    BEGIN
        ALTER TABLE dbo.AssociatedRoom DROP CONSTRAINT FK_AssociatedRoom_Scene_SceneId;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM sys.foreign_keys
        WHERE parent_object_id = OBJECT_ID(N'dbo.AssociatedRoom')
          AND [name] = N'FK_AssociatedRoom_VisualizationProvider_VisualizationProviderId'
    )
    BEGIN
        ALTER TABLE dbo.AssociatedRoom DROP CONSTRAINT FK_AssociatedRoom_VisualizationProvider_VisualizationProviderId;
    END;

    PRINT 'Creating missing AssociatedRoom foreign keys.';

    ALTER TABLE dbo.AssociatedRoom WITH CHECK
    ADD CONSTRAINT FK_AssociatedRoom_Scene_SceneId
        FOREIGN KEY (SceneId) REFERENCES dbo.Scene (Id)
        ON DELETE CASCADE;

    ALTER TABLE dbo.AssociatedRoom CHECK CONSTRAINT FK_AssociatedRoom_Scene_SceneId;

    ALTER TABLE dbo.AssociatedRoom WITH CHECK
    ADD CONSTRAINT FK_AssociatedRoom_VisualizationProvider_VisualizationProviderId
        FOREIGN KEY (VisualizationProviderId) REFERENCES dbo.VisualizationProvider (Id)
        ON DELETE CASCADE;

    ALTER TABLE dbo.AssociatedRoom CHECK CONSTRAINT FK_AssociatedRoom_VisualizationProvider_VisualizationProviderId;

    COMMIT TRANSACTION;

    PRINT 'AssociatedRoom structural repair completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
    DECLARE @ErrorNumber int = ERROR_NUMBER();
    DECLARE @ErrorState int = ERROR_STATE();

    PRINT 'AssociatedRoom repair failed. Backup table remains available if it was created.';
    THROW @ErrorNumber, @ErrorMessage, @ErrorState;
END CATCH;
GO

PRINT 'Post-repair verification for dbo.AssociatedRoom:';

SELECT t.name AS TableName,
       c.column_id,
       c.name AS ColumnName,
       ty.name AS DataType,
       c.is_nullable
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE t.name = 'AssociatedRoom'
ORDER BY c.column_id;

SELECT i.name AS IndexName,
       i.is_primary_key,
       i.is_unique,
       ic.key_ordinal,
       c.name AS ColumnName
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.AssociatedRoom')
  AND i.is_hypothetical = 0
ORDER BY i.is_primary_key DESC, i.name, ic.key_ordinal;

SELECT fk.name AS ForeignKeyName,
       cp.name AS ParentColumn,
       tr.name AS ReferencedTable,
       cr.name AS ReferencedColumn,
       fk.delete_referential_action_desc AS DeleteAction
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE fk.parent_object_id = OBJECT_ID(N'dbo.AssociatedRoom')
ORDER BY fk.name, fkc.constraint_column_id;

PRINT 'Trigger presence check for snapshot-declared visualization triggers:';

SELECT expected.TriggerName,
       CASE WHEN tr.[object_id] IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END AS ExistsInDatabase
FROM
(
    VALUES
        (N'AssociatedRoom_Trigger'),
        (N'Scene_Trigger'),
        (N'VisualizationProvider_Trigger')
) AS expected(TriggerName)
LEFT JOIN sys.triggers tr ON tr.[name] = expected.TriggerName
ORDER BY expected.TriggerName;

PRINT 'WARNING: This script does not recreate missing triggers because their source definition was not found in the repository.';
GO
