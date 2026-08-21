-- =============================================================================
-- Script Name: transform_dim_geography.sql
-- Purpose: Populate Geography Dimension for regional/state sales breakdown.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE gold.sp_transform_dim_geography
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE gold.dim_geography;

    -- Insert Default UNKNOWN Member
    INSERT INTO gold.dim_geography (geography_key, state_name, country, market_region)
    VALUES (-1, 'UNKNOWN', 'Unknown', 'Unknown');

    WITH UniqueStates AS (
        SELECT DISTINCT 
            ship_state AS state_name,
            'India' AS country,
            'Domestic' AS market_region
        FROM silver.amazon_sales
        WHERE ship_state IS NOT NULL
        UNION
        SELECT 
            'Export Market' AS state_name,
            'International' AS country,
            'International' AS market_region
    )
    INSERT INTO gold.dim_geography (
        geography_key,
        state_name,
        country,
        market_region
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY country, state_name) AS geography_key,
        state_name,
        country,
        market_region
    FROM UniqueStates;
END;
GO
