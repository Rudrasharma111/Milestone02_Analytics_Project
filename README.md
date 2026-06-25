# E-Commerce Analytics — M2 Reporting & Dashboard Layer

## Project Overview

This milestone builds an analytics-ready reporting layer on top of the transformed Gold layer from M1, delivering:

- Analytics-ready Gold layer tables (Star Schema) derived from dbt models
- Clearly defined metrics and dimensions with documented grain
- Semantic layer implementation
- Two Power BI dashboards targeting different business personas
- Time-based comparisons — MoM, 7-Day Rolling Average, Revenue Trend
- Stretch Goals — anomaly detection, forecast, composite metrics

---

## Business Objective

Transform Gold layer dimensional models into insight-ready dashboards that answer real business questions for two distinct personas:

- **Leadership / Business** — Revenue, growth, customer trends
- **Operations / Analyst** — Fulfillment, campaigns, inventory, returns

---

## Data Flow (M1 to M2)

```
PostgreSQL Raw Tables (Bronze)
          ↓
dbt Staging Models — stg_orders / stg_customers / stg_products / stg_campaigns
          ↓
dbt Intermediate — int_orders  (joins orders + products + campaigns, calculates total_amount)
          ↓
dbt Mart Models — fct_orders (incremental) + dim_customers + dim_products + dim_campaigns + dim_date
          ↓
Semantic Layer — semantic_layer.yml (MetricFlow)
          ↓
Power BI Dashboard — BERT_Dashboard.pbix
```

---

## Gold Layer — Star Schema

```
              dim_customers
                   |
dim_campaigns ─── fct_orders ─── dim_products
                   |
               dim_date
```

---

## fct_orders — Fact Table

**Grain:** 1 row = 1 unique order line  
**Unique Key:** MD5(order_id + customer_id + product_id)  
**Materialization:** Incremental — only new rows added on each dbt run

| Column | Type | Description |
|--------|------|-------------|
| unique_order_key | TEXT | Surrogate PK — MD5 hash |
| order_id | TEXT | Natural order ID |
| customer_id | TEXT | FK → dim_customers |
| product_id | TEXT | FK → dim_products |
| campaign_id | TEXT | FK → dim_campaigns (nullable) |
| order_date | DATE | Date order was placed |
| order_status | TEXT | Delivered / Returned / Cancelled / Pending |
| payment_method | TEXT | UPI / COD / Credit Card / Debit Card / Net Banking |
| quantity | INT | Units purchased |
| unit_price | FLOAT | Price per unit |
| discount | FLOAT | Discount % applied |
| shipping_cost | FLOAT | Shipping cost |
| total_amount | NUMERIC(10,2) | qty × unit_price × (1 − discount/100) |
| delivery_days | INT | Days taken to deliver |
| returned_flag | INT | 1 = returned, 0 = not returned |
| city | TEXT | Customer city at order time |
| state | TEXT | Customer state at order time |
| is_delivered_order | INT | 1 if Delivered, else 0 |
| is_returned_order | INT | 1 if Returned, else 0 |
| net_revenue_amount | NUMERIC | total_amount if Delivered, else 0 |
| discount_bucket | TEXT | 0-10% / 11-20% / 21-30% / 30%+ |

---

## Dimension Tables

### dim_customers

| Column | Type | Description |
|--------|------|-------------|
| customer_id | TEXT | Primary key |
| customer_name | TEXT | Full name |
| age_group | TEXT | 18-25 / 26-35 / 36-50 / 50+ |
| gender | TEXT | Male / Female / Other |
| city | TEXT | City |
| state | TEXT | State |
| membership_type | TEXT | Gold / Silver / Bronze |
| customer_segment | TEXT | Premium / Regular / Budget |

### dim_products

| Column | Type | Description |
|--------|------|-------------|
| product_id | TEXT | Primary key |
| category | TEXT | Product category |
| subcategory | TEXT | Product subcategory |
| brand | TEXT | Brand name |
| season_tag | TEXT | Summer / Winter / etc. |
| mrp | NUMERIC | Maximum retail price |
| profit_margin_pct | NUMERIC | Profit margin % |
| stock_level | INT | Current stock count |

### dim_campaigns

| Column | Type | Description |
|--------|------|-------------|
| campaign_id | TEXT | Primary key |
| campaign_name | TEXT | Republic Day Sale / Holi & Summer Fest / Monsoon Saver Sale / Back to School / Big Billion Days / Diwali Dhamaka / Wedding Bonanza / Winter Essentials / Christmas Carnival |
| expected_performance | TEXT | High / Medium / Low |

### dim_date

| Column | Type | Description |
|--------|------|-------------|
| full_date | DATE | Primary key |
| year | INT | Year |
| month | INT | Month number |
| quarter | INT | 1–4 |
| month_name | TEXT | January, February, etc. |
| day_name | TEXT | Monday, Tuesday, etc. |

---

## Target Personas & Dashboard Answers

### Persona 1 — Business / Leadership
**Page:** Executive | **Audience:** CEO, Business Head, Investors

| # | Question | Metric | Answer |
|---|----------|--------|--------|
| 1 | What is total revenue? | Total Revenue | **₹29.16 Cr** (Jan 2025 – May 2026) |
| 2 | What did we earn this month? | Latest Month Revenue | **₹2.02 Cr** (May 2026) |
| 3 | How many customers do we have? | Active Customers | **4,000 unique customers** |
| 4 | What is average order value? | AOV | **₹13,081** per delivered order |
| 5 | How is return rate? | Return Rate % | **7.9%** — healthy (5–10% is normal) |
| 6 | Which state performs best? | Revenue by State | **Delhi #1**, Karnataka #2, Maharashtra #3 |
| 7 | How is the revenue trend? | 7D Rolling Average | Peak Oct 2025 ₹3.3 Cr, current ~₹2 Cr/month |
| 8 | Are customers coming back? | Repeat Customer Rate % | **35%** customers placed 2+ orders |

### Persona 2 — Operations / Analyst
**Pages:** Operation + Second Operation | **Audience:** Ops Manager, Data Analyst, Campaign Manager

| # | Question | Metric | Answer |
|---|----------|--------|--------|
| 1 | Which campaign performed best? | Campaign Revenue Contribution % | **Diwali Dhamaka** — 1,758 orders in October alone |
| 2 | How much profit came from campaigns? | Gross Profit, Profit Margin % | Electronics is the highest margin driver |
| 3 | How many orders were cancelled? | Cancelled Orders, Cancellation Rate % | **728 total**, ~2.9% rate |
| 4 | Is inventory healthy? | Inventory Health %, Low Stock | Monitored via stock_level thresholds |
| 5 | Which category sold the most? | Total Items Sold by Category | **Electronics #1** — 60%+ revenue every month |
| 6 | Did discounts drive more orders? | Revenue by Discount Bucket | 11–20% bucket has the highest volume |
| 7 | What is average delivery time? | Avg delivery_days | Shown state-wise on map visual |
| 8 | Delivered vs returned? | Delivered vs Returned | **22,295 Delivered** vs **1,977 Returned** |

---

## Dashboard Walkthrough

### Page 1 — Executive Dashboard

**Top KPI Cards:** Total Revenue · Latest Month Revenue · Total Orders · Active Customers · AOV · Return Rate %

**Line Chart — Revenue Trend:** Monthly revenue with 7-day rolling average overlay. Shows seasonal spikes (October peak) and monsoon dips clearly.

**Filled Map — Revenue by State:** Darker color = higher revenue. Delhi, Karnataka, Maharashtra dominate.

**Bar Chart — Top States:** State-by-state revenue ranking for precise comparison.

**Donut — Order Status:** Delivered 89.2% / Returned 7.9% / Cancelled 2.9% — fulfillment health at a glance.

**Stacked Area — Repeat Customer Rate %:** Monthly loyalty trend. Overall 35% of customers are repeat buyers.

---

### Page 2 — Operation Dashboard

**KPI Cards:** Delivered · Returned · Cancelled · Avg Daily Orders · Cancellation Rate % · Customer Return Rate % · Inventory Health % · Low Stock Products

**Funnel Chart — Campaign Revenue:** Diwali Dhamaka and Big Billion Days dominate. Monsoon Saver Sale and Wedding Bonanza underperform.

**Table — Campaign Performance:** campaign_name, revenue, contribution %, estimated profit, profit margin %, cancellation rate %, return rate %, avg daily orders — full drill-down.

**Donut — Orders by Membership Type:** Gold vs Silver vs Bronze member contribution.

---

### Page 3 — Second Operation Dashboard

**Column Chart — Revenue by Category:** Electronics 60%+, Cooling Appliances 2nd, Home Appliances 3rd.

**Clustered Column — Returns by Category:** Which categories have the highest return rates.

**Bar — Revenue by Subcategory:** Top 15 subcategories ranked by revenue.

**Clustered Column — Revenue by Discount Bucket:** Does a deeper discount equal more revenue? 11–20% is the sweet spot.

**Pie — Payment Method:** UPI vs COD vs Cards breakdown.

**Column — Revenue by Gender & Age Group:** Targeting and demographic insights.

---

## Key Insights

### Overall Dataset Summary (Jan 2025 – May 2026)

| Metric | Value |
|--------|-------|
| Total Order Rows | 25,000 |
| Unique Orders | 24,500 |
| Total Customers | **4,000** |
| Avg Orders per Customer | **6.25** |
| Repeat Customers (2+ orders) | **1,400 (35%)** |
| Single-order Customers | 2,600 (65%) |
| Total Delivered | 22,295 (89.2%) |
| Total Returned | 1,977 (7.9%) |
| Total Cancelled | 728 (2.9%) |
| Total Delivered Revenue | **₹29.16 Cr** |
| Overall AOV | **₹13,081** |
| Peak Month Revenue | ₹3.30 Cr (Oct 2025) |
| Lowest Month Revenue | ₹1.01 Cr (Feb 2025) |

---

### Month-by-Month Performance

| Month | Revenue | Orders | Customers | Delivered | Returned | Return % |
|-------|---------|--------|-----------|-----------|----------|----------|
| Jan 2025 | ₹1.60 Cr | 1,226 | 853 | 1,100 | 88 | 7.2% |
| Feb 2025 | ₹1.01 Cr | 1,111 | 792 | 993 | 76 | 6.8% |
| Mar 2025 | ₹1.53 Cr | 1,581 | 1,002 | 1,387 | 145 | 9.2% |
| Apr 2025 | ₹2.00 Cr | 1,533 | 990 | 1,383 | 113 | 7.4% |
| May 2025 | ₹2.21 Cr | 1,593 | 1,006 | 1,445 | 104 | 6.5% |
| Jun 2025 | ₹1.34 Cr | 1,198 | 815 | 1,074 | 89 | 7.4% |
| Jul 2025 | ₹1.19 Cr | 859 | 662 | 772 | 61 | 7.1% |
| Aug 2025 | ₹1.08 Cr | 853 | 646 | 759 | 69 | 8.1% |
| Sep 2025 | ₹2.70 Cr | 2,116 | 1,200 | 1,869 | 187 | 8.8% |
| **Oct 2025** | **₹3.30 Cr** | **3,183** | **1,529** | **2,822** | 273 | 8.6% |
| Nov 2025 | ₹1.55 Cr | 1,535 | 988 | 1,373 | 120 | 7.8% |
| Dec 2025 | ₹1.55 Cr | 1,216 | 841 | 1,062 | 111 | 9.1% |
| Jan 2026 | ₹1.50 Cr | 1,215 | 847 | 1,071 | 112 | 9.2% |
| Feb 2026 | ₹1.04 Cr | 1,110 | 804 | 985 | 87 | 7.8% |
| Mar 2026 | ₹1.53 Cr | 1,594 | 1,008 | 1,399 | 148 | 9.3% |
| Apr 2026 | ₹2.01 Cr | 1,534 | 994 | 1,401 | 96 | 6.3% |
| May 2026 | ₹2.02 Cr | 1,543 | 1,001 | 1,400 | 98 | 6.4% |

---

### Spike: October 2025 — The Diwali Effect

**Revenue: ₹3.30 Cr | Orders: 3,183 | Customers: 1,529 | +50.4% vs September**

October 2025 is the biggest month in the dataset. September had 2,116 orders — October jumped to 3,183, a 50% increase in a single month.

**Evidence from the data:**
- Diwali Dhamaka campaign alone generated **1,758 orders**
- Big Billion Days campaign added another **1,425 orders**
- Both campaigns ran simultaneously in October — creating a combined impact
- Electronics category contributed ₹2.04 Cr — 62% of that month's revenue on its own
- Delhi ₹53.6L, Karnataka ₹49.9L, Maharashtra ₹47.2L — all three states surged at the same time
- 1,529 unique customers — the highest of any month in the dataset

> **Business Action:** The Diwali + sale campaign combination is our single biggest revenue driver. For next year, advance inventory planning and an increased campaign budget for October are essential.

---

### Dip: June–August 2025 — The Monsoon Slump

**Jun: ₹1.34 Cr → Jul: ₹1.19 Cr → Aug: ₹1.08 Cr — 3 consecutive months of decline**

From May's peak of ₹2.21 Cr to August's low of ₹1.08 Cr — a **51% drop** across three months. This is the longest and steepest decline in the dataset.

**Evidence from the data:**
- June: "Back to School" campaign generated only 606 orders — 592 orders came in with no campaign (49% organic)
- July: "Monsoon Saver Sale" produced only **263 orders** — very weak performance
- August: The same Monsoon campaign generated only **240 orders** — effectively failed
- August had only **646 unique customers** — the lowest of any month in the dataset
- No major festive event in this window — demand was entirely organic

> **Business Action:** Review campaign spending for monsoon months. The Monsoon Saver Sale ROI is poor and should be reconsidered entirely. Try a category-specific push — home goods, monsoon apparel, appliances. Avoid heavy inventory build-up during this window.

---

### Dip: February — A Pattern That Repeats Every Year

**Feb 2025: ₹1.01 Cr (792 customers) | Feb 2026: ₹1.04 Cr (804 customers)**

After January, February shows a consistent dip — the same pattern in both years. February 2025 was the lowest revenue month in the entire dataset.

**Evidence from the data:**
- Feb 2025: "Wedding Bonanza" campaign — only **481 orders**, with 630 orders coming in organically
- Feb 2026: Same campaign — only **488 orders**, with 622 coming in organically
- The campaign produced nearly identical, underwhelming results both times — a **consistent underperformer**
- February is a **28-day month** — structurally fewer orders regardless of campaign activity
- January's Republic Day Sale creates demand saturation — customers have already purchased
- Winter Appliances is the second-biggest category in both Februaries — the winter season is winding down

> **Business Action:** February is structurally weak and will repeat every year. Wedding Bonanza needs to be rethought. Consider a Valentine's Day themed electronics or gifting campaign instead. Build the 28-day factor into all February forecasts.

---

### September 2025 — Pre-Festive Buildup

**Revenue: ₹2.70 Cr | Orders: 2,116 | +148% vs August**

A massive recovery from August's low point. Customers begin advance shopping ahead of Diwali — the pre-festive demand buildup is clearly visible in the data.

---

### Revenue Pattern (Jan 2025 – May 2026)

```
Jan 25  ████████████████          ₹1.60 Cr  Republic Day Sale
Feb 25  ██████████                ₹1.01 Cr  ◀ DIP (28 days + weak campaign)
Mar 25  ███████████████           ₹1.53 Cr  Recovery
Apr 25  ████████████████████      ₹2.00 Cr  Growth
May 25  █████████████████████     ₹2.21 Cr  Summer Peak
Jun 25  █████████████             ₹1.34 Cr  ◀ DIP START (Monsoon)
Jul 25  ████████████              ₹1.19 Cr  ◀ Monsoon Low
Aug 25  ██████████                ₹1.08 Cr  ◀ LOWEST POINT
Sep 25  ██████████████████████████ ₹2.70 Cr  Pre-Festive Surge
Oct 25  █████████████████████████████████  ₹3.30 Cr  ◀ PEAK (Diwali + BBD)
Nov 25  ███████████████           ₹1.55 Cr  Post-Diwali
Dec 25  ███████████████           ₹1.55 Cr  Christmas / Year-end
Jan 26  ███████████████           ₹1.50 Cr  Republic Day
Feb 26  ██████████                ₹1.04 Cr  ◀ DIP (same February pattern)
Mar 26  ███████████████           ₹1.53 Cr  Recovery
Apr 26  ████████████████████      ₹2.01 Cr  Growth
May 26  ████████████████████      ₹2.02 Cr  Stable
```

---

## Dimensions Available for Filtering

| Dimension | Source | Values |
|-----------|--------|--------|
| order_date | fct_orders | Daily / Monthly / Yearly |
| order_status | fct_orders | Delivered / Returned / Cancelled / Pending |
| payment_method | fct_orders | UPI / COD / Credit Card / Debit Card / Net Banking |
| discount_bucket | fct_orders | 0-10% / 11-20% / 21-30% / 30%+ |
| state | fct_orders | All Indian states |
| age_group | dim_customers | 18-25 / 26-35 / 36-50 / 50+ |
| gender | dim_customers | Male / Female / Other |
| membership_type | dim_customers | Gold / Silver / Bronze |
| category | dim_products | Electronics / Cooling Appliances / Home Appliances / Fashion / Winter Appliances / etc. |
| campaign_name | dim_campaigns | 9 campaigns |
| full_date | dim_date | Month / Quarter / Year hierarchy |

---

## Measures & DAX

### Revenue

**Total Revenue**
```dax
Total Revenue = SUM('Fact Orders'[net_revenue_amount])
-- net_revenue_amount = total_amount only if Delivered, else 0
-- Returned and cancelled orders do not count — that money was not earned
-- Result: ₹29.16 Cr
```

**Latest Month Revenue**
```dax
Latest Month Revenue =
  VAR LatestDate = MAXX(ALL('Fact Orders'), 'Fact Orders'[order_date])
  RETURN CALCULATE([Total Revenue],
    FILTER(ALL('Fact Orders'[order_date]),
      YEAR('Fact Orders'[order_date]) = YEAR(LatestDate)
      && MONTH('Fact Orders'[order_date]) = MONTH(LatestDate)))
-- MAXX(ALL) is used because the dataset is historical — TODAY() does not work here
-- Result for May 2026: ₹2.02 Cr
```

**Average Order Value**
```dax
Average Order Value = DIVIDE([Total Revenue], [Delivered Order Count], 0)
-- Delivered count is used as the denominator — only completed orders count
-- Result: ₹13,081
```

**Revenue 7-Day Rolling Average**
```dax
Revenue_7D_Rolling_Avg =
  CALCULATE(
    AVERAGEX(VALUES('public dim_date'[full_date]), [Total Revenue]),
    DATESINPERIOD('public dim_date'[full_date],
                  LASTDATE('public dim_date'[full_date]), -7, DAY))
-- Rolling average smooths out daily spikes — the real trend becomes visible
```

**Month-over-Month Growth %**
```dax
Previous Month Revenue =
  VAR LatestDate = MAXX(ALL('Fact Orders'), 'Fact Orders'[order_date])
  VAR PrevDate   = EOMONTH(LatestDate, -1)
  RETURN CALCULATE([Total Revenue],
    FILTER(ALL('Fact Orders'[order_date]),
      YEAR(order_date) = YEAR(PrevDate)
      && MONTH(order_date) = MONTH(PrevDate)))

Revenue Growth % = DIVIDE([Latest Month Revenue] - [Previous Month Revenue],
                           [Previous Month Revenue])

Revenue Trend = IF([Revenue Growth %] >= 0,
                   "▲ " & FORMAT([Revenue Growth %],"0.0%"),
                   "▼ " & FORMAT(ABS([Revenue Growth %]),"0.0%"))
                & " vs Prev Month"
```

### Volume

**Total Orders**
```dax
Total Orders = COUNTROWS('Fact Orders')
-- Each row is already unique via unique_order_key — COUNTROWS is correct here
-- Result: 25,000 rows
```

**Active Customers**
```dax
Active Customers = DISTINCTCOUNT('Fact Orders'[customer_id])
-- Result: 4,000 unique customers
```

**Repeat Customer Rate %**
```dax
Repeat Customer Rate % =
  VAR TotalCustomers  = DISTINCTCOUNT('Fact Orders'[customer_id])
  VAR RepeatCustomers = COUNTROWS(FILTER(VALUES('Fact Orders'[customer_id]),
                          CALCULATE(DISTINCTCOUNT('Fact Orders'[order_id])) > 1))
  RETURN DIVIDE(RepeatCustomers, TotalCustomers, 0)
-- Result: 35% (1,400 out of 4,000 customers placed more than one order)
```

### Operational

**Delivered Order Count**
```dax
Delivered Order Count = SUM('Fact Orders'[is_delivered_order])
-- is_delivered_order = 1 if status = Delivered, else 0 (set in dbt)
-- Result: 22,295
```

**Return Rate %**
```dax
Return Rate % = DIVIDE([Total Returned Orders], [Total Orders], 0)
-- Total Returned Orders = SUM('Fact Orders'[is_returned_order])
-- Result: 7.9%
```

**Cancellation Rate %**
```dax
Cancellation Rate % = DIVIDE([Cancelled Orders], [Total Orders], 0)
-- Cancelled Orders = CALCULATE([Total Orders], order_status = "Cancelled")
-- Result: 2.9%
```

### Campaign

**Campaign Revenue**
```dax
Campaign Revenue = CALCULATE([Total Revenue], NOT(ISBLANK('Fact Orders'[campaign_id])))
-- Only includes orders that are attributed to a campaign
```

**Gross Profit**
```dax
Gross Profit =
  SUMX(FILTER('Fact Orders', 'Fact Orders'[is_delivered_order] = 1),
       'Fact Orders'[total_amount] * RELATED('public dim_products'[profit_margin_pct]) / 100)
-- RELATED pulls the margin from dim_products row by row
```

### Inventory

**Inventory Health %**
```dax
Inventory Health % =
  DIVIDE(CALCULATE(DISTINCTCOUNT('public dim_products'[product_id]),
                   'public dim_products'[stock_level] >= 550),
         DISTINCTCOUNT('public dim_products'[product_id]), 0)
-- Threshold of 550 is the healthy stock level for this dataset
```

**Low Stock Products**
```dax
Low Stock Products =
  CALCULATE(DISTINCTCOUNT('public dim_products'[product_id]),
    FILTER('public dim_products', 'public dim_products'[stock_level] < 100))
```

---

## Metric Definitions & Assumptions

| Metric | Formula | Assumption |
|--------|---------|------------|
| Total Revenue | SUM(net_revenue_amount) | Delivered orders only — returned/cancelled = 0 |
| AOV | Total Revenue ÷ Delivered Orders | Delivered only — ₹13,081 overall |
| Return Rate % | Returned ÷ Total Orders | 7.9% — healthy range |
| Cancellation Rate % | Cancelled ÷ Total Orders | 2.9% — within acceptable range |
| Repeat Customer Rate % | Customers with >1 order ÷ All customers | 35% — 1,400 of 4,000 |
| Gross Profit | Delivered revenue × profit_margin_pct | Margin is a snapshot — historical values may differ |
| Inventory Health % | Products with stock ≥ 550 ÷ Total products | Threshold = 550 |
| Low Stock | Products with stock < 100 | Threshold = 100 |
| Campaign Revenue | Revenue where campaign_id IS NOT NULL | Some orders are organic — attribution is incomplete |
| 7D Rolling Average | AVERAGEX over last 7 days | Smooths weekend / weekday spikes |

---

## Known Data Limitations & Risks

**1. 25,000 rows but only 24,500 unique orders**  
500 rows contain a repeated order_id — likely duplicate entries in the source CSV. The MD5 key in fct_orders deduplicates these automatically.

**2. campaign_id is nullable**  
In June 2025, 592 out of 1,198 orders had no campaign — 49% organic. Campaign attribution is incomplete and some nulls may represent missing data rather than truly organic traffic.

**3. Incremental load risk**  
fct_orders is incremental on order_date. If an old order's status changes (e.g. Pending → Delivered), it will not update unless `dbt run --full-refresh` is run manually.

**4. Mixed date formats in source**  
stg_orders handles both YYYY-MM-DD and DD/MM/YYYY. Any other format results in a NULL date, and those orders are excluded from all time-based analysis.

**5. Profit margin is a point-in-time snapshot**  
profit_margin_pct is captured from dim_products at ingestion time — not tracked historically. If margins changed during the dataset period, historical profit calculations may be inaccurate.

**6. Stock level is not real-time**  
dim_products.stock_level reflects the last ingestion snapshot only. It is not suitable for live inventory management decisions.

**7. February is structurally weak every year**  
Both Feb 2025 and Feb 2026 show the same dip — driven by the 28-day month, post-January demand saturation, and the consistently underperforming Wedding Bonanza campaign. This pattern should be expected and planned for annually.

---

## Project Structure

```
ecommerce_analytics/
├── models/
│   ├── staging/
│   │   ├── stg_orders.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_products.sql
│   │   └── stg_campaigns.sql
│   ├── intermediate/
│   │   └── int_orders.sql
│   └── marts/
│       ├── fct_orders.sql
│       ├── dim_customers.sql
│       ├── dim_products.sql
│       ├── dim_campaigns.sql
│       ├── dim_date.sql
│       └── metricflow_time_spine.sql
├── analyses/
│   └── dashboard_queries.sql
├── semantic_layer.yml
├── dbt_project.yml
├── ingestion.py
├── BERT_Dashboard.pbix
└── README.md
```

---

## Setup & Run Instructions

```bash
# 1. Start PostgreSQL
docker-compose up -d

# 2. Ingest raw data
python ingestion.py

# 3. Validate dbt connection
dbt debug

# 4. Run all models
dbt run

# 5. Full refresh (if historical data has changed)
dbt run --full-refresh --select fct_orders

# 6. Run data quality tests
dbt test

# 7. Generate and serve documentation
dbt docs generate && dbt docs serve
```

Open `BERT_Dashboard.pbix` → click Refresh → connect to `127.0.0.1:5434`

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| PostgreSQL | Data warehouse |
| Python + Pydantic | Raw data ingestion and row-level validation |
| dbt | ELT transformations, testing, incremental models, documentation |
| MetricFlow (semantic_layer.yml) | Semantic layer — single source of truth for all metric definitions |
| Power BI | Dashboard and visualization |
| Docker | Local PostgreSQL environment |

---

## Author

**Rudra Sharma**  