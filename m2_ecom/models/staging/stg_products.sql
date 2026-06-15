SELECT 
    product_id,
    {{ clean_string('product_name') }} AS product_name,
    {{ clean_string('category') }} AS category,
    price
FROM {{ source('public', 'raw_products') }}
WHERE product_id IS NOT NULL
  AND price > 0