-- Databricks notebook source
-- ============================================================================
-- 08_powerbi_views.sql
-- Project : Olist E-Commerce Analytics
-- Purpose : Create the views that the Power BI model reads. Two fact views
--           (orders and order items) and a set of dimension views, plus two
--           small summary views for the cohort heatmap and order status.
--           These are saved queries, not copies of the data.
-- Scope   : Delivered orders, Jan 2017 to Aug 2018 (96,211 orders), using the
--           definitions in docs/data_quality_notes.md. Revenue is the sum of
--           item price (freight excluded).
-- Requires: delivered_items (03_eda.sql), customer_rfm (05_rfm_segmentation.sql),
--           order_reviews_dedup (06_delivery_and_reviews.sql), seller_revenue
--           and seller_delivery (07_seller_analysis.sql).
-- ============================================================================

-- COMMAND ----------

USE CATALOG workspace;
USE SCHEMA olist;

-- COMMAND ----------

-- 1. State dimension: state name and region.
-- Region is the standard IBGE grouping of Brazilian states.

CREATE OR REPLACE VIEW pbi_dim_state AS
SELECT * FROM VALUES
  ('AC', 'Acre',                'North'),
  ('AL', 'Alagoas',             'Northeast'),
  ('AM', 'Amazonas',            'North'),
  ('AP', 'Amapá',               'North'),
  ('BA', 'Bahia',               'Northeast'),
  ('CE', 'Ceará',               'Northeast'),
  ('DF', 'Distrito Federal',    'Central-West'),
  ('ES', 'Espírito Santo',      'Southeast'),
  ('GO', 'Goiás',               'Central-West'),
  ('MA', 'Maranhão',            'Northeast'),
  ('MG', 'Minas Gerais',        'Southeast'),
  ('MS', 'Mato Grosso do Sul',  'Central-West'),
  ('MT', 'Mato Grosso',         'Central-West'),
  ('PA', 'Pará',                'North'),
  ('PB', 'Paraíba',             'Northeast'),
  ('PE', 'Pernambuco',          'Northeast'),
  ('PI', 'Piauí',               'Northeast'),
  ('PR', 'Paraná',              'South'),
  ('RJ', 'Rio de Janeiro',      'Southeast'),
  ('RN', 'Rio Grande do Norte', 'Northeast'),
  ('RO', 'Rondônia',            'North'),
  ('RR', 'Roraima',             'North'),
  ('RS', 'Rio Grande do Sul',   'South'),
  ('SC', 'Santa Catarina',      'South'),
  ('SE', 'Sergipe',             'Northeast'),
  ('SP', 'São Paulo',           'Southeast'),
  ('TO', 'Tocantins',           'North')
AS t(state_code, state_name, region);

-- COMMAND ----------

-- 2. Date dimension: one row per day, Jan 2017 to Aug 2018, no gaps.

CREATE OR REPLACE VIEW pbi_dim_date AS
SELECT
  d                                        AS calendar_date,
  YEAR(d)                                  AS calendar_year,
  MONTH(d)                                 AS month_number,
  DATE_FORMAT(d, 'MMM')                    AS month_name,
  CAST(DATE_TRUNC('month', d) AS DATE)     AS month_start,
  DATE_FORMAT(d, 'yyyy-MM')                AS year_month,
  DATE_FORMAT(d, 'EEEE')                   AS day_name,
  DAYOFWEEK(d)                             AS day_of_week_number,
  CASE WHEN d BETWEEN DATE'2017-11-24' AND DATE'2017-11-30'
       THEN 'Black Friday week' END        AS event_period
FROM (
  SELECT EXPLODE(SEQUENCE(DATE'2017-01-01', DATE'2018-08-31', INTERVAL 1 DAY)) AS d
);

-- COMMAND ----------

-- 3. Category dimension.
-- Adds English names for two untranslated categories, corrects four
-- misspelled English labels in the source translation table, and adds an
-- 'unknown' row for products with no category.

CREATE OR REPLACE VIEW pbi_dim_category AS
WITH base AS (
  SELECT DISTINCT
    p.product_category_name AS category_pt,
    COALESCE(
      t.product_category_name_english,
      CASE p.product_category_name
        WHEN 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'portable_kitchen_and_food_preparers'
        WHEN 'pc_gamer' THEN 'pc_gamer'
      END
    ) AS category_en
  FROM products p
  LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
  WHERE p.product_category_name IS NOT NULL
),
cleaned AS (
  SELECT
    category_pt,
    CASE category_en
      WHEN 'home_confort'             THEN 'home_comfort'
      WHEN 'costruction_tools_garden' THEN 'construction_tools_garden'
      WHEN 'costruction_tools_tools'  THEN 'construction_tools_tools'
      WHEN 'fashio_female_clothing'   THEN 'fashion_female_clothing'
      ELSE category_en
    END AS category_en
  FROM base
)
SELECT
  category_pt,
  category_en,
  INITCAP(REPLACE(category_en, '_', ' ')) AS category_label
FROM cleaned
UNION ALL
SELECT 'unknown', 'unknown', 'Unknown';

-- COMMAND ----------

-- 4. Fact view, order grain: one row per delivered order in the window.
-- Delivery and review fields use the definitions from script 06. late_flag is
-- 1 or 0, and null when the order has no customer delivery date, so
-- AVERAGE(late_flag) in Power BI is the late rate. Sellers are attributed
-- only on single-seller orders. Do not create a relationship from this view
-- to the seller dimension.

CREATE OR REPLACE VIEW pbi_fact_orders AS
WITH order_lines AS (
  SELECT
    order_id,
    MAX(customer_unique_id)                                   AS customer_unique_id,
    MAX(customer_state)                                       AS customer_state,
    MIN(order_purchase_timestamp)                             AS order_purchase_timestamp,
    COUNT(*)                                                  AS items,
    ROUND(SUM(price), 2)                                      AS revenue,
    ROUND(SUM(freight_value), 2)                              AS freight,
    COUNT(DISTINCT seller_id)                                 AS sellers_in_order,
    CASE WHEN COUNT(DISTINCT seller_id) = 1 THEN MAX(seller_id) END AS single_seller_id
  FROM delivered_items
  GROUP BY order_id
),
payments AS (
  SELECT
    order_id,
    SUM(payment_value)                  AS paid_value,
    MAX_BY(payment_type, payment_value) AS primary_payment_type,
    MAX(payment_installments)           AS max_installments
  FROM order_payments
  WHERE payment_value > 0
  GROUP BY order_id
),
numbered AS (
  SELECT
    l.*,
    ROW_NUMBER() OVER (
      PARTITION BY customer_unique_id
      ORDER BY order_purchase_timestamp, order_id
    ) AS order_seq
  FROM order_lines l
),
timed AS (
  SELECT
    n.*,
    o.order_delivered_customer_date AS delivered_ts,
    (UNIX_TIMESTAMP(o.order_delivered_customer_date)
       - UNIX_TIMESTAMP(n.order_purchase_timestamp)) / 86400.0   AS delivery_days,
    (UNIX_TIMESTAMP(o.order_delivered_customer_date)
       - UNIX_TIMESTAMP(o.order_estimated_delivery_date)) / 86400.0 AS days_late
  FROM numbered n
  JOIN orders o ON n.order_id = o.order_id
)
SELECT
  t.order_id,
  t.customer_unique_id,
  t.customer_state,
  CAST(t.order_purchase_timestamp AS DATE)                          AS order_date,
  CAST(DATE_TRUNC('month', t.order_purchase_timestamp) AS DATE)     AS order_month,
  t.items,
  t.revenue,
  t.freight,
  t.sellers_in_order,
  s.seller_state,
  CASE
    WHEN t.single_seller_id IS NULL        THEN 'Multiple sellers'
    WHEN s.seller_state = t.customer_state THEN 'Same state'
    ELSE                                        'Different state'
  END                                                               AS route,
  p.primary_payment_type,
  p.max_installments,
  p.paid_value,
  CASE WHEN p.primary_payment_type = 'credit_card' THEN
    CASE WHEN p.max_installments < 1   THEN '0 (invalid)'
         WHEN p.max_installments = 1   THEN '1'
         WHEN p.max_installments <= 3  THEN '2 to 3'
         WHEN p.max_installments <= 6  THEN '4 to 6'
         WHEN p.max_installments <= 10 THEN '7 to 10'
         ELSE                               '11 or more' END
  END                                                               AS card_installment_band,
  t.delivery_days,
  t.days_late,
  CASE WHEN t.delivered_ts IS NULL THEN NULL
       WHEN t.days_late > 0        THEN 1
       ELSE 0 END                                                   AS late_flag,
  CASE WHEN t.delivered_ts IS NULL THEN 'No delivery date'
       WHEN t.days_late > 0        THEN 'Late'
       ELSE                             'On time or early' END       AS delivery_outcome,
  CASE WHEN t.delivered_ts IS NULL THEN 'No delivery date'
       WHEN t.days_late <= 0       THEN 'On time or early'
       WHEN t.days_late <= 3       THEN 'Up to 3 days late'
       WHEN t.days_late <= 7       THEN '3 to 7 days late'
       ELSE                             'More than 7 days late' END  AS lateness_band,
  CASE WHEN t.delivered_ts IS NULL THEN 5
       WHEN t.days_late <= 0       THEN 1
       WHEN t.days_late <= 3       THEN 2
       WHEN t.days_late <= 7       THEN 3
       ELSE                             4 END                       AS lateness_band_sort,
  r.review_score,
  CASE
    WHEN r.order_id IS NULL                          THEN 'No review'
    WHEN t.delivered_ts IS NULL                      THEN 'No delivery date'
    WHEN r.review_answer_timestamp < t.delivered_ts  THEN 'Before delivery'
    ELSE                                                  'On or after delivery'
  END                                                               AS review_timing,
  t.order_seq,
  CASE WHEN t.order_seq = 1 THEN 1 ELSE 0 END                       AS is_first_order
FROM timed t
LEFT JOIN sellers s              ON t.single_seller_id = s.seller_id
LEFT JOIN payments p             ON t.order_id = p.order_id
LEFT JOIN order_reviews_dedup r  ON t.order_id = r.order_id;

-- COMMAND ----------

-- 5. Fact view, item grain: one row per delivered item in the window.
-- Order attributes (date, customer state) come through the relationship to
-- pbi_fact_orders on order_id.

CREATE OR REPLACE VIEW pbi_fact_order_items AS
SELECT
  d.order_id,
  d.order_item_id,
  d.product_id,
  d.seller_id,
  COALESCE(p.product_category_name, 'unknown') AS category_pt,
  d.price,
  d.freight_value
FROM delivered_items d
LEFT JOIN products p ON d.product_id = p.product_id;

-- COMMAND ----------

-- 6. Customer dimension: one row per customer (customer_unique_id).
-- repeat_type is based on the gap between the first and last order dates.

CREATE OR REPLACE VIEW pbi_dim_customer AS
WITH spans AS (
  SELECT
    customer_unique_id,
    MIN(order_purchase_timestamp) AS first_order_ts,
    MAX(order_purchase_timestamp) AS last_order_ts
  FROM delivered_items
  GROUP BY customer_unique_id
)
SELECT
  r.customer_unique_id,
  r.orders,
  r.revenue,
  r.recency_days,
  r.r_score,
  r.m_score,
  r.segment,
  CAST(DATE_TRUNC('month', sp.first_order_ts) AS DATE) AS cohort_month,
  CASE
    WHEN r.orders = 1                                          THEN 'One-time'
    WHEN DATEDIFF(sp.last_order_ts, sp.first_order_ts) = 0     THEN 'Repeat, same day'
    WHEN DATEDIFF(sp.last_order_ts, sp.first_order_ts) <= 30   THEN 'Repeat, 1 to 30 days'
    ELSE                                                            'Repeat, over 30 days'
  END                                                          AS repeat_type
FROM customer_rfm r
JOIN spans sp ON r.customer_unique_id = sp.customer_unique_id;

-- COMMAND ----------

-- 7. Seller dimension: one row per seller (all 3,095, including sellers with
-- no delivered orders in the window). Revenue columns cover all delivered
-- orders. Delivery columns cover single-seller orders with a delivery date.
-- revenue_rank and cum_revenue_pct support a Pareto chart.

CREATE OR REPLACE VIEW pbi_dim_seller AS
WITH ranked AS (
  SELECT
    seller_id,
    ROW_NUMBER() OVER (ORDER BY revenue DESC, seller_id) AS revenue_rank,
    ROUND(100.0 * SUM(revenue) OVER (
            ORDER BY revenue DESC, seller_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
          / SUM(revenue) OVER (), 2)                     AS cum_revenue_pct
  FROM seller_revenue
)
SELECT
  s.seller_id,
  s.seller_state,
  st.region                                  AS seller_region,
  r.seller_id IS NOT NULL                    AS is_active,
  r.orders                                   AS orders,
  r.revenue                                  AS revenue,
  CASE
    WHEN r.orders IS NULL            THEN 'No delivered orders'
    WHEN r.orders = 1                THEN '1 order'
    WHEN r.orders <= 5               THEN '2 to 5 orders'
    WHEN r.orders <= 20              THEN '6 to 20 orders'
    WHEN r.orders <= 100             THEN '21 to 100 orders'
    ELSE                                  'More than 100 orders'
  END                                        AS volume_band,
  k.revenue_rank,
  k.cum_revenue_pct,
  d.orders                                   AS delivery_orders,
  d.late_orders,
  d.late_pct,
  d.avg_delivery_days
FROM sellers s
LEFT JOIN pbi_dim_state st   ON s.seller_state = st.state_code
LEFT JOIN seller_revenue r   ON s.seller_id = r.seller_id
LEFT JOIN ranked k           ON s.seller_id = k.seller_id
LEFT JOIN seller_delivery d  ON s.seller_id = d.seller_id;

-- COMMAND ----------

-- 8. Cohort retention for the heatmap: one row per cohort and month since
-- first purchase, including months with zero returning customers. Only months
-- that can be observed before the end of the window are included.

CREATE OR REPLACE VIEW pbi_cohort_retention AS
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
grid AS (
  SELECT s.cohort_month, s.cohort_size, o.months_since_first
  FROM cohort_sizes s
  JOIN (SELECT EXPLODE(SEQUENCE(0, 19)) AS months_since_first) o
    ON CAST(s.cohort_month AS DATE)
       <= ADD_MONTHS(DATE'2018-08-01', -o.months_since_first)
)
SELECT
  CAST(g.cohort_month AS DATE)                                  AS cohort_month,
  g.months_since_first,
  COALESCE(a.active_customers, 0)                               AS active_customers,
  g.cohort_size,
  ROUND(100.0 * COALESCE(a.active_customers, 0) / g.cohort_size, 2) AS retention_pct
FROM grid g
LEFT JOIN activity a
  ON a.cohort_month = g.cohort_month
 AND a.months_since_first = g.months_since_first;

-- COMMAND ----------

-- 9. Order status by month, all orders in the window (for the delivered share
-- and cancellation view on the executive page)

CREATE OR REPLACE VIEW pbi_order_status_by_month AS
SELECT
  CAST(DATE_TRUNC('month', order_purchase_timestamp) AS DATE) AS order_month,
  order_status,
  COUNT(*)                                                    AS orders
FROM orders
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY 1, 2;

-- COMMAND ----------

-- 10. Reconciliation of the model views.
-- Expected: pbi_fact_orders 96,211 rows and revenue 13,181,027.13;
-- pbi_fact_order_items revenue 13,181,027.13 and 96,211 distinct orders;
-- pbi_dim_customer 93,104 rows; pbi_dim_seller 3,095 rows (revenue
-- 13,181,027.13); pbi_dim_category 74 rows; pbi_dim_state 27 rows;
-- pbi_dim_date 608 rows.

SELECT 'pbi_fact_orders' AS view_name, COUNT(*) AS row_count,
       COUNT(DISTINCT order_id) AS distinct_keys, ROUND(SUM(revenue), 2) AS revenue
FROM pbi_fact_orders
UNION ALL
SELECT 'pbi_fact_order_items', COUNT(*), COUNT(DISTINCT order_id), ROUND(SUM(price), 2)
FROM pbi_fact_order_items
UNION ALL
SELECT 'pbi_dim_customer', COUNT(*), COUNT(DISTINCT customer_unique_id), ROUND(SUM(revenue), 2)
FROM pbi_dim_customer
UNION ALL
SELECT 'pbi_dim_seller', COUNT(*), COUNT(DISTINCT seller_id), ROUND(SUM(revenue), 2)
FROM pbi_dim_seller
UNION ALL
SELECT 'pbi_dim_category', COUNT(*), COUNT(DISTINCT category_pt), NULL
FROM pbi_dim_category
UNION ALL
SELECT 'pbi_dim_state', COUNT(*), COUNT(DISTINCT state_code), NULL
FROM pbi_dim_state
UNION ALL
SELECT 'pbi_dim_date', COUNT(*), COUNT(DISTINCT calendar_date), NULL
FROM pbi_dim_date;

-- COMMAND ----------

-- 11. Relationship checks: every fact key should find its dimension row
-- (all violations expected to be 0).

SELECT 'orders without a customer row' AS check_name, COUNT(*) AS violations
FROM pbi_fact_orders f
LEFT JOIN pbi_dim_customer c ON f.customer_unique_id = c.customer_unique_id
WHERE c.customer_unique_id IS NULL
UNION ALL
SELECT 'orders without a state row', COUNT(*)
FROM pbi_fact_orders f
LEFT JOIN pbi_dim_state s ON f.customer_state = s.state_code
WHERE s.state_code IS NULL
UNION ALL
SELECT 'orders without a date row', COUNT(*)
FROM pbi_fact_orders f
LEFT JOIN pbi_dim_date d ON f.order_date = d.calendar_date
WHERE d.calendar_date IS NULL
UNION ALL
SELECT 'items without an order row', COUNT(*)
FROM pbi_fact_order_items i
LEFT JOIN pbi_fact_orders f ON i.order_id = f.order_id
WHERE f.order_id IS NULL
UNION ALL
SELECT 'items without a category row', COUNT(*)
FROM pbi_fact_order_items i
LEFT JOIN pbi_dim_category c ON i.category_pt = c.category_pt
WHERE c.category_pt IS NULL
UNION ALL
SELECT 'items without a seller row', COUNT(*)
FROM pbi_fact_order_items i
LEFT JOIN pbi_dim_seller s ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;
