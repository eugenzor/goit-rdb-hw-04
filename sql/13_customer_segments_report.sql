-- Завдання 3. Перевірка customer_segments
SELECT segment_name,
       COUNT(*) AS n_customers,
       AVG(monetary_value)::NUMERIC(12, 2) AS avg_monetary,
       AVG(n_orders)::NUMERIC(8, 2) AS avg_orders,
       AVG(recency_days)::NUMERIC(10, 2) AS avg_recency_days
FROM customer_segments
GROUP BY segment_name
ORDER BY n_customers DESC;

SELECT conname, contype, pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'customer_segments'::regclass
ORDER BY conname;

SELECT customer_unique_id, segment_name, rfm_score, recency_days,
       monetary_value, n_orders
FROM customer_segments
ORDER BY monetary_value DESC, customer_unique_id
LIMIT 10;
