{{ 
    config(
        materialized='incremental', 
        unique_key=['order_id', 'product_id']
    ) 
}}

SELECT 
    order_id,
    customer_id,
    product_id,
    campaign_id, -- Campaign ID yahan fetch ho raha hai
    order_date,
    quantity,
    total_amount,
    order_status
FROM {{ ref('int_orders') }}
WHERE 1=1

{% if is_incremental() %}
    AND order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}