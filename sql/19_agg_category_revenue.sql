-- 5.1. Категорії з виторгом товарів понад 10000
SELECT p.product_category_name,
       COUNT(DISTINCT oi.order_id) AS n_orders,
       SUM(oi.price)::NUMERIC(12, 2) AS gross_revenue,
       SUM(oi.freight_value)::NUMERIC(12, 2) AS freight,
       AVG(oi.price)::NUMERIC(8, 2) AS avg_item_price
FROM olist_order_items AS oi
JOIN olist_products AS p ON p.product_id = oi.product_id
GROUP BY p.product_category_name
HAVING SUM(oi.price) > 10000
ORDER BY gross_revenue DESC NULLS LAST;
