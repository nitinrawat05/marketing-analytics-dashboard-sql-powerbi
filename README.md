# 📊 Marketing Performance Dashboard
### Power BI | Multi-Page Analytics Dashboard

> A comprehensive marketing analytics solution built in Power BI, covering executive KPIs, channel efficiency, funnel conversion analysis, time-series trends, and budget optimization — all in a single interactive report.

---

## 🗂️ Dashboard Pages Overview

### 1. 🏠 Executive Overview
**Purpose:** High-level summary for senior stakeholders.

| KPI | Value |
|-----|-------|
| Total Revenue | $410.82M |
| Total Profit | $307.17M |
| ROAS | 3.96 |
| CPA | 217.17 |
| Profit Margin | 74.8% |
| Total Spend | $103.65M |

**Visuals Included:**
- Total Revenue Over Time (Line Chart)
- Profit by Channel (Horizontal Bar)
- Total Revenue by Channel (Horizontal Bar)
- Total Spend and Revenue by Channel (Grouped Bar)

---

### 2. 📡 Channel Performance Analysis
**Purpose:** Deep dive into per-channel efficiency metrics.

**Visuals Included:**
- ROAS by Channel (Horizontal Bar — Green)
- CPA by Channel (Horizontal Bar — Red)
- Spend vs Revenue Bubble Chart (Channel Efficiency)
- Channel Summary Table: Revenue, Spend, Profit, ROAS

**Top Insight:** Email achieves the highest ROAS (6.42), while LinkedIn Ads has the highest CPA (~900+).

---

### 3. 🔁 Funnel Analysis
**Purpose:** Track the customer journey from Impression to Conversion.

| Metric | Value |
|--------|-------|
| Total Impressions | 239M |
| Total Clicks | 11M |
| Total Conversions | 477K |
| CTR | 4.7% |
| Conversion Rate | 4.23% |
| Clicks → Conversions Drop-off | **95.77%** |
| Impressions → Clicks Drop-off | **95.27%** |

**Visuals Included:**
- Customer Acquisition Funnel (Waterfall/Bar)
- CTR by Channel (Bar)
- Conversion Rate by Channel (Bar)
- Spend vs Conversions Scatter (Channel Efficiency)

**Key Insight:** The biggest drop-off occurs between Clicks and Conversions (~93%). Email leads in both CTR and conversion rate.

---

### 4. 📈 Time Series & Trends
**Purpose:** Analyze performance over time (2023–2024).

**Visuals Included:**
- Revenue Trend Over Time (Line Chart with benchmark line)
- CTR and Conversion Rate by Year-Month (Dual-line)
- Total Revenue by Month and Channel (Multi-line)

**Key Insights:**
- Revenue shows a **declining trend** over the period — indicates potential budget reallocation or reduced campaign performance.
- CTR improved by **8.3%** over time — better ad engagement.
- **Email** is the top-performing channel with steady revenue growth.

---

### 5. 💰 Budget Optimization
**Purpose:** Strategic spend allocation recommendations using quadrant analysis.

**Visuals Included:**
- Spend vs Revenue Quadrant Chart (Scale / Monitor / Invest / Reduce)
- ROAS by Channel (Horizontal Bar)
- CPA by Channel (Horizontal Bar)
- Sum of Spend and Conversions by Month (Dual-axis Line)

**Quadrant Classification:**
| Quadrant | Channels | Recommendation |
|----------|----------|----------------|
| 🟢 Scale | Google Ads | High Spend, High Revenue — Keep investing |
| 🟡 Invest More | Facebook Ads | Low Spend, Low Revenue — Increase budget |
| 🟠 Monitor | Email, Affiliate | Low Spend, Low Revenue — Optimize |
| 🔴 Reduce | (High Spend, Low Revenue) | Cut budget |

**Key Recommendations:**
- 📧 Email delivers highest returns → **Prioritize budget allocation**
- 🔍 Paid Search shows inefficiency → **Optimize targeting, reduce waste**
- 🤝 Affiliate enables low-cost conversions → **Scale for efficient growth**

---

## 🧭 Navigation Structure

The dashboard uses a **left sidebar navigation** with 5 clearly labeled pages:

```
├── Executive Dashboard
├── Channel Performance
├── Funnel Analysis
├── Time Series & Trends
└── Budget Optimization
```

---

## 🛠️ Tools & Technologies

| Tool | Usage |
|------|-------|
| **Power BI Desktop** | Report creation & publishing |
| **DAX** | KPI calculations, ROAS, CPA, Profit Margin |
| **Power Query (M)** | Data transformation & shaping |
| **Custom Visuals** | Funnel chart, Scatter/Bubble chart |

---

## 📐 Data Model Assumptions

- Data spans **January 2023 – December 2024**
- Channels: Google Ads, Facebook Ads, Email, Affiliate, Instagram Ads, YouTube Ads, LinkedIn Ads
- Regions available as slicer (East, West, North, South, All)
- Metrics tracked: Impressions, Clicks, Conversions, Spend, Revenue, Profit

---

## 📊 Dashboard Level Assessment

### ⭐⭐⭐⭐☆ — **Advanced / Professional Level**

| Criteria | Rating | Notes |
|----------|--------|-------|
| **Complexity** | ⭐⭐⭐⭐☆ | 5-page multi-tab structure, cross-page navigation |
| **DAX Depth** | ⭐⭐⭐⭐☆ | ROAS, CPA, Profit Margin, Drop-off % are non-trivial measures |
| **Visualization Variety** | ⭐⭐⭐⭐⭐ | Line, Bar, Bubble, Funnel, Scatter, Quadrant, KPI cards |
| **Design & UX** | ⭐⭐⭐⭐☆ | Clean dark sidebar nav, consistent color palette (green/red/blue) |
| **Business Insight** | ⭐⭐⭐⭐⭐ | Actionable insights embedded directly in the report |
| **Interactivity** | ⭐⭐⭐⭐☆ | Date slicer, Region slicer, cross-filtering |
| **Storytelling** | ⭐⭐⭐⭐⭐ | Clear narrative flow: Overview → Deep Dive → Funnel → Trends → Action |

**Overall: Advanced Portfolio-Grade Dashboard** — suitable for a Data Analyst, BI Developer, or Marketing Analyst role.

---

## 💡 Key Insights Summary

| # | Insight |
|---|---------|
| 1 | **Email is the most efficient channel** — highest ROAS (6.42) and lowest CPA |
| 2 | **Google Ads drives the most absolute revenue** (~155M profit), worth scaling |
| 3 | **95.77% drop-off between Clicks and Conversions** — landing page optimization needed |
| 4 | **Revenue is declining over time** — investigate budget reallocation since mid-2023 |
| 5 | **LinkedIn & YouTube Ads** have very high CPA (800–900+) — review ROI |
| 6 | **Affiliate is underutilized** — low spend, solid returns, room to scale |
| 7 | **CTR improved 8.3%** — ad creatives and targeting are improving even if revenue dips |
| 8 | **74.8% Profit Margin** is exceptionally strong for a marketing operation |

---

## 📁 File Structure

```
Marketing-Dashboard/
│
├── MarketingDashboard.pbix        # Main Power BI file
├── README.md                      # This file
├── data/
│   └── marketing_data.csv         # Source dataset
└── screenshots/
    ├── 01_executive_overview.png
    ├── 02_channel_performance.png
    ├── 03_funnel_analysis.png
    ├── 04_time_series.png
    └── 05_budget_optimization.png
```

---

## 👤 Author

Built as part of a marketing analytics portfolio project demonstrating end-to-end BI development — from data modeling and DAX to visual design and insight storytelling.

---

*Built with ❤️ in Power BI*
