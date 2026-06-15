-- =============================================================
-- Description : Creates the BILLUPSHEADER table in
--               Cetec_Enriched.[dbo] schema, mirroring all
--               columns from Cetec_Raw.[dbo].[BILLUPSHEADER]
--               with the following modifications:
--                 1. SHIP_DATE_TIME renamed to DateShipped
--                 2. SHIP_DATE_TIME, DOWNLOAD_TIMESTAMP, and
--                    DATE_TIME_POSTED changed from varchar to datetime
--                 3. New column DateTimeEnrichedUTC (datetime) added
-- Source      : Cetec_Raw.dbo.BILLUPSHEADER
-- Target      : Cetec_Enriched.dbo.BILLUPSHEADER
-- =============================================================

IF OBJECT_ID('Cetec_Enriched.dbo.BILLUPSHEADER', 'U') IS NOT NULL
    DROP TABLE Cetec_Enriched.dbo.BILLUPSHEADER;

CREATE TABLE Cetec_Enriched.dbo.BILLUPSHEADER
(
    [Location]              varchar(2)      NULL,
    [PACKER_NUMBER]         varchar(8)      NULL,
    [DateShipped]           datetime        NULL,   -- was SHIP_DATE_TIME varchar(14)
    [UPS_TRACKER_NO]        varchar(30)     NULL,
    [SERVICE_TYPE]          varchar(1)      NULL,
    [COD_AMOUNT]            varchar(6)      NULL,
    [PACKAGES]              decimal(10, 2)  NULL,
    [TOTAL_WEIGHT]          decimal(10, 2)  NULL,
    [VOID]                  varchar(1)      NULL,
    [SHIPPING_CHARGES]      decimal(10, 2)  NULL,
    [WEIGHT_UOM]            varchar(3)      NULL,
    [DOWNLOAD_TIMESTAMP]    datetime        NULL,   -- was varchar(20)
    [DATE_TIME_POSTED]      datetime        NULL,   -- was varchar(20)
    [POSTED_ERROR_MESSAGE]  varchar(30)     NULL,
    [UPS_TRACKER_NO_EXTRA]  varchar(300)    NULL,
    [SourceFile]            nvarchar(25)    NULL,
    [DateTimeImportedUTC]   datetime        NULL,
    [DateTimeEnrichedUTC]   datetime        NULL    -- new column
);
