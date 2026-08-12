-- =============================================================================
-- Script Name: create_silver_tables.sql
-- Purpose: Create Silver-layer tables with cleaned, analysis-friendly types.
--          Bronze is kept raw; Silver is the business-ready layer.
-- =============================================================================

USE DataWarehouse;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'silver' AND t.name = 'amazon_sales'
)
BEGIN
    CREATE TABLE silver.amazon_sales (
        order_id            NVARCHAR(255) NULL,
        order_date          DATE NULL,
        order_status        NVARCHAR(100) NULL,
        sales_channel       NVARCHAR(50) NULL,
        fulfilment          NVARCHAR(50) NULL,
        ship_service_level  NVARCHAR(50) NULL,
        sku                 NVARCHAR(200) NULL,
        category            NVARCHAR(200) NULL,
        qty                 INT NULL,
        amount              DECIMAL(18,2) NULL,
        b2b                 BIT NULL,
        ship_state          NVARCHAR(100) NULL,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO


IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'silver' AND t.name = 'international_sales'
)
BEGIN
    CREATE TABLE silver.international_sales (
        sales_month         DATE NULL,
        customer            NVARCHAR(200) NULL,
        style               NVARCHAR(200) NULL,
        sku                 NVARCHAR(200) NULL,
        size                NVARCHAR(50) NULL,
        pcs                 INT NULL,
        rate                DECIMAL(18,4) NULL,
        gross_amt           DECIMAL(18,2) NULL,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO


IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'silver' AND t.name = 'product_catalog'
)
BEGIN
    CREATE TABLE silver.product_catalog (
        sku                 NVARCHAR(200) NULL,
        style_id            NVARCHAR(200) NULL,
        catalog             NVARCHAR(200) NULL,
        category            NVARCHAR(200) NULL,
        weight              DECIMAL(18,3) NULL,
        tp                  DECIMAL(18,2) NULL,
        mrp_old             DECIMAL(18,2) NULL,
        final_mrp_old       DECIMAL(18,2) NULL,
        ajio_mrp            DECIMAL(18,2) NULL,
        amazon_mrp          DECIMAL(18,2) NULL,
        amazon_fba_mrp      DECIMAL(18,2) NULL,
        flipkart_mrp        DECIMAL(18,2) NULL,
        limeroad_mrp        DECIMAL(18,2) NULL,
        myntra_mrp          DECIMAL(18,2) NULL,
        paytm_mrp           DECIMAL(18,2) NULL,
        snapdeal_mrp        DECIMAL(18,2) NULL,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO


IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'silver' AND t.name = 'inventory'
)
BEGIN
    CREATE TABLE silver.inventory (
        sku_code            NVARCHAR(200) NULL,
        design_no           NVARCHAR(200) NULL,
        stock               INT NULL,
        category            NVARCHAR(200) NULL,
        size                NVARCHAR(50) NULL,
        color               NVARCHAR(100) NULL,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO