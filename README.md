# Modern Data Warehouse 📊 (Medallion Architecture)

![SQL Server](https://img.shields.io/badge/SQL_Server-2022-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

An end-to-end local Data Warehouse project built using **Microsoft SQL Server** (containerized via Docker) following the **Medallion Architecture** (Bronze, Silver, Gold). The primary goal of this project is to prepare clean, denormalized, and high-performance analytical views ready to be consumed by BI tools such as **Power BI**.

## 🏗️ Architecture Overview

The pipeline strictly adheres to the Medallion data engineering pattern:

1. **🥉 Bronze Layer (Raw Data)**: Data is initially loaded as-is from flat files/sources into raw staging tables.
2. **🥈 Silver Layer (Cleansed & Conformed)**: Data is cleansed, deduplicated, and transformed. Business rules and data quality checks are applied here.
3. **🥇 Gold Layer (Curated & Business-Ready)**: Data is modeled into a classic **Star Schema** (Fact and Dimension tables) optimized for reporting. Furthermore, highly denormalized views are created on top of the Star Schema to directly feed into dashboards.

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Power BI Desktop
- Git / Bash (for running scripts)

### Run the Environment
Spin up the SQL Server container and build the Data Warehouse by running:

```bash
docker-compose up -d
./build.sh
```
This will automatically:
1. Start MS SQL Server 2022.
2. Initialize the `DataWarehouse` database.
3. Sequentially execute all `.sql` scripts for Bronze, Silver, and Gold layers.

---

## 📈 Power BI Integration Guide

This project is explicitly designed to serve as a robust backend for **Power BI**. The Gold layer provides 5 distinct views that are pre-calculated, aggregated, and optimized.

### How to Connect:
1. Open **Power BI Desktop**.
2. Click **Get Data** -> **SQL Server database**.
3. **Server**: `localhost,1433`
4. **Database**: `DataWarehouse`
5. **Data Connectivity mode**: Choose **Import** (recommended for smaller datasets to utilize DAX locally) or **DirectQuery**.
6. **Authentication**: Use Database authentication. 
   - **Username**: `sa`
   - **Password**: `KataPENTA1337` (or the one defined in your `.env`)

### Recommended Dashboards & Views

When loading data into Power BI, select the following views from the `gold` schema:

#### 1. Sales Executive Dashboard (`gold.v_sales_performance`)
**Goal:** High-level overview of sales trends.
- **Visuals:** 
  - Line Chart: Revenue over time (`order_date` vs `sales_amount`).
  - Donut Chart: B2B vs B2C Revenue (`is_b2b`).
  - Matrix: Top 5 performing Product Categories.
- **KPI Cards:** Total Revenue, Total Orders, Average Order Value.

#### 2. Inventory Management (`gold.v_inventory_health`)
**Goal:** Prevent stockouts and identify dead stock.
- **Visuals:**
  - Bar Chart: Count of SKUs by `stock_status` (Healthy, Low, Dead).
  - Scatter Plot: Total Units Sold vs. Current Stock.
- **KPI Cards:** Total Units in Stock, SKUs Out of Stock.

#### 3. Geographic Performance (`gold.v_geography_sales`)
**Goal:** Understand regional market penetration.
- **Visuals:**
  - Map Visual: `country` / `state_name` mapped to bubble size for `total_revenue`.
  - Treemap: Sales by `market_region`.

#### 4. Customer Insights (`gold.v_customer_analysis`)
**Goal:** Analyze customer buying behavior.
- **Visuals:**
  - Column Chart: Top 10 Customers by Revenue.
  - Card: Average Order Value.
  - Table: Last purchase dates to identify churning customers.

#### 5. Time Intelligence (`gold.v_time_series_sales`)
**Goal:** Advanced DAX time-intelligence (YTD, MTD comparisons).
- **Visuals:**
  - Line & Clustered Column Chart: Daily Revenue vs Daily Orders.
  - Slicer: Filter by Year and Quarter.
