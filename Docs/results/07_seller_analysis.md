# Script 07 Results: Seller Analysis

Output of `sql/07_seller_analysis.sql`, in cell order. Scope: delivered orders, Jan 2017 to Aug 2018. Revenue is the sum of item price (freight excluded). Delivery analysis uses orders that contain items from exactly one seller, with a customer delivery date. An order is late if it arrived after its estimated delivery timestamp.

## Summary

- Revenue is concentrated: the top 1% of sellers (30) earn 25.9% of revenue, the top 5% earn 53.0%, and the top 20% earn 82.2%. 45% of sellers took part in five orders or fewer and earned 5.4% of revenue.
- Sellers are concentrated in the South and Southeast. SP has 59.5% of sellers and 64.4% of revenue, against 38.4% of customer revenue, so a large share of SP sellers' revenue goes to customers in other states.
- 64.0% of orders are shipped across a state line and take about twice as long as same-state orders (15.2 days against 7.9). For customers in SP alone, a seller outside SP adds about 3 days but does not increase lateness.
- Late deliveries follow seller volume closely and are not concentrated in a few sellers. Late rates are flat across seller size bands (8.0% to 8.6%). The ten sellers with the highest late rates produce 3.2% of late orders.
- Individual sellers do vary: 34 of 412 established sellers (8.3%) have late rates of 15% or more. Part of the spread in the middle bands is chance, and a seller's late rate also depends on where its customers are.
- The Nov 2017 to Mar 2018 episode in RJ was spread across 853 sellers and hit shipments from SP sellers harder than shipments from other states. Sellers do not explain it, and the data has no carrier or route field to identify the cause.

---

## 2. Seller tie-out

| Active sellers | Total revenue | Seller-order links |
|---|---|---|
| 2,945 | 13,181,027.13 | 97,549 |

- Seller revenue sums to the headline figure (13,181,027.13).
- 2,945 of the 3,095 sellers (95.2%) had at least one delivered order in the window.
- Sellers took part in 97,549 orders in total against 96,211 orders overall, because some orders contain items from more than one seller (1,272 orders, 1.32%, with at least one containing three or more sellers). Per-seller order counts therefore cannot be summed to the order total.
- Average revenue per active seller is about 4,476 and average order participation is about 33 orders, but both averages hide a wide spread.

## 3. Revenue concentration among sellers

Average revenue per seller is calculated from the table.

| Top share of sellers | Sellers | Revenue | % of revenue | Average revenue per seller |
|---|---|---|---|---|
| 1% | 30 | 3,417,470 | 25.93 | 113,916 |
| 5% | 148 | 6,984,757 | 52.99 | 47,194 |
| 10% | 295 | 8,837,183 | 67.04 | 29,956 |
| 20% | 589 | 10,834,666 | 82.20 | 18,396 |
| 50% | 1,473 | 12,740,210 | 96.66 | 8,649 |

- The top 1% of sellers (30) earn 25.9% of revenue. The top 5% earn more than the remaining 95% combined (53.0% against 47.0%), and the top 20% earn 82.2%.
- The 1,472 sellers outside the top half earned about 440,800 in total (3.3% of revenue), roughly 300 each. The 2,356 sellers outside the top 20% shared 17.8%, about 1,000 each.
- Concentration partly reflects tenure, since sellers who joined late in the window had less time to earn, and price level, since revenue is based on item price.

## 4. Sellers by order volume

Average revenue per seller is calculated from the table.

| Orders in the window | Sellers | % of sellers | Revenue | % of revenue | Average revenue per seller |
|---|---|---|---|---|---|
| 1 | 516 | 17.5 | 130,549 | 0.99 | 253 |
| 2 to 5 | 810 | 27.5 | 574,827 | 4.36 | 710 |
| 6 to 20 | 834 | 28.3 | 1,684,947 | 12.78 | 2,020 |
| 21 to 100 | 577 | 19.6 | 3,959,699 | 30.04 | 6,863 |
| More than 100 | 208 | 7.1 | 6,831,005 | 51.82 | 32,841 |

- 1,326 sellers (45.0%) took part in 5 orders or fewer and earned 5.4% of revenue in total.
- The 785 sellers with more than 20 orders (26.7% of sellers) earn about 81.9% of revenue, consistent with the revenue ranking in section 3.
- The 208 sellers with more than 100 orders (7.1%) earn 51.8% of revenue, about 32,800 each.
- Ranking by revenue and by order volume selects different sellers: the top 148 sellers by revenue earn 53.0%, more than the 208 high-volume sellers (51.8%). Some top earners therefore sell higher-priced items in fewer than 100 orders.
- Part of the long tail reflects sellers who joined late in the window and had less time to accumulate orders. The data does not separate tenure from activity level.

## 5. Seller locations

Top 10 states by revenue. Percentages are shares of the whole marketplace. Revenue per seller is calculated from the table.

| Seller state | Sellers | % of sellers | Revenue | % of revenue | Revenue per seller |
|---|---|---|---|---|---|
| SP | 1,751 | 59.5 | 8,487,299 | 64.39 | 4,847 |
| PR | 334 | 11.3 | 1,226,348 | 9.30 | 3,672 |
| MG | 235 | 8.0 | 975,967 | 7.40 | 4,153 |
| RJ | 161 | 5.5 | 813,291 | 6.17 | 5,052 |
| SC | 184 | 6.2 | 612,709 | 4.65 | 3,330 |
| RS | 122 | 4.1 | 372,138 | 2.82 | 3,050 |
| BA | 18 | 0.6 | 277,764 | 2.11 | 15,431 |
| DF | 30 | 1.0 | 94,411 | 0.72 | 3,147 |
| PE | 9 | 0.3 | 91,164 | 0.69 | 10,129 |
| GO | 39 | 1.3 | 64,807 | 0.49 | 1,662 |

- The top 10 states hold 2,883 of 2,945 sellers and 98.7% of revenue. The remaining 62 sellers earned about 165,100 (1.25%).
- Sellers in SP, PR, MG, RJ, SC, and RS are 94.6% of sellers and 94.7% of revenue. No state in the North is in the top 10, and the Northeast has only BA and PE.
- SP sellers earn 64.4% of revenue against SP customers' 38.4% share of customer revenue (EDA section 4). SP sellers earned 8,487,299 while SP customers spent 5,055,587 in total, so at least 3,431,712 (40.4% of SP sellers' revenue) went to customers outside SP. The true share is higher, because SP customers also buy from sellers in other states.
- The concentration of sellers in the Southeast is consistent with the long delivery times and high freight shares in the North and Northeast (EDA sections 5 and 7).
- BA (18 sellers) and PE (9 sellers) earn far above the 4,476 average per seller. With so few sellers, a small number of large sellers could account for this.

## 6. Single-seller orders

| Single-seller orders | All delivered orders in scope |
|---|---|
| 94,939 | 96,211 |

- 98.68% of delivered orders contain items from exactly one seller. The other 1,272 orders (1.32%) involve several sellers and are excluded from the seller delivery analysis, because their delivery performance cannot be attributed to one seller.
- The delivery analysis in sections 7 to 15 additionally excludes up to 8 orders with no customer delivery date.

## 7. Same-state versus cross-state delivery

Single-seller delivered orders with a customer delivery date (94,931 orders). Average score includes reviews answered before and after delivery.

| Route | Orders | Share of orders | Average days | Median days | Late % | Average score |
|---|---|---|---|---|---|---|
| Same state | 34,149 | 36.0% | 7.9 | 6.6 | 6.1 | 4.28 |
| Different state | 60,782 | 64.0% | 15.2 | 12.8 | 9.4 | 4.11 |

- 64.0% of orders are shipped from a seller in a different state to the customer.
- Cross-state orders take about twice as long (average 15.2 days against 7.9, median 12.8 against 6.6).
- The late rate is 9.4% for cross-state orders against 6.1% for same-state orders, about 1.5 times, a smaller rise than the rise in delivery time. For customers in SP alone the pattern reverses (section 14), so the higher late rate on cross-state orders reflects the mix of customers served and not the extra distance by itself.
- Cross-state orders are 64.0% of orders and about 73% of late orders (calculated from rounded late rates).
- Different-state is an approximate measure of distance. The comparison also mixes customer locations, since cross-state orders include customers in the North and Northeast.

## 8. Seller delivery base

| Sellers | Orders | Late orders | Late rate |
|---|---|---|---|
| 2,925 | 94,931 | 7,804 | 8.2% |

- 2,925 of the 2,945 active sellers have at least one single-seller order with a delivery date. The other 20 sold only in multi-seller orders or orders without a delivery date and are excluded from seller delivery analysis.
- The late rate on these orders (8.2%) is consistent with the overall late rate in the delivery analysis (`06_delivery_and_reviews`).
- The average seller took part in about 32 of these orders, about 2.7 of them late.

## 9. Concentration of late orders among sellers

Sellers are ranked by their number of late orders. The share of sellers and the last column are calculated from the table.

| Top sellers by late orders | Share of sellers | Late orders | % of late orders | % of all orders | Late share / order share |
|---|---|---|---|---|---|
| 10 | 0.3% | 1,193 | 15.3 | 13.8 | 1.11 |
| 25 | 0.9% | 2,090 | 26.8 | 22.7 | 1.18 |
| 50 | 1.7% | 2,905 | 37.2 | 32.3 | 1.15 |
| 100 | 3.4% | 3,876 | 49.7 | 43.0 | 1.16 |
| 250 | 8.5% | 5,388 | 69.0 | 59.8 | 1.15 |

- Late orders are concentrated among large sellers, roughly in proportion to their order volume. The top 250 sellers by late orders (8.5% of sellers) handle 59.8% of orders and produce 69.0% of late orders.
- Their share of late orders is only 1.1 to 1.2 times their share of orders. The top 250 sellers' late rate is about 9.5% against about 6.3% for the rest (calculated from rounded shares), but part of this difference is mechanical, because sellers are ranked on the number of late orders. Section 10 shows that late rates do not differ by seller size.
- The 10 sellers with the most late orders account for 15.3% of late orders. If the top 100 had delivered at the overall late rate, there would be roughly 520 fewer late orders, about 7% of the total (approximate).
- Ranking by number of late orders favours high-volume sellers, so this table does not identify unusually unreliable sellers.

## 10. Late rate by seller order volume

Late rates are pooled over all orders in each band. The two share columns are calculated from the table.

| Seller order volume | Sellers | Orders | % of orders | Late orders | % of late orders | Late % |
|---|---|---|---|---|---|---|
| 1 order | 524 | 524 | 0.6 | 54 | 0.7 | 10.3 |
| 2 to 5 | 809 | 2,573 | 2.7 | 216 | 2.8 | 8.4 |
| 6 to 20 | 830 | 9,162 | 9.7 | 791 | 10.1 | 8.6 |
| 21 to 100 | 562 | 26,290 | 27.7 | 2,115 | 27.1 | 8.0 |
| More than 100 | 200 | 56,382 | 59.4 | 4,628 | 59.3 | 8.2 |

- Late rates are similar across seller size bands (8.0% to 8.6% for sellers with more than one order, against 8.2% overall), and each band's share of late orders matches its share of orders.
- Seller size does not predict lateness. Large sellers account for most late orders because they handle most orders.
- The 10.3% rate for sellers with one order rests on 524 orders from 524 different sellers and has a margin of roughly 2.6 percentage points, so it is not clearly different from the overall rate.
- A similar average within a band can hide very reliable and very unreliable individual sellers (sections 11 and 15).

## 11. Sellers with the highest late rate

Sellers with at least 50 orders, ranked by late rate (top 10). Average score includes reviews answered before and after delivery.

| Seller | State | Orders | Late orders | Late % | Average delivery days | Average score |
|---|---|---|---|---|---|---|
| 54965bbe... | PR | 72 | 22 | 30.6 | 26.4 | 3.18 |
| a49928bc... | SP | 93 | 25 | 26.9 | 17.0 | 3.09 |
| beadbee3... | SP | 63 | 16 | 25.4 | 14.1 | 3.94 |
| cac4c8e7... | SP | 68 | 16 | 23.5 | 18.7 | 3.66 |
| 06a2c3af... | MA | 388 | 90 | 23.2 | 17.8 | 4.02 |
| 1ca7077d... | SP | 106 | 24 | 22.6 | 15.6 | 2.39 |
| 6039e272... | SP | 62 | 14 | 22.6 | 18.2 | 3.74 |
| 712e6ed8... | SC | 77 | 17 | 22.1 | 24.7 | 3.39 |
| ea566164... | SP | 50 | 11 | 22.0 | 14.0 | 3.78 |
| d13e50ea... | SP | 66 | 14 | 21.2 | 5.0 | 4.82 |

- The ten sellers have late rates of 21.2% to 30.6% (23.8% pooled over 1,045 orders) against 8.2% overall. A rough binomial check indicates that all ten are well above what chance variation around the overall rate would produce for their order counts.
- Together they account for 3.2% of late orders (249 of 7,804) from 1.1% of orders. At the overall late rate they would have about 86 late orders, so about 163 fewer (about 2.1% of all late orders; approximate).
- One seller in MA (388 orders, 90 late) accounts for about a third of the group's late orders. It is the only seller in the list outside the South and Southeast.
- Late rate and delivery speed are different: one SP seller has the fastest average delivery in the list (5.0 days) and a 4.82 average score but a 21.2% late rate, which may reflect tight estimated delivery dates (not tested).
- A seller's late rate also depends on where its customers are, and this table does not control for that.

## 12. RJ delivery performance by seller location

Single-seller delivered orders with a customer delivery date, customers in RJ (12,154 orders, 1,658 late). Periods and shares are calculated from the table.

| Period | Seller location | Orders | Late orders | Late % |
|---|---|---|---|---|
| Nov 2017 to Mar 2018 | SP | 2,895 | 976 | 33.7 |
| Nov 2017 to Mar 2018 | Outside SP | 1,407 | 258 | 18.3 |
| Other months | SP | 5,136 | 282 | 5.5 |
| Other months | Outside SP | 2,716 | 142 | 5.2 |

- Nov 2017 to Mar 2018 holds 35.4% of these orders and 74.4% of late orders (late rate 28.7% against 5.4% in other months).
- Outside the episode, late rates are the same for SP sellers and other sellers (5.5% and 5.2%).
- During the episode the late rate rose to 33.7% for SP sellers (about 6 times their normal rate) and 18.3% for other sellers (about 3.5 times).
- Against each group's own normal late rate, the episode produced about 1,000 extra late orders, about 817 (82%) from SP sellers and about 184 from other sellers. SP sellers send 67% of RJ orders, and that share barely changed between periods.
- The data does not show why SP shipments were hit harder. Carrier or route causes cannot be tested because the data has no carrier field.
- "Outside SP" combines many states, including sellers in RJ itself.

## 13. Concentration of late orders among sellers, RJ episode

Customers in RJ, Nov 2017 to Mar 2018 (4,302 orders, 1,234 late orders, 853 sellers). Sellers are ranked by their number of late orders. Orders and late rates are calculated from the table and rounded percentages.

| Top sellers by late orders | Late orders | % of late orders | % of orders | Late rate |
|---|---|---|---|---|
| 5 | 177 | 14.3 | 10.6 | about 38.8% |
| 10 | 269 | 21.8 | 17.1 | about 36.5% |
| 20 | 399 | 32.3 | 26.7 | about 34.7% |
| 50 | 603 | 48.9 | 38.8 | about 36.1% |
| All other sellers (803) | 631 | 51.1 | 61.2 | about 24.0% |

- Late orders in the episode are only mildly concentrated. The top 50 sellers by late orders (5.9% of sellers) handle 38.8% of orders and produce 48.9% of late orders.
- The other 803 sellers had a late rate of about 24%, more than four times RJ's late rate outside the episode (5.4%), so the deterioration was broad.
- Ranking by late orders favours sellers with more orders, so part of the difference between the top 50 and the rest is mechanical.
- Together with section 12 and section 14 of `06_delivery_and_reviews` (SP and non-SP sellers both affected, SP and MG also worse in the same months), the pattern points to a cause on the delivery side and not to specific sellers. The data has no carrier or route field, so the cause cannot be identified.

## 14. SP customers: seller in SP versus seller elsewhere

Customers in SP (39,834 orders). Holding the customer's state fixed isolates the effect of seller location.

| Seller location | Orders | Share | Average days | Median days | Late % |
|---|---|---|---|---|---|
| Seller in SP | 30,254 | 76.0% | 7.9 | 6.6 | 6.3 |
| Seller outside SP | 9,580 | 24.0% | 11.4 | 9.7 | 4.9 |

- For SP customers, orders from sellers outside SP take about 3 days longer (average 11.4 against 7.9 days, median 9.7 against 6.6), so distance from the seller increases delivery time.
- The late rate is lower for orders from sellers outside SP (4.9% against 6.3%), consistent with longer estimated delivery times on longer routes (EDA section 9).
- Distance from the seller therefore increases delivery time without increasing lateness. The higher late rate on cross-state orders in section 7 mainly reflects which customers those orders serve (an inference from comparing the two tables).
- "Outside SP" includes nearby states such as MG and PR as well as distant ones, so the gap averages over very different distances.

## 15. Established sellers by late-rate band

Sellers with at least 50 orders. The last column is the share of late orders among these sellers, not among all late orders. Shares and totals below are calculated from the table.

| Late-rate band | Sellers | Orders | Late orders | Late % | % of late orders among these sellers |
|---|---|---|---|---|---|
| 20% or more | 12 | 1,345 | 312 | 23.2 | 5.3 |
| 15% to under 20% | 22 | 2,420 | 404 | 16.7 | 6.9 |
| 10% to under 15% | 92 | 21,119 | 2,404 | 11.4 | 41.2 |
| Under 10% | 286 | 46,443 | 2,717 | 5.9 | 46.5 |
| Total | 412 | 71,327 | 5,837 | 8.2 | 100.0 |

- 412 of the 2,925 sellers (14.1%) have at least 50 orders. They handle 75.1% of orders and 74.8% of late orders, with a pooled late rate of 8.2%.
- 34 sellers (8.3% of established sellers) have late rates of 15% or more. They handle 5.3% of these sellers' orders and 12.3% of their late orders.
- The 92 sellers with late rates of 10% to under 15% account for 41.2% of late orders among established sellers, the largest share of any band after the best performers, so lateness is spread through the middle of the distribution and is not confined to the worst sellers.
- Illustration: if every seller above 10% had delivered at the rate of the best band (about 5.9%), there would be roughly 1,650 fewer late orders, about 28% of late orders among established sellers and about 21% of all late single-seller orders (approximate). Sellers differ in where their customers are, so this is not a realistic target for each seller.
- With 50 to a few hundred orders per seller, a seller's late rate carries a margin of several percentage points (about 4 points at 50 orders), so some sellers in the 10% to 15% band are there by chance.
- The 12 sellers in the top band include the 10 listed in section 11.

## Limits

- Delivery results are associations. A seller's late rate depends on its customers' locations, and no control for this was applied except in section 14.
- Seller averages hide wide differences between individual sellers. Small sellers have unstable rates.
- Revenue concentration reflects both seller activity and tenure within the 20-month window.
- The data has no carrier, route, or distance field, so causes of delays cannot be identified.
- Percentages marked as calculated from rounded values are approximations.
