WITH source AS (
    SELECT * FROM {{ source('public', 'raw_orders') }}
)
SELECT 
    CAST(order_id AS TEXT) AS order_id,
    CAST(customer_id AS TEXT) AS customer_id,
    CAST(campaign_id AS TEXT) AS campaign_id, -- Yeh missing tha!
    -- Smart Date Parsing Logic
    CASE 
        WHEN order_date LIKE '%-%' THEN TO_DATE(order_date, 'YYYY-MM-DD')
        WHEN order_date LIKE '%/%' THEN TO_DATE(order_date, 'DD/MM/YYYY')
        ELSE NULL 
    END AS order_date,
    {{ clean_string('payment_method') }} AS payment_method,
    {{ clean_string('order_status') }} AS order_status,
    {{ clean_string('customer_city') }} AS city,
    {{ clean_string('customer_state') }} AS state
FROM source
WHERE order_id IS NOT NULL