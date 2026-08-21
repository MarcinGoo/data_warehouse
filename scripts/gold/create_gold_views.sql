-- =============================================================================
-- Script Name: create_gold_views.sql
-- Purpose: Create reporting-ready views on top of the Star Schema for Power BI.
-- =============================================================================

USE DataWarehouse;
GO

-- 1. Sales Performance View (Flat denormalized view for quick Power BI ingestion)
CREATE OR ALTER VIEW gold.v_sales_performance
AS
SELECT
    f.sales_key,
    f.order_id,
    f.sales_source,
    f.customer_name,
    f.is_b2b,
    
    -- Date Attributes
    d.full_date AS order_date,
    d.[year] AS order_year,
    d.quarter_name AS order_quarter,
    d.month_name AS order_month,
    d.month_year AS order_month_year,
    d.day_of_week_name AS order_day_of_week,
    d.is_weekend,
    
    -- Product Attributes
    p.sku,
    p.style_id,
    p.catalog_name,
    p.category AS product_category,
    p.size AS product_size,
    p.color AS product_color,
    p.unit_cost_tp,
    p.mrp_amazon,
    p.current_stock,
    
    -- Geography Attributes
    g.state_name AS ship_state,
    g.country AS ship_country,
    g.market_region,
    
    -- Channel Attributes
    c.sales_channel,
    c.fulfilment_type,
    c.ship_service_level,
    c.order_status,
    
    -- Financial Measures
    f.quantity,
    f.sales_amount,
    f.unit_price,
    f.unit_cost,
    f.total_cost,
    f.gross_profit,
    CASE 
        WHEN f.sales_amount > 0 THEN CAST((f.gross_profit / f.sales_amount) * 100.0 AS DECIMAL(5,2))
        ELSE 0.00
    END AS gross_margin_pct
FROM gold.fact_sales f
LEFT JOIN gold.dim_date d ON f.date_key = d.date_key
LEFT JOIN gold.dim_product p ON f.product_key = p.product_key
LEFT JOIN gold.dim_geography g ON f.geography_key = g.geography_key
LEFT JOIN gold.dim_order_channel c ON f.channel_key = c.channel_key;
GO

-- 2. Inventory Health & Turnover View
CREATE OR ALTER VIEW gold.v_inventory_health
AS
SELECT
    p.product_key,
    p.sku,
    p.category,
    p.color,
    p.size,
    p.catalog_name,
    p.current_stock,
    ISNULL(SUM(f.quantity), 0) AS total_units_sold,
    ISNULL(SUM(f.sales_amount), 0.00) AS total_revenue,
    ISNULL(SUM(f.gross_profit), 0.00) AS total_profit,
    CASE 
        WHEN p.current_stock = 0 AND ISNULL(SUM(f.quantity), 0) > 0 THEN 'Out of Stock / Fast Mover'
        WHEN p.current_stock > 0 AND ISNULL(SUM(f.quantity), 0) = 0 THEN 'Dead Stock'
        WHEN p.current_stock < 10 THEN 'Low Stock'
        ELSE 'Healthy Stock'
    END AS stock_status
FROM gold.dim_product p
LEFT JOIN gold.fact_sales f ON p.product_key = f.product_key
WHERE p.product_key <> -1
GROUP BY
    p.product_key,
    p.sku,
    p.category,
    p.color,
    p.size,
    p.catalog_name,
    p.current_stock;
GO
