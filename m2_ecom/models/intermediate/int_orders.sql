{{ config(materialized='view') }}
SELECT 
    orders.order_id,
    orders.customer_id,
    order_items.product_id,
    orders.order_date,
    orders.status,
    order_items.quantity,
    products.price,
    (order_items.quantity * products.price) AS total_amount
FROM {{ ref('stg_orders') }} AS orders
JOIN {{ ref('stg_order_items') }} AS order_items
    ON orders.order_id = order_items.order_id
JOIN {{ ref('stg_products') }} AS products
    ON order_items.product_id = products.product_id