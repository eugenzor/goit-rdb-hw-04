-- 2.2. INSERT ... ON CONFLICT DO UPDATE: idempotent upsert агрегованих seller-score
WITH seller_orders AS (
    SELECT DISTINCT seller_id, order_id
    FROM olist_order_items
    WHERE seller_id IS NOT NULL
),
review_per_order AS (
    SELECT order_id, AVG(review_score)::NUMERIC(3, 2) AS order_review_score
    FROM olist_order_reviews
    WHERE review_score IS NOT NULL
    GROUP BY order_id
),
seller_rating AS (
    SELECT so.seller_id,
           AVG(rpo.order_review_score)::NUMERIC(3, 2) AS avg_rating,
           COUNT(rpo.order_id)::INTEGER AS n_reviews
    FROM seller_orders AS so
    LEFT JOIN review_per_order AS rpo ON rpo.order_id = so.order_id
    GROUP BY so.seller_id
),
upserted AS (
    INSERT INTO seller_score (seller_id, avg_rating, n_reviews, tier)
    SELECT seller_id, avg_rating, n_reviews,
           CASE
               WHEN avg_rating IS NULL THEN NULL
               WHEN avg_rating >= 4.5 THEN 'gold'
               WHEN avg_rating >= 3.5 THEN 'silver'
               ELSE 'bronze'
           END AS tier
    FROM seller_rating
    WHERE TRUE  -- відокремлює SELECT від ON CONFLICT у синтаксисі PostgreSQL
    ON CONFLICT (seller_id) DO UPDATE
    SET avg_rating = EXCLUDED.avg_rating,
        n_reviews = EXCLUDED.n_reviews,
        tier = EXCLUDED.tier,
        updated_at = NOW()
    RETURNING seller_id, avg_rating, n_reviews, tier, updated_at
)
SELECT COUNT(*) AS upserted_sellers,
       COUNT(*) FILTER (WHERE tier = 'gold') AS gold,
       COUNT(*) FILTER (WHERE tier = 'silver') AS silver,
       COUNT(*) FILTER (WHERE tier = 'bronze') AS bronze,
       COUNT(*) FILTER (WHERE avg_rating IS NULL) AS without_reviews
FROM upserted;
