# Session02 - Packages, Tests & Documentation

In this lab, you will install the **dbt_utils** package, and add tests to dbt models you have already created. Then, you'll also document them and generate dbt Docs for your project. 

**Note:** Each dbt-focused section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.

## Installing a dbt Package
In the root directory of your project (same level as **dbt_project.yml**), created a file named **packages.yml**. Install the **dbt_utils** by copying the following configuration into your **packages.yml** file.

[The dbt_utils package](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/)

```
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```

Save the changes, and run the following command in your IDE
```
dbt deps
```

To check that your packages is installed, navigate to the `dbt_packages` folder of your project. You should see a subfolder named `dbt_utils`.

Now run the following command, and notice the `dbt_packages` folder being removed. This command uninstalls all packages from your project.
```
dbt clean
```

Fret not! You can reinstall the package by running the `dbt deps` command again :)


## Testing your dbt Project

The first part of this Lab covers the topic of testing dbt resources. **Make sure to execute `dbt test` after each section to confirm that your tests were defined properly.** There will be **no** tests that are expected to fail in the following assignments.


### Testing your Primary Keys
[How to test primary keys with dbt](https://docs.getdbt.com/blog/primary-key-testing#how-to-test-primary-keys-with-dbt)

Your first task is to add tests to all Primary Key columns in your project. To meet the criteria for a Primary Key, a column must not contain duplicate values or nulls.

For the models listed below, determine the appropriate Primary Key field and add the `unique` and `not_null` tests to it:

* `STG_CUSTOMERS`
* `STG_ORDERS`
* `STG_PAYMENTS`

You can do so by creating a YAML file in same subfolder of the model. For example, for the `STG_CUSTOMERS` model, create a YAML file in the `staging` subfolder named **stg_customers.yml** with the following configuration:

```
version: 2

models:
  - name: stg_customers
    columns:
      - name: example_column
        tests:
            - unique
            - not_null
```

Once this is done, execute this command to run the tests you have defined for all of the models in the `staging` subfolder:
```
dbt test --select staging.*
```

Observe the results and logs when the command has been completed:

- Did all tests passed?
- What information does the details of the logs contain?

### Testing for referential integrity

[Relationships tests](https://docs.getdbt.com/reference/resource-properties/tests#relationships)

Taking a look at the `FCT_ORDERS` data, we can see that the column `CUSTOMER_ID` is a foreign key to the `STG_CUSTOMERS` table. Therefore, it's appropriate to validate that all records in the `CUSTOMER_ID` columns have corresponding records in the respective parent table `STG_CUSTOMERS`. You can do this with *relationships* tests.

Your task is to add a relationships tests to your project that checks that all `CUSTOMER_ID` values from the model `FCT_ORDERS` have a matching value in the column `CUSTOMER_ID` of in the model `STG_CUSTOMERS`.


### Testing accepted values

[Accepted values tests](https://docs.getdbt.com/reference/resource-properties/tests#accepted_values)

The final test you are going to apply is for accepted values. Take a look at the column `ORDER_STATUS` in the `FCT_ORDERS` table - it contains values that can be any of the following: 

```
returned
completed
shipped
placed
return_pending
```

Your task is to create *accepted_values* tests for the model `FCT_ORDERS` that validates that these are the only values that this column contains. 

### Testing with dbt_utils package

[expression_is_true test in dbt_utils](https://github.com/dbt-labs/dbt-utils/tree/1.1.1/?tab=readme-ov-file#expression_is_true-source)

Preview the data in the `FCT_CUSTOMER_PAYMENT_JINJA` model: notice that `CNT_ORDERS` represents the total orders placed by each customer, which is a summation of the following columns:

```
CNT_ORDERS_CREDIT_CARD
CNT_ORDERS_COUPON
CNT_ORDERS_BANK_TRANSFER
CNT_ORDERS_GIFT_CARD
```

Your task is to add a dbt test on `FCT_CUSTOMER_PAYMENT_JINJA` using the `expression_is_true` test from **dbt_utils**:

```
version: 2

models:
  - name: fct_customer_payment_jinja
    tests:
      - dbt_utils.expression_is_true:
          # fill in the appropriate expression here  
          expression: "col_a + col_b = total"
```

## Documenting your dbt Project

The second part of this lab covers the subject of documenting your dbt Project. Documentation is a very important aspect of creating and maintaining your dbt Project as it gives non-technical users clarity about how the data has been transformed across the different data layers. 

### Adding descriptions

[Description property](https://docs.getdbt.com/reference/resource-properties/description)

Your task is to add descriptions to `FCT_ORDERS` in your project, and their respective columns. You can use the descriptions below:

|Name         |Type  |Description                                                                                                        |
|-------------|:----:|-------------------------------------------------------------------------------------------------------------------|
|**fct_orders** |**table**|**Fact table containing details about the store's orders, such as order date, customer_id and status.**       |
|`customer_id`  |column|The ID of the customer who placed the oder. Foreign key to `CUSTOMERS`.                                          |
|`order_id`     |column|A unique identifier for each order.                                                                              |
|`order_status` |column|*<docs block, check instructions below>*                                                                         |
|`order_date`   |column|The date the order was placed on.                                                                                |
|`first_name`   |column|The first name of the customer who placed the order.                                                             |
|`last_name`    |column|The last name of the customer who placed the order.                                                              |

**Hint:** To add a description to a dbt resource, all you need to do is to add a `description` key to its properties. For example:

```
version: 2

models:
  - name: example_model
    description: An example model.
    columns:
      - name: example_column
        description: An example column.
```

## Create a docs block

[Using Docs Blocks](https://docs.getdbt.com/docs/collaborate/documentation#using-docs-blocks)

Your final task is to add a docs block to the description of the `ORDER_STATUS` column in the `FCT_ORDERS` table. The description of the column should contain the following markdown content:

```
The last known status of the order. Can be any of the following:

| Status         | Description                                    |
|----------------|------------------------------------------------|
| placed         | Order has been successfully created.           |
| completed      | Order has been successfully completed.         |
| shipped        | Order has been successfully shipped.           |
| return_pending | Order is currently being processed for return. |
| returned       | Order is has been returned.                    |
```

To create and reference a docs block:

1. Create a `.md` file with any name in the `models` folder.
2. Add markdown description to the newly created file.
3. Wrap the markdown content in the following Jinja code, replacing `<docs_block_name>` with an appropriate name:

    ```
    {% docs <docs_block_name> %}

        <REPLACE WITH MARKDOWN CONTENT>

    {% enddocs %}
    ```

4. In the `.yml` configuration of the column you're describing, add a `description` property with the following value:

    ```
    "{{ doc(`<docs_block_name>`) }}"
    ```

## Generating and serving your Docs

Now that you have included the relevant documentation to your project, it's time for dbt to generate a special website for it to make it more accessible and more easily readable. For this, all you have to do is to execute the following two commands:

```
dbt docs generate
```

Then, your site will be served locally by dbt. Once you are no longer in need of reviewing it, you can interrupt the server with `Ctrl + C`.

## Committing and pushing your changes

Now that you have completed your tasks, it's time to commit your changes.
    ```

Congratulations! You have completed this Lab successfully.
