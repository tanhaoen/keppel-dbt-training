# Lesson 5 - Data Loading and Dynamic Data Masking Snowflake 

In this lab, you will try different methods of loading data into a table.

**Note:** Each section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.

## Exercise 1: Load a CSV file from an S3 bucket using SQL
1. Using SQL, create a new table named `VEGETABLES_HEIGHT_<YOUR NAME>` into the `DBT_TRAIN_JAFFLE_SHOP` schema. The table should have 4 columns: 

* `PLANT_NAME`
* `UNIT_OF_MEASURE`
* `LOW_END_OF_RANGE`
* `HIGH_END_OF_RANGE`. 

Initially, create all columns as `VARCHAR`: 

```
CREATE TABLE VEGETABLES_HEIGHT_<YOUR NAME> (
    PLANT_NAME VARCHAR,
    UNIT_OF_MEASURE VARCHAR,
    LOW_END_OF_RANGE VARCHAR,
    HIGH_END_OF_RANGE VARCHAR
);
```

2. Create a new CSV file format named `CSV_VEGETABLES_<YOUR NAME>`. 
```
CREATE FILE FORMAT CSV_VEGETABLES_<YOUR NAME>
    type = CSV 
    SKIP_HEADER = 1;
```

3. Create a stage named `S3_UNI_LAB_STAGE_<YOUR NAME>` using the following URL to an S3 bucket `s3://uni-lab-files/`:
```
CREATE STAGE S3_UNI_LAB_STAGE_<YOUR NAME>
  URL = 's3://uni-lab-files/'
  FILE_FORMAT = CSV_VEGETABLES_<YOUR NAME>;
```

4. List the files in the stage using the following command. It should show all data files that have are available in the `s3://uni-lab-files/` S3 bucket. 
```
LIST @S3_UNI_LAB_STAGE_<YOUR NAME>;
```

5. List the filename and first 7 columns in **veg_plant_height.csv** using a `SELECT` statement and the `$` character.
```
select metadata$filename, $1, $2, $3, $4, $5, $6, $7
from @S3_UNI_LAB_STAGE_<YOUR NAME>
where metadata$filename = 'veg_plant_height.csv'
limit 100;
```

5. Load the data into the `VEGETABLES_HEIGHT_<YOUR NAME>` table using the `COPY INTO` command and the file format that you created. 

* [Creating an S3 Stage](https://docs.snowflake.com/en/user-guide/data-load-s3-create-stage)
* [Copying Data from an S3 Stage](https://docs.snowflake.com/en/user-guide/data-load-s3-copy)

Try executing the following command:
```
COPY INTO VEGETABLES_HEIGHT_<YOUR NAME>
FROM @S3_UNI_LAB_STAGE_<YOUR NAME>/veg_plant_height.csv
FILE_FORMAT = CSV_VEGETABLES_<YOUR NAME>;
```

Notice the error message while executing the command. By default, Snowflake aborts the command whenever a loading error is encountered. 

*[Check out the ON_ERROR configuration for the COPY INTO <table> command](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table#copy-options-copyoptions)

Rerun the command above, this time with an additional configuration of `ON_ERROR = CONTINUE`
```
COPY INTO VEGETABLES_HEIGHT_JY
FROM @S3_UNI_LAB_STAGE_JY/veg_plant_height.csv
FILE_FORMAT = CSV_VEGETABLES_JY
ON_ERROR = CONTINUE;
```

6. Once the `COPY INTO` command has successfully completed, query the `VEGETABLES_HEIGHT_<YOUR NAME>` table to view the data that has been loaded:
```
select * from VEGETABLES_HEIGHT_<YOUR NAME>;
```

7. **OPTIONAL:** The error message below was produced during loading in Step 5, which is caused by having different number of columns per row in **veg_plant_height.csv**.  
```
Field delimiter ',' found while expecting record delimiter '\n'
```

It is important to understand errors produced during loading before setting configurations. In the example above, a better workaround would be to adjust configuration for the file format created in Step 2:
```
CREATE FILE FORMAT CSV_VEGETABLES_<YOUR NAME>
    type = CSV 
    SKIP_HEADER = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

```
Try recreating the `VEGETABLES_HEIGHT_<YOUR NAME>` table and loading the data without the `ON_ERROR` configuration in the `COPY INTO` command this time:
```
DROP TABLE VEGETABLES_HEIGHT_<YOUR NAME>;

CREATE TABLE VEGETABLES_HEIGHT_<YOUR NAME> (
    PLANT_NAME VARCHAR,
    UNIT_OF_MEASURE VARCHAR,
    LOW_END_OF_RANGE VARCHAR,
    HIGH_END_OF_RANGE VARCHAR
);

COPY INTO VEGETABLES_HEIGHT_<YOUR NAME>
FROM @S3_UNI_LAB_STAGE_JY/veg_plant_height.csv
FILE_FORMAT = CSV_VEGETABLES_<YOUR NAME>;
```

You should see that all 41 rows have been loaded with no errors.

## Exercise 2: Create an External Table with data in a S3 bucket
1. Create an external table named `S3_UNI_LAB_TABLE_<YOUR_NAME>` from the external stage and file format you have created in the earlier exercise

* [CREATE EXTERNAL TABLE](https://docs.snowflake.com/en/sql-reference/sql/create-external-table)

```
CREATE OR REPLACE EXTERNAL TABLE S3_UNI_LAB_TABLE_<YOUR_NAME> WITH 
    LOCATION=@S3_UNI_LAB_STAGE_<YOUR_NAME>
    REFRESH_ON_CREATE = TRUE
    FILE_FORMAT = (FORMAT_NAME = CSV_VEGETABLES_<YOUR_NAME>);
```

2. Run this query on the external table. What do you see?
```
select distinct metadata$filename from S3_UNI_LAB_TABLE_<YOUR_NAME>;
```

The external table contains 1 row for every record per data file in the `S3_UNI_LAB_STAGE_<YOUR_NAME>` stage. To filter for only records in **veg_plant_height.csv**, add a WHERE condition on the `metadata$filename` column:
```
select *
from S3_UNI_LAB_TABLE_<YOUR NAME>
where metadata$filename = 'veg_plant_height.csv';
```
**Note:** The S3 bucket used for this lab does not similar data files organised into subdirectories. In practice, you should organise your data files into subdirectories in your storage location, and create a stage for each of them (e.g. logs for A, logs for B). In this way, you can create separate stages, and therefore separate External Tables for all data files in each subdirectory.

## Exercise 3: Create and apply masking policies
1. Using the `MASKING_ADMIN` role, create a masking policy with the following requirements:
    - It should be named `NAME_MASK_<YOUR NAME>` for the `FIRST_NAME` column in the `RAW_CUSTOMERS` table. 
    - Only the `DBT_TRAIN_ANALYST` role should be able to see the original data in the `FIRST_NAME` column.
    - Any other roles should see the `*************` value in the `FIRST_NAME` column.

2. Apply the masking policy to the `SSN` column.

3. Using the `DBT_TRAIN_ANALYST` role, query the `USERS_INFO` table. What do you see in the `SSN` column?

4. Using the `DBT_TRAIN_READER` role, query the `USERS_INFO` table. What do you see in the `SSN` column?

