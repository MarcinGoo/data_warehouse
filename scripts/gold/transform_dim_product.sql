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
        product_key, sku, style_id, catalog_name, category,
        size, color, weight, unit_cost_tp, mrp_amazon, current_stock
    )
    VALUES (
        -1, 'UNKNOWN', 'UNKNOWN', 'Unknown', 'Unknown',
        'Unknown', 'Unknown', 0.000, 0.00, 0.00, 0
    );

    WITH AllSku AS (
        SELECT DISTINCT sku FROM silver.product_catalog WHERE sku IS NOT NULL
        UNION
        SELECT DISTINCT sku_code AS sku FROM silver.inventory WHERE sku_code IS NOT NULL
        UNION
        SELECT DISTINCT sku FROM silver.amazon_sales WHERE sku IS NOT NULL
        UNION
        SELECT DISTINCT sku FROM silver.international_sales WHERE sku IS NOT NULL
    ),
    EnrichedProduct AS (
        SELECT
            a.sku,
            COALESCE(c.style_id, i.design_no, 'UNKNOWN') AS style_id,
            COALESCE(c.catalog, 'Mix') AS catalog_name,
            COALESCE(c.category, i.category, 'Unknown') AS category,
            COALESCE(i.size, 'Unknown') AS size,
            COALESCE(i.color, 'Unknown') AS color,
            ISNULL(c.weight, 0.000) AS weight,
            ISNULL(c.tp, 0.00) AS unit_cost_tp,
            ISNULL(c.amazon_mrp, 0.00) AS mrp_amazon,
            ISNULL(i.stock, 0) AS current_stock
        FROM AllSku a
        LEFT JOIN silver.product_catalog c ON a.sku = c.sku
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
        WHERE a.sku <> 'UNKNOWN'
    )
    INSERT INTO gold.dim_product (
        product_key,
        sku,
        style_id,
        catalog_name,
        category,
        size,
        color,
        weight,
        unit_cost_tp,
        mrp_amazon,
        current_stock
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY sku) AS product_key,
        sku,
        style_id,
        catalog_name,
        category,
        size,
        color,
        weight,
        unit_cost_tp,
        mrp_amazon,
        current_stock
    FROM EnrichedProduct;
END;
GO
