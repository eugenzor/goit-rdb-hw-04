-- Завдання 3. Таблиця olist_customer_dim (один рядок на customer_unique_id)
DROP TABLE IF EXISTS customer_segments CASCADE;
DROP TABLE IF EXISTS olist_customer_dim CASCADE;

CREATE TABLE olist_customer_dim (
    customer_unique_id TEXT PRIMARY KEY,
    latest_customer_id TEXT REFERENCES olist_customers(customer_id),
    customer_state CHAR(2),
    customer_city TEXT
);

INSERT INTO olist_customer_dim (
    customer_unique_id, latest_customer_id, customer_state, customer_city
)
SELECT DISTINCT ON (c.customer_unique_id)
       c.customer_unique_id,
       c.customer_id,
       c.customer_state,
       c.customer_city
FROM olist_customers AS c
LEFT JOIN olist_orders AS o ON o.customer_id = c.customer_id
ORDER BY c.customer_unique_id,
         o.order_purchase_timestamp DESC NULLS LAST,
         c.customer_id;
