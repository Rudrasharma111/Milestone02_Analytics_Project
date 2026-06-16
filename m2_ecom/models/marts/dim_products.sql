{{ config(materialized='table') }}

SELECT 
    product_id,
    category,
    subcategory,
    brand,
    season_tag,
    mrp,
    profit_margin_pct,
    supplier_name,
    stock_level
FROM {{ ref('stg_products') }}