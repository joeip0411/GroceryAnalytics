{{ config(
        materialized = 'table',
        tags=["gold"],
    ) 
}} 

WITH cte AS (
    {{ dbt_date.get_date_dimension("2023-01-01", "2025-12-31") }}
),
final AS (
    SELECT
        md5(date_day) AS date_key,
        *
    FROM
        cte
)
SELECT
    *
FROM
    final