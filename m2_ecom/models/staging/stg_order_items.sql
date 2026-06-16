WITH source AS (
    SELECT * FROM {{ source('public', 'raw_orders') }}
)
SELECT 
    CAST(order_id AS TEXT) AS order_id,
    CAST(product_id AS TEXT) AS product_id,
    CAST(quantity AS INTEGER) AS quantity,
    CAST(unit_price AS FLOAT) AS unit_price,
    CAST(discount AS FLOAT) AS discount,
    CAST(shipping_cost AS FLOAT) AS shipping_cost
FROM source
WHERE order_id IS NOT NULL 
  AND product_id IS NOT NULL
  AND quantity > 0