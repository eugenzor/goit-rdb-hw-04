-- 6.2. останнє замовлення кожного реального покупця
WITH ranked_orders AS (
    SELECT c.customer_unique_id, o.customer_id, o.order_id,
           o.order_purchase_timestamp,
           ROW_NUMBER() OVER (
               PARTITION BY c.customer_unique_id
               ORDER BY o.order_purchase_timestamp DESC, o.order_id DESC
           ) AS rn
    FROM olist_orders AS o
    JOIN olist_customers AS c ON c.customer_id = o.customer_id
)
SELECT customer_unique_id, customer_id, order_id, order_purchase_timestamp
FROM ranked_orders
WHERE rn = 1
ORDER BY customer_unique_id
LIMIT 20;
