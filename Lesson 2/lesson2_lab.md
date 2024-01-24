# Lesson 2 - Familiarising yourself with Jinja and Macros

In this lab, you will create a new dbt model that will be written in Jinja. Then, you will modify the `generate_schema_name` macro that will be used for separating Dev and Prod schemas.

**Note:** Each dbt-focused section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.

## Jinja Templating Language
[Jinja](https://docs.getdbt.com/docs/build/jinja-macros#jinja)


For an upcoming sale campaign, the jaffle shop is interested in exploring the payment method that each customer prefers. 

Your task is to create a **table** model called `FCT_CUSTOMER_PAYMENT` with the following columns:
* `CUSTOMER_ID` - the ID of each customer who has placed an order 
* `CNT_ORDERS` - the total number of orders placed (excluding returned/pending returned orders)
* `CNT_ORDERS_CREDIT_CARD` - the total number of orders placed via **credit card** (excluding returned/pending returned orders)
* `CNT_ORDERS_COUPON` - the total number of orders placed via **coupon** (excluding returned/pending returned orders)
* `CNT_ORDERS_BANK_TRANSFER` - the total number of orders placed via **bank transfer** (excluding returned/pending returned orders)
* `CNT_ORDERS_GIFT_CARD` - the total number of orders placed via **gift card** (excluding returned/pending returned orders)

**Hint:** You need to do a `LEFT JOIN` to the `STG_PAYMENTS` model, which contains the payment method used for each order.

The SQL for `STG_PAYMENTS` is provided to assist you with this task:
```
select * from something
```

### SQL Solution

First, create the `FCT_CUSTOMER_PAYMENT` table using **pure SQL only**. Make the necessary joins and aggregations to produce the required columns and try to use CTEs as described in dbt Labs' [style guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md#example-sql-with-ctes).

Once you are done creating the model, run it and review its output in Snowflake.

### Make your solution DRY

Now that you've confirmed your model produces the correct results, let's try and minimize repetitive code in it. Inspect the parts of your model that produce the aggregations for number of orders per payment method.

When using pure SQL to produce these columns, the code is very repetitive. Utilize Jinja's `for` loops and conditional statements to rewrite it. Run the model again to ensure the results remain consistent.

**Note:** You can use some [Jinja functions](https://jinja.palletsprojects.com/en/3.1.x/templates/#jinja-filters.replace) to produce the column aliases. For example, `{{ 'Hello World' | replace('Hello', 'Hey') }}` will produce the following output: `Hey World`.

**Hint:** 
* For now, you can hard-code the list of payment methods in a variable.

## dbt Macros
[Macros](https://docs.getdbt.com/docs/build/jinja-macros#macros)

For the campaign, the store would like to offer its loyal customers personalized discounts based on their shopping activity and the time passed since they became a customer. Fortunately, they already have a good summary of customers' shopping history in the `CUSTOMERS_OVERVIEW` model and can calculate the discounts based on it.

In order to be eligible for a discount, a customer needs to meet at least one of the following criteria:
* Having placed at least 3 non-cancelled orders
* Having spent at least 300 USD across all orders

If they don't meet either condition, they do not get a personalized discount.

The discount itself is calculated as follows:
* If the customer has 3 orders or less: the discount is 3% of their `TOTAL_AMOUNT_SPENT`
* If the customer more than 3 orders: the discount is 5% of their `TOTAL_AMOUNT_SPENT`

Your task is to create the following **macros**:
* `get_discount_eligibility` - returns a *boolean* value (`TRUE` or `FALSE`) indicating if a customer is eligible for a discount
* `calculate_discount` - returns a *float* value rounded to the second decimal representing the discount in USD, calculated as described above

Both of the macros accept the same arguments:
* `order_count`
* `total_amount_spent`

Use the macros in a new **view** model called `CUSTOMER_DISCOUNTS` that produces the following columns:
* `CUSTOMER_ID`
* `NUMBER_OF_ORDERS`
* `TOTAL_AMOUNT_SPENT`
* `IS_ELIGIBLE_FOR_DISCOUNT` - created using the `get_discount_eligibility` macro
* `DISCOUNT_USD` - created using the `calculate_discount` macro 


## Committing and pushing your changes

This is the final part of the lab, but it's an important one - remember to always commit and push your changes to GitHub when you have completed a task. 
    ```

Congratulations! You have completed this Lab successfully.
