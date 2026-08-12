-- =============================================================================
-- Script Name: tranform_product_catalog.sql
-- Purpose: Clean and normalize product catalog data into the silver layer.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.sp_transform_product_catalog
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE silver.product_catalog;

    INSERT INTO silver.product_catalog (
        sku,
        style_id,
        catalog,
        category,
        weight,
        tp,
        mrp_old,
        final_mrp_old,
        ajio_mrp,
        amazon_mrp,
        amazon_fba_mrp,
        flipkart_mrp,
        limeroad_mrp,
        myntra_mrp,
        paytm_mrp,
        snapdeal_mrp,
        dwh_create_date
    )
    SELECT
        NULLIF(LTRIM(RTRIM(sku)), '') AS sku,
        NULLIF(LTRIM(RTRIM(style_id)), '') AS style_id,
        NULLIF(LTRIM(RTRIM(catalog)), '') AS catalog,
        NULLIF(LTRIM(RTRIM(category)), '') AS category,
        TRY_CAST(NULLIF(LTRIM(RTRIM(weight)), '') AS DECIMAL(18,3)) AS weight,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(tp)), ''), ',', '') AS DECIMAL(18,2)) AS tp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(mrp_old)), ''), ',', '') AS DECIMAL(18,2)) AS mrp_old,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(final_mrp_old)), ''), ',', '') AS DECIMAL(18,2)) AS final_mrp_old,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(ajio_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS ajio_mrp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(amazon_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS amazon_mrp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(amazon_fba_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS amazon_fba_mrp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(flipkart_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS flipkart_mrp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(limeroad_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS limeroad_mrp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(myntra_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS myntra_mrp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(paytm_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS paytm_mrp,
        TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(snapdeal_mrp)), ''), ',', '') AS DECIMAL(18,2)) AS snapdeal_mrp,
        SYSUTCDATETIME() AS dwh_create_date
    FROM bronze.product_catalog
    WHERE NULLIF(LTRIM(RTRIM(sku)), '') IS NOT NULL;
END;
GO
