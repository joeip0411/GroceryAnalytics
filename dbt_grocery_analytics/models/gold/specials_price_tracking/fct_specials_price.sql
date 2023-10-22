{{ config(
        tags=["specials_price_tracking", "gold"],
        group="specials_price_tracking"
    ) 
}} 

with final as (
    select
        prd.product_key,
        b.brand_key,
        d.extraction_time_date_key,
        p.price,
        p.extraction_time
    from {{ref('stg_woolworths__specials_price')}} p join {{ref('dim_brand')}} b on p.brand_name = b.brand_name
        join {{ref('dim_product')}} prd on prd.sku = p.sku
        join {{ref('dim_extraction_date')}} d on d.extraction_time_date_day = date(p.extraction_time)

    {% if is_incremental() %}
    where p.extraction_time > (select max(extraction_time) from {{ this }})
    {% endif %}


)

select * from final