# Session02 - Tests & Documentation

In this lab, you will add tests to dbt resources you have already created, such as sources and models. Then, you'll also document them and generate dbt Docs for your project. 

**Note:** Each dbt-focused section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.

## Testing your dbt Project

The first part of this Lab covers the topic of testing dbt resources. Make sure to execute `dbt test` after each section to confirm that your tests were defined properly. There will be **no** tests that are expected to fail in the following assignments.

### Testing your Primary Keys
[How to test primary keys with dbt](https://docs.getdbt.com/blog/primary-key-testing#how-to-test-primary-keys-with-dbt)

Your first task is to add tests to all Primary Key columns in your project. To meet the criteria for a Primary Key, a column must not contain duplicate values or nulls.

For the resources listed below, determine the appropriate Primary Key field and add the necessary tests to it:

**Source tables:**
* `RAW_CUSTOMERS`
* `RAW_ORDERS`
* `RAW_PAYMENTS`

**Models:**
* `STG_CUSTOMERS`
* `STG_ORDERS`
* `STG_PAYMENTS`
* `CUSTOMERS_OVERVIEW`


### Testing for referential integrity

[Relationships tests](https://docs.getdbt.com/reference/resource-properties/tests#relationships)

Taking a look at the `FCT_ORDERS` data, we can see that the column `CUSTOMER_ID` is a foreign key to the `STG_CUSTOMERS` table

Therefore, it's appropriate to validate that all records in the `CUSTOMER_ID` columns have corresponding records in the respective parent table `STG_CUSTOMERS`. You can do this with *relationships* tests.

In total, you should add 2 relationships tests to your project:
* a test that checks that all `CUSTOMER_ID` values from the source table `STG_CUSTOMERS` have a matching value in the column `ID` of in the source table `RAW_CUSTOMERS` 
* a test that checks that all `CUSTOMER_ID` values from the model `FCT_ORDERS` have a matching value in the column `CUSTOMER_ID` of in the model `STG_CUSTOMERS`


### Testing accepted values

[Accepted values tests](https://docs.getdbt.com/reference/resource-properties/tests#accepted_values)

The final test you are going to apply is for accepted values. Take a look at the column `STATUS` in the `ORDERS` table - it contains values that can be any of the following: *completed*, *pending*, *processing*, *cancelled*, *new*.

Your task is to create *accepted_values* tests for the source table `ORDERS` and the model `STG_ORDERS` that validates that these are the only values that this column contains. In case you followed along during the demo, you may have already done this for the staging model - in this case, do the same for the source table.

## Documenting your dbt Project

The second part of this lab covers the subject of documenting your dbt Project. Documentation is a very important aspect of creating and maintaining your dbt Project as it gives non-technical users clarity about how the data has been transformed across the different data layers. 

### Adding descriptions

[Description property](https://docs.getdbt.com/reference/resource-properties/description)

Your task is to add descriptions to all source tables in your project, and their respective columns. You can use the descriptions below:

|Name         |Type  |Description                                                                                                        |
|-------------|:----:|-------------------------------------------------------------------------------------------------------------------|
|**grocery_store**|**source**|**Raw data from the store's CRM system containing data about customers, orders, order items and products.**|
|**customers**|**table**|**Raw data containing customer details such as names, email and gender.**                                       |
|`id`           |column|A unique identifier for each customer.                                                                           |
|`first_name`   |column|The first name of the customer.                                                                                  |
|`last_name`    |column|The last name of the customer.                                                                                   |
|`email`        |column|The email address provided by the customer.                                                                      |
|`gender`       |column|The gender indicated by the customer.                                                                            |
|`date_of_birth`|column|The date of birth as indicated by the customer.                                                                  |
|**orders**   |**table**|**Raw data containing details about the store's orders, such as order date, customer_id and status.**           |
|`id`           |column|A unique identifier for each order.                                                                              |
|`date`         |column|The date the order was placed on.                                                                                |
|`customer_id`  |column|The ID of the customer who placed the oder. Foreign key to `CUSTOMERS`.                                          |
|`status`       |column|*<docs block, check instructions below>*                                                                         |
|**order_items**|**table**|**Raw data about the items in each order, including order ID, product ID and quantity.**                      |
|`order_id`     |column|The ID of the order that the item belongs to. Foreign key to `ORDERS`.                                           |
|`order_item_id`|column|The ID of the item within the current order.                                                                     |
|`product_id`   |column|The ID of the product that the order item corresponds to. Foreign key to `PRODUCTS`.                             |
|`quantity`     |column|The number of units of the product bought within the current order.                                              |
|**products** |**table**|**Raw data about the products offered by the store, including name and price.**                                 |
|`id`           |column|A unique identifier for each product.                                                                            |
|`name`         |column|The name of the product.                                                                                         |
|`price`        |column|The price of the product.                                                                                        |
|`category`     |column|The category of the product.                                                                                     |

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

Your final task is to add a docs block to the description of the `STATUS` column in the `ORDERS` table. If you followed along during the demo, you might have already done this - in this case, feel free to skip this section.

The description of the column should contain the following markdown content:

```
The last known status of the order. Can be any of the following:

| Status     | Description                                    |
|------------|------------------------------------------------|
| new        | Order is newly created and pending processing. |
| pending    | Order is awaiting further action.              |
| processing | Order is currently being processed.            |
| completed  | Order has been successfully completed.         |
| cancelled  | Order has been cancelled.                      |
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
