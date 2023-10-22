{{ config(
        unique_key = 'PRODUCT_KEY',
        tags=["grocery_basket_price_tracking","specials_price_tracking", "gold"]
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