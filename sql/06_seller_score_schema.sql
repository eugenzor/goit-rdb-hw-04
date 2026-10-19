-- 2.2. Таблиця seller_score
DROP TABLE IF EXISTS seller_score CASCADE;
CREATE TABLE seller_score (
    seller_id TEXT PRIMARY KEY REFERENCES olist_sellers(seller_id),
    avg_rating NUMERIC(3, 2),
    n_reviews INTEGER NOT NULL DEFAULT 0 CHECK (n_reviews >= 0),
    tier TEXT CHECK (tier IN ('gold', 'silver', 'bronze')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
