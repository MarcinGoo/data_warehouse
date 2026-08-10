-- =============================================================================
-- Script Name: 03_load_bronze.sql
-- Purpose: Reload bronze tables directly from source CSVs.
-- =============================================================================

USE DataWarehouse;
GO

-- Clear bronze tables before loading
TRUNCATE TABLE bronze.amazon_sales;
TRUNCATE TABLE bronze.international_sales;
TRUNCATE TABLE bronze.product_catalog;
TRUNCATE TABLE bronze.inventory;
GO

-- Load Amazon Sales
BULK INSERT bronze.amazon_sales
FROM 'D:\data_warehouse\datasets\Amazon Sale Report.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- Load International Sales
BULK INSERT bronze.international_sales
FROM 'D:\data_warehouse\datasets\International sale Report.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- Load Product Catalog
BULK INSERT bronze.product_catalog
FROM 'D:\data_warehouse\datasets\May-2022.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- Load Inventory
BULK INSERT bronze.inventory
FROM 'D:\data_warehouse\datasets\Sale Report.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO
