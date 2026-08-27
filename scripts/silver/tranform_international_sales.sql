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

    WITH aligned AS (
        SELECT 
            -- Check if the columns are shifted (date column contains string, months contains date)
            CASE WHEN ISDATE(REPLACE([date], '-', '/')) = 0 AND ISDATE(REPLACE([months], '-', '/')) = 1 THEN [months] ELSE [date] END AS real_date,
            CASE WHEN ISDATE(REPLACE([date], '-', '/')) = 0 AND ISDATE(REPLACE([months], '-', '/')) = 1 THEN [customer] ELSE [months] END AS real_months,
            CASE WHEN ISDATE(REPLACE([date], '-', '/')) = 0 AND ISDATE(REPLACE([months], '-', '/')) = 1 THEN [date] ELSE [customer] END AS real_customer,
            [style] AS real_style,
            [sku] AS real_sku,
            CASE WHEN ISDATE(REPLACE([date], '-', '/')) = 0 AND ISDATE(REPLACE([months], '-', '/')) = 1 THEN 'UNKNOWN' ELSE [size] END AS real_size,
            CASE WHEN ISDATE(REPLACE([date], '-', '/')) = 0 AND ISDATE(REPLACE([months], '-', '/')) = 1 THEN [size] ELSE [pcs] END AS real_pcs,
            CASE WHEN ISDATE(REPLACE([date], '-', '/')) = 0 AND ISDATE(REPLACE([months], '-', '/')) = 1 THEN [pcs] ELSE [rate] END AS real_rate,
            CASE WHEN ISDATE(REPLACE([date], '-', '/')) = 0 AND ISDATE(REPLACE([months], '-', '/')) = 1 THEN [rate] ELSE [gross_amt] END AS real_gross_amt
        FROM bronze.international_sales
        WHERE customer <> 'Months' AND [date] <> 'DATE' -- filter out headers
    ),
    cleaned AS (
        SELECT
            COALESCE(
                TRY_CONVERT(DATE, REPLACE(NULLIF(LTRIM(RTRIM(real_date)), ''), '-', '/'), 1),
                TRY_PARSE(NULLIF(LTRIM(RTRIM(real_months)), '') AS DATE USING 'en-US'),
                TRY_CAST(NULLIF(LTRIM(RTRIM(real_months)), '') AS DATE)
            ) AS sales_month,
            NULLIF(LTRIM(RTRIM(real_customer)), '') AS customer,
            NULLIF(LTRIM(RTRIM(real_style)), '') AS style,
            COALESCE(NULLIF(LTRIM(RTRIM(real_sku)), ''), 'UNKNOWN') AS sku,
            COALESCE(NULLIF(LTRIM(RTRIM(real_size)), ''), 'UNKNOWN') AS size,
            ISNULL(TRY_CAST(TRY_CAST(NULLIF(LTRIM(RTRIM(real_pcs)), '') AS DECIMAL(18,2)) AS INT), 0) AS pcs,
            ISNULL(TRY_CAST(REPLACE(NULLIF(LTRIM(RTRIM(real_rate)), ''), ',', '') AS DECIMAL(18,4)), 0.0000) AS rate,
            ISNULL(TRY_CAST(REPLACE(REPLACE(NULLIF(LTRIM(RTRIM(real_gross_amt)), ''), ',', ''), '$', '') AS DECIMAL(18,2)), 0.00) AS gross_amt,
            SYSUTCDATETIME() AS dwh_create_date
        FROM aligned
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
