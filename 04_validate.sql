-- ============================================================
--  STEP 4 — VALIDATE EVERYTHING
--  Run these after 01, 02, 03.
--  Checks data quality, FK integrity, and KPI sanity.
-- ============================================================

USE MarketingAnalytics;
GO

-- ── 1. Row counts — raw vs fact (expect fact ≤ raw) ──────────
SELECT 'raw_marketing_data' AS [Layer],  COUNT(*) AS [Rows] FROM raw_marketing_data  UNION ALL
SELECT 'Dim_Date',                        COUNT(*) FROM Dim_Date                       UNION ALL
SELECT 'Dim_Channel',                     COUNT(*) FROM Dim_Channel                    UNION ALL
SELECT 'Dim_Campaign',                    COUNT(*) FROM Dim_Campaign                   UNION ALL
SELECT 'Dim_Geography',                   COUNT(*) FROM Dim_Geography                  UNION ALL
SELECT 'Fact_Marketing',                  COUNT(*) FROM Fact_Marketing;
GO

-- ── 2. FK integrity — all must return 0 ──────────────────────
SELECT
    'Orphan Campaign_ID' AS [Check],
    COUNT(*) AS [Orphan_Rows]
FROM Fact_Marketing
WHERE Campaign_ID NOT IN (SELECT Campaign_ID FROM Dim_Campaign)

UNION ALL

SELECT 'Orphan Channel_ID', COUNT(*)
FROM Fact_Marketing
WHERE Channel_ID NOT IN (SELECT Channel_ID FROM Dim_Channel)

UNION ALL

SELECT 'Orphan Geo_ID', COUNT(*)
FROM Fact_Marketing
WHERE Geo_ID NOT IN (SELECT Geo_ID FROM Dim_Geography)

UNION ALL

SELECT 'Orphan Date_Key', COUNT(*)
FROM Fact_Marketing
WHERE Date_Key NOT IN (SELECT Date_Key FROM Dim_Date);
GO

-- ── 3. Overall KPI sanity check ───────────────────────────────
SELECT
    FORMAT(SUM(Revenue),     'N0') AS Total_Revenue,
    FORMAT(SUM(Spend),       'N0') AS Total_Spend,
    FORMAT(SUM(Profit),      'N0') AS Total_Profit,
    FORMAT(SUM(Conversions), 'N0') AS Total_Conversions,
    FORMAT(SUM(Clicks),      'N0') AS Total_Clicks,
    FORMAT(SUM(Impressions), 'N0') AS Total_Impressions,
    FORMAT(CAST(SUM(Revenue) AS FLOAT) / NULLIF(SUM(Spend),0), 'N2') AS Overall_ROAS
FROM Fact_Marketing;
GO

-- ── 4. Revenue by channel (top-level sanity) ─────────────────
SELECT
    dc.Channel_Name,
    FORMAT(SUM(f.Revenue), 'N0')   AS Revenue,
    FORMAT(SUM(f.Spend),   'N0')   AS Spend,
    FORMAT(CAST(SUM(f.Revenue) AS FLOAT)
        / NULLIF(SUM(f.Spend),0), 'N2') AS ROAS,
    SUM(f.Conversions)              AS Conversions
FROM Fact_Marketing f
JOIN Dim_Channel dc ON f.Channel_ID = dc.Channel_ID
GROUP BY dc.Channel_Name
ORDER BY SUM(f.Revenue) DESC;
GO

-- ── 5. Monthly trend — check for gaps ────────────────────────
SELECT
    dd.Year_Month,
    FORMAT(SUM(f.Revenue), 'N0')  AS Revenue,
    FORMAT(SUM(f.Spend),   'N0')  AS Spend,
    SUM(f.Conversions)            AS Conversions,
    COUNT(*)                      AS Fact_Rows
FROM Fact_Marketing f
JOIN Dim_Date dd ON f.Date_Key = dd.Date_Key
GROUP BY dd.Year_Month
ORDER BY dd.Year_Month;
GO

-- ── 6. Top 10 campaigns ───────────────────────────────────────
SELECT TOP 10
    ca.Campaign_Name,
    ca.Campaign_Type,
    FORMAT(SUM(f.Revenue), 'N0') AS Revenue,
    FORMAT(CAST(SUM(f.Revenue) AS FLOAT)
        / NULLIF(SUM(f.Spend),0), 'N2') AS ROAS,
    SUM(f.Conversions) AS Conversions
FROM Fact_Marketing f
JOIN Dim_Campaign ca ON f.Campaign_ID = ca.Campaign_ID
GROUP BY ca.Campaign_Name, ca.Campaign_Type
ORDER BY SUM(f.Revenue) DESC;
GO

-- ── 7. Rows dropped during transformation ─────────────────────
-- Tells you how many raw rows were excluded (quality issues)
SELECT
    (SELECT COUNT(*) FROM raw_marketing_data) AS Raw_Rows,
    (SELECT COUNT(*) FROM Fact_Marketing)     AS Fact_Rows,
    (SELECT COUNT(*) FROM raw_marketing_data)
        - (SELECT COUNT(*) FROM Fact_Marketing) AS Rows_Dropped,
    FORMAT(
        CAST(
            (SELECT COUNT(*) FROM raw_marketing_data)
            - (SELECT COUNT(*) FROM Fact_Marketing)
        AS FLOAT) /
        NULLIF((SELECT COUNT(*) FROM raw_marketing_data), 0),
    'P1') AS Drop_Rate;
GO
