{{ config(
        materialized = 'incremental'
    ) 
}} 

with final as (
    SELECT
        *
    FROM
        {{ source('WOOLWORTHS', 'SPECIALS_SKU_TEMP') }}

)

select * from final