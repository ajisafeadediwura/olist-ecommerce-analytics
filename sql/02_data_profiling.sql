-- Databricks notebook source
-- ============================================================================
-- 02_data_profiling.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Validate keys, completeness, referential integrity, and date
--           coverage before analysis. Findings are recorded in
--           docs/data_quality_notes.md.
-- ============================================================================

-- COMMAND ----------

USE CATALOG workspace;
USE SCHEMA olist;

-- COMMAND ----------

-- 1. Key uniqueness
-- Expected: orders, customers (customer_id), products, sellers are unique.
-- order_reviews and order_payments are not unique per order.

SELECT 'orders.order_id'          AS key_checked, COUNT(*) AS total_rows, COUNT(DISTINCT order_id)          AS distinct_keys FROM orders
UNION ALL
SELECT 'customers.customer_id',                   COUNT(*), COUNT(DISTINCT customer_id)        FROM customers
UNION ALL
SELECT 'customers.customer_unique_id',            COUNT(*), COUNT(DISTINCT customer_unique_id) FROM customers
UNION ALL
SELECT 'products.product_id',                     COUNT(*), COUNT(DISTINCT product_id)         FROM products
UNION ALL
SELECT 'sellers.seller_id',                       COUNT(*), COUNT(DISTINCT seller_id)          FROM sellers
UNION ALL
SELECT 'order_reviews.review_id',                 COUNT(*), COUNT(DISTINCT review_id)          FROM order_reviews
UNION ALL
SELECT 'order_reviews.order_id',                  COUNT(*), COUNT(DISTINCT order_id)           FROM order_reviews;

-- COMMAND ----------

-- 2. Order status distribution

SELECT
  order_status,
  COUNT(*)                                          AS orders,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- COMMAND ----------

-- 3. Timestamp completeness by order status
-- Delivery dates should be populated for delivered orders only.

SELECT
  order_status,
  COUNT(*)                                                   AS orders,
  COUNT(*) - COUNT(order_approved_at)                        AS null_approved,
  COUNT(*) - COUNT(order_delivered_carrier_date)             AS null_carrier_date,
  COUNT(*) - COUNT(order_delivered_customer_date)            AS null_customer_delivery
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- COMMAND ----------

-- 4. Date coverage: orders per month
-- Used to decide which months are complete enough for trend analysis.

SELECT
  DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
  COUNT(*)                                      AS orders
FROM orders
GROUP BY 1
ORDER BY 1;

-- COMMAND ----------

-- 5. Referential integrity (orphan checks). Every count should be 0 unless noted.

SELECT 'orders without a customer' AS check_name, COUNT(*) AS violations
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'order_items without an order', COUNT(*)
FROM order_items i LEFT JOIN orders o ON i.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'order_items without a product', COUNT(*)
FROM order_items i LEFT JOIN products p ON i.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'order_items without a seller', COUNT(*)
FROM order_items i LEFT JOIN sellers s ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL
UNION ALL
SELECT 'order_payments without an order', COUNT(*)
FROM order_payments p LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'order_reviews without an order', COUNT(*)
FROM order_reviews r LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL
UNION ALL
-- Not necessarily an error: orders that never reached an items record
SELECT 'orders without items', COUNT(*)
FROM orders o LEFT JOIN order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL
UNION ALL
SELECT 'orders without payments', COUNT(*)
FROM orders o LEFT JOIN order_payments p ON o.order_id = p.order_id
WHERE p.order_id IS NULL
UNION ALL
SELECT 'orders without a review', COUNT(*)
FROM orders o LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

-- COMMAND ----------

-- 6. Payments reconciliation
-- Compares what was paid with items plus freight, at order grain.
-- Aggregating before joining avoids multiplying rows across the two tables.

WITH items AS (
  SELECT order_id, SUM(price + freight_value) AS items_total
  FROM order_items
  GROUP BY order_id
),
paid AS (
  SELECT order_id, SUM(payment_value) AS paid_total
  FROM order_payments
  GROUP BY order_id
)
SELECT
  COUNT(*)                                          AS orders_compared,
  COUNT_IF(ABS(items_total - paid_total) > 1)       AS orders_off_by_more_than_1,
  ROUND(SUM(items_total), 2)                        AS total_items_value,
  ROUND(SUM(paid_total), 2)                         AS total_paid_value
FROM items
JOIN paid USING (order_id);

-- COMMAND ----------

-- 7. Multiple rows per order in payments and reviews

SELECT 'payments: orders with more than one payment row' AS check_name, COUNT(*) AS orders
FROM (SELECT order_id FROM order_payments GROUP BY order_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'reviews: orders with more than one review', COUNT(*)
FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1);

-- COMMAND ----------

-- 8. Products: missing categories and missing translations

SELECT 'products with null category' AS check_name, COUNT(*) AS products
FROM products
WHERE product_category_name IS NULL
UNION ALL
SELECT 'categories without an English translation', COUNT(DISTINCT p.product_category_name)
FROM products p
LEFT JOIN product_category_translation t
  ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;

-- COMMAND ----------

-- 9. Value sanity checks

SELECT 'non-positive price'                   AS check_name, COUNT(*) AS violations FROM order_items WHERE price <= 0
UNION ALL
SELECT 'negative freight',                    COUNT(*) FROM order_items WHERE freight_value < 0
UNION ALL
SELECT 'zero or negative payment value',      COUNT(*) FROM order_payments WHERE payment_value <= 0
UNION ALL
SELECT 'review score outside 1-5',            COUNT(*) FROM order_reviews WHERE review_score NOT BETWEEN 1 AND 5
UNION ALL
SELECT 'delivered before purchase',           COUNT(*) FROM orders
  WHERE order_delivered_customer_date < order_purchase_timestamp
UNION ALL
SELECT 'delivered to customer before carrier pickup', COUNT(*) FROM orders
  WHERE order_delivered_customer_date < order_delivered_carrier_date;

-- COMMAND ----------

-- 10. Distribution summaries for key numeric fields

SELECT
  ROUND(MIN(price), 2)                      AS min_price,
  ROUND(PERCENTILE(price, 0.5), 2)          AS median_price,
  ROUND(AVG(price), 2)                      AS avg_price,
  ROUND(PERCENTILE(price, 0.95), 2)         AS p95_price,
  ROUND(MAX(price), 2)                      AS max_price,
  ROUND(PERCENTILE(freight_value, 0.5), 2)  AS median_freight,
  ROUND(MAX(freight_value), 2)              AS max_freight
FROM order_items;
