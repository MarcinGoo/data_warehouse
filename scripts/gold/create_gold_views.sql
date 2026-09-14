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
    p.category AS product_category,
    p.size AS product_size,
    p.color AS product_color,
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
    f.gross_sales_amount,
    f.net_sales_amount,
    f.cancelled_amount,
    f.unit_price
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
    p.current_stock,
    ISNULL(SUM(f.quantity), 0) AS total_units_sold,
    ISNULL(SUM(f.net_sales_amount), 0.00) AS total_revenue,
    ISNULL(SUM(f.cancelled_amount), 0.00) AS total_lost_revenue,
    CASE 
        WHEN p.current_stock = 0 AND ISNULL(SUM(f.quantity), 0) > 0 THEN 'Out of Stock / Fast Mover'
        WHEN p.current_stock = 0 AND ISNULL(SUM(f.quantity), 0) = 0 THEN 'Not Active / Zero Stock'
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
    p.current_stock;
GO

-- 3. Customer Analysis View
CREATE OR ALTER VIEW gold.v_customer_analysis
AS
SELECT
    f.customer_name,
    f.is_b2b,
    g.country,
    g.market_region,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.quantity) AS total_items_purchased,
    SUM(f.net_sales_amount) AS total_revenue,
    AVG(f.net_sales_amount) AS average_order_value,
    MAX(d.full_date) AS last_purchase_date
FROM gold.fact_sales f
LEFT JOIN gold.dim_geography g ON f.geography_key = g.geography_key
LEFT JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY
    f.customer_name,
    f.is_b2b,
    g.country,
    g.market_region;
GO

-- 4. Geography Sales View
CREATE OR ALTER VIEW gold.v_geography_sales
AS
SELECT
    g.market_region,
    g.country,
    g.state_name,
    SUM(f.net_sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_units_sold,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_geography g ON f.geography_key = g.geography_key
GROUP BY
    g.market_region,
    g.country,
    g.state_name;
GO

-- 5. Time Series Sales View
CREATE OR ALTER VIEW gold.v_time_series_sales
AS
SELECT
    d.full_date,
    d.[year] AS sales_year,
    d.quarter_name AS sales_quarter,
    d.month_year,
    d.month_name,
    d.month_num,
    SUM(f.net_sales_amount) AS daily_revenue,
    SUM(f.gross_sales_amount) AS daily_gross_revenue,
    SUM(f.cancelled_amount) AS daily_lost_revenue,
    SUM(f.quantity) AS daily_units_sold,
    COUNT(DISTINCT f.order_id) AS daily_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY
    d.full_date,
    d.[year],
    d.quarter_name,
    d.month_year,
    d.month_name,
    d.month_num;
GO
