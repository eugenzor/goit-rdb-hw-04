-- 6.3. Розподіл статусів замовлень
SELECT order_status, COUNT(*) AS n_orders
FROM olist_orders
GROUP BY order_status
ORDER BY n_orders DESC;
