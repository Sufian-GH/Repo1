--=============================================================================================================================
-- Author: GitHub Copilot
-- Create date: 15-Jun-2026
-- Description: This SP cleans up raw Cetec data from the BILLUPSHEADER data file
--              and loads Cetec_Enriched.dbo.BILLUPSHEADER
--=============================================================================================================================

CREATE OR ALTER PROCEDURE [dbo].[SP_BILLUPSHEADER]
AS

--=============================================================================================================================
-- Standard code to drop all temp tables used in the SP
--=============================================================================================================================
IF OBJECT_ID('tempdb..#BILLUPSHEADER_Clean') IS NOT NULL DROP TABLE #BILLUPSHEADER_Clean;

--=============================================================================================================================
-- First step is to clean up all columns ensuring they are trimmed, uppercased,
-- and that empty strings are replaced with NULLs
-- We also add Region from Dim_Region and convert date/time columns to datetime
--=============================================================================================================================
SELECT
    Location = NULLIF(TRIM(UPPER(B.Location)), ''),
    Region = NULLIF(TRIM(UPPER(R.Region)), ''),
    PACKER_NUMBER = NULLIF(TRIM(UPPER(B.PACKER_NUMBER)), ''),
    -- SHIP_DATE_TIME format: MMDDYYhh:mmxm  (e.g. 07052302:19pm, 13 chars after TRIM)
    -- pos 1-2=MM, 3-4=DD, 5-6=YY(2-digit), 7-8=hh(12h), 9=colon, 10-11=mm, 12-13=am/pm
    DateShipped = TRY_CONVERT(
        datetime,
        CASE WHEN NULLIF(TRIM(B.SHIP_DATE_TIME), '') IS NOT NULL
            THEN '20' + SUBSTRING(TRIM(B.SHIP_DATE_TIME), 5, 2)        -- YYYY
                + '-' + SUBSTRING(TRIM(B.SHIP_DATE_TIME), 1, 2)        -- MM
                + '-' + SUBSTRING(TRIM(B.SHIP_DATE_TIME), 3, 2)        -- DD
                + ' '
                + RIGHT('0' + CAST(
                    CASE LOWER(SUBSTRING(TRIM(B.SHIP_DATE_TIME), 12, 2))
                        WHEN 'am' THEN
                            CASE WHEN CAST(SUBSTRING(TRIM(B.SHIP_DATE_TIME), 7, 2) AS INT) = 12
                                 THEN 0
                                 ELSE CAST(SUBSTRING(TRIM(B.SHIP_DATE_TIME), 7, 2) AS INT)
                            END
                        WHEN 'pm' THEN
                            CASE WHEN CAST(SUBSTRING(TRIM(B.SHIP_DATE_TIME), 7, 2) AS INT) = 12
                                 THEN 12
                                 ELSE CAST(SUBSTRING(TRIM(B.SHIP_DATE_TIME), 7, 2) AS INT) + 12
                            END
                        ELSE CAST(SUBSTRING(TRIM(B.SHIP_DATE_TIME), 7, 2) AS INT)
                    END AS VARCHAR(2)), 2)
                + ':' + SUBSTRING(TRIM(B.SHIP_DATE_TIME), 10, 2)       -- mm
                + ':00'
        END
    ),
    UPS_TRACKER_NO = NULLIF(TRIM(UPPER(B.UPS_TRACKER_NO)), ''),
    SERVICE_TYPE = NULLIF(TRIM(UPPER(B.SERVICE_TYPE)), ''),
    COD_AMOUNT = NULLIF(TRIM(UPPER(B.COD_AMOUNT)), ''),
    PACKAGES = B.PACKAGES,
    TOTAL_WEIGHT = B.TOTAL_WEIGHT,
    VOID = NULLIF(TRIM(UPPER(B.VOID)), ''),
    SHIPPING_CHARGES = B.SHIPPING_CHARGES,
    WEIGHT_UOM = NULLIF(TRIM(UPPER(B.WEIGHT_UOM)), ''),
    -- DOWNLOAD_TIMESTAMP format: YYYYMMDDHHMMSSmmm  (e.g. 20230705183323704, 17 chars)
    -- pos 1-4=YYYY, 5-6=MM, 7-8=DD, 9-10=HH(24h), 11-12=MM, 13-14=SS, 15-17=ms
    DOWNLOAD_TIMESTAMP = TRY_CONVERT(
        datetime,
        CASE WHEN NULLIF(TRIM(B.DOWNLOAD_TIMESTAMP), '') IS NOT NULL
            THEN SUBSTRING(TRIM(B.DOWNLOAD_TIMESTAMP), 1, 4)           -- YYYY
                + '-' + SUBSTRING(TRIM(B.DOWNLOAD_TIMESTAMP), 5, 2)    -- MM
                + '-' + SUBSTRING(TRIM(B.DOWNLOAD_TIMESTAMP), 7, 2)    -- DD
                + ' ' + SUBSTRING(TRIM(B.DOWNLOAD_TIMESTAMP), 9, 2)    -- HH
                + ':' + SUBSTRING(TRIM(B.DOWNLOAD_TIMESTAMP), 11, 2)   -- MM
                + ':' + SUBSTRING(TRIM(B.DOWNLOAD_TIMESTAMP), 13, 2)   -- SS
                + '.' + SUBSTRING(TRIM(B.DOWNLOAD_TIMESTAMP), 15, 3)   -- ms
        END
    ),
    -- DATE_TIME_POSTED format: YYYYMMDDHHMMSSmmm  (e.g. 20230705183326915, 17 chars)
    -- pos 1-4=YYYY, 5-6=MM, 7-8=DD, 9-10=HH(24h), 11-12=MM, 13-14=SS, 15-17=ms
    DATE_TIME_POSTED = TRY_CONVERT(
        datetime,
        CASE WHEN NULLIF(TRIM(B.DATE_TIME_POSTED), '') IS NOT NULL
            THEN SUBSTRING(TRIM(B.DATE_TIME_POSTED), 1, 4)             -- YYYY
                + '-' + SUBSTRING(TRIM(B.DATE_TIME_POSTED), 5, 2)      -- MM
                + '-' + SUBSTRING(TRIM(B.DATE_TIME_POSTED), 7, 2)      -- DD
                + ' ' + SUBSTRING(TRIM(B.DATE_TIME_POSTED), 9, 2)      -- HH
                + ':' + SUBSTRING(TRIM(B.DATE_TIME_POSTED), 11, 2)     -- MM
                + ':' + SUBSTRING(TRIM(B.DATE_TIME_POSTED), 13, 2)     -- SS
                + '.' + SUBSTRING(TRIM(B.DATE_TIME_POSTED), 15, 3)     -- ms
        END
    ),
    POSTED_ERROR_MESSAGE = NULLIF(TRIM(UPPER(B.POSTED_ERROR_MESSAGE)), ''),
    UPS_TRACKER_NO_EXTRA = NULLIF(TRIM(UPPER(B.UPS_TRACKER_NO_EXTRA)), ''),
    SourceFile = NULLIF(TRIM(UPPER(B.SourceFile)), ''),
    DateTimeImportedUTC = B.DateTimeImportedUTC,
    DateTimeEnrichedUTC = GETDATE()
INTO #BILLUPSHEADER_Clean
FROM Cetec_Raw.dbo.BILLUPSHEADER B
LEFT OUTER JOIN Cetec.Dimension.Dim_Region R
    ON NULLIF(TRIM(UPPER(B.Location)), '') = NULLIF(TRIM(UPPER(R.Location)), '');

--=============================================================================================================================
-- Once data is cleaned, we load it into the destination table in the Cetec_Enriched database via a TRUNCATE/INSERT pattern
--=============================================================================================================================
TRUNCATE TABLE Cetec_Enriched.dbo.BILLUPSHEADER;

INSERT INTO Cetec_Enriched.dbo.BILLUPSHEADER
(
    Location,
    Region,
    PACKER_NUMBER,
    DateShipped,
    UPS_TRACKER_NO,
    SERVICE_TYPE,
    COD_AMOUNT,
    PACKAGES,
    TOTAL_WEIGHT,
    VOID,
    SHIPPING_CHARGES,
    WEIGHT_UOM,
    DOWNLOAD_TIMESTAMP,
    DATE_TIME_POSTED,
    POSTED_ERROR_MESSAGE,
    UPS_TRACKER_NO_EXTRA,
    SourceFile,
    DateTimeImportedUTC,
    DateTimeEnrichedUTC
)
SELECT
    Location,
    Region,
    PACKER_NUMBER,
    DateShipped,
    UPS_TRACKER_NO,
    SERVICE_TYPE,
    COD_AMOUNT,
    PACKAGES,
    TOTAL_WEIGHT,
    VOID,
    SHIPPING_CHARGES,
    WEIGHT_UOM,
    DOWNLOAD_TIMESTAMP,
    DATE_TIME_POSTED,
    POSTED_ERROR_MESSAGE,
    UPS_TRACKER_NO_EXTRA,
    SourceFile,
    DateTimeImportedUTC,
    DateTimeEnrichedUTC
FROM #BILLUPSHEADER_Clean;
