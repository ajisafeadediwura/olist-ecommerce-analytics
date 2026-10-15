# Connecting Power BI to Databricks

How the Power BI report reads the model views from Databricks, and how to rebuild the connection. Credentials are not stored in this repository.

## Setup

| Item | Value |
|---|---|
| Reporting tool | Power BI Desktop |
| Data source | Databricks SQL warehouse (serverless) |
| Connector | Databricks (Home > Get Data > Databricks) |
| Connectivity mode | Import |
| Schema | `workspace.olist` |
| Authentication | Personal access token |
| Connected | October 2026 |

## Views loaded

The nine `pbi_` views created by `sql/08_powerbi_views.sql`:

| View | Power BI table name |
|---|---|
| `pbi_fact_orders` | Orders |
| `pbi_fact_order_items` | Order Items |
| `pbi_dim_customer` | Customers |
| `pbi_dim_seller` | Sellers |
| `pbi_dim_category` | Categories |
| `pbi_dim_state` | States |
| `pbi_dim_date` | Dates |
| `pbi_cohort_retention` | Cohort Retention |
| `pbi_order_status_by_month` | Order Status |

Column definitions, grain, and relationships are in `docs/data_model.md`.

![Power BI Navigator with the nine pbi_ views selected]
<img width="1366" height="721" alt="powerbi 4" src="https://github.com/user-attachments/assets/44c6c462-383e-45eb-a614-4aa33ec68bbd" />



*The Navigator showing the nine views under `workspace` > `olist`. Connection details are redacted.*

## How to reproduce

1. Run `sql/01_setup_and_load.sql` to `sql/08_powerbi_views.sql` in order in a Databricks workspace, so that the views exist in `workspace.olist`.
2. Open the SQL warehouse in Databricks, go to the Connection details tab, and note the server hostname and HTTP path.
3. Create a personal access token in the workspace's developer settings. Copy it when it is shown, because it cannot be displayed again.
4. In Power BI Desktop, choose Get Data > Databricks, enter the server hostname and HTTP path, and select Import.
5. Sign in with the personal access token.
6. In the Navigator, expand `workspace` > `olist`, tick the nine `pbi_` views, and click Load.
7. Rename the tables as in the table above.
8. In Model view, create the six relationships listed below.
9. Mark `Dates` as the date table using `calendar_date`, and sort `month_name` by `month_number`, `day_name` by `day_of_week_number`, and `lateness_band` by `lateness_band_sort`.
10. Check the model against the reconciliation measures below.

## Relationships

All are many to one with single-direction filtering. `Cohort Retention` and `Order Status` are not related to other tables.

| Many side | One side |
|---|---|
| `Orders[order_date]` | `Dates[calendar_date]` |
| `Orders[customer_state]` | `States[state_code]` |
| `Orders[customer_unique_id]` | `Customers[customer_unique_id]` |
| `Order Items[order_id]` | `Orders[order_id]` |
| `Order Items[category_pt]` | `Categories[category_pt]` |
| `Order Items[seller_id]` | `Sellers[seller_id]` |

`Sellers` is deliberately not related to `Orders`, because that would create a second path between sellers and orders through the items.

![Power BI model view showing the six relationships]
<img width="1366" height="721" alt="image" src="https://github.com/user-attachments/assets/25d63769-2f9d-4237-b361-dc291dce92f2" />


*Model view with the star layout and the six relationships.*

## Reconciliation

Four measures confirm that the model matches the SQL analysis. `Revenue` and `Item Revenue` reach the same total by two independent routes (orders and items), so agreement also confirms that the order-to-item relationship works.

```dax
Revenue = SUM(Orders[revenue])

Orders Count = COUNTROWS(Orders)

Avg Order Value = DIVIDE([Revenue], [Orders Count])

Item Revenue = SUM('Order Items'[price])
```

| Measure | Expected | Source of the expected value |
|---|---|---|
| Revenue | 13,181,027.13 | Headline KPIs, `docs/eda_findings.md` |
| Orders Count | 96,211 | Headline KPIs, `docs/eda_findings.md` |
| Avg Order Value | 137.00 | Headline KPIs, `docs/eda_findings.md` |
| Item Revenue | 13,181,027.13 | Headline KPIs, `docs/eda_findings.md` |

Expected row counts for each table are in `docs/data_model.md`.

![Four card visuals showing revenue, orders, average order value, and item revenue]
<img width="1366" height="721" alt="image" src="https://github.com/user-attachments/assets/defbd973-fda2-4898-afcc-151d6b8cd8b7" />


*Card visuals for the four measures.*

## Refresh

The data is imported, so the report shows the data as of the last refresh. A refresh needs the SQL warehouse to be running (it may take a minute to start) and a valid token. Personal access tokens expire, and a new one must be created when that happens. If the SQL views change, refresh the report to pick up the new definitions.

## Security

- The server hostname, HTTP path, and token are not stored in this repository. Screenshots have them redacted.
- The `.pbix` file is not committed. It contains the imported data and the connection details, and the raw data is a public Kaggle dataset that is not redistributed here. A PDF export and screenshots of the finished report are in `powerbi/`.
- If a token is ever exposed, revoke it from the workspace's access tokens page and create a new one.

## Limitations

- The report is an import model, so it does not update on its own.
- The connection is set up for one workspace. To use another, create the views there and enter that workspace's hostname, HTTP path, and token.
- The source data is a public Kaggle dataset, and the raw files are not stored in this repository.
