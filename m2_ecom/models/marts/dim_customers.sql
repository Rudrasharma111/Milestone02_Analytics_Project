{{ config(materialized='table') }}

SELECT 
    customer_id,
    customer_name,
    age_group,
    gender,
    city,
    state,
    membership_type,
    customer_segment,
    annual_income_group,
    signup_date
FROM {{ ref('stg_customers') }}