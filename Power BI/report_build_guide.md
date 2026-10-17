# Power BI Report Build Guide

Step by step build of the Olist report: five pages on top of the nine `pbi_` views. Every visual has expected values taken from the SQL analysis (`docs/eda_findings.md`, `docs/analysis_findings.md`, `docs/results/`). If a visual does not match, the model or a relationship is wrong, so fix that before moving on.

Measures and calculated columns are in `powerbi/dax_measures.md`. Table names are as in `docs/data_model.md`.

## Report design principles

- **One question per page.** Each page title states the finding, not the topic ("Revenue grew with order volume in 2017, then plateaued in 2018", not "Revenue overview").
- **Every number has a definition.** Definitions sit in the About page and in one-line notes on each page.
- **Caveats are shown, not hidden.** Where a result depends on a limitation (reviews answered before delivery, small cohorts), the page says so.
- **Consistent styling.** One theme, one font, the same card style, left-aligned titles, no default chart titles.

---

## Part A: Setup

### A1. Check the model

1. Open Model view. Confirm the six relationships are many to one with single-direction filtering and are active: `Orders[order_date]` to `Dates[calendar_date]`, `Orders[customer_state]` to `States[state_code]`, `Orders[customer_unique_id]` to `Customers[customer_unique_id]`, `Order Items[order_id]` to `Orders[order_id]`, `Order Items[category_pt]` to `Categories[category_pt]`, `Order Items[seller_id]` to `Sellers[seller_id]`.
2. Confirm `Sellers` is not related to `Orders`, and that `Cohort Retention` and `Order Status` have no relationships.
3. Select `Dates`, then Table tools > Mark as date table, and choose `calendar_date`.

### A2. Apply the theme

1. Download `olist_theme.json`.
2. View > Themes > Browse for themes, and select the file.
3. Colours used: dark blue `#1F3A5F` (main), orange `#E07A1F` (late or problem values), teal `#2A9D8F` (good), grey for context.

### A3. Create the calculated columns

Create the three calculated columns from `dax_measures.md` (Table view > select the table > New column): `Card Installment Sort` in `Orders`, `Repeat Type Sort` in `Customers`, `Volume Band Sort` in `Sellers`.

### A4. Set the sort orders

Select each column, then Column tools > Sort by column:

| Column | Sort by |
|---|---|
| `Dates[month_name]` | `month_number` |
| `Dates[day_name]` | `day_of_week_number` |
| `Orders[lateness_band]` | `lateness_band_sort` |
| `Orders[card_installment_band]` | `Card Installment Sort` |
| `Customers[repeat_type]` | `Repeat Type Sort` |
| `Sellers[volume_band]` | `Volume Band Sort` |

### A5. Create the measures

Create an empty table for measures (Home > Enter data, name it `_Measures`, then Load). Select it and use Modeling > New measure once for each measure in `dax_measures.md`, one at a time. Apply the formats from the table at the end of that file. Then hide the placeholder column in `_Measures`.

### A6. Hide technical fields

In Model view, right-click and choose "Hide in report view" for: all `*_sort` columns and the three calculated sort columns, `days_late`, `late_flag`, `lateness_band_sort`, `order_seq`, `seller_id` and `product_id` in `Order Items`, `order_item_id`, and `cum_revenue_pct` and `revenue_rank` in `Sellers` (they are used by one chart, which can still use hidden fields). This leaves analysts a clean field list.

### A7. Page setup

Use the default 16:9 canvas. Create five pages and name them: `Executive summary`, `Customers`, `Delivery and satisfaction`, `Sellers and products`, `About`. For every page, set Format page > Wallpaper to a light grey (`#F3F4F6`) and keep the page background white or transparent so cards stand out.

---

## Part B: Page 1, Executive summary

**Question:** how big is the business and how did it grow?
**Title (text box, top left):** *Revenue grew with order volume in 2017, then plateaued in 2018*
**Subtitle:** *Delivered orders, Jan 2017 to Aug 2018. Revenue is item price, freight excluded.*

### Steps

1. **Slicers (top right):** `Dates[calendar_year]` as tiles, and `States[region]` as a dropdown.
2. **Six cards in a row:** `Revenue`, `Orders Count`, `Avg Order Value`, `Customers Count`, `Late Rate`, `Avg Review Score`. Turn off the category label if the title is clear, and give each card a short title.
3. **Two growth cards:** `Revenue Growth Jan-Aug` and `Orders Growth Jan-Aug`, titled "Jan to Aug 2018 vs 2017".
4. **Combo chart** (clustered column and line): X-axis `Dates[year_month]`, columns `Revenue`, line `Orders Count` on the secondary axis. Title: "Monthly revenue and orders".
5. **Bar chart:** `Revenue` by `States[region]`, sorted descending, data labels on. Title: "Revenue by customer region".
6. **Insight text box** (bottom): *Growth came from more orders, not larger ones: average order value stayed between 124 and 149 in every month. November 2017 was the peak, driven by Black Friday.*

### Check the numbers

With no slicer selected:

| Visual | Expected |
|---|---|
| Revenue | 13,181,027.13 |
| Orders Count | 96,211 |
| Avg Order Value | 137.00 |
| Customers Count | 93,104 |
| Late Rate | about 8% |
| Avg Review Score | about 4.15 |
| Revenue Growth Jan-Aug | +141% |
| Orders Growth Jan-Aug | +140% |

| Month | Revenue | Orders |
|---|---|---|
| 2017-01 | 111,798.36 | 750 |
| 2017-11 | 987,765.37 | 7,289 |
| 2018-05 | 977,544.69 | 6,749 |
| 2018-08 | 838,576.64 | 6,351 |

Revenue by region, as a share of the total (approximate, from the state table): Southeast 65.4%, South 14.4%, Northeast 11.3%, Central-West 6.4%, North 2.5%.

---

## Part C: Page 2, Customers

**Question:** do customers come back, and who is worth the most?
**Title:** *Customers rarely return: 3% ordered twice and 1.6% came back after 30 days*
**Subtitle:** *Customer and cohort visuals cover the whole window and ignore the date filter.*

### Steps

1. **Four cards:** `Customer Base`, `Repeat Rate`, `Returned After 30 Days Rate`, `One-Time Revenue Share`.
2. **Cohort matrix** (Cohort Retention):
   - Rows: `cohort_month` (format as `mmm yyyy`). Columns: `months_since_first`. Values: `Retention %`.
   - Format > Cell elements > Background colour > fx > Gradient: minimum 0, maximum 0.01 (1%), light to dark blue.
   - Turn on column subtotals (the bottom "Total" row is the pooled retention by month) and turn off row subtotals.
   - Title: "Retention by monthly cohort". Add a note: *Recent cohorts have had less time to return, so their later months are empty.*
3. **Bar chart, repeat customers:** Y-axis `Customers[repeat_type]`, values `Customer Base`. Add a visual-level filter `repeat_type` is not "One-time". Title: "Repeat customers by gap between first and last order".
4. **RFM table:** rows `Customers[segment]`; values `Customer Base`, `Customer Revenue`, `Avg Revenue per Customer`. Add "Show value as > Percent of grand total" to `Customer Revenue` or add it twice. Sort by `Customer Revenue` descending.
5. **Payment methods:** bar chart with `Orders[primary_payment_type]` and `Share of Orders by Payment Type`. This visual responds to the date slicers.
6. **Installments:** column chart with `Orders[card_installment_band]` on the axis and `Avg Paid` as values. Add a visual-level filter: `card_installment_band` is not blank. Title: "Average amount paid by card installments".
7. **Insight text box:** *94.5% of revenue came from customers who bought once. Customers who spread payment over more installments spent more per order, but this shows association, not cause.*

### Check the numbers

| Visual | Expected |
|---|---|
| Customer Base | 93,104 |
| Repeat Rate | 3.00% |
| Returned After 30 Days Rate | 1.55% |
| One-Time Revenue Share | 94.5% |

Cohort matrix, bottom Total row: month 0 = 100%, month 1 = 0.48%, month 2 = 0.34%, month 3 = 0.26%, month 6 = 0.23%, month 12 = 0.17%.

Repeat customers by gap: same day 784, 1 to 30 days 558, over 30 days 1,447 (together 2,789).

RFM segments:

| Segment | Customers | Revenue |
|---|---|---|
| Dormant high-value, one-time | 20,648 | 5,522,086 |
| Recent high-value, one-time | 14,467 | 3,864,823 |
| Dormant lower-value, one-time | 33,623 | 1,868,692 |
| Recent lower-value, one-time | 21,577 | 1,200,071 |
| Repeat customers | 2,789 | 725,355 |

Payment type share of orders: credit card 75.48%, boleto 19.89%, voucher 3.09%, debit card 1.54%.

Average paid by installments: 1 = 100.65, 2 to 3 = 134.96, 4 to 6 = 181.74, 7 to 10 = 333.44, 11 or more = 361.50 (and 0 invalid = 94.32 on 2 orders).

---

## Part D: Page 3, Delivery and satisfaction

**Question:** does late delivery hurt satisfaction, and where did service break down?
**Title:** *Late delivery lowers review scores, and service broke down in specific periods*
**Subtitle:** *Late means delivered after the estimated date. Reviews are one per order (the most recent).*

### Steps

1. **Slicers:** `Dates[calendar_year]` and `States[region]`.
2. **Four cards:** `Late Rate`, `Avg Delivery Days`, `Avg Review Score`, `Reviews Before Delivery %`.
3. **Review score by lateness (clustered column):**
   - Axis `Orders[lateness_band]`, legend `Orders[review_timing]`, values `Avg Review Score`.
   - Visual-level filters: `lateness_band` is not "No delivery date"; `review_timing` is "Before delivery" or "On or after delivery".
   - Title: "Average review score by lateness and review timing".
   - Add a note: *Customers who reviewed before the parcel arrived scored much lower than those who reviewed after.*
4. **Delivery time by state:** bar chart, axis `States[state_code]`, values `Avg Delivery Days`, sorted descending. Title: "Average delivery time by customer state".
5. **RJ episode (line chart):** axis `Dates[year_month]`, legend `States[state_code]`, values `Late Rate`. Visual-level filter: `state_code` is RJ, SP, or MG. Title: "Late rate by month: RJ, SP, MG".
6. **Black Friday (combo chart):** axis `Dates[calendar_date]`, columns `Orders Count`, line `Late Rate`. Visual-level filter: `Dates[year_month]` is "2017-11". Title: "Orders placed in November 2017 and their late rate".
7. **Insight text box:** *Among customers who reviewed after delivery, scores fall gradually with lateness (4.30 to 3.54). The sharp drop in the combined data comes from customers who reviewed while still waiting. RJ's lateness was concentrated in Nov 2017 to Mar 2018.*

### Check the numbers

| Visual | Expected |
|---|---|
| Reviews Before Delivery % | 4.86% |
| Avg Review Score, late orders | 2.57 (add a temporary card with `Avg Score Late`) |
| Avg Review Score, on-time orders | 4.29 (`Avg Score On Time`) |

Review score by lateness and timing:

| Lateness | Before delivery | On or after delivery |
|---|---|---|
| On time or early | 4.01 | 4.30 |
| Up to 3 days late | 1.94 | 3.90 |
| 3 to 7 days late | 1.61 | 3.69 |
| More than 7 days late | 1.66 | 3.54 |

Delivery time by state: SP 8.7, MG 12.0, RJ 15.3, BA 19.3, RR 29.9 days.

Late rate by month, RJ: Nov 2017 28.1%, Dec 2017 26.1%, Jan 2018 14.7%, Feb 2018 35.9%, Mar 2018 36.9%, Jun 2018 1.4%.

Black Friday: 24 Nov 2017 has 1,147 orders, against 268 the day before. Orders placed 24 to 30 Nov were late 20.1% of the time (check by selecting those days).

---

## Part E: Page 4, Sellers and products

**Question:** how concentrated is the marketplace, and does where sellers are matter?
**Title:** *A small group of sellers and categories carries most revenue, and most orders cross state lines*
**Subtitle:** *Seller figures cover the whole window. Delivery figures use orders with a single seller.*

### Steps

1. **Four cards:** `Active Sellers`, `Top 30 Sellers Revenue Share`, `Seller Late Rate`, `Cross-State Order Share`.
2. **Pareto chart (line chart):** axis `Sellers[revenue_rank]` (set the X-axis type to Continuous), values Maximum of `Sellers[cum_revenue_pct]`. Title: "Cumulative share of revenue by seller rank". Add a note: *The top 1% of sellers earn about a quarter of revenue.*
3. **Seller location:** bar chart, axis `Sellers[seller_state]`, values `Seller Revenue`, top 10 (Filters pane > Top N > 10 by `Seller Revenue`). Title: "Revenue by seller state".
4. **Route table:** rows `Orders[route]`, values `Orders Count`, `Avg Delivery Days`, `Late Rate`, `Avg Review Score`. Visual-level filter: `route` is not "Multiple sellers". Title: "Delivery by seller and customer location".
5. **Category table (top 10):** rows `Categories[category_label]`; values `Item Revenue`, `Category Revenue Share`, `Item Freight %`. Filters pane > Top N > Top 10 by `Item Revenue`. Title: "Top 10 categories by revenue".
6. **Insight text box:** *SP sellers earn 64% of revenue while SP customers are 38% of demand, so many orders travel across states and take about twice as long. Late deliveries are not driven by a few sellers: late rates are similar across seller size.*

### Check the numbers

| Visual | Expected |
|---|---|
| Active Sellers | 2,945 |
| Top 30 Sellers Revenue Share | 25.9% |
| Seller Late Rate | 8.2% |
| Cross-State Order Share | about 64% |

Pareto line: rank 30 = 25.93%, rank 148 = 52.99%, rank 295 = 67.04%, rank 589 = 82.20%.

Revenue by seller state: SP 8,487,299, PR 1,226,348, MG 975,967, RJ 813,291.

Route table: same state about 7.9 days and 6.1% late; different state about 15.2 days and 9.4% late. Average review scores are about 4.28 and 4.11.

Top 10 categories by revenue:

| Category | Revenue | Share | Freight % |
|---|---|---|---|
| Health Beauty | 1,229,558 | 9.33% | 14.5% |
| Watches Gifts | 1,163,466 | 8.83% | 8.4% |
| Bed Bath Table | 1,022,956 | 7.76% | 19.7% |
| Sports Leisure | 952,840 | 7.23% | 17.1% |
| Computers Accessories | 888,056 | 6.74% | 16.2% |
| Furniture Decor | 706,237 | 5.36% | 23.7% |
| Housewares | 614,342 | 4.66% | 23.2% |
| Cool Stuff | 609,158 | 4.62% | 13.3% |
| Auto | 577,838 | 4.38% | 15.6% |
| Garden Tools | 469,135 | 3.56% | 20.6% |

---

## Part F: Page 5, About

Use text boxes only. Suggested content:

- **Purpose:** analysis of the Olist Brazilian e-commerce marketplace, covering growth, customer retention, delivery performance, and sellers.
- **Data:** Brazilian E-Commerce Public Dataset by Olist (Kaggle). Delivered orders from Jan 2017 to Aug 2018 (96,211 orders). Data prepared in Databricks SQL and loaded into Power BI from nine model views.
- **Definitions:** Revenue is item price, excluding freight. A customer is identified by `customer_unique_id`. A late order is delivered after the estimated delivery date. Each order has one review (the most recent). Seller delivery performance uses orders with a single seller.
- **How to read this report:** customer, cohort, and seller figures describe the whole window and do not respond to the date slicer. Order, delivery, and payment figures do.
- **Limitations:** reviews answered before delivery cannot reflect the delivery itself. The data has no carrier or discount fields, so causes of delays and the effect of promotions cannot be identified. Repeat purchase is understated for customers acquired late in the window. Findings are associations, not causal effects.
- **Source code and documentation:** the GitHub repository (add the link).

---

## Part G: Polish checklist

Go through every page before exporting.

1. Replace every default visual title with a clear one, and remove axis titles that repeat the visual title.
2. Align visuals on a grid, with equal gaps and the same card height on every page.
3. Use sentence case, the same font sizes, and the theme colours. Use orange only for lateness or problem values.
4. Show data labels on bar charts, and hide gridlines that add no information.
5. Check number formats: thousands separators, percentages with 1 decimal, no long decimals on cards.
6. Add alt text to every visual (Format visual > General > Alt text).
7. Edit interactions: stop the cohort matrix and the Pareto chart from filtering other visuals (Format > Edit interactions).
8. Sync the year and region slicers across pages 1 and 3 (View > Sync slicers).
9. Test the slicers on each page. Customer and seller visuals should stay unchanged, and order visuals should change.
10. Read every title as a reader would, and check that each one is supported by the visual below it.

## Part H: Export and document

1. File > Export > Export to PDF, saved as `powerbi/olist_report.pdf`.
2. Take one screenshot per page and save them in `powerbi/screenshots/` as `01_executive_summary.png`, `02_customers.png`, `03_delivery_and_satisfaction.png`, `04_sellers_and_products.png`, `05_about.png`. Make sure no connection details are visible.
3. Do not commit the `.pbix` file (see `docs/connection_guide.md`). Add `*.pbix` to `.gitignore`.
4. Commit:

```bash
git add powerbi/ .gitignore
git commit -m "Add Power BI report documentation and exports"
git push origin main
```
