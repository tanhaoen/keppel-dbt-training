with orders as (
    select * from {{ source('snowflake_sample', 'RAW_ORDERS') }}
)

, final as (
    select 
    id as order_id
    , user_id as customer_id
    , order_date
    , status
    , _etl_loaded_at
     from orders
)

select * from final