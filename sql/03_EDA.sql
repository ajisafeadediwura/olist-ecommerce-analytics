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
