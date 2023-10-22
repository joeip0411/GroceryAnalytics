{{ config(
    tags = ["silver"]
) 
}} 

with cte as (
    select
        ifnull(parse_json(brand) ['name'], 'N/A') as brand_name,
        extractiontime as extraction_time
    from
        {{ ref('raw_woolworths__observation_sku_info') }}
    union
    select
        ifnull(parse_json(brand) ['name'], 'N/A') as brand_name,
        extractiontime as extraction_time
    from
        {{ ref('raw_woolworths__specials_sku_info') }}
),
dedup as (
    select
        brand_name,
        extraction_time
    from
        cte qualify row_number() over (
            partition by brand_name
            order by
                brand_name desc
        ) = 1
)
select
    *
from
    dedup