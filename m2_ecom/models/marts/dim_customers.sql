{{ config(materialized='table') }}
SELECT
    customer_id,
    {{ clean_string('customer_name') }} AS customer_name,
    LOWER(TRIM(email)) AS email,
    {{ clean_string('city') }} AS city,
    CURRENT_TIMESTAMP AS updated_at
FROM {{ ref('stg_customers') }}
WHERE customer_id IS NOT NULL