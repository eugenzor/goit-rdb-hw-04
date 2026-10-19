-- Приклад 4.5. Кількість замовлень без відгуку
SELECT COUNT(*) AS n_orders_without_reviews
FROM olist_orders AS o
WHERE NOT EXISTS (
    SELECT 1 FROM olist_order_reviews AS rv WHERE rv.order_id = o.order_id
);
