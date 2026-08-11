-- =============================================================================
-- Script Name: load_bronze.sql
-- Purpose: Reload bronze tables directly from source CSVs.
--          Wrapped in a stored procedure with TRY/CATCH error handling
--          and load-duration/row-count logging via PRINT.
-- =============================================================================
USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @bronze_start_time DATETIME, @bronze_end_time DATETIME;
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @row_count INT;

    SET @bronze_start_time = GETDATE();

    BEGIN TRY

        PRINT 'LOADING BRONZE LAYER';

        -- Clear bronze tables before loading
        TRUNCATE TABLE bronze.amazon_sales;
        TRUNCATE TABLE bronze.international_sales;
        TRUNCATE TABLE bronze.product_catalog;
        TRUNCATE TABLE bronze.inventory;

        SET @start_time = GETDATE();
        -- Load Amazon Sales
        BULK INSERT bronze.amazon_sales
        FROM '/datasets/Amazon Sale Report.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @row_count = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Load duration of "Amazon Sales" table: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> Rows loaded: ' + CAST(@row_count AS NVARCHAR);

        SET @start_time = GETDATE();
        -- Load International Sales
        BULK INSERT bronze.international_sales
        FROM '/datasets/International sale Report.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @row_count = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Load duration of "International Sales" table: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> Rows loaded: ' + CAST(@row_count AS NVARCHAR);

        SET @start_time = GETDATE();
        -- Load Product Catalog
        BULK INSERT bronze.product_catalog
        FROM '/datasets/May-2022.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @row_count = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Load duration of "Product Catalog" table: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> Rows loaded: ' + CAST(@row_count AS NVARCHAR);

        SET @start_time = GETDATE();
        -- Load Inventory
        BULK INSERT bronze.inventory
        FROM '/datasets/Sale Report.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            TABLOCK
        );
        SET @row_count = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Load duration of "Inventory" table: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> Rows loaded: ' + CAST(@row_count AS NVARCHAR);

        SET @bronze_end_time = GETDATE();
        PRINT 'LOADING BRONZE LAYER COMPLETED';
        PRINT '>> Total duration loading bronze layer: ' + CAST(DATEDIFF(second,@bronze_start_time,@bronze_end_time) AS NVARCHAR) + ' seconds';

    END TRY
    BEGIN CATCH
        PRINT '====================================';
        PRINT 'ERROR LOADING BRONZE LAYER';
        PRINT '====================================';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT '====================================';
    END CATCH
END
GO
