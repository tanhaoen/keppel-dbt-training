# Lesson 8 - Lab2

In this lab, you will be adding the 2nd sematic model named `customers` and querying metrics with Joins

- [Lesson 8 - Lab2](#lesson-8---lab2)
  - [Step 1 - Add the semantic model](#step-1---add-the-semantic-model)
  - [Step 2 - Update the SL](#step-2---update-the-sl)
  - [Step 3 - Querying the Metrics with Joins](#step-3---querying-the-metrics-with-joins)

## Step 1 - Add the semantic model

1. Create new file `semantics/sem_customers.yml`
2. Add SM node for `customers` which is based on `dim_customers` model

    ```yml
      semantic_models:
        - name: customers
          description: Customer attributes
          defaults:
            agg_time_dimension: ds
          model: ???
    ```

3. Add Primary Entity using `customer_id`

    ```yml
    semantic_models:
      - name: customers
        ...

        entities:
          - name: customer
            type: primary
            expr: ???
    ```

4. Add a dimesion named `ds` based on `created_at` column

    ```yml
    semantic_models:
      - name: customers
        ...

        dimensions:
          - name: ???
            expr: ???
            type: ???
            type_params:
              time_granularity: day
    ```

5. Add a dimesion named `name` based on `first_name + last_name` columns

    ```yml
    semantic_models:
      - name: customers
        ...

        dimensions:
          - name: ???
            expr: ???
            type: ???
    ```

6. Add a measure named `customer_coumt` that counts all the existing customers - also create the inline metric

    ```yml
    semantic_models:
      - name: customers
        ...

        measures:
          - name: ???
            description: Count of all customers
            expr: ???
            agg: ???
            create_???
    ```

## Step 2 - Update the SL

- Commit the changes
- Run the job successfully again

## Step 3 - Querying the Metrics with Joins

In the Google Sheet, open the dbt SL Query Builder, and start querying:

- Get top 5 customer names that have the most orders place all time
  - Get the executed query behind the scenes
- Get the total order cost returned by a customer whose name contains "P"
  - Get the executed query behind the scenes

**That's all. Well Done 🚀!**
