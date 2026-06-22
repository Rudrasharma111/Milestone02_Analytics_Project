WITH source AS (
    SELECT *
    FROM {{ source('public', 'raw_orders') }}
)

SELECT DISTINCT
    MD5(CAST(order_id AS TEXT) || CAST(customer_id AS TEXT) || CAST(product_id AS TEXT)) AS unique_order_key,
    
    CAST(order_id AS TEXT) AS order_id,
    CAST(customer_id AS TEXT) AS customer_id,
    CAST(product_id AS TEXT) AS product_id,
    CAST(campaign_id AS TEXT) AS campaign_id,
    
    CASE
        WHEN order_date LIKE '%-%' THEN TO_DATE(order_date, 'YYYY-MM-DD')
        WHEN order_date LIKE '%/%' THEN TO_DATE(order_date, 'DD/MM/YYYY')
        ELSE NULL
    END AS order_date,
    CAST(quantity AS INTEGER) AS quantity,
    CAST(unit_price AS FLOAT) AS unit_price,
    CAST(discount AS FLOAT) AS discount,
    CAST(shipping_cost AS FLOAT) AS shipping_cost,
    CAST(delivery_days AS INTEGER) AS delivery_days, 
    CAST(returned_flag AS INTEGER) AS returned_flag,
    {{ clean_string('payment_method') }} AS payment_method,
    {{ clean_string('order_status') }} AS order_status,
    {{ clean_string('customer_city') }} AS city,
    {{ clean_string('customer_state') }} AS state

FROM source
WHERE order_id IS NOT NULL