-- Перевіримо, чи все добре
WITH raw_counts AS (
    SELECT 'customers' AS table_name, COUNT(*) AS n_raw FROM olist_customers_raw
    UNION ALL SELECT 'orders', COUNT(*) FROM olist_orders_raw
    UNION ALL SELECT 'order_items', COUNT(*) FROM olist_order_items_raw
    UNION ALL SELECT 'products', COUNT(*) FROM olist_products_raw
    UNION ALL SELECT 'sellers', COUNT(*) FROM olist_sellers_raw
    UNION ALL SELECT 'reviews', COUNT(*) FROM olist_order_reviews_raw
),
typed_counts AS (
    SELECT 'customers' AS table_name, COUNT(*) AS n_typed FROM olist_customers
    UNION ALL SELECT 'orders', COUNT(*) FROM olist_orders
    UNION ALL SELECT 'order_items', COUNT(*) FROM olist_order_items
    UNION ALL SELECT 'products', COUNT(*) FROM olist_products
    UNION ALL SELECT 'sellers', COUNT(*) FROM olist_sellers
    UNION ALL SELECT 'reviews', COUNT(*) FROM olist_order_reviews
)
SELECT r.table_name, r.n_raw, t.n_typed, t.n_typed - r.n_raw AS delta
FROM raw_counts AS r
JOIN typed_counts AS t USING (table_name)
ORDER BY r.table_name;
