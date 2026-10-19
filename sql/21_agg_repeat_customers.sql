-- 5.3. STRING_AGG: категорії покупок повторних клієнтів
SELECT c.customer_unique_id,
       COUNT(DISTINCT o.order_id) AS n_orders,
       SUM(oi.price)::NUMERIC(12, 2) AS total_product_spend,
       STRING_AGG(
           DISTINCT COALESCE(p.product_category_name, '(unknown)'),
           ', ' ORDER BY COALESCE(p.product_category_name, '(unknown)')
       ) AS categories
FROM olist_customers AS c
JOIN olist_orders AS o ON o.customer_id = c.customer_id
JOIN olist_order_items AS oi ON oi.order_id = o.order_id
LEFT JOIN olist_products AS p ON p.product_id = oi.product_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) >= 2
ORDER BY total_product_spend DESC NULLS LAST, c.customer_unique_id
LIMIT 20;
