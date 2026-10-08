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

## 3. RFM segmentation

Scope: delivered orders, Jan 2017 to Aug 2018, by `customer_unique_id`. Recency is measured in days to 1 Sep 2018. Recency and spend (item revenue) are each scored 1 to 5 by quintile, 5 being best. Frequency is not scored, since 97% of customers placed one order: customers with two or more orders form one segment, and one-time customers are split on spend (score 4 or 5 is "high-value") and recency (score 4 or 5 is "recent", meaning a last order within about 179 days).

| Segment | Customers | % of customers | Revenue | % of revenue | Revenue per customer | Average days since last order |
|---|---|---|---|---|---|---|
| Dormant high-value, one-time | 20,648 | 22.18 | 5,522,086 | 41.89 | 267.44 | 337 |
| Recent high-value, one-time | 14,467 | 15.54 | 3,864,823 | 29.32 | 267.15 | 94 |
| Dormant lower-value, one-time | 33,623 | 36.11 | 1,868,692 | 14.18 | 55.58 | 338 |
| Recent lower-value, one-time | 21,577 | 23.18 | 1,200,071 | 9.10 | 55.62 | 92 |
| Repeat customers | 2,789 | 3.00 | 725,355 | 5.50 | 260.08 | 222 |

- One-time customers with high spend are 37.7% of customers and 71.2% of revenue, at about 267 per customer against about 55.6 for lower-spend one-timers (59.3% of customers, 23.3% of revenue).
- The dormant high-value group is the largest segment by revenue (41.9%), with an average of 337 days since the last order. Dormant one-time customers overall (low recency) hold 56.1% of revenue.
- Spend per customer is nearly identical for dormant and recent customers within each spend group, so recency does not separate high-value from low-value customers.
- Repeat customers average 260.08, slightly below high-value one-time customers, and last ordered 222 days before the end of the window on average.
- Score ranges: spend scores run from up to 39.90 (score 1) through 179.90 and above (score 5, up to 13,440), and recency scores from 383 to 604 days (score 1) to 3 to 94 days (score 5). Customers with identical values can fall in different scores at a boundary, because quintile groups are forced to equal size, so segment edges are approximate.
- The top spend score covers a very wide range (179.90 to 13,440), so quintile scores understate how concentrated the very largest orders are.
- Dormant does not mean lost: with one order per customer, buying cycles are unknown. The only observed return behaviour is the cohort retention rate (about 0.2% a month).


