
-- Silver Customers
CREATE TABLE silveer.dim_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    region VARCHAR(50),
    segment VARCHAR(50),
    join_date DATE
);

-- Silver Products
CREATE TABLE silveer.dim_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    monthly_target_units INT,
    profit_margin DECIMAL(10,2)
);

-- Silver Transactions
CREATE TABLE silveer.fact_transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    date DATE,
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(5,2),
    total_amount DECIMAL(10,2),
    profit DECIMAL(10,2),
    profit_margin_pct DECIMAL(10,2)
);



CREATE OR ALTER PROCEDURE silveer.load_tables AS
BEGIN
    DECLARE @start_time DATETIME;
    DECLARE @end_time DATETIME;

    BEGIN TRY

        -- Load Customers
        SET @start_time = GETDATE();
        TRUNCATE TABLE silveer.dim_customers;
        INSERT INTO silveer.dim_customers
        SELECT
            customer_id,
            TRIM(UPPER(LEFT(customer_name, 1)) + 
                 LOWER(SUBSTRING(customer_name, 2, LEN(customer_name)))),
            TRIM(region),
            TRIM(segment),
            join_date
        FROM bronzee.dim_customers
        WHERE customer_name IS NOT NULL
          AND region IS NOT NULL;
        SET @end_time = GETDATE();
        PRINT 'Silver Customers loaded in: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

        -- Load Products
        SET @start_time = GETDATE();
        TRUNCATE TABLE silveer.dim_products;
        INSERT INTO silveer.dim_products
        SELECT
            product_id,
            TRIM(product_name),
            TRIM(category),
            cost_price,
            selling_price,
            monthly_target,
            ROUND((selling_price - cost_price) / selling_price * 100, 2)
            AS profit_margin
        FROM bronzee.dim_products
        WHERE product_name IS NOT NULL
          AND selling_price > 0;
        SET @end_time = GETDATE();
        PRINT 'Silver Products loaded in: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

        -- Load Transactions
        SET @start_time = GETDATE();
        TRUNCATE TABLE silveer.fact_transactions;
        INSERT INTO silveer.fact_transactions
        SELECT
            transaction_id,
            customer_id,
            product_id,
            date,
            quantity,
            unit_price,
            discount,
            total_amount,
            profit,
            ROUND(profit / NULLIF(total_amount, 0) * 100, 2)
            AS profit_margin_pct
        FROM bronzee.fact_transactions
        WHERE total_amount > 0
          AND quantity > 0
          AND date IS NOT NULL;
        SET @end_time = GETDATE();
        PRINT ' Silver Transactions loaded in: ' +
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';

    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
