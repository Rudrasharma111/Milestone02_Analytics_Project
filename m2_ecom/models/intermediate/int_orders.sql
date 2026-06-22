{{ config(materialized='view') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
products AS (
    SELECT * FROM {{ ref('stg_products') }}
),
campaigns AS (
    SELECT * FROM {{ ref('stg_campaigns') }}
)

SELECT 
    orders.unique_order_key,
    
    orders.order_id,
    orders.customer_id,
    orders.product_id,
    orders.campaign_id,
    CAST(orders.order_date AS DATE) AS order_date,
    orders.order_status,
    orders.payment_method,
    orders.delivery_days,
    orders.city,
    orders.state,
    orders.quantity,
    orders.unit_price,
    orders.discount,
    orders.shipping_cost,
    orders.returned_flag,
    CAST((orders.quantity * orders.unit_price) * (1 - (orders.discount / 100.0)) AS NUMERIC(10,2)) AS total_amount

FROM orders
JOIN products ON orders.product_id = products.product_id
LEFT JOIN campaigns ON orders.campaign_id = campaigns.campaign_id
