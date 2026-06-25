{{ 
    config(
        materialized='incremental', 
        unique_key='unique_order_key'
    ) 
}}

WITH source_data AS (
    SELECT * FROM {{ ref('int_orders') }}
    WHERE order_date IS NOT NULL
    
    {% if is_incremental() %}
    AND order_date >= coalesce(
        NULLIF('{{ var("backfill_start_date", "") }}', '')::date, 
        (SELECT MAX(order_date) FROM {{ this }})
    )
    {% endif %}
)

SELECT 
    MD5(CAST(order_id AS TEXT) || CAST(customer_id AS TEXT) || CAST(product_id AS TEXT)) AS unique_order_key,
    order_id,
    customer_id,
    product_id,
    campaign_id,
    order_date,
    quantity,
    unit_price,
    discount,
    shipping_cost,
    total_amount,
    order_status,
    payment_method,
    delivery_days,
    returned_flag,
    city,
    state,
    CASE WHEN order_status = 'DELIVERED' THEN 1 ELSE 0 END AS is_delivered_order,
    CASE WHEN order_status = 'RETURNED' THEN 1 ELSE 0 END AS is_returned_order,
    CASE WHEN order_status = 'DELIVERED' THEN total_amount ELSE 0 END AS net_revenue_amount,
    CASE 
        WHEN discount >= 0 AND discount <= 10 THEN '0-10%'
        WHEN discount > 10 AND discount <= 20 THEN '11-20%'
        WHEN discount > 20 AND discount <= 30 THEN '21-30%'
        ELSE '30%+'
    END AS discount_bucket
FROM source_data