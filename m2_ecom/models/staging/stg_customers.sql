WITH source AS (
    SELECT * FROM {{ source('public', 'raw_customers') }}
)
SELECT 
    CAST(customer_id AS TEXT) AS customer_id,
    {{ clean_string('customer_name') }} AS customer_name,
    {{ clean_string('age_group') }} AS age_group,
    {{ clean_string('gender') }} AS gender,
    {{ clean_string('city') }} AS city,
    {{ clean_string('state') }} AS state,
    {{ clean_string('membership_type') }} AS membership_type,
    {{ clean_string('customer_segment') }} AS customer_segment,
    {{ clean_string('annual_income_group') }} AS annual_income_group,
    CAST(signup_date AS DATE) AS signup_date
FROM source
WHERE customer_id IS NOT NULL