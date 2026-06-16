WITH source AS (
    SELECT * FROM {{ source('public', 'raw_campaigns') }}
)
SELECT 
    CAST(campaign_id AS TEXT) AS campaign_id,
    {{ clean_string('campaign_name') }} AS campaign_name,
    {{ clean_string('expected_performance') }} AS expected_performance
FROM source
WHERE campaign_id IS NOT NULL