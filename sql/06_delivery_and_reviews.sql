-- Databricks notebook source
-- ============================================================================
-- 06_delivery_and_reviews.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Test whether late delivery lowers customer review scores, and
--           examine delivery performance during the Black Friday 2017 surge
--           and in Rio de Janeiro (RJ).
-- Scope   : Delivered orders with a customer delivery date, Jan 2017 to
--           Aug 2018. One review per order (most recent), via
--           order_reviews_dedup. An order is late if it arrived after its
--           estimated delivery timestamp. Review timing relative to delivery
--           is checked, because some reviews are answered before the parcel
--           arrives.
-- ============================================================================

-- COMMAND ----------

USE CATALOG workspace;
USE SCHEMA olist;

-- COMMAND ----------

-- 1. One review per order: keep the most recent review.
-- Ordered by answer timestamp, then creation date, then review_id so the
-- result is deterministic. reviews_on_order keeps the original review count.

CREATE OR REPLACE VIEW order_reviews_dedup AS
SELECT * EXCEPT (rn)
FROM (
  SELECT
    r.*,
    COUNT(*) OVER (PARTITION BY order_id) AS reviews_on_order,
    ROW_NUMBER() OVER (
      PARTITION BY order_id
      ORDER BY review_answer_timestamp DESC,
               review_creation_date DESC,
               review_id
    ) AS rn
  FROM order_reviews r
)
WHERE rn = 1;

-- COMMAND ----------

-- 2. Check: the view returns one row per order (expected 98,673 for both)

SELECT COUNT(*) AS rows_in_view, COUNT(DISTINCT order_id) AS distinct_orders
FROM order_reviews_dedup;

-- COMMAND ----------

-- 3. One row per delivered order: delivery performance and review score.
-- days_late is negative when the order arrived before the estimated date.

CREATE OR REPLACE VIEW delivery_reviews AS
SELECT
  o.order_id,
  c.customer_state,
  o.order_purchase_timestamp,
  (UNIX_TIMESTAMP(o.order_delivered_customer_date)
     - UNIX_TIMESTAMP(o.order_purchase_timestamp)) / 86400.0      AS delivery_days,
  (UNIX_TIMESTAMP(o.order_delivered_customer_date)
     - UNIX_TIMESTAMP(o.order_estimated_delivery_date)) / 86400.0 AS days_late,
  o.order_delivered_customer_date > o.order_estimated_delivery_date AS is_late,
  r.review_score
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_reviews_dedup r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';

-- COMMAND ----------

-- 4. Review coverage: share of delivered orders that have a review

SELECT
  COUNT(*)                                          AS delivered_orders,
  COUNT(review_score)                               AS with_review,
  ROUND(100.0 * COUNT(review_score) / COUNT(*), 2)  AS review_coverage_pct
FROM delivery_reviews;

-- COMMAND ----------

-- 5. Review scores: on time versus late

SELECT
  CASE WHEN is_late THEN 'late' ELSE 'on time or early' END AS delivery,
  COUNT(review_score)                                       AS reviewed_orders,
  ROUND(AVG(review_score), 2)                               AS avg_score,
  ROUND(100.0 * COUNT_IF(review_score = 1) / COUNT(review_score), 1) AS pct_1_star,
  ROUND(100.0 * COUNT_IF(review_score = 5) / COUNT(review_score), 1) AS pct_5_star
FROM delivery_reviews
WHERE review_score IS NOT NULL
GROUP BY is_late
ORDER BY is_late;

-- COMMAND ----------

-- 6. Review scores by how late the order was (all reviews)

SELECT
  CASE
    WHEN days_late <= 0 THEN '0. on time or early'
    WHEN days_late <= 3 THEN '1. up to 3 days late'
    WHEN days_late <= 7 THEN '2. 3 to 7 days late'
    ELSE                     '3. more than 7 days late'
  END                                                        AS lateness,
  COUNT(review_score)                                        AS reviewed_orders,
  ROUND(AVG(review_score), 2)                                AS avg_score,
  ROUND(100.0 * COUNT_IF(review_score = 1) / COUNT(review_score), 1) AS pct_1_star
FROM delivery_reviews
WHERE review_score IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- COMMAND ----------

-- 7. Reviews answered before the recorded delivery date

SELECT
  COUNT(*)                                                                AS reviewed_orders,
  COUNT_IF(r.review_answer_timestamp < o.order_delivered_customer_date)   AS answered_before_delivery,
  ROUND(100.0 * COUNT_IF(r.review_answer_timestamp < o.order_delivered_customer_date)
        / COUNT(*), 2)                                                    AS pct_before_delivery
FROM orders o
JOIN order_reviews_dedup r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';

-- COMMAND ----------

-- 8. On time versus late, split by whether the review was answered before
-- or after delivery

SELECT
  CASE WHEN d.is_late THEN 'late' ELSE 'on time or early' END AS delivery,
  CASE WHEN r.review_answer_timestamp < o.order_delivered_customer_date
       THEN 'answered before delivery'
       ELSE 'answered on or after delivery' END               AS review_timing,
  COUNT(*)                                                    AS reviewed_orders,
  ROUND(AVG(d.review_score), 2)                               AS avg_score,
  ROUND(100.0 * COUNT_IF(d.review_score = 1) / COUNT(*), 1)   AS pct_1_star
FROM delivery_reviews d
JOIN orders o              ON d.order_id = o.order_id
JOIN order_reviews_dedup r ON d.order_id = r.order_id
WHERE d.review_score IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2;

-- COMMAND ----------

-- 9. Lateness bands, split by review timing

SELECT
  CASE
    WHEN d.days_late <= 0 THEN '0. on time or early'
    WHEN d.days_late <= 3 THEN '1. up to 3 days late'
    WHEN d.days_late <= 7 THEN '2. 3 to 7 days late'
    ELSE                       '3. more than 7 days late'
  END                                                         AS lateness,
  CASE WHEN r.review_answer_timestamp < o.order_delivered_customer_date
       THEN 'before delivery' ELSE 'on or after delivery' END AS review_timing,
  COUNT(*)                                                    AS reviewed_orders,
  ROUND(AVG(d.review_score), 2)                               AS avg_score,
  ROUND(100.0 * COUNT_IF(d.review_score = 1) / COUNT(*), 1)   AS pct_1_star
FROM delivery_reviews d
JOIN orders o              ON d.order_id = o.order_id
JOIN order_reviews_dedup r ON d.order_id = r.order_id
WHERE d.review_score IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2;

-- COMMAND ----------

-- 10. Does the lateness penalty hold within each state?
-- Reviews answered on or after delivery only. States with at least 100 late
-- orders in this group.

SELECT
  d.customer_state,
  COUNT(*)                                                           AS reviewed_orders,
  COUNT_IF(d.is_late)                                                AS late_orders,
  ROUND(AVG(CASE WHEN NOT d.is_late THEN d.review_score END), 2)     AS avg_score_on_time,
  ROUND(AVG(CASE WHEN d.is_late     THEN d.review_score END), 2)     AS avg_score_late,
  ROUND(AVG(CASE WHEN NOT d.is_late THEN d.review_score END)
      - AVG(CASE WHEN d.is_late     THEN d.review_score END), 2)     AS score_gap
FROM delivery_reviews d
JOIN orders o              ON d.order_id = o.order_id
JOIN order_reviews_dedup r ON d.order_id = r.order_id
WHERE d.review_score IS NOT NULL
  AND r.review_answer_timestamp >= o.order_delivered_customer_date
GROUP BY d.customer_state
HAVING COUNT_IF(d.is_late) >= 100
ORDER BY score_gap DESC;

-- COMMAND ----------

-- 11. Black Friday week: delivery performance and satisfaction by purchase date

SELECT
  CASE
    WHEN order_purchase_timestamp >= '2017-11-24'
     AND order_purchase_timestamp <  '2017-12-01' THEN '2. 24 to 30 Nov 2017 (Black Friday week)'
    WHEN order_purchase_timestamp >= '2017-11-01'
     AND order_purchase_timestamp <  '2017-11-24' THEN '1. 1 to 23 Nov 2017'
    WHEN order_purchase_timestamp >= '2017-12-01'
     AND order_purchase_timestamp <  '2018-01-01' THEN '3. Dec 2017'
    ELSE                                               '4. all other months in the window'
  END                                                  AS period,
  COUNT(*)                                             AS delivered_orders,
  ROUND(AVG(delivery_days), 1)                         AS avg_delivery_days,
  ROUND(100.0 * COUNT_IF(is_late) / COUNT(*), 1)       AS late_pct,
  ROUND(AVG(review_score), 2)                          AS avg_score
FROM delivery_reviews
GROUP BY 1
ORDER BY 1;

-- COMMAND ----------

-- 12. Black Friday week: order outcomes across all statuses
-- Tests whether the surge also produced more cancelled or undelivered orders.

SELECT
  CASE WHEN order_purchase_timestamp >= '2017-11-24'
        AND order_purchase_timestamp <  '2017-12-01'
       THEN 'Black Friday week' ELSE 'rest of window' END           AS period,
  COUNT(*)                                                          AS all_orders,
  ROUND(100.0 * COUNT_IF(order_status = 'delivered') / COUNT(*), 2) AS delivered_pct,
  ROUND(100.0 * COUNT_IF(order_status = 'canceled')  / COUNT(*), 2) AS canceled_pct,
  ROUND(100.0 * COUNT_IF(order_status NOT IN ('delivered', 'canceled'))
        / COUNT(*), 2)                                              AS other_not_delivered_pct
FROM orders
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY 1;

-- COMMAND ----------

-- 13. Delivery-time tail in the three largest states

SELECT
  customer_state,
  COUNT(*)                                             AS orders,
  ROUND(PERCENTILE(delivery_days, 0.5), 1)             AS median_days,
  ROUND(PERCENTILE(delivery_days, 0.9), 1)             AS p90_days,
  ROUND(PERCENTILE(delivery_days, 0.95), 1)            AS p95_days,
  ROUND(100.0 * COUNT_IF(delivery_days > 30) / COUNT(*), 1) AS pct_over_30_days,
  ROUND(100.0 * COUNT_IF(is_late) / COUNT(*), 1)       AS late_pct
FROM delivery_reviews
WHERE customer_state IN ('SP', 'RJ', 'MG')
GROUP BY customer_state
ORDER BY customer_state;

-- COMMAND ----------

-- 14. RJ versus SP and MG: late rate by month

SELECT
  DATE_TRUNC('month', order_purchase_timestamp)                  AS order_month,
  COUNT_IF(customer_state = 'RJ')                                AS rj_orders,
  ROUND(100.0 * COUNT_IF(customer_state = 'RJ' AND is_late)
        / COUNT_IF(customer_state = 'RJ'), 1)                    AS rj_late_pct,
  ROUND(100.0 * COUNT_IF(customer_state IN ('SP', 'MG') AND is_late)
        / COUNT_IF(customer_state IN ('SP', 'MG')), 1)           AS sp_mg_late_pct
FROM delivery_reviews
GROUP BY 1
ORDER BY 1;
