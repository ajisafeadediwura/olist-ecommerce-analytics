# Data

## Source

Brazilian E-Commerce Public Dataset by Olist, published on Kaggle: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset contains about 100,000 orders placed on the Olist marketplace between 2016 and 2018. The raw files are not stored in this repository. Licence terms are stated on the Kaggle dataset page.

## Reproducing the data load

1. Download and unzip the dataset from Kaggle.
2. Upload the eight files listed below to the Databricks volume `/Volumes/workspace/olist/raw_files/`.
3. Run `sql/01_setup_and_load.sql`, which creates the schema and loads the tables.

The geolocation file (`olist_geolocation_dataset.csv`) is not used. Location analysis relies on the city and state fields in the customers and sellers tables.

## Tables

All tables are in the schema `workspace.olist`. Row counts are as loaded.

| Table | Source file | Rows | Grain |
|---|---|---|---|
| `customers` | `olist_customers_dataset.csv` | 99,441 | One row per order's customer record |
| `orders` | `olist_orders_dataset.csv` | 99,441 | One row per order |
| `order_items` | `olist_order_items_dataset.csv` | 112,650 | One row per item in an order |
| `order_payments` | `olist_order_payments_dataset.csv` | 103,886 | One row per payment on an order |
| `order_reviews` | `olist_order_reviews_dataset.csv` | 99,224 | One row per review (an order can have more than one) |
| `products` | `olist_products_dataset.csv` | 32,951 | One row per product |
| `sellers` | `olist_sellers_dataset.csv` | 3,095 | One row per seller |
| `product_category_translation` | `product_category_name_translation.csv` | 71 | One row per category name |

## Relationships

| From | To | Key |
|---|---|---|
| `orders` | `customers` | `customer_id` |
| `order_items` | `orders` | `order_id` |
| `order_items` | `products` | `product_id` |
| `order_items` | `sellers` | `seller_id` |
| `order_payments` | `orders` | `order_id` |
| `order_reviews` | `orders` | `order_id` |
| `products` | `product_category_translation` | `product_category_name` |

`customers.customer_id` is assigned per order. The same person appears under several `customer_id` values if they ordered more than once, and `customer_unique_id` identifies the person. Customer-level analysis uses `customer_unique_id`.

## Columns

### customers

| Column | Description |
|---|---|
| `customer_id` | Customer key used in `orders`. Unique per order. |
| `customer_unique_id` | Identifier of the customer across orders. |
| `customer_zip_code_prefix` | First five digits of the customer's zip code. |
| `customer_city` | Customer city. |
| `customer_state` | Customer state (two-letter code). |

### orders

| Column | Description |
|---|---|
| `order_id` | Unique order identifier. |
| `customer_id` | Links to `customers`. |
| `order_status` | delivered, shipped, canceled, unavailable, invoiced, processing, created, or approved. |
| `order_purchase_timestamp` | When the customer placed the order. |
| `order_approved_at` | When payment was approved. |
| `order_delivered_carrier_date` | When the order was handed to the carrier. |
| `order_delivered_customer_date` | When the customer received the order. |
| `order_estimated_delivery_date` | Delivery date promised to the customer. |

### order_items

| Column | Description |
|---|---|
| `order_id` | Links to `orders`. |
| `order_item_id` | Sequence number of the item within the order. |
| `product_id` | Links to `products`. |
| `seller_id` | Links to `sellers`. |
| `shipping_limit_date` | Deadline for the seller to hand the item to the carrier. |
| `price` | Item price. |
| `freight_value` | Freight charged for the item. |

### order_payments

| Column | Description |
|---|---|
| `order_id` | Links to `orders`. |
| `payment_sequential` | Sequence number when an order is paid with more than one method. |
| `payment_type` | credit_card, boleto, voucher, or debit_card. |
| `payment_installments` | Number of installments chosen. |
| `payment_value` | Amount of the payment. |

### order_reviews

| Column | Description |
|---|---|
| `review_id` | Review identifier. |
| `order_id` | Links to `orders`. |
| `review_score` | Satisfaction rating from 1 to 5. |
| `review_comment_title` | Optional review title. |
| `review_comment_message` | Optional review text. |
| `review_creation_date` | When the satisfaction survey was sent. |
| `review_answer_timestamp` | When the customer answered. |

### products

| Column | Description |
|---|---|
| `product_id` | Unique product identifier. |
| `product_category_name` | Category name in Portuguese. |
| `product_name_length` | Number of characters in the product name. |
| `product_description_length` | Number of characters in the product description. |
| `product_photos_qty` | Number of product photos. |
| `product_weight_g` | Weight in grams. |
| `product_length_cm` | Length in centimetres. |
| `product_height_cm` | Height in centimetres. |
| `product_width_cm` | Width in centimetres. |

The source file misspells two columns (`product_name_lenght`, `product_description_lenght`). They are renamed on load.

### sellers

| Column | Description |
|---|---|
| `seller_id` | Unique seller identifier. |
| `seller_zip_code_prefix` | First five digits of the seller's zip code. |
| `seller_city` | Seller city. |
| `seller_state` | Seller state (two-letter code). |

### product_category_translation

| Column | Description |
|---|---|
| `product_category_name` | Category name in Portuguese. |
| `product_category_name_english` | Category name in English. |

## Data quality

Data quality findings and the handling rules applied in the analysis are in `docs/data_quality_notes.md`.
