-- Приклад 4.3. FULL OUTER JOIN: які штати присутні серед клієнтів і продавців
WITH customer_states AS (
    SELECT customer_state AS state, COUNT(*) AS n_customer_records
    FROM olist_customers
    GROUP BY customer_state
),
seller_states AS (
    SELECT seller_state AS state, COUNT(*) AS n_sellers
    FROM olist_sellers
    GROUP BY seller_state
)
SELECT COALESCE(c.state, s.state) AS state,
       COALESCE(c.n_customer_records, 0) AS n_customer_records,
       COALESCE(s.n_sellers, 0) AS n_sellers,
       CASE
           WHEN c.state IS NOT NULL AND s.state IS NOT NULL THEN 'both'
           WHEN c.state IS NOT NULL THEN 'customers_only'
           ELSE 'sellers_only'
       END AS state_presence
FROM customer_states AS c
FULL OUTER JOIN seller_states AS s ON s.state = c.state
ORDER BY state;
