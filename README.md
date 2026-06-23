# 📊 E-Commerce Analytics — M2 Reporting & Dashboard Layer

## 🚀 Project Overview

This milestone builds an **analytics-ready reporting layer** on top of the transformed Gold layer from M1, delivering:

* Analytics-ready Gold layer tables (Star Schema) derived from dbt models
* Clearly defined metrics and dimensions with documented grain
* Semantic layer implementation via MetricFlow YAML
* Two Power BI dashboards targeting different business personas
* SQL queries backing each visualization
* Time-based comparisons — MoM, 7D Rolling Avg, Revenue Trend
* Stretch Goals — anomaly detection, forecast, composite metrics

---

# 🎯 Business Objective

Transform Gold layer dimensional models into **insight-ready dashboards** that answer real business questions for two distinct personas:

* **Leadership / Business** → Revenue, growth, customer trends
* **Operations / Analyst** → Fulfillment, campaigns, inventory, returns

---

# 🔄 Data Flow (M1 → M2)

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

# 🏗️ Gold Layer — Star Schema

```
              dim_customers
                   |
dim_campaigns ─── fct_orders ─── dim_products
                   |
               dim_date
```

---

# 📐 fct_orders — Fact Table

**Grain:** 1 row = 1 unique order line
**Unique Key:** MD5(order_id + customer_id + product_id)
**Materialization:** Incremental — only new rows on each dbt run

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
| returned_flag | INT | 1 = returned, 0 = not |
| city | TEXT | Customer city at order time |
| state | TEXT | Customer state at order time |
| is_delivered_order | INT | 1 if Delivered else 0 |
| is_returned_order | INT | 1 if Returned else 0 |
| net_revenue_amount | NUMERIC | total_amount if Delivered else 0 |
| discount_bucket | TEXT | 0-10% / 11-20% / 21-30% / 30%+ |

---

# 🌟 Dimension Tables

### dim_customers

| Column | Type | Description |
|--------|------|-------------|
| customer_id | TEXT | PK |
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
| product_id | TEXT | PK |
| category | TEXT | Product category |
| subcategory | TEXT | Product subcategory |
| brand | TEXT | Brand name |
| season_tag | TEXT | Summer / Winter etc. |
| mrp | NUMERIC | Max retail price |
| profit_margin_pct | NUMERIC | Profit margin % |
| stock_level | INT | Current stock count |

### dim_campaigns

| Column | Type | Description |
|--------|------|-------------|
| campaign_id | TEXT | PK |
| campaign_name | TEXT | Republic Day Sale / Holi & Summer Fest / Monsoon Saver Sale / Back to School / Big Billion Days / Diwali Dhamaka / Wedding Bonanza / Winter Essentials / Christmas Carnival |
| expected_performance | TEXT | High / Medium / Low |

### dim_date

| Column | Type | Description |
|--------|------|-------------|
| full_date | DATE | PK |
| year | INT | Year |
| month | INT | Month number |
| quarter | INT | 1–4 |
| month_name | TEXT | January etc. |
| day_name | TEXT | Monday etc. |

---

# 📊 Target Personas & Dashboard Answers

## 👔 Persona 1 — Business / Leadership
**Page:** Executive | **Who:** CEO, Business Head, Investors

| # | Question | Metric | Answer |
|---|----------|--------|--------|
| 1 | Total revenue is kitna? | Total Revenue | **₹29.16 Cr** (Jan 2025 – May 2026) |
| 2 | Is mahine kitna revenue aaya? | Latest Month Revenue | **₹2.02 Cr** (May 2026) |
| 3 | Kitne unique customers hain? | Active Customers | **4,000 unique customers** |
| 4 | Average order value kya hai? | AOV | **₹13,081** per delivered order |
| 5 | Return rate kaisi hai? | Return Rate % | **7.9%** — healthy (5–10% normal) |
| 6 | Kaunsa state best hai? | Revenue by State | **Delhi #1**, Karnataka #2, Maharashtra #3 |
| 7 | Revenue trend kaisi hai? | 7D Rolling Avg | Peak Oct 2025 ₹3.3 Cr, current ~₹2 Cr/month |
| 8 | Customers wapas aa rahe hain? | Repeat Customer Rate % | **35%** customers ne 2+ orders kiye |

## 🔧 Persona 2 — Analyst / Operations
**Pages:** Operation + Second Operation | **Who:** Ops Manager, Data Analyst, Campaign Manager

| # | Question | Metric | Answer |
|---|----------|--------|--------|
| 1 | Kaun si campaign best rahi? | Campaign Revenue Contribution % | **Diwali Dhamaka** — 1,758 orders Oct mein akele |
| 2 | Profit kitna hua campaign se? | Gross Profit, Profit Margin % | Electronics highest margin driver |
| 3 | Kitne orders cancel hue? | Cancelled Orders, Cancellation Rate % | **728 total**, ~2.9% rate |
| 4 | Inventory theek hai? | Inventory Health %, Low Stock | stock_level thresholds se monitor |
| 5 | Kaunsi category sabse zyada biki? | Total Items Sold by Category | **Electronics #1** — har mahine 60%+ revenue |
| 6 | Discount se orders bade? | Revenue by Discount Bucket | 11–20% bucket mein highest volume |
| 7 | Average delivery time? | Avg delivery_days | Map visual mein state-wise |
| 8 | Fulfilled vs returned? | Delivered vs Returned | **22,295 Delivered** vs **1,977 Returned** |

---

# 📈 Dashboard Walkthrough

## Page 1 — Executive Dashboard

**Top KPI Cards:** Total Revenue · Latest Month Revenue · Total Orders · Active Customers · AOV · Return Rate %

**Line Chart — Revenue Trend:** Monthly revenue with 7D rolling average overlay. Shows seasonal spikes (Oct peak) and monsoon dips clearly.

**Filled Map — Revenue by State:** Darker = higher revenue. Delhi, Karnataka, Maharashtra dominate.

**Bar Chart — Top States:** Ranking of states by revenue for precise comparison.

**Donut — Order Status:** Delivered 89.2% / Returned 7.9% / Cancelled 2.9% — fulfillment health at a glance.

**Stacked Area — Repeat Customer Rate %:** Monthly loyalty trend. Overall 35% customers are repeat buyers.

---

## Page 2 — Operation Dashboard

**KPI Cards:** Delivered · Returned · Cancelled · Avg Daily Orders · Cancellation Rate % · Customer Return Rate % · Inventory Health % · Low Stock Products

**Funnel Chart — Campaign Revenue:** Diwali Dhamaka and Big Billion Days dominate. Monsoon Saver Sale and Wedding Bonanza underperform.

**Table — Campaign Performance:** campaign_name, revenue, contribution %, estimated profit, profit margin %, cancellation rate %, return rate %, avg daily orders — full drill-down.

**Donut — Orders by Membership Type:** Gold vs Silver vs Bronze member contribution.

---

## Page 3 — Second Operation Dashboard

**Column — Revenue by Category:** Electronics 60%+, Cooling Appliances 2nd, Home Appliances 3rd.

**Clustered Column — Returns by Category:** Which categories have high return rates.

**Bar — Revenue by Subcategory:** Top 15 subcategories ranked.

**Clustered Column — Revenue by Discount Bucket:** Does deeper discount = more revenue? 11–20% sweet spot.

**Pie — Payment Method:** UPI vs COD vs Cards breakdown.

**Column — Revenue by Gender & Age Group:** Targeting insights.

---

# 📊 Key Insights — Real Data Se Nikale Facts

## 📋 Overall Dataset Summary (Jan 2025 – May 2026)

| Metric | Value |
|--------|-------|
| Total Order Rows | 25,000 |
| Unique Orders | 24,500 |
| Unique Customers | **4,000** |
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

## 🔢 Month-by-Month Performance

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

## 🚀 Spike: October 2025 — Diwali Effect

**Revenue: ₹3.30 Cr | Orders: 3,183 | Customers: 1,529 | +50.4% vs September**

**Kya hua:** October 2025 dataset ka sabse bada spike — September ke 2,116 se seedha 3,183 orders — **50% jump ek mahine mein.**

**Data se proof:**
- **Diwali Dhamaka campaign** akele **1,758 orders** laya
- **Big Billion Days campaign** ne **1,425 orders** add kiye
- Dono campaigns ek saath October mein chale — double impact
- **Electronics category** ne ₹2.04 Cr diya — 62% share akele
- **Delhi ₹53.6L, Karnataka ₹49.9L, Maharashtra ₹47.2L** — teeno mein ek saath surge
- 1,529 unique customers — sabse zyada kisi bhi mahine mein

> **Business Action:** Diwali + sale campaign combination hamare sabse bade revenue driver hai. Next year October ke liye advance inventory planning aur campaign budget increase zaroori.

---

## 📉 Dip: June–August 2025 — Monsoon Slump

**Jun: ₹1.34 Cr → Jul: ₹1.19 Cr → Aug: ₹1.08 Cr | 3 consecutive months decline**

**Kya hua:** May ke ₹2.21 Cr peak se August mein ₹1.08 Cr — **51% girावट** teen mahine mein. Dataset ka sabse lamba decline period.

**Data se proof:**
- **June:** "Back to School" campaign sirf 606 orders — 592 orders **bina campaign** ke aaye (organic only)
- **July:** "Monsoon Saver Sale" campaign sirf **263 orders** generate ki — very weak
- **August:** Monsoon campaign phir bhi sirf **240 orders** — almost failed
- August mein sirf **646 unique customers** — sabse kam kisi bhi mahine mein
- Cooling Appliances July mein ₹3.3 Cr — baaki sab categories flat
- **Koi bhi major festive event nahi** June–August mein — pure organic demand

> **Business Action:** Monsoon months mein campaign spend review karo — Monsoon Saver Sale ROI poor hai. Category-specific push (home goods, monsoon essentials) try karo. Is period mein heavy inventory investment avoid karo.

---

## 📉 Dip: February — Har Saal Ka Pattern

**Feb 2025: ₹1.01 Cr (792 customers) | Feb 2026: ₹1.04 Cr (804 customers)**

**Kya hua:** January ke baad February consistent dip — **dono saalo mein same pattern.** Dataset ka lowest revenue month February 2025 tha.

**Data se proof:**
- **Feb 2025:** "Wedding Bonanza" campaign — sirf **481 orders**, 630 orders bina campaign ke
- **Feb 2026:** Same campaign — sirf **488 orders**, 622 orders bina campaign ke
- Campaign dono baar lagbhag same result — **consistent underperformer**
- February sirf **28 days** ka mahina — structurally kam orders
- January mein Republic Day Sale ke baad demand saturation — customers already khareed chuke
- Winter Appliances dono February mein second biggest category — season khatam ho raha hota hai

> **Business Action:** February structural weakness hai — dono saalo mein same. Wedding Bonanza ko rethink karo. Valentine's Day themed electronics/gifting campaign try karo. 28-day month factor planning mein include karo.

---

## 📈 September 2025 — Pre-Diwali Buildup

**Revenue: ₹2.70 Cr | Orders: 2,116 | +148% vs August**

August ke lowest point se September mein massive recovery. Customers Diwali ke liye advance shopping shuru kar dete hain — pre-festive demand buildup clearly visible.

---

## 📊 Revenue Pattern Visual

```
Jan 25  ████████████████          ₹1.60 Cr  Republic Day Sale
Feb 25  ██████████                ₹1.01 Cr  ◀ DIP (28 days + weak campaign)
Mar 25  ███████████████           ₹1.53 Cr  Recovery
Apr 25  ████████████████████      ₹2.00 Cr  Growth
May 25  █████████████████████     ₹2.21 Cr  Summer Peak
Jun 25  █████████████             ₹1.34 Cr  ◀ DIP START (Monsoon)
Jul 25  ████████████              ₹1.19 Cr  ◀ Monsoon Low
Aug 25  ██████████                ₹1.08 Cr  ◀ LOWEST POINT
Sep 25  ██████████████████████████ ₹2.70 Cr  Pre-Diwali Surge
Oct 25  █████████████████████████████████  ₹3.30 Cr  ◀ PEAK (Diwali + BBD)
Nov 25  ███████████████           ₹1.55 Cr  Post-Diwali
Dec 25  ███████████████           ₹1.55 Cr  Christmas/Year-end
Jan 26  ███████████████           ₹1.50 Cr  Republic Day
Feb 26  ██████████                ₹1.04 Cr  ◀ DIP (same Feb pattern)
Mar 26  ███████████████           ₹1.53 Cr  Recovery
Apr 26  ████████████████████      ₹2.01 Cr  Growth
May 26  ████████████████████      ₹2.02 Cr  Stable
```

---

# 📏 Dimensions Available for Slicing

| Dimension | Source | Values |
|-----------|--------|--------|
| order_date | fct_orders | Daily / monthly / yearly |
| order_status | fct_orders | Delivered / Returned / Cancelled / Pending |
| payment_method | fct_orders | UPI / COD / Credit Card / Debit Card / Net Banking |
| discount_bucket | fct_orders | 0-10% / 11-20% / 21-30% / 30%+ |
| state | fct_orders | All Indian states |
| age_group | dim_customers | 18-25 / 26-35 / 36-50 / 50+ |
| gender | dim_customers | Male / Female / Other |
| membership_type | dim_customers | Gold / Silver / Bronze |
| category | dim_products | Electronics / Cooling Appliances / Home Appliances / Fashion / Winter Appliances etc. |
| campaign_name | dim_campaigns | 9 campaigns |
| full_date | dim_date | Month / Quarter / Year hierarchy |

---

# 🔢 Pre-Built Measures & DAX

## Revenue

**Total Revenue**
```dax
Total Revenue = SUM('Fact Orders'[net_revenue_amount])
-- net_revenue_amount = total_amount only if Delivered, else 0
-- Kyun: returned/cancelled ka paisa actually earn nahi hua
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
-- Kyun MAXX(ALL): dataset historical — TODAY() nahi chala
-- May 2026: ₹2.02 Cr
```

**Average Order Value**
```dax
Average Order Value = DIVIDE([Total Revenue], [Delivered Order Count], 0)
-- Kyun Delivered denominator: sirf completed orders ka average
-- Result: ₹13,081
```

**Revenue 7D Rolling Avg**
```dax
Revenue_7D_Rolling_Avg =
  CALCULATE(
    AVERAGEX(VALUES('public dim_date'[full_date]), [Total Revenue]),
    DATESINPERIOD('public dim_date'[full_date],
                  LASTDATE('public dim_date'[full_date]), -7, DAY))
-- Kyun rolling: daily spikes smooth karta hai — asli trend dikhti hai
```

**MoM Growth %**
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

## Volume

**Total Orders**
```dax
Total Orders = COUNTROWS('Fact Orders')
-- Kyun COUNTROWS: har row unique_order_key se already unique
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
-- Result: 35% (1,400 out of 4,000 customers)
```

## Operational

**Delivered Order Count**
```dax
Delivered Order Count = SUM('Fact Orders'[is_delivered_order])
-- dbt: CASE WHEN order_status='Delivered' THEN 1 ELSE 0 END
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

## Campaign

**Campaign Revenue**
```dax
Campaign Revenue = CALCULATE([Total Revenue], NOT(ISBLANK('Fact Orders'[campaign_id])))
-- Kyun NOT(ISBLANK): sirf campaign-attributed orders
```

**Gross Profit**
```dax
Gross Profit =
  SUMX(FILTER('Fact Orders', 'Fact Orders'[is_delivered_order] = 1),
       'Fact Orders'[total_amount] * RELATED('public dim_products'[profit_margin_pct]) / 100)
-- RELATED = dim_products se margin row-by-row uthao
```

## Inventory

**Inventory Health %**
```dax
Inventory Health % =
  DIVIDE(CALCULATE(DISTINCTCOUNT('public dim_products'[product_id]),
                   'public dim_products'[stock_level] >= 550),
         DISTINCTCOUNT('public dim_products'[product_id]), 0)
-- Threshold 550 — hamare data ka healthy stock level
```

**Low Stock Products**
```dax
Low Stock Products =
  CALCULATE(DISTINCTCOUNT('public dim_products'[product_id]),
    FILTER('public dim_products', 'public dim_products'[stock_level] < 100))
```

---

# 🧮 Metric Definitions & Assumptions

| Metric | Formula | Assumption |
|--------|---------|------------|
| Total Revenue | SUM(net_revenue_amount) | Sirf Delivered orders — returned/cancelled = 0 |
| AOV | Total Revenue ÷ Delivered Orders | Delivered only — ₹13,081 overall |
| Return Rate % | Returned ÷ Total Orders | 7.9% — healthy |
| Cancellation Rate % | Cancelled ÷ Total Orders | 2.9% — good |
| Repeat Customer Rate % | Customers >1 order ÷ All customers | 35% — 1,400 of 4,000 |
| Gross Profit | Delivered revenue × profit_margin_pct | Margin = snapshot, historical may differ |
| Inventory Health % | Products stock ≥ 550 ÷ Total products | Threshold = 550 |
| Low Stock | Products stock < 100 | Threshold = 100 |
| Campaign Revenue | Revenue where campaign_id IS NOT NULL | Some orders organic — no attribution |
| 7D Rolling Avg | AVERAGEX last 7 days | Smooths weekend/weekday spikes |

---

# ⚠️ Known Data Limitations & Risks

**1. 25,000 rows but 24,500 unique orders**
500 rows mein same order_id repeat hua — possible duplicate entries in source. MD5 key deduplicates in fct_orders.

**2. campaign_id Nullable**
June 2025 mein 592 of 1,198 orders bina campaign ke aaye — 49% organic. Campaign attribution incomplete.

**3. Incremental Load Risk**
fct_orders incremental on order_date. Historical corrections won't load without `dbt run --full-refresh`.

**4. Date Format Mix**
stg_orders handles YYYY-MM-DD and DD/MM/YYYY. Other formats → NULL → filtered out.

**5. Profit Margin Snapshot**
profit_margin_pct from dim_products at ingestion time — not historical. If margins changed, old profit figures inaccurate.

**6. Stock Level Not Real-Time**
dim_products.stock_level = last ingestion snapshot only.

**7. February Structural Weakness**
Both Feb 2025 and Feb 2026 show same dip — 28-day month + Wedding Bonanza underperformance. Expected every year.

---

# 📂 Project Structure

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

# ⚙️ Setup & Run Instructions

```bash
# 1. Start PostgreSQL
docker-compose up -d

# 2. Ingest raw data
python ingestion.py

# 3. Validate dbt
dbt debug

# 4. Run all models
dbt run

# 5. Full refresh (if historical data changed)
dbt run --full-refresh --select fct_orders

# 6. Run tests
dbt test

# 7. Generate docs
dbt docs generate && dbt docs serve
```

Open `BERT_Dashboard.pbix` → Refresh → connect to `127.0.0.1:5434`

---

# 🚀 Tech Stack

| Tool | Purpose |
|------|---------|
| PostgreSQL | Data warehouse |
| Python + Pydantic | Raw ingestion & validation |
| dbt | ELT transformations, testing, docs |
| MetricFlow (semantic_layer.yml) | Semantic layer — single source of truth |
| Power BI | Dashboard & visualization |
| Docker | Local PostgreSQL |

---

# 👨‍💻 Author

**Rudra Sharma**
Data Analyst · Analytics Engineer · AI/ML Enthusiast