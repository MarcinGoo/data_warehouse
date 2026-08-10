-- =============================================================================
-- Script Name: init_database.sql
-- Purpose: Initialize the DataWarehouse database and setup the
--          Medallion Architecture schemas (bronze, silver, gold).
--
-- Note: This script is fully idempotent. It checks for the existence of the
--       database and schemas before creation, making it safe to execute
--       multiple times in automated CI/CD pipelines or deployment environments.
-- =============================================================================

-- 1. Create Database 
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DataWarehouse')
BEGIN
    CREATE DATABASE DataWarehouse;
END;
GO

USE DataWarehouse;
GO

-- 2. Create Medallion Architecture Schemas 

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'bronze')
BEGIN
    EXEC('CREATE SCHEMA bronze;');
END;
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'silver')
BEGIN
    EXEC('CREATE SCHEMA silver;');
END;
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'gold')
BEGIN
    EXEC('CREATE SCHEMA gold;');
END;
GO
