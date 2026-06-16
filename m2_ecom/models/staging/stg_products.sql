WITH source AS (
    SELECT * FROM {{ source('public', 'raw_products') }}
)
SELECT 
    CAST(product_id AS TEXT) AS product_id,
    {{ clean_string('category') }} AS category,
    {{ clean_string('subcategory') }} AS subcategory,
    {{ clean_string('brand') }} AS brand,
    {{ clean_string('season_tag') }} AS season_tag,
    CAST(mrp AS FLOAT) AS mrp,
    CAST(profit_margin_pct AS FLOAT) AS profit_margin_pct,
    {{ clean_string('supplier_name') }} AS supplier_name,
    CAST(stock_level AS INTEGER) AS stock_level
FROM source
WHERE product_id IS NOT NULL