-- =============================================================
-- Description : Creates the Errors table for BILLUPSHEADER
--               in Cetec_Errors.[Errors] schema, mirroring all
--               columns from Cetec_Raw.[dbo].[BILLUPSHEADER]
--               and adding ErrorCode (int) and ErrorColumn (int).
-- Source      : Cetec_Raw.dbo.BILLUPSHEADER
-- Target      : Cetec_Errors.Errors.BILLUPSHEADER
-- =============================================================

DECLARE @SQL        NVARCHAR(MAX) = N'';
DECLARE @Columns    NVARCHAR(MAX) = N'';

-- Build column list from source table
SELECT @Columns += N'    [' + c.COLUMN_NAME + N'] '
    + c.DATA_TYPE
    + CASE
        WHEN c.DATA_TYPE IN ('char','varchar','nchar','nvarchar')
            THEN N'(' + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1
                              THEN 'MAX'
                              ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(10))
                         END + N')'
        WHEN c.DATA_TYPE IN ('decimal','numeric')
            THEN N'(' + CAST(c.NUMERIC_PRECISION AS NVARCHAR(10))
                      + N',' + CAST(c.NUMERIC_SCALE AS NVARCHAR(10)) + N')'
        ELSE N''
      END
    + N' NULL,' + CHAR(13)
FROM Cetec_Raw.INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_SCHEMA = 'dbo'
  AND c.TABLE_NAME   = 'BILLUPSHEADER'
ORDER BY c.ORDINAL_POSITION;

-- Add the two extra error tracking columns
SET @Columns += N'    [ErrorCode]   INT NULL,' + CHAR(13);
SET @Columns += N'    [ErrorColumn] INT NULL'  + CHAR(13);

-- Drop target table if it already exists
IF OBJECT_ID('Cetec_Errors.Errors.BILLUPSHEADER', 'U') IS NOT NULL
    DROP TABLE Cetec_Errors.Errors.BILLUPSHEADER;

-- Build and execute CREATE TABLE statement
SET @SQL = N'CREATE TABLE Cetec_Errors.Errors.BILLUPSHEADER (' + CHAR(13)
         + @Columns + CHAR(13)
         + N');';

PRINT @SQL;   -- Preview the generated statement
EXEC sp_executesql @SQL;
