-- =============================================================================
-- Script Name: run_silver_transformations.sql
-- Purpose: Execute all silver-layer procedures in order.
-- =============================================================================

USE DataWarehouse;
GO

EXEC silver.sp_transform_amazon_sales;
EXEC silver.sp_transform_international_sales;
EXEC silver.sp_transform_inventory;
GO
