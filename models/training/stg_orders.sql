with orders as (
    select * from {{ source('jaffle_shop', 'ORDERS') }}
)

, final as (
    select * from orders
)

select * from final