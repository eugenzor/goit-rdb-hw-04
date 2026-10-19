-- Приклад 4.4. SELF JOIN: пари продавців з одного штату, але з різних міст
SELECT s1.seller_id AS seller_a,
       s2.seller_id AS seller_b,
       s1.seller_state,
       s1.seller_city AS city_a,
       s2.seller_city AS city_b
FROM olist_sellers AS s1
JOIN olist_sellers AS s2
  ON s1.seller_state = s2.seller_state
 AND s1.seller_id < s2.seller_id
 AND s1.seller_city IS DISTINCT FROM s2.seller_city
ORDER BY s1.seller_state, seller_a, seller_b
LIMIT 20;
