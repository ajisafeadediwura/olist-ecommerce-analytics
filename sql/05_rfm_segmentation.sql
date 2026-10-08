-- Databricks notebook source
-- ============================================================================
-- 05_rfm_segmentation.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Segment customers by recency, spend, and repeat behaviour.
-- Scope   : Delivered orders, Jan 2017 to Aug 2018, by customer_unique_id.
--           Recency is measured to 2018-09-01, the day after the window ends.
--           Frequency is not scored: 97% of customers placed one order, so it
--           is used as a repeat / one-time split.
-- ============================================================================

-- COMMAND ----------

USE CATALOG workspace;
USE SCHEMA olist;

-- COMMAND ----------

-- 1. Customer-level RFM scores and segments

CREATE OR REPLACE VIEW customer_rfm AS
WITH customer_totals AS (
  SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id)  AS orders,
    ROUND(SUM(price), 2)      AS revenue,
    DATEDIFF(DATE'2018-09-01', MAX(DATE(order_purchase_timestamp))) AS recency_days
  FROM delivered_items
  GROUP BY customer_unique_id
),
scored AS (
  SELECT
    *,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY revenue ASC)       AS m_score
  FROM customer_totals
)
SELECT
  *,
  CASE
    WHEN orders >= 2                    THEN 'Repeat customers'
    WHEN m_score >= 4 AND r_score >= 4  THEN 'Recent high-value, one-time'
    WHEN m_score >= 4                   THEN 'Dormant high-value, one-time'
    WHEN r_score >= 4                   THEN 'Recent lower-value, one-time'
    ELSE                                     'Dormant lower-value, one-time'
  END AS segment
FROM scored;

-- COMMAND ----------

-- 2. Score check: what each score represents

SELECT 'recency (days since last order)' AS score_basis, r_score AS score,
       COUNT(*) AS customers, MIN(recency_days) AS min_value, MAX(recency_days) AS max_value
FROM customer_rfm GROUP BY r_score
UNION ALL
SELECT 'monetary (revenue)', m_score, COUNT(*), MIN(revenue), MAX(revenue)
FROM customer_rfm GROUP BY m_score
ORDER BY 1, 2;

-- COMMAND ----------

-- 3. Segment summary

SELECT
  segment,
  COUNT(*)                                                    AS customers,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)          AS pct_of_customers,
  ROUND(SUM(revenue), 2)                                      AS revenue,
  ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2)  AS pct_of_revenue,
  ROUND(AVG(revenue), 2)                                      AS avg_revenue_per_customer,
  ROUND(AVG(recency_days), 0)                                 AS avg_recency_days
FROM customer_rfm
GROUP BY segment
ORDER BY revenue DESC;
