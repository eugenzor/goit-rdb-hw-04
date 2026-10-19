-- Завдання 3. CREATE TABLE customer_segments
CREATE TABLE customer_segments (
    segment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_unique_id TEXT NOT NULL,
    segment_name TEXT NOT NULL CHECK (segment_name IN ('VIP', 'regular', 'new', 'inactive')),
    rfm_score SMALLINT NOT NULL CHECK (rfm_score BETWEEN 1 AND 5),
    recency_days INTEGER CHECK (recency_days IS NULL OR recency_days >= 0),
    monetary_value NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (monetary_value >= 0),
    n_orders INTEGER NOT NULL DEFAULT 0 CHECK (n_orders >= 0),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (customer_unique_id)
);
ALTER TABLE customer_segments
ADD CONSTRAINT fk_customer_segments_customer_unique
FOREIGN KEY (customer_unique_id)
REFERENCES olist_customer_dim(customer_unique_id)
ON DELETE CASCADE;
