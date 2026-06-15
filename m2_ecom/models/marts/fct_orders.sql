{{ config(materialized='incremental', unique_key=['order_id', 'product_id']) }}
SELECT 
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    total_amount,
    UPPER(status) AS status  -- Yahan add karna hai
FROM {{ ref('int_orders') }}
WHERE 1=1

{% if var('backfill_start_date', False) and var('backfill_end_date', False) %}
    AND order_date >= '{{ var("backfill_start_date") }}'
    AND order_date <= '{{ var("backfill_end_date") }}'

{% elif is_incremental() %}
    AND order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}