{{ config(materialized='table') }}

WITH date_spine AS (
    SELECT 
        (DATE '2020-01-01' + sequence.day) AS date_day
    FROM GENERATE_SERIES(0, 3650) AS sequence(day)
)
SELECT 
    date_day AS full_date,
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(MONTH FROM date_day) AS month,
    EXTRACT(QUARTER FROM date_day) AS quarter,
    TO_CHAR(date_day, 'Month') AS month_name,
    TO_CHAR(date_day, 'Day') AS day_name
FROM date_spine
WHERE date_day <= '2030-12-31'