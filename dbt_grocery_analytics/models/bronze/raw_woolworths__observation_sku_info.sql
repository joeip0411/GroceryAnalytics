{{ config(
        materialized = 'incremental'
    ) 
}} 

with final as (
    SELECT
        *
    FROM
        {{ source('WOOLWORTHS', 'OBSERVATION_SKU_INFO_TEMP') }}

)

select * from final