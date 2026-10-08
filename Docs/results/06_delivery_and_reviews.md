# Script 06 Results: Delivery and Reviews

Output of `sql/06_delivery_and_reviews.sql`, in cell order. Scope: delivered orders with a customer delivery date, Jan 2017 to Aug 2018. One review per order (the most recent). An order is late if it arrived after its estimated delivery timestamp.

## Summary

- Review coverage is 99.33% (95,560 of 96,203 delivered orders).
- Late orders are 8.0% of reviewed orders. They average 2.57 against 4.29 for on-time orders.
- 4.86% of reviews were answered before the recorded delivery date. 96.4% of those belong to late orders, and 58.5% of late orders were reviewed before the parcel arrived.
- Among customers who reviewed on or after delivery, scores fall gradually with lateness (4.30, 3.90, 3.69, 3.54). Most of the sharp drop in the combined data comes from customers reviewing while still waiting.
- The lateness penalty is positive in every state tested (gaps of 0.26 to 0.53 points).
- Orders placed in the Black Friday week took 5.0 days longer than the baseline, 20.1% arrived late, and the average score fell to 3.82. The share of orders delivered, cancelled, or left undelivered was not worse than in the rest of the window.
- RJ's late-delivery problem is concentrated in Nov 2017 to Mar 2018. Outside those months its late rate is close to that of SP and MG.

---

## 2. Check: one review per order

| rows_in_view | distinct_orders |
|---|---|
| 98,673 | 98,673 |

The view holds exactly one row per order and matches the distinct order count from profiling.

## 4. Review coverage

| Delivered orders | With review | Coverage % |
|---|---|---|
| 96,203 | 95,560 | 99.33 |

## 5. On time versus late

| Delivery | Reviewed orders | Average score | 1-star share | 5-star share |
|---|---|---|---|---|
| On time or early | 87,902 | 4.29 | 6.6% | 62.5% |
| Late | 7,658 | 2.57 | 46.2% | 22.2% |

- Late orders are 8.0% of reviewed orders and about 38% of all 1-star reviews (calculated from rounded shares).

## 6. Lateness bands (all reviews)

| Lateness | Reviewed orders | Average score | 1-star share |
|---|---|---|---|
| On time or early | 87,902 | 4.29 | 6.6% |
| Up to 3 days late | 2,635 | 3.77 | 13.8% |
| 3 to 7 days late | 1,773 | 2.32 | 53.0% |
| More than 7 days late | 3,250 | 1.73 | 68.8% |

This table mixes reviews answered before and after delivery. Read it together with section 9.

## 7. Reviews answered before delivery

| Reviewed orders | Answered before delivery | % before delivery |
|---|---|---|
| 95,560 | 4,648 | 4.86 |

## 8. On time versus late, by review timing

| Delivery | Review timing | Reviewed orders | Average score | 1-star share |
|---|---|---|---|---|
| Late | Before delivery | 4,479 | 1.66 | 70.8% |
| Late | On or after delivery | 3,179 | 3.85 | 11.5% |
| On time or early | Before delivery | 169 | 4.01 | 13.0% |
| On time or early | On or after delivery | 87,733 | 4.30 | 6.6% |

- 96.4% of reviews answered before delivery belong to late orders, and 58.5% of late orders were reviewed before the parcel arrived.
- Among customers who reviewed on or after delivery, late orders score 3.85 against 4.30 (a gap of 0.45 points) and are about 1.7 times as likely to receive 1 star.
- Late orders reviewed before delivery average 1.66, with 70.8% giving 1 star. They are 4.7% of reviewed orders and an estimated third of all 1-star reviews (calculated from rounded shares).

## 9. Lateness bands, by review timing

| Lateness | Review timing | Reviewed orders | Average score | 1-star share |
|---|---|---|---|---|
| On time or early | Before delivery | 169 | 4.01 | 13.0% |
| On time or early | On or after delivery | 87,733 | 4.30 | 6.6% |
| Up to 3 days late | Before delivery | 182 | 1.94 | 61.5% |
| Up to 3 days late | On or after delivery | 2,453 | 3.90 | 10.2% |
| 3 to 7 days late | Before delivery | 1,172 | 1.61 | 72.6% |
| 3 to 7 days late | On or after delivery | 601 | 3.69 | 14.8% |
| More than 7 days late | Before delivery | 3,125 | 1.66 | 70.7% |
| More than 7 days late | On or after delivery | 125 | 3.54 | 20.0% |

Share of reviews answered before delivery, by band:

| Lateness | Reviewed orders | Answered before delivery |
|---|---|---|
| Up to 3 days late | 2,635 | 6.9% |
| 3 to 7 days late | 1,773 | 66.1% |
| More than 7 days late | 3,250 | 96.2% |

- Among customers who reviewed on or after delivery, scores fall gradually with lateness: 4.30, 3.90, 3.69, 3.54. The 1-star share rises from 6.6% to 10.2%, 14.8%, and 20.0%.
- The steep fall across the late bands in section 6 comes mainly from the change in review timing, not from a threshold in dissatisfaction after delivery.
- The two far-end groups reviewed on or after delivery rest on 601 and 125 orders.

## 10. Lateness penalty within states

Reviews answered on or after delivery. States with at least 100 late orders in that group.

| State | Reviewed orders | Late orders | Average score, on time | Average score, late | Gap |
|---|---|---|---|---|---|
| SC | 3,319 | 154 | 4.30 | 3.77 | 0.53 |
| RJ | 10,975 | 453 | 4.25 | 3.75 | 0.50 |
| MG | 10,906 | 295 | 4.28 | 3.83 | 0.45 |
| SP | 39,037 | 1,261 | 4.33 | 3.89 | 0.44 |
| PR | 4,745 | 124 | 4.31 | 3.93 | 0.38 |
| RS | 5,056 | 138 | 4.31 | 3.96 | 0.36 |
| BA | 2,929 | 152 | 4.15 | 3.89 | 0.26 |

- Late orders score lower than on-time orders in every state tested. The seven states cover 84.7% of reviews answered on or after delivery and 81.1% of late orders in that group.
- Late scores fall in a narrow range (3.75 to 3.96) while on-time scores vary more (4.15 to 4.33), so differences in the gap mostly reflect the on-time baseline.
- Differences of a few hundredths between states are not interpreted. The check controls for state only, not for seller or product category.

## 11. Black Friday week

| Period | Delivered orders | Average delivery days | Late % | Average review score |
|---|---|---|---|---|
| 1 to 23 Nov 2017 | 3,932 | 13.5 | 9.3 | 4.13 |
| 24 to 30 Nov 2017 (Black Friday week) | 3,356 | 17.1 | 20.1 | 3.82 |
| Dec 2017 | 5,513 | 15.4 | 8.4 | 4.09 |
| All other months | 83,402 | 12.1 | 7.6 | 4.18 |

- Orders placed in the Black Friday week took 17.1 days on average, 5.0 days (41%) longer than the baseline, and 20.1% arrived late, about 2.6 times the baseline rate.
- Applying the overall on-time and late average scores to each period's late share predicts about 3.94 for the Black Friday week and 4.16 for the baseline (actual 4.18). The higher late share explains roughly 60% of the score drop (rough illustration).
- The week was 3.5% of delivered orders and an estimated 8.6% of late deliveries (calculated from rounded late percentages).
- December returned close to baseline on late rate and score, although average delivery time stayed elevated (15.4 days). This may reflect longer estimated delivery dates, which was not checked.

## 12. Order outcomes in the Black Friday week

| Period | All orders | Delivered | Canceled | Other, not delivered |
|---|---|---|---|---|
| Black Friday week | 3,439 | 97.62% | 0.12% | 2.27% |
| Rest of window | 95,653 | 97.07% | 0.60% | 2.32% |

- The surge appears as slower and later delivery, not as a higher share of undelivered orders. The week's canceled count is about 4 orders, too few to interpret.

## 13. Delivery-time tail in SP, MG, and RJ

| State | Orders | Median days | 90th percentile | 95th percentile | Over 30 days | Late % |
|---|---|---|---|---|---|---|
| SP | 40,399 | 7.2 | 15.7 | 19.9 | 1.2% | 5.9% |
| MG | 11,319 | 10.3 | 20.2 | 24.4 | 2.3% | 5.6% |
| RJ | 12,310 | 12.0 | 29.1 | 38.3 | 9.4% | 13.5% |

- RJ's median delivery time is close to MG's, but its slow end is much longer: 9.4% of RJ orders took more than 30 days against 2.3% (MG) and 1.2% (SP).
- RJ's promise buffer is similar to SP's and MG's (EDA section 9), so the lateness comes from a tail of very slow orders, not from tight estimates.

## 14. RJ late rate by month

| Month | RJ orders | RJ late % | SP and MG late % |
|---|---|---|---|
| 2017-01 | 91 | 4.4 | 2.1 |
| 2017-02 | 230 | 3.9 | 2.5 |
| 2017-03 | 370 | 5.1 | 3.2 |
| 2017-04 | 325 | 8.0 | 7.0 |
| 2017-05 | 466 | 3.4 | 4.3 |
| 2017-06 | 399 | 3.8 | 3.7 |
| 2017-07 | 547 | 3.7 | 2.2 |
| 2017-08 | 537 | 3.4 | 2.4 |
| 2017-09 | 591 | 5.9 | 3.2 |
| 2017-10 | 654 | 8.3 | 3.4 |
| 2017-11 | 1,012 | 28.1 | 8.8 |
| 2017-12 | 746 | 26.1 | 3.7 |
| 2018-01 | 850 | 14.7 | 3.9 |
| 2018-02 | 879 | 35.9 | 9.1 |
| 2018-03 | 864 | 36.9 | 14.3 |
| 2018-04 | 807 | 5.9 | 2.3 |
| 2018-05 | 816 | 8.1 | 6.7 |
| 2018-06 | 707 | 1.4 | 0.8 |
| 2018-07 | 696 | 3.6 | 4.6 |
| 2018-08 | 723 | 8.3 | 13.4 |

- RJ's late rate is about 2.3 times that of SP and MG over the whole window, but the difference is concentrated in five months. From Nov 2017 to Mar 2018 RJ's monthly late rate was 14.7% to 36.9%. Those months hold 35% of RJ's orders and an estimated 75% of its late orders (calculated from rounded monthly rates).
- Outside that period RJ's late rate is about 5% to 6%, similar to SP and MG over the whole window.
- SP and MG were also worse in Nov 2017, Feb 2018, and Mar 2018, so part of the episode was not specific to RJ. In Dec 2017 and Jan 2018 RJ was far worse than SP and MG.
- The monthly view shows when late deliveries occurred, not why. Months before Mar 2017 rest on fewer than 400 RJ orders each.

## Limits

- Late-delivery and review results are associations. Late orders also cluster in particular states, sellers, and periods.
- Review scores answered before delivery cannot reflect the delivery itself. Section 9 reports both timings separately.
- Percentages marked as calculated from rounded values are approximations.
