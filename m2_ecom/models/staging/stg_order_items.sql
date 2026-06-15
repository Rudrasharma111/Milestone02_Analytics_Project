SELECT order_id,product_id,quantity
FROM {{ source('public', 'raw_order_items') }}
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL
  AND quantity > 0