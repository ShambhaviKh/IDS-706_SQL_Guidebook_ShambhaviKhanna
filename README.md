# SQL Reference Guide

## Table of Contents

1. [Overview](#overview)  
2. [Why This Project](#why-this-project)  
3. [SQLite Version Check](#sqlite-version-check)  
4. [Dataset Used](#dataset-used)   
5. [SQL Operations and Questions Covered](#sql-operations-and-questions-covered)  
6. [How to Run](#how-to-run)  
7. [Outputs](#output-snippets)
8. [Conclusion](#conclusion)  

---

## Overview

his project demonstrates key SQL concepts and advanced query techniques through a restaurant order management example.  
It serves as a **personalized SQL reference guide** for interview preparation and real-world data tasks.

You will find examples of:
- Table creation, insertion, and updates  
- Joins and aggregations  
- Data cleaning and transformation  
- Common Table Expressions (CTEs)  
- Window functions like `RANK()` and `LAG()`  
- Custom queries combining multiple SQL features  

---

## Why This Project

- To practice **SQL fundamentals** (DDL, DML, joins, aggregate functions).  
- To learn and document **advanced SQL features**: window functions, CTEs, data cleaning, string & date functions.  
- To create a **portfolio-ready SQL reference** for personal and professional use.  
- To analyze sample business data (restaurant orders) and answer realistic business questions.

---

## SQLite Version Check

To ensure compatibility, check your SQLite version in terminal:

```bash
sqlite3 --version
```
---

## Dataset used

A reference Kaggle restaurant dataset was reviewed for structure and logic inspiration.
However, the tables and data in this project were created manually using the reference as a guide.
This approach demonstrates how to design and populate relational databases independently while maintaining realistic data patterns.

## 📝 SQL Operations and Questions Covered

| SQL Operation / Feature | Example Query | Question / Purpose Answered |
|------------------------|---------------|----------------------------|
| CREATE TABLE | `CREATE TABLE Customers ...` | Create database schema for customers, menu items, and orders |
| INSERT INTO | `INSERT INTO Orders ...` | Populate tables with sample data |
| UPDATE | `UPDATE Orders SET unit_price = 2.20 WHERE order_id = 1272;` | Update an order price |
| SELECT | `SELECT * FROM Orders;` | Retrieve all orders |
| WHERE | `SELECT order_id, unit_price FROM Orders WHERE order_id = 1272;` | Filter specific rows |
| ORDER BY | `ORDER BY total_spent DESC;` | Sort total spending per customer |
| GROUP BY | `GROUP BY c.customer_name` | Aggregate total spent per customer |
| HAVING | `HAVING COUNT(*) >= 1` | Filter groups with minimum orders |
| LIMIT | `LIMIT 1` | Find the most popular menu item |
| JOIN (INNER JOIN) | `JOIN Customers c ON o.customer_id = c.customer_id` | Combine orders with customer info |
| JOIN (LEFT JOIN) | `LEFT JOIN Orders o ON o.customer_id = c.customer_id` | Include customers with no orders |
| Aggregate Functions | `SUM(o.quantity*o.unit_price), COUNT(*), AVG(quantity), MAX(quantity*unit_price)` | Revenue, total orders, avg quantity, max order |
| CASE WHEN | `CASE WHEN o.quantity >= 5 THEN 'Bulk Order' ... END` | Classify orders as Small, Medium, Bulk |
| CTE (WITH) | `WITH customer_spend AS (...) SELECT ...` | Compute total spend and rank customers |
| Window Functions | `RANK() OVER(...), ROW_NUMBER() OVER(...), LAG(...)` | Rank customers and get previous order totals |
| String Functions | `REPLACE(LOWER(payment_method), '_', ' ')` | Normalize payment method text |
| Date Functions | `substr(order_time,1,7)` | Extract order month from timestamp |
| COALESCE | `COALESCE(c.customer_name,'UNKNOWN')` | Handle missing customer names |
| UNION | `SELECT 'High' ... UNION SELECT 'Low' ...` | Categorize customers as High/Low spenders |

### Questions Answered Through Queries

| # | Question Answered |
|---|------------------|
| 1 | How can I update a specific order’s price? |
| 2 | What is the total revenue and total number of orders? |
| 3 | What is the average quantity per order and maximum order value? |
| 4 | How much did each customer spend in total? |
| 5 | Which menu item is the most popular? |
| 6 | How many orders were made with each payment method? |
| 7 | How can I classify orders by size (Small, Medium, Bulk)? |
| 8 | Which customers rank highest by total spending? |
| 9 | What was each customer’s previous order total? |
| 10 | How can I normalize payment method text and extract order month? |
| 11 | Which customers fall into High or Low spending categories? |


## How to Run

1. Save all SQL statements to a file named `restaurant_project.sql`.  
2. Open SQLite by running the following command in your terminal:

```bash
sqlite3 restro.db
```
3. Execute the SQL script inside SQLite:
```sql
.read restaurant_project.sql
```

## Output Snippets



## Conclusion

1. This project demonstrates core and advanced SQL techniques in a realistic restaurant orders scenario.
2. It serves as a reference guide for interview preparation, SQL practice, and small-scale analytics projects.
3. Designed normalized tables with relationships
4. Practiced aggregate functions, joins, window functions, and CTEs
5. Performed data cleaning and transformation
6. Created a reusable SQL reference guide for future use