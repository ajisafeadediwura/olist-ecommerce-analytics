-- Databricks notebook source
-- ============================================================================
-- 03_eda.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Exploratory analysis of revenue, orders, and customers.
-- Scope   : Delivered orders; trend window Jan 2017 to Aug 2018.
--           Revenue = sum of item price (freight reported separately).
--           See docs/data_quality_notes.md for the rationale.
-- ============================================================================

-- COMMAND ----------

USE CATALOG workspace;
USE SCHEMA olist;

-- COMMAND ----------

-- Delivered order lines within the trend window, with the customer's unique ID.
-- One row per item, so order-level metrics must use COUNT(DISTINCT order_id).

CREATE OR REPLACE VIEW delivered_items AS
SELECT
  o.order_id,
  c.customer_unique_id,
  c.customer_state,
  o.order_purchase_timestamp,
  DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
  i.order_item_id,
  i.product_id,
  i.seller_id,
  i.price,
  i.freight_value
FROM orders o
JOIN customers c   ON o.customer_id = c.customer_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01';

-- COMMAND ----------
-- November spike(Black friday)
SELECT
  DATE(order_purchase_timestamp)                    AS order_date,
  COUNT(DISTINCT order_id)                          AS orders,
  ROUND(SUM(price), 2)                              AS revenue
FROM delivered_items
WHERE order_month = '2017-11-01'
GROUP BY 1
ORDER BY 1;
-- COMMAND ----------

-- Headline KPIs for the analysis window

SELECT
  COUNT(DISTINCT order_id)                          AS orders,
  COUNT(DISTINCT customer_unique_id)                AS customers,
  ROUND(SUM(price), 2)                              AS revenue,
  ROUND(SUM(freight_value), 2)                      AS freight,
  ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)   AS avg_order_value
FROM delivered_items;

-- COMMAND ----------

-- Monthly revenue, orders, and average order value

SELECT
  order_month,
  COUNT(DISTINCT order_id)                          AS orders,
  ROUND(SUM(price), 2)                              AS revenue,
  ROUND(SUM(price) / COUNT(DISTINCT order_id), 2)   AS avg_order_value
FROM delivered_items
GROUP BY order_month
ORDER BY order_month;

-- COMMAND ----------
-- Freight by state ----------
SELECT
  customer_state,
  COUNT(DISTINCT order_id)                              AS orders,
  ROUND(SUM(price), 2)                                  AS revenue,
  ROUND(SUM(freight_value), 2)                          AS freight,
  ROUND(100.0 * SUM(freight_value) / SUM(price), 1)     AS freight_pct_of_price
FROM delivered_items
GROUP BY customer_state
ORDER BY freight_pct_of_price DESC;

-- COMMAND ----------
-- Repeat customers ----------
WITH customer_orders AS (
  SELECT customer_unique_id, COUNT(DISTINCT order_id) AS orders
  FROM delivered_items
  GROUP BY customer_unique_id
)
SELECT
  COUNT(*)                                            AS customers,
  COUNT_IF(orders > 1)                                AS repeat_customers,
  ROUND(100.0 * COUNT_IF(orders > 1) / COUNT(*), 2)   AS repeat_rate_pct,
  MAX(orders)                                         AS max_orders_by_one_customer
FROM customer_orders;

-- COMMAND --------
-- Delivery by customer state--------
WITH delivered AS (
  SELECT
    c.customer_state,
    (UNIX_TIMESTAMP(o.order_delivered_customer_date)
       - UNIX_TIMESTAMP(o.order_purchase_timestamp)) / 86400.0   AS days_to_deliver,
    o.order_delivered_customer_date > o.order_estimated_delivery_date AS is_late
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
)
SELECT
  customer_state,
  COUNT(*)                                            AS orders,
  ROUND(AVG(days_to_deliver), 1)                      AS avg_days,
  ROUND(PERCENTILE(days_to_deliver, 0.5), 1)          AS median_days,
  ROUND(100.0 * COUNT_IF(is_late) / COUNT(*), 1)      AS late_pct
FROM delivered
GROUP BY customer_state
ORDER BY avg_days DESC;

-- COMMAND --------
-- Revenue by order of customer sales ---------
WITH customer_orders AS (
  SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price)               AS revenue
  FROM delivered_items
  GROUP BY customer_unique_id
)
SELECT
  CASE WHEN orders >= 4 THEN '4+' ELSE CAST(orders AS STRING) END AS orders_placed,
  COUNT(*)                                                        AS customers,
  ROUND(SUM(revenue), 2)                                          AS revenue,
  ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2)      AS pct_of_revenue
FROM customer_orders
GROUP BY 1
ORDER BY 1;

-- COMMAND --------
-- Promised versus actual delivery time ----------
WITH delivered AS (
  SELECT
    c.customer_state,
    (UNIX_TIMESTAMP(o.order_delivered_customer_date)
       - UNIX_TIMESTAMP(o.order_purchase_timestamp)) / 86400.0   AS actual_days,
    (UNIX_TIMESTAMP(o.order_estimated_delivery_date)
       - UNIX_TIMESTAMP(o.order_purchase_timestamp)) / 86400.0   AS promised_days
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
)
SELECT
  customer_state,
  COUNT(*)                                          AS orders,
  ROUND(AVG(promised_days), 1)                      AS avg_promised_days,
  ROUND(AVG(actual_days), 1)                        AS avg_actual_days,
  ROUND(AVG(promised_days - actual_days), 1)        AS avg_days_early
FROM delivered
GROUP BY customer_state
ORDER BY avg_days_early DESC;

-- COMMAND -----
-- Revenue by product category --------
WITH lines AS (
  SELECT d.order_id, d.price, d.freight_value, p.product_category_name
  FROM delivered_items d
  JOIN products p ON d.product_id = p.product_id
)
SELECT
  COALESCE(l.product_category_name, 'unknown')                  AS category_pt,
  t.product_category_name_english                               AS category_en,
  COUNT(DISTINCT l.order_id)                                    AS orders,
  ROUND(SUM(l.price), 2)                                        AS revenue,
  ROUND(100.0 * SUM(l.price) / SUM(SUM(l.price)) OVER (), 2)    AS pct_of_revenue,
  ROUND(100.0 * SUM(l.freight_value) / SUM(l.price), 1)         AS freight_pct_of_price
FROM lines l
LEFT JOIN product_category_translation t
  ON l.product_category_name = t.product_category_name
GROUP BY 1, 2
ORDER BY revenue DESC;

-- COMMAND --------
-- Payment method -------
WITH payments AS (
  SELECT
    order_id,
    SUM(payment_value)               AS paid,
    MAX_BY(payment_type, payment_value) AS primary_type,
    MAX(payment_installments)        AS max_installments
  FROM order_payments
  WHERE payment_value > 0
  GROUP BY order_id
),
in_scope AS (
  SELECT DISTINCT order_id FROM delivered_items
)
SELECT
  p.primary_type,
  COUNT(*)                                            AS orders,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)  AS pct_of_orders,
  ROUND(AVG(p.paid), 2)                               AS avg_paid,
  ROUND(AVG(p.max_installments), 1)                   AS avg_installments
FROM payments p
JOIN in_scope s USING (order_id)
GROUP BY p.primary_type
ORDER BY orders DESC;

-- COMMAND ---------
-- Credit card installment --------
WITH payments AS (
  SELECT
    order_id,
    SUM(payment_value)                  AS paid,
    MAX_BY(payment_type, payment_value) AS primary_type,
    MAX(payment_installments)           AS installments
  FROM order_payments
  WHERE payment_value > 0
  GROUP BY order_id
),
in_scope AS (
  SELECT DISTINCT order_id FROM delivered_items
)
SELECT
  CASE WHEN installments < 1 THEN '0 (invalid)'
       WHEN installments = 1 THEN '1'
       WHEN installments BETWEEN 2 AND 3 THEN '2-3'
       WHEN installments BETWEEN 4 AND 6 THEN '4-6'
       WHEN installments BETWEEN 7 AND 10 THEN '7-10'
       ELSE '11+' END                                     AS installment_band,
  COUNT(*)                                                AS orders,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)      AS pct_of_card_orders,
  ROUND(AVG(paid), 2)                                     AS avg_paid,
  ROUND(PERCENTILE(paid, 0.5), 2)                         AS median_paid
FROM payments
JOIN in_scope USING (order_id)
WHERE primary_type = 'credit_card'
GROUP BY 1
ORDER BY MIN(installments);











