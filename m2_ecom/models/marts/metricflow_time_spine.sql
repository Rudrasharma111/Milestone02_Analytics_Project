{{ config(materialized='table') }}

with days as (
    select
        generate_series(
            '2020-01-01'::timestamp,
            '2030-12-31'::timestamp,
            '1 day'::interval
        )::date as date_day
)

select date_day
from days