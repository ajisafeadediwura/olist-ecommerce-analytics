# EDA Findings

Scope: delivered orders, Jan 2017 to Aug 2018. Revenue is the sum of item price (freight excluded). Definitions and rationale are in `docs/data_quality_notes.md`.

## 1. Monthly revenue, orders, and average order value

| Measure | Jan to Aug 2017 | Jan to Aug 2018 | Change |
|---|---|---|---|
| Orders | 21,998 | 52,783 | +140% |
| Revenue | 2,993,456 | 7,218,125 | +141% |
| Average order value | 136.08 | 136.75 | +0.5% |

- Growth was driven by order volume. Average order value stayed between 124 and 149 in every month.
- Nov 2017 was the peak month (7,289 orders, 987,765 revenue). Orders rose 63% over October while average order value dipped from 144.76 to 135.51.
- From Jan 2018 onward, monthly orders stayed between 6,099 and 7,069. Revenue peaked in May 2018 (977,545) and was up to 14% lower in June to August.
- The delivered share of orders is similar in Aug 2018 (97.5%) and Jan 2018 (97.3%), so the late-2018 figures are not distorted by undelivered recent orders.

## 2. November 2017 peak

| Period | Orders | Orders per day | Revenue | Average order value |
|---|---|---|---|---|
| 1 to 23 Nov | 3,932 | 171 | 569,059 | 144.7 |
| 24 Nov (Black Friday) | 1,147 | 1,147 | 149,917 | 130.7 |
| 25 to 30 Nov | 2,210 | 368 | 268,790 | 121.6 |

- Black Friday (24 Nov 2017) produced 15.7% of the month's orders, about 6.7 times the daily average of the first 23 days.
- Demand stayed elevated for about a week afterwards at roughly twice the earlier daily rate. The seven days from 24 Nov account for 46% of November orders and 42% of revenue.
- Orders rose from 20 Nov in the run-up to the event.
- Average order value was lowest in the event week, consistent with promotional buying. The data has no discount field, so this cannot be confirmed.
- Excluding the Black Friday week, November ran at about 171 orders a day against about 144 in October, so the November peak sits on top of continued underlying growth, not a one-off jump in baseline.

## 3. Headline KPIs

Scope: delivered orders, Jan 2017 to Aug 2018.

| Measure | Value |
|---|---|
| Orders | 96,211 |
| Customers | 93,104 |
| Revenue (item price) | 13,181,027 |
| Freight | 2,192,093 |
| Average order value | 137.00 |

- Freight equals 16.6% of item revenue.
- There are about 1.03 orders per customer. 3,107 orders came from customers who had already ordered in the window, roughly 3% of orders.




