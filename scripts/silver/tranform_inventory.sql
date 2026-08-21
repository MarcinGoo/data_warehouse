-- =============================================================================
-- Script Name: tranform_inventory.sql
-- Purpose: Clean and standardize inventory records into the silver layer.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.sp_transform_inventory
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE silver.inventory;

    INSERT INTO silver.inventory (
        sku_code,
        design_no,
        stock,
        category,
        size,
        color,
        dwh_create_date
    )
    SELECT
        NULLIF(LTRIM(RTRIM(sku_code)), '') AS sku_code,
        NULLIF(LTRIM(RTRIM(design_no)), '') AS design_no,
        CAST(ROUND(TRY_CAST(NULLIF(LTRIM(RTRIM(stock)), '') AS DECIMAL(18, 2)), 0) AS INT) AS stock,
        NULLIF(LTRIM(RTRIM(category)), '') AS category,
        NULLIF(LTRIM(RTRIM(size)), '') AS size,
        NULLIF(LTRIM(RTRIM(color)), '') AS color,
        SYSUTCDATETIME() AS dwh_create_date
    FROM bronze.inventory
    WHERE NULLIF(LTRIM(RTRIM(sku_code)), '') IS NOT NULL;
END;
GO
