-- ============================================
-- Query 04: Order Funnel Drop-off Analysis
-- Technique: LEFT JOIN, CASE, Conditional Aggregation
-- ============================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN p.status = 'success' THEN o.order_id END) AS paid_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN o.order_id END) AS cancelled_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'refunded' THEN o.order_id END) AS refunded_orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN p.status = 'success' THEN o.order_id END)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS payment_success_rate_pct
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id;
