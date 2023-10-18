{{ config(
        materialized = 'incremental',
    ) 
}} 

with final as (
    select
        sku,
        IFNULL(parse_json(brand) ['name'], 'N/A') AS brand_name,
        parse_json(offers) ['price']::decimal(12,4) AS price,
        extractiontime as extraction_time
    from {{ ref('raw_woolworths__observation_sku_info') }}

    {% if is_incremental() %}
    where
        extraction_time > (
            select
                max(extraction_time)
            from
                {{ this }}
        ) 
    {% endif %}
)

select * from final

