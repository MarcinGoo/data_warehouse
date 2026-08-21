-- =============================================================================
-- Script Name: transform_fact_sales.sql
-- Purpose: Populate central Sales Fact Table linking all dimensions and
--          calculating key sales, cost, and profitability metrics.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE gold.sp_transform_fact_sales
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE gold.fact_sales;

    WITH DomesticSales AS (
        SELECT
            s.order_id,
            COALESCE(CAST(FORMAT(s.order_date, 'yyyyMMdd') AS INT), -1) AS date_key,
            COALESCE(p.product_key, -1) AS product_key,
            COALESCE(g.geography_key, -1) AS geography_key,
            COALESCE(c.channel_key, -1) AS channel_key,
            'Amazon Retail' AS sales_source,
            'Retail Customer' AS customer_name,
            s.qty AS quantity,
            s.amount AS sales_amount,
            CASE WHEN s.qty > 0 THEN CAST(s.amount / s.qty AS DECIMAL(18,2)) ELSE s.amount END AS unit_price,
            ISNULL(p.unit_cost_tp, 0.00) AS unit_cost,
            CAST(s.qty * ISNULL(p.unit_cost_tp, 0.00) AS DECIMAL(18,2)) AS total_cost,
            CAST(s.amount - (s.qty * ISNULL(p.unit_cost_tp, 0.00)) AS DECIMAL(18,2)) AS gross_profit,
            s.b2b AS is_b2b
        FROM silver.amazon_sales s
        LEFT JOIN gold.dim_product p ON s.sku = p.sku
        LEFT JOIN gold.dim_geography g ON s.ship_state = g.state_name
        LEFT JOIN gold.dim_order_channel c ON 
            COALESCE(s.sales_channel, 'Amazon.in') = c.sales_channel
            AND COALESCE(s.fulfilment, 'Merchant') = c.fulfilment_type
            AND COALESCE(s.ship_service_level, 'Standard') = c.ship_service_level
            AND COALESCE(s.order_status, 'Unknown') = c.order_status
    ),
    ExportSales AS (
        SELECT
            'INT-' + CAST(ROW_NUMBER() OVER (ORDER BY i.sales_month, i.customer, i.sku) AS NVARCHAR(50)) AS order_id,
            COALESCE(CAST(FORMAT(i.sales_month, 'yyyyMMdd') AS INT), -1) AS date_key,
            COALESCE(p.product_key, -1) AS product_key,
            COALESCE(g.geography_key, -1) AS geography_key,
            COALESCE(c.channel_key, -1) AS channel_key,
            'International B2B' AS sales_source,
            COALESCE(i.customer, 'International Buyer') AS customer_name,
            i.pcs AS quantity,
            i.gross_amt AS sales_amount,
            CAST(i.rate AS DECIMAL(18,2)) AS unit_price,
            ISNULL(p.unit_cost_tp, 0.00) AS unit_cost,
            CAST(i.pcs * ISNULL(p.unit_cost_tp, 0.00) AS DECIMAL(18,2)) AS total_cost,
            CAST(i.gross_amt - (i.pcs * ISNULL(p.unit_cost_tp, 0.00)) AS DECIMAL(18,2)) AS gross_profit,
            CAST(1 AS BIT) AS is_b2b
        FROM silver.international_sales i
        LEFT JOIN gold.dim_product p ON i.sku = p.sku
        LEFT JOIN gold.dim_geography g ON g.state_name = 'Export Market'
        LEFT JOIN gold.dim_order_channel c ON c.sales_channel = 'International B2B'
    ),
    CombinedSales AS (
        SELECT * FROM DomesticSales
        UNION ALL
        SELECT * FROM ExportSales
    )
    INSERT INTO gold.fact_sales (
        sales_key,
        order_id,
        date_key,
        product_key,
        geography_key,
        channel_key,
        sales_source,
        customer_name,
        quantity,
        sales_amount,
        unit_price,
        unit_cost,
        total_cost,
        gross_profit,
        is_b2b
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY date_key, order_id) AS sales_key,
        order_id,
        date_key,
        product_key,
        geography_key,
        channel_key,
        sales_source,
        customer_name,
        quantity,
        sales_amount,
        unit_price,
        unit_cost,
        total_cost,
        gross_profit,
        is_b2b
    FROM CombinedSales;
END;
GO
