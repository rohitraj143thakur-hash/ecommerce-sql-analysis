-- ============================================
-- Query 02: Month-over-Month Revenue Growth
-- Technique: Window Function (LAG), Date truncation
-- ============================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        ( (revenue - LAG(revenue) OVER (ORDER BY month))
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) ) * 100,
        2
    ) AS growth_percent
FROM monthly_revenue
ORDER BY month;
