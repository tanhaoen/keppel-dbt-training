with payments as (
    select * from {{ source('snowflake_sample', 'RAW_PAYMENTS') }}
)

, final as (
    select 
        id as payment_id 
        , order_id
        , amount as amount_cents
        , {{ cents_to_dollars('amount') }} as amount_dollars
        , payment_method  
    
    from payments 
)

select * from final