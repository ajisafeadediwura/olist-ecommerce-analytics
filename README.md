# Olist E-Commerce Analytics

End-to-end analysis of the Olist Brazilian e-commerce marketplace: SQL analysis in Databricks, a star-schema model, and a five-page Power BI report with findings and recommendations.

**Question:** where is the marketplace growing, losing customers, and letting service slip, and what would an operator do about it?

![Executive summary]<img width="1366" height="721" alt="01_executive_summary" src="https://github.com/user-attachments/assets/cafcab8f-c096-4ca0-b16d-b881a07417d5" />


## Report preview

| Page | Screenshot |
|---|---|
| Customers: retention, cohorts, segments, payments | ![Customers]<img width="1366" height="721" alt="02_customers" src="https://github.com/user-attachments/assets/a2a05666-137a-436b-8c58-34f43730ef9b" />
 |
| Delivery and satisfaction: lateness, reviews, Black Friday, RJ | ![Delivery and satisfaction]<img width="1366" height="721" alt="03_Delivery_and_satisfaction" src="https://github.com/user-attachments/assets/b30b0675-dba2-48bf-b04f-f51119babe66" />
 |
| Sellers and products: concentration, routes, categories | ![Sellers and products]<img width="1366" height="721" alt="04_sellers_and_products" src="https://github.com/user-attachments/assets/1cf8a446-309a-4a02-9e6f-941cb0eef5d5" />
 |

## Key findings

Scope: 96,211 delivered orders placed from January 2017 to August 2018, 93,104 customers, 13.18M in revenue (item price, freight excluded), average order value 137.00.

### 1. Growth came from order volume, then plateaued

- Jan to Aug 2018 against Jan to Aug 2017: revenue +141% and orders +140%. Average order value did not change (136.75 against 136.08) and stayed between 124 and 149 in every month.
- Monthly orders stayed between about 6,100 and 7,100 throughout 2018.
- Black Friday (24 Nov 2017) produced 1,147 orders in one day, about 6.7 times the daily average of the first 23 days of the month.

### 2. Customers rarely return

- 3.00% of customers placed more than one order, but only 1.55% placed an order more than 30 days after their first. The rest were same-day or within-a-month repeats.
- 94.5% of revenue came from customers who bought once in the window.
- Monthly retention is 0.48% in month 1 and settles near 0.2% afterwards, with no cohort doing noticeably better.
- The largest revenue pool is one-time customers with high spend who have not returned (20,648 customers, 41.9% of revenue).

### 3. Late delivery hurts satisfaction, and timing of the review matters

- 8.1% of delivered orders arrived after the estimated date. Late orders average a 2.57 review score against 4.29 for on-time orders.
- 4.86% of reviews were answered before the parcel arrived, almost all on orders that ended up late. Those customers rated late orders 1.66 on average.
- Among customers who reviewed after delivery, scores fall gradually with lateness: 4.30 on time, 3.90 up to 3 days late, 3.69 for 3 to 7 days, and 3.54 for more than 7 days.
- The penalty holds inside every large state tested (0.26 to 0.53 points).

### 4. Service broke down in specific periods

- Orders placed in the Black Friday week took 17.1 days on average (12.1 in the baseline), 20.1% arrived late (7.6% in the baseline), and the average review score fell to 3.82 (4.18). Orders were not cancelled or left undelivered at a higher rate, so the effect shows up as slower and later delivery.
- In Rio de Janeiro, late deliveries were concentrated in Nov 2017 to Mar 2018 (monthly late rates of 14.7% to 36.9%). Outside those months RJ's late rate was about 5% to 6%, similar to SP and MG. The episode was spread across 853 sellers and not caused by a few.

### 5. Geography drives cost and delivery time

- Sellers are concentrated in the South and Southeast: SP has 59.5% of sellers and earns 64.4% of revenue, against 38.4% of customer revenue.
- 64% of single-seller orders cross a state line and take about twice as long (15.2 days against 7.9). For customers in SP alone, a seller outside SP adds about 3 days.
- Freight takes 13.9% of item price in SP but up to 27.8% in remote states such as RR. Average delivery time ranges from 8.7 days (SP) to 29.9 days (RR).
- Estimated delivery dates include large buffers for remote states, so long waits are mostly within what customers were promised.

### 6. Revenue is concentrated in a few sellers and categories

- The top 30 sellers (1%) earn 25.9% of revenue, the top 20% earn 82.2%, and 45% of sellers took part in five orders or fewer.
- Late rates are similar across seller sizes (8.0% to 8.6%). The ten sellers with the highest late rates (at least 50 orders) produce only 3.2% of late orders.
- The top 10 categories account for 62.5% of revenue. Freight is lowest for high-priced categories (watches and gifts, 8.4% of price) and highest for bulky ones (furniture and decor, 23.7%).

## Recommendations

These follow from the findings. The data shows associations, so recommendations 1 to 4 are suggestions to test, not proven fixes.

1. **Treat retention as an experiment, not a given.** With 94.5% of revenue from one-time buyers, test a post-purchase follow-up in the first 30 days and measure the effect on the 1.55% return rate. The one-time high-spend segment is the obvious audience.
2. **Contact customers whose orders are running late before the estimated date passes.** Customers who review while still waiting give the lowest scores (1.66 for late orders), so proactive updates may protect ratings.
3. **Plan peak periods.** Black Friday 2017 cut service quality for a week. Capacity planning and more cautious promised dates during peaks would address the 20.1% late rate.
4. **Investigate the RJ episode with carrier and route data.** The dataset has no carrier field, so the cause cannot be identified here.
5. **Reduce distance for remote customers.** Evaluate recruiting sellers or fulfilment capacity closer to the North and Northeast, where customers pay more for freight and wait longer. The trade-off is cost, which this data cannot estimate.
6. **Manage concentration risk.** A small group of sellers carries most revenue. Monitor their performance more closely than the long tail, which contributes little revenue.

## Approach

1. **Load and profile.** Eight Kaggle CSV files were loaded into Databricks and profiled for keys, completeness, joins, dates, and value ranges. Findings and the handling rule for each issue are in `docs/data_quality_notes.md`.
2. **Explore.** Revenue trend, geography, freight, delivery, payments, categories, and repeat purchasing (`sql/03_eda.sql`).
3. **Analyse.** Cohort retention, RFM segmentation, delivery and reviews, and sellers (`sql/04` to `sql/07`).
4. **Model.** Nine views form the Power BI model: two fact views, five dimensions, and two summary views. No separate warehouse layer was built.
5. **Report.** Five Power BI pages, each answering one question, with definitions and limitations on the About page. Design decisions and the validation of every headline figure against the SQL results are in `powerbi/report_design.md`.

### Scripts

| Script | Purpose |
|---|---|
| `01_setup_and_load.sql` | Schema, volume, and source tables |
| `02_data_profiling.sql` | Key, null, join, date, and value checks |
| `03_eda.sql` | Revenue, geography, freight, delivery, payments, categories |
| `04_cohort_retention.sql` | Cohort retention and timing of repeat purchases |
| `05_rfm_segmentation.sql` | Customer segments by recency, spend, and repeat behaviour |
| `06_delivery_and_reviews.sql` | Lateness, review scores, Black Friday, RJ |
| `07_seller_analysis.sql` | Seller concentration, routes, late orders by seller |
| `08_powerbi_views.sql` | Views the Power BI model reads |

Full results for the analysis scripts are in `docs/results/` and `docs/analysis_findings.md`.

## Data and definitions

- **Source:** [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). The raw files are not stored in this repository. The geolocation file is not used.
- **Orders in scope:** delivered orders placed from 2017-01-01 to 2018-08-31. Earlier and later months are too sparse to analyse.
- **Revenue:** sum of item price, excluding freight.
- **Customer:** `customer_unique_id`. The `customer_id` field changes with each order, so it is not used for customer analysis.
- **Late order:** delivered after the estimated delivery date.
- **Reviews:** one per order, the most recent.
- **Seller delivery performance:** attributed only on orders with items from a single seller (98.7% of orders).

Column definitions and the model are in `data/README.md` and `docs/data_model.md`.

## Repository structure

```
olist-ecommerce-analytics/
├── README.md
├── Data/               # data dictionary only (no raw data)
├── Docs/
│   ├── data_quality_notes.md
│   ├── EDA_findings.md
│   ├── Analysis_findings.md
│   ├── data_model.md
│   ├── connection_guide.md
│   └── results/        # full output of the analysis scripts
├── powerbi/
│   ├── dax_measures.md
│   ├── report_design.md
│   ├── olist_theme.json
│   └── screenshots/
└── sql/                # scripts 01 to 08
```

## How to reproduce

1. Download the dataset from Kaggle and upload the eight CSV files (all except geolocation) to a Databricks volume at `/Volumes/workspace/olist/raw_files/`.
2. Run `sql/01` to `sql/08` in order in a Databricks SQL notebook.
3. Connect Power BI Desktop to the Databricks SQL warehouse, load the nine `pbi_` views, and create the relationships in `docs/data_model.md`. Steps are in `docs/connection_guide.md`.
4. Create the measures in `powerbi/dax_measures.md` and apply `powerbi/olist_theme.json`.

The Power BI file is not included, because it holds the imported data and connection details. Screenshots of every page are in `powerbi/screenshots/`.

## Limitations

- Reviews answered before delivery cannot reflect the delivery itself, so review results are reported separately for both timings.
- The data has no carrier, route, or discount fields, so the causes of delivery delays and the effect of promotions cannot be identified.
- Repeat purchase is understated for customers first acquired late in the window, and rates are a floor.
- Findings are associations, not causal effects. Seller late rates also depend on where each seller's customers are.
- The data covers 2016 to 2018 and one marketplace.

## Tools

Databricks SQL · Power BI · GitHub

## Author

Built by [Adediwura Ajisafe](https://github.com/ajisafeadediwura).

## Licence

MIT. The Olist dataset is published on Kaggle under its own terms.
