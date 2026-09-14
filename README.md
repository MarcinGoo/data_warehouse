# E-Commerce Data Warehouse & BI Analytics

## 1. Project Overview & Business Problem
The company was operating in a highly fragmented data landscape. Sales data from Amazon (B2C) and international wholesale (B2B) were stored in disjointed formats along with unstructured inventory records. The lack of a centralized Single Source of Truth made it impossible to accurately track overall revenue, monitor fulfillment cancellation rates, or identify bloated inventory (frozen capital).

The goal of this project was to design and build an automated Data Warehouse and Business Intelligence reporting suite that unifies global sales channels, cleanses the data, and provides decision-makers with actionable insights to drive revenue growth, reduce logistics losses, and optimize warehouse space.

## 2. Architecture
The system is built on Microsoft SQL Server and follows the Medallion Architecture (Bronze, Silver, Gold), ensuring a scalable and evolutionary approach to data processing:

- Bronze Layer (Raw Data): Stores data in its original format. Used for bulk loading raw datasets.
- Silver Layer (Cleansed Data): Handles data cleansing, standardizing types, handling NULLs, trimming strings, and filtering out invalid records.
- Gold Layer (Business Data / Star Schema): The analytical layer designed specifically for Business Intelligence. It merges completely different business models (Amazon B2C and International B2B) into a single Fact table (fact_sales). It utilizes Surrogate Keys and a Default Unknown Member (-1) to ensure referential integrity. 

## 3. What Was Achieved
- Engineered a full-stack data platform unifying global sales channels and inventory.
- Implemented a robust ETL pipeline leading raw files into optimized analytical structures.
- Created a unified Star Schema with one central fact table and multiple dimension tables (Date, Product, Geography, Order Channel).
- Built denormalized SQL views (e.g., v_inventory_health, v_sales_performance) that push complex business logic upstream to the database layer, allowing BI tools to operate efficiently.

## 4. Key Logic & Business Conclusions
By deploying this platform, the business can now draw immediate conclusions and take action based on the following implemented logic:

- Inventory Optimization: Created logic to identify frozen capital by categorizing products into "Dead Stock" (stock > 0 but no sales), "Out of Stock / Fast Mover" (lost opportunity), and "Low Stock". 
- Logistics Accountability: Explicitly separated net revenue from lost revenue (due to cancellations/returns) in the Fact table. This allows operations to pinpoint exactly which product categories or regions suffer the highest return rates.
- Strategic Omnichannel View: Executives can compare B2B (Wholesale) and B2C (Amazon) margins and sales volumes side-by-side in a unified data model.

## 5. Power BI Dashboards
The final product of this data pipeline is a set of interactive Power BI dashboards that consume the Gold layer views. By pushing complex business logic upstream to the SQL database, the BI layer remains lightweight and highly performant. 

### Executive Summary
![Executive Summary Dashboard](images/executive_summary.png)

Provides a high-level overview of business growth and revenue performance. Key features include:
- **Core KPIs**: Tracking Total Revenue, Average Order Value (AOV), and Total Units Sold.
- **Channel Comparison**: A clear breakdown of B2C (Amazon) versus B2B (International) sales contribution.
- **Geographical & Category Insights**: Identifying top-performing regions via a Treemap and best-selling product categories, empowering leadership with immediate strategic insights.

### Operations & Fulfillment
![Operations Dashboard](images/operations.png)

A deep-dive into logistics, explicitly tracking net revenue versus lost revenue (due to cancellations, returns, and lost in transit items). Key features include:
- **Lost Revenue Tracking**: Monitoring the exact financial impact of cancelled or returned orders over time.
- **Cancellation Analysis**: Pinpointing exactly which product categories suffer the highest cancellation rates.
- **Fulfillment Status**: A detailed breakdown of all order statuses (Pending, Shipped, Returned, Rejected) to identify operational bottlenecks.

### Inventory Health
![Inventory Health Dashboard](images/inventory_health.png)

This dashboard serves as a strategic tool for procurement and marketing teams to optimize warehouse space and unlock frozen capital. Key business features include:
- **Capital Liquidation**: Instantly identifies "Dead Stock" (items physically taking up space with zero historical sales), allowing marketing to launch targeted clearance campaigns.
- **Opportunity Management**: Tracks "Out of Stock" fast-moving items to help procurement prioritize reordering and prevent lost revenue.
- **Accurate Inventory Valuation**: Automatically filters out inactive or phantom products, ensuring that stock metrics and warehouse utilization reports remain highly accurate.
- **Actionable Insights**: Provides a seamless transition from high-level warehouse metrics to granular, SKU-level details, enabling immediate operational decisions without losing sight of overall inventory health.
