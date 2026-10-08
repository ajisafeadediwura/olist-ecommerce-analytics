-- Databricks notebook source
-- ============================================================================
-- 07_seller_analysis.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Measure how concentrated revenue is among sellers, examine seller
--           location, and test whether seller performance explains late
--           deliveries, including the Nov 2017 to Mar 2018 episode in RJ.
-- Scope   : Delivered orders, Jan 2017 to Aug 2018. Revenue is the sum of
--           item price (freight excluded). Delivery analysis uses orders that
--           contain items from exactly one seller, because an order's delivery
--           performance cannot be attributed to a seller when several sellers
--           share the order.
-- Requires: view delivered_items (03_eda.sql) and view delivery_reviews
--           (06_delivery_and_reviews.sql).
-- ============================================================================

-- COMMAND ----------

USE CATALOG workspace;
USE SCHEMA olist;

-- COMMAND ----------

-- 1. One row per seller: orders, revenue, and state

CREATE OR REPLACE VIEW seller_revenue AS
SELECT
  d.seller_id,
  s.seller_state,
  COUNT(DISTINCT d.order_id)  AS orders,
  ROUND(SUM(d.price), 2)      AS revenue
FROM delivered_items d
JOIN sellers s ON d.seller_id = s.seller_id
GROUP BY d.seller_id, s.seller_state;

-- COMMAND ----------

-- 2. Check: totals should match the headline KPIs (revenue 13,181,027.13)

SELECT
  COUNT(*)                AS active_sellers,
  ROUND(SUM(revenue), 2)  AS total_revenue,
  SUM(orders)             AS seller_order_links
FROM seller_revenue;

-- COMMAND ----------

-- 3. Revenue concentration: share of revenue earned by the top X% of sellers

WITH ranked AS (
  SELECT
    seller_id,
    revenue,
    ROW_NUMBER() OVER (ORDER BY revenue DESC, seller_id) AS rnk,
    COUNT(*)     OVER ()                                 AS total_sellers,
    SUM(revenue) OVER ()                                 AS total_revenue
  FROM seller_revenue
),
cuts AS (
  SELECT EXPLODE(ARRAY(1, 5, 10, 20, 50)) AS pct
)
SELECT
  c.pct                                                  AS top_pct_of_sellers,
  COUNT(*)                                               AS sellers,
  ROUND(SUM(r.revenue), 2)                               AS revenue,
  ROUND(100.0 * SUM(r.revenue) / MAX(r.total_revenue), 2) AS pct_of_revenue
FROM cuts c
JOIN ranked r
  ON r.rnk <= CEIL(r.total_sellers * c.pct / 100.0)
GROUP BY c.pct
ORDER BY c.pct;

-- COMMAND ----------

-- 4. Sellers by order volume

SELECT
  CASE
    WHEN orders = 1                THEN '1. one order'
    WHEN orders BETWEEN 2 AND 5    THEN '2. 2 to 5 orders'
    WHEN orders BETWEEN 6 AND 20   THEN '3. 6 to 20 orders'
    WHEN orders BETWEEN 21 AND 100 THEN '4. 21 to 100 orders'
    ELSE                                '5. more than 100 orders'
  END                                                         AS order_volume,
  COUNT(*)                                                    AS sellers,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_of_sellers,
  ROUND(SUM(revenue), 2)                                      AS revenue,
  ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2)  AS pct_of_revenue
FROM seller_revenue
GROUP BY 1
ORDER BY 1;

-- COMMAND ----------

-- 5. Seller locations: top 10 states by revenue
-- Percentages are shares of the whole marketplace, not of the top 10.

SELECT
  seller_state,
  COUNT(*)                                                     AS sellers,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)           AS pct_of_sellers,
  ROUND(SUM(revenue), 2)                                       AS revenue,
  ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2)   AS pct_of_revenue
FROM seller_revenue
GROUP BY seller_state
ORDER BY revenue DESC
LIMIT 10;

-- COMMAND ----------

-- 6. Orders that contain items from exactly one seller.
-- The check below compares them with all delivered orders in scope
-- (expected all_orders = 96,211; the gap is at most 1,338).

CREATE OR REPLACE VIEW seller_orders AS
SELECT
  order_id,
  MAX(seller_id)  AS seller_id,
  SUM(price)      AS revenue
FROM delivered_items
GROUP BY order_id
HAVING COUNT(DISTINCT seller_id) = 1;

SELECT
  COUNT(*)                                                    AS single_seller_orders,
  (SELECT COUNT(DISTINCT order_id) FROM delivered_items)      AS all_orders
FROM seller_orders;

-- COMMAND ----------

-- 7. Delivery performance when seller and customer are in the same state
-- versus different states (single-seller orders with a delivery date).
-- avg_score includes reviews answered before and after delivery.

SELECT
  CASE WHEN s.seller_state = d.customer_state
       THEN 'same state' ELSE 'different state' END           AS route,
  COUNT(*)                                                    AS orders,
  ROUND(AVG(d.delivery_days), 1)                              AS avg_days,
  ROUND(PERCENTILE(d.delivery_days, 0.5), 1)                  AS median_days,
  ROUND(100.0 * COUNT_IF(d.is_late) / COUNT(*), 1)            AS late_pct,
  ROUND(AVG(d.review_score), 2)                               AS avg_score
FROM seller_orders o
JOIN sellers s          ON o.seller_id = s.seller_id
JOIN delivery_reviews d ON o.order_id = d.order_id
GROUP BY 1
ORDER BY 1;

-- COMMAND ----------

-- 8. One row per seller: delivery performance on single-seller orders.
-- The check below returns the number of sellers, orders, and late orders.

CREATE OR REPLACE VIEW seller_delivery AS
SELECT
  o.seller_id,
  s.seller_state,
  COUNT(*)                                          AS orders,
  COUNT_IF(d.is_late)                               AS late_orders,
  ROUND(100.0 * COUNT_IF(d.is_late) / COUNT(*), 1)  AS late_pct,
  ROUND(AVG(d.delivery_days), 1)                    AS avg_delivery_days,
  ROUND(AVG(d.review_score), 2)                     AS avg_score
FROM seller_orders o
JOIN sellers s          ON o.seller_id = s.seller_id
JOIN delivery_reviews d ON o.order_id = d.order_id
GROUP BY o.seller_id, s.seller_state;

SELECT
  COUNT(*)           AS sellers,
  SUM(orders)        AS orders,
  SUM(late_orders)   AS late_orders
FROM seller_delivery;

-- COMMAND ----------

-- 9. Concentration of late orders: share of all late orders (and of all
-- orders) accounted for by the sellers with the most late orders.

WITH ranked AS (
  SELECT
    seller_id,
    orders,
    late_orders,
    ROW_NUMBER() OVER (ORDER BY late_orders DESC, seller_id) AS rnk,
    SUM(late_orders) OVER ()                                 AS total_late,
    SUM(orders)      OVER ()                                 AS total_orders
  FROM seller_delivery
),
cuts AS (
  SELECT EXPLODE(ARRAY(10, 25, 50, 100, 250)) AS top_n
)
SELECT
  c.top_n                                                       AS top_sellers_by_late_orders,
  SUM(r.late_orders)                                            AS late_orders,
  ROUND(100.0 * SUM(r.late_orders) / MAX(r.total_late), 1)      AS pct_of_late_orders,
  ROUND(100.0 * SUM(r.orders)      / MAX(r.total_orders), 1)    AS pct_of_orders
FROM cuts c
JOIN ranked r ON r.rnk <= c.top_n
GROUP BY c.top_n
ORDER BY c.top_n;

-- COMMAND ----------

-- 10. Late rate by seller order volume (pooled over all orders in each band)

SELECT
  CASE
    WHEN orders = 1                THEN '1. one order'
    WHEN orders BETWEEN 2 AND 5    THEN '2. 2 to 5 orders'
    WHEN orders BETWEEN 6 AND 20   THEN '3. 6 to 20 orders'
    WHEN orders BETWEEN 21 AND 100 THEN '4. 21 to 100 orders'
    ELSE                                '5. more than 100 orders'
  END                                                         AS seller_order_volume,
  COUNT(*)                                                    AS sellers,
  SUM(orders)                                                 AS orders,
  SUM(late_orders)                                            AS late_orders,
  ROUND(100.0 * SUM(late_orders) / SUM(orders), 1)            AS late_pct
FROM seller_delivery
GROUP BY 1
ORDER BY 1;

-- COMMAND ----------

-- 11. The ten sellers with the highest late rate among sellers with at
-- least 50 orders

SELECT
  seller_id,
  seller_state,
  orders,
  late_orders,
  late_pct,
  avg_delivery_days,
  avg_score
FROM seller_delivery
WHERE orders >= 50
ORDER BY late_pct DESC, orders DESC
LIMIT 10;

-- COMMAND ----------

-- 12. RJ customers: late rate in Nov 2017 to Mar 2018 versus other months,
-- by whether the seller is in SP

SELECT
  CASE WHEN d.order_purchase_timestamp >= '2017-11-01'
        AND d.order_purchase_timestamp <  '2018-04-01'
       THEN '1. Nov 2017 to Mar 2018' ELSE '2. other months' END  AS period,
  CASE WHEN s.seller_state = 'SP'
       THEN 'seller in SP' ELSE 'seller outside SP' END           AS seller_location,
  COUNT(*)                                                        AS orders,
  COUNT_IF(d.is_late)                                             AS late_orders,
  ROUND(100.0 * COUNT_IF(d.is_late) / COUNT(*), 1)                AS late_pct
FROM seller_orders o
JOIN sellers s          ON o.seller_id = s.seller_id
JOIN delivery_reviews d ON o.order_id = d.order_id
WHERE d.customer_state = 'RJ'
GROUP BY 1, 2
ORDER BY 1, 2;

-- COMMAND ----------

-- 13. RJ customers, Nov 2017 to Mar 2018: how concentrated are the late
-- orders among sellers?

WITH rj AS (
  SELECT
    o.seller_id,
    COUNT(*)            AS orders,
    COUNT_IF(d.is_late) AS late_orders
  FROM seller_orders o
  JOIN delivery_reviews d ON o.order_id = d.order_id
  WHERE d.customer_state = 'RJ'
    AND d.order_purchase_timestamp >= '2017-11-01'
    AND d.order_purchase_timestamp <  '2018-04-01'
  GROUP BY o.seller_id
),
ranked AS (
  SELECT
    seller_id,
    orders,
    late_orders,
    ROW_NUMBER() OVER (ORDER BY late_orders DESC, seller_id) AS rnk,
    COUNT(*)         OVER ()                                 AS sellers_involved,
    SUM(late_orders) OVER ()                                 AS total_late,
    SUM(orders)      OVER ()                                 AS total_orders
  FROM rj
),
cuts AS (
  SELECT EXPLODE(ARRAY(5, 10, 20, 50)) AS top_n
)
SELECT
  c.top_n                                                       AS top_sellers_by_late_orders,
  MAX(r.sellers_involved)                                       AS sellers_selling_to_rj,
  SUM(r.late_orders)                                            AS late_orders,
  ROUND(100.0 * SUM(r.late_orders) / MAX(r.total_late), 1)      AS pct_of_late_orders,
  ROUND(100.0 * SUM(r.orders)      / MAX(r.total_orders), 1)    AS pct_of_orders
FROM cuts c
JOIN ranked r ON r.rnk <= c.top_n
GROUP BY c.top_n
ORDER BY c.top_n;
