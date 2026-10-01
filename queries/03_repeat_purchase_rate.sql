-- ============================================
-- Query 03: Repeat Purchase Rate by Product Category
-- Technique: Subquery, GROUP BY / HAVING, CASE
-- ============================================

WITH customer_orders AS (
    SELECT
        oi.product_id,
        p.category,
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS orders_for_product
    FROM order_items oi
    JOIN orders o   ON o.order_id = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'completed'
    GROUP BY oi.product_id, p.category, o.customer_id
)
SELECT
    category,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN orders_for_product > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        100.0 * SUM(CASE WHEN orders_for_product > 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS repeat_purchase_rate_pct
FROM customer_orders
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY repeat_purchase_rate_pct DESC;
