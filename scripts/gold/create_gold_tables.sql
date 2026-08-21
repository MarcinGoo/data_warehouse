-- =============================================================================
-- Script Name: create_gold_tables.sql
-- Purpose: Create Gold-layer tables (Star Schema) for analytics and reporting.
--          Includes dimension tables and the central sales fact table.
-- =============================================================================

USE DataWarehouse;
GO

-- 1. Dimension: Date (Calendar)
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_date'
)
BEGIN
    CREATE TABLE gold.dim_date (
        date_key            INT NOT NULL PRIMARY KEY,
        full_date           DATE NULL,
        [year]              INT NULL,
        [quarter]           INT NULL,
        quarter_name        VARCHAR(10) NULL,
        month_num           INT NULL,
        month_name          VARCHAR(20) NULL,
        month_year          VARCHAR(20) NULL,
        day_of_month        INT NULL,
        day_of_week_num     INT NULL,
        day_of_week_name    VARCHAR(20) NULL,
        is_weekend          BIT NULL
    );
END;
GO

-- 2. Dimension: Product
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_product'
)
BEGIN
    CREATE TABLE gold.dim_product (
        product_key         INT NOT NULL PRIMARY KEY,
        sku                 NVARCHAR(200) NOT NULL,
        style_id            NVARCHAR(200) NULL,
        catalog_name        NVARCHAR(200) NULL,
        category            NVARCHAR(200) NULL,
        size                NVARCHAR(50) NULL,
        color               NVARCHAR(100) NULL,
        weight              DECIMAL(18,3) NULL,
        unit_cost_tp        DECIMAL(18,2) NULL,
        mrp_amazon          DECIMAL(18,2) NULL,
        current_stock       INT NULL,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

-- 3. Dimension: Geography
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_geography'
)
BEGIN
    CREATE TABLE gold.dim_geography (
        geography_key       INT NOT NULL PRIMARY KEY,
        state_name          NVARCHAR(100) NOT NULL,
        country             NVARCHAR(50) NOT NULL,
        market_region       NVARCHAR(50) NULL,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

-- 4. Dimension: Order Channel & Fulfillment
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'dim_order_channel'
)
BEGIN
    CREATE TABLE gold.dim_order_channel (
        channel_key         INT NOT NULL PRIMARY KEY,
        sales_channel       NVARCHAR(50) NOT NULL,
        fulfilment_type     NVARCHAR(50) NOT NULL,
        ship_service_level  NVARCHAR(50) NOT NULL,
        order_status        NVARCHAR(100) NOT NULL,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

-- 5. Fact Table: Sales
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE s.name = 'gold' AND t.name = 'fact_sales'
)
BEGIN
    CREATE TABLE gold.fact_sales (
        sales_key           BIGINT NOT NULL PRIMARY KEY,
        order_id            NVARCHAR(255) NULL,
        date_key            INT NOT NULL,
        product_key         INT NOT NULL,
        geography_key       INT NOT NULL,
        channel_key         INT NOT NULL,
        sales_source        NVARCHAR(50) NOT NULL,
        customer_name       NVARCHAR(200) NULL,
        quantity            INT NOT NULL,
        sales_amount        DECIMAL(18,2) NOT NULL,
        unit_price          DECIMAL(18,2) NULL,
        unit_cost           DECIMAL(18,2) NULL,
        total_cost          DECIMAL(18,2) NULL,
        gross_profit        DECIMAL(18,2) NULL,
        is_b2b              BIT NOT NULL DEFAULT 0,
        dwh_create_date     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO
