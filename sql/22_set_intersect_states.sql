-- 6.1. штати, де є і покупці, і продавці
SELECT customer_state AS state
FROM olist_customers
INTERSECT
SELECT seller_state AS state
FROM olist_sellers
ORDER BY state;
