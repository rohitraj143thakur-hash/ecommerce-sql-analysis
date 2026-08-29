-- ============================================================
-- E-commerce Database Analysis - SQL Queries
-- Author: Rohit Thakur
-- Database: ecommerce.db (SQLite)
-- Tables: customers, products, orders, order_items
-- ============================================================

-- 1. Total Revenue Generated
SELECT
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;


-- 2. Total Orders and Average Order Value
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)) * 1.0
        / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;


-- 3. Top 10 Best-Selling Products by Revenue
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY revenue DESC
LIMIT 10;


-- 4. Revenue by Category
SELECT
    p.category,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- 5. Revenue by Region
SELECT
    o.region,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS region_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.region
ORDER BY region_revenue DESC;


-- 6. Monthly Revenue Trend
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;


-- 7. Top 10 Customers by Total Spend
SELECT
    c.customer_name,
    c.city,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS total_spend,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id
ORDER BY total_spend DESC
LIMIT 10;


-- 8. Preferred Payment Method Distribution
SELECT
    payment_method,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY payment_method
ORDER BY order_count DESC;


-- 9. Customer Signup Trend by City (Top 5 cities by customer count)
SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC
LIMIT 5;


-- 10. Repeat Customers (customers with more than 1 order)
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 1
);


-- 11. Average Discount Given per Category
SELECT
    p.category,
    ROUND(AVG(oi.discount_pct), 2) AS avg_discount_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount_pct DESC;


-- 12. Highest Revenue-Generating Order
SELECT
    o.order_id,
    c.customer_name,
    ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id
ORDER BY order_value DESC
LIMIT 1;
