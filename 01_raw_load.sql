-- ============================================================
-- STEP 1 — CREATE DATABASE + RAW TABLE + LOAD CSV
-- Staging Layer (Bronze Layer)
-- ============================================================

-- ── Create fresh database ───────────────────────────────────
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'MarketingAnalytics')
BEGIN
    ALTER DATABASE MarketingAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MarketingAnalytics;
END
GO

CREATE DATABASE MarketingAnalytics;
GO

USE MarketingAnalytics;
GO

-- ============================================================
-- RAW STAGING TABLE
-- Mirrors CSV exactly (no transformations)
-- ============================================================

CREATE TABLE raw_marketing_data (
    row_id               INT,
    report_date          VARCHAR(20),
    campaign_name        VARCHAR(150),
    campaign_type        VARCHAR(50),
    campaign_start_date  VARCHAR(20),
    campaign_end_date    VARCHAR(20),
    channel_name         VARCHAR(50),
    channel_type         VARCHAR(50),
    city                 VARCHAR(50),
    state                VARCHAR(50),
    region               VARCHAR(30),
    city_tier            VARCHAR(10),
    impressions          VARCHAR(20),
    clicks               VARCHAR(20),
    conversions          VARCHAR(20),
    spend                VARCHAR(20),
    revenue              VARCHAR(20),
    profit               VARCHAR(20),
    cpc_raw              VARCHAR(20),
    roas_raw             VARCHAR(20),
    ctr_raw              VARCHAR(20)
);
GO

-- ============================================================
-- LOAD CSV INTO STAGING TABLE
-- ============================================================

BULK INSERT raw_marketing_data
FROM 'D:\PowerBI_Raw_to_StarSchema\raw_marketing_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    ERRORFILE = 'D:\PowerBI_Raw_to_StarSchema\error_log.txt'
);
GO

-- ============================================================
-- BASIC VALIDATION (STAGING CHECKS)
-- ============================================================

-- Preview data
SELECT TOP 10 * 
FROM raw_marketing_data;
GO

-- Row count + sanity checks
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT campaign_name) AS unique_campaigns,
    COUNT(DISTINCT channel_name) AS unique_channels,
    COUNT(DISTINCT city) AS unique_cities,
    MIN(report_date) AS date_from,
    MAX(report_date) AS date_to
FROM raw_marketing_data;
GO

-- Null / blank checks (important for dirty data)
SELECT
    SUM(CASE WHEN campaign_name IS NULL OR campaign_name = '' THEN 1 ELSE 0 END) AS missing_campaigns,
    SUM(CASE WHEN channel_name IS NULL OR channel_name = '' THEN 1 ELSE 0 END) AS missing_channels,
    SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS missing_cities
FROM raw_marketing_data;
GO

PRINT '✅ STEP 1 COMPLETE: Raw data successfully loaded into staging layer.';
GO