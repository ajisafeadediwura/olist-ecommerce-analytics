-- Databricks notebook source
-- ============================================================================
-- 04_cohort_retention.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Measure how many customers return after their first purchase.
-- Scope   : Delivered orders, Jan 2017 to Aug 2018, using the delivered_items
--           view from 03_eda.sql. Customers are identified by
--           customer_unique_id; a cohort is the month of a customer's first
--           delivered order in the window.
-- ============================================================================

-- COMMAND ----------

USE CATALOG workspace;
USE SCHEMA olist;

-- COMMAND ----------

-- 1. Retention by cohort: one row per cohort month and months since first purchase

WITH customer_months AS (
  SELECT DISTINCT customer_unique_id, order_month
  FROM delivered_items
),
cohorts AS (
  SELECT customer_unique_id, MIN(order_month) AS cohort_month
  FROM customer_months
  GROUP BY customer_unique_id
),
activity AS (
  SELECT
    c.cohort_month,
    CAST(MONTHS_BETWEEN(m.order_month, c.cohort_month) AS INT) AS months_since_first,
    COUNT(DISTINCT m.customer_unique_id)                       AS active_customers
  FROM customer_months m
  JOIN cohorts c ON m.customer_unique_id = c.customer_unique_id
  GROUP BY 1, 2
)
SELECT
  cohort_month,
  months_since_first,
  active_customers,
  MAX(CASE WHEN months_since_first = 0 THEN active_customers END)
    OVER (PARTITION BY cohort_month)                           AS cohort_size,
  ROUND(100.0 * active_customers
    / MAX(CASE WHEN months_since_first = 0 THEN active_customers END)
        OVER (PARTITION BY cohort_month), 2)                   AS retention_pct
FROM activity
ORDER BY cohort_month, months_since_first;

-- COMMAND ----------

-- 2. Pooled retention by months since first purchase
-- Only cohorts with a full follow-up period are included at each offset. For
-- example, the Aug 2018 cohort can be observed at month 0 only, so it is
-- excluded from month 1 onward.

WITH customer_months AS (
  SELECT DISTINCT customer_unique_id, order_month
  FROM delivered_items
),
cohorts AS (
  SELECT customer_unique_id, MIN(order_month) AS cohort_month
  FROM customer_months
  GROUP BY customer_unique_id
),
activity AS (
  SELECT
    c.cohort_month,
    CAST(MONTHS_BETWEEN(m.order_month, c.cohort_month) AS INT) AS months_since_first,
    COUNT(DISTINCT m.customer_unique_id)                       AS active_customers
  FROM customer_months m
  JOIN cohorts c ON m.customer_unique_id = c.customer_unique_id
  GROUP BY 1, 2
),
cohort_sizes AS (
  SELECT cohort_month, active_customers AS cohort_size
  FROM activity
  WHERE months_since_first = 0
),
offsets AS (
  SELECT EXPLODE(SEQUENCE(0, 19)) AS months_since_first
),
eligible AS (
  SELECT o.months_since_first, s.cohort_month, s.cohort_size
  FROM offsets o
  JOIN cohort_sizes s
    ON CAST(s.cohort_month AS DATE)
       <= ADD_MONTHS(DATE'2018-08-01', -o.months_since_first)
)
SELECT
  e.months_since_first,
  COUNT(*)                                                       AS cohorts_included,
  SUM(e.cohort_size)                                             AS customers_in_cohorts,
  COALESCE(SUM(a.active_customers), 0)                           AS active_customers,
  ROUND(100.0 * COALESCE(SUM(a.active_customers), 0)
        / SUM(e.cohort_size), 2)                                 AS retention_pct
FROM eligible e
LEFT JOIN activity a
  ON a.cohort_month = e.cohort_month
 AND a.months_since_first = e.months_since_first
GROUP BY e.months_since_first
ORDER BY e.months_since_first;
