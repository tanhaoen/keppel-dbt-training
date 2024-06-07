{% set payment_methods = ["credit_card", "coupon", "bank_transfer", "gift_card"] %}

with orders as (
    select * from {{ ref('stg_orders') }}
)

, payments as (
    select * from {{ ref('stg_payments') }}
)

, order_payment as (
    select 
        orders.*
        , payments.payment_method

    from orders 
    left join payments using(order_id)
)

, final as (
    select 
        customer_id
        , count(1) as cnt_orders
        , {% for payment_method in payment_methods %}
        count_if(payment_method = '{{payment_method}}') as cnt_{{payment_method}},
        {% endfor %}
    from order_payment
    group by 1
)

select * from final