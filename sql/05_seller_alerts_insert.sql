-- 2.1. INSERT ... RETURNING: створення alert для продавця з найбільшою кількістю запізнень
WITH seller_orders AS (
    SELECT DISTINCT oi.seller_id, oi.order_id
    FROM olist_order_items AS oi
    WHERE oi.seller_id IS NOT NULL
),
late_sellers AS (
    SELECT so.seller_id, COUNT(*) AS late_orders
    FROM seller_orders AS so
    JOIN olist_orders AS o ON o.order_id = so.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
      AND o.order_delivered_customer_date::DATE > o.order_estimated_delivery_date::DATE
    GROUP BY so.seller_id
    ORDER BY late_orders DESC, so.seller_id
    LIMIT 1
)
INSERT INTO seller_alerts (seller_id, alert_type, severity, details)
SELECT ls.seller_id, 'late_delivery', 4,
       'Seller has ' || ls.late_orders || ' late delivered orders in the loaded dataset'
FROM late_sellers AS ls
WHERE NOT EXISTS (
    SELECT 1 FROM seller_alerts AS a
    WHERE a.seller_id = ls.seller_id AND a.alert_type = 'late_delivery'
)
RETURNING alert_id, seller_id, alert_type, severity, details, created_at;
