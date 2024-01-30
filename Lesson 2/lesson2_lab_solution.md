# Lesson 2 (Solution) - Project Structure, Jinja and Macros 

## Create a staging model
The `stg_payments` model should go into your `staging` directory.

## Jinja - SQL solution (FCT_CUSTOMER_PAYMENT_SQL)

Add these missing columns:

* `CNT_ORDERS_COUPON` 
* `CNT_ORDERS_BANK_TRANSFER` 
* `CNT_ORDERS_GIFT_CARD` 

```
with orders as (
    select * from {{ ref('stg_orders') }}
)

, payment as (
    select * from {{ ref('stg_payments') }}
)

, order_payment as (
    select 
        orders.*
        , payment.payment_method

    from orders 
    left join payment using (order_id)
)

, final as (
    select 
        customer_id
        , count(1) as cnt_orders 
        , count_if(payment_method='credit_card') as cnt_orders_credit_card
        , count_if(payment_method='coupon') as cnt_orders_coupon
        , count_if(payment_method='bank_transfer') as cnt_orders_bank_transfer
        , count_if(payment_method='gift_card') as cnt_orders_gift_card

    from order_payment
    group by 1
)

select * from final
```

## Jinja - SQL solution (FCT_CUSTOMER_PAYMENT_JINJA)

The `count_if()` statements in the SQL solution are repetitive and can be "automated" via jinja syntax. We can do so by:

1. Including all unique values of `payment_method` in a set
2. Iterating through the set and generating `count_if(...) as cnt_orders_`, without hardcoding any references


```
{% set payment_methods = ["bank_transfer", "credit_card", "gift_card","coupon"] %}

with orders as (
    select * from {{ ref('stg_orders') }}
)

, payment as (
    select * from {{ ref('stg_payments') }}
)

, order_payment as (
    select 
        orders.*
        , payment.payment_method

    from orders 
    left join payment using (order_id)
)

, final as (
    select 
        customer_id
        , count(1) as cnt_orders 
        
        {% for payment_method in payment_methods %}
        , count_if(payment_method = '{{payment_method}}') as cnt_orders_{{payment_method}}
        {% endfor %}

    from order_payment
    group by 1
)

select * from final
```