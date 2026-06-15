-- 1. Overall Total Orders & Total Revenue
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM {{ ref('fct_orders') }}
