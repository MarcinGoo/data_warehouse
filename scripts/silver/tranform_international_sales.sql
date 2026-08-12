-- =============================================================================
-- Script Name: tranform_international_sales.sql
-- Purpose: Clean and normalize international sales data into the silver layer.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.sp_transform_international_sales
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE silver.international_sales;

    WITH cleaned AS (
        SELECT
            COALESCE(
                TRY_CONVERT(DATE, REPLACE(NULLIF(LTRIM(RTRIM([date])), ''), '-', '/'), 1),
                TRY_PARSE(NULLIF(LTRIM(RTRIM(months)), '') AS DATE USING 'en-US'),
                TRY_CAST(NULLIF(LTRIM(RTRIM(months)), '') AS DATE)
            ) AS sales_month,
            NULLIF(LTRIM(RTRIM(customer)), '') AS customer,
            NULLIF(LTRIM(RTRIM(style)), '') AS style,
            COALESCE(NULLIF(LTRIM(RTRIM(sku)), ''), 'UNKNOWN') AS sku,
            COALESCE(NULLIF(LTRIM(RTRIM(size)), ''), 'UNKNOWN') AS size,
            ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(pcs)), '') AS INT), 0) AS pcs,
            ISNULL(TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(rate)), ''), ',', '') AS DECIMAL(18,4)), 0.0000) AS rate,
            ISNULL(TRY_CAST(REPLACE(REPLACE(NULLIF(LTRIM(RTRIM(gross_amt)), ''), ',', ''), '$', '') AS DECIMAL(18,2)), 0.00) AS gross_amt,
            SYSUTCDATETIME() AS dwh_create_date
        FROM bronze.international_sales
    )
    INSERT INTO silver.international_sales (
        sales_month,
        customer,
        style,
        sku,
        size,
        pcs,
        rate,
        gross_amt,
        dwh_create_date
    )
    SELECT
        sales_month,
        customer,
        style,
        sku,
        size,
        pcs,
        rate,
        gross_amt,
        dwh_create_date
    FROM cleaned
    WHERE customer IS NOT NULL
      AND sales_month IS NOT NULL;
END;
GO