-- 2.4. DELETE ... RETURNING: контрольоване видалення застарілих alert-ів
DELETE FROM seller_alerts
WHERE created_at < NOW() - INTERVAL '30 days'
RETURNING alert_id, seller_id, alert_type, created_at;
