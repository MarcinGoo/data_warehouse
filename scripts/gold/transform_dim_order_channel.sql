-- =============================================================================
-- Script Name: transform_dim_order_channel.sql
-- Purpose: Populate Order Channel & Fulfillment Dimension.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE gold.sp_transform_dim_order_channel
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE gold.dim_order_channel;

    -- Insert Default UNKNOWN Member
    INSERT INTO gold.dim_order_channel (
        channel_key, sales_channel, fulfilment_type, ship_service_level, order_status
    )
    VALUES (
        -1, 'Unknown', 'Unknown', 'Unknown', 'Unknown'
    );

    WITH Channels AS (
        SELECT DISTINCT
            COALESCE(sales_channel, 'Amazon.in') AS sales_channel,
            COALESCE(fulfilment, 'Merchant') AS fulfilment_type,
            COALESCE(ship_service_level, 'Standard') AS ship_service_level,
            COALESCE(order_status, 'Unknown') AS order_status
        FROM silver.amazon_sales
        UNION
        SELECT
            'International B2B' AS sales_channel,
            'Direct Export' AS fulfilment_type,
            'International' AS ship_service_level,
            'Completed' AS order_status
    )
    INSERT INTO gold.dim_order_channel (
        channel_key,
        sales_channel,
        fulfilment_type,
        ship_service_level,
        order_status
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY sales_channel, fulfilment_type, order_status) AS channel_key,
        sales_channel,
        fulfilment_type,
        ship_service_level,
        order_status
    FROM Channels;
END;
GO
