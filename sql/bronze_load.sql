CREATE DATABASE NovaMart_DW


USE NovaMart_DW

CREATE SCHEMA bronzee;

CREATE SCHEMA silverr;




IF OBJECT_ID ( 'bronzee.dim_customers','U') IS NOT NULL
       DROP TABLE bronzee.dim_customers

CREATE TABLE bronzee.dim_customers (
customer_id int,
customer_name varchar(50),
region varchar(50),
segment varchar(50),
join_date date
)

IF OBJECT_ID ('bronzee.dim_products','U') IS NOT NULL
        DROP TABLE bronzee.dim_products

CREATE TABLE bronzee.dim_products(
product_id int,
product_name varchar(100),
category varchar(50),
cost_price DECIMAL(10,2),
selling_price DECIMAL(10,2),
monthly_target int
)

IF OBJECT_ID ('bronzee.fact_transactions' ,'U') IS NOT NULL
        DROP TABLE bronzee.fact_transactions

CREATE TABLE bronzee.fact_transactions(
    transaction_id INT,
    customer_id INT,
    product_id INT,
    date DATE,
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    total_amount DECIMAL(10,2),
    profit DECIMAL(10,2)
)


CREATE TABLE bronzee.dim_date (
    date DATE,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    week_number INT,
    day_name VARCHAR(20)
);



WITH date_cte AS (
    
    SELECT CAST('2023-01-01' as DATE ) AS DATE
    UNION ALL 
    SELECT DATEADD( DAY, 1, DATE )
    FROM date_cte
    WHERE DATE < '2024-12-31'

)


INSERT INTO bronzee.dim_date
SELECT
    date,
    DAY(date),
    MONTH(date),
    DATENAME(MONTH, date),
    DATEPART(QUARTER, date),
    YEAR(date),
    DATEPART(WEEK, date),
    DATENAME(WEEKDAY, date)
FROM date_cte
OPTION (MAXRECURSION 1000);




CREATE OR ALTER PROCEDURE bronzee.load_tables AS
BEGIN
    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;

    BEGIN TRY

        -- Load Customers
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronzee.dim_customers;
        BULK INSERT bronzee.dim_customers
        FROM 'E:\sql-data-warehouse-project\customers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT ' Customers loaded in: ' + 
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

        -- Load Products
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronzee.dim_products;
        BULK INSERT bronzee.dim_products
        FROM 'E:\sql-data-warehouse-project\products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT ' Products loaded in: ' + 
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

        -- Load Transactions
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronzee.fact_transactions;
        BULK INSERT bronzee.fact_transactions
        FROM 'E:\sql-data-warehouse-project\transactions.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT ' Transactions loaded in: ' + 
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

    END TRY
    BEGIN CATCH
        PRINT ' Error: ' + ERROR_MESSAGE();
        PRINT 'Failed at: ' + ERROR_PROCEDURE();
    END CATCH
END
