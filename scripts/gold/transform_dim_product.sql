-- =============================================================================
-- Script Name: transform_dim_product.sql
-- Purpose: Build unified Product Dimension from product catalog and inventory.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE gold.sp_transform_dim_product
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE gold.dim_product;

    -- Insert Default UNKNOWN Member
    INSERT INTO gold.dim_product (
        product_key, sku, style_id, category,
        size, color, current_stock
    )
    VALUES (
        -1, 'UNKNOWN', 'UNKNOWN', 'Unknown', 'Unknown', 'Unknown', 0
    );

    WITH AllSku AS (SELECT DISTINCT sku_code AS sku FROM silver.inventory WHERE sku_code IS NOT NULL
        UNION
        SELECT DISTINCT sku FROM silver.amazon_sales WHERE sku IS NOT NULL
        UNION
        SELECT DISTINCT sku FROM silver.international_sales WHERE sku IS NOT NULL
    ),
    EnrichedProduct AS (
        SELECT
            a.sku,
            COALESCE(i.design_no, intl.style, 'UNKNOWN') AS style_id,
            COALESCE(i.category, amz.category, 'Unknown') AS category,
            COALESCE(i.size, intl.size, 'Unknown') AS size,
            COALESCE(i.color, 'Unknown') AS color,
            ISNULL(i.stock, 0) AS current_stock
        FROM AllSku a
        LEFT JOIN (
            SELECT 
                sku_code,
                MAX(design_no) AS design_no,
                MAX(category) AS category,
                MAX(size) AS size,
                MAX(color) AS color,
                SUM(stock) AS stock
            FROM silver.inventory
            GROUP BY sku_code
        ) i ON a.sku = i.sku_code
        LEFT JOIN (
            SELECT
                sku,
                MAX(UPPER(category)) AS category
            FROM silver.amazon_sales
            WHERE category IS NOT NULL
            GROUP BY sku
        ) amz ON a.sku = amz.sku
        LEFT JOIN (
            SELECT
                sku,
                MAX(UPPER(style)) AS style,
                MAX(UPPER(size)) AS size
            FROM silver.international_sales
            GROUP BY sku
        ) intl ON a.sku = intl.sku
        WHERE a.sku <> 'UNKNOWN'
    )
    INSERT INTO gold.dim_product (
        product_key,
        sku,
        style_id, category,
        size, color, current_stock
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY sku) AS product_key,
        sku,
        style_id, category,
        size, color, current_stock
    FROM EnrichedProduct;
END;
GO
