-- =============================================================================
-- Script Name: transform_dim_date.sql
-- Purpose: Populate Date Dimension (Calendar) for time intelligence.
-- =============================================================================

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE gold.sp_transform_dim_date
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE gold.dim_date;

    -- Insert Default UNKNOWN Member
    INSERT INTO gold.dim_date (
        date_key, full_date, [year], [quarter], quarter_name,
        month_num, month_name, month_year, day_of_month,
        day_of_week_num, day_of_week_name, is_weekend
    )
    VALUES (
        -1, NULL, 1900, 1, 'Q1', 1, 'Unknown', 'Unknown', 1, 1, 'Unknown', 0
    );

    -- Generate dates from 2021-01-01 to 2024-12-31
    DECLARE @StartDate DATE = '2021-01-01';
    DECLARE @EndDate DATE = '2024-12-31';

    WITH DateSequence AS (
        SELECT @StartDate AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateSequence
        WHERE DateValue < @EndDate
    )
    INSERT INTO gold.dim_date (
        date_key,
        full_date,
        [year],
        [quarter],
        quarter_name,
        month_num,
        month_name,
        month_year,
        day_of_month,
        day_of_week_num,
        day_of_week_name,
        is_weekend
    )
    SELECT
        CAST(FORMAT(DateValue, 'yyyyMMdd') AS INT) AS date_key,
        DateValue AS full_date,
        YEAR(DateValue) AS [year],
        DATEPART(QUARTER, DateValue) AS [quarter],
        'Q' + CAST(DATEPART(QUARTER, DateValue) AS VARCHAR(1)) AS quarter_name,
        MONTH(DateValue) AS month_num,
        DATENAME(MONTH, DateValue) AS month_name,
        FORMAT(DateValue, 'MMM yyyy') AS month_year,
        DAY(DateValue) AS day_of_month,
        DATEPART(WEEKDAY, DateValue) AS day_of_week_num,
        DATENAME(WEEKDAY, DateValue) AS day_of_week_name,
        CASE WHEN DATEPART(WEEKDAY, DateValue) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
    FROM DateSequence
    OPTION (MAXRECURSION 2000);
END;
GO
