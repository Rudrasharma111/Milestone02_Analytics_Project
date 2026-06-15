{{ config(materialized='table') }}
SELECT
    product_id,
    {{ clean_string('product_name') }} AS product_name,
    {{ clean_string('category') }} AS category,
    price,
    CURRENT_TIMESTAMP AS updated_at
FROM {{ ref('stg_products') }}
WHERE product_id IS NOT NULL