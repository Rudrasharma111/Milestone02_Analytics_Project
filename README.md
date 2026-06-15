# 📊 E-commerce Analytics Data Pipeline (dbt + PostgreSQL)

## 🚀 Project Overview

This project builds an end-to-end analytical data pipeline for e-commerce data by:

* Ingesting raw OLTP-style transactional data into PostgreSQL
* Transforming data using dbt (ELT approach)
* Applying Medallion Architecture (Bronze → Silver → Gold)
* Building analytics-ready dimensional models (Star Schema)
* Enabling reporting, business intelligence, and analytical SQL use cases

---

# 🎯 Business Objective

The goal of this project is to transform raw transactional e-commerce data into structured, high-quality analytical datasets that support:

* Revenue analysis
* Customer spend analysis
* Product performance tracking
* Reporting and dashboarding

---

# 🔄 Data Lifecycle (Raw → Transformed → Analytics)

```txt
CSV Files / Mock Source Data
          ↓
PostgreSQL Raw Tables (Bronze Layer)
          ↓
dbt Source Definitions
          ↓
Staging Models (Silver Layer)
          ↓
Intermediate Transformations (Silver Layer)
          ↓
Mart Models - Fact & Dimensions (Gold Layer)
          ↓
Analytics Queries / BI Tools
```

---

## 📌 Lifecycle Explanation

### Bronze Layer:

Raw source data is ingested into PostgreSQL with minimal or no transformation.

### Silver Layer:

dbt staging and intermediate models clean, standardize, validate, and transform raw data into structured datasets.

### Gold Layer:

Final dimensional models (fact + dimension tables) are created for analytics and reporting.

---

# 🏗️ Architecture Style

## ELT (Extract, Load, Transform)

**Why ELT?**

* Raw data is first loaded into PostgreSQL
* Transformations happen inside the warehouse using dbt
* Better scalability and maintainability

---

# 📐 Data Modeling Approach

## Source Layer:

Uses **3NF-style normalized OLTP tables** for transactional integrity.

### Example:

* raw_orders
* raw_customers
* raw_products
* raw_order_items

---

## Analytics Layer:

Uses **Star Schema** for OLAP analytics.

### Fact Table:

* `fct_orders` → transactional sales metrics

### Dimension Tables:

* `dim_customers`
* `dim_products`

---

# 🌟 Data Model Diagram (Star Schema)

```txt
                    dim_customers
                          |
                          |
dim_products -------- fct_orders -------- dim_dates (optional)
                          |
                          |
                 Measures:
                 - quantity
                 - price
                 - total_amount
```

---

# ⭐ Star Schema vs 3NF

| Feature       | Star Schema             | 3NF                 |
| ------------- | ----------------------- | ------------------- |
| Purpose       | Analytics / OLAP        | Transactions / OLTP |
| Query Speed   | Faster for aggregations | Slower due to joins |
| Design        | Denormalized            | Normalized          |
| Complexity    | Simple for BI           | Complex             |
| Best Use Case | Reporting / Dashboards  | Operational systems |

---

## 📌 Why Star Schema for Gold Layer?

* Faster analytical queries
* Easy joins for BI tools
* Simplified business understanding
* Better dashboard performance

---

# 🥇 Medallion Architecture Implementation

| Layer  | Folder / Schema                           | Description                               |
| ------ | ----------------------------------------- | ----------------------------------------- |
| Bronze | Raw PostgreSQL Tables / Sources           | Raw ingested transactional data           |
| Silver | `models/staging/`, `models/intermediate/` | Cleaned, standardized, transformed data   |
| Gold   | `models/marts/`                           | Analytics-ready fact and dimension tables |

---

# 📂 Project Structure

```txt
ecommerce_analytics/
│
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
│
├── macros/
│
├── tests/
│
├── seeds/
│
├── dbt_project.yml
│
├── docker-compose.yml
│
└── README.md
```

---

# 🔗 dbt Source Definitions

Source definitions are used to map raw PostgreSQL tables into dbt.

### Example Sources:

* raw_customers
* raw_orders
* raw_products
* raw_order_items

This ensures:

* Data lineage
* Freshness monitoring
* Dependency management

---

# ✅ dbt Tests Implemented

## Column-Level Tests:

* `not_null` → Ensures no missing critical values
* `unique` → Ensures primary key uniqueness
* `relationships` → Ensures foreign key integrity

---

## Example:

### `orders.order_id`

* unique
* not_null

### `customer_id`

* relationship with customers table

---

# ⚙️ Setup & Run Instructions

## 1️⃣ Start PostgreSQL Database

```bash
docker-compose up -d
```

---

## 2️⃣ Load Raw Data

```bash
python ingest_data.py
```

---

## 3️⃣ Validate dbt Setup

```bash
dbt debug
```

---

## 4️⃣ Run dbt Models

```bash
dbt run
```

---

## 5️⃣ Run Data Quality Tests

```bash
dbt test
```

---

## 6️⃣ Check Source Freshness

```bash
dbt source freshness
```

---

## 7️⃣ Backfill Historical Data (Optional)

```bash
dbt run --full-refresh
```

---

## 8️⃣ Generate dbt Documentation

```bash
dbt docs generate
dbt docs serve
```

---

# 📊 Sample Analytical SQL Queries

## Total Revenue by Product

```sql
SELECT 
    product_id,
    SUM(total_amount) AS total_revenue
FROM fct_orders
GROUP BY product_id
ORDER BY total_revenue DESC;
```

---

## Customer Lifetime Spend

```sql
SELECT 
    customer_id,
    SUM(total_amount) AS total_spent
FROM fct_orders
GROUP BY customer_id
ORDER BY total_spent DESC;
```

---

## Order Volume by Status

```sql
SELECT 
    status,
    COUNT(order_id) AS total_orders
FROM fct_orders
GROUP BY status;
```

---

# ⚡ Advanced Enhancements / Stretch Goals

## Implemented or Extendable:

* Incremental dbt models (`materialized='incremental'`)
* Historical backfill strategy (`--full-refresh`)
* Source freshness checks
* dbt macros for reusable SQL logic
* Organized model ownership by layers
* Scalable package structure

---

# 🔍 Key Design Decisions

## Why PostgreSQL?

* Reliable local warehouse
* Easy dbt integration
* SQL-friendly

---

## Why dbt?

* Modular SQL transformations
* Testing + documentation
* Version control
* ELT workflow

---

## Why Medallion?

* Layered maintainability
* Better debugging
* Clear data maturity stages

---

# 🎯 Final Outcome

This project demonstrates:

## Data Engineering:

* Raw ingestion
* ELT pipeline
* Layered architecture

## Analytics Engineering:

* dbt transformations
* Testing
* Documentation
* Dimensional modeling

---

# 🏁 Final Summary

This project converts raw OLTP-style e-commerce data into OLAP-ready analytical models using PostgreSQL + dbt. By combining Medallion Architecture, ELT principles, and Star Schema dimensional modeling, it creates scalable, maintainable, and analytics-optimized datasets for real-world business intelligence use cases.

---

# 🚀 Tech Stack

* PostgreSQL
* dbt
* SQL
* Docker
* Python (for ingestion)

---

# 👨‍💻 Author

**Rudra Sharma**
Data Analyst | Analytics Engineer | AI/ML Enthusiast
