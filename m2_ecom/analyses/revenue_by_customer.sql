-- 2. Total Orders by Customer
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders
FROM {{ ref('fct_orders') }}
GROUP BY customer_id
ORDER BY total_orders DESC