# Lesson 7 - Refactoring SQL in dbt

In this lab, you will be refactoring the `customer_orders` SQL file.

## Step 1: Migrate legacy code 1:1

1. Create a `legacy` folder in your `models` directory
2. Create a model named `customer_orders.sql` in the `legacy` folder, and paste this code into the model: 


## Step 2: Implement sources

1. Replace all hardcoded table references using the `source` function 
2. Once you've replaced the sources, check that your model runs successfully
```
dbt run --select customer_orders
```


## Step 3: Choose a Refactoring strategy

We will go with the **refactor along-side** strategy for this lab to allow for easier auditing of the model.

1. Create a new model in the `marts` folder named `fct_customer_orders.sql`
2. Copy and paste the code from `customer_orders.sql` into `fct_customer_orders.sql`


## Step 4: Cosmetic cleanups and CTE groupings

1. Click on "Format" in the Cloud IDE to reformat the code.
2. Create **import CTEs** for all model references.
3. Create **logical CTEs** by creating a new CTE for all subqueries.
4. Wrap the remaining code in a **final CTE**, followed by the **simple select statement**.

Final code:
```
-- import CTE
with orders as (
    select * from {{ source('snowflake_sample', 'raw_orders') }}
)

, customers as (
    select * from {{ source('snowflake_sample', 'raw_customers') }}
)

, payments as (
    select * from {{ source('snowflake_sample', 'raw_payments') }}
)

-- logical CTE
, customers_name as (
    select
        *
        , first_name || ' ' || last_name as name
    from customers
)

, a as (
    select
        *
        , row_number()
            over (partition by user_id order by order_date, id)
            as user_order_seq
    from orders    
)

, b as (
    select
        *
        , first_name || ' ' || last_name as name
    from customers
)

, customer_order_history as (
    select
        b.id as customer_id
        , b.name as full_name
        , b.last_name
        , b.first_name
        , min(order_date) as first_order_date
        , min(case when a.status not in ('returned', 'return_pending') then order_date end) as first_non_returned_order_date
        , max(case when a.status not in ('returned', 'return_pending') then order_date end) as most_recent_non_returned_order_date
        , coalesce(max(user_order_seq), 0) as order_count
        , coalesce(count(case when a.status != 'returned' then 1 end), 0) as non_returned_order_count
        , sum(case when a.status not in ('returned', 'return_pending') then round(c.amount / 100.0, 2) else 0 end) as total_lifetime_value
        , sum(case when a.status not in ('returned', 'return_pending') then round(c.amount / 100.0, 2) else 0 end) / nullif(count(case when a.status not in ('returned', 'return_pending') then 1 end), 0) as avg_non_returned_order_value
        , array_agg(distinct a.id) as order_ids

    from a

    inner join b
        on a.user_id = b.id

    left outer join payments as c
        on a.id = c.order_id

    where a.status not in ('pending')

    group by b.id, b.name, b.last_name, b.first_name
)

-- final CTE
, final as (
    select
        orders.id as order_id
        , orders.user_id as customer_id
        , last_name
        , first_name
        , first_order_date
        , order_count
        , total_lifetime_value
        , orders.status as order_status
        , payments.id as payment_id
        , payments.payment_method
        , round(amount / 100.0, 2) as order_value_dollars
    from orders 
    inner join customers_name
        on orders.user_id = customers_name.id

    inner join customer_order_history
        on orders.user_id = customer_order_history.customer_id

    left outer join payments
        on orders.id = payments.order_id
)

-- final select statment
select * from final 
```


## Step 5: Centralising transformations and splitting models - Intermediate 

1. 