# Data Model

How the Olist data is organised for analysis and reporting. There is no separate warehouse layer. Source CSV files are loaded once into tables, all analysis runs on those tables through SQL views, and Power BI reads a small set of model views.

## Layers

| Layer | Objects | Created by |
|---|---|---|
| Source tables | `customers`, `orders`, `order_items`, `order_payments`, `order_reviews`, `products`, `sellers`, `product_category_translation` | `sql/01_setup_and_load.sql` |
| Analysis views | `delivered_items`, `customer_rfm`, `order_reviews_dedup`, `delivery_reviews`, `seller_revenue`, `seller_orders`, `seller_delivery` | `sql/03` to `sql/07` |
| Power BI model views | `pbi_*` (nine views, listed below) | `sql/08_powerbi_views.sql` |

All objects are in the schema `workspace.olist`. Views store queries, not data.

### View dependencies

| View | Reads | Defined in |
|---|---|---|
| `delivered_items` | `orders`, `customers`, `order_items` | `03_eda.sql` |
| `customer_rfm` | `delivered_items` | `05_rfm_segmentation.sql` |
| `order_reviews_dedup` | `order_reviews` | `06_delivery_and_reviews.sql` |
| `delivery_reviews` | `orders`, `customers`, `order_reviews_dedup` | `06_delivery_and_reviews.sql` |
| `seller_revenue` | `delivered_items`, `sellers` | `07_seller_analysis.sql` |
| `seller_orders` | `delivered_items` | `07_seller_analysis.sql` |
| `seller_delivery` | `seller_orders`, `sellers`, `delivery_reviews` | `07_seller_analysis.sql` |
| `pbi_*` | the views above and the source tables | `08_powerbi_views.sql` |

Run the scripts in numerical order.

## Scope and definitions

These apply to every view and to the report. The reasoning is in `docs/data_quality_notes.md`.

| Item | Definition |
|---|---|
| Orders in scope | Delivered orders placed from 2017-01-01 to 2018-08-31 (96,211 orders) |
| Revenue | Sum of item price. Freight is reported separately |
| Customer | `customer_unique_id`. `customer_id` changes with every order and is not used for customer analysis |
| Late order | Delivered after the estimated delivery timestamp. Requires a customer delivery date (8 delivered orders have none) |
| Review | One per order: the most recent, ordered by answer timestamp, then creation date, then `review_id` |
| Seller attribution | Delivery performance is attributed to a seller only on orders whose items all come from one seller (98.7% of orders) |
| Excluded | 2016 orders, Sep and Oct 2018 orders, and orders that were not delivered. The geolocation file is not used |

## Power BI model

### Views

| View (Power BI name) | Grain | Expected rows | Purpose |
|---|---|---|---|
| `pbi_fact_orders` (Orders) | One delivered order | 96,211 | Revenue, orders, delivery, lateness, reviews, payments, repeat order flags |
| `pbi_fact_order_items` (Order Items) | One delivered item | one per item | Revenue by category and seller |
| `pbi_dim_customer` (Customers) | One customer | 93,104 | RFM segment, cohort month, repeat type |
| `pbi_dim_seller` (Sellers) | One seller | 3,095 | Seller revenue, rank, delivery performance |
| `pbi_dim_category` (Categories) | One category | 74 | Category names, with an `unknown` row |
| `pbi_dim_state` (States) | One state | 27 | State name and region |
| `pbi_dim_date` (Dates) | One day | 608 | Continuous calendar for Jan 2017 to Aug 2018 |
| `pbi_cohort_retention` (Cohort Retention) | Cohort and month since first purchase | not related | Retention heatmap |
| `pbi_order_status_by_month` (Order Status) | Month and order status | not related | Delivered share and cancellations |

### Relationships

All are many to one with single-direction filtering.

| Many side | One side |
|---|---|
| `Orders[order_date]` | `Dates[calendar_date]` |
| `Orders[customer_state]` | `States[state_code]` |
| `Orders[customer_unique_id]` | `Customers[customer_unique_id]` |
| `Order Items[order_id]` | `Orders[order_id]` |
| `Order Items[category_pt]` | `Categories[category_pt]` |
| `Order Items[seller_id]` | `Sellers[seller_id]` |

The seller dimension is deliberately not related to `Orders`. That would create a second path between sellers and orders through the items. Seller delivery figures are stored on the seller dimension instead.

### Columns

**pbi_fact_orders**

| Column | Description |
|---|---|
| `order_id`, `customer_unique_id`, `customer_state` | Keys and customer location |
| `order_date`, `order_month` | Purchase date and its month start |
| `items`, `revenue`, `freight` | Item count, item price total, and freight total |
| `sellers_in_order`, `seller_state`, `route` | Number of sellers. Seller state and route (same state, different state, or multiple sellers) apply to single-seller orders |
| `primary_payment_type`, `max_installments`, `paid_value`, `card_installment_band` | Payment method with the largest value, highest installment count, total paid (zero-value payments excluded), and installment band for credit card orders |
| `delivery_days`, `days_late` | Purchase to delivery, and delivery against the estimate (negative when early) |
| `late_flag`, `delivery_outcome`, `lateness_band`, `lateness_band_sort` | `late_flag` is 1, 0, or empty when there is no delivery date, so its average is the late rate |
| `review_score`, `review_timing` | Score of the most recent review, and whether it was answered before or after delivery |
| `order_seq`, `is_first_order` | The customer's order number within the window, and a first-order flag |

**pbi_fact_order_items**: `order_id`, `order_item_id`, `product_id`, `seller_id`, `category_pt`, `price`, `freight_value`.

**pbi_dim_customer**: `customer_unique_id`, `orders`, `revenue`, `recency_days`, `r_score`, `m_score`, `segment`, `cohort_month`, `repeat_type` (one-time, repeat same day, repeat 1 to 30 days, repeat over 30 days).

**pbi_dim_seller**: `seller_id`, `seller_state`, `seller_region`, `is_active`, `orders`, `revenue`, `volume_band`, `revenue_rank`, `cum_revenue_pct`, `delivery_orders`, `late_orders`, `late_pct`, `avg_delivery_days`.

**pbi_dim_category**: `category_pt`, `category_en`, `category_label`. English names are supplied for two categories missing from the source translation, and four misspelled source labels are corrected.

**pbi_dim_state**: `state_code`, `state_name`, `region`. **pbi_dim_date**: `calendar_date`, `calendar_year`, `month_number`, `month_name`, `month_start`, `year_month`, `day_name`, `day_of_week_number`, `event_period` (marks Black Friday week 2017).

**pbi_cohort_retention**: `cohort_month`, `months_since_first`, `active_customers`, `cohort_size`, `retention_pct`. Months with no returning customers appear as 0, and months a cohort has not had time to reach are omitted.

**pbi_order_status_by_month**: `order_month`, `order_status`, `orders`.

## Reconciliation

Checks at the end of `sql/08_powerbi_views.sql`. Fill in the last column from the actual output.

| View | Check | Expected | Actual |
|---|---|---|---|
| `pbi_fact_orders` | Rows, distinct orders | 96,211 | |
| `pbi_fact_orders` | Revenue | 13,181,027.13 | |
| `pbi_fact_order_items` | Revenue | 13,181,027.13 | |
| `pbi_fact_order_items` | Distinct orders | 96,211 | |
| `pbi_dim_customer` | Rows | 93,104 | |
| `pbi_dim_seller` | Rows, revenue | 3,095, 13,181,027.13 | |
| `pbi_dim_category` | Rows | 74 | |
| `pbi_dim_state` | Rows | 27 | |
| `pbi_dim_date` | Rows | 608 | |
| Relationship checks | Fact keys without a dimension row | 0 for all six | |

The expected revenue is the headline figure from `docs/eda_findings.md`.

## Connecting Power BI

Power BI Desktop connects to the Databricks SQL warehouse using the Databricks connector in Import mode, with a personal access token for authentication. Tokens, the server hostname, and the HTTP path are not stored in this repository. To rebuild the report, create the views with the SQL scripts, connect to your own workspace, load the nine `pbi_` views, rename them as in the table above, and create the relationships.

<img width="1366" height="629" alt="powerbi 3" src="https://github.com/user-attachments/assets/4f0d479a-167f-499b-b8b4-8cd7862040cc" />
<img width="1366" height="721" alt="powerbi 2" src="https://github.com/user-attachments/assets/d6f106ca-3d8c-4fe3-85e6-6991c2546d87" />

