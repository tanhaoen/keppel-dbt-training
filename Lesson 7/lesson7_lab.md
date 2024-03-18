# Lesson 7 - Refactoring SQL in dbt

In this lab, you will be refactoring the `customer_orders` SQL file.

## Step 1: Migrate legacy code 1:1

1. Create a `legacy` folder in your `models` directory
2. Create a model named `customer_orders.sql` in the `legacy` folder, and paste the code from **customer_orders.sql** into the model.


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
3. Create **logical CTEs** by moving all subqueries into a new CTE.
4. Wrap the remaining code in a **final CTE**, followed by the **simple select statement**.

Final code:
```
-- import CTE
with
    base_orders as (select * from {{ source("snowflake_sample", "raw_orders") }}),

    base_customers as (select * from {{ source("snowflake_sample", "raw_customers") }}),

    base_payments as (select * from {{ source("snowflake_sample", "raw_payments") }}),

    -- logical CTEs
    customers as (select first_name || ' ' || last_name as name, * from base_customers),

    a as (
        select
            row_number() over (
                partition by user_id order by order_date, id
            ) as user_order_seq,
            *
        from base_orders
    ),

    b as (select first_name || ' ' || last_name as name, * from base_customers),

    customer_order_history as (
        select
            b.id as customer_id,
            b.name as full_name,
            b.last_name,
            b.first_name,
            min(order_date) as first_order_date,
            min(
                case
                    when a.status not in ('returned', 'return_pending') then order_date
                end
            ) as first_non_returned_order_date,
            max(
                case
                    when a.status not in ('returned', 'return_pending') then order_date
                end
            ) as most_recent_non_returned_order_date,
            coalesce(max(user_order_seq), 0) as order_count,
            coalesce(
                count(case when a.status != 'returned' then 1 end), 0
            ) as non_returned_order_count,
            sum(
                case
                    when a.status not in ('returned', 'return_pending')
                    then round(c.amount / 100.0, 2)
                    else 0
                end
            ) as total_lifetime_value,
            sum(
                case
                    when a.status not in ('returned', 'return_pending')
                    then round(c.amount / 100.0, 2)
                    else 0
                end
            ) / nullif(
                count(
                    case when a.status not in ('returned', 'return_pending') then 1 end
                ),
                0
            ) as avg_non_returned_order_value,
            array_agg(distinct a.id) as order_ids

        from a

        join b on a.user_id = b.id

        left outer join base_payments c on a.id = c.order_id

        where a.status not in ('pending')

        group by b.id, b.name, b.last_name, b.first_name
    ),

    -- final CTE
    final as (
        select
            orders.id as order_id,
            orders.user_id as customer_id,
            customers.last_name,
            customers.first_name,
            first_order_date,
            order_count,
            total_lifetime_value,
            round(amount / 100.0, 2) as order_value_dollars,
            orders.status as order_status,
            payments.id as payment_id,
            payments.payment_method
        from base_orders as orders

        join customers on orders.user_id = customers.id

        join
            customer_order_history
            on orders.user_id = customer_order_history.customer_id

        left outer join base_payments payments on orders.id = payments.order_id
    )

select *
from final
```


## Step 5: Centralising transformations and splitting models - Staging 

1. Identify transformations that can be moved to the staging layer for **customers**, **orders** and **payments**

For **orders**:
- `id` to `order_id`
- `user_id` to `customer_id`
- `status` to `order_status`
- Create `user_order_seq`

For **customers**:
- `id` to `customer_id`
- Create `full_name`

For **payments**:
- `id` to `payment_id`
- Convert `amount` to `order_value_dollars` 

**Note**: As there are multiple rows per `order_id` in `stg_payments`, `stg_payments.amount` does not represent the total order value. Instead, it should be the summation of `amount` in `stg_payments`.

2. Create staging CTEs and update the code to read from the staging CTEs

3. Move logic from staging CTEs into staging models.

Updated code for `stg_customers`
```
with customers as (
    select * from {{ source('snowflake_sample', 'raw_customers') }}
)

, final as (
    select 
        id as customer_id
        , first_name
        , last_name
        , first_name || ' ' || last_name as full_name
    
    from customers 
)

select * from final
```

Updated code for `stg_orders`
```
with orders as (
    select * from {{ source('snowflake_sample', 'raw_orders') }}
)

, final as (
    select 
        id as order_id
        , user_id as customer_id
        , status as order_status
        , order_date
        , row_number()
            over (partition by user_id order by order_date, id)
          as user_order_seq
          
    from orders
)

select * from final
```

Updated code for `stg_payments`
```
with payments as (
    select * from {{ source('snowflake_sample', 'raw_payments') }}
)

, final as (
    select 
        id as payment_id 
        , order_id
        , amount as amount_cents
        , {{ cents_to_dollars('amount_cents') }} as amount_dollars
        , payment_method  
    
    from payments 
)

select * from final
```

4. Update code for staging CTEs to read from the staging models, and remove the import CTEs.

Final code in `fct_customer_orders` 
```
-- import CTE
with
    stg_orders as (
        select order_id, customer_id, order_status, order_date, user_order_seq

        from {{ ref("stg_orders") }}
    ),

    stg_customers as (
        select customer_id, first_name, last_name, full_name
        from {{ ref("stg_customers") }}
    ),

    stg_payments as (
        select payment_id, order_id, amount_dollars, payment_method

        from {{ ref("stg_payments") }}
    ),

    -- logical CTEs
    customer_order_history as (
        select
            stg_customers.customer_id,
            stg_customers.full_name,
            stg_customers.last_name,
            stg_customers.first_name,
            min(order_date) as first_order_date,
            min(
                case
                    when stg_orders.order_status not in ('returned', 'return_pending')
                    then order_date
                end
            ) as first_non_returned_order_date,
            max(
                case
                    when stg_orders.order_status not in ('returned', 'return_pending')
                    then order_date
                end
            ) as most_recent_non_returned_order_date,
            coalesce(max(user_order_seq), 0) as order_count,
            coalesce(
                count(case when stg_orders.order_status != 'returned' then 1 end), 0
            ) as non_returned_order_count,
            sum(
                case
                    when stg_orders.order_status not in ('returned', 'return_pending')
                    then stg_payments.amount_dollars
                    else 0
                end
            ) as total_lifetime_value,
            sum(
                case
                    when stg_orders.order_status not in ('returned', 'return_pending')
                    then stg_payments.amount_dollars
                    else 0
                end
            ) / nullif(
                count(
                    case
                        when
                            stg_orders.order_status
                            not in ('returned', 'return_pending')
                        then 1
                    end
                ),
                0
            ) as avg_non_returned_order_value,
            array_agg(distinct stg_orders.order_id) as order_ids

        from stg_orders

        join stg_customers on stg_orders.customer_id = stg_customers.customer_id

        left outer join stg_payments on stg_orders.order_id = stg_payments.order_id

        where stg_orders.order_status not in ('pending')

        group by
            stg_customers.customer_id,
            stg_customers.full_name,
            stg_customers.last_name,
            stg_customers.first_name
    ),

    -- final CTE
    final as (
        select
            orders.order_id,
            orders.customer_id,
            stg_customers.last_name,
            stg_customers.first_name,
            first_order_date,
            order_count,
            total_lifetime_value,
            stg_payments.amount_dollars as order_value_dollars,
            orders.order_status,
            stg_payments.payment_id,
            stg_payments.payment_method
        from stg_orders as orders

        join stg_customers on orders.customer_id = stg_customers.customer_id

        join
            customer_order_history
            on orders.customer_id = customer_order_history.customer_id

        left outer join stg_payments on orders.order_id = stg_payments.order_id
    )

select *
from final
```

## Step 5: Centralising transformations and splitting models - Intermediate

1. Observe the DAG for the project (or slide 39 & 40 of lesson deck); the join between `stg_orders`, `stg_customers` and `stg_payments` is repeated across all `fct_` models in the project. This is an opportunity to centralise the join logic in an intermediate model.

2. Create a new CTE named **orders_joined**, above the customer_order_history CTE. Move the join logic into this CTE.

3. Check the code for the **customer_order_history** and **final** CTEs - the output of the **orders_joined** CTE can also be used in these 2 CTEs. Replace the references for these CTEs and clean up the code.

4. Create an `intermediate` folder in your `marts` folder, and create a new model named `int_orders_joined.sql`. Copy and paste all code from the **orders_joined CTE** into this model. 

5. Update the code for **orders_joined CTE** in `fct_customer_orders`, and remove unnecessary import CTEs.

Code for `int_orders_joined`
```
-- import CTE
with
    stg_orders as (
        select order_id, customer_id, order_status, order_date, user_order_seq

        from {{ ref("stg_orders") }}
    ),

    stg_customers as (
        select customer_id, first_name, last_name, full_name
        from {{ ref("stg_customers") }}
    ),

    stg_payments as (
        select payment_id, order_id, amount_dollars, payment_method

        from {{ ref("stg_payments") }}
    ),

    -- final CTEs
    final as (
        select
            stg_customers.customer_id,
            stg_customers.full_name,
            stg_customers.last_name,
            stg_customers.first_name,
            stg_orders.order_id,
            stg_orders.order_date,
            stg_orders.order_status,
            stg_orders.user_order_seq,
            stg_payments.amount_dollars,
            stg_payments.payment_id,
            stg_payments.payment_method

        from stg_orders

        join stg_customers on stg_orders.customer_id = stg_customers.customer_id

        left outer join stg_payments on stg_orders.order_id = stg_payments.order_id
    )

select *
from final
```

Code for `fct_customer_orders`
```
-- import CTE
with
    orders_joined as (select * from {{ ref("int_orders_joined") }}),

    -- logical CTE
    customer_order_history as (
        select
            customer_id,
            full_name,
            last_name,
            first_name,
            min(order_date) as first_order_date,
            min(
                case
                    when order_status not in ('returned', 'return_pending')
                    then order_date
                end
            ) as first_non_returned_order_date,
            max(
                case
                    when order_status not in ('returned', 'return_pending')
                    then order_date
                end
            ) as most_recent_non_returned_order_date,
            coalesce(max(user_order_seq), 0) as order_count,
            coalesce(
                count(case when order_status != 'returned' then 1 end), 0
            ) as non_returned_order_count,
            sum(
                case
                    when order_status not in ('returned', 'return_pending')
                    then amount_dollars
                    else 0
                end
            ) as total_lifetime_value,
            sum(
                case
                    when order_status not in ('returned', 'return_pending')
                    then amount_dollars
                    else 0
                end
            ) / nullif(
                count(
                    case
                        when order_status not in ('returned', 'return_pending') then 1
                    end
                ),
                0
            ) as avg_non_returned_order_value,
            array_agg(distinct order_id) as order_ids

        from orders_joined

        where order_status not in ('pending')

        group by customer_id, full_name, last_name, first_name
    ),

    -- final CTE
    final as (
        select
            orders_joined.order_id,
            orders_joined.customer_id,
            orders_joined.last_name,
            orders_joined.first_name,
            customer_order_history.first_order_date,
            customer_order_history.order_count,
            total_lifetime_value,
            orders_joined.amount_dollars as order_value_dollars,
            orders_joined.order_status,
            orders_joined.payment_id,
            orders_joined.payment_method
        from orders_joined

        join
            customer_order_history
            on orders_joined.customer_id = customer_order_history.customer_id

    )

select *
from final
```

## Step 5: Centralising transformations and splitting models - Final

1. Check the name and ordering of columns in the **final CTE** of `fct_customer_orders`. It should match the output of `customer_orders` in the `legacy` folder.

Final code for `fct_customer_orders`
```
-- import CTE
with orders_joined as (
    select * from {{ ref('int_orders_joined') }}
)

-- logical CTE
, customer_order_history as (
    select
        customer_id 
        , full_name
        , last_name 
        , first_name
        , min(order_date) as first_order_date
        , min(case when order_status not in ('returned', 'return_pending') then order_date end) as first_non_returned_order_date
        , max(case when order_status not in ('returned', 'return_pending') then order_date end) as most_recent_non_returned_order_date
        , coalesce(max(user_order_seq), 0) as order_count
        , coalesce(count(case when order_status != 'returned' then 1 end), 0) as non_returned_order_count
        , sum(case when order_status not in ('returned', 'return_pending') then order_value_dollars else 0 end) as total_lifetime_value
        , sum(case when order_status not in ('returned', 'return_pending') then order_value_dollars else 0 end) / nullif(count(case when order_status not in ('returned', 'return_pending') then 1 end), 0) as avg_non_returned_order_value
        , array_agg(distinct order_id) as order_ids

    from orders_joined

    where order_status not in ('pending')

    group by customer_id, full_name, last_name, first_name
)

-- final CTE
, final as (
    select
        orders_joined.order_id
        , orders_joined.customer_id
        , orders_joined.last_name 
        , orders_joined.first_name
        , customer_order_history.first_order_date
        , customer_order_history.order_count
        , customer_order_history.total_lifetime_value
        , orders_joined.order_value_dollars
        , orders_joined.order_status
        , orders_joined.payment_id
        , orders_joined.payment_method

    from orders_joined 
    
    inner join customer_order_history
        on orders_joined.customer_id = customer_order_history.customer_id
)

-- final select statment
select * from final 
```

## Step 6: Auditing

1. Check that `audit_helper` is configured in the `packages.yml` file. Run this command to install `audit_helper`
```
dbt deps
```

2. Copy and paste the following code snippet into a new file in your Cloud IDE:
```
{% set old_etl_relation=ref('customer_orders') -%}

{% set dbt_relation=ref('fct_customer_orders') %}

{{ audit_helper.compare_relations(
    a_relation=old_etl_relation,
    b_relation=dbt_relation,
    primary_key="order_id"
) }}
```

3. Click on "Preview" and check the results of the `compare_relations` macro. You should see only 1 row in the output, indicating that there is a 100% match of data in both tables: 

|IN_A | IN_B | COUNT | PERCENT_OF_TOTAL |
|-----|------|-------|------------------|
|true | true | 113   | 100.0            |

4. **Optional**: Click on "Compile" and inspect the compiled SQL for the `compare_relations` macro


### Congratulations! You have completed this Lab successfully.