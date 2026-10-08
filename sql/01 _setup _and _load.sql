-- Databricks notebook source
-- ============================================================================
-- 01_setup_and_load.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Create the project schema and source-file volume, then load the
--           Olist CSV files into tables for analysis.
-- Source  : Brazilian E-Commerce Public Dataset by Olist (Kaggle)
-- Scope   : The geolocation file is excluded. Location analysis uses the
--           customer and seller state/city fields.
-- ============================================================================

-- COMMAND ----------

-- 1. Schema and volume

USE CATALOG workspace;

CREATE SCHEMA IF NOT EXISTS olist
COMMENT 'Olist Brazilian e-commerce analysis: raw tables and analysis views';

USE SCHEMA olist;

CREATE VOLUME IF NOT EXISTS raw_files
COMMENT 'Source CSV files downloaded from Kaggle';

-- COMMAND ----------

-- 2. Load source tables
-- Source files are read from /Volumes/workspace/olist/raw_files/.
-- Column types are declared explicitly. Timestamps are read as strings and
-- cast, and ZIP code prefixes stay as strings to preserve leading zeros.
-- Two misspelled source columns are corrected on load:
-- product_name_lenght -> product_name_length,
-- product_description_lenght -> product_description_length.

CREATE OR REPLACE TABLE customers AS
SELECT *
FROM read_files(
  '/Volumes/workspace/olist/raw_files/olist_customers_dataset.csv',
  format => 'csv',
  header => true,
  schema => 'customer_id STRING, customer_unique_id STRING,
             customer_zip_code_prefix STRING, customer_city STRING,
             customer_state STRING'
);

-- COMMAND ----------

CREATE OR REPLACE TABLE orders AS
SELECT
  order_id,
  customer_id,
  order_status,
  CAST(order_purchase_timestamp      AS TIMESTAMP) AS order_purchase_timestamp,
  CAST(order_approved_at             AS TIMESTAMP) AS order_approved_at,
  CAST(order_delivered_carrier_date  AS TIMESTAMP) AS order_delivered_carrier_date,
  CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
  CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date
FROM read_files(
  '/Volumes/workspace/olist/raw_files/olist_orders_dataset.csv',
  format => 'csv',
  header => true,
  schema => 'order_id STRING, customer_id STRING, order_status STRING,
             order_purchase_timestamp STRING, order_approved_at STRING,
             order_delivered_carrier_date STRING,
             order_delivered_customer_date STRING,
             order_estimated_delivery_date STRING'
);

-- COMMAND ----------

CREATE OR REPLACE TABLE order_items AS
SELECT
  order_id,
  order_item_id,
  product_id,
  seller_id,
  CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
  price,
  freight_value
FROM read_files(
  '/Volumes/workspace/olist/raw_files/olist_order_items_dataset.csv',
  format => 'csv',
  header => true,
  schema => 'order_id STRING, order_item_id INT, product_id STRING,
             seller_id STRING, shipping_limit_date STRING,
             price DECIMAL(10,2), freight_value DECIMAL(10,2)'
);

-- COMMAND ----------

CREATE OR REPLACE TABLE order_payments AS
SELECT *
FROM read_files(
  '/Volumes/workspace/olist/raw_files/olist_order_payments_dataset.csv',
  format => 'csv',
  header => true,
  schema => 'order_id STRING, payment_sequential INT, payment_type STRING,
             payment_installments INT, payment_value DECIMAL(10,2)'
);

-- COMMAND ----------

-- Review comments contain quoted, multi-line text, so multiLine and
-- quote escaping are enabled for this file.

CREATE OR REPLACE TABLE order_reviews AS
SELECT
  review_id,
  order_id,
  review_score,
  review_comment_title,
  review_comment_message,
  CAST(review_creation_date    AS TIMESTAMP) AS review_creation_date,
  CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM read_files(
  '/Volumes/workspace/olist/raw_files/olist_order_reviews_dataset.csv',
  format => 'csv',
  header => true,
  multiLine => true,
  escape => '"',
  schema => 'review_id STRING, order_id STRING, review_score INT,
             review_comment_title STRING, review_comment_message STRING,
             review_creation_date STRING, review_answer_timestamp STRING'
);

-- COMMAND ----------

CREATE OR REPLACE TABLE products AS
SELECT *
FROM read_files(
  '/Volumes/workspace/olist/raw_files/olist_products_dataset.csv',
  format => 'csv',
  header => true,
  schema => 'product_id STRING, product_category_name STRING,
             product_name_length INT, product_description_length INT,
             product_photos_qty INT, product_weight_g INT,
             product_length_cm INT, product_height_cm INT,
             product_width_cm INT'
);

-- COMMAND ----------

CREATE OR REPLACE TABLE sellers AS
SELECT *
FROM read_files(
  '/Volumes/workspace/olist/raw_files/olist_sellers_dataset.csv',
  format => 'csv',
  header => true,
  schema => 'seller_id STRING, seller_zip_code_prefix STRING,
             seller_city STRING, seller_state STRING'
);

-- COMMAND ----------

CREATE OR REPLACE TABLE product_category_translation AS
SELECT *
FROM read_files(
  '/Volumes/workspace/olist/raw_files/product_category_name_translation.csv',
  format => 'csv',
  header => true,
  schema => 'product_category_name STRING, product_category_name_english STRING'
);

-- COMMAND ----------

-- 3. Load validation
-- Row counts should match the published dataset:
-- customers 99,441 | orders 99,441 | order_items 112,650 | order_payments 103,886
-- order_reviews 99,224 | products 32,951 | sellers 3,095 | translation 71

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'orders',                       COUNT(*) FROM orders
UNION ALL SELECT 'order_items',                  COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments',               COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',                COUNT(*) FROM order_reviews
UNION ALL SELECT 'products',                     COUNT(*) FROM products
UNION ALL SELECT 'sellers',                      COUNT(*) FROM sellers
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM product_category_translation;
