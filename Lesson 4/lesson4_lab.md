# Lesson 4 - User-Defined Functions & Stored Procedures

In this lab, you will learn how to work with User-Defined Functions and Stored Procedures.

**Note:** Each section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.


## Exercise 1: Use SQL to create a User-Defined Function
1. Create a User-Defined Function called `APPEND_EXCLAMATION_MARK_SQL_<YOUR NAME>` which using **SQL** adds an exclamation mark after a random phrase. 

* [Introduction to SQL UDFs](https://docs.snowflake.com/en/developer-guide/udf/sql/udf-sql-introduction)

2. Test the UDF using `Hello World` as the random phrase. 

    Expected output: `Hello World!`


## Exercise 2: Use Python to create a User-Defined Function
1. Create the same function as in `Exercise 1` but this time use the **Python** language. Name it `APPEND_EXCLAMATION_MARK_PYTHON_<YOUR NAME>`.

* [CREATE FUNCTION](https://docs.snowflake.com/en/sql-reference/sql/create-function)

    Hint:
    ```
    def append_excl_mark(phrase):
    return phrase + '!'
    ```
2. Test it with the `Hello World` phrase again.

    Expected output: `Hello World!`


## Exercise 3: Use User-Defined Function in queries
1. Write a query which selects the `payment_method` along with `id`.
    `payment_method` for each payment is as follows: 
    - When the `payment_method` is 'bank_transfer' or 'credit_card', the `payment_type` is 'CASHLESS'.
    - When the `payment_method` is 'gift_card' or 'coupon', the `payment_type` is 'CASH'.

SQL:
```
select
    id
    , payment_method
    , case 
        when payment_method in ('credit_card','bank_transfer') then 'CASHLESS' 
        when payment_method in ('coupon','gift_card') then 'CASH' 
      end as payment_type
from raw_payments;
```

4. Create a **SQL UDF** named `GET_PAYMENT_TYPE_<YOUR NAME>` which handles the logic in the `payment_type` column.

5. Write the same query again but this time using the UDF to create the `payment_type` column.


## Exercise 4: Create your first Stored Procedure
1. Create a new database named `SP_<YOUR NAME>` and a schema called `SP`.
2. Create a Stored Procedure named `MESSAGE_<YOUR NAME>` using SQL (Snowflake Scripting) which returns the value of an argument that is passed in. 
3. Call the stored procedure and pass 'This is your first stored procedure' as an arguement.

* [CREATE PROCEDURE](https://docs.snowflake.com/en/sql-reference/sql/create-procedure)
* [Writing Stored Procedures in Snowflake Scripting](https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-snowflake-scripting)

## Exercise 5: Create a Stored Procedure which updates a table
1. Create a clone of the `RAW_ORDERS` table named `ORDERS_<YOUR NAME>`.

* [CREATE TABLE ... CLONE](https://docs.snowflake.com/en/sql-reference/sql/create-table#create-table-clone)

```
CREATE TABLE orders_<your name> CLONE raw_orders;
```

2. Create a SQL Stored Procedure named `UPDATE_STATUS_<YOUR NAME>` which:

    - Takes the `ID` column from `ORDERS_<YOUR NAME>` as an argument.

    - Updates the value in the `STATUS` column to `completed` for the `ID` value passed as an argument
        E.g. The status for 'id = 86' should change from 'placed' to 'completed'

    - Returns the following message: 'Order status updated to completed for Order ID: <order_id>'

**Note:** You'll need to familiarise with Snowflake Scripting to write a SQL stored procedure:

*[Introduction to Snowflake Stored Procedures](https://thinketl.com/introduction-to-snowflake-stored-procedures/)

* [Working with Variables](https://docs.snowflake.com/en/developer-guide/snowflake-scripting/variables#label-snowscript-variables-binding)

3. Check the `status` for orders with the `ID` value being '86' and the second with '87'. You should see that `status` is currently 'placed':

```
select * from orders_<your name> where id in (86,87);
```

4. Call the Stored Procedure twice - the first time for `ID` value being '86' and the second with '87'. 

5. Check that `status` for orders with the `ID` value being '86' and the second with '87' has changed to `completed`.

```
select * from orders_<your name> where id in (86,87);
```


## Congratulations! You have completed this Lab successfully.





