/*
    File: backupset_queries.sql
    Purpose:
      Reusable SQL Server queries to inspect backup sets and restore order.
      Designed to work for any database by changing parameters below.

    Requirements:
      - SQL Server instance with msdb history available
      - Permission to read msdb backup metadata

    How to use:
      1) Set @DatabaseName to the database you care about.
      2) Optionally set @BackupFile to inspect one specific .bak/.trn file.
      3) Run the full script or run one section at a time.
*/

SET NOCOUNT ON;

/* =============================================================
   Parameters
   - @DatabaseName: Target database for all history queries.
   - @BackupFile  : Optional physical backup file path.
                    Leave NULL if you do not want file-specific queries.
   ============================================================= */
DECLARE @DatabaseName sysname = N'Cetec';
DECLARE @BackupFile   nvarchar(4000) = NULL;

IF @DatabaseName IS NULL OR LTRIM(RTRIM(@DatabaseName)) = N''
BEGIN
    THROW 50001, 'Please set @DatabaseName before running this script.', 1;
END;

/* =============================================================
   Query 1: Backup history for a database (newest first)
   What it shows:
   - backup_set_id, backup type, start/end times
   - LSN metadata used to reason about restore chains
   - physical device path where backup was written

   Backup type codes:
   - D = Full
   - I = Differential
   - L = Log
   ============================================================= */
SELECT bs.backup_set_id, bs.database_name, bs.type AS backup_type_code,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Differential'
        WHEN 'L' THEN 'Log'
        ELSE bs.type
    END AS backup_type,
    bs.backup_start_date, bs.backup_finish_date, bs.first_lsn, bs.last_lsn, bs.checkpoint_lsn, bs.database_backup_lsn, bs.recovery_model, bs.is_copy_only, bmf.physical_device_name
FROM msdb.dbo.backupset AS bs
JOIN msdb.dbo.backupmediafamily AS bmf
ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = @DatabaseName
ORDER BY bs.backup_finish_date DESC;

/* =============================================================
   Query 2: Backup sets inside one specific file
   What it shows:
   - position = FILE number used by RESTORE ... WITH FILE = n
   - backup set order and LSN range inside that media file

   Notes:
   - Only runs when @BackupFile is provided.
   ============================================================= */
IF @BackupFile IS NOT NULL AND LTRIM(RTRIM(@BackupFile)) <> N''
BEGIN

SELECT bs.position AS restore_file_number, bs.backup_set_id,
        CASE bs.type
            WHEN 'D' THEN 'Full'
            WHEN 'I' THEN 'Differential'
            WHEN 'L' THEN 'Log'
            ELSE bs.type
        END AS backup_type,
        bs.backup_start_date, bs.backup_finish_date, bs.first_lsn, bs.last_lsn, bmf.physical_device_name
FROM msdb.dbo.backupset AS bs
JOIN msdb.dbo.backupmediafamily AS bmf
ON bs.media_set_id = bmf.media_set_id
WHERE bmf.physical_device_name = @BackupFile
AND bs.database_name = @DatabaseName
ORDER BY bs.position;

END
ELSE
BEGIN
    PRINT 'Query 2 skipped: set @BackupFile to inspect a specific file.';
END;

/* =============================================================
   Query 3: Log chain inspection for one specific file
   What it shows:
   - Log backup sequence and LSN ranges to validate continuity.

   How to read it:
   - Restore log backups in chronological/position order.
   - A broken LSN chain indicates missing log backups.

   Notes:
   - Only runs when @BackupFile is provided.
   ============================================================= */
IF @BackupFile IS NOT NULL AND LTRIM(RTRIM(@BackupFile)) <> N''
BEGIN

SELECT bs.position, bs.backup_start_date, bs.backup_finish_date, bs.first_lsn, bs.last_lsn, bmf.physical_device_name
FROM msdb.dbo.backupset AS bs
JOIN msdb.dbo.backupmediafamily AS bmf
ON bs.media_set_id = bmf.media_set_id
WHERE bmf.physical_device_name = @BackupFile
AND bs.database_name = @DatabaseName
AND bs.type = 'L'
ORDER BY bs.position;

END
ELSE
BEGIN
    PRINT 'Query 3 skipped: set @BackupFile to inspect log chain in one file.';
END;

/* =============================================================
   Query 4: HEADERONLY helper for a specific file
   What it does:
   - Reads backup headers directly from backup media.
   - Useful for validating media contents before restore.

   Notes:
   - Only runs when @BackupFile is provided.
   ============================================================= */
IF @BackupFile IS NOT NULL AND LTRIM(RTRIM(@BackupFile)) <> N''
BEGIN
    DECLARE @sql nvarchar(max) =
        N'RESTORE HEADERONLY FROM DISK = N''' + REPLACE(@BackupFile, N'''', N'''''') + N''';';

    PRINT 'Running: ' + @sql;
    EXEC sys.sp_executesql @sql;
END
ELSE
BEGIN
    PRINT 'Query 4 skipped: set @BackupFile to run RESTORE HEADERONLY.';
END;

/* =============================================================
   Restore order reminder
   1) Restore Full (D)
   2) Restore latest Differential (I) after that Full (optional)
   3) Restore all required Logs (L) in order
   4) Use NORECOVERY on all but the final restore
   5) Use RECOVERY on the final restore only
   ============================================================= */
