{% test greater_than_equal_zero(model, column_name) %}

with validation_errors as (
    select
        {{ column_name }} as validation_field
    from {{ model }}
    where validation_field < 0
)

select * from validation_errors

{% endtest %}