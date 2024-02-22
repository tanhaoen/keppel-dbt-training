# Lesson 5 - Data Loading and Dynamic Data Masking Snowflake 

In this lab, you will try different methods of loading data into a table.

**Note:** Each section of this lab is accompanied by a link to documentation (highlighted with blue text) that can help you complete your task. You are encouraged to go through it even if you have been able to complete your assignment without it.

## Load a CSV file from an S3 bucket using SQL
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

4. List the files in the stage using the following command
```
LIST @S3_UNI_LAB_STAGE_<YOUR NAME>;
```

5. List the columns from the vegetables height dataset using a `SELECT` statement and the `$` character.
```
select metadata$filename, $1, $2, $3, $4, $5
from @S3_UNI_LAB_STAGE_<YOUR NAME>
where metadata$filename = 'veg_plant_height.csv'
limit 100;
```

5. Load the data into the `VEGETABLES_HEIGHT_<YOUR NAME>` table using the `COPY INTO` command and the file format that you created. 

* [Creating an S3 Stage](https://docs.snowflake.com/en/user-guide/data-load-s3-create-stage)
* [Copying Data from an S3 Stage](https://docs.snowflake.com/en/user-guide/data-load-s3-copy)

```
COPY INTO VEGETABLES_HEIGHT_<YOUR NAME>
FROM @S3_UNI_LAB_STAGE_<YOUR NAME>/veg_plant_height.csv
FILE_FORMAT = CSV_VEGETABLES_<YOUR NAME>;
```