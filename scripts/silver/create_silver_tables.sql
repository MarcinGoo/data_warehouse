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