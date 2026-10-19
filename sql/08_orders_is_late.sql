-- 2.3. UPDATE ... FROM: оновлення прапорця запізнення в olist_orders
ALTER TABLE olist_orders
ADD COLUMN IF NOT EXISTS is_late BOOLEAN NOT NULL DEFAULT FALSE;

WITH delivery_flags AS (
    SELECT order_id,
           (order_delivered_customer_date IS NOT NULL
            AND order_estimated_delivery_date IS NOT NULL
            AND order_delivered_customer_date::DATE > order_estimated_delivery_date::DATE) AS is_late_calc
    FROM olist_orders
),
updated AS (
    UPDATE olist_orders AS o
    SET is_late = f.is_late_calc
    FROM delivery_flags AS f
    WHERE o.order_id = f.order_id
      AND o.is_late IS DISTINCT FROM f.is_late_calc
    RETURNING o.order_id, o.customer_id, o.is_late
)
SELECT COUNT(*) AS changed_rows,
       COUNT(*) FILTER (WHERE is_late) AS changed_to_late
FROM updated;

SELECT COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE is_late) AS late_orders
FROM olist_orders;
