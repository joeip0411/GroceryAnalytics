{{ config(
    tags = ["silver"]
) 
}} 


with cte as (
    select
        sku,
        name as product_name,
        ifnull(description, 'N/A') as product_description,
        extractiontime as extraction_time
    from
        {{ ref('raw_woolworths__observation_sku_info') }}
    union
    select
        sku,
        name as product_name,
        ifnull(description, 'N/A') as product_description,
        extractiontime as extraction_time
    from
        {{ ref('raw_woolworths__specials_sku_info') }}
),
dedup as (
    select
        sku,
        product_name,
        product_description,
        extraction_time
    from
        cte qualify row_number() over (
            partition by product_name
            order by
                product_name desc
        ) = 1
)
select
    *
from
    dedup