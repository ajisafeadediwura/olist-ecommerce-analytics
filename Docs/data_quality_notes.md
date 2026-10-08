# Data Quality Notes

Findings from profiling the Olist dataset (`sql/02_data_profiling.sql`), with the handling decision for each. Row counts after load match the published dataset (see `sql/01_setup_and_load.sql`).

## Scope

The geolocation file is excluded. Location analysis uses the city and state fields on the customers and sellers tables.

## 1. Key uniqueness

| Key | Rows | Distinct values | Finding |
|---|---|---|---|
| `orders.order_id` | 99,441 | 99,441 | Unique. Order grain is safe. |
| `customers.customer_id` | 99,441 | 99,441 | Unique per order, not per person. |
| `customers.customer_unique_id` | 99,441 | 96,096 | Identifies the actual customer. |
| `products.product_id` | 32,951 | 32,951 | Unique. |
| `sellers.seller_id` | 3,095 | 3,095 | Unique. |
| `order_reviews.review_id` | 99,224 | 98,410 | 814 rows share a `review_id` with another row. |
| `order_reviews.order_id` | 99,224 | 98,673 | 551 rows are additional reviews on an order that already has one. |

**Decisions**

- Customer-level analysis (retention, RFM, repeat rate) uses `customer_unique_id`. Using `customer_id` would treat every order as a new customer.
- The gap between 99,441 orders and 96,096 unique customers (3,345) comes from customers who placed more than one order.
- Orders can have more than one review row, so reviews must be reduced to one row per order before joining to orders. Joining directly would duplicate orders and distort revenue and review averages.

- ## 2. Order status

| Status | Orders | % of orders |
|---|---|---|
| delivered | 96,478 | 97.02 |
| shipped | 1,107 | 1.11 |
| canceled | 625 | 0.63 |
| unavailable | 609 | 0.61 |
| invoiced | 314 | 0.32 |
| processing | 301 | 0.30 |
| created | 5 | 0.01 |
| approved | 2 | 0.00 |

Delivered orders make up 97.02% of the dataset. The remaining 2,963 orders (2.98%) are canceled, unavailable, or at an intermediate stage with no confirmed delivery.

**Decisions**

- Revenue, delivery performance, and review analysis are restricted to delivered orders, so every metric uses one consistent definition of a completed sale.
- Non-delivered orders are retained in the source tables and used only for the order status funnel.
