with customers as (
    select * from {{ source('snowflake_sample', 'RAW_CUSTOMERS') }}
)

, final as (
    select 
    id as customer_id
    , first_name
    , last_name
    from customers 
)

select * from final