# 📊 Marketing Analytics Dashboard — Power BI

An end-to-end Marketing Analytics Dashboard built in Power BI to analyze campaign performance, optimize marketing spend, and track funnel efficiency across **20 campaigns, 8 channels, and 2 years (2023–2024)**.

> Built on a star schema with 4,648 daily records and 35+ DAX measures.

---

## 🎯 Objectives

- Analyze marketing performance across channels and campaigns
- Optimize budget allocation using ROI-driven metrics
- Identify high-performing and underperforming campaigns
- Track user journey from Impressions → Clicks → Conversions

---

## 🗂️ Data Model

Star schema — single-direction filters (Dim → Fact):

```
Dim_Campaign  ──┐
Dim_Channel   ──┤──► Fact_Marketing (4,648 rows)
Dim_Geography ──┤
Date_Table    ──┘
```

**Source:** CSV flat files loaded via Power Query

---

## 📊 Key Metrics

`Revenue` · `Conversions` · `CTR` · `Conversion Rate` · `ROAS` · `CPA` · `CPC` · `Profit Margin`

---

## 📌 Dashboard Pages

### 1. Executive Overview
- KPI cards with YoY growth indicators
- Revenue vs Spend trend (dual axis)
- Revenue by Channel (donut) + City map

### 2. Channel Performance
- ROAS and CPA by channel
- Revenue contribution analysis
- Top vs underperforming channel identification

### 3. Funnel Analysis
- Impressions → Clicks → Conversions funnel
- Drop-off rate at each stage
- Conversion efficiency tracking

### 4. Time Series & Trends
- Revenue MTD vs Last Year
- CTR & Conversion Rate trends over time
- MoM growth %

### 5. 🔥 Budget Optimization — Quadrant Analysis
Scatter chart that segments every campaign into 4 action zones:

| Quadrant | Spend | Revenue | Action |
|---|---|---|---|
| Scale | High | High | Increase budget |
| Invest More | Low | High | Scale up |
| Reduce | High | Low | Cut or optimize |
| Monitor | Low | Low | Watch closely |

---

## 🧠 DAX Measures (35+)

| Category | Measures |
|---|---|
| Core KPIs | Revenue, Spend, Clicks, Impressions, Conversions |
| Derived | ROAS, CPA, CPC, CTR, Conversion Rate, Profit Margin % |
| Time Intelligence | YoY %, MTD, QTD, YTD, Rolling 30-Day |
| Ranking | RANKX by Revenue & ROAS, Top Channel/Campaign |
| Efficiency Score | Weighted: ROAS 50% + CVR 30% + Volume 20% |
| KPI Status | 🟢🟡🟠🔴 ROAS bands, Growth Arrow, CTR Benchmark |
| What-If | Simulated Spend / Revenue / ROAS via slicer |

---

## 🎨 Design

- Dark premium theme (`#0F172A` navy, `#6366F1` indigo accent)
- Sidebar navigation for multi-page UX
- KPI cards with conditional growth indicators
- Drill-through pages for campaign/geo deep-dives
- Decomposition tree for root-cause analysis

---

## 🛠️ Tools

Power BI · DAX · Power Query (M) · CSV

---

## 🚀 Getting Started

```
1. Clone the repo
2. Open marketing_analytics.pbix in Power BI Desktop (June 2024+)
3. Point data source to /data folder if prompted
4. Refresh — all relationships and measures load automatically
```

---

## 🔮 Future Improvements

- [ ] **Forecasting** — integrate Power BI's built-in time series forecast or connect Azure ML
- [ ] **Row-Level Security (RLS)** — restrict data access by region or channel manager
- [ ] **Real-time data** — connect to a live database (PostgreSQL / Azure SQL) instead of CSV
- [ ] **Budget vs Actual** — add a budget target table and track variance
- [ ] **Anomaly Detection** — use Power BI's built-in anomaly highlighting on trend charts
- [ ] **Export to PDF** — scheduled report subscription for stakeholders

---

## 💡 Outcome

The dashboard enables stakeholders to quickly identify:
- Where to **scale** marketing spend
- Where to **reduce** inefficiencies
- Which channels drive the most value

---

## 🔗 Author

**Nitin Rawat** — Data Analyst / BI Analyst

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://linkedin.com/in/nitin-rawat-a38536270)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/nitinrawat05)
