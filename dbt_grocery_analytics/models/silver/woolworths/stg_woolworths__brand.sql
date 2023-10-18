{{ config(
        materialized = 'incremental',
        unique_key = 'BRAND_NAME'
    ) 
}} 

WITH cte AS (
    SELECT
        IFNULL(parse_json(brand) ['name'], 'N/A') AS brand_name,
        extractiontime as extraction_time
    FROM
        {{ ref('raw_woolworths__observation_sku_info') }}

    {% if is_incremental() %}
    WHERE
        extraction_time > (
            SELECT
                max(extraction_time)
            FROM
                {{ this }}
        ) 
    {% endif %}

    UNION

    SELECT
        IFNULL(parse_json(brand) ['name'], 'N/A') AS brand_name,
        extractiontime as extraction_time
    FROM
        {{ ref('raw_woolworths__specials_sku_info') }}

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
    SELECT
        brand_name,
        extraction_time
    FROM
        cte
    QUALIFY row_number() over (partition by brand_name order by brand_name) = 1

)

SELECT
    *
FROM
    dedup