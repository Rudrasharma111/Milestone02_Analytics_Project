SELECT 
    order_id,
    customer_id,
    CAST(order_date AS DATE) AS order_date,
    {{ clean_string('status') }} AS status
FROM {{ source('public', 'raw_orders') }}
WHERE order_id IS NOT NULL 
  AND customer_id IS NOT NULL