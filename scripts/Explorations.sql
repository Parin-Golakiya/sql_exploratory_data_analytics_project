/*
===============================================================================
Database Exploration & Analysis
===============================================================================
Script Purpose:
    This script performs comprehensive exploration and validation across all 
    layers of the Data Warehouse (Bronze, Silver, and Gold). It is designed 
    to inspect structure, metadata, and data quality to ensure that the 
    warehouse is correctly built, populated, and ready for analysis.

Key Exploration Areas:
    1. Database Structure Exploration
        - View list of tables and schemas to verify successful deployment.
        - Inspect column details, data types, and metadata.
        - System Views Used: INFORMATION_SCHEMA.TABLES, INFORMATION_SCHEMA.COLUMNS

    2. Dimension Exploration
        - Validate and explore key dimension tables (e.g., Customer, Product, Date).
        - Identify unique values and standardized categorical data.
        - SQL Functions Used: DISTINCT, ORDER BY

    3. Date Range Exploration
        - Determine temporal boundaries of key datasets.
        - Analyze earliest and latest transaction dates to confirm data continuity.
        - SQL Functions Used: MIN(), MAX(), DATEDIFF()

    4. Measures Exploration (Key Metrics)
        - Compute high-level KPIs and aggregated metrics for quick validation.
        - Identify trends, anomalies, and ensure measure accuracy.
        - SQL Functions Used: COUNT(), SUM(), AVG()
===============================================================================
*/


-- ===============================================================================
-- Database Exploration
-- ===============================================================================

-- Explore All Objects in the Database
select * from INFORMATION_SCHEMA.COLUMNS;

-- Explore All Columns in the Database
select * from INFORMATION_SCHEMA.COLUMNS;

-- For Particular Table
select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'dim_customers';


-- ===============================================================================
-- Dimensions Exploration
-- ===============================================================================

-- Explore All Countries our customers come from
select distinct 
	country 
from gold.dim_customers;

-- Explore All Categories & Subcategories with Product Name "The Major Divisions"
select distinct 
	category,
	subcategory,
	product_name
from gold.dim_products;

-- Explore Unique Combinations of category, subcategory, and product_name.
select distinct 
	category,
	subcategory,
	product_name
from gold.dim_products
order by 1,2,3;


-- ===============================================================================
-- Date Range Exploration 
-- ===============================================================================

-- Find the date of the first and last order
select
	min(order_date) as fist_order_date,
	max(order_date) as last_order_date
from gold.fact_sales;

-- How many years & day of sales are available 
select
	min(order_date) as fist_order_date,
	max(order_date) as last_order_date,
	datediff(year, min(order_date),max(order_date)) as order_range_years,
	datediff(day, min(order_date),max(order_date)) as order_range_days
from gold.fact_sales;

-- Find the youngest and oldest customer.
select
	min(birthdate) as oldest_birthdate,
	max(birthdate) as youngest_birthdate
from gold.dim_customers;

-- Find the youngest and oldest customer with age
select
	min(birthdate) as oldest_birthdate,
	max(birthdate) as youngest_birthdate,
	datediff(year, min(birthdate), getdate())  as oldest_age,
	datediff(year, max(birthdate), getdate())  as youngest_age
from gold.dim_customers;

-- Find the youngest and oldest customer with name.
select 
	first_name, 
	birthdate
from gold.dim_customers
where birthdate = (select min(birthdate) from gold.dim_customers)
   OR birthdate = (select max(birthdate) from gold.dim_customers);


-- ===============================================================================
-- Measures Exploration (Key Metrics)
-- ===============================================================================
-- Find the Total Sales
select
	sum(sales_amount) as total_sales
from gold.fact_sales;

-- Find how many items are sold
select
	sum(quantity) as total_quantity
from gold.fact_sales;

-- Find the average selling price
select
	avg(price) as avg_price
from gold.fact_sales;

-- Find the Total number of Orders
select
	count(order_number) as total_order
from gold.fact_sales;

-- Find the Total unique number of Orders
select
	count(distinct order_number) as total_order
from gold.fact_sales;

-- Find the total number of products
select
	count(product_key) as total_products
from gold.dim_products;

-- Find the total number of customers
select
	count(customer_key) as total_customer
from gold.dim_customers;

-- Find the total number of customers that has placed an order
select
	count(distinct customer_key) as total_customer
from gold.fact_sales;

-- Generate a Report that shows all key metrics of the business
select 'Total Sales' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
union all
select 'Total Quantity', sum(quantity) from gold.fact_sales
union all
select 'Average Price', avg(price) from gold.fact_sales
union all
select 'Total Orders', count(distinct order_number) from gold.fact_sales
union all
select 'Total Products', count(distinct product_name) from gold.dim_products
union all
select 'Total Customers', count(customer_key) from gold.dim_customers;