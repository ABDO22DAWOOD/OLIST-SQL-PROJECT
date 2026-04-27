
#  Olist E-Commerce SQL Project

## Overview
Full SQL Server project built on the Brazilian Olist dataset (100K+ orders, 8 tables).  
Includes **database design, indexes, views, stored procedures, and analytical queries**.

## Key Features
- Database architecture with PK/FK constraints.
- Performance indexes for JOINs and filters.
- Views:
  - Top 10 Customers by Lifetime Value.
  - Slowest Delivery Cities.
  - Monthly Revenue Growth (LAG).
  - Top Product Categories by Sales.
  - Best Sellers Ranking.
  - Payment Method Analysis.
  - Shipping Performance by State.
  - Customer Segmentation (VIP/Loyal/New).
- Stored Procedure: Customer Report (parameterized).
- Profitability analysis by category.
- Seller Performance Composite Score.

## SQL Techniques Used
- Window Functions (DENSE_RANK, LAG, PERCENT_RANK).
- CTEs.
- Views.
- Stored Procedures.
- Indexes.
- CASE WHEN, COALESCE.
- Self-Join.

## How to Run
1. Create a database in SQL Server 2022.
2. Run `create_tables.sql` to build schema.
3. Run `indexes.sql` to add performance indexes.
4. Run `views.sql` to create analytical views.
5. Run `procedures.sql` for stored procedures.
6. Test queries in `analytics_queries.sql`.

## Results
- Total Orders: 115,720  
- Total Revenue: BRL 13.8M  
- Avg Delivery: 12 days  
- On-Time Rate: 51.8%

## Conclusion
This project demonstrates advanced SQL skills in **database design, optimization, and analytics**.
