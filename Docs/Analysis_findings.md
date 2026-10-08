# Analysis Findings

Findings from the advanced analysis scripts (`sql/04` onward). Scope and definitions are in `docs/data_quality_notes.md` and `docs/eda_findings.md`.

## 1. Cohort retention

Scope: delivered orders, Jan 2017 to Aug 2018. A customer's cohort is the month of their first delivered order in the window. Retention is the share of a cohort that placed an order in a later month. At each offset only cohorts with a full follow-up period are included.

| Months since first purchase | Cohorts included | Customers in cohorts | Active customers | Retention % |
|---|---|---|---|---|
| 0 | 20 | 93,104 | 93,104 | 100.00 |
| 1 | 19 | 86,960 | 420 | 0.48 |
| 2 | 18 | 81,011 | 273 | 0.34 |
| 3 | 17 | 75,132 | 192 | 0.26 |
| 6 | 14 | 55,267 | 128 | 0.23 |
| 9 | 11 | 36,798 | 60 | 0.16 |
| 12 | 8 | 21,404 | 36 | 0.17 |

- Retention falls from 0.48% in month 1 to about 0.2% by month 6 and stays near that level. No month exceeds 0.5%.
- This agrees with the repeat purchase findings (3.00% of customers, 5.5% of revenue): customers who do not return in the first months mostly do not return.
- Results beyond about month 12 rest on one to seven early, small cohorts, so month 18 (0 of 2,346) and month 19 (1 of 718) are not interpretable.
- Each offset combines different calendar months, so events such as Black Friday 2017 add noise at different offsets for different cohorts.
- The 1,826 later-month activity records are an upper bound on customers who bought in a later month. With 2,789 repeat customers, at least 963 (about 35%) placed all their orders in the same calendar month as their first order.

## 2. Timing of repeat purchases

Scope: delivered orders, Jan 2017 to Aug 2018. For each customer with more than one order, the gap is measured between their first and last order in the window.

| Gap between first and last order | Repeat customers | % of repeat customers | % of all customers |
|---|---|---|---|
| Same day | 784 | 28.1 | 0.84 |
| 1 to 30 days | 558 | 20.0 | 0.60 |
| Over 30 days | 1,447 | 51.9 | 1.55 |

- Of the 2,789 customers with more than one order (3.00% of customers), 1,447 (1.55% of customers) placed their last order more than 30 days after their first. Only these can be described as customers who came back.
- 784 repeat customers placed all their orders on the same day. The data does not show why.
- Quote repeat behaviour as two figures: 3.0% placed more than one order, and 1.6% returned more than 30 days after their first order.



