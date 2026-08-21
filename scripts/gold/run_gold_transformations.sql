-- =============================================================================
-- Script Name: run_gold_transformations.sql
-- Purpose: Execute all gold-layer dimension and fact procedures in order.
-- =============================================================================

USE DataWarehouse;
GO

PRINT 'Transforming Dimension: Date...';
EXEC gold.sp_transform_dim_date;

PRINT 'Transforming Dimension: Product...';
EXEC gold.sp_transform_dim_product;

PRINT 'Transforming Dimension: Geography...';
EXEC gold.sp_transform_dim_geography;

PRINT 'Transforming Dimension: Order Channel...';
EXEC gold.sp_transform_dim_order_channel;

PRINT 'Transforming Fact: Sales...';
EXEC gold.sp_transform_fact_sales;

PRINT 'Gold layer transformations completed successfully.';
GO
