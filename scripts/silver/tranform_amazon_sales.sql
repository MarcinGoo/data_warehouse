-- =============================================================================
-- Script Name: tranform_amazon_sales.sql
-- Purpose: Clean and deduplicate Amazon sales data into the silver layer.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.sp_transform_amazon_sales
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE silver.amazon_sales;

    WITH dedup AS (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY order_id, sku
                ORDER BY
                    CASE WHEN NULLIF(LTRIM(RTRIM(amount)), '') IS NOT NULL THEN 0 ELSE 1 END,
                    CASE WHEN TRY_CAST(NULLIF(LTRIM(RTRIM(qty)), '') AS INT) > 0 THEN 0 ELSE 1 END,
                    [index]
            ) AS rn
        FROM bronze.amazon_sales
    ),
    cleaned AS (
        SELECT
            NULLIF(LTRIM(RTRIM(order_id)), '') AS order_id,
            TRY_CONVERT(DATE, REPLACE(NULLIF(LTRIM(RTRIM([date])), ''), '-', '/'), 1) AS order_date,
            NULLIF(LTRIM(RTRIM(status)), '') AS order_status,
            NULLIF(LTRIM(RTRIM(sales_channel)), '') AS sales_channel,
            NULLIF(LTRIM(RTRIM(fulfilment)), '') AS fulfilment,
            NULLIF(LTRIM(RTRIM(ship_service_level)), '') AS ship_service_level,
            NULLIF(LTRIM(RTRIM(sku)), '') AS sku,
            NULLIF(LTRIM(RTRIM(category)), '') AS category,
            TRY_CAST(NULLIF(LTRIM(RTRIM(qty)), '') AS INT) AS qty,
            TRY_CAST(REPLACE(REPLACE(NULLIF(LTRIM(RTRIM(amount)), ''), ',', ''), '$', '') AS DECIMAL(18,2)) AS amount,
            CASE 
                WHEN LOWER(NULLIF(LTRIM(RTRIM(b2b)), '')) IN ('true', '1') THEN CAST(1 AS BIT)
                ELSE CAST(0 AS BIT)
            END AS b2b,
            CASE UPPER(NULLIF(LTRIM(RTRIM(ship_state)), ''))
                WHEN 'NEW DELHI' THEN 'DELHI'
                WHEN 'ORISSA' THEN 'ODISHA'
                WHEN 'PONDICHERRY' THEN 'PUDUCHERRY'
                WHEN 'RAJSTHAN' THEN 'RAJASTHAN'
                WHEN 'RAJSHTHAN' THEN 'RAJASTHAN'
                ELSE UPPER(NULLIF(LTRIM(RTRIM(ship_state)), ''))
            END AS ship_state,
            SYSUTCDATETIME() AS dwh_create_date
        FROM dedup
        WHERE rn = 1
    )
    INSERT INTO silver.amazon_sales (
        order_id,
        order_date,
        order_status,
        sales_channel,
        fulfilment,
        ship_service_level,
        sku,
        category,
        qty,
        amount,
        b2b,
        ship_state,
        dwh_create_date
    )
    SELECT 
        order_id,
        order_date,
        order_status,
        sales_channel,
        fulfilment,
        ship_service_level,
        sku,
        category,
        qty,
        amount,
        b2b,
        ship_state,
        dwh_create_date
    FROM cleaned
    WHERE order_id IS NOT NULL
      AND qty > 0
      AND amount > 0;
END;
GO