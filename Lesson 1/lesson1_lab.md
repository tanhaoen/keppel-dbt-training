# Lesson 1 - dbt Project Structure, Sources & Models

In this lab, you will explore the capabilities of the dbt Cloud IDE, you will define sources for your dbt project and create your first models, test them and document them. 

**Note:** Each dbt-focused section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.


## Exploring the dbt Cloud IDE
[Develop in the IDE](https://docs.getdbt.com/docs/cloud/dbt-cloud-ide/develop-in-the-cloud)

Now that you've connected your project to dbt Cloud, you should be presented with a few options. Choose `Start developing in the IDE` (or, alternatively, click `Develop` in the top right corner). The dbt Cloud IDE will load.


### Working with the File Explorer

The File Explorer menu is quite self-explanatory, but there are some lesser-known features that you can utilize for better efficiency. Navigate to any model in the left-side menu, hover over its name and click the three dots (...) on the right. You can see a few dbt-specific options:

* `Copy Name` - useful when referencing models with long names 
* `Copy Relative Path` - useful for CLI commands
* `Copy as Ref` - copies a direct Jinja reference to the model
* `Duplicate` - creates a copy of the model

For bigger projects with hundreds or even thousands of models, it might get difficult to navigate to the model you need by going through the project's folder structure. In such cases, you can use the magnifying glass button to search for the model by its name.


### Working with the code editor

Open any model from the File Explorer and add the following comment to it:

```
-- this is a test
```

Notice that the green button `Save` becomes active - click it. Alternatively, you can do the same with the `Command + S` (Mac) / `Ctrl + S` (Windows) command. You need to make sure your files have been saved before you can commit your changes.

When you save your file, it will appear under `Changes` in the `Version Control` menu. You can click it to compare it's current state to the initial one. The `Changes` section lists all files that will be committed if you click the `Commit and sync` button. Once you do that, you will be able to raise a Pull request. 

You don't actually need this comment in the file, so let's discard it. To revert the file to its initial state, click the three dots (...) next to its name under `Version Control > Changes` and choose `Revert File`.


### Using shortcuts

One of the benefits of working in the dbt Cloud IDE is the abundance of autocomplete shortcuts you can use for writing your code in a more efficient manner. You can access all of them by using a double underscore in the code editor: `__`.

Once you do that, you will be presented with the option of choosing a template for some commonly used Jinja functions and code blocks such as `{{ ref() }}`, `{{ source() }}`, `{% for item in list %}`.


## Create a branch

Create a branch in your IDE following this naming convention: `lab-1-<your name>` (e.g. lab-1-jingyu)


## Defining sources

[Add sources to your DAG](https://docs.getdbt.com/docs/build/sources)

You should be able to access the Snowflake Sample Datasets in the `SNOWFLAKE_SAMPLE_DATA` database and `TPCH_SF1` schema, which contains these tables:

* `ORDERS`
* `LINEITEM`
* `CUSTOMERS`

Your task is to define a single dbt Source named `snowflake_sample` that allows you to select from each table using the `{{ source() }}` function. Consult the [dbt documentation](https://docs.getdbt.com/docs/build/sources#declaring-a-source) in case you need a refresher on how sources are declared.

Once you are finished with the source definitions, test if dbt detects them properly. To do this, execute the following command in your terminal:
```
dbt ls
```
If your sources were defined correctly, your terminal's output should resemble the output below:

```
07:52:55 Found 0 models, 3 sources, 0 exposures, 0 metrics, 430 macros, 0 groups, 0 semantic models
07:52:55 source:my_new_project.snowflake_sample.customer
07:52:55 source:my_new_project.snowflake_sample.lineitem
07:52:55 source:my_new_project.snowflake_sample.orders
```

## Creating your first models

[About dbt models](https://docs.getdbt.com/docs/build/models)

[About source function](https://docs.getdbt.com/reference/dbt-jinja-functions/source)

Now that you have your sources defined, it's time to create your first models:

* `STG_ORDERS`
* `STG_CUSTOMERS` 

For your convenience, the SQL for the models have been provided:

**`STG_ORDERS`**
```
with orders as (
    select * from {{ source('snowflake_sample', 'orders') }}
)

, final as (
    select 
        o_orderkey as order_key
        , o_custkey as customer_key
        , o_orderstatus as order_status
        , o_totalprice as total_price
        , o_orderdate as order_date 
        , o_orderpriority as order_priority
        , o_clerk as clerk 
        , o_shippriority as ship_priority
        , o_comment as comment
 
    from orders
)

select * from final
```

**`STG_CUSTOMERS`**
```
with customers as (
    select * from {{ source('snowflake_sample', 'customer') }}
)

, final as (
    select 
        c_custkey as customer_key 
        , c_name as customer_name
        , c_nationkey as nation_key 
        , c_mktsegment as marketing_segment
        , c_comment as comment 

    from customers 
)

select * from final
```

## Compiling your models

[About dbt compile command](https://docs.getdbt.com/reference/commands/compile)

Before materializing your models, you might want to check the compiled SQL for some of them and test it in your data warehouse. To do this, execute the following command in your terminal:

```
dbt compile
```

This will compile the SQL for all .sql files in the `models` folder. You should be able to find the compiled code in the `target/compiled/my_new_project` folder. You can copy the content of any of the files in this folder and run it as a query in Snowflake to see what the output of running the respective model will be.

In case you want to compile the SQL for only one or a select few of your models, you can use the `--select` flag with the above command. For example:
```
dbt compile --select stg_orders
```

The above command will only compile the SQL for the `STG_ORDERS` models.

## Running your models

[About dbt run command](https://docs.getdbt.com/reference/commands/run)

Once your models have been created, you need to run them in order to materialize them in Snowflake. To do this, you need to use the `dbt run` command. Similarly to the `dbt compile` command, you can optionally use the `--select` flag to specify the model(s) you want to build. Let's execute this command first:

```
dbt run --select stg_orders
```

Now, go to Snowflake and make sure you're using the `DBT_TRAIN_ROLE` role. Expand the objects under your `DBT_TRAIN_DB` database and you should see a new schema corresponding to what you indicated in "Schema" in your credentials page. Expand the schema and you should see `STG_ORDERS`.

Now, you need to run the rest of the models. You could simply run `dbt run` to run all models in the `models` folder, but `STG_ORDERS` has already been materialized, so there is no point in spending resources in order to rebuild it. Instead, let's run everything except for it:

```
dbt run --exclude stg_orders
```

Now, all of your staging models should be materialized as tables in Snowflake. The tables should appear in your data warehouse.

## Referencing other models

[About ref function](https://docs.getdbt.com/reference/dbt-jinja-functions/ref)

Now, it's time to create more complex models that convey meaningful information to the business. You are tasked with creating a `FCT_ORDERS` model with the following columns:

* All columns from `STG_ORDERS`
* `CUSTOMER_NAME`
* `CUSTOMER_MKT_SEGMENT`

**Hint:** To do this, you need to join the 2 tables created earlier together.


## Committing and pushing your changes

Now that you have completed your tasks, it's time to commit and push your changes! 

**Note:** You should be able to see your branch and commits in your repository once you have pushed your changes. However, please **do not merge the branch with the main branch for now**!

Congratulations! You have completed this Lab successfully.
