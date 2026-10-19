-- Приклад 4.5. Anti-join: замовлення без відгуку
SELECT o.order_id, o.customer_id, o.order_status, o.order_purchase_timestamp
FROM olist_orders AS o
LEFT JOIN olist_order_reviews AS rv ON rv.order_id = o.order_id
WHERE rv.review_row_id IS NULL
ORDER BY o.order_purchase_timestamp, o.order_id
LIMIT 20;
