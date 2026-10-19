-- 6.3. Перевірки якості даних
SELECT
    (SELECT COUNT(*) FROM olist_orders AS o
     WHERE NOT EXISTS (SELECT 1 FROM olist_order_reviews AS r WHERE r.order_id = o.order_id))
        AS orders_without_reviews,
    (SELECT COUNT(*) FROM olist_products WHERE product_category_name IS NULL)
        AS products_without_category,
    (SELECT COUNT(*) FROM olist_order_reviews
     WHERE review_comment_message IS NULL OR BTRIM(review_comment_message) = '')
        AS reviews_without_text,
    (SELECT COUNT(*) - COUNT(DISTINCT review_id)
     FROM olist_order_reviews WHERE review_id IS NOT NULL)
        AS repeated_review_id_excess,
    (SELECT COUNT(*) FROM (
        SELECT order_id FROM olist_order_items
        GROUP BY order_id HAVING COUNT(DISTINCT seller_id) > 1
     ) multi_seller_orders)
        AS multi_seller_orders,
    (SELECT COUNT(*) FROM olist_orders AS o
     WHERE NOT EXISTS (SELECT 1 FROM olist_order_items AS i WHERE i.order_id = o.order_id))
        AS orders_without_items;
