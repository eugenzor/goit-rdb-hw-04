-- 5.2. AOV за штатом покупця за умови щонайменше 100 замовлень
WITH order_totals AS (
    SELECT o.order_id, c.customer_state,
           SUM(COALESCE(oi.price, 0) + COALESCE(oi.freight_value, 0))::NUMERIC(12, 2) AS order_total
    FROM olist_orders AS o
    JOIN olist_customers AS c ON c.customer_id = o.customer_id
    JOIN olist_order_items AS oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, c.customer_state
)
SELECT customer_state,
       COUNT(*) AS n_orders,
       SUM(order_total)::NUMERIC(12, 2) AS gmv,
       (SUM(order_total) / NULLIF(COUNT(*), 0))::NUMERIC(8, 2) AS aov
FROM order_totals
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY aov DESC NULLS LAST;
