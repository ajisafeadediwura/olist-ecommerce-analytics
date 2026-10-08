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

## 3. Timestamp completeness by order status

| Status | Orders | No approval date | No carrier date | No customer delivery date |
|---|---|---|---|---|
| delivered | 96,478 | 14 | 2 | 8 |
| shipped | 1,107 | 0 | 0 | 1,107 |
| canceled | 625 | 141 | 550 | 619 |
| unavailable | 609 | 0 | 609 | 609 |
| invoiced | 314 | 0 | 314 | 314 |
| processing | 301 | 0 | 301 | 301 |
| created | 5 | 5 | 5 | 5 |
| approved | 2 | 0 | 2 | 2 |

Timestamps are largely consistent with order status. Exceptions:

- 8 delivered orders have no customer delivery date.
- 6 canceled orders have a customer delivery date and 75 have a carrier date, so some cancellations occurred after shipment.
- All 1,107 shipped orders have no delivery date.

**Decisions**

- Delivery time and on-time metrics use delivered orders with a customer delivery date (96,470 orders). The 8 delivered orders without one are excluded from those metrics only and remain in revenue.
- Delivered orders without an approval date (14) are retained, as approval time is not used in the analysis.
- Canceled orders are excluded from delivery analysis regardless of any delivery timestamp.

  
## 4. Date coverage

Orders per month, by purchase timestamp:

| Period | Orders per month | Note |
|---|---|---|
| Sep 2016 | 4 | Dataset start, not representative |
| Oct 2016 | 324 | Sparse |
| Nov 2016 | none | No orders recorded |
| Dec 2016 | 1 | Sparse |
| Jan 2017 | 800 | Early ramp-up |
| Feb to Oct 2017 | 1,780 to 4,631 | Growth |
| Nov 2017 | 7,544 | Peak month |
| Dec 2017 | 5,673 | |
| Jan to Aug 2018 | 6,167 to 7,269 | Plateau |
| Sep 2018 | 16 | Extract cut-off |
| Oct 2018 | 4 | Extract cut-off |

**Decisions**

- Trend analysis uses the complete window Jan 2017 to Aug 2018. The 349 orders outside it (329 in 2016, 20 in Sep and Oct 2018) are excluded from time-trend metrics only.
- Year-over-year comparisons use matching months (Jan to Aug 2018 against Jan to Aug 2017).
- Cohort retention for recent cohorts is understated because of shorter follow-up time, and is labelled as such.
- The Power BI date table spans continuous months so the missing Nov 2016 does not drop out of the calendar.

## 5. Referential integrity

| Check | Violations |
|---|---|
| Orders without a customer | 0 |
| Order items without an order | 0 |
| Order items without a product | 0 |
| Order items without a seller | 0 |
| Order payments without an order | 0 |
| Order reviews without an order | 0 |
| Orders without items | 775 |
| Orders without payments | 1 |
| Orders without a review | 768 |

All child records link to a valid parent. The unmatched orders are orders with no child records, not orphaned child records.

**Decisions**

- Order counts join with LEFT JOIN so orders without items, payments, or reviews are retained. Revenue is based on order items.
- Payments and reviews are reduced to one row per order before joining to orders, to avoid duplicating order rows.
- Review-based metrics report coverage, i.e. the share of delivered orders that have a review.

## 6. Payments reconciliation

Order totals from items (price plus freight) were compared with payments, each aggregated to one row per order before joining. All order statuses are included in this check.

| Measure | Value |
|---|---|
| Orders compared | 98,665 |
| Orders differing by more than 1 | 249 (0.25%) |
| Total items value (price plus freight) | 15,843,409.78 |
| Total paid value | 15,846,280.17 |

Total payments exceed item value by about 2,870 (0.018%). The cause of the 249 larger differences is not determinable from the data.

**Decisions**

- Revenue is defined from `order_items` (item price, delivered orders only). Freight is reported separately.
- Payments are used for payment method and installment analysis, not for revenue.
- The 249 mismatched orders are retained, as their impact is immaterial.

## 7. Multiple rows per order

| Table | Orders with more than one row |
|---|---|
| order_payments | 2,961 |
| order_reviews | 547 |

Payments have one row per payment instalment or method (`payment_sequential`). Reviews have more than one row on 547 orders, and a few orders have three.

**Decisions**

- Payments are aggregated to one row per order before joining. Payment method analysis assigns each order its primary payment type (largest payment value) and flags orders paid with multiple methods.
- Reviews are reduced to one row per order, keeping the most recent review, in the view `order_reviews_dedup`.
- Neither table is joined to `order_items` at row level, since that would duplicate item rows and inflate revenue.

## 8. Product categories

| Check | Count |
|---|---|
| Products with no category | 610 (1.85% of 32,951) |
| Categories without an English translation | 2 |

**Decisions**

- Products with no category are labelled `unknown` so they remain in category totals as their own group.
- Category names are joined to the translation table with a LEFT JOIN. Categories with no translation are given an English name in the category dimension view, so no products are dropped.

 ## 9. Value sanity checks

| Check | Violations |
|---|---|
| Non-positive item price | 0 |
| Negative freight | 0 |
| Zero or negative payment value | 9 |
| Review score outside 1 to 5 | 0 |
| Delivered to customer before purchase | 0 |
| Delivered to customer before carrier pickup | 23 |

Item prices, freight, review scores, and purchase-to-delivery timing are valid. Two exceptions were found: 9 payment rows with a value of zero or less, and 23 orders where the customer delivery timestamp precedes the carrier pickup timestamp.

**Decisions**

- Zero-value payment rows are excluded from payment method analysis. They do not affect revenue, which is based on order items.
- The 23 orders with inconsistent carrier and delivery timestamps are retained in purchase-to-delivery metrics, and excluded from any metric that uses the carrier pickup date.

## 10. Price and freight distribution

| Measure | Item price | Freight |
|---|---|---|
| Minimum | 0.85 | n/a |
| Median | 74.99 | 16.26 |
| Mean | 120.65 | n/a |
| 95th percentile | 349.90 | n/a |
| Maximum | 6,735.00 | 409.68 |

Item prices are right-skewed: the mean is about 1.6 times the median, and the maximum is about 90 times the median.

**Decisions**

- Medians are reported alongside means for price, freight, and order value, and charts state which is shown.
- High-priced items are retained. They pass validity checks, and removing them would understate revenue.





