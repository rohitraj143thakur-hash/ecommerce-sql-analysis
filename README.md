# E-commerce Database Analysis using SQL

A relational database analysis project that models a realistic e-commerce system (customers, products, orders, order items) and answers key business questions using SQL queries — analyzed and visualized with Python.

## 📌 Overview

This project builds a normalized SQLite database with 4 related tables and writes 12 business-focused SQL queries to extract insights such as revenue trends, top products/customers, regional performance, and payment behavior. Query results are exported to CSV and visualized with charts.

## 🎯 Objectives

- Design a normalized relational schema for an e-commerce system
- Write SQL queries (joins, aggregations, subqueries) to answer real business questions
- Visualize query outputs to communicate insights clearly

## 🛠️ Tools Used

- **SQL (SQLite)** – Database design and querying
- **Python** – Automating query execution via `sqlite3`
- **Pandas** – Handling query results
- **Matplotlib / Seaborn** – Data visualization

## 🗄️ Database Schema

```
customers (customer_id, customer_name, city, signup_date)
products  (product_id, product_name, category, price)
orders    (order_id, customer_id, order_date, region, payment_method)
order_items (order_item_id, order_id, product_id, quantity, discount_pct)
```

**Relationships:**
- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`

## 📂 Project Structure

```
ecommerce-sql-analysis/
│
├── database/
│   └── ecommerce.db                 # SQLite database (4 tables, 1500+ orders)
│
├── queries/
│   └── analysis_queries.sql         # 12 standalone SQL queries
│
├── query_results/                   # CSV output of each query
│   ├── 01_total_revenue.csv
│   ├── 03_top_products.csv
│   ├── 07_top_customers.csv
│   └── ... (12 files total)
│
├── charts/
│   ├── 01_top_products.png
│   ├── 02_revenue_by_category.png
│   ├── 03_revenue_by_region.png
│   ├── 04_monthly_revenue_trend.png
│   ├── 05_payment_method.png
│   └── 06_customers_by_city.png
│
├── run_analysis.py                  # Runs all SQL queries + generates charts
├── insights.txt                     # Key findings summary
└── README.md
```

## 📊 Key SQL Queries Included

1. Total revenue generated
2. Total orders & average order value
3. Top 10 best-selling products by revenue
4. Revenue by category
5. Revenue by region
6. Monthly revenue trend
7. Top 10 customers by total spend
8. Payment method distribution
9. Top 5 cities by customer count
10. Repeat customer count
11. Average discount given per category
12. Highest revenue-generating single order

## 📈 Key Insights

- **Total Revenue: ₹36,02,014** across 1,500 orders (Avg. Order Value: ₹2,401)
- **Electronics** is the top revenue-generating category
- **Power Bank** is the best-selling individual product
- **South region** leads in revenue contribution
- **UPI** is the most preferred payment method (34.7% of orders)
- **295 customers** are repeat buyers, showing healthy retention
- Best sales month: **May 2024**

## 🚀 How to Run

```bash
pip install pandas matplotlib seaborn
python run_analysis.py
```

To explore the raw SQL yourself:
```bash
sqlite3 database/ecommerce.db
.read queries/analysis_queries.sql
```

## 💡 Business Recommendation

Focus marketing spend on Electronics and the South region where revenue concentration is highest, and design loyalty offers around UPI checkout since it's the dominant payment channel among repeat customers.

---
**Author:** Rohit Thakur
