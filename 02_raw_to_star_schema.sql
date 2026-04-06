-- ============================================================
--  STEP 2 — BUILD STAR SCHEMA FROM RAW DATA
--
--  This is the TRANSFORMATION LAYER.
--  We carve the raw flat table into:
--    Dim_Date       (generated, not from raw)
--    Dim_Channel    (extracted from raw)
--    Dim_Campaign   (extracted from raw)
--    Dim_Geography  (extracted from raw)
--    Fact_Marketing (cleaned + typed + FK-linked)
--
--  Run this AFTER 01_raw_load.sql
-- ============================================================

USE MarketingAnalytics;
GO


-- ════════════════════════════════════════════════════════════
--  DIM_DATE  — Generate full calendar, not extracted from raw
--  Senior devs ALWAYS build date dim independently so there
--  are no gaps even on days with zero marketing activity.
-- ════════════════════════════════════════════════════════════

CREATE TABLE Dim_Date (
    Date_Key        INT          NOT NULL PRIMARY KEY,   -- YYYYMMDD integer
    [Date]          DATE         NOT NULL,
    [Year]          SMALLINT     NOT NULL,
    Month_Number    TINYINT      NOT NULL,
    Month_Name      VARCHAR(12)  NOT NULL,
    Month_Short     CHAR(3)      NOT NULL,
    Quarter_Number  TINYINT      NOT NULL,
    Quarter         CHAR(2)      NOT NULL,
    Year_Month      CHAR(7)      NOT NULL,               -- 2023-06
    Year_Quarter    VARCHAR(8)   NOT NULL,               -- 2023-Q2
    Day_of_Week     VARCHAR(12)  NOT NULL,
    Day_Number      TINYINT      NOT NULL,               -- 1=Mon … 7=Sun
    Is_Weekend      BIT          NOT NULL
);
GO

-- Recursive CTE to generate every date 2023-01-01 → 2024-12-31
WITH DateSeries AS (
    SELECT CAST('2023-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt)
    FROM DateSeries
    WHERE dt < '2024-12-31'
)
INSERT INTO Dim_Date
SELECT
    CAST(FORMAT(dt, 'yyyyMMdd') AS INT)        AS Date_Key,
    dt                                          AS [Date],
    YEAR(dt)                                    AS [Year],
    MONTH(dt)                                   AS Month_Number,
    DATENAME(MONTH, dt)                         AS Month_Name,
    LEFT(DATENAME(MONTH, dt), 3)                AS Month_Short,
    DATEPART(QUARTER, dt)                       AS Quarter_Number,
    'Q' + CAST(DATEPART(QUARTER, dt) AS CHAR(1)) AS Quarter,
    FORMAT(dt, 'yyyy-MM')                       AS Year_Month,
    CAST(YEAR(dt) AS VARCHAR) + '-Q'
        + CAST(DATEPART(QUARTER,dt) AS VARCHAR) AS Year_Quarter,
    DATENAME(WEEKDAY, dt)                       AS Day_of_Week,
    DATEPART(WEEKDAY, dt)                       AS Day_Number,
    CASE WHEN DATEPART(WEEKDAY, dt) IN (1,7)
         THEN 1 ELSE 0 END                      AS Is_Weekend
FROM DateSeries
OPTION (MAXRECURSION 1000);
GO

SELECT COUNT(*) AS Dim_Date_Rows FROM Dim_Date;   -- expect 731
GO


-- ════════════════════════════════════════════════════════════
--  DIM_CHANNEL — Distinct channels extracted from raw
--  TRIM + UPPER used to handle dirty casing from ad exports
-- ════════════════════════════════════════════════════════════

CREATE TABLE Dim_Channel (
    Channel_ID    INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    Channel_Name  VARCHAR(50)  NOT NULL,
    Channel_Type  VARCHAR(50)  NOT NULL,
    Platform_Type VARCHAR(20)  NOT NULL
);
GO

INSERT INTO Dim_Channel (Channel_Name, Channel_Type, Platform_Type)
SELECT
    TRIM(channel_name)  AS Channel_Name,
    TRIM(channel_type)  AS Channel_Type,
    -- Derive Platform_Type from channel_type
    CASE TRIM(channel_type)
        WHEN 'Email'     THEN 'Owned'
        WHEN 'Affiliate' THEN 'Partner'
        ELSE                  'Paid'
    END                 AS Platform_Type
FROM (
    SELECT DISTINCT channel_name, channel_type
    FROM raw_marketing_data
    WHERE channel_name IS NOT NULL
      AND TRIM(channel_name) <> ''
) AS distinct_channels
ORDER BY channel_name;
GO

SELECT * FROM Dim_Channel;
GO


-- ════════════════════════════════════════════════════════════
--  DIM_CAMPAIGN — Distinct campaigns with their date ranges
--  We use MIN/MAX on dates in case of duplicates in raw
-- ════════════════════════════════════════════════════════════

CREATE TABLE Dim_Campaign (
    Campaign_ID     INT          NOT NULL PRIMARY KEY IDENTITY(1,1),
    Campaign_Name   VARCHAR(150) NOT NULL,
    Campaign_Type   VARCHAR(50)  NOT NULL,
    Start_Date      DATE         NOT NULL,
    End_Date        DATE         NOT NULL,
    Duration_Days   AS DATEDIFF(DAY, Start_Date, End_Date) PERSISTED  -- computed column
);
GO

INSERT INTO Dim_Campaign (Campaign_Name, Campaign_Type, Start_Date, End_Date)
SELECT
    TRIM(campaign_name)                         AS Campaign_Name,
    TRIM(campaign_type)                         AS Campaign_Type,
    MIN(CAST(campaign_start_date AS DATE))      AS Start_Date,
    MAX(CAST(campaign_end_date   AS DATE))      AS End_Date
FROM raw_marketing_data
WHERE campaign_name IS NOT NULL
  AND TRIM(campaign_name) <> ''
GROUP BY TRIM(campaign_name), TRIM(campaign_type)
ORDER BY MIN(CAST(campaign_start_date AS DATE));
GO

SELECT * FROM Dim_Campaign;
GO


-- ════════════════════════════════════════════════════════════
--  DIM_GEOGRAPHY — Cities, states, regions
-- ════════════════════════════════════════════════════════════

CREATE TABLE Dim_Geography (
    Geo_ID  INT         NOT NULL PRIMARY KEY IDENTITY(1,1),
    City    VARCHAR(50) NOT NULL,
    State   VARCHAR(50) NOT NULL,
    Region  VARCHAR(30) NOT NULL,
    Tier    VARCHAR(10) NOT NULL
);
GO

INSERT INTO Dim_Geography (City, State, Region, Tier)
SELECT DISTINCT
    TRIM(city)      AS City,
    TRIM(state)     AS State,
    TRIM(region)    AS Region,
    TRIM(city_tier) AS Tier
FROM raw_marketing_data
WHERE city IS NOT NULL
  AND TRIM(city) <> ''
ORDER BY city;
GO

SELECT * FROM Dim_Geography;
GO


-- ════════════════════════════════════════════════════════════
--  FACT_MARKETING — Cleaned, typed, and FK-linked
--  This is the most important transformation step.
--  We JOIN back to all dimensions to get their surrogate keys.
-- ════════════════════════════════════════════════════════════

CREATE TABLE Fact_Marketing (
    Fact_ID         BIGINT        NOT NULL PRIMARY KEY IDENTITY(1,1),
    Date_Key        INT           NOT NULL,
    [Date]          DATE          NOT NULL,
    Campaign_ID     INT           NOT NULL,
    Channel_ID      INT           NOT NULL,
    Geo_ID          INT           NOT NULL,
    Impressions     BIGINT        NOT NULL DEFAULT 0,
    Clicks          BIGINT        NOT NULL DEFAULT 0,
    Conversions     INT           NOT NULL DEFAULT 0,
    Spend           DECIMAL(18,2) NOT NULL DEFAULT 0,
    Revenue         DECIMAL(18,2) NOT NULL DEFAULT 0,
    Profit          AS (Revenue - Spend) PERSISTED,   -- computed, always consistent

    CONSTRAINT FK_Fact_Date     FOREIGN KEY (Date_Key)    REFERENCES Dim_Date(Date_Key),
    CONSTRAINT FK_Fact_Campaign FOREIGN KEY (Campaign_ID) REFERENCES Dim_Campaign(Campaign_ID),
    CONSTRAINT FK_Fact_Channel  FOREIGN KEY (Channel_ID)  REFERENCES Dim_Channel(Channel_ID),
    CONSTRAINT FK_Fact_Geo      FOREIGN KEY (Geo_ID)      REFERENCES Dim_Geography(Geo_ID)
);
GO

-- ── The main transformation INSERT ───────────────────────────
-- JOIN raw → all 4 dimensions to resolve surrogate keys
-- CAST all numeric strings to proper types
-- Filter out bad rows (negative spend, null dates)

INSERT INTO Fact_Marketing
    (Date_Key, [Date], Campaign_ID, Channel_ID, Geo_ID,
     Impressions, Clicks, Conversions, Spend, Revenue)
SELECT
    dd.Date_Key,
    CAST(r.report_date AS DATE)             AS [Date],
    dc.Campaign_ID,
    dch.Channel_ID,
    dg.Geo_ID,
    ABS(CAST(r.impressions  AS BIGINT))     AS Impressions,   -- ABS handles rare negatives
    ABS(CAST(r.clicks       AS BIGINT))     AS Clicks,
    ABS(CAST(r.conversions  AS INT))        AS Conversions,
    ABS(CAST(r.spend        AS DECIMAL(18,2))) AS Spend,
    ABS(CAST(r.revenue      AS DECIMAL(18,2))) AS Revenue

FROM raw_marketing_data r

-- Resolve Date surrogate key
INNER JOIN Dim_Date dd
    ON dd.Date_Key = CAST(FORMAT(CAST(r.report_date AS DATE), 'yyyyMMdd') AS INT)

-- Resolve Campaign surrogate key
INNER JOIN Dim_Campaign dc
    ON dc.Campaign_Name = TRIM(r.campaign_name)

-- Resolve Channel surrogate key
INNER JOIN Dim_Channel dch
    ON dch.Channel_Name = TRIM(r.channel_name)

-- Resolve Geography surrogate key
INNER JOIN Dim_Geography dg
    ON dg.City = TRIM(r.city)

-- Data quality filters — exclude garbage rows
WHERE r.report_date  IS NOT NULL
  AND TRIM(r.report_date)  <> ''
  AND r.campaign_name IS NOT NULL
  AND TRIM(r.campaign_name) <> ''
  AND ISNUMERIC(r.spend)   = 1
  AND ISNUMERIC(r.revenue) = 1
  AND ISNUMERIC(r.clicks)  = 1
  AND CAST(r.impressions AS BIGINT) >= 0;
GO

-- ── Performance indexes ───────────────────────────────────────
CREATE INDEX IX_Fact_Date     ON Fact_Marketing(Date_Key)    INCLUDE (Revenue, Spend, Conversions);
CREATE INDEX IX_Fact_Campaign ON Fact_Marketing(Campaign_ID) INCLUDE (Revenue, Spend);
CREATE INDEX IX_Fact_Channel  ON Fact_Marketing(Channel_ID)  INCLUDE (Revenue, Spend, Clicks, Impressions);
CREATE INDEX IX_Fact_Geo      ON Fact_Marketing(Geo_ID)      INCLUDE (Revenue, Conversions);
CREATE INDEX IX_Fact_Date2    ON Fact_Marketing([Date]);
GO

PRINT '✅ Star schema built from raw data.';

-- ── Final row counts ──────────────────────────────────────────
SELECT 'raw_marketing_data' AS [Table], COUNT(*) AS [Rows] FROM raw_marketing_data UNION ALL
SELECT 'Dim_Date',                       COUNT(*) FROM Dim_Date       UNION ALL
SELECT 'Dim_Channel',                    COUNT(*) FROM Dim_Channel     UNION ALL
SELECT 'Dim_Campaign',                   COUNT(*) FROM Dim_Campaign    UNION ALL
SELECT 'Dim_Geography',                  COUNT(*) FROM Dim_Geography   UNION ALL
SELECT 'Fact_Marketing',                 COUNT(*) FROM Fact_Marketing;
GO
