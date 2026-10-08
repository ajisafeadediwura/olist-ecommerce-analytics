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

## 4. Revenue by customer state

Scope: delivered orders, Jan 2017 to Aug 2018. State is the customer's state.

| State | Orders | Revenue | % of revenue | Average order value |
|---|---|---|---|---|
| SP | 40,406 | 5,055,587 | 38.36 | 125.12 |
| RJ | 12,310 | 1,751,434 | 13.29 | 142.28 |
| MG | 11,319 | 1,548,207 | 11.75 | 136.78 |
| RS | 5,328 | 726,374 | 5.51 | 136.33 |
| PR | 4,903 | 664,048 | 5.04 | 135.44 |
| SC | 3,537 | 504,774 | 3.83 | 142.71 |

- The top three states (SP, RJ, MG) generate 63.4% of revenue and 66.6% of orders. The top six generate 77.8% of revenue.
- SP accounts for 42.0% of orders but 38.4% of revenue: it has the lowest average order value of any large state (125.12 against 137.00 overall).
- Thirteen states each contribute under 1% of revenue and together make up about 6.1%.
- Average order value is higher in remote states (PB 218.09, AP 199.62, AC 199.14, AL 199.00, PA 184.06). One possible explanation is that high shipping costs discourage small orders. This is untested.
- Averages for the smallest states (RR 40 orders, AP 67, AC 80) rest on few orders and are not reliable.

## 5. Freight by customer state

Scope: delivered orders, Jan 2017 to Aug 2018. Freight share is total freight divided by total item price.

| State | Orders | Freight share of price |
|---|---|---|
| RR | 40 | 27.8% |
| MA | 713 | 26.2% |
| RO | 243 | 24.7% |
| AM | 145 | 24.5% |
| SE | 332 | 24.3% |
| PI | 475 | 24.2% |
| ... | | |
| RJ | 12,310 | 16.8% |
| DF | 2,074 | 16.7% |
| MS | 701 | 16.4% |
| SP | 40,406 | 13.9% |

Overall freight share is 16.6%.

- Freight share ranges from 13.9% (SP) to 27.8% (RR). The 16 highest-freight states are all in the North or Northeast.
- The six largest states by revenue have the lowest freight shares (13.9% to 18.2%).
- States with higher freight shares also tend to have above-average order values, but the ranking does not match exactly: the highest order values (PB, AL, AC, AP) sit mid-table on freight. The relationship is consistent with high shipping costs discouraging small orders, but this is untested.
- Freight also depends on product weight and size, so distance alone does not explain the differences.
- RR, AP, and AC rest on fewer than 100 orders each.

## 6. Repeat purchasing

Scope: delivered orders, Jan 2017 to Aug 2018. Customers are identified by `customer_unique_id`.

| Measure | Value |
|---|---|
| Customers | 93,104 |
| Customers with more than one order | 2,789 |
| Repeat rate | 3.00% |
| Most orders by one customer | 15 |

- Only 3.00% of customers ordered more than once within the window. Repeat customers account for about 6.1% of orders, roughly 2.1 orders each.
- The rate is a floor. Customers whose first order fell before Jan 2017 are counted as one-time buyers if only one order falls in the window, customers acquired late in the window have little time to return, and only delivered orders are counted.
- The highest order count is 15, well above the typical repeater's two.

## 7. Delivery time by customer state

Scope: delivered orders with a customer delivery date, Jan 2017 to Aug 2018. Delivery time runs from purchase to customer delivery. An order is late if it arrived after its estimated delivery timestamp.

| State | Orders | Average days | Median days | Late % |
|---|---|---|---|---|
| RR | 40 | 29.9 | 25.1 | 12.5 |
| AP | 67 | 27.2 | 24.3 | 4.5 |
| AM | 145 | 26.4 | 25.9 | 4.1 |
| AL | 396 | 24.5 | 22.3 | 24.0 |
| PA | 942 | 23.8 | 21.1 | 12.4 |
| MA | 713 | 21.5 | 19.2 | 19.6 |
| BA | 3,253 | 19.3 | 16.9 | 14.0 |
| RJ | 12,310 | 15.3 | 12.0 | 13.5 |
| MG | 11,319 | 12.0 | 10.3 | 5.6 |
| SP | 40,399 | 8.7 | 7.2 | 5.9 |

- Average delivery time ranges from 8.7 days (SP) to 29.9 days (RR). The North and Northeast are slowest, and the Southeast and South are fastest.
- States with the highest freight share also tend to have the longest delivery times (RR highest on both, SP lowest on both).
- Lateness does not follow delivery time. AM, AP, and RO deliver slowly but are rarely late (2.9% to 4.5%), which suggests longer estimates for remote destinations. AL (24.0%) and MA (19.6%) have the highest late rates, and RJ is late on 13.5% of orders despite a 15.3-day average.
- About 8% of delivered orders were late (approximate, weighted from state rates). SP and RJ account for roughly 30% and 21% of late orders. RJ has 12.8% of orders.
- In every state the mean exceeds the median, so a minority of very slow deliveries stretches the averages.
- RR, AP, and AC rest on fewer than 100 orders each.

## 8. Revenue by number of orders placed

Scope: delivered orders, Jan 2017 to Aug 2018, by `customer_unique_id`. Orders per segment are derived from the totals in section 3.

| Orders placed | Customers | Orders | Revenue | % of revenue | Revenue per customer | Revenue per order |
|---|---|---|---|---|---|---|
| 1 | 90,315 | 90,315 | 12,455,672 | 94.50 | 137.91 | 137.91 |
| 2 | 2,562 | 5,124 | 628,326 | 4.77 | 245.25 | 122.62 |
| 3 | 180 | 540 | 65,870 | 0.50 | 365.94 | 121.98 |
| 4+ | 47 | 232 | 31,159 | 0.24 | 662.97 | 134.31 |

- Repeat customers are 3.0% of customers, 6.1% of orders, and 5.5% of revenue. About 94.5% of revenue came from customers who ordered once in the window.
- A repeat customer spent about 1.9 times as much as a one-time customer in the window (260.08 against 137.91), because of more orders and not larger ones.
- Orders from repeat customers average 123.02, about 11% below the 137.91 average for one-time customers.
- 91.9% of repeat customers ordered exactly twice.
- The window understates repeat behaviour for customers whose earlier or later orders fall outside it.

## 9. Promised versus actual delivery time

Scope: delivered orders with a customer delivery date, Jan 2017 to Aug 2018. Promised days run from purchase to the estimated delivery date, and days early is promised minus actual (negative when late). Late % is from section 7.

| State | Orders | Avg promised days | Avg actual days | Avg days early | Late % |
|---|---|---|---|---|---|
| AC | 80 | 41.1 | 21.0 | 20.1 | 3.8 |
| RO | 243 | 38.8 | 19.4 | 19.4 | 2.9 |
| AP | 67 | 46.2 | 27.2 | 19.1 | 4.5 |
| AM | 145 | 45.3 | 26.4 | 18.9 | 4.1 |
| SP | 40,399 | 19.1 | 8.7 | 10.3 | 5.9 |
| RJ | 12,310 | 26.3 | 15.3 | 11.0 | 13.5 |
| CE | 1,273 | 31.2 | 21.2 | 9.9 | 15.4 |
| MA | 713 | 30.3 | 21.5 | 8.7 | 19.6 |
| AL | 396 | 32.5 | 24.5 | 8.0 | 24.0 |

- On average orders arrive before the promised date in every state, by 8.0 days (AL) to 20.1 days (AC). Late deliveries are a tail of the distribution.
- The North's long delivery times are mostly inside the estimates: AC, RO, AP, and AM have the largest buffers (19 to 20 days) and late rates of 2.9% to 4.5%.
- AL and MA have the smallest buffers (8.0 and 8.7 days) and the highest late rates (24.0% and 19.6%). Estimates there are tight relative to actual delivery times.
- Late rates are lowest where promised time is about twice actual time (SP, MG, RO) and highest where it is 1.3 to 1.5 times (AL, MA, SE, CE).
- RJ's late rate (13.5%) is not explained by a tight estimate: its buffer (11.0 days) is similar to SP's and SC's. Its mean delivery time is 3.3 days above its median, which points to a tail of slow deliveries. To be tested in the delivery analysis.

## 10. Revenue by product category

Scope: delivered orders, Jan 2017 to Aug 2018. Orders can contain several categories, so order counts do not sum to the total, and revenue per order is approximate. Revenue percentages sum to 100% across all 74 groups.

| Category | Orders | Revenue | % of revenue | Revenue per order | Freight % of price |
|---|---|---|---|---|---|
| health_beauty | 8,610 | 1,229,558 | 9.33 | 142.8 | 14.5 |
| watches_gifts | 5,491 | 1,163,466 | 8.83 | 211.9 | 8.4 |
| bed_bath_table | 9,267 | 1,022,956 | 7.76 | 110.4 | 19.7 |
| sports_leisure | 7,513 | 952,840 | 7.23 | 126.8 | 17.1 |
| computers_accessories | 6,518 | 888,056 | 6.74 | 136.2 | 16.2 |
| furniture_decor | 6,258 | 706,237 | 5.36 | 112.9 | 23.7 |
| housewares | 5,734 | 614,342 | 4.66 | 107.1 | 23.2 |
| cool_stuff | 3,552 | 609,158 | 4.62 | 171.5 | 13.3 |
| auto | 3,802 | 577,838 | 4.38 | 152.0 | 15.6 |
| garden_tools | 3,443 | 469,135 | 3.56 | 136.3 | 20.6 |

- The top 5 categories generate 39.9% of revenue and the top 10 generate 62.5%. The remaining 48 categories each contribute under 1% and together about 9.1%.
- `bed_bath_table` has the most orders but ranks third in revenue. `watches_gifts` ranks second in revenue with 7th-highest order volume.
- Freight share is lowest for high-priced categories (`pcs` 4.4%, `watches_gifts` 8.4%) and highest for bulky, low-value ones (`furniture_decor` 23.7%, `housewares` 23.2%).
- Products with no category (`unknown`) account for 1.29% of revenue and rank 21st.
## 11. Payment methods

Scope: delivered orders, Jan 2017 to Aug 2018. Each order is assigned its primary payment type (the type with the largest payment value), and zero-value payments are excluded. Amounts paid include freight, so they are not comparable with the order values in section 1. Installments are the highest installment count on the order.

| Primary payment type | Orders | % of orders | Average paid | Average installments |
|---|---|---|---|---|
| credit_card | 72,619 | 75.48 | 166.13 | 3.5 |
| boleto | 19,140 | 19.89 | 144.32 | 1.0 |
| voucher | 2,970 | 3.09 | 114.86 | 1.1 |
| debit_card | 1,482 | 1.54 | 140.44 | 1.0 |

- Credit card and boleto together are the primary payment type on 95.4% of orders.
- Credit card orders average 166.13, about 15% above boleto orders (144.32). Credit card orders average 3.5 installments, while boleto and debit orders have one. Weighted by orders, credit cards account for an estimated 78.5% of paid value, boleto 18.0%, vouchers 2.2%, and debit cards 1.4%.
- Order-weighted average paid across the four types is 159.81, which matches average item value per order plus average freight per order (137.00 + 22.78 = 159.78).
- About 3% of orders have more than one payment row, so primary type is an approximation of how the order was paid.

## 12. Credit card installments

Scope: delivered orders with credit card as the primary payment type (72,619 orders), Jan 2017 to Aug 2018. Amounts paid include freight.

| Installments | Orders | % of card orders | Average paid | Median paid |
|---|---|---|---|---|
| 0 (invalid) | 2 | 0.00 | 94.32 | 94.32 |
| 1 | 23,311 | 32.10 | 100.65 | 71.54 |
| 2 to 3 | 21,961 | 30.24 | 134.96 | 111.60 |
| 4 to 6 | 15,643 | 21.54 | 181.74 | 128.02 |
| 7 to 10 | 11,373 | 15.66 | 333.44 | 205.85 |
| 11 or more | 329 | 0.45 | 361.50 | 218.80 |

- Average and median amounts paid rise with each installment band. Only 32.1% of card orders are paid in a single installment.
- Orders with four or more installments are 37.7% of card orders and an estimated 56% of card paid value. Orders with 7 to 10 installments are 15.7% of card orders and an estimated 31% of card paid value.
- Two card orders have an installment count of zero, which is invalid. They are retained and reported separately.
- The relationship is an association. Customers buying more expensive items may choose longer installment plans, so the data does not show that installments increase basket size.



