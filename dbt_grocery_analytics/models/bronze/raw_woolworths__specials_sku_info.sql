{{ config(
    tags = ["bronze"]
) 
}} 

with final as (
    select
        *
    from
        {{ source('WOOLWORTHS', 'SPECIALS_SKU_INFO_TEMP') }} 
    
    {% if is_incremental() %}
    where
        extractiontime > (
            select
                max(extractiontime)
            from
                {{ this }}
        ) 
    {% endif %}
)
select
    *
from
    final