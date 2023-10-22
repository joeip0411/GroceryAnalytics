{{ config(
        materialized = 'view',
        tags=["grocery_basket_price_tracking", "specials_price_tracking", "gold"]
    ) 
}} 

with final as (
    select
        DATE_KEY as EXTRACTION_TIME_DATE_KEY,
        DATE_DAY as EXTRACTION_TIME_DATE_DAY,
        PRIOR_DATE_DAY as EXTRACTION_TIME_PRIOR_DATE_DAY,
        NEXT_DATE_DAY as EXTRACTION_TIME_NEXT_DATE_DAY,
        PRIOR_YEAR_DATE_DAY as EXTRACTION_TIME_PRIOR_YEAR_DATE_DAY,
        PRIOR_YEAR_OVER_YEAR_DATE_DAY as EXTRACTION_TIME_PRIOR_YEAR_OVER_YEAR_DATE_DAY,
        DAY_OF_WEEK as EXTRACTION_TIME_DAY_OF_WEEK,
        DAY_OF_WEEK_ISO as EXTRACTION_TIME_DAY_OF_WEEK_ISO,
        DAY_OF_WEEK_NAME as EXTRACTION_TIME_DAY_OF_WEEK_NAME,
        DAY_OF_WEEK_NAME_SHORT as EXTRACTION_TIME_DAY_OF_WEEK_NAME_SHORT,
        DAY_OF_MONTH as EXTRACTION_TIME_DAY_OF_MONTH,
        DAY_OF_YEAR as EXTRACTION_TIME_DAY_OF_YEAR,
        WEEK_START_DATE as EXTRACTION_TIME_WEEK_START_DATE,
        WEEK_END_DATE as EXTRACTION_TIME_WEEK_END_DATE,
        PRIOR_YEAR_WEEK_START_DATE as EXTRACTION_TIME_PRIOR_YEAR_WEEK_START_DATE,
        PRIOR_YEAR_WEEK_END_DATE as EXTRACTION_TIME_PRIOR_YEAR_WEEK_END_DATE,
        WEEK_OF_YEAR as EXTRACTION_TIME_WEEK_OF_YEAR,
        ISO_WEEK_START_DATE as EXTRACTION_TIME_ISO_WEEK_START_DATE,
        ISO_WEEK_END_DATE as EXTRACTION_TIME_ISO_WEEK_END_DATE,
        PRIOR_YEAR_ISO_WEEK_START_DATE as EXTRACTION_TIME_PRIOR_YEAR_ISO_WEEK_START_DATE,
        PRIOR_YEAR_ISO_WEEK_END_DATE as EXTRACTION_TIME_PRIOR_YEAR_ISO_WEEK_END_DATE,
        ISO_WEEK_OF_YEAR as EXTRACTION_TIME_ISO_WEEK_OF_YEAR,
        PRIOR_YEAR_WEEK_OF_YEAR as EXTRACTION_TIME_PRIOR_YEAR_WEEK_OF_YEAR,
        PRIOR_YEAR_ISO_WEEK_OF_YEAR as EXTRACTION_TIME_PRIOR_YEAR_ISO_WEEK_OF_YEAR,
        MONTH_OF_YEAR as EXTRACTION_TIME_MONTH_OF_YEAR,
        MONTH_NAME as EXTRACTION_TIME_MONTH_NAME,
        MONTH_NAME_SHORT as EXTRACTION_TIME_MONTH_NAME_SHORT,
        MONTH_START_DATE as EXTRACTION_TIME_MONTH_START_DATE,
        MONTH_END_DATE as EXTRACTION_TIME_MONTH_END_DATE,
        PRIOR_YEAR_MONTH_START_DATE as EXTRACTION_TIME_PRIOR_YEAR_MONTH_START_DATE,
        PRIOR_YEAR_MONTH_END_DATE as EXTRACTION_TIME_PRIOR_YEAR_MONTH_END_DATE,
        QUARTER_OF_YEAR as EXTRACTION_TIME_QUARTER_OF_YEAR,
        QUARTER_START_DATE as EXTRACTION_TIME_QUARTER_START_DATE,
        QUARTER_END_DATE as EXTRACTION_TIME_QUARTER_END_DATE,
        YEAR_NUMBER as EXTRACTION_TIME_YEAR_NUMBER,
        YEAR_START_DATE as EXTRACTION_TIME_YEAR_START_DATE,
        YEAR_END_DATE as EXTRACTION_TIME_YEAR_END_DATE
    from {{ref('dim_date')}}

)

select * from final