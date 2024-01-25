# Lesson 2 - Project Structure, Jinja and Macros

In this lab, you will create new models in your project, using both SQL and Jinja. After that, you will create a macro and trying it out on one of the new models.

**Note:** Each dbt-focused section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.


## Create a staging model
Create a `STG_PAYMENTS` model in your project, which reads from `RAW_PAYMENTS`. Make sure you add it into the correct subdirectory in `models`!

This is the SQL for `STG_PAYMENTS`:
```
with payments as (
    select * from {{ source('snowflake_sample', 'raw_payments') }}
)

, final as (
    select 
        id as payment_id 
        , order_id
        , amount as amount_cents
        , payment_method  
    
    from payments 
)

select * from final
```

**Hint:** Refer to Slide 14 of Lesson 2's deck.

When you are done, execute the following command
```
dbt run --select staging.*
```
You should see that all models in your `staging` directory have run and materialized in Snowflake. You can navigate to your Snowflake console to inspect the output.


## Jinja Templating Language
[Jinja](https://docs.getdbt.com/docs/build/jinja-macros#jinja)


For an upcoming sale campaign, the jaffle shop is interested in exploring the payment method that each customer prefers. 

Your task is to create a **table** model called `FCT_CUSTOMER_PAYMENT` with the following columns:
* `CUSTOMER_ID` - the ID of each customer who has placed an order 
* `CNT_ORDERS` - the total number of orders placed 
* `CNT_ORDERS_CREDIT_CARD` - the total number of orders placed via **credit card** 
* `CNT_ORDERS_COUPON` - the total number of orders placed via **coupon** 
* `CNT_ORDERS_BANK_TRANSFER` - the total number of orders placed via **bank transfer** 
* `CNT_ORDERS_GIFT_CARD` - the total number of orders placed via **gift card** 


### SQL Solution

First, create the `FCT_CUSTOMER_PAYMENT_SQL` table using **pure SQL only**. Make the necessary joins and aggregations to produce the required columns and try to use CTEs as described in dbt Labs' [style guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md#example-sql-with-ctes).

You can use the following SQL as a starting point, and add the missing columns:
```
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
    left join payments using (order_id)
)

, final as (
    select 
        customer_id
        , count(1) as cnt_orders 
        , count_if(payment_method='credit_card') as cnt_orders_credit_card

    from order_payment
    group by 1
)

select * from final
```

Once you are done creating the model, run `FCT_CUSTOMER_PAYMENT_SQL` and all of the upstream models (e.g. `STG_ORDERS`, `STG_PAYMENTS`) using this command:
```
dbt run --select +fct_customer_payment_sql
```


### Make your solution DRY

Now that you've confirmed your model produces the correct results, let's try and minimize repetitive code in it. Inspect the parts of `FCT_CUSTOMER_PAYMENT_SQL` that produce the aggregations for number of orders per payment method. 

When using pure SQL to produce these columns, the code is very repetitive. Utilize Jinja's `for` loops and conditional statements to rewrite it in a new dbt model, `FCT_CUSTOMER_PAYMENT_JINJA`. 

Look at the compiled SQL of `FCT_CUSTOMER_PAYMENT_JINJA` by either clicking the "Compiled code" button, or running this command. The compiled SQL should look similar to what you have in `FCT_CUSTOMER_PAYMENT_SQL`.
```
dbt compile --select fct_customer_payment_jinja
```

Run `FCT_CUSTOMER_PAYMENT_JINJA` to ensure the results remain consistent.

```
dbt run --select fct_customer_payment_jinja
```

**Note:** 
* You can use some [Jinja functions](https://jinja.palletsprojects.com/en/3.1.x/templates/#jinja-filters.replace) to produce the column aliases. For example, `{{ 'Hello World' | replace('Hello', 'Hey') }}` will produce the following output: `Hey World`.

**Hint:** 
* For now, you can hard-code the list of payment methods in a variable.
* You can reference [this example in the dbt documentation](https://docs.getdbt.com/docs/build/jinja-macros#jinja)


## dbt Macros
[Macros](https://docs.getdbt.com/docs/build/jinja-macros#macros)

Refer to the documentation above, and copy the `cents_to_dollars` macro into your project. 
```
{% macro cents_to_dollars(column_name, scale=2) %}
    ({{ column_name }} / 100)::numeric(16, {{ scale }})
{% endmacro %}
```

Once you have done so, modify `STG_PAYMENTS` to include the `AMOUNT_DOLLARS` column. You should use the `cents_to_dollars` macro in your implementation.

**Hint:** Refer to dbt's documentation on how to use the macro.


## Committing and pushing your changes

This is the final part of the lab, but it's an important one - remember to always commit and push your changes to GitHub when you have completed a task. 

Congratulations! You have completed this Lab successfully.
