SELECT 
    customer_id,
    {{ clean_string('name') }} AS customer_name,
    {{ clean_string('email') }} AS email, 
    {{ clean_string('city') }} AS city
FROM {{ source('public', 'raw_customers') }}
WHERE customer_id IS NOT NULL