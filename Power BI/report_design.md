# Report Design and Validation

Design decisions behind the Power BI report, and how its figures were checked against the SQL analysis. Measure definitions are in `powerbi/dax_measures.md`, and the model is in `docs/data_model.md`.

## Pages

| Page | Question | Headline |
|---|---|---|
| Executive summary | How big is the business and how did it grow? | Revenue grew with order volume in 2017, then plateaued in 2018 |
| Customers | Do customers come back, and who is worth the most? | Customers rarely return: 3% ordered more than once and 1.6% came back after 30 days |
| Delivery and satisfaction | Does late delivery hurt satisfaction, and where did service break down? | Late delivery lowers review scores, and service broke down in specific periods |
| Sellers and products | How concentrated is the marketplace, and does seller location matter? | A small group of sellers and categories carries most revenue, and most orders cross state lines |
| About | What do the figures mean and what are the limits? | Definitions, scope, and limitations |

Every page title states the finding, so a reader gets the conclusion before reading the charts. Each page carries a short note on scope, and an insight line at the bottom.

## Model decisions

- **Star layout on views, with no separate warehouse.** Two fact views (orders and order items) and five dimensions. Fact tables are filtered by the dimensions through single-direction, many-to-one relationships.
- **Two grains on purpose.** Order-level measures (revenue, delivery, reviews, payments) use the order fact. Category and seller revenue use the item fact, because one order can contain several categories and sellers.
- **The seller dimension is not related to the order fact.** A seller relationship to both facts would create two filter paths from sellers to orders. Seller delivery performance (late orders, delivery orders) is stored on the seller dimension instead.
- **Customer and seller visuals describe the whole window.** Filters flow from dimensions to facts, so the date and region slicers do not reach the customer and seller tables. The pages say so, and slicers are omitted where they would not apply.
- **Sort order comes from the SQL views.** Text bands such as lateness and repeat type need a sort order. A DAX calculated column built from the column it sorts creates a circular dependency in Power BI, so the sort numbers are part of the views.
- **A continuous date table.** The date table has one row per day from January 2017 to August 2018, so months without orders still appear.

## Measure decisions

- **Late rate is an average of a 1/0 flag.** `late_flag` is blank for the 8 orders with no delivery date, so `AVERAGE` leaves them out of the rate automatically.
- **Late and on-time scores use a text label.** In DAX a blank equals 0 in a comparison, so filtering `late_flag = 0` would include orders with no delivery date. The measures filter on `delivery_outcome` instead.
- **Growth compares matching months.** The data ends in August 2018, so growth is January to August 2018 against January to August 2017. These measures ignore the year slicer, because a single-year selection cannot be compared with itself.
- **Category share is a measure.** The built-in "percent of grand total" would recalculate against only the rows left after a Top N filter, so the share is calculated against all categories.
- **Pooled retention.** The cohort matrix divides returning customers by cohort size. Its total row pools every cohort that has been observed for that many months, which matches the SQL analysis.

## Visual decisions

- **Cohort matrix shows months 1 to 12.** Month 0 is always 100%, and later months rest on a few small cohorts. The colour scale is capped at 1%, because retention never exceeds about 0.7%.
- **The repeat-customer chart excludes one-time customers.** 90,315 one-time customers would hide the three repeat groups (784, 558, and 1,447).
- **Review scores are split by timing.** Customers who reviewed before the parcel arrived scored late orders far lower than those who reviewed afterwards. Combining them would overstate the effect of lateness after delivery.
- **The installment chart covers credit card orders only.** Other payment methods have no installments.
- **The Black Friday and RJ charts ignore the year slicer.** They show specific periods, so a year filter would empty them.
- **Slicer interactions are controlled.** Selecting a bar in one chart does not filter the slicers.

## Validation

Report figures were compared with the SQL results documented in `docs/eda_findings.md`, `docs/analysis_findings.md`, and `docs/results/`. The figures below matched the SQL results, or were consistent with them where the report and the SQL cover slightly different subsets of orders.

### Headline figures

| Figure | Report | SQL source |
|---|---|---|
| Revenue | 13,181,027.13 | 13,181,027.13 (EDA section 3) |
| Item revenue, summed from the item table | 13,181,027.13 | 13,181,027.13 |
| Freight | 2,192,092.88 | 2,192,092.88 |
| Orders | 96,211 | 96,211 |
| Average order value | 137.00 | 137.00 |
| Customers | 93,104 | 93,104 |
| Revenue growth, Jan to Aug 2018 against 2017 | 141.1% | 141% (EDA section 1) |
| Order growth, Jan to Aug 2018 against 2017 | 139.9% | 140% (EDA section 1) |
| Late rate | 8.1% (7,822 late of 96,203 orders with a delivery date) | 8.0% of reviewed orders (7,658 of 95,560, `06_results`) and 8.2% of single-seller orders (7,804 of 94,931, `07_results`), both subsets of the same orders |
| Average review score | 4.16 | about 4.15 when weighting the on-time (4.29) and late (2.57) scores by order count, which are rounded inputs (`06_results`) |
| Reviews answered before delivery | 4.86% | 4.86% (`06_results`, section 7) |

### Customers

| Figure | Report | SQL source |
|---|---|---|
| Cohort retention, months 1 to 12 (total row) | 0.48%, 0.34%, 0.26%, 0.26%, 0.23%, 0.23%, 0.21%, 0.20%, 0.16%, 0.25%, 0.22%, 0.17% | `04_cohort_retention`, pooled retention |
| Segment total: customers and revenue | 93,104 and 13,181,027.13 | `05_rfm_segmentation` |
| Payment method share: credit card, boleto, voucher, debit | 75.5%, 19.9%, 3.1%, 1.5% | EDA section 11 |
| Average paid by installments: 1, 2 to 3, 4 to 6, 7 to 10, 11 or more | 100.65, 134.96, 181.74, 333.44, 361.50 | EDA section 12 |

### Delivery and satisfaction

| Figure | Report | SQL source |
|---|---|---|
| Review score by lateness, reviewed before delivery (on time, up to 3 days, 3 to 7 days, over 7 days) | 4.01, 1.94, 1.61, 1.66 | `06_results`, section 9 |
| Review score by lateness, reviewed on or after delivery | 4.30, 3.90, 3.69, 3.54 | `06_results`, section 9 |

### Sellers and products

| Figure | Report | SQL source |
|---|---|---|
| Active sellers | 2,945 | `07_results`, section 2 |
| Revenue share of the top 30 sellers | 25.9% | `07_results`, section 3 |
| Seller late rate | 8.2% | `07_results`, section 8 |
| Orders shipped across state lines | 64.0% | `07_results`, section 7 |
| Average delivery days, different state and same state | 15.2 and 7.9 | `07_results`, section 7 |
| Late rate, different state and same state | 9.4% and 6.1% | `07_results`, section 7 |
| Health Beauty: revenue, share, freight % | 1,229,557.50, 9.3%, 14.5% | EDA section 10 |
| Watches Gifts: revenue, share, freight % | 1,163,465.91, 8.8%, 8.4% | EDA section 10 |
| Bed Bath Table: revenue, share, freight % | 1,022,955.77, 7.8%, 19.7% | EDA section 10 |
| Top 10 categories, share of revenue | 62.5% | EDA section 10 |

### Issues found and fixed during validation

| Issue | Cause | Fix |
|---|---|---|
| Growth measures returned the same total for 2017 and 2018, and a growth rate of 0% | The relationship between the date table and orders was missing, so the year filter did not reach the facts | Created the relationship. The measures then returned 21,998 and 52,783 orders |
| A circular dependency error when sorting a text band | The sort column was a DAX column calculated from the column it sorted | Moved the sort numbers into the SQL views |
| The year and region slicers lost buttons | Selecting a bar in a chart filtered the slicers | Turned off slicer interactions for the charts |
| Reviewed orders were 95,568 in Power BI and 95,560 in SQL | The SQL figure covered orders with a delivery date, and the model includes the 8 delivered orders without one, all of which have a review | Confirmed the difference was exactly those 8 orders. The report figure is correct |

Revenue and item revenue come from different tables, so their agreement shows the tables reconcile to the same total. It does not test the relationships, so the date, state, and customer relationships were tested separately with breakdown tables.

## Limitations of the report

- Figures are for delivered orders from January 2017 to August 2018 only.
- Customer, cohort, and seller figures do not respond to the date filter.
- Findings are associations. The data has no carrier, route, or discount fields, so causes cannot be identified.
- The Power BI file is not committed because it contains the imported data and connection details. Screenshots of each page are in `powerbi/screenshots/`.
