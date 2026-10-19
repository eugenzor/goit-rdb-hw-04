-- Приклад 4.1. INNER JOIN: топ категорій за revenue і seller-state
SELECT p.product_category_name,
       s.seller_state,
       COUNT(DISTINCT oi.order_id) AS n_orders,
       SUM(COALESCE(oi.price, 0) + COALESCE(oi.freight_value, 0))::NUMERIC(12, 2) AS revenue
FROM olist_order_items AS oi
INNER JOIN olist_orders AS o ON o.order_id = oi.order_id
INNER JOIN olist_products AS p ON p.product_id = oi.product_id
INNER JOIN olist_sellers AS s ON s.seller_id = oi.seller_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name, s.seller_state
ORDER BY revenue DESC NULLS LAST, p.product_category_name, s.seller_state
LIMIT 10;
