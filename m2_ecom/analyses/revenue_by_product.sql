-- 3. Total Revenue by Product
SELECT 
    product_id,
    SUM(total_amount) AS total_revenue
FROM {{ ref('fct_orders') }}
GROUP BY product_id
ORDER BY total_revenue DESC
