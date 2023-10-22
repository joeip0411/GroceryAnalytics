{{ config(
        unique_key = 'BRAND_KEY',
        tags=["grocery_basket_price_tracking", "specials_price_tracking", "gold"],
    ) 
}} 

with final as (
    select
        md5(brand_name) as brand_key,
        brand_name,
        extraction_time
    from {{ref('stg_woolworths__brand')}}

    {% if is_incremental() %}
    where extraction_time > (select max(extraction_time) from {{ this }})
    {% endif %}

)

select * from final