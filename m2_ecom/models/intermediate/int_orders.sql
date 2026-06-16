{{ config(materialized='view') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),
products AS (
    SELECT * FROM {{ ref('stg_products') }}
),
campaigns AS (
    SELECT * FROM {{ ref('stg_campaigns') }}
)

SELECT 
    orders.order_id,
    orders.customer_id,
    order_items.product_id,
    campaigns.campaign_id, -- Campaign ID add kiya gaya hai
    orders.order_date,
    orders.order_status,
    order_items.quantity,
    order_items.unit_price,
    order_items.discount,
    -- Rounding and Casting to NUMERIC for clean business metrics
    ROUND(CAST((order_items.quantity * order_items.unit_price) - order_items.discount AS NUMERIC), 2) AS total_amount
FROM orders
JOIN order_items ON orders.order_id = order_items.order_id
JOIN products ON order_items.product_id = products.product_id
LEFT JOIN campaigns ON orders.campaign_id = campaigns.campaign_id