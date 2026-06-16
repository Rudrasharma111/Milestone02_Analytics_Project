{{ config(materialized='table') }}

/* Yeh query PostgreSQL mein 2020 se lekar 2030 tak ki ek continuous calendar table banayegi.
MetricFlow iska use time-based calculations (MoM, YoY) ke liye karta hai.
*/

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