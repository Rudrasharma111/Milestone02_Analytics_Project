{{ config(materialized='table') }}

SELECT 
    product_id,
    category,
    subcategory,
    brand,
    season_tag,
    CAST(mrp AS NUMERIC(10,2)) AS mrp,
    CAST(profit_margin_pct AS NUMERIC(10,2)) AS profit_margin_pct,
    CAST(stock_level AS INT) AS stock_level
FROM {{ ref('stg_products') }}