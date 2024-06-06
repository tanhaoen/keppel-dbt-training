with customers as (
    select * from {{ source('jaffle_shop', 'CUSTOMERS') }}
)

, final as (
    select * from customers 
)

select * from final