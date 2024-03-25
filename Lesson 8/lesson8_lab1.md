# Lesson 8 - Lab1

In this lab, you will be adding a sematic model named `orders` and querying its metrics.

- [Lesson 8 - Lab1](#lesson-8---lab1)
  - [Step 1 - Add the semantic model](#step-1---add-the-semantic-model)
  - [Step 2 - Add the metrics](#step-2---add-the-metrics)
  - [Step 3 - Configure Sematic Layer in dbt Cloud](#step-3---configure-sematic-layer-in-dbt-cloud)
  - [Step 4 - Querying the Metrics](#step-4---querying-the-metrics)

## Step 1 - Add the semantic model

1. Create new directory `semantics` inside `models` dir
2. Create new file `semantics/sem_orders.yml`
     - 2.1. Add SM node for `orders` which is based on `fct_orders` model

         ```yml
         semantic_models:
           - name: orders
             description: Order fact table. This table is at the order grain with one row per order
             model: ???
         ```

     - 2.2. Add Primary Entity using `order_id`

         ```yml
         semantic_models:
           - name: orders
             ...

             entities:
               - name: order
                 type: primary
                 expr: ???
         ```

     - 2.3. Add Foreign Entity using `customer_id`

         ```yml
         semantic_models:
           - name: orders
             ...

             entities:
               - name: customer
                 type: ???
                 expr: ???
         ```

     - 2.4. Add a dimesion named `ds` based on `order_date` column

         ```yml
         semantic_models:
           - name: orders
             ...

             dimensions:
               - name: ???
                 expr: ???
                 type: ???
                 type_params:
                   time_granularity: day
         ```

     - 2.5. Add a dimesion named `status` based on `order_status` column

         ```yml
         semantic_models:
           - name: orders
             ...

             dimensions:
               - name: ???
                 expr: ???
                 type: ???
         ```

     - 2.6. Add the measures for order count, total order amount and cost, customer with orders count - create metrics right away

         ```yml
         semantic_models:
           - name: orders
             ...

             measures:
              - name: order_count
                description: Count of orders
                expr: ???
                agg: ???
              - name: total_amount
                description: The total order amount
                expr: ???
                agg: ???
              - name: total_cost
                description: The total order amount
                expr: ???
                agg: ???
              - name: customers_with_orders
                description: Distinct count of customers placing orders
                agg: ???
                expr: ???
         ```

     - 2.7. Create metrics in measures' definitions with `create_metric`

## Step 2 - Add the metrics

1. Create new file `semantics/met_orders.yml`
2. Create simple metric `order_count` from the same name measure

    ```yml
    metrics:
      - name: ???
        description: The number of orders
        type: simple
        label: "# Orders"
        type_params:
          measure:
            name: ???
    ```

3. Create ratio metric `order_rate` = `order_count / total_amount`

    ```yml
    metrics:
      - name: ???
        description: Count vs Total Amount
        type: ratio
        label: Order Rate
        type_params:
          numerator: ???
          denominator: ???
    ```

    Add another ratio metric `returned_rate` with filter `filter: "{{ Dimension('order__status' )}} = 'returned'"` defined in `order_count` metric

4. Create derived metric `order_gross_profit` = `total_amount - total_cost`

    ```yml
    metrics:
      - name: ???
        description: Gross profit from each order
        type: derived
        label: Order Gross Profit
        type_params:
          expr: revenue - cost
          metrics:
            - name: ???
              alias: revenue
            - name: ???
              alias: cost
    ```

5. Create cumulative metric `customer_rolling_7` = `Active customers count weekly`

    ```yml
    metrics:
      - name: ???
        type: cumulative
        label: Weekly Active Customers
        type_params:
          measure:
            name: ???
          window: ???
    ```

## Step 3 - Configure Sematic Layer in dbt Cloud

1. Set up a job with `dbt build` command (or just `dbt build --select dim_customers+ fct_orders+`)
2. Run it successfully at least once. **Question**: What changes do you see from the dbt logs?
3. Go to _Account Setting / Projects_, searches for your project and select it
    - In the _Project Details_ dialog, click _Configure Semantic Layer_
      - Enter the SL credentials (aka Snowflake creds which can `select` the mart tables)
      - Select _Environment_ which you successfuly built the job in (2)
    - _Save_ it
    - ℹ️ We will need to revisit for `Host` and `Environment ID`
  
4. Stil in the _Project Details_ dialog, click _Generate Service Token_:
    - Token name: `whatever you want` e.g. `st_sl_demo_datngnuye`
    - Permissions: `Semnatic Layer Only` and `Metadata Only`
    - _Save_ it
    - Store the ST string somewhere safe

## Step 4 - Querying the Metrics

1. Open new Google Sheets
2. Following the guide [here](https://docs.getdbt.com/docs/use-dbt-semantic-layer/gsheets#installing-the-add-on) to get Sheets Add-ons installed and get ready for querying the Metrics
3. Start querying:
    - Get the total order count for each day in the last 3 weeks, sort by the order date descending
      - Add new metric for Gross Profit
      - Add a filter where the order status is completed
    - Get top 3 weeks that have the most active customers

**That's all. Well Done 🚀!**
