-- ============================================
-- Query 01: Top 10 Customers by Total Revenue
-- Technique: CTE + Window Function (RANK)
-- ============================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.name,
        SUM(o.total_amount) AS total_spent,
        COUNT(o.order_id)   AS order_count
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
    GROUP BY c.customer_id, c.name
),
ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY total_spent DESC) AS rnk
    FROM customer_revenue
)
SELECT customer_id, name, total_spent, order_count
FROM ranked
WHERE rnk <= 10
ORDER BY rnk;
