-- Приклад 4.2. LEFT JOIN + COALESCE: customer-level features без множення review
WITH order_totals AS (
    SELECT o.order_id, c.customer_unique_id,
           COALESCE(SUM(COALESCE(oi.price, 0) + COALESCE(oi.freight_value, 0)), 0)::NUMERIC(12, 2) AS order_total
    FROM olist_orders AS o
    JOIN olist_customers AS c ON c.customer_id = o.customer_id
    LEFT JOIN olist_order_items AS oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, c.customer_unique_id
),
review_per_order AS (
    SELECT order_id, AVG(review_score)::NUMERIC(3, 2) AS order_review_score
    FROM olist_order_reviews
    WHERE review_score IS NOT NULL
    GROUP BY order_id
),
customer_stats AS (
    SELECT ot.customer_unique_id,
           COUNT(DISTINCT ot.order_id)::INTEGER AS n_orders,
           COALESCE(SUM(ot.order_total), 0)::NUMERIC(12, 2) AS total_spend,
           AVG(rpo.order_review_score)::NUMERIC(3, 2) AS avg_review_score,
           COUNT(rpo.order_id)::INTEGER AS reviewed_orders
    FROM order_totals AS ot
    LEFT JOIN review_per_order AS rpo ON rpo.order_id = ot.order_id
    GROUP BY ot.customer_unique_id
)
SELECT cd.customer_unique_id, cd.customer_state,
       COALESCE(cs.n_orders, 0) AS n_orders,
       COALESCE(cs.total_spend, 0)::NUMERIC(12, 2) AS total_spend,
       COALESCE(cs.avg_review_score, 0)::NUMERIC(3, 2) AS avg_review_score,
       (COALESCE(cs.reviewed_orders, 0) > 0) AS has_review
FROM olist_customer_dim AS cd
LEFT JOIN customer_stats AS cs ON cs.customer_unique_id = cd.customer_unique_id
ORDER BY total_spend DESC, cd.customer_unique_id
LIMIT 20;
