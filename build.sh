#!/bin/bash
set -e

SQLCMD="docker exec -i dw_sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P KataPENTA1337 -C -d master"
SQLCMD_DW="docker exec -i dw_sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P KataPENTA1337 -C -d DataWarehouse"

cd /home/ultron/data_warehouse

echo "Init DB..."
$SQLCMD < scripts/init_database.sql

echo "Bronze..."
$SQLCMD_DW < scripts/bronze/create_bronze_tables.sql
$SQLCMD_DW < scripts/bronze/load_bronze.sql

echo "Silver..."
$SQLCMD_DW < scripts/silver/create_silver_tables.sql
$SQLCMD_DW < scripts/silver/tranform_amazon_sales.sql
$SQLCMD_DW < scripts/silver/tranform_international_sales.sql
$SQLCMD_DW < scripts/silver/tranform_inventory.sql
$SQLCMD_DW < scripts/silver/run_silver_transformations.sql

echo "Gold..."
$SQLCMD_DW < scripts/gold/create_gold_tables.sql
$SQLCMD_DW < scripts/gold/transform_dim_date.sql
$SQLCMD_DW < scripts/gold/transform_dim_product.sql
$SQLCMD_DW < scripts/gold/transform_dim_geography.sql
$SQLCMD_DW < scripts/gold/transform_dim_order_channel.sql
$SQLCMD_DW < scripts/gold/transform_fact_sales.sql
$SQLCMD_DW < scripts/gold/run_gold_transformations.sql
$SQLCMD_DW < scripts/gold/create_gold_views.sql

echo "Build complete."
