-- Завдання 3. Заповнення customer_segments
WITH reference_date AS (
    SELECT MAX(order_purchase_timestamp)::DATE + 1 AS as_of_date
    FROM olist_orders
),
order_totals AS (
    SELECT o.order_id, o.customer_id,
           o.order_purchase_timestamp::DATE AS order_date,
           COALESCE(SUM(COALESCE(oi.price, 0) + COALESCE(oi.freight_value, 0)), 0)::NUMERIC(12, 2) AS order_total
    FROM olist_orders AS o
    LEFT JOIN olist_order_items AS oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id, o.order_purchase_timestamp
),
customer_stats AS (
    SELECT c.customer_unique_id,
           COUNT(DISTINCT ot.order_id)::INTEGER AS n_orders,
           COALESCE(SUM(ot.order_total), 0)::NUMERIC(12, 2) AS monetary_value,
           MAX(ot.order_date) AS last_order_date
    FROM olist_customer_dim AS cd
    JOIN olist_customers AS c ON c.customer_unique_id = cd.customer_unique_id
    LEFT JOIN order_totals AS ot ON ot.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
segmented AS (
    SELECT cs.customer_unique_id,
           cs.n_orders,
           cs.monetary_value,
           CASE WHEN cs.last_order_date IS NULL THEN NULL
                ELSE (rd.as_of_date - cs.last_order_date)::INTEGER END AS recency_days,
           CASE
               WHEN cs.monetary_value >= 1000 THEN 'VIP'
               WHEN cs.last_order_date IS NOT NULL
                    AND (rd.as_of_date - cs.last_order_date)::INTEGER <= 90
                    AND cs.n_orders = 1 THEN 'new'
               WHEN cs.n_orders >= 2 OR cs.monetary_value >= 100 THEN 'regular'
               ELSE 'inactive'
           END AS segment_name,
           CASE
               WHEN cs.monetary_value >= 1000 THEN 5
               WHEN cs.monetary_value >= 500 THEN 4
               WHEN cs.n_orders >= 2 THEN 3
               WHEN cs.n_orders = 1 THEN 2
               ELSE 1
           END::SMALLINT AS rfm_score
    FROM customer_stats AS cs
    CROSS JOIN reference_date AS rd
),
upserted AS (
    INSERT INTO customer_segments (
        customer_unique_id, segment_name, rfm_score,
        recency_days, monetary_value, n_orders
    )
    SELECT customer_unique_id, segment_name, rfm_score,
           recency_days, monetary_value, n_orders
    FROM segmented
    WHERE TRUE  -- потрібно для однозначного розбору ON CONFLICT
    ON CONFLICT (customer_unique_id) DO UPDATE
    SET segment_name = EXCLUDED.segment_name,
        rfm_score = EXCLUDED.rfm_score,
        recency_days = EXCLUDED.recency_days,
        monetary_value = EXCLUDED.monetary_value,
        n_orders = EXCLUDED.n_orders,
        assigned_at = NOW()
    RETURNING customer_unique_id, segment_name, rfm_score,
              recency_days, monetary_value, n_orders
)
SELECT COUNT(*) AS upserted_customers,
       COUNT(*) FILTER (WHERE segment_name = 'VIP') AS vip,
       COUNT(*) FILTER (WHERE segment_name = 'regular') AS regular,
       COUNT(*) FILTER (WHERE segment_name = 'new') AS new,
       COUNT(*) FILTER (WHERE segment_name = 'inactive') AS inactive
FROM upserted;
