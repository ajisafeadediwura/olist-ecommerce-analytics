# DAX Measures and Calculated Columns

Definitions used in the Power BI report. Table names are as set in the model (see `docs/data_model.md`): `Orders`, `Order Items`, `Customers`, `Sellers`, `Categories`, `States`, `Dates`, `Cohort Retention`, `Order Status`. Measures live in a table called `_Measures`.

## Scope notes

- Order, revenue, delivery, review, and payment measures respond to the date, region, and state filters, because `Orders` is filtered by `Dates` and `States`.
- Measures on `Customers` and `Sellers` are not affected by the date slicer. Those tables are filtered from the fact tables only in one direction, so their columns describe the whole window (Jan 2017 to Aug 2018).
- Late-delivery measures use `delivery_outcome` (an explicit text label) and not a comparison on `late_flag`. In DAX a blank value equals 0 in a comparison, so `late_flag = 0` would wrongly include orders with no delivery date.

## Calculated columns

Create each one in Table view (Table tools > New column). They give text bands a sensible sort order, and each is then used with Column tools > Sort by column.

```dax
-- Table: Orders
Card Installment Sort =
SWITCH(
    Orders[card_installment_band],
    "0 (invalid)", 0,
    "1", 1,
    "2 to 3", 2,
    "4 to 6", 3,
    "7 to 10", 4,
    "11 or more", 5
)
```

```dax
-- Table: Customers
Repeat Type Sort =
SWITCH(
    Customers[repeat_type],
    "One-time", 1,
    "Repeat, same day", 2,
    "Repeat, 1 to 30 days", 3,
    "Repeat, over 30 days", 4
)
```

```dax
-- Table: Sellers
Volume Band Sort =
SWITCH(
    Sellers[volume_band],
    "1 order", 1,
    "2 to 5 orders", 2,
    "6 to 20 orders", 3,
    "21 to 100 orders", 4,
    "More than 100 orders", 5,
    "No delivered orders", 6
)
```

Sort `Orders[card_installment_band]` by `Card Installment Sort`, `Customers[repeat_type]` by `Repeat Type Sort`, `Sellers[volume_band]` by `Volume Band Sort`, `Orders[lateness_band]` by `lateness_band_sort`, `Dates[month_name]` by `month_number`, and `Dates[day_name]` by `day_of_week_number`.

## Core measures

```dax
Revenue = SUM(Orders[revenue])

Orders Count = COUNTROWS(Orders)

Avg Order Value = DIVIDE([Revenue], [Orders Count])

Item Revenue = SUM('Order_Items'[price])

Freight = SUM(Orders[freight])

Freight % of Revenue = DIVIDE([Freight], [Revenue])

Customers Count = DISTINCTCOUNT(Orders[customer_unique_id])
```

## Growth, January to August

The data ends in August 2018, so year-on-year comparisons use matching months. These measures ignore the year slicer on purpose.

```dax
Revenue Jan-Aug 2017 =
CALCULATE([Revenue], Dates[calendar_year] = 2017, Dates[month_number] <= 8)

Revenue Jan-Aug 2018 =
CALCULATE([Revenue], Dates[calendar_year] = 2018)

Revenue Growth Jan-Aug =
DIVIDE([Revenue Jan-Aug 2018] - [Revenue Jan-Aug 2017], [Revenue Jan-Aug 2017])

Orders Jan-Aug 2017 =
CALCULATE([Orders Count], Dates[calendar_year] = 2017, Dates[month_number] <= 8)

Orders Jan-Aug 2018 =
CALCULATE([Orders Count], Dates[calendar_year] = 2018)

Orders Growth Jan-Aug =
DIVIDE([Orders Jan-Aug 2018] - [Orders Jan-Aug 2017], [Orders Jan-Aug 2017])
```

## Delivery and reviews

```dax
Late Rate = AVERAGE(Orders[late_flag])

Late Orders = CALCULATE(COUNTROWS(Orders), Orders[delivery_outcome] = "Late")

Avg Delivery Days = AVERAGE(Orders[delivery_days])

Avg Review Score = AVERAGE(Orders[review_score])

Reviewed Orders = COUNT(Orders[review_score])

Avg Score On Time =
CALCULATE([Avg Review Score], Orders[delivery_outcome] = "On time or early")

Avg Score Late =
CALCULATE([Avg Review Score], Orders[delivery_outcome] = "Late")

Avg Score After Delivery =
CALCULATE([Avg Review Score], Orders[review_timing] = "On or after delivery")

Reviews Before Delivery % =
DIVIDE(
    CALCULATE([Reviewed Orders], Orders[review_timing] = "Before delivery"),
    [Reviewed Orders]
)

1-Star Rate =
DIVIDE(
    CALCULATE([Reviewed Orders], Orders[review_score] = 1),
    [Reviewed Orders]
)
```

`Late Rate` works because `late_flag` is 1 for late, 0 for on time, and blank for the 8 orders with no delivery date. `AVERAGE` skips blanks.

## Customers and retention

These cover the whole window and ignore the date slicer.

```dax
Customer Base = COUNTROWS(Customers)

Repeat Customers = CALCULATE(COUNTROWS(Customers), Customers[orders] > 1)

Repeat Rate = DIVIDE([Repeat Customers], [Customer Base])

Returned After 30 Days =
CALCULATE(COUNTROWS(Customers), Customers[repeat_type] = "Repeat, over 30 days")

Returned After 30 Days Rate = DIVIDE([Returned After 30 Days], [Customer Base])

Customer Revenue = SUM(Customers[revenue])

Avg Revenue per Customer = DIVIDE([Customer Revenue], [Customer Base])

One-Time Revenue Share =
DIVIDE(CALCULATE([Customer Revenue], Customers[orders] = 1), [Customer Revenue])

Retention % =
DIVIDE(
    SUM('Cohort Retention'[active_customers]),
    SUM('Cohort Retention'[cohort_size])
)
```

In the cohort matrix each cell is one cohort and one month, so `Retention %` equals the retention for that cell. The total row sums over every cohort that can be observed at that month, which is the pooled retention used in the SQL analysis.

## Payments

```dax
Avg Paid = AVERAGE(Orders[paid_value])

Share of Orders by Payment Type =
DIVIDE(
    [Orders Count],
    CALCULATE([Orders Count], ALL(Orders[primary_payment_type]))
)
```

## Sellers, routes, and products

```dax
Active Sellers = DISTINCTCOUNT('Order Items'[seller_id])

Seller Revenue = SUM(Sellers[revenue])

Top 30 Sellers Revenue Share =
DIVIDE(
    MAXX(FILTER(Sellers, Sellers[revenue_rank] = 30), Sellers[cum_revenue_pct]),
    100
)

Seller Late Rate = DIVIDE(SUM(Sellers[late_orders]), SUM(Sellers[delivery_orders]))

Cross-State Order Share =
DIVIDE(
    CALCULATE([Orders Count], Orders[route] = "Different state"),
    CALCULATE([Orders Count], Orders[route] <> "Multiple sellers")
)

Item Freight = SUM('Order Items'[freight_value])

Item Freight % = DIVIDE([Item Freight], [Item Revenue])

Category Revenue Share =
DIVIDE([Item Revenue], CALCULATE([Item Revenue], ALL(Categories)))
```

`Category Revenue Share` is a measure because the built-in "percent of grand total" option would recalculate against only the rows left after a Top N filter.

## Formats

| Measure | Format |
|---|---|
| Revenue, Freight, Item Revenue, Seller Revenue, Customer Revenue, Avg Order Value, Avg Paid, Avg Revenue per Customer | Number, 2 decimals (0 decimals for the large totals), thousands separator |
| Orders Count, Customers Count, Customer Base, Late Orders, Active Sellers, Reviewed Orders | Whole number, thousands separator |
| Late Rate, Freight % of Revenue, Item Freight %, all Growth, Share and Rate measures | Percentage, 1 decimal (2 for Repeat Rate, Retention %, and Returned After 30 Days Rate) |
| Avg Review Score, Avg Score measures | Decimal, 2 places |
| Avg Delivery Days | Decimal, 1 place |
