USE DataWarehouse;
GO

-- 1. Podgląd widoku sprzedaży i rentowności:
SELECT TOP 1000 * FROM gold.v_sales_performance;

-- 2. Podgląd widoku rotacji i zdrowia magazynu:
SELECT TOP 10 * FROM gold.v_inventory_health;


SELECT COUNT(*)
FROM bronze.inventory
WHERE category is NULL

SELECT COUNT(*)
FROM gold.dim_product
WHERE category = 'Unknown'

SELECT category, COUNT(*)
FROM bronze.amazon_sales
GROUP BY category
ORDER BY COUNT(*) DESC