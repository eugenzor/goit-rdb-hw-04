-- 2.1. Таблиця seller_alerts
DROP TABLE IF EXISTS seller_alerts CASCADE;
CREATE TABLE seller_alerts (
    alert_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id TEXT NOT NULL REFERENCES olist_sellers(seller_id),
    alert_type TEXT NOT NULL CHECK (alert_type IN ('late_delivery', 'low_rating', 'data_quality')),
    severity SMALLINT NOT NULL CHECK (severity BETWEEN 1 AND 5),
    details TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
