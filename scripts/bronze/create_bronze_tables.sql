-- =============================================================================
-- Script Name: create_bronze_tables.sql
-- Purpose: Create raw ingestion tables in the 'bronze' schema.
-- =============================================================================

USE DataWarehouse;
GO

-- 1. Table for source file: Amazon Sale Report.csv
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'bronze' AND t.name = 'amazon_sales')
BEGIN
    CREATE TABLE bronze.amazon_sales (
        [index]                  VARCHAR(MAX),
        order_id                 VARCHAR(MAX),
        date                     VARCHAR(MAX),
        status                   VARCHAR(MAX),
        fulfilment               VARCHAR(MAX),
        sales_channel            VARCHAR(MAX),
        ship_service_level       VARCHAR(MAX),
        style                    VARCHAR(MAX),
        sku                      VARCHAR(MAX),
        category                 VARCHAR(MAX),
        size                     VARCHAR(MAX),
        asin                     VARCHAR(MAX),
        courier_status           VARCHAR(MAX),
        qty                      VARCHAR(MAX),
        currency                 VARCHAR(MAX),
        amount                   VARCHAR(MAX),
        ship_city                VARCHAR(MAX),
        ship_state               VARCHAR(MAX),
        ship_postal_code         VARCHAR(MAX),
        ship_country             VARCHAR(MAX),
        promotion_ids            VARCHAR(MAX),
        b2b                      VARCHAR(MAX),
        fulfilled_by             VARCHAR(MAX),
        unnamed_22               VARCHAR(MAX)
    );
END;
GO

-- 2. Table for source file: International sale Report.csv
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'bronze' AND t.name = 'international_sales')
BEGIN
    CREATE TABLE bronze.international_sales (
        [index]                  VARCHAR(MAX),
        date                     VARCHAR(MAX),
        months                   VARCHAR(MAX),
        customer                 VARCHAR(MAX),
        style                    VARCHAR(MAX),
        sku                      VARCHAR(MAX),
        size                     VARCHAR(MAX),
        pcs                      VARCHAR(MAX),
        rate                     VARCHAR(MAX),
        gross_amt                VARCHAR(MAX)
    );
END;
GO

-- 3. Table for source file: May-2022.csv
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'bronze' AND t.name = 'product_catalog')
BEGIN
    CREATE TABLE bronze.product_catalog (
        [index]                  VARCHAR(MAX),
        sku                      VARCHAR(MAX),
        style_id                 VARCHAR(MAX),
        catalog                  VARCHAR(MAX),
        category                 VARCHAR(MAX),
        weight                   VARCHAR(MAX),
        tp                       VARCHAR(MAX),
        mrp_old                  VARCHAR(MAX),
        final_mrp_old            VARCHAR(MAX),
        ajio_mrp                 VARCHAR(MAX),
        amazon_mrp               VARCHAR(MAX),
        amazon_fba_mrp           VARCHAR(MAX),
        flipkart_mrp             VARCHAR(MAX),
        limeroad_mrp             VARCHAR(MAX),
        myntra_mrp               VARCHAR(MAX),
        paytm_mrp                VARCHAR(MAX),
        snapdeal_mrp             VARCHAR(MAX)
    );
END;
GO

-- 4. Table for source file: Sale Report.csv
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE s.name = 'bronze' AND t.name = 'inventory')
BEGIN
    CREATE TABLE bronze.inventory (
        [index]                  VARCHAR(MAX),
        sku_code                 VARCHAR(MAX),
        design_no                VARCHAR(MAX),
        stock                    VARCHAR(MAX),
        category                 VARCHAR(MAX),
        size                     VARCHAR(MAX),
        color                    VARCHAR(MAX)
    );
END;
GO
