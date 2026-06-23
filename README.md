# 📊 E-Commerce Analytics — M2 Reporting & Dashboard Layer

## 🚀 Project Overview

This milestone builds an **analytics-ready reporting layer** on top of the transformed Gold layer from M1, delivering:

* Analytics-ready Gold layer tables derived from dbt models
* Clearly defined metrics and dimensions with documented grain
* Semantic layer implementation (MetricFlow YAML)
* Two Power BI dashboards targeting different business personas
* SQL queries backing each visualization
* Time-based comparisons (MoM, WoW, Rolling Avg)

---

# 🎯 Business Objective

Transform Gold layer dimensional models into **insight-ready dashboards** that answer real business questions for two distinct personas:

* **Leadership / Business** → Revenue, growth, customer trends
* **Operations / Analyst** → Fulfillment, campaigns, inventory, returns

---

# 🔄 Data Flow (M1 → M2)

```txt
PostgreSQL Raw Tables (Bronze)
          ↓
dbt Staging Models — stg_orders / stg_customers / stg_products / stg_campaigns
          ↓
dbt Intermediate — int_orders (joins orders + products + campaigns)
          ↓
dbt Mart Models — fct_orders + dim_customers + dim_products + dim_campaigns + dim_date
          ↓
Semantic Layer (semantic_layer.yml — MetricFlow)
          ↓
Power BI Dashboard (BERT_Dashboard.pbix)
```

---

# 🏗️ Gold Layer — Data Model (Star Schema)

```txt
                  dim_customers
                       |
dim_campaigns ──── fct_orders ──── dim_products
                       |
                   dim_date
```

---

# 📐 fct_orders — Fact Table Definition

**Grain:** 1 row = 1 unique order line
**Unique Key:** MD5(order_id + customer_id + product_id)
**Materialization:** Incremental (new rows only on each dbt run)

| Column | Type | Description |
|--------|------|-------------|
| unique_order_key | TEXT | Surrogate PK — MD5 hash |
| order_id | TEXT | Natural order identifier |
| customer_id | TEXT | FK → dim_customers |
| product_id | TEXT | FK → dim_products |
| campaign_id | TEXT | FK → dim_campaigns (nullable) |
| order_date | DATE | Date order was placed |
| order_status | TEXT | DELIVERED / RETURNED / CANCELLED / PENDING |
| payment_method | TEXT | UPI / COD / Credit Card / Debit Card / Net Banking |
| quantity | INT | Units purchased |
| unit_price | FLOAT | Price per unit at time of order |
| discount | FLOAT | Discount percentage applied |
| shipping_cost | FLOAT | Shipping cost charged |
| total_amount | NUMERIC(10,2) | qty × unit_price × (1 − discount/100) |
| delivery_days | INT | Days taken to deliver |
| returned_flag | INT | 1 = returned, 0 = not returned |
| city | TEXT | Customer city at time of order |
| state | TEXT | Customer state at time of order |
| is_delivered_order | INT | 1 if DELIVERED else 0 |
| is_returned_order | INT | 1 if RETURNED else 0 |
| net_revenue_amount | NUMERIC | total_amount if DELIVERED else 0 |
| discount_bucket | TEXT | 0-10% / 11-20% / 21-30% / 30%+ |

---

# 🌟 Dimension Tables

### dim_customers

| Column | Type | Description |
|--------|------|-------------|
| customer_id | TEXT | Primary Key |
| customer_name | TEXT | Full name |
| age_group | TEXT | 18-25 / 26-35 / 36-50 / 50+ |
| gender | TEXT | Male / Female / Other |
| city | TEXT | City of residence |
| state | TEXT | State of residence |
| membership_type | TEXT | Gold / Silver / Bronze |
| customer_segment | TEXT | Premium / Regular / Budget |

### dim_products

| Column | Type | Description |
|--------|------|-------------|
| product_id | TEXT | Primary Key |
| category | TEXT | Top-level product category |
| subcategory | TEXT | Product subcategory |
| brand | TEXT | Brand name |
| season_tag | TEXT | Seasonal tag (Summer / Winter etc.) |
| mrp | NUMERIC | Maximum retail price |
| profit_margin_pct | NUMERIC | Profit margin percentage |
| stock_level | INT | Current stock count |

### dim_campaigns

| Column | Type | Description |
|--------|------|-------------|
| campaign_id | TEXT | Primary Key |
| campaign_name | TEXT | Campaign name |
| expected_performance | TEXT | High / Medium / Low |

### dim_date

| Column | Type | Description |
|--------|------|-------------|
| full_date | DATE | Primary Key |
| year | INT | Year |
| month | INT | Month number |
| quarter | INT | Quarter (1-4) |
| month_name | TEXT | January / February etc. |
| day_name | TEXT | Monday / Tuesday etc. |

---

# 📊 Target Personas & Their Questions

## Persona 1 — Business / Leadership
**Dashboard Page:** Executive
**Who:** CEO, Business Head, Investors

| # | Business Question | Metric |
|---|-------------------|--------|
| 1 | Total revenue this month? | Latest Month Revenue |
| 2 | How many unique customers ordered? | Active Customers |
| 3 | What is our average order value? | Average Order Value |
| 4 | What % of orders were returned? | Return Rate % |
| 5 | Which state has highest revenue? | Total Revenue by State (Map) |
| 6 | How is revenue trending daily? | Revenue 7D Rolling Avg |
| 7 | Are customers repeating purchases? | Repeat Customer Rate % |
| 8 | What is our overall order volume? | Total Orders |

## Persona 2 — Analyst / Operations
**Dashboard Pages:** Operation + Second Operation
**Who:** Operations Manager, Data Analyst, Campaign Manager

| # | Business Question | Metric |
|---|-------------------|--------|
| 1 | Which campaign drove most revenue? | Campaign Revenue Contribution % |
| 2 | What is profit per campaign? | Estimated Profit, Profit Margin % |
| 3 | How many orders cancelled this week? | Cancelled Orders, Cancellation Rate % |
| 4 | Is inventory healthy? | Inventory Health %, Low Stock Products |
| 5 | Which product category sells most? | Total Items Sold by Category |
| 6 | Do bigger discounts drive more orders? | Revenue by Discount Bucket |
| 7 | What is average delivery time? | Avg of delivery_days |
| 8 | How many orders fulfilled vs returned? | Delivered Orders, Returned Orders |

---

# 📏 Metrics & Dimensions — Documented

## Dimensions Available for Slicing

| Dimension | Source | Values |
|-----------|--------|--------|
| order_date | fct_orders | Daily, monthly, yearly |
| order_status | fct_orders | DELIVERED / RETURNED / CANCELLED / PENDING |
| payment_method | fct_orders | UPI / COD / Credit Card / Debit Card / Net Banking |
| discount_bucket | fct_orders | 0-10% / 11-20% / 21-30% / 30%+ |
| state | fct_orders | All Indian states |
| age_group | dim_customers | 18-25 / 26-35 / 36-50 / 50+ |
| gender | dim_customers | Male / Female / Other |
| membership_type | dim_customers | Gold / Silver / Bronze |
| category | dim_products | Product category |
| subcategory | dim_products | Product subcategory |
| campaign_name | dim_campaigns | Campaign identifier |
| full_date (Month/Year) | dim_date | Date hierarchy slicer |

---

# 🔢 Pre-Built Measures — Full Reference

## 💰 Revenue Metrics

**Total Revenue**
```sql
-- dbt (fct_orders): SUM(total_amount)
-- DAX: [Total Revenue] = SUM('Fact Orders'[total_amount])
```

**Latest Month Revenue**
```sql
-- DAX:
[Latest Month Revenue] =
  CALCULATE([Total Revenue], DATESMTD('Fact Orders'[order_date]))
```

**Revenue 7D Rolling Average**
```sql
-- DAX:
[Revenue_7D_Rolling_Avg] =
  CALCULATE(
    [Total Revenue],
    DATESINPERIOD('Fact Orders'[order_date],
                  LASTDATE('Fact Orders'[order_date]), -7, DAY)
  ) / 7
```

**Average Order Value (AOV)**
```sql
-- DAX:
[Average Order Value] = DIVIDE([Total Revenue], [Total Orders])
```

---

## 📦 Volume Metrics

**Total Orders**
```sql
-- dbt: COUNT_DISTINCT(order_id)
-- DAX: [Total Orders] = DISTINCTCOUNT('Fact Orders'[order_id])
```

**Total Items Sold**
```sql
-- dbt: SUM(quantity)
-- DAX: [Total Items Sold] = SUM('Fact Orders'[quantity])
```

**Active Customers**
```sql
-- dbt: COUNT_DISTINCT(customer_id)
-- DAX: [Active Customers] = DISTINCTCOUNT('Fact Orders'[customer_id])
```

---

## 🚚 Operational Metrics

**Delivered Orders**
```sql
-- DAX:
[Delivered Orders] =
  CALCULATE(DISTINCTCOUNT('Fact Orders'[order_id]),
            'Fact Orders'[order_status] = "DELIVERED")
```

**Returned Orders**
```sql
-- DAX:
[Returned Orders] =
  CALCULATE(DISTINCTCOUNT('Fact Orders'[order_id]),
            'Fact Orders'[order_status] = "RETURNED")
```

**Cancelled Orders**
```sql
-- DAX:
[Cancelled Orders] =
  CALCULATE(DISTINCTCOUNT('Fact Orders'[order_id]),
            'Fact Orders'[order_status] = "CANCELLED")
```

**Return Rate %**
```sql
-- DAX:
[Return Rate %] = DIVIDE([Returned Orders], [Total Orders]) * 100
```

**Cancellation Rate %**
```sql
-- DAX:
[Cancellation Rate %] = DIVIDE([Cancelled Orders], [Total Orders]) * 100
```

**Repeat Customer Rate %**
```sql
-- DAX:
[Repeat Customer Rate %] =
  VAR RepeatCustomers =
    CALCULATE(
      DISTINCTCOUNT('Fact Orders'[customer_id]),
      FILTER(
        VALUES('Fact Orders'[customer_id]),
        CALCULATE(DISTINCTCOUNT('Fact Orders'[order_id])) > 1
      )
    )
  RETURN DIVIDE(RepeatCustomers, [Active Customers]) * 100
```

**Inventory Health %**
```sql
-- DAX:
[Inventory Health %] =
  DIVIDE(
    CALCULATE(COUNTROWS('dim_products'), 'dim_products'[stock_level] > 10),
    COUNTROWS('dim_products')
  ) * 100
```

**Low Stock Products**
```sql
-- DAX:
[Low Stock Products] =
  CALCULATE(COUNTROWS('dim_products'), 'dim_products'[stock_level] <= 10)
```

---

## 📣 Campaign Metrics

**Campaign Revenue**
```sql
-- DAX:
[Campaign Revenue] =
  CALCULATE([Total Revenue],
    USERELATIONSHIP('dim_campaigns'[campaign_id], 'Fact Orders'[campaign_id]))
```

**Campaign Revenue Contribution %**
```sql
-- DAX:
[Campaign Revenue Contribution %] =
  DIVIDE([Campaign Revenue],
         CALCULATE([Total Revenue], ALL('dim_campaigns'))) * 100
```

**Estimated Profit**
```sql
-- DAX:
[Estimated Profit] =
  SUMX('Fact Orders',
       'Fact Orders'[total_amount] * RELATED('dim_products'[profit_margin_pct]) / 100)
```

**Profit Margin %**
```sql
-- DAX:
[Profit Margin %] = DIVIDE([Estimated Profit], [Campaign Revenue]) * 100
```

**Avg Daily Orders**
```sql
-- DAX:
[Avg Daily Orders] = DIVIDE([Total Orders], DISTINCTCOUNT('Fact Orders'[order_date]))
```

---

## ⏱️ Time-Based Comparisons (Stretch Goal)

**Previous Month Revenue**
```sql
-- DAX:
[Previous Month Revenue] =
  CALCULATE([Total Revenue], PREVIOUSMONTH('Fact Orders'[order_date]))
```

**MoM Revenue Growth %**
```sql
-- DAX:
[Revenue Growth %] =
  VAR Curr  = [Total Revenue]
  VAR Prior = [Previous Month Revenue]
  RETURN DIVIDE(Curr - Prior, Prior) * 100
```

---

# 🧮 Metric Definitions & Assumptions

| Metric | Formula | Assumption |
|--------|---------|------------|
| Total Revenue | SUM(total_amount) | Includes all statuses |
| Net Revenue | SUM(total_amount) where status = DELIVERED | P&L metric |
| GMV | SUM(total_amount) where status ≠ CANCELLED | Standard e-commerce KPI |
| Return Rate % | Returned ÷ Total Orders × 100 | Denominator includes all statuses |
| Cancellation Rate % | Cancelled ÷ Total Orders × 100 | Denominator includes all statuses |
| Estimated Profit | total_amount × profit_margin_pct ÷ 100 | Margin from dim_products snapshot |
| Inventory Health % | Products with stock > 10 ÷ Total Products × 100 | Threshold = 10 units |
| Repeat Customer Rate % | Customers with >1 order ÷ Active Customers × 100 | Period-dependent |
| Campaign Revenue | Revenue where campaign_id IS NOT NULL | ~% orders have no campaign |
| 7D Rolling Avg | SUM(last 7 days revenue) ÷ 7 | Smooths daily spikes |

---

# ⚠️ Known Data Limitations & Risks

**1. Duplicate Order Risk**
`fct_orders` uses MD5(order_id + customer_id + product_id) as unique key. Same customer re-ordering the same product may collapse into one row.

**2. campaign_id is Nullable**
Not all orders have a campaign. Campaign metrics undercount if attribution is incomplete in source data.

**3. Incremental Load Risk**
`fct_orders` is incremental on `order_date`. Backdated or corrected historical data will not be picked up without `dbt run --full-refresh`.

**4. Date Format Inconsistency**
`stg_orders` handles `YYYY-MM-DD` and `DD/MM/YYYY`. Any other format results in NULL order_date and gets filtered out in `fct_orders`.

**5. Profit Margin is a Snapshot**
`profit_margin_pct` is from dim_products at ingestion time. Historical profit calculations may be inaccurate if margins changed over time.

**6. Stock Level is Not Real-Time**
`dim_products.stock_level` reflects stock at last ingestion — not live inventory.

---

# 📂 Project Structure

```txt
ecommerce_analytics/
│
├── models/
│   ├── staging/
│   │   ├── stg_orders.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_products.sql
│   │   └── stg_campaigns.sql
│   │
│   ├── intermediate/
│   │   └── int_orders.sql
│   │
│   └── marts/
│       ├── fct_orders.sql
│       ├── dim_customers.sql
│       ├── dim_products.sql
│       ├── dim_campaigns.sql
│       ├── dim_date.sql
│       └── metricflow_time_spine.sql
│
├── semantic_layer.yml
├── dbt_project.yml
├── ingestion.py
├── BERT_Dashboard.pbix
└── README.md
```

---

# ⚙️ Setup & Run Instructions

## 1️⃣ Start PostgreSQL

```bash
docker-compose up -d
```

## 2️⃣ Ingest Raw CSV Data

```bash
python ingestion.py
```

## 3️⃣ Validate dbt Setup

```bash
dbt debug
```

## 4️⃣ Run All dbt Models

```bash
dbt run
```

## 5️⃣ Full Refresh (if historical data changed)

```bash
dbt run --full-refresh --select fct_orders
```

## 6️⃣ Run Data Quality Tests

```bash
dbt test
```

## 7️⃣ Generate dbt Docs

```bash
dbt docs generate
dbt docs serve
```

## 8️⃣ Open Dashboard

Open `BERT_Dashboard.pbix` in Power BI Desktop → Refresh data source → point to `127.0.0.1:5434`

---

# 📊 Sample SQL Queries Backing Visualizations

## Total Revenue by State

```sql
SELECT state, SUM(total_amount) AS total_revenue
FROM fct_orders
GROUP BY state
ORDER BY total_revenue DESC;
```

## Return Rate by Product Category

```sql
SELECT p.category,
       COUNT(CASE WHEN f.order_status = 'RETURNED' THEN 1 END) * 100.0
         / COUNT(*) AS return_rate_pct
FROM fct_orders f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY return_rate_pct DESC;
```

## Monthly Revenue Trend

```sql
SELECT DATE_TRUNC('month', order_date) AS month,
       SUM(total_amount) AS monthly_revenue
FROM fct_orders
WHERE order_status != 'CANCELLED'
GROUP BY 1
ORDER BY 1;
```

## Campaign Performance

```sql
SELECT c.campaign_name,
       SUM(f.total_amount) AS campaign_revenue,
       COUNT(DISTINCT f.order_id) AS total_orders,
       SUM(f.total_amount * p.profit_margin_pct / 100) AS estimated_profit
FROM fct_orders f
JOIN dim_campaigns c ON f.campaign_id = c.campaign_id
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY c.campaign_name
ORDER BY campaign_revenue DESC;
```

## Revenue by Discount Bucket

```sql
SELECT discount_bucket,
       COUNT(DISTINCT order_id) AS total_orders,
       SUM(total_amount) AS total_revenue
FROM fct_orders
GROUP BY discount_bucket
ORDER BY total_revenue DESC;
```

---

# 🚀 Tech Stack

| Tool | Purpose |
|------|---------|
| PostgreSQL | Data warehouse |
| Python + Pydantic | Raw data ingestion & validation |
| dbt | ELT transformations, testing, documentation |
| MetricFlow (semantic_layer.yml) | Semantic layer / single source of truth |
| Power BI | Dashboard & visualization |
| Docker | Local PostgreSQL setup |

---

# 👨‍💻 Author

**Rudra Sharma**
Data Analyst | Analytics Engineer | AI/ML Enthusiast