{{ config(
        materialized = 'incremental',
        unique_key = 'SKU'
    ) 
}} 

with cte as (

    select 
        sku,
        name as product_name,
        ifnull(description, 'N/A') as product_description,
        extractiontime as extraction_time
    from {{ ref('raw_woolworths__observation_sku_info') }}
    {% if is_incremental() %}
    WHERE
        extraction_time > (
            SELECT
                max(extraction_time)
            FROM
                {{ this }}
        ) 
    {% endif %}


    union 

    select 
        sku,
        name as product_name,
        ifnull(description, 'N/A') as product_description,
        extractiontime as extraction_time
    from {{ ref('raw_woolworths__specials_sku_info') }}
    {% if is_incremental() %}
    WHERE
        extraction_time > (
            SELECT
                max(extraction_time)
            FROM
                {{ this }}
        ) 
    {% endif %}

),

dedup as (
    select 
        sku,
        product_name,
        product_description,
        extraction_time
    from cte
        qualify row_number() over (partition by product_name order by product_name) = 1

)

select * from dedup
