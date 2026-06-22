{{ config(materialized='table') }}

SELECT 
    campaign_id,
    campaign_name,
    expected_performance
FROM {{ ref('stg_campaigns') }}