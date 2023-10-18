{{ config(
        materialized = 'incremental',
        unique_key = 'PRODUCT_KEY'
    ) 
}} 

with final as (
    select
        md5(sku) as product_key,
        sku,
        product_name,
        product_description,
        extraction_time
    from {{ref('stg_woolworths__product')}}

    {% if is_incremental() %}
    where extraction_time > (select max(extraction_time) from {{ this }})
    {% endif %}

)

select * from final