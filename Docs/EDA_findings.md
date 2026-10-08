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







