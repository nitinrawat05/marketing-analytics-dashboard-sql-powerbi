USE MarketingAnalytics;
GO

-- ============================================================
-- VIEW 1: Executive KPI
-- ============================================================
CREATE OR ALTER VIEW vw_Executive_KPI AS
SELECT
    dd.[Year],
    dd.Quarter,
    dd.Month_Name,
    dd.Month_Number,
    dd.Year_Month,
    dd.Year_Quarter,

    COUNT(DISTINCT f.Campaign_ID) AS Active_Campaigns,
    COUNT(DISTINCT f.Channel_ID)  AS Active_Channels,
    SUM(f.Impressions)            AS Total_Impressions,
    SUM(f.Clicks)                 AS Total_Clicks,
    SUM(f.Conversions)            AS Total_Conversions,
    SUM(f.Spend)                  AS Total_Spend,
    SUM(f.Revenue)                AS Total_Revenue,
    SUM(f.Profit)                 AS Total_Profit,

    CAST(SUM(f.Revenue) AS FLOAT) / NULLIF(SUM(f.Spend), 0)        AS ROAS,
    CAST(SUM(f.Clicks) AS FLOAT) / NULLIF(SUM(f.Impressions), 0)   AS CTR,
    SUM(f.Spend) / NULLIF(SUM(f.Conversions), 0)                   AS CPA,
    CAST(SUM(f.Conversions) AS FLOAT) / NULLIF(SUM(f.Clicks), 0)   AS CVR

FROM Fact_Marketing f
JOIN Dim_Date dd ON f.Date_Key = dd.Date_Key
GROUP BY
    dd.[Year], dd.Quarter, dd.Month_Name,
    dd.Month_Number, dd.Year_Month, dd.Year_Quarter;
GO

-- ============================================================
-- VIEW 2: Channel Performance
-- ============================================================
CREATE OR ALTER VIEW vw_Channel_Performance AS
SELECT
    dc.Channel_Name,
    dc.Channel_Type,
    dc.Platform_Type,

    dd.[Year],
    dd.Quarter,
    dd.Month_Name,
    dd.Month_Number,
    dd.Year_Month,

    SUM(f.Impressions) AS Impressions,
    SUM(f.Clicks)      AS Clicks,
    SUM(f.Conversions) AS Conversions,
    SUM(f.Spend)       AS Spend,
    SUM(f.Revenue)     AS Revenue,
    SUM(f.Profit)      AS Profit,

    CAST(SUM(f.Revenue) AS FLOAT) / NULLIF(SUM(f.Spend), 0)        AS ROAS,
    CAST(SUM(f.Clicks) AS FLOAT) / NULLIF(SUM(f.Impressions), 0)   AS CTR,
    SUM(f.Spend) / NULLIF(SUM(f.Clicks), 0)                        AS CPC,
    SUM(f.Spend) / NULLIF(SUM(f.Conversions), 0)                   AS CPA,
    CAST(SUM(f.Conversions) AS FLOAT) / NULLIF(SUM(f.Clicks), 0)   AS CVR,

    CAST(SUM(f.Revenue) AS FLOAT) /
    NULLIF(SUM(SUM(f.Revenue)) OVER (PARTITION BY dd.[Year], dd.Month_Number), 0)
    AS Revenue_Share_Pct

FROM Fact_Marketing f
JOIN Dim_Channel dc ON f.Channel_ID = dc.Channel_ID
JOIN Dim_Date dd    ON f.Date_Key   = dd.Date_Key
GROUP BY
    dc.Channel_Name, dc.Channel_Type, dc.Platform_Type,
    dd.[Year], dd.Quarter, dd.Month_Name, dd.Month_Number, dd.Year_Month;
GO

-- ============================================================
-- VIEW 3: Campaign Performance
-- ============================================================
CREATE OR ALTER VIEW vw_Campaign_Performance AS
SELECT
    ca.Campaign_Name,
    ca.Campaign_Type,
    ca.Start_Date,
    ca.End_Date,
    ca.Duration_Days,

    dc.Channel_Name,
    dc.Platform_Type,

    dg.Region,
    dg.Tier,

    dd.[Year],
    dd.Quarter,
    dd.Month_Name,
    dd.Month_Number,

    SUM(f.Impressions) AS Impressions,
    SUM(f.Clicks)      AS Clicks,
    SUM(f.Conversions) AS Conversions,
    SUM(f.Spend)       AS Spend,
    SUM(f.Revenue)     AS Revenue,
    SUM(f.Profit)      AS Profit,

    CAST(SUM(f.Revenue) AS FLOAT) / NULLIF(SUM(f.Spend), 0)        AS ROAS,
    SUM(f.Spend) / NULLIF(SUM(f.Conversions), 0)                   AS CPA,
    CAST(SUM(f.Conversions) AS FLOAT) / NULLIF(SUM(f.Clicks), 0)   AS CVR,

    RANK() OVER (
        PARTITION BY dd.[Year]
        ORDER BY SUM(f.Revenue) DESC
    ) AS Campaign_Rank_by_Revenue

FROM Fact_Marketing f
JOIN Dim_Campaign ca ON f.Campaign_ID = ca.Campaign_ID
JOIN Dim_Channel dc  ON f.Channel_ID  = dc.Channel_ID
JOIN Dim_Geography dg ON f.Geo_ID     = dg.Geo_ID
JOIN Dim_Date dd      ON f.Date_Key   = dd.Date_Key
GROUP BY
    ca.Campaign_Name, ca.Campaign_Type, ca.Start_Date, ca.End_Date, ca.Duration_Days,
    dc.Channel_Name, dc.Platform_Type,
    dg.Region, dg.Tier,
    dd.[Year], dd.Quarter, dd.Month_Name, dd.Month_Number;
GO

-- ============================================================
-- VIEW 4: Daily Trend
-- ============================================================
CREATE OR ALTER VIEW vw_Daily_Trend AS
SELECT
    f.[Date],
    dd.[Year],
    dd.Quarter,
    dd.Month_Name,
    dd.Month_Number,
    dd.Year_Month,
    dd.Day_of_Week,
    dd.Is_Weekend,

    dc.Channel_Name,
    dc.Platform_Type,

    SUM(f.Impressions) AS Impressions,
    SUM(f.Clicks)      AS Clicks,
    SUM(f.Conversions) AS Conversions,
    SUM(f.Spend)       AS Spend,
    SUM(f.Revenue)     AS Revenue,
    SUM(f.Profit)      AS Profit

FROM Fact_Marketing f
JOIN Dim_Date dd    ON f.Date_Key   = dd.Date_Key
JOIN Dim_Channel dc ON f.Channel_ID = dc.Channel_ID
GROUP BY
    f.[Date], dd.[Year], dd.Quarter, dd.Month_Name, dd.Month_Number,
    dd.Year_Month, dd.Day_of_Week, dd.Is_Weekend,
    dc.Channel_Name, dc.Platform_Type;
GO

-- ============================================================
-- VIEW 5: Geography Performance
-- ============================================================
CREATE OR ALTER VIEW vw_Geography_Performance AS
SELECT
    dg.City,
    dg.State,
    dg.Region,
    dg.Tier,

    dd.[Year],
    dd.Quarter,

    SUM(f.Impressions) AS Impressions,
    SUM(f.Clicks)      AS Clicks,
    SUM(f.Conversions) AS Conversions,
    SUM(f.Spend)       AS Spend,
    SUM(f.Revenue)     AS Revenue,
    SUM(f.Profit)      AS Profit,

    CAST(SUM(f.Revenue) AS FLOAT) / NULLIF(SUM(f.Spend), 0) AS ROAS,

    RANK() OVER (
        PARTITION BY dg.Region, dd.[Year]
        ORDER BY SUM(f.Revenue) DESC
    ) AS City_Rank_in_Region

FROM Fact_Marketing f
JOIN Dim_Geography dg ON f.Geo_ID   = dg.Geo_ID
JOIN Dim_Date dd      ON f.Date_Key = dd.Date_Key
GROUP BY
    dg.City, dg.State, dg.Region, dg.Tier,
    dd.[Year], dd.Quarter;
GO

-- ============================================================
-- VIEW 6: YoY Comparison (FIXED)
-- ============================================================
CREATE OR ALTER VIEW vw_YoY_Comparison AS
WITH monthly AS (
    SELECT
        dd.[Year],
        dd.Month_Number,
        dd.Month_Short,
        SUM(f.Revenue)     AS Revenue,
        SUM(f.Spend)       AS Spend,
        SUM(f.Conversions) AS Conversions,
        CAST(SUM(f.Revenue) AS FLOAT) / NULLIF(SUM(f.Spend), 0) AS ROAS
    FROM Fact_Marketing f
    JOIN Dim_Date dd ON f.Date_Key = dd.Date_Key
    GROUP BY dd.[Year], dd.Month_Number, dd.Month_Short
)
SELECT
    curr.[Year],
    curr.Month_Number,
    curr.Month_Short,
    curr.Revenue AS Revenue_CY,
    prev.Revenue AS Revenue_PY,

    curr.Revenue - prev.Revenue AS Revenue_Growth_Abs,
    CAST(curr.Revenue - prev.Revenue AS FLOAT) / NULLIF(prev.Revenue, 0)
    AS Revenue_Growth_Pct

FROM monthly curr
LEFT JOIN monthly prev
    ON prev.[Year] = curr.[Year] - 1
   AND prev.Month_Number = curr.Month_Number;
GO