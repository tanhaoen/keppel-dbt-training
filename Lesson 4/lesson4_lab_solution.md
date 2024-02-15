# Lesson 4 (Solution) - User-Defined Functions & Stored Procedures

Note: I have used `JY` as my initials in the exercises. Your solution should correspond to your name / initials.

## Exercise 1: Use SQL to create a User-Defined Function

You do not need to explicitly configure the `LANGUAGE` parameter in `CREATE FUNCTION` for SQL UDFs:

* [CREATE FUNCTION](https://docs.snowflake.com/en/sql-reference/sql/create-function#sql-handler) 

```
CREATE FUNCTION APPEND_EXCLAMATION_MARK_SQL_JY(input_text STRING)
RETURNS STRING
as
$$
    concat(input_text, '!')
$$;
```

To execute the function:
```
select append_exclamation_mark_sql_jy('hello world');
```

## Exercise 2: Use Python to create a User-Defined Function

```
CREATE FUNCTION APPEND_EXCLAMATION_MARK_PYTHON_JY(input_text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'append_exclamation_mark'
as
$$
def append_exclamation_mark(input_text):
  return input_text + '!'
$$;
```

To execute the function:
```
select append_exclamation_mark_python_jy('hello world');
```

## Exercise 3: Use User-Defined Function in queries

SQL UDF for `GET_PAYMENT_TYPE` UDF repeats the logic used for the `payment_type` column:
```
CREATE FUNCTION GET_PAYMENT_TYPE_JY(payment_method STRING)
RETURNS STRING
AS
$$
case 
    when payment_method in ('credit_card','bank_transfer') then 'CASHLESS' 
    when payment_method in ('coupon','gift_card') then 'CASH' 
end
$$;
```

Rewriting the query provided by calling the UDF:
```
select
    id
    , payment_method
    , get_payment_type_jy(payment_method) as payment_type

from raw_payments
limit 50;
```

## Exercise 4: Create a Stored Procedure which updates a table

Unlike UDFs, creating a procedure via SQL will require the **Snowflake Scripting** syntax:

* [CREATE PROCEDURE](https://docs.snowflake.com/en/sql-reference/sql/create-procedure)

Every SQL procedure will minimally require a `BEGIN` and `END` block: 

* [Snowflake Scripting - Blocks](https://docs.snowflake.com/en/developer-guide/snowflake-scripting/blocks)

```
CREATE PROCEDURE update_status_jy(order_id NUMBER) 
RETURNS VARCHAR
AS
$$
BEGIN
    UPDATE orders_jy SET status='completed' WHERE id = :order_id;
    RETURN 'Order status updated to completed for Order ID:'|| order_id;
END;
$$;
```

Calling the Stored Procedure and checking the updated record:
```
CALL update_status_jy(86);
select * from orders_jy where id in (86,87);

CALL update_status_jy(87);
select * from orders_jy where id in (86,87);
```