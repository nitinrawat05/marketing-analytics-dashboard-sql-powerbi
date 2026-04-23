# 📊 Marketing Analytics Dashboard — Power BI

A senior-level Power BI project built on a **star schema** with 4,600+ daily marketing records across 20 campaigns, 8 channels, and 2 years (2023–2024).

---

## 🗂️ Repository Structure

```
├── marketing_analytics.pbix       # Main Power BI report
├── marketing_analytics.pbit       # Power BI template
├── DAX_Measures_Complete.txt      # All 35+ DAX measures documented
├── data/
│   ├── Fact_Marketing.csv         # 4,648 rows — core metrics
│   ├── Dim_Campaign.csv           # 20 campaigns
│   ├── Dim_Channel.csv            # 8 channels
│   ├── Dim_Geography.csv          # City / Region / Tier
│   └── Dim_Date.csv               # Date dimension
└── README.md
```

---

## 🧱 Data Model

Star schema with single-direction filters (Dim → Fact):

```
Dim_Campaign  ──┐
Dim_Channel   ──┤──► Fact_Marketing
Dim_Geography ──┤
Date_Table    ──┘
```

**Fact_Marketing columns:** `Record_ID | Date | Campaign_ID | Channel_ID | Geo_ID | Impressions | Clicks | Conversions | Spend | Revenue | Discount_Rate`

---

## 📐 DAX Measures (35+)

| Category | Measures |
|---|---|
| Core KPIs | Total Revenue, Spend, Clicks, Impressions, Conversions |
| Derived Metrics | ROAS, CPA, CPC, CTR, Conversion Rate, Profit Margin |
| Time Intelligence | YoY %, MTD, QTD, YTD, Rolling 30-Day |
| Ranking | Channel/Campaign rank by Revenue & ROAS |
| Efficiency Score | Weighted composite (ROAS 50%, CVR 30%, Volume 20%) |
| KPI Status | ROAS Status, Growth Arrow, CTR Benchmark |
| What-If | Simulated Spend / Revenue / ROAS |

---

## 📋 Dashboard Pages

1. **Executive Overview** — KPI cards, Revenue vs Spend trend, Channel donut, City map, Top 10 campaigns
2. **Channel Deep-Dive** — CTR/CPC/CPA/ROAS per channel, Campaign × Channel matrix
3. **Campaign Analytics** — Efficiency scores, Decomposition tree, Waterfall by Campaign Type
4. **Trend & Forecast** — MTD vs LY, YTD area chart, MoM growth
5. **Drill-Through** — Campaign-level, day-level, and geographic detail

---

## 🚀 Getting Started

1. Clone the repo
2. Open `marketing_analytics.pbix` in **Power BI Desktop** (June 2024+)
3. If prompted, point the data source to the `/data` CSVs
4. Refresh data — all relationships and DAX load automatically

To use the template (`.pbit`), open it and supply the CSV folder path when prompted.

---

## 🎨 Theme

Dark premium theme — `#0F172A` navy background, `#6366F1` indigo accent, Segoe UI. Import via **View → Customize Current Theme** using values in `DAX_Measures_Complete.txt`.

---

## 🛠️ Tech Stack

- Power BI Desktop
- DAX (Data Analysis Expressions)
- Power Query (M)
- CSV data sources
