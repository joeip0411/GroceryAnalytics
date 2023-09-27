{{ config(materialized='table') }}

with cte as (
    {{ dbt_date.get_date_dimension("2015-01-01", "2022-12-31") }}
),

final as (
    select
        row_number() over (order by date_day asc) as dim_date_key,
        *
    from cte

)

select * from final

