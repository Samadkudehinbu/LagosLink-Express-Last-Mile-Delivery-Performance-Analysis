# 🚚 LagosLink Express — Last-Mile Delivery Performance Analysis

🔗 **[View Live Report](https://app.powerbi.com/view?r=eyJrIjoiNzg3OGE0MWEtNjY0Zi00M2RiLWE1OWMtMzMxZWZiYmEzNDdmIiwidCI6IjgxMTQ1ZWNkLTc5NTAtNDk4Ny1hOGFmLTJhMDY1YTgwMWVhYyJ9)** &nbsp;|&nbsp; 📃
**[Dataset](Datasets)** &nbsp;|&nbsp; 📖
**[Medium Article](https://medium.com/@kudehinbusamad/analysing-last-mile-delivery-performance-across-12-lagos-zones-a-sql-power-bi-case-study-2c3b8805b20e)**
 &nbsp;|&nbsp; 👤 **[LinkedIn](https://www.linkedin.com/in/abdulsamad-kudehinbu/)** &nbsp;|&nbsp; 🌐 **[Portfolio](https://sites.google.com/view/abdulsamadportfolio/home)**  
---

## 📌 Overview

This project is a full end-to-end data analysis of last-mile delivery operations for **LagosLink Express**, a fictional Lagos-based logistics company. It covers 8,000 delivery orders across 12 Lagos zones over two years (January 2024 – December 2025), analysing delivery success rates, SLA compliance, courier performance, and operational trends.

The analysis was built to reflect the real challenges facing logistics companies operating in Lagos — high-congestion routes, courier experience gaps, festive season demand spikes, and zone-level inefficiencies. Every insight in this project maps directly to a decision a logistics operations manager would actually need to make.

**🛠️ Tools used:** SQL Server · SQL Server Management Studio (SSMS) · Power BI Desktop

**⚙️ Pipeline:** Synthetic dataset generated in Python → imported into SQL Server → analysed with T-SQL → connected to Power BI via Import Mode → 3-page interactive dashboard

---

## 🏙️ Business Context

Last-mile delivery is the most expensive and operationally complex part of any logistics chain — and in Lagos, it is significantly harder than in most cities. Bridge dependency for Island zones, chronic road congestion on the Mainland, and variable courier reliability all compound into a delivery environment where small inefficiencies translate directly into failed orders, missed SLAs, and customer churn.

This project simulates what a data analyst embedded in a Lagos logistics operation would build: a structured SQL analysis layer and an interactive Power BI report that gives operations managers the visibility to act on problems, not just observe them.

---

## 🗂️ Dataset

The [dataset](Datasets) was synthetically generated in Python to reflect realistic Lagos logistics patterns. It follows a **star schema** with one fact table and four dimension tables.

| Table | Description | Rows |
|---|---|---|
| `fact_deliveries` | Core delivery records — one row per delivery attempt | 8,000 |
| `dim_zone` | 12 Lagos delivery zones with congestion levels | 12 |
| `dim_courier` | 40 courier profiles with experience level and vehicle type | 40 |
| `dim_date` | Full date dimension covering Jan 2024 – Dec 2025 | 731 |
| `dim_failure_reason` | 8 failure reason categories | 8 |

### Data Model Structure

<img width="867" height="683" alt="Data Model Structure" src="https://github.com/user-attachments/assets/c4fee7ce-4fd6-420d-a8fc-272bc273cb3c" />


---

## 🗃️ SQL Analysis

The full T-SQL analysis is structured across 8 sections, all written in SQL Server Management Studio. The analysis moves from schema setup through to advanced window functions.

| # | Section | File |
|---|---|---|
| 1 | Primary keys and foreign key constraints — star schema integrity | [section1_keys.sql](Section1.sql) |
| 2 | Data validation — row counts, null checks, orphan records | [section2_validation.sql](Section2.sql) |
| 3 | Overall delivery performance KPIs | [section3_kpis.sql](Section3.sql) |
| 4 | Zone performance — success rate, SLA breach, failure ranking | [section4_zone_analysis.sql](Section4.sql) |
| 5 | Courier performance — scorecard, experience breakdown, Top/Bottom 10 | [section5_courier_analysis.sql](Section5.sql) |
| 6 | SLA breach analysis — by zone, hour of day, experience level | [section6_sla_analysis.sql](Section6.sql) |
| 7 | Failure reason analysis — root cause, zone-level, experience-level | [section7_failure_analysis.sql](Section7.sql) |
| 8 | Time-series and trend analysis — monthly, YoY, quarterly, rolling averages | [section8_trends.sql](Section8.sql) |

**💡 SQL techniques demonstrated:**
- CTEs (Common Table Expressions)
- Window functions: `RANK()`, `PERCENT_RANK()`, `LAG()`, `STDEV()`, rolling `SUM()` and `AVG()` with `ROWS BETWEEN`
- Conditional aggregation with `CASE WHEN`
- `NULLIF()` for safe division
- Multi-table JOINs across the star schema
- `HAVING` clauses for minimum sample size thresholds

---

## 📊 Power BI Report

The Power BI report connects directly to SQL Server using **Import Mode** — the data is loaded into Power BI's in-memory engine rather than imported from flat files, reflecting a real production pipeline. The report is built on a star schema data model with `dim_date` marked as the Date Table for full time intelligence support.

DAX measures are organised in a dedicated `_Measures` table and cover delivery rates, SLA metrics, time intelligence (YoY comparisons, previous month variance), and contextual breakdowns by zone type, congestion level, and experience level.

### 📋 Page 1 — Executive Summary

A top-level operational overview of LagosLink Express across the full two-year period.

**KPI Cards:** Total Orders · Delivery Success Rate · SLA Breach Rate · Avg Delivery Time · Second Attempt Orders (each with vs Previous Month variance)

**Visuals:**
- 📈 Monthly Trends combo chart — order volume and success rate over time
- 🍩 Orders by Delivery Status donut — Delivered vs Failed split
- 📊 Delivery Success and SLA Breach Rate by Vehicle Type clustered bar chart
- 🎯 Second Attempt Recovery Rate gauge — actual vs 85% benchmark

**Filters:** Year · Month · Day Type · Zone Name

<img width="1131" height="940" alt="1 Executive Summary" src="https://github.com/user-attachments/assets/a29e29d5-de66-4b20-bd47-4b1b20168180" />

---

### 🗺️ Page 2 — Zones Performance

A deep-dive into delivery performance across all 12 Lagos zones.

**✨ Key feature:** A **field parameter switcher** allows the viewer to toggle the main zone bar chart across five metrics — Total Orders, Delivery Success Rate, SLA Breach Rate, Avg Delivery Time, and Avg SLA Deviation — in a single visual. This replaces five separate charts with one dynamic, interactive view.

**Visuals:**
- 📊 Dynamic bar chart by Zone Name (field parameter)
- 📊 Zone Type column chart — Mainland vs Island volume
- 📊 Order Status by Congestion Level — Total Orders, Successful Deliveries, Failed Deliveries across High, Medium, and Low congestion zones

**Filters:** Year · Month · Day Type · Zone Name

<img width="1136" height="942" alt="2 Zones Performance" src="https://github.com/user-attachments/assets/d9617c62-16fc-40e1-8604-229472dd238e" />

---

### 🚴 Page 3 — Couriers Performance

An individual and group analysis of all 40 LagosLink Express couriers.

**✨ Key feature:** A **Couriers Intelligence Table** displays each courier's Average Rating, Average Delivery Time, Total Orders, Delivered, Failed, and SLA Breach Rate — with conditional formatting on delivery time to instantly flag couriers running significantly over their average. This functions as an operational reference sheet for a fleet manager.

**Visuals:**
- 🔵 Scatter chart — Delivery Success Rate vs Avg Delivery Time per courier, coloured by experience level
- 📊 Performance by Experience Level clustered bar chart — Success Rate and SLA Breach Rate for Junior, Mid-level, and Senior couriers
- 🍩 Couriers by Vehicle Type donut chart
- 📋 Couriers Intelligence Table

**Filters:** Year · Month · Day Type · Zone Name

<img width="1136" height="940" alt="3 Couriers Performance" src="https://github.com/user-attachments/assets/0be850b4-486b-4bf2-ac72-f4d0ef681606" />

---

## 🔍 Key Findings

### 📦 Overall Performance
- LagosLink Express completed **88.95%** of 8,000 orders successfully over the two years
- However, **35.86%** of successfully delivered orders breached their SLA target — meaning more than 1 in 3 deliveries that arrived, arrived late
- **811 orders (10.1%)** required a second delivery attempt, with a **70.04% recovery rate** on retry — meaning 243 orders were lost entirely even after a second attempt

### 🗺️ Zone Performance
- **Victoria Island** was the best performing zone — 94.52% success rate and an average delivery time of just 41.4 minutes, well within its 90-minute Island SLA target
- **Ikorodu** was the most operationally challenging zone — average delivery time of **111.5 minutes** against a 75-minute Mainland SLA target, and a **69.22% SLA breach rate** on delivered orders
- **Lagos Island** had the lowest overall success rate at **84.50%**, with a 15.5% failure rate
- Island zones (89.85% success rate, 20.97% SLA breach rate) significantly outperformed Mainland zones (88.29% success rate, 46.95% SLA breach rate) — largely because the 90-minute Island SLA target better reflects actual operating conditions, while the 75-minute Mainland target is frequently unrealistic given Lagos traffic

### 🚴 Courier Performance
- **Senior couriers** achieved a **91.73% success rate** and a **23.13% SLA breach rate**
- **Junior couriers** achieved an **86.36% success rate** and a **43.64% SLA breach rate** — a 5.4 percentage point gap in success rate and a 20.5 percentage point gap in SLA compliance compared to Senior couriers
- The **top performing courier (COU-036)** achieved a **95.61% success rate** across 205 deliveries
- All 5 bottom-performing couriers were Junior-level, with success rates between 84.46% and 85.34%
- **Vans** recorded the highest success rate at **89.11%** and the fastest average delivery time at **70.0 minutes** — counterintuitive given Lagos traffic, but likely reflecting van assignments to shorter, less congested routes

### ❌ Failure Analysis
- The top three failure reasons accounted for **69.8%** of all failed deliveries: Customer Unavailable (27.0%), Traffic Delay (22.7%), and Wrong Address (20.0%)
- Customer and Data Quality issues (Customer Unavailable + Wrong Address) together account for **47.1%** of failures — suggesting that a significant share of LagosLink Express's failure problem is solvable through better address verification at order intake and proactive customer communication before delivery

### 📅 Year-over-Year
- **2024:** 4,055 orders · 89.30% success rate · 36.18% SLA breach rate
- **2025:** 3,945 orders · 88.59% success rate · 35.54% SLA breach rate
- Order volume declined slightly in 2025 while the SLA breach rate marginally improved — suggesting modest operational efficiency gains despite lower volume

---

## 💡 Recommendations

1. 🕐 **Revise the Mainland SLA target for Ikorodu** — at an average delivery time of 111.5 minutes, the current 75-minute target is structurally unachievable. A realistic target reflects actual conditions and gives operations teams a meaningful benchmark to work toward.

2. 👷 **Invest in Junior courier training** — the 20.5 percentage point SLA breach rate gap between Junior and Senior couriers points directly to a training and onboarding gap, not just experience. Structured route familiarisation and time management training could close a meaningful share of that gap.

3. ✅ **Implement address verification at order intake** — Wrong Address failures (20.0% of all failures) are preventable at the source. A lightweight address confirmation step before dispatch could reduce failed deliveries by an estimated 1 in 5.

4. 📱 **Introduce proactive pre-delivery customer communication** — Customer Unavailable is the single largest failure reason at 27.0%. A simple SMS or WhatsApp notification 30–60 minutes before delivery would directly reduce this figure.

5. 🎯 **Deploy Senior couriers to high-congestion zones** — the zone-courier risk analysis shows that Junior couriers operating in High-congestion zones (Ikeja, Surulere, Lagos Island, Ikorodu) represent the worst-performing operational combinations. Reallocating Senior couriers to these zones during peak hours would improve both success rates and SLA compliance where it matters most.

---

## 👤 About

Built by **Abdulsamad Kudehinbu (Bolaji)** — Data & BI Analyst with a background in Civil and Environmental Engineering.
