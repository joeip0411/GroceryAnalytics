{{ config(
    tags = ["silver"]
) 
}} 


with final as (
    select
        sku,
        ifnull(parse_json(brand) ['name'], 'N/A') as brand_name,
        parse_json(offers) ['price']::decimal(12, 4) as price,
        extractiontime as extraction_time
    from
        {{ ref('raw_woolworths__specials_sku_info') }} 
)
select
    *
from
    final